///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - 3d camera mode",
  )

  // Define the camera to look into our 3d world
  let camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0), // Camera position
    @raylib.Vector3::new(0.0, 0.0, 0.0), // Camera looking at point
    @raylib.Vector3::new(0.0, 1.0, 0.0), // Camera up vector
    45.0, // Camera field-of-view Y
    @raylib.CameraPerspective, // Camera projection type
  )

  let cube_position = @raylib.Vector3::new(0.0, 0.0, 0.0)

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_mode_3d(camera)

    @raylib.draw_cube(cube_position, 2.0, 2.0, 2.0, @raylib.red)
    @raylib.draw_cube_wires(cube_position, 2.0, 2.0, 2.0, @raylib.maroon)

    @raylib.draw_grid(10, 1.0)

    @raylib.end_mode_3d()

    @raylib.draw_text(
      "Welcome to the third dimension!", 10, 40, 20, @raylib.darkgray,
    )

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
