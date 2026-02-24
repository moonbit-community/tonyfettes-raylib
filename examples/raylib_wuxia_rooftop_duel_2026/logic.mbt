///|
fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
fn normalize(dx : Float, dy : Float) -> (Float, Float) {
  let d1 : Float = absf(dx) + absf(dy)
  if d1 <= 0.0001 {
    (1.0, 0.0)
  } else {
    (dx / d1, dy / d1)
  }
}

///|
fn set_message(game : Game, msg : String, ttl : Float) -> Unit {
  game.message = msg
  game.message_t = ttl
}

///|
fn clear_enemies(game : Game) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    game.enemies[i].active = false
    game.enemies[i].x = 0.0
    game.enemies[i].y = 0.0
    game.enemies[i].vx = 0.0
    game.enemies[i].vy = 0.0
    game.enemies[i].hp = 0.0
    game.enemies[i].max_hp = 0.0
    game.enemies[i].radius = 20.0
    game.enemies[i].speed = 0.0
    game.enemies[i].state = enemy_state_seek
    game.enemies[i].state_t = 0.0
    game.enemies[i].telegraph_total_t = 0.0
    game.enemies[i].visual_phase = 0.0
  }
}

///|
fn active_enemy_count(game : Game) -> Int {
  let mut count : Int = 0
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if game.enemies[i].active {
      count = count + 1
    }
  }
  count
}

///|
fn wave_enemy_total(wave : Int) -> Int {
  mini(30, 4 + wave * 2)
}

///|
fn wave_spawn_interval(wave : Int) -> Float {
  maxf(
    spawn_interval_min,
    spawn_interval_base - Float::from_int(wave - 1) * 0.06,
  )
}

///|
fn reset_player(game : Game) -> Unit {
  game.player_x = arena_center_x()
  game.player_y = arena_center_y() + 120.0
  game.player_vx = 0.0
  game.player_vy = 0.0
  game.facing_x = 1.0
  game.facing_y = 0.0
  game.move_x = 0.0
  game.move_y = 0.0
  game.health = player_max_health
  game.stamina = player_max_stamina
  game.invuln_t = 0.0
  game.parry_t = 0.0
  game.dash_t_left = 0.0
  game.dash_dir_x = 1.0
  game.dash_dir_y = 0.0
  game.attack_cd = 0.0
  game.attack_anim_t = 0.0
  game.attack_kind = attack_none
}

///|
fn start_new_run(game : Game) -> Unit {
  clear_enemies(game)
  reset_player(game)

  game.state = state_playing
  game.wave = 1
  game.wave_enemies_total = wave_enemy_total(game.wave)
  game.wave_spawned = 0
  game.wave_defeated = 0
  game.spawn_cd = 0.2
  game.wave_gap_t = 0.0
  game.stage_score = 0
  game.last_stage_bonus = 0
  game.combo = 0
  game.combo_t = 0.0
  game.score = 0
  game.game_t = 0.0
  game.shake_t = 0.0

  set_message(
    game, "Blade ready. Time your parries inside telegraph windows.", 2.8,
  )
}

///|
fn finish_game_over(game : Game) -> Unit {
  if game.state != state_playing {
    return
  }

  game.state = state_game_over
  game.move_x = 0.0
  game.move_y = 0.0
  game.player_vx = game.player_vx * 0.2
  game.player_vy = game.player_vy * 0.2

  if game.score > game.best_score {
    game.best_score = game.score
  }

  set_message(
    game,
    "Defeated on wave " +
    game.wave.to_string() +
    ". Press R to challenge again.",
    4.2,
  )
}

///|
fn add_score_event(game : Game, base : Int, stage_points : Int) -> Unit {
  let combo_bonus_percent : Int = mini(240, game.combo * 13)
  let gained : Int = base * (100 + combo_bonus_percent) / 100

  game.score = game.score + gained
  game.stage_score = game.stage_score + stage_points + game.combo / 2
  game.combo = mini(999, game.combo + 1)
  game.combo_t = combo_timeout

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn hurt_player(game : Game, dmg : Float) -> Unit {
  if game.state != state_playing || game.invuln_t > 0.0 {
    return
  }

  game.health = maxf(0.0, game.health - dmg)
  game.invuln_t = player_hit_invuln
  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = maxf(game.shake_t, 0.24)

  if game.health <= 0.0 {
    finish_game_over(game)
  } else {
    set_message(game, "Guard broken!", 0.65)
  }
}

///|
fn spawn_enemy(game : Game) -> Bool {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if game.enemies[i].active {
      continue
    }

    let wave_f : Float = Float::from_int(game.wave)

    let side : Int = @raylib.get_random_value(0, 3)
    if side == 0 {
      game.enemies[i].x = randf(arena_left() + 26.0, arena_right() - 26.0)
      game.enemies[i].y = arena_top() - randf(20.0, 80.0)
    } else if side == 1 {
      game.enemies[i].x = randf(arena_left() + 26.0, arena_right() - 26.0)
      game.enemies[i].y = arena_bottom() + randf(20.0, 80.0)
    } else if side == 2 {
      game.enemies[i].x = arena_left() - randf(20.0, 80.0)
      game.enemies[i].y = randf(arena_top() + 26.0, arena_bottom() - 26.0)
    } else {
      game.enemies[i].x = arena_right() + randf(20.0, 80.0)
      game.enemies[i].y = randf(arena_top() + 26.0, arena_bottom() - 26.0)
    }

    game.enemies[i].active = true
    game.enemies[i].radius = randf(18.0, 26.0)
    game.enemies[i].max_hp = 60.0 + wave_f * 7.0 + randf(-6.0, 12.0)
    game.enemies[i].hp = game.enemies[i].max_hp
    game.enemies[i].speed = 126.0 + wave_f * 10.0 + randf(-18.0, 18.0)
    game.enemies[i].vx = 0.0
    game.enemies[i].vy = 0.0
    game.enemies[i].state = enemy_state_seek
    game.enemies[i].state_t = 0.0
    game.enemies[i].telegraph_total_t = 0.0
    game.enemies[i].visual_phase = randf(0.0, 6.28)

    return true
  }

  false
}

///|
fn defeat_enemy(game : Game, idx : Int, parry_kill : Bool) -> Unit {
  if not(game.enemies[idx].active) {
    return
  }

  game.enemies[idx].active = false
  game.wave_defeated = game.wave_defeated + 1

  let base : Int = if parry_kill { 54 } else { 38 }
  let stage : Int = if parry_kill { 24 } else { 18 }
  add_score_event(game, base, stage)

  let stamina_gain : Float = if parry_kill { 16.0 } else { 8.0 }
  game.stamina = minf(player_max_stamina, game.stamina + stamina_gain)
  game.shake_t = maxf(game.shake_t, if parry_kill { 0.22 } else { 0.14 })
}

///|
fn stun_enemy_from_parry(game : Game, idx : Int, from_strike : Bool) -> Unit {
  if not(game.enemies[idx].active) {
    return
  }

  game.enemies[idx].state = enemy_state_stunned
  game.enemies[idx].state_t = enemy_stunned_t
  game.enemies[idx].telegraph_total_t = 0.0

  let push = normalize(
    game.enemies[idx].x - game.player_x,
    game.enemies[idx].y - game.player_y,
  )

  let launch : Float = if from_strike { 540.0 } else { 360.0 }
  game.enemies[idx].vx = push.0 * launch
  game.enemies[idx].vy = push.1 * launch

  let dmg : Float = if from_strike {
    parry_counter_damage + 16.0
  } else {
    parry_counter_damage
  }

  game.enemies[idx].hp = game.enemies[idx].hp - dmg

  add_score_event(game, if from_strike { 34 } else { 24 }, 12)
  game.stamina = minf(player_max_stamina, game.stamina + 14.0)
  game.health = minf(player_max_health, game.health + 1.5)

  if game.enemies[idx].hp <= 0.0 {
    defeat_enemy(game, idx, true)
  }
}

///|
fn resolve_parry_window(game : Game) -> Int {
  if game.state != state_playing || game.parry_t <= 0.0 {
    return 0
  }

  let mut parried : Int = 0

  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue
    }

    if game.enemies[i].state != enemy_state_telegraph {
      continue
    }

    if game.enemies[i].state_t > enemy_parry_window + 0.06 {
      continue
    }

    let rr : Float = parry_range + game.enemies[i].radius
    if dist2(game.player_x, game.player_y, game.enemies[i].x, game.enemies[i].y) >
      rr * rr {
      continue
    }

    stun_enemy_from_parry(game, i, false)
    parried = parried + 1
  }

  parried
}

///|
fn apply_attack_hit(
  game : Game,
  idx : Int,
  damage : Float,
  knockback : Float,
  telegraph_stagger : Bool,
) -> Bool {
  if not(game.enemies[idx].active) {
    return false
  }

  game.enemies[idx].hp = game.enemies[idx].hp - damage

  let push = normalize(
    game.enemies[idx].x - game.player_x,
    game.enemies[idx].y - game.player_y,
  )

  game.enemies[idx].vx = game.enemies[idx].vx + push.0 * knockback
  game.enemies[idx].vy = game.enemies[idx].vy + push.1 * knockback

  if telegraph_stagger &&
    game.enemies[idx].state == enemy_state_telegraph &&
    game.enemies[idx].state_t <= enemy_parry_window + 0.08 {
    game.enemies[idx].state = enemy_state_stunned
    game.enemies[idx].state_t = enemy_stunned_t * 0.7
  }

  if game.enemies[idx].hp <= 0.0 {
    defeat_enemy(game, idx, false)
  }

  true
}

///|
fn try_player_attack(game : Game, attack : Int) -> Bool {
  if game.state != state_playing {
    return false
  }
  if game.attack_cd > 0.0 {
    return false
  }

  let cost : Float = if attack == attack_heavy {
    heavy_attack_cost
  } else {
    light_attack_cost
  }
  if game.stamina < cost {
    set_message(game, "Not enough stamina.", 0.55)
    return false
  }

  let damage : Float = if attack == attack_heavy {
    heavy_attack_damage
  } else {
    light_attack_damage
  }
  let reach : Float = if attack == attack_heavy {
    heavy_attack_range
  } else {
    light_attack_range
  }
  let arc_dot : Float = if attack == attack_heavy {
    heavy_attack_arc_dot
  } else {
    light_attack_arc_dot
  }

  game.stamina = game.stamina - cost
  game.attack_cd = if attack == attack_heavy {
    heavy_attack_cooldown
  } else {
    light_attack_cooldown
  }
  game.attack_anim_t = if attack == attack_heavy {
    heavy_attack_anim_t
  } else {
    light_attack_anim_t
  }
  game.attack_kind = attack

  let mut hit_count : Int = 0

  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue
    }

    let dx : Float = game.enemies[i].x - game.player_x
    let dy : Float = game.enemies[i].y - game.player_y
    let rr : Float = reach + game.enemies[i].radius

    if dx * dx + dy * dy > rr * rr {
      continue
    }

    let enemy_dir = normalize(dx, dy)
    let dot : Float = enemy_dir.0 * game.facing_x + enemy_dir.1 * game.facing_y
    if dot < arc_dot {
      continue
    }

    let hit : Bool = apply_attack_hit(
      game,
      i,
      damage,
      if attack == attack_heavy {
        380.0
      } else {
        260.0
      },
      attack == attack_heavy,
    )

    if hit {
      hit_count = hit_count + 1
      add_score_event(
        game,
        if attack == attack_heavy {
          22
        } else {
          14
        },
        if attack == attack_heavy {
          11
        } else {
          7
        },
      )
    }
  }

  if hit_count == 0 {
    game.combo_t = maxf(0.0, game.combo_t - 0.40)
  } else {
    game.shake_t = maxf(
      game.shake_t,
      if attack == attack_heavy {
        0.15
      } else {
        0.10
      },
    )
  }

  true
}

///|
fn trigger_parry_dash(game : Game) -> Bool {
  if game.state != state_playing {
    return false
  }
  if game.parry_t > 0.0 {
    return false
  }
  if game.stamina < parry_dash_cost {
    set_message(game, "Not enough stamina for parry.", 0.55)
    return false
  }

  let dash_dir = if absf(game.move_x) + absf(game.move_y) > 0.01 {
    normalize(game.move_x, game.move_y)
  } else {
    normalize(game.facing_x, game.facing_y)
  }

  game.stamina = game.stamina - parry_dash_cost
  game.parry_t = parry_active_t
  game.dash_t_left = dash_t
  game.dash_dir_x = dash_dir.0
  game.dash_dir_y = dash_dir.1
  game.player_vx = game.player_vx + game.dash_dir_x * dash_speed
  game.player_vy = game.player_vy + game.dash_dir_y * dash_speed

  let parry_now : Int = resolve_parry_window(game)
  if parry_now > 0 {
    set_message(game, "Perfect parry x" + parry_now.to_string(), 0.70)
    game.shake_t = maxf(game.shake_t, 0.20)
  }

  true
}

///|
fn update_player(game : Game, dt : Float) -> Unit {
  game.player_vx = game.player_vx + game.move_x * player_move_accel * dt
  game.player_vy = game.player_vy + game.move_y * player_move_accel * dt

  if game.dash_t_left > 0.0 {
    game.player_vx = game.player_vx + game.dash_dir_x * dash_speed * dt
    game.player_vy = game.player_vy + game.dash_dir_y * dash_speed * dt
  }

  let damp : Float = maxf(0.0, 1.0 - dt * player_friction)
  game.player_vx = game.player_vx * damp
  game.player_vy = game.player_vy * damp

  game.player_x = game.player_x + game.player_vx * dt
  game.player_y = game.player_y + game.player_vy * dt

  let left : Float = arena_left() + player_radius + 8.0
  let right : Float = arena_right() - player_radius - 8.0
  let top : Float = arena_top() + player_radius + 8.0
  let bottom : Float = arena_bottom() - player_radius - 8.0

  if game.player_x < left {
    game.player_x = left
    game.player_vx = maxf(0.0, game.player_vx)
  } else if game.player_x > right {
    game.player_x = right
    game.player_vx = minf(0.0, game.player_vx)
  }

  if game.player_y < top {
    game.player_y = top
    game.player_vy = maxf(0.0, game.player_vy)
  } else if game.player_y > bottom {
    game.player_y = bottom
    game.player_vy = minf(0.0, game.player_vy)
  }
}

///|
fn update_enemy_seek(game : Game, idx : Int, dt : Float) -> Unit {
  let dir = normalize(
    game.player_x - game.enemies[idx].x,
    game.player_y - game.enemies[idx].y,
  )

  let side_x : Float = -dir.1
  let side_y : Float = dir.0
  let sidestep : Float = sinf(
      game.enemies[idx].visual_phase * 3.0 + game.ui_t * 1.6,
    ) *
    48.0

  let tx : Float = dir.0 * game.enemies[idx].speed + side_x * sidestep
  let ty : Float = dir.1 * game.enemies[idx].speed + side_y * sidestep

  game.enemies[idx].vx = game.enemies[idx].vx * (1.0 - dt * 3.2) + tx * dt * 3.2
  game.enemies[idx].vy = game.enemies[idx].vy * (1.0 - dt * 3.2) + ty * dt * 3.2

  game.enemies[idx].x = game.enemies[idx].x + game.enemies[idx].vx * dt
  game.enemies[idx].y = game.enemies[idx].y + game.enemies[idx].vy * dt

  let engage_rr : Float = 90.0 + player_radius + game.enemies[idx].radius
  if dist2(
      game.player_x,
      game.player_y,
      game.enemies[idx].x,
      game.enemies[idx].y,
    ) <=
    engage_rr * engage_rr {
    let telegraph_t : Float = randf(enemy_telegraph_min, enemy_telegraph_max)
    game.enemies[idx].state = enemy_state_telegraph
    game.enemies[idx].state_t = telegraph_t
    game.enemies[idx].telegraph_total_t = telegraph_t
    game.enemies[idx].vx = game.enemies[idx].vx * 0.22
    game.enemies[idx].vy = game.enemies[idx].vy * 0.22
  }
}

///|
fn update_enemy_telegraph(game : Game, idx : Int, dt : Float) -> Unit {
  game.enemies[idx].state_t = maxf(0.0, game.enemies[idx].state_t - dt)

  let dir = normalize(
    game.player_x - game.enemies[idx].x,
    game.player_y - game.enemies[idx].y,
  )

  game.enemies[idx].vx = game.enemies[idx].vx * (1.0 - dt * 7.5) +
    dir.0 * game.enemies[idx].speed * dt * 0.9
  game.enemies[idx].vy = game.enemies[idx].vy * (1.0 - dt * 7.5) +
    dir.1 * game.enemies[idx].speed * dt * 0.9

  game.enemies[idx].x = game.enemies[idx].x + game.enemies[idx].vx * dt
  game.enemies[idx].y = game.enemies[idx].y + game.enemies[idx].vy * dt

  if game.enemies[idx].state_t <= 0.0 {
    let strike_dir = normalize(
      game.player_x - game.enemies[idx].x,
      game.player_y - game.enemies[idx].y,
    )

    game.enemies[idx].state = enemy_state_strike
    game.enemies[idx].state_t = enemy_strike_t

    let strike_speed : Float = 520.0 + Float::from_int(game.wave) * 18.0
    game.enemies[idx].vx = strike_dir.0 * strike_speed
    game.enemies[idx].vy = strike_dir.1 * strike_speed
  }
}

///|
fn update_enemy_strike(game : Game, idx : Int, dt : Float) -> Unit {
  game.enemies[idx].state_t = maxf(0.0, game.enemies[idx].state_t - dt)

  game.enemies[idx].x = game.enemies[idx].x + game.enemies[idx].vx * dt
  game.enemies[idx].y = game.enemies[idx].y + game.enemies[idx].vy * dt
  game.enemies[idx].vx = game.enemies[idx].vx * (1.0 - dt * 1.7)
  game.enemies[idx].vy = game.enemies[idx].vy * (1.0 - dt * 1.7)

  let hit_rr : Float = player_radius + game.enemies[idx].radius + 4.0
  if dist2(
      game.player_x,
      game.player_y,
      game.enemies[idx].x,
      game.enemies[idx].y,
    ) <=
    hit_rr * hit_rr {
    if game.parry_t > 0.0 {
      stun_enemy_from_parry(game, idx, true)
      set_message(game, "Counter cut!", 0.50)
    } else {
      hurt_player(
        game,
        enemy_contact_damage + Float::from_int(game.wave) * 1.05,
      )
      game.enemies[idx].state = enemy_state_recover
      game.enemies[idx].state_t = enemy_recover_t
      game.enemies[idx].vx = -game.enemies[idx].vx * 0.36
      game.enemies[idx].vy = -game.enemies[idx].vy * 0.36
      return
    }
  }

  if game.enemies[idx].state_t <= 0.0 {
    game.enemies[idx].state = enemy_state_recover
    game.enemies[idx].state_t = enemy_recover_t
  }
}

///|
fn update_enemy_recover(game : Game, idx : Int, dt : Float) -> Unit {
  game.enemies[idx].state_t = maxf(0.0, game.enemies[idx].state_t - dt)

  game.enemies[idx].x = game.enemies[idx].x + game.enemies[idx].vx * dt
  game.enemies[idx].y = game.enemies[idx].y + game.enemies[idx].vy * dt

  game.enemies[idx].vx = game.enemies[idx].vx * (1.0 - dt * 6.0)
  game.enemies[idx].vy = game.enemies[idx].vy * (1.0 - dt * 6.0)

  if game.enemies[idx].state_t <= 0.0 {
    game.enemies[idx].state = enemy_state_seek
    game.enemies[idx].state_t = 0.0
  }
}

///|
fn update_enemy_stunned(game : Game, idx : Int, dt : Float) -> Unit {
  game.enemies[idx].state_t = maxf(0.0, game.enemies[idx].state_t - dt)

  game.enemies[idx].x = game.enemies[idx].x + game.enemies[idx].vx * dt
  game.enemies[idx].y = game.enemies[idx].y + game.enemies[idx].vy * dt

  game.enemies[idx].vx = game.enemies[idx].vx * (1.0 - dt * 7.8)
  game.enemies[idx].vy = game.enemies[idx].vy * (1.0 - dt * 7.8)

  if game.enemies[idx].state_t <= 0.0 {
    game.enemies[idx].state = enemy_state_seek
    game.enemies[idx].state_t = 0.0
  }
}

///|
fn keep_enemy_inside_rooftop(game : Game, idx : Int) -> Unit {
  let left : Float = arena_left() - 120.0
  let right : Float = arena_right() + 120.0
  let top : Float = arena_top() - 120.0
  let bottom : Float = arena_bottom() + 120.0

  if game.enemies[idx].x < left {
    game.enemies[idx].x = left
    game.enemies[idx].vx = absf(game.enemies[idx].vx) * 0.4
  } else if game.enemies[idx].x > right {
    game.enemies[idx].x = right
    game.enemies[idx].vx = -absf(game.enemies[idx].vx) * 0.4
  }

  if game.enemies[idx].y < top {
    game.enemies[idx].y = top
    game.enemies[idx].vy = absf(game.enemies[idx].vy) * 0.4
  } else if game.enemies[idx].y > bottom {
    game.enemies[idx].y = bottom
    game.enemies[idx].vy = -absf(game.enemies[idx].vy) * 0.4
  }
}

///|
fn update_enemies(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue
    }

    game.enemies[i].visual_phase = game.enemies[i].visual_phase +
      dt * (1.4 + Float::from_int(i % 5) * 0.3)

    if game.enemies[i].state == enemy_state_seek {
      update_enemy_seek(game, i, dt)
    } else if game.enemies[i].state == enemy_state_telegraph {
      update_enemy_telegraph(game, i, dt)
    } else if game.enemies[i].state == enemy_state_strike {
      update_enemy_strike(game, i, dt)
    } else if game.enemies[i].state == enemy_state_recover {
      update_enemy_recover(game, i, dt)
    } else {
      update_enemy_stunned(game, i, dt)
    }

    keep_enemy_inside_rooftop(game, i)
  }
}

///|
fn update_wave_flow(game : Game, dt : Float) -> Unit {
  let before_gap : Float = game.wave_gap_t
  game.wave_gap_t = maxf(0.0, game.wave_gap_t - dt)

  if before_gap > 0.0 && game.wave_gap_t <= 0.0 {
    set_message(game, "Wave " + game.wave.to_string() + " begins.", 1.1)
  }

  if game.wave_gap_t > 0.0 {
    return
  }

  game.spawn_cd = game.spawn_cd - dt
  let interval : Float = wave_spawn_interval(game.wave)

  while game.spawn_cd <= 0.0 && game.wave_spawned < game.wave_enemies_total {
    if spawn_enemy(game) {
      game.wave_spawned = game.wave_spawned + 1
    }
    game.spawn_cd = game.spawn_cd + interval
  }

  if game.wave_spawned < game.wave_enemies_total {
    return
  }

  if game.wave_defeated < game.wave_enemies_total {
    return
  }

  if active_enemy_count(game) > 0 {
    return
  }

  let cleared_wave : Int = game.wave
  let bonus : Int = 100 +
    cleared_wave * 44 +
    game.stage_score / 2 +
    mini(500, game.combo * 6)

  game.last_stage_bonus = bonus
  game.score = game.score + bonus

  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.wave = game.wave + 1
  game.wave_enemies_total = wave_enemy_total(game.wave)
  game.wave_spawned = 0
  game.wave_defeated = 0
  game.stage_score = 0
  game.spawn_cd = 0.2
  game.wave_gap_t = wave_gap_duration

  set_message(
    game,
    "Wave " +
    cleared_wave.to_string() +
    " cleared! Stage bonus +" +
    bonus.to_string(),
    2.0,
  )
}

///|
fn update_timers(game : Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt
  game.message_t = maxf(0.0, game.message_t - dt)
  game.shake_t = maxf(0.0, game.shake_t - dt)

  if game.message_t <= 0.0 {
    game.message = ""
  }
}

///|
fn update_play_timers(game : Game, dt : Float) -> Unit {
  update_timers(game, dt)

  game.game_t = game.game_t + dt
  game.attack_cd = maxf(0.0, game.attack_cd - dt)
  game.attack_anim_t = maxf(0.0, game.attack_anim_t - dt)
  game.parry_t = maxf(0.0, game.parry_t - dt)
  game.dash_t_left = maxf(0.0, game.dash_t_left - dt)
  game.invuln_t = maxf(0.0, game.invuln_t - dt)

  game.combo_t = maxf(0.0, game.combo_t - dt)
  if game.combo_t <= 0.0 {
    game.combo = 0
  }

  if game.attack_anim_t <= 0.0 {
    game.attack_kind = attack_none
  }

  let regen : Float = if game.attack_anim_t > 0.0 || game.parry_t > 0.0 {
    stamina_regen_slow
  } else {
    stamina_regen_fast
  }
  game.stamina = minf(player_max_stamina, game.stamina + regen * dt)
}

///|
fn update_logic(game : Game, dt : Float) -> Unit {
  let step : Float = clampf(dt, 0.0, 0.05)

  if game.state == state_playing {
    update_play_timers(game, step)
  } else {
    update_timers(game, step)
    return
  }

  update_player(game, step)

  if game.parry_t > 0.0 {
    let parried : Int = resolve_parry_window(game)
    if parried > 0 {
      set_message(game, "Perfect parry x" + parried.to_string(), 0.65)
    }
  }

  update_wave_flow(game, step)
  update_enemies(game, step)

  if game.health <= 0.0 {
    finish_game_over(game)
  }
}
