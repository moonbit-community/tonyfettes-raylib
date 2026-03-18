///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - 3d camera split screen",
  )

  // Setup player 1 camera and screen
  let mut camera_player1 = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 1.0, -3.0), // position
    @raylib.Vector3::new(0.0, 1.0, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    45.0, // fovy
    @raylib.CameraPerspective, // projection
  )

  let screen_player1 = @raylib.load_render_texture(
    screen_width / 2,
    screen_height,
  )

  // Setup player 2 camera and screen
  let mut camera_player2 = @raylib.Camera3D::new(
    @raylib.Vector3::new(-3.0, 3.0, 0.0), // position
    @raylib.Vector3::new(0.0, 3.0, 0.0), // target
    @raylib.Vector3::new(0.0, 1.0, 0.0), // up
    45.0, // fovy
    @raylib.CameraPerspective, // projection
  )

  let screen_player2 = @raylib.load_render_texture(
    screen_width / 2,
    screen_height,
  )

  // Build a flipped rectangle the size of the split view to use for drawing later
  let split_screen_rect = @raylib.Rectangle::new(
    0.0,
    0.0,
    Float::from_int(screen_width / 2),
    -Float::from_int(screen_height),
  )

  // Grid data
  let count = 5
  let spacing : Float = 4.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let offset_this_frame = (10.0 : Float) * @raylib.get_frame_time()

    // Move Player1 forward and backwards (no turning)
    if @raylib.is_key_down(@raylib.KeyW) {
      camera_player1 = @raylib.Camera3D::new(
        @raylib.Vector3::new(
          camera_player1.position.x,
          camera_player1.position.y,
          camera_player1.position.z + offset_this_frame,
        ),
        @raylib.Vector3::new(
          camera_player1.target.x,
          camera_player1.target.y,
          camera_player1.target.z + offset_this_frame,
        ),
        camera_player1.up,
        camera_player1.fovy,
        camera_player1.projection,
      )
    } else if @raylib.is_key_down(@raylib.KeyS) {
      camera_player1 = @raylib.Camera3D::new(
        @raylib.Vector3::new(
          camera_player1.position.x,
          camera_player1.position.y,
          camera_player1.position.z - offset_this_frame,
        ),
        @raylib.Vector3::new(
          camera_player1.target.x,
          camera_player1.target.y,
          camera_player1.target.z - offset_this_frame,
        ),
        camera_player1.up,
        camera_player1.fovy,
        camera_player1.projection,
      )
    }

    // Move Player2 forward and backwards (no turning)
    if @raylib.is_key_down(@raylib.KeyUp) {
      camera_player2 = @raylib.Camera3D::new(
        @raylib.Vector3::new(
          camera_player2.position.x + offset_this_frame,
          camera_player2.position.y,
          camera_player2.position.z,
        ),
        @raylib.Vector3::new(
          camera_player2.target.x + offset_this_frame,
          camera_player2.target.y,
          camera_player2.target.z,
        ),
        camera_player2.up,
        camera_player2.fovy,
        camera_player2.projection,
      )
    } else if @raylib.is_key_down(@raylib.KeyDown) {
      camera_player2 = @raylib.Camera3D::new(
        @raylib.Vector3::new(
          camera_player2.position.x - offset_this_frame,
          camera_player2.position.y,
          camera_player2.position.z,
        ),
        @raylib.Vector3::new(
          camera_player2.target.x - offset_this_frame,
          camera_player2.target.y,
          camera_player2.target.z,
        ),
        camera_player2.up,
        camera_player2.fovy,
        camera_player2.projection,
      )
    }

    // Draw
    // Draw Player1 view to the render texture
    @raylib.begin_texture_mode(screen_player1)
    @raylib.clear_background(@raylib.skyblue)
    @raylib.begin_mode_3d(camera_player1)

    // Draw scene: grid of cube trees on a plane to make a "world"
    @raylib.draw_plane(
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.Vector2::new(50.0, 50.0),
      @raylib.beige,
    )

    let count_f = Float::from_int(count)
    let mut x = -count_f * spacing
    while x <= count_f * spacing {
      let mut z = -count_f * spacing
      while z <= count_f * spacing {
        @raylib.draw_cube(
          @raylib.Vector3::new(x, 1.5, z),
          1.0,
          1.0,
          1.0,
          @raylib.lime,
        )
        @raylib.draw_cube(
          @raylib.Vector3::new(x, 0.5, z),
          0.25,
          1.0,
          0.25,
          @raylib.brown,
        )
        z = z + spacing
      }
      x = x + spacing
    }

    // Draw a cube at each player's position
    @raylib.draw_cube(camera_player1.position, 1.0, 1.0, 1.0, @raylib.red)
    @raylib.draw_cube(camera_player2.position, 1.0, 1.0, 1.0, @raylib.blue)

    @raylib.end_mode_3d()
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width() / 2,
      40,
      @raylib.fade(@raylib.raywhite, 0.8),
    )
    @raylib.draw_text("PLAYER1: W/S to move", 10, 10, 20, @raylib.maroon)
    @raylib.end_texture_mode()

    // Draw Player2 view to the render texture
    @raylib.begin_texture_mode(screen_player2)
    @raylib.clear_background(@raylib.skyblue)
    @raylib.begin_mode_3d(camera_player2)

    // Draw scene: grid of cube trees on a plane to make a "world"
    @raylib.draw_plane(
      @raylib.Vector3::new(0.0, 0.0, 0.0),
      @raylib.Vector2::new(50.0, 50.0),
      @raylib.beige,
    )

    x = -count_f * spacing
    while x <= count_f * spacing {
      let mut z = -count_f * spacing
      while z <= count_f * spacing {
        @raylib.draw_cube(
          @raylib.Vector3::new(x, 1.5, z),
          1.0,
          1.0,
          1.0,
          @raylib.lime,
        )
        @raylib.draw_cube(
          @raylib.Vector3::new(x, 0.5, z),
          0.25,
          1.0,
          0.25,
          @raylib.brown,
        )
        z = z + spacing
      }
      x = x + spacing
    }

    // Draw a cube at each player's position
    @raylib.draw_cube(camera_player1.position, 1.0, 1.0, 1.0, @raylib.red)
    @raylib.draw_cube(camera_player2.position, 1.0, 1.0, 1.0, @raylib.blue)

    @raylib.end_mode_3d()
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width() / 2,
      40,
      @raylib.fade(@raylib.raywhite, 0.8),
    )
    @raylib.draw_text("PLAYER2: UP/DOWN to move", 10, 10, 20, @raylib.darkblue)
    @raylib.end_texture_mode()

    // Draw both views render textures to the screen side by side
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.black)
    @raylib.draw_render_texture_rec(
      screen_player1,
      split_screen_rect,
      @raylib.Vector2::new(0.0, 0.0),
      @raylib.white,
    )
    @raylib.draw_render_texture_rec(
      screen_player2,
      split_screen_rect,
      @raylib.Vector2::new(Float::from_int(screen_width) / 2.0, 0.0),
      @raylib.white,
    )
    @raylib.draw_rectangle(
      @raylib.get_screen_width() / 2 - 2,
      0,
      4,
      @raylib.get_screen_height(),
      @raylib.lightgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_render_texture(screen_player1)
  @raylib.unload_render_texture(screen_player2)
  @raylib.close_window()
}
