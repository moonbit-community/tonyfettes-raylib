///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - animation playing",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(10.0, 10.0, 10.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load the animated model mesh and basic data
  // NOTE: Requires resources/models/iqm/guy.iqm, guytex.png, and guyanim.iqm
  // to be placed in the example directory.
  let _ = @raylib.change_directory("examples/raylib_models_animation")
  let model = @raylib.load_model("resources/models/iqm/guy.iqm")
  let texture = @raylib.load_texture("resources/models/iqm/guytex.png")
  @raylib.set_model_material_texture(
    model,
    0,
    @raylib.MaterialMapAlbedo,
    texture,
  )

  let position = @raylib.Vector3::new(0.0, 0.0, 0.0)

  // Load animation data
  let anims = @raylib.load_model_animations("resources/models/iqm/guyanim.iqm")
  let anims_count = @raylib.model_animations_count(anims)
  let mut anim_frame_counter = 0

  @raylib.disable_cursor()
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFirstPerson)

    // Play animation when spacebar is held down
    if @raylib.is_key_down(@raylib.KeySpace) {
      anim_frame_counter = anim_frame_counter + 1
      // Update animation for the first animation (index 0)
      if anims_count > 0 {
        @raylib.update_model_animation(model, anims, 0, anim_frame_counter)
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_model_ex(
      model,
      position,
      @raylib.Vector3::new(1.0, 0.0, 0.0),
      -90.0,
      @raylib.Vector3::new(1.0, 1.0, 1.0),
      @raylib.white,
    )
    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()
    @raylib.draw_text(
      "PRESS SPACE to PLAY MODEL ANIMATION", 10, 10, 20, @raylib.maroon,
    )
    @raylib.draw_text(
      "(c) Guy IQM 3D model by @culacant",
      screen_width - 200,
      screen_height - 20,
      10,
      @raylib.gray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.unload_model_animations(anims)
  @raylib.unload_model(model)
  @raylib.close_window()
}
