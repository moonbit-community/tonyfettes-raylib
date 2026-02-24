///|
fn main {
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(screen_w, screen_h, "raylib [game] candy crush 2026")
  defer @raylib.close_window()
  @raylib.set_target_fps(target_fps)

  let game = Game::new()

  while not(@raylib.window_should_close()) {
    let dt = clampf(@raylib.get_frame_time(), 0.0, 0.05)

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_borderless_windowed()
    }

    let mouse = @raylib.get_mouse_position()
    let mouse_x = mouse.x
    let mouse_y = mouse.y
    let mouse_press = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)

    let mut touch_count = @raylib.get_touch_point_count()
    if touch_count < 0 {
      touch_count = 0
    }

    update_timers(game, dt)

    if game.state == state_title {
      update_title_input(game, mouse_x, mouse_y, mouse_press, touch_count)
    } else if game.state == state_play {
      update_play_input(game, mouse_x, mouse_y, mouse_press, touch_count)
    } else {
      update_result_input(game, mouse_x, mouse_y, mouse_press, touch_count)
    }

    @raylib.begin_drawing()
    draw_frame(game, mouse_x, mouse_y, mouse_press, touch_count)
    @raylib.end_drawing()
  }
}
