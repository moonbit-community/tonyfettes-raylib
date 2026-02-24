///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_textures_image_text")
  @raylib.init_window(
    screen_width, screen_height, "raylib [texture] example - image text drawing",
  )

  let parrots = @raylib.load_image("resources/parrots.png") // Load image in CPU memory (RAM)

  // TTF Font loading with custom generation parameters
  let font = @raylib.load_font_ex("resources/KAISG.ttf", 64)

  // Draw over image using custom font
  @raylib.image_draw_text_ex(
    parrots,
    font,
    "[Parrots font drawing]",
    @raylib.Vector2::new(20.0, 20.0),
    64.0,
    0.0,
    @raylib.red,
  )

  let texture = @raylib.load_texture_from_image(parrots) // Image converted to texture, uploaded to GPU memory (VRAM)
  @raylib.unload_image(parrots) // Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

  // parrots.png: 512x384
  let tex_width = 512
  let tex_height = 384
  let position = @raylib.Vector2::new(
    Float::from_int(screen_width / 2 - tex_width / 2),
    Float::from_int(screen_height / 2 - tex_height / 2 - 20),
  )

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw texture with text already drawn inside
    @raylib.draw_texture_v(texture, position, @raylib.white)

    // Draw text directly using sprite font
    @raylib.draw_text_ex(
      font,
      "[Parrots font drawing]",
      @raylib.Vector2::new(position.x + 20.0, position.y + 20.0 + 280.0),
      64.0,
      0.0,
      @raylib.white,
    )

    @raylib.draw_text(
      "PRESS SPACE to SHOW FONT ATLAS USED", 290, 420, 10, @raylib.darkgray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.unload_font(font)
  @raylib.close_window()
}
