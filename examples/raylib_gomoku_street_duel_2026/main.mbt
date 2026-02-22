///|
fn main {
  @raylib.init_window(
    screen_w, screen_h, "raylib [game] gomoku street duel 2026",
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
        reset_round(game, true)
      }
    } else if game.state == state_play {
      let held_dir : Int = detect_held_dir(
        mouse_x, mouse_y, mouse_hold, touch_count,
      )
      update_cursor_hold(game, dt, held_dir)

      if game.turn == player_human {
        let place_press : Bool = detect_place_press(
          mouse_x, mouse_y, mouse_press, touch_count,
        )
        let hint_press : Bool = detect_hint_press(
          mouse_x, mouse_y, mouse_press, touch_count,
        )
        let undo_press : Bool = detect_undo_press(
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
          reset_round(game, true)
        } else if hint_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.2
          ignore(use_hint(game))
        } else if undo_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.2
          ignore(undo_last_turn(game))
        } else if clear_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.12
          clear_hint(game)
          set_message(game, "Hint cleared", 0.45)
        } else if board_tap.0 && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.1
          clear_hint(game)
          ignore(place_stone(game, board_tap.1, board_tap.2, player_human))
        } else if place_press && game.touch_action_cd <= 0.0 {
          game.touch_action_cd = 0.1
          clear_hint(game)
          ignore(place_stone(game, game.cursor_x, game.cursor_y, player_human))
        }
      }

      ai_step(game)
    } else if next_press || reset_press {
      let odd_round : Bool = (game.human_wins + game.ai_wins + game.draws) % 2 ==
        1
      reset_round(game, not(odd_round))
    }

    @raylib.begin_drawing()
    draw_frame(game, mouse_x, mouse_y, mouse_hold, touch_count)
    @raylib.end_drawing()
  }
}
