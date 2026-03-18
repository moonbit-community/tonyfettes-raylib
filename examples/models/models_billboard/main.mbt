///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - billboard rendering",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(5.0, 4.0, 5.0),
    @raylib.Vector3::new(0.0, 2.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    45.0,
    @raylib.CameraPerspective,
  )

  // Generate a billboard texture (checked pattern as substitute for billboard.png)
  let bill_image = @raylib.gen_image_checked(
    64, 64, 8, 8, @raylib.blue, @raylib.white,
  )
  let bill = @raylib.load_texture_from_image(bill_image)
  @raylib.unload_image(bill_image)

  let bill_position_static = @raylib.Vector3::new(0.0, 2.0, 0.0)
  let bill_position_rotating = @raylib.Vector3::new(1.0, 2.0, 1.0)

  // Entire billboard texture source rectangle
  let source = @raylib.Rectangle::new(0.0, 0.0, 64.0, 64.0)

  // Billboard locked on axis-Y
  let bill_up = @raylib.Vector3::new(0.0, 1.0, 0.0)

  // Set the height of the rotating billboard to 1.0 with the aspect ratio fixed
  let size = @raylib.Vector2::new(1.0, 1.0)

  // Rotate around origin (center of the image)
  let origin = @raylib.Vector2::new(0.5, 0.5)

  let mut rotation : Float = 0.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    camera = @raylib.update_camera(camera, @raylib.CameraOrbital)
    rotation = rotation + 0.4

    // Compute distances for draw order
    let dx_s = camera.position.x - bill_position_static.x
    let dy_s = camera.position.y - bill_position_static.y
    let dz_s = camera.position.z - bill_position_static.z
    let distance_static = dx_s * dx_s + dy_s * dy_s + dz_s * dz_s
    let dx_r = camera.position.x - bill_position_rotating.x
    let dy_r = camera.position.y - bill_position_rotating.y
    let dz_r = camera.position.z - bill_position_rotating.z
    let distance_rotating = dx_r * dx_r + dy_r * dy_r + dz_r * dz_r

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)
    @raylib.draw_grid(10, 1.0)

    // Draw order matters!
    if distance_static > distance_rotating {
      @raylib.draw_billboard(
        camera, bill, bill_position_static, 2.0, @raylib.white,
      )
      @raylib.draw_billboard_pro(
        camera, bill, source, bill_position_rotating, bill_up, size, origin, rotation,
        @raylib.white,
      )
    } else {
      @raylib.draw_billboard_pro(
        camera, bill, source, bill_position_rotating, bill_up, size, origin, rotation,
        @raylib.white,
      )
      @raylib.draw_billboard(
        camera, bill, bill_position_static, 2.0, @raylib.white,
      )
    }
    @raylib.end_mode_3d()
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(bill)
  @raylib.close_window()
}
