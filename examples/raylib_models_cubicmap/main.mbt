///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - cubicmap rendering",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(16.0, 14.0, 16.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load cubicmap image (RAM)
  // NOTE: Requires resources/cubicmap.png and resources/cubicmap_atlas.png
  // to be placed in the example directory.
  let _ = @raylib.change_directory("examples/raylib_models_cubicmap")
  let image = @raylib.load_image("resources/cubicmap.png")
  let cubicmap = @raylib.load_texture_from_image(image)

  let mesh = @raylib.gen_mesh_cubicmap(
    image,
    @raylib.Vector3::new(1.0, 1.0, 1.0),
  )
  let model = @raylib.load_model_from_mesh(mesh)

  // Load map texture
  let texture = @raylib.load_texture("resources/cubicmap_atlas.png")
  @raylib.set_model_material_texture(
    model,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )

  let map_position = @raylib.Vector3::new(-16.0, 0.0, -8.0)

  @raylib.unload_image(image) // Unload cubicmap image from RAM

  let mut pause = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeyP) {
      pause = not(pause)
    }
    if not(pause) {
      camera = @raylib.update_camera(camera, @raylib.CameraOrbital)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_model(model, map_position, 1.0, @raylib.white)
    @raylib.end_mode_3d()
    @raylib.draw_text("cubicmap image used to", 658, 90, 10, @raylib.gray)
    @raylib.draw_text("generate map 3d model", 658, 104, 10, @raylib.gray)
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(cubicmap)
  @raylib.unload_texture(texture)
  @raylib.unload_model(model)
  @raylib.close_window()
}
