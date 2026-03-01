///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "raylib [game] abyss_signal_runner_2026",
  )
  defer @raylib.close_window()

  @raylib.init_audio_device()
  defer @raylib.close_audio_device()

  @raylib.set_target_fps(@types.target_fps)

  let game = @types.Game::new()
  @game.init_game(game)

  while not(@raylib.window_should_close()) {
    let dt = @types.clampf(@raylib.get_frame_time(), 0.0, 0.033)

    game.mx = Float::from_int(@raylib.get_mouse_x())
    game.my = Float::from_int(@raylib.get_mouse_y())
    game.touch_count = @raylib.get_touch_point_count()
    game.hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
      game.touch_count > 0

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_frame(game)
    @raylib.end_drawing()
  }
}
