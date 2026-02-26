///|
fn update_starfield(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.stars.length(); i = i + 1 {
    game.stars[i].y += game.stars[i].speed * dt
    game.stars[i].twinkle += dt * 3.0
    if game.stars[i].y > Float::from_int(screen_height + 10) {
      game.stars[i].y = -4.0
      game.stars[i].x = Float::from_int(rand_range(game, 0, screen_width))
      game.stars[i].speed = Float::from_int(rand_range(game, 12, 85))
      game.stars[i].twinkle = rand_rangef(game, 0.0, 6.2)
    }
  }
}

///|
fn enter_game_over(game : Game) -> Unit {
  if game.state == state_game_over {
    return
  }
  game.state = state_game_over
  game.game_over_timer = if game.demo_mode { 0.8 } else { game_over_delay }
}

///|
fn start_manual_campaign(game : Game) -> Unit {
  game.demo_mode = false
  game.demo_elapsed = 0.0
  start_new_campaign(game)
}

///|
fn start_demo_campaign(game : Game) -> Unit {
  game.demo_mode = true
  game.coop_enabled = true
  game.demo_runs += 1
  game.demo_elapsed = 0.0
  start_new_campaign(game)

  for i = 0; i < max_players; i = i + 1 {
    if not(game.players[i].active) {
      continue i + 1
    }
    game.players[i].lives = 6
    game.players[i].weapon_level = 1
    game.players[i].reload_delay = player_reload_base * 0.92
  }
}

///|
fn update_menu(game : Game, dt : Float) -> Unit {
  game.menu_blink += dt * menu_select_blink_speed

  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = 3
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.menu_cursor += 1
    if game.menu_cursor > 3 {
      game.menu_cursor = 0
    }
  }

  if @raylib.is_key_pressed(@raylib.KeyC) {
    game.coop_enabled = not(game.coop_enabled)
  }
  if @raylib.is_key_pressed(@raylib.KeyD) {
    start_demo_campaign(game)
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      start_manual_campaign(game)
    } else if game.menu_cursor == 1 {
      start_demo_campaign(game)
    } else if game.menu_cursor == 2 {
      game.coop_enabled = not(game.coop_enabled)
    } else {
      @raylib.close_window()
    }
  }
}

///|
fn update_stage_intro(game : Game, dt : Float) -> Unit {
  game.stage_intro_timer -= dt
  if game.stage_intro_timer <= 0.0 {
    game.stage_intro_timer = 0.0
    game.state = state_playing
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  game.stage_clear_timer -= dt
  if game.stage_clear_timer > 0.0 {
    return
  }

  game.stage_index += 1
  if game.stage_index >= level_count {
    game.state = state_campaign_clear
    game.campaign_clear_timer = if game.demo_mode {
      1.0
    } else {
      campaign_clear_delay
    }
  } else {
    load_stage(game, game.stage_index)
  }
}

///|
fn update_campaign_clear(game : Game, dt : Float) -> Unit {
  game.campaign_clear_timer -= dt
  if game.campaign_clear_timer <= 0.0 {
    if game.demo_mode {
      start_demo_campaign(game)
    } else {
      game.state = state_menu
      game.menu_cursor = 0
    }
  }
}

///|
fn update_game_over(game : Game, dt : Float) -> Unit {
  game.game_over_timer -= dt
  if game.game_over_timer <= 0.0 {
    if game.demo_mode {
      start_demo_campaign(game)
    } else {
      game.state = state_menu
      game.menu_cursor = 0
    }
  }
}

///|
fn update_playing(game : Game, dt : Float) -> Unit {
  if game.demo_mode && @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.demo_mode = false
    game.state = state_menu
    game.menu_cursor = 0
    return
  }

  if not(game.demo_mode) && @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = state_paused
    return
  }

  update_camera_shake(game, dt)
  update_combo(game, dt)
  update_global_effects(game, dt)
  update_player_reload_timers(game, dt)

  update_player_input(game, dt)
  update_enemy_spawn(game, dt)
  update_enemies(game, dt)
  update_bombs(game, dt)
  update_bullets(game, dt)
  update_powerups(game, dt)
  update_player_respawns(game, dt)
  update_particles(game, dt)

  if game.base_flash > 0.0 {
    game.base_flash -= dt * 2.0
    if game.base_flash < 0.0 {
      game.base_flash = 0.0
    }
  }

  if not(game.base_alive) {
    enter_game_over(game)
    return
  }

  if all_players_out(game) {
    enter_game_over(game)
    return
  }

  if stage_is_clear(game) {
    game.state = state_stage_clear
    game.stage_clear_timer = if game.demo_mode {
      0.65
    } else {
      stage_clear_time
    }
    spawn_spark_burst(
      game,
      Float::from_int(map_pixel_w / 2),
      Float::from_int(map_pixel_h / 2),
      50,
    )
  }
}

///|
fn update_paused(game : Game, dt : Float) -> Unit {
  game.pause_blink += dt * 4.5
  update_particles(game, dt)
  if @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = state_playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = state_menu
    game.menu_cursor = 0
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_starfield(game, dt)
  if game.demo_mode && game.state != state_menu {
    game.demo_elapsed += dt
  }

  if game.state == state_menu {
    update_menu(game, dt)
  } else if game.state == state_stage_intro {
    update_stage_intro(game, dt)
  } else if game.state == state_playing {
    update_playing(game, dt)
  } else if game.state == state_paused {
    update_paused(game, dt)
  } else if game.state == state_stage_clear {
    update_stage_clear(game, dt)
  } else if game.state == state_game_over {
    update_game_over(game, dt)
  } else if game.state == state_campaign_clear {
    update_campaign_clear(game, dt)
  }
}
