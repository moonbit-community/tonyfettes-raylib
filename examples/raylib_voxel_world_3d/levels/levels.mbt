// Block color definitions (r, g, b) for each block type
// Expanded to cover all 24 block types

///|
pub fn block_color_r(kind : Int) -> Int {
  if kind == @types.block_dirt {
    139
  } else if kind == @types.block_grass {
    76
  } else if kind == @types.block_stone {
    128
  } else if kind == @types.block_wood {
    139
  } else if kind == @types.block_leaves {
    34
  } else if kind == @types.block_water {
    64
  } else if kind == @types.block_sand {
    210
  } else if kind == @types.block_glass {
    200
  } else if kind == @types.block_brick {
    178
  } else if kind == @types.block_ore_iron {
    140
  } else if kind == @types.block_ore_gold {
    180
  } else if kind == @types.block_ore_diamond {
    100
  } else if kind == @types.block_snow {
    240
  } else if kind == @types.block_gravel {
    130
  } else if kind == @types.block_planks {
    180
  } else if kind == @types.block_cobblestone {
    110
  } else if kind == @types.block_torch {
    255
  } else if kind == @types.block_bedrock {
    50
  } else if kind == @types.block_flower_red {
    220
  } else if kind == @types.block_flower_yellow {
    255
  } else if kind == @types.block_tall_grass {
    60
  } else if kind == @types.block_cactus {
    30
  } else if kind == @types.block_clay {
    160
  } else {
    255
  }
}

///|
pub fn block_color_g(kind : Int) -> Int {
  if kind == @types.block_dirt {
    90
  } else if kind == @types.block_grass {
    153
  } else if kind == @types.block_stone {
    128
  } else if kind == @types.block_wood {
    90
  } else if kind == @types.block_leaves {
    139
  } else if kind == @types.block_water {
    164
  } else if kind == @types.block_sand {
    180
  } else if kind == @types.block_glass {
    220
  } else if kind == @types.block_brick {
    90
  } else if kind == @types.block_ore_iron {
    130
  } else if kind == @types.block_ore_gold {
    160
  } else if kind == @types.block_ore_diamond {
    200
  } else if kind == @types.block_snow {
    245
  } else if kind == @types.block_gravel {
    125
  } else if kind == @types.block_planks {
    140
  } else if kind == @types.block_cobblestone {
    110
  } else if kind == @types.block_torch {
    200
  } else if kind == @types.block_bedrock {
    50
  } else if kind == @types.block_flower_red {
    40
  } else if kind == @types.block_flower_yellow {
    220
  } else if kind == @types.block_tall_grass {
    140
  } else if kind == @types.block_cactus {
    130
  } else if kind == @types.block_clay {
    155
  } else {
    255
  }
}

///|
pub fn block_color_b(kind : Int) -> Int {
  if kind == @types.block_dirt {
    43
  } else if kind == @types.block_grass {
    0
  } else if kind == @types.block_stone {
    128
  } else if kind == @types.block_wood {
    43
  } else if kind == @types.block_leaves {
    34
  } else if kind == @types.block_water {
    223
  } else if kind == @types.block_sand {
    140
  } else if kind == @types.block_glass {
    240
  } else if kind == @types.block_brick {
    60
  } else if kind == @types.block_ore_iron {
    150
  } else if kind == @types.block_ore_gold {
    50
  } else if kind == @types.block_ore_diamond {
    240
  } else if kind == @types.block_snow {
    250
  } else if kind == @types.block_gravel {
    120
  } else if kind == @types.block_planks {
    80
  } else if kind == @types.block_cobblestone {
    105
  } else if kind == @types.block_torch {
    50
  } else if kind == @types.block_bedrock {
    50
  } else if kind == @types.block_flower_red {
    50
  } else if kind == @types.block_flower_yellow {
    50
  } else if kind == @types.block_tall_grass {
    30
  } else if kind == @types.block_cactus {
    50
  } else if kind == @types.block_clay {
    145
  } else {
    255
  }
}

// Darker shade for block sides

///|
pub fn block_side_color_r(kind : Int) -> Int {
  let r = block_color_r(kind)
  r * 4 / 5
}

///|
pub fn block_side_color_g(kind : Int) -> Int {
  let g = block_color_g(kind)
  g * 4 / 5
}

///|
pub fn block_side_color_b(kind : Int) -> Int {
  let b = block_color_b(kind)
  b * 4 / 5
}

// Even darker shade for block bottom

///|
pub fn block_bottom_color_r(kind : Int) -> Int {
  let r = block_color_r(kind)
  r * 3 / 5
}

///|
pub fn block_bottom_color_g(kind : Int) -> Int {
  let g = block_color_g(kind)
  g * 3 / 5
}

///|
pub fn block_bottom_color_b(kind : Int) -> Int {
  let b = block_color_b(kind)
  b * 3 / 5
}

// Block alpha (water and glass are semi-transparent)

///|
pub fn block_alpha(kind : Int) -> Int {
  if kind == @types.block_water {
    160
  } else if kind == @types.block_glass {
    120
  } else if kind == @types.block_leaves {
    230
  } else {
    255
  }
}

// ========== Biome Definitions ==========

///|
pub fn biome_tree_density(biome : Int) -> Float {
  if biome == @types.biome_plains {
    0.02
  } else if biome == @types.biome_forest {
    0.12
  } else if biome == @types.biome_desert {
    0.0
  } else if biome == @types.biome_mountains {
    0.01
  } else if biome == @types.biome_tundra {
    0.03
  } else if biome == @types.biome_swamp {
    0.06
  } else {
    0.03
  }
}

///|
pub fn biome_grass_density(biome : Int) -> Float {
  if biome == @types.biome_plains {
    0.15
  } else if biome == @types.biome_forest {
    0.08
  } else if biome == @types.biome_desert {
    0.0
  } else if biome == @types.biome_mountains {
    0.02
  } else if biome == @types.biome_tundra {
    0.01
  } else if biome == @types.biome_swamp {
    0.1
  } else {
    0.05
  }
}

// ========== Fog colors per time of day ==========

///|
pub fn fog_color_r(is_night : Bool) -> Int {
  if is_night {
    15
  } else {
    180
  }
}

///|
pub fn fog_color_g(is_night : Bool) -> Int {
  if is_night {
    15
  } else {
    200
  }
}

///|
pub fn fog_color_b(is_night : Bool) -> Int {
  if is_night {
    40
  } else {
    220
  }
}

// ========== Crafting Recipes ==========

///|
pub fn get_crafting_recipes() -> Array[@types.CraftingRecipe] {
  let recipes : Array[@types.CraftingRecipe] = []
  // Wood -> Planks (1 wood = 4 planks)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_wood, 1, 0, 0, @types.block_planks, 4, "Wood -> Planks",
    ),
  )
  // Planks -> Sticks (not a block, but stored as item)
  // Stone + Cobblestone -> Brick
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_cobblestone, 4, 0, 0, @types.block_brick, 1, "Cobblestone -> Brick",
    ),
  )
  // Sand -> Glass (smelting)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_sand, 4, 0, 0, @types.block_glass, 1, "Sand -> Glass",
    ),
  )
  // Cobblestone -> Stone (smelting)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_cobblestone, 1, 0, 0, @types.block_stone, 1, "Cobblestone -> Stone",
    ),
  )
  // Clay -> Brick
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_clay, 4, 0, 0, @types.block_brick, 2, "Clay -> Bricks",
    ),
  )
  // Dirt + Sand -> Gravel
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_dirt, 2, @types.block_sand, 2, @types.block_gravel, 4, "Dirt+Sand -> Gravel",
    ),
  )
  // Planks -> Torch (simplified)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_planks, 1, @types.block_wood, 1, @types.block_torch, 4, "Planks+Wood -> Torches",
    ),
  )
  // Snow -> Ice (represented as glass-like block)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_snow, 4, 0, 0, @types.block_glass, 1, "Snow -> Ice",
    ),
  )
  // Gravel + Sand -> Cobblestone
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_gravel, 2, @types.block_sand, 2, @types.block_cobblestone, 4,
      "Gravel+Sand -> Cobblestone",
    ),
  )
  // Dirt -> Grass Block (with sunlight, simplified)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_dirt, 4, @types.block_leaves, 1, @types.block_grass, 4, "Dirt+Leaves -> Grass",
    ),
  )
  // Stone + Sand -> Brick Wall
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_stone, 2, @types.block_sand, 1, @types.block_brick, 2, "Stone+Sand -> Bricks",
    ),
  )
  // Leaves -> Tall Grass (decoration crafting)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_leaves, 4, 0, 0, @types.block_tall_grass, 2, "Leaves -> Tall Grass",
    ),
  )
  // Wood -> Torch (simple recipe)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_wood, 2, 0, 0, @types.block_torch, 2, "Wood -> Torches",
    ),
  )
  // Cobblestone + Dirt -> Gravel
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_cobblestone, 2, @types.block_dirt, 1, @types.block_gravel, 3,
      "Cobble+Dirt -> Gravel",
    ),
  )
  // Sand + Glass -> Decorative Glass
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_sand, 2, @types.block_glass, 1, @types.block_glass, 3, "Sand+Glass -> More Glass",
    ),
  )
  // Clay + Sand -> Brick (alternate)
  recipes.push(
    @types.CraftingRecipe::new(
      @types.block_clay, 2, @types.block_sand, 2, @types.block_brick, 3, "Clay+Sand -> Bricks",
    ),
  )
  recipes
}

// ========== Mob spawn tables ==========

// Returns a mob type suitable for this biome; 0 = no spawn

///|
pub fn get_spawn_type_for_biome(
  biome : Int,
  is_night : Bool,
  rng_val : Int,
) -> Int {
  let r = rng_val % 100
  if is_night {
    // Hostile mobs at night
    if r < 40 {
      @types.entity_zombie
    } else if r < 65 {
      @types.entity_skeleton
    } else if r < 80 {
      @types.entity_spider
    } else {
      0
    }
    // Passive mobs during day, biome-dependent
  } else if biome == @types.biome_plains {
    if r < 35 {
      @types.entity_cow
    } else if r < 65 {
      @types.entity_pig
    } else if r < 85 {
      @types.entity_chicken
    } else {
      0
    }
  } else if biome == @types.biome_forest {
    if r < 30 {
      @types.entity_pig
    } else if r < 55 {
      @types.entity_chicken
    } else if r < 70 {
      @types.entity_cow
    } else {
      0
    }
  } else if biome == @types.biome_desert {
    // Very few spawns in desert
    if r < 10 {
      @types.entity_chicken
    } else {
      0
    }
  } else if biome == @types.biome_mountains {
    if r < 25 {
      @types.entity_cow
    } else {
      0
    }
  } else if biome == @types.biome_tundra {
    if r < 20 {
      @types.entity_cow
    } else if r < 35 {
      @types.entity_pig
    } else {
      0
    }
  } else if biome == @types.biome_swamp {
    if r < 20 {
      @types.entity_pig
    } else if r < 40 {
      @types.entity_chicken
    } else {
      0
    }
  } else {
    0
  }
}

// ========== Ore distribution ==========

///|
pub fn ore_vein_size(ore : Int) -> Int {
  if ore == @types.block_ore_iron {
    4
  } else if ore == @types.block_ore_gold {
    3
  } else if ore == @types.block_ore_diamond {
    2
  } else {
    1
  }
}

// ========== Structure templates ==========

// Simple house dimensions

///|
pub fn structure_house_width() -> Int {
  7
}

///|
pub fn structure_house_depth() -> Int {
  7
}

///|
pub fn structure_house_height() -> Int {
  5
}

// Get block for a house at relative position

///|
pub fn structure_house_block(rx : Int, ry : Int, rz : Int) -> Int {
  let w = structure_house_width() - 1
  let d = structure_house_depth() - 1
  let h = structure_house_height() - 1
  // Floor
  if ry == 0 {
    return @types.block_planks
  }
  // Roof
  if ry == h {
    return @types.block_planks
  }
  // Walls
  let is_wall = rx == 0 || rx == w || rz == 0 || rz == d
  if is_wall && ry > 0 && ry < h {
    // Door opening
    if rx == w / 2 && rz == 0 && ry < 3 {
      return @types.block_air
    }
    // Window openings
    if ry == 2 {
      if (rx == 0 || rx == w) && rz == d / 2 {
        return @types.block_glass
      }
      if (rz == 0 || rz == d) && rx == w / 2 {
        return @types.block_glass
      }
    }
    return @types.block_cobblestone
  }
  // Interior
  if ry > 0 && ry < h {
    // Torch in corner
    if rx == 1 && rz == 1 && ry == 1 {
      return @types.block_torch
    }
    return @types.block_air
  }
  @types.block_air
}

// ========== Biome parameters definitions ==========

///|
pub fn get_biome_params(biome : Int) -> @types.BiomeParams {
  if biome == @types.biome_plains {
    {
      id: @types.biome_plains,
      name: "Plains",
      height_base: 22.0,
      height_amplitude: 6.0,
      tree_density: 0.02,
      surface_block: @types.block_grass,
      sub_surface_block: @types.block_dirt,
      has_snow: false,
      has_cactus: false,
      water_color_r: 64,
      water_color_g: 164,
      water_color_b: 223,
    }
  } else if biome == @types.biome_forest {
    {
      id: @types.biome_forest,
      name: "Forest",
      height_base: 23.0,
      height_amplitude: 10.0,
      tree_density: 0.12,
      surface_block: @types.block_grass,
      sub_surface_block: @types.block_dirt,
      has_snow: false,
      has_cactus: false,
      water_color_r: 40,
      water_color_g: 140,
      water_color_b: 200,
    }
  } else if biome == @types.biome_desert {
    {
      id: @types.biome_desert,
      name: "Desert",
      height_base: 19.0,
      height_amplitude: 5.0,
      tree_density: 0.0,
      surface_block: @types.block_sand,
      sub_surface_block: @types.block_sand,
      has_snow: false,
      has_cactus: true,
      water_color_r: 80,
      water_color_g: 180,
      water_color_b: 200,
    }
  } else if biome == @types.biome_mountains {
    {
      id: @types.biome_mountains,
      name: "Mountains",
      height_base: 30.0,
      height_amplitude: 22.0,
      tree_density: 0.01,
      surface_block: @types.block_stone,
      sub_surface_block: @types.block_stone,
      has_snow: true,
      has_cactus: false,
      water_color_r: 50,
      water_color_g: 130,
      water_color_b: 210,
    }
  } else if biome == @types.biome_tundra {
    {
      id: @types.biome_tundra,
      name: "Tundra",
      height_base: 21.0,
      height_amplitude: 8.0,
      tree_density: 0.03,
      surface_block: @types.block_snow,
      sub_surface_block: @types.block_gravel,
      has_snow: true,
      has_cactus: false,
      water_color_r: 80,
      water_color_g: 140,
      water_color_b: 180,
    }
  } else {
    // Swamp
    {
      id: @types.biome_swamp,
      name: "Swamp",
      height_base: 18.0,
      height_amplitude: 3.0,
      tree_density: 0.06,
      surface_block: @types.block_grass,
      sub_surface_block: @types.block_clay,
      has_snow: false,
      has_cactus: false,
      water_color_r: 50,
      water_color_g: 100,
      water_color_b: 80,
    }
  }
}

// ========== Ore distribution tables per depth ==========

// Get ore spawn chance at a given depth for each ore type

///|
pub fn ore_chance_at_depth(ore : Int, depth : Int) -> Float {
  if ore == @types.block_ore_iron {
    if depth < 5 {
      0.01
    } else if depth < 15 {
      0.025
    } else if depth < 30 {
      0.035
    } else if depth < 45 {
      0.03
    } else {
      0.01
    }
  } else if ore == @types.block_ore_gold {
    if depth < 5 {
      0.005
    } else if depth < 12 {
      0.015
    } else if depth < 20 {
      0.02
    } else if depth < 28 {
      0.015
    } else {
      0.0
    }
  } else if ore == @types.block_ore_diamond {
    if depth < 5 {
      0.002
    } else if depth < 8 {
      0.005
    } else if depth < 14 {
      0.008
    } else if depth < 16 {
      0.006
    } else {
      0.0
    }
  } else {
    0.0
  }
}

// Get ore vein maximum size at given depth

///|
pub fn ore_vein_max_at_depth(ore : Int, depth : Int) -> Int {
  if ore == @types.block_ore_iron {
    if depth < 10 {
      3
    } else if depth < 25 {
      5
    } else {
      4
    }
  } else if ore == @types.block_ore_gold {
    if depth < 10 {
      2
    } else if depth < 20 {
      4
    } else {
      3
    }
  } else if ore == @types.block_ore_diamond {
    if depth < 8 {
      1
    } else if depth < 14 {
      3
    } else {
      2
    }
  } else {
    1
  }
}

// ========== Structure templates ==========

// Large tree template: oak tree with wider canopy

///|
pub fn structure_large_tree_height() -> Int {
  7
}

///|
pub fn structure_large_tree_canopy_radius() -> Int {
  3
}

///|
pub fn structure_large_tree_block(rx : Int, ry : Int, rz : Int) -> Int {
  let trunk_h = 5
  let canopy_start = 3
  let canopy_end = 7
  let r = structure_large_tree_canopy_radius()
  // Trunk
  if rx == 0 && rz == 0 && ry < trunk_h {
    return @types.block_wood
  }
  // Canopy (sphere-ish leaves)
  if ry >= canopy_start && ry < canopy_end {
    let dist_sq = rx * rx + rz * rz
    let layer = ry - canopy_start
    let max_r : Int = if layer == 0 {
      r
    } else if layer == 1 {
      r
    } else if layer == 2 {
      r - 1
    } else {
      r - 2
    }
    if max_r < 0 {
      return @types.block_air
    }
    if dist_sq <= max_r * max_r {
      if rx == 0 && rz == 0 && ry < trunk_h {
        return @types.block_wood
      }
      return @types.block_leaves
    }
  }
  @types.block_air
}

// Ruin structure template: small ruined stone walls

///|
pub fn structure_ruin_width() -> Int {
  5
}

///|
pub fn structure_ruin_depth() -> Int {
  5
}

///|
pub fn structure_ruin_height() -> Int {
  3
}

///|
pub fn structure_ruin_block(rx : Int, ry : Int, rz : Int) -> Int {
  let w = structure_ruin_width() - 1
  let d = structure_ruin_depth() - 1
  // Floor is cobblestone
  if ry == 0 {
    return @types.block_cobblestone
  }
  // Partial walls (some gaps for ruin effect)
  let is_wall = rx == 0 || rx == w || rz == 0 || rz == d
  if is_wall && ry > 0 && ry < structure_ruin_height() {
    // Leave gaps at certain positions to look ruined
    if (rx + rz + ry) % 3 == 0 {
      return @types.block_air
    }
    return @types.block_cobblestone
  }
  @types.block_air
}

// Watchtower template

///|
pub fn structure_tower_width() -> Int {
  3
}

///|
pub fn structure_tower_height() -> Int {
  8
}

///|
pub fn structure_tower_block(rx : Int, ry : Int, rz : Int) -> Int {
  let w = structure_tower_width() - 1
  // Base and top platform
  if ry == 0 || ry == structure_tower_height() - 1 {
    return @types.block_cobblestone
  }
  // Walls (hollow inside)
  let is_wall = rx == 0 || rx == w || rz == 0 || rz == w
  if is_wall && ry > 0 && ry < structure_tower_height() - 1 {
    // Door at ground level
    if rx == w / 2 && rz == 0 && ry < 3 {
      return @types.block_air
    }
    // Windows at mid height
    if ry == 4 && (rx == 0 || rx == w || rz == 0 || rz == w) {
      if rx == w / 2 || rz == w / 2 {
        return @types.block_glass
      }
    }
    return @types.block_cobblestone
  }
  // Interior torch
  if rx == 1 && rz == 1 && ry == 1 {
    return @types.block_torch
  }
  @types.block_air
}

// ========== Mob spawn tables per biome and time of day ==========

// Get the spawn rate modifier for a biome

///|
pub fn biome_spawn_rate(biome : Int) -> Float {
  if biome == @types.biome_plains {
    1.0
  } else if biome == @types.biome_forest {
    1.2
  } else if biome == @types.biome_desert {
    0.4
  } else if biome == @types.biome_mountains {
    0.5
  } else if biome == @types.biome_tundra {
    0.6
  } else if biome == @types.biome_swamp {
    1.1
  } else {
    0.8
  }
}

// Night-specific spawn multiplier

///|
pub fn night_spawn_multiplier() -> Float {
  1.8
}

// Get the hostile mob pool for a biome at night

///|
pub fn get_night_hostile_pool(biome : Int, rng_val : Int) -> Int {
  let r = rng_val % 100
  if biome == @types.biome_swamp {
    // Swamps have more spiders at night
    if r < 30 {
      @types.entity_zombie
    } else if r < 50 {
      @types.entity_spider
    } else if r < 70 {
      @types.entity_skeleton
    } else {
      0
    }
  } else if biome == @types.biome_desert {
    // Deserts have more skeletons
    if r < 25 {
      @types.entity_zombie
    } else if r < 60 {
      @types.entity_skeleton
    } else if r < 75 {
      @types.entity_spider
    } else {
      0
    }
  } else if biome == @types.biome_tundra {
    // Tundra has more skeletons
    if r < 20 {
      @types.entity_zombie
    } else if r < 55 {
      @types.entity_skeleton
    } else if r < 70 {
      @types.entity_spider
    } else {
      0
    }
  } else if biome == @types.biome_forest {
    // Forests have more spiders
    if r < 35 {
      @types.entity_zombie
    } else if r < 55 {
      @types.entity_spider
    } else if r < 75 {
      @types.entity_skeleton
    } else {
      0
    }
    // Default (plains, mountains)
  } else if r < 40 {
    @types.entity_zombie
  } else if r < 65 {
    @types.entity_skeleton
  } else if r < 80 {
    @types.entity_spider
  } else {
    0
  }
}

// ========== Damage amounts for weapons ==========

///|
pub fn get_weapon_damage(tool : Int) -> Int {
  if tool == @types.tool_wooden_sword {
    4
  } else if tool == @types.tool_stone_sword {
    5
  } else if tool == @types.tool_iron_sword {
    7
  } else if tool == @types.tool_wooden_axe {
    3
  } else if tool == @types.tool_stone_axe {
    4
  } else if tool == @types.tool_iron_axe {
    5
  } else {
    1
  }
}

// ========== Light emitting blocks ==========

///|
pub fn block_light_level(kind : Int) -> Int {
  if kind == @types.block_torch {
    @types.torch_light_level
  } else {
    0
  }
}

// ========== Block hardness (for explosion/damage resistance) ==========

///|
pub fn block_hardness(kind : Int) -> Int {
  if kind == @types.block_bedrock {
    999
  } else if kind == @types.block_stone || kind == @types.block_cobblestone {
    5
  } else if kind == @types.block_brick {
    6
  } else if kind == @types.block_ore_iron || kind == @types.block_ore_gold {
    5
  } else if kind == @types.block_ore_diamond {
    6
  } else if kind == @types.block_wood || kind == @types.block_planks {
    3
  } else if kind == @types.block_dirt || kind == @types.block_grass {
    1
  } else if kind == @types.block_sand || kind == @types.block_gravel {
    1
  } else if kind == @types.block_glass {
    0
  } else if kind == @types.block_leaves {
    0
  } else if kind == @types.block_snow || kind == @types.block_clay {
    1
  } else {
    2
  }
}
