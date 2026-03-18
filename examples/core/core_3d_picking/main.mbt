///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - 3d picking",
  )

  // Define the camera to look into our 3d world
  let mut camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(10.0, 10.0, 10.0), // position
    @raylib.Vector3::new(0.0, 0.0, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    45.0, // fovy
    @raylib.CameraPerspective, // projection
  )

  let cube_position = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let cube_size = @raylib.Vector3::new(2.0, 2.0, 2.0)

  let mut ray = @raylib.Ray::new(
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
  )
  let mut collision_hit = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_cursor_hidden() {
      camera = @raylib.update_camera(camera, @raylib.CameraFirstPerson)
    }

    // Toggle camera controls
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) {
      if @raylib.is_cursor_hidden() {
        @raylib.enable_cursor()
      } else {
        @raylib.disable_cursor()
      }
    }

    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
      if not(collision_hit) {
        ray = @raylib.get_screen_to_world_ray(
          @raylib.get_mouse_position(),
          camera,
        )

        // Check collision between ray and box
        let box_ = @raylib.BoundingBox::new(
          @raylib.Vector3::new(
            cube_position.x - cube_size.x / 2.0,
            cube_position.y - cube_size.y / 2.0,
            cube_position.z - cube_size.z / 2.0,
          ),
          @raylib.Vector3::new(
            cube_position.x + cube_size.x / 2.0,
            cube_position.y + cube_size.y / 2.0,
            cube_position.z + cube_size.z / 2.0,
          ),
        )
        let result = @raylib.get_ray_collision_box(ray, box_)
        collision_hit = result.hit
      } else {
        collision_hit = false
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)

    if collision_hit {
      @raylib.draw_cube(
        cube_position,
        cube_size.x,
        cube_size.y,
        cube_size.z,
        @raylib.red,
      )
      @raylib.draw_cube_wires(
        cube_position,
        cube_size.x,
        cube_size.y,
        cube_size.z,
        @raylib.maroon,
      )
      @raylib.draw_cube_wires(
        cube_position,
        cube_size.x + 0.2,
        cube_size.y + 0.2,
        cube_size.z + 0.2,
        @raylib.green,
      )
    } else {
      @raylib.draw_cube(
        cube_position,
        cube_size.x,
        cube_size.y,
        cube_size.z,
        @raylib.gray,
      )
      @raylib.draw_cube_wires(
        cube_position,
        cube_size.x,
        cube_size.y,
        cube_size.z,
        @raylib.darkgray,
      )
    }

    @raylib.draw_ray(ray, @raylib.maroon)
    @raylib.draw_grid(10, 1.0)

    @raylib.end_mode_3d()

    @raylib.draw_text(
      "Try clicking on the box with your mouse!", 240, 10, 20, @raylib.darkgray,
    )

    if collision_hit {
      let text = "BOX SELECTED"
      let text_width = @raylib.measure_text(text, 30)
      @raylib.draw_text(
        text,
        (screen_width - text_width) / 2,
        (Float::from_int(screen_height) * 0.1).to_int(),
        30,
        @raylib.green,
      )
    }

    @raylib.draw_text(
      "Right click mouse to toggle camera controls", 10, 430, 10, @raylib.gray,
    )

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
