///|
fn main {
  @raylib.init_window(screen_w, screen_h, "raylib [game] warehouse master 2026")
  defer @raylib.close_window()
  @raylib.set_target_fps(target_fps)

  let game : Game = Game::new()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    let mouse = @raylib.get_mouse_position()
    let mouse_x : Float = mouse.x
    let mouse_y : Float = mouse.y
    let mouse_hold : Bool = @raylib.is_mouse_button_down(
      @raylib.MouseButtonLeft,
    )
    let mouse_press : Bool = @raylib.is_mouse_button_pressed(
      @raylib.MouseButtonLeft,
    )

    let mut touch_count : Int = @raylib.get_touch_point_count()
    if touch_count < 0 {
      touch_count = 0
    }

    let start_press : Bool = detect_start_press(
      mouse_x, mouse_y, mouse_press, touch_count,
    )
    let next_press : Bool = detect_next_press(
      mouse_x, mouse_y, mouse_press, touch_count,
    )

    if game.state == state_title {
      update_active_game(game, dt, touch_none, false, false)
      if start_press {
        restart_campaign(game)
      }
    } else if game.state == state_play {
      let held_dir : Int = detect_hold_direction(
        mouse_x, mouse_y, mouse_hold, touch_count,
      )
      let undo_press : Bool = detect_undo_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )
      let reset_press : Bool = detect_reset_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )

      update_active_game(game, dt, held_dir, undo_press, reset_press)
    } else if game.state == state_level_clear {
      update_active_game(game, dt, touch_none, false, false)
      if next_press {
        advance_to_next_level(game)
      }
    } else {
      update_active_game(game, dt, touch_none, false, false)
      if next_press {
        game.state = state_title
      }
    }

    @raylib.begin_drawing()
    draw_frame(game, mouse_x, mouse_y, mouse_hold, touch_count)
    @raylib.end_drawing()
  }
}
