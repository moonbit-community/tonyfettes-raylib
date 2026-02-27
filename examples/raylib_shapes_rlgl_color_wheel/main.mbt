///|
fn clamp(val : Float, min : Float, max : Float) -> Float {
  if val < min {
    min
  } else if val > max {
    max
  } else {
    val
  }
}

///|
fn hex2(value : Int) -> String {
  let digits = "0123456789ABCDEF"
  let hi = (value >> 4) & 0xF
  let lo = value & 0xF
  digits[hi].to_string() + digits[lo].to_string()
}

///|
/// Equivalent to raylib's Vector2Angle(a, b) = atan2f(b.y - a.y, b.x - a.x)
fn vector2_angle(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  @math.atan2f(by - ay, bx - ax)
}

///|
/// Equivalent to raylib's Vector2Distance(a, b)
fn vector2_distance(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  @math.hypotf(bx - ax, by - ay)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let pi : Float = Float::from_double(@math.PI)

  // The minimum/maximum points the circle can have
  let points_min : Float = 3.0
  let points_max : Float = 256.0

  // The current number of points and the radius of the circle
  let mut triangle_count : Float = 64.0
  let mut point_scale : Float = 150.0

  // Slider value, literally maps to value in HSV
  let value : Ref[Float] = { val: 1.0 }

  // The center of the screen
  let center_x : Float = Float::from_int(screen_width) / 2.0
  let center_y : Float = Float::from_int(screen_height) / 2.0

  // The location of the color wheel
  let mut circle_pos_x : Float = center_x
  let mut circle_pos_y : Float = center_y

  // The currently selected color
  let mut color = @raylib.Color::new(255, 255, 255, 255)

  // Indicates if the slider is being clicked
  let mut slider_clicked = false

  // Indicates if the current color is going to be updated
  let mut setting_color = false

  // How the color wheel will be rendered
  let mut render_type = @rl.Triangles

  // Enable anti-aliasing
  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - rlgl color wheel",
  )
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    triangle_count = triangle_count + @raylib.get_mouse_wheel_move()
    triangle_count = clamp(triangle_count, points_min, points_max)

    let slider_rect_x : Float = 42.0
    let slider_rect_y : Float = 16.0 + 64.0 + 45.0
    let slider_rect_w : Float = 64.0
    let slider_rect_h : Float = 16.0

    let mouse_position = @raylib.get_mouse_position()

    // Checks if the user is hovering over the value slider
    let slider_hover = mouse_position.x >= slider_rect_x &&
      mouse_position.y >= slider_rect_y &&
      mouse_position.x < slider_rect_x + slider_rect_w &&
      mouse_position.y < slider_rect_y + slider_rect_h

    // Copy color as hex
    if @raylib.is_key_down(341) && @raylib.is_key_down(67) {
      if @raylib.is_key_pressed(67) {
        @raylib.set_clipboard_text(
          "#" +
          hex2(color.r.to_int()) +
          hex2(color.g.to_int()) +
          hex2(color.b.to_int()),
        )
      }
    }

    // Scale up the color wheel, adjusting the handle visually
    if @raylib.is_key_down(265) {
      point_scale = point_scale * 1.025
      if point_scale > Float::from_int(screen_height) / 2.0 {
        point_scale = Float::from_int(screen_height) / 2.0
      } else {
        let dx = (circle_pos_x - center_x) * 1.025
        let dy = (circle_pos_y - center_y) * 1.025
        circle_pos_x = dx + center_x
        circle_pos_y = dy + center_y
      }
    }

    // Scale down the wheel, adjusting the handle visually
    if @raylib.is_key_down(264) {
      point_scale = point_scale * 0.975
      if point_scale < 32.0 {
        point_scale = 32.0
      } else {
        let dx = (circle_pos_x - center_x) * 0.975
        let dy = (circle_pos_y - center_y) * 0.975
        circle_pos_x = dx + center_x
        circle_pos_y = dy + center_y
      }
      let distance = vector2_distance(
          center_x, center_y, circle_pos_x, circle_pos_y,
        ) /
        point_scale
      // Vector2Angle((0, -pointScale), Vector2Subtract(center, circlePos))
      // = atan2f((center_y - circle_pos_y) - (-point_scale), (center_x - circle_pos_x) - 0)
      let angle = (
          vector2_angle(
            0.0,
            -point_scale,
            center_x - circle_pos_x,
            center_y - circle_pos_y,
          ) /
          pi +
          1.0
        ) /
        2.0
      if distance > 1.0 {
        circle_pos_x = @math.sinf(angle * (pi * 2.0)) * point_scale + center_x
        circle_pos_y = -@math.cosf(angle * (pi * 2.0)) * point_scale + center_y
      }
    }

    // Checks if the user clicked on the color wheel
    let mouse_pos = @raylib.get_mouse_position()
    if @raylib.is_mouse_button_pressed(0) &&
      vector2_distance(mouse_pos.x, mouse_pos.y, center_x, center_y) <=
      point_scale + 10.0 {
      setting_color = true
    }

    // Update flag when mouse button is released
    if @raylib.is_mouse_button_released(0) {
      setting_color = false
    }

    // Check if the user clicked/released the slider for the color's value
    if slider_hover && @raylib.is_mouse_button_pressed(0) {
      slider_clicked = true
    }
    if slider_clicked && @raylib.is_mouse_button_released(0) {
      slider_clicked = false
    }

    // Update render mode accordingly
    if @raylib.is_key_pressed(32) {
      render_type = @rl.Lines
    }
    if @raylib.is_key_released(32) {
      render_type = @rl.Triangles
    }

    // If the slider or the wheel was clicked, update the current color
    if setting_color || slider_clicked {
      if setting_color {
        let mp = @raylib.get_mouse_position()
        circle_pos_x = mp.x
        circle_pos_y = mp.y
      }
      let distance = vector2_distance(
          center_x, center_y, circle_pos_x, circle_pos_y,
        ) /
        point_scale

      // Vector2Angle((0, -pointScale), Vector2Subtract(center, circlePos))
      let angle = (
          vector2_angle(
            0.0,
            -point_scale,
            center_x - circle_pos_x,
            center_y - circle_pos_y,
          ) /
          pi +
          1.0
        ) /
        2.0

      if setting_color && distance > 1.0 {
        circle_pos_x = @math.sinf(angle * (pi * 2.0)) * point_scale + center_x
        circle_pos_y = -@math.cosf(angle * (pi * 2.0)) * point_scale + center_y
      }

      let angle360 = angle * 360.0
      let value_actual = clamp(distance, 0.0, 1.0)
      let v = value.val
      let val_byte = (v * 255.0).to_int()
      let white_ish = @raylib.Color::new(val_byte, val_byte, val_byte, 255)
      let hsv_color = @raylib.color_from_hsv(
        angle360,
        clamp(distance, 0.0, 1.0),
        1.0,
      )
      color = @raylib.color_lerp(white_ish, hsv_color, value_actual)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Begin rendering color wheel
    let tri_count = triangle_count.to_int()
    @rl.begin(render_type)
    for i = 0; i < tri_count; i = i + 1 {
      let angle_offset = pi * 2.0 / triangle_count
      let angle = angle_offset * Float::from_int(i)
      let angle_offset_calc = (Float::from_int(i) + 1.0) * angle_offset

      let pos_x = center_x + @math.sinf(angle) * point_scale
      let pos_y = center_y + -@math.cosf(angle) * point_scale
      let pos2_x = center_x + @math.sinf(angle_offset_calc) * point_scale
      let pos2_y = center_y + -@math.cosf(angle_offset_calc) * point_scale

      let angle_deg = angle / (2.0 * pi) * 360.0
      let angle_offset_deg = angle_offset / (2.0 * pi) * 360.0

      let cur_color = @raylib.color_from_hsv(angle_deg, 1.0, 1.0)
      let off_color = @raylib.color_from_hsv(
        angle_deg + angle_offset_deg,
        1.0,
        1.0,
      )

      if render_type == @rl.Triangles {
        @rl.color4ub(cur_color.r, cur_color.g, cur_color.b, cur_color.a)
        @rl.vertex2f(pos_x, pos_y)
        // rl_color4f(value, value, value, 1.0) => rl_color4ub with byte conversion
        let v = value.val
        let vb = (clamp(v, 0.0, 1.0) * 255.0).to_int().to_byte()
        @rl.color4ub(vb, vb, vb, b'\xFF')
        @rl.vertex2f(center_x, center_y)
        @rl.color4ub(off_color.r, off_color.g, off_color.b, off_color.a)
        @rl.vertex2f(pos2_x, pos2_y)
      } else if render_type == @rl.Lines {
        @rl.color4ub(cur_color.r, cur_color.g, cur_color.b, cur_color.a)
        @rl.vertex2f(pos_x, pos_y)
        let w = @raylib.white
        @rl.color4ub(w.r, w.g, w.b, w.a)
        @rl.vertex2f(center_x, center_y)
        @rl.vertex2f(center_x, center_y)
        @rl.color4ub(off_color.r, off_color.g, off_color.b, off_color.a)
        @rl.vertex2f(pos2_x, pos2_y)
        @rl.vertex2f(pos2_x, pos2_y)
        @rl.color4ub(cur_color.r, cur_color.g, cur_color.b, cur_color.a)
        @rl.vertex2f(pos_x, pos_y)
      }
    }
    @rl.end_()

    // Make the handle slightly more visible overtop darker colors
    let circle_pos = @raylib.Vector2::new(circle_pos_x, circle_pos_y)
    let mut handle_color = @raylib.black
    if vector2_distance(center_x, center_y, circle_pos_x, circle_pos_y) /
      point_scale <=
      0.5 &&
      value.val <= 0.5 {
      handle_color = @raylib.darkgray
    }

    // Draw the color handle
    @raylib.draw_circle_lines_v(circle_pos, 4.0, handle_color)

    // Draw the color in a preview, with a darkened outline
    @raylib.draw_rectangle_v(
      @raylib.Vector2::new(8.0, 8.0),
      @raylib.Vector2::new(64.0, 64.0),
      color,
    )
    @raylib.draw_rectangle_lines_ex(
      @raylib.Rectangle::new(8.0, 8.0, 64.0, 64.0),
      2.0,
      @raylib.color_lerp(color, @raylib.black, 0.5),
    )

    // Draw current color as hex and decimal
    let hex_str = "#" +
      hex2(color.r.to_int()) +
      hex2(color.g.to_int()) +
      hex2(color.b.to_int())
    let dec_str = "(" +
      color.r.to_int().to_string() +
      ", " +
      color.g.to_int().to_string() +
      ", " +
      color.b.to_int().to_string() +
      ")"
    @raylib.draw_text(hex_str, 8, 8 + 64 + 8, 20, @raylib.darkgray)
    @raylib.draw_text(dec_str, 8, 8 + 64 + 8 + 22, 20, @raylib.darkgray)

    // Update the visuals for the copying text
    let mut copy_color = @raylib.darkgray
    let mut offset = 0
    if @raylib.is_key_down(341) && @raylib.is_key_down(67) {
      copy_color = @raylib.darkgreen
      offset = 4
    }

    // Draw the copying text
    @raylib.draw_text("press ctrl+c to copy!", 8, 425 - offset, 20, copy_color)

    // Display the number of rendered triangles
    @raylib.draw_text(
      "triangle count: " + tri_count.to_string(),
      8,
      395,
      20,
      @raylib.darkgray,
    )

    // Slider to change color's value
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(
        slider_rect_x, slider_rect_y, slider_rect_w, slider_rect_h,
      ),
      "value: ",
      "",
      value,
      0.0,
      1.0,
    )
    |> ignore

    // Draw FPS next to outlined color preview
    @raylib.draw_fps(64 + 16, 8)

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
