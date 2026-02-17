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

  let _ = @raylib.change_directory("examples/raylib_shaders_julia_set")

  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - julia set",
  )

  // Points of interest for the Julia set
  let points_of_interest : Array[@raylib.Vector2] = [
    @raylib.Vector2::new(-0.348827, 0.607167),
    @raylib.Vector2::new(-0.786268, 0.169728),
    @raylib.Vector2::new(-0.8, 0.156),
    @raylib.Vector2::new(0.285, 0.0),
    @raylib.Vector2::new(-0.835, -0.2321),
    @raylib.Vector2::new(-0.70176, -0.3842),
  ]

  let zoom_speed : Float = 1.01
  let offset_speed_mul : Float = 2.0
  let starting_zoom : Float = 0.75

  // Load Julia set shader
  let shader = @raylib.load_shader("", "resources/shaders/glsl330/julia_set.fs")

  // Create a RenderTexture
  let target = @raylib.load_render_texture(
    @raylib.get_screen_width(),
    @raylib.get_screen_height(),
  )

  // Initialize shader uniforms
  let mut c_x : Float = points_of_interest[0].x
  let mut c_y : Float = points_of_interest[0].y
  let mut offset_x : Float = 0.0
  let mut offset_y : Float = 0.0
  let mut zoom : Float = starting_zoom

  let c_loc = @raylib.get_shader_location(shader, "c")
  let zoom_loc = @raylib.get_shader_location(shader, "zoom")
  let offset_loc = @raylib.get_shader_location(shader, "offset")

  @raylib.set_shader_value(
    shader,
    c_loc,
    vec2_to_bytes(@raylib.Vector2::new(c_x, c_y)),
    @raylib.ShaderUniformVec2,
  )
  @raylib.set_shader_value(
    shader,
    zoom_loc,
    float_to_bytes(zoom),
    @raylib.ShaderUniformFloat,
  )
  @raylib.set_shader_value(
    shader,
    offset_loc,
    vec2_to_bytes(@raylib.Vector2::new(offset_x, offset_y)),
    @raylib.ShaderUniformVec2,
  )

  let mut increment_speed = 0
  let mut show_controls = true

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update - select point of interest
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      c_x = points_of_interest[0].x
      c_y = points_of_interest[0].y
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_bytes(@raylib.Vector2::new(c_x, c_y)),
        @raylib.ShaderUniformVec2,
      )
    } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
      c_x = points_of_interest[1].x
      c_y = points_of_interest[1].y
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_bytes(@raylib.Vector2::new(c_x, c_y)),
        @raylib.ShaderUniformVec2,
      )
    } else if @raylib.is_key_pressed(@raylib.KeyThree) {
      c_x = points_of_interest[2].x
      c_y = points_of_interest[2].y
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_bytes(@raylib.Vector2::new(c_x, c_y)),
        @raylib.ShaderUniformVec2,
      )
    } else if @raylib.is_key_pressed(@raylib.KeyFour) {
      c_x = points_of_interest[3].x
      c_y = points_of_interest[3].y
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_bytes(@raylib.Vector2::new(c_x, c_y)),
        @raylib.ShaderUniformVec2,
      )
    } else if @raylib.is_key_pressed(@raylib.KeyFive) {
      c_x = points_of_interest[4].x
      c_y = points_of_interest[4].y
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_bytes(@raylib.Vector2::new(c_x, c_y)),
        @raylib.ShaderUniformVec2,
      )
    } else if @raylib.is_key_pressed(@raylib.KeySix) {
      c_x = points_of_interest[5].x
      c_y = points_of_interest[5].y
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_bytes(@raylib.Vector2::new(c_x, c_y)),
        @raylib.ShaderUniformVec2,
      )
    }

    // Reset view
    if @raylib.is_key_pressed(@raylib.KeyR) {
      zoom = starting_zoom
      offset_x = 0.0
      offset_y = 0.0
      @raylib.set_shader_value(
        shader,
        zoom_loc,
        float_to_bytes(zoom),
        @raylib.ShaderUniformFloat,
      )
      @raylib.set_shader_value(
        shader,
        offset_loc,
        vec2_to_bytes(@raylib.Vector2::new(offset_x, offset_y)),
        @raylib.ShaderUniformVec2,
      )
    }

    if @raylib.is_key_pressed(@raylib.KeySpace) {
      increment_speed = 0
    }
    if @raylib.is_key_pressed(@raylib.KeyF1) {
      show_controls = not(show_controls)
    }

    if @raylib.is_key_pressed(@raylib.KeyRight) {
      increment_speed = increment_speed + 1
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) {
      increment_speed = increment_speed - 1
    }

    // Zoom and pan with mouse
    if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
      @raylib.is_mouse_button_down(@raylib.MouseButtonRight) {
      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        zoom = zoom * zoom_speed
      } else {
        zoom = zoom * ((1.0 : Float) / zoom_speed)
      }

      let mouse_pos = @raylib.get_mouse_position()
      let offset_velocity_x = (
          mouse_pos.x / Float::from_int(screen_width) - 0.5
        ) *
        offset_speed_mul /
        zoom
      let offset_velocity_y = (
          mouse_pos.y / Float::from_int(screen_height) - 0.5
        ) *
        offset_speed_mul /
        zoom

      offset_x = offset_x + @raylib.get_frame_time() * offset_velocity_x
      offset_y = offset_y + @raylib.get_frame_time() * offset_velocity_y

      @raylib.set_shader_value(
        shader,
        zoom_loc,
        float_to_bytes(zoom),
        @raylib.ShaderUniformFloat,
      )
      @raylib.set_shader_value(
        shader,
        offset_loc,
        vec2_to_bytes(@raylib.Vector2::new(offset_x, offset_y)),
        @raylib.ShaderUniformVec2,
      )
    }

    // Animate c parameter
    let dc = @raylib.get_frame_time() *
      Float::from_int(increment_speed) *
      0.0005
    c_x = c_x + dc
    c_y = c_y + dc
    @raylib.set_shader_value(
      shader,
      c_loc,
      vec2_to_bytes(@raylib.Vector2::new(c_x, c_y)),
      @raylib.ShaderUniformVec2,
    )

    // Draw
    @raylib.begin_texture_mode(target)
    @raylib.clear_background(@raylib.black)
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
      @raylib.black,
    )
    @raylib.end_texture_mode()

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.black)

    // Draw render texture with julia set shader
    @raylib.begin_shader_mode(shader)
    @raylib.draw_render_texture_ex(
      target,
      @raylib.Vector2::new(0.0, 0.0),
      0.0,
      1.0,
      @raylib.white,
    )
    @raylib.end_shader_mode()

    if show_controls {
      @raylib.draw_text(
        "Press Mouse buttons right/left to zoom in/out and move", 10, 15, 10, @raylib.raywhite,
      )
      @raylib.draw_text(
        "Press KEY_F1 to toggle these controls", 10, 30, 10, @raylib.raywhite,
      )
      @raylib.draw_text(
        "Press KEYS [1 - 6] to change point of interest", 10, 45, 10, @raylib.raywhite,
      )
      @raylib.draw_text(
        "Press KEY_LEFT | KEY_RIGHT to change speed", 10, 60, 10, @raylib.raywhite,
      )
      @raylib.draw_text(
        "Press KEY_SPACE to stop movement animation", 10, 75, 10, @raylib.raywhite,
      )
      @raylib.draw_text(
        "Press KEY_R to recenter the camera", 10, 90, 10, @raylib.raywhite,
      )
    }
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.unload_render_texture(target)
  @raylib.close_window()
}
