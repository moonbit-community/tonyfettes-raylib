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
pub fn distance2d_sq(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x1 - x2
  let dz = z1 - z2
  dx * dx + dz * dz
}

///|
pub fn in_bounds(gx : Int, gy : Int) -> Bool {
  gx >= 0 && gy >= 0 && gx < map_w && gy < map_h
}

///|
pub fn tile_index(gx : Int, gy : Int) -> Int {
  gy * map_w + gx
}

///|
pub fn get_tile(game : Game, gx : Int, gy : Int) -> Int {
  if in_bounds(gx, gy) {
    game.tiles[tile_index(gx, gy)]
  } else {
    tile_rock
  }
}

///|
pub fn set_tile(game : Game, gx : Int, gy : Int, tile : Int) -> Unit {
  if in_bounds(gx, gy) {
    game.tiles[tile_index(gx, gy)] = tile
  }
}

///|
pub fn grid_to_world_x(gx : Int) -> Float {
  Float::from_int(gx) * cell_size + cell_size / 2.0
}

///|
pub fn grid_to_world_z(gy : Int) -> Float {
  Float::from_int(gy) * cell_size + cell_size / 2.0
}

///|
pub fn world_to_grid_x(wx : Float) -> Int {
  (wx / cell_size).to_int()
}

///|
pub fn world_to_grid_y(wz : Float) -> Int {
  (wz / cell_size).to_int()
}

///|
pub fn tower_at(game : Game, gx : Int, gy : Int) -> Int {
  for i in 0..<game.towers.length() {
    if game.towers[i].active &&
      game.towers[i].gx == gx &&
      game.towers[i].gy == gy {
      return i
    }
  }
  -1
}

///|
pub fn alloc_tower(game : Game) -> Int {
  for i in 0..<game.towers.length() {
    if not(game.towers[i].active) {
      return i
    }
  }
  -1
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

// Tower cost lookup (base cost)

///|
pub fn tower_cost_for(kind : Int) -> Int {
  if kind == tower_arrow {
    cost_arrow
  } else if kind == tower_cannon {
    cost_cannon
  } else if kind == tower_frost {
    cost_frost
  } else if kind == tower_lightning {
    cost_lightning
  } else if kind == tower_flame {
    cost_flame
  } else if kind == tower_sniper {
    cost_sniper
  } else if kind == tower_splash {
    cost_splash
  } else if kind == tower_buff {
    cost_buff
  } else {
    999
  }
}

// Keep old name for backward compatibility

///|
pub fn tower_cost(kind : Int) -> Int {
  tower_cost_for(kind)
}

// Tower upgrade cost for a given level

///|
pub fn tower_upgrade_cost(kind : Int, current_level : Int) -> Int {
  let base = tower_cost_for(kind)
  if current_level == 1 {
    let cost : Float = Float::from_int(base) * upgrade_cost_mult_2
    cost.to_int()
  } else if current_level == 2 {
    let cost : Float = Float::from_int(base) * upgrade_cost_mult_3
    cost.to_int()
  } else {
    0
  }
}

// Total investment in a tower (base + upgrades)

///|
pub fn tower_total_investment(kind : Int, level : Int) -> Int {
  let mut total = tower_cost_for(kind)
  if level >= 2 {
    let cost2 : Float = Float::from_int(tower_cost_for(kind)) *
      upgrade_cost_mult_2
    total = total + cost2.to_int()
  }
  if level >= 3 {
    let cost3 : Float = Float::from_int(tower_cost_for(kind)) *
      upgrade_cost_mult_3
    total = total + cost3.to_int()
  }
  total
}

// Tower sell value

///|
pub fn tower_sell_value(kind : Int, level : Int) -> Int {
  let invested = tower_total_investment(kind, level)
  let value : Float = Float::from_int(invested) * sell_value_pct
  value.to_int()
}

///|
pub fn tower_range(kind : Int) -> Float {
  if kind == tower_arrow {
    range_arrow
  } else if kind == tower_cannon {
    range_cannon
  } else if kind == tower_frost {
    range_frost
  } else if kind == tower_lightning {
    range_lightning
  } else if kind == tower_flame {
    range_flame
  } else if kind == tower_sniper {
    range_sniper
  } else if kind == tower_splash {
    range_splash
  } else if kind == tower_buff {
    range_buff
  } else {
    0.0
  }
}

// Tower range with level scaling and buff bonus

///|
pub fn tower_effective_range(tower : Tower) -> Float {
  let base = tower_range(tower.kind)
  let level_mult : Float = 1.0 +
    Float::from_int(tower.level - 1) * upgrade_range_mult
  let buff_mult : Float = 1.0 + tower.buff_range
  base * level_mult * buff_mult
}

///|
pub fn tower_damage(kind : Int) -> Float {
  if kind == tower_arrow {
    dmg_arrow
  } else if kind == tower_cannon {
    dmg_cannon
  } else if kind == tower_frost {
    dmg_frost
  } else if kind == tower_lightning {
    dmg_lightning
  } else if kind == tower_flame {
    dmg_flame
  } else if kind == tower_sniper {
    dmg_sniper
  } else if kind == tower_splash {
    dmg_splash
  } else if kind == tower_buff {
    dmg_buff
  } else {
    0.0
  }
}

// Tower damage with level scaling and buff bonus

///|
pub fn tower_effective_damage(tower : Tower) -> Float {
  let base = tower_damage(tower.kind)
  let level_mult : Float = 1.0 +
    Float::from_int(tower.level - 1) * upgrade_damage_mult
  let buff_mult : Float = 1.0 + tower.buff_damage
  base * level_mult * buff_mult
}

///|
pub fn tower_fire_rate(kind : Int) -> Float {
  if kind == tower_arrow {
    rate_arrow
  } else if kind == tower_cannon {
    rate_cannon
  } else if kind == tower_frost {
    rate_frost
  } else if kind == tower_lightning {
    rate_lightning
  } else if kind == tower_flame {
    rate_flame
  } else if kind == tower_sniper {
    rate_sniper
  } else if kind == tower_splash {
    rate_splash
  } else if kind == tower_buff {
    rate_buff
  } else {
    1.0
  }
}

// Tower fire rate with level scaling and buff bonus (lower = faster)

///|
pub fn tower_effective_rate(tower : Tower) -> Float {
  let base = tower_fire_rate(tower.kind)
  let level_mult : Float = 1.0 -
    Float::from_int(tower.level - 1) * upgrade_rate_mult
  let buff_mult : Float = 1.0 - tower.buff_rate
  let result : Float = base * level_mult * buff_mult
  maxf(result, 0.1)
}

///|
pub fn tower_name(kind : Int) -> String {
  if kind == tower_arrow {
    "Arrow"
  } else if kind == tower_cannon {
    "Cannon"
  } else if kind == tower_frost {
    "Frost"
  } else if kind == tower_lightning {
    "Lightning"
  } else if kind == tower_flame {
    "Flame"
  } else if kind == tower_sniper {
    "Sniper"
  } else if kind == tower_splash {
    "Splash"
  } else if kind == tower_buff {
    "Buff"
  } else {
    "Unknown"
  }
}

///|
pub fn tower_description(kind : Int) -> String {
  if kind == tower_arrow {
    "Fast single-target"
  } else if kind == tower_cannon {
    "Slow splash damage"
  } else if kind == tower_frost {
    "Slows enemies"
  } else if kind == tower_lightning {
    "Chain lightning"
  } else if kind == tower_flame {
    "Rapid fire burn"
  } else if kind == tower_sniper {
    "High damage crit"
  } else if kind == tower_splash {
    "Wide area damage"
  } else if kind == tower_buff {
    "Boosts nearby towers"
  } else {
    ""
  }
}

///|
pub fn enemy_name(kind : Int) -> String {
  if kind == enemy_basic {
    "Soldier"
  } else if kind == enemy_fast {
    "Scout"
  } else if kind == enemy_tank {
    "Heavy"
  } else if kind == enemy_flying {
    "Flyer"
  } else if kind == enemy_boss {
    "Boss"
  } else if kind == enemy_healer {
    "Medic"
  } else if kind == enemy_swarm {
    "Swarm"
  } else if kind == enemy_shield {
    "Shield"
  } else if kind == enemy_camo {
    "Stealth"
  } else if kind == enemy_splitter {
    "Splitter"
  } else {
    "Unknown"
  }
}

///|
pub fn targeting_mode_name(mode : Int) -> String {
  if mode == target_first {
    "First"
  } else if mode == target_last {
    "Last"
  } else if mode == target_strongest {
    "Strong"
  } else if mode == target_closest {
    "Close"
  } else {
    "First"
  }
}

// Enemy resistance to tower damage types
// Returns a multiplier: <1.0 = resistant, 1.0 = normal, >1.0 = weak

///|
pub fn enemy_resistance(enemy_kind : Int, tower_kind : Int) -> Float {
  // Flying enemies are weak to arrow, resistant to flame
  if enemy_kind == enemy_flying {
    if tower_kind == tower_arrow {
      return 1.5
    }
    if tower_kind == tower_flame {
      return 0.5
    }
    return 1.0
  }
  // Tank enemies are resistant to arrow, weak to cannon
  if enemy_kind == enemy_tank {
    if tower_kind == tower_arrow {
      return 0.6
    }
    if tower_kind == tower_cannon {
      return 1.5
    }
    return 1.0
  }
  // Shield enemies are resistant to splash, weak to sniper
  if enemy_kind == enemy_shield {
    if tower_kind == tower_splash {
      return 0.6
    }
    if tower_kind == tower_sniper {
      return 1.5
    }
    return 1.0
  }
  // Boss enemies are resistant to frost slow
  if enemy_kind == enemy_boss {
    if tower_kind == tower_frost {
      return 0.5
    }
    return 1.0
  }
  // Swarm enemies are weak to splash and flame
  if enemy_kind == enemy_swarm {
    if tower_kind == tower_splash {
      return 1.5
    }
    if tower_kind == tower_flame {
      return 1.5
    }
    return 1.0
  }
  // Armored (healer) enemies are weak to lightning
  if enemy_kind == enemy_healer {
    if tower_kind == tower_lightning {
      return 1.3
    }
    return 1.0
  }
  1.0
}

// Enemy armor value by type

///|
pub fn enemy_armor_value(kind : Int) -> Float {
  if kind == enemy_basic {
    armor_basic
  } else if kind == enemy_fast {
    armor_fast
  } else if kind == enemy_tank {
    armor_tank
  } else if kind == enemy_flying {
    armor_flying
  } else if kind == enemy_boss {
    armor_boss
  } else if kind == enemy_healer {
    armor_healer
  } else if kind == enemy_swarm {
    armor_swarm
  } else if kind == enemy_shield {
    armor_shield
  } else if kind == enemy_camo {
    armor_camo
  } else if kind == enemy_splitter {
    armor_splitter
  } else {
    0.0
  }
}

// Calculate actual damage after armor and resistance

///|
pub fn calc_damage(
  base_damage : Float,
  tower_kind : Int,
  enemy : Enemy,
) -> Float {
  let resistance = enemy_resistance(enemy.kind, tower_kind)
  let effective_armor : Float = enemy.armor * enemy.armor_break_factor
  let after_armor : Float = maxf(base_damage - effective_armor, 1.0)
  after_armor * resistance
}

// Path interpolation: get world position at a given path progress

///|
pub fn path_position_x(game : Game, path_idx : Int, progress : Float) -> Float {
  if path_idx >= game.path_count - 1 {
    if game.path_count > 0 {
      return game.path_nodes[game.path_count - 1].x
    }
    return 0.0
  }
  let p0 = game.path_nodes[path_idx]
  let p1 = game.path_nodes[path_idx + 1]
  lerpf(p0.x, p1.x, progress)
}

///|
pub fn path_position_z(game : Game, path_idx : Int, progress : Float) -> Float {
  if path_idx >= game.path_count - 1 {
    if game.path_count > 0 {
      return game.path_nodes[game.path_count - 1].z
    }
    return 0.0
  }
  let p0 = game.path_nodes[path_idx]
  let p1 = game.path_nodes[path_idx + 1]
  lerpf(p0.z, p1.z, progress)
}

// Get total path progress for an enemy (for targeting comparison)

///|
pub fn enemy_total_progress(enemy : Enemy) -> Float {
  Float::from_int(enemy.path_index) + enemy.path_progress
}

// Target selection: find best enemy in range based on targeting mode

///|
pub fn find_target(
  game : Game,
  wx : Float,
  wz : Float,
  range : Float,
  mode : Int,
  can_see_camo : Bool,
) -> Int {
  let mut best_idx = -1
  let mut best_score : Float = -999999.0
  for j in 0..<game.enemies.length() {
    let enemy = game.enemies[j]
    if not(enemy.active) {
      continue
    }
    // Skip camo enemies if tower cannot detect them
    if enemy.is_camo && not(can_see_camo) {
      continue
    }
    let dist = distance2d(wx, wz, enemy.x, enemy.z)
    if dist <= range {
      let score : Float = if mode == target_first {
        // Highest path progress = first (furthest along)
        enemy_total_progress(enemy)
      } else if mode == target_last {
        // Lowest path progress = last
        -enemy_total_progress(enemy)
      } else if mode == target_strongest {
        // Highest current HP
        enemy.hp
      } else {
        // Closest: negate distance so closer = higher score
        -dist
      }
      if score > best_score {
        best_score = score
        best_idx = j
      }
    }
  }
  best_idx
}

// Count active enemies

///|
pub fn count_active_enemies(game : Game) -> Int {
  let mut count = 0
  for enemy in game.enemies {
    if enemy.active {
      count += 1
    }
  }
  count
}

// Count active towers

///|
pub fn count_active_towers(game : Game) -> Int {
  let mut count = 0
  for tower in game.towers {
    if tower.active {
      count += 1
    }
  }
  count
}

// Check if any tower can detect camo (sniper towers and lightning towers can detect camo)

///|
pub fn tower_can_detect_camo(kind : Int) -> Bool {
  kind == tower_sniper || kind == tower_lightning
}

// Get projectile speed for tower type

///|
pub fn projectile_speed_for(kind : Int) -> Float {
  if kind == tower_arrow {
    proj_speed_bullet
  } else if kind == tower_cannon {
    proj_speed_cannonball
  } else if kind == tower_frost {
    proj_speed_ice_shard
  } else if kind == tower_lightning {
    proj_speed_lightning
  } else if kind == tower_flame {
    proj_speed_fireball
  } else if kind == tower_sniper {
    proj_speed_sniper
  } else if kind == tower_splash {
    proj_speed_splash
  } else {
    12.0
  }
}

// Get splash radius for tower type

///|
pub fn splash_radius_for(kind : Int) -> Float {
  if kind == tower_cannon {
    splash_radius_cannon
  } else if kind == tower_splash {
    splash_radius_splash
  } else if kind == tower_flame {
    splash_radius_flame
  } else {
    0.0
  }
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
    p.vx = rand_rangef(game, -2.0, 2.0)
    p.vy = rand_rangef(game, 1.0, 5.0)
    p.vz = rand_rangef(game, -2.0, 2.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.1)
    p.kind = particle_normal
    ignore(i)
  }
}

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
    p.vx = rand_rangef(game, -1.5, 1.5)
    p.vy = rand_rangef(game, 0.5, 3.0)
    p.vz = rand_rangef(game, -1.5, 1.5)
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

// Spawn gold collection particles

///|
pub fn spawn_gold_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles_typed(game, wx, wy, wz, 5, 255, 215, 0, particle_gold)
}

// Spawn explosion particles

///|
pub fn spawn_explosion_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  size : Int,
) -> Unit {
  spawn_particles_typed(
    game, wx, wy, wz, size, 255, 150, 50, particle_explosion,
  )
}

// Spawn ice particles

///|
pub fn spawn_ice_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles_typed(game, wx, wy, wz, 4, 150, 200, 255, particle_ice)
}

// Spawn fire particles

///|
pub fn spawn_fire_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles_typed(game, wx, wy, wz, 3, 255, 100, 30, particle_fire)
}

// Spawn lightning particles

///|
pub fn spawn_lightning_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles_typed(game, wx, wy, wz, 4, 200, 200, 50, particle_lightning)
}

// Spawn build effect particles

///|
pub fn spawn_build_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
) -> Unit {
  spawn_particles_typed(game, wx, wy, wz, 10, 100, 200, 255, particle_build)
}

///|
pub fn can_place_tower(game : Game, gx : Int, gy : Int) -> Bool {
  if not(in_bounds(gx, gy)) {
    return false
  }
  let tile = get_tile(game, gx, gy)
  if tile != tile_grass {
    return false
  }
  if tower_at(game, gx, gy) >= 0 {
    return false
  }
  true
}

// Set notification message

///|
pub fn set_notification(game : Game, text : String, duration : Float) -> Unit {
  game.notification_text = text
  game.notification_timer = duration
}

// Difficulty HP multiplier

///|
pub fn difficulty_hp_mult(difficulty : Int) -> Float {
  if difficulty == 0 {
    difficulty_easy_hp
  } else if difficulty == 2 {
    difficulty_hard_hp
  } else {
    difficulty_normal_hp
  }
}

// Difficulty speed multiplier

///|
pub fn difficulty_speed_mult(difficulty : Int) -> Float {
  if difficulty == 0 {
    difficulty_easy_speed
  } else if difficulty == 2 {
    difficulty_hard_speed
  } else {
    difficulty_normal_speed
  }
}

///|
pub fn difficulty_name(difficulty : Int) -> String {
  if difficulty == 0 {
    "Easy"
  } else if difficulty == 2 {
    "Hard"
  } else {
    "Normal"
  }
}

// Get upgrade info for tower at given level

///|
pub fn get_upgrade_info(kind : Int, level : Int) -> UpgradeInfo {
  let cost = tower_upgrade_cost(kind, level)
  let dmg_mult : Float = 1.0 + Float::from_int(level) * upgrade_damage_mult
  let rng_mult : Float = 1.0 + Float::from_int(level) * upgrade_range_mult
  let rate_mult : Float = 1.0 - Float::from_int(level) * upgrade_rate_mult
  let desc : String = if level == 1 {
    "Improved stats"
  } else if level == 2 {
    get_level3_special_desc(kind)
  } else {
    "Max level"
  }
  {
    cost,
    damage_mult: dmg_mult,
    range_mult: rng_mult,
    rate_mult,
    special_desc: desc,
  }
}

// Level 3 special ability descriptions

///|
fn get_level3_special_desc(kind : Int) -> String {
  if kind == tower_arrow {
    "Double shot"
  } else if kind == tower_cannon {
    "Bigger explosion"
  } else if kind == tower_frost {
    "Freeze chance"
  } else if kind == tower_lightning {
    "More chains"
  } else if kind == tower_flame {
    "Fire aura"
  } else if kind == tower_sniper {
    "Armor break"
  } else if kind == tower_splash {
    "Stun chance"
  } else if kind == tower_buff {
    "Buff pulse"
  } else {
    "Special"
  }
}

// Add chain line visual effect

///|
pub fn add_chain_line(
  game : Game,
  x1 : Float,
  y1 : Float,
  z1 : Float,
  x2 : Float,
  y2 : Float,
  z2 : Float,
) -> Unit {
  for cl in game.chain_lines {
    if not(cl.active) {
      cl.active = true
      cl.x1 = x1
      cl.y1 = y1
      cl.z1 = z1
      cl.x2 = x2
      cl.y2 = y2
      cl.z2 = z2
      cl.life = 0.3
      return
    }
  }
}

// Speed setting name

///|
pub fn speed_name(setting : Int) -> String {
  if setting == 0 {
    "1x"
  } else if setting == 1 {
    "2x"
  } else {
    "3x"
  }
}

// Speed multiplier from setting

///|
pub fn speed_from_setting(setting : Int) -> Float {
  if setting == 0 {
    speed_1x
  } else if setting == 1 {
    speed_2x
  } else {
    speed_3x
  }
}
