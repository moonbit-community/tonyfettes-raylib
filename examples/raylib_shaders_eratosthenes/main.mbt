///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_shaders_eratosthenes")
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - eratosthenes sieve",
  )

  let target = @raylib.load_render_texture(screen_width, screen_height)

  // Load Eratosthenes shader
  // NOTE: Defining empty string for vertex shader forces usage of internal default vertex shader
  let shader = @raylib.load_shader(
    "", "resources/shaders/glsl330/eratosthenes.fs",
  )
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_texture_mode(target)
    @raylib.clear_background(@raylib.black)
    // Draw a rectangle in shader mode to be used as shader canvas
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
      @raylib.black,
    )
    @raylib.end_texture_mode()
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    // Draw fullscreen rectangle with shader applied
    @raylib.begin_shader_mode(shader)
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
      @raylib.white,
    )
    @raylib.end_shader_mode()
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.unload_render_texture(target)
  @raylib.close_window()
}
