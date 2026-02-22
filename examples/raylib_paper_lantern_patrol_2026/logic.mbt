///|
fn set_status(game : Game, text : String, ttl : Float) -> Unit {
  game.status_text = text
  game.status_t = ttl
}

///|
fn active_lantern_count(game : Game) -> Int {
  let mut total = 0
  for i in 0..<game.lanterns.length() {
    if game.lanterns[i].active {
      total = total + 1
    }
  }
  total
}

///|
fn active_gust_count(game : Game) -> Int {
  let mut total = 0
  for i in 0..<game.gusts.length() {
    if game.gusts[i].active {
      total = total + 1
    }
  }
  total
}

///|
fn active_thief_count(game : Game) -> Int {
  let mut total = 0
  for i in 0..<game.thieves.length() {
    if game.thieves[i].active {
      total = total + 1
    }
  }
  total
}

///|
fn reset_patrol(patrol : Patrol) -> Unit {
  let gate = gate_position()
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
fn reset_lanterns(game : Game) -> Unit {
  for i in 0..<game.lanterns.length() {
    game.lanterns[i].active = false
    game.lanterns[i].x = 0.0
    game.lanterns[i].y = 0.0
    game.lanterns[i].vx = 0.0
    game.lanterns[i].vy = 0.0
    game.lanterns[i].flame = 0.0
    game.lanterns[i].target_shrine = 0
    game.lanterns[i].escorting = false
    game.lanterns[i].wobble = 0.0
  }
}

///|
fn reset_gusts(game : Game) -> Unit {
  for i in 0..<game.gusts.length() {
    game.gusts[i].active = false
    game.gusts[i].x = 0.0
    game.gusts[i].y = 0.0
    game.gusts[i].vx = 0.0
    game.gusts[i].vy = 0.0
    game.gusts[i].radius = 0.0
    game.gusts[i].power = 0.0
    game.gusts[i].life = 0.0
  }
}

///|
fn reset_sparks(game : Game) -> Unit {
  for i in 0..<game.sparks.length() {
    game.sparks[i].active = false
    game.sparks[i].x = 0.0
    game.sparks[i].y = 0.0
    game.sparks[i].vx = 0.0
    game.sparks[i].vy = 0.0
    game.sparks[i].life = 0.0
    game.sparks[i].power = 0.0
    game.sparks[i].size = 0.0
  }
}

///|
fn reset_thieves(game : Game) -> Unit {
  for i in 0..<game.thieves.length() {
    game.thieves[i].active = false
    game.thieves[i].x = 0.0
    game.thieves[i].y = 0.0
    game.thieves[i].vx = 0.0
    game.thieves[i].vy = 0.0
    game.thieves[i].speed = 0.0
    game.thieves[i].target = -1
    game.thieves[i].steal_cd = 0.0
    game.thieves[i].life = 0.0
  }
}

///|
fn start_new_run(game : Game) -> Unit {
  game.state = state_playing
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
fn end_run_game_over(game : Game, reason : String) -> Unit {
  game.state = state_game_over
  game.game_over_reason = reason
  set_status(game, "Run ended. Press R to patrol again.", 2.0)
}

///|
fn free_lantern_slot(game : Game) -> Int {
  for i in 0..<game.lanterns.length() {
    if not(game.lanterns[i].active) {
      return i
    }
  }
  -1
}

///|
fn free_gust_slot(game : Game) -> Int {
  for i in 0..<game.gusts.length() {
    if not(game.gusts[i].active) {
      return i
    }
  }
  -1
}

///|
fn free_spark_slot(game : Game) -> Int {
  for i in 0..<game.sparks.length() {
    if not(game.sparks[i].active) {
      return i
    }
  }
  -1
}

///|
fn free_thief_slot(game : Game) -> Int {
  for i in 0..<game.thieves.length() {
    if not(game.thieves[i].active) {
      return i
    }
  }
  -1
}

///|
fn spawn_lantern(game : Game) -> Bool {
  let slot = free_lantern_slot(game)
  if slot < 0 {
    return false
  }

  let gate = gate_position()

  game.lanterns[slot].active = true
  game.lanterns[slot].x = gate.0 + randf(-18.0, 18.0)
  game.lanterns[slot].y = gate.1 + randf(-44.0, 44.0)
  game.lanterns[slot].vx = randf(12.0, 38.0)
  game.lanterns[slot].vy = randf(-24.0, 24.0)
  game.lanterns[slot].flame = randf(84.0, 100.0)
  game.lanterns[slot].target_shrine = randi(0, shrine_count - 1)
  game.lanterns[slot].escorting = false
  game.lanterns[slot].wobble = randf(0.0, 6.28)

  true
}

///|
fn spawn_gust(game : Game) -> Bool {
  let slot = free_gust_slot(game)
  if slot < 0 {
    return false
  }

  let edge = randi(0, 3)

  if edge == 0 {
    game.gusts[slot].x = play_left - 44.0
    game.gusts[slot].y = randf(play_top, play_bottom)
    game.gusts[slot].vx = randf(100.0, 220.0)
    game.gusts[slot].vy = randf(-48.0, 48.0)
  } else if edge == 1 {
    game.gusts[slot].x = play_right + 44.0
    game.gusts[slot].y = randf(play_top, play_bottom)
    game.gusts[slot].vx = randf(-220.0, -100.0)
    game.gusts[slot].vy = randf(-48.0, 48.0)
  } else if edge == 2 {
    game.gusts[slot].x = randf(play_left, play_right)
    game.gusts[slot].y = play_top - 44.0
    game.gusts[slot].vx = randf(-48.0, 48.0)
    game.gusts[slot].vy = randf(100.0, 220.0)
  } else {
    game.gusts[slot].x = randf(play_left, play_right)
    game.gusts[slot].y = play_bottom + 44.0
    game.gusts[slot].vx = randf(-48.0, 48.0)
    game.gusts[slot].vy = randf(-220.0, -100.0)
  }

  game.gusts[slot].active = true
  game.gusts[slot].radius = randf(66.0, 100.0)
  game.gusts[slot].power = randf(0.70, 1.28)
  game.gusts[slot].life = randf(5.0, 9.2)

  true
}

///|
fn spawn_spark(game : Game) -> Bool {
  let slot = free_spark_slot(game)
  if slot < 0 {
    return false
  }

  let origin = randi(0, shrine_count)
  let anchor : (Float, Float) = if origin == 0 {
    gate_position()
  } else {
    shrine_position(origin - 1)
  }

  game.sparks[slot].active = true
  game.sparks[slot].x = anchor.0 + randf(-80.0, 80.0)
  game.sparks[slot].y = anchor.1 + randf(-80.0, 80.0)
  game.sparks[slot].vx = randf(-100.0, 100.0)
  game.sparks[slot].vy = randf(-96.0, 96.0)
  game.sparks[slot].life = randf(0.9, 2.8)
  game.sparks[slot].power = randf(
    spark_drain_power * 0.8,
    spark_drain_power * 1.2,
  )
  game.sparks[slot].size = randf(1.8, 4.6)

  true
}

///|
fn nearest_active_lantern(
  game : Game,
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

    let d2 = dist2(x, y, game.lanterns[i].x, game.lanterns[i].y)
    if d2 <= best_d2 {
      best = i
      best_d2 = d2
    }
  }

  best
}

///|
fn spawn_thief(game : Game) -> Bool {
  let slot = free_thief_slot(game)
  if slot < 0 {
    return false
  }

  let edge = randi(0, 2)

  if edge == 0 {
    game.thieves[slot].x = play_right + randf(28.0, 72.0)
    game.thieves[slot].y = randf(play_top + 30.0, play_bottom - 30.0)
  } else if edge == 1 {
    game.thieves[slot].x = randf(play_left + 60.0, play_right - 60.0)
    game.thieves[slot].y = play_top - randf(28.0, 72.0)
  } else {
    game.thieves[slot].x = randf(play_left + 60.0, play_right - 60.0)
    game.thieves[slot].y = play_bottom + randf(28.0, 72.0)
  }

  game.thieves[slot].active = true
  game.thieves[slot].vx = 0.0
  game.thieves[slot].vy = 0.0
  game.thieves[slot].speed = thief_speed +
    Float::from_int(game.deliveries) * 1.7 +
    randf(-14.0, 22.0)
  game.thieves[slot].target = nearest_active_lantern(
    game,
    game.thieves[slot].x,
    game.thieves[slot].y,
    100000000.0,
  )
  game.thieves[slot].steal_cd = randf(0.1, 0.6)
  game.thieves[slot].life = randf(10.0, 20.0)

  true
}

///|
fn release_escort(game : Game) -> Unit {
  let idx = game.patrol.escort
  if idx >= 0 && idx < game.lanterns.length() {
    game.lanterns[idx].escorting = false
  }
  game.patrol.escort = -1
}

///|
fn set_escort(game : Game, idx : Int) -> Unit {
  if idx < 0 || idx >= game.lanterns.length() || not(game.lanterns[idx].active) {
    return
  }

  release_escort(game)
  game.patrol.escort = idx
  game.lanterns[idx].escorting = true
}

///|
fn deliver_lantern(game : Game, idx : Int) -> Unit {
  if idx < 0 || idx >= game.lanterns.length() || not(game.lanterns[idx].active) {
    return
  }

  let flame_score = game.lanterns[idx].flame.to_int() * score_per_flame
  let gain = delivery_score_base + game.combo * combo_bonus_step + flame_score

  game.score = game.score + gain
  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.deliveries = game.deliveries + 1
  game.combo = clampi(game.combo + 1, 0, 99)
  game.combo_t = combo_window

  game.lanterns[idx].active = false
  game.lanterns[idx].escorting = false

  if game.patrol.escort == idx {
    game.patrol.escort = -1
  }

  game.screen_flash_t = maxf(game.screen_flash_t, 0.12)
  set_status(game, "Safe delivery +\{gain}! Combo x\{game.combo}.", 1.0)
}

///|
fn extinguish_lantern(game : Game, idx : Int) -> Unit {
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
  game.screen_flash_t = maxf(game.screen_flash_t, 0.28)

  set_status(
    game,
    "Lantern extinguished (\{game.extinguished}/\{extinguish_limit}).",
    1.2,
  )

  if game.extinguished >= extinguish_limit {
    end_run_game_over(game, "Too many lanterns were extinguished.")
  }
}

///|
fn try_interact(game : Game) -> Unit {
  if game.patrol.escort >= 0 {
    let idx = game.patrol.escort

    if idx >= 0 && idx < game.lanterns.length() && game.lanterns[idx].active {
      let shrine = shrine_position(game.lanterns[idx].target_shrine)
      if dist2(game.lanterns[idx].x, game.lanterns[idx].y, shrine.0, shrine.1) <=
        squaref(delivery_radius + 6.0) {
        deliver_lantern(game, idx)
        return
      }

      game.lanterns[idx].flame = minf(
        100.0,
        game.lanterns[idx].flame + interact_stabilize_boost,
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
    squaref(escort_pickup_range),
  )
  if pickup >= 0 {
    set_escort(game, pickup)
    set_status(game, "Lantern linked to patrol.", 0.8)
    return
  }

  let gate = gate_position()
  if dist2(game.patrol.x, game.patrol.y, gate.0, gate.1) <=
    squaref(escort_pickup_range + 22.0) {
    if spawn_lantern(game) {
      let near_gate = nearest_active_lantern(
        game,
        game.patrol.x,
        game.patrol.y,
        squaref(escort_pickup_range + 40.0),
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
fn try_cancel(game : Game) -> Unit {
  if game.patrol.escort >= 0 {
    release_escort(game)
    set_status(game, "Escort released.", 0.7)
    return
  }

  game.patrol.guard_t = guard_time
  set_status(game, "Guard stance raised.", 0.8)
}

///|
fn try_calm(game : Game) -> Unit {
  if game.patrol.calm_cd <= 0.0 {
    game.patrol.calm_t = calm_duration
    game.patrol.calm_cd = calm_cooldown
    set_status(game, "Calm-wind field deployed.", 1.0)
  } else {
    set_status(game, "Calm field cooling down.", 0.7)
  }
}

///|
fn handle_actions(game : Game) -> Unit {
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
fn update_patrol(game : Game, dt : Float) -> Unit {
  let mut dir_x = Float::from_int(game.input.move_x)
  let mut dir_y = Float::from_int(game.input.move_y)

  if dir_x != 0.0 || dir_y != 0.0 {
    let len2 = dir_x * dir_x + dir_y * dir_y
    let inv = Float::from_int(1) / maxf(len2.sqrt(), 0.001)
    dir_x = dir_x * inv
    dir_y = dir_y * inv
  }

  game.patrol.vx = game.patrol.vx + dir_x * patrol_accel * dt
  game.patrol.vy = game.patrol.vy + dir_y * patrol_accel * dt

  let drag = clampf(1.0 - patrol_drag * dt, 0.0, 1.0)
  game.patrol.vx = game.patrol.vx * drag
  game.patrol.vy = game.patrol.vy * drag

  let speed2 = game.patrol.vx * game.patrol.vx + game.patrol.vy * game.patrol.vy
  let cap2 = patrol_max_speed * patrol_max_speed
  if speed2 > cap2 {
    let factor = patrol_max_speed / maxf(speed2.sqrt(), 0.001)
    game.patrol.vx = game.patrol.vx * factor
    game.patrol.vy = game.patrol.vy * factor
  }

  game.patrol.x = game.patrol.x + game.patrol.vx * dt
  game.patrol.y = game.patrol.y + game.patrol.vy * dt

  if game.patrol.x < play_left {
    game.patrol.x = play_left
    game.patrol.vx = maxf(game.patrol.vx, 0.0)
  }
  if game.patrol.x > play_right {
    game.patrol.x = play_right
    game.patrol.vx = minf(game.patrol.vx, 0.0)
  }
  if game.patrol.y < play_top {
    game.patrol.y = play_top
    game.patrol.vy = maxf(game.patrol.vy, 0.0)
  }
  if game.patrol.y > play_bottom {
    game.patrol.y = play_bottom
    game.patrol.vy = minf(game.patrol.vy, 0.0)
  }

  game.patrol.guard_t = maxf(game.patrol.guard_t - dt, 0.0)
  game.patrol.calm_t = maxf(game.patrol.calm_t - dt, 0.0)
  game.patrol.calm_cd = maxf(game.patrol.calm_cd - dt, 0.0)
}

///|
fn update_combo_timer(game : Game, dt : Float) -> Unit {
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
fn update_spawning(game : Game, dt : Float) -> Unit {
  game.lantern_spawn_cd = game.lantern_spawn_cd - dt
  if game.lantern_spawn_cd <= 0.0 {
    ignore(spawn_lantern(game))
    let pressure = Float::from_int(game.deliveries) * 0.055
    let next = maxf(lantern_spawn_floor, lantern_spawn_interval - pressure)
    game.lantern_spawn_cd = next + randf(0.05, 0.44)
  }

  game.gust_spawn_cd = game.gust_spawn_cd - dt
  if game.gust_spawn_cd <= 0.0 {
    ignore(spawn_gust(game))
    let wind_pressure = Float::from_int(game.deliveries) * 0.024 +
      game.run_time * 0.012
    let next = maxf(gust_spawn_floor, gust_spawn_interval - wind_pressure)
    game.gust_spawn_cd = next + randf(0.0, 0.26)
  }

  game.spark_spawn_cd = game.spark_spawn_cd - dt
  if game.spark_spawn_cd <= 0.0 {
    ignore(spawn_spark(game))
    let lantern_pressure = Float::from_int(active_lantern_count(game)) * 0.005
    let next = maxf(spark_spawn_floor, spark_spawn_interval - lantern_pressure)
    game.spark_spawn_cd = next
  }

  if game.run_time > 8.0 {
    game.thief_spawn_cd = game.thief_spawn_cd - dt
    if game.thief_spawn_cd <= 0.0 {
      ignore(spawn_thief(game))
      let thief_pressure = Float::from_int(game.deliveries) * 0.18
      let next = maxf(thief_spawn_floor, thief_spawn_interval - thief_pressure)
      game.thief_spawn_cd = next + randf(0.0, 1.2)
    }
  }
}

///|
fn update_gusts(game : Game, dt : Float) -> Unit {
  for i in 0..<game.gusts.length() {
    if not(game.gusts[i].active) {
      continue
    }

    game.gusts[i].x = game.gusts[i].x + game.gusts[i].vx * dt
    game.gusts[i].y = game.gusts[i].y + game.gusts[i].vy * dt
    game.gusts[i].life = game.gusts[i].life - dt

    if game.patrol.calm_t > 0.0 &&
      dist2(game.gusts[i].x, game.gusts[i].y, game.patrol.x, game.patrol.y) <=
      squaref(calm_radius + game.gusts[i].radius) {
      let damp = clampf(1.0 - dt * 1.6, 0.50, 1.0)
      game.gusts[i].vx = game.gusts[i].vx * damp
      game.gusts[i].vy = game.gusts[i].vy * damp
    }

    if game.gusts[i].x < play_left - 160.0 ||
      game.gusts[i].x > play_right + 160.0 ||
      game.gusts[i].y < play_top - 160.0 ||
      game.gusts[i].y > play_bottom + 160.0 ||
      game.gusts[i].life <= 0.0 {
      game.gusts[i].active = false
    }
  }
}

///|
fn update_sparks(game : Game, dt : Float) -> Unit {
  for i in 0..<game.sparks.length() {
    if not(game.sparks[i].active) {
      continue
    }

    let in_calm = game.patrol.calm_t > 0.0 &&
      dist2(game.sparks[i].x, game.sparks[i].y, game.patrol.x, game.patrol.y) <=
      squaref(calm_radius)

    if in_calm {
      let calm_drag = clampf(1.0 - dt * 4.0, 0.35, 1.0)
      game.sparks[i].vx = game.sparks[i].vx * calm_drag
      game.sparks[i].vy = game.sparks[i].vy * calm_drag
      game.sparks[i].life = game.sparks[i].life - dt * 1.6
    }

    game.sparks[i].x = game.sparks[i].x + game.sparks[i].vx * dt
    game.sparks[i].y = game.sparks[i].y + game.sparks[i].vy * dt
    game.sparks[i].life = game.sparks[i].life - dt

    if game.sparks[i].life <= 0.0 ||
      game.sparks[i].x < play_left - 80.0 ||
      game.sparks[i].x > play_right + 80.0 ||
      game.sparks[i].y < play_top - 80.0 ||
      game.sparks[i].y > play_bottom + 80.0 {
      game.sparks[i].active = false
    }
  }
}

///|
fn update_thieves(game : Game, dt : Float) -> Unit {
  for i in 0..<game.thieves.length() {
    if not(game.thieves[i].active) {
      continue
    }

    game.thieves[i].steal_cd = maxf(game.thieves[i].steal_cd - dt, 0.0)
    game.thieves[i].life = game.thieves[i].life - dt

    if game.thieves[i].life <= 0.0 {
      game.thieves[i].active = false
      continue
    }

    let target = nearest_active_lantern(
      game,
      game.thieves[i].x,
      game.thieves[i].y,
      100000000.0,
    )
    game.thieves[i].target = target

    let mut vx : Float = 0.0
    let mut vy : Float = 0.0

    if target >= 0 {
      let dx = game.lanterns[target].x - game.thieves[i].x
      let dy = game.lanterns[target].y - game.thieves[i].y
      let d2 = dx * dx + dy * dy

      if d2 <= squaref(thief_contact_radius) {
        if game.thieves[i].steal_cd <= 0.0 {
          game.lanterns[target].flame = game.lanterns[target].flame -
            thief_drain_burst
          game.thieves[i].steal_cd = thief_steal_period
          game.screen_flash_t = maxf(game.screen_flash_t, 0.12)
        }
      } else {
        let inv = Float::from_int(1) / maxf(d2.sqrt(), 0.001)
        let mut speed = game.thieves[i].speed
        if game.patrol.calm_t > 0.0 &&
          dist2(
            game.thieves[i].x,
            game.thieves[i].y,
            game.patrol.x,
            game.patrol.y,
          ) <=
          squaref(calm_radius) {
          speed = speed * 0.64
        }

        vx = dx * inv * speed
        vy = dy * inv * speed
      }
    } else {
      let gate = gate_position()
      let dx = gate.0 - game.thieves[i].x
      let dy = gate.1 - game.thieves[i].y
      let inv = Float::from_int(1) / maxf((dx * dx + dy * dy).sqrt(), 0.001)
      vx = dx * inv * (game.thieves[i].speed * 0.36)
      vy = dy * inv * (game.thieves[i].speed * 0.36)
    }

    game.thieves[i].vx = vx
    game.thieves[i].vy = vy
    game.thieves[i].x = game.thieves[i].x + game.thieves[i].vx * dt
    game.thieves[i].y = game.thieves[i].y + game.thieves[i].vy * dt

    if game.patrol.guard_t > 0.0 {
      let dx = game.thieves[i].x - game.patrol.x
      let dy = game.thieves[i].y - game.patrol.y
      let d2 = dx * dx + dy * dy
      if d2 <= squaref(guard_radius) {
        let inv = Float::from_int(1) / maxf(d2.sqrt(), 0.001)
        game.thieves[i].x = game.thieves[i].x + dx * inv * guard_push * dt
        game.thieves[i].y = game.thieves[i].y + dy * inv * guard_push * dt
        game.thieves[i].life = game.thieves[i].life - dt * 1.8
      }
    }

    if game.thieves[i].x < play_left - 140.0 ||
      game.thieves[i].x > play_right + 140.0 ||
      game.thieves[i].y < play_top - 140.0 ||
      game.thieves[i].y > play_bottom + 140.0 ||
      game.thieves[i].life <= 0.0 {
      game.thieves[i].active = false
    }
  }
}

///|
fn update_lanterns(game : Game, dt : Float) -> Unit {
  for i in 0..<game.lanterns.length() {
    if not(game.lanterns[i].active) {
      continue
    }

    if game.patrol.escort != i {
      game.lanterns[i].escorting = false
    }

    let mut drain = lantern_base_drain * dt

    let near_patrol = dist2(
      game.lanterns[i].x,
      game.lanterns[i].y,
      game.patrol.x,
      game.patrol.y,
    )

    let in_calm = game.patrol.calm_t > 0.0 &&
      near_patrol <= squaref(calm_radius)
    if in_calm {
      drain = drain * 0.34
    }

    if game.patrol.guard_t > 0.0 && near_patrol <= squaref(guard_radius * 0.78) {
      game.lanterns[i].flame = minf(
        100.0,
        game.lanterns[i].flame + lantern_escort_regen * 0.45 * dt,
      )
    }

    if game.patrol.escort == i && game.lanterns[i].escorting {
      let follow_x = game.patrol.x + game.patrol.vx * 0.05
      let follow_y = game.patrol.y -
        26.0 +
        sinf(game.run_time * 7.0 + game.lanterns[i].wobble) * 5.0

      game.lanterns[i].vx = game.lanterns[i].vx +
        (follow_x - game.lanterns[i].x) * escort_pull * dt
      game.lanterns[i].vy = game.lanterns[i].vy +
        (follow_y - game.lanterns[i].y) * escort_pull * dt

      game.lanterns[i].flame = minf(
        100.0,
        game.lanterns[i].flame + lantern_escort_regen * dt,
      )

      drain = drain * 0.72
    }

    game.lanterns[i].vx = game.lanterns[i].vx + randf(-15.0, 15.0) * dt
    game.lanterns[i].vy = game.lanterns[i].vy + randf(-15.0, 15.0) * dt

    for g in 0..<game.gusts.length() {
      if not(game.gusts[g].active) {
        continue
      }

      let d2 = dist2(
        game.lanterns[i].x,
        game.lanterns[i].y,
        game.gusts[g].x,
        game.gusts[g].y,
      )
      let r2 = squaref(game.gusts[g].radius)
      if d2 > r2 {
        continue
      }

      let influence : Float = Float::from_int(1) -
        d2 / maxf(r2, Float::from_int(1))
      game.lanterns[i].vx = game.lanterns[i].vx +
        game.gusts[g].vx * game.gusts[g].power * influence * 0.34 * dt
      game.lanterns[i].vy = game.lanterns[i].vy +
        game.gusts[g].vy * game.gusts[g].power * influence * 0.34 * dt
      drain = drain + gust_drain_power * influence * dt
    }

    for s in 0..<game.sparks.length() {
      if not(game.sparks[s].active) {
        continue
      }

      let d2 = dist2(
        game.lanterns[i].x,
        game.lanterns[i].y,
        game.sparks[s].x,
        game.sparks[s].y,
      )

      if d2 <= squaref(game.sparks[s].size + lantern_radius + 4.0) {
        drain = drain + game.sparks[s].power * dt
        game.sparks[s].active = false
      }
    }

    let drag = clampf(1.0 - lantern_drag * dt, 0.0, 1.0)
    game.lanterns[i].vx = game.lanterns[i].vx * drag
    game.lanterns[i].vy = game.lanterns[i].vy * drag

    game.lanterns[i].x = game.lanterns[i].x + game.lanterns[i].vx * dt
    game.lanterns[i].y = game.lanterns[i].y + game.lanterns[i].vy * dt

    if game.lanterns[i].x < play_left {
      game.lanterns[i].x = play_left
      game.lanterns[i].vx = absf(game.lanterns[i].vx) * 0.4
    }
    if game.lanterns[i].x > play_right {
      game.lanterns[i].x = play_right
      game.lanterns[i].vx = -absf(game.lanterns[i].vx) * 0.4
    }
    if game.lanterns[i].y < play_top {
      game.lanterns[i].y = play_top
      game.lanterns[i].vy = absf(game.lanterns[i].vy) * 0.4
    }
    if game.lanterns[i].y > play_bottom {
      game.lanterns[i].y = play_bottom
      game.lanterns[i].vy = -absf(game.lanterns[i].vy) * 0.4
    }

    game.lanterns[i].flame = game.lanterns[i].flame - drain

    if game.lanterns[i].flame <= 0.0 {
      extinguish_lantern(game, i)
      if game.state == state_game_over {
        return
      }
      continue
    }

    let shrine = shrine_position(game.lanterns[i].target_shrine)
    if dist2(game.lanterns[i].x, game.lanterns[i].y, shrine.0, shrine.1) <=
      squaref(delivery_radius) {
      deliver_lantern(game, i)
      continue
    }

    game.lanterns[i].wobble = game.lanterns[i].wobble +
      dt * (1.8 + randf(-0.3, 0.4))
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
    set_status(game, "Patrol resumed.", 0.7)
  }
}

///|
fn update_game_over_state(game : Game) -> Unit {
  if game.input.press_restart || game.input.press_start {
    start_new_run(game)
  }
}

///|
fn update_playing_state(game : Game, dt : Float) -> Unit {
  if game.input.press_pause {
    game.state = state_paused
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
fn update_game(game : Game, dt : Float) -> Unit {
  if game.status_t > 0.0 {
    game.status_t = maxf(game.status_t - dt, 0.0)
  }

  if game.screen_flash_t > 0.0 {
    game.screen_flash_t = maxf(game.screen_flash_t - dt, 0.0)
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
