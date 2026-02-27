///|
let deg2rad : Float = 0.017453292519943295

// Draw rectangle with rounded edges and horizontal gradient, with options to choose side of roundness
// Adapted from both `DrawRectangleRounded` and `DrawRectangleGradientH`

///|
fn draw_rectangle_rounded_gradient_h(
  rec : @raylib.Rectangle,
  roundness_left : Float,
  roundness_right : Float,
  segments : Int,
  left : @raylib.Color,
  right : @raylib.Color,
) -> Unit {
  // Neither side is rounded
  if (roundness_left <= (0.0 : Float) && roundness_right <= (0.0 : Float)) ||
    rec.width < (1.0 : Float) ||
    rec.height < (1.0 : Float) {
    @raylib.draw_rectangle_gradient_ex(rec, left, left, right, right)
    return
  }
  let roundness_left : Float = if roundness_left >= (1.0 : Float) {
    1.0
  } else {
    roundness_left
  }
  let roundness_right : Float = if roundness_right >= (1.0 : Float) {
    1.0
  } else {
    roundness_right
  }

  // Calculate corner radius both from right and left
  let rec_size : Float = if rec.width > rec.height {
    rec.height
  } else {
    rec.width
  }
  let radius_left : Float = rec_size * roundness_left / (2.0 : Float)
  let radius_right : Float = rec_size * roundness_right / (2.0 : Float)
  let radius_left : Float = if radius_left <= (0.0 : Float) {
    0.0
  } else {
    radius_left
  }
  let radius_right : Float = if radius_right <= (0.0 : Float) {
    0.0
  } else {
    radius_right
  }
  if radius_right <= (0.0 : Float) && radius_left <= (0.0 : Float) {
    return
  }
  let step_length : Float = (90.0 : Float) / Float::from_int(segments)

  // Coordinates of the 12 points
  // P0, P1, P2
  let point0_x : Float = rec.x + radius_left
  let point0_y : Float = rec.y
  let point1_x : Float = rec.x + rec.width - radius_right
  let point1_y : Float = rec.y
  let point2_x : Float = rec.x + rec.width
  let point2_y : Float = rec.y + radius_right
  // P3, P4
  let point3_x : Float = rec.x + rec.width
  let point3_y : Float = rec.y + rec.height - radius_right
  let point4_x : Float = rec.x + rec.width - radius_right
  let point4_y : Float = rec.y + rec.height
  // P5, P6, P7
  let point5_x : Float = rec.x + radius_left
  let point5_y : Float = rec.y + rec.height
  let point6_x : Float = rec.x
  let point6_y : Float = rec.y + rec.height - radius_left
  let point7_x : Float = rec.x
  let point7_y : Float = rec.y + radius_left
  // P8, P9
  let point8_x : Float = rec.x + radius_left
  let point8_y : Float = rec.y + radius_left
  let point9_x : Float = rec.x + rec.width - radius_right
  let point9_y : Float = rec.y + radius_right
  // P10, P11
  let point10_x : Float = rec.x + rec.width - radius_right
  let point10_y : Float = rec.y + rec.height - radius_right
  let point11_x : Float = rec.x + radius_left
  let point11_y : Float = rec.y + rec.height - radius_left

  let centers_x = [point8_x, point9_x, point10_x, point11_x]
  let centers_y = [point8_y, point9_y, point10_y, point11_y]
  let angles : FixedArray[Float] = [180.0, 270.0, 0.0, 90.0]

  @rl.begin(@rl.Triangles)

  // Draw all of the 4 corners: [1] Upper Left Corner, [3] Upper Right Corner, [5] Lower Right Corner, [7] Lower Left Corner
  for k = 0; k < 4; k = k + 1 {
    let color : @raylib.Color = if k == 0 || k == 3 { left } else { right }
    let radius : Float = if k == 0 || k == 3 {
      radius_left
    } else {
      radius_right
    }
    let center_x = centers_x[k]
    let center_y = centers_y[k]
    let mut angle : Float = angles[k]
    for i = 0; i < segments; i = i + 1 {
      @rl.color4ub(color.r, color.g, color.b, color.a)
      @rl.vertex2f(center_x, center_y)
      @rl.vertex2f(
        center_x + @math.cosf(deg2rad * (angle + step_length)) * radius,
        center_y + @math.sinf(deg2rad * (angle + step_length)) * radius,
      )
      @rl.vertex2f(
        center_x + @math.cosf(deg2rad * angle) * radius,
        center_y + @math.sinf(deg2rad * angle) * radius,
      )
      angle = angle + step_length
    }
  }

  // [2] Upper Rectangle
  @rl.color4ub(left.r, left.g, left.b, left.a)
  @rl.vertex2f(point0_x, point0_y)
  @rl.vertex2f(point8_x, point8_y)
  @rl.color4ub(right.r, right.g, right.b, right.a)
  @rl.vertex2f(point9_x, point9_y)
  @rl.vertex2f(point1_x, point1_y)
  @rl.color4ub(left.r, left.g, left.b, left.a)
  @rl.vertex2f(point0_x, point0_y)
  @rl.color4ub(right.r, right.g, right.b, right.a)
  @rl.vertex2f(point9_x, point9_y)

  // [4] Right Rectangle
  @rl.color4ub(right.r, right.g, right.b, right.a)
  @rl.vertex2f(point9_x, point9_y)
  @rl.vertex2f(point10_x, point10_y)
  @rl.vertex2f(point3_x, point3_y)
  @rl.vertex2f(point2_x, point2_y)
  @rl.vertex2f(point9_x, point9_y)
  @rl.vertex2f(point3_x, point3_y)

  // [6] Bottom Rectangle
  @rl.color4ub(left.r, left.g, left.b, left.a)
  @rl.vertex2f(point11_x, point11_y)
  @rl.vertex2f(point5_x, point5_y)
  @rl.color4ub(right.r, right.g, right.b, right.a)
  @rl.vertex2f(point4_x, point4_y)
  @rl.vertex2f(point10_x, point10_y)
  @rl.color4ub(left.r, left.g, left.b, left.a)
  @rl.vertex2f(point11_x, point11_y)
  @rl.color4ub(right.r, right.g, right.b, right.a)
  @rl.vertex2f(point4_x, point4_y)

  // [8] Left Rectangle
  @rl.color4ub(left.r, left.g, left.b, left.a)
  @rl.vertex2f(point7_x, point7_y)
  @rl.vertex2f(point6_x, point6_y)
  @rl.vertex2f(point11_x, point11_y)
  @rl.vertex2f(point8_x, point8_y)
  @rl.vertex2f(point7_x, point7_y)
  @rl.vertex2f(point11_x, point11_y)

  // [9] Middle Rectangle
  @rl.color4ub(left.r, left.g, left.b, left.a)
  @rl.vertex2f(point8_x, point8_y)
  @rl.vertex2f(point11_x, point11_y)
  @rl.color4ub(right.r, right.g, right.b, right.a)
  @rl.vertex2f(point10_x, point10_y)
  @rl.vertex2f(point9_x, point9_y)
  @rl.color4ub(left.r, left.g, left.b, left.a)
  @rl.vertex2f(point8_x, point8_y)
  @rl.color4ub(right.r, right.g, right.b, right.a)
  @rl.vertex2f(point10_x, point10_y)

  @rl.end_()
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [shapes] example - rectangle advanced",
  )
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update rectangle bounds
    let width : Float = Float::from_int(@raylib.get_screen_width()) /
      (2.0 : Float)
    let height : Float = Float::from_int(@raylib.get_screen_height()) /
      (6.0 : Float)
    let mut rec_y : Float = Float::from_int(@raylib.get_screen_height()) /
      (2.0 : Float) -
      (5.0 : Float) * (height / (2.0 : Float))
    let rec_x : Float = Float::from_int(@raylib.get_screen_width()) /
      (2.0 : Float) -
      width / (2.0 : Float)

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    // Draw all rectangles with different roundness for each side and different gradients
    draw_rectangle_rounded_gradient_h(
      @raylib.Rectangle::new(rec_x, rec_y, width, height),
      0.8,
      0.8,
      36,
      @raylib.blue,
      @raylib.red,
    )

    rec_y = rec_y + height + (1.0 : Float)
    draw_rectangle_rounded_gradient_h(
      @raylib.Rectangle::new(rec_x, rec_y, width, height),
      0.5,
      1.0,
      36,
      @raylib.red,
      @raylib.pink,
    )

    rec_y = rec_y + height + (1.0 : Float)
    draw_rectangle_rounded_gradient_h(
      @raylib.Rectangle::new(rec_x, rec_y, width, height),
      1.0,
      0.5,
      36,
      @raylib.red,
      @raylib.blue,
    )

    rec_y = rec_y + height + (1.0 : Float)
    draw_rectangle_rounded_gradient_h(
      @raylib.Rectangle::new(rec_x, rec_y, width, height),
      0.0,
      1.0,
      36,
      @raylib.blue,
      @raylib.black,
    )

    rec_y = rec_y + height + (1.0 : Float)
    draw_rectangle_rounded_gradient_h(
      @raylib.Rectangle::new(rec_x, rec_y, width, height),
      1.0,
      0.0,
      36,
      @raylib.blue,
      @raylib.pink,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.close_window()
}
