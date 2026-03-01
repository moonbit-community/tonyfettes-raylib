// Main game update dispatcher (FSM)

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_particles(game, dt)
  if game.state == @types.StateMenu {
    update_menu(game, dt)
  } else if game.state == @types.StatePlaying {
    update_playing(game, dt)
  } else if game.state == @types.StatePaused {
    update_paused(game, dt)
  } else if game.state == @types.StateLevelComplete {
    update_level_complete(game, dt)
  } else if game.state == @types.StateGameOver {
    update_game_over(game, dt)
  } else if game.state == @types.StateFloorSelect {
    update_floor_select(game, dt)
  } else if game.state == @types.StateCampaignComplete {
    update_campaign_complete(game, dt)
  } else if game.state == @types.StateWorldSelect {
    update_world_select(game, dt)
  }
  // Update transition
  if game.transition_timer > 0.0 {
    game.transition_timer -= dt
    if game.transition_timer <= 0.0 {
      game.transition_timer = 0.0
    }
  }
  // Update message
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer <= 0.0 {
      game.message_timer = 0.0
    }
  }
  // Update achievement display
  if game.achievement_display_timer > 0.0 {
    game.achievement_display_timer -= dt
    if game.achievement_display_timer <= 0.0 {
      game.achievement_display_timer = 0.0
    }
  }
}

///|
fn update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * @types.menu_blink_speed
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor > 2 {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      // New game
      reset_progress(game)
      load_floor(game, 0)
      game.state = @types.StatePlaying
    } else if game.menu_cursor == 1 {
      // World select
      game.state = @types.StateWorldSelect
    } else {
      // Floor select
      game.state = @types.StateFloorSelect
    }
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  // Update level timer
  game.level_timer += dt
  // Pause
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.StatePaused
    return
  }
  // Undo
  if @raylib.is_key_pressed(@raylib.KeyZ) ||
    @raylib.is_key_pressed(@raylib.KeyU) {
    undo_move(game)
    return
  }
  // Restart level
  if @raylib.is_key_pressed(@raylib.KeyR) {
    load_floor(game, game.current_floor)
    return
  }
  // Update animations
  update_player_animation(game, dt)
  update_entity_animations(game, dt)
  // Update spike timer (timed spikes in lava world)
  if game.current_world == @types.WorldLava {
    update_timed_spikes(game, dt)
  }
  // Ambient particles for decorations
  update_decoration_particles(game, dt)
  // Camera rotation
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.camera_angle += 90.0
  }
  if @raylib.is_key_pressed(@raylib.KeyE) {
    game.camera_angle -= 90.0
  }
  // Gate animation
  if game.gate_anim_timer > 0.0 {
    game.gate_anim_timer -= dt
    if game.gate_anim_timer <= 0.0 {
      game.gate_anim_timer = 0.0
    }
  }
  // Tutorial timer
  if game.tutorial_active {
    game.tutorial_timer += dt
  }
  // Player input (only when not moving)
  if not(game.player_moving) {
    let mut dir : @types.Dir = @types.DirNone
    if @raylib.is_key_pressed(@raylib.KeyUp) ||
      @raylib.is_key_pressed(@raylib.KeyW) {
      dir = @types.DirUp
    } else if @raylib.is_key_pressed(@raylib.KeyDown) ||
      @raylib.is_key_pressed(@raylib.KeyS) {
      dir = @types.DirDown
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) ||
      @raylib.is_key_pressed(@raylib.KeyA) {
      dir = @types.DirLeft
    } else if @raylib.is_key_pressed(@raylib.KeyRight) ||
      @raylib.is_key_pressed(@raylib.KeyD) {
      dir = @types.DirRight
    }
    if dir != @types.DirNone {
      try_move_player(game, dir)
    }
  }
  // Update camera target towards player
  let target_x = Float::from_int(game.player_gx)
  let target_z = Float::from_int(game.player_gy)
  game.camera_target_x += (target_x - game.camera_target_x) *
    @types.minf(dt * 5.0, 1.0)
  game.camera_target_z += (target_z - game.camera_target_z) *
    @types.minf(dt * 5.0, 1.0)
}

///|
fn update_timed_spikes(game : @types.Game, dt : Float) -> Unit {
  game.spike_timer += dt
  if game.spike_timer >= @types.spike_cycle_time {
    game.spike_timer -= @types.spike_cycle_time
    game.spike_phase = not(game.spike_phase)
    // Toggle all spikes
    toggle_spikes(game)
  }
}

///|
fn update_decoration_particles(game : @types.Game, dt : Float) -> Unit {
  ignore(dt)
  // Spawn particles near decorations periodically
  if game.frame_counter % 30 == 0 {
    for i in 0..<game.decoration_count {
      let d = game.decorations[i]
      if not(d.active) {
        continue
      }
      if d.kind == @types.DecoTorch {
        @types.spawn_ambient_particles(
          game,
          d.x,
          0.6,
          d.z,
          1,
          255,
          160,
          50,
          0.1,
          0.8,
        )
      } else if d.kind == @types.DecoCrystal {
        @types.spawn_ambient_particles(
          game,
          d.x,
          0.4,
          d.z,
          1,
          100,
          200,
          255,
          0.1,
          0.4,
        )
      } else if d.kind == @types.DecoMagmaPool {
        @types.spawn_ambient_particles(
          game,
          d.x,
          0.1,
          d.z,
          1,
          255,
          100,
          20,
          0.15,
          0.3,
        )
      } else if d.kind == @types.DecoFloatingRock {
        @types.spawn_ambient_particles(
          game,
          d.x,
          0.5,
          d.z,
          1,
          150,
          100,
          200,
          0.1,
          0.3,
        )
      }
    }
  }
}

///|
fn update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.StatePlaying
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = @types.StateMenu
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    load_floor(game, game.current_floor)
    game.state = @types.StatePlaying
  }
  if @raylib.is_key_pressed(@raylib.KeyL) {
    game.state = @types.StateFloorSelect
  }
}

///|
fn update_level_complete(game : @types.Game, dt : Float) -> Unit {
  game.complete_timer += dt
  // Spawn celebration particles periodically
  if game.frame_counter % 10 == 0 && game.complete_timer < 3.0 {
    let px = Float::from_int(game.player_gx) +
      @types.rand_rangef(game, -2.0, 2.0)
    let pz = Float::from_int(game.player_gy) +
      @types.rand_rangef(game, -2.0, 2.0)
    @types.spawn_ambient_particles(
      game, px, 0.5, pz, 3, @types.color_exit_r, @types.color_exit_g, @types.color_exit_b,
      0.3, 2.0,
    )
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let next = game.current_floor + 1
    if next >= @types.max_floors {
      game.state = @types.StateCampaignComplete
    } else {
      load_floor(game, next)
      game.state = @types.StatePlaying
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = @types.StateMenu
  }
  if @raylib.is_key_pressed(@raylib.KeyL) {
    game.state = @types.StateFloorSelect
  }
}

///|
fn update_game_over(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    load_floor(game, game.current_floor)
    game.state = @types.StatePlaying
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = @types.StateMenu
  }
}

///|
fn update_floor_select(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.StateMenu
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.floor_select_cursor -= 1
    if game.floor_select_cursor < 0 {
      game.floor_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.floor_select_cursor += 1
    if game.floor_select_cursor >= @types.max_floors {
      game.floor_select_cursor = @types.max_floors - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.floor_select_cursor -= 6
    if game.floor_select_cursor < 0 {
      game.floor_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.floor_select_cursor += 6
    if game.floor_select_cursor >= @types.max_floors {
      game.floor_select_cursor = @types.max_floors - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.floor_info[game.floor_select_cursor].unlocked {
      load_floor(game, game.floor_select_cursor)
      game.state = @types.StatePlaying
    }
  }
}

///|
fn update_world_select(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.StateMenu
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.world_select_cursor -= 1
    if game.world_select_cursor < 0 {
      game.world_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.world_select_cursor += 1
    if game.world_select_cursor >= @types.num_worlds {
      game.world_select_cursor = @types.num_worlds - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if @types.is_world_unlocked(game, game.world_select_cursor) {
      let first_floor = game.world_select_cursor * @types.floors_per_world
      game.floor_select_cursor = first_floor
      game.state = @types.StateFloorSelect
    }
  }
}

///|
fn update_campaign_complete(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = @types.StateMenu
  }
}
