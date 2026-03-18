///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - text formatting",
  )
  let score = 100020
  let hiscore = 200450
  let lives = 5
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // MoonBit string interpolation replaces C's TextFormat
    @raylib.draw_text("Score: \{score}", 200, 80, 20, @raylib.red)
    @raylib.draw_text("HiScore: \{hiscore}", 200, 120, 20, @raylib.green)
    @raylib.draw_text("Lives: \{lives}", 200, 160, 40, @raylib.blue)

    let frame_time = @raylib.get_frame_time() * 1000.0
    @raylib.draw_text(
      "Elapsed Time: \{frame_time} ms",
      200,
      220,
      20,
      @raylib.black,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
