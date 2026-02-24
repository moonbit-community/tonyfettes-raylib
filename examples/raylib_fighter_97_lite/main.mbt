///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(screen_width, screen_height, game_title)
  @raylib.set_target_fps(60)

  let game = Game::new()

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > max_frame_dt {
      dt = max_frame_dt
    }

    update_game(game, dt)

    @raylib.begin_drawing()
    draw_game(game)
    @raylib.end_drawing()
  }

  @raylib.close_window()
}
