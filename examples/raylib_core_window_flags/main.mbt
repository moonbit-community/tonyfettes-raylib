///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - window flags",
  )
  let mut ball_position_x : Float = Float::from_int(@raylib.get_screen_width()) /
    2.0
  let mut ball_position_y : Float = Float::from_int(@raylib.get_screen_height()) /
    2.0
  let mut ball_speed_x : Float = 5.0
  let mut ball_speed_y : Float = 4.0
  let ball_radius : Float = 20.0
  let mut frames_counter = 0

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update

    // Toggle fullscreen
    if @raylib.is_key_pressed(@raylib.KeyF) {
      @raylib.toggle_fullscreen()
    }

    // Toggle window resizable
    if @raylib.is_key_pressed(@raylib.KeyR) {
      if @raylib.is_window_state(@raylib.FlagWindowResizable) {
        @raylib.clear_window_state(@raylib.FlagWindowResizable)
      } else {
        @raylib.set_window_state(@raylib.FlagWindowResizable)
      }
    }

    // Toggle window undecorated
    if @raylib.is_key_pressed(@raylib.KeyD) {
      if @raylib.is_window_state(@raylib.FlagWindowUndecorated) {
        @raylib.clear_window_state(@raylib.FlagWindowUndecorated)
      } else {
        @raylib.set_window_state(@raylib.FlagWindowUndecorated)
      }
    }

    // Toggle window hidden
    if @raylib.is_key_pressed(@raylib.KeyH) {
      if not(@raylib.is_window_state(@raylib.FlagWindowHidden)) {
        @raylib.set_window_state(@raylib.FlagWindowHidden)
      }
      frames_counter = 0
    }
    if @raylib.is_window_state(@raylib.FlagWindowHidden) {
      frames_counter += 1
      if frames_counter >= 240 {
        @raylib.clear_window_state(@raylib.FlagWindowHidden)
      }
    }

    // Toggle window minimized
    if @raylib.is_key_pressed(@raylib.KeyN) {
      if not(@raylib.is_window_state(@raylib.FlagWindowMinimized)) {
        @raylib.minimize_window()
      }
      frames_counter = 0
    }
    if @raylib.is_window_state(@raylib.FlagWindowMinimized) {
      frames_counter += 1
      if frames_counter >= 240 {
        @raylib.restore_window()
      }
    }

    // Toggle window maximized
    if @raylib.is_key_pressed(@raylib.KeyM) {
      if @raylib.is_window_state(@raylib.FlagWindowMaximized) {
        @raylib.restore_window()
      } else {
        @raylib.maximize_window()
      }
    }

    // Toggle window unfocused
    if @raylib.is_key_pressed(@raylib.KeyU) {
      if @raylib.is_window_state(@raylib.FlagWindowUnfocused) {
        @raylib.clear_window_state(@raylib.FlagWindowUnfocused)
      } else {
        @raylib.set_window_state(@raylib.FlagWindowUnfocused)
      }
    }

    // Toggle window topmost
    if @raylib.is_key_pressed(@raylib.KeyT) {
      if @raylib.is_window_state(@raylib.FlagWindowTopmost) {
        @raylib.clear_window_state(@raylib.FlagWindowTopmost)
      } else {
        @raylib.set_window_state(@raylib.FlagWindowTopmost)
      }
    }

    // Toggle window always run
    if @raylib.is_key_pressed(@raylib.KeyA) {
      if @raylib.is_window_state(@raylib.FlagWindowAlwaysRun) {
        @raylib.clear_window_state(@raylib.FlagWindowAlwaysRun)
      } else {
        @raylib.set_window_state(@raylib.FlagWindowAlwaysRun)
      }
    }

    // Toggle vsync hint
    if @raylib.is_key_pressed(@raylib.KeyV) {
      if @raylib.is_window_state(@raylib.FlagVsyncHint) {
        @raylib.clear_window_state(@raylib.FlagVsyncHint)
      } else {
        @raylib.set_window_state(@raylib.FlagVsyncHint)
      }
    }

    // Bouncing ball logic
    ball_position_x += ball_speed_x
    ball_position_y += ball_speed_y
    if ball_position_x >=
      Float::from_int(@raylib.get_screen_width()) - ball_radius ||
      ball_position_x <= ball_radius {
      ball_speed_x = -ball_speed_x
    }
    if ball_position_y >=
      Float::from_int(@raylib.get_screen_height()) - ball_radius ||
      ball_position_y <= ball_radius {
      ball_speed_y = -ball_speed_y
    }

    // Draw
    @raylib.begin_drawing()
    if @raylib.is_window_state(@raylib.FlagWindowTransparent) {
      @raylib.clear_background(@raylib.blank)
    } else {
      @raylib.clear_background(@raylib.raywhite)
    }
    @raylib.draw_circle_v(
      @raylib.Vector2::new(ball_position_x, ball_position_y),
      ball_radius,
      @raylib.maroon,
    )
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        0.0,
        0.0,
        Float::from_int(@raylib.get_screen_width()),
        Float::from_int(@raylib.get_screen_height()),
      ),
      4.0,
      @raylib.raywhite,
    )
    @raylib.draw_circle_v(@raylib.get_mouse_position(), 10.0, @raylib.darkblue)
    @raylib.draw_fps(10, 10)
    @raylib.draw_text(
      "Screen Size: [\{@raylib.get_screen_width()}, \{@raylib.get_screen_height()}]",
      10,
      40,
      10,
      @raylib.green,
    )

    // Draw window state info
    @raylib.draw_text(
      "Following flags can be set after window creation:", 10, 60, 10, @raylib.gray,
    )

    // FLAG_FULLSCREEN_MODE
    if @raylib.is_window_state(@raylib.FlagFullscreenMode) {
      @raylib.draw_text(
        "[F] FLAG_FULLSCREEN_MODE: on", 10, 80, 10, @raylib.lime,
      )
    } else {
      @raylib.draw_text(
        "[F] FLAG_FULLSCREEN_MODE: off", 10, 80, 10, @raylib.maroon,
      )
    }

    // FLAG_WINDOW_RESIZABLE
    if @raylib.is_window_state(@raylib.FlagWindowResizable) {
      @raylib.draw_text(
        "[R] FLAG_WINDOW_RESIZABLE: on", 10, 100, 10, @raylib.lime,
      )
    } else {
      @raylib.draw_text(
        "[R] FLAG_WINDOW_RESIZABLE: off", 10, 100, 10, @raylib.maroon,
      )
    }

    // FLAG_WINDOW_UNDECORATED
    if @raylib.is_window_state(@raylib.FlagWindowUndecorated) {
      @raylib.draw_text(
        "[D] FLAG_WINDOW_UNDECORATED: on", 10, 120, 10, @raylib.lime,
      )
    } else {
      @raylib.draw_text(
        "[D] FLAG_WINDOW_UNDECORATED: off", 10, 120, 10, @raylib.maroon,
      )
    }

    // FLAG_WINDOW_HIDDEN
    if @raylib.is_window_state(@raylib.FlagWindowHidden) {
      @raylib.draw_text("[H] FLAG_WINDOW_HIDDEN: on", 10, 140, 10, @raylib.lime)
    } else {
      @raylib.draw_text(
        "[H] FLAG_WINDOW_HIDDEN: off", 10, 140, 10, @raylib.maroon,
      )
    }

    // FLAG_WINDOW_MINIMIZED
    if @raylib.is_window_state(@raylib.FlagWindowMinimized) {
      @raylib.draw_text(
        "[N] FLAG_WINDOW_MINIMIZED: on", 10, 160, 10, @raylib.lime,
      )
    } else {
      @raylib.draw_text(
        "[N] FLAG_WINDOW_MINIMIZED: off", 10, 160, 10, @raylib.maroon,
      )
    }

    // FLAG_WINDOW_MAXIMIZED
    if @raylib.is_window_state(@raylib.FlagWindowMaximized) {
      @raylib.draw_text(
        "[M] FLAG_WINDOW_MAXIMIZED: on", 10, 180, 10, @raylib.lime,
      )
    } else {
      @raylib.draw_text(
        "[M] FLAG_WINDOW_MAXIMIZED: off", 10, 180, 10, @raylib.maroon,
      )
    }

    // FLAG_WINDOW_UNFOCUSED
    if @raylib.is_window_state(@raylib.FlagWindowUnfocused) {
      @raylib.draw_text(
        "[U] FLAG_WINDOW_UNFOCUSED: on", 10, 200, 10, @raylib.lime,
      )
    } else {
      @raylib.draw_text(
        "[U] FLAG_WINDOW_UNFOCUSED: off", 10, 200, 10, @raylib.maroon,
      )
    }

    // FLAG_WINDOW_TOPMOST
    if @raylib.is_window_state(@raylib.FlagWindowTopmost) {
      @raylib.draw_text(
        "[T] FLAG_WINDOW_TOPMOST: on", 10, 220, 10, @raylib.lime,
      )
    } else {
      @raylib.draw_text(
        "[T] FLAG_WINDOW_TOPMOST: off", 10, 220, 10, @raylib.maroon,
      )
    }

    // FLAG_WINDOW_ALWAYS_RUN
    if @raylib.is_window_state(@raylib.FlagWindowAlwaysRun) {
      @raylib.draw_text(
        "[A] FLAG_WINDOW_ALWAYS_RUN: on", 10, 240, 10, @raylib.lime,
      )
    } else {
      @raylib.draw_text(
        "[A] FLAG_WINDOW_ALWAYS_RUN: off", 10, 240, 10, @raylib.maroon,
      )
    }

    // FLAG_VSYNC_HINT
    if @raylib.is_window_state(@raylib.FlagVsyncHint) {
      @raylib.draw_text("[V] FLAG_VSYNC_HINT: on", 10, 260, 10, @raylib.lime)
    } else {
      @raylib.draw_text("[V] FLAG_VSYNC_HINT: off", 10, 260, 10, @raylib.maroon)
    }

    // Pre-creation-only flags
    @raylib.draw_text(
      "Following flags can only be set before window creation:", 10, 300, 10, @raylib.gray,
    )
    if @raylib.is_window_state(@raylib.FlagWindowHighdpi) {
      @raylib.draw_text("FLAG_WINDOW_HIGHDPI: on", 10, 320, 10, @raylib.lime)
    } else {
      @raylib.draw_text("FLAG_WINDOW_HIGHDPI: off", 10, 320, 10, @raylib.maroon)
    }
    if @raylib.is_window_state(@raylib.FlagWindowTransparent) {
      @raylib.draw_text(
        "FLAG_WINDOW_TRANSPARENT: on", 10, 340, 10, @raylib.lime,
      )
    } else {
      @raylib.draw_text(
        "FLAG_WINDOW_TRANSPARENT: off", 10, 340, 10, @raylib.maroon,
      )
    }
    if @raylib.is_window_state(@raylib.FlagMsaa4xHint) {
      @raylib.draw_text("FLAG_MSAA_4X_HINT: on", 10, 360, 10, @raylib.lime)
    } else {
      @raylib.draw_text("FLAG_MSAA_4X_HINT: off", 10, 360, 10, @raylib.maroon)
    }

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
