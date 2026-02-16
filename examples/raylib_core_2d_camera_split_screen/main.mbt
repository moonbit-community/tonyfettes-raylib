///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 440
  let player_size : Float = 40.0

  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - 2d camera split screen",
  )

  let mut player1 = @raylib.Rectangle::new(
    200.0, 200.0, player_size, player_size,
  )
  let mut player2 = @raylib.Rectangle::new(
    250.0, 200.0, player_size, player_size,
  )

  let mut camera1 = @raylib.Camera2D::new(
    @raylib.Vector2::new(200.0, 200.0), // offset
    @raylib.Vector2::new(player1.x, player1.y), // target
    0.0, // rotation
    1.0, // zoom
  )

  let mut camera2 = @raylib.Camera2D::new(
    @raylib.Vector2::new(200.0, 200.0), // offset
    @raylib.Vector2::new(player2.x, player2.y), // target
    0.0, // rotation
    1.0, // zoom
  )

  let screen_camera1 = @raylib.load_render_texture(
    screen_width / 2,
    screen_height,
  )
  let screen_camera2 = @raylib.load_render_texture(
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

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_down(@raylib.KeyS) {
      player1 = @raylib.Rectangle::new(
        player1.x,
        player1.y + 3.0,
        player1.width,
        player1.height,
      )
    } else if @raylib.is_key_down(@raylib.KeyW) {
      player1 = @raylib.Rectangle::new(
        player1.x,
        player1.y - 3.0,
        player1.width,
        player1.height,
      )
    }
    if @raylib.is_key_down(@raylib.KeyD) {
      player1 = @raylib.Rectangle::new(
        player1.x + 3.0,
        player1.y,
        player1.width,
        player1.height,
      )
    } else if @raylib.is_key_down(@raylib.KeyA) {
      player1 = @raylib.Rectangle::new(
        player1.x - 3.0,
        player1.y,
        player1.width,
        player1.height,
      )
    }

    if @raylib.is_key_down(@raylib.KeyUp) {
      player2 = @raylib.Rectangle::new(
        player2.x,
        player2.y - 3.0,
        player2.width,
        player2.height,
      )
    } else if @raylib.is_key_down(@raylib.KeyDown) {
      player2 = @raylib.Rectangle::new(
        player2.x,
        player2.y + 3.0,
        player2.width,
        player2.height,
      )
    }
    if @raylib.is_key_down(@raylib.KeyRight) {
      player2 = @raylib.Rectangle::new(
        player2.x + 3.0,
        player2.y,
        player2.width,
        player2.height,
      )
    } else if @raylib.is_key_down(@raylib.KeyLeft) {
      player2 = @raylib.Rectangle::new(
        player2.x - 3.0,
        player2.y,
        player2.width,
        player2.height,
      )
    }

    camera1 = @raylib.Camera2D::new(
      camera1.offset,
      @raylib.Vector2::new(player1.x, player1.y),
      camera1.rotation,
      camera1.zoom,
    )
    camera2 = @raylib.Camera2D::new(
      camera2.offset,
      @raylib.Vector2::new(player2.x, player2.y),
      camera2.rotation,
      camera2.zoom,
    )

    // Draw
    @raylib.begin_texture_mode(screen_camera1)
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_2d(camera1)

    // Draw full scene with first camera
    let player_size_int = player_size.to_int()
    for i = 0; i < screen_width / player_size_int + 1; i = i + 1 {
      @raylib.draw_line_v(
        @raylib.Vector2::new(Float::from_int(player_size_int * i), 0.0),
        @raylib.Vector2::new(
          Float::from_int(player_size_int * i),
          Float::from_int(screen_height),
        ),
        @raylib.lightgray,
      )
    }
    for i = 0; i < screen_height / player_size_int + 1; i = i + 1 {
      @raylib.draw_line_v(
        @raylib.Vector2::new(0.0, Float::from_int(player_size_int * i)),
        @raylib.Vector2::new(
          Float::from_int(screen_width),
          Float::from_int(player_size_int * i),
        ),
        @raylib.lightgray,
      )
    }
    for i = 0; i < screen_width / player_size_int; i = i + 1 {
      for j = 0; j < screen_height / player_size_int; j = j + 1 {
        @raylib.draw_text(
          "[\{i},\{j}]",
          10 + player_size_int * i,
          15 + player_size_int * j,
          10,
          @raylib.lightgray,
        )
      }
    }

    @raylib.draw_rectangle_rec(player1, @raylib.red)
    @raylib.draw_rectangle_rec(player2, @raylib.blue)
    @raylib.end_mode_2d()
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width() / 2,
      30,
      @raylib.fade(@raylib.raywhite, 0.6),
    )
    @raylib.draw_text("PLAYER1: W/S/A/D to move", 10, 10, 10, @raylib.maroon)
    @raylib.end_texture_mode()

    @raylib.begin_texture_mode(screen_camera2)
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_2d(camera2)

    // Draw full scene with second camera
    for i = 0; i < screen_width / player_size_int + 1; i = i + 1 {
      @raylib.draw_line_v(
        @raylib.Vector2::new(Float::from_int(player_size_int * i), 0.0),
        @raylib.Vector2::new(
          Float::from_int(player_size_int * i),
          Float::from_int(screen_height),
        ),
        @raylib.lightgray,
      )
    }
    for i = 0; i < screen_height / player_size_int + 1; i = i + 1 {
      @raylib.draw_line_v(
        @raylib.Vector2::new(0.0, Float::from_int(player_size_int * i)),
        @raylib.Vector2::new(
          Float::from_int(screen_width),
          Float::from_int(player_size_int * i),
        ),
        @raylib.lightgray,
      )
    }
    for i = 0; i < screen_width / player_size_int; i = i + 1 {
      for j = 0; j < screen_height / player_size_int; j = j + 1 {
        @raylib.draw_text(
          "[\{i},\{j}]",
          10 + player_size_int * i,
          15 + player_size_int * j,
          10,
          @raylib.lightgray,
        )
      }
    }

    @raylib.draw_rectangle_rec(player1, @raylib.red)
    @raylib.draw_rectangle_rec(player2, @raylib.blue)
    @raylib.end_mode_2d()
    @raylib.draw_rectangle(
      0,
      0,
      @raylib.get_screen_width() / 2,
      30,
      @raylib.fade(@raylib.raywhite, 0.6),
    )
    @raylib.draw_text(
      "PLAYER2: UP/DOWN/LEFT/RIGHT to move", 10, 10, 10, @raylib.darkblue,
    )
    @raylib.end_texture_mode()

    // Draw both views render textures to the screen side by side
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.black)
    @raylib.draw_render_texture_rec(
      screen_camera1,
      split_screen_rect,
      @raylib.Vector2::new(0.0, 0.0),
      @raylib.white,
    )
    @raylib.draw_render_texture_rec(
      screen_camera2,
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
  @raylib.unload_render_texture(screen_camera1)
  @raylib.unload_render_texture(screen_camera2)
  @raylib.close_window()
}
