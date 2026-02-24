///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - loading",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(50.0, 50.0, 50.0),
    @raylib.Vector3::new(0.0, 10.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load model
  // NOTE: Requires resources/models/obj/castle.obj and castle_diffuse.png
  // to be placed in the example directory, OR drag-and-drop model files at runtime.
  let _ = @raylib.change_directory("examples/raylib_models_loading")
  let mut model = @raylib.load_model("resources/models/obj/castle.obj")
  let mut texture = @raylib.load_texture(
    "resources/models/obj/castle_diffuse.png",
  )
  @raylib.set_model_material_texture(
    model,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )

  let position = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let mut bounds = @raylib.get_model_bounding_box(model)
  let mut selected = false

  @raylib.disable_cursor()
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFirstPerson)

    // Load new models/textures on drag & drop
    if @raylib.is_file_dropped() {
      let dropped_files = @raylib.load_dropped_files()
      let count = @raylib.file_path_list_count(dropped_files)
      if count == 1 {
        let file_path = @raylib.file_path_list_get(dropped_files, 0)
        if @raylib.is_file_extension(file_path, ".obj") ||
          @raylib.is_file_extension(file_path, ".gltf") ||
          @raylib.is_file_extension(file_path, ".glb") ||
          @raylib.is_file_extension(file_path, ".vox") ||
          @raylib.is_file_extension(file_path, ".iqm") ||
          @raylib.is_file_extension(file_path, ".m3d") {
          @raylib.unload_model(model)
          model = @raylib.load_model(file_path)
          @raylib.set_model_material_texture(
            model,
            0,
            @raylib.MaterialMapAlbedo,
            texture,
          )
          bounds = @raylib.get_model_bounding_box(model)
        } else if @raylib.is_file_extension(file_path, ".png") {
          @raylib.unload_texture(texture)
          texture = @raylib.load_texture(file_path)
          @raylib.set_model_material_texture(
            model,
            0,
            @raylib.MaterialMapAlbedo,
            texture,
          )
        }
      }
      @raylib.unload_dropped_files(dropped_files)
    }

    // Select model on mouse click
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      let ray = @raylib.get_screen_to_world_ray(
        @raylib.get_mouse_position(),
        camera,
      )
      let collision = @raylib.get_ray_collision_box(ray, bounds)
      if collision.hit {
        selected = not(selected)
      } else {
        selected = false
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_model(model, position, 1.0, @raylib.white)
    @raylib.draw_grid(20, 10.0)
    if selected {
      @raylib.draw_bounding_box(bounds, @raylib.green)
    }
    @raylib.end_mode_3d()
    @raylib.draw_text(
      "Drag & drop model to load mesh/texture.",
      10,
      @raylib.get_screen_height() - 20,
      10,
      @raylib.darkgray,
    )
    if selected {
      @raylib.draw_text(
        "MODEL SELECTED",
        @raylib.get_screen_width() - 110,
        10,
        10,
        @raylib.green,
      )
    }
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.unload_model(model)
  @raylib.close_window()
}
