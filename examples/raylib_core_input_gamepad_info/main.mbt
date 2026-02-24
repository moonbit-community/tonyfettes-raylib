///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - gamepad information",
  )
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    let mut y = 5
    for i = 0; i < 4; i = i + 1 {
      // MAX_GAMEPADS = 4
      if @raylib.is_gamepad_available(i) {
        @raylib.draw_text(
          "Gamepad name: \{@raylib.get_gamepad_name(i)}",
          10,
          y,
          10,
          @raylib.black,
        )
        y += 11
        let axis_count = @raylib.get_gamepad_axis_count(i)
        @raylib.draw_text(
          "  Axis count: \{axis_count}",
          10,
          y,
          10,
          @raylib.black,
        )
        y += 11
        for axis = 0; axis < axis_count; axis = axis + 1 {
          let axis_val = @raylib.get_gamepad_axis_movement(i, axis)
          @raylib.draw_text(
            "  Axis \{axis} = \{axis_val}",
            10,
            y,
            10,
            @raylib.black,
          )
          y += 11
        }
        for button = 0; button < 32; button = button + 1 {
          let button_down = if @raylib.is_gamepad_button_down(i, button) {
            1
          } else {
            0
          }
          @raylib.draw_text(
            "  Button \{button} = \{button_down}",
            10,
            y,
            10,
            @raylib.black,
          )
          y += 11
        }
      }
    }
    @raylib.draw_fps(screen_width - 100, 100)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
