///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_w, @types.screen_h, "raylib [game] skyline_parkour_trials_2026",
  )
  defer @raylib.close_window()

  @raylib.set_target_fps(@types.target_fps)

  let game = @types.Game::new()
  @game.init_title_scene(game)

  while not(@raylib.window_should_close()) {
    let dt = @types.clampf(@raylib.get_frame_time(), 0.0, 0.033)
    game.mouse_x = Float::from_int(@raylib.get_mouse_x())
    game.mouse_y = Float::from_int(@raylib.get_mouse_y())
    game.touch_count = @raylib.get_touch_point_count()
    game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
      game.touch_count > 0

    @game.update_game(game, dt)

    @raylib.begin_drawing()
    @render.draw_frame(game)
    @raylib.end_drawing()
  }
}
