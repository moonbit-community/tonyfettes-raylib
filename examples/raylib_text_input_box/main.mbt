///|
fn string_take(s : String, n : Int) -> String {
  let len = s.length()
  let end = if n < len { n } else { len }
  let buf = StringBuilder::new()
  for i = 0; i < end; i = i + 1 {
    buf.write_char(s[i].to_int().unsafe_to_char())
  }
  buf.to_string()
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let max_input_chars = 9
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - input box",
  )
  let mut name = ""
  let mut letter_count = 0
  let text_box = @raylib.Rectangle::new(
    Float::from_int(screen_width) / 2.0 - 100.0,
    180.0,
    225.0,
    50.0,
  )
  let mut mouse_on_text = false
  let mut frames_counter = 0
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    mouse_on_text = @raylib.check_collision_point_rec(
      @raylib.get_mouse_position(),
      text_box,
    )
    if mouse_on_text {
      // Set the window's cursor to the I-Beam
      @raylib.set_mouse_cursor(@raylib.MouseCursorIbeam)

      // Get char pressed (unicode character) on the queue
      let mut key = @raylib.get_char_pressed()

      // Check if more characters have been pressed on the same frame
      while key > 0 {
        // Only allow keys in range [32..125]
        if key >= 32 && key <= 125 && letter_count < max_input_chars {
          name = name + key.unsafe_to_char().to_string()
          letter_count += 1
        }
        key = @raylib.get_char_pressed()
      }
      if @raylib.is_key_pressed(@raylib.KeyBackspace) {
        letter_count -= 1
        if letter_count < 0 {
          letter_count = 0
        }
        name = string_take(name, letter_count)
      }
    } else {
      @raylib.set_mouse_cursor(@raylib.MouseCursorDefault)
    }
    if mouse_on_text {
      frames_counter += 1
    } else {
      frames_counter = 0
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text("PLACE MOUSE OVER INPUT BOX!", 240, 140, 20, @raylib.gray)
    @raylib.draw_rectangle_rec(text_box, @raylib.lightgray)
    if mouse_on_text {
      @raylib.draw_rectangle_lines(
        text_box.x.to_int(),
        text_box.y.to_int(),
        text_box.width.to_int(),
        text_box.height.to_int(),
        @raylib.red,
      )
    } else {
      @raylib.draw_rectangle_lines(
        text_box.x.to_int(),
        text_box.y.to_int(),
        text_box.width.to_int(),
        text_box.height.to_int(),
        @raylib.darkgray,
      )
    }
    @raylib.draw_text(
      name,
      text_box.x.to_int() + 5,
      text_box.y.to_int() + 8,
      40,
      @raylib.maroon,
    )
    @raylib.draw_text(
      "INPUT CHARS: \{letter_count}/\{max_input_chars}",
      315,
      250,
      20,
      @raylib.darkgray,
    )
    if mouse_on_text {
      if letter_count < max_input_chars {
        // Draw blinking underscore char
        if frames_counter / 20 % 2 == 0 {
          @raylib.draw_text(
            "_",
            text_box.x.to_int() + 8 + @raylib.measure_text(name, 40),
            text_box.y.to_int() + 12,
            40,
            @raylib.maroon,
          )
        }
      } else {
        @raylib.draw_text(
          "Press BACKSPACE to delete chars...", 230, 300, 20, @raylib.gray,
        )
      }
    }

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
