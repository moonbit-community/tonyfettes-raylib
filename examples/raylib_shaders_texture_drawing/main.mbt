///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - texture drawing",
  )
  let _ = @raylib.change_directory("raylib_shaders_texture_drawing")
  let im_blank = @raylib.gen_image_color(1024, 1024, @raylib.blank)
  let texture = @raylib.load_texture_from_image(im_blank)
  @raylib.unload_image(im_blank)
  // Load shader
  let shader = @raylib.load_shader(
    "", "resources/shaders/glsl330/cubes_panning.fs",
  )
  let mut time : Float = 0.0
  let time_loc = @raylib.get_shader_location(shader, "uTime")
  shader.set_value(
    time_loc,
    @raylib.ShaderUniformData::Float(time),
    )
  @raylib.set_target_fps(60)
  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    time = Float::from_double(@raylib.get_time())
    shader.set_value(
      time_loc,
      @raylib.ShaderUniformData::Float(time),
      )
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_shader_mode(shader)
    @raylib.draw_texture(texture, 0, 0, @raylib.white)
    @raylib.end_shader_mode()
    @raylib.draw_text(
      "BACKGROUND is PAINTED and ANIMATED on SHADER!", 10, 10, 20, @raylib.maroon,
    )
    @raylib.end_drawing()
  }
  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.unload_texture(texture)
  @raylib.close_window()
}
