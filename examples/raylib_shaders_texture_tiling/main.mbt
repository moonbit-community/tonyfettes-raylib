///|
fn vec2_to_bytes(x : Float, y : Float) -> Bytes {
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
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - texture tiling",
  )
  let _ = @raylib.change_directory("examples/raylib_shaders_texture_tiling")
  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(4.0, 4.0, 4.0),
    @raylib.Vector3::new(0.0, 0.5, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  // Load a cube model
  let cube = @raylib.gen_mesh_cube(1.0, 1.0, 1.0)
  let model = @raylib.load_model_from_mesh(cube)
  // Load a texture and assign to cube model
  let texture = @raylib.load_texture("resources/cubicmap_atlas.png")
  @raylib.set_model_material_texture(
    model,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )
  // Set the texture tiling using a shader
  let tiling = vec2_to_bytes(3.0, 3.0)
  let shader = @raylib.load_shader("", "resources/shaders/glsl330/tiling.fs")
  @raylib.set_shader_value(
    shader,
    @raylib.get_shader_location(shader, "tiling"),
    tiling,
    @raylib.ShaderUniformVec2,
  )
  @raylib.set_model_material_shader(model, 0, shader)
  @raylib.disable_cursor()
  @raylib.set_target_fps(60)
  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFree)
    if @raylib.is_key_pressed(@raylib.KeyZ) {
      camera = @raylib.Camera3D::new(
        camera.position,
        @raylib.Vector3::new(0.0, 0.5, 0.0),
        camera.up,
        camera.fovy,
        camera.projection,
      )
    }
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.begin_shader_mode(shader)
    @raylib.draw_model(
      model,
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      2.0,
      @raylib.white,
    )
    @raylib.end_shader_mode()
    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()
    @raylib.draw_text(
      "Use mouse to rotate the camera", 10, 10, 20, @raylib.darkgray,
    )
    @raylib.end_drawing()
  }
  // De-Initialization
  @raylib.unload_model(model)
  @raylib.unload_shader(shader)
  @raylib.unload_texture(texture)
  @raylib.close_window()
}
