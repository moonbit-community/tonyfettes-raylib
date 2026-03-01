///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_width, @types.screen_height, @types.game_title,
  )
  @raylib.set_target_fps(60)

  let game = @types.Game::new()

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > @types.max_frame_dt {
      dt = @types.max_frame_dt
    }

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_game(game)
    @raylib.end_drawing()
  }

  @raylib.close_window()
}
