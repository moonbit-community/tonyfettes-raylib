///|
fn main {
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("shaders/shaders_hot_reloading")

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
  shader.set_value(resolution_loc, @raylib.ShaderUniformData::Vec2(resolution))

  let mut total_time : Float = 0.0
  let mut shader_auto_reloading = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    total_time += @raylib.get_frame_time()
    let mouse = @raylib.get_mouse_position()

    // Set shader uniforms
    shader.set_value(time_loc, @raylib.ShaderUniformData::Float(total_time))
    shader.set_value(mouse_loc, @raylib.ShaderUniformData::Vec2(mouse))

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
          shader.set_value(
            resolution_loc,
            @raylib.ShaderUniformData::Vec2(resolution),
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
