///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_width, @types.screen_height, "Survival Arena 3D",
  )
  @raylib.set_target_fps(60)
  let game = @types.Game::new()
  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 { dt = 0.05 }
    @game.update_game(game, dt)
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(10, 10, 15, 255))
    if game.state != @types.state_menu {
      @render.draw_world(game)
    }
    @render.draw_ui(game)
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
