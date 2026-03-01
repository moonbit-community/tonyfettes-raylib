///|
fn update_starfield(game : @types.Game, dt : Float) -> Unit {
  for star in game.stars {
    star.y += star.speed * dt
    star.twinkle += dt * 3.0
    if star.y > Float::from_int(@types.screen_height + 10) {
      star.y = -4.0
      star.x = Float::from_int(@types.rand_range(game, 0, @types.screen_width))
      star.speed = Float::from_int(@types.rand_range(game, 12, 85))
      star.twinkle = @types.rand_rangef(game, 0.0, 6.2)
    }
  }
}

///|
fn enter_game_over(game : @types.Game) -> Unit {
  if game.state == @types.GameOver {
    return
  }
  game.state = @types.GameOver
  game.game_over_timer = if game.demo_mode {
    0.8
  } else {
    @types.game_over_delay
  }
}

///|
fn start_manual_campaign(game : @types.Game) -> Unit {
  game.demo_mode = false
  game.demo_elapsed = 0.0
  start_new_campaign(game)
}

///|
fn start_demo_campaign(game : @types.Game) -> Unit {
  game.demo_mode = true
  game.coop_enabled = true
  game.demo_runs += 1
  game.demo_elapsed = 0.0
  start_new_campaign(game)

  for i in 0..<@types.max_players {
    if not(game.players[i].active) {
      continue
    }
    game.players[i].lives = 6
    game.players[i].weapon_level = 1
    game.players[i].reload_delay = @types.player_reload_base * 0.92
  }
}

///|
fn update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * @types.menu_select_blink_speed

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
fn update_stage_intro(game : @types.Game, dt : Float) -> Unit {
  game.stage_intro_timer -= dt
  if game.stage_intro_timer <= 0.0 {
    game.stage_intro_timer = 0.0
    game.state = @types.Playing
  }
}

///|
fn update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.stage_clear_timer -= dt
  if game.stage_clear_timer > 0.0 {
    return
  }

  game.stage_index += 1
  if game.stage_index >= @types.level_count {
    game.state = @types.CampaignClear
    game.campaign_clear_timer = if game.demo_mode {
      1.0
    } else {
      @types.campaign_clear_delay
    }
  } else {
    load_stage(game, game.stage_index)
  }
}

///|
fn update_campaign_clear(game : @types.Game, dt : Float) -> Unit {
  game.campaign_clear_timer -= dt
  if game.campaign_clear_timer <= 0.0 {
    if game.demo_mode {
      start_demo_campaign(game)
    } else {
      game.state = @types.Menu
      game.menu_cursor = 0
    }
  }
}

///|
fn update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.game_over_timer -= dt
  if game.game_over_timer <= 0.0 {
    if game.demo_mode {
      start_demo_campaign(game)
    } else {
      game.state = @types.Menu
      game.menu_cursor = 0
    }
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if game.demo_mode && @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.demo_mode = false
    game.state = @types.Menu
    game.menu_cursor = 0
    return
  }

  if not(game.demo_mode) && @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.Paused
    return
  }

  @types.update_camera_shake(game, dt)
  @score.update_combo(game, dt)
  update_global_effects(game, dt)
  update_player_reload_timers(game, dt)

  update_player_input(game, dt)
  update_enemy_spawn(game, dt)
  update_enemies(game, dt)
  update_bombs(game, dt)
  update_bullets(game, dt)
  update_powerups(game, dt)
  update_player_respawns(game, dt)
  @particles.update_particles(game, dt)

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
    game.state = @types.StageClear
    game.stage_clear_timer = if game.demo_mode {
      0.65
    } else {
      @types.stage_clear_time
    }
    @particles.spawn_spark_burst(
      game,
      Float::from_int(@types.map_pixel_w / 2),
      Float::from_int(@types.map_pixel_h / 2),
      50,
    )
  }
}

///|
fn update_paused(game : @types.Game, dt : Float) -> Unit {
  game.pause_blink += dt * 4.5
  @particles.update_particles(game, dt)
  if @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.Playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.Menu
    game.menu_cursor = 0
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_starfield(game, dt)
  if game.demo_mode && game.state != @types.Menu {
    game.demo_elapsed += dt
  }

  match game.state {
    @types.Menu => update_menu(game, dt)
    @types.StageIntro => update_stage_intro(game, dt)
    @types.Playing => update_playing(game, dt)
    @types.Paused => update_paused(game, dt)
    @types.StageClear => update_stage_clear(game, dt)
    @types.GameOver => update_game_over(game, dt)
    @types.CampaignClear => update_campaign_clear(game, dt)
  }
}
