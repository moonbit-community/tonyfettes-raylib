// Player movement and camera

fn update_player(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  // Mouse look
  let mouse_delta = @raylib.get_mouse_delta()
  player.yaw -= mouse_delta.x * @types.player_mouse_sensitivity
  player.pitch -= mouse_delta.y * @types.player_mouse_sensitivity
  player.pitch = @types.clampf(player.pitch, -1.4, 1.4)
  // Sprint
  player.sprint = @raylib.is_key_down(@raylib.KeyLeftShift) && not(player.crouching)
  // Crouch toggle
  if @raylib.is_key_pressed(@raylib.KeyLeftControl) || @raylib.is_key_pressed(@raylib.KeyC) {
    player.crouching = not(player.crouching)
  }
  // Smooth crouch lerp
  let crouch_target : Float = if player.crouching { 1.0 } else { 0.0 }
  let crouch_speed : Float = 6.0
  if player.crouch_lerp < crouch_target {
    player.crouch_lerp = @types.minf(player.crouch_lerp + crouch_speed * dt, crouch_target)
  } else if player.crouch_lerp > crouch_target {
    player.crouch_lerp = @types.maxf(player.crouch_lerp - crouch_speed * dt, crouch_target)
  }
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
    let bob_speed : Float = if player.sprint { 14.0 } else if player.crouching { 6.0 } else { 10.0 }
    player.bob_timer += dt * bob_speed
  }
  // Apply speed with modifiers
  let crouch_mult : Float = if player.crouching { @types.player_crouch_mult } else { 1.0 }
  let sprint_mult : Float = if player.sprint { @types.player_sprint_mult } else { 1.0 }
  let boost_mult : Float = if player.speed_boost_timer > 0.0 { 1.35 } else { 1.0 }
  let speed = @types.player_speed * player.speed_mult * sprint_mult * crouch_mult * boost_mult
  let new_x = player.x + move_x * speed * dt
  let new_z = player.z + move_z * speed * dt
  // Collision with arena walls
  let clamped = @types.clamp_to_arena(new_x, new_z)
  let mut final_x = clamped.0
  let mut final_z = clamped.1
  // Collision with pillars
  for i = 0; i < game.pillars.length(); i = i + 1 {
    let pillar = game.pillars[i]
    let result = @types.push_from_pillar(
      final_x, final_z, @types.player_radius, pillar.x, pillar.z, pillar.radius,
    )
    final_x = result.0
    final_z = result.1
  }
  // Collision with barricades
  let barr_result = @types.push_from_barricades(game, final_x, final_z, @types.player_radius)
  final_x = barr_result.0
  final_z = barr_result.1
  // Collision with low walls
  let wall_result = @types.push_from_low_walls(game, final_x, final_z, @types.player_radius)
  final_x = wall_result.0
  final_z = wall_result.1
  player.x = final_x
  player.z = final_z
  // Damage cooldown
  if player.damage_timer > 0.0 {
    player.damage_timer -= dt
  }
  // Flash timer
  if player.flash_timer > 0.0 {
    player.flash_timer -= dt
  }
  // Hit marker timer
  if game.hit_marker_timer > 0.0 {
    game.hit_marker_timer -= dt
  }
  // Combo timer
  if player.combo_timer > 0.0 {
    player.combo_timer -= dt
    if player.combo_timer <= 0.0 {
      // Track highest combo
      if player.combo_count > game.highest_combo {
        game.highest_combo = player.combo_count
      }
      player.combo_count = 0
      player.combo_mult = @types.combo_base_mult
    }
  }
  // Boost timers
  if player.speed_boost_timer > 0.0 {
    player.speed_boost_timer -= dt
  }
  if player.damage_boost_timer > 0.0 {
    player.damage_boost_timer -= dt
  }
  if player.shield_timer > 0.0 {
    player.shield_timer -= dt
  }
  // Multi-kill timer
  if player.recent_kill_timer > 0.0 {
    player.recent_kill_timer -= dt
    if player.recent_kill_timer <= 0.0 {
      player.recent_kill_count = 0
    }
  }
  // Recoil recovery
  if player.recoil_offset > 0.0 {
    player.recoil_offset -= dt * 8.0
    if player.recoil_offset < 0.0 { player.recoil_offset = 0.0 }
  }
  // Minigun spin decay when not firing
  if not(player.minigun_spinning) && player.minigun_spin > 0.0 {
    player.minigun_spin -= dt * 2.0
    if player.minigun_spin < 0.0 { player.minigun_spin = 0.0 }
  }
}

fn update_camera_fps(game : @types.Game) -> Unit {
  let player = game.player
  let cos_yaw = @math.cosf(player.yaw)
  let sin_yaw = @math.sinf(player.yaw)
  let cos_pitch = @math.cosf(player.pitch)
  let sin_pitch = @math.sinf(player.pitch)
  // Camera position at player eye height with head bob and crouch
  let bob_offset = @math.sinf(player.bob_timer) * 0.06
  let height_diff = @types.player_height - @types.player_crouch_height
  let current_height = @types.player_height - height_diff * player.crouch_lerp
  game.cam_pos_x = player.x
  game.cam_pos_y = current_height + bob_offset
  game.cam_pos_z = player.z
  // Camera target in look direction with recoil
  let recoil_pitch = player.pitch + player.recoil_offset * 0.05
  let look_x = sin_yaw * @math.cosf(recoil_pitch)
  let look_y = @math.sinf(recoil_pitch)
  let look_z = cos_yaw * @math.cosf(recoil_pitch)
  game.cam_target_x = player.x + look_x
  game.cam_target_y = current_height + bob_offset + look_y
  game.cam_target_z = player.z + look_z
}

fn damage_player(game : @types.Game, damage : Float) -> Unit {
  let player = game.player
  if player.damage_timer > 0.0 { return }
  // Shield blocks all damage
  if player.shield_timer > 0.0 {
    @types.spawn_particles(game, player.x, player.y, player.z, 5, 50, 150, 255)
    return
  }
  player.damage_timer = @types.player_damage_cooldown
  player.flash_timer = 0.2
  game.total_damage_taken += damage
  // Armor absorbs some damage
  let mut remaining = damage
  if player.armor > 0.0 {
    let armor_absorb = @types.minf(remaining * 0.6, player.armor)
    player.armor -= armor_absorb
    remaining = remaining - armor_absorb
  }
  player.hp -= remaining
  if player.hp < 0.0 { player.hp = 0.0 }
  // Red flash particles around player
  @types.spawn_particles(game, player.x, player.y, player.z, 5, 255, 50, 50)
}

fn damage_player_from(game : @types.Game, damage : Float, from_x : Float, from_z : Float) -> Unit {
  damage_player(game, damage)
  @types.add_damage_indicator(game, from_x, from_z)
}
