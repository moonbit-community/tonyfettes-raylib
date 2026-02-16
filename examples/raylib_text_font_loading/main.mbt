///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_text_font_loading")
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - font loading",
  )

  // Define characters to draw
  // NOTE: raylib supports UTF-8 encoding
  let msg = "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHI\nJKLMNOPQRSTUVWXYZ[]^_`abcdefghijklmn\nopqrstuvwxyz{|}~"

  // BMFont (AngelCode): Font data and image atlas have been generated using external program
  let font_bm = @raylib.load_font("resources/pixantiqua.fnt")

  // TTF font: Font data and atlas are generated directly from TTF
  // NOTE: We define a font base size of 32 pixels tall
  let font_ttf = @raylib.load_font_ex("resources/pixantiqua.ttf", 32)

  @raylib.set_text_line_spacing(16)

  // Font base sizes (BMFont pixantiqua is 32, TTF loaded at 32)
  let font_size : Float = 32.0

  let mut use_ttf = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_down(@raylib.KeySpace) {
      use_ttf = true
    } else {
      use_ttf = false
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text(
      "Hold SPACE to use TTF generated font", 20, 20, 20, @raylib.lightgray,
    )
    if not(use_ttf) {
      @raylib.draw_text_ex(
        font_bm,
        msg,
        @raylib.Vector2::new(20.0, 100.0),
        font_size,
        2.0,
        @raylib.maroon,
      )
      @raylib.draw_text(
        "Using BMFont (Angelcode) imported",
        20,
        @raylib.get_screen_height() - 30,
        20,
        @raylib.gray,
      )
    } else {
      @raylib.draw_text_ex(
        font_ttf,
        msg,
        @raylib.Vector2::new(20.0, 100.0),
        font_size,
        2.0,
        @raylib.lime,
      )
      @raylib.draw_text(
        "Using TTF font generated",
        20,
        @raylib.get_screen_height() - 30,
        20,
        @raylib.gray,
      )
    }
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_font(font_bm)
  @raylib.unload_font(font_ttf)
  @raylib.close_window()
}
