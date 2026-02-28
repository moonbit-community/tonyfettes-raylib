///|
pub fn draw_world(game : @types.Game) -> Unit {
  let camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(game.cam_x, game.cam_y, game.cam_z),
    @raylib.Vector3::new(game.px, game.py, game.pz),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
  @raylib.begin_mode_3d(camera)
  // Skybox floor
  draw_world_floor(game)
  // World decorations (behind platforms)
  draw_decorations(game)
  draw_platforms(game)
  draw_collectibles(game)
  draw_powerups_3d(game)
  draw_hazards(game)
  draw_enemies_3d(game)
  draw_projectiles_3d(game)
  draw_checkpoints(game)
  draw_goal(game)
  draw_player(game)
  draw_player_shadow(game)
  draw_particles_3d(game)
  @raylib.end_mode_3d()
}

///|
fn draw_world_floor(game : @types.Game) -> Unit {
  let world = game.current_world
  if world == @types.world_forest {
    // Green meadow
    @raylib.draw_plane(
      @raylib.Vector3::new(0.0, -25.0, 0.0),
      @raylib.Vector2::new(200.0, 200.0),
      @raylib.Color::new(40, 80, 30, 255),
    )
  } else if world == @types.world_crystal {
    // Dark cave floor
    @raylib.draw_plane(
      @raylib.Vector3::new(0.0, -25.0, 0.0),
      @raylib.Vector2::new(200.0, 200.0),
      @raylib.Color::new(15, 20, 40, 255),
    )
  } else if world == @types.world_lava {
    // Lava surface
    let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.03) * 0.03
    @raylib.draw_plane(
      @raylib.Vector3::new(0.0, -25.0 + pulse, 0.0),
      @raylib.Vector2::new(200.0, 200.0),
      @raylib.Color::new(200, 60, 10, 255),
    )
    // Glow layer
    @raylib.draw_plane(
      @raylib.Vector3::new(0.0, -24.95, 0.0),
      @raylib.Vector2::new(180.0, 180.0),
      @raylib.Color::new(255, 100, 20, 100),
    )
  } else {
    // Sky world - clouds below
    @raylib.draw_plane(
      @raylib.Vector3::new(0.0, -25.0, 0.0),
      @raylib.Vector2::new(200.0, 200.0),
      @raylib.Color::new(200, 210, 230, 255),
    )
  }
}

///|
fn draw_platforms(game : @types.Game) -> Unit {
  for i = 0; i < game.platforms.length(); i = i + 1 {
    let plat = game.platforms[i]
    if not(plat.active) {
      continue i + 1
    }
    // Phasing platforms: skip if invisible
    if plat.kind == @types.plat_phasing && not(plat.phase_visible) {
      continue i + 1
    }
    let alpha : Int = if plat.crumbling {
      let t : Float = plat.crumble_timer / @types.crumble_time
      (t * 255.0).to_int()
    } else if plat.kind == @types.plat_phasing {
      // Fade in/out near transitions
      let total_cycle : Float = @types.phase_on_time + @types.phase_off_time
      let ratio : Float = plat.phase_timer / total_cycle
      let floored : Float = Float::from_int(ratio.to_int())
      let in_cycle : Float = plat.phase_timer - floored * total_cycle
      if in_cycle > @types.phase_on_time - 0.5 {
        let fade : Float = (@types.phase_on_time - in_cycle) / 0.5
        @types.clampi((fade * 255.0).to_int(), 80, 255)
      } else if in_cycle < 0.3 {
        let fade : Float = in_cycle / 0.3
        @types.clampi((fade * 255.0).to_int(), 80, 255)
      } else {
        255
      }
    } else {
      255
    }
    let a = @types.clampi(alpha, 50, 255)
    // Main platform body
    @raylib.draw_cube(
      @raylib.Vector3::new(plat.x, plat.y, plat.z),
      plat.w,
      plat.h,
      plat.d,
      @raylib.Color::new(plat.r, plat.g, plat.b, a),
    )
    // Wireframe
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(plat.x, plat.y, plat.z),
      plat.w,
      plat.h,
      plat.d,
      @raylib.Color::new(
        @types.clampi(plat.r - 30, 0, 255),
        @types.clampi(plat.g - 30, 0, 255),
        @types.clampi(plat.b - 30, 0, 255),
        a,
      ),
    )
    // Top surface highlight
    let top_y = plat.y + plat.h / 2.0
    @raylib.draw_cube(
      @raylib.Vector3::new(plat.x, top_y + 0.01, plat.z),
      plat.w * 0.95,
      0.02,
      plat.d * 0.95,
      @raylib.Color::new(
        @types.clampi(plat.r + 30, 0, 255),
        @types.clampi(plat.g + 30, 0, 255),
        @types.clampi(plat.b + 30, 0, 255),
        a,
      ),
    )
    // Special indicators per platform type
    draw_platform_special(game, plat)
  }
}

///|
fn draw_platform_special(game : @types.Game, plat : @types.Platform) -> Unit {
  if plat.kind == @types.plat_bouncy {
    // Spring coil on top
    @raylib.draw_cylinder(
      @raylib.Vector3::new(plat.x, plat.y + plat.h / 2.0, plat.z),
      0.3,
      0.5,
      0.2,
      8,
      @raylib.Color::new(255, 150, 0, 255),
    )
    // Spring base ring
    @raylib.draw_cylinder(
      @raylib.Vector3::new(plat.x, plat.y + plat.h / 2.0 + 0.2, plat.z),
      0.35,
      0.25,
      0.05,
      8,
      @raylib.Color::new(255, 200, 50, 255),
    )
  }
  if plat.kind == @types.plat_falling && plat.touched && not(plat.falling) {
    // Warning flash
    let flash = @math.sinf(Float::from_int(game.frame_counter) * 0.3)
    if flash > 0.0 {
      @raylib.draw_cube(
        @raylib.Vector3::new(plat.x, plat.y + 0.2, plat.z),
        plat.w * 0.8,
        0.05,
        plat.d * 0.8,
        @raylib.Color::new(255, 50, 50, 150),
      )
    }
    // Exclamation mark above
    @raylib.draw_cube(
      @raylib.Vector3::new(plat.x, plat.y + 0.8, plat.z),
      0.1,
      0.4,
      0.1,
      @raylib.Color::new(255, 200, 50, 200),
    )
  }
  if plat.kind == @types.plat_ice {
    // Ice sheen on surface
    let shimmer : Float = (
        @math.sinf(Float::from_int(game.frame_counter) * 0.08) + 1.0
      ) *
      0.5
    let sheen_a = 30 + (shimmer * 50.0).to_int()
    @raylib.draw_cube(
      @raylib.Vector3::new(plat.x, plat.y + plat.h / 2.0 + 0.02, plat.z),
      plat.w * 0.9,
      0.01,
      plat.d * 0.9,
      @raylib.Color::new(200, 230, 255, @types.clampi(sheen_a, 0, 255)),
    )
  }
  // Moving platform rails
  if plat.kind >= @types.plat_moving_x && plat.kind <= @types.plat_moving_z {
    draw_platform_rails(plat)
  }
  // Conveyor arrows
  if plat.kind == @types.plat_conveyor_l || plat.kind == @types.plat_conveyor_r {
    let dir_sign : Float = if plat.kind == @types.plat_conveyor_l {
      -1.0
    } else {
      1.0
    }
    let top = plat.y + plat.h / 2.0 + 0.02
    // Draw arrow indicators
    for j = 0; j < 3; j = j + 1 {
      let offset : Float = (Float::from_int(j) - 1.0) * plat.d * 0.3
      @raylib.draw_cube(
        @raylib.Vector3::new(plat.x + dir_sign * 0.3, top, plat.z + offset),
        0.3,
        0.01,
        0.15,
        @raylib.Color::new(200, 200, 100, 180),
      )
      ignore(j)
    }
  }
}

///|
fn draw_platform_rails(plat : @types.Platform) -> Unit {
  let rail_color = @raylib.Color::new(80, 80, 90, 150)
  if plat.kind == @types.plat_moving_x {
    let left = plat.base_x - plat.move_range
    let right = plat.base_x + plat.move_range
    let mid_x : Float = (left + right) * 0.5
    let rail_len : Float = right - left
    @raylib.draw_cube(
      @raylib.Vector3::new(mid_x, plat.base_y - 0.2, plat.z),
      rail_len,
      0.05,
      0.05,
      rail_color,
    )
  } else if plat.kind == @types.plat_moving_y {
    let bottom = plat.base_y - plat.move_range
    let top = plat.base_y + plat.move_range
    let mid_y : Float = (bottom + top) * 0.5
    let rail_len : Float = top - bottom
    @raylib.draw_cube(
      @raylib.Vector3::new(plat.base_x + plat.w / 2.0 + 0.1, mid_y, plat.z),
      0.05,
      rail_len,
      0.05,
      rail_color,
    )
  } else if plat.kind == @types.plat_moving_z {
    let front = plat.base_z - plat.move_range
    let back = plat.base_z + plat.move_range
    let mid_z : Float = (front + back) * 0.5
    let rail_len : Float = back - front
    @raylib.draw_cube(
      @raylib.Vector3::new(plat.x, plat.base_y - 0.2, mid_z),
      0.05,
      0.05,
      rail_len,
      rail_color,
    )
  }
}

///|
fn draw_collectibles(game : @types.Game) -> Unit {
  for i = 0; i < game.collectibles.length(); i = i + 1 {
    let c = game.collectibles[i]
    if not(c.active) || c.collected {
      continue i + 1
    }
    let bob = @math.sinf(c.bob_timer * 2.5) * 0.2
    let y = c.y + bob
    if c.kind == @types.collect_gem {
      draw_gem(c.x, y, c.z, c.spin_timer, game.frame_counter)
    } else if c.kind == @types.collect_star {
      draw_star_collectible(c.x, y, c.z, c.spin_timer)
    } else if c.kind == @types.collect_life {
      draw_life_pickup(c.x, y, c.z, c.bob_timer)
    } else if c.kind == @types.collect_coin_bronze {
      draw_coin(
        c.x,
        y,
        c.z,
        c.spin_timer,
        @types.coin_bronze_r,
        @types.coin_bronze_g,
        @types.coin_bronze_b,
      )
    } else if c.kind == @types.collect_coin_silver {
      draw_coin(
        c.x,
        y,
        c.z,
        c.spin_timer,
        @types.coin_silver_r,
        @types.coin_silver_g,
        @types.coin_silver_b,
      )
    } else if c.kind == @types.collect_coin_gold {
      draw_coin(
        c.x,
        y,
        c.z,
        c.spin_timer,
        @types.coin_gold_r,
        @types.coin_gold_g,
        @types.coin_gold_b,
      )
    } else if c.kind == @types.collect_key {
      draw_key(c.x, y, c.z, c.spin_timer)
    }
  }
}

///|
fn draw_gem(x : Float, y : Float, z : Float, spin : Float, frame : Int) -> Unit {
  // Diamond shape: two cubes rotated
  let size : Float = 0.3
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y, z),
    size,
    size,
    size,
    @raylib.Color::new(@types.gem_r, @types.gem_g, @types.gem_b, 220),
  )
  // Glow effect
  let glow = (@math.sinf(spin * 2.0) + 1.0) * 0.5
  let glow_a = 60 + (glow * 60.0).to_int()
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y, z),
    size * 1.3,
    size * 1.3,
    size * 1.3,
    @raylib.Color::new(100, 255, 180, @types.clampi(glow_a, 0, 255)),
  )
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(x, y, z),
    size * 1.1,
    size * 1.1,
    size * 1.1,
    @raylib.Color::new(100, 255, 180, 255),
  )
  ignore(frame)
}

///|
fn draw_star_collectible(x : Float, y : Float, z : Float, spin : Float) -> Unit {
  // Star: cross shape
  let size : Float = 0.4
  let thin : Float = 0.15
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y, z),
    size,
    thin,
    thin,
    @raylib.Color::new(@types.star_r, @types.star_g, @types.star_b, 220),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y, z),
    thin,
    size,
    thin,
    @raylib.Color::new(@types.star_r, @types.star_g, @types.star_b, 220),
  )
  // Glow
  let glow = (@math.sinf(spin * 1.5) + 1.0) * 0.5
  let glow_a = 40 + (glow * 60.0).to_int()
  @raylib.draw_sphere(
    @raylib.Vector3::new(x, y, z),
    0.3,
    @raylib.Color::new(255, 255, 100, @types.clampi(glow_a, 0, 255)),
  )
}

///|
fn draw_life_pickup(x : Float, y : Float, z : Float, timer : Float) -> Unit {
  let pulse = @math.sinf(timer * 3.0) * 0.05 + 0.25
  @raylib.draw_sphere(
    @raylib.Vector3::new(x, y, z),
    pulse,
    @raylib.Color::new(255, 80, 80, 220),
  )
  // Cross on top
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y, z),
    0.35,
    0.08,
    0.08,
    @raylib.Color::new(255, 255, 255, 200),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y, z),
    0.08,
    0.35,
    0.08,
    @raylib.Color::new(255, 255, 255, 200),
  )
}

///|
fn draw_coin(
  x : Float,
  y : Float,
  z : Float,
  spin : Float,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  // Coin is a flat cylinder
  let scale = @types.absf(@math.cosf(spin)) * 0.15 + 0.05
  @raylib.draw_cylinder(
    @raylib.Vector3::new(x, y - 0.1, z),
    scale,
    scale,
    0.2,
    8,
    @raylib.Color::new(r, g, b, 220),
  )
  // Shiny highlight
  @raylib.draw_cylinder(
    @raylib.Vector3::new(x, y - 0.05, z),
    scale * 0.6,
    scale * 0.6,
    0.05,
    8,
    @raylib.Color::new(
      @types.clampi(r + 50, 0, 255),
      @types.clampi(g + 50, 0, 255),
      @types.clampi(b + 50, 0, 255),
      200,
    ),
  )
}

///|
fn draw_key(x : Float, y : Float, z : Float, spin : Float) -> Unit {
  // Key handle (ring)
  @raylib.draw_cylinder(
    @raylib.Vector3::new(x, y, z),
    0.15,
    0.15,
    0.25,
    6,
    @raylib.Color::new(@types.key_r, @types.key_g, @types.key_b, 230),
  )
  // Key stem
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y - 0.2, z),
    0.05,
    0.3,
    0.05,
    @raylib.Color::new(@types.key_r, @types.key_g, @types.key_b, 230),
  )
  // Key teeth
  @raylib.draw_cube(
    @raylib.Vector3::new(x + 0.06, y - 0.3, z),
    0.1,
    0.05,
    0.05,
    @raylib.Color::new(@types.key_r, @types.key_g, @types.key_b, 230),
  )
  ignore(spin)
}

///|
fn draw_powerups_3d(game : @types.Game) -> Unit {
  for i = 0; i < game.powerups.length(); i = i + 1 {
    let pu = game.powerups[i]
    if not(pu.active) || pu.collected {
      continue i + 1
    }
    let bob = @math.sinf(pu.bob_timer * @types.powerup_bob_speed) * 0.3
    let y = pu.y + bob
    // Power-up color
    let pr : Int = if pu.kind == @types.powerup_double_jump {
      @types.pu_double_jump_r
    } else if pu.kind == @types.powerup_speed {
      @types.pu_speed_r
    } else if pu.kind == @types.powerup_shield {
      @types.pu_shield_r
    } else if pu.kind == @types.powerup_magnet {
      @types.pu_magnet_r
    } else {
      @types.pu_slow_fall_r
    }
    let pg : Int = if pu.kind == @types.powerup_double_jump {
      @types.pu_double_jump_g
    } else if pu.kind == @types.powerup_speed {
      @types.pu_speed_g
    } else if pu.kind == @types.powerup_shield {
      @types.pu_shield_g
    } else if pu.kind == @types.powerup_magnet {
      @types.pu_magnet_g
    } else {
      @types.pu_slow_fall_g
    }
    let pb : Int = if pu.kind == @types.powerup_double_jump {
      @types.pu_double_jump_b
    } else if pu.kind == @types.powerup_speed {
      @types.pu_speed_b
    } else if pu.kind == @types.powerup_shield {
      @types.pu_shield_b
    } else if pu.kind == @types.powerup_magnet {
      @types.pu_magnet_b
    } else {
      @types.pu_slow_fall_b
    }
    // Main sphere
    @raylib.draw_sphere(
      @raylib.Vector3::new(pu.x, y, pu.z),
      0.35,
      @raylib.Color::new(pr, pg, pb, 220),
    )
    // Outer glow ring
    let glow_pulse = (@math.sinf(pu.spin_timer * 3.0) + 1.0) * 0.5
    let glow_a = 40 + (glow_pulse * 80.0).to_int()
    @raylib.draw_sphere(
      @raylib.Vector3::new(pu.x, y, pu.z),
      0.5,
      @raylib.Color::new(pr, pg, pb, @types.clampi(glow_a, 0, 255)),
    )
    // Icon indicator
    if pu.kind == @types.powerup_double_jump {
      // Up arrow
      @raylib.draw_cube(
        @raylib.Vector3::new(pu.x, y + 0.5, pu.z),
        0.06,
        0.2,
        0.06,
        @raylib.Color::new(255, 255, 255, 200),
      )
    } else if pu.kind == @types.powerup_speed {
      // Lightning bolt
      @raylib.draw_cube(
        @raylib.Vector3::new(pu.x - 0.05, y + 0.5, pu.z),
        0.15,
        0.06,
        0.06,
        @raylib.Color::new(255, 255, 255, 200),
      )
    } else if pu.kind == @types.powerup_shield {
      // Shield ring
      @raylib.draw_cube(
        @raylib.Vector3::new(pu.x, y + 0.5, pu.z),
        0.2,
        0.06,
        0.2,
        @raylib.Color::new(255, 255, 255, 180),
      )
    }
  }
}

///|
fn draw_hazards(game : @types.Game) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    let h = game.hazards[i]
    if not(h.active) {
      continue i + 1
    }
    if h.kind == @types.hazard_spike {
      draw_spike(h)
    } else if h.kind == @types.hazard_lava {
      draw_lava_pool(game, h)
    } else if h.kind == @types.hazard_saw {
      draw_saw_blade(game, h)
    } else if h.kind == @types.hazard_fire_jet {
      draw_fire_jet(game, h)
    } else if h.kind == @types.hazard_pendulum {
      draw_pendulum(h)
    } else if h.kind == @types.hazard_crusher {
      draw_crusher(h)
    }
  }
}

///|
fn draw_spike(h : @types.Hazard) -> Unit {
  // Spike: cone pointing up
  @raylib.draw_cylinder(
    @raylib.Vector3::new(h.x, h.y, h.z),
    0.0,
    h.w / 2.0,
    h.h,
    4,
    @raylib.Color::new(@types.spike_r, @types.spike_g, @types.spike_b, 255),
  )
  // Base
  @raylib.draw_cylinder(
    @raylib.Vector3::new(h.x, h.y - 0.05, h.z),
    h.w / 2.0,
    h.w / 2.0 + 0.05,
    0.1,
    8,
    @raylib.Color::new(
      @types.spike_r - 40,
      @types.spike_g - 40,
      @types.spike_b - 40,
      255,
    ),
  )
}

///|
fn draw_lava_pool(game : @types.Game, h : @types.Hazard) -> Unit {
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.05) * 0.02
  @raylib.draw_cube(
    @raylib.Vector3::new(h.x, h.y + pulse, h.z),
    h.w,
    h.h,
    h.d,
    @raylib.Color::new(
      @types.lava_glow_r, @types.lava_glow_g, @types.lava_glow_b, 200,
    ),
  )
  // Glow on top
  @raylib.draw_cube(
    @raylib.Vector3::new(h.x, h.y + h.h / 2.0 + 0.02, h.z),
    h.w * 0.9,
    0.02,
    h.d * 0.9,
    @raylib.Color::new(255, 180, 50, 120),
  )
  // Bubbles
  if game.frame_counter % 30 == 0 {
    @types.spawn_particles(game, h.x, h.y + 0.2, h.z, 2, 255, 150, 30)
  }
}

///|
fn draw_saw_blade(game : @types.Game, h : @types.Hazard) -> Unit {
  // Rotating disk
  @raylib.draw_cylinder(
    @raylib.Vector3::new(h.x, h.y, h.z),
    h.w / 2.0,
    h.w / 2.0,
    0.1,
    16,
    @raylib.Color::new(@types.saw_r, @types.saw_g, @types.saw_b, 255),
  )
  // Center axle
  @raylib.draw_cylinder(
    @raylib.Vector3::new(h.x, h.y, h.z),
    0.08,
    0.08,
    0.15,
    8,
    @raylib.Color::new(100, 100, 100, 255),
  )
  // Sparks occasionally
  if game.frame_counter % 10 == 0 {
    @types.spawn_particles(game, h.x, h.y, h.z, 1, 255, 200, 100)
  }
}

///|
fn draw_fire_jet(game : @types.Game, h : @types.Hazard) -> Unit {
  // Base nozzle
  @raylib.draw_cylinder(
    @raylib.Vector3::new(h.x, h.y - 0.3, h.z),
    0.2,
    0.15,
    0.3,
    8,
    @raylib.Color::new(100, 100, 110, 255),
  )
  if h.on {
    // Fire column
    let flicker = @math.sinf(Float::from_int(game.frame_counter) * 0.5) * 0.1
    @raylib.draw_cylinder(
      @raylib.Vector3::new(h.x, h.y + 0.5, h.z),
      0.15 + flicker,
      0.05,
      h.h,
      8,
      @raylib.Color::new(
        @types.fire_jet_r, @types.fire_jet_g, @types.fire_jet_b, 200,
      ),
    )
    // Inner glow
    @raylib.draw_cylinder(
      @raylib.Vector3::new(h.x, h.y + 0.5, h.z),
      0.08,
      0.02,
      h.h * 0.8,
      6,
      @raylib.Color::new(255, 240, 100, 150),
    )
    // Fire particles
    if game.frame_counter % 3 == 0 {
      @types.spawn_particles_dir(
        game,
        h.x,
        h.y + h.h,
        h.z,
        1,
        0.0,
        2.0,
        0.0,
        0.5,
        255,
        150,
        30,
      )
    }
  }
}

///|
fn draw_pendulum(h : @types.Hazard) -> Unit {
  // Chain
  @raylib.draw_cube(
    @raylib.Vector3::new(h.base_x, h.base_y + 1.0, h.z),
    0.04,
    2.0,
    0.04,
    @raylib.Color::new(120, 120, 130, 255),
  )
  // Ball
  @raylib.draw_sphere(
    @raylib.Vector3::new(h.x, h.y, h.z),
    h.w / 2.0,
    @raylib.Color::new(180, 60, 60, 255),
  )
  // Spikes on ball
  @raylib.draw_cube(
    @raylib.Vector3::new(h.x + h.w / 2.0, h.y, h.z),
    0.15,
    0.06,
    0.06,
    @raylib.Color::new(200, 200, 200, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(h.x - h.w / 2.0, h.y, h.z),
    0.15,
    0.06,
    0.06,
    @raylib.Color::new(200, 200, 200, 255),
  )
}

///|
fn draw_crusher(h : @types.Hazard) -> Unit {
  // Heavy block
  @raylib.draw_cube(
    @raylib.Vector3::new(h.x, h.y, h.z),
    h.w,
    h.h,
    h.d,
    @raylib.Color::new(140, 100, 80, 255),
  )
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(h.x, h.y, h.z),
    h.w,
    h.h,
    h.d,
    @raylib.Color::new(100, 70, 50, 255),
  )
  // Warning stripes on bottom
  @raylib.draw_cube(
    @raylib.Vector3::new(h.x, h.y - h.h / 2.0 - 0.01, h.z),
    h.w * 0.9,
    0.02,
    h.d * 0.9,
    @raylib.Color::new(255, 200, 50, 200),
  )
}

///|
fn draw_enemies_3d(game : @types.Game) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let e = game.enemies[i]
    if not(e.active) {
      continue i + 1
    }
    // Stunned enemies flash
    if e.stunned && game.frame_counter % 6 < 3 {
      continue i + 1
    }
    if e.kind == @types.enemy_patrol {
      draw_enemy_patrol(e)
    } else if e.kind == @types.enemy_bounce {
      draw_enemy_bounce(e)
    } else if e.kind == @types.enemy_fly_circle {
      draw_enemy_fly(e)
    } else if e.kind == @types.enemy_chase {
      draw_enemy_chase(e)
    } else if e.kind == @types.enemy_turret {
      draw_enemy_turret(e)
    }
    // Shadow under enemy
    @raylib.draw_cube(
      @raylib.Vector3::new(e.x, e.base_y - 0.1, e.z),
      e.size * 1.2,
      0.02,
      e.size * 1.2,
      @raylib.Color::new(0, 0, 0, 50),
    )
  }
}

///|
fn draw_enemy_patrol(e : @types.Enemy) -> Unit {
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    e.size,
    e.size,
    e.size,
    @raylib.Color::new(e.r, e.g, e.b, 255),
  )
  // Eyes
  let eye_dir : Float = if e.patrol_dir > 0.0 { 1.0 } else { -1.0 }
  let eye_x : Float = e.x + eye_dir * e.size * 0.25
  let eye_y : Float = e.y + e.size * 0.15
  @raylib.draw_cube(
    @raylib.Vector3::new(eye_x, eye_y, e.z + e.size * 0.5),
    0.08,
    0.08,
    0.02,
    @raylib.Color::new(255, 255, 255, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(eye_x + eye_dir * 0.15, eye_y, e.z + e.size * 0.5),
    0.08,
    0.08,
    0.02,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Feet
  let walk_anim = @math.sinf(e.anim_timer * 8.0) * 0.1
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x - 0.12, e.y - e.size * 0.5 - 0.05 + walk_anim, e.z),
    0.12,
    0.1,
    0.15,
    @raylib.Color::new(e.r - 30, e.g - 30, e.b - 30, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x + 0.12, e.y - e.size * 0.5 - 0.05 - walk_anim, e.z),
    0.12,
    0.1,
    0.15,
    @raylib.Color::new(e.r - 30, e.g - 30, e.b - 30, 255),
  )
}

///|
fn draw_enemy_bounce(e : @types.Enemy) -> Unit {
  // Squash and stretch based on vertical position
  let height_ratio : Float = (e.y - e.base_y) / @types.enemy_bounce_height
  let squash_x : Float = e.size * (1.0 + (1.0 - height_ratio) * 0.3)
  let squash_y : Float = e.size * (0.7 + height_ratio * 0.6)
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    squash_x,
    squash_y,
    squash_x,
    @raylib.Color::new(e.r, e.g, e.b, 255),
  )
  // Face
  @raylib.draw_sphere(
    @raylib.Vector3::new(e.x, e.y + squash_y * 0.3, e.z + squash_x * 0.4),
    0.06,
    @raylib.Color::new(255, 255, 255, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(e.x + 0.1, e.y + squash_y * 0.3, e.z + squash_x * 0.4),
    0.06,
    @raylib.Color::new(255, 255, 255, 255),
  )
}

///|
fn draw_enemy_fly(e : @types.Enemy) -> Unit {
  // Spherical body
  @raylib.draw_sphere(
    @raylib.Vector3::new(e.x, e.y, e.z),
    e.size * 0.5,
    @raylib.Color::new(e.r, e.g, e.b, 255),
  )
  // Wings (oscillating cubes)
  let wing_flap = @math.sinf(e.anim_timer * 12.0) * 0.2
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x - e.size * 0.6, e.y + wing_flap, e.z),
    e.size * 0.5,
    0.04,
    e.size * 0.3,
    @raylib.Color::new(e.r + 40, e.g + 40, e.b, 200),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x + e.size * 0.6, e.y - wing_flap, e.z),
    e.size * 0.5,
    0.04,
    e.size * 0.3,
    @raylib.Color::new(e.r + 40, e.g + 40, e.b, 200),
  )
  // Eyes
  @raylib.draw_sphere(
    @raylib.Vector3::new(e.x - 0.08, e.y + 0.05, e.z + e.size * 0.45),
    0.05,
    @raylib.Color::new(255, 255, 255, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(e.x + 0.08, e.y + 0.05, e.z + e.size * 0.45),
    0.05,
    @raylib.Color::new(255, 255, 255, 255),
  )
}

///|
fn draw_enemy_chase(e : @types.Enemy) -> Unit {
  // Angry-looking cube with horns
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    e.size,
    e.size,
    e.size,
    @raylib.Color::new(e.r, e.g, e.b, 255),
  )
  // Horns
  @raylib.draw_cylinder(
    @raylib.Vector3::new(e.x - 0.15, e.y + e.size * 0.4, e.z),
    0.02,
    0.06,
    0.2,
    4,
    @raylib.Color::new(e.r - 50, e.g - 20, e.b - 20, 255),
  )
  @raylib.draw_cylinder(
    @raylib.Vector3::new(e.x + 0.15, e.y + e.size * 0.4, e.z),
    0.02,
    0.06,
    0.2,
    4,
    @raylib.Color::new(e.r - 50, e.g - 20, e.b - 20, 255),
  )
  // Angry eyes
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x - 0.1, e.y + 0.1, e.z + e.size * 0.5),
    0.12,
    0.06,
    0.02,
    @raylib.Color::new(255, 50, 50, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x + 0.1, e.y + 0.1, e.z + e.size * 0.5),
    0.12,
    0.06,
    0.02,
    @raylib.Color::new(255, 50, 50, 255),
  )
}

///|
fn draw_enemy_turret(e : @types.Enemy) -> Unit {
  // Base
  @raylib.draw_cylinder(
    @raylib.Vector3::new(e.x, e.y - e.size * 0.3, e.z),
    e.size * 0.5,
    e.size * 0.6,
    e.size * 0.4,
    8,
    @raylib.Color::new(e.r, e.g, e.b, 255),
  )
  // Barrel
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y + 0.1, e.z + e.size * 0.5),
    0.1,
    0.1,
    e.size * 0.8,
    @raylib.Color::new(e.r - 20, e.g - 20, e.b - 20, 255),
  )
  // Eye/sensor
  @raylib.draw_sphere(
    @raylib.Vector3::new(e.x, e.y + e.size * 0.2, e.z),
    0.1,
    @raylib.Color::new(255, 50, 50, 200),
  )
}

///|
fn draw_projectiles_3d(game : @types.Game) -> Unit {
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    let proj = game.projectiles[i]
    if not(proj.active) {
      continue i + 1
    }
    @raylib.draw_sphere(
      @raylib.Vector3::new(proj.x, proj.y, proj.z),
      @types.proj_radius,
      @raylib.Color::new(proj.r, proj.g, proj.b, 220),
    )
    // Trail glow
    @raylib.draw_sphere(
      @raylib.Vector3::new(proj.x, proj.y, proj.z),
      @types.proj_radius * 1.5,
      @raylib.Color::new(proj.r, proj.g, proj.b, 80),
    )
  }
}

///|
fn draw_checkpoints(game : @types.Game) -> Unit {
  for i = 0; i < game.checkpoints.length(); i = i + 1 {
    let cp = game.checkpoints[i]
    if not(cp.active) {
      continue i + 1
    }
    let color = if cp.activated {
      @raylib.Color::new(0, 255, 100, 200)
    } else {
      @raylib.Color::new(200, 200, 50, 150)
    }
    // Pole
    @raylib.draw_cylinder(
      @raylib.Vector3::new(cp.x, cp.y - 0.5, cp.z),
      0.08,
      0.08,
      @types.checkpoint_flag_height,
      8,
      @raylib.Color::new(180, 180, 190, 255),
    )
    // Flag
    let flag_y = cp.y + 0.6
    @raylib.draw_cube(
      @raylib.Vector3::new(cp.x + 0.2, flag_y, cp.z),
      0.35,
      0.2,
      0.02,
      color,
    )
    // Top sphere
    @raylib.draw_sphere(
      @raylib.Vector3::new(cp.x, cp.y + 0.8, cp.z),
      0.1,
      color,
    )
    // Activation glow
    if cp.activated {
      let glow_pulse = @math.sinf(cp.anim_timer * 3.0) * 0.1
      @raylib.draw_sphere(
        @raylib.Vector3::new(cp.x, cp.y + 0.5, cp.z),
        0.5 + glow_pulse,
        @raylib.Color::new(0, 255, 100, 40),
      )
      cp.anim_timer += 0.016
    }
  }
}

///|
fn draw_goal(game : @types.Game) -> Unit {
  let bob = @math.sinf(Float::from_int(game.frame_counter) * 0.04) * 0.3
  let y = game.goal_y + bob
  // Inner gem
  @raylib.draw_cube(
    @raylib.Vector3::new(game.goal_x, y, game.goal_z),
    0.8,
    0.8,
    0.8,
    @raylib.Color::new(
      @types.goal_inner_r, @types.goal_inner_g, @types.goal_inner_b, 200,
    ),
  )
  // Outer wireframe
  let spin = Float::from_int(game.frame_counter) * 0.02
  let outer_size : Float = 1.0 + @math.sinf(spin) * 0.1
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(game.goal_x, y, game.goal_z),
    outer_size,
    outer_size,
    outer_size,
    @raylib.Color::new(
      @types.goal_outer_r, @types.goal_outer_g, @types.goal_outer_b, 255,
    ),
  )
  // Glow sphere
  let glow_size : Float = 1.2 + @math.sinf(spin * 2.0) * 0.2
  @raylib.draw_sphere(
    @raylib.Vector3::new(game.goal_x, y, game.goal_z),
    glow_size,
    @raylib.Color::new(
      @types.goal_inner_r, @types.goal_inner_g, @types.goal_inner_b, 30,
    ),
  )
  // Pillar underneath
  @raylib.draw_cylinder(
    @raylib.Vector3::new(game.goal_x, game.goal_y - 0.8, game.goal_z),
    0.3,
    0.5,
    0.8,
    6,
    @raylib.Color::new(200, 180, 120, 200),
  )
}

///|
fn draw_player(game : @types.Game) -> Unit {
  // Invincibility flash
  if game.invincible_timer > 0.0 && game.frame_counter % 4 < 2 {
    return
  }
  let px = game.px
  let py = game.py
  let pz = game.pz
  let pr = @types.player_radius
  let ph = @types.player_height
  // Squash and stretch
  let squash_y : Float = 1.0 - game.anim_land_squash * 0.3
  let stretch_y : Float = 1.0 + game.anim_jump_stretch * 0.2
  let body_scale_y : Float = squash_y * stretch_y
  let body_scale_x : Float = 1.0 +
    game.anim_land_squash * 0.2 -
    game.anim_jump_stretch * 0.1
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(px, py, pz),
    pr * 2.0 * body_scale_x,
    ph * body_scale_y,
    pr * 2.0 * body_scale_x,
    @raylib.Color::new(
      @types.player_body_r, @types.player_body_g, @types.player_body_b, 255,
    ),
  )
  // Belt detail
  @raylib.draw_cube(
    @raylib.Vector3::new(px, py - 0.05, pz),
    pr * 2.0 * body_scale_x + 0.02,
    0.06,
    pr * 2.0 * body_scale_x + 0.02,
    @raylib.Color::new(
      @types.player_body_r - 20,
      @types.player_body_g - 20,
      @types.player_body_b,
      255,
    ),
  )
  // Head
  let head_y = py + ph * 0.5 * body_scale_y + 0.15
  @raylib.draw_sphere(
    @raylib.Vector3::new(px, head_y, pz),
    0.22,
    @raylib.Color::new(
      @types.player_head_r, @types.player_head_g, @types.player_head_b, 255,
    ),
  )
  // Eyes (face the facing direction)
  let eye_offset_x = game.facing_x * 0.12
  let eye_offset_z = game.facing_z * 0.12
  @raylib.draw_sphere(
    @raylib.Vector3::new(
      px + eye_offset_x - game.facing_z * 0.06,
      head_y + 0.03,
      pz + eye_offset_z + game.facing_x * 0.06,
    ),
    0.04,
    @raylib.Color::new(
      @types.player_eye_r, @types.player_eye_g, @types.player_eye_b, 255,
    ),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(
      px + eye_offset_x + game.facing_z * 0.06,
      head_y + 0.03,
      pz + eye_offset_z - game.facing_x * 0.06,
    ),
    0.04,
    @raylib.Color::new(
      @types.player_eye_r, @types.player_eye_g, @types.player_eye_b, 255,
    ),
  )
  // Arms
  let arm_swing = @math.sinf(game.anim_walk_timer) * 0.15
  let arm_y = py + ph * 0.2
  @raylib.draw_cube(
    @raylib.Vector3::new(px - pr - 0.1, arm_y + arm_swing, pz),
    0.1,
    0.3,
    0.1,
    @raylib.Color::new(
      @types.player_arm_r, @types.player_arm_g, @types.player_arm_b, 255,
    ),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(px + pr + 0.1, arm_y - arm_swing, pz),
    0.1,
    0.3,
    0.1,
    @raylib.Color::new(
      @types.player_arm_r, @types.player_arm_g, @types.player_arm_b, 255,
    ),
  )
  // Legs
  let leg_swing = @math.sinf(game.anim_walk_timer) * 0.12
  let leg_y = py - ph * 0.5 - 0.05
  @raylib.draw_cube(
    @raylib.Vector3::new(px - 0.1, leg_y + leg_swing, pz),
    0.12,
    0.25,
    0.12,
    @raylib.Color::new(
      @types.player_leg_r, @types.player_leg_g, @types.player_leg_b, 255,
    ),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(px + 0.1, leg_y - leg_swing, pz),
    0.12,
    0.25,
    0.12,
    @raylib.Color::new(
      @types.player_leg_r, @types.player_leg_g, @types.player_leg_b, 255,
    ),
  )
  // Shield visual
  if game.has_shield {
    let shield_pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.1) *
      0.1
    @raylib.draw_sphere(
      @raylib.Vector3::new(px, py, pz),
      pr * 2.5 + shield_pulse,
      @raylib.Color::new(
        @types.player_shield_r, @types.player_shield_g, @types.player_shield_b, @types.player_shield_a,
      ),
    )
  }
  // Dash trail
  if game.dashing {
    @raylib.draw_cube(
      @raylib.Vector3::new(
        px - game.dash_dir_x * 0.5,
        py,
        pz - game.dash_dir_z * 0.5,
      ),
      pr * 1.5,
      ph * 0.5,
      pr * 1.5,
      @raylib.Color::new(
        @types.player_body_r, @types.player_body_g, @types.player_body_b, 100,
      ),
    )
  }
  // Wall slide indicator
  if game.wall_slide {
    @raylib.draw_cube(
      @raylib.Vector3::new(px - game.wall_dir * (pr + 0.05), py, pz),
      0.05,
      ph * 0.6,
      pr * 1.5,
      @raylib.Color::new(200, 200, 255, 100),
    )
  }
}

///|
fn draw_player_shadow(game : @types.Game) -> Unit {
  let shadow_y = @types.find_shadow_y(game, game.px, game.py, game.pz)
  let alpha = @types.shadow_alpha(game.py, shadow_y)
  let scale = @types.shadow_scale(game.py, shadow_y)
  if alpha > 0 {
    @raylib.draw_cube(
      @raylib.Vector3::new(game.px, shadow_y + 0.01, game.pz),
      scale,
      0.02,
      scale,
      @raylib.Color::new(0, 0, 0, alpha),
    )
  }
}

///|
fn draw_decorations(game : @types.Game) -> Unit {
  for i = 0; i < game.decorations.length(); i = i + 1 {
    let d = game.decorations[i]
    if not(d.active) {
      continue i + 1
    }
    if d.kind == @types.deco_tree {
      draw_tree(d)
    } else if d.kind == @types.deco_rock {
      draw_rock(d)
    } else if d.kind == @types.deco_crystal {
      draw_crystal(d)
    } else if d.kind == @types.deco_mushroom {
      draw_mushroom(d)
    } else if d.kind == @types.deco_pillar {
      draw_pillar(d)
    } else if d.kind == @types.deco_stalagmite {
      draw_stalagmite(d)
    } else if d.kind == @types.deco_lava_rock {
      draw_lava_rock(d)
    } else if d.kind == @types.deco_cloud {
      draw_cloud_deco(d)
    } else if d.kind == @types.deco_bush {
      draw_bush(d)
    } else if d.kind == @types.deco_lamp {
      draw_lamp(d)
    }
  }
}

///|
fn draw_tree(d : @types.Decoration) -> Unit {
  let s = d.scale
  // Trunk
  @raylib.draw_cylinder(
    @raylib.Vector3::new(d.x, d.y, d.z),
    0.1 * s,
    0.15 * s,
    0.6 * s,
    6,
    @raylib.Color::new(
      @types.forest_trunk_r, @types.forest_trunk_g, @types.forest_trunk_b, 255,
    ),
  )
  // Canopy (sphere)
  @raylib.draw_sphere(
    @raylib.Vector3::new(d.x, d.y + 0.7 * s, d.z),
    0.4 * s,
    @raylib.Color::new(d.r, d.g, d.b, 220),
  )
  // Second canopy layer
  @raylib.draw_sphere(
    @raylib.Vector3::new(d.x + 0.1 * s, d.y + 0.9 * s, d.z - 0.05 * s),
    0.3 * s,
    @raylib.Color::new(d.r + 10, d.g + 15, d.b, 200),
  )
}

///|
fn draw_rock(d : @types.Decoration) -> Unit {
  let s = d.scale
  @raylib.draw_cube(
    @raylib.Vector3::new(d.x, d.y + 0.1 * s, d.z),
    0.3 * s,
    0.25 * s,
    0.25 * s,
    @raylib.Color::new(d.r, d.g, d.b, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(d.x + 0.08 * s, d.y + 0.2 * s, d.z - 0.05 * s),
    0.15 * s,
    0.15 * s,
    0.18 * s,
    @raylib.Color::new(d.r + 10, d.g + 10, d.b + 10, 255),
  )
}

///|
fn draw_crystal(d : @types.Decoration) -> Unit {
  let s = d.scale
  // Main crystal spire
  @raylib.draw_cylinder(
    @raylib.Vector3::new(d.x, d.y, d.z),
    0.0,
    0.12 * s,
    0.6 * s,
    5,
    @raylib.Color::new(d.r, d.g, d.b, 200),
  )
  // Smaller crystal next to it
  @raylib.draw_cylinder(
    @raylib.Vector3::new(d.x + 0.12 * s, d.y, d.z - 0.05 * s),
    0.0,
    0.08 * s,
    0.35 * s,
    5,
    @raylib.Color::new(d.r + 20, d.g + 20, d.b + 30, 180),
  )
}

///|
fn draw_mushroom(d : @types.Decoration) -> Unit {
  let s = d.scale
  // Stem
  @raylib.draw_cylinder(
    @raylib.Vector3::new(d.x, d.y, d.z),
    0.04 * s,
    0.06 * s,
    0.2 * s,
    6,
    @raylib.Color::new(200, 190, 170, 255),
  )
  // Cap
  @raylib.draw_cylinder(
    @raylib.Vector3::new(d.x, d.y + 0.18 * s, d.z),
    0.02 * s,
    0.15 * s,
    0.08 * s,
    8,
    @raylib.Color::new(d.r, d.g, d.b, 230),
  )
}

///|
fn draw_pillar(d : @types.Decoration) -> Unit {
  let s = d.scale
  // Stone pillar
  @raylib.draw_cylinder(
    @raylib.Vector3::new(d.x, d.y, d.z),
    0.15 * s,
    0.15 * s,
    1.2 * s,
    6,
    @raylib.Color::new(d.r, d.g, d.b, 255),
  )
  // Capital
  @raylib.draw_cylinder(
    @raylib.Vector3::new(d.x, d.y + 1.15 * s, d.z),
    0.2 * s,
    0.15 * s,
    0.1 * s,
    6,
    @raylib.Color::new(d.r + 15, d.g + 15, d.b + 15, 255),
  )
  // Base
  @raylib.draw_cylinder(
    @raylib.Vector3::new(d.x, d.y - 0.02, d.z),
    0.2 * s,
    0.2 * s,
    0.05,
    6,
    @raylib.Color::new(d.r - 10, d.g - 10, d.b - 10, 255),
  )
}

///|
fn draw_stalagmite(d : @types.Decoration) -> Unit {
  let s = d.scale
  @raylib.draw_cylinder(
    @raylib.Vector3::new(d.x, d.y, d.z),
    0.0,
    0.1 * s,
    0.5 * s,
    5,
    @raylib.Color::new(d.r, d.g, d.b, 255),
  )
}

///|
fn draw_lava_rock(d : @types.Decoration) -> Unit {
  let s = d.scale
  @raylib.draw_cube(
    @raylib.Vector3::new(d.x, d.y + 0.12 * s, d.z),
    0.25 * s,
    0.25 * s,
    0.2 * s,
    @raylib.Color::new(d.r, d.g, d.b, 255),
  )
  // Glow cracks
  @raylib.draw_cube(
    @raylib.Vector3::new(d.x, d.y + 0.13 * s, d.z),
    0.27 * s,
    0.02,
    0.22 * s,
    @raylib.Color::new(255, 100, 20, 100),
  )
}

///|
fn draw_cloud_deco(d : @types.Decoration) -> Unit {
  let s = d.scale
  @raylib.draw_sphere(
    @raylib.Vector3::new(d.x, d.y, d.z),
    0.4 * s,
    @raylib.Color::new(d.r, d.g, d.b, 150),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(d.x + 0.3 * s, d.y - 0.05, d.z),
    0.3 * s,
    @raylib.Color::new(d.r, d.g, d.b, 130),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(d.x - 0.25 * s, d.y + 0.05, d.z),
    0.25 * s,
    @raylib.Color::new(d.r, d.g, d.b, 140),
  )
}

///|
fn draw_bush(d : @types.Decoration) -> Unit {
  let s = d.scale
  @raylib.draw_sphere(
    @raylib.Vector3::new(d.x, d.y + 0.1 * s, d.z),
    0.2 * s,
    @raylib.Color::new(d.r, d.g, d.b, 220),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(d.x + 0.1 * s, d.y + 0.08 * s, d.z + 0.08 * s),
    0.15 * s,
    @raylib.Color::new(d.r + 10, d.g + 15, d.b + 5, 200),
  )
}

///|
fn draw_lamp(d : @types.Decoration) -> Unit {
  let s = d.scale
  // Post
  @raylib.draw_cylinder(
    @raylib.Vector3::new(d.x, d.y, d.z),
    0.03 * s,
    0.03 * s,
    0.5 * s,
    6,
    @raylib.Color::new(120, 110, 90, 255),
  )
  // Light orb
  @raylib.draw_sphere(
    @raylib.Vector3::new(d.x, d.y + 0.55 * s, d.z),
    0.08 * s,
    @raylib.Color::new(d.r, d.g, d.b, 230),
  )
  // Glow
  @raylib.draw_sphere(
    @raylib.Vector3::new(d.x, d.y + 0.55 * s, d.z),
    0.2 * s,
    @raylib.Color::new(d.r, d.g, d.b, 40),
  )
}

///|
fn draw_particles_3d(game : @types.Game) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) {
      continue i + 1
    }
    let life_ratio : Float = p.life / p.max_life
    let alpha = (life_ratio * 255.0).to_int()
    let a = @types.clampi(alpha, 0, 255)
    let size = p.size * (0.5 + life_ratio * 0.5)
    @raylib.draw_cube(
      @raylib.Vector3::new(p.x, p.y, p.z),
      size,
      size,
      size,
      @raylib.Color::new(p.r, p.g, p.b, a),
    )
  }
}
