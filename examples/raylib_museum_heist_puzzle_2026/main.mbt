///|
fn main {
  @raylib.init_window(
    screen_w, screen_h, "raylib [moonbit] museum heist stealth puzzle 2026",
  )
  defer @raylib.close_window()
  @raylib.set_target_fps(target_fps)

  let game = Game::new()
  reset_to_title(game)

  while not(@raylib.window_should_close()) {
    let dt = @raylib.get_frame_time()

    let mouse = @raylib.get_mouse_position()
    let mouse_x = mouse.x
    let mouse_y = mouse.y
    let mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let mouse_press = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)

    let mut touch_count = @raylib.get_touch_point_count()
    if touch_count < 0 {
      touch_count = 0
    }

    let move_dir = if game.state == state_play {
      detect_move_dir(mouse_x, mouse_y, mouse_hold, touch_count)
    } else {
      dir_none
    }

    let input : FrameInput = {
      move_dir,
      start_pressed: detect_start_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      ),
      next_pressed: detect_next_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      ),
      retry_pressed: detect_retry_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      ),
      restart_pressed: detect_restart_play_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      ),
    }

    update_game(game, dt, input)

    @raylib.begin_drawing()
    draw_frame(game, mouse_x, mouse_y, mouse_hold, touch_count)
    @raylib.end_drawing()
  }
}
