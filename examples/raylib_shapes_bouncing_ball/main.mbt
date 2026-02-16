///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - bouncing ball",
  )
  let mut ball_position_x : Float = Float::from_int(@raylib.get_screen_width()) /
    2.0
  let mut ball_position_y : Float = Float::from_int(@raylib.get_screen_height()) /
    2.0
  let mut ball_speed_x : Float = 5.0
  let mut ball_speed_y : Float = 4.0
  let ball_radius = 20
  let mut pause = false
  let mut frames_counter = 0
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      pause = not(pause)
    }
    if not(pause) {
      ball_position_x += ball_speed_x
      ball_position_y += ball_speed_y

      // Check walls collision for bouncing
      if ball_position_x >=
        Float::from_int(@raylib.get_screen_width() - ball_radius) ||
        ball_position_x <= Float::from_int(ball_radius) {
        ball_speed_x = -ball_speed_x
      }
      if ball_position_y >=
        Float::from_int(@raylib.get_screen_height() - ball_radius) ||
        ball_position_y <= Float::from_int(ball_radius) {
        ball_speed_y = -ball_speed_y
      }
    } else {
      frames_counter += 1
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_circle_v(
      @raylib.Vector2::new(ball_position_x, ball_position_y),
      Float::from_int(ball_radius),
      @raylib.maroon,
    )
    @raylib.draw_text(
      "PRESS SPACE to PAUSE BALL MOVEMENT",
      10,
      @raylib.get_screen_height() - 25,
      20,
      @raylib.lightgray,
    )

    // On pause, we draw a blinking message
    if pause && frames_counter / 30 % 2 != 0 {
      @raylib.draw_text("PAUSED", 350, 200, 30, @raylib.gray)
    }
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
