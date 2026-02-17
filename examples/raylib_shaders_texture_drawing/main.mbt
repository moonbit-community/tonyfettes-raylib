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
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - texture drawing",
  )
  let _ = @raylib.change_directory("examples/raylib_shaders_texture_drawing")
  let im_blank = @raylib.gen_image_color(1024, 1024, @raylib.blank)
  let texture = @raylib.load_texture_from_image(im_blank)
  @raylib.unload_image(im_blank)
  // Load shader
  let shader = @raylib.load_shader(
    "", "resources/shaders/glsl330/cubes_panning.fs",
  )
  let mut time : Float = 0.0
  let time_loc = @raylib.get_shader_location(shader, "uTime")
  @raylib.set_shader_value(
    shader,
    time_loc,
    float_to_bytes(time),
    @raylib.ShaderUniformFloat,
  )
  @raylib.set_target_fps(60)
  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    time = Float::from_double(@raylib.get_time())
    @raylib.set_shader_value(
      shader,
      time_loc,
      float_to_bytes(time),
      @raylib.ShaderUniformFloat,
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
