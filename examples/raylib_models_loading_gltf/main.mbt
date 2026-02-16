///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - loading gltf",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(6.0, 6.0, 6.0),
    @raylib.Vector3::new(0.0, 2.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load gltf model
  // NOTE: Requires resources/models/gltf/robot.glb to be placed in the example directory.
  let _ = @raylib.change_directory("examples/raylib_models_loading_gltf")
  let model = @raylib.load_model("resources/models/gltf/robot.glb")
  let position = @raylib.Vector3::new(0.0, 0.0, 0.0)

  // Load gltf model animations
  let model_animations = @raylib.load_model_animations(
    "resources/models/gltf/robot.glb",
  )
  let anims_count = @raylib.model_animations_count(model_animations)
  let mut anim_index = 0
  let mut anim_current_frame = 0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)

    // Select current animation
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
      if anims_count > 0 {
        anim_index = (anim_index + 1) % anims_count
      }
    } else if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      if anims_count > 0 {
        anim_index = (anim_index + anims_count - 1) % anims_count
      }
    }

    // Update model animation
    if anims_count > 0 {
      anim_current_frame = anim_current_frame + 1
      @raylib.update_model_animation(
        model, model_animations, anim_index, anim_current_frame,
      )
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_model(model, position, 1.0, @raylib.white)
    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()
    @raylib.draw_text(
      "Use the LEFT/RIGHT mouse buttons to switch animation", 10, 10, 20, @raylib.gray,
    )
    @raylib.draw_text(
      "Animation index: " + anim_index.to_string(),
      10,
      @raylib.get_screen_height() - 20,
      10,
      @raylib.darkgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_model_animations(model_animations)
  @raylib.unload_model(model)
  @raylib.close_window()
}
