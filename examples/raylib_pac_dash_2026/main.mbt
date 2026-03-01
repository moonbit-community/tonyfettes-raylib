///|
fn main {
  @raylib.init_window(
    @types.screen_width, @types.screen_height, "Pac Dash 2026",
  )
  @raylib.set_target_fps(60)

  let game = @types.Game::new()
  @game.init_game(game)

  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }
    @game.update_game(game, dt)
    @render.draw_frame(game)
  }

  @raylib.close_window()
}
