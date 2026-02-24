///|
fn text_subtext(text : String, end_pos : Int) -> String {
  let len = text.length()
  let n = if end_pos < len { end_pos } else { len }
  let buf = StringBuilder::new()
  for i = 0; i < n; i = i + 1 {
    buf.write_char(text[i].to_int().unsafe_to_char())
  }
  buf.to_string()
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - text writing anim",
  )
  let message = "This sample illustrates a text writing\nanimation effect! Check it out! ;)"
  let mut frames_counter = 0
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_down(@raylib.KeySpace) {
      frames_counter += 8
    } else {
      frames_counter += 1
    }
    if @raylib.is_key_pressed(@raylib.KeyEnter) {
      frames_counter = 0
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Use string slicing to show only a portion of the message (writing animation)
    @raylib.draw_text(
      text_subtext(message, frames_counter / 10),
      210,
      160,
      20,
      @raylib.maroon,
    )
    @raylib.draw_text(
      "PRESS [ENTER] to RESTART!", 240, 260, 20, @raylib.lightgray,
    )
    @raylib.draw_text(
      "HOLD [SPACE] to SPEED UP!", 239, 300, 20, @raylib.lightgray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
