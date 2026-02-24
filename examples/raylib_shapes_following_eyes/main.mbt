///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - following eyes",
  )

  let sclera_left_position = @raylib.Vector2::new(
    Float::from_int(@raylib.get_screen_width()) / 2.0 - 100.0,
    Float::from_int(@raylib.get_screen_height()) / 2.0,
  )
  let sclera_right_position = @raylib.Vector2::new(
    Float::from_int(@raylib.get_screen_width()) / 2.0 + 100.0,
    Float::from_int(@raylib.get_screen_height()) / 2.0,
  )
  let sclera_radius : Float = 80.0
  let iris_radius : Float = 24.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let mouse = @raylib.get_mouse_position()

    // Left eye
    let mut iris_left_x = mouse.x
    let mut iris_left_y = mouse.y
    let iris_left = @raylib.Vector2::new(iris_left_x, iris_left_y)

    // Check not inside the left eye sclera
    if not(
        @raylib.check_collision_point_circle(
          iris_left,
          sclera_left_position,
          sclera_radius - iris_radius,
        ),
      ) {
      let dx = iris_left_x - sclera_left_position.x
      let dy = iris_left_y - sclera_left_position.y
      let angle = @math.atan2f(dy, dx)
      let dxx = (sclera_radius - iris_radius) * @math.cosf(angle)
      let dyy = (sclera_radius - iris_radius) * @math.sinf(angle)
      iris_left_x = sclera_left_position.x + dxx
      iris_left_y = sclera_left_position.y + dyy
    }

    // Right eye
    let mut iris_right_x = mouse.x
    let mut iris_right_y = mouse.y
    let iris_right = @raylib.Vector2::new(iris_right_x, iris_right_y)

    // Check not inside the right eye sclera
    if not(
        @raylib.check_collision_point_circle(
          iris_right,
          sclera_right_position,
          sclera_radius - iris_radius,
        ),
      ) {
      let dx = iris_right_x - sclera_right_position.x
      let dy = iris_right_y - sclera_right_position.y
      let angle = @math.atan2f(dy, dx)
      let dxx = (sclera_radius - iris_radius) * @math.cosf(angle)
      let dyy = (sclera_radius - iris_radius) * @math.sinf(angle)
      iris_right_x = sclera_right_position.x + dxx
      iris_right_y = sclera_right_position.y + dyy
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_circle_v(
      sclera_left_position, sclera_radius, @raylib.lightgray,
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(iris_left_x, iris_left_y),
      iris_radius,
      @raylib.brown,
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(iris_left_x, iris_left_y),
      10.0,
      @raylib.black,
    )

    @raylib.draw_circle_v(
      sclera_right_position, sclera_radius, @raylib.lightgray,
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(iris_right_x, iris_right_y),
      iris_radius,
      @raylib.darkgreen,
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(iris_right_x, iris_right_y),
      10.0,
      @raylib.black,
    )

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
