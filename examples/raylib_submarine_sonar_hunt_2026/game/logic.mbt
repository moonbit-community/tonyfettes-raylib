///|
fn reset_controls(game : @types.Game) -> Unit {
  game.move_x = 0.0
  game.move_y = 0.0
  game.boost_hold = false
  game.sonar_trigger = false
}

///|
fn clear_world(game : @types.Game) -> Unit {
  for mine in game.mines {
    mine.active = false
    mine.x = 0.0
    mine.y = 0.0
    mine.r = 0.0
    mine.reveal_t = 0.0
    mine.armed = true
  }
  for target in game.targets {
    target.active = false
    target.x = 0.0
    target.y = 0.0
    target.detected = false
    target.pulse_t = 0.0
  }
}

///|
fn target_goal_for_mission(mission : Int) -> Int {
  @types.clampi(
    @types.base_target_goal + mission - 1,
    @types.base_target_goal,
    @types.target_goal_cap,
  )
}

///|
fn mine_count_for_mission(mission : Int) -> Int {
  @types.clampi(
    @types.base_mine_count + (mission - 1) * 4,
    @types.base_mine_count,
    @types.max_mines,
  )
}

///|
fn sonar_range_at(game : @types.Game) -> Float {
  if @types.in_hot_zone_xy(game.sub_x, game.sub_y) {
    @types.sonar_base_range + @types.sonar_hot_bonus
  } else {
    @types.sonar_base_range
  }
}

///|
fn random_arena_point(margin : Float) -> (Float, Float) {
  let x = @types.randf(
    @types.arena_left() + margin,
    @types.arena_right() - margin,
  )
  let y = @types.randf(
    @types.arena_top() + margin,
    @types.arena_bottom() - margin,
  )
  (x, y)
}

///|
fn spawn_targets(game : @types.Game) -> Unit {
  for i in 0..<game.target_goal {
    let mut px = @types.sub_start_x + 320.0
    let mut py = @types.sub_start_y
    let mut placed = false
    for _try in 0..<90 {
      if placed {
        continue
      }
      let cand = random_arena_point(30.0)
      let cx = cand.0
      let cy = cand.1
      let mut ok = cy > @types.surface_band_y + 18.0 &&
        @types.dist2(cx, cy, @types.sub_start_x, @types.sub_start_y) >
        220.0 * 220.0
      if ok {
        for j in 0..<i {
          if game.targets[j].active &&
            @types.dist2(cx, cy, game.targets[j].x, game.targets[j].y) <
            136.0 * 136.0 {
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
fn spawn_mines(game : @types.Game) -> Unit {
  for i in 0..<game.mine_count {
    let mut px = @types.sub_start_x + 200.0
    let mut py = @types.sub_start_y
    let mut pr = @types.randf(12.0, 17.0)
    let mut placed = false
    for _try in 0..<120 {
      if placed {
        continue
      }
      let mut cand_x : Float = 0.0
      let mut cand_y : Float = 0.0
      if i % 3 == 0 {
        let a = @types.randf(0.0, 6.28318)
        let rr = @types.randf(30.0, @types.hot_zone_r - 10.0)
        cand_x = @types.clampf(
          @types.hot_zone_x + @types.cosf(a) * rr,
          @types.arena_left() + 24.0,
          @types.arena_right() - 24.0,
        )
        cand_y = @types.clampf(
          @types.hot_zone_y + @types.sinf(a) * rr,
          @types.arena_top() + 24.0,
          @types.arena_bottom() - 24.0,
        )
      } else {
        let cand = random_arena_point(24.0)
        cand_x = cand.0
        cand_y = cand.1
      }
      let cand_r = @types.randf(12.0, 18.5)
      let mut ok = @types.dist2(
          cand_x,
          cand_y,
          @types.sub_start_x,
          @types.sub_start_y,
        ) >
        140.0 * 140.0
      if ok {
        for j in 0..<game.target_goal {
          if game.targets[j].active &&
            @types.dist2(cand_x, cand_y, game.targets[j].x, game.targets[j].y) <
            72.0 * 72.0 {
            ok = false
          }
        }
      }
      if ok {
        for j in 0..<i {
          if game.mines[j].active {
            let sep = cand_r + game.mines[j].r + 20.0
            if @types.dist2(
                cand_x,
                cand_y,
                game.mines[j].x,
                game.mines[j].y,
              ) <
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
fn init_title_scene(game : @types.Game) -> Unit {
  game.state = @types.state_title
  game.lose_reason = @types.lose_none
  game.sonar_wave_t = 0.0
  game.sonar_wave_r = 0.0
  game.sonar_cd = 0.0
  game.shake_t = 0.0
  reset_controls(game)
}

///|
fn start_mission(game : @types.Game, mission : Int) -> Unit {
  let clamped_mission = @types.clampi(
    mission,
    @types.mission_min,
    @types.mission_max,
  )
  clear_world(game)
  game.state = @types.state_play
  game.mission = clamped_mission
  game.mine_count = mine_count_for_mission(clamped_mission)
  game.target_goal = target_goal_for_mission(clamped_mission)
  game.targets_found = 0
  game.sub_x = @types.sub_start_x
  game.sub_y = @types.sub_start_y
  game.sub_vx = 0.0
  game.sub_vy = 0.0
  game.oxygen = @types.oxygen_max
  game.fuel = @types.fuel_max
  game.hull = @types.hull_max
  game.lose_reason = @types.lose_none
  game.sonar_cd = 0.0
  game.sonar_wave_t = 0.0
  game.sonar_wave_r = 0.0
  game.last_pulse_range = @types.sonar_base_range
  game.shake_t = 0.0
  reset_controls(game)
  spawn_targets(game)
  spawn_mines(game)
}

///|
fn restart_mission(game : @types.Game) -> Unit {
  start_mission(game, game.mission)
}

///|
fn next_mission(game : @types.Game) -> Unit {
  let next_id = @types.clampi(
    game.mission + 1,
    @types.mission_min,
    @types.mission_max,
  )
  start_mission(game, next_id)
}

///|
fn fire_sonar(game : @types.Game) -> Unit {
  if game.sonar_cd > 0.0 {
    return
  }
  if game.fuel < @types.sonar_fuel_cost ||
    game.oxygen < @types.sonar_oxygen_cost {
    return
  }
  game.fuel = game.fuel - @types.sonar_fuel_cost
  game.oxygen = game.oxygen - @types.sonar_oxygen_cost
  game.sonar_cd = @types.sonar_cd_time
  game.sonar_wave_t = @types.sonar_pulse_time
  let pulse_range = sonar_range_at(game)
  game.last_pulse_range = pulse_range
  let mut found_this_pulse = 0
  for i in 0..<game.target_goal {
    if not(game.targets[i].active) || game.targets[i].detected {
      continue
    }
    if @types.dist2(
        game.sub_x,
        game.sub_y,
        game.targets[i].x,
        game.targets[i].y,
      ) <=
      pulse_range * pulse_range {
      game.targets[i].detected = true
      game.targets[i].pulse_t = 1.0
      game.targets_found = game.targets_found + 1
      found_this_pulse = found_this_pulse + 1
    }
  }
  let mine_reveal_range = pulse_range * 1.08
  for i in 0..<game.mine_count {
    if not(game.mines[i].active) || not(game.mines[i].armed) {
      continue
    }
    if @types.dist2(
        game.sub_x,
        game.sub_y,
        game.mines[i].x,
        game.mines[i].y,
      ) <=
      mine_reveal_range * mine_reveal_range {
      game.mines[i].reveal_t = @types.mine_reveal_time
    }
  }
  if found_this_pulse > 0 {
    let gain = Float::from_int(found_this_pulse)
    game.oxygen = @types.minf(
      @types.oxygen_max,
      game.oxygen + gain * @types.detect_oxygen_reward,
    )
    game.fuel = @types.minf(
      @types.fuel_max,
      game.fuel + gain * @types.detect_fuel_reward,
    )
  }
}

///|
fn update_sonar_wave(game : @types.Game, dt : Float) -> Unit {
  if game.sonar_cd > 0.0 {
    game.sonar_cd = @types.maxf(0.0, game.sonar_cd - dt)
  }
  if game.sonar_wave_t > 0.0 {
    game.sonar_wave_t = @types.maxf(0.0, game.sonar_wave_t - dt)
    let progress : Float = 1.0 - game.sonar_wave_t / @types.sonar_pulse_time
    game.sonar_wave_r = game.last_pulse_range *
      @types.clampf(progress, 0.0, 1.0)
  } else {
    game.sonar_wave_r = 0.0
  }
}

///|
fn update_submarine_motion(game : @types.Game, dt : Float) -> Unit {
  let mut ix = game.move_x
  let mut iy = game.move_y
  let mag2 = ix * ix + iy * iy
  if mag2 > 1.0 {
    let inv : Float = 1.0 / @types.sqrtf(mag2)
    ix = ix * inv
    iy = iy * inv
  }
  let boosting = game.boost_hold && game.fuel > 0.0
  let accel = if boosting { @types.sub_boost_accel } else { @types.sub_accel }
  game.sub_vx = game.sub_vx + ix * accel * dt
  game.sub_vy = game.sub_vy + iy * accel * dt
  let drag : Float = 1.0 / (1.0 + @types.sub_drag * dt)
  game.sub_vx = game.sub_vx * drag
  game.sub_vy = game.sub_vy * drag
  let speed2 = game.sub_vx * game.sub_vx + game.sub_vy * game.sub_vy
  let max_speed = if boosting {
    @types.sub_boost_max_speed
  } else {
    @types.sub_max_speed
  }
  if speed2 > max_speed * max_speed {
    let scale = max_speed / @types.sqrtf(speed2)
    game.sub_vx = game.sub_vx * scale
    game.sub_vy = game.sub_vy * scale
  }
  game.sub_x = game.sub_x + game.sub_vx * dt
  game.sub_y = game.sub_y + game.sub_vy * dt
  let lo_x = @types.arena_left() + @types.sub_r + 4.0
  let hi_x = @types.arena_right() - @types.sub_r - 4.0
  let lo_y = @types.arena_top() + @types.sub_r + 4.0
  let hi_y = @types.arena_bottom() - @types.sub_r - 4.0
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
fn update_resources(game : @types.Game, dt : Float) -> Unit {
  let input_mag = @types.clampf(
    @types.sqrtf(game.move_x * game.move_x + game.move_y * game.move_y),
    0.0,
    1.0,
  )
  let boosting = game.boost_hold && game.fuel > 0.0
  let mut fuel_drain = @types.fuel_idle_drain +
    input_mag * @types.fuel_move_drain
  if boosting {
    fuel_drain = fuel_drain + @types.fuel_boost_drain
  }
  game.fuel = game.fuel - fuel_drain * dt
  let mut oxygen_delta = -@types.oxygen_base_drain
  if @types.in_hot_zone_xy(game.sub_x, game.sub_y) {
    oxygen_delta = oxygen_delta - @types.oxygen_hot_drain
  }
  if boosting {
    oxygen_delta = oxygen_delta - @types.oxygen_boost_drain
  }
  if game.sub_y <= @types.surface_band_y {
    oxygen_delta = oxygen_delta + @types.oxygen_surface_recover
  }
  game.oxygen = game.oxygen + oxygen_delta * dt
  game.oxygen = @types.clampf(game.oxygen, 0.0, @types.oxygen_max)
  game.fuel = @types.clampf(game.fuel, 0.0, @types.fuel_max)
  game.hull = @types.clampf(game.hull, 0.0, @types.hull_max)
}

///|
fn update_contacts(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.target_goal {
    if not(game.targets[i].active) {
      continue
    }
    if game.targets[i].pulse_t > 0.0 {
      game.targets[i].pulse_t = @types.maxf(
        0.0,
        game.targets[i].pulse_t - dt,
      )
    }
  }
  for i in 0..<game.mine_count {
    if not(game.mines[i].active) {
      continue
    }
    if game.mines[i].reveal_t > 0.0 {
      game.mines[i].reveal_t = @types.maxf(0.0, game.mines[i].reveal_t - dt)
    }
    if not(game.mines[i].armed) {
      continue
    }
    let hit_r = @types.sub_r + game.mines[i].r
    if @types.dist2(game.sub_x, game.sub_y, game.mines[i].x, game.mines[i].y) <=
      hit_r * hit_r {
      game.mines[i].armed = false
      game.mines[i].reveal_t = 2.4
      game.hull = game.hull - @types.mine_damage_hull
      game.oxygen = game.oxygen - @types.mine_damage_oxygen
      game.fuel = game.fuel - @types.mine_damage_fuel
      game.shake_t = 0.36
      let dx = game.sub_x - game.mines[i].x
      let dy = game.sub_y - game.mines[i].y
      let n = @types.sqrtf(@types.maxf(dx * dx + dy * dy, 0.001))
      game.sub_vx = game.sub_vx + dx / n * 180.0
      game.sub_vy = game.sub_vy + dy / n * 180.0
    }
  }
}

///|
fn resolve_round_state(game : @types.Game) -> Unit {
  if game.targets_found >= game.target_goal {
    game.state = @types.state_win
    game.lose_reason = @types.lose_none
    let unlock = @types.clampi(
      game.mission + 1,
      @types.mission_min,
      @types.mission_max,
    )
    if unlock > game.best_mission {
      game.best_mission = unlock
    }
    reset_controls(game)
    return
  }
  if game.hull <= 0.0 {
    game.state = @types.state_lose
    game.lose_reason = @types.lose_hull
    reset_controls(game)
    return
  }
  if game.oxygen <= 0.0 {
    game.state = @types.state_lose
    game.lose_reason = @types.lose_oxygen
    reset_controls(game)
    return
  }
  if game.fuel <= 0.0 {
    game.state = @types.state_lose
    game.lose_reason = @types.lose_fuel
    reset_controls(game)
  }
}

///|
fn update_play_state(game : @types.Game, dt : Float) -> Unit {
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
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  let d = @types.clampf(dt, 0.0, 0.05)

  // Read mouse/touch state into game struct
  game.mouse_x = Float::from_int(@raylib.get_mouse_x())
  game.mouse_y = Float::from_int(@raylib.get_mouse_y())
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  // Process input based on current state
  if game.state == @types.state_title {
    update_title_input(game)
  } else if game.state == @types.state_play {
    update_play_input(game)
  } else {
    update_result_input(game)
  }

  game.time_s = game.time_s + d
  if game.touch_cd > 0.0 {
    game.touch_cd = @types.maxf(0.0, game.touch_cd - d)
  }
  if game.shake_t > 0.0 {
    game.shake_t = @types.maxf(0.0, game.shake_t - d)
  }
  update_sonar_wave(game, d)
  if game.state == @types.state_play {
    update_play_state(game, d)
  }
}
