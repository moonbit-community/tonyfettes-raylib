///|
fn is_accept_pressed() -> Bool {
  @raylib.is_key_pressed(@raylib.KeyEnter) ||
  @raylib.is_key_pressed(@raylib.KeySpace)
}

///|
fn is_restart_pressed() -> Bool {
  is_accept_pressed() || @raylib.is_key_pressed(@raylib.KeyR)
}

///|
fn update_camera(game : @types.Game, dt : Float) -> Unit {
  let width_f = Float::from_int(@types.screen_width)
  let mut target_x = if game.player.reached_flag {
    game.player.x - width_f * 0.45
  } else {
    game.player.x -
    width_f * 0.36 +
    Float::from_int(game.player.facing) * @types.camera_lead_px
  }

  target_x = @types.clampf(target_x, 0.0, @types.world_width_px - width_f)

  let blend = @types.clampf(dt * @types.camera_lerp, 0.0, 1.0)
  game.camera_x += (target_x - game.camera_x) * blend
}

///|
fn tick_level_timer(game : @types.Game, dt : Float) -> Unit {
  if game.player.reached_flag || game.state != @types.state_playing {
    return
  }

  game.time_accum += dt
  while game.time_accum >= 1.0 {
    game.time_accum -= 1.0
    game.time_left -= 1
    if game.time_left <= 0 {
      game.time_left = 0
      game.state = @types.state_game_over
      game.player.lives = 0
      return
    }
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  tick_level_timer(game, dt)
  if game.state != @types.state_playing {
    return
  }

  update_player(game, dt)
  update_enemies(game, dt)
  update_coins(game, dt)
  @particles.update_particles(game, dt)

  if game.shake_t > 0.0 {
    game.shake_t -= dt
    if game.shake_t < 0.0 {
      game.shake_t = 0.0
    }
  }

  update_camera(game, dt)
}

///|
pub fn init_game(game : @types.Game) -> Unit {
  build_level(game)
  game.state = @types.state_title
  game.time_left = @types.start_time_seconds
  game.time_accum = 0.0
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.elapsed += dt

  if game.state == @types.state_title {
    @particles.update_particles(game, dt)
    if is_accept_pressed() {
      reset_full_run(game)
    }
    return
  }

  if game.state == @types.state_playing {
    update_playing(game, dt)
    return
  }

  @particles.update_particles(game, dt)
  if is_restart_pressed() {
    reset_full_run(game)
  }
}
