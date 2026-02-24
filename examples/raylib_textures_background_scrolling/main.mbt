///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory(
    "examples/raylib_textures_background_scrolling",
  )
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - background scrolling",
  )

  // NOTE: Be careful, background width must be equal or bigger than screen width
  // if not, texture should be drawn more than two times for scrolling effect
  let background = @raylib.load_texture(
    "resources/cyberpunk_street_background.png",
  )
  let midground = @raylib.load_texture(
    "resources/cyberpunk_street_midground.png",
  )
  let foreground = @raylib.load_texture(
    "resources/cyberpunk_street_foreground.png",
  )

  // Texture dimensions (scaled 2x): background 512, midground 512, foreground 704
  let background_width : Float = 512.0
  let midground_width : Float = 512.0
  let foreground_width : Float = 704.0

  let mut scrolling_back : Float = 0.0
  let mut scrolling_mid : Float = 0.0
  let mut scrolling_fore : Float = 0.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    scrolling_back -= 0.1
    scrolling_mid -= 0.5
    scrolling_fore -= 1.0

    // NOTE: Texture is scaled twice its size, so it should be considered on scrolling
    if scrolling_back <= -(background_width * 2.0) {
      scrolling_back = 0.0
    }
    if scrolling_mid <= -(midground_width * 2.0) {
      scrolling_mid = 0.0
    }
    if scrolling_fore <= -(foreground_width * 2.0) {
      scrolling_fore = 0.0
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.get_color(0x052c46ff))

    // Draw background image twice
    // NOTE: Texture is scaled twice its size
    @raylib.draw_texture_ex(
      background,
      @raylib.Vector2::new(scrolling_back, 20.0),
      0.0,
      2.0,
      @raylib.white,
    )
    @raylib.draw_texture_ex(
      background,
      @raylib.Vector2::new(background_width * 2.0 + scrolling_back, 20.0),
      0.0,
      2.0,
      @raylib.white,
    )

    // Draw midground image twice
    @raylib.draw_texture_ex(
      midground,
      @raylib.Vector2::new(scrolling_mid, 20.0),
      0.0,
      2.0,
      @raylib.white,
    )
    @raylib.draw_texture_ex(
      midground,
      @raylib.Vector2::new(midground_width * 2.0 + scrolling_mid, 20.0),
      0.0,
      2.0,
      @raylib.white,
    )

    // Draw foreground image twice
    @raylib.draw_texture_ex(
      foreground,
      @raylib.Vector2::new(scrolling_fore, 70.0),
      0.0,
      2.0,
      @raylib.white,
    )
    @raylib.draw_texture_ex(
      foreground,
      @raylib.Vector2::new(foreground_width * 2.0 + scrolling_fore, 70.0),
      0.0,
      2.0,
      @raylib.white,
    )

    @raylib.draw_text(
      "BACKGROUND SCROLLING & PARALLAX", 10, 10, 20, @raylib.red,
    )
    @raylib.draw_text(
      "(c) Cyberpunk Street Environment by Luis Zuno (@ansimuz)",
      screen_width - 330,
      screen_height - 20,
      10,
      @raylib.raywhite,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(background)
  @raylib.unload_texture(midground)
  @raylib.unload_texture(foreground)
  @raylib.close_window()
}
