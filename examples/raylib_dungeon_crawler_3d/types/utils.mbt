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
pub fn get_tile(game : Game, gx : Int, gy : Int) -> Int {
  if in_bounds(gx, gy) {
    game.tiles[tile_index(gx, gy)]
  } else {
    tile_wall
  }
}

///|
pub fn set_tile(game : Game, gx : Int, gy : Int, tile : Int) -> Unit {
  if in_bounds(gx, gy) {
    game.tiles[tile_index(gx, gy)] = tile
  }
}

///|
pub fn is_walkable(tile : Int) -> Bool {
  tile == tile_floor ||
  tile == tile_door ||
  tile == tile_stairs ||
  tile == tile_chest ||
  tile == tile_trap ||
  tile == tile_shrine ||
  tile == tile_shop
}

///|
pub fn is_door_tile(tile : Int) -> Bool {
  tile == tile_door ||
  tile == tile_locked_door ||
  tile == tile_boss_door ||
  tile == tile_secret_door
}

// Convert world position to grid position

///|
pub fn world_to_grid_x(wx : Float) -> Int {
  (wx / cell_size).to_int()
}

///|
pub fn world_to_grid_z(wz : Float) -> Int {
  (wz / cell_size).to_int()
}

// Convert grid position to world center

///|
pub fn grid_to_world_x(gx : Int) -> Float {
  Float::from_int(gx) * cell_size + cell_size / 2.0
}

///|
pub fn grid_to_world_z(gy : Int) -> Float {
  Float::from_int(gy) * cell_size + cell_size / 2.0
}

// Check if a world position is blocked by walls

///|
pub fn is_blocked(game : Game, wx : Float, wz : Float, radius : Float) -> Bool {
  // Check four corners of bounding box
  let gx0 = world_to_grid_x(wx - radius)
  let gz0 = world_to_grid_z(wz - radius)
  let gx1 = world_to_grid_x(wx + radius)
  let gz1 = world_to_grid_z(wz + radius)
  if not(is_walkable(get_tile(game, gx0, gz0))) {
    return true
  }
  if not(is_walkable(get_tile(game, gx1, gz0))) {
    return true
  }
  if not(is_walkable(get_tile(game, gx0, gz1))) {
    return true
  }
  if not(is_walkable(get_tile(game, gx1, gz1))) {
    return true
  }
  false
}

// Check if blocked including locked doors

///|
pub fn is_blocked_strict(
  game : Game,
  wx : Float,
  wz : Float,
  radius : Float,
) -> Bool {
  let gx0 = world_to_grid_x(wx - radius)
  let gz0 = world_to_grid_z(wz - radius)
  let gx1 = world_to_grid_x(wx + radius)
  let gz1 = world_to_grid_z(wz + radius)
  let t0 = get_tile(game, gx0, gz0)
  let t1 = get_tile(game, gx1, gz0)
  let t2 = get_tile(game, gx0, gz1)
  let t3 = get_tile(game, gx1, gz1)
  if not(is_walkable(t0)) && not(is_door_tile(t0)) {
    return true
  }
  if not(is_walkable(t1)) && not(is_door_tile(t1)) {
    return true
  }
  if not(is_walkable(t2)) && not(is_door_tile(t2)) {
    return true
  }
  if not(is_walkable(t3)) && not(is_door_tile(t3)) {
    return true
  }
  // Check locked doors
  if t0 == tile_locked_door || t0 == tile_boss_door {
    return true
  }
  if t1 == tile_locked_door || t1 == tile_boss_door {
    return true
  }
  if t2 == tile_locked_door || t2 == tile_boss_door {
    return true
  }
  if t3 == tile_locked_door || t3 == tile_boss_door {
    return true
  }
  false
}

// Distance between two points in 2D (xz plane)

///|
pub fn dist2d(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x2 - x1
  let dz = z2 - z1
  (dx * dx + dz * dz).sqrt()
}

// Squared distance (avoids sqrt for comparisons)

///|
pub fn dist2d_sq(x1 : Float, z1 : Float, x2 : Float, z2 : Float) -> Float {
  let dx = x2 - x1
  let dz = z2 - z1
  dx * dx + dz * dz
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

// Weighted random selection: returns index based on weights

///|
pub fn rand_weighted(game : Game, weights : Array[Int]) -> Int {
  let mut total = 0
  for i in 0..<weights.length() {
    total += weights[i]
  }
  if total <= 0 {
    return 0
  }
  let mut roll = rand_range(game, 0, total - 1)
  for i in 0..<weights.length() {
    roll -= weights[i]
    if roll < 0 {
      return i
    }
  }
  weights.length() - 1
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
pub fn alloc_loot(game : Game) -> Int {
  for i in 0..<game.loot.length() {
    if not(game.loot[i].active) {
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

///|
pub fn alloc_torch(game : Game) -> Int {
  for i in 0..<game.torches.length() {
    if not(game.torches[i].active) {
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
    p.y = wy + rand_rangef(game, 0.0, 0.4)
    p.z = wz + rand_rangef(game, -0.3, 0.3)
    p.vx = rand_rangef(game, -2.0, 2.0)
    p.vy = rand_rangef(game, 1.0, 5.0)
    p.vz = rand_rangef(game, -2.0, 2.0)
    p.life = rand_rangef(game, 0.3, 0.8)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.03, 0.1)
    ignore(i)
  }
}

// Spawn directional particles (for spell effects)

///|
pub fn spawn_directional_particles(
  game : Game,
  wx : Float,
  wy : Float,
  wz : Float,
  dir_x : Float,
  dir_z : Float,
  count : Int,
  r : Int,
  g : Int,
  b : Int,
  speed : Float,
) -> Unit {
  for i in 0..<count {
    let idx = alloc_particle(game)
    if idx < 0 {
      return
    }
    let p = game.particles[idx]
    p.active = true
    p.x = wx + rand_rangef(game, -0.2, 0.2)
    p.y = wy + rand_rangef(game, -0.1, 0.3)
    p.z = wz + rand_rangef(game, -0.2, 0.2)
    p.vx = dir_x * speed + rand_rangef(game, -1.0, 1.0)
    p.vy = rand_rangef(game, 0.5, 2.0)
    p.vz = dir_z * speed + rand_rangef(game, -1.0, 1.0)
    p.life = rand_rangef(game, 0.2, 0.5)
    p.max_life = p.life
    p.r = r
    p.g = g
    p.b = b
    p.size = rand_rangef(game, 0.04, 0.12)
    ignore(i)
  }
}

// Mark explored tiles around player position

///|
pub fn update_explored(game : Game) -> Unit {
  let gx = world_to_grid_x(game.player_x)
  let gz = world_to_grid_z(game.player_z)
  let radius = 4
  for dy in -radius..=radius {
    for dx in -radius..=radius {
      let nx = gx + dx
      let nz = gz + dy
      if in_bounds(nx, nz) {
        game.explored[tile_index(nx, nz)] = true
      }
    }
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

// Normalize angle to -pi..pi range

///|
pub fn normalize_angle(angle : Float) -> Float {
  let mut a = angle
  while a > pi {
    a = a - 2.0 * pi
  }
  while a < -pi {
    a = a + 2.0 * pi
  }
  a
}

// Add message to log

///|
pub fn add_message(
  game : Game,
  text : String,
  r : Int,
  g : Int,
  b : Int,
) -> Unit {
  // Shift messages down
  for i = game.messages.length() - 1; i > 0; i = i - 1 {
    game.messages[i].text = game.messages[i - 1].text
    game.messages[i].timer = game.messages[i - 1].timer
    game.messages[i].r = game.messages[i - 1].r
    game.messages[i].g = game.messages[i - 1].g
    game.messages[i].b = game.messages[i - 1].b
  }
  // Add new at top
  if game.messages.length() > 0 {
    game.messages[0].text = text
    game.messages[0].timer = 4.0
    game.messages[0].r = r
    game.messages[0].g = g
    game.messages[0].b = b
  }
}

// Inventory helpers

///|
pub fn alloc_inventory(game : Game) -> Int {
  for i in 0..<game.inventory.length() {
    if not(game.inventory[i].active) {
      return i
    }
  }
  -1
}

///|
pub fn count_inventory_items(game : Game) -> Int {
  let mut count = 0
  for i in 0..<game.inventory.length() {
    if game.inventory[i].active {
      count += 1
    }
  }
  count
}

// Get weapon stats

///|
pub fn get_weapon_range(weapon_type : Int) -> Float {
  if weapon_type == weapon_sword {
    sword_range
  } else if weapon_type == weapon_axe {
    axe_range
  } else if weapon_type == weapon_mace {
    mace_range
  } else if weapon_type == weapon_dagger {
    dagger_range
  } else if weapon_type == weapon_staff {
    staff_range
  } else if weapon_type == weapon_bow {
    bow_range
  } else {
    sword_range
  }
}

///|
pub fn get_weapon_cooldown(weapon_type : Int) -> Float {
  if weapon_type == weapon_sword {
    sword_cooldown
  } else if weapon_type == weapon_axe {
    axe_cooldown
  } else if weapon_type == weapon_mace {
    mace_cooldown
  } else if weapon_type == weapon_dagger {
    dagger_cooldown
  } else if weapon_type == weapon_staff {
    staff_cooldown
  } else if weapon_type == weapon_bow {
    bow_cooldown
  } else {
    sword_cooldown
  }
}

///|
pub fn get_weapon_damage_mult(weapon_type : Int) -> Float {
  if weapon_type == weapon_sword {
    sword_damage_mult
  } else if weapon_type == weapon_axe {
    axe_damage_mult
  } else if weapon_type == weapon_mace {
    mace_damage_mult
  } else if weapon_type == weapon_dagger {
    dagger_damage_mult
  } else if weapon_type == weapon_staff {
    staff_damage_mult
  } else if weapon_type == weapon_bow {
    bow_damage_mult
  } else {
    sword_damage_mult
  }
}

///|
pub fn get_weapon_name(weapon_type : Int) -> String {
  if weapon_type == weapon_sword {
    "Sword"
  } else if weapon_type == weapon_axe {
    "Axe"
  } else if weapon_type == weapon_mace {
    "Mace"
  } else if weapon_type == weapon_dagger {
    "Dagger"
  } else if weapon_type == weapon_staff {
    "Staff"
  } else if weapon_type == weapon_bow {
    "Bow"
  } else {
    "Unknown"
  }
}

///|
pub fn get_armor_defense(armor_type : Int) -> Int {
  if armor_type == armor_robes {
    robes_defense
  } else if armor_type == armor_leather {
    leather_defense
  } else if armor_type == armor_chain {
    chain_defense
  } else if armor_type == armor_plate {
    plate_defense
  } else {
    0
  }
}

///|
pub fn get_armor_name(armor_type : Int) -> String {
  if armor_type == armor_none {
    "None"
  } else if armor_type == armor_robes {
    "Robes"
  } else if armor_type == armor_leather {
    "Leather"
  } else if armor_type == armor_chain {
    "Chain"
  } else if armor_type == armor_plate {
    "Plate"
  } else {
    "Unknown"
  }
}

///|
pub fn get_spell_name(spell_type : Int) -> String {
  if spell_type == spell_fireball {
    "Fireball"
  } else if spell_type == spell_ice_bolt {
    "Ice Bolt"
  } else if spell_type == spell_heal {
    "Heal"
  } else if spell_type == spell_shield {
    "Shield"
  } else if spell_type == spell_lightning {
    "Lightning"
  } else if spell_type == spell_teleport {
    "Teleport"
  } else {
    "None"
  }
}

///|
pub fn get_spell_mana_cost(spell_type : Int) -> Int {
  if spell_type == spell_fireball {
    fireball_mana_cost
  } else if spell_type == spell_ice_bolt {
    ice_bolt_mana_cost
  } else if spell_type == spell_heal {
    heal_mana_cost
  } else if spell_type == spell_shield {
    shield_mana_cost
  } else if spell_type == spell_lightning {
    lightning_mana_cost
  } else if spell_type == spell_teleport {
    teleport_mana_cost
  } else {
    0
  }
}

// Calculate total player defense (base + armor + buffs)

///|
pub fn calc_player_defense(game : Game) -> Int {
  let mut total = game.player_def + get_armor_defense(game.player_armor)
  for i in 0..<game.buffs.length() {
    if game.buffs[i].active && game.buffs[i].kind == buff_shield {
      total += game.buffs[i].value
    }
  }
  total
}

// Calculate total player attack (base + str + weapon + buffs)

///|
pub fn calc_player_attack(game : Game) -> Int {
  let base = game.player_atk + game.player_str / 3
  let mult = get_weapon_damage_mult(game.player_weapon)
  let base_f = Float::from_int(base) * mult
  let mut total = base_f.to_int()
  for i in 0..<game.buffs.length() {
    if game.buffs[i].active && game.buffs[i].kind == buff_strength {
      total += game.buffs[i].value
    }
  }
  total
}

// Get enemy type name

///|
pub fn get_enemy_name(kind : Int) -> String {
  if kind == enemy_skeleton {
    "Skeleton"
  } else if kind == enemy_archer {
    "Archer"
  } else if kind == enemy_golem {
    "Golem"
  } else if kind == enemy_wraith {
    "Wraith"
  } else if kind == enemy_dragon_boss {
    "Dragon"
  } else if kind == enemy_slime {
    "Slime"
  } else if kind == enemy_bat {
    "Bat"
  } else if kind == enemy_spider {
    "Spider"
  } else if kind == enemy_minotaur {
    "Minotaur"
  } else if kind == enemy_lich {
    "Lich"
  } else if kind == enemy_mimic {
    "Mimic"
  } else {
    "Unknown"
  }
}

// Get XP value for enemy type

///|
pub fn get_enemy_xp(kind : Int) -> Int {
  if kind == enemy_skeleton {
    xp_per_skeleton
  } else if kind == enemy_archer {
    xp_per_archer
  } else if kind == enemy_golem {
    xp_per_golem
  } else if kind == enemy_wraith {
    xp_per_wraith
  } else if kind == enemy_dragon_boss {
    xp_per_dragon
  } else if kind == enemy_slime {
    xp_per_slime
  } else if kind == enemy_bat {
    xp_per_bat
  } else if kind == enemy_spider {
    xp_per_spider
  } else if kind == enemy_minotaur {
    xp_per_minotaur
  } else if kind == enemy_lich {
    xp_per_lich
  } else if kind == enemy_mimic {
    xp_per_mimic
  } else {
    10
  }
}

// Get rarity name

///|
pub fn get_rarity_name(rarity : Int) -> String {
  if rarity == rarity_common {
    "Common"
  } else if rarity == rarity_uncommon {
    "Uncommon"
  } else if rarity == rarity_rare {
    "Rare"
  } else if rarity == rarity_epic {
    "Epic"
  } else if rarity == rarity_legendary {
    "Legendary"
  } else {
    "Unknown"
  }
}

// Get class name

///|
pub fn get_class_name(class_type : Int) -> String {
  if class_type == class_warrior {
    "Warrior"
  } else if class_type == class_rogue {
    "Rogue"
  } else if class_type == class_mage {
    "Mage"
  } else {
    "Unknown"
  }
}

// Check line of sight between two grid cells

///|
pub fn has_line_of_sight(
  game : Game,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> Bool {
  let dx = absi(x2 - x1)
  let dy = absi(y2 - y1)
  let sx = if x1 < x2 { 1 } else { -1 }
  let sy = if y1 < y2 { 1 } else { -1 }
  let mut err = dx - dy
  let mut cx = x1
  let mut cy = y1
  for _step in 0..<100 {
    if cx == x2 && cy == y2 {
      return true
    }
    let tile = get_tile(game, cx, cy)
    if tile == tile_wall && not(cx == x1 && cy == y1) {
      return false
    }
    let e2 = 2 * err
    if e2 > -dy {
      err -= dy
      cx += sx
    }
    if e2 < dx {
      err += dx
      cy += sy
    }
  }
  false
}

// Simple pathfinding step: returns direction to move toward target
// Returns (dx, dz) normalized direction

///|
pub fn pathfind_step(
  game : Game,
  from_x : Float,
  from_z : Float,
  to_x : Float,
  to_z : Float,
) -> (Float, Float) {
  let dx = to_x - from_x
  let dz = to_z - from_z
  let d = (dx * dx + dz * dz).sqrt()
  if d < 0.1 {
    return (0.0, 0.0)
  }
  let nx = dx / d
  let nz = dz / d
  // Try direct path first
  let radius : Float = 0.4
  let step : Float = 0.5
  let test_x = from_x + nx * step
  let test_z = from_z + nz * step
  if not(is_blocked(game, test_x, test_z, radius)) {
    return (nx, nz)
  }
  // Try sliding along X
  if not(is_blocked(game, test_x, from_z, radius)) {
    let x_dir = signf(nx)
    return (x_dir, 0.0)
  }
  // Try sliding along Z
  if not(is_blocked(game, from_x, test_z, radius)) {
    let z_dir = signf(nz)
    return (0.0, z_dir)
  }
  (0.0, 0.0)
}

// Find a random walkable position in a room

///|
pub fn find_walkable_in_room(game : Game, room : Room) -> (Int, Int) {
  for _attempt in 0..<20 {
    let gx = rand_range(game, room.x + 1, room.x + room.w - 2)
    let gy = rand_range(game, room.y + 1, room.y + room.h - 2)
    if is_walkable(get_tile(game, gx, gy)) {
      return (gx, gy)
    }
  }
  (room.center_x(), room.center_y())
}

// Check if player has an active buff of given kind

///|
pub fn has_buff(game : Game, kind : Int) -> Bool {
  for i in 0..<game.buffs.length() {
    if game.buffs[i].active && game.buffs[i].kind == kind {
      return true
    }
  }
  false
}

// Add a buff to player

///|
pub fn add_buff(game : Game, kind : Int, duration : Float, value : Int) -> Unit {
  // Check if already have this buff, refresh it
  for i in 0..<game.buffs.length() {
    if game.buffs[i].active && game.buffs[i].kind == kind {
      game.buffs[i].timer = duration
      game.buffs[i].value = value
      return
    }
  }
  // Find empty slot
  for i in 0..<game.buffs.length() {
    if not(game.buffs[i].active) {
      game.buffs[i].active = true
      game.buffs[i].kind = kind
      game.buffs[i].timer = duration
      game.buffs[i].value = value
      return
    }
  }
}

// Update buff timers

///|
pub fn update_buffs(game : Game, dt : Float) -> Unit {
  for i in 0..<game.buffs.length() {
    if game.buffs[i].active {
      game.buffs[i].timer -= dt
      if game.buffs[i].timer <= 0.0 {
        game.buffs[i].active = false
      }
    }
  }
}

// Update message timers

///|
pub fn update_messages(game : Game, dt : Float) -> Unit {
  for i in 0..<game.messages.length() {
    if game.messages[i].timer > 0.0 {
      game.messages[i].timer -= dt
      if game.messages[i].timer < 0.0 {
        game.messages[i].timer = 0.0
      }
    }
  }
}

// Get trap name

///|
pub fn get_trap_name(kind : Int) -> String {
  if kind == trap_spike {
    "Spike Trap"
  } else if kind == trap_arrow {
    "Arrow Trap"
  } else if kind == trap_flame {
    "Flame Trap"
  } else if kind == trap_poison {
    "Poison Gas"
  } else if kind == trap_pitfall {
    "Pitfall"
  } else if kind == trap_teleporter {
    "Teleporter"
  } else {
    "Unknown Trap"
  }
}

// Get loot name

///|
pub fn get_loot_name(kind : Int) -> String {
  if kind == loot_health_potion {
    "Health Potion"
  } else if kind == loot_mana_potion {
    "Mana Potion"
  } else if kind == loot_damage_boost {
    "Damage Scroll"
  } else if kind == loot_armor {
    "Armor Shard"
  } else if kind == loot_speed_potion {
    "Speed Potion"
  } else if kind == loot_strength_potion {
    "Strength Potion"
  } else if kind == loot_gold_pile {
    "Gold"
  } else if kind == loot_key {
    "Key"
  } else if kind == loot_boss_key {
    "Boss Key"
  } else {
    "Unknown"
  }
}

// Get theme name

///|
pub fn get_theme_name(theme : Int) -> String {
  if theme == theme_crypt {
    "Crypt"
  } else if theme == theme_sewer {
    "Sewer"
  } else if theme == theme_cavern {
    "Cavern"
  } else if theme == theme_library {
    "Library"
  } else if theme == theme_prison {
    "Prison"
  } else if theme == theme_throne_room {
    "Throne Room"
  } else if theme == theme_mine {
    "Mine"
  } else if theme == theme_temple {
    "Temple"
  } else if theme == theme_abyss {
    "Abyss"
  } else if theme == theme_final_chamber {
    "Final Chamber"
  } else {
    "Unknown"
  }
}
