///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_text_font_filters")
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - font filters",
  )

  let msg = "Loaded Font"

  // NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)

  // TTF Font loading with custom generation parameters
  let font = @raylib.load_font_ex("resources/KAISG.ttf", 96)

  // Generate mipmap levels to use trilinear filtering
  // NOTE: On 2D drawing it won't be noticeable, it looks like FILTER_BILINEAR
  @raylib.gen_font_texture_mipmaps(font)

  let mut font_size : Float = Float::from_int(@raylib.get_font_base_size(font))
  let mut font_position_x : Float = 40.0
  let font_position_y : Float = Float::from_int(screen_height) / 2.0 - 80.0

  // Setup texture scaling filter
  @raylib.set_font_texture_filter(font, 0) // TEXTURE_FILTER_POINT
  let mut current_font_filter = 0

  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    font_size = font_size + @raylib.get_mouse_wheel_move() * 4.0

    // Choose font texture filter method
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      @raylib.set_font_texture_filter(font, 0) // TEXTURE_FILTER_POINT
      current_font_filter = 0
    } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
      @raylib.set_font_texture_filter(font, 1) // TEXTURE_FILTER_BILINEAR
      current_font_filter = 1
    } else if @raylib.is_key_pressed(@raylib.KeyThree) {
      // NOTE: Trilinear filter won't be noticed on 2D drawing
      @raylib.set_font_texture_filter(font, 2) // TEXTURE_FILTER_TRILINEAR
      current_font_filter = 2
    }

    let text_size = @raylib.measure_text_ex(font, msg, font_size, 0.0)

    if @raylib.is_key_down(@raylib.KeyLeft) {
      font_position_x = font_position_x - 10.0
    } else if @raylib.is_key_down(@raylib.KeyRight) {
      font_position_x = font_position_x + 10.0
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_text(
      "Use mouse wheel to change font size", 20, 20, 10, @raylib.gray,
    )
    @raylib.draw_text(
      "Use KEY_RIGHT and KEY_LEFT to move text", 20, 40, 10, @raylib.gray,
    )
    @raylib.draw_text(
      "Use 1, 2, 3 to change texture filter", 20, 60, 10, @raylib.gray,
    )
    @raylib.draw_text(
      "Drop a new TTF font for dynamic loading", 20, 80, 10, @raylib.darkgray,
    )

    @raylib.draw_text_ex(
      font,
      msg,
      @raylib.Vector2::new(font_position_x, font_position_y),
      font_size,
      0.0,
      @raylib.black,
    )

    @raylib.draw_rectangle(
      0,
      screen_height - 80,
      screen_width,
      80,
      @raylib.lightgray,
    )
    @raylib.draw_text(
      "Font size: " + font_size.to_string(),
      20,
      screen_height - 50,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "Text size: [" +
      text_size.x.to_string() +
      ", " +
      text_size.y.to_string() +
      "]",
      20,
      screen_height - 30,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text("CURRENT TEXTURE FILTER:", 250, 400, 20, @raylib.gray)

    if current_font_filter == 0 {
      @raylib.draw_text("POINT", 570, 400, 20, @raylib.black)
    } else if current_font_filter == 1 {
      @raylib.draw_text("BILINEAR", 570, 400, 20, @raylib.black)
    } else if current_font_filter == 2 {
      @raylib.draw_text("TRILINEAR", 570, 400, 20, @raylib.black)
    }

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_font(font) // Font unloading
  @raylib.close_window() // Close window and OpenGL context
}
