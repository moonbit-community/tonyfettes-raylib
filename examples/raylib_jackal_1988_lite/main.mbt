///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [game] jackal 1988 lite",
  )
  @raylib.set_target_fps(60)

  let game = Game::new()

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    update_game(game, dt)

    @raylib.begin_drawing()
    draw_world(game)
    draw_ui(game)
    @raylib.end_drawing()
  }

  @raylib.close_window()
}
