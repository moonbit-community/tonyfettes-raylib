///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - 3d camera free",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(10.0, 10.0, 10.0), // position
    @raylib.Vector3::new(0.0, 0.0, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    45.0, // fovy
    @raylib.CameraPerspective, // projection
  )

  let cube_position = @raylib.Vector3::new(0.0, 0.0, 0.0)

  @raylib.disable_cursor() // Limit cursor to relative movement inside the window

  @raylib.set_target_fps(60) // Set our game to run at 60 frames-per-second

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraFree)
    if @raylib.is_key_pressed(@raylib.KeyZ) {
      camera = @raylib.Camera3D::new(
        camera.position,
        @raylib.Vector3::new(0.0, 0.0, 0.0),
        camera.up,
        camera.fovy,
        camera.projection,
      )
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_cube(cube_position, 2.0, 2.0, 2.0, @raylib.red)
    @raylib.draw_cube_wires(cube_position, 2.0, 2.0, 2.0, @raylib.maroon)
    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()
    @raylib.draw_rectangle(10, 10, 320, 93, @raylib.fade(@raylib.skyblue, 0.5))
    @raylib.draw_rectangle_lines(10, 10, 320, 93, @raylib.blue)
    @raylib.draw_text(
      "Free camera default controls:", 20, 20, 10, @raylib.black,
    )
    @raylib.draw_text(
      "- Mouse Wheel to Zoom in-out", 40, 40, 10, @raylib.darkgray,
    )
    @raylib.draw_text(
      "- Mouse Wheel Pressed to Pan", 40, 60, 10, @raylib.darkgray,
    )
    @raylib.draw_text("- Z to zoom to (0, 0, 0)", 40, 80, 10, @raylib.darkgray)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
