// 3D world rendering

///|
pub fn draw_world(game : @types.Game) -> Unit {
  let camera = build_camera(game)
  @raylib.begin_mode_3d(camera)
  draw_celestial_body(game)
  draw_terrain(game)
  draw_terrain_details(game)
  draw_buildings(game)
  draw_turrets_3d(game)
  draw_checkpoints(game)
  draw_enemies(game)
  draw_projectiles(game)
  draw_tracer_trails(game)
  draw_particles_3d(game)
  draw_player_aircraft(game)
  draw_engine_trail(game)
  draw_damage_smoke(game)
  draw_enemy_damage_trails(game)
  draw_landing_zone(game)
  draw_clouds(game)
  draw_rain_effect(game)
  draw_fog_overlay(game)
  @raylib.end_mode_3d()
}

///|
fn build_camera(game : @types.Game) -> @raylib.Camera3D {
  @raylib.Camera3D::new(
    @raylib.Vector3::new(game.cam_x, game.cam_y, game.cam_z),
    @raylib.Vector3::new(
      game.cam_target_x,
      game.cam_target_y,
      game.cam_target_z,
    ),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
}

///|
fn draw_terrain(game : @types.Game) -> Unit {
  let scale = @types.terrain_chunk_scale
  for i in 0..<game.terrain.length() {
    let t = game.terrain[i]
    if not(t.active) {
      continue
    }
    let wx = Float::from_int(t.grid_x) * scale
    let wz = Float::from_int(t.grid_z) * scale
    let h = t.height
    let draw_h : Float = if h < 0.5 { 0.5 } else { h }
    // Main terrain block
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, draw_h / 2.0, wz),
      scale,
      draw_h,
      scale,
      @raylib.Color::new(t.color_r, t.color_g, t.color_b, 255),
    )
    // Water surface at low terrain
    if h < 1.0 {
      @raylib.draw_cube(
        @raylib.Vector3::new(wx, 0.5, wz),
        scale,
        0.1,
        scale,
        @raylib.Color::new(30, 80, 200, 120),
      )
    }
  }
}

///|
fn draw_checkpoints(game : @types.Game) -> Unit {
  for i in 0..<game.checkpoints.length() {
    let cp = game.checkpoints[i]
    if not(cp.active) || cp.collected {
      continue
    }
    // Draw checkpoint ring using cubes arranged in a circle
    let segments = 12
    let radius = cp.radius * 0.5
    for s in 0..<segments {
      let angle = Float::from_int(s) *
        @types.pi *
        2.0 /
        Float::from_int(segments)
      let rx = cp.x + @math.cosf(angle) * radius
      let ry = cp.y + @math.sinf(angle) * radius
      let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.1)
      let green_val = 200 + (pulse * 55.0).to_int()
      @raylib.draw_cube(
        @raylib.Vector3::new(rx, ry, cp.z),
        0.6,
        0.6,
        0.6,
        @raylib.Color::new(50, @types.clampi(green_val, 0, 255), 50, 200),
      )
    }
    // Also draw ring in XZ plane
    for s in 0..<segments {
      let angle = Float::from_int(s) *
        @types.pi *
        2.0 /
        Float::from_int(segments)
      let rx = cp.x + @math.cosf(angle) * radius
      let rz = cp.z + @math.sinf(angle) * radius
      @raylib.draw_cube(
        @raylib.Vector3::new(rx, cp.y, rz),
        0.5,
        0.5,
        0.5,
        @raylib.Color::new(50, 255, 100, 180),
      )
    }
  }
}

///|
fn draw_enemies(game : @types.Game) -> Unit {
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    // Check distance to player for culling
    let dist = @types.distance3d(
      game.player.x,
      game.player.y,
      game.player.z,
      e.x,
      e.y,
      e.z,
    )
    if dist > game.draw_distance {
      continue
    }
    if e.kind == @types.enemy_type_ground {
      // Ground turret: box base + cylinder barrel
      let flash_color = if e.flash_timer > 0.0 {
        @raylib.Color::new(255, 200, 100, 255)
      } else {
        @raylib.Color::new(120, 60, 60, 255)
      }
      @raylib.draw_cube(
        @raylib.Vector3::new(e.x, e.y, e.z),
        e.size,
        e.size * 0.8,
        e.size,
        flash_color,
      )
      // Turret top
      @raylib.draw_cube(
        @raylib.Vector3::new(e.x, e.y + e.size * 0.6, e.z),
        e.size * 0.5,
        e.size * 0.4,
        e.size * 0.5,
        @raylib.Color::new(80, 40, 40, 255),
      )
    } else {
      // Air fighter: elongated body + wings
      let flash_color = if e.flash_timer > 0.0 {
        @raylib.Color::new(255, 200, 100, 255)
      } else {
        @raylib.Color::new(180, 50, 50, 255)
      }
      // Fuselage
      @raylib.draw_cube(
        @raylib.Vector3::new(e.x, e.y, e.z),
        e.size * 0.4,
        e.size * 0.3,
        e.size * 1.2,
        flash_color,
      )
      // Wings
      @raylib.draw_cube(
        @raylib.Vector3::new(e.x, e.y, e.z),
        e.size * 2.0,
        e.size * 0.1,
        e.size * 0.5,
        @raylib.Color::new(160, 40, 40, 255),
      )
      // Tail
      @raylib.draw_cube(
        @raylib.Vector3::new(e.x, e.y + e.size * 0.3, e.z - e.size * 0.5),
        e.size * 0.6,
        e.size * 0.4,
        e.size * 0.15,
        @raylib.Color::new(150, 40, 40, 255),
      )
    }
    // Health bar (when damaged)
    if e.hp < e.max_hp {
      let bar_w : Float = 2.0
      let ratio = e.hp / e.max_hp
      let bar_y = e.y + e.size + 0.5
      @raylib.draw_cube(
        @raylib.Vector3::new(e.x, bar_y, e.z),
        bar_w,
        0.15,
        0.15,
        @raylib.Color::new(255, 0, 0, 200),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(
          e.x - bar_w * (1.0 - ratio) / 2.0,
          bar_y + 0.01,
          e.z,
        ),
        bar_w * ratio,
        0.15,
        0.15,
        @raylib.Color::new(0, 255, 0, 200),
      )
    }
  }
}

///|
fn draw_projectiles(game : @types.Game) -> Unit {
  for i in 0..<game.projectiles.length() {
    let p = game.projectiles[i]
    if not(p.active) {
      continue
    }
    let color = if p.is_enemy {
      @raylib.Color::new(255, 80, 30, 255)
    } else {
      @raylib.Color::new(255, 255, 50, 255)
    }
    @raylib.draw_sphere(@raylib.Vector3::new(p.x, p.y, p.z), 0.2, color)
    // Trail
    let trail_x = p.x - p.dx * 0.3
    let trail_y = p.y - p.dy * 0.3
    let trail_z = p.z - p.dz * 0.3
    let trail_color = if p.is_enemy {
      @raylib.Color::new(255, 100, 50, 120)
    } else {
      @raylib.Color::new(255, 200, 50, 120)
    }
    @raylib.draw_sphere(
      @raylib.Vector3::new(trail_x, trail_y, trail_z),
      0.12,
      trail_color,
    )
  }
}

///|
fn draw_particles_3d(game : @types.Game) -> Unit {
  for i in 0..<game.particles.length() {
    let p = game.particles[i]
    if not(p.active) {
      continue
    }
    let alpha = (p.life / p.max_life * 255.0).to_int()
    let a = @types.clampi(alpha, 0, 255)
    @raylib.draw_cube(
      @raylib.Vector3::new(p.x, p.y, p.z),
      p.size,
      p.size,
      p.size,
      @raylib.Color::new(p.r, p.g, p.b, a),
    )
  }
}

///|
fn draw_player_aircraft(game : @types.Game) -> Unit {
  let player = game.player
  if not(player.alive) {
    return
  }
  // Draw player aircraft (visible from chase cam)
  let (fx, fy, fz) = @types.get_forward(player.pitch, player.yaw)
  let (rx, ry, rz) = @types.get_right(player.yaw, player.roll)
  let size = @types.aircraft_size
  // Fuselage
  @raylib.draw_cube(
    @raylib.Vector3::new(player.x, player.y, player.z),
    size * 0.4,
    size * 0.3,
    size * 1.5,
    @raylib.Color::new(80, 120, 200, 255),
  )
  // Wings (stretched along right vector)
  @raylib.draw_cube(
    @raylib.Vector3::new(player.x, player.y, player.z),
    size * 2.5,
    size * 0.08,
    size * 0.6,
    @raylib.Color::new(60, 100, 180, 255),
  )
  // Tail fin
  @raylib.draw_cube(
    @raylib.Vector3::new(
      player.x - fx * size * 0.8,
      player.y - fy * size * 0.8 + size * 0.3,
      player.z - fz * size * 0.8,
    ),
    size * 0.08,
    size * 0.5,
    size * 0.3,
    @raylib.Color::new(60, 100, 180, 255),
  )
  // Tail wings
  @raylib.draw_cube(
    @raylib.Vector3::new(
      player.x - fx * size * 0.7,
      player.y - fy * size * 0.7,
      player.z - fz * size * 0.7,
    ),
    size * 1.0,
    size * 0.06,
    size * 0.25,
    @raylib.Color::new(70, 110, 190, 255),
  )
  // Cockpit
  @raylib.draw_sphere(
    @raylib.Vector3::new(
      player.x + fx * size * 0.4,
      player.y + fy * size * 0.4 + size * 0.1,
      player.z + fz * size * 0.4,
    ),
    size * 0.2,
    @raylib.Color::new(150, 200, 255, 180),
  )
  // Engine exhaust
  if player.throttle > 0.3 {
    let ex = player.x - fx * size * 0.9
    let ey = player.y - fy * size * 0.9
    let ez = player.z - fz * size * 0.9
    let flame_size = size * 0.15 * (0.5 + player.throttle * 0.5)
    @raylib.draw_sphere(
      @raylib.Vector3::new(ex, ey, ez),
      flame_size,
      @raylib.Color::new(255, 180, 50, 200),
    )
  }
  ignore(rx)
  ignore(ry)
  ignore(rz)
}

// Draw buildings with type-specific detail

///|
fn draw_buildings(game : @types.Game) -> Unit {
  for i in 0..<game.buildings.length() {
    let b = game.buildings[i]
    if not(b.active) {
      continue
    }
    // Distance culling
    let dist = @types.distance3d(
      game.player.x,
      game.player.y,
      game.player.z,
      b.x,
      b.y + b.height / 2.0,
      b.z,
    )
    if dist > game.draw_distance {
      continue
    }
    let flash = b.flash_timer > 0.0
    if b.kind == @types.building_hangar {
      // Hangar: large box with arched roof approximation
      let base_color = if flash {
        @raylib.Color::new(255, 200, 100, 255)
      } else {
        @raylib.Color::new(120, 130, 140, 255)
      }
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.4, b.z),
        b.width,
        b.height * 0.8,
        b.depth,
        base_color,
      )
      // Roof peak
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.85, b.z),
        b.width * 0.8,
        b.height * 0.3,
        b.depth * 0.95,
        @raylib.Color::new(100, 110, 120, 255),
      )
      // Door opening
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.25, b.z + b.depth * 0.5),
        b.width * 0.5,
        b.height * 0.5,
        0.3,
        @raylib.Color::new(50, 50, 60, 255),
      )
    } else if b.kind == @types.building_tower {
      // Control tower: thin tall structure with observation deck
      let tower_color = if flash {
        @raylib.Color::new(255, 200, 100, 255)
      } else {
        @raylib.Color::new(180, 180, 190, 255)
      }
      // Main tower shaft
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.4, b.z),
        b.width,
        b.height * 0.8,
        b.depth,
        tower_color,
      )
      // Observation deck (wider at top)
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.85, b.z),
        b.width * 1.5,
        b.height * 0.15,
        b.depth * 1.5,
        @raylib.Color::new(150, 160, 170, 255),
      )
      // Windows on observation deck
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.87, b.z),
        b.width * 1.4,
        b.height * 0.1,
        b.depth * 1.4,
        @raylib.Color::new(100, 180, 255, 150),
      )
      // Antenna on top
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 1.05, b.z),
        0.15,
        b.height * 0.2,
        0.15,
        @raylib.Color::new(200, 200, 200, 255),
      )
    } else if b.kind == @types.building_runway {
      // Runway: flat with markings
      let runway_color = if flash {
        @raylib.Color::new(200, 200, 200, 255)
      } else {
        @raylib.Color::new(60, 60, 65, 255)
      }
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + 0.05, b.z),
        b.width,
        0.1,
        b.depth,
        runway_color,
      )
      // Center line markings
      let num_marks = 5
      for m in 0..<num_marks {
        let mark_z = b.z - b.depth * 0.4 + Float::from_int(m) * b.depth * 0.2
        @raylib.draw_cube(
          @raylib.Vector3::new(b.x, b.y + 0.12, mark_z),
          0.2,
          0.02,
          1.5,
          @raylib.Color::new(255, 255, 255, 200),
        )
        ignore(m)
      }
    } else if b.kind == @types.building_house {
      // House: simple box with peaked roof
      let house_color = if flash {
        @raylib.Color::new(255, 200, 100, 255)
      } else {
        @raylib.Color::new(180, 160, 130, 255)
      }
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.4, b.z),
        b.width,
        b.height * 0.8,
        b.depth,
        house_color,
      )
      // Roof
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.9, b.z),
        b.width * 1.1,
        b.height * 0.25,
        b.depth * 1.1,
        @raylib.Color::new(160, 80, 50, 255),
      )
      // Window
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x + b.width * 0.35, b.y + b.height * 0.45, b.z),
        0.1,
        b.height * 0.2,
        b.depth * 0.25,
        @raylib.Color::new(100, 180, 255, 180),
      )
    } else if b.kind == @types.building_factory {
      // Factory: large industrial building with smokestacks
      let factory_color = if flash {
        @raylib.Color::new(255, 200, 100, 255)
      } else {
        @raylib.Color::new(140, 130, 120, 255)
      }
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.4, b.z),
        b.width,
        b.height * 0.8,
        b.depth,
        factory_color,
      )
      // Smokestack 1
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x + b.width * 0.3, b.y + b.height * 0.9, b.z),
        0.8,
        b.height * 0.4,
        0.8,
        @raylib.Color::new(100, 90, 85, 255),
      )
      // Smokestack 2
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x - b.width * 0.3, b.y + b.height * 0.85, b.z),
        0.6,
        b.height * 0.35,
        0.6,
        @raylib.Color::new(110, 100, 90, 255),
      )
      // Roof detail
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.82, b.z),
        b.width * 0.9,
        b.height * 0.05,
        b.depth * 0.9,
        @raylib.Color::new(120, 110, 100, 255),
      )
    } else {
      // Bunker: low reinforced structure
      let bunker_color = if flash {
        @raylib.Color::new(255, 200, 100, 255)
      } else {
        @raylib.Color::new(90, 100, 90, 255)
      }
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.4, b.z),
        b.width,
        b.height * 0.8,
        b.depth,
        bunker_color,
      )
      // Reinforcement rings
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.85, b.z),
        b.width * 1.05,
        b.height * 0.1,
        b.depth * 1.05,
        @raylib.Color::new(70, 80, 70, 255),
      )
      // Gun slit
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.5, b.z + b.depth * 0.5),
        b.width * 0.3,
        b.height * 0.1,
        0.2,
        @raylib.Color::new(30, 30, 30, 255),
      )
    }
    // Damage indicator: dark cracks for damaged buildings
    if b.hp < b.max_hp * 0.5 {
      let hp_rat = b.hp / b.max_hp
      let dmg_frac : Float = 1.0 - hp_rat
      let dmg_alpha = (dmg_frac * 150.0).to_int()
      let da = @types.clampi(dmg_alpha, 20, 150)
      @raylib.draw_cube(
        @raylib.Vector3::new(b.x, b.y + b.height * 0.5, b.z),
        b.width * 0.7,
        b.height * 0.5,
        b.depth * 0.7,
        @raylib.Color::new(30, 20, 10, da),
      )
    }
  }
}

// Draw anti-aircraft turrets with detail

///|
fn draw_turrets_3d(game : @types.Game) -> Unit {
  for i in 0..<game.turrets.length() {
    let t = game.turrets[i]
    if not(t.active) {
      continue
    }
    // Distance culling
    let dist = @types.distance3d(
      game.player.x,
      game.player.y,
      game.player.z,
      t.x,
      t.y,
      t.z,
    )
    if dist > game.draw_distance {
      continue
    }
    let flash = t.flash_timer > 0.0
    // Base platform
    @raylib.draw_cube(
      @raylib.Vector3::new(t.x, t.y + 0.3, t.z),
      3.0,
      0.6,
      3.0,
      @raylib.Color::new(80, 85, 80, 255),
    )
    // Turret body (rotating)
    let body_color = if flash {
      @raylib.Color::new(255, 220, 100, 255)
    } else {
      @raylib.Color::new(100, 110, 100, 255)
    }
    @raylib.draw_cube(
      @raylib.Vector3::new(t.x, t.y + 0.9, t.z),
      1.8,
      1.0,
      1.8,
      body_color,
    )
    // Gun barrel (approximated as elongated cube)
    let barrel_len : Float = 2.5
    let barrel_dx = @math.sinf(t.rotation) * @math.cosf(t.elevation)
    let barrel_dy = @math.sinf(t.elevation)
    let barrel_dz = @math.cosf(t.rotation) * @math.cosf(t.elevation)
    let barrel_cx = t.x + barrel_dx * barrel_len * 0.5
    let barrel_cy = t.y + 1.2 + barrel_dy * barrel_len * 0.5
    let barrel_cz = t.z + barrel_dz * barrel_len * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(barrel_cx, barrel_cy, barrel_cz),
      0.3,
      0.3,
      barrel_len,
      @raylib.Color::new(60, 65, 60, 255),
    )
    // Muzzle flash
    if flash {
      let flash_x = t.x + barrel_dx * barrel_len
      let flash_y = t.y + 1.2 + barrel_dy * barrel_len
      let flash_z = t.z + barrel_dz * barrel_len
      @raylib.draw_sphere(
        @raylib.Vector3::new(flash_x, flash_y, flash_z),
        0.5,
        @raylib.Color::new(255, 255, 150, 200),
      )
    }
    // Health bar above turret
    if t.hp < t.max_hp {
      let bar_w : Float = 2.5
      let ratio = t.hp / t.max_hp
      let bar_y = t.y + 2.5
      @raylib.draw_cube(
        @raylib.Vector3::new(t.x, bar_y, t.z),
        bar_w,
        0.15,
        0.15,
        @raylib.Color::new(255, 0, 0, 180),
      )
      let health_w = bar_w * ratio
      let health_offset = (bar_w - health_w) * 0.5
      @raylib.draw_cube(
        @raylib.Vector3::new(t.x - health_offset, bar_y + 0.01, t.z),
        health_w,
        0.15,
        0.15,
        @raylib.Color::new(0, 255, 0, 180),
      )
    }
  }
}

// Draw terrain detail: trees and rocks at close range

///|
fn draw_terrain_details(game : @types.Game) -> Unit {
  let scale = @types.terrain_chunk_scale
  let detail_range : Float = 50.0
  for i in 0..<game.terrain.length() {
    let t = game.terrain[i]
    if not(t.active) {
      continue
    }
    let wx = Float::from_int(t.grid_x) * scale
    let wz = Float::from_int(t.grid_z) * scale
    // Only draw details for nearby terrain
    let dist = @types.distance2d(game.player.x, game.player.z, wx, wz)
    if dist > detail_range {
      continue
    }
    let h = t.height
    // Trees on forest-height terrain
    if h > @types.terrain_forest_level && h < @types.terrain_snow_level - 2.0 {
      // Deterministic tree placement using grid position as seed
      let seed = t.grid_x * 73 + t.grid_z * 37
      let seed_abs = if seed < 0 { -seed } else { seed }
      let tree_chance = seed_abs % 100
      if tree_chance < 30 {
        let tree_offset_x = Float::from_int(seed_abs % 7) * 0.5
        let tree_x : Float = wx + tree_offset_x - 1.5
        let tree_offset_z = Float::from_int(seed_abs / 7 % 7) * 0.5
        let tree_z : Float = wz + tree_offset_z - 1.5
        let tree_base : Float = Float::from_int(seed_abs % 4) * 0.5
        let tree_h : Float = 2.0 + tree_base
        // Tree trunk
        let trunk_y = h + tree_h * 0.3
        let trunk_h = tree_h * 0.6
        @raylib.draw_cube(
          @raylib.Vector3::new(tree_x, trunk_y, tree_z),
          0.3,
          trunk_h,
          0.3,
          @raylib.Color::new(100, 70, 40, 255),
        )
        // Tree canopy
        let canopy_y = h + tree_h * 0.75
        let canopy_h = tree_h * 0.5
        @raylib.draw_cube(
          @raylib.Vector3::new(tree_x, canopy_y, tree_z),
          1.5,
          canopy_h,
          1.5,
          @raylib.Color::new(30, 100 + seed_abs % 30, 20, 220),
        )
      }
    }
    // Rocks on high terrain
    if h > 8.0 && h < @types.terrain_snow_level {
      let rock_seed = t.grid_x * 41 + t.grid_z * 59
      let rock_abs = if rock_seed < 0 { -rock_seed } else { rock_seed }
      let rock_chance = rock_abs % 100
      if rock_chance < 20 {
        let rock_off_x = Float::from_int(rock_abs % 5) * 0.6
        let rock_x : Float = wx + rock_off_x - 1.5
        let rock_off_z = Float::from_int(rock_abs / 5 % 5) * 0.6
        let rock_z : Float = wz + rock_off_z - 1.5
        let rock_base = Float::from_int(rock_abs % 3) * 0.3
        let rock_size : Float = 0.5 + rock_base
        let rock_y = h + rock_size * 0.3
        let rock_h = rock_size * 0.6
        let rock_d = rock_size * 0.8
        @raylib.draw_cube(
          @raylib.Vector3::new(rock_x, rock_y, rock_z),
          rock_size,
          rock_h,
          rock_d,
          @raylib.Color::new(130, 125, 115, 255),
        )
      }
    }
  }
}

///|
fn draw_landing_zone(game : @types.Game) -> Unit {
  let mission = game.missions[game.current_mission]
  if not(mission.has_landing) {
    return
  }
  // Draw landing strip
  let lx = mission.landing_x
  let lz = mission.landing_z
  let ly = @types.terrain_height_at(lx, lz) + 0.1
  // Runway
  @raylib.draw_cube(
    @raylib.Vector3::new(lx, ly, lz),
    5.0,
    0.1,
    20.0,
    @raylib.Color::new(60, 60, 60, 255),
  )
  // Center line
  @raylib.draw_cube(
    @raylib.Vector3::new(lx, ly + 0.05, lz),
    0.3,
    0.02,
    18.0,
    @raylib.Color::new(255, 255, 255, 200),
  )
  // Edge lights (pulsing)
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.15)
  let alpha = 180 + (pulse * 75.0).to_int()
  let a = @types.clampi(alpha, 0, 255)
  for i in -4..=4 {
    let offset_z = Float::from_int(i) * 4.0
    @raylib.draw_cube(
      @raylib.Vector3::new(lx + 2.8, ly + 0.3, lz + offset_z),
      0.3,
      0.3,
      0.3,
      @raylib.Color::new(255, 200, 50, a),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(lx - 2.8, ly + 0.3, lz + offset_z),
      0.3,
      0.3,
      0.3,
      @raylib.Color::new(255, 200, 50, a),
    )
  }
}
