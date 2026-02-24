///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - 3d camera first person",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 2.0, 4.0), // position
    @raylib.Vector3::new(0.0, 2.0, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    60.0, // fovy
    @raylib.CameraPerspective, // projection
  )

  let mut camera_mode = @raylib.CameraFirstPerson

  // Generates some random columns
  let max_columns = 20
  let heights : Array[Float] = []
  let positions : Array[@raylib.Vector3] = []
  let colors : Array[@raylib.Color] = []

  for i = 0; i < max_columns; i = i + 1 {
    let h = Float::from_int(@raylib.get_random_value(1, 12))
    heights.push(h)
    positions.push(
      @raylib.Vector3::new(
        Float::from_int(@raylib.get_random_value(-15, 15)),
        h / 2.0,
        Float::from_int(@raylib.get_random_value(-15, 15)),
      ),
    )
    colors.push(
      @raylib.Color::new(
        @raylib.get_random_value(20, 255),
        @raylib.get_random_value(10, 55),
        30,
        255,
      ),
    )
  }

  @raylib.disable_cursor() // Limit cursor to relative movement inside the window

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Switch camera mode
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      camera_mode = @raylib.CameraFree
      camera = @raylib.Camera3D::new(
        camera.position,
        camera.target,
        @raylib.Vector3::new(0.0, 1.0, 0.0),
        camera.fovy,
        camera.projection,
      )
    }
    if @raylib.is_key_pressed(@raylib.KeyTwo) {
      camera_mode = @raylib.CameraFirstPerson
      camera = @raylib.Camera3D::new(
        camera.position,
        camera.target,
        @raylib.Vector3::new(0.0, 1.0, 0.0),
        camera.fovy,
        camera.projection,
      )
    }
    if @raylib.is_key_pressed(@raylib.KeyThree) {
      camera_mode = @raylib.CameraThirdPerson
      camera = @raylib.Camera3D::new(
        camera.position,
        camera.target,
        @raylib.Vector3::new(0.0, 1.0, 0.0),
        camera.fovy,
        camera.projection,
      )
    }
    if @raylib.is_key_pressed(@raylib.KeyFour) {
      camera_mode = @raylib.CameraOrbital
      camera = @raylib.Camera3D::new(
        camera.position,
        camera.target,
        @raylib.Vector3::new(0.0, 1.0, 0.0),
        camera.fovy,
        camera.projection,
      )
    }

    // Switch camera projection
    if @raylib.is_key_pressed(@raylib.KeyP) {
      if camera.projection == @raylib.CameraPerspective {
        // Create isometric view
        camera_mode = @raylib.CameraThirdPerson
        camera = @raylib.Camera3D::new(
          @raylib.Vector3::new(0.0, 2.0, -100.0),
          @raylib.Vector3::new(0.0, 2.0, 0.0),
          @raylib.Vector3::new(0.0, 1.0, 0.0),
          20.0,
          @raylib.CameraOrthographic,
        )
      } else if camera.projection == @raylib.CameraOrthographic {
        // Reset to default view
        camera_mode = @raylib.CameraThirdPerson
        camera = @raylib.Camera3D::new(
          @raylib.Vector3::new(0.0, 2.0, 10.0),
          @raylib.Vector3::new(0.0, 2.0, 0.0),
          @raylib.Vector3::new(0.0, 1.0, 0.0),
          60.0,
          @raylib.CameraPerspective,
        )
      }
    }

    // Update camera
    camera = @raylib.update_camera(camera, camera_mode)

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)

    // Draw ground
    @raylib.draw_plane(
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.Vector2::new(32.0, 32.0),
      @raylib.lightgray,
    )

    // Draw walls
    @raylib.draw_cube(
      @raylib.Vector3::new(-16.0, 2.5, 0.0),
      1.0,
      5.0,
      32.0,
      @raylib.blue,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(16.0, 2.5, 0.0),
      1.0,
      5.0,
      32.0,
      @raylib.lime,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(0.0, 2.5, 16.0),
      32.0,
      5.0,
      1.0,
      @raylib.gold,
    )

    // Draw some cubes around
    for i = 0; i < max_columns; i = i + 1 {
      @raylib.draw_cube(positions[i], 2.0, heights[i], 2.0, colors[i])
      @raylib.draw_cube_wires(
        positions[i],
        2.0,
        heights[i],
        2.0,
        @raylib.maroon,
      )
    }

    // Draw player cube
    if camera_mode == @raylib.CameraThirdPerson {
      @raylib.draw_cube(camera.target, 0.5, 0.5, 0.5, @raylib.purple)
      @raylib.draw_cube_wires(camera.target, 0.5, 0.5, 0.5, @raylib.darkpurple)
    }

    @raylib.end_mode_3d()

    // Draw info boxes
    @raylib.draw_rectangle(5, 5, 330, 100, @raylib.fade(@raylib.skyblue, 0.5))
    @raylib.draw_rectangle_lines(5, 5, 330, 100, @raylib.blue)

    @raylib.draw_text("Camera controls:", 15, 15, 10, @raylib.black)
    @raylib.draw_text(
      "- Move keys: W, A, S, D, Space, Left-Ctrl", 15, 30, 10, @raylib.black,
    )
    @raylib.draw_text(
      "- Look around: arrow keys or mouse", 15, 45, 10, @raylib.black,
    )
    @raylib.draw_text(
      "- Camera mode keys: 1, 2, 3, 4", 15, 60, 10, @raylib.black,
    )
    @raylib.draw_text(
      "- Zoom keys: num-plus, num-minus or mouse scroll", 15, 75, 10, @raylib.black,
    )
    @raylib.draw_text("- Camera projection key: P", 15, 90, 10, @raylib.black)

    @raylib.draw_rectangle(600, 5, 195, 100, @raylib.fade(@raylib.skyblue, 0.5))
    @raylib.draw_rectangle_lines(600, 5, 195, 100, @raylib.blue)

    @raylib.draw_text("Camera status:", 610, 15, 10, @raylib.black)

    let mode_str = if camera_mode == @raylib.CameraFree {
      "FREE"
    } else if camera_mode == @raylib.CameraFirstPerson {
      "FIRST_PERSON"
    } else if camera_mode == @raylib.CameraThirdPerson {
      "THIRD_PERSON"
    } else if camera_mode == @raylib.CameraOrbital {
      "ORBITAL"
    } else {
      "CUSTOM"
    }
    @raylib.draw_text("- Mode: \{mode_str}", 610, 30, 10, @raylib.black)

    let proj_str = if camera.projection == @raylib.CameraPerspective {
      "PERSPECTIVE"
    } else if camera.projection == @raylib.CameraOrthographic {
      "ORTHOGRAPHIC"
    } else {
      "CUSTOM"
    }
    @raylib.draw_text("- Projection: \{proj_str}", 610, 45, 10, @raylib.black)

    @raylib.draw_text(
      "- Position: (\{camera.position.x}, \{camera.position.y}, \{camera.position.z})",
      610,
      60,
      10,
      @raylib.black,
    )
    @raylib.draw_text(
      "- Target: (\{camera.target.x}, \{camera.target.y}, \{camera.target.z})",
      610,
      75,
      10,
      @raylib.black,
    )
    @raylib.draw_text(
      "- Up: (\{camera.up.x}, \{camera.up.y}, \{camera.up.z})",
      610,
      90,
      10,
      @raylib.black,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
