///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - collision area",
  )

  // Box A: Moving box
  let mut box_a = @raylib.Rectangle::new(
    10.0,
    Float::from_int(@raylib.get_screen_height()) / 2.0 - 50.0,
    200.0,
    100.0,
  )
  let mut box_a_speed_x : Float = 4.0

  // Box B: Mouse moved box
  let mut box_b = @raylib.Rectangle::new(
    Float::from_int(@raylib.get_screen_width()) / 2.0 - 30.0,
    Float::from_int(@raylib.get_screen_height()) / 2.0 - 30.0,
    60.0,
    60.0,
  )

  // Collision rectangle
  let mut box_collision = @raylib.Rectangle::new(0.0, 0.0, 0.0, 0.0)

  let screen_upper_limit = 40 // Top menu limits

  let mut pause = false // Movement pause
  let mut collision = false // Collision detection

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update

    // Move box if not paused
    if not(pause) {
      box_a = @raylib.Rectangle::new(
        box_a.x + box_a_speed_x,
        box_a.y,
        box_a.width,
        box_a.height,
      )
    }

    // Bounce box on x screen limits
    if box_a.x + box_a.width >= Float::from_int(@raylib.get_screen_width()) ||
      box_a.x <= 0.0 {
      box_a_speed_x = box_a_speed_x * -1.0
    }

    // Update player-controlled-box (box02)
    let mouse_x = Float::from_int(@raylib.get_mouse_x())
    let mouse_y = Float::from_int(@raylib.get_mouse_y())
    let mut box_b_x = mouse_x - box_b.width / 2.0
    let mut box_b_y = mouse_y - box_b.height / 2.0

    // Make sure Box B does not go out of move area limits
    if box_b_x + box_b.width >= Float::from_int(@raylib.get_screen_width()) {
      box_b_x = Float::from_int(@raylib.get_screen_width()) - box_b.width
    } else if box_b_x <= 0.0 {
      box_b_x = 0.0
    }

    if box_b_y + box_b.height >= Float::from_int(@raylib.get_screen_height()) {
      box_b_y = Float::from_int(@raylib.get_screen_height()) - box_b.height
    } else if box_b_y <= Float::from_int(screen_upper_limit) {
      box_b_y = Float::from_int(screen_upper_limit)
    }

    box_b = @raylib.Rectangle::new(box_b_x, box_b_y, box_b.width, box_b.height)

    // Check boxes collision
    collision = @raylib.check_collision_recs(box_a, box_b)

    // Get collision rectangle (only on collision)
    if collision {
      box_collision = @raylib.get_collision_rec(box_a, box_b)
    }

    // Pause Box A movement
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      pause = not(pause)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_rectangle(
      0,
      0,
      screen_width,
      screen_upper_limit,
      if collision {
        @raylib.red
      } else {
        @raylib.black
      },
    )

    @raylib.draw_rectangle_rec(box_a, @raylib.gold)
    @raylib.draw_rectangle_rec(box_b, @raylib.blue)

    if collision {
      // Draw collision area
      @raylib.draw_rectangle_rec(box_collision, @raylib.lime)

      // Draw collision message
      @raylib.draw_text(
        "COLLISION!",
        @raylib.get_screen_width() / 2 -
        @raylib.measure_text("COLLISION!", 20) / 2,
        screen_upper_limit / 2 - 10,
        20,
        @raylib.black,
      )

      // Draw collision area
      let collision_area = box_collision.width.to_int() *
        box_collision.height.to_int()
      @raylib.draw_text(
        "Collision Area: \{collision_area}",
        @raylib.get_screen_width() / 2 - 100,
        screen_upper_limit + 10,
        20,
        @raylib.black,
      )
    }

    // Draw help instructions
    @raylib.draw_text(
      "Press SPACE to PAUSE/RESUME",
      20,
      screen_height - 35,
      20,
      @raylib.lightgray,
    )

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
