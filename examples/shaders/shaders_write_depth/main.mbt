///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("raylib_shaders_write_depth")

  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - write depth buffer",
  )

  // The shader inverts the depth buffer by writing into it by
  // `gl_FragDepth = 1 - gl_FragCoord.z;`
  let shader = @raylib.load_shader(
    "", "resources/shaders/glsl330/write_depth.fs",
  )

  // Use rlgl primitives to create writable depth texture buffer
  let fbo_id = @rl.load_framebuffer()
  let color_tex_id = @rl.load_texture(
    screen_width, screen_height, @raylib.PixelformatUncompressedR8g8b8a8, 1,
  )
  let depth_tex_id = @rl.load_texture_depth(screen_width, screen_height, false)
  @rl.framebuffer_attach(
    fbo_id, color_tex_id, @rl.AttachmentColorChannel0,
    @rl.AttachmentTexture2d, 0,
  )
  @rl.framebuffer_attach(
    fbo_id, depth_tex_id, @rl.AttachmentDepth, @rl.AttachmentTexture2d, 0,
  )
  if @rl.framebuffer_complete(fbo_id) {
    @raylib.trace_log(@raylib.LogInfo, "FBO: Framebuffer object created successfully")
  }
  let target = @raylib.new_render_texture(
    fbo_id,
    @raylib.new_texture(
      color_tex_id, screen_width, screen_height, 1,
      @raylib.PixelformatUncompressedR8g8b8a8,
    ),
    @raylib.new_texture(
      depth_tex_id, screen_width, screen_height, 1,
      19, // DEPTH_COMPONENT_24BIT
    ),
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(2.0, 2.0, 3.0), // Camera position
    @raylib.Vector3::new(0.0, 0.5, 0.0), // Camera looking at point
    @raylib.Vector3::new(0.0, 1.0, 0.0), // Camera up vector
    45.0, // Camera field-of-view Y
    @raylib.CameraPerspective, // Camera projection type
  )

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    // Draw

    // Draw into our custom render texture (framebuffer)
    @raylib.begin_texture_mode(target)
    @raylib.clear_background(@raylib.white)

    @raylib.begin_mode_3d(camera)
    @raylib.begin_shader_mode(shader)
    @raylib.draw_cube_wires_v(
      @raylib.Vector3::new(0.0, 0.5, 1.0),
      @raylib.Vector3::new(1.0, 1.0, 1.0),
      @raylib.red,
    )
    @raylib.draw_cube_v(
      @raylib.Vector3::new(0.0, 0.5, 1.0),
      @raylib.Vector3::new(1.0, 1.0, 1.0),
      @raylib.purple,
    )
    @raylib.draw_cube_wires_v(
      @raylib.Vector3::new(0.0, 0.5, -1.0),
      @raylib.Vector3::new(1.0, 1.0, 1.0),
      @raylib.darkgreen,
    )
    @raylib.draw_cube_v(
      @raylib.Vector3::new(0.0, 0.5, -1.0),
      @raylib.Vector3::new(1.0, 1.0, 1.0),
      @raylib.yellow,
    )
    @raylib.draw_grid(10, 1.0)
    @raylib.end_shader_mode()
    @raylib.end_mode_3d()
    @raylib.end_texture_mode()

    // Draw into screen our custom render texture
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_render_texture_rec(
      target,
      @raylib.Rectangle::new(
        0.0,
        0.0,
        Float::from_int(screen_width),
        -Float::from_int(screen_height),
      ),
      @raylib.Vector2::new(0.0, 0.0),
      @raylib.white,
    )
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_render_texture(target)
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
