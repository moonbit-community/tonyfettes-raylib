///|
fn main {
  @raylib.init_window(screen_w, screen_h, "raylib [game] picross harbor 2026")
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

    update_frame_timers(game, dt)

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

      if detect_toggle_tool() {
        switch_tool(game)
      }

      let undo_press : Bool = detect_undo_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )
      let hint_press : Bool = detect_hint_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )
      let fill_press : Bool = detect_fill_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )
      let cross_press : Bool = detect_cross_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )
      let board_tap = detect_board_tap(
        game, mouse_x, mouse_y, mouse_press, touch_count,
      )

      if reset_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.2
        reload_level(game)
      } else if undo_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.16
        ignore(undo_action(game))
      } else if hint_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.2
        ignore(use_hint(game))
      } else if board_tap.0 && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.12
        ignore(
          apply_tool_on_cell(game, board_tap.1, board_tap.2, game.tool_mode),
        )
      } else if fill_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.1
        ignore(apply_tool_at_cursor(game, tool_fill))
      } else if cross_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.1
        ignore(apply_tool_at_cursor(game, tool_cross))
      }
    } else if game.state == state_level_clear {
      if next_press {
        advance_level(game)
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
