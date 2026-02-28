// Status effect on an enemy

///|
pub(all) struct StatusEffect {
  mut kind : Int
  mut duration : Float
  mut strength : Float
  mut tick_timer : Float
}

///|
pub fn StatusEffect::none() -> StatusEffect {
  { kind: effect_none, duration: 0.0, strength: 0.0, tick_timer: 0.0 }
}

///|
pub fn StatusEffect::new(
  kind : Int,
  duration : Float,
  strength : Float,
) -> StatusEffect {
  { kind, duration, strength, tick_timer: 0.0 }
}

// Tower entity

///|
pub(all) struct Tower {
  mut active : Bool
  mut kind : Int
  mut gx : Int
  mut gy : Int
  mut level : Int
  mut reload_timer : Float
  mut target_idx : Int
  mut angle : Float
  mut targeting_mode : Int
  mut kills : Int
  mut total_damage : Float
  mut special_timer : Float
  mut special_active : Bool
  mut buff_damage : Float
  mut buff_range : Float
  mut buff_rate : Float
  mut sell_value : Int
}

///|
pub fn Tower::inactive() -> Tower {
  {
    active: false,
    kind: 0,
    gx: 0,
    gy: 0,
    level: 1,
    reload_timer: 0.0,
    target_idx: -1,
    angle: 0.0,
    targeting_mode: target_first,
    kills: 0,
    total_damage: 0.0,
    special_timer: 0.0,
    special_active: false,
    buff_damage: 0.0,
    buff_range: 0.0,
    buff_rate: 0.0,
    sell_value: 0,
  }
}

///|
pub fn Tower::new(kind : Int, gx : Int, gy : Int) -> Tower {
  {
    active: true,
    kind,
    gx,
    gy,
    level: 1,
    reload_timer: 0.0,
    target_idx: -1,
    angle: 0.0,
    targeting_mode: target_first,
    kills: 0,
    total_damage: 0.0,
    special_timer: 0.0,
    special_active: false,
    buff_damage: 0.0,
    buff_range: 0.0,
    buff_rate: 0.0,
    sell_value: tower_cost_for(kind),
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
  mut hp : Float
  mut max_hp : Float
  mut speed : Float
  mut base_speed : Float
  mut armor : Float
  mut path_index : Int
  mut path_progress : Float
  mut slow_timer : Float
  mut slow_factor : Float
  mut burn_timer : Float
  mut burn_dps : Float
  mut stun_timer : Float
  mut armor_break_timer : Float
  mut armor_break_factor : Float
  mut gold_value : Int
  mut flying : Bool
  mut is_boss : Bool
  mut is_camo : Bool
  mut shield_hp : Float
  mut shield_max : Float
  mut shield_regen_timer : Float
  mut heal_timer : Float
  mut spawn_children : Bool
  mut score_value : Int
}

///|
pub fn Enemy::inactive() -> Enemy {
  {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    hp: 0.0,
    max_hp: 1.0,
    speed: 2.0,
    base_speed: 2.0,
    armor: 0.0,
    path_index: 0,
    path_progress: 0.0,
    slow_timer: 0.0,
    slow_factor: 1.0,
    burn_timer: 0.0,
    burn_dps: 0.0,
    stun_timer: 0.0,
    armor_break_timer: 0.0,
    armor_break_factor: 1.0,
    gold_value: 10,
    flying: false,
    is_boss: false,
    is_camo: false,
    shield_hp: 0.0,
    shield_max: 0.0,
    shield_regen_timer: 0.0,
    heal_timer: 0.0,
    spawn_children: false,
    score_value: 10,
  }
}

// Projectile

///|
pub(all) struct Projectile {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut target_idx : Int
  mut damage : Float
  mut speed : Float
  mut splash_radius : Float
  mut slow_amount : Float
  mut slow_duration : Float
  mut burn_damage : Float
  mut burn_duration : Float
  mut stun_chance : Float
  mut stun_duration : Float
  mut chain_count : Int
  mut chain_range : Float
  mut is_crit : Bool
  mut tower_idx : Int
}

///|
pub fn Projectile::inactive() -> Projectile {
  {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    target_idx: -1,
    damage: 0.0,
    speed: 12.0,
    splash_radius: 0.0,
    slow_amount: 0.0,
    slow_duration: 0.0,
    burn_damage: 0.0,
    burn_duration: 0.0,
    stun_chance: 0.0,
    stun_duration: 0.0,
    chain_count: 0,
    chain_range: 0.0,
    is_crit: false,
    tower_idx: -1,
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

// Particle kinds

///|
pub let particle_normal : Int = 0

///|
pub let particle_fire : Int = 1

///|
pub let particle_ice : Int = 2

///|
pub let particle_lightning : Int = 3

///|
pub let particle_gold : Int = 4

///|
pub let particle_build : Int = 5

///|
pub let particle_explosion : Int = 6

// Path node

///|
pub(all) struct PathNode {
  x : Float
  z : Float
}

// Wave spawn entry: one type of enemy within a wave

///|
pub(all) struct WaveSpawnEntry {
  enemy_kind : Int
  count : Int
  hp_mult : Float
  speed_mult : Float
  spawn_delay : Float
}

// Wave definition

///|
pub(all) struct WaveDef {
  enemy_kind : Int
  count : Int
  hp_mult : Float
  speed_mult : Float
}

// Extended wave definition with multiple spawn groups

///|
pub(all) struct WaveInfo {
  entries : Array[WaveSpawnEntry]
  is_boss_wave : Bool
  bonus_gold : Int
  wave_message : String
}

// Map data definition

///|
pub(all) struct MapInfo {
  name : String
  difficulty : Int
  layout : Array[String]
  description : String
  starting_gold_bonus : Int
}

// Tower upgrade info

///|
pub(all) struct UpgradeInfo {
  cost : Int
  damage_mult : Float
  range_mult : Float
  rate_mult : Float
  special_desc : String
}

// Main Game struct

///|
pub(all) struct Game {
  mut state : Int
  mut prev_state : Int

  // Economy
  mut gold : Int
  mut lives : Int
  mut score : Int
  mut interest_timer : Float
  mut total_gold_earned : Int
  mut total_gold_spent : Int

  // Wave system
  mut current_wave : Int
  mut wave_timer : Float
  mut spawn_timer : Float
  mut enemies_to_spawn : Int
  mut enemies_spawned : Int
  mut wave_enemy_kind : Int
  mut wave_hp_mult : Float
  mut wave_speed_mult : Float
  mut wave_spawn_group : Int
  mut enemies_killed_this_wave : Int
  mut wave_active : Bool

  // Multi-group wave system
  mut spawn_groups : Array[WaveSpawnEntry]
  mut current_group : Int
  mut group_spawned : Int
  mut group_delay_timer : Float

  // Map
  tiles : Array[Int]
  path_nodes : Array[PathNode]
  mut path_count : Int

  // Entity pools
  towers : Array[Tower]
  enemies : Array[Enemy]
  projectiles : Array[Projectile]
  particles : Array[Particle]

  // Building mode
  mut selected_tower_type : Int
  mut hover_gx : Int
  mut hover_gy : Int
  mut hover_valid : Bool

  // Camera
  mut camera_angle : Float
  mut camera_pitch : Float
  mut camera_dist : Float
  mut camera_target_x : Float
  mut camera_target_z : Float

  // UI
  mut menu_cursor : Int
  mut menu_blink : Float
  mut show_ranges : Bool
  mut selected_tower_idx : Int
  mut upgrade_preview : Bool
  mut tower_info_scroll : Int
  mut notification_timer : Float
  mut notification_text : String
  mut show_minimap : Bool

  // Speed control
  mut speed_multiplier : Float
  mut speed_setting : Int

  // Difficulty
  mut difficulty : Int

  // RNG
  mut rng_state : Int
  mut frame_counter : Int

  // Current map
  mut current_map : Int

  // Stats tracking
  mut towers_built : Int
  mut towers_sold : Int
  mut total_kills : Int
  mut damage_dealt : Float
  mut longest_wave : Int

  // Wave message display
  mut wave_message : String
  mut wave_message_timer : Float

  // Lightning chain visualization
  mut chain_lines : Array[ChainLine]
  mut chain_line_count : Int
}

// Chain lightning visual line

///|
pub(all) struct ChainLine {
  mut active : Bool
  mut x1 : Float
  mut y1 : Float
  mut z1 : Float
  mut x2 : Float
  mut y2 : Float
  mut z2 : Float
  mut life : Float
}

///|
pub fn ChainLine::inactive() -> ChainLine {
  {
    active: false,
    x1: 0.0,
    y1: 0.0,
    z1: 0.0,
    x2: 0.0,
    y2: 0.0,
    z2: 0.0,
    life: 0.0,
  }
}

///|
pub fn Game::new() -> Game {
  {
    state: state_menu,
    prev_state: state_menu,
    gold: starting_gold,
    lives: starting_lives,
    score: 0,
    interest_timer: 0.0,
    total_gold_earned: starting_gold,
    total_gold_spent: 0,
    current_wave: 0,
    wave_timer: 0.0,
    spawn_timer: 0.0,
    enemies_to_spawn: 0,
    enemies_spawned: 0,
    wave_enemy_kind: 0,
    wave_hp_mult: 1.0,
    wave_speed_mult: 1.0,
    wave_spawn_group: 0,
    enemies_killed_this_wave: 0,
    wave_active: false,
    spawn_groups: [],
    current_group: 0,
    group_spawned: 0,
    group_delay_timer: 0.0,
    tiles: Array::make(map_total, tile_grass),
    path_nodes: {
      let arr : Array[PathNode] = []
      for i = 0; i < max_path_nodes; i = i + 1 {
        arr.push({ x: 0.0, z: 0.0 })
        ignore(i)
      }
      arr
    },
    path_count: 0,
    towers: Array::make(max_towers, Tower::inactive()),
    enemies: Array::make(max_enemies, Enemy::inactive()),
    projectiles: Array::make(max_projectiles, Projectile::inactive()),
    particles: Array::make(max_particles, Particle::inactive()),
    selected_tower_type: tower_arrow,
    hover_gx: 0,
    hover_gy: 0,
    hover_valid: false,
    camera_angle: 45.0,
    camera_pitch: 55.0,
    camera_dist: 25.0,
    camera_target_x: Float::from_int(map_w) * cell_size / 2.0,
    camera_target_z: Float::from_int(map_h) * cell_size / 2.0,
    menu_cursor: 0,
    menu_blink: 0.0,
    show_ranges: false,
    selected_tower_idx: -1,
    upgrade_preview: false,
    tower_info_scroll: 0,
    notification_timer: 0.0,
    notification_text: "",
    show_minimap: true,
    speed_multiplier: 1.0,
    speed_setting: 0,
    difficulty: 1,
    rng_state: 12345,
    frame_counter: 0,
    current_map: 0,
    towers_built: 0,
    towers_sold: 0,
    total_kills: 0,
    damage_dealt: 0.0,
    longest_wave: 0,
    wave_message: "",
    wave_message_timer: 0.0,
    chain_lines: Array::make(16, ChainLine::inactive()),
    chain_line_count: 0,
  }
}
