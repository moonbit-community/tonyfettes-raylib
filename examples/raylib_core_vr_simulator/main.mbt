///|
fn float_array_to_bytes(arr : FixedArray[Float]) -> Bytes {
  let result = FixedArray::make(arr.length() * 4, b'\x00')
  for i = 0; i < arr.length(); i = i + 1 {
    let bits = arr[i].reinterpret_as_int()
    result[i * 4] = (bits & 0xFF).to_byte()
    result[i * 4 + 1] = ((bits >> 8) & 0xFF).to_byte()
    result[i * 4 + 2] = ((bits >> 16) & 0xFF).to_byte()
    result[i * 4 + 3] = ((bits >> 24) & 0xFF).to_byte()
  }
  FixedArray::unsafe_reinterpret_as_bytes(result)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let glsl_version = 330

  // NOTE: screenWidth/screenHeight should match VR device aspect ratio
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - vr simulator",
  )
  let _ = @raylib.change_directory("examples/raylib_core_vr_simulator")

  // VR device parameters definition
  let device = @raylib.VrDeviceInfo::new(
    2160, // h_resolution
    1200, // v_resolution
    0.133793, // h_screen_size
    0.0669, // v_screen_size
    0.041, // eye_to_screen_distance
    0.07, // lens_separation_distance
    0.07, // interpupillary_distance
    [1.0, 0.22, 0.24, 0.0], // lens_distortion_values
    [0.996, -0.004, 1.014, 0.0], // chroma_ab_correction
  )

  // Load VR stereo config for VR device parameters
  let config = @raylib.load_vr_stereo_config(device)

  // Distortion shader (uses device lens distortion and chroma)
  let distortion = @raylib.load_shader(
    "",
    "resources/distortion\{glsl_version}.fs",
  )

  // Update distortion shader with lens and distortion-scale parameters
  @raylib.set_shader_value(
    distortion,
    @raylib.get_shader_location(distortion, "leftLensCenter"),
    @raylib.vr_stereo_config_left_lens_center(config),
    @raylib.ShaderUniformVec2,
  )
  @raylib.set_shader_value(
    distortion,
    @raylib.get_shader_location(distortion, "rightLensCenter"),
    @raylib.vr_stereo_config_right_lens_center(config),
    @raylib.ShaderUniformVec2,
  )
  @raylib.set_shader_value(
    distortion,
    @raylib.get_shader_location(distortion, "leftScreenCenter"),
    @raylib.vr_stereo_config_left_screen_center(config),
    @raylib.ShaderUniformVec2,
  )
  @raylib.set_shader_value(
    distortion,
    @raylib.get_shader_location(distortion, "rightScreenCenter"),
    @raylib.vr_stereo_config_right_screen_center(config),
    @raylib.ShaderUniformVec2,
  )
  @raylib.set_shader_value(
    distortion,
    @raylib.get_shader_location(distortion, "scale"),
    @raylib.vr_stereo_config_scale(config),
    @raylib.ShaderUniformVec2,
  )
  @raylib.set_shader_value(
    distortion,
    @raylib.get_shader_location(distortion, "scaleIn"),
    @raylib.vr_stereo_config_scale_in(config),
    @raylib.ShaderUniformVec2,
  )
  @raylib.set_shader_value(
    distortion,
    @raylib.get_shader_location(distortion, "deviceWarpParam"),
    float_array_to_bytes(device.lens_distortion_values),
    @raylib.ShaderUniformVec4,
  )
  @raylib.set_shader_value(
    distortion,
    @raylib.get_shader_location(distortion, "chromaAbParam"),
    float_array_to_bytes(device.chroma_ab_correction),
    @raylib.ShaderUniformVec4,
  )

  // Initialize framebuffer for stereo rendering
  let target = @raylib.load_render_texture(
    device.h_resolution,
    device.v_resolution,
  )

  // The target's height is flipped (in the source Rectangle), due to OpenGL reasons
  let source_rec = @raylib.Rectangle::new(
    0.0,
    0.0,
    Float::from_int(device.h_resolution),
    -Float::from_int(device.v_resolution),
  )
  let dest_rec = @raylib.Rectangle::new(
    0.0,
    0.0,
    Float::from_int(@raylib.get_screen_width()),
    Float::from_int(@raylib.get_screen_height()),
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(5.0, 2.0, 5.0),
    @raylib.Vector3::new(0.0, 2.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    60.0,
    @raylib.CameraPerspective,
  )

  let cube_position = @raylib.Vector3::new(0.0, 0.0, 0.0)

  @raylib.disable_cursor()
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFirstPerson)

    // Draw
    @raylib.begin_texture_mode(target)
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_vr_stereo_mode(config)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_cube(cube_position, 2.0, 2.0, 2.0, @raylib.red)
    @raylib.draw_cube_wires(cube_position, 2.0, 2.0, 2.0, @raylib.maroon)
    @raylib.draw_grid(40, 1.0)
    @raylib.end_mode_3d()
    @raylib.end_vr_stereo_mode()
    @raylib.end_texture_mode()

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_shader_mode(distortion)
    @raylib.draw_render_texture_pro(
      target,
      source_rec,
      dest_rec,
      @raylib.Vector2::new(0.0, 0.0),
      0.0,
      @raylib.white,
    )
    @raylib.end_shader_mode()
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_vr_stereo_config(config)
  @raylib.unload_render_texture(target)
  @raylib.unload_shader(distortion)
  @raylib.close_window()
}
