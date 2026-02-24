///|
fn clear_towers(game : Game) -> Unit {
  for i = 0; i < game.towers.length(); i = i + 1 {
    game.towers[i].active = false
    game.towers[i].x = 0.0
    game.towers[i].y = 0.0
    game.towers[i].need = 0
    game.towers[i].delivered = 0
    game.towers[i].pulse_t = 0.0
  }
}

///|
fn clear_storms(game : Game) -> Unit {
  for i = 0; i < game.storms.length(); i = i + 1 {
    game.storms[i].active = false
    game.storms[i].x = 0.0
    game.storms[i].y = 0.0
    game.storms[i].r = 0.0
    game.storms[i].vx = 0.0
    game.storms[i].vy = 0.0
    game.storms[i].phase = 0.0
    game.storms[i].strength = 0.0
  }
}

///|
fn stage_timer_limit(stage : Int) -> Float {
  let raw = timer_base - Float::from_int(stage - 1) * timer_step
  maxf(timer_floor, raw)
}

///|
fn stage_tower_count(stage : Int) -> Int {
  clampi(2 + stage, 3, max_towers)
}

///|
fn stage_storm_count(stage : Int) -> Int {
  clampi(1 + stage / 2, 1, max_storms)
}

///|
fn stage_tower_need(stage : Int, idx : Int) -> Int {
  let base = 1 + (stage - 1) / 2
  clampi(base + idx % 2, 1, 4)
}

///|
fn set_hint(game : Game, text : String, ttl : Float) -> Unit {
  game.hint_text = text
  game.hint_t = ttl
}

///|
fn tower_spot_ok(game : Game, placed : Int, x : Float, y : Float) -> Bool {
  if dist2(x, y, depot_x(), depot_y()) < 250.0 * 250.0 {
    return false
  }

  for i = 0; i < placed; i = i + 1 {
    if not(game.towers[i].active) {
      continue
    }

    if dist2(x, y, game.towers[i].x, game.towers[i].y) < 190.0 * 190.0 {
      return false
    }
  }

  true
}

///|
fn setup_stage(game : Game, stage : Int) -> Unit {
  clear_towers(game)
  clear_storms(game)

  game.state = state_play
  game.stage = if stage < 1 { 1 } else { stage }
  game.result_win = false
  game.result_note = ""

  game.mission_limit_s = stage_timer_limit(game.stage)
  game.timer_s = game.mission_limit_s
  game.objective_total = 0
  game.objective_done = 0

  game.rover_x = depot_x()
  game.rover_y = depot_y()
  game.rover_vx = 0.0
  game.rover_vy = 0.0
  game.rover_energy = energy_max
  game.rover_heat = heat_max
  game.cargo_cells = 0
  game.storm_intensity = 0.0
  game.in_depot = true
  game.nearby_tower = -1
  game.flash_t = 0.0

  let tower_count = stage_tower_count(game.stage)
  for i = 0; i < tower_count; i = i + 1 {
    let mut tx = randf(world_left() + 120.0, world_right() - 120.0)
    let mut ty = randf(world_top() + 120.0, world_bottom() - 120.0)

    for _attempt = 0; _attempt < 36; _attempt = _attempt + 1 {
      let cand_x = randf(world_left() + 120.0, world_right() - 120.0)
      let cand_y = randf(world_top() + 120.0, world_bottom() - 120.0)
      if tower_spot_ok(game, i, cand_x, cand_y) {
        tx = cand_x
        ty = cand_y
        break
      }
    }

    game.towers[i].active = true
    game.towers[i].x = tx
    game.towers[i].y = ty
    game.towers[i].need = stage_tower_need(game.stage, i)
    game.towers[i].delivered = 0
    game.towers[i].pulse_t = randf(0.0, 6.28)
    game.objective_total = game.objective_total + game.towers[i].need
  }

  let storm_count = stage_storm_count(game.stage)
  for i = 0; i < storm_count; i = i + 1 {
    let mut sx = randf(world_left() + 140.0, world_right() - 140.0)
    let mut sy = randf(world_top() + 140.0, world_bottom() - 140.0)

    for _attempt = 0; _attempt < 24; _attempt = _attempt + 1 {
      if dist2(sx, sy, depot_x(), depot_y()) > 230.0 * 230.0 {
        break
      }
      sx = randf(world_left() + 140.0, world_right() - 140.0)
      sy = randf(world_top() + 140.0, world_bottom() - 140.0)
    }

    let mut vx = randf(-120.0, 120.0)
    let mut vy = randf(-120.0, 120.0)
    if absf(vx) + absf(vy) < 50.0 {
      vx = 54.0 + Float::from_int(i) * 18.0
      vy = -62.0 + Float::from_int(i) * 12.0
    }

    game.storms[i].active = true
    game.storms[i].x = sx
    game.storms[i].y = sy
    game.storms[i].r = randf(90.0, 152.0) + Float::from_int(game.stage) * 7.0
    game.storms[i].vx = vx
    game.storms[i].vy = vy
    game.storms[i].phase = randf(0.0, 6.28)
    game.storms[i].strength = clampf(
      0.52 + Float::from_int(game.stage) * 0.10 + randf(0.0, 0.28),
      0.4,
      1.7,
    )
  }

  set_hint(game, "Load cells at depot, deliver to relay towers", 2.2)
}

///|
fn init_title_scene(game : Game) -> Unit {
  clear_towers(game)
  clear_storms(game)

  game.state = state_title
  game.stage = 1
  game.mission_limit_s = stage_timer_limit(1)
  game.timer_s = game.mission_limit_s
  game.objective_total = 0
  game.objective_done = 0
  game.rover_x = depot_x()
  game.rover_y = depot_y()
  game.rover_vx = 0.0
  game.rover_vy = 0.0
  game.rover_energy = energy_max
  game.rover_heat = heat_max
  game.cargo_cells = 0
  game.storm_intensity = 0.0
  game.in_depot = true
  game.nearby_tower = -1
  game.result_note = ""
  game.result_win = false
  game.flash_t = 0.0
  set_hint(game, "Arctic relay prep", 0.0)

  for i = 0; i < 3; i = i + 1 {
    game.towers[i].active = true
    game.towers[i].x = world_left() + 420.0 + Float::from_int(i) * 170.0
    game.towers[i].y = world_top() + 210.0 + Float::from_int(i % 2) * 220.0
    game.towers[i].need = 2
    game.towers[i].delivered = i % 2
    game.towers[i].pulse_t = Float::from_int(i)
  }

  for i = 0; i < 2; i = i + 1 {
    game.storms[i].active = true
    game.storms[i].x = world_left() + 500.0 + Float::from_int(i) * 200.0
    game.storms[i].y = world_top() + 260.0 + Float::from_int(i) * 180.0
    game.storms[i].r = 120.0
    game.storms[i].vx = 42.0 - Float::from_int(i) * 18.0
    game.storms[i].vy = 34.0 + Float::from_int(i) * 20.0
    game.storms[i].phase = Float::from_int(i) * 2.1
    game.storms[i].strength = 0.62
  }
}

///|
fn closest_pending_tower(game : Game, x : Float, y : Float) -> Int {
  let mut best_idx = -1
  let mut best_d2 = tower_interact_r() * tower_interact_r()

  for i = 0; i < game.towers.length(); i = i + 1 {
    if not(game.towers[i].active) {
      continue
    }
    if game.towers[i].delivered >= game.towers[i].need {
      continue
    }

    let d2 = dist2(x, y, game.towers[i].x, game.towers[i].y)
    if d2 <= best_d2 {
      best_d2 = d2
      best_idx = i
    }
  }

  best_idx
}

///|
fn update_proximity(game : Game) -> Unit {
  game.in_depot = dist2(game.rover_x, game.rover_y, depot_x(), depot_y()) <=
    depot_r() * depot_r()
  game.nearby_tower = closest_pending_tower(game, game.rover_x, game.rover_y)
}

///|
fn update_storms(game : Game, dt : Float) -> Unit {
  let left = world_left() + 20.0
  let right = world_right() - 20.0
  let top = world_top() + 20.0
  let bottom = world_bottom() - 20.0

  for i = 0; i < game.storms.length(); i = i + 1 {
    if not(game.storms[i].active) {
      continue
    }

    game.storms[i].phase = game.storms[i].phase +
      dt * (0.8 + game.storms[i].strength * 0.8)

    let drift_x = cosf(game.storms[i].phase * 0.7) * 18.0
    let drift_y = sinf(game.storms[i].phase * 0.6) * 14.0

    game.storms[i].x = game.storms[i].x + (game.storms[i].vx + drift_x) * dt
    game.storms[i].y = game.storms[i].y + (game.storms[i].vy + drift_y) * dt

    if game.storms[i].x - game.storms[i].r < left {
      game.storms[i].x = left + game.storms[i].r
      game.storms[i].vx = absf(game.storms[i].vx)
    } else if game.storms[i].x + game.storms[i].r > right {
      game.storms[i].x = right - game.storms[i].r
      game.storms[i].vx = -absf(game.storms[i].vx)
    }

    if game.storms[i].y - game.storms[i].r < top {
      game.storms[i].y = top + game.storms[i].r
      game.storms[i].vy = absf(game.storms[i].vy)
    } else if game.storms[i].y + game.storms[i].r > bottom {
      game.storms[i].y = bottom - game.storms[i].r
      game.storms[i].vy = -absf(game.storms[i].vy)
    }
  }
}

///|
fn storm_effect_at(game : Game, x : Float, y : Float) -> (Float, Float, Float) {
  let mut intensity : Float = 0.0
  let mut wind_x : Float = 0.0
  let mut wind_y : Float = 0.0

  for i = 0; i < game.storms.length(); i = i + 1 {
    if not(game.storms[i].active) {
      continue
    }

    let rr = game.storms[i].r
    let rr2 = rr * rr
    let d2 = dist2(x, y, game.storms[i].x, game.storms[i].y)

    if d2 > rr2 {
      continue
    }

    let center_gain : Float = 1.0 - d2 / rr2
    let amp : Float = game.storms[i].strength * (0.35 + center_gain * 0.95)
    intensity = intensity + amp

    let swirl : Float = 8.0 + center_gain * 22.0
    wind_x = wind_x +
      game.storms[i].vx * 0.008 * amp +
      cosf(game.storms[i].phase + Float::from_int(i) * 0.7) * swirl
    wind_y = wind_y +
      game.storms[i].vy * 0.008 * amp +
      sinf(game.storms[i].phase + Float::from_int(i) * 0.7) * swirl
  }

  (clampf(intensity, 0.0, 1.8), wind_x, wind_y)
}

///|
fn update_rover(
  game : Game,
  dt : Float,
  intensity : Float,
  wind_x : Float,
  wind_y : Float,
) -> Unit {
  let mut dir_x = game.input_x
  let mut dir_y = game.input_y

  let norm = absf(dir_x) + absf(dir_y)
  if norm > 0.0001 {
    dir_x = dir_x / norm
    dir_y = dir_y / norm
  }

  let ctrl : Float = 1.0 - storm_control_penalty * clampf(intensity, 0.0, 1.2)

  game.rover_vx = game.rover_vx +
    (dir_x * rover_accel * ctrl + wind_x * rover_wind_force) * dt
  game.rover_vy = game.rover_vy +
    (dir_y * rover_accel * ctrl + wind_y * rover_wind_force) * dt

  let damp = clampf(1.0 - (rover_drag + intensity * 2.2) * dt, 0.0, 1.0)
  game.rover_vx = game.rover_vx * damp
  game.rover_vy = game.rover_vy * damp

  let max_speed = maxf(
    130.0,
    rover_max_speed * (1.0 - 0.24 * clampf(intensity, 0.0, 1.0)),
  )
  let speed_sum = absf(game.rover_vx) + absf(game.rover_vy)
  if speed_sum > max_speed {
    let s = max_speed / speed_sum
    game.rover_vx = game.rover_vx * s
    game.rover_vy = game.rover_vy * s
  }

  game.rover_x = game.rover_x + game.rover_vx * dt
  game.rover_y = game.rover_y + game.rover_vy * dt

  let left = world_left() + rover_r + 4.0
  let right = world_right() - rover_r - 4.0
  let top = world_top() + rover_r + 4.0
  let bottom = world_bottom() - rover_r - 4.0

  if game.rover_x < left {
    game.rover_x = left
    game.rover_vx = 0.0
  } else if game.rover_x > right {
    game.rover_x = right
    game.rover_vx = 0.0
  }

  if game.rover_y < top {
    game.rover_y = top
    game.rover_vy = 0.0
  } else if game.rover_y > bottom {
    game.rover_y = bottom
    game.rover_vy = 0.0
  }
}

///|
fn update_resources(game : Game, dt : Float, intensity : Float) -> Unit {
  let speed = absf(game.rover_vx) + absf(game.rover_vy)
  let energy_drain = energy_idle_drain +
    speed * energy_move_drain +
    intensity * energy_storm_drain
  let heat_drain = heat_idle_drain + intensity * heat_storm_drain

  let mut next_energy = game.rover_energy - energy_drain * dt
  let mut next_heat = game.rover_heat - heat_drain * dt

  if game.in_depot {
    next_energy = next_energy + energy_recharge_rate * dt
    next_heat = next_heat + heat_recharge_rate * dt
  }

  game.rover_energy = clampf(next_energy, 0.0, energy_max)
  game.rover_heat = clampf(next_heat, 0.0, heat_max)
}

///|
fn apply_action(game : Game) -> Unit {
  if not(game.input_action_press) {
    return
  }

  if game.in_depot {
    if game.cargo_cells < cargo_capacity {
      game.cargo_cells = game.cargo_cells + 1
      set_hint(game, "Power cell secured in cargo bay", 1.0)
      game.flash_t = 0.12
    } else {
      set_hint(game, "Cargo bay is full", 0.9)
    }
    return
  }

  if game.nearby_tower >= 0 {
    if game.cargo_cells <= 0 {
      set_hint(game, "No power cell in cargo", 0.9)
      return
    }

    let idx = game.nearby_tower
    if game.towers[idx].delivered < game.towers[idx].need {
      game.towers[idx].delivered = game.towers[idx].delivered + 1
      game.cargo_cells = game.cargo_cells - 1
      game.objective_done = game.objective_done + 1
      game.flash_t = 0.18

      if game.towers[idx].delivered >= game.towers[idx].need {
        let bonus = tower_online_bonus_base +
          Float::from_int(game.stage) * tower_online_bonus_step
        game.timer_s = game.timer_s + bonus
        set_hint(game, "Relay online, +\{bonus.to_int()}s", 1.3)
      } else {
        set_hint(game, "Relay charge delivered", 0.8)
      }
    }
    return
  }

  set_hint(game, "Move close to depot or a relay tower", 0.8)
}

///|
fn set_result(game : Game, win : Bool, note : String) -> Unit {
  game.state = state_result
  game.result_win = win
  game.result_note = note
  game.flash_t = 0.8
  game.rover_vx = 0.0
  game.rover_vy = 0.0

  if win && game.stage > game.best_stage {
    game.best_stage = game.stage
  }
}

///|
fn update_play_state(game : Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    init_title_scene(game)
    return
  }

  game.timer_s = game.timer_s - dt
  update_storms(game, dt)

  let effect = storm_effect_at(game, game.rover_x, game.rover_y)
  game.storm_intensity = effect.0

  update_rover(game, dt, effect.0, effect.1, effect.2)

  update_proximity(game)
  update_resources(game, dt, game.storm_intensity)

  for i = 0; i < game.towers.length(); i = i + 1 {
    if game.towers[i].active {
      game.towers[i].pulse_t = game.towers[i].pulse_t +
        dt * (1.2 + Float::from_int(i) * 0.15)
    }
  }

  apply_action(game)

  if game.objective_total > 0 && game.objective_done >= game.objective_total {
    set_result(game, true, "All relay towers synchronized")
    return
  }

  if game.timer_s <= 0.0 {
    set_result(game, false, "Shift timer expired")
    return
  }

  if game.rover_energy <= 0.0 {
    set_result(game, false, "Battery depleted in whiteout")
    return
  }

  if game.rover_heat <= 0.0 {
    set_result(game, false, "Rover heat loss critical")
    return
  }
}

///|
fn update_game(game : Game, dt0 : Float) -> Unit {
  let dt = clampf(dt0, 0.0, 0.05)
  game.ui_t = game.ui_t + dt
  game.flash_t = maxf(0.0, game.flash_t - dt)
  game.hint_t = maxf(0.0, game.hint_t - dt)

  if game.state == state_title {
    update_storms(game, dt)
    if game.input_start_press {
      setup_stage(game, 1)
    }
    return
  }

  if game.state == state_play {
    update_play_state(game, dt)
    return
  }

  if game.input_next_press {
    let next_stage = if game.result_win { game.stage + 1 } else { game.stage }
    setup_stage(game, next_stage)
  } else if game.input_restart_press {
    setup_stage(game, 1)
  }
}
