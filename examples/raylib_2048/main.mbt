///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(screen_w, screen_h, "2048")
  defer @raylib.close_window()
  @raylib.set_target_fps(target_fps)
  let game : Game = Game::new()
  while not(@raylib.window_should_close()) {
    let dt : Float = clampf(@raylib.get_frame_time(), 0.0, 0.05)
    handle_input(game)
    update_animations(game, dt)
    @raylib.begin_drawing()
    draw_frame(game)
    @raylib.end_drawing()
  }
}
