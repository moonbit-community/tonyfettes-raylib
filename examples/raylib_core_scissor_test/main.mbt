///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - scissor test",
  )

  let scissor_width : Float = 300.0
  let scissor_height : Float = 300.0
  let mut scissor_mode = true

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeyS) {
      scissor_mode = not(scissor_mode)
    }

    // Centre the scissor area around the mouse position
    let scissor_x = Float::from_int(@raylib.get_mouse_x()) - scissor_width / 2.0
    let scissor_y = Float::from_int(@raylib.get_mouse_y()) -
      scissor_height / 2.0

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    if scissor_mode {
      @raylib.begin_scissor_mode(
        scissor_x.to_int(),
        scissor_y.to_int(),
        scissor_width.to_int(),
        scissor_height.to_int(),
      )
    }

    // Draw full screen rectangle and some text
    // NOTE: Only part defined by scissor area will be rendered
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
      @raylib.red,
    )
    @raylib.draw_text(
      "Move the mouse around to reveal this text!", 190, 200, 20, @raylib.lightgray,
    )

    if scissor_mode {
      @raylib.end_scissor_mode()
    }

    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(
        scissor_x, scissor_y, scissor_width, scissor_height,
      ),
      1.0,
      @raylib.black,
    )
    @raylib.draw_text(
      "Press S to toggle scissor test", 10, 10, 20, @raylib.black,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
