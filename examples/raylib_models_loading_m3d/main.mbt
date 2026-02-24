///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - M3D model loading",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(1.5, 1.5, 1.5), // position
    @raylib.Vector3::new(0.0, 0.4, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    45.0, // fovy
    @raylib.CameraPerspective,
  )

  let position = @raylib.Vector3::new(0.0, 0.0, 0.0) // Set model position

  let mut draw_mesh = true
  let mut draw_skeleton = true
  let mut anim_playing = false // Store anim state, what to draw

  // Load model
  let _ = @raylib.change_directory("examples/raylib_models_loading_m3d")
  let model = @raylib.load_model("resources/models/m3d/cesium_man.m3d")

  // Load animations
  let anims = @raylib.load_model_animations(
    "resources/models/m3d/cesium_man.m3d",
  )
  let anims_count = @raylib.model_animations_count(anims)
  let mut anim_frame_counter = 0
  let mut anim_id = 0

  @raylib.disable_cursor() // Limit cursor to relative movement inside the window

  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFirstPerson)

    if anims_count > 0 {
      // Play animation when spacebar is held down (or step one frame with N)
      if @raylib.is_key_down(@raylib.KeySpace) ||
        @raylib.is_key_pressed(@raylib.KeyN) {
        anim_frame_counter = anim_frame_counter + 1
        let frame_count = @raylib.get_model_animation_frame_count(
          anims, anim_id,
        )
        if anim_frame_counter >= frame_count {
          anim_frame_counter = 0
        }
        @raylib.update_model_animation(
          model, anims, anim_id, anim_frame_counter,
        )
        anim_playing = true
      }

      // Select animation by pressing C
      if @raylib.is_key_pressed(@raylib.KeyC) {
        anim_frame_counter = 0
        anim_id = anim_id + 1
        if anim_id >= anims_count {
          anim_id = 0
        }
        @raylib.update_model_animation(model, anims, anim_id, 0)
        anim_playing = true
      }
    }

    // Toggle skeleton drawing
    if @raylib.is_key_pressed(@raylib.KeyB) {
      draw_skeleton = not(draw_skeleton)
    }

    // Toggle mesh drawing
    if @raylib.is_key_pressed(@raylib.KeyM) {
      draw_mesh = not(draw_mesh)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_mode_3d(camera)

    // Draw 3d model with texture
    if draw_mesh {
      @raylib.draw_model(model, position, 1.0, @raylib.white)
    }

    // Draw the animated skeleton
    if draw_skeleton {
      let bone_count = @raylib.get_model_bone_count(model)
      // Loop to (boneCount - 1) because the last one is a special "no bone" bone,
      // needed to workaround buggy models
      // without a -1, we would always draw a cube at the origin
      for i = 0; i < bone_count - 1; i = i + 1 {
        if not(anim_playing) || anims_count == 0 {
          // Display the bind-pose skeleton
          let translation = @raylib.get_model_bind_pose_translation(model, i)
          @raylib.draw_cube(translation, 0.04, 0.04, 0.04, @raylib.red)

          let parent = @raylib.get_model_bone_parent(model, i)
          if parent >= 0 {
            let parent_translation = @raylib.get_model_bind_pose_translation(
              model, parent,
            )
            @raylib.draw_line_3d(translation, parent_translation, @raylib.red)
          }
        } else {
          // Display the frame-pose skeleton
          let translation = @raylib.get_model_animation_frame_pose_translation(
            anims, anim_id, anim_frame_counter, i,
          )
          @raylib.draw_cube(translation, 0.05, 0.05, 0.05, @raylib.red)

          let parent = @raylib.get_model_animation_bone_parent(
            anims, anim_id, i,
          )
          if parent >= 0 {
            let parent_translation = @raylib.get_model_animation_frame_pose_translation(
              anims, anim_id, anim_frame_counter, parent,
            )
            @raylib.draw_line_3d(translation, parent_translation, @raylib.red)
          }
        }
      }
    }

    @raylib.draw_grid(10, 1.0) // Draw a grid

    @raylib.end_mode_3d()

    @raylib.draw_text(
      "PRESS SPACE to PLAY MODEL ANIMATION",
      10,
      @raylib.get_screen_height() - 80,
      10,
      @raylib.maroon,
    )
    @raylib.draw_text(
      "PRESS N to STEP ONE ANIMATION FRAME",
      10,
      @raylib.get_screen_height() - 60,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "PRESS C to CYCLE THROUGH ANIMATIONS",
      10,
      @raylib.get_screen_height() - 40,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "PRESS M to toggle MESH, B to toggle SKELETON DRAWING",
      10,
      @raylib.get_screen_height() - 20,
      10,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "(c) CesiumMan model by KhronosGroup",
      @raylib.get_screen_width() - 210,
      @raylib.get_screen_height() - 20,
      10,
      @raylib.gray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_model_animations(anims)
  @raylib.unload_model(model)
  @raylib.close_window()
}
