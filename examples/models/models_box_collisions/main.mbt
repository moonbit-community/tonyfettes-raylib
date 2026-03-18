///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [models] example - box collisions",
  )

  // Define the camera to look into our 3d world
  let camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 10.0, 10.0), // position
    @raylib.Vector3::new(0.0, 0.0, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    45.0, // fovy
    @raylib.CameraPerspective, // projection
  )

  let mut player_position = @raylib.Vector3::new(0.0, 1.0, 2.0)
  let player_size = @raylib.Vector3::new(1.0, 2.0, 1.0)
  let mut player_color = @raylib.green

  let enemy_box_pos = @raylib.Vector3::new(-4.0, 1.0, 0.0)
  let enemy_box_size = @raylib.Vector3::new(2.0, 2.0, 2.0)

  let enemy_sphere_pos = @raylib.Vector3::new(4.0, 0.0, 0.0)
  let enemy_sphere_size : Float = 1.5

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update

    // Move player
    if @raylib.is_key_down(@raylib.KeyRight) {
      player_position = @raylib.Vector3::new(
        player_position.x + 0.2,
        player_position.y,
        player_position.z,
      )
    } else if @raylib.is_key_down(@raylib.KeyLeft) {
      player_position = @raylib.Vector3::new(
        player_position.x - 0.2,
        player_position.y,
        player_position.z,
      )
    } else if @raylib.is_key_down(@raylib.KeyDown) {
      player_position = @raylib.Vector3::new(
        player_position.x,
        player_position.y,
        player_position.z + 0.2,
      )
    } else if @raylib.is_key_down(@raylib.KeyUp) {
      player_position = @raylib.Vector3::new(
        player_position.x,
        player_position.y,
        player_position.z - 0.2,
      )
    }

    let mut collision = false

    // Check collisions player vs enemy-box
    let player_box = @raylib.BoundingBox::new(
      @raylib.Vector3::new(
        player_position.x - player_size.x / 2.0,
        player_position.y - player_size.y / 2.0,
        player_position.z - player_size.z / 2.0,
      ),
      @raylib.Vector3::new(
        player_position.x + player_size.x / 2.0,
        player_position.y + player_size.y / 2.0,
        player_position.z + player_size.z / 2.0,
      ),
    )
    let enemy_box = @raylib.BoundingBox::new(
      @raylib.Vector3::new(
        enemy_box_pos.x - enemy_box_size.x / 2.0,
        enemy_box_pos.y - enemy_box_size.y / 2.0,
        enemy_box_pos.z - enemy_box_size.z / 2.0,
      ),
      @raylib.Vector3::new(
        enemy_box_pos.x + enemy_box_size.x / 2.0,
        enemy_box_pos.y + enemy_box_size.y / 2.0,
        enemy_box_pos.z + enemy_box_size.z / 2.0,
      ),
    )
    if @raylib.check_collision_boxes(player_box, enemy_box) {
      collision = true
    }

    // Check collisions player vs enemy-sphere
    if @raylib.check_collision_box_sphere(
        player_box, enemy_sphere_pos, enemy_sphere_size,
      ) {
      collision = true
    }

    if collision {
      player_color = @raylib.red
    } else {
      player_color = @raylib.green
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_3d(camera)

    // Draw enemy-box
    @raylib.draw_cube(
      enemy_box_pos,
      enemy_box_size.x,
      enemy_box_size.y,
      enemy_box_size.z,
      @raylib.gray,
    )
    @raylib.draw_cube_wires(
      enemy_box_pos,
      enemy_box_size.x,
      enemy_box_size.y,
      enemy_box_size.z,
      @raylib.darkgray,
    )

    // Draw enemy-sphere
    @raylib.draw_sphere(enemy_sphere_pos, enemy_sphere_size, @raylib.gray)
    @raylib.draw_sphere_wires(
      enemy_sphere_pos, enemy_sphere_size, 16, 16, @raylib.darkgray,
    )

    // Draw player
    @raylib.draw_cube_v(player_position, player_size, player_color)

    @raylib.draw_grid(10, 1.0)
    @raylib.end_mode_3d()
    @raylib.draw_text(
      "Move player with arrow keys to collide", 220, 40, 20, @raylib.gray,
    )
    @raylib.draw_fps(10, 10)
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
