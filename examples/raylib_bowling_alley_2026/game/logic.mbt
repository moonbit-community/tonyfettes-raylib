///|
fn set_message(game : @types.Game, msg : String, ttl : Float) -> Unit {
  game.message = msg
  game.message_t = ttl
}

///|
fn clear_sparks(game : @types.Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = 0
  }
}

///|
fn spawn_spark(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  for spark in game.sparks {
    if spark.active {
      continue
    }

    spark.active = true
    spark.x = x
    spark.y = y
    spark.vx = vx
    spark.vy = vy
    spark.life = life
    spark.size = size
    spark.kind = kind
    break
  }
}

///|
fn burst_sparks(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<n {
    spawn_spark(
      game,
      x + @types.randf(-12.0, 12.0),
      y + @types.randf(-12.0, 12.0),
      @types.randf(-220.0, 220.0),
      @types.randf(-260.0, 120.0),
      @types.randf(0.25, 1.0),
      @types.randf(1.4, 5.2),
      kind,
    )
  }
}

///|
fn update_sparks(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.life = spark.life - dt
    if spark.life <= 0.0 {
      spark.active = false
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.vx = spark.vx * (1.0 - dt * 2.8)
    spark.vy = spark.vy * (1.0 - dt * 2.4) + dt * 180.0
  }
}

///|
fn reset_ball(game : @types.Game) -> Unit {
  game.ball_x = @types.ball_start_x
  game.ball_y = @types.ball_start_y
  game.ball_vx = 0.0
  game.ball_vy = 0.0
  game.ball_spin = 0.0
  game.ball_live = false
  game.resolve_t = 0.0
}

///|
fn reset_full_rack(game : @types.Game) -> Unit {
  let cx : Float = @types.ball_start_x
  let mut idx : Int = 0

  for row in 0..<4 {
    let y : Float = @types.pin_deck_y + Float::from_int(row) * @types.pin_row_gap
    let x0 : Float = cx - Float::from_int(row) * @types.pin_col_gap * 0.5

    for col in 0..<=row {
      if idx >= game.pins.length() {
        continue
      }

      game.pins[idx].standing = true
      game.pins[idx].x = x0 + Float::from_int(col) * @types.pin_col_gap
      game.pins[idx].y = y
      game.pins[idx].vx = 0.0
      game.pins[idx].vy = 0.0
      game.pins[idx].ang = 0.0
      game.pins[idx].ang_v = 0.0
      idx = idx + 1
    }
  }

  while idx < game.pins.length() {
    game.pins[idx].standing = false
    game.pins[idx].x = -200.0
    game.pins[idx].y = -200.0
    game.pins[idx].vx = 0.0
    game.pins[idx].vy = 0.0
    game.pins[idx].ang = 0.0
    game.pins[idx].ang_v = 0.0
    idx = idx + 1
  }
}

///|
fn count_standing(game : @types.Game) -> Int {
  let mut n : Int = 0
  for pin in game.pins {
    if pin.standing {
      n = n + 1
    }
  }
  n
}

///|
fn pins_are_quiet(game : @types.Game) -> Bool {
  for pin in game.pins {
    if pin.standing {
      continue
    }

    let speed2 : Float = pin.vx * pin.vx + pin.vy * pin.vy
    if speed2 > 324.0 {
      return false
    }
  }

  true
}

///|
fn prepare_roll(game : @types.Game, reset_rack : Bool) -> Unit {
  if reset_rack {
    reset_full_rack(game)
  }

  game.pins_left = count_standing(game)
  game.pins_before_roll = game.pins_left
  reset_ball(game)

  game.can_throw = true
  game.charging = false
  game.power = 0.22
  game.power_dir = 1.0
  game.ball_spin = 0.0
  game.spin = @types.clampf(
    game.spin * 0.65, @types.spin_min, @types.spin_max,
  )
}

///|
fn reset_match_stats(game : @types.Game) -> Unit {
  game.frame = 0
  game.roll_in_frame = 0
  game.first_roll = 0
  game.last_knock = 0

  game.strikes = 0
  game.spares = 0
  game.opens = 0

  game.game_t = 0.0
  game.ui_t = 0.0
  game.shake_t = 0.0
  clear_rolls(game)
}

///|
fn start_match(game : @types.Game) -> Unit {
  reset_match_stats(game)
  game.state = @types.state_play
  game.aim = 0.0
  game.spin = 0.0
  clear_sparks(game)

  prepare_roll(game, true)
  set_message(game, "Frame 1: aim and hold power", 2.0)
}

///|
fn finalize_match(game : @types.Game) -> Unit {
  recompute_score(game)
  game.state = @types.state_result
  game.can_throw = false
  game.charging = false

  if game.score >= 220 {
    set_message(game, "Legend game! Score \{game.score}", 2.4)
  } else if game.score >= 180 {
    set_message(game, "Great run! Score \{game.score}", 2.4)
  } else {
    set_message(game, "Final score \{game.score}", 2.4)
  }
}

///|
fn knock_pin(
  game : @types.Game,
  i : Int,
  vx : Float,
  vy : Float,
  impact_kind : Int,
) -> Unit {
  if i < 0 || i >= game.pins.length() {
    return
  }

  if not(game.pins[i].standing) {
    return
  }

  game.pins[i].standing = false
  game.pins[i].vx = vx
  game.pins[i].vy = vy
  game.pins[i].ang_v = @types.randf(-7.0, 7.0)
  game.pins_left = count_standing(game)

  burst_sparks(game, game.pins[i].x, game.pins[i].y, 12, impact_kind)
  game.shake_t = @types.maxf(game.shake_t, 0.08)
}

///|
fn throw_ball(game : @types.Game) -> Bool {
  if game.state != @types.state_play || not(game.can_throw) {
    return false
  }

  let power_speed : Float = 520.0 + game.power * 780.0
  let angle : Float = @types.deg_to_rad(game.aim)

  game.ball_vx = Float::from_double(@math.sin(angle.to_double())) *
    power_speed +
    game.spin * 96.0
  game.ball_vy = -Float::from_double(@math.cos(angle.to_double())) *
    power_speed
  game.ball_spin = game.spin
  game.ball_live = true
  game.can_throw = false
  game.charging = false
  game.resolve_t = -1.0
  game.last_knock = 0

  set_message(game, "Ball out", 0.7)
  burst_sparks(game, game.ball_x, game.ball_y, 14, 0)
  true
}

///|
fn on_roll_scored(game : @types.Game, knocked : Int) -> Unit {
  let k : Int = if knocked < 0 {
    0
  } else if knocked > game.pins_before_roll {
    game.pins_before_roll
  } else {
    knocked
  }

  push_roll(game, k)
  game.last_knock = k

  if game.frame < 9 {
    if game.roll_in_frame == 0 {
      game.first_roll = k
      if k == 10 {
        game.strikes = game.strikes + 1
        game.frame = game.frame + 1
        game.roll_in_frame = 0

        if game.frame >= 10 {
          finalize_match(game)
          return
        }

        prepare_roll(game, true)
        set_message(game, "Strike! Frame \{game.frame + 1}", 1.3)
      } else {
        game.roll_in_frame = 1
        prepare_roll(game, false)
        set_message(
          game,
          "Frame \{game.frame + 1} roll 2: \{10 - k} pins left",
          1.2,
        )
      }
    } else {
      if game.first_roll + k == 10 {
        game.spares = game.spares + 1
        set_message(game, "Spare!", 1.1)
      } else {
        game.opens = game.opens + 1
        set_message(game, "Open frame", 1.0)
      }

      game.frame = game.frame + 1
      game.roll_in_frame = 0

      if game.frame >= 10 {
        finalize_match(game)
        return
      }

      prepare_roll(game, true)
      set_message(game, "Frame \{game.frame + 1}", 1.0)
    }

    recompute_score(game)
    return
  }

  // Tenth frame handling.
  if game.roll_in_frame == 0 {
    game.first_roll = k

    if k == 10 {
      game.strikes = game.strikes + 1
      game.roll_in_frame = 1
      prepare_roll(game, true)
      set_message(game, "10th frame strike, bonus balls", 1.4)
    } else {
      game.roll_in_frame = 1
      prepare_roll(game, false)
      set_message(game, "10th frame roll 2", 1.1)
    }

    recompute_score(game)
    return
  }

  if game.roll_in_frame == 1 {
    if game.first_roll == 10 {
      if k == 10 {
        game.strikes = game.strikes + 1
        prepare_roll(game, true)
      } else {
        prepare_roll(game, false)
      }

      game.roll_in_frame = 2
      set_message(game, "10th frame final ball", 1.1)
      recompute_score(game)
      return
    }

    if game.first_roll + k == 10 {
      game.spares = game.spares + 1
      game.roll_in_frame = 2
      prepare_roll(game, true)
      set_message(game, "Spare! bonus ball", 1.3)
      recompute_score(game)
      return
    }

    game.opens = game.opens + 1
    finalize_match(game)
    return
  }

  finalize_match(game)
}

///|
fn update_ball(game : @types.Game, dt : Float) -> Unit {
  if not(game.ball_live) {
    return
  }

  game.ball_x = game.ball_x + game.ball_vx * dt
  game.ball_y = game.ball_y + game.ball_vy * dt

  game.ball_vx = game.ball_vx + game.ball_spin * 44.0 * dt
  game.ball_vx = game.ball_vx * (1.0 - dt * 0.56)
  game.ball_vy = game.ball_vy * (1.0 - dt * 0.42)

  let min_x : Float = @types.lane_left + 28.0
  let max_x : Float = @types.lane_right - 28.0

  if game.ball_x < min_x {
    game.ball_x = min_x
    game.ball_vx = @types.absf(game.ball_vx) * 0.76
    burst_sparks(game, game.ball_x, game.ball_y, 8, 2)
  } else if game.ball_x > max_x {
    game.ball_x = max_x
    game.ball_vx = -@types.absf(game.ball_vx) * 0.76
    burst_sparks(game, game.ball_x, game.ball_y, 8, 2)
  }

  if game.ball_y < @types.lane_top + 40.0 {
    game.ball_live = false
    game.resolve_t = 0.42
  }

  let speed2 : Float = game.ball_vx * game.ball_vx + game.ball_vy * game.ball_vy
  if speed2 < 6400.0 && game.ball_y < @types.foul_line_y - 30.0 {
    game.ball_live = false
    game.resolve_t = 0.48
  }
}

///|
fn collide_ball_pins(game : @types.Game) -> Unit {
  if not(game.ball_live) {
    return
  }

  let hit_r : Float = @types.pin_radius + @types.ball_radius
  let hit_r2 : Float = hit_r * hit_r

  for i in 0..<game.pins.length() {
    if not(game.pins[i].standing) {
      continue
    }

    let d2 : Float = @types.dist2(
      game.ball_x,
      game.ball_y,
      game.pins[i].x,
      game.pins[i].y,
    )
    if d2 > hit_r2 {
      continue
    }

    let dx : Float = game.pins[i].x - game.ball_x
    let dy : Float = game.pins[i].y - game.ball_y
    let d : Float = @types.sqrtf(d2) + 0.0001

    let nx : Float = dx / d
    let ny : Float = dy / d
    let impulse : Float = @types.maxf(
      150.0,
      @types.sqrtf(
        game.ball_vx * game.ball_vx + game.ball_vy * game.ball_vy,
      ),
    )

    knock_pin(
      game,
      i,
      nx * impulse * 1.04 + @types.randf(-50.0, 50.0),
      ny * impulse * 1.04 + @types.randf(-40.0, 30.0),
      1,
    )

    game.ball_vx = game.ball_vx - nx * 95.0
    game.ball_vy = game.ball_vy - ny * 95.0
    game.ball_vx = game.ball_vx * 0.83
    game.ball_vy = game.ball_vy * 0.83
  }
}

///|
fn update_pin_motion(game : @types.Game, dt : Float) -> Unit {
  for pin in game.pins {
    if pin.standing {
      continue
    }

    pin.x = pin.x + pin.vx * dt
    pin.y = pin.y + pin.vy * dt

    pin.vx = pin.vx * (1.0 - dt * 2.5)
    pin.vy = pin.vy * (1.0 - dt * 2.2) + dt * 160.0
    pin.ang = pin.ang + pin.ang_v * dt
    pin.ang_v = pin.ang_v * (1.0 - dt * 2.1)

    let min_x : Float = @types.lane_left + 20.0
    let max_x : Float = @types.lane_right - 20.0

    if pin.x < min_x {
      pin.x = min_x
      pin.vx = @types.absf(pin.vx) * 0.48
    } else if pin.x > max_x {
      pin.x = max_x
      pin.vx = -@types.absf(pin.vx) * 0.48
    }

    if pin.y < @types.lane_top + 12.0 {
      pin.y = @types.lane_top + 12.0
      pin.vy = @types.absf(pin.vy) * 0.38
    }
    if pin.y > @types.lane_bottom - 6.0 {
      pin.y = @types.lane_bottom - 6.0
      pin.vy = -@types.absf(pin.vy) * 0.28
    }
  }
}

///|
fn chain_pin_hits(game : @types.Game) -> Unit {
  let hit : Float = @types.pin_radius * 2.0
  let hit2 : Float = hit * hit

  for i in 0..<game.pins.length() {
    if game.pins[i].standing {
      continue
    }

    let speed2 : Float = game.pins[i].vx * game.pins[i].vx +
      game.pins[i].vy * game.pins[i].vy
    if speed2 < 7800.0 {
      continue
    }

    for j in 0..<game.pins.length() {
      if i == j || not(game.pins[j].standing) {
        continue
      }

      let d2 : Float = @types.dist2(
        game.pins[i].x,
        game.pins[i].y,
        game.pins[j].x,
        game.pins[j].y,
      )
      if d2 > hit2 {
        continue
      }

      knock_pin(
        game,
        j,
        game.pins[i].vx * 0.62 + @types.randf(-32.0, 32.0),
        game.pins[i].vy * 0.62 + @types.randf(-28.0, 28.0),
        1,
      )
      game.pins[i].vx = game.pins[i].vx * 0.72
      game.pins[i].vy = game.pins[i].vy * 0.72
    }
  }
}

///|
fn update_play(game : @types.Game, dt : Float) -> Unit {
  game.game_t = game.game_t + dt
  game.ui_t = game.ui_t + dt

  if game.message_t > 0.0 {
    game.message_t = game.message_t - dt
  }
  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
  }
  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }

  update_sparks(game, dt)
  update_ball(game, dt)
  collide_ball_pins(game)
  update_pin_motion(game, dt)
  chain_pin_hits(game)

  if game.ball_live {
    return
  }

  if game.resolve_t < 0.0 {
    game.resolve_t = 0.52
  }

  if game.resolve_t > 0.0 {
    game.resolve_t = game.resolve_t - dt
    return
  }

  if not(pins_are_quiet(game)) {
    return
  }

  let standing : Int = count_standing(game)
  let knocked : Int = game.pins_before_roll - standing
  on_roll_scored(game, knocked)
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  if game.state == @types.state_title {
    update_title_input(game)
  } else if game.state == @types.state_play {
    update_play_input(game, dt)
    update_play(game, dt)
  } else {
    update_result_input(game)
  }
}
