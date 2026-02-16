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
fn vec2_to_uniform_bytes(x : Float, y : Float) -> Bytes {
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
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_shaders_julia_set")
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - julia set",
  )

  // A few good julia sets
  let points_of_interest : Array[(Float, Float)] = [
    (-0.348827, 0.607167),
    (-0.786268, 0.169728),
    (-0.8, 0.156),
    (0.285, 0.0),
    (-0.835, -0.2321),
    (-0.70176, -0.3842),
  ]

  let zoom_speed : Float = 1.01
  let offset_speed_mul : Float = 2.0
  let starting_zoom : Float = 0.75

  // Load julia set shader
  // NOTE: Defining empty string for vertex shader forces usage of internal default vertex shader
  let shader = @raylib.load_shader("", "resources/shaders/glsl330/julia_set.fs")

  // Create a RenderTexture2D to be used for render to texture
  let target = @raylib.load_render_texture(
    @raylib.get_screen_width(),
    @raylib.get_screen_height(),
  )

  // c constant to use in z^2 + c
  let mut c_x : Float = points_of_interest[0].0
  let mut c_y : Float = points_of_interest[0].1

  // Offset and zoom to draw the julia set at (centered on screen and default size)
  let mut offset_x : Float = 0.0
  let mut offset_y : Float = 0.0
  let mut zoom : Float = starting_zoom

  // Get variable (uniform) locations on the shader
  let c_loc = @raylib.get_shader_location(shader, "c")
  let zoom_loc = @raylib.get_shader_location(shader, "zoom")
  let offset_loc = @raylib.get_shader_location(shader, "offset")

  // Upload the shader uniform values
  @raylib.set_shader_value(
    shader,
    c_loc,
    vec2_to_uniform_bytes(c_x, c_y),
    @raylib.shader_uniform_vec2,
  )
  @raylib.set_shader_value(
    shader,
    zoom_loc,
    float_to_bytes(zoom),
    @raylib.shader_uniform_float,
  )
  @raylib.set_shader_value(
    shader,
    offset_loc,
    vec2_to_uniform_bytes(offset_x, offset_y),
    @raylib.shader_uniform_vec2,
  )

  let mut increment_speed = 0
  let mut show_controls = true
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Press [1 - 6] to reset c to a point of interest
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      c_x = points_of_interest[0].0
      c_y = points_of_interest[0].1
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_uniform_bytes(c_x, c_y),
        @raylib.shader_uniform_vec2,
      )
    } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
      c_x = points_of_interest[1].0
      c_y = points_of_interest[1].1
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_uniform_bytes(c_x, c_y),
        @raylib.shader_uniform_vec2,
      )
    } else if @raylib.is_key_pressed(@raylib.KeyThree) {
      c_x = points_of_interest[2].0
      c_y = points_of_interest[2].1
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_uniform_bytes(c_x, c_y),
        @raylib.shader_uniform_vec2,
      )
    } else if @raylib.is_key_pressed(@raylib.KeyFour) {
      c_x = points_of_interest[3].0
      c_y = points_of_interest[3].1
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_uniform_bytes(c_x, c_y),
        @raylib.shader_uniform_vec2,
      )
    } else if @raylib.is_key_pressed(@raylib.KeyFive) {
      c_x = points_of_interest[4].0
      c_y = points_of_interest[4].1
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_uniform_bytes(c_x, c_y),
        @raylib.shader_uniform_vec2,
      )
    } else if @raylib.is_key_pressed(@raylib.KeySix) {
      c_x = points_of_interest[5].0
      c_y = points_of_interest[5].1
      @raylib.set_shader_value(
        shader,
        c_loc,
        vec2_to_uniform_bytes(c_x, c_y),
        @raylib.shader_uniform_vec2,
      )
    }

    // If "R" is pressed, reset zoom and offset
    if @raylib.is_key_pressed(@raylib.KeyR) {
      zoom = starting_zoom
      offset_x = 0.0
      offset_y = 0.0
      @raylib.set_shader_value(
        shader,
        zoom_loc,
        float_to_bytes(zoom),
        @raylib.shader_uniform_float,
      )
      @raylib.set_shader_value(
        shader,
        offset_loc,
        vec2_to_uniform_bytes(offset_x, offset_y),
        @raylib.shader_uniform_vec2,
      )
    }

    // Pause animation (c change)
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      increment_speed = 0
    }

    // Toggle controls
    if @raylib.is_key_pressed(@raylib.KeyF1) {
      show_controls = not(show_controls)
    }

    if @raylib.is_key_pressed(@raylib.KeyRight) {
      increment_speed += 1
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) {
      increment_speed -= 1
    }

    // If either left or right button is pressed, zoom in/out
    if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
      @raylib.is_mouse_button_down(@raylib.MouseButtonRight) {
      // Change zoom. If Mouse left -> zoom in. Mouse right -> zoom out
      if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
        zoom = zoom * zoom_speed
      } else {
        zoom = zoom * (1.0 / zoom_speed)
      }
      let mouse_pos = @raylib.get_mouse_position()
      let sw = Float::from_int(screen_width)
      let sh = Float::from_int(screen_height)

      // Find the velocity at which to change the camera
      let offset_vel_x = (mouse_pos.x / sw - 0.5) * offset_speed_mul / zoom
      let offset_vel_y = (mouse_pos.y / sh - 0.5) * offset_speed_mul / zoom

      // Apply move velocity to camera
      let dt = @raylib.get_frame_time()
      offset_x = offset_x + dt * offset_vel_x
      offset_y = offset_y + dt * offset_vel_y

      // Update the shader uniform values
      @raylib.set_shader_value(
        shader,
        zoom_loc,
        float_to_bytes(zoom),
        @raylib.shader_uniform_float,
      )
      @raylib.set_shader_value(
        shader,
        offset_loc,
        vec2_to_uniform_bytes(offset_x, offset_y),
        @raylib.shader_uniform_vec2,
      )
    }

    // Increment c value with time
    let dc = @raylib.get_frame_time() *
      Float::from_int(increment_speed) *
      0.0005
    c_x = c_x + dc
    c_y = c_y + dc
    @raylib.set_shader_value(
      shader,
      c_loc,
      vec2_to_uniform_bytes(c_x, c_y),
      @raylib.shader_uniform_vec2,
    )

    // Draw
    // Using a render texture to draw Julia set
    @raylib.begin_texture_mode(target)
    @raylib.clear_background(@raylib.black)
    // Draw a rectangle in shader mode to be used as shader canvas
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
    // Draw the saved texture and rendered julia set with shader
    // NOTE: We draw a fullscreen rectangle with the shader applied directly
    @raylib.begin_shader_mode(shader)
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
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
