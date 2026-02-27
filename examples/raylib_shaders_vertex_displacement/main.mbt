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
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory(
    "examples/raylib_shaders_vertex_displacement",
  )

  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - vertex displacement",
  )

  // Set up camera
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(20.0, 5.0, -20.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    60.0,
    @raylib.CameraPerspective,
  )

  // Load vertex and fragment shaders
  let shader = @raylib.load_shader(
    "resources/shaders/glsl330/vertex_displacement.vs", "resources/shaders/glsl330/vertex_displacement.fs",
  )

  // Load perlin noise texture
  let perlin_noise_image = @raylib.gen_image_perlin_noise(512, 512, 0, 0, 1.0)
  let perlin_noise_map = @raylib.load_texture_from_image(perlin_noise_image)
  @raylib.unload_image(perlin_noise_image)

  // Set shader uniform location for perlin noise map
  let perlin_noise_map_loc = @raylib.get_shader_location(
    shader, "perlinNoiseMap",
  )
  @rl.enable_shader(@raylib.get_shader_id(shader).reinterpret_as_uint())
  @rl.active_texture_slot(1)
  @rl.enable_texture(
    @raylib.get_texture_id(perlin_noise_map).reinterpret_as_uint(),
  )
  @rl.set_uniform_sampler(perlin_noise_map_loc, 1U)

  // Create a plane mesh and model
  let plane_mesh = @raylib.gen_mesh_plane(50.0, 50.0, 50, 50)
  let plane_model = @raylib.load_model_from_mesh(plane_mesh)

  // Set plane model material shader
  @raylib.set_model_material_shader(plane_model, 0, shader)

  let mut time : Float = 0.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFree)

    time += @raylib.get_frame_time()
    @raylib.set_shader_value(
      shader,
      @raylib.get_shader_location(shader, "time"),
      float_to_bytes(time),
      @raylib.ShaderUniformFloat,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_mode_3d(camera)

    @raylib.begin_shader_mode(shader)
    @raylib.draw_model(
      plane_model,
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      1.0,
      @raylib.white,
    )
    @raylib.end_shader_mode()

    @raylib.end_mode_3d()

    @raylib.draw_text("Vertex displacement", 10, 10, 20, @raylib.darkgray)
    @raylib.draw_fps(10, 40)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.unload_model(plane_model)
  @raylib.unload_texture(perlin_noise_map)
  @raylib.close_window()
}
