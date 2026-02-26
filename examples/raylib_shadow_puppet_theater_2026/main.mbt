///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_w, screen_h, "raylib [game] shadow_puppet_theater_2026",
  )
  defer @raylib.close_window()

  @raylib.set_target_fps(target_fps)

  let game : Game = Game::new()
  init_title_scene(game)

  while not(@raylib.window_should_close()) {
    let dt : Float = clampf(@raylib.get_frame_time(), 0.0, 0.05)

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_borderless_windowed()
    }

    sample_input(game)
    update_game(game, dt)

    @raylib.begin_drawing()
    draw_frame(game)
    @raylib.end_drawing()
  }
}
