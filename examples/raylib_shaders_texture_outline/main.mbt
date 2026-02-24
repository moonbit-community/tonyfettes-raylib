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
fn vec2_to_bytes(x : Float, y : Float) -> Bytes {
  let arr = FixedArray::make(8, b'\x00')
  let bx = x.reinterpret_as_int()
  arr[0] = (bx & 0xFF).to_byte()
  arr[1] = ((bx >> 8) & 0xFF).to_byte()
  arr[2] = ((bx >> 16) & 0xFF).to_byte()
  arr[3] = ((bx >> 24) & 0xFF).to_byte()
  let by = y.reinterpret_as_int()
  arr[4] = (by & 0xFF).to_byte()
  arr[5] = ((by >> 8) & 0xFF).to_byte()
  arr[6] = ((by >> 16) & 0xFF).to_byte()
  arr[7] = ((by >> 24) & 0xFF).to_byte()
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

///|
fn vec4_to_bytes(x : Float, y : Float, z : Float, w : Float) -> Bytes {
  let arr = FixedArray::make(16, b'\x00')
  let bx = x.reinterpret_as_int()
  arr[0] = (bx & 0xFF).to_byte()
  arr[1] = ((bx >> 8) & 0xFF).to_byte()
  arr[2] = ((bx >> 16) & 0xFF).to_byte()
  arr[3] = ((bx >> 24) & 0xFF).to_byte()
  let by = y.reinterpret_as_int()
  arr[4] = (by & 0xFF).to_byte()
  arr[5] = ((by >> 8) & 0xFF).to_byte()
  arr[6] = ((by >> 16) & 0xFF).to_byte()
  arr[7] = ((by >> 24) & 0xFF).to_byte()
  let bz = z.reinterpret_as_int()
  arr[8] = (bz & 0xFF).to_byte()
  arr[9] = ((bz >> 8) & 0xFF).to_byte()
  arr[10] = ((bz >> 16) & 0xFF).to_byte()
  arr[11] = ((bz >> 24) & 0xFF).to_byte()
  let bw = w.reinterpret_as_int()
  arr[12] = (bw & 0xFF).to_byte()
  arr[13] = ((bw >> 8) & 0xFF).to_byte()
  arr[14] = ((bw >> 16) & 0xFF).to_byte()
  arr[15] = ((bw >> 24) & 0xFF).to_byte()
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - Apply an outline to a texture",
  )
  let _ = @raylib.change_directory("examples/raylib_shaders_texture_outline")
  let texture = @raylib.load_texture("resources/fudesumi.png")
  let shdr_outline = @raylib.load_shader(
    "", "resources/shaders/glsl330/outline.fs",
  )
  let mut outline_size : Float = 2.0
  let outline_color = vec4_to_bytes(1.0, 0.0, 0.0, 1.0) // Normalized RED
  let tex_w = @raylib.get_texture_width(texture)
  let tex_h = @raylib.get_texture_height(texture)
  let texture_size = vec2_to_bytes(
    Float::from_int(tex_w),
    Float::from_int(tex_h),
  )
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
  @raylib.set_shader_value(
    shdr_outline,
    outline_size_loc,
    float_to_bytes(outline_size),
    @raylib.ShaderUniformFloat,
  )
  @raylib.set_shader_value(
    shdr_outline,
    outline_color_loc,
    outline_color,
    @raylib.ShaderUniformVec4,
  )
  @raylib.set_shader_value(
    shdr_outline,
    texture_size_loc,
    texture_size,
    @raylib.ShaderUniformVec2,
  )
  @raylib.set_target_fps(60)
  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    outline_size += @raylib.get_mouse_wheel_move()
    if outline_size < 1.0 {
      outline_size = 1.0
    }
    @raylib.set_shader_value(
      shdr_outline,
      outline_size_loc,
      float_to_bytes(outline_size),
      @raylib.ShaderUniformFloat,
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
