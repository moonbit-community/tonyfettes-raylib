///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_w, screen_h, "raylib [game] polar_train_heist_2026",
  )
  defer @raylib.close_window()

  @raylib.init_audio_device()
  defer @raylib.close_audio_device()

  @raylib.set_target_fps(target_fps)

  let game = Game::new()
  init_title_scene(game)

  while not(@raylib.window_should_close()) {
    let dt = clampf(@raylib.get_frame_time(), 0.0, 0.033)
    let mx = Float::from_int(@raylib.get_mouse_x())
    let my = Float::from_int(@raylib.get_mouse_y())
    let touch_count = @raylib.get_touch_point_count()
    let hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
      touch_count > 0

    if game.state == state_title {
      update_title_input(game, mx, my, hold, touch_count)
    } else if game.state == state_play {
      update_play_input(game, mx, my, hold, touch_count)
    } else {
      update_result_input(game, mx, my, hold, touch_count)
    }

    update_game(game, dt)

    @raylib.begin_drawing()
    draw_frame(game, mx, my, hold, touch_count)
    @raylib.end_drawing()
  }
}
