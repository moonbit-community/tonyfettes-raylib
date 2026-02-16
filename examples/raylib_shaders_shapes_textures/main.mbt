///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_shaders_shapes_textures")

  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - shapes and textures shaders",
  )

  // Load shader (grayscale)
  let shader = @raylib.load_shader("", "resources/shaders/glsl330/grayscale.fs")

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw shapes without shader (normal colors)
    @raylib.draw_text("USING DEFAULT SHADER", 20, 40, 10, @raylib.red)
    @raylib.draw_circle(80, 120, 35.0, @raylib.darkblue)
    @raylib.draw_circle_gradient(80, 220, 60.0, @raylib.green, @raylib.skyblue)
    @raylib.draw_circle_lines(80, 340, 80.0, @raylib.darkblue)

    // Draw shapes with shader applied (grayscale)
    @raylib.begin_shader_mode(shader)
    @raylib.draw_text("USING CUSTOM SHADER", 190, 40, 10, @raylib.red)
    @raylib.draw_rectangle(190, 90, 120, 60, @raylib.red)
    @raylib.draw_rectangle_gradient_h(
      160, 170, 180, 130, @raylib.maroon, @raylib.gold,
    )
    @raylib.draw_rectangle_lines(210, 320, 80, 60, @raylib.orange)
    @raylib.end_shader_mode()

    // Draw more shapes without shader
    @raylib.draw_text("USING DEFAULT SHADER", 370, 40, 10, @raylib.red)
    @raylib.draw_triangle(
      @raylib.Vector2::new(430.0, 80.0),
      @raylib.Vector2::new(370.0, 150.0),
      @raylib.Vector2::new(490.0, 150.0),
      @raylib.violet,
    )
    @raylib.draw_triangle_lines(
      @raylib.Vector2::new(430.0, 160.0),
      @raylib.Vector2::new(410.0, 230.0),
      @raylib.Vector2::new(450.0, 230.0),
      @raylib.darkblue,
    )
    @raylib.draw_poly(
      @raylib.Vector2::new(430.0, 320.0),
      6,
      80.0,
      0.0,
      @raylib.brown,
    )

    // Draw rectangle with shader
    @raylib.begin_shader_mode(shader)
    @raylib.draw_rectangle(550, 100, 200, 300, @raylib.blue)
    @raylib.end_shader_mode()

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
