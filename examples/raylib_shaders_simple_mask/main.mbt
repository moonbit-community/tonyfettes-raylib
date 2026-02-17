///|
fn int_to_bytes(v : Int) -> Bytes {
  let arr = FixedArray::make(4, b'\x00')
  arr[0] = (v & 0xFF).to_byte()
  arr[1] = ((v >> 8) & 0xFF).to_byte()
  arr[2] = ((v >> 16) & 0xFF).to_byte()
  arr[3] = ((v >> 24) & 0xFF).to_byte()
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_shaders_simple_mask")
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - simple mask",
  )

  // Load the shader
  let shader = @raylib.load_shader("", "resources/shaders/glsl330/mask.fs")

  // Load textures
  let tex_diffuse = @raylib.load_texture("resources/plasma.png")
  let tex_mask = @raylib.load_texture("resources/mask.png")

  // Get shader locations
  let mask_loc = @raylib.get_shader_location(shader, "mask")
  let frame_loc = @raylib.get_shader_location(shader, "frame")

  // Hardcoded texture dimensions (Texture is opaque)
  let tex_width = 128
  let tex_height = 128

  let mut frames_counter = 0
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    frames_counter += 1

    // Send frames counter to shader for animation
    @raylib.set_shader_value(
      shader,
      frame_loc,
      int_to_bytes(frames_counter),
      @raylib.ShaderUniformInt,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.darkblue)

    // Set the mask texture on the shader's mask sampler
    @raylib.set_shader_value_texture(shader, mask_loc, tex_mask)

    // Draw the diffuse texture with the mask shader applied
    @raylib.begin_shader_mode(shader)
    // Draw center
    @raylib.draw_texture(
      tex_diffuse,
      screen_width / 2 - tex_width / 2,
      screen_height / 2 - tex_height / 2,
      @raylib.white,
    )
    // Draw a few more copies at different positions
    @raylib.draw_texture(
      tex_diffuse,
      screen_width / 2 - tex_width / 2 - 200,
      screen_height / 2 - tex_height / 2,
      @raylib.white,
    )
    @raylib.draw_texture(
      tex_diffuse,
      screen_width / 2 - tex_width / 2 + 200,
      screen_height / 2 - tex_height / 2,
      @raylib.white,
    )
    @raylib.end_shader_mode()
    @raylib.draw_text(
      "Frame: " + frames_counter.to_string(),
      20,
      screen_height - 40,
      20,
      @raylib.white,
    )
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(tex_diffuse)
  @raylib.unload_texture(tex_mask)
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
