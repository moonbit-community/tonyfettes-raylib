///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_w, screen_h, "raylib [game] night_market_chef_duel_2026",
  )
  defer @raylib.close_window()

  @raylib.set_target_fps(target_fps)

  let game = Game::new()
  init_game(game)

  while not(@raylib.window_should_close()) {
    let dt = clampf(@raylib.get_frame_time(), 0.0, 0.05)

    capture_input(game)
    update_game(game, dt)

    @raylib.begin_drawing()
    draw_frame(game)
    @raylib.end_drawing()
  }
}
