///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - core world screen",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(10.0, 10.0, 10.0), // Camera position
    @raylib.Vector3::new(0.0, 0.0, 0.0), // Camera looking at point
    @raylib.Vector3::new(0.0, 1.0, 0.0), // Camera up vector
    45.0, // Camera field-of-view Y
    @raylib.CameraPerspective, // Camera projection type
  )

  let cube_position = @raylib.Vector3::new(0.0, 0.0, 0.0)

  @raylib.disable_cursor() // Limit cursor to relative movement inside the window

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraThirdPerson)

    // Calculate cube screen space position (with a little offset to be in top)
    let cube_screen_position = @raylib.get_world_to_screen(
      @raylib.Vector3::new(
        cube_position.x,
        cube_position.y + 2.5,
        cube_position.z,
      ),
      camera,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_mode_3d(camera)
    @raylib.draw_cube(cube_position, 2.0, 2.0, 2.0, @raylib.red)
    @raylib.draw_cube_wires(cube_position, 2.0, 2.0, 2.0, @raylib.maroon)
    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()

    @raylib.draw_text(
      "Enemy: 100 / 100",
      cube_screen_position.x.to_int() -
      @raylib.measure_text("Enemy: 100/100", 20) / 2,
      cube_screen_position.y.to_int(),
      20,
      @raylib.black,
    )

    let sx = cube_screen_position.x.to_int()
    let sy = cube_screen_position.y.to_int()
    @raylib.draw_text(
      "Cube position in screen space coordinates: [\{sx}, \{sy}]",
      10,
      10,
      20,
      @raylib.lime,
    )
    @raylib.draw_text(
      "Text 2d should be always on top of the cube", 10, 40, 20, @raylib.gray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
