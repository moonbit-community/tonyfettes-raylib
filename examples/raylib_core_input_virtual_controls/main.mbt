///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [core] example - input virtual controls",
  )

  let dpad_x : Float = 90.0
  let dpad_y : Float = 300.0
  let dpad_rad : Float = 25.0 // radius of each pad
  let dpad_color = @raylib.blue

  // Collider positions: up, left, right, down
  let dpad_collider_x : Array[Float] = [
    dpad_x,
    dpad_x - dpad_rad * 1.5,
    dpad_x + dpad_rad * 1.5,
    dpad_x,
  ]
  let dpad_collider_y : Array[Float] = [
    dpad_y - dpad_rad * 1.5,
    dpad_y,
    dpad_y,
    dpad_y + dpad_rad * 1.5,
  ]
  let dpad_labels : Array[String] = ["X", "Y", "B", "A"]

  let mut player_x : Float = 100.0
  let mut player_y : Float = 100.0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let mut dpad_keydown = -1 // reset

    let input_x : Float = if @raylib.get_touch_point_count() > 0 {
      Float::from_int(@raylib.get_touch_x())
    } else {
      Float::from_int(@raylib.get_mouse_x())
    }
    let input_y : Float = if @raylib.get_touch_point_count() > 0 {
      Float::from_int(@raylib.get_touch_y())
    } else {
      Float::from_int(@raylib.get_mouse_y())
    }

    for i = 0; i < 4; i = i + 1 {
      // Test distance: Manhattan distance < radius
      let dx = dpad_collider_x[i] - input_x
      let dy = dpad_collider_y[i] - input_y
      let abs_dx = if dx < 0.0 { -dx } else { dx }
      let abs_dy = if dy < 0.0 { -dy } else { dy }
      if abs_dx + abs_dy < dpad_rad {
        dpad_keydown = i
        break
      }
    }

    // Move player
    let dt = @raylib.get_frame_time()
    match dpad_keydown {
      0 => player_y -= 50.0 * dt // up
      1 => player_x -= 50.0 * dt // left
      2 => player_x += 50.0 * dt // right
      3 => player_y += 50.0 * dt // down
      _ => ()
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    for i = 0; i < 4; i = i + 1 {
      // Draw all pads
      @raylib.draw_circle_v(
        @raylib.Vector2::new(dpad_collider_x[i], dpad_collider_y[i]),
        dpad_rad,
        dpad_color,
      )
      if i != dpad_keydown {
        // Draw label
        @raylib.draw_text(
          dpad_labels[i],
          dpad_collider_x[i].to_int() - 7,
          dpad_collider_y[i].to_int() - 8,
          20,
          @raylib.black,
        )
      }
    }

    @raylib.draw_rectangle_rec(
      @raylib.Rectangle::new(player_x - 4.0, player_y - 4.0, 75.0, 28.0),
      @raylib.red,
    )
    @raylib.draw_text(
      "Player",
      player_x.to_int(),
      player_y.to_int(),
      20,
      @raylib.white,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
