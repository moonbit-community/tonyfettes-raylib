///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "raylib [game] subway_signal_saboteur_2026",
  )
  defer @raylib.close_window()

  @raylib.init_audio_device()
  defer @raylib.close_audio_device()

  @raylib.set_target_fps(@types.target_fps)

  let game : @types.Game = @types.Game::new()

  while not(@raylib.window_should_close()) {
    let dt : Float = @types.clampf(@raylib.get_frame_time(), 0.0, 0.04)

    game.mouse_x = @raylib.get_mouse_x() |> Float::from_int
    game.mouse_y = @raylib.get_mouse_y() |> Float::from_int
    game.touch_count = @raylib.get_touch_point_count()
    game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
      game.touch_count > 0

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_frame(game)
    @raylib.end_drawing()
  }
}
