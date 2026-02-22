///|
fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
fn reset_threat(threat : Threat) -> Unit {
  threat.active = false
  threat.kind = threat_firecracker
  threat.x = 0.0
  threat.y = 0.0
  threat.speed = 0.0
  threat.radius = 0.0
  threat.stun_t = 0.0
  threat.spin = 0.0
}

///|
fn clear_threats(game : Game) -> Unit {
  for i = 0; i < game.threats.length(); i = i + 1 {
    reset_threat(game.threats[i])
  }
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn spawn_interval(elapsed : Float) -> Float {
  clampf(
    spawn_time_start - elapsed * spawn_difficulty_ramp,
    spawn_time_floor,
    spawn_time_start,
  )
}

///|
fn speed_bonus(elapsed : Float) -> Float {
  clampf(elapsed * 3.8, 0.0, speed_scale_max_bonus)
}

///|
fn start_run(game : Game) -> Unit {
  game.state = state_playing

  game.troupe_x = Float::from_int(street_left + 220)
  game.troupe_lane = troupe_start_lane
  game.troupe_y = lane_y(game.troupe_lane)

  game.score = 0
  game.cleared = 0
  game.leaked = 0

  game.combo = 0
  game.combo_t = 0.0

  game.hype = 28.0
  game.morale = morale_start
  game.crowd_order = order_start

  game.strike_cd = 0.0
  game.strike_t = 0.0
  game.guard_cd = 0.0
  game.guard_t = 0.0
  game.burst_cd = 0.0
  game.burst_t = 0.0

  game.spawn_t = 0.8
  game.elapsed = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0

  game.msg = ""
  game.msg_t = 0.0

  clear_threats(game)

  set_msg(game, "Festival open. Keep the lanes orderly.", 2.2)
}

///|
fn spawn_threat(game : Game) -> Unit {
  let mut slot = -1
  for i = 0; i < game.threats.length(); i = i + 1 {
    if not(game.threats[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    return
  }

  let incident_rate = clampf(0.24 + game.elapsed * 0.0038, 0.24, 0.62)
  let kind = if randf(0.0, 1.0) < incident_rate {
    threat_incident
  } else {
    threat_firecracker
  }

  let lane = @raylib.get_random_value(0, lane_count - 1)
  let spawn_x = Float::from_int(
    street_right + 70 + @raylib.get_random_value(0, 260),
  )

  let base_speed = if kind == threat_firecracker {
    firecracker_speed_base
  } else {
    incident_speed_base
  }

  game.threats[slot].active = true
  game.threats[slot].kind = kind
  game.threats[slot].x = spawn_x
  game.threats[slot].y = lane_y(lane)
  game.threats[slot].speed = base_speed + speed_bonus(game.elapsed)
  game.threats[slot].radius = if kind == threat_firecracker {
    24.0
  } else {
    32.0
  }
  game.threats[slot].stun_t = 0.0
  game.threats[slot].spin = randf(0.0, 6.2)
}

///|
fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
fn score_for_clear(
  kind : Int,
  combo : Int,
  action : Int,
  stunned : Bool,
) -> Int {
  let mut score = if kind == threat_firecracker {
    score_firecracker
  } else {
    score_incident
  }

  if action == action_guard {
    score = score - 14
  } else if action == action_burst {
    score = score - 24
  }

  if stunned {
    score = score + 28
  }

  score = score + combo * 16

  if score < 20 {
    20
  } else {
    score
  }
}

///|
fn hype_for_clear(
  kind : Int,
  combo : Int,
  action : Int,
  stunned : Bool,
) -> Float {
  let mut gain = if kind == threat_firecracker {
    hype_gain_firecracker
  } else {
    hype_gain_incident
  }

  if action == action_burst {
    gain = gain * 0.85
  }

  if stunned {
    gain = gain + 2.4
  }

  gain + Float::from_int(combo) * hype_gain_combo_step
}

///|
fn register_clear(
  game : Game,
  kind : Int,
  action : Int,
  stunned : Bool,
) -> Unit {
  if game.combo_t <= 0.0 {
    game.combo = 0
  }

  game.combo = game.combo + 1
  game.combo_t = combo_keep_time

  let gain_score = score_for_clear(kind, game.combo, action, stunned)
  game.score = game.score + gain_score
  if game.score > game.best_score {
    game.best_score = game.score
  }

  let gain_hype = hype_for_clear(kind, game.combo, action, stunned)
  game.hype = clampf(game.hype + gain_hype, 0.0, hype_max)

  let order_gain = order_gain_on_clear +
    minf(3.8, Float::from_int(game.combo) * 0.22)
  game.crowd_order = clampf(game.crowd_order + order_gain, 0.0, order_max)

  game.cleared = game.cleared + 1
  game.flash_t = maxf(game.flash_t, 0.07)
}

///|
fn clear_threat_at(game : Game, i : Int, action : Int) -> Unit {
  if i < 0 || i >= game.threats.length() {
    return
  }
  if not(game.threats[i].active) {
    return
  }

  let kind = game.threats[i].kind
  let stunned = game.threats[i].stun_t > 0.0

  game.threats[i].active = false
  game.threats[i].stun_t = 0.0

  register_clear(game, kind, action, stunned)
}

///|
fn lose_order(
  game : Game,
  order_loss : Float,
  morale_loss : Float,
  msg : String,
) -> Unit {
  game.crowd_order = clampf(game.crowd_order - order_loss, 0.0, order_max)
  game.morale = clampf(game.morale - morale_loss, 0.0, morale_max)

  game.combo = 0
  game.combo_t = 0.0
  game.leaked = game.leaked + 1

  game.flash_t = maxf(game.flash_t, 0.28)
  game.shake_t = maxf(game.shake_t, 0.22)
  set_msg(game, msg, msg_ttl)
}

///|
fn breach_penalty(game : Game, kind : Int) -> Unit {
  if kind == threat_firecracker {
    lose_order(
      game, breach_order_loss_firecracker, breach_morale_loss_firecracker, "Firecracker slipped through the line!",
    )
  } else {
    lose_order(
      game, breach_order_loss_incident, breach_morale_loss_incident, "Crowd incident reached the parade core!",
    )
  }
}

///|
fn contact_penalty(game : Game, kind : Int) -> Unit {
  if kind == threat_firecracker {
    lose_order(
      game, 6.0, collision_morale_loss_firecracker, "Blast near the troupe!",
    )
  } else {
    lose_order(
      game, 9.0, collision_morale_loss_incident, "Formation broken by a crowd surge!",
    )
  }
}

///|
fn update_troupe(game : Game, dt : Float) -> Unit {
  let mut vx = Float::from_int(game.input.move_x)
  let mut vy = Float::from_int(game.input.move_y)

  if vx != 0.0 && vy != 0.0 {
    vx = vx * 0.7071
    vy = vy * 0.7071
  }

  game.troupe_x = game.troupe_x + vx * troupe_move_speed * dt
  game.troupe_y = game.troupe_y + vy * troupe_move_speed * dt

  let min_x = Float::from_int(street_left) + troupe_w * 0.5
  let max_x = Float::from_int(street_right) - troupe_w * 0.5
  let min_y = lane_y(0)
  let max_y = lane_y(lane_count - 1)

  game.troupe_x = clampf(game.troupe_x, min_x, max_x)
  game.troupe_y = clampf(game.troupe_y, min_y, max_y)
  game.troupe_lane = lane_from_y(game.troupe_y)
}

///|
fn handle_strike(game : Game) -> Unit {
  if game.strike_cd > 0.0 {
    return
  }

  game.strike_cd = strike_cd_time
  game.strike_t = strike_fx_time

  let mut cleared_now = 0
  for i = 0; i < game.threats.length(); i = i + 1 {
    if not(game.threats[i].active) {
      continue
    }

    if game.threats[i].kind == threat_incident && game.threats[i].stun_t <= 0.0 {
      continue
    }

    let reach = strike_radius + game.threats[i].radius
    if dist2(game.troupe_x, game.troupe_y, game.threats[i].x, game.threats[i].y) <=
      squaref(reach) {
      clear_threat_at(game, i, action_strike)
      cleared_now = cleared_now + 1
    }
  }

  if cleared_now > 0 {
    set_msg(game, "Drum strike cleared \{cleared_now} threat(s)!", msg_ttl)
  } else {
    game.combo = 0
    game.combo_t = 0.0
    set_msg(game, "Strike missed. Rhythm dropped.", msg_ttl)
  }
}

///|
fn handle_guard(game : Game) -> Unit {
  if game.guard_cd > 0.0 {
    return
  }

  game.guard_cd = guard_cd_time
  game.guard_t = guard_hold_time

  let mut stunned_now = 0

  for i = 0; i < game.threats.length(); i = i + 1 {
    if not(game.threats[i].active) {
      continue
    }
    if game.threats[i].kind != threat_incident {
      continue
    }

    let reach = guard_radius + game.threats[i].radius
    if dist2(game.troupe_x, game.troupe_y, game.threats[i].x, game.threats[i].y) >
      squaref(reach) {
      continue
    }

    let fresh = game.threats[i].stun_t <= 0.0
    game.threats[i].stun_t = maxf(game.threats[i].stun_t, guard_stun_time)

    if fresh {
      stunned_now = stunned_now + 1
      game.score = game.score + score_guard_stun
      if game.score > game.best_score {
        game.best_score = game.score
      }
      game.hype = clampf(game.hype + hype_gain_guard_stun, 0.0, hype_max)
      game.crowd_order = clampf(game.crowd_order + 0.9, 0.0, order_max)
    }
  }

  if stunned_now > 0 {
    set_msg(game, "Guard stunned \{stunned_now} incident(s).", msg_ttl)
  } else {
    set_msg(game, "Guard stance raised.", msg_ttl)
  }
}

///|
fn trigger_burst(game : Game) -> Unit {
  if game.burst_cd > 0.0 {
    set_msg(game, "Hype burst recharging.", msg_ttl)
    return
  }

  if game.hype < burst_cost {
    set_msg(game, "Need more hype for burst.", msg_ttl)
    return
  }

  game.hype = clampf(game.hype - burst_cost, 0.0, hype_max)
  game.burst_t = burst_duration
  game.burst_cd = burst_cd_time
  game.flash_t = maxf(game.flash_t, 0.16)

  set_msg(game, "Hype burst unleashed!", msg_ttl)
}

///|
fn update_action_timers(game : Game, dt : Float) -> Unit {
  if game.strike_cd > 0.0 {
    game.strike_cd = maxf(0.0, game.strike_cd - dt)
  }
  if game.strike_t > 0.0 {
    game.strike_t = maxf(0.0, game.strike_t - dt)
  }
  if game.guard_cd > 0.0 {
    game.guard_cd = maxf(0.0, game.guard_cd - dt)
  }
  if game.guard_t > 0.0 {
    game.guard_t = maxf(0.0, game.guard_t - dt)
  }
  if game.burst_cd > 0.0 {
    game.burst_cd = maxf(0.0, game.burst_cd - dt)
  }
  if game.burst_t > 0.0 {
    game.burst_t = maxf(0.0, game.burst_t - dt)
  }

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      game.combo_t = 0.0
      game.combo = 0
    }
  }

  if game.msg_t > 0.0 {
    game.msg_t = maxf(0.0, game.msg_t - dt)
  }
  if game.flash_t > 0.0 {
    game.flash_t = maxf(0.0, game.flash_t - dt)
  }
  if game.shake_t > 0.0 {
    game.shake_t = maxf(0.0, game.shake_t - dt)
  }
}

///|
fn update_spawn(game : Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  while game.spawn_t <= 0.0 {
    spawn_threat(game)
    game.spawn_t = game.spawn_t + spawn_interval(game.elapsed)
  }
}

///|
fn update_threats(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.threats.length(); i = i + 1 {
    if not(game.threats[i].active) {
      continue
    }

    if game.threats[i].stun_t > 0.0 {
      game.threats[i].stun_t = maxf(0.0, game.threats[i].stun_t - dt)
    }

    let mut move_scale : Float = 1.0 + clampf(game.elapsed * 0.0022, 0.0, 0.55)
    if game.threats[i].stun_t > 0.0 {
      move_scale = if game.threats[i].kind == threat_incident {
        move_scale * 0.30
      } else {
        move_scale * 0.55
      }
    }

    game.threats[i].x = game.threats[i].x -
      game.threats[i].speed * move_scale * dt
    game.threats[i].spin = game.threats[i].spin +
      dt * (if game.threats[i].kind == threat_firecracker { 5.8 } else { 3.4 })

    let contact_r = game.threats[i].radius + troupe_w * 0.32
    if dist2(game.troupe_x, game.troupe_y, game.threats[i].x, game.threats[i].y) <=
      squaref(contact_r) {
      if game.guard_t > 0.0 {
        if game.threats[i].kind == threat_firecracker {
          clear_threat_at(game, i, action_guard)
        } else {
          let fresh = game.threats[i].stun_t <= 0.0
          game.threats[i].stun_t = maxf(game.threats[i].stun_t, guard_stun_time)
          game.threats[i].x = game.threats[i].x + 34.0
          if fresh {
            game.score = game.score + score_guard_stun
            if game.score > game.best_score {
              game.best_score = game.score
            }
            game.hype = clampf(game.hype + hype_gain_guard_stun, 0.0, hype_max)
          }
        }
      } else {
        let kind = game.threats[i].kind
        game.threats[i].active = false
        contact_penalty(game, kind)
      }
      continue
    }

    if game.threats[i].x < Float::from_int(street_left - 84) {
      let kind = game.threats[i].kind
      game.threats[i].active = false
      breach_penalty(game, kind)
    }
  }
}

///|
fn apply_burst_field(game : Game) -> Unit {
  if game.burst_t <= 0.0 {
    return
  }

  let mut cleared_now = 0
  for i = 0; i < game.threats.length(); i = i + 1 {
    if not(game.threats[i].active) {
      continue
    }

    let reach = burst_radius + game.threats[i].radius
    if dist2(game.troupe_x, game.troupe_y, game.threats[i].x, game.threats[i].y) <=
      squaref(reach) {
      clear_threat_at(game, i, action_burst)
      cleared_now = cleared_now + 1
    }
  }

  if cleared_now > 0 && game.msg_t < 0.2 {
    set_msg(game, "Hype burst cleared \{cleared_now} threat(s)!", 0.8)
  }
}

///|
fn apply_order_pressure(game : Game, dt : Float) -> Unit {
  game.crowd_order = clampf(
    game.crowd_order + order_recover_rate * dt,
    0.0,
    order_max,
  )
  if game.combo > 0 {
    game.crowd_order = clampf(
      game.crowd_order + Float::from_int(game.combo) * 0.11 * dt,
      0.0,
      order_max,
    )
  }

  if game.crowd_order < order_pressure_threshold {
    let pressure = order_pressure_threshold - game.crowd_order
    game.morale = clampf(
      game.morale - pressure * order_pressure_drain_rate * dt,
      0.0,
      morale_max,
    )
  }
}

///|
fn finish_if_needed(game : Game) -> Unit {
  if game.morale > 0.0 {
    return
  }

  game.morale = 0.0
  game.state = state_game_over
  game.combo = 0
  game.combo_t = 0.0
  game.guard_t = 0.0
  game.burst_t = 0.0

  if game.score > game.best_score {
    game.best_score = game.score
  }

  set_msg(game, "Morale collapsed. Parade lost.", 2.2)
}

///|
fn update_title_state(game : Game) -> Unit {
  if game.input.press_start || game.input.press_restart {
    start_run(game)
  }
}

///|
fn update_paused_state(game : Game) -> Unit {
  if game.input.press_restart {
    start_run(game)
    return
  }

  if game.input.press_pause || game.input.press_start {
    game.state = state_playing
    set_msg(game, "Back in formation.", msg_ttl)
  }
}

///|
fn update_game_over_state(game : Game) -> Unit {
  if game.input.press_restart || game.input.press_start {
    start_run(game)
  }
}

///|
fn update_playing_state(game : Game, dt : Float) -> Unit {
  if game.input.press_restart {
    start_run(game)
    return
  }

  if game.input.press_pause {
    game.state = state_paused
    set_msg(game, "Paused. P to resume, R to restart.", 2.0)
    return
  }

  game.elapsed = game.elapsed + dt

  update_action_timers(game, dt)
  update_troupe(game, dt)

  if game.input.press_guard {
    handle_guard(game)
  }
  if game.input.press_strike {
    handle_strike(game)
  }
  if game.input.press_burst {
    trigger_burst(game)
  }

  update_spawn(game, dt)
  update_threats(game, dt)
  apply_burst_field(game)
  apply_order_pressure(game, dt)
  finish_if_needed(game)
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt

  if game.state == state_title {
    if game.msg_t > 0.0 {
      game.msg_t = maxf(0.0, game.msg_t - dt)
    }
    update_title_state(game)
    return
  }

  if game.state == state_playing {
    update_playing_state(game, dt)
    return
  }

  if game.state == state_paused {
    update_paused_state(game)
    return
  }

  if game.msg_t > 0.0 {
    game.msg_t = maxf(0.0, game.msg_t - dt)
  }
  update_game_over_state(game)
}
