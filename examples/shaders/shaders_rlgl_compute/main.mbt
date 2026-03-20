// raylib [shaders] example - rlgl compute shader (Game of Life)
//
// WARNING: This example requires OpenGL 4.3+ for compute shader support.
//
// Ported from raylib's shaders_rlgl_compute.c example.
// Original by Teddy Astie (@tsnake41), reviewed by Ramon Santamaria (@raysan5).

// IMPORTANT: Must match GOL_WIDTH in the .glsl files.
// Must be a multiple of 16 (check golLogic compute dispatch).

///|
const GolWidth : Int = 768

///|
const MaxBufferedTransferts : Int = 48

// GolUpdateCmd: 4 x uint32 = 16 bytes
// GolUpdateSSBO layout (std430): uint count at offset 0, 12 bytes padding,
// then GolUpdateCmd array starting at offset 16.

///|
fn write_u32(buf : @raylib.UByteArray, offset : Int, value : UInt) -> Unit {
  buf[offset] = (value & 0xFFU).to_byte()
  buf[offset + 1] = ((value >> 8) & 0xFFU).to_byte()
  buf[offset + 2] = ((value >> 16) & 0xFFU).to_byte()
  buf[offset + 3] = ((value >> 24) & 0xFFU).to_byte()
}

///|
fn build_transfert_ssbo(
  commands : Array[(UInt, UInt, UInt, UInt)],
) -> @raylib.UByteArray {
  let total = 16 + MaxBufferedTransferts * 16
  let buf = @raylib.UByteArray::new(total)
  // Write count as little-endian uint32 at offset 0 (12 bytes padding follows)
  write_u32(buf, 0, commands.length().reinterpret_as_uint())
  // Write commands starting at offset 16
  for i, cmd in commands {
    let (x, y, w, enabled) = cmd
    let off = 16 + i * 16
    write_u32(buf, off, x)
    write_u32(buf, off + 4, y)
    write_u32(buf, off + 8, w)
    write_u32(buf, off + 12, enabled)
  }
  buf
}

///|
fn main {
  let screen_width = GolWidth
  let screen_height = GolWidth
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - rlgl compute",
  )
  let _ = @raylib.change_directory("shaders/shaders_rlgl_compute")

  // Game of Life logic compute shader
  let gol_logic_code = @raylib.load_file_text(
    "resources/shaders/glsl430/gol.glsl",
  )
  let gol_logic_shader = @rl.compile_shader(gol_logic_code, @rl.ComputeShader)
  let gol_logic_program = @rl.load_compute_shader_program(gol_logic_shader)

  // Game of Life render shader (fragment only)
  let gol_render_shader = @raylib.load_shader(
    "", "resources/shaders/glsl430/gol_render.glsl",
  )
  let res_uniform_loc = gol_render_shader.get_location("resolution")

  // Game of Life transfert compute shader (CPU<->GPU)
  let gol_transfert_code = @raylib.load_file_text(
    "resources/shaders/glsl430/gol_transfert.glsl",
  )
  let gol_transfert_shader = @rl.compile_shader(
    gol_transfert_code,
    @rl.ComputeShader,
  )
  let gol_transfert_program = @rl.load_compute_shader_program(
    gol_transfert_shader,
  )

  // Load shader storage buffer objects (SSBOs)
  let cell_size : UInt = 4U // sizeof(unsigned int)
  let grid_size = GolWidth.reinterpret_as_uint() *
    GolWidth.reinterpret_as_uint() *
    cell_size
  // GolUpdateSSBO: 16 bytes header + MaxBufferedTransferts * 16 bytes
  let transfert_ssbo_size = (16 + MaxBufferedTransferts * 16).reinterpret_as_uint()
  let mut ssbo_a = @rl.load_shader_buffer_empty(grid_size, @rl.DynamicCopy)
  let mut ssbo_b = @rl.load_shader_buffer_empty(grid_size, @rl.DynamicCopy)
  let ssbo_transfert = @rl.load_shader_buffer_empty(
    transfert_ssbo_size,
    @rl.DynamicCopy,
  )

  // Command buffer for mouse draw events
  let commands : Array[(UInt, UInt, UInt, UInt)] = []
  let mut brush_size = 8

  // White texture for rendering via fragment shader
  let white_image = @raylib.gen_image_color(GolWidth, GolWidth, @raylib.white)
  let white_tex = white_image.to_texture()
  white_image.unload()

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    brush_size += Float::to_int(@raylib.get_mouse_wheel_move())
    if brush_size < 1 {
      brush_size = 1
    }
    let mouse_left = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    let mouse_right = @raylib.is_mouse_button_down(@raylib.MouseButtonRight)
    if (mouse_left || mouse_right) && commands.length() < MaxBufferedTransferts {
      let mx = @raylib.get_mouse_x()
      let my = @raylib.get_mouse_y()
      let enabled : UInt = if mouse_left { 1U } else { 0U }
      commands.push(
        (
          (mx - brush_size / 2).reinterpret_as_uint(),
          (my - brush_size / 2).reinterpret_as_uint(),
          brush_size.reinterpret_as_uint(),
          enabled,
        ),
      )
    } else if commands.length() > 0 {
      // Send transfert buffer to GPU
      let ssbo_data = build_transfert_ssbo(commands)
      @rl.update_shader_buffer(
        ssbo_transfert, @rl.Buffer::UByteArray(ssbo_data), 0U,
      )
      ssbo_data.free()

      // Process SSBO commands on GPU
      @rl.enable_shader(gol_transfert_program)
      @rl.bind_shader_buffer(ssbo_a, 1U)
      @rl.bind_shader_buffer(ssbo_transfert, 3U)
      @rl.compute_shader_dispatch(
        commands.length().reinterpret_as_uint(),
        1U,
        1U,
      )
      @rl.disable_shader()
      commands.clear()
    } else {
      // Process game of life logic
      @rl.enable_shader(gol_logic_program)
      @rl.bind_shader_buffer(ssbo_a, 1U)
      @rl.bind_shader_buffer(ssbo_b, 2U)
      @rl.compute_shader_dispatch(
        (GolWidth / 16).reinterpret_as_uint(),
        (GolWidth / 16).reinterpret_as_uint(),
        1U,
      )
      @rl.disable_shader()

      // Swap SSBOs
      let temp = ssbo_a
      ssbo_a = ssbo_b
      ssbo_b = temp
    }

    // Bind current grid for rendering
    @rl.bind_shader_buffer(ssbo_a, 1U)
    let resolution = @raylib.Vector2::new(
      Float::from_int(screen_width),
      Float::from_int(screen_height),
    )
    gol_render_shader.set_value(
      res_uniform_loc,
      @raylib.ShaderUniformData::Vec2(resolution),
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.blank)
    gol_render_shader.begin_mode()
    @raylib.draw_texture(white_tex, 0, 0, @raylib.white)
    @raylib.end_shader_mode()
    @raylib.draw_rectangle_lines(
      @raylib.get_mouse_x() - brush_size / 2,
      @raylib.get_mouse_y() - brush_size / 2,
      brush_size,
      brush_size,
      @raylib.red,
    )
    @raylib.draw_text(
      "Use Mouse wheel to increase/decrease brush size", 10, 10, 20, @raylib.white,
    )
    @raylib.draw_fps(@raylib.get_screen_width() - 100, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @rl.unload_shader_buffer(ssbo_a)
  @rl.unload_shader_buffer(ssbo_b)
  @rl.unload_shader_buffer(ssbo_transfert)
  @rl.unload_shader_program(gol_transfert_program)
  @rl.unload_shader_program(gol_logic_program)
  @raylib.unload_texture(white_tex)
  @raylib.unload_shader(gol_render_shader)
  @raylib.close_window()
}
