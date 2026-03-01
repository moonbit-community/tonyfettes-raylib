///|
fn set_status(game : @types.Game, text : String, ttl : Float) -> Unit {
  game.status_text = text
  game.status_t = ttl
}

///|
fn preferred_alive_beacon(game : @types.Game, preferred : Int) -> Int {
  if preferred >= 0 &&
    preferred < game.beacons.length() &&
    game.beacons[preferred].integrity > 0.0 {
    return preferred
  }

  let mut best_index = -1
  let mut best_integrity : Float = -1.0

  for i in 0..<game.beacons.length() {
    if game.beacons[i].integrity > best_integrity {
      best_integrity = game.beacons[i].integrity
      best_index = i
    }
  }

  if best_integrity <= 0.0 {
    -1
  } else {
    best_index
  }
}

///|
fn reset_player(player : @types.Player) -> Unit {
  player.x = Float::from_int(@types.world_x + 330)
  player.y = @types.lane_y(1)
  player.facing_x = 1.0
  player.facing_y = 0.0
  player.dash_vx = 0.0
  player.dash_vy = 0.0
  player.dash_t = 0.0
  player.dash_cd = 0.0
  player.attack_cd = 0.0
  player.attack_t = 0.0
}

///|
fn reset_beacons(game : @types.Game) -> Unit {
  for beacon in game.beacons {
    beacon.integrity = @types.beacon_integrity_max
    beacon.pulse_t = 0.0
  }
}

///|
fn reset_traps(game : @types.Game) -> Unit {
  for trap in game.traps {
    trap.active = false
    trap.trigger_cd = 0.0
    trap.flash_t = 0.0
  }
}

///|
fn reset_enemies(game : @types.Game) -> Unit {
  for enemy in game.enemies {
    enemy.active = false
    enemy.slow_t = 0.0
    enemy.anim_t = 0.0
  }
}

///|
fn begin_night(game : @types.Game, night : Int) -> Unit {
  game.night = night
  game.spawn_pool = @types.night_spawn_base + (night - 1) * @types.night_spawn_step
  game.spawn_cd = 0.84
  game.night_banner_t = @types.night_banner_time
}

///|
fn start_new_run(game : @types.Game) -> Unit {
  game.state = @types.state_playing
  game.score = 0
  game.kills = 0
  game.elapsed = 0.0
  game.energy = 74.0
  game.sweep_charge = 24.0
  game.trap_place_cd = 0.0
  game.sweep_t = 0.0
  game.shake_t = 0.0
  game.game_over_reason = ""

  reset_player(game.player)
  reset_beacons(game)
  reset_traps(game)
  reset_enemies(game)

  begin_night(game, 1)
  set_status(game, "Night 1 begins. Protect every shrine beacon.", 2.4)
}

///|
fn end_run_game_over(game : @types.Game, reason : String) -> Unit {
  game.state = @types.state_game_over
  game.game_over_reason = reason
  set_status(game, "Sanctum fallen. Press R to restart.", 2.2)
}

///|
fn update_player_movement(game : @types.Game, dt : Float) -> Unit {
  let mut move_x = Float::from_int(game.input.move_x)
  let mut move_y = Float::from_int(game.input.move_y)

  if move_x != 0.0 || move_y != 0.0 {
    let (nx, ny) = @types.normalize2(move_x, move_y)
    move_x = nx
    move_y = ny
    game.player.facing_x = nx
    game.player.facing_y = ny
  }

  if game.player.dash_t > 0.0 {
    game.player.x = game.player.x + game.player.dash_vx * dt
    game.player.y = game.player.y + game.player.dash_vy * dt
  } else {
    game.player.x = game.player.x + move_x * @types.player_speed * dt
    game.player.y = game.player.y + move_y * @types.player_speed * dt
  }

  let min_x = Float::from_int(@types.world_x) + @types.player_radius + 6.0
  let max_x = Float::from_int(@types.world_x + @types.world_w) -
    @types.player_radius -
    6.0
  let min_y = Float::from_int(@types.world_y) + @types.player_radius + 6.0
  let max_y = Float::from_int(@types.world_y + @types.world_h) -
    @types.player_radius -
    6.0

  game.player.x = @types.clampf(game.player.x, min_x, max_x)
  game.player.y = @types.clampf(game.player.y, min_y, max_y)
}

///|
fn nearest_trap_slot(
  game : @types.Game,
  want_active : Bool,
  max_distance : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = @types.squaref(max_distance)

  for i in 0..<game.traps.length() {
    if game.traps[i].active != want_active {
      continue
    }

    let d2 = @types.dist2(
      game.player.x,
      game.player.y,
      game.traps[i].x,
      game.traps[i].y,
    )
    if d2 <= best_d2 {
      best = i
      best_d2 = d2
    }
  }

  best
}

///|
fn try_place_trap(game : @types.Game) -> Bool {
  if game.trap_place_cd > 0.0 || game.energy < @types.trap_place_energy_cost {
    return false
  }

  let slot = nearest_trap_slot(game, false, @types.trap_place_range)
  if slot < 0 {
    return false
  }

  game.traps[slot].active = true
  game.traps[slot].trigger_cd = 0.0
  game.traps[slot].flash_t = @types.trap_flash_time

  game.trap_place_cd = @types.trap_place_cooldown
  game.energy = @types.clampf(
    game.energy - @types.trap_place_energy_cost,
    0.0,
    @types.energy_max,
  )
  set_status(game, "Bamboo snare placed.", 0.8)

  true
}

///|
fn try_remove_trap(game : @types.Game) -> Bool {
  let slot = nearest_trap_slot(game, true, @types.trap_remove_range)
  if slot < 0 {
    return false
  }

  game.traps[slot].active = false
  game.traps[slot].trigger_cd = 0.2
  game.traps[slot].flash_t = @types.trap_flash_time

  game.energy = @types.clampf(
    game.energy + @types.trap_remove_refund,
    0.0,
    @types.energy_max,
  )
  set_status(game, "Trap recovered.", 0.7)

  true
}

///|
fn register_kill(game : @types.Game, enemy_kind : Int) -> Unit {
  game.kills = game.kills + 1

  let gain_score = @types.score_kill_base + (game.night - 1) * 6 + enemy_kind * 9
  game.score = game.score + gain_score

  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.energy = @types.clampf(game.energy + 4.8, 0.0, @types.energy_max)
  game.sweep_charge = @types.clampf(
    game.sweep_charge + @types.sweep_charge_kill,
    0.0,
    @types.sweep_charge_max,
  )
}

///|
fn damage_enemy(
  game : @types.Game,
  enemy_index : Int,
  damage : Float,
  slow_t : Float,
) -> Bool {
  if enemy_index < 0 || enemy_index >= game.enemies.length() {
    return false
  }

  if not(game.enemies[enemy_index].active) {
    return false
  }

  game.enemies[enemy_index].hp = game.enemies[enemy_index].hp - damage
  if slow_t > 0.0 {
    game.enemies[enemy_index].slow_t = @types.maxf(
      game.enemies[enemy_index].slow_t,
      slow_t,
    )
  }

  if game.enemies[enemy_index].hp <= 0.0 {
    let kind = game.enemies[enemy_index].kind
    game.enemies[enemy_index].active = false
    register_kill(game, kind)
    return true
  }

  false
}

///|
fn perform_basic_attack(game : @types.Game) -> Unit {
  if game.player.attack_cd > 0.0 ||
    game.energy < @types.basic_attack_energy_cost {
    return
  }

  game.player.attack_cd = @types.basic_attack_cooldown
  game.player.attack_t = @types.attack_flash_time
  game.energy = @types.clampf(
    game.energy - @types.basic_attack_energy_cost,
    0.0,
    @types.energy_max,
  )

  let mut hits = 0
  let mut kills = 0

  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    let radius = @types.enemy_hit_radius(game.enemies[i].kind)
    let reach = @types.basic_attack_range + radius
    let dx = game.enemies[i].x - game.player.x
    let dy = game.enemies[i].y - game.player.y
    let d2 = dx * dx + dy * dy

    if d2 > @types.squaref(reach) {
      continue
    }

    let inv_len : Float = Float::from_int(1) / @types.maxf(d2.sqrt(), 0.001)
    let dot = dx * inv_len * game.player.facing_x +
      dy * inv_len * game.player.facing_y

    if dot < @types.basic_attack_arc_dot {
      continue
    }

    hits = hits + 1
    game.sweep_charge = @types.clampf(
      game.sweep_charge + @types.sweep_charge_hit,
      0.0,
      @types.sweep_charge_max,
    )

    if damage_enemy(game, i, @types.basic_attack_damage, 0.26) {
      kills = kills + 1
    }
  }

  if hits == 0 {
    set_status(game, "Slash missed.", 0.6)
  } else if kills > 0 {
    set_status(game, "Slash cut through \{kills} infiltrator(s).", 0.9)
  } else {
    set_status(game, "Slash connected.", 0.6)
  }
}

///|
fn start_dash(game : @types.Game) -> Unit {
  if game.player.dash_t > 0.0 || game.player.dash_cd > 0.0 {
    return
  }

  if game.energy < @types.dash_energy_cost {
    set_status(game, "Not enough energy to dash.", 0.7)
    return
  }

  let mut dir_x = Float::from_int(game.input.move_x)
  let mut dir_y = Float::from_int(game.input.move_y)

  if dir_x == 0.0 && dir_y == 0.0 {
    dir_x = game.player.facing_x
    dir_y = game.player.facing_y
  }

  let (nx, ny) = @types.normalize2(dir_x, dir_y)
  if nx == 0.0 && ny == 0.0 {
    return
  }

  game.energy = @types.clampf(
    game.energy - @types.dash_energy_cost,
    0.0,
    @types.energy_max,
  )
  game.player.dash_cd = @types.dash_cooldown
  game.player.dash_t = @types.dash_time
  game.player.dash_vx = nx * @types.dash_speed
  game.player.dash_vy = ny * @types.dash_speed

  set_status(game, "Shadow dash.", 0.6)
}

///|
fn trigger_sweep(game : @types.Game) -> Unit {
  if game.sweep_charge < @types.sweep_charge_max {
    return
  }

  game.sweep_charge = 0.0
  game.sweep_t = @types.sweep_fx_time
  game.player.attack_t = @types.maxf(
    game.player.attack_t,
    @types.attack_flash_time * 1.3,
  )
  game.shake_t = @types.maxf(game.shake_t, 0.12)

  let mut hits = 0
  let mut kills = 0

  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    let radius = @types.enemy_hit_radius(game.enemies[i].kind)
    let reach = @types.sweep_radius + radius

    if @types.dist2(
        game.player.x,
        game.player.y,
        game.enemies[i].x,
        game.enemies[i].y,
      ) <=
      @types.squaref(reach) {
      hits = hits + 1
      if damage_enemy(game, i, @types.sweep_damage, 0.65) {
        kills = kills + 1
      }
    }
  }

  if kills > 0 {
    set_status(game, "Moon sweep erased \{kills} infiltrator(s).", 1.2)
  } else if hits > 0 {
    set_status(game, "Moon sweep staggered the wave.", 0.9)
  } else {
    set_status(game, "Moon sweep found no target.", 0.9)
  }
}

///|
fn handle_player_actions(game : @types.Game) -> Unit {
  if game.input.press_k {
    ignore(try_remove_trap(game))
  }

  if game.input.press_j {
    if not(try_place_trap(game)) {
      perform_basic_attack(game)
    }
  }

  if game.input.press_space {
    if game.sweep_charge >= @types.sweep_charge_max {
      trigger_sweep(game)
    } else {
      start_dash(game)
    }
  }
}

///|
fn free_enemy_slot(game : @types.Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_enemy(game : @types.Game) -> Bool {
  let slot = free_enemy_slot(game)
  if slot < 0 {
    return false
  }

  let route_count = @types.spawn_route_count(game.night)
  let route = @raylib.get_random_value(0, route_count - 1)
  let target = preferred_alive_beacon(game, @types.spawn_route_target(route))

  if target < 0 {
    return false
  }

  let (sx, sy) = @types.spawn_route_position(route)

  let mut kind = @raylib.get_random_value(0, 2)
  if game.night >= 6 && @types.randf(0.0, 1.0) < 0.24 {
    kind = 2
  }

  let night_scale = Float::from_int(@types.maxi(game.night - 1, 0))
  let mut hp = @types.enemy_hp_base +
    night_scale * @types.enemy_hp_step +
    @types.randf(-4.0, 10.0)
  let mut speed = @types.enemy_speed_base +
    night_scale * @types.enemy_speed_step +
    @types.randf(-5.0, 12.0)
  let mut damage = @types.enemy_damage_base +
    night_scale * @types.enemy_damage_step

  match kind {
    1 => {
      hp = hp - 10.0
      speed = speed + 22.0
    }
    2 => {
      hp = hp + 24.0
      speed = speed - 12.0
      damage = damage + 3.0
    }
    _ => ()
  }

  game.enemies[slot].active = true
  game.enemies[slot].x = sx
  game.enemies[slot].y = sy
  game.enemies[slot].vx = 0.0
  game.enemies[slot].vy = 0.0
  game.enemies[slot].hp = hp
  game.enemies[slot].max_hp = hp
  game.enemies[slot].speed = @types.maxf(42.0, speed)
  game.enemies[slot].damage = damage
  game.enemies[slot].target = target
  game.enemies[slot].slow_t = 0.0
  game.enemies[slot].kind = kind
  game.enemies[slot].anim_t = @types.randf(0.0, 6.28)

  true
}

///|
fn update_spawning(game : @types.Game, dt : Float) -> Unit {
  if game.spawn_pool <= 0 {
    return
  }

  game.spawn_cd = game.spawn_cd - dt
  if game.spawn_cd > 0.0 {
    return
  }

  if spawn_enemy(game) {
    game.spawn_pool = game.spawn_pool - 1
    game.spawn_cd = @types.spawn_interval_for_night(game.night)
  } else {
    game.spawn_cd = 0.2
  }
}

///|
fn update_traps(game : @types.Game, dt : Float) -> Unit {
  let power = @types.trap_damage +
    Float::from_int(@types.maxi(game.night - 1, 0)) * 1.8

  for trap in game.traps {
    if trap.trigger_cd > 0.0 {
      trap.trigger_cd = @types.maxf(trap.trigger_cd - dt, 0.0)
    }
    if trap.flash_t > 0.0 {
      trap.flash_t = @types.maxf(trap.flash_t - dt, 0.0)
    }

    if not(trap.active) || trap.trigger_cd > 0.0 {
      continue
    }

    let mut hit_index = -1
    let mut best_d2 = @types.squaref(@types.trap_trigger_radius)

    for j in 0..<game.enemies.length() {
      if not(game.enemies[j].active) {
        continue
      }

      let d2 = @types.dist2(trap.x, trap.y, game.enemies[j].x, game.enemies[j].y)
      if d2 <= best_d2 {
        hit_index = j
        best_d2 = d2
      }
    }

    if hit_index >= 0 {
      trap.trigger_cd = @types.trap_rearm_time
      trap.flash_t = @types.trap_flash_time
      game.sweep_charge = @types.clampf(
        game.sweep_charge + @types.sweep_charge_hit * 0.6,
        0.0,
        @types.sweep_charge_max,
      )
      ignore(damage_enemy(game, hit_index, power, @types.trap_slow_time))
    }
  }
}

///|
fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    if game.enemies[i].slow_t > 0.0 {
      game.enemies[i].slow_t = @types.maxf(game.enemies[i].slow_t - dt, 0.0)
    }

    let target = preferred_alive_beacon(game, game.enemies[i].target)
    if target < 0 {
      game.enemies[i].active = false
      continue
    }

    game.enemies[i].target = target

    let tx = game.beacons[target].x
    let ty = game.beacons[target].y
    let dx = tx - game.enemies[i].x
    let dy = ty - game.enemies[i].y
    let d2 = dx * dx + dy * dy

    let reach = @types.beacon_radius +
      @types.enemy_hit_radius(game.enemies[i].kind) +
      2.0
    if d2 <= @types.squaref(reach) {
      game.beacons[target].integrity = @types.maxf(
        game.beacons[target].integrity - game.enemies[i].damage,
        0.0,
      )
      game.beacons[target].pulse_t = 0.40
      game.enemies[i].active = false
      game.shake_t = @types.maxf(game.shake_t, @types.shake_hit_time)
      continue
    }

    let (nx, ny) = @types.normalize2(dx, dy)
    let slow_factor : Float = if game.enemies[i].slow_t > 0.0 {
      @types.trap_slow_factor
    } else {
      1.0
    }
    let speed = game.enemies[i].speed * slow_factor

    game.enemies[i].vx = nx * speed
    game.enemies[i].vy = ny * speed
    game.enemies[i].anim_t = game.enemies[i].anim_t + dt

    let sway = @types.sinf(
        game.enemies[i].anim_t * 7.5 + Float::from_int(i) * 0.4,
      ) *
      14.0

    game.enemies[i].x = game.enemies[i].x +
      (game.enemies[i].vx + -ny * sway) * dt
    game.enemies[i].y = game.enemies[i].y +
      (game.enemies[i].vy + nx * sway) * dt
  }
}

///|
fn evaluate_wave_and_loss(game : @types.Game) -> Unit {
  if @types.beacon_total_integrity(game) <= 0.0 ||
    @types.living_beacon_count(game) <= 0 {
    end_run_game_over(game, "All shrine beacons collapsed.")
    return
  }

  if game.spawn_pool > 0 || @types.active_enemy_count(game) > 0 {
    return
  }

  let cleared_night = game.night
  game.score = game.score +
    @types.score_night_clear_bonus +
    cleared_night * 34
  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.energy = @types.clampf(
    game.energy + @types.night_clear_energy_bonus,
    0.0,
    @types.energy_max,
  )
  game.sweep_charge = @types.clampf(
    game.sweep_charge + @types.night_clear_charge_bonus,
    0.0,
    @types.sweep_charge_max,
  )

  begin_night(game, cleared_night + 1)
  set_status(
    game,
    "Night \{cleared_night} survived. Night \{game.night} approaches.",
    2.3,
  )
}

///|
fn tick_play_timers(game : @types.Game, dt : Float) -> Unit {
  game.elapsed = game.elapsed + dt
  game.energy = @types.clampf(
    game.energy + @types.energy_regen * dt,
    0.0,
    @types.energy_max,
  )
  game.sweep_charge = @types.clampf(
    game.sweep_charge + @types.sweep_charge_passive * dt,
    0.0,
    @types.sweep_charge_max,
  )

  game.player.attack_cd = @types.maxf(game.player.attack_cd - dt, 0.0)
  game.player.attack_t = @types.maxf(game.player.attack_t - dt, 0.0)
  game.player.dash_cd = @types.maxf(game.player.dash_cd - dt, 0.0)
  game.player.dash_t = @types.maxf(game.player.dash_t - dt, 0.0)

  game.trap_place_cd = @types.maxf(game.trap_place_cd - dt, 0.0)
  game.sweep_t = @types.maxf(game.sweep_t - dt, 0.0)
  game.night_banner_t = @types.maxf(game.night_banner_t - dt, 0.0)
  game.shake_t = @types.maxf(game.shake_t - dt, 0.0)

  for beacon in game.beacons {
    beacon.pulse_t = @types.maxf(beacon.pulse_t - dt, 0.0)
  }
}

///|
fn update_title_state(game : @types.Game) -> Unit {
  if game.input.press_start || game.input.press_restart {
    start_new_run(game)
  }
}

///|
fn update_paused_state(game : @types.Game) -> Unit {
  if game.input.press_restart {
    start_new_run(game)
    return
  }

  if game.input.press_pause {
    game.state = @types.state_playing
    set_status(game, "Resumed.", 0.7)
  }
}

///|
fn update_game_over_state(game : @types.Game) -> Unit {
  if game.input.press_start || game.input.press_restart {
    start_new_run(game)
  }
}

///|
fn update_playing_state(game : @types.Game, dt : Float) -> Unit {
  if game.input.press_pause {
    game.state = @types.state_paused
    set_status(game, "Paused.", 0.7)
    return
  }

  if game.input.press_restart {
    start_new_run(game)
    return
  }

  tick_play_timers(game, dt)
  handle_player_actions(game)
  update_player_movement(game, dt)
  update_spawning(game, dt)
  update_traps(game, dt)
  update_enemies(game, dt)
  evaluate_wave_and_loss(game)
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  update_input(game)

  if game.status_t > 0.0 {
    game.status_t = @types.maxf(game.status_t - dt, 0.0)
  }

  if game.state == @types.state_title {
    update_title_state(game)
  } else if game.state == @types.state_playing {
    update_playing_state(game, dt)
  } else if game.state == @types.state_paused {
    update_paused_state(game)
  } else {
    update_game_over_state(game)
  }
}
