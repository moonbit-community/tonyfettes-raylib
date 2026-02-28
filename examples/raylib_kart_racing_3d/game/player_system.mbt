// Player kart physics and input

///|
pub fn update_player_kart(game : @types.Game, dt : Float) -> Unit {
  let kart = game.karts[@types.player_kart]
  if not(kart.active) || kart.finished {
    return
  }
  // Update timers
  update_kart_timers(kart, dt)
  // Stun/spin handling
  if kart.spin_timer > 0.0 {
    kart.spin_timer -= dt
    kart.angle = kart.angle + 8.0 * dt
    kart.speed = kart.speed * (1.0 - 2.0 * dt)
    if kart.speed < 0.0 {
      kart.speed = 0.0
    }
    apply_kart_physics(game, @types.player_kart, dt)
    return
  }
  if kart.stunned_timer > 0.0 {
    kart.stunned_timer -= dt
    kart.speed = kart.speed * (1.0 - 3.0 * dt)
    if kart.speed < 0.0 {
      kart.speed = 0.0
    }
    apply_kart_physics(game, @types.player_kart, dt)
    return
  }
  // Acceleration / braking
  let mut accel : Float = 0.0
  let kart_accel_stat = @types.get_kart_accel(kart)
  if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
    accel = kart_accel_stat
  }
  if @raylib.is_key_down(@raylib.KeyDown) || @raylib.is_key_down(@raylib.KeyS) {
    accel = -@types.kart_brake
  }
  // Steering
  let mut steer_input : Float = 0.0
  if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
    steer_input = 1.0
  }
  if @raylib.is_key_down(@raylib.KeyRight) || @raylib.is_key_down(@raylib.KeyD) {
    steer_input = -1.0
  }
  // Drift mechanic (left shift or Z/X)
  let drift_key = @raylib.is_key_down(@raylib.KeyLeftShift) ||
    @raylib.is_key_down(@raylib.KeyZ) ||
    @raylib.is_key_down(@raylib.KeyX)
  let drifting = drift_key &&
    @types.absf(steer_input) > 0.01 &&
    kart.speed > 5.0
  if drifting {
    if not(kart.drift_left) && not(kart.drift_right) {
      // Initiate drift
      if steer_input > 0.0 {
        kart.drift_left = true
      } else {
        kart.drift_right = true
      }
      kart.drift_timer = 0.0
      kart.drift_level = @types.drift_level_none
      kart.drift_angle = 0.0
    }
    kart.drift_timer += dt
    // Update drift level based on accumulated time
    let new_level = @types.calc_drift_level(kart.drift_timer)
    if new_level > kart.drift_level {
      kart.drift_level = new_level
      // Emit level-up particles
      let dc = @types.get_drift_spark_color(new_level)
      @types.spawn_particles(
        game,
        kart.x,
        kart.y + 0.3,
        kart.z,
        8,
        dc.0,
        dc.1,
        dc.2,
      )
    }
    // Build drift angle
    let drift_dir : Float = if kart.drift_left { 0.3 } else { -0.3 }
    kart.drift_angle = @types.lerpf(kart.drift_angle, drift_dir, dt * 3.0)
    // Emit drift sparks based on level
    if kart.drift_level > @types.drift_level_none && game.frame_counter % 3 == 0 {
      let dc = @types.get_drift_spark_color(kart.drift_level)
      let sin_a = @math.sinf(kart.angle)
      let cos_a = @math.cosf(kart.angle)
      let spark_side : Float = if kart.drift_left { 1.0 } else { -1.0 }
      let sx = kart.x -
        sin_a * @types.kart_length * 0.4 +
        cos_a * spark_side * @types.kart_width * 0.5
      let sz = kart.z -
        cos_a * @types.kart_length * 0.4 -
        sin_a * spark_side * @types.kart_width * 0.5
      @types.spawn_typed_particles(
        game,
        @types.particle_drift_spark,
        sx,
        kart.y + 0.1,
        sz,
        2,
        dc.0,
        dc.1,
        dc.2,
        0.06,
        0.2,
      )
    }
  } else {
    // Release drift = boost based on level
    if kart.drift_level > @types.drift_level_none {
      let drift_mult = @types.get_kart_drift_boost_mult(kart)
      let boost_power = @types.get_drift_boost_power(kart.drift_level) *
        drift_mult
      let boost_dur = @types.get_drift_boost_duration(kart.drift_level)
      kart.boost_timer = boost_dur
      kart.boost_power = boost_power
      let dc = @types.get_drift_spark_color(kart.drift_level)
      @types.spawn_particles(
        game,
        kart.x,
        kart.y + 0.2,
        kart.z,
        12,
        dc.0,
        dc.1,
        dc.2,
      )
    }
    kart.drift_left = false
    kart.drift_right = false
    kart.drift_timer = 0.0
    kart.drift_level = @types.drift_level_none
    kart.drift_angle = @types.lerpf(kart.drift_angle, 0.0, dt * 5.0)
  }
  // Apply steering
  let handling = @types.get_kart_handling(kart)
  let steer_mult : Float = if kart.drift_left || kart.drift_right {
    @types.drift_steer_mult
  } else {
    1.0
  }
  let air_mult : Float = if kart.on_ground {
    1.0
  } else {
    @types.air_steer_mult
  }
  let speed_steer_factor = @types.clampf(kart.speed / 10.0, 0.3, 1.0)
  kart.steer = steer_input *
    handling *
    steer_mult *
    speed_steer_factor *
    air_mult
  // Apply acceleration
  let effective_max = @types.get_kart_max_speed(kart)
  kart.speed = kart.speed + accel * dt
  // Friction
  let friction_mult : Float = if kart.drift_left || kart.drift_right {
    @types.drift_friction_mult
  } else {
    1.0
  }
  if @types.absf(accel) < 0.01 {
    let friction = @types.kart_friction * friction_mult
    if kart.speed > 0.0 {
      kart.speed = kart.speed - friction * dt
      if kart.speed < 0.0 {
        kart.speed = 0.0
      }
    } else if kart.speed < 0.0 {
      kart.speed = kart.speed + friction * dt
      if kart.speed > 0.0 {
        kart.speed = 0.0
      }
    }
  }
  kart.speed = @types.clampf(kart.speed, -effective_max * 0.3, effective_max)
  // Use powerup
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    use_powerup(game, @types.player_kart)
  }
  // Boost timer
  if kart.boost_timer > 0.0 {
    kart.boost_timer -= dt
    // Spawn boost particles
    if game.frame_counter % 3 == 0 {
      @types.spawn_typed_particles(
        game,
        @types.particle_boost_flame,
        kart.x,
        kart.y + 0.1,
        kart.z,
        2,
        255,
        150,
        30,
        0.06,
        0.3,
      )
    }
  }
  // Shield timer
  if kart.shield_timer > 0.0 {
    kart.shield_timer -= dt
  }
  // Jump ramp detection
  if kart.on_ground && @types.is_on_ramp(game, kart) && kart.speed > 8.0 {
    kart.vy = @types.jump_ramp_force
    kart.on_ground = false
    kart.air_timer = 0.0
    @types.spawn_particles(game, kart.x, kart.y, kart.z, 6, 255, 255, 200)
  }
  apply_kart_physics(game, @types.player_kart, dt)
}

// Update common kart timers

///|
fn update_kart_timers(kart : @types.Kart, dt : Float) -> Unit {
  if kart.bounce_timer > 0.0 {
    kart.bounce_timer -= dt
  }
  if kart.invincible_timer > 0.0 && kart.star_timer <= 0.0 {
    kart.invincible_timer -= dt
  }
  if kart.lightning_timer > 0.0 {
    kart.lightning_timer -= dt
  }
  if not(kart.on_ground) {
    kart.air_timer += dt
  } else {
    kart.air_timer = 0.0
  }
}

// Apply physics movement for any kart

///|
pub fn apply_kart_physics(
  game : @types.Game,
  kart_idx : Int,
  dt : Float,
) -> Unit {
  let kart = game.karts[kart_idx]
  // Steering rotates the kart (add drift angle)
  let total_steer = kart.steer + kart.drift_angle
  kart.angle = kart.angle + total_steer * dt
  kart.angle = @types.normalize_angle(kart.angle)
  // Move in facing direction
  let move_x = @math.sinf(kart.angle) * kart.speed * dt
  let move_z = @math.cosf(kart.angle) * kart.speed * dt
  kart.x = kart.x + move_x
  kart.z = kart.z + move_z
  // Gravity and ground
  let ground_y = get_ground_height(game, kart.x, kart.z)
  // Add ramp height
  let effective_ground : Float = if @types.is_on_ramp(game, kart) {
    let seg = @types.get_segment(game, kart.waypoint_idx)
    ground_y + seg.ramp_height * kart.waypoint_progress
  } else {
    ground_y
  }
  if kart.y <= effective_ground {
    // Landing bounce
    if not(kart.on_ground) && kart.air_timer > 0.3 {
      kart.bounce_timer = 0.2
      @types.spawn_particles(game, kart.x, kart.y, kart.z, 4, 200, 200, 200)
    }
    kart.y = effective_ground
    kart.vy = 0.0
    kart.on_ground = true
  } else {
    kart.vy = kart.vy - @types.gravity * dt
    kart.y = kart.y + kart.vy * dt
    if kart.y < effective_ground {
      if not(kart.on_ground) && kart.air_timer > 0.3 {
        kart.bounce_timer = 0.2
      }
      kart.y = effective_ground
      kart.vy = 0.0
      kart.on_ground = true
    } else {
      kart.on_ground = false
    }
  }
  // Keep karts from going too far off track
  clamp_kart_to_track_bounds(game, kart_idx)
}

///|
fn clamp_kart_to_track_bounds(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  let wc = game.waypoint_count
  if wc < 2 {
    return
  }
  // Find nearest waypoint segment
  let mut best_dist : Float = 99999.0
  let mut best_seg = 0
  for i = 0; i < wc; i = i + 1 {
    let wp = game.waypoints[i]
    let d = @types.distance2d(kart.x, kart.z, wp.x, wp.z)
    if d < best_dist {
      best_dist = d
      best_seg = i
    }
  }
  // Get segment width multiplier
  let seg = game.segments[best_seg]
  let track_width = @types.road_width * seg.width_mult
  // Check distance from track center line
  let max_dist = track_width * 2.5
  if best_dist > max_dist {
    // Push kart back towards track
    let wp = game.waypoints[best_seg]
    let dx = wp.x - kart.x
    let dz = wp.z - kart.z
    let d = @types.distance2d(kart.x, kart.z, wp.x, wp.z)
    if d > 0.01 {
      let push = (best_dist - max_dist) * 0.5
      kart.x = kart.x + dx / d * push
      kart.z = kart.z + dz / d * push
    }
    // Slow down when off track
    kart.speed = kart.speed * 0.95
  }
}

// Use held powerup

///|
pub fn use_powerup(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  if kart.held_powerup == @types.powerup_none {
    return
  }
  let item = kart.held_powerup
  if item == @types.powerup_boost {
    kart.boost_timer = @types.boost_duration
    kart.boost_power = @types.boost_speed_add
    @types.spawn_particles(game, kart.x, kart.y + 0.3, kart.z, 10, 255, 200, 0)
  } else if item == @types.powerup_shield {
    kart.shield_timer = @types.shield_duration
    @types.spawn_particles(game, kart.x, kart.y + 0.5, kart.z, 8, 100, 200, 255)
  } else if item == @types.powerup_missile {
    fire_missile(game, kart_idx)
  } else if item == @types.powerup_oil_slick {
    drop_item(game, kart_idx, @types.powerup_oil_slick)
  } else if item == @types.powerup_lightning {
    activate_lightning(game, kart_idx)
  } else if item == @types.powerup_star {
    kart.star_timer = @types.star_duration
    kart.invincible_timer = @types.star_duration
    @types.spawn_particles(
      game,
      kart.x,
      kart.y + 0.5,
      kart.z,
      15,
      255,
      255,
      100,
    )
  } else if item == @types.powerup_banana {
    drop_item(game, kart_idx, @types.powerup_banana)
  } else if item == @types.powerup_triple_mushroom {
    kart.boost_timer = @types.triple_mushroom_boost
    kart.boost_power = @types.boost_speed_add
    kart.item_count = 2 // 2 more uses remaining
    @types.spawn_particles(
      game,
      kart.x,
      kart.y + 0.3,
      kart.z,
      10,
      255,
      150,
      200,
    )
    // Don't clear the item - it has remaining uses
    return
  }
  // Handle triple mushroom remaining uses
  if kart.held_powerup == @types.powerup_triple_mushroom && kart.item_count > 0 {
    kart.item_count -= 1
    if kart.item_count <= 0 {
      kart.held_powerup = @types.powerup_none
      kart.item_count = 0
    }
    return
  }
  kart.held_powerup = @types.powerup_none
  kart.item_count = 0
}

///|
fn fire_missile(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let proj = game.projectiles[idx]
  proj.active = true
  proj.x = kart.x + @math.sinf(kart.angle) * 1.5
  proj.y = kart.y + 0.5
  proj.z = kart.z + @math.cosf(kart.angle) * 1.5
  proj.angle = kart.angle
  proj.speed = @types.missile_speed
  proj.owner = kart_idx
  proj.life = 5.0
  // Find and set homing target
  proj.target_kart = @types.find_target_ahead(game, kart_idx)
  proj.homing_strength = 2.5
  @types.spawn_particles(game, proj.x, proj.y, proj.z, 5, 255, 100, 50)
}

///|
fn drop_item(game : @types.Game, kart_idx : Int, item_type : Int) -> Unit {
  let kart = game.karts[kart_idx]
  let idx = @types.alloc_dropped_item(game)
  if idx < 0 {
    return
  }
  let item = game.dropped_items[idx]
  item.active = true
  item.item_type = item_type
  // Drop behind the kart
  item.x = kart.x - @math.sinf(kart.angle) * 2.0
  item.y = kart.y + 0.1
  item.z = kart.z - @math.cosf(kart.angle) * 2.0
  item.owner = kart_idx
  item.rotation = 0.0
  if item_type == @types.powerup_banana {
    item.lifetime = @types.banana_lifetime
  } else {
    item.lifetime = @types.oil_slick_lifetime
  }
  @types.spawn_particles(game, item.x, item.y + 0.2, item.z, 4, 200, 200, 100)
}

///|
fn activate_lightning(game : @types.Game, source_kart : Int) -> Unit {
  game.lightning_active = true
  game.lightning_timer = @types.lightning_duration
  game.lightning_source = source_kart
  // Hit all other karts
  for i = 0; i < @types.max_karts; i = i + 1 {
    if i == source_kart {
      continue i + 1
    }
    let kart = game.karts[i]
    if not(kart.active) || kart.finished {
      continue i + 1
    }
    if kart.star_timer > 0.0 || kart.invincible_timer > 0.0 {
      continue i + 1
    }
    kart.lightning_timer = @types.lightning_duration
    kart.spin_timer = @types.lightning_spin_duration
    kart.speed = kart.speed * 0.5
    @types.spawn_typed_particles(
      game,
      @types.particle_lightning,
      kart.x,
      kart.y + 1.0,
      kart.z,
      6,
      255,
      255,
      100,
      0.08,
      0.5,
    )
  }
  // Visual effect
  @types.spawn_typed_particles(
    game,
    @types.particle_lightning,
    game.karts[source_kart].x,
    game.karts[source_kart].y + 2.0,
    game.karts[source_kart].z,
    10,
    255,
    255,
    200,
    0.1,
    0.6,
  )
}

// Kart-kart collisions with weight-based bumping

///|
pub fn check_kart_collisions(game : @types.Game) -> Unit {
  for i = 0; i < @types.max_karts; i = i + 1 {
    let ka = game.karts[i]
    if not(ka.active) {
      continue i + 1
    }
    for j = i + 1; j < @types.max_karts; j = j + 1 {
      let kb = game.karts[j]
      if not(kb.active) {
        continue j + 1
      }
      let dx = kb.x - ka.x
      let dz = kb.z - ka.z
      let dist = @types.distance2d(ka.x, ka.z, kb.x, kb.z)
      let min_dist : Float = 1.4
      if dist < min_dist && dist > 0.01 {
        // Push apart based on weight
        let weight_a = @types.get_kart_weight(ka)
        let weight_b = @types.get_kart_weight(kb)
        let forces = @types.calc_bump_force(weight_a, weight_b)
        let overlap = min_dist - dist
        let nx = dx / dist
        let nz = dz / dist
        ka.x = ka.x - nx * overlap * forces.0
        ka.z = ka.z - nz * overlap * forces.0
        kb.x = kb.x + nx * overlap * forces.1
        kb.z = kb.z + nz * overlap * forces.1
        // Speed exchange weighted by mass
        let avg_speed = (ka.speed * weight_a + kb.speed * weight_b) /
          (weight_a + weight_b)
        ka.speed = @types.lerpf(ka.speed, avg_speed, 0.3)
        kb.speed = @types.lerpf(kb.speed, avg_speed, 0.3)
        // Check for spin from weight difference
        let spins = @types.should_spin_from_bump(weight_a, weight_b)
        if spins.0 && ka.spin_timer <= 0.0 && ka.invincible_timer <= 0.0 {
          if ka.shield_timer > 0.0 {
            ka.shield_timer = 0.0
          } else {
            ka.spin_timer = @types.bump_spin_threshold
          }
        }
        if spins.1 && kb.spin_timer <= 0.0 && kb.invincible_timer <= 0.0 {
          if kb.shield_timer > 0.0 {
            kb.shield_timer = 0.0
          } else {
            kb.spin_timer = @types.bump_spin_threshold
          }
        }
        // Star kart instantly spins the other
        if ka.star_timer > 0.0 && kb.spin_timer <= 0.0 {
          if kb.shield_timer > 0.0 {
            kb.shield_timer = 0.0
          } else {
            kb.spin_timer = @types.spin_duration
            kb.speed = kb.speed * 0.3
          }
          @types.spawn_particles(
            game,
            kb.x,
            kb.y + 0.5,
            kb.z,
            10,
            255,
            255,
            100,
          )
        }
        if kb.star_timer > 0.0 && ka.spin_timer <= 0.0 {
          if ka.shield_timer > 0.0 {
            ka.shield_timer = 0.0
          } else {
            ka.spin_timer = @types.spin_duration
            ka.speed = ka.speed * 0.3
          }
          @types.spawn_particles(
            game,
            ka.x,
            ka.y + 0.5,
            ka.z,
            10,
            255,
            255,
            100,
          )
        }
      }
    }
  }
}
