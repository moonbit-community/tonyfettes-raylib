///|
fn reset_threat(threat : @types.Threat) -> Unit {
  threat.active = false
  threat.kind = @types.threat_firecracker
  threat.x = 0.0
  threat.y = 0.0
  threat.speed = 0.0
  threat.radius = 0.0
  threat.stun_t = 0.0
  threat.spin = 0.0
}

///|
fn clear_threats(game : @types.Game) -> Unit {
  for threat in game.threats {
    reset_threat(threat)
  }
}

///|
fn spawn_interval(elapsed : Float) -> Float {
  @types.clampf(
    @types.spawn_time_start - elapsed * @types.spawn_difficulty_ramp,
    @types.spawn_time_floor,
    @types.spawn_time_start,
  )
}

///|
fn speed_bonus(elapsed : Float) -> Float {
  @types.clampf(elapsed * 3.8, 0.0, @types.speed_scale_max_bonus)
}

///|
fn start_run(game : @types.Game) -> Unit {
  game.state = Playing

  game.troupe_x = Float::from_int(@types.street_left + 220)
  game.troupe_lane = @types.troupe_start_lane
  game.troupe_y = @types.lane_y(game.troupe_lane)

  game.score = 0
  game.cleared = 0
  game.leaked = 0

  game.combo = 0
  game.combo_t = 0.0

  game.hype = 28.0
  game.morale = @types.morale_start
  game.crowd_order = @types.order_start

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

  @types.set_msg(game, "Festival open. Keep the lanes orderly.", 2.2)
}

///|
fn spawn_threat(game : @types.Game) -> Unit {
  let mut slot = -1
  for i in 0..<game.threats.length() {
    if not(game.threats[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    return
  }

  let incident_rate = @types.clampf(
    0.24 + game.elapsed * 0.0038,
    0.24,
    0.62,
  )
  let kind = if @types.randf(0.0, 1.0) < incident_rate {
    @types.threat_incident
  } else {
    @types.threat_firecracker
  }

  let lane = @raylib.get_random_value(0, @types.lane_count - 1)
  let spawn_x = Float::from_int(
    @types.street_right + 70 + @raylib.get_random_value(0, 260),
  )

  let base_speed = if kind == @types.threat_firecracker {
    @types.firecracker_speed_base
  } else {
    @types.incident_speed_base
  }

  game.threats[slot].active = true
  game.threats[slot].kind = kind
  game.threats[slot].x = spawn_x
  game.threats[slot].y = @types.lane_y(lane)
  game.threats[slot].speed = base_speed + speed_bonus(game.elapsed)
  game.threats[slot].radius = if kind == @types.threat_firecracker {
    24.0
  } else {
    32.0
  }
  game.threats[slot].stun_t = 0.0
  game.threats[slot].spin = @types.randf(0.0, 6.2)
}

///|
fn score_for_clear(
  kind : Int,
  combo : Int,
  action : @types.Action,
  stunned : Bool,
) -> Int {
  let mut score = if kind == @types.threat_firecracker {
    @types.score_firecracker
  } else {
    @types.score_incident
  }

  match action {
    Guard => score = score - 14
    Burst => score = score - 24
    Strike => ()
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
  action : @types.Action,
  stunned : Bool,
) -> Float {
  let mut gain = if kind == @types.threat_firecracker {
    @types.hype_gain_firecracker
  } else {
    @types.hype_gain_incident
  }

  match action {
    Burst => gain = gain * 0.85
    Strike | Guard => ()
  }

  if stunned {
    gain = gain + 2.4
  }

  gain + Float::from_int(combo) * @types.hype_gain_combo_step
}

///|
fn register_clear(
  game : @types.Game,
  kind : Int,
  action : @types.Action,
  stunned : Bool,
) -> Unit {
  if game.combo_t <= 0.0 {
    game.combo = 0
  }

  game.combo = game.combo + 1
  game.combo_t = @types.combo_keep_time

  let gain_score = score_for_clear(kind, game.combo, action, stunned)
  game.score = game.score + gain_score
  if game.score > game.best_score {
    game.best_score = game.score
  }

  let gain_hype = hype_for_clear(kind, game.combo, action, stunned)
  game.hype = @types.clampf(game.hype + gain_hype, 0.0, @types.hype_max)

  let order_gain = @types.order_gain_on_clear +
    @types.minf(3.8, Float::from_int(game.combo) * 0.22)
  game.crowd_order = @types.clampf(
    game.crowd_order + order_gain,
    0.0,
    @types.order_max,
  )

  game.cleared = game.cleared + 1
  game.flash_t = @types.maxf(game.flash_t, 0.07)
}

///|
fn clear_threat_at(game : @types.Game, i : Int, action : @types.Action) -> Unit {
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
  game : @types.Game,
  order_loss : Float,
  morale_loss : Float,
  msg : String,
) -> Unit {
  game.crowd_order = @types.clampf(
    game.crowd_order - order_loss,
    0.0,
    @types.order_max,
  )
  game.morale = @types.clampf(
    game.morale - morale_loss,
    0.0,
    @types.morale_max,
  )

  game.combo = 0
  game.combo_t = 0.0
  game.leaked = game.leaked + 1

  game.flash_t = @types.maxf(game.flash_t, 0.28)
  game.shake_t = @types.maxf(game.shake_t, 0.22)
  @types.set_msg(game, msg, @types.msg_ttl)
}

///|
fn breach_penalty(game : @types.Game, kind : Int) -> Unit {
  if kind == @types.threat_firecracker {
    lose_order(
      game,
      @types.breach_order_loss_firecracker,
      @types.breach_morale_loss_firecracker,
      "Firecracker slipped through the line!",
    )
  } else {
    lose_order(
      game,
      @types.breach_order_loss_incident,
      @types.breach_morale_loss_incident,
      "Crowd incident reached the parade core!",
    )
  }
}

///|
fn contact_penalty(game : @types.Game, kind : Int) -> Unit {
  if kind == @types.threat_firecracker {
    lose_order(
      game,
      6.0,
      @types.collision_morale_loss_firecracker,
      "Blast near the troupe!",
    )
  } else {
    lose_order(
      game,
      9.0,
      @types.collision_morale_loss_incident,
      "Formation broken by a crowd surge!",
    )
  }
}

///|
fn update_troupe(game : @types.Game, dt : Float) -> Unit {
  let mut vx = Float::from_int(game.input.move_x)
  let mut vy = Float::from_int(game.input.move_y)

  if vx != 0.0 && vy != 0.0 {
    vx = vx * 0.7071
    vy = vy * 0.7071
  }

  game.troupe_x = game.troupe_x + vx * @types.troupe_move_speed * dt
  game.troupe_y = game.troupe_y + vy * @types.troupe_move_speed * dt

  let min_x = Float::from_int(@types.street_left) + @types.troupe_w * 0.5
  let max_x = Float::from_int(@types.street_right) - @types.troupe_w * 0.5
  let min_y = @types.lane_y(0)
  let max_y = @types.lane_y(@types.lane_count - 1)

  game.troupe_x = @types.clampf(game.troupe_x, min_x, max_x)
  game.troupe_y = @types.clampf(game.troupe_y, min_y, max_y)
  game.troupe_lane = @types.lane_from_y(game.troupe_y)
}

///|
fn handle_strike(game : @types.Game) -> Unit {
  if game.strike_cd > 0.0 {
    return
  }

  game.strike_cd = @types.strike_cd_time
  game.strike_t = @types.strike_fx_time

  let mut cleared_now = 0
  for i in 0..<game.threats.length() {
    if not(game.threats[i].active) {
      continue
    }

    if game.threats[i].kind == @types.threat_incident &&
      game.threats[i].stun_t <= 0.0 {
      continue
    }

    let reach = @types.strike_radius + game.threats[i].radius
    if @types.dist2(
        game.troupe_x,
        game.troupe_y,
        game.threats[i].x,
        game.threats[i].y,
      ) <=
      @types.squaref(reach) {
      clear_threat_at(game, i, Strike)
      cleared_now = cleared_now + 1
    }
  }

  if cleared_now > 0 {
    @types.set_msg(
      game,
      "Drum strike cleared \{cleared_now} threat(s)!",
      @types.msg_ttl,
    )
  } else {
    game.combo = 0
    game.combo_t = 0.0
    @types.set_msg(game, "Strike missed. Rhythm dropped.", @types.msg_ttl)
  }
}

///|
fn handle_guard(game : @types.Game) -> Unit {
  if game.guard_cd > 0.0 {
    return
  }

  game.guard_cd = @types.guard_cd_time
  game.guard_t = @types.guard_hold_time

  let mut stunned_now = 0

  for threat in game.threats {
    if not(threat.active) {
      continue
    }
    if threat.kind != @types.threat_incident {
      continue
    }

    let reach = @types.guard_radius + threat.radius
    if @types.dist2(game.troupe_x, game.troupe_y, threat.x, threat.y) >
      @types.squaref(reach) {
      continue
    }

    let fresh = threat.stun_t <= 0.0
    threat.stun_t = @types.maxf(threat.stun_t, @types.guard_stun_time)

    if fresh {
      stunned_now = stunned_now + 1
      game.score = game.score + @types.score_guard_stun
      if game.score > game.best_score {
        game.best_score = game.score
      }
      game.hype = @types.clampf(
        game.hype + @types.hype_gain_guard_stun,
        0.0,
        @types.hype_max,
      )
      game.crowd_order = @types.clampf(
        game.crowd_order + 0.9,
        0.0,
        @types.order_max,
      )
    }
  }

  if stunned_now > 0 {
    @types.set_msg(
      game,
      "Guard stunned \{stunned_now} incident(s).",
      @types.msg_ttl,
    )
  } else {
    @types.set_msg(game, "Guard stance raised.", @types.msg_ttl)
  }
}

///|
fn trigger_burst(game : @types.Game) -> Unit {
  if game.burst_cd > 0.0 {
    @types.set_msg(game, "Hype burst recharging.", @types.msg_ttl)
    return
  }

  if game.hype < @types.burst_cost {
    @types.set_msg(game, "Need more hype for burst.", @types.msg_ttl)
    return
  }

  game.hype = @types.clampf(game.hype - @types.burst_cost, 0.0, @types.hype_max)
  game.burst_t = @types.burst_duration
  game.burst_cd = @types.burst_cd_time
  game.flash_t = @types.maxf(game.flash_t, 0.16)

  @types.set_msg(game, "Hype burst unleashed!", @types.msg_ttl)
}

///|
fn update_action_timers(game : @types.Game, dt : Float) -> Unit {
  if game.strike_cd > 0.0 {
    game.strike_cd = @types.maxf(0.0, game.strike_cd - dt)
  }
  if game.strike_t > 0.0 {
    game.strike_t = @types.maxf(0.0, game.strike_t - dt)
  }
  if game.guard_cd > 0.0 {
    game.guard_cd = @types.maxf(0.0, game.guard_cd - dt)
  }
  if game.guard_t > 0.0 {
    game.guard_t = @types.maxf(0.0, game.guard_t - dt)
  }
  if game.burst_cd > 0.0 {
    game.burst_cd = @types.maxf(0.0, game.burst_cd - dt)
  }
  if game.burst_t > 0.0 {
    game.burst_t = @types.maxf(0.0, game.burst_t - dt)
  }

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      game.combo_t = 0.0
      game.combo = 0
    }
  }

  if game.msg_t > 0.0 {
    game.msg_t = @types.maxf(0.0, game.msg_t - dt)
  }
  if game.flash_t > 0.0 {
    game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  }
  if game.shake_t > 0.0 {
    game.shake_t = @types.maxf(0.0, game.shake_t - dt)
  }
}

///|
fn update_spawn(game : @types.Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  while game.spawn_t <= 0.0 {
    spawn_threat(game)
    game.spawn_t = game.spawn_t + spawn_interval(game.elapsed)
  }
}

///|
fn update_threats(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.threats.length() {
    if not(game.threats[i].active) {
      continue
    }

    if game.threats[i].stun_t > 0.0 {
      game.threats[i].stun_t = @types.maxf(0.0, game.threats[i].stun_t - dt)
    }

    let mut move_scale : Float = 1.0 +
      @types.clampf(game.elapsed * 0.0022, 0.0, 0.55)
    if game.threats[i].stun_t > 0.0 {
      move_scale = if game.threats[i].kind == @types.threat_incident {
        move_scale * 0.30
      } else {
        move_scale * 0.55
      }
    }

    game.threats[i].x = game.threats[i].x -
      game.threats[i].speed * move_scale * dt
    game.threats[i].spin = game.threats[i].spin +
      dt *
      (if game.threats[i].kind == @types.threat_firecracker { 5.8 } else { 3.4 })

    let contact_r = game.threats[i].radius + @types.troupe_w * 0.32
    if @types.dist2(
        game.troupe_x,
        game.troupe_y,
        game.threats[i].x,
        game.threats[i].y,
      ) <=
      @types.squaref(contact_r) {
      if game.guard_t > 0.0 {
        if game.threats[i].kind == @types.threat_firecracker {
          clear_threat_at(game, i, Guard)
        } else {
          let fresh = game.threats[i].stun_t <= 0.0
          game.threats[i].stun_t = @types.maxf(
            game.threats[i].stun_t,
            @types.guard_stun_time,
          )
          game.threats[i].x = game.threats[i].x + 34.0
          if fresh {
            game.score = game.score + @types.score_guard_stun
            if game.score > game.best_score {
              game.best_score = game.score
            }
            game.hype = @types.clampf(
              game.hype + @types.hype_gain_guard_stun,
              0.0,
              @types.hype_max,
            )
          }
        }
      } else {
        let kind = game.threats[i].kind
        game.threats[i].active = false
        contact_penalty(game, kind)
      }
      continue
    }

    if game.threats[i].x < Float::from_int(@types.street_left - 84) {
      let kind = game.threats[i].kind
      game.threats[i].active = false
      breach_penalty(game, kind)
    }
  }
}

///|
fn apply_burst_field(game : @types.Game) -> Unit {
  if game.burst_t <= 0.0 {
    return
  }

  let mut cleared_now = 0
  for i in 0..<game.threats.length() {
    if not(game.threats[i].active) {
      continue
    }

    let reach = @types.burst_radius + game.threats[i].radius
    if @types.dist2(
        game.troupe_x,
        game.troupe_y,
        game.threats[i].x,
        game.threats[i].y,
      ) <=
      @types.squaref(reach) {
      clear_threat_at(game, i, Burst)
      cleared_now = cleared_now + 1
    }
  }

  if cleared_now > 0 && game.msg_t < 0.2 {
    @types.set_msg(game, "Hype burst cleared \{cleared_now} threat(s)!", 0.8)
  }
}

///|
fn apply_order_pressure(game : @types.Game, dt : Float) -> Unit {
  game.crowd_order = @types.clampf(
    game.crowd_order + @types.order_recover_rate * dt,
    0.0,
    @types.order_max,
  )
  if game.combo > 0 {
    game.crowd_order = @types.clampf(
      game.crowd_order + Float::from_int(game.combo) * 0.11 * dt,
      0.0,
      @types.order_max,
    )
  }

  if game.crowd_order < @types.order_pressure_threshold {
    let pressure = @types.order_pressure_threshold - game.crowd_order
    game.morale = @types.clampf(
      game.morale - pressure * @types.order_pressure_drain_rate * dt,
      0.0,
      @types.morale_max,
    )
  }
}

///|
fn finish_if_needed(game : @types.Game) -> Unit {
  if game.morale > 0.0 {
    return
  }

  game.morale = 0.0
  game.state = GameOver
  game.combo = 0
  game.combo_t = 0.0
  game.guard_t = 0.0
  game.burst_t = 0.0

  if game.score > game.best_score {
    game.best_score = game.score
  }

  @types.set_msg(game, "Morale collapsed. Parade lost.", 2.2)
}

///|
fn update_title_state(game : @types.Game) -> Unit {
  if game.input.press_start || game.input.press_restart {
    start_run(game)
  }
}

///|
fn update_paused_state(game : @types.Game) -> Unit {
  if game.input.press_restart {
    start_run(game)
    return
  }

  if game.input.press_pause || game.input.press_start {
    game.state = Playing
    @types.set_msg(game, "Back in formation.", @types.msg_ttl)
  }
}

///|
fn update_game_over_state(game : @types.Game) -> Unit {
  if game.input.press_restart || game.input.press_start {
    start_run(game)
  }
}

///|
fn update_playing_state(game : @types.Game, dt : Float) -> Unit {
  if game.input.press_restart {
    start_run(game)
    return
  }

  if game.input.press_pause {
    game.state = Paused
    @types.set_msg(game, "Paused. P to resume, R to restart.", 2.0)
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
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  update_input(game)

  game.time_s = game.time_s + dt

  match game.state {
    Title => {
      if game.msg_t > 0.0 {
        game.msg_t = @types.maxf(0.0, game.msg_t - dt)
      }
      update_title_state(game)
    }
    Playing => update_playing_state(game, dt)
    Paused => update_paused_state(game)
    GameOver => {
      if game.msg_t > 0.0 {
        game.msg_t = @types.maxf(0.0, game.msg_t - dt)
      }
      update_game_over_state(game)
    }
  }
}
