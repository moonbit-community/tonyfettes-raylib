// Main game update dispatcher (FSM)

pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  if game.state == @types.state_menu {
    update_menu(game, dt)
  } else if game.state == @types.state_playing {
    update_playing(game, dt)
  } else if game.state == @types.state_paused {
    update_paused(game, dt)
  } else if game.state == @types.state_game_over {
    update_game_over(game, dt)
  } else if game.state == @types.state_level_up {
    update_level_up(game, dt)
  } else if game.state == @types.state_floor_complete {
    update_floor_complete(game, dt)
  }
  // Update message
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer <= 0.0 {
      game.message_timer = 0.0
    }
  }
  // Update level up timer
  if game.level_up_timer > 0.0 {
    game.level_up_timer -= dt
    if game.level_up_timer <= 0.0 {
      game.level_up_timer = 0.0
    }
  }
}

fn update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * @types.menu_blink_speed
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
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      // New game
      start_new_game(game)
    } else {
      // Continue (restart)
      start_new_game(game)
    }
  }
}

fn start_new_game(game : @types.Game) -> Unit {
  // Reset player stats
  game.player_hp = @types.player_start_hp
  game.player_max_hp = @types.player_start_hp
  game.player_atk = @types.player_start_atk
  game.player_def = @types.player_start_def
  game.player_level = 1
  game.player_xp = 0
  game.player_xp_next = @types.xp_per_level
  game.current_floor = 0
  game.camera_yaw = 0.0
  game.camera_pitch = 0.0
  // Reset floor info
  for i = 0; i < @types.max_floors; i = i + 1 {
    game.floor_info[i].cleared = false
    game.floor_info[i].enemies_killed = 0
    game.floor_info[i].enemies_total = 0
  }
  // Generate first dungeon
  generate_dungeon(game)
  game.state = @types.state_playing
  @raylib.disable_cursor()
}

fn update_playing(game : @types.Game, dt : Float) -> Unit {
  // Pause
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_paused
    @raylib.enable_cursor()
    return
  }
  // Update systems
  update_player(game, dt)
  update_enemies(game, dt)
  update_projectiles(game, dt)
  update_particles(game, dt)
  update_loot_bob(game, dt)
}

fn update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.state_playing
    @raylib.disable_cursor()
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = @types.state_menu
    @raylib.enable_cursor()
  }
}

fn update_game_over(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Restart game
    start_new_game(game)
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = @types.state_menu
    @raylib.enable_cursor()
  }
}

fn update_level_up(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = @types.state_playing
    @raylib.disable_cursor()
  }
}

fn update_floor_complete(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.current_floor < @types.max_floors - 1 {
      game.current_floor += 1
      generate_dungeon(game)
      game.state = @types.state_playing
      @raylib.disable_cursor()
    } else {
      // Game won - return to menu
      game.state = @types.state_menu
      @raylib.enable_cursor()
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = @types.state_menu
    @raylib.enable_cursor()
  }
}
