///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_text_raylib_fonts")
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - raylib fonts",
  )
  let max_fonts = 8

  // Load fonts
  let fonts : Array[@raylib.Font] = [
    @raylib.load_font("resources/fonts/alagard.png"),
    @raylib.load_font("resources/fonts/pixelplay.png"),
    @raylib.load_font("resources/fonts/mecha.png"),
    @raylib.load_font("resources/fonts/setback.png"),
    @raylib.load_font("resources/fonts/romulus.png"),
    @raylib.load_font("resources/fonts/pixantiqua.png"),
    @raylib.load_font("resources/fonts/alpha_beta.png"),
    @raylib.load_font("resources/fonts/jupiter_crash.png"),
  ]
  let messages : Array[String] = [
    "ALAGARD FONT designed by Hewett Tsoi", "PIXELPLAY FONT designed by Aleksander Shevchuk",
    "MECHA FONT designed by Captain Falcon", "SETBACK FONT designed by Brian Kent (AEnigma)",
    "ROMULUS FONT designed by Hewett Tsoi", "PIXANTIQUA FONT designed by Gerhard Grossmann",
    "ALPHA_BETA FONT designed by Brian Kent (AEnigma)", "JUPITER_CRASH FONT designed by Brian Kent (AEnigma)",
  ]
  let spacings : FixedArray[Float] = [2.0, 4.0, 8.0, 4.0, 3.0, 4.0, 4.0, 1.0]

  // Font base sizes for each pixel font (determined by the sprite image dimensions)
  let base_sizes : FixedArray[Float] = [
    16.0, 8.0, 16.0, 16.0, 16.0, 32.0, 16.0, 16.0,
  ]

  // Calculate positions using MeasureTextEx
  let positions : Array[@raylib.Vector2] = Array::make(
    max_fonts,
    @raylib.Vector2::new(0.0, 0.0),
  )
  for i = 0; i < max_fonts; i = i + 1 {
    let font_size = base_sizes[i] * 2.0
    let text_size = @raylib.measure_text_ex(
      fonts[i],
      messages[i],
      font_size,
      spacings[i],
    )
    positions[i] = @raylib.Vector2::new(
      Float::from_int(screen_width) / 2.0 - text_size.x / 2.0,
      60.0 + base_sizes[i] + 45.0 * Float::from_int(i),
    )
  }

  // Small Y position corrections
  positions[3] = @raylib.Vector2::new(positions[3].x, positions[3].y + 8.0)
  positions[4] = @raylib.Vector2::new(positions[4].x, positions[4].y + 2.0)
  positions[7] = @raylib.Vector2::new(positions[7].x, positions[7].y - 8.0)
  let colors : Array[@raylib.Color] = [
    @raylib.maroon, @raylib.orange, @raylib.darkgreen, @raylib.darkblue, @raylib.darkpurple,
    @raylib.lime, @raylib.gold, @raylib.red,
  ]
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text(
      "free fonts included with raylib", 250, 20, 20, @raylib.darkgray,
    )
    @raylib.draw_line(220, 50, 590, 50, @raylib.darkgray)
    for i = 0; i < max_fonts; i = i + 1 {
      @raylib.draw_text_ex(
        fonts[i],
        messages[i],
        positions[i],
        base_sizes[i] * 2.0,
        spacings[i],
        colors[i],
      )
    }
    @raylib.end_drawing()
  }

  // De-Initialization
  for i = 0; i < max_fonts; i = i + 1 {
    @raylib.unload_font(fonts[i])
  }
  @raylib.close_window()
}
