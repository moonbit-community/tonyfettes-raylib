// Player movement, physics, and platform interaction

fn update_player(game : @types.Game, dt : Float) -> Unit {
  // Input
  let mut input_x : Float = 0.0
  let mut input_z : Float = 0.0
  if @raylib.is_key_down(@raylib.KeyW) || @raylib.is_key_down(@raylib.KeyUp) {
    input_z -= 1.0
  }
  if @raylib.is_key_down(@raylib.KeyS) || @raylib.is_key_down(@raylib.KeyDown) {
    input_z += 1.0
  }
  if @raylib.is_key_down(@raylib.KeyA) || @raylib.is_key_down(@raylib.KeyLeft) {
    input_x -= 1.0
  }
  if @raylib.is_key_down(@raylib.KeyD) || @raylib.is_key_down(@raylib.KeyRight) {
    input_x += 1.0
  }
  // Rotate input by camera angle
  let angle_rad = game.cam_angle * @types.deg2rad
  let cos_a = @math.cosf(angle_rad)
  let sin_a = @math.sinf(angle_rad)
  let rx = input_x * cos_a - input_z * sin_a
  let rz = input_x * sin_a + input_z * cos_a
  // Normalize input
  let input_len = (rx * rx + rz * rz).sqrt()
  let mut nx = rx
  let mut nz = rz
  if input_len > 0.01 {
    nx = rx / input_len
    nz = rz / input_len
    // Update facing direction
    game.facing_x = nx
    game.facing_z = nz
  }

  // Dash mechanic
  if @raylib.is_key_pressed(@raylib.KeyLeftShift) && game.dash_cooldown_timer <= 0.0 && not(game.dashing) {
    if input_len > 0.01 {
      game.dashing = true
      game.dash_timer = @types.dash_duration
      game.dash_cooldown_timer = @types.dash_cooldown
      game.dash_dir_x = nx
      game.dash_dir_z = nz
      @types.spawn_particles_dir(
        game, game.px, game.py, game.pz,
        @types.particle_dash_count, -nx * 3.0, 0.5, -nz * 3.0,
        1.5, @types.player_body_r, @types.player_body_g, @types.player_body_b,
      )
    }
  }

  // Apply dash movement
  if game.dashing {
    game.dash_timer -= dt
    if game.dash_timer <= 0.0 {
      game.dashing = false
    } else {
      game.vx = game.dash_dir_x * @types.dash_speed
      game.vz = game.dash_dir_z * @types.dash_speed
      game.vy = 0.0
      // Skip normal movement during dash
      game.px += game.vx * dt
      game.py += game.vy * dt
      game.pz += game.vz * dt
      game.grounded = false
      game.on_ice = false
      resolve_platform_collisions(game)
      // Dash trail particles
      if game.frame_counter % 2 == 0 {
        @types.spawn_particles_dir(
          game, game.px, game.py, game.pz,
          1, -game.vx * 0.2, 0.5, -game.vz * 0.2,
          0.5, @types.player_body_r, @types.player_body_g, @types.player_body_b,
        )
      }
      return
    }
  }

  // Apply movement
  let speed_mult : Float = if game.powerup_type == @types.powerup_speed { @types.powerup_speed_mult } else { 1.0 }
  let base_accel : Float = @types.move_speed * speed_mult
  let accel : Float = if game.grounded { base_accel } else { base_accel * @types.air_control }
  let friction : Float = if game.on_ice {
    @types.ice_friction
  } else if game.grounded {
    @types.ground_friction
  } else {
    @types.air_friction
  }
  game.vx = game.vx * friction + nx * accel * dt * @types.player_accel_mult
  game.vz = game.vz * friction + nz * accel * dt * @types.player_accel_mult

  // Conveyor belt force
  apply_conveyor_force(game, dt)

  // Clamp horizontal speed
  let hspeed = (game.vx * game.vx + game.vz * game.vz).sqrt()
  let max_h_speed : Float = base_accel * 1.2
  if hspeed > max_h_speed {
    game.vx = game.vx / hspeed * max_h_speed
    game.vz = game.vz / hspeed * max_h_speed
  }

  // Walk animation
  if game.grounded && hspeed > 0.5 {
    game.anim_walk_timer += dt * hspeed * 2.0
  }

  // Jump buffering
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    game.jump_buffer_timer = @types.jump_buffer
  }
  if game.jump_buffer_timer > 0.0 {
    game.jump_buffer_timer -= dt
  }

  // Coyote time
  if game.grounded {
    game.coyote_timer = @types.coyote_time
    game.double_jumped = false
  } else {
    game.coyote_timer -= dt
  }

  // Wall slide detection
  game.wall_slide = false
  game.can_wall_jump = false
  if not(game.grounded) && game.vy < 0.0 {
    check_wall_slide(game)
  }

  // Jump
  if game.jump_buffer_timer > 0.0 && game.coyote_timer > 0.0 {
    // Normal jump
    game.vy = @types.jump_force
    game.grounded = false
    game.coyote_timer = 0.0
    game.jump_buffer_timer = 0.0
    game.anim_jump_stretch = 0.3
    @types.spawn_particles(game, game.px, game.py, game.pz, @types.particle_jump_count, 200, 200, 255)
  } else if game.jump_buffer_timer > 0.0 && game.can_wall_jump && game.wall_slide {
    // Wall jump
    game.vy = @types.wall_jump_v_force
    game.vx = game.wall_dir * @types.wall_jump_h_force
    game.grounded = false
    game.coyote_timer = 0.0
    game.jump_buffer_timer = 0.0
    game.wall_slide = false
    game.anim_jump_stretch = 0.3
    @types.spawn_particles_dir(
      game, game.px, game.py, game.pz,
      @types.particle_jump_count, game.wall_dir * 2.0, 1.0, 0.0,
      1.0, 200, 200, 255,
    )
  } else if game.jump_buffer_timer > 0.0 && game.has_double_jump && not(game.double_jumped) && not(game.grounded) && game.coyote_timer <= 0.0 {
    // Double jump
    game.vy = @types.double_jump_force
    game.double_jumped = true
    game.jump_buffer_timer = 0.0
    game.anim_jump_stretch = 0.25
    @types.spawn_particle_ring(
      game, game.px, game.py - 0.3, game.pz,
      8, 0.5, 1.5, 150, 200, 255,
    )
  }

  // Variable jump height
  if @raylib.is_key_released(@raylib.KeySpace) && game.vy > 0.0 {
    game.vy = game.vy * 0.5
  }

  // Wall sliding slow fall
  if game.wall_slide {
    if game.vy < -@types.wall_slide_speed {
      game.vy = -@types.wall_slide_speed
    }
    // Wall slide particles
    if game.frame_counter % 4 == 0 {
      @types.spawn_particles_dir(
        game, game.px - game.wall_dir * 0.3, game.py, game.pz,
        @types.particle_wall_slide_count, 0.0, -0.5, 0.0,
        0.3, 180, 180, 200,
      )
    }
  }

  // Gravity
  let grav_mult : Float = if game.powerup_type == @types.powerup_slow_fall && game.vy < 0.0 {
    @types.powerup_slow_fall_mult
  } else {
    1.0
  }
  game.vy -= @types.gravity * grav_mult * dt
  if game.vy < -@types.max_fall_speed {
    game.vy = -@types.max_fall_speed
  }

  // Apply velocity
  game.px += game.vx * dt
  game.py += game.vy * dt
  game.pz += game.vz * dt

  // Platform collision
  let was_grounded = game.grounded
  game.grounded = false
  game.on_ice = false
  resolve_platform_collisions(game)

  // Landing squash animation
  if game.grounded && not(was_grounded) && game.vy <= 0.0 {
    game.anim_land_squash = 0.3
    if game.vy < -5.0 {
      @types.spawn_particles(game, game.px, game.py - @types.player_height * 0.5, game.pz, @types.particle_landing_count, 180, 170, 150)
    }
  }

  // Decay animation timers
  if game.anim_land_squash > 0.0 {
    game.anim_land_squash -= dt * 4.0
    if game.anim_land_squash < 0.0 { game.anim_land_squash = 0.0 }
  }
  if game.anim_jump_stretch > 0.0 {
    game.anim_jump_stretch -= dt * 3.0
    if game.anim_jump_stretch < 0.0 { game.anim_jump_stretch = 0.0 }
  }

  // Magnet effect - pull collectibles toward player
  if game.powerup_type == @types.powerup_magnet {
    pull_collectibles_magnet(game, dt)
  }
}

fn check_wall_slide(game : @types.Game) -> Unit {
  let pr = @types.player_radius
  let ph = @types.player_height
  let check_dist : Float = 0.15
  // Check left and right walls
  for i = 0; i < game.platforms.length(); i = i + 1 {
    let plat = game.platforms[i]
    if not(plat.active) { continue i + 1 }
    if plat.kind == @types.plat_bouncy || plat.kind == @types.plat_ice { continue i + 1 }
    let b_min_x = plat.x - plat.w / 2.0
    let b_max_x = plat.x + plat.w / 2.0
    let b_min_y = plat.y - plat.h / 2.0
    let b_max_y = plat.y + plat.h / 2.0
    let b_min_z = plat.z - plat.d / 2.0
    let b_max_z = plat.z + plat.d / 2.0
    // Player must be vertically overlapping
    let p_min_y = game.py - ph / 2.0
    let p_max_y = game.py + ph / 2.0
    if p_max_y <= b_min_y || p_min_y >= b_max_y { continue i + 1 }
    // Check Z overlap
    if game.pz - pr >= b_max_z || game.pz + pr <= b_min_z { continue i + 1 }
    // Check left wall
    if game.px + pr + check_dist > b_min_x && game.px + pr < b_min_x + 0.2 {
      game.wall_slide = true
      game.can_wall_jump = true
      game.wall_dir = -1.0
      return
    }
    // Check right wall
    if game.px - pr - check_dist < b_max_x && game.px - pr > b_max_x - 0.2 {
      game.wall_slide = true
      game.can_wall_jump = true
      game.wall_dir = 1.0
      return
    }
  }
}

fn apply_conveyor_force(game : @types.Game, dt : Float) -> Unit {
  if not(game.grounded) { return }
  for i = 0; i < game.platforms.length(); i = i + 1 {
    let plat = game.platforms[i]
    if not(plat.active) { continue i + 1 }
    if plat.kind != @types.plat_conveyor_l && plat.kind != @types.plat_conveyor_r { continue i + 1 }
    // Check if player is on this platform
    let on_plat = game.px > plat.x - plat.w / 2.0 && game.px < plat.x + plat.w / 2.0 &&
    game.pz > plat.z - plat.d / 2.0 && game.pz < plat.z + plat.d / 2.0
    let py_check = @types.absf(game.py - @types.player_height / 2.0 - plat.y - plat.h / 2.0)
    if on_plat && py_check < 0.2 {
      let dir : Float = if plat.kind == @types.plat_conveyor_l { -1.0 } else { 1.0 }
      game.vx += dir * @types.conveyor_force * dt
    }
  }
}

fn pull_collectibles_magnet(game : @types.Game, dt : Float) -> Unit {
  let mag_range = @types.powerup_magnet_range
  for i = 0; i < game.collectibles.length(); i = i + 1 {
    let c = game.collectibles[i]
    if not(c.active) || c.collected { continue i + 1 }
    let dist = @types.dist3d(game.px, game.py, game.pz, c.x, c.y, c.z)
    if dist < mag_range && dist > 0.1 {
      let pull_speed : Float = 5.0 * dt
      let inv_dist : Float = 1.0 / dist
      c.x += (game.px - c.x) * inv_dist * pull_speed * (mag_range - dist)
      c.y += (game.py - c.y) * inv_dist * pull_speed * (mag_range - dist)
      c.z += (game.pz - c.z) * inv_dist * pull_speed * (mag_range - dist)
      c.magnet_target = true
    }
  }
}

fn resolve_platform_collisions(game : @types.Game) -> Unit {
  let pr = @types.player_radius
  let ph = @types.player_height
  for i = 0; i < game.platforms.length(); i = i + 1 {
    let plat = game.platforms[i]
    if not(plat.active) { continue i + 1 }
    // Phasing platforms
    if plat.kind == @types.plat_phasing && not(plat.phase_visible) { continue i + 1 }
    // AABB check: player as box centered at (px, py, pz) with size (pr*2, ph, pr*2)
    let p_min_x = game.px - pr
    let p_max_x = game.px + pr
    let p_min_y = game.py - ph / 2.0
    let p_max_y = game.py + ph / 2.0
    let p_min_z = game.pz - pr
    let p_max_z = game.pz + pr
    let b_min_x = plat.x - plat.w / 2.0
    let b_max_x = plat.x + plat.w / 2.0
    let b_min_y = plat.y - plat.h / 2.0
    let b_max_y = plat.y + plat.h / 2.0
    let b_min_z = plat.z - plat.d / 2.0
    let b_max_z = plat.z + plat.d / 2.0
    // Check overlap
    if p_max_x > b_min_x && p_min_x < b_max_x && p_max_y > b_min_y && p_min_y <
    b_max_y && p_max_z > b_min_z && p_min_z < b_max_z {
      // Determine push direction (smallest penetration)
      let pen_left = p_max_x - b_min_x
      let pen_right = b_max_x - p_min_x
      let pen_bottom = p_max_y - b_min_y
      let pen_top = b_max_y - p_min_y
      let pen_front = p_max_z - b_min_z
      let pen_back = b_max_z - p_min_z
      let min_pen_x = @types.minf(pen_left, pen_right)
      let min_pen_y = @types.minf(pen_bottom, pen_top)
      let min_pen_z = @types.minf(pen_front, pen_back)
      if min_pen_y <= min_pen_x && min_pen_y <= min_pen_z {
        // Vertical resolution
        if pen_bottom < pen_top {
          // Player on top of platform
          game.py = b_max_y + ph / 2.0
          if game.vy < 0.0 {
            // Handle special platform types
            if plat.kind == @types.plat_bouncy {
              game.vy = @types.bounce_force
              game.double_jumped = false
              @types.spawn_particles(
                game, game.px, game.py - ph / 2.0, game.pz, 8, 255, 200, 50,
              )
            } else {
              game.vy = 0.0
              game.grounded = true
            }
          }
          if plat.kind == @types.plat_ice { game.on_ice = true }
          // Falling platform trigger
          if plat.kind == @types.plat_falling && not(plat.touched) {
            plat.touched = true
            plat.fall_timer = @types.fall_delay
          }
          // Crumbling platform trigger
          if plat.kind == @types.plat_crumbling && not(plat.crumbling) {
            plat.crumbling = true
            plat.crumble_timer = @types.crumble_time
          }
          // Moving platform carry
          if plat.kind >= @types.plat_moving_x && plat.kind <= @types.plat_moving_z {
            carry_player_on_platform(game, plat)
          }
        } else {
          // Player hitting bottom
          game.py = b_min_y - ph / 2.0
          if game.vy > 0.0 { game.vy = 0.0 }
        }
      } else if min_pen_x <= min_pen_z {
        // Horizontal X resolution
        if pen_left < pen_right {
          game.px = b_min_x - pr
        } else {
          game.px = b_max_x + pr
        }
        game.vx = 0.0
      } else {
        // Horizontal Z resolution
        if pen_front < pen_back {
          game.pz = b_min_z - pr
        } else {
          game.pz = b_max_z + pr
        }
        game.vz = 0.0
      }
    }
  }
}

fn carry_player_on_platform(game : @types.Game, plat : @types.Platform) -> Unit {
  // Calculate platform velocity from its movement
  let speed = plat.move_speed
  let range = plat.move_range
  let cos_val = @math.cosf(plat.move_timer) * range * speed
  if plat.kind == @types.plat_moving_x {
    let plat_vel_x : Float = cos_val * 0.016
    game.px += plat_vel_x
  } else if plat.kind == @types.plat_moving_y {
    let plat_vel_y : Float = cos_val * 0.016
    game.py += plat_vel_y
  } else if plat.kind == @types.plat_moving_z {
    let plat_vel_z : Float = cos_val * 0.016
    game.pz += plat_vel_z
  }
}

fn update_platforms(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.platforms.length(); i = i + 1 {
    let plat = game.platforms[i]
    if not(plat.active) { continue i + 1 }
    // Moving platforms
    if plat.kind == @types.plat_moving_x {
      plat.move_timer += dt * plat.move_speed
      plat.x = plat.base_x + @math.sinf(plat.move_timer) * plat.move_range
    } else if plat.kind == @types.plat_moving_y {
      plat.move_timer += dt * plat.move_speed
      plat.y = plat.base_y + @math.sinf(plat.move_timer) * plat.move_range
    } else if plat.kind == @types.plat_moving_z {
      plat.move_timer += dt * plat.move_speed
      plat.z = plat.base_z + @math.sinf(plat.move_timer) * plat.move_range
    }
    // Falling platforms
    if plat.kind == @types.plat_falling && plat.touched {
      if plat.fall_timer > 0.0 {
        plat.fall_timer -= dt
        // Shake effect before falling
        let shake = @types.rand_rangef(game, -@types.fall_shake_amp, @types.fall_shake_amp)
        plat.x = plat.base_x + shake
        plat.z = plat.base_z + shake
      } else if not(plat.falling) {
        plat.falling = true
        plat.x = plat.base_x
        plat.z = plat.base_z
      }
      if plat.falling {
        plat.y -= @types.fall_speed * dt
        if plat.y < -30.0 { plat.active = false }
      }
    }
    // Crumbling platforms
    if plat.kind == @types.plat_crumbling && plat.crumbling {
      plat.crumble_timer -= dt
      if plat.crumble_timer <= 0.0 {
        plat.active = false
        @types.spawn_particles(
          game, plat.x, plat.y, plat.z, 12, plat.r, plat.g, plat.b,
        )
      }
    }
    // Phasing platforms
    if plat.kind == @types.plat_phasing {
      plat.phase_timer += dt
      let total_cycle : Float = @types.phase_on_time + @types.phase_off_time
      let ratio : Float = plat.phase_timer / total_cycle
      let floored : Float = Float::from_int(ratio.to_int())
      let in_cycle : Float = plat.phase_timer - floored * total_cycle
      plat.phase_visible = in_cycle < @types.phase_on_time
    }
    // Rotating platforms
    if plat.kind == @types.plat_rotating {
      plat.rot_angle += @types.rotate_speed * dt
    }
    // Size pulsing platforms
    if plat.kind == @types.plat_size_pulse {
      plat.move_timer += dt * 2.0
      let scale : Float = 1.0 + @math.sinf(plat.move_timer) * 0.3
      plat.w = plat.move_range * scale
      plat.d = plat.move_range * scale
    }
  }
}

fn update_collectibles(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.collectibles.length(); i = i + 1 {
    let c = game.collectibles[i]
    if not(c.active) || c.collected { continue i + 1 }
    c.bob_timer += dt
    c.spin_timer += dt * 3.0
    // Check player collision (sphere)
    let dist = @types.dist3d(game.px, game.py, game.pz, c.x, c.y, c.z)
    let pickup_dist : Float = if c.magnet_target { 0.8 } else { 1.0 }
    if dist < pickup_dist {
      c.collected = true
      c.active = false
      if c.kind == @types.collect_gem {
        game.gems_collected += 1
        @types.add_score(game, @types.gem_score)
        @types.spawn_particles(game, c.x, c.y, c.z, @types.particle_collect_count, @types.gem_r, @types.gem_g, @types.gem_b)
      } else if c.kind == @types.collect_star {
        game.stars_collected += 1
        @types.add_score(game, @types.star_score)
        @types.spawn_particles(game, c.x, c.y, c.z, 12, @types.star_r, @types.star_g, @types.star_b)
      } else if c.kind == @types.collect_life {
        game.lives += 1
        @types.spawn_particles(game, c.x, c.y, c.z, 10, 255, 100, 100)
      } else if c.kind == @types.collect_coin_bronze {
        game.coins_collected += 1
        @types.add_score(game, @types.coin_bronze_score)
        @types.spawn_particles(game, c.x, c.y, c.z, 6, @types.coin_bronze_r, @types.coin_bronze_g, @types.coin_bronze_b)
      } else if c.kind == @types.collect_coin_silver {
        game.coins_collected += 1
        @types.add_score(game, @types.coin_silver_score)
        @types.spawn_particles(game, c.x, c.y, c.z, 8, @types.coin_silver_r, @types.coin_silver_g, @types.coin_silver_b)
      } else if c.kind == @types.collect_coin_gold {
        game.coins_collected += 1
        @types.add_score(game, @types.coin_gold_score)
        @types.spawn_particles(game, c.x, c.y, c.z, 10, @types.coin_gold_r, @types.coin_gold_g, @types.coin_gold_b)
      } else if c.kind == @types.collect_key {
        game.keys_collected += 1
        @types.add_score(game, @types.key_score)
        @types.spawn_particle_ring(game, c.x, c.y, c.z, 12, 0.8, 2.0, @types.key_r, @types.key_g, @types.key_b)
      }
      c.magnet_target = false
    }
  }
}
