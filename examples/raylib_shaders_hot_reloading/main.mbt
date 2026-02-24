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
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_shaders_hot_reloading")

  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - hot reloading",
  )

  let frag_shader_file = "resources/shaders/glsl330/reload.fs"
  let mut frag_shader_mod_time = @raylib.get_file_mod_time(frag_shader_file)

  // Load shader (empty string for vertex shader = use default)
  let mut shader = @raylib.load_shader("", frag_shader_file)

  // Get shader uniform locations
  let mut resolution_loc = @raylib.get_shader_location(shader, "resolution")
  let mut mouse_loc = @raylib.get_shader_location(shader, "mouse")
  let mut time_loc = @raylib.get_shader_location(shader, "time")

  // Set resolution uniform
  let resolution = @raylib.Vector2::new(
    Float::from_int(screen_width),
    Float::from_int(screen_height),
  )
  @raylib.set_shader_value(
    shader,
    resolution_loc,
    vec2_to_bytes(resolution),
    @raylib.ShaderUniformVec2,
  )

  let mut total_time : Float = 0.0
  let mut shader_auto_reloading = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    total_time += @raylib.get_frame_time()
    let mouse = @raylib.get_mouse_position()

    // Set shader uniforms
    @raylib.set_shader_value(
      shader,
      time_loc,
      float_to_bytes(total_time),
      @raylib.ShaderUniformFloat,
    )
    @raylib.set_shader_value(
      shader,
      mouse_loc,
      vec2_to_bytes(mouse),
      @raylib.ShaderUniformVec2,
    )

    // Hot shader reloading
    if shader_auto_reloading ||
      @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      let current_mod_time = @raylib.get_file_mod_time(frag_shader_file)
      if current_mod_time != frag_shader_mod_time {
        let updated_shader = @raylib.load_shader("", frag_shader_file)
        if @raylib.is_shader_valid(updated_shader) {
          @raylib.unload_shader(shader)
          shader = updated_shader
          resolution_loc = @raylib.get_shader_location(shader, "resolution")
          mouse_loc = @raylib.get_shader_location(shader, "mouse")
          time_loc = @raylib.get_shader_location(shader, "time")
          @raylib.set_shader_value(
            shader,
            resolution_loc,
            vec2_to_bytes(resolution),
            @raylib.ShaderUniformVec2,
          )
        }
        frag_shader_mod_time = current_mod_time
      }
    }

    if @raylib.is_key_pressed(@raylib.KeyA) {
      shader_auto_reloading = not(shader_auto_reloading)
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_shader_mode(shader)
    @raylib.draw_rectangle(0, 0, screen_width, screen_height, @raylib.white)
    @raylib.end_shader_mode()

    let auto_text = if shader_auto_reloading { "AUTO" } else { "MANUAL" }
    let auto_color = if shader_auto_reloading {
      @raylib.red
    } else {
      @raylib.black
    }
    @raylib.draw_text(
      "PRESS [A] to TOGGLE SHADER AUTOLOADING: \{auto_text}",
      10,
      10,
      10,
      auto_color,
    )
    if not(shader_auto_reloading) {
      @raylib.draw_text(
        "MOUSE CLICK to SHADER RE-LOADING", 10, 30, 10, @raylib.black,
      )
    }
    @raylib.draw_text(
      "Shader last modification: \{frag_shader_mod_time}",
      10,
      430,
      10,
      @raylib.black,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
