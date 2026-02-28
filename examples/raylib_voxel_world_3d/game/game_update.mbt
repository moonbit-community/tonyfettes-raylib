// Main game update dispatcher

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  if game.state == @types.state_menu {
    update_menu(game, dt)
  } else if game.state == @types.state_playing {
    update_playing(game, dt)
  } else if game.state == @types.state_paused {
    update_paused(game, dt)
  } else if game.state == @types.state_inventory {
    update_inventory(game, dt)
  } else if game.state == @types.state_crafting {
    update_crafting(game, dt)
  } else if game.state == @types.state_game_over {
    update_game_over(game, dt)
  }
}

///|
fn update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_new_game(game)
    game.state = @types.state_playing
    @raylib.disable_cursor()
    @types.show_message(
      game, "WASD: Move | Space: Jump | LMB: Break | RMB: Place | E: Inventory | C: Craft",
      5.0,
    )
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_paused
    @raylib.enable_cursor()
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyE) {
    game.state = @types.state_inventory
    @raylib.enable_cursor()
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyC) {
    game.state = @types.state_crafting
    game.crafting_selection = 0
    @raylib.enable_cursor()
    return
  }
  // Toggle debug info
  if @raylib.is_key_pressed(@raylib.KeyF3) {
    game.show_debug = not(game.show_debug)
  }
  // Update game systems
  update_player(game, dt)
  update_camera_fps(game)
  update_block_target(game)
  handle_block_interaction(game, dt)
  handle_block_selection(game)
  update_day_night(game, dt)
  update_message(game, dt)
  update_entities(game, dt)
  update_particles(game, dt)
  update_hunger(game, dt)
  update_block_physics(game, dt)
  update_entity_spawning(game, dt)
  update_combat(game, dt)
  update_player_stats(game, dt)
  update_distance_tracking(game)
}

///|
fn update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.state_playing
    @raylib.disable_cursor()
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.state = @types.state_menu
    @raylib.enable_cursor()
  }
}

///|
fn update_inventory(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyE) {
    game.state = @types.state_playing
    @raylib.disable_cursor()
    return
  }
  // Number keys to select item in first row
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.player.inventory.selected = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.player.inventory.selected = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.player.inventory.selected = 2
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.player.inventory.selected = 3
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) {
    game.player.inventory.selected = 4
  }
  if @raylib.is_key_pressed(@raylib.KeySix) {
    game.player.inventory.selected = 5
  }
  if @raylib.is_key_pressed(@raylib.KeySeven) {
    game.player.inventory.selected = 6
  }
  if @raylib.is_key_pressed(@raylib.KeyEight) {
    game.player.inventory.selected = 7
  }
  if @raylib.is_key_pressed(@raylib.KeyNine) {
    game.player.inventory.selected = 8
  }
  // Update selected_block from inventory
  let sel_slot = game.player.inventory.slots[game.player.inventory.selected]
  if sel_slot.count > 0 {
    game.player.selected_block = sel_slot.item_id
  }
}

///|
fn update_crafting(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyC) {
    game.state = @types.state_playing
    @raylib.disable_cursor()
    return
  }
  let recipes = @levels.get_crafting_recipes()
  let num_recipes = recipes.length()
  // Navigate recipes with up/down or W/S
  if @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp) {
    game.crafting_selection -= 1
    if game.crafting_selection < 0 {
      game.crafting_selection = num_recipes - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyS) ||
    @raylib.is_key_pressed(@raylib.KeyDown) {
    game.crafting_selection += 1
    if game.crafting_selection >= num_recipes {
      game.crafting_selection = 0
    }
  }
  // Craft with Enter or Space
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.crafting_selection >= 0 && game.crafting_selection < num_recipes {
      try_craft(game, recipes[game.crafting_selection])
    }
  }
}

///|
fn try_craft(game : @types.Game, recipe : @types.CraftingRecipe) -> Unit {
  let inv = game.player.inventory
  // Check if player has required materials
  let mut has_input1 = false
  let mut has_input2 = false
  let mut input1_slot = -1
  let mut input2_slot = -1
  // Find input1
  if recipe.input1_id > 0 && recipe.input1_count > 0 {
    for i = 0; i < @types.inventory_slots; i = i + 1 {
      if inv.slots[i].item_id == recipe.input1_id &&
        inv.slots[i].count >= recipe.input1_count {
        has_input1 = true
        input1_slot = i
      }
    }
  } else {
    has_input1 = true
  }
  // Find input2
  if recipe.input2_id > 0 && recipe.input2_count > 0 {
    for i = 0; i < @types.inventory_slots; i = i + 1 {
      if inv.slots[i].item_id == recipe.input2_id &&
        inv.slots[i].count >= recipe.input2_count &&
        i != input1_slot {
        has_input2 = true
        input2_slot = i
      }
    }
  } else {
    has_input2 = true
  }
  if has_input1 && has_input2 {
    // Consume inputs
    if input1_slot >= 0 {
      inv.slots[input1_slot].count -= recipe.input1_count
      if inv.slots[input1_slot].count <= 0 {
        inv.slots[input1_slot].item_id = 0
        inv.slots[input1_slot].count = 0
      }
    }
    if input2_slot >= 0 {
      inv.slots[input2_slot].count -= recipe.input2_count
      if inv.slots[input2_slot].count <= 0 {
        inv.slots[input2_slot].item_id = 0
        inv.slots[input2_slot].count = 0
      }
    }
    // Add output
    let leftover = inv.add_item(recipe.output_id, recipe.output_count)
    ignore(leftover)
    @types.show_message(game, "Crafted: \{recipe.name}", 2.0)
  } else {
    @types.show_message(game, "Missing materials!", 1.5)
  }
}

///|
fn update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.death_timer += dt
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Respawn
    respawn_player(game)
    game.state = @types.state_playing
    @raylib.disable_cursor()
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.state = @types.state_menu
    @raylib.enable_cursor()
  }
}

///|
fn respawn_player(game : @types.Game) -> Unit {
  let spawn_x = Float::from_int(@types.world_chunks_x * @types.chunk_x) / 2.0
  let spawn_z = Float::from_int(@types.world_chunks_z * @types.chunk_z) / 2.0
  let height = find_surface_height(game, spawn_x.to_int(), spawn_z.to_int())
  game.player.x = spawn_x
  game.player.y = Float::from_int(height + 1) + 0.1
  game.player.z = spawn_z
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.vz = 0.0
  game.player.health = @types.player_max_health
  game.player.hunger = @types.player_max_hunger
  game.player.invulnerable_timer = @types.respawn_invulnerability
  game.player.on_ground = false
  game.player.mining_active = false
  game.player.mining_progress = 0.0
  game.respawn_count += 1
  game.death_timer = 0.0
  @types.show_message(game, "Respawned!", 2.0)
}

///|
fn start_new_game(game : @types.Game) -> Unit {
  // Reset player to spawn on terrain surface
  let spawn_x = Float::from_int(@types.world_chunks_x * @types.chunk_x) / 2.0
  let spawn_z = Float::from_int(@types.world_chunks_z * @types.chunk_z) / 2.0
  let spawn_wx = spawn_x.to_int()
  let spawn_wz = spawn_z.to_int()
  let height = find_surface_height(game, spawn_wx, spawn_wz)
  let spawn_y = Float::from_int(height + 1) + 0.1
  game.player.x = spawn_x
  game.player.y = spawn_y
  game.player.z = spawn_z
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.vz = 0.0
  game.player.yaw = 0.0
  game.player.pitch = 0.0
  game.player.on_ground = false
  game.player.sprint = false
  game.player.selected_block = @types.block_grass
  game.player.bob_timer = 0.0
  game.player.health = @types.player_max_health
  game.player.hunger = @types.player_max_hunger
  game.player.hunger_timer = 0.0
  game.player.air = @types.player_max_air
  game.player.mining_active = false
  game.player.mining_progress = 0.0
  game.player.equipped_tool = @types.tool_hand
  game.player.attack_cooldown = 0.0
  game.player.invulnerable_timer = @types.respawn_invulnerability
  game.player.damage_flash = 0.0
  game.player.fall_start_y = spawn_y
  game.player.was_on_ground = false
  game.player.underwater = false
  game.player.air_timer = 0.0
  game.player.starve_timer = 0.0
  // Reset day timer to morning
  game.day_timer = 20.0
  game.day_count = 1
  game.sky_r = 135
  game.sky_g = 206
  game.sky_b = 235
  game.sun_angle = 0.0
  game.is_night = false
  game.target.hit = false
  game.message_timer = 0.0
  game.message_text = ""
  game.show_debug = false
  game.frame_counter = 0
  // Reset entities
  for i = 0; i < @types.entity_max; i = i + 1 {
    game.entities[i].active = false
  }
  // Reset particles
  for i = 0; i < @types.particle_max; i = i + 1 {
    game.particles[i].active = false
  }
  // Reset stats
  game.blocks_broken = 0
  game.blocks_placed = 0
  game.mobs_killed = 0
  game.distance_walked = 0.0
  game.prev_pos_x = spawn_x
  game.prev_pos_z = spawn_z
  game.death_timer = 0.0
  game.respawn_count = 0
  game.entity_spawn_timer = 5.0
  game.gravity_block_timer = 0.0
  game.water_spread_timer = 0.0
  game.crafting_selection = 0
}

///|
fn find_surface_height(game : @types.Game, wx : Int, wz : Int) -> Int {
  for y = @types.chunk_y - 1; y >= 0; y = y - 1 {
    let block = @types.get_world_block(game, wx, y, wz)
    if @types.is_solid(block) {
      return y
    }
  }
  0
}

// ========== Hunger system ==========

///|
fn update_hunger(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  let drain_rate : Float = if player.sprint {
    @types.hunger_sprint_drain
  } else {
    @types.hunger_drain_rate
  }
  player.hunger_timer += drain_rate * dt
  if player.hunger_timer >= 1.0 {
    player.hunger_timer -= 1.0
    if player.hunger > 0 {
      player.hunger -= 1
    }
  }
  // Heal if hunger is high
  if player.hunger >= @types.hunger_heal_threshold &&
    player.health < @types.player_max_health {
    // Slow healing
    if game.frame_counter % 60 == 0 {
      player.health += 1
      if player.health > @types.player_max_health {
        player.health = @types.player_max_health
      }
    }
  }
  // Starve if hunger is zero
  if player.hunger <= @types.hunger_starve_threshold {
    player.starve_timer += dt
    if player.starve_timer >= @types.starve_damage_interval {
      player.starve_timer -= @types.starve_damage_interval
      damage_player(game, 1)
    }
  } else {
    player.starve_timer = 0.0
  }
}

// ========== Player stat updates (invulnerability, damage flash, fall damage) ==========

///|
fn update_player_stats(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  // Update invulnerability
  if player.invulnerable_timer > 0.0 {
    player.invulnerable_timer -= dt
    if player.invulnerable_timer < 0.0 {
      player.invulnerable_timer = 0.0
    }
  }
  // Update damage flash
  if player.damage_flash > 0.0 {
    player.damage_flash -= dt * 3.0
    if player.damage_flash < 0.0 {
      player.damage_flash = 0.0
    }
  }
  // Update attack cooldown
  if player.attack_cooldown > 0.0 {
    player.attack_cooldown -= dt
    if player.attack_cooldown < 0.0 {
      player.attack_cooldown = 0.0
    }
  }
  // Fall damage
  if player.on_ground && not(player.was_on_ground) {
    let fall_dist = player.fall_start_y - player.y
    if fall_dist > @types.fall_damage_threshold {
      let damage = ((fall_dist - @types.fall_damage_threshold) *
      @types.fall_damage_multiplier).to_int()
      if damage > 0 {
        damage_player(game, damage)
        @types.show_message(game, "Ouch! Fall damage!", 1.5)
      }
    }
  }
  if not(player.on_ground) && player.was_on_ground {
    player.fall_start_y = player.y
  }
  player.was_on_ground = player.on_ground
  // Underwater check
  let head_y = (player.y + @types.player_eye_height).to_int()
  let head_block = @types.get_world_block(
    game,
    player.x.to_int(),
    head_y,
    player.z.to_int(),
  )
  player.underwater = head_block == @types.block_water
  if player.underwater {
    player.air_timer += dt
    if player.air_timer >= 1.0 {
      player.air_timer -= 1.0
      player.air -= 1
      if player.air < 0 {
        player.air = 0
        damage_player(game, 2)
      }
    }
  } else {
    player.air = @types.player_max_air
    player.air_timer = 0.0
  }
}

///|
pub fn damage_player(game : @types.Game, amount : Int) -> Unit {
  let player = game.player
  if player.invulnerable_timer > 0.0 {
    return
  }
  player.health -= amount
  player.damage_flash = 1.0
  player.invulnerable_timer = 0.5
  if player.health <= 0 {
    player.health = 0
    game.state = @types.state_game_over
    game.death_timer = 0.0
    @raylib.enable_cursor()
  }
}

// ========== Distance tracking ==========

///|
fn update_distance_tracking(game : @types.Game) -> Unit {
  let dx = game.player.x - game.prev_pos_x
  let dz = game.player.z - game.prev_pos_z
  let dist = (dx * dx + dz * dz).sqrt()
  if dist > 0.01 && dist < 10.0 {
    game.distance_walked += dist
  }
  game.prev_pos_x = game.player.x
  game.prev_pos_z = game.player.z
}

// ========== Block physics (sand/gravel falling) ==========

///|
fn update_block_physics(game : @types.Game, dt : Float) -> Unit {
  game.gravity_block_timer += dt
  if game.gravity_block_timer < @types.gravity_block_interval {
    return
  }
  game.gravity_block_timer -= @types.gravity_block_interval
  // Check blocks near player for gravity
  let pcx = game.player.x.to_int()
  let pcz = game.player.z.to_int()
  let pcy = game.player.y.to_int()
  let check_radius = 16
  let min_x = @types.maxi(0, pcx - check_radius)
  let max_x = @types.mini(
    @types.world_chunks_x * @types.chunk_x - 1,
    pcx + check_radius,
  )
  let min_z = @types.maxi(0, pcz - check_radius)
  let max_z = @types.mini(
    @types.world_chunks_z * @types.chunk_z - 1,
    pcz + check_radius,
  )
  let min_y = @types.maxi(1, pcy - 10)
  let max_y = @types.mini(@types.chunk_y - 1, pcy + 10)
  for wy = min_y; wy <= max_y; wy = wy + 1 {
    for wz = min_z; wz <= max_z; wz = wz + 1 {
      for wx = min_x; wx <= max_x; wx = wx + 1 {
        let block = @types.get_world_block(game, wx, wy, wz)
        if @types.is_gravity_block(block) {
          let below = @types.get_world_block(game, wx, wy - 1, wz)
          if not(@types.is_solid(below)) && below != @types.block_water {
            // Block falls one step
            @types.set_world_block(game, wx, wy, wz, @types.block_air)
            @types.set_world_block(game, wx, wy - 1, wz, block)
          }
        }
      }
    }
  }
}

// ========== Particle update ==========

///|
fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < @types.particle_max; i = i + 1 {
    let p = game.particles[i]
    if p.active {
      p.x += p.vx * dt
      p.y += p.vy * dt
      p.z += p.vz * dt
      p.vy -= @types.particle_gravity * dt
      p.lifetime -= dt
      p.size *= 0.98
      if p.lifetime <= 0.0 {
        p.active = false
      }
    }
  }
}

// ========== Combat system ==========

///|
fn update_combat(game : @types.Game, dt : Float) -> Unit {
  ignore(dt)
  // Check for entity attacks on player
  let player = game.player
  for i = 0; i < @types.entity_max; i = i + 1 {
    let ent = game.entities[i]
    if ent.active &&
      @types.is_hostile(ent.kind) &&
      ent.ai_state == @types.ai_attack {
      if ent.attack_cooldown <= 0.0 {
        let dist = @types.distance3d(
          ent.x,
          ent.y,
          ent.z,
          player.x,
          player.y,
          player.z,
        )
        if dist < @types.entity_attack_range {
          let dmg = if ent.kind == @types.entity_zombie {
            @types.zombie_damage
          } else if ent.kind == @types.entity_skeleton {
            @types.skeleton_damage
          } else if ent.kind == @types.entity_spider {
            @types.spider_damage
          } else {
            1
          }
          damage_player(game, dmg)
          ent.attack_cooldown = 1.5
          // Knockback
          let dx = player.x - ent.x
          let dz = player.z - ent.z
          let dl = (dx * dx + dz * dz).sqrt()
          if dl > 0.01 {
            player.vx += dx / dl * 5.0
            player.vz += dz / dl * 5.0
            player.vy += 3.0
          }
        }
      }
    }
  }
  // Player attack on entity with left click
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
    player.attack_cooldown <= 0.0 {
    let target = game.target
    // Check entities near crosshair
    let cos_yaw = @math.cosf(player.yaw)
    let sin_yaw = @math.sinf(player.yaw)
    let cos_pitch = @math.cosf(player.pitch)
    let sin_pitch = @math.sinf(player.pitch)
    let look_x = sin_yaw * cos_pitch
    let look_y = sin_pitch
    let look_z = cos_yaw * cos_pitch
    let mut closest_ent = -1
    let mut closest_dist : Float = @types.reach_distance + 1.0
    for i = 0; i < @types.entity_max; i = i + 1 {
      let ent = game.entities[i]
      if ent.active {
        // Simple dot product test to see if entity is near look direction
        let to_x = ent.x - game.cam_pos_x
        let to_y = ent.y + 0.5 - game.cam_pos_y
        let to_z = ent.z - game.cam_pos_z
        let dist = (to_x * to_x + to_y * to_y + to_z * to_z).sqrt()
        if dist < @types.reach_distance && dist > 0.1 {
          let nx = to_x / dist
          let ny = to_y / dist
          let nz = to_z / dist
          let dot = nx * look_x + ny * look_y + nz * look_z
          if dot > 0.85 {
            if dist < closest_dist {
              closest_dist = dist
              closest_ent = i
            }
          }
        }
      }
    }
    if closest_ent >= 0 {
      // Hit this entity instead of breaking a block
      let ent = game.entities[closest_ent]
      let dmg = @levels.get_weapon_damage(player.equipped_tool)
      ent.health -= dmg
      ent.damage_flash = 0.5
      player.attack_cooldown = 0.4
      // Knockback on entity
      let dx = ent.x - player.x
      let dz = ent.z - player.z
      let dl = (dx * dx + dz * dz).sqrt()
      if dl > 0.01 {
        ent.vx += dx / dl * 6.0
        ent.vy += 3.0
        ent.vz += dz / dl * 6.0
      }
      // Hostile entities become aggressive
      if @types.is_hostile(ent.kind) {
        ent.ai_state = @types.ai_chase
        ent.target_x = player.x
        ent.target_z = player.z
      } else {
        // Passive entities flee
        ent.ai_state = @types.ai_flee
        ent.ai_timer = 5.0
        ent.target_x = ent.x + (ent.x - player.x) * 2.0
        ent.target_z = ent.z + (ent.z - player.z) * 2.0
      }
      if ent.health <= 0 {
        ent.active = false
        game.mobs_killed += 1
        @types.show_message(
          game,
          "Killed \{@types.entity_name(ent.kind)}!",
          1.5,
        )
        // Drop food items (add to inventory)
        if ent.kind == @types.entity_pig || ent.kind == @types.entity_cow {
          // Restore hunger
          game.player.hunger += 4
          if game.player.hunger > @types.player_max_hunger {
            game.player.hunger = @types.player_max_hunger
          }
          @types.show_message(game, "Got food! Hunger restored.", 2.0)
        }
      }
      // Prevent block breaking on the same click
      ignore(target)
    }
  }
}
