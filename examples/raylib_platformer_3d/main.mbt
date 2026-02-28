///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(@types.screen_width, @types.screen_height, "Platformer 3D")
  @raylib.set_target_fps(60)
  let game = @types.Game::new()
  while not(@raylib.window_should_close()) {
    let mut dt = @raylib.get_frame_time()
    if dt > 0.05 { dt = 0.05 }
    @game.update_game(game, dt)
    @raylib.begin_drawing()
    let bg = @levels.world_bg_color(game.current_world)
    @raylib.clear_background(@raylib.Color::new(bg.0, bg.1, bg.2, 255))
    if game.state == @types.state_playing || game.state == @types.state_paused ||
    game.state == @types.state_level_complete {
      @render.draw_world(game)
    }
    @render.draw_ui(game)
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
