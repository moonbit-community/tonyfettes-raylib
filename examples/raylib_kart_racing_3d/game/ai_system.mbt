// AI kart behavior

///|
pub fn update_ai_karts(game : @types.Game, dt : Float) -> Unit {
  let player = game.karts[@types.player_kart]
  let player_progress = player.total_progress
  for i in 1..<@types.max_karts {
    let kart = game.karts[i]
    if not(kart.active) || kart.finished {
      continue
    }
    // Update timers
    update_ai_timers(kart, dt)
    // Stun/spin handling
    if kart.spin_timer > 0.0 {
      kart.spin_timer -= dt
      kart.angle = kart.angle + 8.0 * dt
      kart.speed = kart.speed * (1.0 - 2.0 * dt)
      if kart.speed < 0.0 {
        kart.speed = 0.0
      }
      apply_kart_physics(game, i, dt)
      continue
    }
    if kart.stunned_timer > 0.0 {
      kart.stunned_timer -= dt
      kart.speed = kart.speed * (1.0 - 3.0 * dt)
      apply_kart_physics(game, i, dt)
      continue
    }
    // Determine target waypoint (look ahead based on difficulty)
    let wc = game.waypoint_count
    if wc < 2 {
      continue
    }
    let diff_stats = @types.ai_difficulty_stats[@types.clampi(
        kart.ai_difficulty,
        0,
        3,
      )]
    let look_ahead : Int = 2 + (diff_stats.2 * 2.0).to_int()
    let target_wp_idx = (kart.waypoint_idx + look_ahead) % wc
    let target_wp = @types.get_waypoint(game, target_wp_idx)
    // Apply racing line offset for more natural movement
    let perp = @types.get_track_perpendicular(game, kart.waypoint_idx)
    let line_offset = kart.ai_line_offset * diff_stats.2
    let target_x = target_wp.x + perp.0 * line_offset
    let target_z = target_wp.z + perp.1 * line_offset
    // Steering towards target with reaction delay
    let dx = target_x - kart.x
    let dz = target_z - kart.z
    let target_angle = @math.atan2f(dx, dz)
    let angle_delta = @types.angle_diff(kart.angle, target_angle)
    // Smooth steering with difficulty-based accuracy
    let steer_strength : Float = 3.0 * diff_stats.2
    let handling = @types.get_kart_handling(kart)
    let target_steer = @types.clampf(
      angle_delta * steer_strength,
      -handling,
      handling,
    )
    // Reaction time - lerp towards target steer
    let reaction = @types.clampf(1.0 - diff_stats.3 * 0.3, 0.2, 1.0)
    kart.steer = @types.lerpf(kart.steer, target_steer, reaction)
    // AI drift logic - better AI drifts on sharp turns
    let should_drift = @types.absf(angle_delta) > 0.8 &&
      kart.speed > 12.0 &&
      diff_stats.2 > 0.7
    if should_drift {
      if not(kart.drift_left) && not(kart.drift_right) {
        if angle_delta > 0.0 {
          kart.drift_left = true
        } else {
          kart.drift_right = true
        }
        kart.drift_timer = 0.0
        kart.drift_level = @types.drift_level_none
      }
      kart.drift_timer += dt
      kart.drift_level = @types.calc_drift_level(kart.drift_timer)
    } else {
      // Release drift for boost
      if kart.drift_level > @types.drift_level_none {
        let drift_mult = @types.get_kart_drift_boost_mult(kart)
        let boost_power = @types.get_drift_boost_power(kart.drift_level) *
          drift_mult
        let boost_dur = @types.get_drift_boost_duration(kart.drift_level)
        kart.boost_timer = boost_dur
        kart.boost_power = boost_power
      }
      kart.drift_left = false
      kart.drift_right = false
      kart.drift_timer = 0.0
      kart.drift_level = @types.drift_level_none
    }
    // AI braking for sharp turns ahead
    let next_seg_idx = (kart.waypoint_idx + 1) % wc
    let next_wp = @types.get_waypoint(game, next_seg_idx)
    let next_next_wp = @types.get_waypoint(game, (next_seg_idx + 1) % wc)
    let next_angle = @math.atan2f(
      next_next_wp.x - next_wp.x,
      next_next_wp.z - next_wp.z,
    )
    let cur_track_angle = @math.atan2f(
      next_wp.x - @types.get_waypoint(game, kart.waypoint_idx).x,
      next_wp.z - @types.get_waypoint(game, kart.waypoint_idx).z,
    )
    let upcoming_turn = @types.absf(
      @types.angle_diff(cur_track_angle, next_angle),
    )
    // Rubber-banding: AI adjusts speed based on relative position to player
    let ai_progress = kart.total_progress
    let speed_mult = @types.calc_rubber_band_mult(
      ai_progress,
      player_progress,
      kart.ai_difficulty,
    )
    // Calculate target speed
    let kart_max = @types.get_kart_max_speed(kart)
    let mut target_speed = kart_max * speed_mult
    // Slow down for sharp turns
    if upcoming_turn > 1.0 && diff_stats.2 > 0.5 {
      let turn_slow : Float = 1.0 - (upcoming_turn - 1.0) * 0.3
      target_speed = target_speed * @types.clampf(turn_slow, 0.5, 1.0)
    }
    // Acceleration
    let kart_accel_stat = @types.get_kart_accel(kart)
    if kart.speed < target_speed {
      kart.speed = kart.speed + kart_accel_stat * 0.9 * dt
    } else {
      kart.speed = kart.speed - @types.kart_friction * 0.5 * dt
    }
    kart.speed = @types.clampf(kart.speed, 0.0, kart_max * 1.15)
    // Boost timer
    if kart.boost_timer > 0.0 {
      kart.boost_timer -= dt
    }
    // Shield timer
    if kart.shield_timer > 0.0 {
      kart.shield_timer -= dt
    }
    // AI item usage strategy
    ai_use_item(game, i, dt)
    // Slight random variation for natural movement
    if game.frame_counter % 60 == i {
      kart.steer = kart.steer + @types.rand_rangef(game, -0.15, 0.15)
      // Occasionally update racing line offset
      kart.ai_line_offset = @types.rand_rangef(game, -2.0, 2.0)
    }
    // Jump ramp detection
    if kart.on_ground && @types.is_on_ramp(game, kart) && kart.speed > 8.0 {
      kart.vy = @types.jump_ramp_force
      kart.on_ground = false
      kart.air_timer = 0.0
    }
    apply_kart_physics(game, i, dt)
  }
}

///|
fn update_ai_timers(kart : @types.Kart, dt : Float) -> Unit {
  if kart.bounce_timer > 0.0 {
    kart.bounce_timer -= dt
  }
  if kart.invincible_timer > 0.0 && kart.star_timer <= 0.0 {
    kart.invincible_timer -= dt
  }
  if kart.lightning_timer > 0.0 {
    kart.lightning_timer -= dt
  }
  if kart.star_timer > 0.0 {
    kart.star_timer -= dt
    kart.invincible_timer = kart.star_timer
  }
  if not(kart.on_ground) {
    kart.air_timer += dt
  } else {
    kart.air_timer = 0.0
  }
}

// AI item usage strategy

///|
fn ai_use_item(game : @types.Game, kart_idx : Int, dt : Float) -> Unit {
  let kart = game.karts[kart_idx]
  if kart.held_powerup == @types.powerup_none {
    return
  }
  kart.ai_use_item_timer -= dt
  if kart.ai_use_item_timer > 0.0 {
    return
  }
  let diff_stats = @types.ai_difficulty_stats[@types.clampi(
      kart.ai_difficulty,
      0,
      3,
    )]
  let item = kart.held_powerup
  let should_use : Bool = if item == @types.powerup_boost ||
    item == @types.powerup_triple_mushroom {
    // Use boost anytime (not in sharp turn)
    let wc = game.waypoint_count
    let next_wp = @types.get_waypoint(game, (kart.waypoint_idx + 1) % wc)
    let dx = next_wp.x - kart.x
    let dz = next_wp.z - kart.z
    let turn = @types.absf(@types.angle_diff(kart.angle, @math.atan2f(dx, dz)))
    turn < 0.5
  } else if item == @types.powerup_shield {
    // Use shield when in danger (near opponents)
    has_nearby_opponent(game, kart_idx, 15.0)
  } else if item == @types.powerup_missile {
    // Fire when someone is ahead and fairly close
    let target = @types.find_target_ahead(game, kart_idx)
    if target >= 0 {
      @types.distance2d(
        kart.x,
        kart.z,
        game.karts[target].x,
        game.karts[target].z,
      ) <
      30.0
    } else {
      false
    }
  } else if item == @types.powerup_oil_slick || item == @types.powerup_banana {
    // Drop behind when someone is close behind
    has_nearby_opponent_behind(game, kart_idx, 10.0)
  } else if item == @types.powerup_lightning {
    // Use when in lower positions
    kart.place >= 4
  } else if item == @types.powerup_star {
    // Use when near opponents to ram them
    has_nearby_opponent(game, kart_idx, 12.0) || kart.place >= 3
  } else {
    true
  }
  if should_use {
    use_powerup(game, kart_idx)
    let reaction_base = diff_stats.3
    kart.ai_use_item_timer = @types.rand_rangef(
      game,
      2.0 + reaction_base,
      5.0 + reaction_base * 2.0,
    )
  } else {
    kart.ai_use_item_timer = 1.0
  }
}

// Check if any opponent is nearby

///|
fn has_nearby_opponent(
  game : @types.Game,
  kart_idx : Int,
  range : Float,
) -> Bool {
  let kart = game.karts[kart_idx]
  for i in 0..<@types.max_karts {
    if i == kart_idx {
      continue
    }
    let other = game.karts[i]
    if not(other.active) || other.finished {
      continue
    }
    if @types.distance2d(kart.x, kart.z, other.x, other.z) < range {
      return true
    }
  }
  false
}

// Check if any opponent is nearby behind

///|
fn has_nearby_opponent_behind(
  game : @types.Game,
  kart_idx : Int,
  range : Float,
) -> Bool {
  let kart = game.karts[kart_idx]
  for i in 0..<@types.max_karts {
    if i == kart_idx {
      continue
    }
    let other = game.karts[i]
    if not(other.active) || other.finished {
      continue
    }
    if other.total_progress >= kart.total_progress {
      continue
    }
    if @types.distance2d(kart.x, kart.z, other.x, other.z) < range {
      return true
    }
  }
  false
}
