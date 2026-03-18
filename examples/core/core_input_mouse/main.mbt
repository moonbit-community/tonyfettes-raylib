///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - mouse input",
  )
  let mut ball_position = @raylib.Vector2::new(-100.0, -100.0)
  let mut ball_color = @raylib.darkblue
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    ball_position = @raylib.get_mouse_position()
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      ball_color = @raylib.maroon
    } else if @raylib.is_mouse_button_pressed(@raylib.MouseButtonMiddle) {
      ball_color = @raylib.lime
    } else if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
      ball_color = @raylib.darkblue
    } else if @raylib.is_mouse_button_pressed(@raylib.MouseButtonSide) {
      ball_color = @raylib.purple
    } else if @raylib.is_mouse_button_pressed(@raylib.MouseButtonExtra) {
      ball_color = @raylib.yellow
    } else if @raylib.is_mouse_button_pressed(@raylib.MouseButtonForward) {
      ball_color = @raylib.orange
    } else if @raylib.is_mouse_button_pressed(@raylib.MouseButtonBack) {
      ball_color = @raylib.beige
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_circle_v(ball_position, 40.0, ball_color)
    @raylib.draw_text(
      "move ball with mouse and click mouse button to change color", 10, 10, 20,
      @raylib.darkgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
