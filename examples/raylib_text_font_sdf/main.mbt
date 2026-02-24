///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_text_font_sdf")
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - SDF fonts",
  )

  // NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)

  let msg = "Signed Distance Fields"

  // Loading file to memory
  let file_data = @raylib.load_file_data("resources/anonymous_pro_bold.ttf")

  // Default font generation from TTF font
  // Parameters > font size: 16, font type: FONT_DEFAULT, glyphs padding in image: 4 px, pack method: 0 (default)
  let font_default = @raylib.build_font_from_data(
    file_data,
    file_data.length(),
    16,
    @raylib.FontDefault,
    4,
    0,
  )

  // SDF font generation from TTF font
  // Parameters > font size: 16, font type: FONT_SDF, glyphs padding in image: 0 px, pack method: 1 (Skyline algorithm)
  let font_sdf = @raylib.build_font_from_data(
    file_data,
    file_data.length(),
    16,
    @raylib.FontSdf,
    0,
    1,
  )

  // Load SDF required shader (we use default vertex shader)
  let shader = @raylib.load_shader("", "resources/shaders/glsl330/sdf.fs")
  @raylib.set_font_texture_filter(font_sdf, @raylib.TextureFilterBilinear) // Required for SDF font

  let mut font_position_x : Float = 40.0
  let mut font_position_y : Float = Float::from_int(screen_height) / 2.0 - 50.0
  let mut text_size_x : Float = 0.0
  let mut text_size_y : Float = 0.0
  let mut font_size : Float = 16.0
  let mut current_font = 0 // 0 - fontDefault, 1 - fontSDF

  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    font_size = font_size + @raylib.get_mouse_wheel_move() * 8.0

    if font_size < 6.0 {
      font_size = 6.0
    }

    if @raylib.is_key_down(@raylib.KeySpace) {
      current_font = 1
    } else {
      current_font = 0
    }

    let text_size = if current_font == 0 {
      @raylib.measure_text_ex(font_default, msg, font_size, 0.0)
    } else {
      @raylib.measure_text_ex(font_sdf, msg, font_size, 0.0)
    }
    text_size_x = text_size.x
    text_size_y = text_size.y

    font_position_x = Float::from_int(@raylib.get_screen_width()) / 2.0 -
      text_size_x / 2.0
    font_position_y = Float::from_int(@raylib.get_screen_height()) / 2.0 -
      text_size_y / 2.0 +
      80.0

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    if current_font == 1 {
      // NOTE: SDF fonts require a custom SDF shader to compute fragment color
      @raylib.begin_shader_mode(shader) // Activate SDF font shader
      @raylib.draw_text_ex(
        font_sdf,
        msg,
        @raylib.Vector2::new(font_position_x, font_position_y),
        font_size,
        0.0,
        @raylib.black,
      )
      @raylib.end_shader_mode() // Activate our default shader for next drawings
      @raylib.draw_texture(
        @raylib.get_font_texture(font_sdf),
        10,
        10,
        @raylib.black,
      )
    } else {
      @raylib.draw_text_ex(
        font_default,
        msg,
        @raylib.Vector2::new(font_position_x, font_position_y),
        font_size,
        0.0,
        @raylib.black,
      )
      @raylib.draw_texture(
        @raylib.get_font_texture(font_default),
        10,
        10,
        @raylib.black,
      )
    }

    if current_font == 1 {
      @raylib.draw_text("SDF!", 320, 20, 80, @raylib.red)
    } else {
      @raylib.draw_text("default font", 315, 40, 30, @raylib.gray)
    }

    @raylib.draw_text(
      "FONT SIZE: 16.0",
      @raylib.get_screen_width() - 240,
      20,
      20,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "RENDER SIZE: " + font_size.to_string(),
      @raylib.get_screen_width() - 240,
      50,
      20,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "Use MOUSE WHEEL to SCALE TEXT!",
      @raylib.get_screen_width() - 240,
      90,
      10,
      @raylib.darkgray,
    )

    @raylib.draw_text(
      "HOLD SPACE to USE SDF FONT VERSION!",
      340,
      @raylib.get_screen_height() - 30,
      20,
      @raylib.maroon,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_font(font_default) // Default font unloading
  @raylib.unload_font(font_sdf) // SDF font unloading
  @raylib.unload_shader(shader) // Unload SDF shader
  @raylib.close_window() // Close window and OpenGL context
}
