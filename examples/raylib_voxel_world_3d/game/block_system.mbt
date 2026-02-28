// Block interaction: targeting, breaking, placing, mining

// DDA ray march to find the block the player is looking at
pub fn update_block_target(game : @types.Game) -> Unit {
  let target = game.target
  target.hit = false
  let player = game.player
  let cos_yaw = @math.cosf(player.yaw)
  let sin_yaw = @math.sinf(player.yaw)
  let cos_pitch = @math.cosf(player.pitch)
  let sin_pitch = @math.sinf(player.pitch)
  // Ray direction
  let dx = sin_yaw * cos_pitch
  let dy = sin_pitch
  let dz = cos_yaw * cos_pitch
  // Ray origin (at eye level)
  let mut rx = game.cam_pos_x
  let mut ry = game.cam_pos_y
  let mut rz = game.cam_pos_z
  let step = @types.ray_step
  let max_steps = (@types.reach_distance / step).to_int()
  let mut prev_bx = @types.floorf(rx)
  let mut prev_by = @types.floorf(ry)
  let mut prev_bz = @types.floorf(rz)
  for i = 0; i < max_steps; i = i + 1 {
    rx += dx * step
    ry += dy * step
    rz += dz * step
    let bx = @types.floorf(rx)
    let by = @types.floorf(ry)
    let bz = @types.floorf(rz)
    let block = @types.get_world_block(game, bx, by, bz)
    if @types.is_solid(block) {
      target.hit = true
      target.bx = bx
      target.by = by
      target.bz = bz
      target.distance = Float::from_int(i) * step
      // Normal is the direction we came from
      target.nx = prev_bx - bx
      target.ny = prev_by - by
      target.nz = prev_bz - bz
      // Clamp normals to -1..1
      if target.nx > 1 { target.nx = 1 }
      if target.nx < -1 { target.nx = -1 }
      if target.ny > 1 { target.ny = 1 }
      if target.ny < -1 { target.ny = -1 }
      if target.nz > 1 { target.nz = 1 }
      if target.nz < -1 { target.nz = -1 }
      return
    }
    prev_bx = bx
    prev_by = by
    prev_bz = bz
    ignore(i)
  }
}

// Handle block breaking (with mining time) and placing
pub fn handle_block_interaction(game : @types.Game, dt : Float) -> Unit {
  let target = game.target
  let player = game.player

  // Mining system: hold left mouse button to mine
  if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) || @raylib.is_key_down(@raylib.KeyF) {
    if target.hit {
      let block = @types.get_world_block(game, target.bx, target.by, target.bz)
      if @types.is_solid(block) && block != @types.block_bedrock {
        // Check if same block we were mining
        if player.mining_active && player.mining_block_x == target.bx &&
          player.mining_block_y == target.by && player.mining_block_z == target.bz {
          // Continue mining
          let mine_time = @types.get_mining_time(block, player.equipped_tool)
          player.mining_progress += dt / mine_time
          if player.mining_progress >= 1.0 {
            // Block broken!
            let drop = @types.get_block_drop(block)
            @types.set_world_block(game, target.bx, target.by, target.bz, @types.block_air)
            game.blocks_broken += 1
            player.mining_active = false
            player.mining_progress = 0.0
            // Add to inventory
            if drop != @types.block_air {
              let leftover = player.inventory.add_item(drop, 1)
              ignore(leftover)
            }
            // Spawn break particles
            let cr = @levels.block_color_r(block)
            let cg = @levels.block_color_g(block)
            let cb = @levels.block_color_b(block)
            @types.spawn_break_particles(game, target.bx, target.by, target.bz, cr, cg, cb)
            @types.show_message(
              game,
              "Broke \{@types.block_name(block)}",
              1.0,
            )
          }
        } else {
          // Start mining new block
          player.mining_active = true
          player.mining_block_x = target.bx
          player.mining_block_y = target.by
          player.mining_block_z = target.bz
          player.mining_progress = 0.0
        }
      }
    } else {
      // Not looking at a block, cancel mining
      player.mining_active = false
      player.mining_progress = 0.0
    }
  } else {
    // Released mouse button, cancel mining
    if player.mining_active {
      player.mining_active = false
      player.mining_progress = 0.0
    }
  }

  // Place block: right mouse button or G key
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) ||
    @raylib.is_key_pressed(@raylib.KeyG) {
    if target.hit {
      let place_x = target.bx + target.nx
      let place_y = target.by + target.ny
      let place_z = target.bz + target.nz
      // Make sure placement position is valid and not occupied
      let existing = @types.get_world_block(game, place_x, place_y, place_z)
      if not(@types.is_solid(existing)) && place_y >= 0 && place_y < @types.chunk_y {
        // Make sure we are not placing inside the player
        let pr = @types.player_radius + 0.1
        let fpx = Float::from_int(place_x) + 0.5
        let fpy = Float::from_int(place_y) + 0.5
        let fpz = Float::from_int(place_z) + 0.5
        let ddx = @types.absf(game.player.x - fpx)
        let ddy = @types.absf(game.player.y + @types.player_height * 0.5 - fpy)
        let ddz = @types.absf(game.player.z - fpz)
        let collides = ddx < pr + 0.5 && ddy < @types.player_height * 0.5 + 0.5 &&
          ddz < pr + 0.5
        if not(collides) {
          // Use item from inventory
          let sel = player.inventory.selected
          let slot = player.inventory.slots[sel]
          if slot.count > 0 && slot.item_id > 0 {
            let block_to_place = slot.item_id
            slot.count -= 1
            if slot.count <= 0 {
              slot.item_id = 0
              slot.count = 0
            }
            @types.set_world_block(game, place_x, place_y, place_z, block_to_place)
            game.blocks_placed += 1
            @types.show_message(
              game,
              "Placed \{@types.block_name(block_to_place)}",
              1.0,
            )
          } else {
            @types.show_message(game, "No blocks to place!", 1.0)
          }
        }
      }
    }
  }
}

// Handle block selection via number keys and scroll wheel
pub fn handle_block_selection(game : @types.Game) -> Unit {
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
  // Mouse wheel cycling through hotbar slots
  let wheel = @raylib.get_mouse_wheel_move()
  if wheel > 0.0 {
    let mut next = game.player.inventory.selected - 1
    if next < 0 { next = @types.hotbar_slots - 1 }
    game.player.inventory.selected = next
  } else if wheel < 0.0 {
    let mut next = game.player.inventory.selected + 1
    if next >= @types.hotbar_slots { next = 0 }
    game.player.inventory.selected = next
  }
  // Update selected_block from inventory
  let sel_slot = game.player.inventory.slots[game.player.inventory.selected]
  if sel_slot.count > 0 {
    game.player.selected_block = sel_slot.item_id
  }
}
