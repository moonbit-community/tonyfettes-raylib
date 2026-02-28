// Player movement and physics

///|
pub fn update_player(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  // Mouse look
  let mouse_delta = @raylib.get_mouse_delta()
  player.yaw -= mouse_delta.x * @types.player_mouse_sensitivity
  player.pitch -= mouse_delta.y * @types.player_mouse_sensitivity
  player.pitch = @types.clampf(player.pitch, -1.4, 1.4)
  // Keep yaw in 0..2pi range
  if player.yaw < 0.0 {
    player.yaw += @types.two_pi
  }
  if player.yaw > @types.two_pi {
    player.yaw -= @types.two_pi
  }
  // Sprint
  player.sprint = @raylib.is_key_down(@raylib.KeyLeftShift) && player.hunger > 2
  // Movement direction based on yaw
  let cos_yaw = @math.cosf(player.yaw)
  let sin_yaw = @math.sinf(player.yaw)
  // Forward vector (in xz plane)
  let fwd_x = sin_yaw
  let fwd_z = cos_yaw
  // Right vector
  let right_x = cos_yaw
  let right_z = -sin_yaw
  let mut move_x : Float = 0.0
  let mut move_z : Float = 0.0
  if @raylib.is_key_down(@raylib.KeyW) {
    move_x += fwd_x
    move_z += fwd_z
  }
  if @raylib.is_key_down(@raylib.KeyS) {
    move_x -= fwd_x
    move_z -= fwd_z
  }
  if @raylib.is_key_down(@raylib.KeyA) {
    move_x -= right_x
    move_z -= right_z
  }
  if @raylib.is_key_down(@raylib.KeyD) {
    move_x += right_x
    move_z += right_z
  }
  // Normalize movement
  let move_len = (move_x * move_x + move_z * move_z).sqrt()
  if move_len > 0.01 {
    move_x = move_x / move_len
    move_z = move_z / move_len
    // Head bob
    let bob_speed : Float = if player.sprint { 14.0 } else { 10.0 }
    player.bob_timer += dt * bob_speed
  }
  // Apply horizontal speed
  let base_speed : Float = if player.underwater {
    @types.player_speed * 0.5
  } else {
    @types.player_speed
  }
  let speed = base_speed *
    (if player.sprint { @types.player_sprint_mult } else { 1.0 })
  player.vx = move_x * speed
  player.vz = move_z * speed
  // Gravity (reduced in water)
  let grav : Float = if player.underwater {
    @types.gravity * 0.3
  } else {
    @types.gravity
  }
  player.vy -= grav * dt
  let term_vel : Float = if player.underwater {
    @types.terminal_velocity * 0.3
  } else {
    @types.terminal_velocity
  }
  if player.vy < -term_vel {
    player.vy = -term_vel
  }
  // Jump
  if player.on_ground && @raylib.is_key_pressed(@raylib.KeySpace) {
    player.vy = @types.player_jump_force
    player.on_ground = false
  }
  // Swim up in water
  if player.underwater && @raylib.is_key_down(@raylib.KeySpace) {
    player.vy = 3.5
  }
  // Apply velocity with collision detection
  // Horizontal movement (X)
  let new_x = player.x + player.vx * dt
  if not(check_player_collision(game, new_x, player.y, player.z)) {
    player.x = new_x
  } else {
    player.vx = 0.0
  }
  // Horizontal movement (Z)
  let new_z = player.z + player.vz * dt
  if not(check_player_collision(game, player.x, player.y, new_z)) {
    player.z = new_z
  } else {
    player.vz = 0.0
  }
  // Vertical movement (Y)
  let new_y = player.y + player.vy * dt
  if not(check_player_collision(game, player.x, new_y, player.z)) {
    player.y = new_y
    player.on_ground = false
  } else {
    if player.vy < 0.0 {
      player.on_ground = true
      // Snap to ground level
      let foot_y = @types.floorf(player.y - 0.01)
      player.y = Float::from_int(foot_y + 1) + 0.001
    }
    player.vy = 0.0
  }
  // Clamp to world bounds
  let world_max_x = Float::from_int(@types.world_chunks_x * @types.chunk_x) -
    0.5
  let world_max_z = Float::from_int(@types.world_chunks_z * @types.chunk_z) -
    0.5
  player.x = @types.clampf(player.x, 0.5, world_max_x)
  player.z = @types.clampf(player.z, 0.5, world_max_z)
  // Prevent falling below world
  if player.y < 1.0 {
    player.y = 1.0
    player.vy = 0.0
    player.on_ground = true
  }
  // Cactus damage
  let px = player.x.to_int()
  let py = player.y.to_int()
  let pz = player.z.to_int()
  for cy = py; cy <= py + 1; cy = cy + 1 {
    for dx = -1; dx <= 1; dx = dx + 1 {
      for dz = -1; dz <= 1; dz = dz + 1 {
        let block = @types.get_world_block(game, px + dx, cy, pz + dz)
        if block == @types.block_cactus {
          let dist_x = @types.absf(player.x - Float::from_int(px + dx) - 0.5)
          let dist_z = @types.absf(player.z - Float::from_int(pz + dz) - 0.5)
          if dist_x < @types.player_radius + 0.4 &&
            dist_z < @types.player_radius + 0.4 {
            if game.frame_counter % 30 == 0 {
              damage_player(game, 1)
              @types.show_message(game, "Ouch! Cactus!", 1.0)
            }
          }
        }
      }
    }
  }
}

// Check if player AABB collides with any solid block

///|
fn check_player_collision(
  game : @types.Game,
  px : Float,
  py : Float,
  pz : Float,
) -> Bool {
  let r = @types.player_radius
  let h = @types.player_height
  // Check all blocks the player AABB overlaps
  let min_x = @types.floorf(px - r)
  let max_x = @types.floorf(px + r)
  let min_y = @types.floorf(py)
  let max_y = @types.floorf(py + h)
  let min_z = @types.floorf(pz - r)
  let max_z = @types.floorf(pz + r)
  for by = min_y; by <= max_y; by = by + 1 {
    for bz = min_z; bz <= max_z; bz = bz + 1 {
      for bx = min_x; bx <= max_x; bx = bx + 1 {
        let block = @types.get_world_block(game, bx, by, bz)
        if @types.is_solid(block) {
          return true
        }
      }
    }
  }
  false
}

// Update camera to follow player

///|
pub fn update_camera_fps(game : @types.Game) -> Unit {
  let player = game.player
  let cos_yaw = @math.cosf(player.yaw)
  let sin_yaw = @math.sinf(player.yaw)
  let cos_pitch = @math.cosf(player.pitch)
  let sin_pitch = @math.sinf(player.pitch)
  // Camera position at player eye height with head bob
  let bob_offset = @math.sinf(player.bob_timer) * 0.04
  // Subtle sway during sprint
  let sway : Float = if player.sprint {
    @math.sinf(player.bob_timer * 0.5) * 0.02
  } else {
    0.0
  }
  game.cam_pos_x = player.x + sway * cos_yaw
  game.cam_pos_y = player.y + @types.player_eye_height + bob_offset
  game.cam_pos_z = player.z - sway * sin_yaw
  // Camera target in look direction
  let look_x = sin_yaw * cos_pitch
  let look_y = sin_pitch
  let look_z = cos_yaw * cos_pitch
  game.cam_target_x = game.cam_pos_x + look_x
  game.cam_target_y = game.cam_pos_y + look_y
  game.cam_target_z = game.cam_pos_z + look_z
}
