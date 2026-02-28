///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
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

///|
pub fn sign(v : Float) -> Float {
  if v > 0.0 {
    1.0
  } else if v < 0.0 {
    -1.0
  } else {
    0.0
  }
}

///|
pub fn smooth_damp(
  current : Float,
  target : Float,
  speed : Float,
  dt : Float,
) -> Float {
  let diff = target - current
  let step = diff * speed * dt
  if absf(step) > absf(diff) {
    target
  } else {
    current + step
  }
}

///|
pub fn angle_wrap(angle : Float) -> Float {
  let mut a = angle
  if a > pi {
    a = a - two_pi
  }
  if a < -pi {
    a = a + two_pi
  }
  a
}

///|
pub fn angle_diff(a : Float, b : Float) -> Float {
  angle_wrap(b - a)
}

///|
pub fn distance3d(
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
) -> Float {
  let dx = x1 - x2
  let dy = y1 - y2
  let dz = z1 - z2
  (dx * dx + dy * dy + dz * dz).sqrt()
}

///|
pub fn distance2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x1 - x2
  let dz = z1 - z2
  (dx * dx + dz * dz).sqrt()
}

///|
pub fn normalize3d(x : Float, y : Float, z : Float) -> (Float, Float, Float) {
  let len = (x * x + y * y + z * z).sqrt()
  if len < 0.0001 {
    (0.0, 0.0, 0.0)
  } else {
    (x / len, y / len, z / len)
  }
}

///|
pub fn dot3d(
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
) -> Float {
  x1 * x2 + y1 * y2 + z1 * z2
}

///|
pub fn cross3d(
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
) -> (Float, Float, Float) {
  (y1 * z2 - z1 * y2, z1 * x2 - x1 * z2, x1 * y2 - y1 * x2)
}

// Terrain height at world position using noise-like function

///|
pub fn terrain_height_at(wx : Float, wz : Float) -> Float {
  let freq1 : Float = 0.02
  let freq2 : Float = 0.05
  let freq3 : Float = 0.01
  let h1 = @math.sinf(wx * freq1 + 1.3) *
    @math.cosf(wz * freq1 + 0.7) *
    terrain_max_height *
    0.5
  let h2 = @math.sinf(wx * freq2 + 3.1) *
    @math.cosf(wz * freq2 + 2.1) *
    terrain_max_height *
    0.25
  let h3 = @math.sinf(wx * freq3) *
    @math.cosf(wz * freq3) *
    terrain_max_height *
    0.8
  let h = h1 + h2 + h3
  if h < 0.0 {
    0.0
  } else {
    h
  }
}

// Terrain height with bilinear interpolation for smoother results

///|
pub fn terrain_height_smooth(wx : Float, wz : Float) -> Float {
  let step : Float = 2.0
  let gx_raw : Float = wx / step
  let gx = Float::from_int(gx_raw.to_int() - (if gx_raw < 0.0 { 1 } else { 0 })) *
    step
  let gz_raw : Float = wz / step
  let gz = Float::from_int(gz_raw.to_int() - (if gz_raw < 0.0 { 1 } else { 0 })) *
    step
  let h00 = terrain_height_at(gx, gz)
  let h10 = terrain_height_at(gx + step, gz)
  let h01 = terrain_height_at(gx, gz + step)
  let h11 = terrain_height_at(gx + step, gz + step)
  let fx = (wx - gx) / step
  let fz = (wz - gz) / step
  let fx_c = clampf(fx, 0.0, 1.0)
  let fz_c = clampf(fz, 0.0, 1.0)
  let h0 = lerpf(h00, h10, fx_c)
  let h1 = lerpf(h01, h11, fx_c)
  lerpf(h0, h1, fz_c)
}

// Terrain normal (approximate via finite differences)

///|
pub fn terrain_normal(wx : Float, wz : Float) -> (Float, Float, Float) {
  let eps : Float = 1.0
  let hc = terrain_height_at(wx, wz)
  let hx = terrain_height_at(wx + eps, wz)
  let hz = terrain_height_at(wx, wz + eps)
  let dx = hx - hc
  let dz = hz - hc
  normalize3d(-dx, eps, -dz)
}

// Altitude above terrain

///|
pub fn altitude_above_terrain(x : Float, y : Float, z : Float) -> Float {
  let ground = terrain_height_at(x, z)
  y - ground
}

// Altitude effect on engine and control (thinner air at high altitude)

///|
pub fn altitude_factor(altitude : Float) -> Float {
  if altitude < altitude_thin_air_start {
    1.0
  } else if altitude > altitude_thin_air_max {
    altitude_control_min
  } else {
    let t = (altitude - altitude_thin_air_start) /
      (altitude_thin_air_max - altitude_thin_air_start)
    lerpf(1.0, altitude_control_min, t)
  }
}

// Calculate lift based on speed and aircraft min speed

///|
pub fn calculate_lift(speed : Float, min_speed : Float) -> Float {
  let ratio = speed / (min_speed + 1.0)
  let lift_base : Float = ratio * ratio * aircraft_gravity
  if lift_base > aircraft_gravity * 1.5 {
    aircraft_gravity * 1.5
  } else {
    lift_base
  }
}

// Calculate drag based on speed

///|
pub fn calculate_drag(speed : Float, max_speed : Float) -> Float {
  let ratio = speed / max_speed
  aircraft_drag * ratio * ratio * speed
}

// Calculate thrust from throttle and altitude

///|
pub fn calculate_thrust(
  throttle : Float,
  max_speed : Float,
  altitude : Float,
) -> Float {
  let alt_eff = altitude_factor(altitude)
  throttle * max_speed * 0.5 * alt_eff
}

// Check if aircraft is in stall condition

///|
pub fn is_stalling(speed : Float, min_speed : Float) -> Bool {
  speed < min_speed * stall_speed_threshold
}

// Fuel consumption rate based on throttle

///|
pub fn fuel_consumption(throttle : Float) -> Float {
  if throttle < 0.1 {
    fuel_idle_rate
  } else if throttle < 0.7 {
    lerpf(fuel_idle_rate, fuel_cruise_rate, (throttle - 0.1) / 0.6)
  } else {
    lerpf(fuel_cruise_rate, fuel_afterburner_rate, (throttle - 0.7) / 0.3)
  }
}

// Lead targeting: predict where target will be

///|
pub fn lead_target(
  shooter_x : Float,
  shooter_y : Float,
  shooter_z : Float,
  target_x : Float,
  target_y : Float,
  target_z : Float,
  target_vx : Float,
  target_vy : Float,
  target_vz : Float,
  bullet_speed : Float,
) -> (Float, Float, Float) {
  let dx = target_x - shooter_x
  let dy = target_y - shooter_y
  let dz = target_z - shooter_z
  let dist = (dx * dx + dy * dy + dz * dz).sqrt()
  let time_to_target : Float = dist / bullet_speed
  let pred_x = target_x + target_vx * time_to_target
  let pred_y = target_y + target_vy * time_to_target
  let pred_z = target_z + target_vz * time_to_target
  (pred_x, pred_y, pred_z)
}

// Bomb trajectory prediction: where will bomb land given current position/velocity

///|
pub fn bomb_impact_point(
  x : Float,
  y : Float,
  z : Float,
  vx : Float,
  vz : Float,
  altitude_agl : Float,
) -> (Float, Float, Float) {
  // Time to fall from altitude_agl under gravity
  let fall_arg : Float = 2.0 * altitude_agl / bomb_gravity
  let fall_time = fall_arg.sqrt()
  let impact_x = x + vx * fall_time
  let impact_z = z + vz * fall_time
  let impact_y = y - altitude_agl
  (impact_x, impact_y, impact_z)
}

// Wind effect on aircraft

///|
pub fn apply_wind(
  x : Float,
  z : Float,
  wind_dir_x : Float,
  wind_dir_z : Float,
  wind_speed : Float,
  dt : Float,
) -> (Float, Float) {
  let wx = x + wind_dir_x * wind_speed * dt
  let wz = z + wind_dir_z * wind_speed * dt
  (wx, wz)
}

// Turbulence jitter

///|
pub fn turbulence_jitter(
  game : Game,
  strength : Float,
  dt : Float,
) -> (Float, Float) {
  if strength < 0.01 {
    (0.0, 0.0)
  } else {
    let pitch_j = rand_rangef(game, -strength, strength) * dt
    let roll_j = rand_rangef(game, -strength, strength) * dt
    (pitch_j, roll_j)
  }
}

// Collision: point vs sphere

///|
pub fn point_in_sphere(
  px : Float,
  py : Float,
  pz : Float,
  sx : Float,
  sy : Float,
  sz : Float,
  radius : Float,
) -> Bool {
  let dist = distance3d(px, py, pz, sx, sy, sz)
  dist < radius
}

// Collision: point vs AABB (axis-aligned bounding box)

///|
pub fn point_in_aabb(
  px : Float,
  py : Float,
  pz : Float,
  bx : Float,
  by : Float,
  bz : Float,
  hw : Float,
  hh : Float,
  hd : Float,
) -> Bool {
  absf(px - bx) < hw && absf(py - by) < hh && absf(pz - bz) < hd
}

// Distance and bearing to waypoint

///|
pub fn bearing_to(
  from_x : Float,
  from_z : Float,
  to_x : Float,
  to_z : Float,
) -> Float {
  @math.atan2f(to_x - from_x, to_z - from_z)
}

// Landing approach calculation

///|
pub fn landing_alignment(
  player_x : Float,
  player_z : Float,
  player_yaw : Float,
  runway_x : Float,
  runway_z : Float,
) -> Float {
  let bearing = bearing_to(player_x, player_z, runway_x, runway_z)
  let diff = angle_diff(player_yaw, bearing)
  absf(diff)
}

// Glide slope check for landing

///|
pub fn glide_slope_deviation(
  player_x : Float,
  player_y : Float,
  player_z : Float,
  runway_x : Float,
  runway_z : Float,
) -> Float {
  let dist_h = distance2d(player_x, player_z, runway_x, runway_z)
  let ideal_alt = terrain_height_at(runway_x, runway_z) +
    dist_h * landing_glide_slope
  player_y - ideal_alt
}

// Calculate G-force from vertical acceleration change

///|
pub fn calculate_gforce(
  current_vy : Float,
  prev_vy : Float,
  dt : Float,
) -> Float {
  if dt < 0.001 {
    gforce_normal
  } else {
    let accel = (current_vy - prev_vy) / dt
    let g = gforce_normal + accel / aircraft_gravity
    clampf(g, -2.0, gforce_max + 2.0)
  }
}

// Camera chase position calculation

///|
pub fn chase_camera_pos(
  player_x : Float,
  player_y : Float,
  player_z : Float,
  fx : Float,
  fy : Float,
  fz : Float,
  dist : Float,
  height : Float,
) -> (Float, Float, Float) {
  let cx = player_x - fx * dist
  let cy = player_y - fy * dist + height
  let cz = player_z - fz * dist
  (cx, cy, cz)
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

// Allocators

///|
pub fn alloc_enemy(game : Game) -> Int {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_turret(game : Game) -> Int {
  for i = 0; i < game.turrets.length(); i = i + 1 {
    if not(game.turrets[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_projectile(game : Game) -> Int {
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    if not(game.projectiles[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_particle(game : Game) -> Int {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_checkpoint(game : Game) -> Int {
  for i = 0; i < game.checkpoints.length(); i = i + 1 {
    if not(game.checkpoints[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_building(game : Game) -> Int {
  for i = 0; i < game.buildings.length(); i = i + 1 {
    if not(game.buildings[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_terrain(game : Game) -> Int {
  for i = 0; i < game.terrain.length(); i = i + 1 {
    if not(game.terrain[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_cloud(game : Game) -> Int {
  for i = 0; i < game.clouds.length(); i = i + 1 {
    if not(game.clouds[i].active) {
      return i
    }
  }
  -1
}

// Spawn particles at position

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
  for i = 0; i < count; i = i + 1 {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.kind = particle_explosion
    p.x = wx + rand_rangef(game, -0.5, 0.5)
    p.y = wy + rand_rangef(game, -0.5, 0.5)
    p.z = wz + rand_rangef(game, -0.5, 0.5)
    p.vx = rand_rangef(game, -4.0, 4.0)
    p.vy = rand_rangef(game, -2.0, 5.0)
    p.vz = rand_rangef(game, -4.0, 4.0)
    p.life = rand_rangef(game, 0.3, 1.0)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.05, 0.2)
    ignore(i)
  }
}

// Spawn smoke trail particles

///|
pub fn spawn_smoke(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.kind = particle_smoke
    p.x = wx + rand_rangef(game, -0.3, 0.3)
    p.y = wy + rand_rangef(game, -0.3, 0.3)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -1.0, 1.0)
    p.vy = rand_rangef(game, 0.5, 2.0)
    p.vz = rand_rangef(game, -1.0, 1.0)
    p.life = rand_rangef(game, 0.8, 2.0)
    p.max_life = p.life
    p.r = 80
    p.g = 80
    p.b = 80
    p.size = rand_rangef(game, 0.15, 0.4)
    ignore(i)
  }
}

// Spawn fire particles

///|
pub fn spawn_fire(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.kind = particle_fire
    p.x = wx + rand_rangef(game, -0.2, 0.2)
    p.y = wy
    p.z = wz + rand_rangef(game, -0.2, 0.2)
    p.vx = rand_rangef(game, -1.5, 1.5)
    p.vy = rand_rangef(game, 1.0, 4.0)
    p.vz = rand_rangef(game, -1.5, 1.5)
    p.life = rand_rangef(game, 0.2, 0.6)
    p.max_life = p.life
    p.r = 255
    p.g = rand_range(game, 80, 200)
    p.b = 20
    p.size = rand_rangef(game, 0.1, 0.25)
    ignore(i)
  }
}

// Spawn debris particles

///|
pub fn spawn_debris(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
) -> Unit {
  for i = 0; i < count; i = i + 1 {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.kind = particle_debris
    p.x = wx + rand_rangef(game, -1.0, 1.0)
    p.y = wy + rand_rangef(game, -0.5, 1.0)
    p.z = wz + rand_rangef(game, -1.0, 1.0)
    p.vx = rand_rangef(game, -8.0, 8.0)
    p.vy = rand_rangef(game, 2.0, 10.0)
    p.vz = rand_rangef(game, -8.0, 8.0)
    p.life = rand_rangef(game, 0.5, 1.5)
    p.max_life = p.life
    p.r = rand_range(game, 60, 120)
    p.g = rand_range(game, 50, 100)
    p.b = rand_range(game, 30, 60)
    p.size = rand_rangef(game, 0.1, 0.3)
    ignore(i)
  }
}

// Spawn rocket trail

///|
pub fn spawn_rocket_trail(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  let idx = alloc_particle(game)
  if idx < 0 {
    return
  }
  let p = game.particles[idx]
  p.active = true
  p.kind = particle_smoke
  p.x = wx + rand_rangef(game, -0.1, 0.1)
  p.y = wy + rand_rangef(game, -0.1, 0.1)
  p.z = wz + rand_rangef(game, -0.1, 0.1)
  p.vx = rand_rangef(game, -0.5, 0.5)
  p.vy = rand_rangef(game, -0.3, 0.3)
  p.vz = rand_rangef(game, -0.5, 0.5)
  p.life = 0.4
  p.max_life = 0.4
  p.r = 200
  p.g = 200
  p.b = 200
  p.size = 0.15
}

// Spawn explosion

///|
pub fn spawn_explosion(game : Game, wx : Float, wy : Float, wz : Float) -> Unit {
  spawn_particles(game, wx, wy, wz, 20, 255, 180, 50)
  spawn_particles(game, wx, wy, wz, 10, 255, 80, 20)
  spawn_fire(game, wx, wy, wz, 8)
  spawn_debris(game, wx, wy, wz, 6)
  spawn_smoke(game, wx, wy, wz, 5)
}

// Spawn large explosion (for buildings/bases)

///|
pub fn spawn_large_explosion(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles(game, wx, wy, wz, 30, 255, 200, 50)
  spawn_particles(game, wx, wy, wz, 15, 255, 100, 30)
  spawn_fire(game, wx, wy, wz, 15)
  spawn_debris(game, wx, wy, wz, 12)
  spawn_smoke(game, wx, wy, wz, 10)
}

// Show message

///|
pub fn show_message(game : Game, text : String, duration : Float) -> Unit {
  game.message_text = text
  game.message_timer = duration
}

// Add message to message queue

///|
pub fn push_message(
  game : Game,
  text : String,
  duration : Float,
  priority : Int,
) -> Unit {
  // Find empty slot or lowest priority
  let mut lowest_pri = 999
  let mut lowest_idx = 0
  for i = 0; i < game.messages.length(); i = i + 1 {
    if game.messages[i].timer <= 0.0 {
      game.messages[i].text = text
      game.messages[i].timer = duration
      game.messages[i].priority = priority
      return
    }
    if game.messages[i].priority < lowest_pri {
      lowest_pri = game.messages[i].priority
      lowest_idx = i
    }
  }
  // Overwrite lowest priority if our priority is higher
  if priority > lowest_pri {
    game.messages[lowest_idx].text = text
    game.messages[lowest_idx].timer = duration
    game.messages[lowest_idx].priority = priority
  }
}

// Count active enemies

///|
pub fn count_active_enemies(game : Game) -> Int {
  let mut count = 0
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if game.enemies[i].active {
      count += 1
    }
  }
  count
}

// Count active turrets

///|
pub fn count_active_turrets(game : Game) -> Int {
  let mut count = 0
  for i = 0; i < game.turrets.length(); i = i + 1 {
    if game.turrets[i].active {
      count += 1
    }
  }
  count
}

// Count active buildings

///|
pub fn count_active_buildings(game : Game) -> Int {
  let mut count = 0
  for i = 0; i < game.buildings.length(); i = i + 1 {
    if game.buildings[i].active {
      count += 1
    }
  }
  count
}

// Count active checkpoints not collected

///|
pub fn count_remaining_checkpoints(game : Game) -> Int {
  let mut count = 0
  for i = 0; i < game.checkpoints.length(); i = i + 1 {
    if game.checkpoints[i].active && not(game.checkpoints[i].collected) {
      count += 1
    }
  }
  count
}

// Get forward direction from pitch and yaw

///|
pub fn get_forward(pitch : Float, yaw : Float) -> (Float, Float, Float) {
  let cp = @math.cosf(pitch)
  let sp = @math.sinf(pitch)
  let cy = @math.cosf(yaw)
  let sy = @math.sinf(yaw)
  (sy * cp, -sp, cy * cp)
}

// Get right direction from yaw and roll

///|
pub fn get_right(yaw : Float, roll : Float) -> (Float, Float, Float) {
  let cy = @math.cosf(yaw)
  let sy = @math.sinf(yaw)
  let cr = @math.cosf(roll)
  let sr = @math.sinf(roll)
  (cy * cr, sr, -sy * cr)
}

// Find nearest enemy to position

///|
pub fn find_nearest_enemy(game : Game, x : Float, y : Float, z : Float) -> Int {
  let mut best_idx = -1
  let mut best_dist : Float = 99999.0
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue i + 1
    }
    let d = distance3d(
      x,
      y,
      z,
      game.enemies[i].x,
      game.enemies[i].y,
      game.enemies[i].z,
    )
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  best_idx
}

// Calculate mission accuracy percentage

///|
pub fn calculate_accuracy(shots_fired : Int, shots_hit : Int) -> Float {
  if shots_fired <= 0 {
    0.0
  } else {
    Float::from_int(shots_hit) / Float::from_int(shots_fired) * 100.0
  }
}

// Calculate mission rating based on score

///|
pub fn calculate_rating(score : Int) -> String {
  if score >= rating_s_threshold {
    "S"
  } else if score >= rating_a_threshold {
    "A"
  } else if score >= rating_b_threshold {
    "B"
  } else if score >= rating_c_threshold {
    "C"
  } else {
    "D"
  }
}

// Weapon name for display

///|
pub fn weapon_name(kind : Int) -> String {
  if kind == weapon_machine_gun {
    "MG"
  } else if kind == weapon_rockets {
    "RKT"
  } else if kind == weapon_bombs {
    "BMB"
  } else {
    "???"
  }
}

// Get ammo count for current weapon

///|
pub fn get_ammo(player : Player) -> Int {
  if player.current_weapon == weapon_machine_gun {
    player.ammo_mg
  } else if player.current_weapon == weapon_rockets {
    player.ammo_rockets
  } else {
    player.ammo_bombs
  }
}

// Weather name

///|
pub fn weather_name(kind : Int) -> String {
  if kind == weather_clear {
    "CLEAR"
  } else if kind == weather_cloudy {
    "CLOUDY"
  } else if kind == weather_fog {
    "FOG"
  } else if kind == weather_rain {
    "RAIN"
  } else if kind == weather_storm {
    "STORM"
  } else if kind == weather_night {
    "NIGHT"
  } else {
    ""
  }
}

// Difficulty stars string

///|
pub fn difficulty_str(level : Int) -> String {
  if level <= 1 {
    "*"
  } else if level <= 2 {
    "**"
  } else if level <= 3 {
    "***"
  } else if level <= 5 {
    "****"
  } else if level <= 7 {
    "*****"
  } else {
    "******"
  }
}
