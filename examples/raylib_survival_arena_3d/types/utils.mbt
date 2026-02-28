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
pub fn distance2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x1 - x2
  let dz = z1 - z2
  (dx * dx + dz * dz).sqrt()
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
pub fn normalize3d(x : Float, y : Float, z : Float) -> (Float, Float, Float) {
  let len = (x * x + y * y + z * z).sqrt()
  if len < 0.0001 {
    (0.0, 0.0, 0.0)
  } else {
    (x / len, y / len, z / len)
  }
}

// Dot product of two 3d vectors

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

// Angle between two 2d vectors (returns radians)

///|
pub fn angle_between(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  @math.atan2f(z2 - z1, x2 - x1)
}

// Check if angle difference is within threshold (for shield check)

///|
pub fn angle_within(angle1 : Float, angle2 : Float, threshold : Float) -> Bool {
  let mut diff = angle1 - angle2
  if diff > pi {
    diff = diff - 2.0 * pi
  }
  if diff < -pi {
    diff = diff + 2.0 * pi
  }
  absf(diff) < threshold
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

// Allocators

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
pub fn alloc_pickup(game : Game) -> Int {
  for i in 0..<game.pickups.length() {
    if not(game.pickups[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_barricade(game : Game) -> Int {
  for i in 0..<game.barricades.length() {
    if not(game.barricades[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn alloc_trap(game : Game) -> Int {
  for i in 0..<game.traps.length() {
    if not(game.traps[i].active) {
      return i
    }
  }
  -1
}

// Spawn particles

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
    p.y = wy + rand_rangef(game, 0.0, 0.5)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -3.0, 3.0)
    p.vy = rand_rangef(game, 1.0, 6.0)
    p.vz = rand_rangef(game, -3.0, 3.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.12)
    p.kind = particle_blood
    ignore(i)
  }
}

// Spawn typed particles

///|
pub fn spawn_particles_typed(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
  kind : Int,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx + rand_rangef(game, -0.3, 0.3)
    p.y = wy + rand_rangef(game, 0.0, 0.5)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -3.0, 3.0)
    p.vy = rand_rangef(game, 1.0, 6.0)
    p.vz = rand_rangef(game, -3.0, 3.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.12)
    p.kind = kind
    ignore(i)
  }
}

// Spawn directional particles (for muzzle flash etc)

///|
pub fn spawn_particles_dir(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  dx : Float,
  dy : Float,
  dz : Float,
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
    p.vx = dx * rand_rangef(game, 2.0, 5.0) + rand_rangef(game, -1.0, 1.0)
    p.vy = dy * rand_rangef(game, 2.0, 5.0) + rand_rangef(game, -0.5, 2.0)
    p.vz = dz * rand_rangef(game, 2.0, 5.0) + rand_rangef(game, -1.0, 1.0)
    p.life = rand_rangef(game, 0.1, 0.4)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.03, 0.08)
    p.kind = particle_muzzle
    ignore(i)
  }
}

// Spawn shell casing particle

///|
pub fn spawn_shell_casing(
  game : Game,
  x : Float,
  y : Float,
  z : Float,
  right_x : Float,
  right_z : Float,
) -> Unit {
  let idx = alloc_particle(game)
  if idx < 0 {
    return
  }
  let p = game.particles[idx]
  p.active = true
  p.x = x + right_x * 0.3
  p.y = y - 0.1
  p.z = z + right_z * 0.3
  p.vx = right_x * rand_rangef(game, 2.0, 4.0)
  p.vy = rand_rangef(game, 1.0, 3.0)
  p.vz = right_z * rand_rangef(game, 2.0, 4.0)
  p.life = rand_rangef(game, 0.5, 1.2)
  p.max_life = p.life
  p.r = 200
  p.g = 180
  p.b = 50
  p.size = 0.04
  p.kind = particle_shell
}

// Check if point is inside arena bounds

///|
pub fn in_arena(x : Float, z : Float) -> Bool {
  let half_w = arena_width / 2.0 - arena_wall_thickness
  let half_d = arena_depth / 2.0 - arena_wall_thickness
  x > -half_w && x < half_w && z > -half_d && z < half_d
}

// Clamp position to arena bounds

///|
pub fn clamp_to_arena(x : Float, z : Float) -> (Float, Float) {
  let half_w = arena_width / 2.0 - arena_wall_thickness - 0.3
  let half_d = arena_depth / 2.0 - arena_wall_thickness - 0.3
  (clampf(x, -half_w, half_w), clampf(z, -half_d, half_d))
}

// Check circle vs pillar collision, return pushed position

///|
pub fn push_from_pillar(
  x : Float,
  z : Float,
  radius : Float,
  px : Float,
  pz : Float,
  pradius : Float,
) -> (Float, Float, Bool) {
  let dx = x - px
  let dz = z - pz
  let dist = (dx * dx + dz * dz).sqrt()
  let min_dist = radius + pradius
  if dist < min_dist && dist > 0.001 {
    let push = min_dist - dist
    let nx = dx / dist
    let nz = dz / dist
    (x + nx * push, z + nz * push, true)
  } else {
    (x, z, false)
  }
}

// Check circle vs box collision (for low walls, barricades)

///|
pub fn push_from_box(
  x : Float,
  z : Float,
  radius : Float,
  bx : Float,
  bz : Float,
  bw : Float,
  bd : Float,
) -> (Float, Float, Bool) {
  let half_w = bw / 2.0
  let half_d = bd / 2.0
  // Find closest point on box to circle
  let closest_x = clampf(x, bx - half_w, bx + half_w)
  let closest_z = clampf(z, bz - half_d, bz + half_d)
  let dx = x - closest_x
  let dz = z - closest_z
  let dist = (dx * dx + dz * dz).sqrt()
  if dist < radius && dist > 0.001 {
    let push = radius - dist
    let nx = dx / dist
    let nz = dz / dist
    (x + nx * push, z + nz * push, true)
  } else if dist < 0.001 &&
    absf(x - bx) < half_w + radius &&
    absf(z - bz) < half_d + radius {
    // Inside the box, push out on nearest edge
    let dx_edge = half_w + radius - absf(x - bx)
    let dz_edge = half_d + radius - absf(z - bz)
    if dx_edge < dz_edge {
      let push_dir = sign(x - bx)
      (x + push_dir * dx_edge, z, true)
    } else {
      let push_dir = sign(z - bz)
      (x, z + push_dir * dz_edge, true)
    }
  } else {
    (x, z, false)
  }
}

// Weapon name

///|
pub fn weapon_name(kind : Int) -> String {
  if kind == weapon_pistol {
    "Pistol"
  } else if kind == weapon_shotgun {
    "Shotgun"
  } else if kind == weapon_rifle {
    "Rifle"
  } else if kind == weapon_sniper {
    "Sniper"
  } else if kind == weapon_rocket {
    "Rocket"
  } else if kind == weapon_minigun {
    "Minigun"
  } else {
    "Unknown"
  }
}

// Weapon short name for UI slots

///|
pub fn weapon_short_name(kind : Int) -> String {
  if kind == weapon_pistol {
    "P"
  } else if kind == weapon_shotgun {
    "SG"
  } else if kind == weapon_rifle {
    "AR"
  } else if kind == weapon_sniper {
    "SN"
  } else if kind == weapon_rocket {
    "RL"
  } else if kind == weapon_minigun {
    "MG"
  } else {
    "?"
  }
}

// Weapon fire rate (base)

///|
pub fn weapon_fire_rate(kind : Int) -> Float {
  if kind == weapon_pistol {
    rate_pistol
  } else if kind == weapon_shotgun {
    rate_shotgun
  } else if kind == weapon_rifle {
    rate_rifle
  } else if kind == weapon_sniper {
    rate_sniper
  } else if kind == weapon_rocket {
    rate_rocket
  } else if kind == weapon_minigun {
    rate_minigun
  } else {
    1.0
  }
}

// Weapon damage (base)

///|
pub fn weapon_damage(kind : Int) -> Float {
  if kind == weapon_pistol {
    dmg_pistol
  } else if kind == weapon_shotgun {
    dmg_shotgun
  } else if kind == weapon_rifle {
    dmg_rifle
  } else if kind == weapon_sniper {
    dmg_sniper
  } else if kind == weapon_rocket {
    dmg_rocket
  } else if kind == weapon_minigun {
    dmg_minigun
  } else {
    0.0
  }
}

// Weapon projectile speed

///|
pub fn weapon_proj_speed(kind : Int) -> Float {
  if kind == weapon_pistol {
    speed_pistol
  } else if kind == weapon_shotgun {
    speed_shotgun
  } else if kind == weapon_rifle {
    speed_rifle
  } else if kind == weapon_sniper {
    speed_sniper
  } else if kind == weapon_rocket {
    speed_rocket
  } else if kind == weapon_minigun {
    speed_minigun
  } else {
    30.0
  }
}

// Weapon reload time (base)

///|
pub fn weapon_reload_time(kind : Int) -> Float {
  if kind == weapon_pistol {
    reload_pistol
  } else if kind == weapon_shotgun {
    reload_shotgun
  } else if kind == weapon_rifle {
    reload_rifle
  } else if kind == weapon_sniper {
    reload_sniper
  } else if kind == weapon_rocket {
    reload_rocket
  } else if kind == weapon_minigun {
    reload_minigun
  } else {
    1.0
  }
}

// Weapon magazine size (base)

///|
pub fn weapon_mag_size(kind : Int) -> Int {
  if kind == weapon_pistol {
    mag_pistol
  } else if kind == weapon_shotgun {
    mag_shotgun
  } else if kind == weapon_rifle {
    mag_rifle
  } else if kind == weapon_sniper {
    mag_sniper
  } else if kind == weapon_rocket {
    mag_rocket
  } else if kind == weapon_minigun {
    mag_minigun
  } else {
    10
  }
}

// Get effective fire rate with upgrades

///|
pub fn effective_fire_rate(player : Player, kind : Int) -> Float {
  let base = weapon_fire_rate(kind)
  let lvl = Float::from_int(player.weapon_rate_level[kind])
  let mult : Float = 1.0 - lvl * 0.12
  base * mult
}

// Get effective damage with upgrades and boosts

///|
pub fn effective_damage(player : Player, kind : Int) -> Float {
  let base = weapon_damage(kind)
  let lvl = Float::from_int(player.weapon_damage_level[kind])
  let upgrade_mult : Float = 1.0 + lvl * 0.2
  let boost_mult : Float = if player.damage_boost_timer > 0.0 {
    1.5
  } else {
    1.0
  }
  base * upgrade_mult * player.damage_mult * boost_mult
}

// Get effective magazine size with upgrades

///|
pub fn effective_mag_size(player : Player, kind : Int) -> Int {
  let base = weapon_mag_size(kind)
  let lvl = player.weapon_mag_level[kind]
  let bonus_f : Float = Float::from_int(base) * Float::from_int(lvl) * 0.3
  base + bonus_f.to_int()
}

// Enemy name

///|
pub fn enemy_name(kind : Int) -> String {
  if kind == enemy_zombie {
    "Zombie"
  } else if kind == enemy_runner {
    "Runner"
  } else if kind == enemy_brute {
    "Brute"
  } else if kind == enemy_spitter {
    "Spitter"
  } else if kind == enemy_exploder {
    "Exploder"
  } else if kind == enemy_necromancer {
    "Necromancer"
  } else if kind == enemy_shielded {
    "Shielded"
  } else if kind == enemy_boss {
    "Boss"
  } else {
    "Unknown"
  }
}

// Pickup name

///|
pub fn pickup_name(kind : Int) -> String {
  if kind == pickup_health {
    "Health Pack"
  } else if kind == pickup_ammo {
    "Ammo Crate"
  } else if kind == pickup_speed_boost {
    "Speed Boost"
  } else if kind == pickup_damage_boost {
    "Damage Boost"
  } else if kind == pickup_shield {
    "Shield"
  } else if kind == pickup_nuke {
    "NUKE"
  } else {
    "Unknown"
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

// Show temporary message

///|
pub fn show_message(game : Game, text : String, duration : Float) -> Unit {
  game.message_text = text
  game.message_timer = duration
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
  // Shift existing entries down
  for i = max_kill_feed - 1; i > 0; i = i - 1 {
    let prev = i - 1
    game.kill_feed[i].active = game.kill_feed[prev].active
    game.kill_feed[i].text = game.kill_feed[prev].text
    game.kill_feed[i].timer = game.kill_feed[prev].timer
    game.kill_feed[i].color_r = game.kill_feed[prev].color_r
    game.kill_feed[i].color_g = game.kill_feed[prev].color_g
    game.kill_feed[i].color_b = game.kill_feed[prev].color_b
  }
  game.kill_feed[0].active = true
  game.kill_feed[0].text = text
  game.kill_feed[0].timer = kill_feed_duration
  game.kill_feed[0].color_r = r
  game.kill_feed[0].color_g = g
  game.kill_feed[0].color_b = b
}

// Update kill feed timers

///|
pub fn update_kill_feed(game : Game, dt : Float) -> Unit {
  for i in 0..<max_kill_feed {
    if game.kill_feed[i].active {
      game.kill_feed[i].timer -= dt
      if game.kill_feed[i].timer <= 0.0 {
        game.kill_feed[i].active = false
      }
    }
  }
}

// Update damage indicators

///|
pub fn update_damage_indicators(game : Game, dt : Float) -> Unit {
  for i in 0..<game.damage_indicators.length() {
    if game.damage_indicators[i].active {
      game.damage_indicators[i].timer -= dt
      if game.damage_indicators[i].timer <= 0.0 {
        game.damage_indicators[i].active = false
      }
    }
  }
}

// Add damage indicator from a direction

///|
pub fn add_damage_indicator(
  game : Game,
  from_x : Float,
  from_z : Float,
) -> Unit {
  let angle = @math.atan2f(from_z - game.player.z, from_x - game.player.x)
  // Find inactive slot
  for i in 0..<game.damage_indicators.length() {
    if not(game.damage_indicators[i].active) {
      game.damage_indicators[i].active = true
      game.damage_indicators[i].angle = angle - game.player.yaw
      game.damage_indicators[i].timer = 1.0
      return
    }
  }
  // Overwrite oldest
  game.damage_indicators[0].active = true
  game.damage_indicators[0].angle = angle - game.player.yaw
  game.damage_indicators[0].timer = 1.0
}

// Check if a hit is a headshot based on projectile Y vs enemy center

///|
pub fn is_headshot_hit(
  proj_y : Float,
  enemy_y : Float,
  enemy_size : Float,
) -> Bool {
  let head_threshold = enemy_y + enemy_size * (1.0 - headshot_head_ratio)
  proj_y > head_threshold
}

// Get combo multiplier text

///|
pub fn combo_text(combo : Int) -> String {
  if combo >= 10 {
    "UNSTOPPABLE x\{combo}"
  } else if combo >= 7 {
    "RAMPAGE x\{combo}"
  } else if combo >= 5 {
    "KILLING SPREE x\{combo}"
  } else if combo >= 3 {
    "COMBO x\{combo}"
  } else {
    ""
  }
}

// Collision push against barricades

///|
pub fn push_from_barricades(
  game : Game,
  x : Float,
  z : Float,
  radius : Float,
) -> (Float, Float) {
  let mut rx = x
  let mut rz = z
  for i in 0..<game.barricades.length() {
    let b = game.barricades[i]
    if not(b.active) {
      continue
    }
    let result = push_from_box(
      rx,
      rz,
      radius,
      b.x,
      b.z,
      barricade_size,
      barricade_size,
    )
    rx = result.0
    rz = result.1
  }
  (rx, rz)
}

// Collision push against low walls

///|
pub fn push_from_low_walls(
  game : Game,
  x : Float,
  z : Float,
  radius : Float,
) -> (Float, Float) {
  let mut rx = x
  let mut rz = z
  for i in 0..<game.low_walls.length() {
    let w = game.low_walls[i]
    let result = push_from_box(rx, rz, radius, w.x, w.z, w.width, w.depth)
    rx = result.0
    rz = result.1
  }
  (rx, rz)
}
