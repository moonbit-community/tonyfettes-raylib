// 3D world rendering

///|
pub fn draw_world(game : @types.Game) -> Unit {
  let camera = build_camera(game)
  @raylib.begin_mode_3d(camera)
  draw_floor_tiles(game)
  draw_laser_beams(game)
  draw_entities(game)
  draw_player(game)
  draw_decorations(game)
  draw_particles_3d(game)
  draw_shadows(game)
  @raylib.end_mode_3d()
}

///|
fn build_camera(game : @types.Game) -> @raylib.Camera3D {
  let angle_rad = game.camera_angle * 3.14159 / 180.0
  let cos_a = @math.cosf(angle_rad)
  let sin_a = @math.sinf(angle_rad)
  let cam_x = game.camera_target_x + @types.camera_dist * sin_a
  let cam_z = game.camera_target_z + @types.camera_dist * cos_a
  @raylib.Camera3D::new(
    @raylib.Vector3::new(cam_x, @types.camera_height, cam_z),
    @raylib.Vector3::new(game.camera_target_x, 0.0, game.camera_target_z),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraOrthographic,
  )
}

///|
fn draw_floor_tiles(game : @types.Game) -> Unit {
  let world = game.current_world
  for gy in 0..<@types.grid_h {
    for gx in 0..<@types.grid_w {
      let tile = @types.get_tile(game, gx, gy)
      let wx = Float::from_int(gx)
      let wz = Float::from_int(gy)
      if tile == @types.TileWall {
        draw_wall(game, wx, wz, world)
      } else if tile == @types.TileFloor {
        draw_floor(wx, wz, world)
      } else if tile == @types.TilePlate {
        draw_plate(game, wx, wz, gx, gy, world)
      } else if tile == @types.TileSwitchOff {
        draw_switch(wx, wz, false, world)
      } else if tile == @types.TileSwitchOn {
        draw_switch(wx, wz, true, world)
      } else if tile == @types.TileExitClosed {
        draw_exit(game, wx, wz, false, world)
      } else if tile == @types.TileExitOpen {
        draw_exit(game, wx, wz, true, world)
      } else if tile == @types.TilePit {
        draw_pit(wx, wz, world)
      } else if tile == @types.TileIce {
        draw_ice(wx, wz)
      } else if tile == @types.TileTeleportA || tile == @types.TileTeleportB {
        draw_teleport(game, wx, wz, world)
      } else if tile == @types.TileCracked {
        draw_cracked(wx, wz, world)
      } else if tile == @types.TileSpikesOff {
        draw_spikes(wx, wz, false, world)
      } else if tile == @types.TileSpikesOn {
        draw_spikes(wx, wz, true, world)
      } else if @types.is_conveyor(tile) {
        draw_conveyor(game, wx, wz, tile, world)
      } else if tile == @types.TileBridgeOff {
        draw_bridge(wx, wz, false)
      } else if tile == @types.TileBridgeOn {
        draw_bridge(wx, wz, true)
      } else if tile == @types.TileGateClosed {
        draw_gate(wx, wz, false, world)
      } else if tile == @types.TileGateOpen {
        draw_gate(wx, wz, true, world)
      } else if @types.is_mirror(tile) {
        draw_mirror(game, wx, wz, tile, world)
      } else if @types.is_laser_source(tile) {
        draw_laser_source(wx, wz, tile, world)
      } else if tile == @types.TileLaserTarget {
        draw_laser_target(game, wx, wz, world)
      } else if tile == @types.TileRotatePlatform {
        draw_rotate_platform(game, wx, wz, world)
      }
    }
  }
}

///|
fn draw_wall(game : @types.Game, wx : Float, wz : Float, world : @types.World) -> Unit {
  ignore(game)
  let wc = @types.get_world_wall_color(world)
  let pos = @raylib.Vector3::new(wx, 0.5, wz)
  @raylib.draw_cube(
    pos,
    1.0,
    1.0,
    1.0,
    @raylib.Color::new(wc.0, wc.1, wc.2, 255),
  )
  // Edge lines slightly darker
  let edge_r = @types.clampi(wc.0 - 15, 0, 255)
  let edge_g = @types.clampi(wc.1 - 15, 0, 255)
  let edge_b = @types.clampi(wc.2 - 15, 0, 255)
  @raylib.draw_cube_wires(
    pos,
    1.0,
    1.0,
    1.0,
    @raylib.Color::new(edge_r, edge_g, edge_b, 255),
  )
  // Top trim per world
  if world == @types.WorldDungeon {
    // Stone trim on top
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 1.02, wz),
      0.9,
      0.04,
      0.9,
      @raylib.Color::new(55, 60, 75, 255),
    )
  } else if world == @types.WorldIce {
    // Icy sparkle on top
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 1.02, wz),
      0.85,
      0.03,
      0.85,
      @raylib.Color::new(200, 230, 255, 150),
    )
  } else if world == @types.WorldLava {
    // Glowing edges
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 1.0, wz),
      1.02,
      0.02,
      1.02,
      @raylib.Color::new(255, 100, 20, 100),
    )
  } else if world == @types.WorldGarden {
    // Moss on top
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 1.02, wz),
      0.9,
      0.04,
      0.9,
      @raylib.Color::new(40, 100, 35, 200),
    )
  } else if world == @types.WorldVoid {
    // Purple glow
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 1.0, wz),
      1.02,
      0.02,
      1.02,
      @raylib.Color::new(120, 60, 200, 100),
    )
  }
}

///|
fn draw_floor(wx : Float, wz : Float, world : @types.World) -> Unit {
  let fc = @types.get_world_floor_color(world)
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, -0.05, wz),
    0.95,
    0.1,
    0.95,
    @raylib.Color::new(fc.0, fc.1, fc.2, 255),
  )
  // Grid lines
  let line_r = @types.clampi(fc.0 - 10, 0, 255)
  let line_g = @types.clampi(fc.1 - 10, 0, 255)
  let line_b = @types.clampi(fc.2 - 10, 0, 255)
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.001, wz),
    0.98,
    0.002,
    0.02,
    @raylib.Color::new(line_r, line_g, line_b, 80),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.001, wz),
    0.02,
    0.002,
    0.98,
    @raylib.Color::new(line_r, line_g, line_b, 80),
  )
}

///|
fn draw_plate(
  game : @types.Game,
  wx : Float,
  wz : Float,
  gx : Int,
  gy : Int,
  world : @types.World,
) -> Unit {
  // Floor base
  draw_floor(wx, wz, world)
  // Plate indicator
  let has_block = @types.entity_at(game, gx, gy) >= 0
  let height : Float = if has_block { -0.02 } else { 0.02 }
  let color = if has_block {
    @raylib.Color::new(100, 220, 80, 255)
  } else {
    @raylib.Color::new(
      @types.color_plate_r, @types.color_plate_g, @types.color_plate_b, 255,
    )
  }
  @raylib.draw_cube(@raylib.Vector3::new(wx, height, wz), 0.7, 0.04, 0.7, color)
  // Glow ring when active
  if has_block {
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.01, wz),
      0.8,
      0.02,
      0.8,
      @raylib.Color::new(100, 255, 80, 100),
    )
  }
  // Corner marks
  let mark_color = if has_block {
    @raylib.Color::new(80, 180, 60, 255)
  } else {
    @raylib.Color::new(180, 160, 40, 255)
  }
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.3, 0.03, wz - 0.3),
    0.08,
    0.02,
    0.08,
    mark_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.3, 0.03, wz - 0.3),
    0.08,
    0.02,
    0.08,
    mark_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.3, 0.03, wz + 0.3),
    0.08,
    0.02,
    0.08,
    mark_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.3, 0.03, wz + 0.3),
    0.08,
    0.02,
    0.08,
    mark_color,
  )
}

///|
fn draw_switch(wx : Float, wz : Float, on : Bool, world : @types.World) -> Unit {
  draw_floor(wx, wz, world)
  // Base platform
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.03, wz),
    0.5,
    0.06,
    0.5,
    @raylib.Color::new(100, 100, 110, 255),
  )
  let color = if on {
    @raylib.Color::new(50, 200, 50, 255)
  } else {
    @raylib.Color::new(200, 50, 50, 255)
  }
  // Lever
  let lever_height : Float = if on { 0.05 } else { 0.2 }
  let lever_tilt : Float = if on { 0.15 } else { -0.15 }
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + lever_tilt, lever_height + 0.05, wz),
    0.08,
    0.2,
    0.08,
    @raylib.Color::new(180, 180, 190, 255),
  )
  // Lever knob
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + lever_tilt, lever_height + 0.15, wz),
    0.08,
    color,
  )
}

///|
fn draw_exit(
  game : @types.Game,
  wx : Float,
  wz : Float,
  open : Bool,
  world : @types.World,
) -> Unit {
  draw_floor(wx, wz, world)
  if open {
    // Glowing green portal with pulsing
    let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.06) * 0.05 +
      0.3
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, pulse, wz),
      0.6,
      0.6,
      0.6,
      @raylib.Color::new(50, 220, 100, 180),
    )
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(wx, pulse, wz),
      0.7,
      0.7,
      0.7,
      @raylib.Color::new(80, 255, 130, 255),
    )
    // Inner glow
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, pulse, wz),
      0.3,
      0.3,
      0.3,
      @raylib.Color::new(100, 255, 150, 120),
    )
    // Ground glow ring
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.01, wz),
      0.9,
      0.02,
      0.9,
      @raylib.Color::new(50, 200, 100, 80),
    )
  } else {
    // Closed door - bars
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.3, wz),
      0.6,
      0.6,
      0.6,
      @raylib.Color::new(100, 100, 100, 200),
    )
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(wx, 0.3, wz),
      0.7,
      0.7,
      0.7,
      @raylib.Color::new(150, 50, 50, 255),
    )
    // Cross bars
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.3, wz),
      0.7,
      0.05,
      0.05,
      @raylib.Color::new(120, 40, 40, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.3, wz),
      0.05,
      0.05,
      0.7,
      @raylib.Color::new(120, 40, 40, 255),
    )
  }
}

///|
fn draw_pit(wx : Float, wz : Float, world : @types.World) -> Unit {
  ignore(world)
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, -0.4, wz),
    0.9,
    0.1,
    0.9,
    @raylib.Color::new(20, 20, 30, 255),
  )
  // Pit edge
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, -0.1, wz),
    0.95,
    0.02,
    0.02,
    @raylib.Color::new(40, 40, 50, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, -0.1, wz),
    0.02,
    0.02,
    0.95,
    @raylib.Color::new(40, 40, 50, 255),
  )
}

///|
fn draw_ice(wx : Float, wz : Float) -> Unit {
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, -0.03, wz),
    0.95,
    0.06,
    0.95,
    @raylib.Color::new(
      @types.color_ice_r, @types.color_ice_g, @types.color_ice_b, 200,
    ),
  )
  // Reflective highlights
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.15, 0.01, wz + 0.1),
    0.3,
    0.01,
    0.1,
    @raylib.Color::new(220, 240, 255, 100),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.2, 0.01, wz - 0.2),
    0.15,
    0.01,
    0.2,
    @raylib.Color::new(220, 240, 255, 80),
  )
}

///|
fn draw_teleport(
  game : @types.Game,
  wx : Float,
  wz : Float,
  world : @types.World,
) -> Unit {
  draw_floor(wx, wz, world)
  let fc = Float::from_int(game.frame_counter)
  let pulse = @math.sinf(fc * 0.08) * 0.1 + 0.3
  // Portal base ring
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.02, wz),
    0.7,
    0.04,
    0.7,
    @raylib.Color::new(120, 60, 200, 200),
  )
  // Swirling portal cube
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, pulse, wz),
    0.5,
    0.5,
    0.5,
    @raylib.Color::new(150, 80, 255, 180),
  )
  // Inner ring (rotated feel)
  let ring_size : Float = 0.3 + @math.sinf(fc * 0.12) * 0.05
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, pulse + 0.1, wz),
    ring_size,
    0.05,
    ring_size,
    @raylib.Color::new(200, 150, 255, 150),
  )
  // Wires
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(wx, pulse, wz),
    0.55,
    0.55,
    0.55,
    @raylib.Color::new(180, 120, 255, 200),
  )
}

///|
fn draw_cracked(wx : Float, wz : Float, world : @types.World) -> Unit {
  let fc = @types.get_world_floor_color(world)
  let cr = @types.clampi(fc.0 + 20, 0, 255)
  let cg = @types.clampi(fc.1 + 10, 0, 255)
  let cb = @types.clampi(fc.2 - 10, 0, 255)
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, -0.05, wz),
    0.95,
    0.1,
    0.95,
    @raylib.Color::new(cr, cg, cb, 255),
  )
  // Crack lines as small dark cubes
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.15, 0.01, wz + 0.1),
    0.5,
    0.02,
    0.04,
    @raylib.Color::new(50, 40, 30, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.1, 0.01, wz - 0.15),
    0.04,
    0.02,
    0.4,
    @raylib.Color::new(50, 40, 30, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.05, 0.01, wz + 0.2),
    0.3,
    0.02,
    0.03,
    @raylib.Color::new(50, 40, 30, 255),
  )
}

///|
fn draw_spikes(wx : Float, wz : Float, active : Bool, world : @types.World) -> Unit {
  draw_floor(wx, wz, world)
  if active {
    // Four spike cones
    let offsets : Array[(Float, Float)] = [
      (-0.2, -0.2),
      (0.2, -0.2),
      (-0.2, 0.2),
      (0.2, 0.2),
    ]
    for offset in offsets {
      let ox = offset.0
      let oz = offset.1
      @raylib.draw_cylinder(
        @raylib.Vector3::new(wx + ox, 0.0, wz + oz),
        0.0,
        0.08,
        0.3,
        4,
        @raylib.Color::new(200, 200, 200, 255),
      )
    }
    // Warning glow on floor
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.01, wz),
      0.8,
      0.01,
      0.8,
      @raylib.Color::new(255, 50, 50, 60),
    )
  } else {
    // Holes where spikes retract
    let offsets : Array[(Float, Float)] = [
      (-0.2, -0.2),
      (0.2, -0.2),
      (-0.2, 0.2),
      (0.2, 0.2),
    ]
    for offset in offsets {
      let ox = offset.0
      let oz = offset.1
      @raylib.draw_cube(
        @raylib.Vector3::new(wx + ox, -0.02, wz + oz),
        0.12,
        0.04,
        0.12,
        @raylib.Color::new(40, 40, 50, 255),
      )
    }
  }
}

///|
fn draw_conveyor(
  game : @types.Game,
  wx : Float,
  wz : Float,
  tile : @types.Tile,
  world : @types.World,
) -> Unit {
  draw_floor(wx, wz, world)
  // Conveyor surface
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.01, wz),
    0.9,
    0.02,
    0.9,
    @raylib.Color::new(
      @types.color_conveyor_r, @types.color_conveyor_g, @types.color_conveyor_b,
      200,
    ),
  )
  // Arrow indicators - animated
  let dir = @types.conveyor_direction(tile)
  let anim_offset = @math.sinf(Float::from_int(game.frame_counter) * 0.1) * 0.15
  let arrow_dx = Float::from_int(@types.dir_dx(dir))
  let arrow_dz = Float::from_int(@types.dir_dy(dir))
  // Three arrows along conveyor direction
  for i in 0..<3 {
    let fi = Float::from_int(i)
    let offset : Float = (fi - 1.0) * 0.25 + anim_offset
    let ax = wx + arrow_dx * offset
    let az = wz + arrow_dz * offset
    // Arrow body
    if dir == @types.DirUp || dir == @types.DirDown {
      @raylib.draw_cube(
        @raylib.Vector3::new(ax, 0.03, az),
        0.08,
        0.02,
        0.15,
        @raylib.Color::new(200, 200, 220, 255),
      )
    } else {
      @raylib.draw_cube(
        @raylib.Vector3::new(ax, 0.03, az),
        0.15,
        0.02,
        0.08,
        @raylib.Color::new(200, 200, 220, 255),
      )
    }
    // Arrowhead
    let tip_x = ax + arrow_dx * 0.1
    let tip_z = az + arrow_dz * 0.1
    @raylib.draw_cube(
      @raylib.Vector3::new(tip_x, 0.04, tip_z),
      0.12,
      0.02,
      0.12,
      @raylib.Color::new(220, 220, 240, 255),
    )
  }
}

///|
fn draw_bridge(wx : Float, wz : Float, active : Bool) -> Unit {
  if active {
    // Extended bridge - walkable planks
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, -0.02, wz),
      0.9,
      0.08,
      0.9,
      @raylib.Color::new(
        @types.color_bridge_r, @types.color_bridge_g, @types.color_bridge_b, 255,
      ),
    )
    // Plank lines
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.03, wz - 0.2),
      0.85,
      0.01,
      0.03,
      @raylib.Color::new(110, 80, 45, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.03, wz + 0.2),
      0.85,
      0.01,
      0.03,
      @raylib.Color::new(110, 80, 45, 255),
    )
    // Side rails
    @raylib.draw_cube(
      @raylib.Vector3::new(wx - 0.42, 0.08, wz),
      0.04,
      0.12,
      0.9,
      @raylib.Color::new(120, 90, 50, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(wx + 0.42, 0.08, wz),
      0.04,
      0.12,
      0.9,
      @raylib.Color::new(120, 90, 50, 255),
    )
  } else {
    // Retracted bridge - gap
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, -0.35, wz),
      0.9,
      0.08,
      0.9,
      @raylib.Color::new(30, 25, 40, 255),
    )
    // Side brackets
    @raylib.draw_cube(
      @raylib.Vector3::new(wx - 0.42, -0.1, wz),
      0.06,
      0.2,
      0.15,
      @raylib.Color::new(90, 70, 40, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(wx + 0.42, -0.1, wz),
      0.06,
      0.2,
      0.15,
      @raylib.Color::new(90, 70, 40, 255),
    )
  }
}

///|
fn draw_gate(wx : Float, wz : Float, open : Bool, world : @types.World) -> Unit {
  draw_floor(wx, wz, world)
  if open {
    // Gate posts remain, bars raised
    @raylib.draw_cube(
      @raylib.Vector3::new(wx - 0.4, 0.3, wz),
      0.08,
      0.6,
      0.08,
      @raylib.Color::new(
        @types.color_gate_r, @types.color_gate_g, @types.color_gate_b, 255,
      ),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(wx + 0.4, 0.3, wz),
      0.08,
      0.6,
      0.08,
      @raylib.Color::new(
        @types.color_gate_r, @types.color_gate_g, @types.color_gate_b, 255,
      ),
    )
    // Raised bars (above player height)
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.9, wz),
      0.7,
      0.06,
      0.06,
      @raylib.Color::new(140, 140, 160, 200),
    )
  } else {
    // Closed gate - bars blocking
    @raylib.draw_cube(
      @raylib.Vector3::new(wx - 0.4, 0.3, wz),
      0.08,
      0.6,
      0.08,
      @raylib.Color::new(
        @types.color_gate_r, @types.color_gate_g, @types.color_gate_b, 255,
      ),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(wx + 0.4, 0.3, wz),
      0.08,
      0.6,
      0.08,
      @raylib.Color::new(
        @types.color_gate_r, @types.color_gate_g, @types.color_gate_b, 255,
      ),
    )
    // Horizontal bars
    for i in 0..<3 {
      let bar_y : Float = 0.15 + Float::from_int(i) * 0.2
      @raylib.draw_cube(
        @raylib.Vector3::new(wx, bar_y, wz),
        0.72,
        0.06,
        0.06,
        @raylib.Color::new(140, 140, 160, 255),
      )
    }
    // Warning indicator
    @raylib.draw_cube(
      @raylib.Vector3::new(wx, 0.01, wz),
      0.8,
      0.01,
      0.8,
      @raylib.Color::new(200, 50, 50, 60),
    )
  }
}

///|
fn draw_mirror(
  game : @types.Game,
  wx : Float,
  wz : Float,
  tile : @types.Tile,
  world : @types.World,
) -> Unit {
  draw_floor(wx, wz, world)
  ignore(game)
  // Mirror base
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.02, wz),
    0.4,
    0.04,
    0.4,
    @raylib.Color::new(100, 100, 110, 255),
  )
  // Mirror panel - angled based on type
  // NE mirror: / shape, NW mirror: \ shape
  // For simplicity, render as a thin reflective panel
  let color = @raylib.Color::new(
    @types.color_mirror_r, @types.color_mirror_g, @types.color_mirror_b, 220,
  )
  if tile == @types.TileMirrorNe || tile == @types.TileMirrorSw {
    // / diagonal - thin along NE-SW
    @raylib.draw_cube(@raylib.Vector3::new(wx, 0.3, wz), 0.6, 0.5, 0.06, color)
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(wx, 0.3, wz),
      0.62,
      0.52,
      0.08,
      @raylib.Color::new(180, 200, 240, 255),
    )
  } else {
    // \ diagonal - thin along NW-SE
    @raylib.draw_cube(@raylib.Vector3::new(wx, 0.3, wz), 0.06, 0.5, 0.6, color)
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(wx, 0.3, wz),
      0.08,
      0.52,
      0.62,
      @raylib.Color::new(180, 200, 240, 255),
    )
  }
}

///|
fn draw_laser_source(wx : Float, wz : Float, tile : @types.Tile, world : @types.World) -> Unit {
  ignore(world)
  // Laser emitter as a wall-like block with a lens
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.4, wz),
    0.9,
    0.8,
    0.9,
    @raylib.Color::new(60, 60, 70, 255),
  )
  // Lens on the emitting side
  let dir = @types.laser_source_direction(tile)
  let ldx = Float::from_int(@types.dir_dx(dir)) * 0.45
  let ldz = Float::from_int(@types.dir_dy(dir)) * 0.45
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + ldx, 0.4, wz + ldz),
    0.12,
    @raylib.Color::new(
      @types.color_laser_r, @types.color_laser_g, @types.color_laser_b, 255,
    ),
  )
  // Glow around lens
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + ldx, 0.4, wz + ldz),
    0.18,
    @raylib.Color::new(
      @types.color_laser_r, @types.color_laser_g, @types.color_laser_b, 80,
    ),
  )
}

///|
fn draw_laser_target(
  game : @types.Game,
  wx : Float,
  wz : Float,
  world : @types.World,
) -> Unit {
  draw_floor(wx, wz, world)
  // Check if this target is hit by a laser
  let mut is_hit = false
  for i in 0..<game.laser_segment_count {
    let seg = game.laser_segments[i]
    if seg.active && seg.end_gx == wx.to_int() && seg.end_gy == wz.to_int() {
      is_hit = true
    }
  }
  let target_color = if is_hit {
    @raylib.Color::new(100, 255, 100, 255)
  } else {
    @raylib.Color::new(
      @types.color_target_r, @types.color_target_g, @types.color_target_b, 255,
    )
  }
  // Target circle
  @raylib.draw_cylinder(
    @raylib.Vector3::new(wx, 0.01, wz),
    0.35,
    0.35,
    0.04,
    12,
    target_color,
  )
  // Inner circle
  let inner_color = if is_hit {
    @raylib.Color::new(200, 255, 200, 255)
  } else {
    @raylib.Color::new(255, 230, 150, 255)
  }
  @raylib.draw_cylinder(
    @raylib.Vector3::new(wx, 0.03, wz),
    0.15,
    0.15,
    0.04,
    12,
    inner_color,
  )
  // Glow when hit
  if is_hit {
    @raylib.draw_cylinder(
      @raylib.Vector3::new(wx, 0.0, wz),
      0.4,
      0.4,
      0.02,
      12,
      @raylib.Color::new(100, 255, 100, 60),
    )
  }
}

///|
fn draw_rotate_platform(
  game : @types.Game,
  wx : Float,
  wz : Float,
  world : @types.World,
) -> Unit {
  draw_floor(wx, wz, world)
  // Rotating platform disc
  let fc = Float::from_int(game.frame_counter)
  let rot_offset = @math.sinf(fc * 0.02) * 0.02
  @raylib.draw_cylinder(
    @raylib.Vector3::new(wx, 0.02 + rot_offset, wz),
    0.4,
    0.4,
    0.06,
    8,
    @raylib.Color::new(
      @types.color_rotate_r, @types.color_rotate_g, @types.color_rotate_b, 255,
    ),
  )
  // Arrow marks showing rotation
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.2, 0.06, wz),
    0.15,
    0.02,
    0.04,
    @raylib.Color::new(180, 150, 220, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.06, wz + 0.2),
    0.04,
    0.02,
    0.15,
    @raylib.Color::new(180, 150, 220, 255),
  )
}

///|
fn draw_laser_beams(game : @types.Game) -> Unit {
  let fc = Float::from_int(game.frame_counter)
  let pulse = @math.sinf(fc * 0.15) * 0.3 + 0.7
  let pulse_alpha = (pulse * 200.0).to_int()
  let a = @types.clampi(pulse_alpha, 80, 255)
  for i in 0..<game.laser_segment_count {
    let seg = game.laser_segments[i]
    if not(seg.active) {
      continue
    }
    let sx = Float::from_int(seg.start_gx)
    let sy = Float::from_int(seg.start_gy)
    let ex = Float::from_int(seg.end_gx)
    let ey = Float::from_int(seg.end_gy)
    let beam_height : Float = 0.4
    // Draw beam as a thin cube stretching between start and end
    if seg.dir == @types.DirRight || seg.dir == @types.DirLeft {
      // Horizontal beam
      let min_x = @types.minf(sx, ex)
      let max_x = @types.maxf(sx, ex)
      let length = max_x - min_x + 1.0
      let center_x = (min_x + max_x) / 2.0
      @raylib.draw_cube(
        @raylib.Vector3::new(center_x, beam_height, sy),
        length,
        0.06,
        0.06,
        @raylib.Color::new(
          @types.color_laser_r, @types.color_laser_g, @types.color_laser_b, a,
        ),
      )
      // Inner bright core
      @raylib.draw_cube(
        @raylib.Vector3::new(center_x, beam_height, sy),
        length,
        0.02,
        0.02,
        @raylib.Color::new(255, 200, 200, a),
      )
    } else {
      // Vertical beam
      let min_z = @types.minf(sy, ey)
      let max_z = @types.maxf(sy, ey)
      let length = max_z - min_z + 1.0
      let center_z = (min_z + max_z) / 2.0
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, beam_height, center_z),
        0.06,
        0.06,
        length,
        @raylib.Color::new(
          @types.color_laser_r, @types.color_laser_g, @types.color_laser_b, a,
        ),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(sx, beam_height, center_z),
        0.02,
        0.02,
        length,
        @raylib.Color::new(255, 200, 200, a),
      )
    }
  }
}

///|
fn draw_entities(game : @types.Game) -> Unit {
  let world = game.current_world
  for e in game.entities {
    if not(e.active) {
      continue
    }
    let wx = e.anim_x
    let wz = e.anim_y
    let fall_offset : Float = if e.falling {
      let t : Float = 1.0 - e.fall_timer / @types.fall_anim_duration
      t * -2.0
    } else {
      0.0
    }
    if e.kind == @types.EntityBlock {
      draw_block(game, wx, wz, fall_offset, world)
    } else if e.kind == @types.EntityDiamond {
      draw_diamond(game, wx, wz)
    } else if e.kind == @types.EntityKey {
      draw_key(game, wx, wz)
    }
  }
}

///|
fn draw_block(
  game : @types.Game,
  wx : Float,
  wz : Float,
  fall_offset : Float,
  world : @types.World,
) -> Unit {
  ignore(game)
  let ac = @types.get_world_accent_color(world)
  let block_r = @types.clampi((@types.color_block_r + ac.0) / 2, 0, 255)
  let block_g = @types.clampi((@types.color_block_g + ac.1) / 2, 0, 255)
  let block_b = @types.clampi((@types.color_block_b + ac.2) / 2, 0, 255)
  let pos = @raylib.Vector3::new(wx, 0.35 + fall_offset, wz)
  @raylib.draw_cube(
    pos,
    0.8,
    0.7,
    0.8,
    @raylib.Color::new(block_r, block_g, block_b, 255),
  )
  @raylib.draw_cube_wires(
    pos,
    0.8,
    0.7,
    0.8,
    @raylib.Color::new(
      @types.clampi(block_r - 40, 0, 255),
      @types.clampi(block_g - 30, 0, 255),
      @types.clampi(block_b - 20, 0, 255),
      255,
    ),
  )
  // Top cross mark
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.71 + fall_offset, wz),
    0.5,
    0.02,
    0.06,
    @raylib.Color::new(
      @types.clampi(block_r + 20, 0, 255),
      @types.clampi(block_g + 20, 0, 255),
      @types.clampi(block_b + 20, 0, 255),
      255,
    ),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.71 + fall_offset, wz),
    0.06,
    0.02,
    0.5,
    @raylib.Color::new(
      @types.clampi(block_r + 20, 0, 255),
      @types.clampi(block_g + 20, 0, 255),
      @types.clampi(block_b + 20, 0, 255),
      255,
    ),
  )
}

///|
fn draw_diamond(game : @types.Game, wx : Float, wz : Float) -> Unit {
  let bob = @math.sinf(Float::from_int(game.frame_counter) * 0.06) * 0.08
  let pos = @raylib.Vector3::new(wx, 0.4 + bob, wz)
  // Diamond as rotated cube
  @raylib.draw_cube(
    pos,
    0.3,
    0.4,
    0.3,
    @raylib.Color::new(
      @types.color_diamond_r, @types.color_diamond_g, @types.color_diamond_b, 220,
    ),
  )
  @raylib.draw_cube_wires(
    pos,
    0.35,
    0.45,
    0.35,
    @raylib.Color::new(150, 230, 255, 255),
  )
  // Inner sparkle
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.4 + bob, wz),
    0.15,
    0.2,
    0.15,
    @raylib.Color::new(200, 240, 255, 180),
  )
  // Ground glow
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.01, wz),
    0.4,
    0.01,
    0.4,
    @raylib.Color::new(
      @types.color_diamond_r, @types.color_diamond_g, @types.color_diamond_b, 40,
    ),
  )
}

///|
fn draw_key(game : @types.Game, wx : Float, wz : Float) -> Unit {
  let bob = @math.sinf(Float::from_int(game.frame_counter) * 0.05) * 0.06
  let pos = @raylib.Vector3::new(wx, 0.35 + bob, wz)
  // Key body
  @raylib.draw_cube(
    pos,
    0.25,
    0.35,
    0.15,
    @raylib.Color::new(
      @types.color_key_r, @types.color_key_g, @types.color_key_b, 255,
    ),
  )
  // Key handle
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.5 + bob, wz),
    0.15,
    0.1,
    0.15,
    @raylib.Color::new(
      @types.color_key_r, @types.color_key_g, @types.color_key_b, 255,
    ),
  )
  // Key teeth
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.08, 0.22 + bob, wz),
    0.06,
    0.08,
    0.06,
    @raylib.Color::new(220, 190, 0, 255),
  )
  // Ground glow
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.01, wz),
    0.35,
    0.01,
    0.35,
    @raylib.Color::new(
      @types.color_key_r, @types.color_key_g, @types.color_key_b, 30,
    ),
  )
}

///|
fn draw_player(game : @types.Game) -> Unit {
  let wx = game.player_anim_x
  let wz = game.player_anim_z
  let world = game.current_world
  // Walk animation bob
  let walk_bob : Float = if game.player_moving {
    @types.absf(@math.sinf(game.player_walk_cycle)) * 0.05
  } else {
    0.0
  }
  // Push lean
  let push_lean : Float = if game.player_push_anim > 0.0 {
    game.player_push_anim / @types.push_anim_duration * 0.05
  } else {
    0.0
  }
  let lean_dx = Float::from_int(@types.dir_dx(game.player_dir)) * push_lean
  let lean_dz = Float::from_int(@types.dir_dy(game.player_dir)) * push_lean
  // Body color based on world
  let body_color = if world == @types.WorldIce {
    @raylib.Color::new(80, 160, 240, 255)
  } else if world == @types.WorldLava {
    @raylib.Color::new(200, 120, 60, 255)
  } else if world == @types.WorldGarden {
    @raylib.Color::new(60, 180, 80, 255)
  } else if world == @types.WorldVoid {
    @raylib.Color::new(140, 80, 200, 255)
  } else {
    @raylib.Color::new(60, 140, 220, 255)
  }
  // Shadow blob under player
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.005, wz),
    0.5,
    0.01,
    0.5,
    @raylib.Color::new(0, 0, 0, 60),
  )
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + lean_dx, 0.35 + walk_bob, wz + lean_dz),
    0.5,
    0.7,
    0.5,
    body_color,
  )
  // Body trim
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + lean_dx, 0.15 + walk_bob, wz + lean_dz),
    0.52,
    0.06,
    0.52,
    @raylib.Color::new(40, 100, 180, 255),
  )
  // Head
  let head_color = if world == @types.WorldVoid {
    @raylib.Color::new(170, 120, 230, 255)
  } else {
    @raylib.Color::new(80, 170, 250, 255)
  }
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + lean_dx, 0.85 + walk_bob, wz + lean_dz),
    0.2,
    head_color,
  )
  // Arms (left and right)
  let arm_swing : Float = if game.player_moving {
    @math.sinf(game.player_walk_cycle) * 0.1
  } else {
    0.0
  }
  // Left arm
  @raylib.draw_cube(
    @raylib.Vector3::new(
      wx + lean_dx - 0.35,
      0.45 + walk_bob + arm_swing,
      wz + lean_dz,
    ),
    0.12,
    0.35,
    0.12,
    body_color,
  )
  // Right arm
  @raylib.draw_cube(
    @raylib.Vector3::new(
      wx + lean_dx + 0.35,
      0.45 + walk_bob - arm_swing,
      wz + lean_dz,
    ),
    0.12,
    0.35,
    0.12,
    body_color,
  )
  // Direction indicator (small cube in front / eyes)
  let dx = Float::from_int(@types.dir_dx(game.player_dir)) * 0.2
  let dz = Float::from_int(@types.dir_dy(game.player_dir)) * 0.2
  // Eye left
  @raylib.draw_cube(
    @raylib.Vector3::new(
      wx + lean_dx + dx - 0.06,
      0.88 + walk_bob,
      wz + lean_dz + dz,
    ),
    0.05,
    0.05,
    0.05,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Eye right
  @raylib.draw_cube(
    @raylib.Vector3::new(
      wx + lean_dx + dx + 0.06,
      0.88 + walk_bob,
      wz + lean_dz + dz,
    ),
    0.05,
    0.05,
    0.05,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Pupils
  @raylib.draw_cube(
    @raylib.Vector3::new(
      wx + lean_dx + dx * 1.3 - 0.06,
      0.88 + walk_bob,
      wz + lean_dz + dz * 1.3,
    ),
    0.03,
    0.03,
    0.03,
    @raylib.Color::new(20, 20, 40, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(
      wx + lean_dx + dx * 1.3 + 0.06,
      0.88 + walk_bob,
      wz + lean_dz + dz * 1.3,
    ),
    0.03,
    0.03,
    0.03,
    @raylib.Color::new(20, 20, 40, 255),
  )
}

///|
fn draw_decorations(game : @types.Game) -> Unit {
  let fc = Float::from_int(game.frame_counter)
  for i in 0..<game.decoration_count {
    let d = game.decorations[i]
    if not(d.active) {
      continue
    }
    if d.kind == @types.DecoTorch {
      // Wall torch: bracket + flame
      @raylib.draw_cube(
        @raylib.Vector3::new(d.x, 0.3, d.z),
        0.08,
        0.3,
        0.08,
        @raylib.Color::new(100, 80, 50, 255),
      )
      let flicker = @math.sinf(fc * 0.15 + d.phase) * 0.03
      @raylib.draw_sphere(
        @raylib.Vector3::new(d.x, 0.5 + flicker, d.z),
        0.06 + flicker,
        @raylib.Color::new(255, 180, 50, 220),
      )
      @raylib.draw_sphere(
        @raylib.Vector3::new(d.x, 0.55 + flicker, d.z),
        0.04,
        @raylib.Color::new(255, 220, 100, 150),
      )
    } else if d.kind == @types.DecoCrystal {
      // Ice crystal
      let sparkle = @math.sinf(fc * 0.08 + d.phase) * 0.02
      @raylib.draw_cube(
        @raylib.Vector3::new(d.x, 0.15 + sparkle, d.z),
        0.08 * d.scale,
        0.3 * d.scale,
        0.08 * d.scale,
        @raylib.Color::new(150, 210, 255, 200),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(d.x + 0.05, 0.1, d.z - 0.03),
        0.05 * d.scale,
        0.2 * d.scale,
        0.05 * d.scale,
        @raylib.Color::new(120, 190, 240, 180),
      )
    } else if d.kind == @types.DecoMagmaPool {
      // Lava pool glow
      let glow = @math.sinf(fc * 0.04 + d.phase) * 0.02
      @raylib.draw_cube(
        @raylib.Vector3::new(d.x, 0.01 + glow, d.z),
        0.25 * d.scale,
        0.02,
        0.25 * d.scale,
        @raylib.Color::new(255, 100, 20, 180),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(d.x, 0.02 + glow, d.z),
        0.15 * d.scale,
        0.02,
        0.15 * d.scale,
        @raylib.Color::new(255, 180, 50, 120),
      )
    } else if d.kind == @types.DecoFlower {
      // Garden flower
      let sway = @math.sinf(fc * 0.03 + d.phase) * 0.02
      // Stem
      @raylib.draw_cube(
        @raylib.Vector3::new(d.x + sway, 0.1, d.z),
        0.03,
        0.2 * d.scale,
        0.03,
        @raylib.Color::new(50, 130, 40, 255),
      )
      // Petals
      @raylib.draw_sphere(
        @raylib.Vector3::new(d.x + sway, 0.22 * d.scale, d.z),
        0.06 * d.scale,
        @raylib.Color::new(255, 120, 180, 255),
      )
      @raylib.draw_sphere(
        @raylib.Vector3::new(d.x + sway, 0.22 * d.scale + 0.02, d.z),
        0.03 * d.scale,
        @raylib.Color::new(255, 220, 100, 255),
      )
    } else if d.kind == @types.DecoFloatingRock {
      // Void floating rock
      let float_y = @math.sinf(fc * 0.02 + d.phase) * 0.1 + 0.3
      @raylib.draw_cube(
        @raylib.Vector3::new(d.x, float_y, d.z),
        0.12 * d.scale,
        0.08 * d.scale,
        0.12 * d.scale,
        @raylib.Color::new(60, 50, 90, 200),
      )
      // Glow underneath
      @raylib.draw_cube(
        @raylib.Vector3::new(d.x, float_y - 0.05, d.z),
        0.08 * d.scale,
        0.02,
        0.08 * d.scale,
        @raylib.Color::new(150, 80, 255, 80),
      )
    }
  }
}

///|
fn draw_shadows(game : @types.Game) -> Unit {
  // Shadow blobs under entities
  for e in game.entities {
    if not(e.active) || e.falling {
      continue
    }
    @raylib.draw_cube(
      @raylib.Vector3::new(e.anim_x, 0.005, e.anim_y),
      0.6,
      0.01,
      0.6,
      @raylib.Color::new(0, 0, 0, 40),
    )
  }
}

///|
fn draw_particles_3d(game : @types.Game) -> Unit {
  for p in game.particles {
    if not(p.active) {
      continue
    }
    let alpha_f = p.life / p.max_life
    let alpha = (alpha_f * 255.0).to_int()
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
