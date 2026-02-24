///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_textures_image_loading")

  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - image loading",
  )

  // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  let image = @raylib.load_image("resources/raylib_logo.png") // Loaded in CPU memory (RAM)
  let texture = @raylib.load_texture_from_image(image) // Image converted to texture, GPU memory (VRAM)
  @raylib.unload_image(image) // Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // TODO: Update your variables here

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_texture(
      texture,
      screen_width / 2 - 256 / 2,
      screen_height / 2 - 256 / 2,
      @raylib.white,
    )
    @raylib.draw_text(
      "this IS a texture loaded from an image!", 300, 370, 10, @raylib.gray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.close_window()
}
