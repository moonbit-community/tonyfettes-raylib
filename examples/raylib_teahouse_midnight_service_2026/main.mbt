///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    @types.screen_w,
    @types.screen_h,
    "raylib [game] teahouse_midnight_service_2026",
  )
  defer @raylib.close_window()
  @raylib.init_audio_device()
  defer @raylib.close_audio_device()
  @raylib.set_target_fps(@types.target_fps)
  let game = @types.Game::new()
  @types.init_title_scene(game)
  while not(@raylib.window_should_close()) {
    let dt = @types.clampf(@raylib.get_frame_time(), 0.0, 0.033)
    @game.update_game(game, dt)
    @raylib.begin_drawing()
    @render.draw_frame(game)
    @raylib.end_drawing()
  }
}
