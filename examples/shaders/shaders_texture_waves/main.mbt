///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("shaders/shaders_texture_waves")

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
  shader.set_value(
    @raylib.get_shader_location(shader, "size"),
    @raylib.ShaderUniformData::Vec2(screen_size),
    )
  shader.set_value(
    freq_x_loc,
    @raylib.ShaderUniformData::Float(freq_x),
    )
  shader.set_value(
    freq_y_loc,
    @raylib.ShaderUniformData::Float(freq_y),
    )
  shader.set_value(
    amp_x_loc,
    @raylib.ShaderUniformData::Float(amp_x),
    )
  shader.set_value(
    amp_y_loc,
    @raylib.ShaderUniformData::Float(amp_y),
    )
  shader.set_value(
    speed_x_loc,
    @raylib.ShaderUniformData::Float(speed_x),
    )
  shader.set_value(
    speed_y_loc,
    @raylib.ShaderUniformData::Float(speed_y),
    )

  let mut seconds : Float = 0.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    seconds = seconds + @raylib.get_frame_time()
    shader.set_value(
      seconds_loc,
      @raylib.ShaderUniformData::Float(seconds),
      )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_shader_mode(shader)
    // Draw a colored rectangle as a substitute for a texture
    @raylib.draw_rectangle(0, 0, screen_width, screen_height, @raylib.blue)
    // Draw grid-like pattern to make wave effect visible
    for i in 0..<(screen_width / 20) {
      @raylib.draw_line(i * 20, 0, i * 20, screen_height, @raylib.darkblue)
    }
    for i in 0..<(screen_height / 20) {
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
