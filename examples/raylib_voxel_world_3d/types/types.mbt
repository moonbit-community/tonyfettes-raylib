// A single chunk of blocks
pub(all) struct Chunk {
  blocks : Array[Int]
  cx : Int
  cz : Int
  mut dirty : Bool
  mut biome : Int
}

pub fn Chunk::new(cx : Int, cz : Int) -> Chunk {
  let size = chunk_x * chunk_y * chunk_z
  { blocks: Array::make(size, block_air), cx, cz, dirty: true, biome: biome_plains }
}

pub fn Chunk::get_block(self : Chunk, x : Int, y : Int, z : Int) -> Int {
  if x < 0 || x >= chunk_x || y < 0 || y >= chunk_y || z < 0 || z >= chunk_z {
    block_air
  } else {
    self.blocks[y * chunk_x * chunk_z + z * chunk_x + x]
  }
}

pub fn Chunk::set_block(
  self : Chunk,
  x : Int,
  y : Int,
  z : Int,
  block : Int
) -> Unit {
  if x >= 0 && x < chunk_x && y >= 0 && y < chunk_y && z >= 0 && z < chunk_z {
    self.blocks[y * chunk_x * chunk_z + z * chunk_x + x] = block
    self.dirty = true
  }
}

// Inventory item slot
pub(all) struct ItemSlot {
  mut item_id : Int
  mut count : Int
}

pub fn ItemSlot::empty() -> ItemSlot {
  { item_id: 0, count: 0 }
}

pub fn ItemSlot::make(item_id : Int, count : Int) -> ItemSlot {
  { item_id, count }
}

// Inventory system
pub(all) struct Inventory {
  slots : Array[ItemSlot]
  mut selected : Int
}

pub fn Inventory::new() -> Inventory {
  let slots : Array[ItemSlot] = []
  for i = 0; i < inventory_slots; i = i + 1 {
    slots.push(ItemSlot::empty())
    ignore(i)
  }
  // Give some starting items
  slots[0] = ItemSlot::make(block_grass, 32)
  slots[1] = ItemSlot::make(block_dirt, 32)
  slots[2] = ItemSlot::make(block_stone, 32)
  slots[3] = ItemSlot::make(block_wood, 32)
  slots[4] = ItemSlot::make(block_leaves, 16)
  slots[5] = ItemSlot::make(block_sand, 16)
  slots[6] = ItemSlot::make(block_glass, 16)
  slots[7] = ItemSlot::make(block_brick, 16)
  slots[8] = ItemSlot::make(block_torch, 8)
  { slots, selected: 0 }
}

// Add item to inventory, returns count that could not be added
pub fn Inventory::add_item(self : Inventory, item_id : Int, count : Int) -> Int {
  let mut remaining = count
  // First try to stack with existing slots
  for i = 0; i < inventory_slots; i = i + 1 {
    if remaining <= 0 {
      return 0
    }
    if self.slots[i].item_id == item_id && self.slots[i].count > 0 && self.slots[i].count < stack_max {
      let can_add = if stack_max - self.slots[i].count < remaining {
        stack_max - self.slots[i].count
      } else {
        remaining
      }
      self.slots[i].count += can_add
      remaining -= can_add
    }
  }
  // Then try empty slots
  for i = 0; i < inventory_slots; i = i + 1 {
    if remaining <= 0 {
      return 0
    }
    if self.slots[i].count <= 0 {
      let to_add = if remaining < stack_max { remaining } else { stack_max }
      self.slots[i].item_id = item_id
      self.slots[i].count = to_add
      remaining -= to_add
    }
  }
  remaining
}

// Remove one item from the selected hotbar slot
pub fn Inventory::use_selected(self : Inventory) -> Int {
  let slot = self.slots[self.selected]
  if slot.count > 0 {
    let id = slot.item_id
    slot.count -= 1
    if slot.count <= 0 {
      slot.item_id = 0
    }
    id
  } else {
    0
  }
}

// Get the item id in the selected slot
pub fn Inventory::selected_item(self : Inventory) -> Int {
  let slot = self.slots[self.selected]
  if slot.count > 0 {
    slot.item_id
  } else {
    0
  }
}

// Player entity
pub(all) struct Player {
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut yaw : Float
  mut pitch : Float
  mut on_ground : Bool
  mut sprint : Bool
  mut selected_block : Int
  mut bob_timer : Float
  // Health and hunger
  mut health : Int
  mut hunger : Int
  mut hunger_timer : Float
  mut air : Int
  // Mining
  mut mining_block_x : Int
  mut mining_block_y : Int
  mut mining_block_z : Int
  mut mining_progress : Float
  mut mining_active : Bool
  // Tool
  mut equipped_tool : Int
  // Combat
  mut attack_cooldown : Float
  mut invulnerable_timer : Float
  mut damage_flash : Float
  // Fall damage tracking
  mut fall_start_y : Float
  mut was_on_ground : Bool
  // Inventory
  inventory : Inventory
  // Underwater
  mut underwater : Bool
  mut air_timer : Float
  // Starvation
  mut starve_timer : Float
}

pub fn Player::new() -> Player {
  let spawn_x = Float::from_int(world_chunks_x * chunk_x) / 2.0
  let spawn_z = Float::from_int(world_chunks_z * chunk_z) / 2.0
  {
    x: spawn_x,
    y: 40.0,
    z: spawn_z,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    yaw: 0.0,
    pitch: 0.0,
    on_ground: false,
    sprint: false,
    selected_block: block_grass,
    bob_timer: 0.0,
    health: player_max_health,
    hunger: player_max_hunger,
    hunger_timer: 0.0,
    air: player_max_air,
    mining_block_x: 0,
    mining_block_y: 0,
    mining_block_z: 0,
    mining_progress: 0.0,
    mining_active: false,
    equipped_tool: tool_hand,
    attack_cooldown: 0.0,
    invulnerable_timer: 0.0,
    damage_flash: 0.0,
    fall_start_y: 40.0,
    was_on_ground: false,
    inventory: Inventory::new(),
    underwater: false,
    air_timer: 0.0,
    starve_timer: 0.0,
  }
}

// Ray hit result for block targeting
pub(all) struct BlockHit {
  mut hit : Bool
  mut bx : Int
  mut by : Int
  mut bz : Int
  mut nx : Int
  mut ny : Int
  mut nz : Int
  mut distance : Float
}

pub fn BlockHit::new() -> BlockHit {
  { hit: false, bx: 0, by: 0, bz: 0, nx: 0, ny: 0, nz: 0, distance: 0.0 }
}

// Entity (mob) struct
pub(all) struct Entity {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut health : Int
  mut max_health : Int
  mut ai_state : Int
  mut ai_timer : Float
  mut target_x : Float
  mut target_z : Float
  mut yaw : Float
  mut on_ground : Bool
  mut damage_flash : Float
  mut anim_timer : Float
  mut attack_cooldown : Float
}

pub fn Entity::inactive() -> Entity {
  {
    active: false,
    kind: 0,
    x: 0.0,
    y: 0.0,
    z: 0.0,
    vx: 0.0,
    vy: 0.0,
    vz: 0.0,
    health: 0,
    max_health: 0,
    ai_state: ai_idle,
    ai_timer: 0.0,
    target_x: 0.0,
    target_z: 0.0,
    yaw: 0.0,
    on_ground: false,
    damage_flash: 0.0,
    anim_timer: 0.0,
    attack_cooldown: 0.0,
  }
}

// Particle struct for block break effects etc.
pub(all) struct Particle {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut z : Float
  mut vx : Float
  mut vy : Float
  mut vz : Float
  mut lifetime : Float
  mut max_lifetime : Float
  mut color_r : Int
  mut color_g : Int
  mut color_b : Int
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
    lifetime: 0.0,
    max_lifetime: 1.0,
    color_r: 255,
    color_g: 255,
    color_b: 255,
    size: 0.1,
  }
}

// Crafting recipe
pub(all) struct CraftingRecipe {
  input1_id : Int
  input1_count : Int
  input2_id : Int
  input2_count : Int
  output_id : Int
  output_count : Int
  name : String
}

pub fn CraftingRecipe::new(
  in1_id : Int,
  in1_count : Int,
  in2_id : Int,
  in2_count : Int,
  out_id : Int,
  out_count : Int,
  name : String
) -> CraftingRecipe {
  {
    input1_id: in1_id,
    input1_count: in1_count,
    input2_id: in2_id,
    input2_count: in2_count,
    output_id: out_id,
    output_count: out_count,
    name,
  }
}

// Biome parameters
pub(all) struct BiomeParams {
  id : Int
  name : String
  height_base : Float
  height_amplitude : Float
  tree_density : Float
  surface_block : Int
  sub_surface_block : Int
  has_snow : Bool
  has_cactus : Bool
  water_color_r : Int
  water_color_g : Int
  water_color_b : Int
}

// Main Game struct
pub(all) struct Game {
  mut state : Int

  // Player
  player : Player

  // World
  chunks : Array[Chunk]

  // Camera (stored as separate floats for rendering)
  mut cam_pos_x : Float
  mut cam_pos_y : Float
  mut cam_pos_z : Float
  mut cam_target_x : Float
  mut cam_target_y : Float
  mut cam_target_z : Float

  // Block targeting
  target : BlockHit

  // Day/night cycle
  mut day_timer : Float
  mut day_count : Int
  mut sky_r : Int
  mut sky_g : Int
  mut sky_b : Int
  mut sun_angle : Float
  mut is_night : Bool

  // UI state
  mut menu_blink : Float
  mut message_timer : Float
  mut message_text : String
  mut show_debug : Bool
  mut crafting_selection : Int

  // Entities
  entities : Array[Entity]
  mut entity_spawn_timer : Float

  // Particles
  particles : Array[Particle]

  // Block physics
  mut gravity_block_timer : Float

  // Water spreading
  mut water_spread_timer : Float

  // RNG
  mut rng_state : Int
  mut frame_counter : Int

  // Difficulty
  mut difficulty : Int

  // Stats
  mut blocks_broken : Int
  mut blocks_placed : Int
  mut mobs_killed : Int
  mut distance_walked : Float
  mut prev_pos_x : Float
  mut prev_pos_z : Float

  // Death screen
  mut death_timer : Float
  mut respawn_count : Int
}

pub fn Game::new() -> Game {
  // Create chunks
  let total_chunks = world_chunks_x * world_chunks_z
  let chunks : Array[Chunk] = []
  for cz = 0; cz < world_chunks_z; cz = cz + 1 {
    for cx = 0; cx < world_chunks_x; cx = cx + 1 {
      chunks.push(Chunk::new(cx, cz))
    }
  }
  // Create entity pool
  let entities : Array[Entity] = []
  for i = 0; i < entity_max; i = i + 1 {
    entities.push(Entity::inactive())
    ignore(i)
  }
  // Create particle pool
  let particles : Array[Particle] = []
  for i = 0; i < particle_max; i = i + 1 {
    particles.push(Particle::inactive())
    ignore(i)
  }
  let game : Game = {
    state: state_menu,
    player: Player::new(),
    chunks,
    cam_pos_x: 0.0,
    cam_pos_y: 40.0,
    cam_pos_z: 0.0,
    cam_target_x: 0.0,
    cam_target_y: 40.0,
    cam_target_z: -1.0,
    target: BlockHit::new(),
    day_timer: 30.0,
    day_count: 1,
    sky_r: 135,
    sky_g: 206,
    sky_b: 235,
    sun_angle: 0.0,
    is_night: false,
    menu_blink: 0.0,
    message_timer: 0.0,
    message_text: "",
    show_debug: false,
    crafting_selection: 0,
    entities,
    entity_spawn_timer: 5.0,
    particles,
    gravity_block_timer: 0.0,
    water_spread_timer: 0.0,
    rng_state: 12345,
    frame_counter: 0,
    difficulty: 1,
    blocks_broken: 0,
    blocks_placed: 0,
    mobs_killed: 0,
    distance_walked: 0.0,
    prev_pos_x: 0.0,
    prev_pos_z: 0.0,
    death_timer: 0.0,
    respawn_count: 0,
  }
  // Generate terrain for all chunks
  for i = 0; i < total_chunks; i = i + 1 {
    generate_chunk_terrain(game.chunks[i], game)
  }
  game
}
