///|
let deg2rad : Float = Float::from_double(@math.PI) / 180.0

///|
let wave_points : Int = 36

///|
fn clamp(value : Float, min : Float, max : Float) -> Float {
  if value < min {
    min
  } else if value > max {
    max
  } else {
    value
  }
}

///|
fn wrap(value : Float, min : Float, max : Float) -> Float {
  let range = max - min
  if range == 0.0 {
    return min
  }
  let mut result = value
  while result >= max {
    result = result - range
  }
  while result < min {
    result = result + range
  }
  result
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint)
  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - math sine cosine",
  )

  let sine_points : Array[@raylib.Vector2] = Array::make(
    wave_points,
    @raylib.Vector2::new(0.0, 0.0),
  )
  let cos_points : Array[@raylib.Vector2] = Array::make(
    wave_points,
    @raylib.Vector2::new(0.0, 0.0),
  )
  let center = @raylib.Vector2::new(
    Float::from_int(screen_width) / 2.0 - 30.0,
    Float::from_int(screen_height) / 2.0,
  )
  let start = @raylib.Rectangle::new(
    20.0,
    Float::from_int(screen_height) - 120.0,
    200.0,
    100.0,
  )
  let radius : Float = 130.0
  let mut angle : Float = 0.0
  let pause : Ref[Bool] = { val: false }

  // Initialize wave points
  for i = 0; i < wave_points; i = i + 1 {
    let t : Float = Float::from_int(i) / Float::from_int(wave_points - 1)
    let current_angle : Float = t * 360.0 * deg2rad
    sine_points[i] = @raylib.Vector2::new(
      start.x + t * start.width,
      start.y +
      start.height / 2.0 -
      @math.sinf(current_angle) * (start.height / 2.0),
    )
    cos_points[i] = @raylib.Vector2::new(
      start.x + t * start.width,
      start.y +
      start.height / 2.0 -
      @math.cosf(current_angle) * (start.height / 2.0),
    )
  }

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    let angle_rad : Float = angle * deg2rad
    let cos_rad : Float = @math.cosf(angle_rad)
    let sin_rad : Float = @math.sinf(angle_rad)

    let point = @raylib.Vector2::new(
      center.x + cos_rad * radius,
      center.y - sin_rad * radius,
    )
    let limit_min = @raylib.Vector2::new(center.x - radius, center.y - radius)
    let limit_max = @raylib.Vector2::new(center.x + radius, center.y + radius)

    let complementary : Float = 90.0 - angle
    let supplementary : Float = 180.0 - angle
    let explementary : Float = 360.0 - angle

    let tangent : Float = clamp(@math.tanf(angle_rad), -10.0, 10.0)
    let cotangent : Float = if tangent.abs() > 0.001 {
      clamp(1.0 / tangent, -radius, radius)
    } else {
      0.0
    }
    let tangent_point = @raylib.Vector2::new(
      center.x + radius,
      center.y - tangent * radius,
    )
    let cotangent_point = @raylib.Vector2::new(
      center.x + cotangent * radius,
      center.y - radius,
    )

    angle = wrap(angle + (if not(pause.val) { 1.0 } else { 0.0 }), 0.0, 360.0)

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Cotangent (orange)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(center.x, limit_min.y),
      @raylib.Vector2::new(cotangent_point.x, limit_min.y),
      2.0,
      @raylib.orange,
    )
    // DrawLineDashed replaced with draw_line_ex (solid line)
    @raylib.draw_line_ex(center, cotangent_point, 1.0, @raylib.orange)

    // Side background
    @raylib.draw_line(
      580,
      0,
      580,
      @raylib.get_screen_height(),
      @raylib.Color::new(218, 218, 218, 255),
    )
    @raylib.draw_rectangle(
      580,
      0,
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
      @raylib.Color::new(232, 232, 232, 255),
    )

    // Base circle and axes
    @raylib.draw_circle_lines_v(center, radius, @raylib.gray)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(center.x, limit_min.y),
      @raylib.Vector2::new(center.x, limit_max.y),
      1.0,
      @raylib.gray,
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(limit_min.x, center.y),
      @raylib.Vector2::new(limit_max.x, center.y),
      1.0,
      @raylib.gray,
    )

    // Wave graph axes
    @raylib.draw_line_ex(
      @raylib.Vector2::new(start.x, start.y),
      @raylib.Vector2::new(start.x, start.y + start.height),
      2.0,
      @raylib.gray,
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(start.x + start.width, start.y),
      @raylib.Vector2::new(start.x + start.width, start.y + start.height),
      2.0,
      @raylib.gray,
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(start.x, start.y + start.height / 2.0),
      @raylib.Vector2::new(start.x + start.width, start.y + start.height / 2.0),
      2.0,
      @raylib.gray,
    )

    // Wave graph axis labels
    @raylib.draw_text(
      "1",
      (start.x - 8.0).to_int(),
      start.y.to_int(),
      6,
      @raylib.gray,
    )
    @raylib.draw_text(
      "0",
      (start.x - 8.0).to_int(),
      (start.y + start.height / 2.0 - 6.0).to_int(),
      6,
      @raylib.gray,
    )
    @raylib.draw_text(
      "-1",
      (start.x - 12.0).to_int(),
      (start.y + start.height - 8.0).to_int(),
      6,
      @raylib.gray,
    )
    @raylib.draw_text(
      "0",
      (start.x - 2.0).to_int(),
      (start.y + start.height + 4.0).to_int(),
      6,
      @raylib.gray,
    )
    @raylib.draw_text(
      "360",
      (start.x + start.width - 8.0).to_int(),
      (start.y + start.height + 4.0).to_int(),
      6,
      @raylib.gray,
    )

    // Sine (red - vertical)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(center.x, center.y),
      @raylib.Vector2::new(center.x, point.y),
      2.0,
      @raylib.red,
    )
    // DrawLineDashed replaced with draw_line_ex (solid line)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(point.x, center.y),
      @raylib.Vector2::new(point.x, point.y),
      1.0,
      @raylib.red,
    )
    @raylib.draw_text("Sine " + sin_rad.to_string(), 640, 190, 6, @raylib.red)
    @raylib.draw_circle_v(
      @raylib.Vector2::new(
        start.x + angle / 360.0 * start.width,
        start.y + (-sin_rad + 1.0) * start.height / 2.0,
      ),
      4.0,
      @raylib.red,
    )
    @raylib.draw_spline_linear(sine_points, 1.0, @raylib.red)

    // Cosine (blue - horizontal)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(center.x, center.y),
      @raylib.Vector2::new(point.x, center.y),
      2.0,
      @raylib.blue,
    )
    // DrawLineDashed replaced with draw_line_ex (solid line)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(center.x, point.y),
      @raylib.Vector2::new(point.x, point.y),
      1.0,
      @raylib.blue,
    )
    @raylib.draw_text(
      "Cosine " + cos_rad.to_string(),
      640,
      210,
      6,
      @raylib.blue,
    )
    @raylib.draw_circle_v(
      @raylib.Vector2::new(
        start.x + angle / 360.0 * start.width,
        start.y + (-cos_rad + 1.0) * start.height / 2.0,
      ),
      4.0,
      @raylib.blue,
    )
    @raylib.draw_spline_linear(cos_points, 1.0, @raylib.blue)

    // Tangent (purple)
    @raylib.draw_line_ex(
      @raylib.Vector2::new(limit_max.x, center.y),
      @raylib.Vector2::new(limit_max.x, tangent_point.y),
      2.0,
      @raylib.purple,
    )
    // DrawLineDashed replaced with draw_line_ex (solid line)
    @raylib.draw_line_ex(center, tangent_point, 1.0, @raylib.purple)
    @raylib.draw_text(
      "Tangent " + tangent.to_string(),
      640,
      230,
      6,
      @raylib.purple,
    )

    // Cotangent (orange)
    @raylib.draw_text(
      "Cotangent " + cotangent.to_string(),
      640,
      250,
      6,
      @raylib.orange,
    )

    // Complementary angle (beige)
    @raylib.draw_circle_sector_lines(
      center,
      radius * 0.6,
      -angle,
      -90.0,
      36,
      @raylib.beige,
    )
    @raylib.draw_text(
      "Complementary  " + complementary.to_int().to_string() + "\u00B0",
      640,
      150,
      6,
      @raylib.beige,
    )

    // Supplementary angle (darkblue)
    @raylib.draw_circle_sector_lines(
      center,
      radius * 0.5,
      -angle,
      -180.0,
      36,
      @raylib.darkblue,
    )
    @raylib.draw_text(
      "Supplementary  " + supplementary.to_int().to_string() + "\u00B0",
      640,
      130,
      6,
      @raylib.darkblue,
    )

    // Explementary angle (pink)
    @raylib.draw_circle_sector_lines(
      center,
      radius * 0.4,
      -angle,
      -360.0,
      36,
      @raylib.pink,
    )
    @raylib.draw_text(
      "Explementary  " + explementary.to_int().to_string() + "\u00B0",
      640,
      170,
      6,
      @raylib.pink,
    )

    // Current angle - arc (lime), radius (black), endpoint (black)
    @raylib.draw_circle_sector_lines(
      center,
      radius * 0.7,
      -angle,
      0.0,
      36,
      @raylib.lime,
    )
    @raylib.draw_line_ex(
      @raylib.Vector2::new(center.x, center.y),
      point,
      2.0,
      @raylib.black,
    )
    @raylib.draw_circle_v(point, 4.0, @raylib.black)

    // Draw GUI controls
    @raygui.gui_set_style(
      @raygui.ControlLabel,
      @raygui.TextColorNormal,
      @raylib.color_to_int(@raylib.gray),
    )
    @raygui.gui_toggle(
      @raylib.Rectangle::new(640.0, 70.0, 120.0, 20.0),
      "Pause",
      pause,
    )
    |> ignore
    let angle_ref : Ref[Float] = { val: angle }
    @raygui.gui_set_style(
      @raygui.ControlLabel,
      @raygui.TextColorNormal,
      @raylib.color_to_int(@raylib.lime),
    )
    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(640.0, 40.0, 120.0, 20.0),
      "Angle",
      angle_ref.val.to_int().to_string() + "\u00B0",
      angle_ref,
      0.0,
      360.0,
    )
    |> ignore
    angle = angle_ref.val

    // Angle values panel
    @raygui.gui_group_box(
      @raylib.Rectangle::new(620.0, 110.0, 140.0, 170.0),
      "Angle Values",
    )

    @raylib.draw_fps(10, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
