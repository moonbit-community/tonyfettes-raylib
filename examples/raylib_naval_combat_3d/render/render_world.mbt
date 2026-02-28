// 3D world rendering

///|
pub fn draw_world(game : @types.Game) -> Unit {
  let camera = build_camera(game)
  @raylib.begin_mode_3d(camera)
  draw_ocean(game)
  draw_islands(game)
  draw_player_ship(game)
  draw_enemy_ships(game)
  draw_cannonballs(game)
  draw_particles_3d(game)
  draw_wind_indicator(game)
  @raylib.end_mode_3d()
}

///|
fn build_camera(game : @types.Game) -> @raylib.Camera3D {
  let ship = game.player
  // Camera behind and above the player ship
  let cam_angle = ship.heading + @types.pi + game.camera_offset_angle
  let cos_a = @math.cosf(cam_angle)
  let sin_a = @math.sinf(cam_angle)
  let cam_x = ship.x + sin_a * @types.camera_dist
  let cam_y = @types.camera_height
  let cam_z = ship.z + cos_a * @types.camera_dist
  @raylib.Camera3D::new(
    @raylib.Vector3::new(cam_x, cam_y, cam_z),
    @raylib.Vector3::new(ship.x, 1.0, ship.z),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
}

///|
fn draw_ocean(game : @types.Game) -> Unit {
  // Main ocean plane
  let size = @types.ocean_size
  @raylib.draw_plane(
    @raylib.Vector3::new(0.0, -0.1, 0.0),
    @raylib.Vector2::new(size, size),
    @raylib.Color::new(20, 60, 120, 255),
  )
  // Simulated wave stripes using thin planes at slightly different heights
  let time = Float::from_int(game.frame_counter) * 0.03
  for i = 0; i < 20; i = i + 1 {
    let offset = Float::from_int(i) * 10.0 - 95.0
    let wave_h = @math.sinf(time + Float::from_int(i) * 0.7) * 0.15
    let alpha : Int = 40 +
      (@math.sinf(time + Float::from_int(i) * 0.5) * 20.0).to_int()
    let a = @types.clampi(alpha, 20, 80)
    @raylib.draw_cube(
      @raylib.Vector3::new(0.0, wave_h, offset),
      size,
      0.05,
      3.0,
      @raylib.Color::new(60, 120, 180, a),
    )
  }
  // Cross waves
  for i = 0; i < 15; i = i + 1 {
    let offset = Float::from_int(i) * 13.0 - 91.0
    let wave_h = @math.sinf(time * 0.8 + Float::from_int(i) * 0.9) * 0.1
    @raylib.draw_cube(
      @raylib.Vector3::new(offset, wave_h + 0.02, 0.0),
      3.0,
      0.04,
      size,
      @raylib.Color::new(40, 100, 160, 35),
    )
  }
}

///|
fn draw_islands(game : @types.Game) -> Unit {
  for i = 0; i < game.island_count; i = i + 1 {
    let island = game.islands[i]
    if not(island.active) {
      continue i + 1
    }
    // Base rock - draw as a cluster of cubes
    let base_color = @raylib.Color::new(100, 85, 60, 255)
    let green_color = @raylib.Color::new(50, 120, 40, 255)
    let dark_color = @raylib.Color::new(70, 60, 45, 255)
    // Central large cube
    @raylib.draw_cube(
      @raylib.Vector3::new(island.x, island.height * 0.5, island.z),
      island.radius * 1.2,
      island.height,
      island.radius * 1.2,
      base_color,
    )
    // Additional blocks
    for b = 0; b < island.blocks; b = b + 1 {
      let angle = Float::from_int(b) * 6.28318 / Float::from_int(island.blocks)
      let bx = island.x + @math.sinf(angle) * island.radius * 0.5
      let bz = island.z + @math.cosf(angle) * island.radius * 0.5
      let bh = island.height * 0.6
      let bw = island.radius * 0.6
      @raylib.draw_cube(
        @raylib.Vector3::new(bx, bh * 0.5, bz),
        bw,
        bh,
        bw,
        dark_color,
      )
    }
    // Top greenery
    @raylib.draw_cube(
      @raylib.Vector3::new(island.x, island.height + 0.2, island.z),
      island.radius * 1.0,
      0.4,
      island.radius * 1.0,
      green_color,
    )
    // Beach ring (sand-colored flat ring)
    @raylib.draw_cylinder(
      @raylib.Vector3::new(island.x, 0.05, island.z),
      island.radius * 1.4,
      island.radius * 1.5,
      0.1,
      16,
      @raylib.Color::new(200, 180, 130, 200),
    )
  }
}

///|
fn draw_player_ship(game : @types.Game) -> Unit {
  let ship = game.player
  let sin_h = @math.sinf(ship.heading)
  let cos_h = @math.cosf(ship.heading)
  // Hull (main body)
  let hull_color = @raylib.Color::new(120, 80, 40, 255)
  // Draw hull as elongated cube rotated by heading
  // We approximate rotation by drawing at an angle
  // Main hull
  @raylib.draw_cube(
    @raylib.Vector3::new(ship.x, 0.5, ship.z),
    1.8,
    1.0,
    4.0,
    hull_color,
  )
  // Bow (front)
  let bow_x = ship.x + sin_h * 2.5
  let bow_z = ship.z + cos_h * 2.5
  @raylib.draw_cube(
    @raylib.Vector3::new(bow_x, 0.5, bow_z),
    1.0,
    0.8,
    1.5,
    @raylib.Color::new(100, 70, 35, 255),
  )
  // Stern (back)
  let stern_x = ship.x - sin_h * 2.2
  let stern_z = ship.z - cos_h * 2.2
  @raylib.draw_cube(
    @raylib.Vector3::new(stern_x, 0.7, stern_z),
    1.6,
    1.2,
    1.2,
    @raylib.Color::new(110, 75, 40, 255),
  )
  // Mast
  @raylib.draw_cylinder(
    @raylib.Vector3::new(ship.x, 1.0, ship.z),
    0.1,
    0.1,
    4.0,
    6,
    @raylib.Color::new(80, 60, 30, 255),
  )
  // Sails (if sail_hp > 0)
  if ship.sail_hp > 0.0 {
    let sail_alpha : Int = (ship.sail_hp / ship.max_hp * 200.0).to_int() + 55
    let sa = @types.clampi(sail_alpha, 55, 255)
    // Main sail
    @raylib.draw_cube(
      @raylib.Vector3::new(ship.x, 3.0, ship.z),
      2.5 * ship.sail_amount,
      2.0,
      0.1,
      @raylib.Color::new(240, 230, 200, sa),
    )
    // Top sail
    @raylib.draw_cube(
      @raylib.Vector3::new(ship.x, 4.5, ship.z),
      1.8 * ship.sail_amount,
      1.0,
      0.1,
      @raylib.Color::new(240, 230, 200, sa),
    )
  }
  // Cannon ports (small cubes on sides)
  let left_x = ship.x + @math.cosf(ship.heading) * 1.2
  let left_z = ship.z - @math.sinf(ship.heading) * 1.2
  let right_x = ship.x - @math.cosf(ship.heading) * 1.2
  let right_z = ship.z + @math.sinf(ship.heading) * 1.2
  let cannon_color = @raylib.Color::new(50, 50, 55, 255)
  @raylib.draw_cube(
    @raylib.Vector3::new(left_x, 0.6, left_z),
    0.3,
    0.3,
    0.5,
    cannon_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(right_x, 0.6, right_z),
    0.3,
    0.3,
    0.5,
    cannon_color,
  )
  // Reload indicators on sides (small colored cubes)
  if ship.reload_left > 0.0 {
    @raylib.draw_cube(
      @raylib.Vector3::new(left_x, 1.2, left_z),
      0.2,
      0.2,
      0.2,
      @raylib.Color::new(255, 100, 100, 200),
    )
  }
  if ship.reload_right > 0.0 {
    @raylib.draw_cube(
      @raylib.Vector3::new(right_x, 1.2, right_z),
      0.2,
      0.2,
      0.2,
      @raylib.Color::new(255, 100, 100, 200),
    )
  }
  // Flag on top
  @raylib.draw_cube(
    @raylib.Vector3::new(ship.x, 5.2, ship.z),
    0.6,
    0.3,
    0.05,
    @raylib.Color::new(200, 50, 50, 255),
  )
  ignore(sin_h)
  ignore(cos_h)
}

///|
fn draw_enemy_ships(game : @types.Game) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue i + 1
    }
    let sin_h = @math.sinf(enemy.heading)
    let cos_h = @math.cosf(enemy.heading)
    // Hull
    let hull_color = @raylib.Color::new(60, 50, 45, 255)
    @raylib.draw_cube(
      @raylib.Vector3::new(enemy.x, 0.4, enemy.z),
      1.5,
      0.8,
      3.5,
      hull_color,
    )
    // Bow
    let bow_x = enemy.x + sin_h * 2.0
    let bow_z = enemy.z + cos_h * 2.0
    @raylib.draw_cube(
      @raylib.Vector3::new(bow_x, 0.4, bow_z),
      0.8,
      0.7,
      1.2,
      @raylib.Color::new(50, 40, 35, 255),
    )
    // Mast
    @raylib.draw_cylinder(
      @raylib.Vector3::new(enemy.x, 0.8, enemy.z),
      0.08,
      0.08,
      3.0,
      6,
      @raylib.Color::new(70, 55, 30, 255),
    )
    // Sails (dark)
    @raylib.draw_cube(
      @raylib.Vector3::new(enemy.x, 2.5, enemy.z),
      2.0,
      1.5,
      0.08,
      @raylib.Color::new(40, 40, 45, 230),
    )
    // Skull flag
    @raylib.draw_cube(
      @raylib.Vector3::new(enemy.x, 4.0, enemy.z),
      0.5,
      0.3,
      0.04,
      @raylib.Color::new(30, 30, 30, 255),
    )
    // Health bar
    let hp_pct = enemy.hull_hp / enemy.max_hp
    let bar_w : Float = 2.5
    let bar_y : Float = 4.8
    @raylib.draw_cube(
      @raylib.Vector3::new(enemy.x, bar_y, enemy.z),
      bar_w,
      0.1,
      0.2,
      @raylib.Color::new(80, 0, 0, 200),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(
        enemy.x - bar_w * (1.0 - hp_pct) / 2.0,
        bar_y + 0.01,
        enemy.z,
      ),
      bar_w * hp_pct,
      0.12,
      0.2,
      @raylib.Color::new(0, 200, 0, 220),
    )
    // AI state indicator
    let indicator_color = if enemy.ai_state == @types.ai_patrol {
      @raylib.Color::new(100, 100, 255, 150)
    } else if enemy.ai_state == @types.ai_chase {
      @raylib.Color::new(255, 255, 100, 150)
    } else {
      @raylib.Color::new(255, 100, 100, 150)
    }
    @raylib.draw_sphere(
      @raylib.Vector3::new(enemy.x, 5.2, enemy.z),
      0.15,
      indicator_color,
    )
    ignore(sin_h)
    ignore(cos_h)
  }
}

///|
fn draw_cannonballs(game : @types.Game) -> Unit {
  for i = 0; i < game.cannonballs.length(); i = i + 1 {
    let cb = game.cannonballs[i]
    if not(cb.active) {
      continue i + 1
    }
    let color = if cb.from_player {
      @raylib.Color::new(40, 40, 40, 255)
    } else {
      @raylib.Color::new(80, 20, 20, 255)
    }
    @raylib.draw_sphere(@raylib.Vector3::new(cb.x, cb.y, cb.z), 0.2, color)
    // Trail
    @raylib.draw_sphere(
      @raylib.Vector3::new(
        cb.x - cb.vx * 0.02,
        cb.y - cb.vy * 0.02,
        cb.z - cb.vz * 0.02,
      ),
      0.1,
      @raylib.Color::new(100, 100, 100, 120),
    )
  }
}

///|
fn draw_particles_3d(game : @types.Game) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) {
      continue i + 1
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
fn draw_wind_indicator(game : @types.Game) -> Unit {
  // Draw a wind direction arrow near the player
  let ship = game.player
  let arrow_base_x = ship.x + 5.0
  let arrow_base_z = ship.z + 5.0
  let arrow_y : Float = 6.0
  let wind_dx = @math.sinf(game.wind_angle) * 3.0
  let wind_dz = @math.cosf(game.wind_angle) * 3.0
  @raylib.draw_line_3d(
    @raylib.Vector3::new(arrow_base_x, arrow_y, arrow_base_z),
    @raylib.Vector3::new(
      arrow_base_x + wind_dx,
      arrow_y,
      arrow_base_z + wind_dz,
    ),
    @raylib.Color::new(200, 200, 255, 200),
  )
  // Arrowhead
  @raylib.draw_sphere(
    @raylib.Vector3::new(
      arrow_base_x + wind_dx,
      arrow_y,
      arrow_base_z + wind_dz,
    ),
    0.3,
    @raylib.Color::new(200, 200, 255, 200),
  )
}
