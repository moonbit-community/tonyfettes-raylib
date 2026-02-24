///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - splines drawing",
  )

  // Spline points
  let points : Array[@raylib.Vector2] = [
    @raylib.Vector2::new(50.0, 400.0),
    @raylib.Vector2::new(160.0, 220.0),
    @raylib.Vector2::new(340.0, 380.0),
    @raylib.Vector2::new(520.0, 60.0),
    @raylib.Vector2::new(710.0, 260.0),
  ]
  let mut point_count = 5
  let mut selected_point = -1
  let mut focused_point = -1

  // Cubic Bezier control points
  let control_start : Array[@raylib.Vector2] = Array::make(
    31,
    @raylib.Vector2::new(0.0, 0.0),
  )
  let control_end : Array[@raylib.Vector2] = Array::make(
    31,
    @raylib.Vector2::new(0.0, 0.0),
  )
  for i = 0; i < point_count - 1; i = i + 1 {
    control_start[i] = @raylib.Vector2::new(points[i].x + 50.0, points[i].y)
    control_end[i] = @raylib.Vector2::new(
      points[i + 1].x - 50.0,
      points[i + 1].y,
    )
  }

  // Spline config
  let spline_thickness : Float = 8.0
  let mut spline_type_active = 0 // 0-Linear, 1-BSpline, 2-CatmullRom, 3-Bezier

  // Control point selection for Bezier mode
  let mut selected_control = -1 // index * 2 + (0=start, 1=end), -1 = none
  let mut focused_control = -1

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let mouse = @raylib.get_mouse_position()

    // Spline points creation logic (right click to add)
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) &&
      point_count < 32 {
      points.push(@raylib.Vector2::new(mouse.x, mouse.y))
      let i = point_count - 1
      control_start[i] = @raylib.Vector2::new(points[i].x + 50.0, points[i].y)
      control_end[i] = @raylib.Vector2::new(
        points[i + 1].x - 50.0,
        points[i + 1].y,
      )
      point_count = point_count + 1
    }

    // Spline point focus and selection logic
    focused_point = -1
    for i = 0; i < point_count; i = i + 1 {
      if @raylib.check_collision_point_circle(mouse, points[i], 8.0) {
        focused_point = i
        if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
          selected_point = i
        }
        break
      }
    }

    // Spline point movement logic
    if selected_point >= 0 {
      points[selected_point] = @raylib.Vector2::new(mouse.x, mouse.y)
      if @raylib.is_mouse_button_released(@raylib.MouseButtonLeft) {
        selected_point = -1
      }
    }

    // Cubic Bezier spline control points logic
    if spline_type_active == 3 && focused_point == -1 {
      focused_control = -1
      for i = 0; i < point_count - 1; i = i + 1 {
        if @raylib.check_collision_point_circle(mouse, control_start[i], 6.0) {
          focused_control = i * 2
          if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
            selected_control = i * 2
          }
          break
        } else if @raylib.check_collision_point_circle(
            mouse,
            control_end[i],
            6.0,
          ) {
          focused_control = i * 2 + 1
          if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
            selected_control = i * 2 + 1
          }
          break
        }
      }

      // Spline control point movement logic
      if selected_control >= 0 {
        let ctrl_idx = selected_control / 2
        let is_start = selected_control % 2 == 0
        if is_start {
          control_start[ctrl_idx] = @raylib.Vector2::new(mouse.x, mouse.y)
        } else {
          control_end[ctrl_idx] = @raylib.Vector2::new(mouse.x, mouse.y)
        }
        if @raylib.is_mouse_button_released(@raylib.MouseButtonLeft) {
          selected_control = -1
        }
      }
    }

    // Spline selection logic
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      spline_type_active = 0
    } else if @raylib.is_key_pressed(@raylib.KeyTwo) {
      spline_type_active = 1
    } else if @raylib.is_key_pressed(@raylib.KeyThree) {
      spline_type_active = 2
    } else if @raylib.is_key_pressed(@raylib.KeyFour) {
      spline_type_active = 3
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Build the points array slice for drawing
    let draw_points : Array[@raylib.Vector2] = []
    for i = 0; i < point_count; i = i + 1 {
      draw_points.push(points[i])
    }

    if spline_type_active == 0 {
      // Draw spline: linear
      @raylib.draw_spline_linear(draw_points, spline_thickness, @raylib.red)
    } else if spline_type_active == 1 {
      // Draw spline: basis
      @raylib.draw_spline_basis(draw_points, spline_thickness, @raylib.red)
    } else if spline_type_active == 2 {
      // Draw spline: catmull-rom
      @raylib.draw_spline_catmull_rom(
        draw_points, spline_thickness, @raylib.red,
      )
    } else if spline_type_active == 3 {
      // Build interleaved points for cubic bezier
      let interleaved : Array[@raylib.Vector2] = []
      for i = 0; i < point_count - 1; i = i + 1 {
        interleaved.push(points[i])
        interleaved.push(control_start[i])
        interleaved.push(control_end[i])
      }
      interleaved.push(points[point_count - 1])

      // Draw spline: cubic-bezier (with control points)
      @raylib.draw_spline_bezier_cubic(
        interleaved, spline_thickness, @raylib.red,
      )

      // Draw spline control points
      for i = 0; i < point_count - 1; i = i + 1 {
        // Every cubic bezier point has two control points
        @raylib.draw_circle_v(control_start[i], 6.0, @raylib.gold)
        @raylib.draw_circle_v(control_end[i], 6.0, @raylib.gold)
        if focused_control == i * 2 {
          @raylib.draw_circle_v(control_start[i], 8.0, @raylib.green)
        } else if focused_control == i * 2 + 1 {
          @raylib.draw_circle_v(control_end[i], 8.0, @raylib.green)
        }
        @raylib.draw_line_ex(
          points[i],
          control_start[i],
          1.0,
          @raylib.lightgray,
        )
        @raylib.draw_line_ex(
          points[i + 1],
          control_end[i],
          1.0,
          @raylib.lightgray,
        )

        // Draw spline control lines
        @raylib.draw_line_v(points[i], control_start[i], @raylib.gray)
        @raylib.draw_line_v(control_end[i], points[i + 1], @raylib.gray)
      }
    }

    // Draw spline point helpers
    for i = 0; i < point_count; i = i + 1 {
      let radius : Float = if focused_point == i { 12.0 } else { 8.0 }
      let color = if focused_point == i {
        @raylib.blue
      } else {
        @raylib.darkblue
      }
      @raylib.draw_circle_lines_v(points[i], radius, color)
      if spline_type_active != 0 &&
        spline_type_active != 3 &&
        i < point_count - 1 {
        @raylib.draw_line_v(points[i], points[i + 1], @raylib.gray)
      }
      @raylib.draw_text(
        "[\{points[i].x.to_int()}, \{points[i].y.to_int()}]",
        points[i].x.to_int(),
        points[i].y.to_int() + 10,
        10,
        @raylib.black,
      )
    }

    // Draw spline type info
    let type_names = ["LINEAR", "BSPLINE", "CATMULLROM", "BEZIER"]
    @raylib.draw_text(
      "Spline type: \{type_names[spline_type_active]}",
      12,
      10,
      20,
      @raylib.darkgray,
    )
    @raylib.draw_text(
      "[1] Linear  [2] BSpline  [3] CatmullRom  [4] Bezier", 12, 36, 10, @raylib.gray,
    )
    @raylib.draw_text(
      "Right-click to add points. Left-click to drag.", 12, 52, 10, @raylib.gray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
