///|
fn main {
  @raylib.init_window(
    screen_w, screen_h, "raylib [game] volcano rescue operations 2026",
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

    if game.state == state_title {
      if detect_start_press(mouse_x, mouse_y, mouse_press, touch_count) {
        start_campaign(game)
      }
    } else if game.state == state_play {
      let restart_press : Bool = detect_restart_press(
        mouse_x, mouse_y, mouse_press, touch_count,
      )

      if restart_press && game.touch_cd <= 0.0 {
        game.touch_cd = 0.2
        restart_level(game)
      } else {
        let dir : Int = detect_dir_press(
          mouse_x, mouse_y, mouse_press, touch_count,
        )
        if dir != dir_none && game.touch_cd <= 0.0 {
          game.touch_cd = 0.08
          ignore(append_manual_step(game, dir))
        }

        let tap = detect_map_target(mouse_x, mouse_y, mouse_press, touch_count)
        if tap.0 && game.touch_cd <= 0.0 {
          game.touch_cd = 0.12
          ignore(plan_route_to(game, tap.1, tap.2))
        }

        if detect_execute_press(mouse_x, mouse_y, mouse_press, touch_count) &&
          game.touch_cd <= 0.0 {
          game.touch_cd = 0.14
          begin_route(game)
        }

        if detect_clear_route_press(mouse_x, mouse_y, mouse_press, touch_count) &&
          game.touch_cd <= 0.0 {
          game.touch_cd = 0.14
          clear_planned_route(game)
        }

        if detect_coolant_press(mouse_x, mouse_y, mouse_press, touch_count) &&
          game.touch_cd <= 0.0 {
          game.touch_cd = 0.18
          use_coolant(game)
        }
      }

      update_play(game, dt)
    } else if detect_restart_press(mouse_x, mouse_y, mouse_press, touch_count) &&
      game.touch_cd <= 0.0 {
      game.touch_cd = 0.2
      restart_level(game)
    } else if detect_next_press(mouse_x, mouse_y, mouse_press, touch_count) &&
      game.touch_cd <= 0.0 &&
      game.result == result_win {
      game.touch_cd = 0.2
      next_level_or_title(game)
    }

    @raylib.begin_drawing()
    draw_frame(game, mouse_x, mouse_y, mouse_hold, touch_count)
    @raylib.end_drawing()
  }
}
