///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_textures_logo_raylib")

  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - texture loading and drawing",
  )

  // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  let texture = @raylib.load_texture("resources/raylib_logo.png")

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
    @raylib.draw_text("this IS a texture!", 360, 370, 10, @raylib.gray)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.close_window()
}
