// 3D world rendering

pub fn draw_world(game : @types.Game) -> Unit {
  let camera = build_camera(game)
  @raylib.begin_mode_3d(camera)
  draw_arena_floor()
  draw_arena_walls()
  draw_pillars(game)
  draw_low_walls(game)
  draw_ramps(game)
  draw_crates(game)
  draw_barricades(game)
  draw_traps(game)
  draw_pickups_3d(game)
  draw_enemies(game)
  draw_projectiles(game)
  draw_particles_3d(game)
  @raylib.end_mode_3d()
}

fn build_camera(game : @types.Game) -> @raylib.Camera3D {
  @raylib.Camera3D::new(
    @raylib.Vector3::new(game.cam_pos_x, game.cam_pos_y, game.cam_pos_z),
    @raylib.Vector3::new(
      game.cam_target_x, game.cam_target_y, game.cam_target_z,
    ),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
}

fn draw_arena_floor() -> Unit {
  // Main floor
  @raylib.draw_plane(
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector2::new(@types.arena_width, @types.arena_depth),
    @raylib.Color::new(40, 45, 50, 255),
  )
  // Floor grid lines for visual reference
  let half_w = @types.arena_width / 2.0
  let half_d = @types.arena_depth / 2.0
  let grid_step : Float = 5.0
  let grid_color = @raylib.Color::new(55, 60, 65, 255)
  let mut gx : Float = -half_w
  while gx <= half_w {
    @raylib.draw_line_3d(
      @raylib.Vector3::new(gx, 0.01, -half_d),
      @raylib.Vector3::new(gx, 0.01, half_d),
      grid_color,
    )
    gx = gx + grid_step
  }
  let mut gz : Float = -half_d
  while gz <= half_d {
    @raylib.draw_line_3d(
      @raylib.Vector3::new(-half_w, 0.01, gz),
      @raylib.Vector3::new(half_w, 0.01, gz),
      grid_color,
    )
    gz = gz + grid_step
  }
  // Center circle marking
  let center_color = @raylib.Color::new(60, 65, 70, 255)
  let segments = 32
  for i = 0; i < segments; i = i + 1 {
    let a1 = Float::from_int(i) * 2.0 * @types.pi / Float::from_int(segments)
    let a2 = Float::from_int(i + 1) * 2.0 * @types.pi / Float::from_int(segments)
    let r : Float = 5.0
    @raylib.draw_line_3d(
      @raylib.Vector3::new(@math.cosf(a1) * r, 0.02, @math.sinf(a1) * r),
      @raylib.Vector3::new(@math.cosf(a2) * r, 0.02, @math.sinf(a2) * r),
      center_color,
    )
  }
}

fn draw_arena_walls() -> Unit {
  let half_w = @types.arena_width / 2.0
  let half_d = @types.arena_depth / 2.0
  let wh = @types.arena_wall_height
  let wt = @types.arena_wall_thickness
  let wall_color = @raylib.Color::new(70, 75, 85, 255)
  let wall_top_color = @raylib.Color::new(90, 95, 105, 255)
  let wall_stripe_color = @raylib.Color::new(120, 50, 50, 255)
  // North wall (positive Z)
  @raylib.draw_cube(
    @raylib.Vector3::new(0.0, wh / 2.0, half_d),
    @types.arena_width + wt * 2.0,
    wh,
    wt,
    wall_color,
  )
  // South wall (negative Z)
  @raylib.draw_cube(
    @raylib.Vector3::new(0.0, wh / 2.0, -half_d),
    @types.arena_width + wt * 2.0,
    wh,
    wt,
    wall_color,
  )
  // East wall (positive X)
  @raylib.draw_cube(
    @raylib.Vector3::new(half_w, wh / 2.0, 0.0),
    wt,
    wh,
    @types.arena_depth,
    wall_color,
  )
  // West wall (negative X)
  @raylib.draw_cube(
    @raylib.Vector3::new(-half_w, wh / 2.0, 0.0),
    wt,
    wh,
    @types.arena_depth,
    wall_color,
  )
  // Wall top trim
  @raylib.draw_cube(
    @raylib.Vector3::new(0.0, wh, half_d),
    @types.arena_width + wt * 2.0,
    0.2,
    wt + 0.2,
    wall_top_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(0.0, wh, -half_d),
    @types.arena_width + wt * 2.0,
    0.2,
    wt + 0.2,
    wall_top_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(half_w, wh, 0.0),
    wt + 0.2,
    0.2,
    @types.arena_depth,
    wall_top_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(-half_w, wh, 0.0),
    wt + 0.2,
    0.2,
    @types.arena_depth,
    wall_top_color,
  )
  // Warning stripes on walls at base
  let stripe_h : Float = 0.3
  @raylib.draw_cube(
    @raylib.Vector3::new(0.0, stripe_h / 2.0, half_d - wt * 0.5 + 0.02),
    @types.arena_width, stripe_h, 0.05, wall_stripe_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(0.0, stripe_h / 2.0, -half_d + wt * 0.5 - 0.02),
    @types.arena_width, stripe_h, 0.05, wall_stripe_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(half_w - wt * 0.5 + 0.02, stripe_h / 2.0, 0.0),
    0.05, stripe_h, @types.arena_depth, wall_stripe_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(-half_w + wt * 0.5 - 0.02, stripe_h / 2.0, 0.0),
    0.05, stripe_h, @types.arena_depth, wall_stripe_color,
  )
}

fn draw_pillars(game : @types.Game) -> Unit {
  for i = 0; i < game.pillars.length(); i = i + 1 {
    let pillar = game.pillars[i]
    let base_color = @raylib.Color::new(100, 95, 90, 255)
    let top_color = @raylib.Color::new(120, 115, 108, 255)
    let mid_band = @raylib.Color::new(80, 80, 75, 255)
    // Pillar body
    @raylib.draw_cylinder(
      @raylib.Vector3::new(pillar.x, 0.0, pillar.z),
      pillar.radius,
      pillar.radius,
      pillar.height,
      12,
      base_color,
    )
    // Pillar top cap
    @raylib.draw_cylinder(
      @raylib.Vector3::new(pillar.x, pillar.height, pillar.z),
      pillar.radius + 0.2,
      pillar.radius + 0.2,
      0.3,
      12,
      top_color,
    )
    // Pillar base
    @raylib.draw_cylinder(
      @raylib.Vector3::new(pillar.x, 0.0, pillar.z),
      pillar.radius + 0.15,
      pillar.radius + 0.15,
      0.3,
      12,
      top_color,
    )
    // Mid-section band
    @raylib.draw_cylinder(
      @raylib.Vector3::new(pillar.x, pillar.height * 0.5 - 0.1, pillar.z),
      pillar.radius + 0.05,
      pillar.radius + 0.05,
      0.2,
      12,
      mid_band,
    )
  }
}

fn draw_low_walls(game : @types.Game) -> Unit {
  let wall_color = @raylib.Color::new(85, 80, 75, 255)
  let wall_top = @raylib.Color::new(100, 95, 88, 255)
  for i = 0; i < game.low_walls.length(); i = i + 1 {
    let w = game.low_walls[i]
    // Main wall body
    @raylib.draw_cube(
      @raylib.Vector3::new(w.x, w.height / 2.0, w.z),
      w.width,
      w.height,
      w.depth,
      wall_color,
    )
    // Top trim
    @raylib.draw_cube(
      @raylib.Vector3::new(w.x, w.height, w.z),
      w.width + 0.1,
      0.1,
      w.depth + 0.1,
      wall_top,
    )
    // Wire frame
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(w.x, w.height / 2.0, w.z),
      w.width,
      w.height,
      w.depth,
      @raylib.Color::new(60, 55, 50, 255),
    )
  }
}

fn draw_ramps(game : @types.Game) -> Unit {
  let ramp_color = @raylib.Color::new(75, 80, 70, 255)
  let ramp_top = @raylib.Color::new(90, 95, 85, 255)
  for i = 0; i < game.ramps.length(); i = i + 1 {
    let r = game.ramps[i]
    // Draw ramp as a series of steps (approximation)
    let steps = 4
    for s = 0; s < steps; s = s + 1 {
      let step_frac = Float::from_int(s) / Float::from_int(steps)
      let next_frac = Float::from_int(s + 1) / Float::from_int(steps)
      let step_h = r.height * next_frac
      let step_y = step_h / 2.0
      let step_len = r.length / Float::from_int(steps)
      let step_offset = (step_frac - 0.5) * r.length
      let cos_a = @math.cosf(r.angle)
      let sin_a = @math.sinf(r.angle)
      let sx = r.x + sin_a * step_offset
      let sz = r.z + cos_a * step_offset
      let color = if s % 2 == 0 { ramp_color } else { ramp_top }
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, step_y, sz),
        r.width,
        step_h,
        step_len,
        color,
      )
    }
  }
}

fn draw_crates(game : @types.Game) -> Unit {
  for i = 0; i < game.crates.length(); i = i + 1 {
    let crate = game.crates[i]
    if not(crate.active) { continue i + 1 }
    let cs = @types.crate_size
    // Crate body
    let crate_color = if crate.kind == @types.weapon_shotgun {
      @raylib.Color::new(180, 120, 50, 255)
    } else if crate.kind == @types.weapon_rifle {
      @raylib.Color::new(50, 150, 50, 255)
    } else if crate.kind == @types.weapon_minigun {
      @raylib.Color::new(80, 80, 180, 255)
    } else {
      @raylib.Color::new(180, 50, 50, 255)
    }
    @raylib.draw_cube(
      @raylib.Vector3::new(crate.x, cs * 0.5, crate.z),
      cs,
      cs,
      cs,
      crate_color,
    )
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(crate.x, cs * 0.5, crate.z),
      cs,
      cs,
      cs,
      @raylib.Color::new(40, 30, 20, 255),
    )
    // Cross straps on crate
    @raylib.draw_cube(
      @raylib.Vector3::new(crate.x, cs * 0.5, crate.z),
      cs * 1.01,
      0.1,
      cs * 1.01,
      @raylib.Color::new(60, 50, 30, 255),
    )
    // Floating indicator above crate
    let bob = @math.sinf(
      Float::from_int(game.frame_counter) * 0.05 + Float::from_int(i) * 2.0,
    ) * 0.2
    let indicator_y = cs + 0.5 + bob
    @raylib.draw_sphere(
      @raylib.Vector3::new(crate.x, indicator_y, crate.z),
      0.15,
      @raylib.Color::new(255, 255, 100, 200),
    )
  }
}

fn draw_barricades(game : @types.Game) -> Unit {
  for i = 0; i < game.barricades.length(); i = i + 1 {
    let b = game.barricades[i]
    if not(b.active) { continue i + 1 }
    let bs = @types.barricade_size
    let hp_pct = b.hp / b.max_hp
    // Color varies with damage
    let r_val : Float = 140.0 - hp_pct * 40.0
    let g_val : Float = 100.0 + hp_pct * 30.0
    let b_val : Float = 50.0 + hp_pct * 20.0
    let barr_color = @raylib.Color::new(r_val.to_int(), g_val.to_int(), b_val.to_int(), 255)
    // Main body
    @raylib.draw_cube(
      @raylib.Vector3::new(b.x, 1.0, b.z),
      bs,
      2.0,
      bs,
      barr_color,
    )
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(b.x, 1.0, b.z),
      bs,
      2.0,
      bs,
      @raylib.Color::new(80, 60, 30, 255),
    )
    // Cross braces
    @raylib.draw_cube(
      @raylib.Vector3::new(b.x, 1.0, b.z),
      bs * 0.1,
      2.0,
      bs * 1.02,
      @raylib.Color::new(100, 80, 40, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(b.x, 1.0, b.z),
      bs * 1.02,
      2.0,
      bs * 0.1,
      @raylib.Color::new(100, 80, 40, 255),
    )
    // HP bar above barricade
    if hp_pct < 1.0 {
      let bar_w = bs * 1.2
      let bar_y : Float = 2.3
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, bar_y, b.z),
        bar_w, 0.08, 0.15,
        @raylib.Color::new(80, 0, 0, 200),
      )
      let fill_w = bar_w * hp_pct
      let fill_offset = (bar_w - fill_w) * 0.5
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x - fill_offset, bar_y, b.z),
        fill_w, 0.1, 0.15,
        @raylib.Color::new(0, 200, 0, 220),
      )
    }
  }
}

fn draw_traps(game : @types.Game) -> Unit {
  for i = 0; i < game.traps.length(); i = i + 1 {
    let trap = game.traps[i]
    if not(trap.active) { continue i + 1 }
    let trap_active = trap.active_timer > 0.0
    if trap.kind == @types.trap_spike {
      // Spike trap - base plate with spikes
      let plate_color = @raylib.Color::new(90, 80, 70, 255)
      @raylib.draw_cube(
        @raylib.Vector3::new(trap.x, 0.05, trap.z),
        1.8, 0.1, 1.8, plate_color,
      )
      // Spikes
      let spike_height : Float = if trap_active { 0.8 } else { 0.1 }
      let spike_color = if trap_active {
        @raylib.Color::new(200, 50, 50, 255)
      } else {
        @raylib.Color::new(150, 150, 150, 255)
      }
      for sx = -1; sx <= 1; sx = sx + 1 {
        for sz = -1; sz <= 1; sz = sz + 1 {
          let spike_x = trap.x + Float::from_int(sx) * 0.5
          let spike_z = trap.z + Float::from_int(sz) * 0.5
          @raylib.draw_cube(
            @raylib.Vector3::new(spike_x, spike_height / 2.0 + 0.1, spike_z),
            0.08, spike_height, 0.08, spike_color,
          )
        }
      }
    } else if trap.kind == @types.trap_flame {
      // Flame trap - vent with fire
      @raylib.draw_cube(
        @raylib.Vector3::new(trap.x, 0.05, trap.z),
        1.5, 0.1, 1.5,
        @raylib.Color::new(60, 60, 60, 255),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(trap.x, 0.08, trap.z),
        1.0, 0.06, 1.0,
        @raylib.Color::new(40, 40, 40, 255),
      )
      if trap_active {
        // Fire visual
        @raylib.draw_cube(
          @raylib.Vector3::new(trap.x, 0.6, trap.z),
          0.8, 1.0, 0.8,
          @raylib.Color::new(255, 150, 30, 150),
        )
        @raylib.draw_cube(
          @raylib.Vector3::new(trap.x, 1.0, trap.z),
          0.4, 0.8, 0.4,
          @raylib.Color::new(255, 200, 50, 120),
        )
      }
    } else {
      // Electric trap
      @raylib.draw_cube(
        @raylib.Vector3::new(trap.x, 0.15, trap.z),
        1.5, 0.3, 1.5,
        @raylib.Color::new(50, 60, 80, 255),
      )
      let glow_color = if trap_active {
        @raylib.Color::new(100, 150, 255, 200)
      } else {
        @raylib.Color::new(50, 80, 150, 150)
      }
      // Tesla coil
      @raylib.draw_cylinder(
        @raylib.Vector3::new(trap.x, 0.3, trap.z),
        0.15, 0.1, 0.8, 8, glow_color,
      )
      @raylib.draw_sphere(
        @raylib.Vector3::new(trap.x, 1.2, trap.z),
        0.2, glow_color,
      )
    }
  }
}

fn draw_pickups_3d(game : @types.Game) -> Unit {
  for i = 0; i < game.pickups.length(); i = i + 1 {
    let pickup = game.pickups[i]
    if not(pickup.active) { continue i + 1 }
    let rot_angle = Float::from_int(game.frame_counter) * 0.03 + Float::from_int(i) * 1.5
    let glow_pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.08) * 0.3 + 0.7
    let glow_alpha = (glow_pulse * 200.0).to_int()
    let ga = @types.clampi(glow_alpha, 100, 200)
    if pickup.kind == @types.pickup_health {
      // Health pack: green cube with cross
      @raylib.draw_cube(
        @raylib.Vector3::new(pickup.x, pickup.y, pickup.z),
        0.5, 0.5, 0.5,
        @raylib.Color::new(50, 200, 50, ga),
      )
      // Cross on top
      @raylib.draw_cube(
        @raylib.Vector3::new(pickup.x, pickup.y + 0.26, pickup.z),
        0.4, 0.05, 0.12,
        @raylib.Color::new(255, 255, 255, 255),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(pickup.x, pickup.y + 0.26, pickup.z),
        0.12, 0.05, 0.4,
        @raylib.Color::new(255, 255, 255, 255),
      )
    } else if pickup.kind == @types.pickup_ammo {
      // Ammo crate: brown cube
      @raylib.draw_cube(
        @raylib.Vector3::new(pickup.x, pickup.y, pickup.z),
        0.5, 0.35, 0.5,
        @raylib.Color::new(180, 150, 50, ga),
      )
      @raylib.draw_cube_wires(
        @raylib.Vector3::new(pickup.x, pickup.y, pickup.z),
        0.5, 0.35, 0.5,
        @raylib.Color::new(120, 100, 30, 255),
      )
    } else if pickup.kind == @types.pickup_speed_boost {
      // Speed boost: blue sphere
      @raylib.draw_sphere(
        @raylib.Vector3::new(pickup.x, pickup.y, pickup.z),
        0.3,
        @raylib.Color::new(50, 150, 255, ga),
      )
    } else if pickup.kind == @types.pickup_damage_boost {
      // Damage boost: red sphere
      @raylib.draw_sphere(
        @raylib.Vector3::new(pickup.x, pickup.y, pickup.z),
        0.3,
        @raylib.Color::new(255, 80, 50, ga),
      )
    } else if pickup.kind == @types.pickup_shield {
      // Shield: cyan sphere
      @raylib.draw_sphere(
        @raylib.Vector3::new(pickup.x, pickup.y, pickup.z),
        0.3,
        @raylib.Color::new(50, 200, 255, ga),
      )
    } else {
      // Nuke: pulsing gold sphere
      @raylib.draw_sphere(
        @raylib.Vector3::new(pickup.x, pickup.y, pickup.z),
        0.35,
        @raylib.Color::new(255, 215, 0, ga),
      )
      @raylib.draw_sphere(
        @raylib.Vector3::new(pickup.x, pickup.y, pickup.z),
        0.42,
        @raylib.Color::new(255, 255, 100, (ga / 3)),
      )
    }
    // Life indicator (fading when about to expire)
    if pickup.life < 5.0 {
      let blink = @math.sinf(Float::from_int(game.frame_counter) * 0.2) > 0.0
      if not(blink) { continue i + 1 }
    }
    ignore(rot_angle)
  }
}

fn draw_enemies(game : @types.Game) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let enemy = game.enemies[i]
    if not(enemy.active) { continue i + 1 }
    let color = enemy_color(enemy.kind, enemy.flash_timer > 0.0)
    let size = enemy.size
    if enemy.kind == @types.enemy_zombie {
      draw_zombie(enemy, color, size)
    } else if enemy.kind == @types.enemy_runner {
      draw_runner(enemy, color, size)
    } else if enemy.kind == @types.enemy_brute {
      draw_brute(enemy, color, size)
    } else if enemy.kind == @types.enemy_spitter {
      draw_spitter(enemy, color, size)
    } else if enemy.kind == @types.enemy_exploder {
      draw_exploder(enemy, color, size, game.frame_counter)
    } else if enemy.kind == @types.enemy_necromancer {
      draw_necromancer(enemy, color, size, game.frame_counter)
    } else if enemy.kind == @types.enemy_shielded {
      draw_shielded(enemy, color, size)
    } else {
      draw_boss(enemy, color, size, game.frame_counter)
    }
    // Health bar (only if damaged)
    if enemy.hp < enemy.max_hp {
      let hp_pct = enemy.hp / enemy.max_hp
      let bar_w = size * 1.4
      let bar_y = enemy.size * 1.6 + 0.2
      // Background
      @raylib.draw_cube(
        @raylib.Vector3::new(enemy.x, bar_y, enemy.z),
        bar_w, 0.08, 0.15,
        @raylib.Color::new(80, 0, 0, 200),
      )
      // Health fill
      let fill_w = bar_w * hp_pct
      let fill_offset = (bar_w - fill_w) * 0.5
      let hp_color = if hp_pct > 0.5 {
        @raylib.Color::new(0, 220, 0, 220)
      } else if hp_pct > 0.25 {
        @raylib.Color::new(220, 200, 0, 220)
      } else {
        @raylib.Color::new(220, 50, 0, 220)
      }
      @raylib.draw_cube(
        @raylib.Vector3::new(enemy.x - fill_offset, bar_y, enemy.z),
        fill_w, 0.1, 0.15, hp_color,
      )
    }
    // Stun indicator
    if enemy.stun_timer > 0.0 {
      @raylib.draw_sphere(
        @raylib.Vector3::new(enemy.x, enemy.size * 1.8, enemy.z),
        0.15,
        @raylib.Color::new(255, 255, 100, 200),
      )
    }
  }
}

fn draw_zombie(enemy : @types.Enemy, color : @raylib.Color, size : Float) -> Unit {
  // Zombie: blocky humanoid, slouching
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 0.7, enemy.z),
    size * 0.6, size * 1.0, size * 0.4, color,
  )
  // Head
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 1.3, enemy.z),
    size * 0.35, size * 0.35, size * 0.35,
    @raylib.Color::new(100, 150, 80, 255),
  )
  // Arms (drooping)
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.45, size * 0.55, enemy.z + size * 0.1),
    size * 0.15, size * 0.7, size * 0.15, color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.45, size * 0.6, enemy.z + size * 0.15),
    size * 0.15, size * 0.65, size * 0.15, color,
  )
  // Legs
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.15, size * 0.15, enemy.z),
    size * 0.18, size * 0.3, size * 0.18, @raylib.Color::new(60, 100, 50, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.15, size * 0.15, enemy.z),
    size * 0.18, size * 0.3, size * 0.18, @raylib.Color::new(60, 100, 50, 255),
  )
}

fn draw_runner(enemy : @types.Enemy, color : @raylib.Color, size : Float) -> Unit {
  // Runner: lean, sleek, long limbs
  // Slim body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 0.6, enemy.z),
    size * 0.35, size * 0.8, size * 0.25, color,
  )
  // Small head
  @raylib.draw_sphere(
    @raylib.Vector3::new(enemy.x, size * 1.1, enemy.z),
    size * 0.2, color,
  )
  // Long thin legs
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.12, size * 0.12, enemy.z),
    size * 0.1, size * 0.25, size * 0.1, @raylib.Color::new(40, 140, 60, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.12, size * 0.12, enemy.z),
    size * 0.1, size * 0.25, size * 0.1, @raylib.Color::new(40, 140, 60, 255),
  )
  // Thin arms
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.3, size * 0.6, enemy.z),
    size * 0.08, size * 0.5, size * 0.08, color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.3, size * 0.6, enemy.z),
    size * 0.08, size * 0.5, size * 0.08, color,
  )
}

fn draw_brute(enemy : @types.Enemy, color : @raylib.Color, size : Float) -> Unit {
  // Brute: large, bulky, armored
  // Wide body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 0.6, enemy.z),
    size * 0.9, size * 1.2, size * 0.7, color,
  )
  // Armored head
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 1.3, enemy.z),
    size * 0.5, size * 0.4, size * 0.5,
    @raylib.Color::new(100, 80, 120, 255),
  )
  // Shoulder pads
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.55, size * 1.0, enemy.z),
    size * 0.3, size * 0.3, size * 0.4,
    @raylib.Color::new(80, 60, 100, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.55, size * 1.0, enemy.z),
    size * 0.3, size * 0.3, size * 0.4,
    @raylib.Color::new(80, 60, 100, 255),
  )
  // Thick arms
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.55, size * 0.5, enemy.z),
    size * 0.25, size * 0.6, size * 0.25, color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.55, size * 0.5, enemy.z),
    size * 0.25, size * 0.6, size * 0.25, color,
  )
  // Thick legs
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.2, size * 0.15, enemy.z),
    size * 0.25, size * 0.3, size * 0.25,
    @raylib.Color::new(80, 50, 100, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.2, size * 0.15, enemy.z),
    size * 0.25, size * 0.3, size * 0.25,
    @raylib.Color::new(80, 50, 100, 255),
  )
}

fn draw_spitter(enemy : @types.Enemy, color : @raylib.Color, size : Float) -> Unit {
  // Spitter: hunched, with glowing mouth
  // Hunched body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 0.5, enemy.z),
    size * 0.5, size * 0.7, size * 0.4, color,
  )
  // Head with glowing area
  @raylib.draw_sphere(
    @raylib.Vector3::new(enemy.x, size * 0.9, enemy.z),
    size * 0.25,
    @raylib.Color::new(50, 200, 80, 255),
  )
  // Extended jaw/mouth
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 0.75, enemy.z + size * 0.25),
    size * 0.2, size * 0.15, size * 0.2,
    @raylib.Color::new(80, 220, 50, 255),
  )
  // Thin arms
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.35, size * 0.45, enemy.z),
    size * 0.1, size * 0.5, size * 0.1, color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.35, size * 0.45, enemy.z),
    size * 0.1, size * 0.5, size * 0.1, color,
  )
}

fn draw_exploder(enemy : @types.Enemy, color : @raylib.Color, size : Float, frame : Int) -> Unit {
  // Exploder: bloated body, glowing cracks
  let base_color = if enemy.explode_triggered {
    let pulse = @math.sinf(Float::from_int(frame) * 0.3) * 0.5 + 0.5
    let r_f : Float = 255.0 * pulse
    @raylib.Color::new(r_f.to_int(), 100, 30, 255)
  } else {
    color
  }
  // Bloated body
  @raylib.draw_sphere(
    @raylib.Vector3::new(enemy.x, size * 0.6, enemy.z),
    size * 0.5, base_color,
  )
  // Crack lines (glowing cubes)
  let crack_color = @raylib.Color::new(255, 200, 50, 200)
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.1, size * 0.7, enemy.z + size * 0.2),
    size * 0.04, size * 0.4, size * 0.04, crack_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.15, size * 0.5, enemy.z - size * 0.15),
    size * 0.04, size * 0.3, size * 0.04, crack_color,
  )
  // Small head
  @raylib.draw_sphere(
    @raylib.Vector3::new(enemy.x, size * 1.0, enemy.z),
    size * 0.15, base_color,
  )
  // Short legs
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.15, size * 0.1, enemy.z),
    size * 0.15, size * 0.2, size * 0.15,
    @raylib.Color::new(150, 100, 50, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.15, size * 0.1, enemy.z),
    size * 0.15, size * 0.2, size * 0.15,
    @raylib.Color::new(150, 100, 50, 255),
  )
}

fn draw_necromancer(enemy : @types.Enemy, color : @raylib.Color, size : Float, frame : Int) -> Unit {
  // Necromancer: robed figure with staff
  // Robe body (wider at bottom)
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 0.5, enemy.z),
    size * 0.5, size * 0.8, size * 0.5, color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 0.15, enemy.z),
    size * 0.7, size * 0.3, size * 0.7,
    @raylib.Color::new(60, 30, 100, 255),
  )
  // Hood/head
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 1.05, enemy.z),
    size * 0.35, size * 0.35, size * 0.35,
    @raylib.Color::new(40, 20, 60, 255),
  )
  // Glowing eyes
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.08, size * 1.1, enemy.z + size * 0.18),
    size * 0.06, size * 0.06, size * 0.06,
    @raylib.Color::new(200, 50, 255, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.08, size * 1.1, enemy.z + size * 0.18),
    size * 0.06, size * 0.06, size * 0.06,
    @raylib.Color::new(200, 50, 255, 255),
  )
  // Staff
  let staff_glow = @math.sinf(Float::from_int(frame) * 0.05) * 0.3 + 0.7
  let glow_val : Float = staff_glow * 255.0
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.4, size * 0.7, enemy.z),
    size * 0.06, size * 1.4, size * 0.06,
    @raylib.Color::new(80, 50, 30, 255),
  )
  // Staff orb
  @raylib.draw_sphere(
    @raylib.Vector3::new(enemy.x + size * 0.4, size * 1.4, enemy.z),
    size * 0.12,
    @raylib.Color::new(glow_val.to_int(), 50, 255, 200),
  )
}

fn draw_shielded(enemy : @types.Enemy, color : @raylib.Color, size : Float) -> Unit {
  // Shielded: body with front shield panel
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 0.6, enemy.z),
    size * 0.6, size * 1.0, size * 0.5, color,
  )
  // Head
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 1.2, enemy.z),
    size * 0.3, size * 0.3, size * 0.3,
    @raylib.Color::new(80, 80, 120, 255),
  )
  // Shield (facing player based on facing_angle)
  let shield_dist : Float = size * 0.45
  let shield_x = enemy.x + @math.sinf(enemy.facing_angle) * shield_dist
  let shield_z = enemy.z + @math.cosf(enemy.facing_angle) * shield_dist
  @raylib.draw_cube(
    @raylib.Vector3::new(shield_x, size * 0.7, shield_z),
    size * 0.8, size * 1.2, size * 0.12,
    @raylib.Color::new(150, 160, 200, 230),
  )
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(shield_x, size * 0.7, shield_z),
    size * 0.8, size * 1.2, size * 0.12,
    @raylib.Color::new(180, 190, 220, 255),
  )
  // Arms
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.4, size * 0.6, enemy.z),
    size * 0.15, size * 0.6, size * 0.15, color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.4, size * 0.6, enemy.z),
    size * 0.15, size * 0.6, size * 0.15, color,
  )
}

fn draw_boss(enemy : @types.Enemy, color : @raylib.Color, size : Float, frame : Int) -> Unit {
  // Boss: imposing, with crown-like features, phased appearance
  let phase_color = if enemy.boss_phase >= 3 {
    @raylib.Color::new(255, 50, 50, 255)
  } else if enemy.boss_phase >= 2 {
    @raylib.Color::new(255, 120, 50, 255)
  } else if enemy.boss_phase >= 1 {
    @raylib.Color::new(220, 100, 180, 255)
  } else {
    color
  }
  // Large body
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 0.7, enemy.z),
    size * 0.8, size * 1.4, size * 0.6, phase_color,
  )
  // Crown/horns
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x, size * 1.6, enemy.z),
    size * 0.6, size * 0.4, size * 0.6,
    @raylib.Color::new(200, 180, 50, 255),
  )
  // Horn spikes
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.25, size * 1.85, enemy.z),
    size * 0.08, size * 0.3, size * 0.08,
    @raylib.Color::new(220, 200, 50, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.25, size * 1.85, enemy.z),
    size * 0.08, size * 0.3, size * 0.08,
    @raylib.Color::new(220, 200, 50, 255),
  )
  // Eyes (glowing cubes)
  let eye_pulse = @math.sinf(Float::from_int(frame) * 0.1) * 50.0 + 205.0
  let eye_val = eye_pulse.to_int()
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.2, size * 1.3, enemy.z + size * 0.35),
    size * 0.12, size * 0.12, size * 0.12,
    @raylib.Color::new(eye_val, 50, 50, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.2, size * 1.3, enemy.z + size * 0.35),
    size * 0.12, size * 0.12, size * 0.12,
    @raylib.Color::new(eye_val, 50, 50, 255),
  )
  // Massive arms
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.55, size * 0.6, enemy.z),
    size * 0.25, size * 0.9, size * 0.25, phase_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.55, size * 0.6, enemy.z),
    size * 0.25, size * 0.9, size * 0.25, phase_color,
  )
  // Fists
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.55, size * 0.12, enemy.z),
    size * 0.3, size * 0.3, size * 0.3,
    @raylib.Color::new(150, 80, 150, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.55, size * 0.12, enemy.z),
    size * 0.3, size * 0.3, size * 0.3,
    @raylib.Color::new(150, 80, 150, 255),
  )
  // Legs
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x + size * 0.2, size * 0.15, enemy.z),
    size * 0.25, size * 0.3, size * 0.25, phase_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(enemy.x - size * 0.2, size * 0.15, enemy.z),
    size * 0.25, size * 0.3, size * 0.25, phase_color,
  )
  // Phase aura
  if enemy.boss_phase >= 2 {
    let aura_size = size * 1.2
    let aura_alpha : Float = @math.sinf(Float::from_int(frame) * 0.08) * 30.0 + 40.0
    let aura_a = aura_alpha.to_int()
    @raylib.draw_sphere(
      @raylib.Vector3::new(enemy.x, size * 0.7, enemy.z),
      aura_size,
      @raylib.Color::new(255, 50, 50, aura_a),
    )
  }
}

fn enemy_color(kind : Int, is_flashing : Bool) -> @raylib.Color {
  if is_flashing {
    return @raylib.Color::new(255, 255, 255, 255)
  }
  if kind == @types.enemy_zombie {
    @raylib.Color::new(80, 140, 60, 255)
  } else if kind == @types.enemy_runner {
    @raylib.Color::new(60, 180, 80, 255)
  } else if kind == @types.enemy_brute {
    @raylib.Color::new(120, 80, 160, 255)
  } else if kind == @types.enemy_spitter {
    @raylib.Color::new(60, 160, 100, 255)
  } else if kind == @types.enemy_exploder {
    @raylib.Color::new(200, 140, 50, 255)
  } else if kind == @types.enemy_necromancer {
    @raylib.Color::new(100, 50, 150, 255)
  } else if kind == @types.enemy_shielded {
    @raylib.Color::new(80, 100, 160, 255)
  } else {
    // Boss
    @raylib.Color::new(180, 40, 180, 255)
  }
}

fn draw_projectiles(game : @types.Game) -> Unit {
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    let proj = game.projectiles[i]
    if not(proj.active) { continue i + 1 }
    if proj.is_enemy {
      if proj.kind == @types.enemy_boss {
        // Boss projectile: purple sphere
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.25,
          @raylib.Color::new(200, 50, 200, 255),
        )
        // Trail
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x - proj.dx * 0.2, proj.y - proj.dy * 0.2, proj.z - proj.dz * 0.2),
          0.15,
          @raylib.Color::new(150, 30, 150, 150),
        )
      } else {
        // Enemy spit: green sphere
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.2,
          @raylib.Color::new(80, 220, 50, 255),
        )
      }
    } else if proj.kind == @types.weapon_rocket {
      // Rocket: larger, with trail
      @raylib.draw_sphere(
        @raylib.Vector3::new(proj.x, proj.y, proj.z),
        0.25,
        @raylib.Color::new(200, 80, 30, 255),
      )
      // Exhaust trail
      @raylib.draw_sphere(
        @raylib.Vector3::new(
          proj.x - proj.dx * 0.3, proj.y - proj.dy * 0.3,
          proj.z - proj.dz * 0.3,
        ),
        0.15,
        @raylib.Color::new(255, 180, 50, 180),
      )
      @raylib.draw_sphere(
        @raylib.Vector3::new(
          proj.x - proj.dx * 0.5, proj.y - proj.dy * 0.5,
          proj.z - proj.dz * 0.5,
        ),
        0.1,
        @raylib.Color::new(200, 100, 30, 120),
      )
    } else if proj.kind == @types.weapon_shotgun {
      // Shotgun pellet: small
      @raylib.draw_sphere(
        @raylib.Vector3::new(proj.x, proj.y, proj.z),
        0.06,
        @raylib.Color::new(255, 220, 100, 255),
      )
    } else if proj.kind == @types.weapon_sniper {
      // Sniper: bright tracer line
      @raylib.draw_sphere(
        @raylib.Vector3::new(proj.x, proj.y, proj.z),
        0.05,
        @raylib.Color::new(255, 255, 200, 255),
      )
      // Long trail
      @raylib.draw_line_3d(
        @raylib.Vector3::new(proj.x, proj.y, proj.z),
        @raylib.Vector3::new(
          proj.x - proj.dx * 1.5, proj.y - proj.dy * 1.5, proj.z - proj.dz * 1.5,
        ),
        @raylib.Color::new(255, 255, 150, 200),
      )
    } else if proj.kind == @types.weapon_minigun {
      // Minigun bullet: tiny fast
      @raylib.draw_sphere(
        @raylib.Vector3::new(proj.x, proj.y, proj.z),
        0.04,
        @raylib.Color::new(255, 200, 50, 255),
      )
    } else {
      // Pistol/Rifle bullet
      let color = if proj.kind == @types.weapon_pistol {
        @raylib.Color::new(255, 230, 150, 255)
      } else {
        @raylib.Color::new(255, 200, 50, 255)
      }
      @raylib.draw_sphere(
        @raylib.Vector3::new(proj.x, proj.y, proj.z), 0.08, color,
      )
    }
  }
}

fn draw_particles_3d(game : @types.Game) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) { continue i + 1 }
    let alpha = (p.life / p.max_life * 255.0).to_int()
    let a = @types.clampi(alpha, 0, 255)
    if p.kind == @types.particle_shell {
      // Shell casings: elongated
      @raylib.draw_cube(
        @raylib.Vector3::new(p.x, p.y, p.z),
        0.02, 0.06, 0.02,
        @raylib.Color::new(p.r, p.g, p.b, a),
      )
    } else if p.kind == @types.particle_spark {
      // Sparks: bright, small
      @raylib.draw_sphere(
        @raylib.Vector3::new(p.x, p.y, p.z),
        p.size * 0.5,
        @raylib.Color::new(p.r, p.g, p.b, a),
      )
    } else {
      @raylib.draw_cube(
        @raylib.Vector3::new(p.x, p.y, p.z),
        p.size, p.size, p.size,
        @raylib.Color::new(p.r, p.g, p.b, a),
      )
    }
  }
}
