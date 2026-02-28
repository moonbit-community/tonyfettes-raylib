// Crafting system: recipe matching, crafting execution, tool durability,
// workbench and furnace logic

// ========== Tool durability tracking ==========

// Maximum durability for each tool tier

///|
pub fn get_tool_max_durability(tool : Int) -> Int {
  if tool == @types.tool_hand {
    999999
  } else if tool == @types.tool_wooden_pickaxe ||
    tool == @types.tool_wooden_axe ||
    tool == @types.tool_wooden_shovel ||
    tool == @types.tool_wooden_sword {
    60
  } else if tool == @types.tool_stone_pickaxe ||
    tool == @types.tool_stone_axe ||
    tool == @types.tool_stone_shovel ||
    tool == @types.tool_stone_sword {
    132
  } else if tool == @types.tool_iron_pickaxe ||
    tool == @types.tool_iron_axe ||
    tool == @types.tool_iron_shovel ||
    tool == @types.tool_iron_sword {
    250
  } else {
    100
  }
}

// Get the tier level of a tool (0=hand, 1=wood, 2=stone, 3=iron)

///|
pub fn get_tool_tier(tool : Int) -> Int {
  if tool == @types.tool_hand {
    0
  } else if tool == @types.tool_wooden_pickaxe ||
    tool == @types.tool_wooden_axe ||
    tool == @types.tool_wooden_shovel ||
    tool == @types.tool_wooden_sword {
    1
  } else if tool == @types.tool_stone_pickaxe ||
    tool == @types.tool_stone_axe ||
    tool == @types.tool_stone_shovel ||
    tool == @types.tool_stone_sword {
    2
  } else if tool == @types.tool_iron_pickaxe ||
    tool == @types.tool_iron_axe ||
    tool == @types.tool_iron_shovel ||
    tool == @types.tool_iron_sword {
    3
  } else {
    0
  }
}

// Check if a tool is a pickaxe type

///|
pub fn is_pickaxe(tool : Int) -> Bool {
  tool == @types.tool_wooden_pickaxe ||
  tool == @types.tool_stone_pickaxe ||
  tool == @types.tool_iron_pickaxe
}

// Check if a tool is an axe type

///|
pub fn is_axe(tool : Int) -> Bool {
  tool == @types.tool_wooden_axe ||
  tool == @types.tool_stone_axe ||
  tool == @types.tool_iron_axe
}

// Check if a tool is a shovel type

///|
pub fn is_shovel(tool : Int) -> Bool {
  tool == @types.tool_wooden_shovel ||
  tool == @types.tool_stone_shovel ||
  tool == @types.tool_iron_shovel
}

// Check if a tool is a sword type

///|
pub fn is_sword(tool : Int) -> Bool {
  tool == @types.tool_wooden_sword ||
  tool == @types.tool_stone_sword ||
  tool == @types.tool_iron_sword
}

// Get the best tool type for breaking a given block

///|
pub fn get_best_tool_class_for_block(block : Int) -> Int {
  // Returns: 0=any, 1=pickaxe, 2=axe, 3=shovel, 4=sword
  if block == @types.block_stone ||
    block == @types.block_cobblestone ||
    block == @types.block_ore_iron ||
    block == @types.block_ore_gold ||
    block == @types.block_ore_diamond ||
    block == @types.block_brick {
    1
  } else if block == @types.block_wood ||
    block == @types.block_planks ||
    block == @types.block_leaves {
    2
  } else if block == @types.block_dirt ||
    block == @types.block_grass ||
    block == @types.block_sand ||
    block == @types.block_gravel ||
    block == @types.block_clay ||
    block == @types.block_snow {
    3
  } else {
    0
  }
}

// Check if the equipped tool matches the best tool class for a block

///|
pub fn is_correct_tool_for_block(tool : Int, block : Int) -> Bool {
  let best_class = get_best_tool_class_for_block(block)
  if best_class == 0 {
    true
  } else if best_class == 1 {
    is_pickaxe(tool)
  } else if best_class == 2 {
    is_axe(tool)
  } else if best_class == 3 {
    is_shovel(tool)
  } else {
    false
  }
}

// Get the effective mining speed multiplier when using the correct tool

///|
pub fn get_tool_effectiveness(tool : Int, block : Int) -> Float {
  let correct = is_correct_tool_for_block(tool, block)
  let tier = get_tool_tier(tool)
  if tool == @types.tool_hand {
    1.0
  } else if correct {
    if tier == 1 {
      0.5
    } else if tier == 2 {
      0.3
    } else if tier == 3 {
      0.15
    } else {
      1.0
    }
    // Wrong tool type, still slightly faster than hand
  } else if tier == 1 {
    0.8
  } else if tier == 2 {
    0.65
  } else if tier == 3 {
    0.5
  } else {
    1.0
  }
}

// ========== Crafting recipe matching ==========

// Check if inventory has enough of a specific item

///|
pub fn count_item_in_inventory(game : @types.Game, item_id : Int) -> Int {
  let inv = game.player.inventory
  let mut total = 0
  for i in 0..<@types.inventory_slots {
    if inv.slots[i].item_id == item_id && inv.slots[i].count > 0 {
      total += inv.slots[i].count
    }
  }
  total
}

// Check if a recipe can be crafted with current inventory

///|
pub fn can_craft_recipe(
  game : @types.Game,
  recipe : @types.CraftingRecipe,
) -> Bool {
  let has_input1 : Bool = if recipe.input1_id > 0 && recipe.input1_count > 0 {
    count_item_in_inventory(game, recipe.input1_id) >= recipe.input1_count
  } else {
    true
  }
  let has_input2 : Bool = if recipe.input2_id > 0 && recipe.input2_count > 0 {
    count_item_in_inventory(game, recipe.input2_id) >= recipe.input2_count
  } else {
    true
  }
  has_input1 && has_input2
}

// Remove a specific amount of an item from inventory

///|
pub fn remove_item_from_inventory(
  game : @types.Game,
  item_id : Int,
  amount : Int,
) -> Bool {
  let inv = game.player.inventory
  let mut remaining = amount
  for i in 0..<@types.inventory_slots {
    if remaining <= 0 {
      return true
    }
    if inv.slots[i].item_id == item_id && inv.slots[i].count > 0 {
      let can_take : Int = if inv.slots[i].count < remaining {
        inv.slots[i].count
      } else {
        remaining
      }
      inv.slots[i].count -= can_take
      remaining -= can_take
      if inv.slots[i].count <= 0 {
        inv.slots[i].item_id = 0
        inv.slots[i].count = 0
      }
    }
  }
  remaining <= 0
}

// Execute a crafting recipe: consume inputs and produce outputs

///|
pub fn execute_craft(
  game : @types.Game,
  recipe : @types.CraftingRecipe,
) -> Bool {
  if not(can_craft_recipe(game, recipe)) {
    return false
  }
  // Consume input 1
  if recipe.input1_id > 0 && recipe.input1_count > 0 {
    let removed1 = remove_item_from_inventory(
      game,
      recipe.input1_id,
      recipe.input1_count,
    )
    if not(removed1) {
      return false
    }
  }
  // Consume input 2
  if recipe.input2_id > 0 && recipe.input2_count > 0 {
    let removed2 = remove_item_from_inventory(
      game,
      recipe.input2_id,
      recipe.input2_count,
    )
    if not(removed2) {
      return false
    }
  }
  // Produce output
  let leftover = game.player.inventory.add_item(
    recipe.output_id,
    recipe.output_count,
  )
  if leftover > 0 {
    @types.show_message(game, "Inventory full! Lost some items.", 2.0)
  }
  true
}

// ========== Tool equip cycling ==========

// Cycle through tools the player owns (simplified: just cycle equipped_tool)

///|
pub fn cycle_tool_forward(game : @types.Game) -> Unit {
  let mut next = game.player.equipped_tool + 1
  if next >= @types.tool_count {
    next = 0
  }
  game.player.equipped_tool = next
  let tname = @types.tool_name(next)
  @types.show_message(game, "Equipped: \{tname}", 1.5)
}

///|
pub fn cycle_tool_backward(game : @types.Game) -> Unit {
  let mut prev = game.player.equipped_tool - 1
  if prev < 0 {
    prev = @types.tool_count - 1
  }
  game.player.equipped_tool = prev
  let tname = @types.tool_name(prev)
  @types.show_message(game, "Equipped: \{tname}", 1.5)
}

// Handle tool equip keys (T to cycle, number + T for specific)

///|
pub fn handle_tool_input(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyT) {
    cycle_tool_forward(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    cycle_tool_backward(game)
  }
}

// ========== Furnace smelting logic ==========

// Smelting converts raw ores to ingots (simplified as block items)
// Iron ore -> Iron Ingot (represented as block_ore_iron processed)
// Gold ore -> Gold Ingot (represented as block_ore_gold processed)

// Get smelting result for a given input block (0 if not smeltable)

///|
pub fn get_smelting_result(input : Int) -> Int {
  if input == @types.block_sand {
    @types.block_glass
  } else if input == @types.block_cobblestone {
    @types.block_stone
  } else if input == @types.block_clay {
    @types.block_brick
  } else if input == @types.block_wood {
    // Wood -> charcoal (represented as torch ingredient)
    @types.block_torch
  } else {
    0
  }
}

// Get smelting time in seconds for a given input

///|
pub fn get_smelting_time(input : Int) -> Float {
  if input == @types.block_sand {
    8.0
  } else if input == @types.block_cobblestone {
    6.0
  } else if input == @types.block_clay {
    10.0
  } else if input == @types.block_wood {
    4.0
  } else {
    10.0
  }
}

// Check if a block is smeltable

///|
pub fn is_smeltable(block : Int) -> Bool {
  get_smelting_result(block) != 0
}

// ========== Quick-craft helpers ==========

// Find the first available recipe the player can craft

///|
pub fn find_first_craftable(game : @types.Game) -> Int {
  let recipes = @levels.get_crafting_recipes()
  for i in 0..<recipes.length() {
    if can_craft_recipe(game, recipes[i]) {
      return i
    }
  }
  -1
}

// Count how many recipes the player can currently craft

///|
pub fn count_craftable_recipes(game : @types.Game) -> Int {
  let recipes = @levels.get_crafting_recipes()
  let mut count = 0
  for i in 0..<recipes.length() {
    if can_craft_recipe(game, recipes[i]) {
      count += 1
    }
  }
  count
}

// ========== Tool crafting requirement check ==========

// Check if the player has the required tool tier to mine certain ores

///|
pub fn can_mine_with_tool(block : Int, tool : Int) -> Bool {
  let tier = get_tool_tier(tool)
  if block == @types.block_ore_diamond {
    // Need at least iron pickaxe
    tier >= 3 && is_pickaxe(tool)
  } else if block == @types.block_ore_gold {
    // Need at least iron pickaxe
    tier >= 3 && is_pickaxe(tool)
  } else if block == @types.block_ore_iron {
    // Need at least stone pickaxe
    tier >= 2 && is_pickaxe(tool)
  } else if block == @types.block_stone || block == @types.block_cobblestone {
    // Any pickaxe works, hand is very slow
    true
  } else {
    true
  }
}

// Get bonus drops when using correct tool

///|
pub fn get_bonus_drop_chance(tool : Int, block : Int) -> Float {
  let tier = get_tool_tier(tool)
  let correct = is_correct_tool_for_block(tool, block)
  if correct && tier >= 2 {
    // Stone or iron tool with correct type: chance of extra drop
    if tier == 2 {
      0.15
    } else if tier == 3 {
      0.3
    } else {
      0.0
    }
  } else {
    0.0
  }
}

// ========== Workbench interaction ==========

// When player interacts with a workbench block, open crafting UI

///|
pub fn check_workbench_interaction(game : @types.Game) -> Bool {
  let target = game.target
  if target.hit {
    let block = @types.get_world_block(game, target.bx, target.by, target.bz)
    if block == @types.block_planks {
      // Planks act as workbench
      return true
    }
  }
  false
}

// ========== Crafting category helpers ==========

// Get the category of a recipe for UI grouping

///|
pub fn get_recipe_category(recipe : @types.CraftingRecipe) -> Int {
  // 0=blocks, 1=tools, 2=materials, 3=decorations
  let out = recipe.output_id
  if out == @types.block_planks ||
    out == @types.block_cobblestone ||
    out == @types.block_stone ||
    out == @types.block_brick ||
    out == @types.block_glass {
    0
  } else if out == @types.block_torch || out == @types.block_gravel {
    3
  } else {
    2
  }
}

// Get category name

///|
pub fn recipe_category_name(cat : Int) -> String {
  if cat == 0 {
    "Blocks"
  } else if cat == 1 {
    "Tools"
  } else if cat == 2 {
    "Materials"
  } else if cat == 3 {
    "Decorations"
  } else {
    "Other"
  }
}
