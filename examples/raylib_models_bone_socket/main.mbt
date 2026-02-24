///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - bone socket",
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
  let _ = @raylib.change_directory("examples/raylib_models_bone_socket")
  let character_model = @raylib.load_model("resources/models/gltf/greenman.glb")
  let equip_model : FixedArray[_] = [
    @raylib.load_model("resources/models/gltf/greenman_hat.glb"),
    @raylib.load_model("resources/models/gltf/greenman_sword.glb"),
    @raylib.load_model("resources/models/gltf/greenman_shield.glb"),
  ]

  let show_equip : FixedArray[Bool] = [true, true, true]

  // Load gltf model animations
  let model_animations = @raylib.load_model_animations(
    "resources/models/gltf/greenman.glb",
  )
  let anims_count = @raylib.model_animations_count(model_animations)
  let mut anim_index = 0
  let mut anim_current_frame = 0

  // Indices of bones for sockets
  let bone_socket_index : FixedArray[Int] = [-1, -1, -1]

  // Search bones for sockets
  let bone_count = @raylib.get_model_bone_count(character_model)
  for i = 0; i < bone_count; i = i + 1 {
    let name = @raylib.get_model_bone_name(character_model, i)
    if name == "socket_hat" {
      bone_socket_index[0] = i
      continue i + 1
    }
    if name == "socket_hand_R" {
      bone_socket_index[1] = i
      continue i + 1
    }
    if name == "socket_hand_L" {
      bone_socket_index[2] = i
      continue i + 1
    }
  }

  let position = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let mut angle = 0

  @raylib.disable_cursor()
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraThirdPerson)

    // Rotate character
    if @raylib.is_key_down(@raylib.KeyF) {
      angle = (angle + 1) % 360
    } else if @raylib.is_key_down(@raylib.KeyH) {
      angle = (360 + angle - 1) % 360
    }

    // Select current animation
    if @raylib.is_key_pressed(@raylib.KeyT) {
      anim_index = (anim_index + 1) % anims_count
    } else if @raylib.is_key_pressed(@raylib.KeyG) {
      anim_index = (anim_index + anims_count - 1) % anims_count
    }

    // Toggle shown of equip
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      show_equip[0] = not(show_equip[0])
    }
    if @raylib.is_key_pressed(@raylib.KeyTwo) {
      show_equip[1] = not(show_equip[1])
    }
    if @raylib.is_key_pressed(@raylib.KeyThree) {
      show_equip[2] = not(show_equip[2])
    }

    // Update model animation
    let frame_count = @raylib.get_model_animation_frame_count(
      model_animations, anim_index,
    )
    anim_current_frame = (anim_current_frame + 1) % frame_count
    @raylib.update_model_animation(
      character_model, model_animations, anim_index, anim_current_frame,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)

    // Draw character
    let deg2rad : Float = 3.14159265358979323846 / 180.0
    let character_rotate = @raylib.Vector4::quat_from_axis_angle(
      @raylib.Vector3::new(0.0, 1.0, 0.0),
      Float::from_int(angle) * deg2rad,
    )
    let character_transform = @raylib.Matrix::multiply(
      @raylib.Vector4::quat_to_matrix(character_rotate),
      @raylib.Matrix::translate(position.x, position.y, position.z),
    )
    @raylib.set_model_transform(character_model, character_transform)
    @raylib.update_model_animation(
      character_model, model_animations, anim_index, anim_current_frame,
    )
    let mesh = @raylib.get_model_mesh(character_model, 0)
    let material = @raylib.get_model_material(character_model, 1)
    @raylib.draw_mesh(mesh, material, character_transform)

    // Draw equipments (hat, sword, shield)
    for i = 0; i < 3; i = i + 1 {
      if not(show_equip[i]) {
        continue i + 1
      }

      let socket_idx = bone_socket_index[i]

      // Get frame pose translation and rotation for this bone socket
      let transform_translation = @raylib.get_model_animation_frame_pose_translation(
        model_animations, anim_index, anim_current_frame, socket_idx,
      )
      let out_rotation = @raylib.get_model_animation_frame_pose_rotation(
        model_animations, anim_index, anim_current_frame, socket_idx,
      )

      // Get bind pose rotation for this bone socket
      let in_rotation = @raylib.get_model_bind_pose_rotation(
        character_model, socket_idx,
      )

      // Calculate socket rotation (angle between bone in initial pose and same bone in current animation frame)
      let rotate = @raylib.Vector4::quat_multiply(
        out_rotation,
        @raylib.Vector4::quat_invert(in_rotation),
      )
      let mut matrix_transform = @raylib.Vector4::quat_to_matrix(rotate)
      // Translate socket to its position in the current animation
      matrix_transform = @raylib.Matrix::multiply(
        matrix_transform,
        @raylib.Matrix::translate(
          transform_translation.x,
          transform_translation.y,
          transform_translation.z,
        ),
      )
      // Transform the socket using the transform of the character (angle and translate)
      matrix_transform = @raylib.Matrix::multiply(
        matrix_transform, character_transform,
      )

      // Draw mesh at socket position with socket angle rotation
      let equip_mesh = @raylib.get_model_mesh(equip_model[i], 0)
      let equip_material = @raylib.get_model_material(equip_model[i], 1)
      @raylib.draw_mesh(equip_mesh, equip_material, matrix_transform)
    }

    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()

    @raylib.draw_text(
      "Use the T/G to switch animation", 10, 10, 20, @raylib.gray,
    )
    @raylib.draw_text(
      "Use the F/H to rotate character left/right", 10, 35, 20, @raylib.gray,
    )
    @raylib.draw_text(
      "Use the 1,2,3 to toggle shown of hat, sword and shield", 10, 60, 20, @raylib.gray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_model_animations(model_animations)
  @raylib.unload_model(character_model)
  for i = 0; i < 3; i = i + 1 {
    @raylib.unload_model(equip_model[i])
  }
  @raylib.close_window()
}
