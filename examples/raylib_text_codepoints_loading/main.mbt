///|
fn codepoint_remove_duplicates(codepoints : Array[Int]) -> Array[Int] {
  let result : Array[Int] = []
  for i = 0; i < codepoints.length(); i = i + 1 {
    let mut found = false
    for j = 0; j < result.length(); j = j + 1 {
      if codepoints[i] == result[j] {
        found = true
        break
      }
    }
    if not(found) {
      result.push(codepoints[i])
    }
  }
  result
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_text_codepoints_loading")
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - codepoints loading",
  )

  // Text to be displayed, must be UTF-8
  // NOTE: It can contain all the required text for the game,
  // this text will be scanned to get all the required codepoints
  let text =
    #|いろはにほへと　ちりぬるを
    #|わかよたれそ　つねならむ
    #|うゐのおくやま　けふこえて
    #|あさきゆめみし　ゑひもせす

  // Get codepoints from text
  let codepoints = @raylib.load_codepoints(text)
  let codepoint_count = codepoints.length()

  // Removed duplicate codepoints to generate smaller font atlas
  let codepoints_no_dups = codepoint_remove_duplicates(codepoints)
  let codepoints_no_dups_count = codepoints_no_dups.length()

  // Load font containing all the provided codepoint glyphs
  // A texture font atlas is automatically generated
  let font = @raylib.load_font_ex_codepoints(
    "resources/DotGothic16-Regular.ttf", 36, codepoints_no_dups,
  )

  // Set bilinear scale filter for better font scaling
  @raylib.set_font_texture_filter(font, 1) // TEXTURE_FILTER_BILINEAR

  @raylib.set_text_line_spacing(20) // Set line spacing for multiline text (when line breaks are included '\n')

  let mut show_font_atlas = false

  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      show_font_atlas = not(show_font_atlas)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_rectangle(0, 0, @raylib.get_screen_width(), 70, @raylib.black)
    @raylib.draw_text(
      "Total codepoints contained in provided text: " +
      codepoint_count.to_string(),
      10,
      10,
      20,
      @raylib.green,
    )
    @raylib.draw_text(
      "Total codepoints required for font atlas (duplicates excluded): " +
      codepoints_no_dups_count.to_string(),
      10,
      40,
      20,
      @raylib.green,
    )

    if show_font_atlas {
      // Draw generated font texture atlas containing provided codepoints
      let font_texture = @raylib.get_font_texture(font)
      @raylib.draw_texture(font_texture, 150, 100, @raylib.black)
      @raylib.draw_rectangle_lines(
        150,
        100,
        @raylib.get_texture_width(font_texture),
        @raylib.get_texture_height(font_texture),
        @raylib.black,
      )
    } else {
      // Draw provided text with loaded font, containing all required codepoint glyphs
      @raylib.draw_text_ex(
        font,
        text,
        @raylib.Vector2::new(160.0, 110.0),
        48.0,
        5.0,
        @raylib.black,
      )
    }

    @raylib.draw_text(
      "Press SPACE to toggle font atlas view!",
      10,
      @raylib.get_screen_height() - 30,
      20,
      @raylib.gray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_font(font) // Font unloading
  @raylib.close_window() // Close window and OpenGL context
}
