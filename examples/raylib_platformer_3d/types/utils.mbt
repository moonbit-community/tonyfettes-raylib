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
pub fn signf(v : Float) -> Float {
  if v > 0.0 {
    1.0
  } else if v < 0.0 {
    -1.0
  } else {
    0.0
  }
}

///|
pub fn dist2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x1 - x2
  let dz = z1 - z2
  (dx * dx + dz * dz).sqrt()
}

///|
pub fn dist3d(
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

// Smoothstep interpolation (cubic ease in/out)

///|
pub fn smoothstep(edge0 : Float, edge1 : Float, x : Float) -> Float {
  let t = clampf((x - edge0) / (edge1 - edge0), 0.0, 1.0)
  t * t * (3.0 - 2.0 * t)
}

// Ease-in quadratic

///|
pub fn ease_in_quad(t : Float) -> Float {
  t * t
}

// Ease-out quadratic

///|
pub fn ease_out_quad(t : Float) -> Float {
  t * (2.0 - t)
}

// Ease-in-out quadratic

///|
pub fn ease_in_out_quad(t : Float) -> Float {
  if t < 0.5 {
    2.0 * t * t
  } else {
    -1.0 + (4.0 - 2.0 * t) * t
  }
}

// Ease-out bounce

///|
pub fn ease_out_bounce(t_in : Float) -> Float {
  let n1 : Float = 7.5625
  let d1 : Float = 2.75
  let mut t = t_in
  if t < 1.0 / d1 {
    n1 * t * t
  } else if t < 2.0 / d1 {
    t = t - 1.5 / d1
    n1 * t * t + 0.75
  } else if t < 2.5 / d1 {
    t = t - 2.25 / d1
    n1 * t * t + 0.9375
  } else {
    t = t - 2.625 / d1
    n1 * t * t + 0.984375
  }
}

// Ease-out elastic (simplified)

///|
pub fn ease_out_elastic(t : Float) -> Float {
  if t <= 0.0 {
    return 0.0
  }
  if t >= 1.0 {
    return 1.0
  }
  let c4 : Float = two_pi / 3.0
  let neg10 : Float = -10.0
  let power : Float = neg10 * t
  let ln2 : Float = 0.6931472
  let x : Float = power * ln2
  let ax : Float = absf(x)
  let exp_val : Float = if ax > 10.0 {
    0.0
  } else {
    let mut result : Float = 1.0
    let mut term : Float = x
    result = result + term
    term = term * x / 2.0
    result = result + term
    term = term * x / 3.0
    result = result + term
    term = term * x / 4.0
    result = result + term
    term = term * x / 5.0
    result = result + term
    term = term * x / 6.0
    result = result + term
    if result < 0.0 {
      0.0
    } else {
      result
    }
  }
  let sin_arg : Float = (t * 10.0 - 0.75) * c4
  exp_val * @math.sinf(sin_arg) + 1.0
}

// Move toward value

///|
pub fn move_toward(current : Float, target : Float, max_delta : Float) -> Float {
  let diff = target - current
  if absf(diff) <= max_delta {
    target
  } else {
    current + signf(diff) * max_delta
  }
}

// Wrap angle to 0..360

///|
pub fn wrap_angle(angle : Float) -> Float {
  let mut a = angle
  for {
    if a >= 360.0 {
      a = a - 360.0
    } else if a < 0.0 {
      a = a + 360.0
    } else {
      break
    }
  }
  a
}

// Normalize a 2D vector, returning (nx, nz, length)

///|
pub fn normalize2d(x : Float, z : Float) -> (Float, Float, Float) {
  let len = (x * x + z * z).sqrt()
  if len > 0.001 {
    (x / len, z / len, len)
  } else {
    (0.0, 0.0, 0.0)
  }
}

// Dot product 2d

///|
pub fn dot2d(ax : Float, az : Float, bx : Float, bz : Float) -> Float {
  ax * bx + az * bz
}

// Dot product 3d

///|
pub fn dot3d(
  ax : Float,
  ay : Float,
  az : Float,
  bx : Float,
  by : Float,
  bz : Float,
) -> Float {
  ax * bx + ay * by + az * bz
}

// Reflect 2d vector off normal

///|
pub fn reflect2d(
  vx : Float,
  vz : Float,
  nx : Float,
  nz : Float,
) -> (Float, Float) {
  let dp : Float = dot2d(vx, vz, nx, nz)
  let d : Float = 2.0 * dp
  (vx - d * nx, vz - d * nz)
}

// AABB overlap check

///|
pub fn aabb_overlap(
  ax : Float,
  ay : Float,
  az : Float,
  aw : Float,
  ah : Float,
  ad : Float,
  bx : Float,
  by : Float,
  bz : Float,
  bw : Float,
  bh : Float,
  bd : Float,
) -> Bool {
  let a_min_x = ax - aw / 2.0
  let a_max_x = ax + aw / 2.0
  let a_min_y = ay - ah / 2.0
  let a_max_y = ay + ah / 2.0
  let a_min_z = az - ad / 2.0
  let a_max_z = az + ad / 2.0
  let b_min_x = bx - bw / 2.0
  let b_max_x = bx + bw / 2.0
  let b_min_y = by - bh / 2.0
  let b_max_y = by + bh / 2.0
  let b_min_z = bz - bd / 2.0
  let b_max_z = bz + bd / 2.0
  a_min_x < b_max_x &&
  a_max_x > b_min_x &&
  a_min_y < b_max_y &&
  a_max_y > b_min_y &&
  a_min_z < b_max_z &&
  a_max_z > b_min_z
}

// Sphere-AABB overlap

///|
pub fn sphere_aabb(
  sx : Float,
  sy : Float,
  sz : Float,
  sr : Float,
  bx : Float,
  by : Float,
  bz : Float,
  bw : Float,
  bh : Float,
  bd : Float,
) -> Bool {
  let closest_x = clampf(sx, bx - bw / 2.0, bx + bw / 2.0)
  let closest_y = clampf(sy, by - bh / 2.0, by + bh / 2.0)
  let closest_z = clampf(sz, bz - bd / 2.0, bz + bd / 2.0)
  let dx = sx - closest_x
  let dy = sy - closest_y
  let dz = sz - closest_z
  dx * dx + dy * dy + dz * dz < sr * sr
}

// Check if point is above a platform (for shadow casting)

///|
pub fn point_above_platform(
  px : Float,
  pz : Float,
  bx : Float,
  bz : Float,
  bw : Float,
  bd : Float,
) -> Bool {
  px > bx - bw / 2.0 &&
  px < bx + bw / 2.0 &&
  pz > bz - bd / 2.0 &&
  pz < bz + bd / 2.0
}

// Find highest platform below a point (for shadow y)

///|
pub fn find_shadow_y(game : Game, px : Float, py : Float, pz : Float) -> Float {
  let mut best_y : Float = -25.0
  for plat in game.platforms {
    if not(plat.active) {
      continue
    }
    if point_above_platform(px, pz, plat.x, plat.z, plat.w, plat.d) {
      let top = plat.y + plat.h / 2.0
      if top < py && top > best_y {
        best_y = top
      }
    }
  }
  best_y
}

// Calculate shadow alpha based on height above surface

///|
pub fn shadow_alpha(py : Float, shadow_y : Float) -> Int {
  let height = py - shadow_y
  if height < 0.0 {
    return 0
  }
  if height > shadow_max_height {
    return shadow_min_alpha
  }
  let ratio : Float = height / shadow_max_height
  let t : Float = 1.0 - ratio
  let min_f : Float = Float::from_int(shadow_min_alpha)
  let range_f : Float = Float::from_int(shadow_max_alpha - shadow_min_alpha)
  let alpha_f : Float = min_f + t * range_f
  clampi(alpha_f.to_int(), shadow_min_alpha, shadow_max_alpha)
}

// Calculate shadow size based on height

///|
pub fn shadow_scale(py : Float, shadow_y : Float) -> Float {
  let height = py - shadow_y
  if height < 0.0 {
    return shadow_size_base
  }
  let t = clampf(height / shadow_max_height, 0.0, 1.0)
  shadow_size_base * (1.0 - t * 0.5)
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
    p.x = wx + rand_rangef(game, -0.3, 0.3)
    p.y = wy + rand_rangef(game, 0.0, 0.4)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -2.0, 2.0)
    p.vy = rand_rangef(game, 1.5, 5.0)
    p.vz = rand_rangef(game, -2.0, 2.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.1)
    p.kind = 0
    ignore(i)
  }
}

// Spawn directional particles (e.g., for wall slide)

///|
pub fn spawn_particles_dir(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  dvx : Float,
  dvy : Float,
  dvz : Float,
  spread : Float,
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
    p.x = wx + rand_rangef(game, -0.15, 0.15)
    p.y = wy + rand_rangef(game, -0.15, 0.15)
    p.z = wz + rand_rangef(game, -0.15, 0.15)
    p.vx = dvx + rand_rangef(game, -spread, spread)
    p.vy = dvy + rand_rangef(game, -spread, spread)
    p.vz = dvz + rand_rangef(game, -spread, spread)
    p.life = rand_rangef(game, 0.2, 0.6)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.03, 0.08)
    p.kind = 0
    ignore(i)
  }
}

// Spawn ring of particles (for power-up aura, checkpoint activation)

///|
pub fn spawn_particle_ring(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  radius : Float,
  speed : Float,
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
    let angle = Float::from_int(i) / Float::from_int(count) * two_pi
    p.active = true
    p.x = wx + @math.cosf(angle) * radius
    p.y = wy
    p.z = wz + @math.sinf(angle) * radius
    p.vx = @math.cosf(angle) * speed
    p.vy = rand_rangef(game, 1.0, 3.0)
    p.vz = @math.sinf(angle) * speed
    p.life = rand_rangef(game, 0.4, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.05, 0.12)
    p.kind = 0
    ignore(i)
  }
}

// Allocate enemy slot

///|
pub fn alloc_enemy(game : Game) -> Int {
  for i in 0..<game.enemies.length() {
    if not(game.enemies[i].active) {
      return i
    }
  }
  -1
}

// Allocate projectile slot

///|
pub fn alloc_projectile(game : Game) -> Int {
  for i in 0..<game.projectiles.length() {
    if not(game.projectiles[i].active) {
      return i
    }
  }
  -1
}

// Allocate score fly slot

///|
pub fn alloc_score_fly(game : Game) -> Int {
  for i in 0..<game.score_flies.length() {
    if not(game.score_flies[i].active) {
      return i
    }
  }
  -1
}

// Spawn a score fly text

///|
pub fn spawn_score_fly(
  game : Game,
  screen_x : Float,
  screen_y : Float,
  value : Int,
) -> Unit {
  let idx = alloc_score_fly(game)
  if idx < 0 {
    return
  }
  let sf = game.score_flies[idx]
  sf.active = true
  sf.x = screen_x
  sf.y = screen_y
  sf.value = value
  sf.timer = 0.0
  sf.max_time = 1.2
}

// Add score with combo

///|
pub fn add_score(game : Game, base : Int) -> Unit {
  let mult_score = Float::from_int(base) * game.combo_mult
  game.score = game.score + mult_score.to_int()
  game.combo_count += 1
  game.combo_timer = combo_decay_time
  game.combo_mult = minf(
    combo_base_mult + Float::from_int(game.combo_count) * combo_increment,
    combo_max,
  )
}

// Camera shake trigger

///|
pub fn trigger_cam_shake(
  game : Game,
  intensity : Float,
  duration : Float,
) -> Unit {
  game.cam_shake = intensity
  game.cam_shake_timer = duration
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

// Map a value from one range to another

///|
pub fn map_range(
  value : Float,
  in_low : Float,
  in_high : Float,
  out_low : Float,
  out_high : Float,
) -> Float {
  let t = clampf((value - in_low) / (in_high - in_low), 0.0, 1.0)
  out_low + (out_high - out_low) * t
}

// Approach float value at a given speed

///|
pub fn approach(
  current : Float,
  target : Float,
  speed : Float,
  dt : Float,
) -> Float {
  let diff = target - current
  if absf(diff) < speed * dt {
    target
  } else {
    current + signf(diff) * speed * dt
  }
}

// Color lerp helper (returns int 0-255)

///|
pub fn lerp_color(a : Int, b : Int, t : Float) -> Int {
  let tc = clampf(t, 0.0, 1.0)
  let result = Float::from_int(a) +
    (Float::from_int(b) - Float::from_int(a)) * tc
  clampi(result.to_int(), 0, 255)
}

// Pulse helper: returns 0..1 with sine wave

///|
pub fn pulse(timer : Float, speed : Float) -> Float {
  (@math.sinf(timer * speed) + 1.0) * 0.5
}

// Flash helper: returns true for on_time, false for off_time

///|
pub fn flash_on(timer : Float, period : Float) -> Bool {
  let ratio : Float = timer / period
  let floored : Float = Float::from_int(ratio.to_int())
  let phase : Float = timer - floored * period
  phase < period * 0.5
}

// Calculate star rating for level completion

///|
pub fn calc_stars(
  time : Float,
  gems : Int,
  total_gems : Int,
  deaths : Int,
) -> Int {
  let mut stars = 1
  if deaths == 0 {
    stars = stars + 1
  }
  if gems == total_gems && time < star_time_threshold_1 {
    stars = stars + 1
  }
  if stars > 3 {
    stars = 3
  }
  stars
}
