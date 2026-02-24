///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - GPU skinning",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(5.0, 5.0, 5.0),
    @raylib.Vector3::new(0.0, 2.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Load gltf model
  let _ = @raylib.change_directory("examples/raylib_models_gpu_skinning")
  let character_model = @raylib.load_model("resources/models/gltf/greenman.glb")

  // Load skinning shader
  let skinning_shader = @raylib.load_shader(
    "resources/shaders/glsl330/skinning.vs", "resources/shaders/glsl330/skinning.fs",
  )

  @raylib.set_model_material_shader(character_model, 1, skinning_shader)

  // Load gltf model animations
  let model_animations = @raylib.load_model_animations(
    "resources/models/gltf/greenman.glb",
  )
  let anims_count = @raylib.model_animations_count(model_animations)
  let mut anim_index = 0
  let mut anim_current_frame = 0

  let position = @raylib.Vector3::new(0.0, 0.0, 0.0)

  @raylib.disable_cursor() // Limit cursor to relative movement inside the window

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraThirdPerson)

    // Select current animation
    if @raylib.is_key_pressed(@raylib.KeyT) {
      anim_index = (anim_index + 1) % anims_count
    } else if @raylib.is_key_pressed(@raylib.KeyG) {
      anim_index = (anim_index + anims_count - 1) % anims_count
    }

    // Update model animation
    let frame_count = @raylib.get_model_animation_frame_count(
      model_animations, anim_index,
    )
    anim_current_frame = (anim_current_frame + 1) % frame_count
    @raylib.set_model_transform(
      character_model,
      @raylib.Matrix::translate(position.x, position.y, position.z),
    )
    @raylib.update_model_animation_bones(
      character_model, model_animations, anim_index, anim_current_frame,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)

    // Draw character mesh, pose calculation is done in shader (GPU skinning)
    let mesh = @raylib.get_model_mesh(character_model, 0)
    let material = @raylib.get_model_material(character_model, 1)
    let transform = @raylib.get_model_transform(character_model)
    @raylib.draw_mesh(mesh, material, transform)

    @raylib.draw_grid(10, 1.0)

    @raylib.end_mode_3d()

    @raylib.draw_text(
      "Use the T/G to switch animation", 10, 10, 20, @raylib.gray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_model_animations(model_animations)
  @raylib.unload_model(character_model)
  @raylib.unload_shader(skinning_shader)
  @raylib.close_window()
}
