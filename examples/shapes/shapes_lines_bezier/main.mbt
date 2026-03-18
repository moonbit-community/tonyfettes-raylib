///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - cubic-bezier lines",
  )

  let mut start_x : Float = 30.0
  let mut start_y : Float = 30.0
  let mut end_x : Float = Float::from_int(screen_width) - 30.0
  let mut end_y : Float = Float::from_int(screen_height) - 30.0
  let mut move_start_point = false
  let mut move_end_point = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let mouse = @raylib.get_mouse_position()
    let start_point = @raylib.Vector2::new(start_x, start_y)
    let end_point = @raylib.Vector2::new(end_x, end_y)

    if @raylib.check_collision_point_circle(mouse, start_point, 10.0) &&
      @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
      move_start_point = true
    } else if @raylib.check_collision_point_circle(mouse, end_point, 10.0) &&
      @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
      move_end_point = true
    }

    if move_start_point {
      start_x = mouse.x
      start_y = mouse.y
      if @raylib.is_mouse_button_released(@raylib.MouseButtonLeft) {
        move_start_point = false
      }
    }

    if move_end_point {
      end_x = mouse.x
      end_y = mouse.y
      if @raylib.is_mouse_button_released(@raylib.MouseButtonLeft) {
        move_end_point = false
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_text(
      "MOVE START-END POINTS WITH MOUSE", 15, 20, 20, @raylib.gray,
    )

    // Draw line cubic bezier
    let sp = @raylib.Vector2::new(start_x, start_y)
    let ep = @raylib.Vector2::new(end_x, end_y)
    @raylib.draw_line_bezier(sp, ep, 4.0, @raylib.blue)

    // Draw start-end spline circles with some details
    let start_hover = @raylib.check_collision_point_circle(mouse, sp, 10.0)
    let start_radius : Float = if start_hover { 14.0 } else { 8.0 }
    let start_color = if move_start_point { @raylib.red } else { @raylib.blue }
    @raylib.draw_circle_v(sp, start_radius, start_color)

    let end_hover = @raylib.check_collision_point_circle(mouse, ep, 10.0)
    let end_radius : Float = if end_hover { 14.0 } else { 8.0 }
    let end_color = if move_end_point { @raylib.red } else { @raylib.blue }
    @raylib.draw_circle_v(ep, end_radius, end_color)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
