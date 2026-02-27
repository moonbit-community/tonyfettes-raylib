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
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - skybox loading and drawing",
  )
  let _ = @raylib.change_directory("examples/raylib_models_skybox")

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(1.0, 1.0, 1.0), // Camera position
    @raylib.Vector3::new(4.0, 1.0, 4.0), // Camera looking at point
    @raylib.Vector3::new(0.0, 1.0, 0.0), // Camera up vector
    45.0, // Camera field-of-view Y
    @raylib.CameraPerspective, // Camera projection type
  )

  // Load skybox model
  let cube = @raylib.gen_mesh_cube(1.0, 1.0, 1.0)
  let skybox = @raylib.load_model_from_mesh(cube)

  // Load skybox shader and set required locations
  // NOTE: Some locations are automatically set at shader loading
  let skybox_shader = @raylib.load_shader(
    "resources/shaders/glsl330/skybox.vs", "resources/shaders/glsl330/skybox.fs",
  )
  @raylib.set_model_material_shader(skybox, 0, skybox_shader)

  // Set shader uniforms
  @raylib.set_shader_value(
    skybox_shader,
    @raylib.get_shader_location(skybox_shader, "environmentMap"),
    int_to_bytes(@raylib.MaterialMapCubemap),
    @raylib.ShaderUniformInt,
  )
  @raylib.set_shader_value(
    skybox_shader,
    @raylib.get_shader_location(skybox_shader, "doGamma"),
    int_to_bytes(0),
    @raylib.ShaderUniformInt,
  )
  @raylib.set_shader_value(
    skybox_shader,
    @raylib.get_shader_location(skybox_shader, "vflipped"),
    int_to_bytes(0),
    @raylib.ShaderUniformInt,
  )

  // Load cubemap texture from skybox image
  let img = @raylib.load_image("resources/skybox.png")
  let cubemap = @raylib.load_texture_cubemap(
    img,
    @raylib.CubemapLayoutAutoDetect,
  )
  @raylib.set_model_material_texture(
    skybox,
    0,
    @raylib.MaterialMapCubemap,
    cubemap,
  )
  @raylib.unload_image(img)

  let skybox_file_name = "resources/skybox.png"

  @raylib.disable_cursor() // Limit cursor to relative movement inside the window
  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFirstPerson)

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)

    // We are inside the cube, we need to disable backface culling!
    @rl.disable_backface_culling()
    @rl.disable_depth_mask()
    @raylib.draw_model(
      skybox,
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      1.0,
      @raylib.white,
    )
    @rl.enable_backface_culling()
    @rl.enable_depth_mask()

    @raylib.draw_grid(10, 1.0)

    @raylib.end_mode_3d()

    @raylib.draw_text(
      ": " + @raylib.get_file_name(skybox_file_name),
      10,
      @raylib.get_screen_height() - 20,
      10,
      @raylib.black,
    )
    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_shader(skybox_shader)
  @raylib.unload_texture(cubemap)
  @raylib.unload_model(skybox)
  @raylib.close_window()
}
