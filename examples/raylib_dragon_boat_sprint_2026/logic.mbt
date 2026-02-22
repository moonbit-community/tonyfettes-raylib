///|
fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
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

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
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
fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn set_message(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
fn add_score(game : Game, delta : Int) -> Unit {
  game.score = maxi(0, game.score + delta)
}

///|
fn clear_hazards(game : Game) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    game.hazards[i].active = false
    game.hazards[i].kind = hazard_debris
    game.hazards[i].lane = 0.0
    game.hazards[i].dist = 0.0
    game.hazards[i].size = 0.0
    game.hazards[i].drift = 0.0
    game.hazards[i].phase = 0.0
  }
}

///|
fn setup_rivals(game : Game) -> Unit {
  for i = 0; i < game.rivals.length(); i = i + 1 {
    let lane_seed : Float = if i == 0 {
      -0.78
    } else if i == 1 {
      -0.28
    } else if i == 2 {
      0.28
    } else {
      0.78
    }

    game.rivals[i].active = true
    game.rivals[i].id = i + 1
    game.rivals[i].lane = lane_seed + randf(-0.04, 0.04)
    game.rivals[i].dist = randf(-18.0, 24.0) + Float::from_int(i * 7 - 11)
    game.rivals[i].speed_bias = randf(-10.0, 13.0)
    game.rivals[i].stroke_t = randf(0.0, 6.28)
  }
}

///|
fn reset_run(game : Game) -> Unit {
  clear_hazards(game)
  setup_rivals(game)

  game.state = state_play
  game.distance = 0.0
  game.speed = base_speed
  game.lane = 0.0

  game.rhythm_t = 0.0
  game.stroke_cd = 0.0
  game.since_paddle_t = 0.0
  game.streak = 0
  game.best_streak = 0
  game.rhythm_meter = 0.0
  game.burst_t = 0.0

  game.wave_t = 0.0
  game.wobble = 0.0

  game.checkpoint_idx = 0

  game.score = 0
  game.hit_count = 0
  game.best_rank = max_rivals + 1
  game.finish_rank = max_rivals + 1
  game.finish_time = 0.0

  game.game_t = 0.0
  game.hazard_spawn_t = 0.35

  set_message(game, "Sprint started! Tap J in rhythm.", 2.2)
}

///|
fn current_rank(game : Game) -> Int {
  let mut ahead : Int = 0

  for i = 0; i < game.rivals.length(); i = i + 1 {
    if game.rivals[i].active && game.rivals[i].dist > game.distance {
      ahead = ahead + 1
    }
  }

  ahead + 1
}

///|
fn spawn_hazard(game : Game) -> Bool {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    if game.hazards[i].active {
      continue
    }

    let kind_roll = @raylib.get_random_value(0, 99)
    let kind : Int = if kind_roll < 58 { hazard_debris } else { hazard_wave }

    game.hazards[i].active = true
    game.hazards[i].kind = kind
    game.hazards[i].lane = Float::from_int(@raylib.get_random_value(-95, 95)) /
      100.0
    game.hazards[i].dist = game.distance + randf(420.0, 1380.0)
    game.hazards[i].size = if kind == hazard_debris {
      randf(18.0, 33.0)
    } else {
      randf(30.0, 56.0)
    }
    game.hazards[i].drift = randf(-0.4, 0.4)
    game.hazards[i].phase = randf(0.0, 6.28)

    return true
  }

  false
}

///|
fn update_rhythm(game : Game, dt : Float) -> Unit {
  game.rhythm_t = game.rhythm_t + dt
  while game.rhythm_t >= beat_period {
    game.rhythm_t = game.rhythm_t - beat_period
  }

  game.stroke_cd = maxf(0.0, game.stroke_cd - dt)
  game.since_paddle_t = game.since_paddle_t + dt

  let streak_drop_t : Float = beat_period * 1.35
  if game.since_paddle_t > streak_drop_t {
    if game.streak > 0 {
      game.streak = game.streak - 1
      game.since_paddle_t = game.since_paddle_t - beat_period * 0.8
    }
  }

  game.rhythm_meter = maxf(0.0, game.rhythm_meter - dt * 1.6)
}

///|
fn apply_paddle(game : Game) -> Unit {
  if game.stroke_cd > 0.0 {
    game.rhythm_meter = maxf(0.0, game.rhythm_meter - 8.0)
    game.wobble = minf(1.8, game.wobble + 0.06)
    set_message(game, "Stroke too rushed", 0.45)
    return
  }

  let miss : Float = minf(game.rhythm_t, beat_period - game.rhythm_t)

  if miss <= beat_perfect_window {
    game.streak = clampi(game.streak + 1, 0, 30)
    game.rhythm_meter = minf(
      100.0,
      game.rhythm_meter + 18.0 + Float::from_int(game.streak) * 0.35,
    )
    game.speed = game.speed + 48.0 + Float::from_int(game.streak) * 1.8
    game.wobble = maxf(0.0, game.wobble - 0.11)
    add_score(game, 15 + game.streak * 3)
    set_message(game, "Perfect stroke!", 0.5)
  } else if miss <= beat_good_window {
    game.streak = clampi(game.streak + 1, 0, 30)
    game.rhythm_meter = minf(100.0, game.rhythm_meter + 12.0)
    game.speed = game.speed + 33.0 + Float::from_int(game.streak)
    game.wobble = maxf(0.0, game.wobble - 0.04)
    add_score(game, 9 + game.streak * 2)
    set_message(game, "Good stroke", 0.35)
  } else {
    game.streak = 0
    game.rhythm_meter = maxf(0.0, game.rhythm_meter - 16.0)
    game.speed = maxf(70.0, game.speed - 22.0)
    game.wobble = minf(1.8, game.wobble + 0.14)
    add_score(game, -10)
    set_message(game, "Off-beat stroke", 0.7)
  }

  if game.streak > game.best_streak {
    game.best_streak = game.streak
  }

  game.stroke_cd = 0.1
  game.since_paddle_t = 0.0
}

///|
fn try_burst(game : Game) -> Unit {
  if game.burst_t <= 0.0 &&
    game.input.burst_pressed &&
    game.rhythm_meter >= 100.0 {
    game.burst_t = 1.2
    game.rhythm_meter = 0.0
    add_score(game, 90)
    set_message(game, "Dragon burst!", 1.0)
  }
}

///|
fn update_wave_lane(game : Game, dt : Float) -> Unit {
  game.wave_t = game.wave_t + dt

  let wave_force : Float = 0.5 +
    0.5 * sinf(game.wave_t * 1.82 + game.distance * 0.004)

  game.lane = game.lane + game.input.steer * dt * 2.4

  if game.input.stabilize_down {
    game.wobble = maxf(0.0, game.wobble - dt * (1.7 + wave_force * 1.2))
  } else {
    game.wobble = minf(1.8, game.wobble + dt * (0.28 + wave_force * 0.95))
  }

  let drift : Float = sinf(
      game.wave_t * 2.63 + game.distance * 0.002 + game.lane * 1.8,
    ) *
    dt *
    game.wobble *
    1.35

  game.lane = clampf(game.lane + drift, -1.08, 1.08)
}

///|
fn update_speed_distance(game : Game, dt : Float) -> Unit {
  let streak_bonus : Float = Float::from_int(mini(game.streak, 20)) * 2.4
  let rhythm_bonus : Float = game.rhythm_meter * 0.22
  let burst_bonus : Float = if game.burst_t > 0.0 { 108.0 } else { 0.0 }
  let stabilize_drag : Float = if game.input.stabilize_down { 8.0 } else { 0.0 }
  let wobble_penalty : Float = game.wobble * 28.0

  let target_speed : Float = base_speed +
    streak_bonus +
    rhythm_bonus +
    burst_bonus -
    stabilize_drag -
    wobble_penalty

  game.speed = clampf(
    game.speed + (target_speed - game.speed) * dt * 2.8,
    68.0,
    340.0,
  )

  game.distance = game.distance + game.speed * dt
  game.game_t = game.game_t + dt

  add_score(game, (game.speed * dt * 0.085).to_int())

  game.burst_t = maxf(0.0, game.burst_t - dt)
}

///|
fn update_hazard_spawning(game : Game, dt : Float) -> Unit {
  game.hazard_spawn_t = game.hazard_spawn_t - dt

  if game.hazard_spawn_t <= 0.0 {
    ignore(spawn_hazard(game))
    let pace : Float = maxf(0.2, 0.74 - game.distance / 9000.0)
    game.hazard_spawn_t = pace + randf(0.0, 0.32)
  }
}

///|
fn update_hazards(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    if not(game.hazards[i].active) {
      continue
    }

    game.hazards[i].phase = game.hazards[i].phase + dt
    game.hazards[i].lane = clampf(
      game.hazards[i].lane + game.hazards[i].drift * dt * 0.4,
      -1.08,
      1.08,
    )

    if game.hazards[i].dist < game.distance - 120.0 {
      game.hazards[i].active = false
      continue
    }

    let lane_delta : Float = absf(game.hazards[i].lane - game.lane)
    let dist_delta : Float = absf(game.hazards[i].dist - game.distance)

    let lane_hit_w : Float = if game.hazards[i].kind == hazard_debris {
      0.2
    } else {
      0.28
    }

    if dist_delta < 26.0 && lane_delta < lane_hit_w {
      if game.hazards[i].kind == hazard_debris {
        let shield : Float = if game.burst_t > 0.0 { 0.5 } else { 1.0 }

        game.speed = maxf(72.0, game.speed - 46.0 * shield)
        game.rhythm_meter = maxf(0.0, game.rhythm_meter - 24.0 * shield)
        game.wobble = minf(1.8, game.wobble + 0.34 * shield)
        if shield >= 1.0 {
          game.streak = 0
        }
        game.hit_count = game.hit_count + 1

        add_score(game, -28)
        set_message(game, "Debris impact!", 0.85)
      } else if game.input.stabilize_down {
        game.rhythm_meter = minf(100.0, game.rhythm_meter + 3.5)
        add_score(game, 6)
        set_message(game, "Wave absorbed", 0.45)
      } else {
        game.speed = maxf(72.0, game.speed - 24.0)
        game.rhythm_meter = maxf(0.0, game.rhythm_meter - 11.0)
        game.wobble = minf(1.8, game.wobble + 0.22)
        add_score(game, -12)
        set_message(game, "Wave rocked the boat", 0.7)
      }

      game.hazards[i].active = false
    }
  }
}

///|
fn update_rivals(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.rivals.length(); i = i + 1 {
    if not(game.rivals[i].active) {
      continue
    }

    game.rivals[i].stroke_t = game.rivals[i].stroke_t +
      dt * (1.4 + game.rivals[i].speed_bias * 0.01)
    if game.rivals[i].stroke_t > 6.28 {
      game.rivals[i].stroke_t = game.rivals[i].stroke_t - 6.28
    }

    let tempo : Float = 0.5 +
      0.5 *
      sinf(game.rivals[i].stroke_t + Float::from_int(game.rivals[i].id) * 0.35)

    let mut rival_speed : Float = base_speed +
      8.0 +
      game.rivals[i].speed_bias +
      tempo * 44.0

    if game.distance > finish_distance * 0.82 {
      rival_speed = rival_speed + 11.0
    }

    game.rivals[i].dist = game.rivals[i].dist + rival_speed * dt

    let path_t : Float = game.ui_t *
      (0.62 + Float::from_int(game.rivals[i].id) * 0.08) +
      Float::from_int(game.rivals[i].id) * 0.9

    game.rivals[i].lane = clampf(
      game.rivals[i].lane + sinf(path_t) * dt * 0.3,
      -1.02,
      1.02,
    )

    let near_dist : Float = absf(game.rivals[i].dist - game.distance)
    let near_lane : Float = absf(game.rivals[i].lane - game.lane)

    if near_dist < 15.0 && near_lane < 0.2 {
      if game.speed >= rival_speed {
        game.rivals[i].dist = game.rivals[i].dist - dt * 20.0
        add_score(game, 5)
      } else {
        game.speed = maxf(68.0, game.speed - 14.0)
        game.wobble = minf(1.8, game.wobble + 0.1)
      }
    }
  }

  let rank : Int = current_rank(game)
  if rank < game.best_rank {
    game.best_rank = rank
    if rank == 1 {
      add_score(game, 85)
      set_message(game, "You took the lead!", 1.1)
    } else {
      add_score(game, 28)
    }
  }
}

///|
fn update_checkpoints(game : Game) -> Unit {
  if game.checkpoint_idx >= checkpoint_count {
    return
  }

  let next_dist : Float = checkpoint_distance(game.checkpoint_idx)
  if game.distance >= next_dist {
    game.checkpoint_idx = game.checkpoint_idx + 1
    game.rhythm_meter = minf(100.0, game.rhythm_meter + 16.0)
    add_score(game, 120 + game.streak * 10)

    set_message(
      game,
      "Checkpoint " +
      game.checkpoint_idx.to_string() +
      "/" +
      checkpoint_count.to_string(),
      1.2,
    )
  }
}

///|
fn finish_run(game : Game) -> Unit {
  if game.state != state_play {
    return
  }

  game.state = state_result
  game.finish_time = game.game_t
  game.finish_rank = current_rank(game)

  let place_bonus : Int = if game.finish_rank == 1 {
    650
  } else if game.finish_rank == 2 {
    460
  } else if game.finish_rank == 3 {
    320
  } else {
    200
  }

  let streak_bonus : Int = game.best_streak * 22
  let clean_bonus : Int = maxi(0, 280 - game.hit_count * 70)
  let checkpoint_bonus : Int = game.checkpoint_idx * 110
  let time_bonus : Int = maxi(0, 420 - game.finish_time.to_int() * 8)

  game.score = maxi(
    0,
    game.score +
    place_bonus +
    streak_bonus +
    clean_bonus +
    checkpoint_bonus +
    time_bonus,
  )

  set_message(game, "Finish! Rank #" + game.finish_rank.to_string(), 2.4)
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  update_rhythm(game, dt)

  if game.input.paddle_pressed {
    apply_paddle(game)
  }

  try_burst(game)
  update_wave_lane(game, dt)
  update_speed_distance(game, dt)
  update_hazard_spawning(game, dt)
  update_hazards(game, dt)
  update_rivals(game, dt)
  update_checkpoints(game)

  if game.distance >= finish_distance {
    finish_run(game)
  }
}

///|
fn tick_message(game : Game, dt : Float) -> Unit {
  game.msg_t = game.msg_t - dt
  if game.msg_t <= 0.0 {
    game.msg_t = 0.0
    game.msg = ""
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.msg_t > 0.0 {
    tick_message(game, dt)
  }

  if game.input.restart_pressed {
    reset_run(game)
    return
  }

  if game.state == state_title {
    if game.input.start_pressed {
      reset_run(game)
    }
    return
  }

  if game.state == state_paused {
    if game.input.pause_pressed {
      game.state = state_play
      set_message(game, "Race resumed", 0.8)
    }
    return
  }

  if game.state == state_result {
    if game.input.start_pressed {
      reset_run(game)
    }
    return
  }

  if game.input.pause_pressed {
    game.state = state_paused
    set_message(game, "Race paused", 0.8)
    return
  }

  update_play(game, dt)
}
