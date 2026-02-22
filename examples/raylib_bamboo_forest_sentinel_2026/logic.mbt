///|
fn set_status(game : Game, text : String, ttl : Float) -> Unit {
  game.status_text = text
  game.status_t = ttl
}

///|
fn active_enemy_count(game : Game) -> Int {
  let mut total = 0
  for i in 0..<game.enemies.length() {
    if game.enemies[i].active {
      total = total + 1
    }
  }
  total
}

///|
fn living_beacon_count(game : Game) -> Int {
  let mut total = 0
  for i in 0..<game.beacons.length() {
    if game.beacons[i].integrity > 0.0 {
      total = total + 1
    }
  }
  total
}

///|
fn beacon_total_integrity(game : Game) -> Float {
  let mut total : Float = 0.0
  for i in 0..<game.beacons.length() {
    total = total + maxf(game.beacons[i].integrity, 0.0)
  }
  total
}

///|
fn preferred_alive_beacon(game : Game, preferred : Int) -> Int {
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
fn reset_player(player : Player) -> Unit {
  player.x = Float::from_int(world_x + 330)
  player.y = lane_y(1)
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
fn reset_beacons(game : Game) -> Unit {
  for i in 0..<game.beacons.length() {
    game.beacons[i].integrity = beacon_integrity_max
    game.beacons[i].pulse_t = 0.0
  }
}

///|
fn reset_traps(game : Game) -> Unit {
  for i in 0..<game.traps.length() {
    game.traps[i].active = false
    game.traps[i].trigger_cd = 0.0
    game.traps[i].flash_t = 0.0
  }
}

///|
fn reset_enemies(game : Game) -> Unit {
  for i in 0..<game.enemies.length() {
    game.enemies[i].active = false
    game.enemies[i].slow_t = 0.0
    game.enemies[i].anim_t = 0.0
  }
}

///|
fn begin_night(game : Game, night : Int) -> Unit {
  game.night = night
  game.spawn_pool = night_spawn_base + (night - 1) * night_spawn_step
  game.spawn_cd = 0.84
  game.night_banner_t = night_banner_time
}

///|
fn start_new_run(game : Game) -> Unit {
  game.state = state_playing
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
fn end_run_game_over(game : Game, reason : String) -> Unit {
  game.state = state_game_over
  game.game_over_reason = reason
  set_status(game, "Sanctum fallen. Press R to restart.", 2.2)
}

///|
fn normalize2(x : Float, y : Float) -> (Float, Float) {
  let len2 = x * x + y * y
  if len2 <= 0.000001 {
    (0.0, 0.0)
  } else {
    let inv : Float = Float::from_int(1) / len2.sqrt()
    (x * inv, y * inv)
  }
}

///|
fn update_player_movement(game : Game, dt : Float) -> Unit {
  let mut move_x = Float::from_int(game.input.move_x)
  let mut move_y = Float::from_int(game.input.move_y)

  if move_x != 0.0 || move_y != 0.0 {
    let (nx, ny) = normalize2(move_x, move_y)
    move_x = nx
    move_y = ny
    game.player.facing_x = nx
    game.player.facing_y = ny
  }

  if game.player.dash_t > 0.0 {
    game.player.x = game.player.x + game.player.dash_vx * dt
    game.player.y = game.player.y + game.player.dash_vy * dt
  } else {
    game.player.x = game.player.x + move_x * player_speed * dt
    game.player.y = game.player.y + move_y * player_speed * dt
  }

  let min_x = Float::from_int(world_x) + player_radius + 6.0
  let max_x = Float::from_int(world_x + world_w) - player_radius - 6.0
  let min_y = Float::from_int(world_y) + player_radius + 6.0
  let max_y = Float::from_int(world_y + world_h) - player_radius - 6.0

  game.player.x = clampf(game.player.x, min_x, max_x)
  game.player.y = clampf(game.player.y, min_y, max_y)
}

///|
fn nearest_trap_slot(
  game : Game,
  want_active : Bool,
  max_distance : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = squaref(max_distance)

  for i in 0..<game.traps.length() {
    if game.traps[i].active != want_active {
      continue
    }

    let d2 = dist2(
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
fn try_place_trap(game : Game) -> Bool {
  if game.trap_place_cd > 0.0 || game.energy < trap_place_energy_cost {
    return false
  }

  let slot = nearest_trap_slot(game, false, trap_place_range)
  if slot < 0 {
    return false
  }

  game.traps[slot].active = true
  game.traps[slot].trigger_cd = 0.0
  game.traps[slot].flash_t = trap_flash_time

  game.trap_place_cd = trap_place_cooldown
  game.energy = clampf(game.energy - trap_place_energy_cost, 0.0, energy_max)
  set_status(game, "Bamboo snare placed.", 0.8)

  true
}

///|
fn try_remove_trap(game : Game) -> Bool {
  let slot = nearest_trap_slot(game, true, trap_remove_range)
  if slot < 0 {
    return false
  }

  game.traps[slot].active = false
  game.traps[slot].trigger_cd = 0.2
  game.traps[slot].flash_t = trap_flash_time

  game.energy = clampf(game.energy + trap_remove_refund, 0.0, energy_max)
  set_status(game, "Trap recovered.", 0.7)

  true
}

///|
fn register_kill(game : Game, enemy_kind : Int) -> Unit {
  game.kills = game.kills + 1

  let gain_score = score_kill_base + (game.night - 1) * 6 + enemy_kind * 9
  game.score = game.score + gain_score

  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.energy = clampf(game.energy + 4.8, 0.0, energy_max)
  game.sweep_charge = clampf(
    game.sweep_charge + sweep_charge_kill,
    0.0,
    sweep_charge_max,
  )
}

///|
fn damage_enemy(
  game : Game,
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
    game.enemies[enemy_index].slow_t = maxf(
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
fn perform_basic_attack(game : Game) -> Unit {
  if game.player.attack_cd > 0.0 || game.energy < basic_attack_energy_cost {
    return
  }

  game.player.attack_cd = basic_attack_cooldown
  game.player.attack_t = attack_flash_time
  game.energy = clampf(game.energy - basic_attack_energy_cost, 0.0, energy_max)

  let mut hits = 0
  let mut kills = 0

  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    let radius = enemy_hit_radius(game.enemies[i].kind)
    let reach = basic_attack_range + radius
    let dx = game.enemies[i].x - game.player.x
    let dy = game.enemies[i].y - game.player.y
    let d2 = dx * dx + dy * dy

    if d2 > squaref(reach) {
      continue
    }

    let inv_len : Float = Float::from_int(1) / maxf(d2.sqrt(), 0.001)
    let dot = dx * inv_len * game.player.facing_x +
      dy * inv_len * game.player.facing_y

    if dot < basic_attack_arc_dot {
      continue
    }

    hits = hits + 1
    game.sweep_charge = clampf(
      game.sweep_charge + sweep_charge_hit,
      0.0,
      sweep_charge_max,
    )

    if damage_enemy(game, i, basic_attack_damage, 0.26) {
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
fn start_dash(game : Game) -> Unit {
  if game.player.dash_t > 0.0 || game.player.dash_cd > 0.0 {
    return
  }

  if game.energy < dash_energy_cost {
    set_status(game, "Not enough energy to dash.", 0.7)
    return
  }

  let mut dir_x = Float::from_int(game.input.move_x)
  let mut dir_y = Float::from_int(game.input.move_y)

  if dir_x == 0.0 && dir_y == 0.0 {
    dir_x = game.player.facing_x
    dir_y = game.player.facing_y
  }

  let (nx, ny) = normalize2(dir_x, dir_y)
  if nx == 0.0 && ny == 0.0 {
    return
  }

  game.energy = clampf(game.energy - dash_energy_cost, 0.0, energy_max)
  game.player.dash_cd = dash_cooldown
  game.player.dash_t = dash_time
  game.player.dash_vx = nx * dash_speed
  game.player.dash_vy = ny * dash_speed

  set_status(game, "Shadow dash.", 0.6)
}

///|
fn trigger_sweep(game : Game) -> Unit {
  if game.sweep_charge < sweep_charge_max {
    return
  }

  game.sweep_charge = 0.0
  game.sweep_t = sweep_fx_time
  game.player.attack_t = maxf(game.player.attack_t, attack_flash_time * 1.3)
  game.shake_t = maxf(game.shake_t, 0.12)

  let mut hits = 0
  let mut kills = 0

  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    let radius = enemy_hit_radius(game.enemies[i].kind)
    let reach = sweep_radius + radius

    if dist2(game.player.x, game.player.y, game.enemies[i].x, game.enemies[i].y) <=
      squaref(reach) {
      hits = hits + 1
      if damage_enemy(game, i, sweep_damage, 0.65) {
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
fn handle_player_actions(game : Game) -> Unit {
  if game.input.press_k {
    ignore(try_remove_trap(game))
  }

  if game.input.press_j {
    if not(try_place_trap(game)) {
      perform_basic_attack(game)
    }
  }

  if game.input.press_space {
    if game.sweep_charge >= sweep_charge_max {
      trigger_sweep(game)
    } else {
      start_dash(game)
    }
  }
}

///|
fn free_enemy_slot(game : Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_enemy(game : Game) -> Bool {
  let slot = free_enemy_slot(game)
  if slot < 0 {
    return false
  }

  let route_count = spawn_route_count(game.night)
  let route = @raylib.get_random_value(0, route_count - 1)
  let target = preferred_alive_beacon(game, spawn_route_target(route))

  if target < 0 {
    return false
  }

  let (sx, sy) = spawn_route_position(route)

  let mut kind = @raylib.get_random_value(0, 2)
  if game.night >= 6 && randf(0.0, 1.0) < 0.24 {
    kind = 2
  }

  let night_scale = Float::from_int(maxi(game.night - 1, 0))
  let mut hp = enemy_hp_base + night_scale * enemy_hp_step + randf(-4.0, 10.0)
  let mut speed = enemy_speed_base +
    night_scale * enemy_speed_step +
    randf(-5.0, 12.0)
  let mut damage = enemy_damage_base + night_scale * enemy_damage_step

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
  game.enemies[slot].speed = maxf(42.0, speed)
  game.enemies[slot].damage = damage
  game.enemies[slot].target = target
  game.enemies[slot].slow_t = 0.0
  game.enemies[slot].kind = kind
  game.enemies[slot].anim_t = randf(0.0, 6.28)

  true
}

///|
fn update_spawning(game : Game, dt : Float) -> Unit {
  if game.spawn_pool <= 0 {
    return
  }

  game.spawn_cd = game.spawn_cd - dt
  if game.spawn_cd > 0.0 {
    return
  }

  if spawn_enemy(game) {
    game.spawn_pool = game.spawn_pool - 1
    game.spawn_cd = spawn_interval_for_night(game.night)
  } else {
    game.spawn_cd = 0.2
  }
}

///|
fn update_traps(game : Game, dt : Float) -> Unit {
  let power = trap_damage + Float::from_int(maxi(game.night - 1, 0)) * 1.8

  for i in 0..<game.traps.length() {
    if game.traps[i].trigger_cd > 0.0 {
      game.traps[i].trigger_cd = maxf(game.traps[i].trigger_cd - dt, 0.0)
    }
    if game.traps[i].flash_t > 0.0 {
      game.traps[i].flash_t = maxf(game.traps[i].flash_t - dt, 0.0)
    }

    if not(game.traps[i].active) || game.traps[i].trigger_cd > 0.0 {
      continue
    }

    let mut hit_index = -1
    let mut best_d2 = squaref(trap_trigger_radius)

    for j in 0..<game.enemies.length() {
      if not(game.enemies[j].active) {
        continue
      }

      let d2 = dist2(
        game.traps[i].x,
        game.traps[i].y,
        game.enemies[j].x,
        game.enemies[j].y,
      )
      if d2 <= best_d2 {
        hit_index = j
        best_d2 = d2
      }
    }

    if hit_index >= 0 {
      game.traps[i].trigger_cd = trap_rearm_time
      game.traps[i].flash_t = trap_flash_time
      game.sweep_charge = clampf(
        game.sweep_charge + sweep_charge_hit * 0.6,
        0.0,
        sweep_charge_max,
      )
      ignore(damage_enemy(game, hit_index, power, trap_slow_time))
    }
  }
}

///|
fn update_enemies(game : Game, dt : Float) -> Unit {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      continue
    }

    if game.enemies[i].slow_t > 0.0 {
      game.enemies[i].slow_t = maxf(game.enemies[i].slow_t - dt, 0.0)
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

    let reach = beacon_radius + enemy_hit_radius(game.enemies[i].kind) + 2.0
    if d2 <= squaref(reach) {
      game.beacons[target].integrity = maxf(
        game.beacons[target].integrity - game.enemies[i].damage,
        0.0,
      )
      game.beacons[target].pulse_t = 0.40
      game.enemies[i].active = false
      game.shake_t = maxf(game.shake_t, shake_hit_time)
      continue
    }

    let (nx, ny) = normalize2(dx, dy)
    let slow_factor : Float = if game.enemies[i].slow_t > 0.0 {
      trap_slow_factor
    } else {
      1.0
    }
    let speed = game.enemies[i].speed * slow_factor

    game.enemies[i].vx = nx * speed
    game.enemies[i].vy = ny * speed
    game.enemies[i].anim_t = game.enemies[i].anim_t + dt

    let sway = sinf(game.enemies[i].anim_t * 7.5 + Float::from_int(i) * 0.4) *
      14.0

    game.enemies[i].x = game.enemies[i].x +
      (game.enemies[i].vx + -ny * sway) * dt
    game.enemies[i].y = game.enemies[i].y +
      (game.enemies[i].vy + nx * sway) * dt
  }
}

///|
fn evaluate_wave_and_loss(game : Game) -> Unit {
  if beacon_total_integrity(game) <= 0.0 || living_beacon_count(game) <= 0 {
    end_run_game_over(game, "All shrine beacons collapsed.")
    return
  }

  if game.spawn_pool > 0 || active_enemy_count(game) > 0 {
    return
  }

  let cleared_night = game.night
  game.score = game.score + score_night_clear_bonus + cleared_night * 34
  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.energy = clampf(game.energy + night_clear_energy_bonus, 0.0, energy_max)
  game.sweep_charge = clampf(
    game.sweep_charge + night_clear_charge_bonus,
    0.0,
    sweep_charge_max,
  )

  begin_night(game, cleared_night + 1)
  set_status(
    game,
    "Night \{cleared_night} survived. Night \{game.night} approaches.",
    2.3,
  )
}

///|
fn tick_play_timers(game : Game, dt : Float) -> Unit {
  game.elapsed = game.elapsed + dt
  game.energy = clampf(game.energy + energy_regen * dt, 0.0, energy_max)
  game.sweep_charge = clampf(
    game.sweep_charge + sweep_charge_passive * dt,
    0.0,
    sweep_charge_max,
  )

  game.player.attack_cd = maxf(game.player.attack_cd - dt, 0.0)
  game.player.attack_t = maxf(game.player.attack_t - dt, 0.0)
  game.player.dash_cd = maxf(game.player.dash_cd - dt, 0.0)
  game.player.dash_t = maxf(game.player.dash_t - dt, 0.0)

  game.trap_place_cd = maxf(game.trap_place_cd - dt, 0.0)
  game.sweep_t = maxf(game.sweep_t - dt, 0.0)
  game.night_banner_t = maxf(game.night_banner_t - dt, 0.0)
  game.shake_t = maxf(game.shake_t - dt, 0.0)

  for i in 0..<game.beacons.length() {
    game.beacons[i].pulse_t = maxf(game.beacons[i].pulse_t - dt, 0.0)
  }
}

///|
fn update_title_state(game : Game) -> Unit {
  if game.input.press_start || game.input.press_restart {
    start_new_run(game)
  }
}

///|
fn update_paused_state(game : Game) -> Unit {
  if game.input.press_restart {
    start_new_run(game)
    return
  }

  if game.input.press_pause {
    game.state = state_playing
    set_status(game, "Resumed.", 0.7)
  }
}

///|
fn update_game_over_state(game : Game) -> Unit {
  if game.input.press_start || game.input.press_restart {
    start_new_run(game)
  }
}

///|
fn update_playing_state(game : Game, dt : Float) -> Unit {
  if game.input.press_pause {
    game.state = state_paused
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
fn update_game(game : Game, dt : Float) -> Unit {
  if game.status_t > 0.0 {
    game.status_t = maxf(game.status_t - dt, 0.0)
  }

  if game.state == state_title {
    update_title_state(game)
  } else if game.state == state_playing {
    update_playing_state(game, dt)
  } else if game.state == state_paused {
    update_paused_state(game)
  } else {
    update_game_over_state(game)
  }
}

///|
fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}
