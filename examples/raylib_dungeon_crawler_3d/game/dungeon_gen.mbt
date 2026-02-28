// BSP-style dungeon generation

///|
pub fn generate_dungeon(game : @types.Game) -> Unit {
  // Clear all tiles to wall
  for i in 0..<@types.grid_total {
    game.tiles[i] = @types.tile_wall
    game.explored[i] = false
  }
  // Clear entities
  for i in 0..<game.enemies.length() {
    game.enemies[i].active = false
  }
  for i in 0..<game.projectiles.length() {
    game.projectiles[i].active = false
  }
  for i in 0..<game.particles.length() {
    game.particles[i].active = false
  }
  for i in 0..<game.loot.length() {
    game.loot[i].active = false
  }
  for i in 0..<game.traps.length() {
    game.traps[i].active = false
  }
  for i in 0..<game.torches.length() {
    game.torches[i].active = false
  }
  // Set floor theme
  game.floor_theme = @levels.get_floor_theme(game.current_floor)
  // Reset shrine used for this floor
  game.shrine_used = false
  // Get floor config
  let config = @levels.get_floor_config(game.current_floor)
  let num_rooms = config.0
  // Generate rooms
  game.room_count = 0
  for i in 0..<num_rooms {
    try_place_room(game)
    ignore(i)
  }
  // Ensure at least 2 rooms
  if game.room_count < 2 {
    // Force place rooms
    let r0 = @types.Room::new(2, 2, 6, 6)
    carve_room(game, r0)
    game.rooms[0] = r0
    let r1 = @types.Room::new(20, 20, 6, 6)
    carve_room(game, r1)
    game.rooms[1] = r1
    game.room_count = 2
  }
  // Connect rooms with corridors
  for i in 1..<game.room_count {
    let r0 = game.rooms[i - 1]
    let r1 = game.rooms[i]
    carve_corridor(
      game,
      r0.center_x(),
      r0.center_y(),
      r1.center_x(),
      r1.center_y(),
    )
  }
  // Assign room types
  assign_room_types(game)
  // Place player in first room
  let start_room = game.rooms[0]
  game.player_x = @types.grid_to_world_x(start_room.center_x())
  game.player_z = @types.grid_to_world_z(start_room.center_y())
  // Place stairs in last room
  let last_room = game.rooms[game.room_count - 1]
  game.stairs_x = last_room.center_x()
  game.stairs_z = last_room.center_y()
  @types.set_tile(game, game.stairs_x, game.stairs_z, @types.tile_stairs)
  // Place enemies (basic + extended)
  place_enemies(game)
  place_extended_enemies(game)
  // Place loot
  place_loot(game)
  // Place some doors at corridor entrances
  place_doors(game)
  // Place locked doors
  place_locked_doors(game)
  // Place chests
  place_chests(game)
  // Place traps
  place_traps(game)
  // Place torches
  place_torches(game)
  // Place shop if applicable
  if @levels.floor_has_shop(game.current_floor) {
    place_shop(game)
  }
  // Place shrine if applicable
  if @levels.floor_has_shrine(game.current_floor) {
    place_shrine(game)
  }
  // Update explored around player
  @types.update_explored(game)
}

///|
fn try_place_room(game : @types.Game) -> Unit {
  if game.room_count >= @types.max_rooms {
    return
  }
  // Try multiple times to find a non-overlapping room
  for attempt in 0..<20 {
    let w = @types.rand_range(game, @types.min_room_size, @types.max_room_size)
    let h = @types.rand_range(game, @types.min_room_size, @types.max_room_size)
    let x = @types.rand_range(game, 1, @types.grid_w - w - 1)
    let y = @types.rand_range(game, 1, @types.grid_h - h - 1)
    // Check for overlap with existing rooms (with margin)
    let mut overlap = false
    for i in 0..<game.room_count {
      let r = game.rooms[i]
      if x < r.x + r.w + 2 &&
        x + w + 2 > r.x &&
        y < r.y + r.h + 2 &&
        y + h + 2 > r.y {
        overlap = true
      }
    }
    if not(overlap) {
      let room = @types.Room::new(x, y, w, h)
      carve_room(game, room)
      game.rooms[game.room_count] = room
      game.room_count += 1
      return
    }
    ignore(attempt)
  }
}

///|
fn carve_room(game : @types.Game, room : @types.Room) -> Unit {
  for gy in room.y..<(room.y + room.h) {
    for gx in room.x..<(room.x + room.w) {
      @types.set_tile(game, gx, gy, @types.tile_floor)
    }
  }
}

///|
fn carve_corridor(
  game : @types.Game,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> Unit {
  let mut cx = x1
  let mut cy = y1
  // Go horizontal first, then vertical
  while cx != x2 {
    for dw in 0..=@types.corridor_width {
      @types.set_tile(game, cx, cy + dw, @types.tile_floor)
      if cy - dw >= 0 {
        @types.set_tile(game, cx, cy, @types.tile_floor)
      }
    }
    if cx < x2 {
      cx += 1
    } else {
      cx -= 1
    }
  }
  while cy != y2 {
    for dw in 0..=@types.corridor_width {
      @types.set_tile(game, cx + dw, cy, @types.tile_floor)
      if cx - dw >= 0 {
        @types.set_tile(game, cx, cy, @types.tile_floor)
      }
    }
    if cy < y2 {
      cy += 1
    } else {
      cy -= 1
    }
  }
}

///|
fn assign_room_types(game : @types.Game) -> Unit {
  // First room is always normal (player start)
  game.rooms[0].kind = @types.room_normal
  // Last room: boss or normal
  let config = @levels.get_floor_config(game.current_floor)
  let has_boss = config.5
  if has_boss {
    game.rooms[game.room_count - 1].kind = @types.room_boss
  }
  // Assign treasure room to a middle room
  if game.room_count > 3 {
    let tr_idx = @types.rand_range(game, 1, game.room_count - 2)
    game.rooms[tr_idx].kind = @types.room_treasure
  }
}

///|
fn place_enemies(game : @types.Game) -> Unit {
  let config = @levels.get_floor_config(game.current_floor)
  let num_skeletons = config.1
  let num_archers = config.2
  let num_golems = config.3
  let num_wraiths = config.4
  let has_boss = config.5
  let hp_scale = @levels.get_enemy_hp_scale(game.current_floor)
  let atk_scale = @levels.get_enemy_atk_scale(game.current_floor)
  let def_scale = @levels.get_enemy_def_scale(game.current_floor)
  let mut total_spawned = 0
  // Place skeletons
  for i in 0..<num_skeletons {
    spawn_enemy_in_room(
      game,
      @types.enemy_skeleton,
      20 + hp_scale,
      5 + atk_scale,
      2 + def_scale,
      @types.xp_per_skeleton,
    )
    total_spawned += 1
    ignore(i)
  }
  // Place archers
  for i in 0..<num_archers {
    spawn_enemy_in_room(
      game,
      @types.enemy_archer,
      15 + hp_scale,
      4 + atk_scale,
      1 + def_scale,
      @types.xp_per_archer,
    )
    total_spawned += 1
    ignore(i)
  }
  // Place golems
  for i in 0..<num_golems {
    spawn_enemy_in_room(
      game,
      @types.enemy_golem,
      50 + hp_scale * 2,
      8 + atk_scale,
      5 + def_scale * 2,
      @types.xp_per_golem,
    )
    total_spawned += 1
    ignore(i)
  }
  // Place wraiths
  for i in 0..<num_wraiths {
    spawn_enemy_in_room(
      game,
      @types.enemy_wraith,
      18 + hp_scale,
      6 + atk_scale,
      1 + def_scale,
      @types.xp_per_wraith,
    )
    total_spawned += 1
    ignore(i)
  }
  // Place boss in last room
  if has_boss {
    let last_room = game.rooms[game.room_count - 1]
    let wx = @types.grid_to_world_x(last_room.center_x() + 2)
    let wz = @types.grid_to_world_z(last_room.center_y())
    let idx = @types.alloc_enemy(game)
    if idx >= 0 {
      let e = game.enemies[idx]
      e.active = true
      e.kind = @types.enemy_dragon_boss
      e.x = wx
      e.z = wz
      e.hp = @levels.get_boss_hp(game.current_floor)
      e.max_hp = e.hp
      e.atk = @levels.get_boss_atk(game.current_floor)
      e.def = @levels.get_boss_def(game.current_floor)
      e.attack_timer = 0.0
      e.move_timer = 0.0
      e.alerted = false
      e.hit_flash = 0.0
      e.ai_state = @types.ai_idle
      e.xp_value = @types.xp_per_dragon
      e.speed_mult = 1.0
      total_spawned += 1
    }
  }
  // Update floor info
  game.floor_info[game.current_floor].enemies_total = total_spawned
  game.floor_info[game.current_floor].enemies_killed = 0
}

///|
fn place_extended_enemies(game : @types.Game) -> Unit {
  let ext = @levels.get_extended_enemy_config(game.current_floor)
  let num_slimes = ext.0
  let num_bats = ext.1
  let num_spiders = ext.2
  let num_minotaurs = ext.3
  let num_lichs = ext.4
  let hp_scale = @levels.get_enemy_hp_scale(game.current_floor)
  let atk_scale = @levels.get_enemy_atk_scale(game.current_floor)
  let def_scale = @levels.get_enemy_def_scale(game.current_floor)
  let mut extra = 0
  // Place slimes
  for i in 0..<num_slimes {
    spawn_enemy_in_room(
      game,
      @types.enemy_slime,
      12 + hp_scale,
      3 + atk_scale,
      0 + def_scale,
      @types.xp_per_slime,
    )
    extra += 1
    ignore(i)
  }
  // Place bats
  for i in 0..<num_bats {
    spawn_enemy_in_room(
      game,
      @types.enemy_bat,
      8 + hp_scale / 2,
      4 + atk_scale,
      0,
      @types.xp_per_bat,
    )
    extra += 1
    ignore(i)
  }
  // Place spiders
  for i in 0..<num_spiders {
    spawn_enemy_in_room(
      game,
      @types.enemy_spider,
      16 + hp_scale,
      6 + atk_scale,
      2 + def_scale,
      @types.xp_per_spider,
    )
    extra += 1
    ignore(i)
  }
  // Place minotaurs
  for i in 0..<num_minotaurs {
    spawn_enemy_in_room(
      game,
      @types.enemy_minotaur,
      45 + hp_scale * 2,
      10 + atk_scale,
      4 + def_scale * 2,
      @types.xp_per_minotaur,
    )
    extra += 1
    ignore(i)
  }
  // Place lichs
  for i in 0..<num_lichs {
    spawn_enemy_in_room(
      game,
      @types.enemy_lich,
      30 + hp_scale,
      8 + atk_scale * 2,
      3 + def_scale,
      @types.xp_per_lich,
    )
    extra += 1
    ignore(i)
  }
  game.floor_info[game.current_floor].enemies_total += extra
}

///|
fn spawn_enemy_in_room(
  game : @types.Game,
  kind : Int,
  hp : Int,
  atk : Int,
  def : Int,
  xp_value : Int,
) -> Unit {
  let idx = @types.alloc_enemy(game)
  if idx < 0 {
    return
  }
  // Pick a random room (not the first one where player spawns)
  let room_idx = if game.room_count > 1 {
    @types.rand_range(game, 1, game.room_count - 1)
  } else {
    0
  }
  let room = game.rooms[room_idx]
  let gx = @types.rand_range(game, room.x + 1, room.x + room.w - 2)
  let gy = @types.rand_range(game, room.y + 1, room.y + room.h - 2)
  let e = game.enemies[idx]
  e.active = true
  e.kind = kind
  e.x = @types.grid_to_world_x(gx)
  e.z = @types.grid_to_world_z(gy)
  e.hp = hp
  e.max_hp = hp
  e.atk = atk
  e.def = def
  e.attack_timer = 0.0
  e.move_timer = 0.0
  e.alerted = false
  e.hit_flash = 0.0
  e.ai_state = @types.ai_idle
  e.patrol_x = e.x
  e.patrol_z = e.z
  e.speed_mult = 1.0
  e.ability_cooldown = 0.0
  e.stun_timer = 0.0
  e.slow_timer = 0.0
  e.xp_value = xp_value
  e.facing_angle = @types.rand_rangef(game, 0.0, 6.28)
}

///|
fn place_loot(game : @types.Game) -> Unit {
  let config = @levels.get_floor_config(game.current_floor)
  let num_loot = config.6
  for i in 0..<num_loot {
    let idx = @types.alloc_loot(game)
    if idx < 0 {
      return
    }
    // Pick a random room
    let room_idx = @types.rand_range(game, 0, game.room_count - 1)
    let room = game.rooms[room_idx]
    let gx = @types.rand_range(game, room.x + 1, room.x + room.w - 2)
    let gy = @types.rand_range(game, room.y + 1, room.y + room.h - 2)
    let l = game.loot[idx]
    l.active = true
    // Determine rarity
    let rarity_weights : Array[Int] = [
      @levels.get_rarity_weight_common(game.current_floor),
      @levels.get_rarity_weight_uncommon(game.current_floor),
      @levels.get_rarity_weight_rare(game.current_floor),
      @levels.get_rarity_weight_epic(game.current_floor),
      @levels.get_rarity_weight_legendary(game.current_floor),
    ]
    l.rarity = @types.rand_weighted(game, rarity_weights)
    // Random loot type - expanded with new types
    let roll = @types.rand_range(game, 0, 7)
    if roll == 0 {
      l.kind = @types.loot_health_potion
    } else if roll == 1 {
      l.kind = @types.loot_damage_boost
    } else if roll == 2 {
      l.kind = @types.loot_armor
    } else if roll == 3 {
      l.kind = @types.loot_mana_potion
    } else if roll == 4 {
      l.kind = @types.loot_gold_pile
      l.value = @types.rand_range(
        game, @types.gold_pile_min, @types.gold_pile_max,
      )
    } else if roll == 5 {
      l.kind = @types.loot_speed_potion
    } else if roll == 6 {
      l.kind = @types.loot_strength_potion
    } else {
      l.kind = @types.loot_gold_pile
      l.value = @types.rand_range(
        game,
        @types.gold_pile_min + 10,
        @types.gold_pile_max + 20,
      )
    }
    l.x = @types.grid_to_world_x(gx)
    l.z = @types.grid_to_world_z(gy)
    l.bob_phase = @types.rand_rangef(game, 0.0, 6.28)
    ignore(i)
  }
}

///|
fn place_doors(game : @types.Game) -> Unit {
  // Scan for corridor-like passages and place occasional doors
  for gy in 2..<(@types.grid_h - 2) {
    for gx in 2..<(@types.grid_w - 2) {
      if @types.get_tile(game, gx, gy) != @types.tile_floor {
        continue
      }
      // Horizontal doorway: walls above and below, floor left and right
      let is_h_door = @types.get_tile(game, gx, gy - 1) == @types.tile_wall &&
        @types.get_tile(game, gx, gy + 1) == @types.tile_wall &&
        @types.get_tile(game, gx - 1, gy) == @types.tile_floor &&
        @types.get_tile(game, gx + 1, gy) == @types.tile_floor
      // Vertical doorway: walls left and right, floor above and below
      let is_v_door = @types.get_tile(game, gx - 1, gy) == @types.tile_wall &&
        @types.get_tile(game, gx + 1, gy) == @types.tile_wall &&
        @types.get_tile(game, gx, gy - 1) == @types.tile_floor &&
        @types.get_tile(game, gx, gy + 1) == @types.tile_floor
      if is_h_door || is_v_door {
        // 30% chance to place a door
        if @types.rand_range(game, 0, 99) < 30 {
          @types.set_tile(game, gx, gy, @types.tile_door)
        }
      }
    }
  }
}

///|
fn place_locked_doors(game : @types.Game) -> Unit {
  let num_locked = @levels.get_locked_door_count(game.current_floor)
  if num_locked == 0 {
    return
  }
  let mut placed = 0
  // Try to place locked doors at corridor entrances between rooms
  for gy in 2..<(@types.grid_h - 2) {
    for gx in 2..<(@types.grid_w - 2) {
      if placed >= num_locked {
        return
      }
      if @types.get_tile(game, gx, gy) != @types.tile_door {
        continue
      }
      // Convert some regular doors to locked doors (50% chance)
      if @types.rand_range(game, 0, 99) < 50 {
        @types.set_tile(game, gx, gy, @types.tile_locked_door)
        placed += 1
        // Also place a key somewhere
        let key_idx = @types.alloc_loot(game)
        if key_idx >= 0 {
          let room_idx = @types.rand_range(game, 0, game.room_count - 1)
          let room = game.rooms[room_idx]
          let kx = @types.rand_range(game, room.x + 1, room.x + room.w - 2)
          let ky = @types.rand_range(game, room.y + 1, room.y + room.h - 2)
          let lk = game.loot[key_idx]
          lk.active = true
          lk.kind = @types.loot_key
          lk.x = @types.grid_to_world_x(kx)
          lk.z = @types.grid_to_world_z(ky)
          lk.bob_phase = @types.rand_rangef(game, 0.0, 6.28)
          lk.rarity = @types.rarity_uncommon
          lk.value = 0
        }
      }
    }
  }
}

///|
fn place_chests(game : @types.Game) -> Unit {
  // Place 1-3 chests in random rooms
  let num_chests = @types.rand_range(game, 1, 3)
  for i in 0..<num_chests {
    let room_idx = @types.rand_range(game, 0, game.room_count - 1)
    let room = game.rooms[room_idx]
    // Place chest near a wall in the room
    let gx = @types.rand_range(game, room.x + 1, room.x + room.w - 2)
    let gy = room.y + room.h - 1 // near bottom wall
    if @types.get_tile(game, gx, gy) == @types.tile_floor {
      @types.set_tile(game, gx, gy, @types.tile_chest)
    }
    ignore(i)
  }
  // Maybe place a mimic (10% chance per chest, only after floor 3)
  if game.current_floor >= 3 {
    for _try in 0..<1 {
      if @types.rand_range(game, 0, 99) < 15 {
        // Find a chest tile and put a mimic near it
        let room_idx = @types.rand_range(game, 1, game.room_count - 1)
        let room = game.rooms[room_idx]
        let gx = @types.rand_range(game, room.x + 1, room.x + room.w - 2)
        let gy = @types.rand_range(game, room.y + 1, room.y + room.h - 2)
        if @types.get_tile(game, gx, gy) == @types.tile_floor {
          @types.set_tile(game, gx, gy, @types.tile_chest)
          // Spawn a mimic enemy here that activates when player interacts
          let idx = @types.alloc_enemy(game)
          if idx >= 0 {
            let e = game.enemies[idx]
            e.active = true
            e.kind = @types.enemy_mimic
            e.x = @types.grid_to_world_x(gx)
            e.z = @types.grid_to_world_z(gy)
            let hp_s = @levels.get_enemy_hp_scale(game.current_floor)
            let atk_s = @levels.get_enemy_atk_scale(game.current_floor)
            let def_s = @levels.get_enemy_def_scale(game.current_floor)
            e.hp = 25 + hp_s
            e.max_hp = e.hp
            e.atk = 7 + atk_s
            e.def = 3 + def_s
            e.attack_timer = 0.0
            e.move_timer = 0.0
            e.alerted = false
            e.hit_flash = 0.0
            e.ai_state = @types.ai_idle
            e.xp_value = @types.xp_per_mimic
            e.speed_mult = 1.0
            game.floor_info[game.current_floor].enemies_total += 1
          }
        }
      }
    }
  }
}

///|
fn place_traps(game : @types.Game) -> Unit {
  let num_traps = @levels.get_floor_trap_count(game.current_floor)
  for i in 0..<num_traps {
    let idx = @types.alloc_trap(game)
    if idx < 0 {
      return
    }
    // Pick a random room (not the first)
    let room_idx = if game.room_count > 1 {
      @types.rand_range(game, 1, game.room_count - 1)
    } else {
      0
    }
    let room = game.rooms[room_idx]
    let gx = @types.rand_range(game, room.x + 1, room.x + room.w - 2)
    let gy = @types.rand_range(game, room.y + 1, room.y + room.h - 2)
    if @types.get_tile(game, gx, gy) == @types.tile_floor {
      @types.set_tile(game, gx, gy, @types.tile_trap)
      let trap = game.traps[idx]
      trap.active = true
      trap.kind = @levels.get_available_trap_type(
        game.current_floor,
        @types.rand_next(game),
      )
      trap.gx = gx
      trap.gz = gy
      trap.armed = true
      trap.cooldown = 0.0
      trap.triggered = false
      trap.visible = false
    }
    ignore(i)
  }
}

///|
fn place_torches(game : @types.Game) -> Unit {
  let torches_per_room = @levels.get_torches_per_room(game.floor_theme)
  for r in 0..<game.room_count {
    let room = game.rooms[r]
    for t in 0..<torches_per_room {
      let idx = @types.alloc_torch(game)
      if idx < 0 {
        return
      }
      // Place torch on a wall adjacent to the room
      let side = @types.rand_range(game, 0, 3)
      let mut gx = 0
      let mut gz = 0
      if side == 0 {
        // Top wall
        gx = @types.rand_range(game, room.x, room.x + room.w - 1)
        gz = room.y - 1
      } else if side == 1 {
        // Bottom wall
        gx = @types.rand_range(game, room.x, room.x + room.w - 1)
        gz = room.y + room.h
      } else if side == 2 {
        // Left wall
        gx = room.x - 1
        gz = @types.rand_range(game, room.y, room.y + room.h - 1)
      } else {
        // Right wall
        gx = room.x + room.w
        gz = @types.rand_range(game, room.y, room.y + room.h - 1)
      }
      if @types.in_bounds(gx, gz) &&
        @types.get_tile(game, gx, gz) == @types.tile_wall {
        let torch = game.torches[idx]
        torch.active = true
        torch.gx = gx
        torch.gz = gz
        torch.flicker_phase = @types.rand_rangef(game, 0.0, 6.28)
      }
      ignore(t)
    }
  }
}

///|
fn place_shop(game : @types.Game) -> Unit {
  // Place shop in a middle room
  if game.room_count <= 2 {
    return
  }
  let shop_idx = @types.rand_range(game, 1, game.room_count - 2)
  let room = game.rooms[shop_idx]
  room.kind = @types.room_shop
  // Mark shop tile
  let sx = room.center_x()
  let sy = room.center_y()
  @types.set_tile(game, sx, sy, @types.tile_shop)
  // Generate shop items
  for i in 0..<@types.max_shop_items {
    game.shop_items[i].active = true
    game.shop_items[i].kind = @levels.get_shop_item_type(i)
    game.shop_items[i].price = @levels.get_shop_item_price(i)
    game.shop_items[i].name_idx = i
    game.shop_items[i].stat_bonus = 0
  }
}

///|
fn place_shrine(game : @types.Game) -> Unit {
  // Place shrine in a middle room
  if game.room_count <= 2 {
    return
  }
  let shrine_idx = @types.rand_range(game, 1, game.room_count - 2)
  let room = game.rooms[shrine_idx]
  // Don't overlap with shop
  if room.kind == @types.room_shop {
    return
  }
  room.kind = @types.room_shrine
  // Mark shrine tile
  let sx = room.center_x()
  let sy = room.center_y()
  @types.set_tile(game, sx, sy, @types.tile_shrine)
  // Generate shrine options
  game.shrine_options[0] = 0 // HP bonus
  game.shrine_options[1] = 1 // Mana bonus
  game.shrine_options[2] = 2 // ATK bonus
  game.shrine_used = false
}
