///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - basic shapes drawing",
  )

  let mut rotation : Float = 0.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    rotation += 0.2

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_text(
      "some basic shapes available on raylib", 20, 20, 20, @raylib.darkgray,
    )

    // Circle shapes and lines
    @raylib.draw_circle(screen_width / 5, 120, 35.0, @raylib.darkblue)
    @raylib.draw_circle_gradient(
      screen_width / 5,
      220,
      60.0,
      @raylib.green,
      @raylib.skyblue,
    )
    @raylib.draw_circle_lines(screen_width / 5, 340, 80.0, @raylib.darkblue)

    // Rectangle shapes and lines
    @raylib.draw_rectangle(screen_width / 4 * 2 - 60, 100, 120, 60, @raylib.red)
    @raylib.draw_rectangle_gradient_h(
      screen_width / 4 * 2 - 90,
      170,
      180,
      130,
      @raylib.maroon,
      @raylib.gold,
    )
    @raylib.draw_rectangle_lines(
      screen_width / 4 * 2 - 40,
      320,
      80,
      60,
      @raylib.orange,
    )

    // Triangle shapes and lines
    let sw_f = Float::from_int(screen_width)
    @raylib.draw_triangle(
      @raylib.Vector2::new(sw_f / 4.0 * 3.0, 80.0),
      @raylib.Vector2::new(sw_f / 4.0 * 3.0 - 60.0, 150.0),
      @raylib.Vector2::new(sw_f / 4.0 * 3.0 + 60.0, 150.0),
      @raylib.violet,
    )
    @raylib.draw_triangle_lines(
      @raylib.Vector2::new(sw_f / 4.0 * 3.0, 160.0),
      @raylib.Vector2::new(sw_f / 4.0 * 3.0 - 20.0, 230.0),
      @raylib.Vector2::new(sw_f / 4.0 * 3.0 + 20.0, 230.0),
      @raylib.darkblue,
    )

    // Polygon shapes and lines
    @raylib.draw_poly(
      @raylib.Vector2::new(sw_f / 4.0 * 3.0, 330.0),
      6,
      80.0,
      rotation,
      @raylib.brown,
    )
    @raylib.draw_poly_lines(
      @raylib.Vector2::new(sw_f / 4.0 * 3.0, 330.0),
      6,
      90.0,
      rotation,
      @raylib.brown,
    )
    @raylib.draw_poly_lines_ex(
      @raylib.Vector2::new(sw_f / 4.0 * 3.0, 330.0),
      6,
      85.0,
      rotation,
      6.0,
      @raylib.beige,
    )

    // NOTE: We draw all LINES based shapes together to optimize internal drawing,
    // this way, all LINES are rendered in a single draw pass
    @raylib.draw_line(18, 42, screen_width - 18, 42, @raylib.black)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
