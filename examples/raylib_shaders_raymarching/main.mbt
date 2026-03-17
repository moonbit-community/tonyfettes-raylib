///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("raylib_shaders_raymarching")
  @raylib.set_config_flags(@raylib.FlagWindowResizable)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - raymarching rendering",
  )
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(2.5, 2.5, 3.0),
    @raylib.Vector3::new(0.0, 0.0, 0.7),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    65.0,
    @raylib.CameraPerspective,
  )

  // Load raymarching shader
  let shader = @raylib.load_shader(
    "", "resources/shaders/glsl330/raymarching.fs",
  )

  // Get shader locations for required uniforms
  let view_eye_loc = @raylib.get_shader_location(shader, "viewEye")
  let view_center_loc = @raylib.get_shader_location(shader, "viewCenter")
  let run_time_loc = @raylib.get_shader_location(shader, "runTime")
  let resolution_loc = @raylib.get_shader_location(shader, "resolution")
  let mut resolution_x = Float::from_int(screen_width)
  let mut resolution_y = Float::from_int(screen_height)
  @raylib.set_shader_value(
    shader,
    resolution_loc,
    @raylib.ShaderUniformData::Vec2(@raylib.Vector2::new(resolution_x, resolution_y)),
  )
  let mut run_time : Float = 0.0
  @raylib.disable_cursor()
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFirstPerson)
    let delta_time = @raylib.get_frame_time()
    run_time = run_time + delta_time

    // Set shader required uniform values
    @raylib.set_shader_value(
      shader,
      view_eye_loc,
      @raylib.ShaderUniformData::Vec3(
        @raylib.Vector3::new(
          camera.position.x,
          camera.position.y,
          camera.position.z,
        ),
      ),
    )
    @raylib.set_shader_value(
      shader,
      view_center_loc,
      @raylib.ShaderUniformData::Vec3(
        @raylib.Vector3::new(camera.target.x, camera.target.y, camera.target.z),
      ),
    )
    @raylib.set_shader_value(
      shader,
      run_time_loc,
      @raylib.ShaderUniformData::Float(run_time),
    )

    // Check if screen is resized
    if @raylib.is_window_resized() {
      resolution_x = Float::from_int(@raylib.get_screen_width())
      resolution_y = Float::from_int(@raylib.get_screen_height())
      @raylib.set_shader_value(
        shader,
        resolution_loc,
        @raylib.ShaderUniformData::Vec2(@raylib.Vector2::new(resolution_x, resolution_y)),
      )
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    // We only draw a white full-screen rectangle,
    // frame is generated in shader using raymarching
    @raylib.begin_shader_mode(shader)
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
      @raylib.white,
    )
    @raylib.end_shader_mode()
    @raylib.draw_text(
      "(c) Raymarching shader by Inigo Quilez. MIT License.",
      @raylib.get_screen_width() - 280,
      @raylib.get_screen_height() - 20,
      10,
      @raylib.black,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.close_window()
}
