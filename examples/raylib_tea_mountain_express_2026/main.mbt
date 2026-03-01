///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "raylib [game] tea_mountain_express_2026",
  )
  defer @raylib.close_window()

  @raylib.set_target_fps(@types.target_fps)

  let game = @types.Game::new()

  while not(@raylib.window_should_close()) {
    let dt = @types.clampf(@raylib.get_frame_time(), 0.0, 0.05)

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_borderless_windowed()
    }

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_frame(game)
    @raylib.end_drawing()
  }
}
