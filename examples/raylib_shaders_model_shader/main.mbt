///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - model shader",
  )
  let _ = @raylib.change_directory("examples/raylib_shaders_model_shader")
  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(4.0, 4.0, 4.0),
    @raylib.Vector3::new(0.0, 1.0, -1.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )
  // Load OBJ model
  let model = @raylib.load_model("resources/models/watermill.obj")
  // Load model texture
  let texture = @raylib.load_texture("resources/models/watermill_diffuse.png")
  // Load shader for model
  let shader = @raylib.load_shader("", "resources/shaders/glsl330/grayscale.fs")
  // Set shader effect to 3d model
  @raylib.set_model_material_shader(model, 0, shader)
  // Bind texture to model
  @raylib.set_model_material_texture(
    model,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )
  let position = @raylib.Vector3::new(0.0, 0.0, 0.0)
  @raylib.disable_cursor()
  @raylib.set_target_fps(60)
  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFree)
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_model(model, position, 0.2, @raylib.white)
    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()
    @raylib.draw_text(
      "(c) Watermill 3D model by Alberto Cano",
      screen_width - 210,
      screen_height - 20,
      10,
      @raylib.gray,
    )
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }
  // De-Initialization
  @raylib.unload_shader(shader)
  @raylib.unload_texture(texture)
  @raylib.unload_model(model)
  @raylib.close_window()
}
