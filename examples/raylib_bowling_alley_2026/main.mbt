///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(screen_w, screen_h, "raylib [game] bowling_alley_2026")
  defer @raylib.close_window()

  @raylib.init_audio_device()
  defer @raylib.close_audio_device()

  @raylib.set_target_fps(target_fps)

  let game : Game = Game::new()

  while not(@raylib.window_should_close()) {
    let dt : Float = @raylib.get_frame_time()

    let mouse_x : Float = @raylib.get_mouse_x() |> Float::from_int
    let mouse_y : Float = @raylib.get_mouse_y() |> Float::from_int
    let touch_count : Int = @raylib.get_touch_point_count()

    let mouse_hold : Bool = @raylib.is_mouse_button_down(
        @raylib.MouseButtonLeft,
      ) ||
      touch_count > 0

    if game.state == state_title {
      update_title_input(game, mouse_x, mouse_y, mouse_hold, touch_count)
    } else if game.state == state_play {
      update_play_input(game, dt, mouse_x, mouse_y, mouse_hold, touch_count)
      update_play(game, dt)
    } else {
      update_result_input(game, mouse_x, mouse_y, mouse_hold, touch_count)
    }

    @raylib.begin_drawing()
    draw_frame(game, mouse_x, mouse_y, mouse_hold, touch_count)
    @raylib.end_drawing()
  }
}
