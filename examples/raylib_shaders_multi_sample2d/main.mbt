///|
fn float_to_bytes(v : Float) -> Bytes {
  let arr = FixedArray::make(4, b'\x00')
  let bits = v.reinterpret_as_int()
  arr[0] = (bits & 0xFF).to_byte()
  arr[1] = ((bits >> 8) & 0xFF).to_byte()
  arr[2] = ((bits >> 16) & 0xFF).to_byte()
  arr[3] = ((bits >> 24) & 0xFF).to_byte()
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(screen_width, screen_height, "raylib - multiple sample2D")
  let _ = @raylib.change_directory("examples/raylib_shaders_multi_sample2d")
  let im_red = @raylib.gen_image_color(
    800,
    450,
    @raylib.Color::new(255, 0, 0, 255),
  )
  let tex_red = @raylib.load_texture_from_image(im_red)
  @raylib.unload_image(im_red)
  let im_blue = @raylib.gen_image_color(
    800,
    450,
    @raylib.Color::new(0, 0, 255, 255),
  )
  let tex_blue = @raylib.load_texture_from_image(im_blue)
  @raylib.unload_image(im_blue)
  let shader = @raylib.load_shader("", "resources/shaders/glsl330/color_mix.fs")
  // Get an additional sampler2D location to be enabled on drawing
  let tex_blue_loc = @raylib.get_shader_location(shader, "texture1")
  // Get shader uniform for divider
  let divider_loc = @raylib.get_shader_location(shader, "divider")
  let mut divider_value : Float = 0.5
  @raylib.set_target_fps(60)
  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_down(@raylib.KeyRight) {
      divider_value += 0.01
    } else if @raylib.is_key_down(@raylib.KeyLeft) {
      divider_value -= 0.01
    }
    if divider_value < 0.0 {
      divider_value = 0.0
    } else if divider_value > 1.0 {
      divider_value = 1.0
    }
    @raylib.set_shader_value(
      shader,
      divider_loc,
      float_to_bytes(divider_value),
      @raylib.ShaderUniformFloat,
    )
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_shader_mode(shader)
    // Additional samplers are enabled for all draw calls in the batch
    @raylib.set_shader_value_texture(shader, tex_blue_loc, tex_blue)
    // We are drawing texRed using default sampler2D texture0
    // but an additional texture unit is enabled for texBlue (sampler2D texture1)
    @raylib.draw_texture(tex_red, 0, 0, @raylib.white)
    @raylib.end_shader_mode()
    @raylib.draw_text(
      "Use KEY_LEFT/KEY_RIGHT to move texture mixing in shader!",
      80,
      @raylib.get_screen_height() - 40,
      20,
      @raylib.raywhite,
    )
    @raylib.end_drawing()
  }
  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.unload_texture(tex_red)
  @raylib.unload_texture(tex_blue)
  @raylib.close_window()
}
