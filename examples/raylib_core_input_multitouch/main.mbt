///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - input multitouch",
  )
  let max_touch_points = 10
  let touch_positions : Array[@raylib.Vector2] = []
  for i = 0; i < max_touch_points; i = i + 1 {
    touch_positions.push(@raylib.Vector2::new(0.0, 0.0))
  }
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let mut t_count = @raylib.get_touch_point_count()
    if t_count > max_touch_points {
      t_count = max_touch_points
    }
    for i = 0; i < t_count; i = i + 1 {
      touch_positions[i] = @raylib.get_touch_position(i)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    for i = 0; i < t_count; i = i + 1 {
      // Make sure point is not (0, 0) as this means there is no touch for it
      if touch_positions[i].x > 0.0 && touch_positions[i].y > 0.0 {
        // Draw circle and touch index number
        @raylib.draw_circle_v(touch_positions[i], 34.0, @raylib.orange)
        @raylib.draw_text(
          "\{i}",
          touch_positions[i].x.to_int() - 10,
          touch_positions[i].y.to_int() - 70,
          40,
          @raylib.black,
        )
      }
    }
    @raylib.draw_text(
      "touch the screen at multiple locations to get multiple balls", 10, 10, 20,
      @raylib.darkgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
