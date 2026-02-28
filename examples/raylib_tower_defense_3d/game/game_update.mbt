// Main game update dispatcher

pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  // Apply speed multiplier to dt for gameplay (not menu/UI)
  let game_dt : Float = if game.state == @types.state_playing {
    dt * game.speed_multiplier
  } else {
    dt
  }
  update_particles(game, dt)
  update_chain_lines(game, dt)
  update_notifications(game, dt)
  update_wave_message(game, dt)
  if game.state == @types.state_menu {
    update_menu(game, dt)
  } else if game.state == @types.state_map_select {
    update_map_select(game, dt)
  } else if game.state == @types.state_playing {
    update_playing(game, game_dt)
  } else if game.state == @types.state_paused {
    update_paused(game, dt)
  } else if game.state == @types.state_wave_prep {
    update_wave_prep(game, dt)
  } else if game.state == @types.state_building {
    update_building(game, dt)
  } else if game.state == @types.state_tower_info {
    update_tower_info(game, dt)
  } else if game.state == @types.state_game_over {
    update_game_over(game, dt)
  } else if game.state == @types.state_victory {
    update_victory(game, dt)
  }
}

fn update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor > 1 {
      game.menu_cursor = 0
    }
  }
  // Difficulty selection with Left/Right
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.difficulty -= 1
    if game.difficulty < 0 {
      game.difficulty = 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.difficulty += 1
    if game.difficulty > 2 {
      game.difficulty = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    if game.menu_cursor == 0 {
      // Start game -> map select
      game.state = @types.state_map_select
      game.menu_cursor = 0
    } else if game.menu_cursor == 1 {
      // Cycle difficulty
      game.difficulty = (game.difficulty + 1) % 3
    }
  }
}

fn update_map_select(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = @types.map_count - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor >= @types.map_count {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_menu
    game.menu_cursor = 0
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    game.current_map = game.menu_cursor
    load_map(game, game.current_map)
    game.state = @types.state_wave_prep
    game.wave_timer = @types.wave_prep_time
  }
  ignore(dt)
}

fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) || @raylib.is_key_pressed(
    @raylib.KeyP,
  ) {
    game.state = @types.state_paused
    return
  }
  // Toggle building mode
  if @raylib.is_key_pressed(@raylib.KeyB) {
    game.prev_state = @types.state_playing
    game.state = @types.state_building
    return
  }
  // Toggle range display
  if @raylib.is_key_pressed(@raylib.KeyR) {
    game.show_ranges = not(game.show_ranges)
  }
  // Toggle minimap
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.show_minimap = not(game.show_minimap)
  }
  // Speed control
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.speed_setting = (game.speed_setting + 1) % 3
    game.speed_multiplier = @types.speed_from_setting(game.speed_setting)
  }
  // Tower selection with mouse click (select tower by clicking on it)
  if @raylib.is_key_pressed(@raylib.KeyT) {
    // Open tower info if tower is selected
    if game.selected_tower_idx >= 0 {
      game.prev_state = @types.state_playing
      game.state = @types.state_tower_info
      return
    }
  }
  // Select/deselect tower with number keys when not in build mode
  handle_tower_selection(game)
  update_camera(game, dt)
  update_spawning(game, dt)
  update_enemies(game, dt)
  update_towers(game, dt)
  update_projectiles(game, dt)
  update_interest(game, dt)
  // Check wave complete
  if game.enemies_spawned >= game.enemies_to_spawn {
    let mut alive = false
    for i = 0; i < game.enemies.length(); i = i + 1 {
      if game.enemies[i].active {
        alive = true
        break
      }
    }
    if not(alive) && game.wave_active {
      // Wave complete
      game.wave_active = false
      let info = @levels.get_wave_info(game.current_wave)
      game.gold += info.bonus_gold + @types.wave_completion_bonus
      game.total_gold_earned += info.bonus_gold + @types.wave_completion_bonus
      if game.current_wave > game.longest_wave {
        game.longest_wave = game.current_wave
      }
      game.current_wave += 1
      if game.current_wave >= @types.max_waves {
        game.state = @types.state_victory
      } else {
        game.state = @types.state_wave_prep
        game.wave_timer = @types.wave_prep_time
      }
    }
  }
  // Check game over
  if game.lives <= 0 {
    game.lives = 0
    game.state = @types.state_game_over
  }
}

fn update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) || @raylib.is_key_pressed(
    @raylib.KeyP,
  ) {
    game.state = @types.state_playing
  }
  // Allow quitting to menu
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    reset_game(game)
    game.state = @types.state_menu
  }
}

fn update_wave_prep(game : @types.Game, dt : Float) -> Unit {
  update_camera(game, dt)
  // Allow building during prep
  if @raylib.is_key_pressed(@raylib.KeyB) {
    game.prev_state = @types.state_wave_prep
    game.state = @types.state_building
    return
  }
  // Tower selection with number keys
  handle_tower_placement_keys(game)
  // Speed control
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.speed_setting = (game.speed_setting + 1) % 3
    game.speed_multiplier = @types.speed_from_setting(game.speed_setting)
  }
  game.wave_timer -= dt
  if game.wave_timer <= 0.0 || @raylib.is_key_pressed(@raylib.KeySpace) {
    start_wave(game, game.current_wave)
    game.state = @types.state_playing
  }
}

fn update_building(game : @types.Game, dt : Float) -> Unit {
  update_camera(game, dt)
  if @raylib.is_key_pressed(@raylib.KeyEscape) || @raylib.is_key_pressed(
    @raylib.KeyB,
  ) {
    // Return to previous state
    if game.prev_state == @types.state_playing {
      game.state = @types.state_playing
    } else {
      game.state = @types.state_wave_prep
    }
    return
  }
  handle_tower_placement_keys(game)
  // Hover position (arrow keys for grid cursor)
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.hover_gx -= 1
    if game.hover_gx < 0 {
      game.hover_gx = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.hover_gx += 1
    if game.hover_gx >= @types.map_w {
      game.hover_gx = @types.map_w - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.hover_gy -= 1
    if game.hover_gy < 0 {
      game.hover_gy = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.hover_gy += 1
    if game.hover_gy >= @types.map_h {
      game.hover_gy = @types.map_h - 1
    }
  }
  game.hover_valid = @types.can_place_tower(game, game.hover_gx, game.hover_gy)
  // Place tower
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    try_place_tower(game)
  }
}

fn update_tower_info(game : @types.Game, dt : Float) -> Unit {
  update_camera(game, dt)
  if @raylib.is_key_pressed(@raylib.KeyEscape) || @raylib.is_key_pressed(
    @raylib.KeyT,
  ) {
    game.state = game.prev_state
    return
  }
  // Upgrade tower with U
  if @raylib.is_key_pressed(@raylib.KeyU) {
    try_upgrade_tower(game)
  }
  // Sell tower with S
  if @raylib.is_key_pressed(@raylib.KeyS) {
    try_sell_tower(game)
    game.state = game.prev_state
    return
  }
  // Cycle targeting mode with F
  if @raylib.is_key_pressed(@raylib.KeyF) {
    cycle_targeting_mode(game)
  }
  // Navigate between towers with Left/Right
  if @raylib.is_key_pressed(@raylib.KeyLeft) || @raylib.is_key_pressed(
    @raylib.KeyRight,
  ) {
    let dir : Int = if @raylib.is_key_pressed(@raylib.KeyRight) { 1 } else { -1 }
    let start = game.selected_tower_idx
    let mut next = start + dir
    for _iter = 0; _iter < game.towers.length(); _iter = _iter + 1 {
      if next < 0 {
        next = game.towers.length() - 1
      }
      if next >= game.towers.length() {
        next = 0
      }
      if game.towers[next].active {
        game.selected_tower_idx = next
        return
      }
      next += dir
    }
  }
}

fn update_game_over(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    reset_game(game)
    game.state = @types.state_menu
  }
}

fn update_victory(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    reset_game(game)
    game.state = @types.state_menu
  }
}

fn update_camera(game : @types.Game, dt : Float) -> Unit {
  // Camera rotation with Q/E
  if @raylib.is_key_down(@raylib.KeyQ) {
    game.camera_angle += 60.0 * dt
  }
  if @raylib.is_key_down(@raylib.KeyE) {
    game.camera_angle -= 60.0 * dt
  }
  // Camera pan with WASD (when not in build mode moving cursor)
  if game.state != @types.state_building {
    let pan_speed : Float = 15.0 * dt
    if @raylib.is_key_down(@raylib.KeyW) {
      game.camera_target_z -= pan_speed
    }
    if @raylib.is_key_down(@raylib.KeyS) {
      game.camera_target_z += pan_speed
    }
    if @raylib.is_key_down(@raylib.KeyA) {
      game.camera_target_x -= pan_speed
    }
    if @raylib.is_key_down(@raylib.KeyD) {
      game.camera_target_x += pan_speed
    }
  }
  // Clamp camera target
  let map_max_x = Float::from_int(@types.map_w) * @types.cell_size
  let map_max_z = Float::from_int(@types.map_h) * @types.cell_size
  game.camera_target_x = @types.clampf(game.camera_target_x, 0.0, map_max_x)
  game.camera_target_z = @types.clampf(game.camera_target_z, 0.0, map_max_z)
  // Camera zoom with mouse wheel or +/-
  let wheel = @raylib.get_mouse_wheel_move()
  if wheel != 0.0 {
    game.camera_dist -= wheel * 2.0
    game.camera_dist = @types.clampf(
      game.camera_dist, @types.camera_min_dist, @types.camera_max_dist,
    )
  }
  // Camera pitch adjustment with Z/X
  if @raylib.is_key_down(@raylib.KeyZ) {
    game.camera_pitch += 30.0 * dt
    game.camera_pitch = @types.clampf(game.camera_pitch, 20.0, 80.0)
  }
  if @raylib.is_key_down(@raylib.KeyX) {
    game.camera_pitch -= 30.0 * dt
    game.camera_pitch = @types.clampf(game.camera_pitch, 20.0, 80.0)
  }
  ignore(dt)
}

fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) {
      continue i + 1
    }
    p.life -= dt
    if p.life <= 0.0 {
      p.active = false
      continue i + 1
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.z += p.vz * dt
    p.vy -= 8.0 * dt
    p.vx *= 0.97
    p.vz *= 0.97
    // Gold particles float upward
    if p.kind == @types.particle_gold {
      p.vy = 2.0
      p.vx *= 0.9
      p.vz *= 0.9
    }
    // Lightning particles jitter
    if p.kind == @types.particle_lightning {
      p.x += @types.rand_rangef(game, -0.1, 0.1)
      p.z += @types.rand_rangef(game, -0.1, 0.1)
    }
  }
}

fn update_chain_lines(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.chain_lines.length(); i = i + 1 {
    let cl = game.chain_lines[i]
    if not(cl.active) {
      continue i + 1
    }
    cl.life -= dt
    if cl.life <= 0.0 {
      cl.active = false
    }
  }
}

fn update_notifications(game : @types.Game, dt : Float) -> Unit {
  if game.notification_timer > 0.0 {
    game.notification_timer -= dt
  }
}

fn update_wave_message(game : @types.Game, dt : Float) -> Unit {
  if game.wave_message_timer > 0.0 {
    game.wave_message_timer -= dt
  }
}

fn update_interest(game : @types.Game, dt : Float) -> Unit {
  game.interest_timer += dt
  if game.interest_timer >= @types.interest_interval {
    game.interest_timer = 0.0
    let interest_amount : Float = Float::from_int(game.gold) * @types.interest_rate
    let capped = @types.mini(interest_amount.to_int(), @types.interest_cap)
    if capped > 0 {
      game.gold += capped
      game.total_gold_earned += capped
    }
  }
}

fn handle_tower_placement_keys(game : @types.Game) -> Unit {
  // Quick-place with number keys
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_tower_type = @types.tower_arrow
  } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.selected_tower_type = @types.tower_cannon
  } else if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.selected_tower_type = @types.tower_frost
  } else if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.selected_tower_type = @types.tower_lightning
  } else if @raylib.is_key_pressed(@raylib.KeyFive) {
    game.selected_tower_type = @types.tower_flame
  } else if @raylib.is_key_pressed(@raylib.KeySix) {
    game.selected_tower_type = @types.tower_sniper
  } else if @raylib.is_key_pressed(@raylib.KeySeven) {
    game.selected_tower_type = @types.tower_splash
  } else if @raylib.is_key_pressed(@raylib.KeyEight) {
    game.selected_tower_type = @types.tower_buff
  }
}

fn handle_tower_selection(game : @types.Game) -> Unit {
  // Select towers by moving cursor over them and pressing T
  // For now, find nearest tower to cursor
  if @raylib.is_key_pressed(@raylib.KeyT) {
    // Find nearest active tower
    let mut best_idx = -1
    let mut best_dist : Float = 999.0
    let cam_x = game.camera_target_x
    let cam_z = game.camera_target_z
    for i = 0; i < game.towers.length(); i = i + 1 {
      let tower = game.towers[i]
      if not(tower.active) {
        continue i + 1
      }
      let tx = @types.grid_to_world_x(tower.gx)
      let tz = @types.grid_to_world_z(tower.gy)
      let dist = @types.distance2d(cam_x, cam_z, tx, tz)
      if dist < best_dist {
        best_dist = dist
        best_idx = i
      }
    }
    game.selected_tower_idx = best_idx
  }
}
