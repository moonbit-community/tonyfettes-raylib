///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - heightmap rendering",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(18.0, 21.0, 18.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load heightmap image (RAM)
  // NOTE: Requires resources/heightmap.png to be placed in the example directory.
  // You can use any grayscale PNG image as a heightmap.
  let _ = @raylib.change_directory("examples/raylib_models_heightmap")
  let image = @raylib.load_image("resources/heightmap.png")
  let texture = @raylib.load_texture_from_image(image)

  // Generate heightmap mesh (RAM and VRAM)
  let mesh = @raylib.gen_mesh_heightmap(
    image,
    @raylib.Vector3::new(16.0, 8.0, 16.0),
  )
  let model = @raylib.load_model_from_mesh(mesh)

  // Set map diffuse texture
  @raylib.set_model_material_texture(
    model,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )

  let map_position = @raylib.Vector3::new(-8.0, 0.0, -8.0)

  @raylib.unload_image(image) // Unload heightmap image from RAM

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_model(model, map_position, 1.0, @raylib.red)
    @raylib.draw_grid(20, 1.0)
    @raylib.end_mode_3d()
    @raylib.draw_text(
      "Heightmap model generated from image",
      10,
      screen_height - 30,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.unload_model(model)
  @raylib.close_window()
}
