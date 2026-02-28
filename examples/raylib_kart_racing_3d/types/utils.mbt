pub fn absf(v : Float) -> Float {
  if v < 0.0 { -v } else { v }
}

pub fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low { low } else if v > high { high } else { v }
}

pub fn clampi(v : Int, low : Int, high : Int) -> Int {
  if v < low { low } else if v > high { high } else { v }
}

pub fn minf(a : Float, b : Float) -> Float {
  if a < b { a } else { b }
}

pub fn maxf(a : Float, b : Float) -> Float {
  if a > b { a } else { b }
}

pub fn mini(a : Int, b : Int) -> Int {
  if a < b { a } else { b }
}

pub fn maxi(a : Int, b : Int) -> Int {
  if a > b { a } else { b }
}

pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

pub fn smooth_step(edge0 : Float, edge1 : Float, x : Float) -> Float {
  let t = clampf((x - edge0) / (edge1 - edge0), 0.0, 1.0)
  t * t * (3.0 - 2.0 * t)
}

pub fn distance2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x1 - x2
  let dz = z1 - z2
  (dx * dx + dz * dz).sqrt()
}

pub fn distance3d(
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float
) -> Float {
  let dx = x1 - x2
  let dy = y1 - y2
  let dz = z1 - z2
  (dx * dx + dy * dy + dz * dz).sqrt()
}

pub fn distance2d_sq(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x1 - x2
  let dz = z1 - z2
  dx * dx + dz * dz
}

// Normalize angle to [-PI, PI]
pub fn normalize_angle(a : Float) -> Float {
  let mut result = a
  for _i = 0; _i < 10; _i = _i + 1 {
    if result > pi {
      result = result - two_pi
    } else if result < -pi {
      result = result + two_pi
    } else {
      break
    }
  }
  result
}

// Angle difference (shortest path)
pub fn angle_diff(from : Float, to : Float) -> Float {
  normalize_angle(to - from)
}

// Get angle from point a to point b
pub fn angle_to(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  @math.atan2f(x2 - x1, z2 - z1)
}

// Dot product of 2D vectors
pub fn dot2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  x1 * x2 + z1 * z2
}

// Cross product magnitude of 2D vectors (useful for determining side)
pub fn cross2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  x1 * z2 - z1 * x2
}

// Project point onto line segment, return parameter t [0,1]
pub fn project_point_on_segment(
  px : Float,
  pz : Float,
  ax : Float,
  az : Float,
  bx : Float,
  bz : Float
) -> Float {
  let dx = bx - ax
  let dz = bz - az
  let len_sq = dx * dx + dz * dz
  if len_sq < 0.0001 {
    return 0.0
  }
  let t = ((px - ax) * dx + (pz - az) * dz) / len_sq
  clampf(t, 0.0, 1.0)
}

// Get distance from point to line segment
pub fn point_to_segment_dist(
  px : Float,
  pz : Float,
  ax : Float,
  az : Float,
  bx : Float,
  bz : Float
) -> Float {
  let t = project_point_on_segment(px, pz, ax, az, bx, bz)
  let proj_x = ax + (bx - ax) * t
  let proj_z = az + (bz - az) * t
  distance2d(px, pz, proj_x, proj_z)
}

// Get the surface grip multiplier
pub fn get_surface_grip(surface : Int) -> Float {
  if surface == surface_road {
    grip_road
  } else if surface == surface_dirt {
    grip_dirt
  } else if surface == surface_grass {
    grip_grass
  } else if surface == surface_boost_pad {
    grip_boost_pad
  } else if surface == surface_oil {
    grip_oil
  } else if surface == surface_ice {
    grip_ice
  } else {
    grip_road
  }
}

// Get the surface speed multiplier
pub fn get_surface_speed_mult(surface : Int) -> Float {
  if surface == surface_road {
    speed_mult_road
  } else if surface == surface_dirt {
    speed_mult_dirt
  } else if surface == surface_grass {
    speed_mult_grass
  } else if surface == surface_boost_pad {
    speed_mult_boost_pad
  } else if surface == surface_oil {
    speed_mult_oil
  } else if surface == surface_ice {
    speed_mult_ice
  } else {
    speed_mult_road
  }
}

// Get the drift boost power for a level
pub fn get_drift_boost_power(level : Int) -> Float {
  if level == drift_level_mini {
    drift_mini_boost
  } else if level == drift_level_super {
    drift_super_boost
  } else if level == drift_level_ultra {
    drift_ultra_boost
  } else {
    0.0
  }
}

// Get the drift boost duration for a level
pub fn get_drift_boost_duration(level : Int) -> Float {
  if level == drift_level_mini {
    drift_mini_duration
  } else if level == drift_level_super {
    drift_super_duration
  } else if level == drift_level_ultra {
    drift_ultra_duration
  } else {
    0.0
  }
}

// Calculate drift level based on time
pub fn calc_drift_level(drift_time : Float) -> Int {
  if drift_time >= drift_ultra_threshold {
    drift_level_ultra
  } else if drift_time >= drift_super_threshold {
    drift_level_super
  } else if drift_time >= drift_mini_threshold {
    drift_level_mini
  } else {
    drift_level_none
  }
}

// Get drift spark color based on level (r, g, b)
pub fn get_drift_spark_color(level : Int) -> (Int, Int, Int) {
  if level == drift_level_mini {
    (80, 150, 255)   // Blue
  } else if level == drift_level_super {
    (255, 180, 50)   // Orange
  } else if level == drift_level_ultra {
    (255, 80, 200)   // Pink
  } else {
    (200, 200, 200)  // Default gray
  }
}

// Get kart max speed based on type and surface
pub fn get_kart_max_speed(kart : Kart) -> Float {
  let stats = kart_stats[clampi(kart.kart_type, 0, kart_type_count - 1)]
  let base_speed = stats.0
  let surface_mult = get_surface_speed_mult(kart.on_surface_type)
  let mut result : Float = base_speed * surface_mult
  if kart.boost_timer > 0.0 {
    result = result + kart.boost_power
  }
  if kart.star_timer > 0.0 {
    result = result + star_speed_add
  }
  if kart.lightning_timer > 0.0 {
    result = result * lightning_slow_mult
  }
  result
}

// Get kart acceleration based on type
pub fn get_kart_accel(kart : Kart) -> Float {
  let stats = kart_stats[clampi(kart.kart_type, 0, kart_type_count - 1)]
  stats.1
}

// Get kart handling based on type
pub fn get_kart_handling(kart : Kart) -> Float {
  let stats = kart_stats[clampi(kart.kart_type, 0, kart_type_count - 1)]
  let grip = get_surface_grip(kart.on_surface_type)
  stats.2 * grip
}

// Get kart weight
pub fn get_kart_weight(kart : Kart) -> Float {
  let stats = kart_stats[clampi(kart.kart_type, 0, kart_type_count - 1)]
  stats.3
}

// Get kart drift boost multiplier
pub fn get_kart_drift_boost_mult(kart : Kart) -> Float {
  let stats = kart_stats[clampi(kart.kart_type, 0, kart_type_count - 1)]
  stats.4
}

// RNG
pub fn rand_next(game : Game) -> Int {
  let mut x = game.rng_state
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x < 0 { x = -x }
  game.rng_state = x
  x
}

pub fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low { low } else { low + rand_next(game) % (high - low + 1) }
}

pub fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

pub fn rand_bool(game : Game, chance : Float) -> Bool {
  rand_rangef(game, 0.0, 1.0) < chance
}

// Allocators
pub fn alloc_powerup(game : Game) -> Int {
  for i = 0; i < game.powerups.length(); i = i + 1 {
    if not(game.powerups[i].active) {
      return i
    }
  }
  -1
}

pub fn alloc_projectile(game : Game) -> Int {
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    if not(game.projectiles[i].active) {
      return i
    }
  }
  -1
}

pub fn alloc_particle(game : Game) -> Int {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      return i
    }
  }
  -1
}

pub fn alloc_dropped_item(game : Game) -> Int {
  for i = 0; i < game.dropped_items.length(); i = i + 1 {
    if not(game.dropped_items[i].active) {
      return i
    }
  }
  -1
}

pub fn spawn_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    let idx = alloc_particle(game)
    if idx < 0 { return }
    let p = game.particles[idx]
    p.active = true
    p.particle_type = particle_explosion
    p.x = wx + rand_rangef(game, -0.3, 0.3)
    p.y = wy + rand_rangef(game, 0.0, 0.5)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -2.0, 2.0)
    p.vy = rand_rangef(game, 1.0, 5.0)
    p.vz = rand_rangef(game, -2.0, 2.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.1)
    ignore(i)
  }
}

// Spawn typed particles
pub fn spawn_typed_particles(
  game : Game,
  ptype : Int,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
  size : Float,
  life : Float
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    let idx = alloc_particle(game)
    if idx < 0 { return }
    let p = game.particles[idx]
    p.active = true
    p.particle_type = ptype
    p.x = wx + rand_rangef(game, -0.2, 0.2)
    p.y = wy + rand_rangef(game, 0.0, 0.3)
    p.z = wz + rand_rangef(game, -0.2, 0.2)
    p.vx = rand_rangef(game, -1.5, 1.5)
    p.vy = rand_rangef(game, 0.5, 3.0)
    p.vz = rand_rangef(game, -1.5, 1.5)
    p.life = life + rand_rangef(game, -0.1, 0.1)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = size + rand_rangef(game, -0.01, 0.01)
    ignore(i)
  }
}

// Get waypoint with wrap-around
pub fn get_waypoint(game : Game, idx : Int) -> Waypoint {
  let wc = game.waypoint_count
  if wc == 0 {
    return { x: 0.0, y: 0.0, z: 0.0 }
  }
  let mut i = idx % wc
  if i < 0 { i = i + wc }
  game.waypoints[i]
}

// Get track segment with wrap-around
pub fn get_segment(game : Game, idx : Int) -> TrackSegment {
  let wc = game.waypoint_count
  if wc == 0 {
    return TrackSegment::default()
  }
  let mut i = idx % wc
  if i < 0 { i = i + wc }
  game.segments[i]
}

// Calculate kart's total progress for ranking
pub fn calc_total_progress(kart : Kart, waypoint_count : Int) -> Float {
  Float::from_int(kart.lap * waypoint_count + kart.waypoint_idx) +
  kart.waypoint_progress
}

// Points for finishing position
pub fn position_points(place : Int) -> Int {
  if place >= 1 && place <= cup_points_table.length() {
    cup_points_table[place - 1]
  } else {
    1
  }
}

// Check if kart is near a jump ramp segment
pub fn is_on_ramp(game : Game, kart : Kart) -> Bool {
  let wc = game.waypoint_count
  if wc < 2 { return false }
  let seg = get_segment(game, kart.waypoint_idx)
  seg.is_ramp
}

// Get surface type at kart position based on distance from track center
pub fn detect_surface_type(game : Game, x : Float, z : Float) -> Int {
  let wc = game.waypoint_count
  if wc < 2 { return surface_road }
  // Find nearest segment
  let mut best_dist : Float = 99999.0
  let mut best_seg = 0
  for i = 0; i < wc; i = i + 1 {
    let wp = game.waypoints[i]
    let d = distance2d(x, z, wp.x, wp.z)
    if d < best_dist {
      best_dist = d
      best_seg = i
    }
  }
  // Check segment surface type
  let seg = game.segments[best_seg]
  // If within road width, use segment surface
  if best_dist < road_half * seg.width_mult {
    // Check for boost pad or special surface
    if seg.surface_type != surface_road {
      return seg.surface_type
    }
    return surface_road
  }
  // Slightly off road - dirt
  if best_dist < road_half * seg.width_mult + 2.0 {
    return surface_dirt
  }
  // Far off road - grass
  surface_grass
}

// Detect wrong way: check if kart heading is opposite to track direction
pub fn is_wrong_way(game : Game, kart : Kart) -> Bool {
  let wc = game.waypoint_count
  if wc < 2 { return false }
  let cur = get_waypoint(game, kart.waypoint_idx)
  let nxt = get_waypoint(game, (kart.waypoint_idx + 1) % wc)
  let track_angle = @math.atan2f(nxt.x - cur.x, nxt.z - cur.z)
  let diff = absf(angle_diff(kart.angle, track_angle))
  diff > wrong_way_angle_threshold
}

// Find nearest opponent ahead of the given kart (for homing missiles)
pub fn find_target_ahead(game : Game, kart_idx : Int) -> Int {
  let kart = game.karts[kart_idx]
  let mut best_idx = -1
  let mut best_dist : Float = 99999.0
  for i = 0; i < max_karts; i = i + 1 {
    if i == kart_idx { continue i + 1 }
    let other = game.karts[i]
    if not(other.active) || other.finished { continue i + 1 }
    if other.total_progress <= kart.total_progress { continue i + 1 }
    let d = distance2d(kart.x, kart.z, other.x, other.z)
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  // If nobody is ahead, target nearest behind
  if best_idx < 0 {
    for i = 0; i < max_karts; i = i + 1 {
      if i == kart_idx { continue i + 1 }
      let other = game.karts[i]
      if not(other.active) || other.finished { continue i + 1 }
      let d = distance2d(kart.x, kart.z, other.x, other.z)
      if d < best_dist {
        best_dist = d
        best_idx = i
      }
    }
  }
  best_idx
}

// Find nearest opponent behind the given kart
pub fn find_target_behind(game : Game, kart_idx : Int) -> Int {
  let kart = game.karts[kart_idx]
  let mut best_idx = -1
  let mut best_dist : Float = 99999.0
  for i = 0; i < max_karts; i = i + 1 {
    if i == kart_idx { continue i + 1 }
    let other = game.karts[i]
    if not(other.active) || other.finished { continue i + 1 }
    if other.total_progress >= kart.total_progress { continue i + 1 }
    let d = distance2d(kart.x, kart.z, other.x, other.z)
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  best_idx
}

// Get item probability weights based on race position (better items when further behind)
pub fn get_item_weights(place : Int) -> Array[Int] {
  // Returns weights for: boost, shield, missile, oil, lightning, star, banana, triple_mushroom
  if place <= 1 {
    // First place: defensive items
    [10, 15, 0, 20, 0, 0, 30, 5]
  } else if place <= 3 {
    // Top 3: mixed items
    [20, 15, 10, 15, 0, 0, 15, 10]
  } else if place <= 5 {
    // Middle: offensive items
    [15, 10, 20, 10, 5, 5, 5, 15]
  } else {
    // Back of pack: powerful items
    [10, 5, 15, 5, 15, 15, 0, 20]
  }
}

// Pick a random powerup based on position weights
pub fn pick_random_powerup(game : Game, place : Int) -> Int {
  let weights = get_item_weights(place)
  let mut total = 0
  for i = 0; i < weights.length(); i = i + 1 {
    total = total + weights[i]
  }
  if total == 0 { return powerup_boost }
  let roll = rand_range(game, 0, total - 1)
  let mut accum = 0
  for i = 0; i < weights.length(); i = i + 1 {
    accum = accum + weights[i]
    if roll < accum {
      // Map index to powerup type (1-indexed)
      return i + 1
    }
  }
  powerup_boost
}

// Calculate rubber-band speed multiplier for AI
pub fn calc_rubber_band_mult(
  ai_progress : Float,
  player_progress : Float,
  difficulty : Int
) -> Float {
  let stats = ai_difficulty_stats[clampi(difficulty, 0, 3)]
  let base_mult = stats.0
  let progress_diff = ai_progress - player_progress
  let mut mult = base_mult
  if progress_diff < -8.0 {
    mult = mult + ai_rubberband_behind * 3.0
  } else if progress_diff < -3.0 {
    mult = mult + ai_rubberband_behind * 2.0
  } else if progress_diff < 0.0 {
    mult = mult + ai_rubberband_behind
  } else if progress_diff > 8.0 {
    mult = mult - ai_rubberband_ahead * 3.0
  } else if progress_diff > 3.0 {
    mult = mult - ai_rubberband_ahead * 2.0
  } else if progress_diff > 0.0 {
    mult = mult - ai_rubberband_ahead
  }
  clampf(mult, 0.7, 1.15)
}

// Format time as string "MM:SS.ms"
pub fn format_time(t : Float) -> String {
  let total_secs = t.to_int()
  let mins = total_secs / 60
  let secs = total_secs % 60
  let frac = t - Float::from_int(total_secs)
  let ms = (frac * 100.0).to_int()
  if mins > 0 {
    "\{mins}:\{secs}.\{ms}"
  } else {
    "\{secs}.\{ms}"
  }
}

// Get ordinal suffix for position (1st, 2nd, 3rd, etc.)
pub fn ordinal_suffix(n : Int) -> String {
  if n == 1 {
    "1st"
  } else if n == 2 {
    "2nd"
  } else if n == 3 {
    "3rd"
  } else {
    "\{n}th"
  }
}

// Track spline interpolation: get position at progress along segment
pub fn interpolate_track_position(
  game : Game,
  seg_idx : Int,
  t : Float
) -> (Float, Float, Float) {
  let wc = game.waypoint_count
  if wc < 2 { return (0.0, 0.0, 0.0) }
  let wp0 = get_waypoint(game, seg_idx)
  let wp1 = get_waypoint(game, (seg_idx + 1) % wc)
  let x = lerpf(wp0.x, wp1.x, t)
  let y = lerpf(wp0.y, wp1.y, t)
  let z = lerpf(wp0.z, wp1.z, t)
  (x, y, z)
}

// Get track direction vector at a segment
pub fn get_track_direction(game : Game, seg_idx : Int) -> (Float, Float) {
  let wc = game.waypoint_count
  if wc < 2 { return (0.0, 1.0) }
  let wp0 = get_waypoint(game, seg_idx)
  let wp1 = get_waypoint(game, (seg_idx + 1) % wc)
  let dx = wp1.x - wp0.x
  let dz = wp1.z - wp0.z
  let d = distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
  if d < 0.01 { return (0.0, 1.0) }
  (dx / d, dz / d)
}

// Get perpendicular direction to track at a segment
pub fn get_track_perpendicular(game : Game, seg_idx : Int) -> (Float, Float) {
  let dir = get_track_direction(game, seg_idx)
  (-dir.1, dir.0)
}

// Calculate weight-based bump force between two karts
pub fn calc_bump_force(weight_a : Float, weight_b : Float) -> (Float, Float) {
  let total = weight_a + weight_b
  if total < 0.01 { return (0.5, 0.5) }
  // Lighter kart gets pushed more
  let force_a = weight_b / total
  let force_b = weight_a / total
  (force_a, force_b)
}

// Check if two karts should trigger a spin based on weight difference
pub fn should_spin_from_bump(weight_a : Float, weight_b : Float) -> (Bool, Bool) {
  let diff = absf(weight_a - weight_b)
  if diff >= weight_spin_diff {
    if weight_a < weight_b {
      (true, false)  // a spins, b doesn't
    } else {
      (false, true)  // b spins, a doesn't
    }
  } else {
    (false, false)  // neither spins
  }
}
