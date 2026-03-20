///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - Apply an outline to a texture",
  )
  let _ = @raylib.change_directory("shaders/shaders_texture_outline")
  let texture = @raylib.load_texture("resources/fudesumi.png")
  let shdr_outline = @raylib.load_shader(
    "", "resources/shaders/glsl330/outline.fs",
  )
  let mut outline_size : Float = 2.0
  let tex_w = @raylib.get_texture_width(texture)
  let tex_h = @raylib.get_texture_height(texture)
  // Get shader locations
  let outline_size_loc = @raylib.get_shader_location(
    shdr_outline, "outlineSize",
  )
  let outline_color_loc = @raylib.get_shader_location(
    shdr_outline, "outlineColor",
  )
  let texture_size_loc = @raylib.get_shader_location(
    shdr_outline, "textureSize",
  )
  // Set shader values
  shdr_outline.set_value(
    outline_size_loc,
    @raylib.ShaderUniformData::Float(outline_size),
  )
  shdr_outline.set_value(
    outline_color_loc,
    @raylib.ShaderUniformData::Vec4(@raylib.Vector4::new(1.0, 0.0, 0.0, 1.0)),
  )
  shdr_outline.set_value(
    texture_size_loc,
    @raylib.ShaderUniformData::Vec2(
      @raylib.Vector2::new(Float::from_int(tex_w), Float::from_int(tex_h)),
    ),
  )
  @raylib.set_target_fps(60)
  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    outline_size += @raylib.get_mouse_wheel_move()
    if outline_size < 1.0 {
      outline_size = 1.0
    }
    shdr_outline.set_value(
      outline_size_loc,
      @raylib.ShaderUniformData::Float(outline_size),
    )
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_shader_mode(shdr_outline)
    @raylib.draw_texture(
      texture,
      @raylib.get_screen_width() / 2 - tex_w / 2,
      -30,
      @raylib.white,
    )
    @raylib.end_shader_mode()
    @raylib.draw_text(
      "Shader-based\ntexture\noutline", 10, 10, 20, @raylib.gray,
    )
    @raylib.draw_text(
      "Scroll mouse wheel to\nchange outline size", 10, 72, 20, @raylib.gray,
    )
    @raylib.draw_text(
      "Outline size: " + outline_size.to_int().to_string() + " px",
      10,
      120,
      20,
      @raylib.maroon,
    )
    @raylib.draw_fps(710, 10)
    @raylib.end_drawing()
  }
  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.unload_shader(shdr_outline)
  @raylib.close_window()
}
