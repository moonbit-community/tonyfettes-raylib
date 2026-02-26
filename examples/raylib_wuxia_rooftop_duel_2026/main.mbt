///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_w, screen_h, "raylib [game] wuxia_rooftop_duel_2026",
  )
  defer @raylib.close_window()

  @raylib.set_target_fps(target_fps)

  let game : Game = Game::new()

  while not(@raylib.window_should_close()) {
    let dt : Float = clampf(@raylib.get_frame_time(), 0.0, 0.05)

    update_input(game, dt)
    update_logic(game, dt)

    @raylib.begin_drawing()
    draw_frame(game)
    @raylib.end_drawing()
  }
}
