// Enemy entity
pub(all) struct Enemy {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut z : Float
  mut hp : Int
  mut max_hp : Int
  mut atk : Int
  mut def : Int
  mut attack_timer : Float
  mut move_timer : Float
  mut alerted : Bool
  mut hit_flash : Float
  mut ai_state : Int
  mut patrol_x : Float
  mut patrol_z : Float
  mut speed_mult : Float
  mut ability_cooldown : Float
  mut stun_timer : Float
  mut slow_timer : Float
  mut xp_value : Int
  mut facing_angle : Float
}

pub fn Enemy::inactive() -> Enemy {
  {
    active: false,
    kind: enemy_none,
    x: 0.0,
    z: 0.0,
    hp: 0,
    max_hp: 0,
    atk: 0,
    def: 0,
    attack_timer: 0.0,
    move_timer: 0.0,
    alerted: false,
    hit_flash: 0.0,
    ai_state: ai_idle,
    patrol_x: 0.0,
    patrol_z: 0.0,
    speed_mult: 1.0,
    ability_cooldown: 0.0,
    stun_timer: 0.0,
    slow_timer: 0.0,
    xp_value: 10,
    facing_angle: 0.0,
  }
}

// Projectile (from archers, spells, traps)
pub(all) struct Projectile {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut z : Float
  mut vx : Float
  mut vz : Float
  mut damage : Int
  mut lifetime : Float
  mut from_enemy : Bool
  mut aoe_radius : Float
  mut slow_on_hit : Bool
}

pub fn Projectile::inactive() -> Projectile {
  {
    active: false,
    kind: 0,
    x: 0.0,
    z: 0.0,
    vx: 0.0,
    vz: 0.0,
    damage: 0,
    lifetime: 0.0,
    from_enemy: false,
    aoe_radius: 0.0,
    slow_on_hit: false,
  }
}

// Particle effect
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
}

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
  }
}

// Loot item on ground
pub(all) struct Loot {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut z : Float
  mut bob_phase : Float
  mut rarity : Int
  mut value : Int
}

pub fn Loot::inactive() -> Loot {
  {
    active: false,
    kind: loot_none,
    x: 0.0,
    z: 0.0,
    bob_phase: 0.0,
    rarity: rarity_common,
    value: 0,
  }
}

// Inventory item
pub(all) struct InvItem {
  mut kind : Int
  mut active : Bool
  mut rarity : Int
  mut stat_bonus : Int
  mut name_idx : Int
}

pub fn InvItem::empty() -> InvItem {
  { kind: 0, active: false, rarity: rarity_common, stat_bonus: 0, name_idx: 0 }
}

// Trap entity
pub(all) struct Trap {
  mut active : Bool
  mut kind : Int
  mut gx : Int
  mut gz : Int
  mut armed : Bool
  mut cooldown : Float
  mut triggered : Bool
  mut visible : Bool
}

pub fn Trap::inactive() -> Trap {
  {
    active: false,
    kind: trap_spike,
    gx: 0,
    gz: 0,
    armed: true,
    cooldown: 0.0,
    triggered: false,
    visible: false,
  }
}

// Torch for lighting
pub(all) struct Torch {
  mut active : Bool
  mut gx : Int
  mut gz : Int
  mut flicker_phase : Float
}

pub fn Torch::inactive() -> Torch {
  { active: false, gx: 0, gz: 0, flicker_phase: 0.0 }
}

// Message log entry
pub(all) struct MessageEntry {
  mut text : String
  mut timer : Float
  mut r : Int
  mut g : Int
  mut b : Int
}

pub fn MessageEntry::empty() -> MessageEntry {
  { text: "", timer: 0.0, r: 200, g: 200, b: 200 }
}

// Shop item
pub(all) struct ShopItem {
  mut active : Bool
  mut kind : Int
  mut price : Int
  mut name_idx : Int
  mut stat_bonus : Int
}

pub fn ShopItem::empty() -> ShopItem {
  { active: false, kind: 0, price: 0, name_idx: 0, stat_bonus: 0 }
}

// Room for BSP dungeon generation
pub(all) struct Room {
  mut x : Int
  mut y : Int
  mut w : Int
  mut h : Int
  mut kind : Int
  mut explored : Bool
  mut enemies_cleared : Bool
}

pub fn Room::new(x : Int, y : Int, w : Int, h : Int) -> Room {
  { x, y, w, h, kind: 0, explored: false, enemies_cleared: false }
}

pub fn Room::center_x(self : Room) -> Int {
  self.x + self.w / 2
}

pub fn Room::center_y(self : Room) -> Int {
  self.y + self.h / 2
}

// Room types
pub let room_normal : Int = 0
pub let room_treasure : Int = 1
pub let room_boss : Int = 2
pub let room_shop : Int = 3
pub let room_shrine : Int = 4

// Floor info
pub(all) struct FloorInfo {
  mut cleared : Bool
  mut enemies_killed : Int
  mut enemies_total : Int
}

pub fn FloorInfo::new() -> FloorInfo {
  { cleared: false, enemies_killed: 0, enemies_total: 0 }
}

// Player spell slot
pub(all) struct SpellSlot {
  mut spell_type : Int
  mut active : Bool
}

pub fn SpellSlot::empty() -> SpellSlot {
  { spell_type: spell_none, active: false }
}

// Active buff on player
pub(all) struct Buff {
  mut kind : Int
  mut timer : Float
  mut value : Int
  mut active : Bool
}

pub fn Buff::inactive() -> Buff {
  { kind: 0, timer: 0.0, value: 0, active: false }
}

// Buff kinds
pub let buff_speed : Int = 0
pub let buff_strength : Int = 1
pub let buff_shield : Int = 2
pub let buff_poison : Int = 3

pub let max_buffs : Int = 4

// Main Game struct
pub(all) struct Game {
  // State
  mut state : Int
  mut prev_state : Int

  // Player
  mut player_x : Float
  mut player_z : Float
  mut player_yaw : Float
  mut player_hp : Int
  mut player_max_hp : Int
  mut player_mana : Int
  mut player_max_mana : Int
  mut player_atk : Int
  mut player_def : Int
  mut player_str : Int
  mut player_dex : Int
  mut player_int_stat : Int
  mut player_level : Int
  mut player_xp : Int
  mut player_xp_next : Int
  mut player_hit_flash : Float
  mut player_gold : Int
  mut player_keys : Int
  mut player_boss_keys : Int
  mut player_weapon : Int
  mut player_armor : Int
  mut player_class : Int
  mut player_kills : Int
  mut player_total_gold : Int

  // Sword swing
  mut swing_timer : Float
  mut swing_active : Bool
  mut attack_cooldown_timer : Float

  // Camera
  mut camera_yaw : Float
  mut camera_pitch : Float

  // Dungeon
  mut current_floor : Int
  tiles : Array[Int]
  explored : Array[Bool]
  rooms : Array[Room]
  mut room_count : Int
  mut stairs_x : Int
  mut stairs_z : Int
  mut floor_theme : Int

  // Enemies
  enemies : Array[Enemy]

  // Projectiles
  projectiles : Array[Projectile]

  // Particles
  particles : Array[Particle]

  // Loot
  loot : Array[Loot]

  // Traps
  traps : Array[Trap]

  // Torches
  torches : Array[Torch]

  // Floor tracking
  floor_info : Array[FloorInfo]

  // Inventory
  inventory : Array[InvItem]
  mut inv_cursor : Int

  // Spells
  spells : Array[SpellSlot]
  mut selected_spell : Int
  mut spell_cooldown : Float

  // Buffs
  buffs : Array[Buff]

  // Shop
  shop_items : Array[ShopItem]
  mut shop_cursor : Int

  // Shrine
  mut shrine_cursor : Int
  mut shrine_used : Bool
  shrine_options : Array[Int]

  // Message log
  messages : Array[MessageEntry]

  // Boss intro
  mut boss_intro_timer : Float
  mut boss_intro_name : String

  // UI
  mut menu_cursor : Int
  mut menu_blink : Float
  mut message_timer : Float
  mut message_text : String
  mut damage_flash : Float
  mut level_up_timer : Float
  mut class_select_cursor : Int

  // Stats tracking
  mut floors_cleared : Int
  mut total_enemies_killed : Int

  // Sprint
  mut sprinting : Bool

  // Poison tracking
  mut poison_timer : Float
  mut poison_remaining : Float

  // RNG
  mut rng_state : Int
  mut frame_counter : Int
}

pub fn Game::new() -> Game {
  let floor_info : Array[FloorInfo] = []
  for i = 0; i < max_floors; i = i + 1 {
    floor_info.push(FloorInfo::new())
    ignore(i)
  }
  let rooms : Array[Room] = []
  for i = 0; i < max_rooms; i = i + 1 {
    rooms.push(Room::new(0, 0, 0, 0))
    ignore(i)
  }
  let inventory : Array[InvItem] = []
  for i = 0; i < max_inventory; i = i + 1 {
    inventory.push(InvItem::empty())
    ignore(i)
  }
  let spells : Array[SpellSlot] = []
  for i = 0; i < max_spells; i = i + 1 {
    spells.push(SpellSlot::empty())
    ignore(i)
  }
  let buffs : Array[Buff] = []
  for i = 0; i < max_buffs; i = i + 1 {
    buffs.push(Buff::inactive())
    ignore(i)
  }
  let shop_items : Array[ShopItem] = []
  for i = 0; i < max_shop_items; i = i + 1 {
    shop_items.push(ShopItem::empty())
    ignore(i)
  }
  let messages : Array[MessageEntry] = []
  for i = 0; i < max_messages; i = i + 1 {
    messages.push(MessageEntry::empty())
    ignore(i)
  }
  let traps : Array[Trap] = []
  for i = 0; i < max_traps; i = i + 1 {
    traps.push(Trap::inactive())
    ignore(i)
  }
  let torches : Array[Torch] = []
  for i = 0; i < max_torches; i = i + 1 {
    torches.push(Torch::inactive())
    ignore(i)
  }
  let shrine_options : Array[Int] = [0, 1, 2]
  {
    state: state_class_select,
    prev_state: state_menu,
    player_x: 5.0,
    player_z: 5.0,
    player_yaw: 0.0,
    player_hp: player_start_hp,
    player_max_hp: player_start_hp,
    player_mana: player_start_mana,
    player_max_mana: player_start_mana,
    player_atk: player_start_atk,
    player_def: player_start_def,
    player_str: player_start_str,
    player_dex: player_start_dex,
    player_int_stat: player_start_int_stat,
    player_level: 1,
    player_xp: 0,
    player_xp_next: xp_per_level,
    player_hit_flash: 0.0,
    player_gold: 0,
    player_keys: 0,
    player_boss_keys: 0,
    player_weapon: weapon_sword,
    player_armor: armor_none,
    player_class: class_warrior,
    player_kills: 0,
    player_total_gold: 0,
    swing_timer: 0.0,
    swing_active: false,
    attack_cooldown_timer: 0.0,
    camera_yaw: 0.0,
    camera_pitch: 0.0,
    current_floor: 0,
    tiles: Array::make(grid_total, tile_wall),
    explored: Array::make(grid_total, false),
    rooms,
    room_count: 0,
    stairs_x: 0,
    stairs_z: 0,
    floor_theme: theme_crypt,
    enemies: {
      let arr : Array[Enemy] = []
      for i = 0; i < max_enemies; i = i + 1 {
        arr.push(Enemy::inactive())
        ignore(i)
      }
      arr
    },
    projectiles: {
      let arr : Array[Projectile] = []
      for i = 0; i < max_projectiles; i = i + 1 {
        arr.push(Projectile::inactive())
        ignore(i)
      }
      arr
    },
    particles: Array::make(max_particles, Particle::inactive()),
    loot: {
      let arr : Array[Loot] = []
      for i = 0; i < max_loot; i = i + 1 {
        arr.push(Loot::inactive())
        ignore(i)
      }
      arr
    },
    traps,
    torches,
    floor_info,
    inventory,
    inv_cursor: 0,
    spells,
    selected_spell: 0,
    spell_cooldown: 0.0,
    buffs,
    shop_items,
    shop_cursor: 0,
    shrine_cursor: 0,
    shrine_used: false,
    shrine_options,
    messages,
    boss_intro_timer: 0.0,
    boss_intro_name: "",
    menu_cursor: 0,
    menu_blink: 0.0,
    message_timer: 0.0,
    message_text: "",
    damage_flash: 0.0,
    level_up_timer: 0.0,
    class_select_cursor: 0,
    floors_cleared: 0,
    total_enemies_killed: 0,
    sprinting: false,
    poison_timer: 0.0,
    poison_remaining: 0.0,
    rng_state: 12345,
    frame_counter: 0,
  }
}
