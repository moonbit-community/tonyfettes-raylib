///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_w, screen_h, "raylib [game] ice_fishing_blitz_2026",
  )
  defer @raylib.close_window()

  @raylib.init_audio_device()
  defer @raylib.close_audio_device()

  @raylib.set_target_fps(target_fps)

  let game : Game = Game::new()

  while not(@raylib.window_should_close()) {
    let dt : Float = clampf(@raylib.get_frame_time(), 0.0, 0.04)

    let mx : Float = @raylib.get_mouse_x() |> Float::from_int
    let my : Float = @raylib.get_mouse_y() |> Float::from_int
    let touch_count : Int = @raylib.get_touch_point_count()

    let hold : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
      touch_count > 0

    if game.state == state_title {
      update_title_input(game, mx, my, hold, touch_count)
      update_play(game, dt)
    } else if game.state == state_play {
      update_play_input(game, dt, mx, my, hold, touch_count)
      update_play(game, dt)
    } else {
      update_result_input(game, mx, my, hold, touch_count)
      update_play(game, dt)
    }

    @raylib.begin_drawing()
    draw_frame(game, mx, my, hold, touch_count)
    @raylib.end_drawing()
  }
}
