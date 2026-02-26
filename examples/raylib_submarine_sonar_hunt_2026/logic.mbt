///|
fn reset_controls(game : Game) -> Unit {
  game.move_x = 0.0
  game.move_y = 0.0
  game.boost_hold = false
  game.sonar_trigger = false
}

///|
fn clear_world(game : Game) -> Unit {
  for i = 0; i < game.mines.length(); i = i + 1 {
    game.mines[i].active = false
    game.mines[i].x = 0.0
    game.mines[i].y = 0.0
    game.mines[i].r = 0.0
    game.mines[i].reveal_t = 0.0
    game.mines[i].armed = true
  }

  for i = 0; i < game.targets.length(); i = i + 1 {
    game.targets[i].active = false
    game.targets[i].x = 0.0
    game.targets[i].y = 0.0
    game.targets[i].detected = false
    game.targets[i].pulse_t = 0.0
  }
}

///|
fn target_goal_for_mission(mission : Int) -> Int {
  clampi(base_target_goal + mission - 1, base_target_goal, target_goal_cap)
}

///|
fn mine_count_for_mission(mission : Int) -> Int {
  clampi(base_mine_count + (mission - 1) * 4, base_mine_count, max_mines)
}

///|
fn in_hot_zone_xy(x : Float, y : Float) -> Bool {
  dist2(x, y, hot_zone_x, hot_zone_y) <= hot_zone_r * hot_zone_r
}

///|
fn sonar_range_at(game : Game) -> Float {
  if in_hot_zone_xy(game.sub_x, game.sub_y) {
    sonar_base_range + sonar_hot_bonus
  } else {
    sonar_base_range
  }
}

///|
fn random_arena_point(margin : Float) -> (Float, Float) {
  let x = randf(arena_left() + margin, arena_right() - margin)
  let y = randf(arena_top() + margin, arena_bottom() - margin)
  (x, y)
}

///|
fn spawn_targets(game : Game) -> Unit {
  for i = 0; i < game.target_goal; i = i + 1 {
    let mut px = sub_start_x + 320.0
    let mut py = sub_start_y
    let mut placed = false

    for _try = 0; _try < 90; _try = _try + 1 {
      if placed {
        continue
      }

      let cand = random_arena_point(30.0)
      let cx = cand.0
      let cy = cand.1

      let mut ok = cy > surface_band_y + 18.0 &&
        dist2(cx, cy, sub_start_x, sub_start_y) > 220.0 * 220.0

      if ok {
        for j = 0; j < i; j = j + 1 {
          if game.targets[j].active &&
            dist2(cx, cy, game.targets[j].x, game.targets[j].y) < 136.0 * 136.0 {
            ok = false
          }
        }
      }

      if ok {
        px = cx
        py = cy
        placed = true
      }
    }

    game.targets[i].active = true
    game.targets[i].x = px
    game.targets[i].y = py
    game.targets[i].detected = false
    game.targets[i].pulse_t = 0.0
  }
}

///|
fn spawn_mines(game : Game) -> Unit {
  for i = 0; i < game.mine_count; i = i + 1 {
    let mut px = sub_start_x + 200.0
    let mut py = sub_start_y
    let mut pr = randf(12.0, 17.0)
    let mut placed = false

    for _try = 0; _try < 120; _try = _try + 1 {
      if placed {
        continue
      }

      let mut cand_x : Float = 0.0
      let mut cand_y : Float = 0.0

      if i % 3 == 0 {
        let a = randf(0.0, 6.28318)
        let rr = randf(30.0, hot_zone_r - 10.0)
        cand_x = clampf(
          hot_zone_x + cosf(a) * rr,
          arena_left() + 24.0,
          arena_right() - 24.0,
        )
        cand_y = clampf(
          hot_zone_y + sinf(a) * rr,
          arena_top() + 24.0,
          arena_bottom() - 24.0,
        )
      } else {
        let cand = random_arena_point(24.0)
        cand_x = cand.0
        cand_y = cand.1
      }

      let cand_r = randf(12.0, 18.5)

      let mut ok = dist2(cand_x, cand_y, sub_start_x, sub_start_y) >
        140.0 * 140.0

      if ok {
        for j = 0; j < game.target_goal; j = j + 1 {
          if game.targets[j].active &&
            dist2(cand_x, cand_y, game.targets[j].x, game.targets[j].y) <
            72.0 * 72.0 {
            ok = false
          }
        }
      }

      if ok {
        for j = 0; j < i; j = j + 1 {
          if game.mines[j].active {
            let sep = cand_r + game.mines[j].r + 20.0
            if dist2(cand_x, cand_y, game.mines[j].x, game.mines[j].y) <
              sep * sep {
              ok = false
            }
          }
        }
      }

      if ok {
        px = cand_x
        py = cand_y
        pr = cand_r
        placed = true
      }
    }

    game.mines[i].active = true
    game.mines[i].x = px
    game.mines[i].y = py
    game.mines[i].r = pr
    game.mines[i].armed = true
    game.mines[i].reveal_t = if i < 3 { 1.1 } else { 0.0 }
  }
}

///|
fn init_title_scene(game : Game) -> Unit {
  game.state = state_title
  game.lose_reason = lose_none
  game.sonar_wave_t = 0.0
  game.sonar_wave_r = 0.0
  game.sonar_cd = 0.0
  game.shake_t = 0.0
  reset_controls(game)
}

///|
fn start_mission(game : Game, mission : Int) -> Unit {
  let clamped_mission = clampi(mission, mission_min, mission_max)

  clear_world(game)
  game.state = state_play
  game.mission = clamped_mission
  game.mine_count = mine_count_for_mission(clamped_mission)
  game.target_goal = target_goal_for_mission(clamped_mission)
  game.targets_found = 0

  game.sub_x = sub_start_x
  game.sub_y = sub_start_y
  game.sub_vx = 0.0
  game.sub_vy = 0.0

  game.oxygen = oxygen_max
  game.fuel = fuel_max
  game.hull = hull_max
  game.lose_reason = lose_none

  game.sonar_cd = 0.0
  game.sonar_wave_t = 0.0
  game.sonar_wave_r = 0.0
  game.last_pulse_range = sonar_base_range
  game.shake_t = 0.0

  reset_controls(game)

  spawn_targets(game)
  spawn_mines(game)
}

///|
fn restart_mission(game : Game) -> Unit {
  start_mission(game, game.mission)
}

///|
fn next_mission(game : Game) -> Unit {
  let next_id = clampi(game.mission + 1, mission_min, mission_max)
  start_mission(game, next_id)
}

///|
fn fire_sonar(game : Game) -> Unit {
  if game.sonar_cd > 0.0 {
    return
  }
  if game.fuel < sonar_fuel_cost || game.oxygen < sonar_oxygen_cost {
    return
  }

  game.fuel = game.fuel - sonar_fuel_cost
  game.oxygen = game.oxygen - sonar_oxygen_cost
  game.sonar_cd = sonar_cd_time
  game.sonar_wave_t = sonar_pulse_time

  let pulse_range = sonar_range_at(game)
  game.last_pulse_range = pulse_range

  let mut found_this_pulse = 0
  for i = 0; i < game.target_goal; i = i + 1 {
    if not(game.targets[i].active) || game.targets[i].detected {
      continue
    }

    if dist2(game.sub_x, game.sub_y, game.targets[i].x, game.targets[i].y) <=
      pulse_range * pulse_range {
      game.targets[i].detected = true
      game.targets[i].pulse_t = 1.0
      game.targets_found = game.targets_found + 1
      found_this_pulse = found_this_pulse + 1
    }
  }

  let mine_reveal_range = pulse_range * 1.08
  for i = 0; i < game.mine_count; i = i + 1 {
    if not(game.mines[i].active) || not(game.mines[i].armed) {
      continue
    }

    if dist2(game.sub_x, game.sub_y, game.mines[i].x, game.mines[i].y) <=
      mine_reveal_range * mine_reveal_range {
      game.mines[i].reveal_t = mine_reveal_time
    }
  }

  if found_this_pulse > 0 {
    let gain = Float::from_int(found_this_pulse)
    game.oxygen = minf(oxygen_max, game.oxygen + gain * detect_oxygen_reward)
    game.fuel = minf(fuel_max, game.fuel + gain * detect_fuel_reward)
  }
}

///|
fn update_sonar_wave(game : Game, dt : Float) -> Unit {
  if game.sonar_cd > 0.0 {
    game.sonar_cd = maxf(0.0, game.sonar_cd - dt)
  }

  if game.sonar_wave_t > 0.0 {
    game.sonar_wave_t = maxf(0.0, game.sonar_wave_t - dt)
    let progress : Float = 1.0 - game.sonar_wave_t / sonar_pulse_time
    game.sonar_wave_r = game.last_pulse_range * clampf(progress, 0.0, 1.0)
  } else {
    game.sonar_wave_r = 0.0
  }
}

///|
fn update_submarine_motion(game : Game, dt : Float) -> Unit {
  let mut ix = game.move_x
  let mut iy = game.move_y

  let mag2 = ix * ix + iy * iy
  if mag2 > 1.0 {
    let inv : Float = 1.0 / sqrtf(mag2)
    ix = ix * inv
    iy = iy * inv
  }

  let boosting = game.boost_hold && game.fuel > 0.0
  let accel = if boosting { sub_boost_accel } else { sub_accel }

  game.sub_vx = game.sub_vx + ix * accel * dt
  game.sub_vy = game.sub_vy + iy * accel * dt

  let drag : Float = 1.0 / (1.0 + sub_drag * dt)
  game.sub_vx = game.sub_vx * drag
  game.sub_vy = game.sub_vy * drag

  let speed2 = game.sub_vx * game.sub_vx + game.sub_vy * game.sub_vy
  let max_speed = if boosting { sub_boost_max_speed } else { sub_max_speed }
  if speed2 > max_speed * max_speed {
    let scale = max_speed / sqrtf(speed2)
    game.sub_vx = game.sub_vx * scale
    game.sub_vy = game.sub_vy * scale
  }

  game.sub_x = game.sub_x + game.sub_vx * dt
  game.sub_y = game.sub_y + game.sub_vy * dt

  let lo_x = arena_left() + sub_r + 4.0
  let hi_x = arena_right() - sub_r - 4.0
  let lo_y = arena_top() + sub_r + 4.0
  let hi_y = arena_bottom() - sub_r - 4.0

  if game.sub_x < lo_x {
    game.sub_x = lo_x
    game.sub_vx = 0.0
  } else if game.sub_x > hi_x {
    game.sub_x = hi_x
    game.sub_vx = 0.0
  }

  if game.sub_y < lo_y {
    game.sub_y = lo_y
    game.sub_vy = 0.0
  } else if game.sub_y > hi_y {
    game.sub_y = hi_y
    game.sub_vy = 0.0
  }
}

///|
fn update_resources(game : Game, dt : Float) -> Unit {
  let input_mag = clampf(
    sqrtf(game.move_x * game.move_x + game.move_y * game.move_y),
    0.0,
    1.0,
  )

  let boosting = game.boost_hold && game.fuel > 0.0

  let mut fuel_drain = fuel_idle_drain + input_mag * fuel_move_drain
  if boosting {
    fuel_drain = fuel_drain + fuel_boost_drain
  }

  game.fuel = game.fuel - fuel_drain * dt

  let mut oxygen_delta = -oxygen_base_drain
  if in_hot_zone_xy(game.sub_x, game.sub_y) {
    oxygen_delta = oxygen_delta - oxygen_hot_drain
  }
  if boosting {
    oxygen_delta = oxygen_delta - oxygen_boost_drain
  }
  if game.sub_y <= surface_band_y {
    oxygen_delta = oxygen_delta + oxygen_surface_recover
  }

  game.oxygen = game.oxygen + oxygen_delta * dt

  game.oxygen = clampf(game.oxygen, 0.0, oxygen_max)
  game.fuel = clampf(game.fuel, 0.0, fuel_max)
  game.hull = clampf(game.hull, 0.0, hull_max)
}

///|
fn update_contacts(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.target_goal; i = i + 1 {
    if not(game.targets[i].active) {
      continue
    }

    if game.targets[i].pulse_t > 0.0 {
      game.targets[i].pulse_t = maxf(0.0, game.targets[i].pulse_t - dt)
    }
  }

  for i = 0; i < game.mine_count; i = i + 1 {
    if not(game.mines[i].active) {
      continue
    }

    if game.mines[i].reveal_t > 0.0 {
      game.mines[i].reveal_t = maxf(0.0, game.mines[i].reveal_t - dt)
    }

    if not(game.mines[i].armed) {
      continue
    }

    let hit_r = sub_r + game.mines[i].r
    if dist2(game.sub_x, game.sub_y, game.mines[i].x, game.mines[i].y) <=
      hit_r * hit_r {
      game.mines[i].armed = false
      game.mines[i].reveal_t = 2.4

      game.hull = game.hull - mine_damage_hull
      game.oxygen = game.oxygen - mine_damage_oxygen
      game.fuel = game.fuel - mine_damage_fuel
      game.shake_t = 0.36

      let dx = game.sub_x - game.mines[i].x
      let dy = game.sub_y - game.mines[i].y
      let n = sqrtf(maxf(dx * dx + dy * dy, 0.001))
      game.sub_vx = game.sub_vx + dx / n * 180.0
      game.sub_vy = game.sub_vy + dy / n * 180.0
    }
  }
}

///|
fn resolve_round_state(game : Game) -> Unit {
  if game.targets_found >= game.target_goal {
    game.state = state_win
    game.lose_reason = lose_none
    let unlock = clampi(game.mission + 1, mission_min, mission_max)
    if unlock > game.best_mission {
      game.best_mission = unlock
    }
    reset_controls(game)
    return
  }

  if game.hull <= 0.0 {
    game.state = state_lose
    game.lose_reason = lose_hull
    reset_controls(game)
    return
  }

  if game.oxygen <= 0.0 {
    game.state = state_lose
    game.lose_reason = lose_oxygen
    reset_controls(game)
    return
  }

  if game.fuel <= 0.0 {
    game.state = state_lose
    game.lose_reason = lose_fuel
    reset_controls(game)
  }
}

///|
fn update_play_state(game : Game, dt : Float) -> Unit {
  if game.sonar_trigger {
    fire_sonar(game)
  }
  game.sonar_trigger = false

  update_submarine_motion(game, dt)
  update_resources(game, dt)
  update_contacts(game, dt)
  resolve_round_state(game)
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  let d = clampf(dt, 0.0, 0.05)

  game.time_s = game.time_s + d

  if game.touch_cd > 0.0 {
    game.touch_cd = maxf(0.0, game.touch_cd - d)
  }
  if game.shake_t > 0.0 {
    game.shake_t = maxf(0.0, game.shake_t - d)
  }

  update_sonar_wave(game, d)

  if game.state == state_play {
    update_play_state(game, d)
  }
}

///|
fn nearest_undetected_target(game : Game) -> (Float, Float, Bool) {
  let mut best_x = game.sub_x
  let mut best_y = game.sub_y
  let mut found = false
  let mut best_d : Float = 1_000_000_000.0

  for i = 0; i < game.target_goal; i = i + 1 {
    if not(game.targets[i].active) || game.targets[i].detected {
      continue
    }

    let d = dist2(game.sub_x, game.sub_y, game.targets[i].x, game.targets[i].y)
    if d < best_d {
      best_d = d
      best_x = game.targets[i].x
      best_y = game.targets[i].y
      found = true
    }
  }

  (best_x, best_y, found)
}

///|
fn lose_reason_text(game : Game) -> String {
  if game.lose_reason == lose_hull {
    "Hull failure after mine impact"
  } else if game.lose_reason == lose_oxygen {
    "Crew oxygen depleted"
  } else if game.lose_reason == lose_fuel {
    "Fuel reserves exhausted"
  } else {
    "Mission failed"
  }
}
