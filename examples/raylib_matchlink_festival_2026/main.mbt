///|
fn main {
  @raylib.init_window(
    screen_w, screen_h, "raylib [game] matchlink festival 2026",
  )
  defer @raylib.close_window()
  @raylib.set_target_fps(target_fps)

  let game : Game = Game::new()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.05 {
      dt = 0.05
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_borderless_windowed()
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

    update_timers(game, dt)

    let start_press : Bool = detect_start_press(
      mouse_x, mouse_y, mouse_press, touch_count,
    )
    let next_press : Bool = detect_next_press(
      mouse_x, mouse_y, mouse_press, touch_count,
    )
    let reset_press : Bool = detect_reset_press(
      mouse_x, mouse_y, mouse_press, touch_count,
    )

    if game.state == state_title {
      if start_press {
        restart_campaign(game)
      }
    } else if game.state == state_play {
      let held_dir : Int = detect_held_dir(
        mouse_x, mouse_y, mouse_hold, touch_count,
      )
      update_cursor_hold(game, dt, held_dir)

      let select_press : Bool = detect_select_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )
      let hint_press : Bool = detect_hint_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )
      let shuffle_press : Bool = detect_shuffle_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )
      let clear_press : Bool = detect_clear_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )
      let board_tap = detect_board_tap(
        game, mouse_x, mouse_y, mouse_press, touch_count,
      )

      if reset_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.2
        reload_level(game)
      } else if clear_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.12
        clear_selection(game)
        game.message = "Selection cleared"
        game.message_t = 0.5
      } else if hint_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.18
        ignore(use_hint(game))
      } else if shuffle_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.2
        ignore(reshuffle_board(game, true))
      } else if board_tap.0 && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.1
        pick_cell(game, board_tap.1, board_tap.2)
      } else if select_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.1
        pick_cursor_cell(game)
      }
    } else if game.state == state_level_clear {
      if next_press {
        next_level(game)
      }
    } else if game.state == state_campaign_clear {
      if next_press {
        restart_campaign(game)
      }
    } else if reset_press || next_press {
      reload_level(game)
    }

    @raylib.begin_drawing()
    draw_frame(game, mouse_x, mouse_y, mouse_hold, touch_count)
    @raylib.end_drawing()
  }
}
