///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_text_font_spritefont")
  @raylib.init_window(
    screen_width, screen_height, "raylib [text] example - sprite font loading",
  )

  let msg1 = "THIS IS A custom SPRITE FONT..."
  let msg2 = "...and this is ANOTHER CUSTOM font..."
  let msg3 = "...and a THIRD one! GREAT! :D"

  // NOTE: Textures/Fonts MUST be loaded after Window initialization (OpenGL context is required)
  let font1 = @raylib.load_font("resources/custom_mecha.png")
  let font2 = @raylib.load_font("resources/custom_alagard.png")
  let font3 = @raylib.load_font("resources/custom_jupiter_crash.png")

  let base_size1 = Float::from_int(@raylib.get_font_base_size(font1))
  let base_size2 = Float::from_int(@raylib.get_font_base_size(font2))
  let base_size3 = Float::from_int(@raylib.get_font_base_size(font3))

  let sw = Float::from_int(screen_width)
  let sh = Float::from_int(screen_height)

  let font_position1 = @raylib.Vector2::new(
    sw / 2.0 - @raylib.measure_text_ex(font1, msg1, base_size1, -3.0).x / 2.0,
    sh / 2.0 - base_size1 / 2.0 - 80.0,
  )
  let font_position2 = @raylib.Vector2::new(
    sw / 2.0 - @raylib.measure_text_ex(font2, msg2, base_size2, -2.0).x / 2.0,
    sh / 2.0 - base_size2 / 2.0 - 10.0,
  )
  let font_position3 = @raylib.Vector2::new(
    sw / 2.0 - @raylib.measure_text_ex(font3, msg3, base_size3, 2.0).x / 2.0,
    sh / 2.0 - base_size3 / 2.0 + 50.0,
  )

  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // TODO: Update variables here...

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text_ex(
      font1, msg1, font_position1, base_size1, -3.0, @raylib.white,
    )
    @raylib.draw_text_ex(
      font2, msg2, font_position2, base_size2, -2.0, @raylib.white,
    )
    @raylib.draw_text_ex(
      font3, msg3, font_position3, base_size3, 2.0, @raylib.white,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_font(font1)
  @raylib.unload_font(font2)
  @raylib.unload_font(font3)
  @raylib.close_window() // Close window and OpenGL context
}
