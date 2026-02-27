///|
fn read_input() -> @types.Input {
  {
    move_left: @raylib.is_key_down(@raylib.KeyA) ||
    @raylib.is_key_down(@raylib.KeyLeft),
    move_right: @raylib.is_key_down(@raylib.KeyD) ||
    @raylib.is_key_down(@raylib.KeyRight),
    jump_pressed: @raylib.is_key_pressed(@raylib.KeyW) ||
    @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeySpace),
    jump_held: @raylib.is_key_down(@raylib.KeyW) ||
    @raylib.is_key_down(@raylib.KeyUp) ||
    @raylib.is_key_down(@raylib.KeySpace),
    accept: @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace),
    restart: @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) ||
    @raylib.is_key_pressed(@raylib.KeyR),
  }
}

///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_width, @types.screen_height, "raylib [game] super mario 1985 lite",
  )
  @raylib.set_target_fps(60)

  let game = @types.Game::new()
  @game.init_game(game)

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    let input = read_input()
    @game.update_game(game, input, dt)

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.black)
    @render.draw_world(game)
    @render.draw_ui(game)
    @raylib.end_drawing()
  }

  @raylib.close_window()
}
