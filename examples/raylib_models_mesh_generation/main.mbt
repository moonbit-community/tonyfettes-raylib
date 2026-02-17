///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - mesh generation",
  )

  // We generate a checked image for texturing
  let checked = @raylib.gen_image_checked(
    2, 2, 1, 1, @raylib.red, @raylib.green,
  )
  let texture = @raylib.load_texture_from_image(checked)
  @raylib.unload_image(checked)

  // Generate parametric meshes and load them as models
  let num_models = 8
  let models : Array[@raylib.Model] = []
  models.push(
    @raylib.load_model_from_mesh(@raylib.gen_mesh_plane(2.0, 2.0, 4, 3)),
  )
  models.push(
    @raylib.load_model_from_mesh(@raylib.gen_mesh_cube(2.0, 1.0, 2.0)),
  )
  models.push(
    @raylib.load_model_from_mesh(@raylib.gen_mesh_sphere(2.0, 32, 32)),
  )
  models.push(
    @raylib.load_model_from_mesh(@raylib.gen_mesh_hemisphere(2.0, 16, 16)),
  )
  models.push(
    @raylib.load_model_from_mesh(@raylib.gen_mesh_cylinder(1.0, 2.0, 16)),
  )
  models.push(
    @raylib.load_model_from_mesh(@raylib.gen_mesh_torus(0.25, 4.0, 16, 32)),
  )
  models.push(
    @raylib.load_model_from_mesh(@raylib.gen_mesh_knot(1.0, 2.0, 16, 128)),
  )
  models.push(@raylib.load_model_from_mesh(@raylib.gen_mesh_poly(5, 2.0)))

  // Set checked texture as default diffuse component for all models material
  for i = 0; i < num_models; i = i + 1 {
    @raylib.set_model_material_texture(
      models[i],
      0,
      @raylib.MaterialMapAlbedo,
      texture,
    )
  }

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(5.0, 5.0, 5.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Model drawing position
  let position = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let mut current_model = 0

  // Model names for display
  let model_names : Array[String] = [
    "PLANE", "CUBE", "SPHERE", "HEMISPHERE", "CYLINDER", "TORUS", "KNOT", "POLY",
  ]

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      current_model = (current_model + 1) % num_models
    }
    if @raylib.is_key_pressed(@raylib.KeyRight) {
      current_model = current_model + 1
      if current_model >= num_models {
        current_model = 0
      }
    } else if @raylib.is_key_pressed(@raylib.KeyLeft) {
      current_model = current_model - 1
      if current_model < 0 {
        current_model = num_models - 1
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_model(models[current_model], position, 1.0, @raylib.white)
    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()
    @raylib.draw_rectangle(30, 400, 310, 30, @raylib.fade(@raylib.skyblue, 0.5))
    @raylib.draw_rectangle_lines(
      30,
      400,
      310,
      30,
      @raylib.fade(@raylib.darkblue, 0.5),
    )
    @raylib.draw_text(
      "MOUSE LEFT BUTTON to CYCLE PROCEDURAL MODELS", 40, 410, 10, @raylib.blue,
    )
    @raylib.draw_text(model_names[current_model], 680, 10, 20, @raylib.darkblue)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  for i = 0; i < num_models; i = i + 1 {
    @raylib.unload_model(models[i])
  }
  @raylib.close_window()
}
