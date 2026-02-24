///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - waving cubes",
  )

  // Initialize the camera
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(30.0, 20.0, 30.0), // position
    @raylib.Vector3::new(0.0, 0.0, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    70.0, // fovy
    @raylib.CameraPerspective, // projection
  )

  // Specify the amount of blocks in each direction
  let num_blocks = 15

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let time = @raylib.get_time()

    // Calculate time scale for cube position and size
    let scale = Float::from_double(2.0 + @math.sin(time)) * 0.7

    // Move camera around the scene
    let camera_time = time * 0.3
    camera = @raylib.Camera3D::new(
      @raylib.Vector3::new(
        Float::from_double(@math.cos(camera_time)) * 40.0,
        camera.position.y,
        Float::from_double(@math.sin(camera_time)) * 40.0,
      ),
      camera.target,
      camera.up,
      camera.fovy,
      camera.projection,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_grid(10, 5.0)
    for x = 0; x < num_blocks; x = x + 1 {
      for y = 0; y < num_blocks; y = y + 1 {
        for z = 0; z < num_blocks; z = z + 1 {
          // Scale of the blocks depends on x/y/z positions
          let block_scale = Float::from_int(x + y + z) / 30.0

          // Scatter makes the waving effect by adding block_scale over time
          let scatter = @math.sinf(
            block_scale * 20.0 + Float::from_double(time * 4.0),
          )

          // Calculate the cube position
          let cube_pos = @raylib.Vector3::new(
            Float::from_int(x - num_blocks / 2) * (scale * 3.0) + scatter,
            Float::from_int(y - num_blocks / 2) * (scale * 2.0) + scatter,
            Float::from_int(z - num_blocks / 2) * (scale * 3.0) + scatter,
          )

          // Pick a color with a hue depending on cube position for the rainbow color effect
          let cube_color = @raylib.color_from_hsv(
            Float::from_int((x + y + z) * 18 % 360),
            0.75,
            0.9,
          )

          // Calculate cube size
          let cube_size : Float = (2.4 - scale) * block_scale

          // And finally, draw the cube!
          @raylib.draw_cube(
            cube_pos, cube_size, cube_size, cube_size, cube_color,
          )
        }
      }
    }
    @raylib.end_mode_3d()
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
