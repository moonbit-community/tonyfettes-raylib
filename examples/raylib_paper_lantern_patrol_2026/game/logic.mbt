///|
fn set_status(game : @types.Game, text : String, ttl : Float) -> Unit {
  game.status_text = text
  game.status_t = ttl
}

///|
fn reset_patrol(patrol : @types.Patrol) -> Unit {
  let gate = @types.gate_position()
  patrol.x = gate.0 + 30.0
  patrol.y = gate.1
  patrol.vx = 0.0
  patrol.vy = 0.0
  patrol.escort = -1
  patrol.guard_t = 0.0
  patrol.calm_t = 0.0
  patrol.calm_cd = 0.0
}

///|
fn reset_lanterns(game : @types.Game) -> Unit {
  for lantern in game.lanterns {
    lantern.active = false
    lantern.x = 0.0
    lantern.y = 0.0
    lantern.vx = 0.0
    lantern.vy = 0.0
    lantern.flame = 0.0
    lantern.target_shrine = 0
    lantern.escorting = false
    lantern.wobble = 0.0
  }
}

///|
fn reset_gusts(game : @types.Game) -> Unit {
  for gust in game.gusts {
    gust.active = false
    gust.x = 0.0
    gust.y = 0.0
    gust.vx = 0.0
    gust.vy = 0.0
    gust.radius = 0.0
    gust.power = 0.0
    gust.life = 0.0
  }
}

///|
fn reset_sparks(game : @types.Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.power = 0.0
    spark.size = 0.0
  }
}

///|
fn reset_thieves(game : @types.Game) -> Unit {
  for thief in game.thieves {
    thief.active = false
    thief.x = 0.0
    thief.y = 0.0
    thief.vx = 0.0
    thief.vy = 0.0
    thief.speed = 0.0
    thief.target = -1
    thief.steal_cd = 0.0
    thief.life = 0.0
  }
}

///|
fn start_new_run(game : @types.Game) -> Unit {
  game.state = @types.state_playing
  game.score = 0
  game.deliveries = 0
  game.extinguished = 0
  game.combo = 0
  game.combo_t = 0.0
  game.run_time = 0.0
  game.lantern_spawn_cd = 0.45
  game.gust_spawn_cd = 1.0
  game.spark_spawn_cd = 0.20
  game.thief_spawn_cd = 6.4
  game.status_text = "Escort lanterns to shrines before their flame dies."
  game.status_t = 2.5
  game.screen_flash_t = 0.0
  game.game_over_reason = ""

  reset_patrol(game.patrol)
  reset_lanterns(game)
  reset_gusts(game)
  reset_sparks(game)
  reset_thieves(game)

  ignore(spawn_lantern(game))
  ignore(spawn_lantern(game))
}

///|
fn end_run_game_over(game : @types.Game, reason : String) -> Unit {
  game.state = @types.state_game_over
  game.game_over_reason = reason
  set_status(game, "Run ended. Press R to patrol again.", 2.0)
}

///|
fn free_lantern_slot(game : @types.Game) -> Int {
  for i in 0..<game.lanterns.length() {
    if not(game.lanterns[i].active) {
      return i
    }
  }
  -1
}

///|
fn free_gust_slot(game : @types.Game) -> Int {
  for i in 0..<game.gusts.length() {
    if not(game.gusts[i].active) {
      return i
    }
  }
  -1
}

///|
fn free_spark_slot(game : @types.Game) -> Int {
  for i in 0..<game.sparks.length() {
    if not(game.sparks[i].active) {
      return i
    }
  }
  -1
}

///|
fn free_thief_slot(game : @types.Game) -> Int {
  for i in 0..<game.thieves.length() {
    if not(game.thieves[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_lantern(game : @types.Game) -> Bool {
  let slot = free_lantern_slot(game)
  if slot < 0 {
    return false
  }

  let gate = @types.gate_position()

  game.lanterns[slot].active = true
  game.lanterns[slot].x = gate.0 + @types.randf(-18.0, 18.0)
  game.lanterns[slot].y = gate.1 + @types.randf(-44.0, 44.0)
  game.lanterns[slot].vx = @types.randf(12.0, 38.0)
  game.lanterns[slot].vy = @types.randf(-24.0, 24.0)
  game.lanterns[slot].flame = @types.randf(84.0, 100.0)
  game.lanterns[slot].target_shrine = @types.randi(0, @types.shrine_count - 1)
  game.lanterns[slot].escorting = false
  game.lanterns[slot].wobble = @types.randf(0.0, 6.28)

  true
}

///|
fn spawn_gust(game : @types.Game) -> Bool {
  let slot = free_gust_slot(game)
  if slot < 0 {
    return false
  }

  let edge = @types.randi(0, 3)

  if edge == 0 {
    game.gusts[slot].x = @types.play_left - 44.0
    game.gusts[slot].y = @types.randf(@types.play_top, @types.play_bottom)
    game.gusts[slot].vx = @types.randf(100.0, 220.0)
    game.gusts[slot].vy = @types.randf(-48.0, 48.0)
  } else if edge == 1 {
    game.gusts[slot].x = @types.play_right + 44.0
    game.gusts[slot].y = @types.randf(@types.play_top, @types.play_bottom)
    game.gusts[slot].vx = @types.randf(-220.0, -100.0)
    game.gusts[slot].vy = @types.randf(-48.0, 48.0)
  } else if edge == 2 {
    game.gusts[slot].x = @types.randf(@types.play_left, @types.play_right)
    game.gusts[slot].y = @types.play_top - 44.0
    game.gusts[slot].vx = @types.randf(-48.0, 48.0)
    game.gusts[slot].vy = @types.randf(100.0, 220.0)
  } else {
    game.gusts[slot].x = @types.randf(@types.play_left, @types.play_right)
    game.gusts[slot].y = @types.play_bottom + 44.0
    game.gusts[slot].vx = @types.randf(-48.0, 48.0)
    game.gusts[slot].vy = @types.randf(-220.0, -100.0)
  }

  game.gusts[slot].active = true
  game.gusts[slot].radius = @types.randf(66.0, 100.0)
  game.gusts[slot].power = @types.randf(0.70, 1.28)
  game.gusts[slot].life = @types.randf(5.0, 9.2)

  true
}

///|
fn spawn_spark(game : @types.Game) -> Bool {
  let slot = free_spark_slot(game)
  if slot < 0 {
    return false
  }

  let origin = @types.randi(0, @types.shrine_count)
  let anchor : (Float, Float) = if origin == 0 {
    @types.gate_position()
  } else {
    @types.shrine_position(origin - 1)
  }

  game.sparks[slot].active = true
  game.sparks[slot].x = anchor.0 + @types.randf(-80.0, 80.0)
  game.sparks[slot].y = anchor.1 + @types.randf(-80.0, 80.0)
  game.sparks[slot].vx = @types.randf(-100.0, 100.0)
  game.sparks[slot].vy = @types.randf(-96.0, 96.0)
  game.sparks[slot].life = @types.randf(0.9, 2.8)
  game.sparks[slot].power = @types.randf(
    @types.spark_drain_power * 0.8,
    @types.spark_drain_power * 1.2,
  )
  game.sparks[slot].size = @types.randf(1.8, 4.6)

  true
}

///|
fn nearest_active_lantern(
  game : @types.Game,
  x : Float,
  y : Float,
  max_d2 : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i in 0..<game.lanterns.length() {
    if not(game.lanterns[i].active) || game.lanterns[i].flame <= 0.0 {
      continue
    }

    let d2 = @types.dist2(x, y, game.lanterns[i].x, game.lanterns[i].y)
    if d2 <= best_d2 {
      best = i
      best_d2 = d2
    }
  }

  best
}

///|
fn spawn_thief(game : @types.Game) -> Bool {
  let slot = free_thief_slot(game)
  if slot < 0 {
    return false
  }

  let edge = @types.randi(0, 2)

  if edge == 0 {
    game.thieves[slot].x = @types.play_right + @types.randf(28.0, 72.0)
    game.thieves[slot].y = @types.randf(
      @types.play_top + 30.0,
      @types.play_bottom - 30.0,
    )
  } else if edge == 1 {
    game.thieves[slot].x = @types.randf(
      @types.play_left + 60.0,
      @types.play_right - 60.0,
    )
    game.thieves[slot].y = @types.play_top - @types.randf(28.0, 72.0)
  } else {
    game.thieves[slot].x = @types.randf(
      @types.play_left + 60.0,
      @types.play_right - 60.0,
    )
    game.thieves[slot].y = @types.play_bottom + @types.randf(28.0, 72.0)
  }

  game.thieves[slot].active = true
  game.thieves[slot].vx = 0.0
  game.thieves[slot].vy = 0.0
  game.thieves[slot].speed = @types.thief_speed +
    Float::from_int(game.deliveries) * 1.7 +
    @types.randf(-14.0, 22.0)
  game.thieves[slot].target = nearest_active_lantern(
    game,
    game.thieves[slot].x,
    game.thieves[slot].y,
    100000000.0,
  )
  game.thieves[slot].steal_cd = @types.randf(0.1, 0.6)
  game.thieves[slot].life = @types.randf(10.0, 20.0)

  true
}

///|
fn release_escort(game : @types.Game) -> Unit {
  let idx = game.patrol.escort
  if idx >= 0 && idx < game.lanterns.length() {
    game.lanterns[idx].escorting = false
  }
  game.patrol.escort = -1
}

///|
fn set_escort(game : @types.Game, idx : Int) -> Unit {
  if idx < 0 || idx >= game.lanterns.length() || not(game.lanterns[idx].active) {
    return
  }

  release_escort(game)
  game.patrol.escort = idx
  game.lanterns[idx].escorting = true
}

///|
fn deliver_lantern(game : @types.Game, idx : Int) -> Unit {
  if idx < 0 || idx >= game.lanterns.length() || not(game.lanterns[idx].active) {
    return
  }

  let flame_score = game.lanterns[idx].flame.to_int() * @types.score_per_flame
  let gain = @types.delivery_score_base +
    game.combo * @types.combo_bonus_step +
    flame_score

  game.score = game.score + gain
  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.deliveries = game.deliveries + 1
  game.combo = @types.clampi(game.combo + 1, 0, 99)
  game.combo_t = @types.combo_window

  game.lanterns[idx].active = false
  game.lanterns[idx].escorting = false

  if game.patrol.escort == idx {
    game.patrol.escort = -1
  }

  game.screen_flash_t = @types.maxf(game.screen_flash_t, 0.12)
  set_status(game, "Safe delivery +\{gain}! Combo x\{game.combo}.", 1.0)
}

///|
fn extinguish_lantern(game : @types.Game, idx : Int) -> Unit {
  if idx < 0 || idx >= game.lanterns.length() || not(game.lanterns[idx].active) {
    return
  }

  game.lanterns[idx].active = false
  game.lanterns[idx].escorting = false

  if game.patrol.escort == idx {
    game.patrol.escort = -1
  }

  game.extinguished = game.extinguished + 1
  game.combo = 0
  game.combo_t = 0.0
  game.screen_flash_t = @types.maxf(game.screen_flash_t, 0.28)

  set_status(
    game,
    "Lantern extinguished (\{game.extinguished}/\{@types.extinguish_limit}).",
    1.2,
  )

  if game.extinguished >= @types.extinguish_limit {
    end_run_game_over(game, "Too many lanterns were extinguished.")
  }
}

///|
fn try_interact(game : @types.Game) -> Unit {
  if game.patrol.escort >= 0 {
    let idx = game.patrol.escort

    if idx >= 0 && idx < game.lanterns.length() && game.lanterns[idx].active {
      let shrine = @types.shrine_position(game.lanterns[idx].target_shrine)
      if @types.dist2(
          game.lanterns[idx].x,
          game.lanterns[idx].y,
          shrine.0,
          shrine.1,
        ) <=
        @types.squaref(@types.delivery_radius + 6.0) {
        deliver_lantern(game, idx)
        return
      }

      game.lanterns[idx].flame = @types.minf(
        100.0,
        game.lanterns[idx].flame + @types.interact_stabilize_boost,
      )
      set_status(game, "Escorted flame steadied.", 0.52)
      return
    }

    release_escort(game)
  }

  let pickup = nearest_active_lantern(
    game,
    game.patrol.x,
    game.patrol.y,
    @types.squaref(@types.escort_pickup_range),
  )
  if pickup >= 0 {
    set_escort(game, pickup)
    set_status(game, "Lantern linked to patrol.", 0.8)
    return
  }

  let gate = @types.gate_position()
  if @types.dist2(game.patrol.x, game.patrol.y, gate.0, gate.1) <=
    @types.squaref(@types.escort_pickup_range + 22.0) {
    if spawn_lantern(game) {
      let near_gate = nearest_active_lantern(
        game,
        game.patrol.x,
        game.patrol.y,
        @types.squaref(@types.escort_pickup_range + 40.0),
      )
      if near_gate >= 0 {
        set_escort(game, near_gate)
      }
      set_status(game, "Lantern launched from the gate.", 0.92)
    } else {
      set_status(game, "No room to launch a new lantern.", 0.8)
    }
    return
  }

  set_status(game, "Move closer to a lantern or gate.", 0.7)
}

///|
fn try_cancel(game : @types.Game) -> Unit {
  if game.patrol.escort >= 0 {
    release_escort(game)
    set_status(game, "Escort released.", 0.7)
    return
  }

  game.patrol.guard_t = @types.guard_time
  set_status(game, "Guard stance raised.", 0.8)
}

///|
fn try_calm(game : @types.Game) -> Unit {
  if game.patrol.calm_cd <= 0.0 {
    game.patrol.calm_t = @types.calm_duration
    game.patrol.calm_cd = @types.calm_cooldown
    set_status(game, "Calm-wind field deployed.", 1.0)
  } else {
    set_status(game, "Calm field cooling down.", 0.7)
  }
}

///|
fn handle_actions(game : @types.Game) -> Unit {
  if game.input.press_interact {
    try_interact(game)
  }
  if game.input.press_cancel {
    try_cancel(game)
  }
  if game.input.press_calm {
    try_calm(game)
  }
}

///|
fn update_patrol(game : @types.Game, dt : Float) -> Unit {
  let mut dir_x = Float::from_int(game.input.move_x)
  let mut dir_y = Float::from_int(game.input.move_y)

  if dir_x != 0.0 || dir_y != 0.0 {
    let len2 = dir_x * dir_x + dir_y * dir_y
    let inv = Float::from_int(1) / @types.maxf(len2.sqrt(), 0.001)
    dir_x = dir_x * inv
    dir_y = dir_y * inv
  }

  game.patrol.vx = game.patrol.vx + dir_x * @types.patrol_accel * dt
  game.patrol.vy = game.patrol.vy + dir_y * @types.patrol_accel * dt

  let drag = @types.clampf(1.0 - @types.patrol_drag * dt, 0.0, 1.0)
  game.patrol.vx = game.patrol.vx * drag
  game.patrol.vy = game.patrol.vy * drag

  let speed2 = game.patrol.vx * game.patrol.vx +
    game.patrol.vy * game.patrol.vy
  let cap2 = @types.patrol_max_speed * @types.patrol_max_speed
  if speed2 > cap2 {
    let factor = @types.patrol_max_speed / @types.maxf(speed2.sqrt(), 0.001)
    game.patrol.vx = game.patrol.vx * factor
    game.patrol.vy = game.patrol.vy * factor
  }

  game.patrol.x = game.patrol.x + game.patrol.vx * dt
  game.patrol.y = game.patrol.y + game.patrol.vy * dt

  if game.patrol.x < @types.play_left {
    game.patrol.x = @types.play_left
    game.patrol.vx = @types.maxf(game.patrol.vx, 0.0)
  }
  if game.patrol.x > @types.play_right {
    game.patrol.x = @types.play_right
    game.patrol.vx = @types.minf(game.patrol.vx, 0.0)
  }
  if game.patrol.y < @types.play_top {
    game.patrol.y = @types.play_top
    game.patrol.vy = @types.maxf(game.patrol.vy, 0.0)
  }
  if game.patrol.y > @types.play_bottom {
    game.patrol.y = @types.play_bottom
    game.patrol.vy = @types.minf(game.patrol.vy, 0.0)
  }

  game.patrol.guard_t = @types.maxf(game.patrol.guard_t - dt, 0.0)
  game.patrol.calm_t = @types.maxf(game.patrol.calm_t - dt, 0.0)
  game.patrol.calm_cd = @types.maxf(game.patrol.calm_cd - dt, 0.0)
}

///|
fn update_combo_timer(game : @types.Game, dt : Float) -> Unit {
  if game.combo_t <= 0.0 {
    return
  }

  game.combo_t = game.combo_t - dt
  if game.combo_t <= 0.0 {
    game.combo_t = 0.0
    game.combo = 0
  }
}

///|
fn update_spawning(game : @types.Game, dt : Float) -> Unit {
  game.lantern_spawn_cd = game.lantern_spawn_cd - dt
  if game.lantern_spawn_cd <= 0.0 {
    ignore(spawn_lantern(game))
    let pressure = Float::from_int(game.deliveries) * 0.055
    let next = @types.maxf(
      @types.lantern_spawn_floor,
      @types.lantern_spawn_interval - pressure,
    )
    game.lantern_spawn_cd = next + @types.randf(0.05, 0.44)
  }

  game.gust_spawn_cd = game.gust_spawn_cd - dt
  if game.gust_spawn_cd <= 0.0 {
    ignore(spawn_gust(game))
    let wind_pressure = Float::from_int(game.deliveries) * 0.024 +
      game.run_time * 0.012
    let next = @types.maxf(
      @types.gust_spawn_floor,
      @types.gust_spawn_interval - wind_pressure,
    )
    game.gust_spawn_cd = next + @types.randf(0.0, 0.26)
  }

  game.spark_spawn_cd = game.spark_spawn_cd - dt
  if game.spark_spawn_cd <= 0.0 {
    ignore(spawn_spark(game))
    let lantern_pressure = Float::from_int(
        @types.active_lantern_count(game),
      ) *
      0.005
    let next = @types.maxf(
      @types.spark_spawn_floor,
      @types.spark_spawn_interval - lantern_pressure,
    )
    game.spark_spawn_cd = next
  }

  if game.run_time > 8.0 {
    game.thief_spawn_cd = game.thief_spawn_cd - dt
    if game.thief_spawn_cd <= 0.0 {
      ignore(spawn_thief(game))
      let thief_pressure = Float::from_int(game.deliveries) * 0.18
      let next = @types.maxf(
        @types.thief_spawn_floor,
        @types.thief_spawn_interval - thief_pressure,
      )
      game.thief_spawn_cd = next + @types.randf(0.0, 1.2)
    }
  }
}

///|
fn update_gusts(game : @types.Game, dt : Float) -> Unit {
  for gust in game.gusts {
    if not(gust.active) {
      continue
    }

    gust.x = gust.x + gust.vx * dt
    gust.y = gust.y + gust.vy * dt
    gust.life = gust.life - dt

    if game.patrol.calm_t > 0.0 &&
      @types.dist2(gust.x, gust.y, game.patrol.x, game.patrol.y) <=
      @types.squaref(@types.calm_radius + gust.radius) {
      let damp = @types.clampf(1.0 - dt * 1.6, 0.50, 1.0)
      gust.vx = gust.vx * damp
      gust.vy = gust.vy * damp
    }

    if gust.x < @types.play_left - 160.0 ||
      gust.x > @types.play_right + 160.0 ||
      gust.y < @types.play_top - 160.0 ||
      gust.y > @types.play_bottom + 160.0 ||
      gust.life <= 0.0 {
      gust.active = false
    }
  }
}

///|
fn update_sparks(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    let in_calm = game.patrol.calm_t > 0.0 &&
      @types.dist2(spark.x, spark.y, game.patrol.x, game.patrol.y) <=
      @types.squaref(@types.calm_radius)

    if in_calm {
      let calm_drag = @types.clampf(1.0 - dt * 4.0, 0.35, 1.0)
      spark.vx = spark.vx * calm_drag
      spark.vy = spark.vy * calm_drag
      spark.life = spark.life - dt * 1.6
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.life = spark.life - dt

    if spark.life <= 0.0 ||
      spark.x < @types.play_left - 80.0 ||
      spark.x > @types.play_right + 80.0 ||
      spark.y < @types.play_top - 80.0 ||
      spark.y > @types.play_bottom + 80.0 {
      spark.active = false
    }
  }
}

///|
fn update_thieves(game : @types.Game, dt : Float) -> Unit {
  for thief in game.thieves {
    if not(thief.active) {
      continue
    }

    thief.steal_cd = @types.maxf(thief.steal_cd - dt, 0.0)
    thief.life = thief.life - dt

    if thief.life <= 0.0 {
      thief.active = false
      continue
    }

    let target = nearest_active_lantern(game, thief.x, thief.y, 100000000.0)
    thief.target = target

    let mut vx : Float = 0.0
    let mut vy : Float = 0.0

    if target >= 0 {
      let dx = game.lanterns[target].x - thief.x
      let dy = game.lanterns[target].y - thief.y
      let d2 = dx * dx + dy * dy

      if d2 <= @types.squaref(@types.thief_contact_radius) {
        if thief.steal_cd <= 0.0 {
          game.lanterns[target].flame = game.lanterns[target].flame -
            @types.thief_drain_burst
          thief.steal_cd = @types.thief_steal_period
          game.screen_flash_t = @types.maxf(game.screen_flash_t, 0.12)
        }
      } else {
        let inv = Float::from_int(1) / @types.maxf(d2.sqrt(), 0.001)
        let mut speed = thief.speed
        if game.patrol.calm_t > 0.0 &&
          @types.dist2(thief.x, thief.y, game.patrol.x, game.patrol.y) <=
          @types.squaref(@types.calm_radius) {
          speed = speed * 0.64
        }

        vx = dx * inv * speed
        vy = dy * inv * speed
      }
    } else {
      let gate = @types.gate_position()
      let dx = gate.0 - thief.x
      let dy = gate.1 - thief.y
      let inv = Float::from_int(1) /
        @types.maxf((dx * dx + dy * dy).sqrt(), 0.001)
      vx = dx * inv * (thief.speed * 0.36)
      vy = dy * inv * (thief.speed * 0.36)
    }

    thief.vx = vx
    thief.vy = vy
    thief.x = thief.x + thief.vx * dt
    thief.y = thief.y + thief.vy * dt

    if game.patrol.guard_t > 0.0 {
      let dx = thief.x - game.patrol.x
      let dy = thief.y - game.patrol.y
      let d2 = dx * dx + dy * dy
      if d2 <= @types.squaref(@types.guard_radius) {
        let inv = Float::from_int(1) / @types.maxf(d2.sqrt(), 0.001)
        thief.x = thief.x + dx * inv * @types.guard_push * dt
        thief.y = thief.y + dy * inv * @types.guard_push * dt
        thief.life = thief.life - dt * 1.8
      }
    }

    if thief.x < @types.play_left - 140.0 ||
      thief.x > @types.play_right + 140.0 ||
      thief.y < @types.play_top - 140.0 ||
      thief.y > @types.play_bottom + 140.0 ||
      thief.life <= 0.0 {
      thief.active = false
    }
  }
}

///|
fn update_lanterns(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.lanterns.length() {
    if not(game.lanterns[i].active) {
      continue
    }

    if game.patrol.escort != i {
      game.lanterns[i].escorting = false
    }

    let mut drain = @types.lantern_base_drain * dt

    let near_patrol = @types.dist2(
      game.lanterns[i].x,
      game.lanterns[i].y,
      game.patrol.x,
      game.patrol.y,
    )

    let in_calm = game.patrol.calm_t > 0.0 &&
      near_patrol <= @types.squaref(@types.calm_radius)
    if in_calm {
      drain = drain * 0.34
    }

    if game.patrol.guard_t > 0.0 &&
      near_patrol <= @types.squaref(@types.guard_radius * 0.78) {
      game.lanterns[i].flame = @types.minf(
        100.0,
        game.lanterns[i].flame + @types.lantern_escort_regen * 0.45 * dt,
      )
    }

    if game.patrol.escort == i && game.lanterns[i].escorting {
      let follow_x = game.patrol.x + game.patrol.vx * 0.05
      let follow_y = game.patrol.y -
        26.0 +
        @types.sinf(game.run_time * 7.0 + game.lanterns[i].wobble) * 5.0

      game.lanterns[i].vx = game.lanterns[i].vx +
        (follow_x - game.lanterns[i].x) * @types.escort_pull * dt
      game.lanterns[i].vy = game.lanterns[i].vy +
        (follow_y - game.lanterns[i].y) * @types.escort_pull * dt

      game.lanterns[i].flame = @types.minf(
        100.0,
        game.lanterns[i].flame + @types.lantern_escort_regen * dt,
      )

      drain = drain * 0.72
    }

    game.lanterns[i].vx = game.lanterns[i].vx + @types.randf(-15.0, 15.0) * dt
    game.lanterns[i].vy = game.lanterns[i].vy + @types.randf(-15.0, 15.0) * dt

    for gust in game.gusts {
      if not(gust.active) {
        continue
      }

      let d2 = @types.dist2(
        game.lanterns[i].x,
        game.lanterns[i].y,
        gust.x,
        gust.y,
      )
      let r2 = @types.squaref(gust.radius)
      if d2 > r2 {
        continue
      }

      let influence : Float = Float::from_int(1) -
        d2 / @types.maxf(r2, Float::from_int(1))
      game.lanterns[i].vx = game.lanterns[i].vx +
        gust.vx * gust.power * influence * 0.34 * dt
      game.lanterns[i].vy = game.lanterns[i].vy +
        gust.vy * gust.power * influence * 0.34 * dt
      drain = drain + @types.gust_drain_power * influence * dt
    }

    for spark in game.sparks {
      if not(spark.active) {
        continue
      }

      let d2 = @types.dist2(
        game.lanterns[i].x,
        game.lanterns[i].y,
        spark.x,
        spark.y,
      )

      if d2 <= @types.squaref(spark.size + @types.lantern_radius + 4.0) {
        drain = drain + spark.power * dt
        spark.active = false
      }
    }

    let drag = @types.clampf(1.0 - @types.lantern_drag * dt, 0.0, 1.0)
    game.lanterns[i].vx = game.lanterns[i].vx * drag
    game.lanterns[i].vy = game.lanterns[i].vy * drag

    game.lanterns[i].x = game.lanterns[i].x + game.lanterns[i].vx * dt
    game.lanterns[i].y = game.lanterns[i].y + game.lanterns[i].vy * dt

    if game.lanterns[i].x < @types.play_left {
      game.lanterns[i].x = @types.play_left
      game.lanterns[i].vx = @types.absf(game.lanterns[i].vx) * 0.4
    }
    if game.lanterns[i].x > @types.play_right {
      game.lanterns[i].x = @types.play_right
      game.lanterns[i].vx = -@types.absf(game.lanterns[i].vx) * 0.4
    }
    if game.lanterns[i].y < @types.play_top {
      game.lanterns[i].y = @types.play_top
      game.lanterns[i].vy = @types.absf(game.lanterns[i].vy) * 0.4
    }
    if game.lanterns[i].y > @types.play_bottom {
      game.lanterns[i].y = @types.play_bottom
      game.lanterns[i].vy = -@types.absf(game.lanterns[i].vy) * 0.4
    }

    game.lanterns[i].flame = game.lanterns[i].flame - drain

    if game.lanterns[i].flame <= 0.0 {
      extinguish_lantern(game, i)
      if game.state == @types.state_game_over {
        return
      }
      continue
    }

    let shrine = @types.shrine_position(game.lanterns[i].target_shrine)
    if @types.dist2(game.lanterns[i].x, game.lanterns[i].y, shrine.0, shrine.1) <=
      @types.squaref(@types.delivery_radius) {
      deliver_lantern(game, i)
      continue
    }

    game.lanterns[i].wobble = game.lanterns[i].wobble +
      dt * (1.8 + @types.randf(-0.3, 0.4))
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
    set_status(game, "Patrol resumed.", 0.7)
  }
}

///|
fn update_game_over_state(game : @types.Game) -> Unit {
  if game.input.press_restart || game.input.press_start {
    start_new_run(game)
  }
}

///|
fn update_playing_state(game : @types.Game, dt : Float) -> Unit {
  if game.input.press_pause {
    game.state = @types.state_paused
    set_status(game, "Patrol paused.", 0.7)
    return
  }

  if game.input.press_restart {
    start_new_run(game)
    return
  }

  game.run_time = game.run_time + dt

  update_patrol(game, dt)
  handle_actions(game)
  update_combo_timer(game, dt)

  update_spawning(game, dt)
  update_gusts(game, dt)
  update_sparks(game, dt)
  update_thieves(game, dt)
  update_lanterns(game, dt)

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  update_input(game)

  if game.status_t > 0.0 {
    game.status_t = @types.maxf(game.status_t - dt, 0.0)
  }

  if game.screen_flash_t > 0.0 {
    game.screen_flash_t = @types.maxf(game.screen_flash_t - dt, 0.0)
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
