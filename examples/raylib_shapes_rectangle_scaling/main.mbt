///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let mouse_scale_mark_size : Float = 12.0

  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - rectangle scaling mouse",
  )

  let rec_x : Float = 100.0
  let rec_y : Float = 100.0
  let mut rec_width : Float = 200.0
  let mut rec_height : Float = 80.0

  let mut mouse_scale_ready = false
  let mut mouse_scale_mode = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let mouse_position = @raylib.get_mouse_position()

    let scale_rec = @raylib.Rectangle::new(
      rec_x + rec_width - mouse_scale_mark_size,
      rec_y + rec_height - mouse_scale_mark_size,
      mouse_scale_mark_size,
      mouse_scale_mark_size,
    )

    if @raylib.check_collision_point_rec(mouse_position, scale_rec) {
      mouse_scale_ready = true
      if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) {
        mouse_scale_mode = true
      }
    } else {
      mouse_scale_ready = false
    }

    if mouse_scale_mode {
      mouse_scale_ready = true

      rec_width = mouse_position.x - rec_x
      rec_height = mouse_position.y - rec_y

      // Check minimum rec size
      if rec_width < mouse_scale_mark_size {
        rec_width = mouse_scale_mark_size
      }
      if rec_height < mouse_scale_mark_size {
        rec_height = mouse_scale_mark_size
      }

      // Check maximum rec size
      let max_w = Float::from_int(@raylib.get_screen_width()) - rec_x
      let max_h = Float::from_int(@raylib.get_screen_height()) - rec_y
      if rec_width > max_w {
        rec_width = max_w
      }
      if rec_height > max_h {
        rec_height = max_h
      }

      if @raylib.is_mouse_button_released(@raylib.MouseButtonLeft) {
        mouse_scale_mode = false
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_text(
      "Scale rectangle dragging from bottom-right corner!", 10, 10, 20, @raylib.gray,
    )

    let rec = @raylib.Rectangle::new(rec_x, rec_y, rec_width, rec_height)
    @raylib.draw_rectangle_rec(rec, @raylib.fade(@raylib.green, 0.5))

    if mouse_scale_ready {
      @raylib.draw_rectangle_lines_ex(rec, 1.0, @raylib.red)
      @raylib.draw_triangle(
        @raylib.Vector2::new(
          rec_x + rec_width - mouse_scale_mark_size,
          rec_y + rec_height,
        ),
        @raylib.Vector2::new(rec_x + rec_width, rec_y + rec_height),
        @raylib.Vector2::new(
          rec_x + rec_width,
          rec_y + rec_height - mouse_scale_mark_size,
        ),
        @raylib.red,
      )
    }

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
