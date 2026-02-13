///|
fn main {
  // Initialize window
  @raylib.set_config_flags(@raylib.FlagWindowResizable)
  @raylib.init_window(800, 600, "MoonBit Raylib Demo")
  @raylib.set_target_fps(60)

  // Ball state
  let mut ball_x : Float = 400.0
  let mut ball_y : Float = 300.0
  let ball_radius : Float = 20.0
  let ball_speed : Float = 200.0

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let dt = @raylib.get_frame_time()

    // Move ball with arrow keys or WASD
    if @raylib.is_key_down(@raylib.KeyRight) ||
      @raylib.is_key_down(@raylib.KeyD) {
      ball_x += ball_speed * dt
    }
    if @raylib.is_key_down(@raylib.KeyLeft) || @raylib.is_key_down(@raylib.KeyA) {
      ball_x -= ball_speed * dt
    }
    if @raylib.is_key_down(@raylib.KeyDown) || @raylib.is_key_down(@raylib.KeyS) {
      ball_y += ball_speed * dt
    }
    if @raylib.is_key_down(@raylib.KeyUp) || @raylib.is_key_down(@raylib.KeyW) {
      ball_y -= ball_speed * dt
    }

    // Keep ball in bounds
    let sw = Float::from_int(@raylib.get_screen_width())
    let sh = Float::from_int(@raylib.get_screen_height())
    if ball_x < ball_radius {
      ball_x = ball_radius
    }
    if ball_x > sw - ball_radius {
      ball_x = sw - ball_radius
    }
    if ball_y < ball_radius {
      ball_y = ball_radius
    }
    if ball_y > sh - ball_radius {
      ball_y = sh - ball_radius
    }

    // Get mouse position
    let mouse = @raylib.get_mouse_position()

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw title
    @raylib.draw_text("MoonBit + Raylib", 10, 10, 30, @raylib.darkgray)
    @raylib.draw_text(
      "Move the ball with WASD or Arrow Keys", 10, 50, 20, @raylib.gray,
    )

    // Draw some shapes
    @raylib.draw_rectangle(10, 80, 200, 4, @raylib.lightgray)

    // Draw gradient rectangle
    @raylib.draw_rectangle_gradient_h(
      550, 80, 200, 100, @raylib.blue, @raylib.skyblue,
    )
    @raylib.draw_rectangle_lines(550, 80, 200, 100, @raylib.darkblue)

    // Draw the ball
    @raylib.draw_circle_v(
      @raylib.Vector2::new(ball_x, ball_y),
      ball_radius,
      @raylib.maroon,
    )
    @raylib.draw_circle_lines_v(
      @raylib.Vector2::new(ball_x, ball_y),
      ball_radius + 2.0,
      @raylib.red,
    )

    // Draw line from ball to mouse
    @raylib.draw_line_ex(
      @raylib.Vector2::new(ball_x, ball_y),
      mouse,
      2.0,
      @raylib.fade(@raylib.green, 0.5),
    )

    // Draw mouse crosshair
    @raylib.draw_circle_lines_v(mouse, 10.0, @raylib.darkgreen)
    @raylib.draw_line_v(
      @raylib.Vector2::new(mouse.x - 15.0, mouse.y),
      @raylib.Vector2::new(mouse.x + 15.0, mouse.y),
      @raylib.darkgreen,
    )
    @raylib.draw_line_v(
      @raylib.Vector2::new(mouse.x, mouse.y - 15.0),
      @raylib.Vector2::new(mouse.x, mouse.y + 15.0),
      @raylib.darkgreen,
    )

    // Draw some triangles
    @raylib.draw_triangle(
      @raylib.Vector2::new(350.0, 150.0),
      @raylib.Vector2::new(300.0, 250.0),
      @raylib.Vector2::new(400.0, 250.0),
      @raylib.gold,
    )
    @raylib.draw_triangle_lines(
      @raylib.Vector2::new(350.0, 145.0),
      @raylib.Vector2::new(295.0, 255.0),
      @raylib.Vector2::new(405.0, 255.0),
      @raylib.orange,
    )

    // Draw rounded rectangle
    @raylib.draw_rectangle_rounded(
      @raylib.Rectangle::new(50.0, 400.0, 200.0, 80.0),
      0.3,
      6,
      @raylib.fade(@raylib.purple, 0.7),
    )
    @raylib.draw_rectangle_rounded_lines(
      @raylib.Rectangle::new(50.0, 400.0, 200.0, 80.0),
      0.3,
      6,
      @raylib.darkpurple,
    )
    @raylib.draw_text("Rounded Rect", 80, 430, 20, @raylib.white)

    // Draw polygon
    @raylib.draw_poly(
      @raylib.Vector2::new(650.0, 350.0),
      6,
      50.0,
      0.0,
      @raylib.fade(@raylib.skyblue, 0.8),
    )
    @raylib.draw_poly_lines(
      @raylib.Vector2::new(650.0, 350.0),
      6,
      50.0,
      0.0,
      @raylib.darkblue,
    )

    // Draw FPS
    @raylib.draw_fps(10, 570)

    @raylib.end_drawing()
  }

  // Cleanup
  @raylib.close_window()
}
