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
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn sign_f(v : Float) -> Float {
  if v > 0.0 {
    1.0
  } else if v < 0.0 {
    -1.0
  } else {
    0.0
  }
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
pub fn distance_squared_3d(
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
  dx * dx + dy * dy + dz * dz
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
    (0.0, 0.0, 1.0)
  } else {
    (x / len, y / len, z / len)
  }
}

///|
pub fn length3d(x : Float, y : Float, z : Float) -> Float {
  (x * x + y * y + z * z).sqrt()
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

// Cross product

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

// Rotate a vector around an axis by angle (Rodrigues rotation formula)

///|
pub fn rotate_vector_around_axis(
  vx : Float,
  vy : Float,
  vz : Float,
  ax : Float,
  ay : Float,
  az : Float,
  angle : Float,
) -> (Float, Float, Float) {
  let cos_a = @math.cosf(angle)
  let sin_a = @math.sinf(angle)
  let dot_val = dot3d(vx, vy, vz, ax, ay, az)
  let cross = cross3d(ax, ay, az, vx, vy, vz)
  let rx = vx * cos_a + cross.0 * sin_a + ax * dot_val * (1.0 - cos_a)
  let ry = vy * cos_a + cross.1 * sin_a + ay * dot_val * (1.0 - cos_a)
  let rz = vz * cos_a + cross.2 * sin_a + az * dot_val * (1.0 - cos_a)
  (rx, ry, rz)
}

// Forward direction from yaw and pitch

///|
pub fn forward_dir(yaw : Float, pitch : Float) -> (Float, Float, Float) {
  let cp = @math.cosf(pitch)
  let sp = @math.sinf(pitch)
  let cy = @math.cosf(yaw)
  let sy = @math.sinf(yaw)
  (sy * cp, sp, cy * cp)
}

// Right direction from yaw

///|
pub fn right_dir(yaw : Float) -> (Float, Float, Float) {
  let cy = @math.cosf(yaw)
  let sy = @math.sinf(yaw)
  (cy, 0.0, -sy)
}

// Up direction from yaw and pitch

///|
pub fn up_dir(yaw : Float, pitch : Float) -> (Float, Float, Float) {
  let fwd = forward_dir(yaw, pitch)
  let rgt = right_dir(yaw)
  cross3d(rgt.0, rgt.1, rgt.2, fwd.0, fwd.1, fwd.2)
}

// Lead targeting: calculate where to aim to hit a moving target
// Returns the aim direction normalized

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
  projectile_speed : Float,
) -> (Float, Float, Float) {
  let dx = target_x - shooter_x
  let dy = target_y - shooter_y
  let dz = target_z - shooter_z
  let dist = (dx * dx + dy * dy + dz * dz).sqrt()
  if dist < 0.01 {
    return (0.0, 0.0, 1.0)
  }
  // Time to intercept (approximate)
  let time_to_target = dist / projectile_speed
  // Predict target position
  let pred_x = target_x + target_vx * time_to_target
  let pred_y = target_y + target_vy * time_to_target
  let pred_z = target_z + target_vz * time_to_target
  // Direction to predicted position
  let aim_dx = pred_x - shooter_x
  let aim_dy = pred_y - shooter_y
  let aim_dz = pred_z - shooter_z
  normalize3d(aim_dx, aim_dy, aim_dz)
}

// Sphere-sphere collision test

///|
pub fn sphere_collision(
  x1 : Float,
  y1 : Float,
  z1 : Float,
  r1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
  r2 : Float,
) -> Bool {
  let dist_sq = distance_squared_3d(x1, y1, z1, x2, y2, z2)
  let combined_r = r1 + r2
  dist_sq < combined_r * combined_r
}

// Distance culling: check if object is within render distance

///|
pub fn within_render_distance(
  cam_x : Float,
  cam_y : Float,
  cam_z : Float,
  obj_x : Float,
  obj_y : Float,
  obj_z : Float,
  max_dist : Float,
) -> Bool {
  let dist_sq = distance_squared_3d(cam_x, cam_y, cam_z, obj_x, obj_y, obj_z)
  dist_sq < max_dist * max_dist
}

// Damage calculation with shield absorption

///|
pub fn calc_damage(
  damage : Float,
  shield : Float,
  armor_factor : Float,
) -> (Float, Float) {
  // Returns (hull_damage, shield_remaining)
  let effective_damage = damage * (1.0 - armor_factor * 0.5)
  if shield > 0.0 {
    let absorbed = minf(shield, effective_damage)
    let remaining_shield = shield - absorbed
    let remaining_damage = effective_damage - absorbed
    (remaining_damage, remaining_shield)
  } else {
    (effective_damage, 0.0)
  }
}

// Angle difference (handles wrapping)

///|
pub fn angle_diff(a : Float, b : Float) -> Float {
  let mut d = b - a
  if d > pi {
    d = d - two_pi
  }
  if d < -pi {
    d = d + two_pi
  }
  d
}

// Smooth damp (spring-like interpolation)

///|
pub fn smooth_damp(
  current : Float,
  target : Float,
  speed : Float,
  dt : Float,
) -> Float {
  let diff = target - current
  current + diff * clampf(speed * dt, 0.0, 1.0)
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

///|
pub fn rand_bool(game : Game, chance : Float) -> Bool {
  rand_rangef(game, 0.0, 1.0) < chance
}

///|
pub fn alloc_enemy(game : Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_projectile(game : Game) -> Int {
  for i in 0..<game.projectiles.length() {
    if not(game.projectiles[i].active) {
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

///|
pub fn alloc_asteroid(game : Game) -> Int {
  for i in 0..<game.asteroids.length() {
    if not(game.asteroids[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_powerup(game : Game) -> Int {
  for i in 0..<game.powerups.length() {
    if not(game.powerups[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_station(game : Game) -> Int {
  for i in 0..<game.stations.length() {
    if not(game.stations[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_debris(game : Game) -> Int {
  for i in 0..<game.debris.length() {
    if not(game.debris[i].active) {
      return i
    }
  }
  -1
}

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
    p.x = wx + rand_rangef(game, -0.5, 0.5)
    p.y = wy + rand_rangef(game, -0.5, 0.5)
    p.z = wz + rand_rangef(game, -0.5, 0.5)
    p.vx = rand_rangef(game, -8.0, 8.0)
    p.vy = rand_rangef(game, -8.0, 8.0)
    p.vz = rand_rangef(game, -8.0, 8.0)
    p.life = rand_rangef(game, 0.3, 1.0)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.05, 0.2)
    p.kind = 0
    ignore(i)
  }
}

///|
pub fn spawn_explosion(
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
    p.x = wx
    p.y = wy
    p.z = wz
    p.vx = rand_rangef(game, -15.0, 15.0)
    p.vy = rand_rangef(game, -15.0, 15.0)
    p.vz = rand_rangef(game, -15.0, 15.0)
    p.life = rand_rangef(game, 0.5, 1.5)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.1, 0.4)
    p.kind = 1
    ignore(i)
  }
}

// Spawn shield hit particles at a specific point

///|
pub fn spawn_shield_hit(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx
    p.y = wy
    p.z = wz
    p.vx = rand_rangef(game, -5.0, 5.0)
    p.vy = rand_rangef(game, -5.0, 5.0)
    p.vz = rand_rangef(game, -5.0, 5.0)
    p.life = rand_rangef(game, 0.2, 0.5)
    p.max_life = p.life
    p.r = 80
    p.g = 160
    p.b = 255
    p.size = rand_rangef(game, 0.08, 0.15)
    p.kind = 2
    ignore(i)
  }
}

// Spawn debris from destroyed ship

///|
pub fn spawn_debris(
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
    let idx = alloc_debris(game)
    if idx < 0 {
      return
    }
    let d = game.debris[idx]
    d.active = true
    d.x = wx + rand_rangef(game, -1.0, 1.0)
    d.y = wy + rand_rangef(game, -1.0, 1.0)
    d.z = wz + rand_rangef(game, -1.0, 1.0)
    d.vx = rand_rangef(game, -10.0, 10.0)
    d.vy = rand_rangef(game, -10.0, 10.0)
    d.vz = rand_rangef(game, -10.0, 10.0)
    d.rot_x = rand_rangef(game, 0.0, 6.28)
    d.rot_y = rand_rangef(game, 0.0, 6.28)
    d.rot_speed = rand_rangef(game, 1.0, 4.0)
    d.life = rand_rangef(game, 3.0, 6.0)
    d.size = rand_rangef(game, 0.2, 0.6)
    d.r = r
    d.g = g
    d.b = b
    ignore(i)
  }
}

// Count active enemies

///|
pub fn count_active_enemies(game : Game) -> Int {
  let mut count = 0
  for i in 0..<game.enemies.length() {
    if game.enemies[i].active {
      count += 1
    }
  }
  count
}

// Count active enemies of a type

///|
pub fn count_enemies_of_type(game : Game, kind : Int) -> Int {
  let mut count = 0
  for i in 0..<game.enemies.length() {
    if game.enemies[i].active && game.enemies[i].kind == kind {
      count += 1
    }
  }
  count
}

// Find nearest enemy to a position

///|
pub fn find_nearest_enemy(game : Game, x : Float, y : Float, z : Float) -> Int {
  let mut best_idx = -1
  let mut best_dist : Float = 999999.0
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    let dist = distance3d(x, y, z, e.x, e.y, e.z)
    if dist < best_dist {
      best_dist = dist
      best_idx = i
    }
  }
  best_idx
}

// Weapon name

///|
pub fn weapon_name(weapon : Int) -> String {
  if weapon == weapon_laser {
    "LASER"
  } else if weapon == weapon_missile {
    "MISSILE"
  } else if weapon == weapon_plasma {
    "PLASMA"
  } else if weapon == weapon_railgun {
    "RAILGUN"
  } else {
    "UNKNOWN"
  }
}

// Weapon cooldown

///|
pub fn weapon_cooldown(weapon : Int) -> Float {
  if weapon == weapon_laser {
    laser_cooldown
  } else if weapon == weapon_missile {
    missile_cooldown
  } else if weapon == weapon_plasma {
    plasma_cooldown
  } else if weapon == weapon_railgun {
    railgun_cooldown
  } else {
    1.0
  }
}

// Weapon energy cost

///|
pub fn weapon_energy_cost(weapon : Int) -> Float {
  if weapon == weapon_laser {
    laser_energy_cost
  } else if weapon == weapon_missile {
    0.0
  } else if weapon == weapon_plasma {
    plasma_energy_cost
  } else if weapon == weapon_railgun {
    railgun_energy_cost
  } else {
    0.0
  }
}

// Weapon speed

///|
pub fn weapon_proj_speed(weapon : Int) -> Float {
  if weapon == weapon_laser {
    laser_speed
  } else if weapon == weapon_missile {
    missile_speed
  } else if weapon == weapon_plasma {
    plasma_speed
  } else if weapon == weapon_railgun {
    railgun_speed
  } else {
    100.0
  }
}

// Enemy type name

///|
pub fn enemy_type_name(kind : Int) -> String {
  if kind == enemy_fighter {
    "Fighter"
  } else if kind == enemy_cruiser {
    "Cruiser"
  } else if kind == enemy_interceptor {
    "Interceptor"
  } else if kind == enemy_bomber {
    "Bomber"
  } else if kind == enemy_capital {
    "Capital Ship"
  } else {
    "Asteroid"
  }
}

// Wrap coordinate within world bounds

///|
pub fn wrap_coord(v : Float) -> Float {
  let half = world_size
  if v > half {
    v - half * 2.0
  } else if v < -half {
    v + half * 2.0
  } else {
    v
  }
}

// Add kill feed entry

///|
pub fn add_kill_feed(
  game : Game,
  text : String,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  // Shift existing entries up
  for i = max_kill_feed - 1; i > 0; i = i - 1 {
    game.kill_feed[i].active = game.kill_feed[i - 1].active
    game.kill_feed[i].text = game.kill_feed[i - 1].text
    game.kill_feed[i].timer = game.kill_feed[i - 1].timer
    game.kill_feed[i].r = game.kill_feed[i - 1].r
    game.kill_feed[i].g = game.kill_feed[i - 1].g
    game.kill_feed[i].b = game.kill_feed[i - 1].b
  }
  game.kill_feed[0].active = true
  game.kill_feed[0].text = text
  game.kill_feed[0].timer = kill_feed_duration
  game.kill_feed[0].r = r
  game.kill_feed[0].g = g
  game.kill_feed[0].b = b
}

// Update combo system

///|
pub fn update_combo(game : Game, dt : Float) -> Unit {
  if game.combo_timer > 0.0 {
    game.combo_timer -= dt
    if game.combo_timer <= 0.0 {
      game.combo_count = 0
      game.combo_multiplier = 1.0
    }
  }
}

// Register a kill for combo

///|
pub fn register_kill_combo(game : Game) -> Unit {
  game.combo_count += 1
  game.combo_timer = combo_timeout
  if game.combo_count >= 8 {
    game.combo_multiplier = combo_mult_8
  } else if game.combo_count >= 5 {
    game.combo_multiplier = combo_mult_5
  } else if game.combo_count >= 3 {
    game.combo_multiplier = combo_mult_3
  } else if game.combo_count >= 2 {
    game.combo_multiplier = combo_mult_2
  } else {
    game.combo_multiplier = 1.0
  }
}

// Formation position calculation

///|
pub fn formation_offset(
  pattern : Int,
  index : Int,
  spacing : Float,
) -> (Float, Float, Float) {
  let fi = Float::from_int(index)
  if pattern == formation_v {
    // V formation: alternating left/right, pushed back
    let side : Float = if index % 2 == 0 { 1.0 } else { -1.0 }
    let rank = Float::from_int((index + 1) / 2)
    (side * rank * spacing, 0.0, -rank * spacing * 0.8)
  } else if pattern == formation_line {
    // Line abreast
    let half = fi - 3.0
    (half * spacing, 0.0, 0.0)
  } else if pattern == formation_circle {
    // Circle formation
    let angle = fi * (two_pi / 8.0)
    let r = spacing * 2.0
    (@math.cosf(angle) * r, 0.0, @math.sinf(angle) * r)
  } else {
    // Wedge (arrow)
    let side : Float = if index % 2 == 0 { 1.0 } else { -1.0 }
    let rank = Float::from_int((index + 1) / 2)
    (side * rank * spacing * 0.7, rank * spacing * 0.3, -rank * spacing)
  }
}

// Check and update mission objectives

///|
pub fn check_objective_progress(
  game : Game,
  obj_type : Int,
  increment : Int,
) -> Unit {
  for i in 0..<game.objectives_count {
    let obj = game.objectives[i]
    if obj.obj_type == obj_type && not(obj.complete) {
      obj.current_count = obj.current_count + increment
      if obj.current_count >= obj.target_count {
        obj.current_count = obj.target_count
        obj.complete = true
      }
    }
  }
}

// Check if all objectives are complete

///|
pub fn all_objectives_complete(game : Game) -> Bool {
  if game.objectives_count == 0 {
    return false
  }
  for i in 0..<game.objectives_count {
    if not(game.objectives[i].complete) {
      return false
    }
  }
  true
}

// Accuracy percentage

///|
pub fn calc_accuracy(shots_fired : Int, shots_hit : Int) -> Int {
  if shots_fired <= 0 {
    0
  } else {
    let pct = Float::from_int(shots_hit) / Float::from_int(shots_fired) * 100.0
    pct.to_int()
  }
}

// Mission rank based on score, time, accuracy

///|
pub fn calc_rank(score : Int, time : Float, accuracy : Int) -> String {
  let score_pts : Int = score / 100
  let time_bonus : Int = if time < 60.0 {
    50
  } else if time < 120.0 {
    30
  } else if time < 180.0 {
    15
  } else {
    0
  }
  let acc_bonus : Int = accuracy / 2
  let total = score_pts + time_bonus + acc_bonus
  if total >= 80 {
    "S"
  } else if total >= 60 {
    "A"
  } else if total >= 40 {
    "B"
  } else if total >= 20 {
    "C"
  } else {
    "D"
  }
}
