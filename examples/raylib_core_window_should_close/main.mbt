///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - window should close",
  )

  @raylib.set_exit_key(@raylib.KeyNull) // Disable KEY_ESCAPE to close window, X-button still works

  let mut exit_window_requested = false // Flag to request window to exit
  let mut exit_window = false // Flag to set window to exit

  @raylib.set_target_fps(60)

  // Main game loop
  while not(exit_window) {
    // Update
    // Detect if X-button or KEY_ESCAPE have been pressed to close window
    if @raylib.window_should_close() ||
      @raylib.is_key_pressed(@raylib.KeyEscape) {
      exit_window_requested = true
    }

    if exit_window_requested {
      // A request for close window has been issued, we can save data before closing
      // or just show a message asking for confirmation
      if @raylib.is_key_pressed(@raylib.KeyY) {
        exit_window = true
      } else if @raylib.is_key_pressed(@raylib.KeyN) {
        exit_window_requested = false
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    if exit_window_requested {
      @raylib.draw_rectangle(0, 100, screen_width, 200, @raylib.black)
      @raylib.draw_text(
        "Are you sure you want to exit program? [Y/N]", 40, 180, 30, @raylib.white,
      )
    } else {
      @raylib.draw_text(
        "Try to close the window to get confirmation message!", 120, 200, 20, @raylib.lightgray,
      )
    }

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
