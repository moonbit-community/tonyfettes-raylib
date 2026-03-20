///|
fn tanf(x : Float) -> Float {
  @math.tanf(x)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("shaders/shaders_hybrid_render")

  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - write depth buffer",
  )

  // This Shader calculates pixel depth and color using raymarch
  let shdr_raymarch = @raylib.load_shader(
    "", "resources/shaders/glsl330/hybrid_raymarch.fs",
  )

  // This Shader is a standard rasterization fragment shader with the addition of depth writing
  // You are required to write depth for all shaders if one shader does it
  let shdr_raster = @raylib.load_shader(
    "", "resources/shaders/glsl330/hybrid_raster.fs",
  )

  // Fill the struct with shader locs.
  let march_loc_cam_pos = @raylib.get_shader_location(shdr_raymarch, "camPos")
  let march_loc_cam_dir = @raylib.get_shader_location(shdr_raymarch, "camDir")
  let march_loc_screen_center = @raylib.get_shader_location(
    shdr_raymarch, "screenCenter",
  )

  // Transfer screenCenter position to shader. Which is used to calculate ray direction.
  let screen_center = @raylib.Vector2::new(
    Float::from_int(screen_width) / 2.0,
    Float::from_int(screen_height) / 2.0,
  )
  shdr_raymarch.set_value(
    march_loc_screen_center,
    @raylib.ShaderUniformData::Vec2(screen_center),
  )

  // Use composable rl* primitives to create writable depth texture buffer
  let fbo_id = @rl.load_framebuffer()
  let color_tex_id = @rl.load_texture(
    screen_width,
    screen_height,
    @raylib.PixelformatUncompressedR8g8b8a8,
    1,
  )
  let depth_tex_id = @rl.load_texture_depth(screen_width, screen_height, false)
  @rl.framebuffer_attach(
    fbo_id,
    color_tex_id,
    @rl.AttachmentColorChannel0,
    @rl.AttachmentTexture2d,
    0,
  )
  @rl.framebuffer_attach(
    fbo_id,
    depth_tex_id,
    @rl.AttachmentDepth,
    @rl.AttachmentTexture2d,
    0,
  )
  if @rl.framebuffer_complete(fbo_id) {
    @raylib.trace_log(
      @raylib.LogInfo,
      "FBO: Framebuffer object created successfully",
    )
  }
  let target = @raylib.new_render_texture(
    fbo_id,
    @raylib.new_texture(
      color_tex_id,
      screen_width,
      screen_height,
      1,
      @raylib.PixelformatUncompressedR8g8b8a8,
    ),
    @raylib.new_texture(
      depth_tex_id, screen_width, screen_height, 1, 19, // DEPTH_COMPONENT_24BIT
    ),
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.5, 1.0, 1.5), // Camera position
    @raylib.Vector3::new(0.0, 0.5, 0.0), // Camera looking at point
    @raylib.Vector3::new(0.0, 1.0, 0.0), // Camera up vector
    45.0, // Camera field-of-view Y
    @raylib.CameraPerspective, // Camera projection type
  )

  // Camera FOV is pre-calculated in the camera Distance.
  let deg2rad : Float = 0.017453292519943295 // PI / 180
  let cam_dist : Float = 1.0 / tanf(camera.fovy * 0.5 * deg2rad)

  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    // Update Camera Position in the ray march shader.
    shdr_raymarch.set_value(
      march_loc_cam_pos,
      @raylib.ShaderUniformData::Vec3(camera.position),
    )

    // Update Camera Looking Vector. Vector length determines FOV.
    let cam_dir = @raylib.Vector3::scale(
      @raylib.Vector3::normalize(
        @raylib.Vector3::subtract(camera.target, camera.position),
      ),
      cam_dist,
    )
    shdr_raymarch.set_value(
      march_loc_cam_dir,
      @raylib.ShaderUniformData::Vec3(cam_dir),
    )

    // Draw
    // Draw into our custom render texture (framebuffer)
    @raylib.begin_texture_mode(target)
    @raylib.clear_background(@raylib.white)

    // Raymarch Scene
    @rl.enable_depth_test() // Manually enable Depth Test to handle multiple rendering methods.
    @raylib.begin_shader_mode(shdr_raymarch)
    @raylib.draw_rectangle_rec(
      @raylib.Rectangle::new(
        0.0,
        0.0,
        Float::from_int(screen_width),
        Float::from_int(screen_height),
      ),
      @raylib.white,
    )
    @raylib.end_shader_mode()

    // Rasterize Scene
    @raylib.begin_mode_3d(camera)
    @raylib.begin_shader_mode(shdr_raster)
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
        Float::from_int(-screen_height),
      ),
      @raylib.Vector2::new(0.0, 0.0),
      @raylib.white,
    )
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_render_texture(target)
  @raylib.unload_shader(shdr_raymarch)
  @raylib.unload_shader(shdr_raster)

  @raylib.close_window()
}
