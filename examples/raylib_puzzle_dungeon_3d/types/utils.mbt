// Math helpers

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
pub fn clampi(v : Int, low : Int, high : Int) -> Int {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

// Direction helpers

///|
pub fn dir_dx(dir : Dir) -> Int {
  if dir == DirRight {
    1
  } else if dir == DirLeft {
    -1
  } else {
    0
  }
}

///|
pub fn dir_dy(dir : Dir) -> Int {
  if dir == DirDown {
    1
  } else if dir == DirUp {
    -1
  } else {
    0
  }
}

///|
pub fn opposite_dir(dir : Dir) -> Dir {
  if dir == DirUp {
    DirDown
  } else if dir == DirDown {
    DirUp
  } else if dir == DirLeft {
    DirRight
  } else {
    DirLeft
  }
}

///|
pub fn rotate_dir_cw(dir : Dir) -> Dir {
  if dir == DirUp {
    DirRight
  } else if dir == DirRight {
    DirDown
  } else if dir == DirDown {
    DirLeft
  } else {
    DirUp
  }
}

// Grid helpers

///|
pub fn in_bounds(gx : Int, gy : Int) -> Bool {
  gx >= 0 && gy >= 0 && gx < grid_w && gy < grid_h
}

///|
pub fn tile_index(gx : Int, gy : Int) -> Int {
  gy * grid_w + gx
}

///|
pub fn get_tile(game : Game, gx : Int, gy : Int) -> Tile {
  if in_bounds(gx, gy) {
    game.tiles[tile_index(gx, gy)]
  } else {
    TileWall
  }
}

///|
pub fn set_tile(game : Game, gx : Int, gy : Int, tile : Tile) -> Unit {
  if in_bounds(gx, gy) {
    game.tiles[tile_index(gx, gy)] = tile
  }
}

///|
pub fn is_walkable(tile : Tile) -> Bool {
  tile == TileFloor ||
  tile == TilePlate ||
  tile == TileSwitchOff ||
  tile == TileSwitchOn ||
  tile == TileExitOpen ||
  tile == TileIce ||
  tile == TileTeleportA ||
  tile == TileTeleportB ||
  tile == TileCracked ||
  tile == TileSpikesOff ||
  tile == TileConveyorUp ||
  tile == TileConveyorRight ||
  tile == TileConveyorDown ||
  tile == TileConveyorLeft ||
  tile == TileBridgeOn ||
  tile == TileGateOpen ||
  tile == TileMirrorNe ||
  tile == TileMirrorNw ||
  tile == TileMirrorSe ||
  tile == TileMirrorSw ||
  tile == TileLaserTarget ||
  tile == TileRotatePlatform
}

///|
pub fn is_pushable_onto(tile : Tile) -> Bool {
  tile == TileFloor ||
  tile == TilePlate ||
  tile == TilePit ||
  tile == TileIce ||
  tile == TileCracked ||
  tile == TileSpikesOff ||
  tile == TileConveyorUp ||
  tile == TileConveyorRight ||
  tile == TileConveyorDown ||
  tile == TileConveyorLeft ||
  tile == TileBridgeOn ||
  tile == TileGateOpen ||
  tile == TileRotatePlatform
}

///|
pub fn is_solid_tile(tile : Tile) -> Bool {
  tile == TileWall ||
  tile == TileExitClosed ||
  tile == TilePit ||
  tile == TileSpikesOn ||
  tile == TileBridgeOff ||
  tile == TileGateClosed
}

///|
pub fn is_conveyor(tile : Tile) -> Bool {
  tile == TileConveyorUp ||
  tile == TileConveyorRight ||
  tile == TileConveyorDown ||
  tile == TileConveyorLeft
}

///|
pub fn conveyor_direction(tile : Tile) -> Dir {
  if tile == TileConveyorUp {
    DirUp
  } else if tile == TileConveyorRight {
    DirRight
  } else if tile == TileConveyorDown {
    DirDown
  } else if tile == TileConveyorLeft {
    DirLeft
  } else {
    DirNone
  }
}

///|
pub fn is_mirror(tile : Tile) -> Bool {
  tile == TileMirrorNe ||
  tile == TileMirrorNw ||
  tile == TileMirrorSe ||
  tile == TileMirrorSw
}

///|
pub fn is_laser_source(tile : Tile) -> Bool {
  tile == TileLaserSourceRight ||
  tile == TileLaserSourceDown ||
  tile == TileLaserSourceLeft ||
  tile == TileLaserSourceUp
}

///|
pub fn laser_source_direction(tile : Tile) -> Dir {
  if tile == TileLaserSourceRight {
    DirRight
  } else if tile == TileLaserSourceDown {
    DirDown
  } else if tile == TileLaserSourceLeft {
    DirLeft
  } else if tile == TileLaserSourceUp {
    DirUp
  } else {
    DirNone
  }
}

// Reflect a direction off a mirror tile

///|
pub fn mirror_reflect(tile : Tile, incoming_dir : Dir) -> Dir {
  // NE mirror: / shape - reflects up<->right, down<->left
  if tile == TileMirrorNe {
    if incoming_dir == DirLeft {
      DirUp
    } else if incoming_dir == DirDown {
      DirRight
    } else if incoming_dir == DirRight {
      DirDown
    } else if incoming_dir == DirUp {
      DirLeft
    } else {
      DirNone
    }
  } else if tile == TileMirrorNw {
    // NW mirror: \ shape - reflects up<->left, down<->right
    if incoming_dir == DirRight {
      DirUp
    } else if incoming_dir == DirDown {
      DirLeft
    } else if incoming_dir == DirLeft {
      DirDown
    } else if incoming_dir == DirUp {
      DirRight
    } else {
      DirNone
    }
  } else if tile == TileMirrorSe {
    // SE mirror: \ shape going other way
    if incoming_dir == DirLeft {
      DirDown
    } else if incoming_dir == DirUp {
      DirRight
    } else if incoming_dir == DirRight {
      DirUp
    } else if incoming_dir == DirDown {
      DirLeft
    } else {
      DirNone
    }
  } else if tile == TileMirrorSw {
    // SW mirror: / shape going other way
    if incoming_dir == DirRight {
      DirDown
    } else if incoming_dir == DirUp {
      DirLeft
    } else if incoming_dir == DirLeft {
      DirUp
    } else if incoming_dir == DirDown {
      DirRight
    } else {
      DirNone
    }
  } else {
    DirNone
  }
}

// Entity helpers

///|
pub fn entity_at(game : Game, gx : Int, gy : Int) -> Int {
  for i in 0..<game.entities.length() {
    if game.entities[i].active &&
      game.entities[i].gx == gx &&
      game.entities[i].gy == gy {
      return i
    }
  }
  -1
}

///|
pub fn alloc_entity(game : Game) -> Int {
  for i in 0..<game.entities.length() {
    if not(game.entities[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_particle(game : Game) -> Int {
  for i in 0..<game.particles.length() {
    if not(game.particles[i].active) {
      return i
    }
  }
  -1
}

// RNG

///|
pub fn rand_next(game : Game) -> Int {
  let mut x = game.rng_state
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x < 0 {
    x = -x
  }
  game.rng_state = x
  x
}

///|
pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

// Smooth step for animations

///|
pub fn smooth_step(t : Float) -> Float {
  let tc = clampf(t, 0.0, 1.0)
  tc * tc * (3.0 - 2.0 * tc)
}

// Easing for bounce

///|
pub fn ease_out_bounce(t : Float) -> Float {
  let tc = clampf(t, 0.0, 1.0)
  if tc < 1.0 / 2.75 {
    7.5625 * tc * tc
  } else if tc < 2.0 / 2.75 {
    let t2 = tc - 1.5 / 2.75
    7.5625 * t2 * t2 + 0.75
  } else if tc < 2.5 / 2.75 {
    let t2 = tc - 2.25 / 2.75
    7.5625 * t2 * t2 + 0.9375
  } else {
    let t2 = tc - 2.625 / 2.75
    7.5625 * t2 * t2 + 0.984375
  }
}

// Ease out cubic

///|
pub fn ease_out_cubic(t : Float) -> Float {
  let tc = clampf(t, 0.0, 1.0)
  let inv : Float = 1.0 - tc
  let result : Float = 1.0 - inv * inv * inv
  result
}

// Ease in out quad

///|
pub fn ease_in_out_quad(t : Float) -> Float {
  let tc = clampf(t, 0.0, 1.0)
  if tc < 0.5 {
    2.0 * tc * tc
  } else {
    let v : Float = -2.0 * tc + 2.0
    let result : Float = 1.0 - v * v / 2.0
    result
  }
}

// Spawn particles at a position

///|
pub fn spawn_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx + rand_rangef(game, -0.2, 0.2)
    p.y = wy + rand_rangef(game, 0.0, 0.3)
    p.z = wz + rand_rangef(game, -0.2, 0.2)
    p.vx = rand_rangef(game, -1.5, 1.5)
    p.vy = rand_rangef(game, 1.0, 4.0)
    p.vz = rand_rangef(game, -1.5, 1.5)
    p.life = rand_rangef(game, 0.4, 1.0)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.03, 0.08)
    ignore(i)
  }
}

// Spawn smaller ambient particles (for effects like portals, lasers)

///|
pub fn spawn_ambient_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
  spread : Float,
  speed : Float,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx + rand_rangef(game, -spread, spread)
    p.y = wy + rand_rangef(game, -spread, spread)
    p.z = wz + rand_rangef(game, -spread, spread)
    p.vx = rand_rangef(game, -speed, speed)
    p.vy = rand_rangef(game, 0.5, speed * 2.0)
    p.vz = rand_rangef(game, -speed, speed)
    p.life = rand_rangef(game, 0.2, 0.6)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.02, 0.05)
    ignore(i)
  }
}

// Count plates that have blocks on them

///|
pub fn count_active_plates(game : Game) -> Int {
  let mut count = 0
  for gy in 0..<grid_h {
    for gx in 0..<grid_w {
      if get_tile(game, gx, gy) == TilePlate {
        let eidx = entity_at(game, gx, gy)
        if eidx >= 0 && game.entities[eidx].kind == EntityBlock {
          count += 1
        }
      }
    }
  }
  count
}

// Count total plates

///|
pub fn count_plates(game : Game) -> Int {
  let mut count = 0
  for gy in 0..<grid_h {
    for gx in 0..<grid_w {
      if get_tile(game, gx, gy) == TilePlate {
        count += 1
      }
    }
  }
  count
}

// Count total diamonds

///|
pub fn count_diamonds(game : Game) -> Int {
  let mut count = 0
  for entity in game.entities {
    if entity.active && entity.kind == EntityDiamond {
      count += 1
    }
  }
  count
}

// Count total laser targets

///|
pub fn count_laser_targets(game : Game) -> Int {
  let mut count = 0
  for gy in 0..<grid_h {
    for gx in 0..<grid_w {
      if get_tile(game, gx, gy) == TileLaserTarget {
        count += 1
      }
    }
  }
  count
}

// Get current world from floor number

///|
pub fn get_world_for_floor(floor : Int) -> World {
  int_to_world(floor / floors_per_world)
}

// Get world theme colors

///|
pub fn get_world_floor_color(world : World) -> (Int, Int, Int) {
  if world == WorldIce {
    (ice_floor_r, ice_floor_g, ice_floor_b)
  } else if world == WorldLava {
    (lava_floor_r, lava_floor_g, lava_floor_b)
  } else if world == WorldGarden {
    (garden_floor_r, garden_floor_g, garden_floor_b)
  } else if world == WorldVoid {
    (void_floor_r, void_floor_g, void_floor_b)
  } else {
    (dungeon_floor_r, dungeon_floor_g, dungeon_floor_b)
  }
}

///|
pub fn get_world_wall_color(world : World) -> (Int, Int, Int) {
  if world == WorldIce {
    (ice_wall_r, ice_wall_g, ice_wall_b)
  } else if world == WorldLava {
    (lava_wall_r, lava_wall_g, lava_wall_b)
  } else if world == WorldGarden {
    (garden_wall_r, garden_wall_g, garden_wall_b)
  } else if world == WorldVoid {
    (void_wall_r, void_wall_g, void_wall_b)
  } else {
    (dungeon_wall_r, dungeon_wall_g, dungeon_wall_b)
  }
}

///|
pub fn get_world_accent_color(world : World) -> (Int, Int, Int) {
  if world == WorldIce {
    (ice_accent_r, ice_accent_g, ice_accent_b)
  } else if world == WorldLava {
    (lava_accent_r, lava_accent_g, lava_accent_b)
  } else if world == WorldGarden {
    (garden_accent_r, garden_accent_g, garden_accent_b)
  } else if world == WorldVoid {
    (void_accent_r, void_accent_g, void_accent_b)
  } else {
    (dungeon_accent_r, dungeon_accent_g, dungeon_accent_b)
  }
}

///|
pub fn get_world_bg_color(world : World) -> (Int, Int, Int) {
  if world == WorldIce {
    (ice_bg_r, ice_bg_g, ice_bg_b)
  } else if world == WorldLava {
    (lava_bg_r, lava_bg_g, lava_bg_b)
  } else if world == WorldGarden {
    (garden_bg_r, garden_bg_g, garden_bg_b)
  } else if world == WorldVoid {
    (void_bg_r, void_bg_g, void_bg_b)
  } else {
    (dungeon_bg_r, dungeon_bg_g, dungeon_bg_b)
  }
}

///|
pub fn get_world_name(world : World) -> String {
  if world == WorldDungeon {
    world_name_0
  } else if world == WorldIce {
    world_name_1
  } else if world == WorldLava {
    world_name_2
  } else if world == WorldGarden {
    world_name_3
  } else if world == WorldVoid {
    world_name_4
  } else {
    "Unknown"
  }
}

// Laser path calculation
// Traces laser beams from all sources, bouncing off mirrors

///|
pub fn calculate_laser_paths(game : Game) -> Unit {
  // Clear old segments
  for i in 0..<max_laser_segments {
    game.laser_segments[i].active = false
  }
  game.laser_segment_count = 0
  game.laser_targets_hit = 0
  // Find all laser sources
  for gy in 0..<grid_h {
    for gx in 0..<grid_w {
      let tile = get_tile(game, gx, gy)
      if is_laser_source(tile) {
        let dir = laser_source_direction(tile)
        trace_laser(game, gx, gy, dir)
      }
    }
  }
}

///|
fn trace_laser(game : Game, start_gx : Int, start_gy : Int, dir : Dir) -> Unit {
  let mut cx = start_gx
  let mut cy = start_gy
  let mut current_dir = dir
  let mut bounces = 0
  let max_bounces = 10
  while bounces < max_bounces {
    let dx = dir_dx(current_dir)
    let dy = dir_dy(current_dir)
    let seg_start_x = cx
    let seg_start_y = cy
    // Trace in current direction
    let mut hit_something = false
    let mut steps = 0
    while not(hit_something) && steps < grid_w + grid_h {
      cx = cx + dx
      cy = cy + dy
      steps = steps + 1
      if not(in_bounds(cx, cy)) {
        // Hit boundary - record segment and stop
        add_laser_segment(
          game,
          seg_start_x,
          seg_start_y,
          cx - dx,
          cy - dy,
          current_dir,
        )
        return
      }
      let tile = get_tile(game, cx, cy)
      // Check for entity blocking
      let eidx = entity_at(game, cx, cy)
      if eidx >= 0 {
        // Blocked by entity
        add_laser_segment(
          game,
          seg_start_x,
          seg_start_y,
          cx - dx,
          cy - dy,
          current_dir,
        )
        return
      }
      if tile == TileWall || tile == TileGateClosed || tile == TileExitClosed {
        // Blocked by wall
        add_laser_segment(
          game,
          seg_start_x,
          seg_start_y,
          cx - dx,
          cy - dy,
          current_dir,
        )
        return
      }
      if tile == TileLaserTarget {
        // Hit target
        add_laser_segment(game, seg_start_x, seg_start_y, cx, cy, current_dir)
        game.laser_targets_hit += 1
        return
      }
      if is_mirror(tile) {
        // Reflect
        add_laser_segment(game, seg_start_x, seg_start_y, cx, cy, current_dir)
        let new_dir = mirror_reflect(tile, current_dir)
        if new_dir == DirNone {
          return // Mirror doesn't reflect this direction
        }
        current_dir = new_dir
        bounces = bounces + 1
        hit_something = true
      }
    }
    if not(hit_something) {
      return
    }
  }
}

///|
fn add_laser_segment(
  game : Game,
  sx : Int,
  sy : Int,
  ex : Int,
  ey : Int,
  dir : Dir,
) -> Unit {
  if game.laser_segment_count >= max_laser_segments {
    return
  }
  let seg = game.laser_segments[game.laser_segment_count]
  seg.active = true
  seg.start_gx = sx
  seg.start_gy = sy
  seg.end_gx = ex
  seg.end_gy = ey
  seg.dir = dir
  game.laser_segment_count += 1
}

// Conveyor chain resolution - move all entities on conveyors

///|
pub fn resolve_conveyors(game : Game) -> Unit {
  // Process each entity on a conveyor
  for e in game.entities {
    if not(e.active) || e.falling {
      continue
    }
    let tile = get_tile(game, e.gx, e.gy)
    if is_conveyor(tile) {
      let dir = conveyor_direction(tile)
      let dx = dir_dx(dir)
      let dy = dir_dy(dir)
      let nx = e.gx + dx
      let ny = e.gy + dy
      if in_bounds(nx, ny) {
        let target_tile = get_tile(game, nx, ny)
        let target_entity = entity_at(game, nx, ny)
        if is_pushable_onto(target_tile) && target_entity < 0 {
          e.gx = nx
          e.gy = ny
          e.anim_timer = push_anim_duration
          // Check pit/cracked
          if target_tile == TilePit {
            e.falling = true
            e.fall_timer = fall_anim_duration
            set_tile(game, nx, ny, TileFloor)
          } else if target_tile == TileCracked {
            set_tile(game, nx, ny, TilePit)
            e.falling = true
            e.fall_timer = fall_anim_duration
          }
        }
      }
    }
  }
}

// Ice sliding for an entity - slides until hitting something

///|
pub fn ice_slide_entity(game : Game, entity_idx : Int, dir : Dir) -> Unit {
  let e = game.entities[entity_idx]
  let dx = dir_dx(dir)
  let dy = dir_dy(dir)
  let mut sliding = true
  while sliding {
    let nx = e.gx + dx
    let ny = e.gy + dy
    if not(in_bounds(nx, ny)) {
      sliding = false
    } else {
      let target_tile = get_tile(game, nx, ny)
      let target_entity = entity_at(game, nx, ny)
      if not(is_pushable_onto(target_tile)) || target_entity >= 0 {
        sliding = false
      } else {
        e.gx = nx
        e.gy = ny
        if target_tile == TilePit {
          e.falling = true
          e.fall_timer = fall_anim_duration
          set_tile(game, nx, ny, TileFloor)
          sliding = false
        } else if target_tile == TileCracked {
          set_tile(game, nx, ny, TilePit)
          e.falling = true
          e.fall_timer = fall_anim_duration
          sliding = false
        } else if target_tile != TileIce {
          sliding = false
        }
      }
    }
  }
  e.anim_timer = push_anim_duration
}

// Check if a position has a gate that should open/close

///|
pub fn update_gates(game : Game) -> Unit {
  let plates_ok = game.plates_total == 0 ||
    game.plates_active >= game.plates_total
  for gy in 0..<grid_h {
    for gx in 0..<grid_w {
      let tile = get_tile(game, gx, gy)
      if tile == TileGateClosed && plates_ok {
        set_tile(game, gx, gy, TileGateOpen)
        spawn_particles(
          game,
          Float::from_int(gx),
          0.5,
          Float::from_int(gy),
          gate_particle_count,
          color_gate_r,
          color_gate_g,
          color_gate_b,
        )
      } else if tile == TileGateOpen && not(plates_ok) {
        // Only close if no entity standing on it
        let eidx = entity_at(game, gx, gy)
        if eidx < 0 {
          set_tile(game, gx, gy, TileGateClosed)
        }
      }
    }
  }
}

// Toggle bridges via switch

///|
pub fn toggle_bridges(game : Game) -> Unit {
  for gy in 0..<grid_h {
    for gx in 0..<grid_w {
      let tile = get_tile(game, gx, gy)
      if tile == TileBridgeOff {
        set_tile(game, gx, gy, TileBridgeOn)
      } else if tile == TileBridgeOn {
        // Only retract if no entity on it
        let eidx = entity_at(game, gx, gy)
        if eidx < 0 {
          set_tile(game, gx, gy, TileBridgeOff)
        }
      }
    }
  }
}

// Get tutorial message for a floor

///|
pub fn get_tutorial_for_floor(floor : Int) -> String {
  if floor == 0 {
    tutorial_msg_move
  } else if floor == 1 {
    tutorial_msg_push
  } else if floor == 2 {
    tutorial_msg_plate
  } else if floor == 3 {
    tutorial_msg_diamond
  } else if floor == 4 {
    tutorial_msg_ice
  } else if floor == 6 {
    tutorial_msg_undo
  } else if floor == 10 {
    tutorial_msg_teleport
  } else if floor == 17 {
    tutorial_msg_switch
  } else if floor == 12 {
    tutorial_msg_cracked
  } else {
    ""
  }
}

// Decoration placement helpers

///|
pub fn setup_decorations(game : Game) -> Unit {
  game.decoration_count = 0
  let world = game.current_world
  // Place decorations near walls
  for gy in 0..<grid_h {
    for gx in 0..<grid_w {
      let tile = get_tile(game, gx, gy)
      if tile == TileFloor {
        // Check if adjacent to wall for decoration placement
        let adj_wall = is_solid_tile(get_tile(game, gx - 1, gy)) ||
          is_solid_tile(get_tile(game, gx + 1, gy)) ||
          is_solid_tile(get_tile(game, gx, gy - 1)) ||
          is_solid_tile(get_tile(game, gx, gy + 1))
        if adj_wall {
          let chance = rand_range(game, 0, 100)
          if chance < 15 && game.decoration_count < max_decorations {
            let d = game.decorations[game.decoration_count]
            d.active = true
            d.x = Float::from_int(gx) + rand_rangef(game, -0.3, 0.3)
            d.y = 0.0
            d.z = Float::from_int(gy) + rand_rangef(game, -0.3, 0.3)
            d.scale = rand_rangef(game, 0.5, 1.2)
            d.phase = rand_rangef(game, 0.0, 6.28)
            if world == WorldDungeon {
              d.kind = DecoTorch
            } else if world == WorldIce {
              d.kind = DecoCrystal
            } else if world == WorldLava {
              d.kind = DecoMagmaPool
            } else if world == WorldGarden {
              d.kind = DecoFlower
            } else {
              d.kind = DecoFloatingRock
            }
            game.decoration_count += 1
          }
        }
      }
    }
  }
}

// Count total stars earned

///|
pub fn count_total_stars(game : Game) -> Int {
  let mut total = 0
  for i in 0..<max_floors {
    total += game.floor_info[i].stars
  }
  total
}

// Check if a world is unlocked

///|
pub fn is_world_unlocked(game : Game, world : Int) -> Bool {
  if world == 0 {
    return true
  }
  // Need to complete at least 4 levels in previous world
  let prev_start = (world - 1) * floors_per_world
  let mut completed = 0
  for i in prev_start..<(prev_start + floors_per_world) {
    if i < max_floors && game.floor_info[i].completed {
      completed += 1
    }
  }
  completed >= 4
}

// Get the number of stars needed to unlock a world

///|
pub fn stars_to_unlock_world(world : Int) -> Int {
  if world == 0 {
    0
  } else if world == 1 {
    6
  } else if world == 2 {
    15
  } else if world == 3 {
    27
  } else if world == 4 {
    42
  } else {
    999
  }
}
