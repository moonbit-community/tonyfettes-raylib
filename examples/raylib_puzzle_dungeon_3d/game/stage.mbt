// Stage/floor loading and undo system

///|
pub fn load_floor(game : @types.Game, floor : Int) -> Unit {
  game.current_floor = floor
  game.current_world = @types.get_world_for_floor(floor)
  game.moves = 0
  game.keys_held = 0
  game.diamonds_collected = 0
  game.diamonds_total = 0
  game.plates_active = 0
  game.plates_total = 0
  game.exit_open = false
  game.undo_count = 0
  game.player_moving = false
  game.player_anim_timer = 0.0
  game.player_walk_cycle = 0.0
  game.player_push_anim = 0.0
  game.level_timer = 0.0
  game.used_undo = false
  game.spike_timer = 0.0
  game.spike_phase = false
  game.conveyor_moved_this_turn = false
  game.gate_anim_timer = 0.0
  game.gate_opening = false
  game.laser_segment_count = 0
  game.laser_targets_hit = 0
  game.laser_targets_total = 0
  // Clear entities
  for i in 0..<game.entities.length() {
    game.entities[i] = @types.Entity::inactive()
  }
  // Clear particles
  for i in 0..<game.particles.length() {
    game.particles[i] = @types.Particle::inactive()
  }
  // Clear laser segments
  for i in 0..<@types.max_laser_segments {
    game.laser_segments[i].active = false
  }
  // Clear decorations
  for i in 0..<@types.max_decorations {
    game.decorations[i].active = false
  }
  game.decoration_count = 0
  // Load level data
  let data = @levels.get_floor_data(floor)
  let mut entity_count = 0
  for gy in 0..<@types.grid_h {
    if gy >= data.length() {
      // Fill rest with walls
      for gx in 0..<@types.grid_w {
        @types.set_tile(game, gx, gy, @types.tile_wall)
      }
      continue
    }
    let row = data[gy]
    let row_bytes = @utf8.encode(row)
    for gx in 0..<@types.grid_w {
      let ch : Byte = if gx < row_bytes.length() { row_bytes[gx] } else { b'#' }
      let result = parse_tile_char(ch, gx, gy)
      @types.set_tile(game, gx, gy, result.0)
      if result.1 >= 0 && entity_count < @types.max_entities {
        // Spawn entity
        if result.1 == @types.entity_block {
          game.entities[entity_count] = @types.Entity::new_block(gx, gy)
        } else if result.1 == @types.entity_diamond {
          game.entities[entity_count] = @types.Entity::new_diamond(gx, gy)
        } else if result.1 == @types.entity_key {
          game.entities[entity_count] = @types.Entity::new_key(gx, gy)
        }
        entity_count += 1
      }
      if result.2 {
        // Player spawn
        game.player_gx = gx
        game.player_gy = gy
        game.player_anim_x = Float::from_int(gx)
        game.player_anim_z = Float::from_int(gy)
      }
    }
  }
  // Count objectives
  game.plates_total = @types.count_plates(game)
  game.diamonds_total = @types.count_diamonds(game)
  game.laser_targets_total = @types.count_laser_targets(game)
  // Camera
  game.camera_target_x = Float::from_int(game.player_gx)
  game.camera_target_z = Float::from_int(game.player_gy)
  // Setup decorations
  @types.setup_decorations(game)
  // Calculate initial laser paths
  @types.calculate_laser_paths(game)
  // Check if exit should already be open (no plates, no diamonds, no laser targets)
  check_exit(game)
  // Setup tutorial
  let tutorial_msg = @types.get_tutorial_for_floor(floor)
  if tutorial_msg.length() > 0 {
    game.tutorial_active = true
    game.tutorial_text = tutorial_msg
    game.tutorial_timer = 0.0
    game.tutorial_step = 0
  } else {
    game.tutorial_active = false
    game.tutorial_text = ""
  }
}

///|
fn parse_tile_char(ch : Byte, _gx : Int, _gy : Int) -> (Int, Int, Bool) {
  // Returns (tile_type, entity_type (-1 for none), is_player_spawn)
  if ch == b'#' {
    (@types.tile_wall, -1, false)
  } else if ch == b'.' {
    (@types.tile_floor, -1, false)
  } else if ch == b'P' {
    (@types.tile_floor, -1, true)
  } else if ch == b'B' {
    (@types.tile_floor, @types.entity_block, false)
  } else if ch == b'O' {
    (@types.tile_plate, -1, false)
  } else if ch == b'E' {
    (@types.tile_exit_closed, -1, false)
  } else if ch == b'D' {
    (@types.tile_floor, @types.entity_diamond, false)
  } else if ch == b'K' {
    (@types.tile_floor, @types.entity_key, false)
  } else if ch == b'I' {
    (@types.tile_ice, -1, false)
  } else if ch == b'T' {
    (@types.tile_teleport_a, -1, false)
  } else if ch == b'U' {
    (@types.tile_teleport_b, -1, false)
  } else if ch == b'C' {
    (@types.tile_cracked, -1, false)
  } else if ch == b'X' {
    (@types.tile_pit, -1, false)
  } else if ch == b'S' {
    (@types.tile_switch_off, -1, false)
  } else if ch == b'^' {
    (@types.tile_conveyor_up, -1, false)
  } else if ch == b'>' {
    (@types.tile_conveyor_right, -1, false)
  } else if ch == b'v' {
    (@types.tile_conveyor_down, -1, false)
  } else if ch == b'<' {
    (@types.tile_conveyor_left, -1, false)
  } else if ch == b'b' {
    (@types.tile_bridge_off, -1, false)
  } else if ch == b'w' {
    (@types.tile_bridge_on, -1, false)
  } else if ch == b'G' {
    (@types.tile_gate_closed, -1, false)
  } else if ch == b'/' {
    (@types.tile_mirror_ne, -1, false)
  } else if ch == b'\\' {
    (@types.tile_mirror_nw, -1, false)
  } else if ch == b'L' {
    (@types.tile_laser_source_right, -1, false)
  } else if ch == b'J' {
    (@types.tile_laser_source_down, -1, false)
  } else if ch == b'H' {
    (@types.tile_laser_source_left, -1, false)
  } else if ch == b'F' {
    (@types.tile_laser_source_up, -1, false)
  } else if ch == b'Q' {
    (@types.tile_laser_target, -1, false)
  } else if ch == b'R' {
    (@types.tile_rotate_platform, -1, false)
  } else if ch == b'Y' {
    // Block on conveyor up
    (@types.tile_conveyor_up, @types.entity_block, false)
  } else if ch == b'Z' {
    // Block on plate
    (@types.tile_plate, @types.entity_block, false)
  } else {
    (@types.tile_wall, -1, false)
  }
}

///|
fn save_undo(game : @types.Game) -> Unit {
  if game.undo_count >= @types.max_undo {
    // Shift everything down by 1
    for i in 0..<(@types.max_undo - 1) {
      game.undo_stack[i] = game.undo_stack[i + 1]
    }
    game.undo_count = @types.max_undo - 1
  }
  let idx = game.undo_count
  let state = game.undo_stack[idx]
  state.player_gx = game.player_gx
  state.player_gy = game.player_gy
  state.moves = game.moves
  state.keys_held = game.keys_held
  state.diamonds_collected = game.diamonds_collected
  // Copy tiles
  for i in 0..<@types.grid_total {
    state.tiles[i] = game.tiles[i]
  }
  // Copy entities
  for i in 0..<@types.max_entities {
    state.entity_gx[i] = game.entities[i].gx
    state.entity_gy[i] = game.entities[i].gy
    state.entity_active[i] = game.entities[i].active
    state.entity_kind[i] = game.entities[i].kind
  }
  game.undo_count += 1
}

///|
fn undo_move(game : @types.Game) -> Unit {
  if game.undo_count <= 0 {
    return
  }
  game.undo_count -= 1
  game.used_undo = true
  game.total_undos += 1
  let state = game.undo_stack[game.undo_count]
  game.player_gx = state.player_gx
  game.player_gy = state.player_gy
  game.player_anim_x = Float::from_int(state.player_gx)
  game.player_anim_z = Float::from_int(state.player_gy)
  game.player_moving = false
  game.player_anim_timer = 0.0
  game.moves = state.moves
  game.keys_held = state.keys_held
  game.diamonds_collected = state.diamonds_collected
  // Restore tiles
  for i in 0..<@types.grid_total {
    game.tiles[i] = state.tiles[i]
  }
  // Restore entities
  for i in 0..<@types.max_entities {
    game.entities[i].gx = state.entity_gx[i]
    game.entities[i].gy = state.entity_gy[i]
    game.entities[i].active = state.entity_active[i]
    game.entities[i].kind = state.entity_kind[i]
    game.entities[i].anim_x = Float::from_int(state.entity_gx[i])
    game.entities[i].anim_y = Float::from_int(state.entity_gy[i])
    game.entities[i].anim_timer = 0.0
    game.entities[i].falling = false
    game.entities[i].fall_timer = 0.0
  }
  // Recount plates
  game.plates_active = @types.count_active_plates(game)
  game.plates_total = @types.count_plates(game)
  game.diamonds_total = @types.count_diamonds(game)
  // Recalculate laser paths
  @types.calculate_laser_paths(game)
  check_exit(game)
}

///|
fn reset_progress(game : @types.Game) -> Unit {
  for i in 0..<@types.max_floors {
    game.floor_info[i].unlocked = false
    game.floor_info[i].completed = false
    game.floor_info[i].best_moves = 999
    game.floor_info[i].stars = 0
  }
  game.floor_info[0].unlocked = true
  game.total_stars = 0
  game.total_moves = 0
  game.total_undos = 0
  game.levels_completed = 0
  // Reset achievements
  for i in 0..<@types.max_achievements {
    game.achievements[i].unlocked = false
  }
}
