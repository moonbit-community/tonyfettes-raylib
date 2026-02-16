///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - 2d camera",
  )

  // Player rectangle
  let mut player_x : Float = 400.0
  let player_y : Float = 280.0
  let player_w : Float = 40.0
  let player_h : Float = 40.0

  // Generate buildings
  let max_buildings = 100
  let buildings : Array[@raylib.Rectangle] = []
  let build_colors : Array[@raylib.Color] = []
  let mut spacing = 0
  for i = 0; i < max_buildings; i = i + 1 {
    let w = Float::from_int(@raylib.get_random_value(50, 200))
    let h = Float::from_int(@raylib.get_random_value(100, 800))
    let y : Float = Float::from_int(screen_height) - 130.0 - h
    let x : Float = -6000.0 + Float::from_int(spacing)
    buildings.push(@raylib.Rectangle::new(x, y, w, h))
    spacing += w.to_int()
    build_colors.push(
      @raylib.Color::new(
        @raylib.get_random_value(200, 240),
        @raylib.get_random_value(200, 240),
        @raylib.get_random_value(200, 250),
        255,
      ),
    )
  }

  // Camera setup
  let mut camera = @raylib.Camera2D::new(
    @raylib.Vector2::new(
      Float::from_int(screen_width) / 2.0,
      Float::from_int(screen_height) / 2.0,
    ),
    @raylib.Vector2::new(player_x + 20.0, player_y + 20.0),
    0.0,
    1.0,
  )
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Player movement
    if @raylib.is_key_down(@raylib.KeyRight) {
      player_x += 2.0
    } else if @raylib.is_key_down(@raylib.KeyLeft) {
      player_x -= 2.0
    }

    // Camera target follows player
    let target = @raylib.Vector2::new(player_x + 20.0, player_y + 20.0)

    // Camera rotation controls
    let mut rotation = camera.rotation
    if @raylib.is_key_down(@raylib.KeyA) {
      rotation -= 1.0
    } else if @raylib.is_key_down(@raylib.KeyS) {
      rotation += 1.0
    }

    // Limit camera rotation to 80 degrees (-40 to 40)
    if rotation > 40.0 {
      rotation = 40.0
    } else if rotation < -40.0 {
      rotation = -40.0
    }

    // Camera zoom controls
    let mut zoom = camera.zoom + @raylib.get_mouse_wheel_move() * 0.05
    if zoom > 3.0 {
      zoom = 3.0
    } else if zoom < 0.1 {
      zoom = 0.1
    }

    // Camera reset (zoom and rotation)
    if @raylib.is_key_pressed(@raylib.KeyR) {
      zoom = 1.0
      rotation = 0.0
    }

    // Reconstruct camera with updated values
    camera = @raylib.Camera2D::new(camera.offset, target, rotation, zoom)

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.begin_mode_2d(camera)

    // Ground
    @raylib.draw_rectangle(-6000, 320, 13000, 8000, @raylib.darkgray)

    // Buildings
    for i = 0; i < max_buildings; i = i + 1 {
      @raylib.draw_rectangle_rec(buildings[i], build_colors[i])
    }

    // Player
    @raylib.draw_rectangle_rec(
      @raylib.Rectangle::new(player_x, player_y, player_w, player_h),
      @raylib.red,
    )

    // Crosshair lines at camera target
    @raylib.draw_line(
      camera.target.x.to_int(),
      -screen_height * 10,
      camera.target.x.to_int(),
      screen_height * 10,
      @raylib.green,
    )
    @raylib.draw_line(
      -screen_width * 10,
      camera.target.y.to_int(),
      screen_width * 10,
      camera.target.y.to_int(),
      @raylib.green,
    )

    @raylib.end_mode_2d()

    // Screen area label
    @raylib.draw_text("SCREEN AREA", 640, 10, 20, @raylib.red)

    // Screen border
    @raylib.draw_rectangle(0, 0, screen_width, 5, @raylib.red)
    @raylib.draw_rectangle(0, 5, 5, screen_height - 10, @raylib.red)
    @raylib.draw_rectangle(
      screen_width - 5,
      5,
      5,
      screen_height - 10,
      @raylib.red,
    )
    @raylib.draw_rectangle(0, screen_height - 5, screen_width, 5, @raylib.red)

    // Info box background
    @raylib.draw_rectangle_rec(
      @raylib.Rectangle::new(10.0, 10.0, 250.0, 113.0),
      @raylib.fade(@raylib.skyblue, 0.5),
    )
    @raylib.draw_rectangle_lines(10, 10, 250, 113, @raylib.blue)

    // Info text
    @raylib.draw_text("Free 2d camera controls:", 20, 20, 10, @raylib.black)
    @raylib.draw_text(
      "- Right/Left to move Offset", 40, 40, 10, @raylib.darkgray,
    )
    @raylib.draw_text(
      "- Mouse Wheel to Zoom in-out", 40, 60, 10, @raylib.darkgray,
    )
    @raylib.draw_text("- A / S to Rotate", 40, 80, 10, @raylib.darkgray)
    @raylib.draw_text(
      "- R to reset Zoom and Rotation", 40, 100, 10, @raylib.darkgray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
