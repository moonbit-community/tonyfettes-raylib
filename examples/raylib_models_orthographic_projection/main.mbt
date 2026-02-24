///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - geometric shapes",
  )

  // Define the camera to look into our 3d world
  let fovy_perspective : Float = 45.0
  let width_orthographic : Float = 10.0

  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0), // position
    @raylib.Vector3::new(0.0, 0.0, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    fovy_perspective, // fovy
    @raylib.CameraPerspective, // projection
  )

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      if camera.projection == @raylib.CameraPerspective {
        camera = @raylib.Camera3D::new(
          camera.position,
          camera.target,
          camera.up,
          width_orthographic,
          @raylib.CameraOrthographic,
        )
      } else {
        camera = @raylib.Camera3D::new(
          camera.position,
          camera.target,
          camera.up,
          fovy_perspective,
          @raylib.CameraPerspective,
        )
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_cube(
      @raylib.Vector3::new(-4.0, 0.0, 2.0),
      2.0,
      5.0,
      2.0,
      @raylib.red,
    )
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(-4.0, 0.0, 2.0),
      2.0,
      5.0,
      2.0,
      @raylib.gold,
    )
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(-4.0, 0.0, -2.0),
      3.0,
      6.0,
      2.0,
      @raylib.maroon,
    )
    @raylib.draw_sphere(
      @raylib.Vector3::new(-1.0, 0.0, -2.0),
      1.0,
      @raylib.green,
    )
    @raylib.draw_sphere_wires(
      @raylib.Vector3::new(1.0, 0.0, 2.0),
      2.0,
      16,
      16,
      @raylib.lime,
    )
    @raylib.draw_cylinder(
      @raylib.Vector3::new(4.0, 0.0, -2.0),
      1.0,
      2.0,
      3.0,
      4,
      @raylib.skyblue,
    )
    @raylib.draw_cylinder_wires(
      @raylib.Vector3::new(4.0, 0.0, -2.0),
      1.0,
      2.0,
      3.0,
      4,
      @raylib.darkblue,
    )
    @raylib.draw_cylinder_wires(
      @raylib.Vector3::new(4.5, -1.0, 2.0),
      1.0,
      1.0,
      2.0,
      6,
      @raylib.brown,
    )
    @raylib.draw_cylinder(
      @raylib.Vector3::new(1.0, 0.0, -4.0),
      0.0,
      1.5,
      3.0,
      8,
      @raylib.gold,
    )
    @raylib.draw_cylinder_wires(
      @raylib.Vector3::new(1.0, 0.0, -4.0),
      0.0,
      1.5,
      3.0,
      8,
      @raylib.pink,
    )
    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()
    @raylib.draw_text(
      "Press Spacebar to switch camera type",
      10,
      @raylib.get_screen_height() - 30,
      20,
      @raylib.darkgray,
    )
    if camera.projection == @raylib.CameraOrthographic {
      @raylib.draw_text("ORTHOGRAPHIC", 10, 40, 20, @raylib.black)
    } else if camera.projection == @raylib.CameraPerspective {
      @raylib.draw_text("PERSPECTIVE", 10, 40, 20, @raylib.black)
    }
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
