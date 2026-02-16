///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - input mouse wheel",
  )
  let mut box_position_y = screen_height / 2 - 40
  let scroll_speed = 4
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    box_position_y -= (@raylib.get_mouse_wheel_move() *
    Float::from_int(scroll_speed)).to_int()

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_rectangle(
      screen_width / 2 - 40,
      box_position_y,
      80,
      80,
      @raylib.maroon,
    )
    @raylib.draw_text(
      "Use mouse wheel to move the cube up and down!", 10, 10, 20, @raylib.gray,
    )
    @raylib.draw_text(
      "Box position Y: \{box_position_y}",
      10,
      40,
      20,
      @raylib.lightgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
