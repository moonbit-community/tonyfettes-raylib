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
fn vec2_to_bytes(v : @raylib.Vector2) -> Bytes {
  v.to_bytes()
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_shaders_texture_waves")

  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - texture waves",
  )

  // Load shader and setup location points and values
  let shader = @raylib.load_shader("", "resources/shaders/glsl330/wave.fs")

  let seconds_loc = @raylib.get_shader_location(shader, "seconds")
  let freq_x_loc = @raylib.get_shader_location(shader, "freqX")
  let freq_y_loc = @raylib.get_shader_location(shader, "freqY")
  let amp_x_loc = @raylib.get_shader_location(shader, "ampX")
  let amp_y_loc = @raylib.get_shader_location(shader, "ampY")
  let speed_x_loc = @raylib.get_shader_location(shader, "speedX")
  let speed_y_loc = @raylib.get_shader_location(shader, "speedY")

  // Shader uniform values
  let freq_x : Float = 25.0
  let freq_y : Float = 25.0
  let amp_x : Float = 5.0
  let amp_y : Float = 5.0
  let speed_x : Float = 8.0
  let speed_y : Float = 8.0

  let screen_size = @raylib.Vector2::new(
    Float::from_int(@raylib.get_screen_width()),
    Float::from_int(@raylib.get_screen_height()),
  )
  @raylib.set_shader_value(
    shader,
    @raylib.get_shader_location(shader, "size"),
    vec2_to_bytes(screen_size),
    @raylib.ShaderUniformVec2,
  )
  @raylib.set_shader_value(
    shader,
    freq_x_loc,
    float_to_bytes(freq_x),
    @raylib.ShaderUniformFloat,
  )
  @raylib.set_shader_value(
    shader,
    freq_y_loc,
    float_to_bytes(freq_y),
    @raylib.ShaderUniformFloat,
  )
  @raylib.set_shader_value(
    shader,
    amp_x_loc,
    float_to_bytes(amp_x),
    @raylib.ShaderUniformFloat,
  )
  @raylib.set_shader_value(
    shader,
    amp_y_loc,
    float_to_bytes(amp_y),
    @raylib.ShaderUniformFloat,
  )
  @raylib.set_shader_value(
    shader,
    speed_x_loc,
    float_to_bytes(speed_x),
    @raylib.ShaderUniformFloat,
  )
  @raylib.set_shader_value(
    shader,
    speed_y_loc,
    float_to_bytes(speed_y),
    @raylib.ShaderUniformFloat,
  )

  let mut seconds : Float = 0.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    seconds = seconds + @raylib.get_frame_time()
    @raylib.set_shader_value(
      shader,
      seconds_loc,
      float_to_bytes(seconds),
      @raylib.ShaderUniformFloat,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_shader_mode(shader)
    // Draw a colored rectangle as a substitute for a texture
    @raylib.draw_rectangle(0, 0, screen_width, screen_height, @raylib.blue)
    // Draw grid-like pattern to make wave effect visible
    for i = 0; i < screen_width / 20; i = i + 1 {
      @raylib.draw_line(i * 20, 0, i * 20, screen_height, @raylib.darkblue)
    }
    for i = 0; i < screen_height / 20; i = i + 1 {
      @raylib.draw_line(0, i * 20, screen_width, i * 20, @raylib.darkblue)
    }
    @raylib.draw_rectangle(100, 100, 600, 250, @raylib.skyblue)
    @raylib.draw_text("WAVE SHADER EFFECT", 250, 200, 30, @raylib.white)
    @raylib.end_shader_mode()

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
