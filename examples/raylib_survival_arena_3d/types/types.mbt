// Player entity
///|
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut z : Float
  mut yaw : Float
  mut pitch : Float
  mut hp : Float
  mut armor : Float
  mut current_weapon : Int
  ammo : Array[Int]
  magazine : Array[Int]
  mag_size : Array[Int]
  mut speed_mult : Float
  mut damage_mult : Float
  mut damage_timer : Float
  mut score : Int
  mut money : Int
  mut kills : Int
  mut headshots : Int
  mut bob_timer : Float
  mut flash_timer : Float
  mut sprint : Bool
  mut crouching : Bool
  mut crouch_lerp : Float
  // Combo system
  mut combo_count : Int
  mut combo_timer : Float
  mut combo_mult : Float
  // Boost timers
  mut speed_boost_timer : Float
  mut damage_boost_timer : Float
  mut shield_timer : Float
  // Kill tracking for multi-kill
  mut recent_kill_timer : Float
  mut recent_kill_count : Int
  // Weapons owned
  owns_weapon : Array[Bool]
  // Minigun state
  mut minigun_spin : Float
  mut minigun_spinning : Bool
  // Recoil
  mut recoil_offset : Float
  mut recoil_recover : Float
  // Weapon upgrade levels: [damage_lvl, fire_rate_lvl, mag_lvl] per weapon
  weapon_damage_level : Array[Int]
  weapon_rate_level : Array[Int]
  weapon_mag_level : Array[Int]
}

///|
pub fn Player::new() -> Player {
  let ammo : Array[Int] = [
    ammo_pistol, ammo_shotgun, ammo_rifle, ammo_sniper, ammo_rocket, ammo_minigun,
  ]
  let magazine : Array[Int] = [
    mag_pistol, mag_shotgun, mag_rifle, mag_sniper, mag_rocket, mag_minigun,
  ]
  let mag_size : Array[Int] = [
    mag_pistol, mag_shotgun, mag_rifle, mag_sniper, mag_rocket, mag_minigun,
  ]
  let owns_weapon : Array[Bool] = [true, true, true, false, false, false]
  {
    x: 0.0,
    y: player_height,
    z: 0.0,
    yaw: 0.0,
    pitch: 0.0,
    hp: player_max_hp,
    armor: 0.0,
    current_weapon: weapon_pistol,
    ammo,
    magazine,
    mag_size,
    speed_mult: 1.0,
    damage_mult: 1.0,
    damage_timer: 0.0,
    score: 0,
    money: 0,
    kills: 0,
    headshots: 0,
    bob_timer: 0.0,
    flash_timer: 0.0,
    sprint: false,
    crouching: false,
    crouch_lerp: 0.0,
    combo_count: 0,
    combo_timer: 0.0,
    combo_mult: combo_base_mult,
    speed_boost_timer: 0.0,
    damage_boost_timer: 0.0,
    shield_timer: 0.0,
    recent_kill_timer: 0.0,
    recent_kill_count: 0,
    owns_weapon,
    minigun_spin: 0.0,
    minigun_spinning: false,
    recoil_offset: 0.0,
    recoil_recover: 0.0,
    weapon_damage_level: Array::make(weapon_count, 0),
    weapon_rate_level: Array::make(weapon_count, 0),
    weapon_mag_level: Array::make(weapon_count, 0),
  }
}

// Enemy entity

///|
pub(all) struct Enemy {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut hp : Float
  mut max_hp : Float
  mut speed : Float
  mut damage : Float
  mut attack_timer : Float
  mut attack_range : Float
  mut size : Float
  mut gold_value : Int
  mut score_value : Int
  mut spit_timer : Float
  mut spit_cooldown : Float
  mut stun_timer : Float
  mut flash_timer : Float
  // Exploder state
  mut explode_triggered : Bool
  mut explode_timer : Float
  // Necromancer state
  mut revive_timer : Float
  // Shielded state - angle facing
  mut facing_angle : Float
  // Boss phase
  mut boss_phase : Int
  mut boss_ability_timer : Float
  // State machine: 0=spawn, 1=chase, 2=attack, 3=stagger, 4=die_anim
  mut state : Int
  mut state_timer : Float
  // Death position for necromancer revive
  mut death_x : Float
  mut death_z : Float
  mut can_revive : Bool
  // Drops
  mut drops_pickup : Bool
}

///|
pub fn Enemy::inactive() -> Enemy {
  {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    hp: 0.0,
    max_hp: 1.0,
    speed: 2.0,
    damage: 5.0,
    attack_timer: 0.0,
    attack_range: 2.0,
    size: 0.6,
    gold_value: 10,
    score_value: 10,
    spit_timer: 0.0,
    spit_cooldown: 3.0,
    stun_timer: 0.0,
    flash_timer: 0.0,
    explode_triggered: false,
    explode_timer: 0.0,
    revive_timer: 0.0,
    facing_angle: 0.0,
    boss_phase: 0,
    boss_ability_timer: 0.0,
    state: 0,
    state_timer: 0.0,
    death_x: 0.0,
    death_z: 0.0,
    can_revive: false,
    drops_pickup: false,
  }
}

// Projectile (player bullets and enemy spits)

///|
pub(all) struct Projectile {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut dx : Float
  mut dy : Float
  mut dz : Float
  mut speed : Float
  mut damage : Float
  mut life : Float
  mut is_enemy : Bool
  mut splash_radius : Float
  mut penetration : Int
  mut is_headshot_capable : Bool
}

///|
pub fn Projectile::inactive() -> Projectile {
  {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    dx: 0.0,
    dy: 0.0,
    dz: 0.0,
    speed: 30.0,
    damage: 10.0,
    life: 3.0,
    is_enemy: false,
    splash_radius: 0.0,
    penetration: 0,
    is_headshot_capable: false,
  }
}

// Particle

///|
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut life : Float
  mut max_life : Float
  mut r : Int
  mut g : Int
  mut b : Int
  mut size : Float
  mut kind : Int
}

///|
pub fn Particle::inactive() -> Particle {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    life: 0.0,
    max_life: 1.0,
    r: 255,
    g: 255,
    b: 255,
    size: 0.05,
    kind: 0,
  }
}

// Arena pillar (static obstacle)

///|
pub(all) struct Pillar {
  x : Float
  z : Float
  radius : Float
  height : Float
}

// Arena crate (ammo pickup)

///|
pub(all) struct Crate {
  mut active : Bool
  mut x : Float
  mut z : Float
  mut respawn_timer : Float
  mut kind : Int
}

///|
pub fn Crate::new(x : Float, z : Float, kind : Int) -> Crate {
  { active: true, x, z, respawn_timer: 0.0, kind }
}

// Low wall (half-cover)

///|
pub(all) struct LowWall {
  x : Float
  z : Float
  width : Float
  height : Float
  depth : Float
  angle : Float
}

// Ramp structure

///|
pub(all) struct Ramp {
  x : Float
  z : Float
  width : Float
  length : Float
  height : Float
  angle : Float
}

// Pickup (dropped by enemies or spawned)

///|
pub(all) struct Pickup {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut float_timer : Float
  mut life : Float
}

///|
pub fn Pickup::inactive() -> Pickup {
  {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    float_timer: 0.0,
    life: 0.0,
  }
}

// Arena trap

///|
pub(all) struct ArenaTrap {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut z : Float
  mut cooldown_timer : Float
  mut active_timer : Float
  mut damage : Float
}

///|
pub fn ArenaTrap::inactive() -> ArenaTrap {
  {
    active: false,
    kind: 0,
    x: 0.0,
    z: 0.0,
    cooldown_timer: 0.0,
    active_timer: 0.0,
    damage: 0.0,
  }
}

// Barricade

///|
pub(all) struct Barricade {
  mut active : Bool
  mut x : Float
  mut z : Float
  mut hp : Float
  mut max_hp : Float
}

///|
pub fn Barricade::inactive() -> Barricade {
  { active: false, x: 0.0, z: 0.0, hp: 0.0, max_hp: barricade_max_hp }
}

// Kill feed entry

///|
pub(all) struct KillFeedEntry {
  mut active : Bool
  mut text : String
  mut timer : Float
  mut color_r : Int
  mut color_g : Int
  mut color_b : Int
}

///|
pub fn KillFeedEntry::inactive() -> KillFeedEntry {
  {
    active: false,
    text: "",
    timer: 0.0,
    color_r: 255,
    color_g: 255,
    color_b: 255,
  }
}

// Weapon state

///|
pub(all) struct WeaponState {
  mut reload_timer : Float
  mut reloading : Bool
  mut reload_time : Float
}

///|
pub fn WeaponState::new() -> WeaponState {
  { reload_timer: 0.0, reloading: false, reload_time: 0.0 }
}

// Shop item

///|
pub(all) struct ShopItem {
  name : String
  cost : Int
  kind : Int
}

// Damage indicator direction

///|
pub(all) struct DamageIndicator {
  mut active : Bool
  mut angle : Float
  mut timer : Float
}

///|
pub fn DamageIndicator::inactive() -> DamageIndicator {
  { active: false, angle: 0.0, timer: 0.0 }
}

// Main Game struct

///|
pub(all) struct Game {
  mut state : Int

  // Player
  player : Player
  weapons : Array[WeaponState]

  // Wave system
  mut current_wave : Int
  mut wave_timer : Float
  mut spawn_timer : Float
  mut enemies_to_spawn : Int
  mut enemies_spawned : Int
  mut wave_enemy_kinds : Array[Int]
  mut wave_enemy_counts : Array[Int]
  mut wave_spawn_idx : Int
  mut wave_hp_mult : Float
  mut wave_speed_mult : Float
  mut wave_active : Bool

  // Arena
  pillars : Array[Pillar]
  crates : Array[Crate]
  low_walls : Array[LowWall]
  ramps : Array[Ramp]

  // Entity pools
  enemies : Array[Enemy]
  projectiles : Array[Projectile]
  particles : Array[Particle]
  pickups : Array[Pickup]
  traps : Array[ArenaTrap]
  barricades : Array[Barricade]

  // Kill feed
  kill_feed : Array[KillFeedEntry]

  // Damage indicators
  damage_indicators : Array[DamageIndicator]

  // Camera
  mut cam_pos_x : Float
  mut cam_pos_y : Float
  mut cam_pos_z : Float
  mut cam_target_x : Float
  mut cam_target_y : Float
  mut cam_target_z : Float

  // UI
  mut menu_cursor : Int
  mut menu_blink : Float
  mut shop_cursor : Int
  mut message_timer : Float
  mut message_text : String
  mut show_wave_summary : Bool
  mut wave_summary_timer : Float
  mut wave_summary_kills : Int
  mut wave_summary_money : Int

  // RNG
  mut rng_state : Int
  mut frame_counter : Int

  // Crosshair hit marker
  mut hit_marker_timer : Float

  // Difficulty scaling
  mut difficulty : Float

  // Stats tracking
  mut total_shots_fired : Int
  mut total_shots_hit : Int
  mut highest_combo : Int
  mut total_damage_dealt : Float
  mut total_damage_taken : Float
}

///|
pub fn Game::new() -> Game {
  // Create weapons array
  let weapons : Array[WeaponState] = []
  for _i = 0; _i < weapon_count; _i = _i + 1 {
    weapons.push(WeaponState::new())
  }
  // Create pillars in a circle pattern
  let pillars : Array[Pillar] = []
  for i = 0; i < pillar_count; i = i + 1 {
    let angle = Float::from_int(i) * 2.0 * pi / Float::from_int(pillar_count)
    let dist : Float = 18.0
    let px = @math.cosf(angle) * dist
    let pz = @math.sinf(angle) * dist
    pillars.push({ x: px, z: pz, radius: pillar_radius, height: pillar_height })
  }
  // Create ammo crates at various positions
  let crates : Array[Crate] = []
  crates.push(Crate::new(12.0, 12.0, weapon_shotgun))
  crates.push(Crate::new(-12.0, 12.0, weapon_rifle))
  crates.push(Crate::new(12.0, -12.0, weapon_rocket))
  crates.push(Crate::new(-12.0, -12.0, weapon_shotgun))
  crates.push(Crate::new(0.0, 15.0, weapon_rifle))
  crates.push(Crate::new(0.0, -15.0, weapon_minigun))
  // Create low walls for cover
  let low_walls : Array[LowWall] = []
  low_walls.push({
    x: 8.0,
    z: 0.0,
    width: low_wall_width,
    height: low_wall_height,
    depth: low_wall_depth,
    angle: 0.0,
  })
  low_walls.push({
    x: -8.0,
    z: 0.0,
    width: low_wall_width,
    height: low_wall_height,
    depth: low_wall_depth,
    angle: 0.0,
  })
  low_walls.push({
    x: 0.0,
    z: 8.0,
    width: low_wall_width,
    height: low_wall_height,
    depth: low_wall_depth,
    angle: 1.5708,
  })
  low_walls.push({
    x: 0.0,
    z: -8.0,
    width: low_wall_width,
    height: low_wall_height,
    depth: low_wall_depth,
    angle: 1.5708,
  })
  low_walls.push({
    x: 15.0,
    z: 15.0,
    width: 3.0,
    height: low_wall_height,
    depth: low_wall_depth,
    angle: 0.785,
  })
  low_walls.push({
    x: -15.0,
    z: -15.0,
    width: 3.0,
    height: low_wall_height,
    depth: low_wall_depth,
    angle: 0.785,
  })
  // Create ramps
  let ramps : Array[Ramp] = []
  ramps.push({
    x: 20.0,
    z: 0.0,
    width: ramp_width,
    length: ramp_length,
    height: ramp_height,
    angle: 0.0,
  })
  ramps.push({
    x: -20.0,
    z: 0.0,
    width: ramp_width,
    length: ramp_length,
    height: ramp_height,
    angle: 3.14159,
  })
  ramps.push({
    x: 0.0,
    z: 20.0,
    width: ramp_width,
    length: ramp_length,
    height: ramp_height,
    angle: 1.5708,
  })
  ramps.push({
    x: 0.0,
    z: -20.0,
    width: ramp_width,
    length: ramp_length,
    height: ramp_height,
    angle: 4.7124,
  })
  // Kill feed
  let kill_feed : Array[KillFeedEntry] = Array::make(
    max_kill_feed,
    KillFeedEntry::inactive(),
  )
  // Damage indicators
  let damage_indicators : Array[DamageIndicator] = Array::make(
    4,
    DamageIndicator::inactive(),
  )
  {
    state: state_menu,
    player: Player::new(),
    weapons,
    current_wave: 0,
    wave_timer: 0.0,
    spawn_timer: 0.0,
    enemies_to_spawn: 0,
    enemies_spawned: 0,
    wave_enemy_kinds: [],
    wave_enemy_counts: [],
    wave_spawn_idx: 0,
    wave_hp_mult: 1.0,
    wave_speed_mult: 1.0,
    wave_active: false,
    pillars,
    crates,
    low_walls,
    ramps,
    enemies: Array::make(max_enemies, Enemy::inactive()),
    projectiles: Array::make(max_projectiles, Projectile::inactive()),
    particles: Array::make(max_particles, Particle::inactive()),
    pickups: Array::make(max_pickups, Pickup::inactive()),
    traps: Array::make(max_traps, ArenaTrap::inactive()),
    barricades: Array::make(max_barricades, Barricade::inactive()),
    kill_feed,
    damage_indicators,
    cam_pos_x: 0.0,
    cam_pos_y: player_height,
    cam_pos_z: 0.0,
    cam_target_x: 0.0,
    cam_target_y: player_height,
    cam_target_z: -1.0,
    menu_cursor: 0,
    menu_blink: 0.0,
    shop_cursor: 0,
    message_timer: 0.0,
    message_text: "",
    show_wave_summary: false,
    wave_summary_timer: 0.0,
    wave_summary_kills: 0,
    wave_summary_money: 0,
    rng_state: 54321,
    frame_counter: 0,
    hit_marker_timer: 0.0,
    difficulty: 1.0,
    total_shots_fired: 0,
    total_shots_hit: 0,
    highest_combo: 0,
    total_damage_dealt: 0.0,
    total_damage_taken: 0.0,
  }
}
