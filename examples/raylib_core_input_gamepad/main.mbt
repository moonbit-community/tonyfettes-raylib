///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - gamepad input",
  )
  let mut gamepad = 0
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeyLeft) && gamepad > 0 {
      gamepad -= 1
    }
    if @raylib.is_key_pressed(@raylib.KeyRight) {
      gamepad += 1
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    if @raylib.is_gamepad_available(gamepad) {
      @raylib.draw_text(
        "GP\{gamepad}: \{@raylib.get_gamepad_name(gamepad)}",
        10,
        10,
        10,
        @raylib.black,
      )

      // Get axis values
      let left_stick_x = @raylib.get_gamepad_axis_movement(
        gamepad,
        @raylib.GamepadAxisLeftX,
      )
      let left_stick_y = @raylib.get_gamepad_axis_movement(
        gamepad,
        @raylib.GamepadAxisLeftY,
      )
      let right_stick_x = @raylib.get_gamepad_axis_movement(
        gamepad,
        @raylib.GamepadAxisRightX,
      )
      let right_stick_y = @raylib.get_gamepad_axis_movement(
        gamepad,
        @raylib.GamepadAxisRightY,
      )
      let left_trigger = @raylib.get_gamepad_axis_movement(
        gamepad,
        @raylib.GamepadAxisLeftTrigger,
      )
      let right_trigger = @raylib.get_gamepad_axis_movement(
        gamepad,
        @raylib.GamepadAxisRightTrigger,
      )

      // Draw background: generic gamepad
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(175.0, 110.0, 460.0, 220.0),
        0.3,
        16,
        @raylib.darkgray,
      )

      // Draw buttons: basic
      @raylib.draw_circle(365, 170, 12.0, @raylib.raywhite)
      @raylib.draw_circle(405, 170, 12.0, @raylib.raywhite)
      @raylib.draw_circle(445, 170, 12.0, @raylib.raywhite)
      @raylib.draw_circle(516, 191, 17.0, @raylib.raywhite)
      @raylib.draw_circle(551, 227, 17.0, @raylib.raywhite)
      @raylib.draw_circle(587, 191, 17.0, @raylib.raywhite)
      @raylib.draw_circle(551, 155, 17.0, @raylib.raywhite)
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonMiddleLeft,
        ) {
        @raylib.draw_circle(365, 170, 10.0, @raylib.red)
      }
      if @raylib.is_gamepad_button_down(gamepad, @raylib.GamepadButtonMiddle) {
        @raylib.draw_circle(405, 170, 10.0, @raylib.green)
      }
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonMiddleRight,
        ) {
        @raylib.draw_circle(445, 170, 10.0, @raylib.blue)
      }
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonRightFaceLeft,
        ) {
        @raylib.draw_circle(516, 191, 15.0, @raylib.gold)
      }
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonRightFaceDown,
        ) {
        @raylib.draw_circle(551, 227, 15.0, @raylib.blue)
      }
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonRightFaceRight,
        ) {
        @raylib.draw_circle(587, 191, 15.0, @raylib.green)
      }
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonRightFaceUp,
        ) {
        @raylib.draw_circle(551, 155, 15.0, @raylib.red)
      }

      // Draw buttons: d-pad
      @raylib.draw_rectangle(245, 145, 28, 88, @raylib.raywhite)
      @raylib.draw_rectangle(215, 174, 88, 29, @raylib.raywhite)
      @raylib.draw_rectangle(247, 147, 24, 84, @raylib.black)
      @raylib.draw_rectangle(217, 176, 84, 25, @raylib.black)
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonLeftFaceUp,
        ) {
        @raylib.draw_rectangle(247, 147, 24, 29, @raylib.red)
      }
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonLeftFaceDown,
        ) {
        @raylib.draw_rectangle(247, 201, 24, 30, @raylib.red)
      }
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonLeftFaceLeft,
        ) {
        @raylib.draw_rectangle(217, 176, 30, 25, @raylib.red)
      }
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonLeftFaceRight,
        ) {
        @raylib.draw_rectangle(271, 176, 30, 25, @raylib.red)
      }

      // Draw buttons: left-right back
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(215.0, 98.0, 100.0, 10.0),
        0.5,
        16,
        @raylib.darkgray,
      )
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(495.0, 98.0, 100.0, 10.0),
        0.5,
        16,
        @raylib.darkgray,
      )
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonLeftTrigger1,
        ) {
        @raylib.draw_rectangle_rounded(
          @raylib.Rectangle::new(215.0, 98.0, 100.0, 10.0),
          0.5,
          16,
          @raylib.red,
        )
      }
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonRightTrigger1,
        ) {
        @raylib.draw_rectangle_rounded(
          @raylib.Rectangle::new(495.0, 98.0, 100.0, 10.0),
          0.5,
          16,
          @raylib.red,
        )
      }

      // Draw axis: left joystick
      let mut left_gamepad_color = @raylib.black
      if @raylib.is_gamepad_button_down(gamepad, @raylib.GamepadButtonLeftThumb) {
        left_gamepad_color = @raylib.red
      }
      @raylib.draw_circle(345, 260, 40.0, @raylib.black)
      @raylib.draw_circle(345, 260, 35.0, @raylib.lightgray)
      @raylib.draw_circle(
        345 + (left_stick_x * 20.0).to_int(),
        260 + (left_stick_y * 20.0).to_int(),
        25.0,
        left_gamepad_color,
      )

      // Draw axis: right joystick
      let mut right_gamepad_color = @raylib.black
      if @raylib.is_gamepad_button_down(
          gamepad,
          @raylib.GamepadButtonRightThumb,
        ) {
        right_gamepad_color = @raylib.red
      }
      @raylib.draw_circle(465, 260, 40.0, @raylib.black)
      @raylib.draw_circle(465, 260, 35.0, @raylib.lightgray)
      @raylib.draw_circle(
        465 + (right_stick_x * 20.0).to_int(),
        260 + (right_stick_y * 20.0).to_int(),
        25.0,
        right_gamepad_color,
      )

      // Draw axis: left-right triggers
      @raylib.draw_rectangle(151, 110, 15, 70, @raylib.gray)
      @raylib.draw_rectangle(644, 110, 15, 70, @raylib.gray)
      @raylib.draw_rectangle(
        151,
        110,
        15,
        (((1.0 : Float) + left_trigger) / 2.0 * 70.0).to_int(),
        @raylib.red,
      )
      @raylib.draw_rectangle(
        644,
        110,
        15,
        (((1.0 : Float) + right_trigger) / 2.0 * 70.0).to_int(),
        @raylib.red,
      )

      // Draw detected axes
      let axis_count = @raylib.get_gamepad_axis_count(gamepad)
      @raylib.draw_text(
        "DETECTED AXIS [\{axis_count}]:",
        10,
        50,
        10,
        @raylib.maroon,
      )
      for i = 0; i < axis_count; i = i + 1 {
        let axis_val = @raylib.get_gamepad_axis_movement(gamepad, i)
        @raylib.draw_text(
          "AXIS \{i}: \{axis_val}",
          20,
          70 + 20 * i,
          10,
          @raylib.darkgray,
        )
      }

      // Draw detected button
      let button_pressed = @raylib.get_gamepad_button_pressed()
      if button_pressed != @raylib.GamepadButtonUnknown {
        @raylib.draw_text(
          "DETECTED BUTTON: \{button_pressed}",
          10,
          430,
          10,
          @raylib.red,
        )
      } else {
        @raylib.draw_text("DETECTED BUTTON: NONE", 10, 430, 10, @raylib.gray)
      }
    } else {
      @raylib.draw_text("GP\{gamepad}: NOT DETECTED", 10, 10, 10, @raylib.gray)
      // Draw generic gamepad placeholder
      @raylib.draw_rectangle_rounded(
        @raylib.Rectangle::new(175.0, 110.0, 460.0, 220.0),
        0.3,
        16,
        @raylib.lightgray,
      )
      @raylib.draw_text(
        "No gamepad detected. Connect a gamepad and try again.", 200, 215, 10, @raylib.gray,
      )
    }
    @raylib.draw_text(
      "Use LEFT/RIGHT arrow keys to switch gamepad",
      10,
      screen_height - 20,
      10,
      @raylib.darkgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
