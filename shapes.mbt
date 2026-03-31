// ============================================================================
// Basic shapes drawing (all wrappers — every function takes Color/Vector2/Rectangle)
// ============================================================================

///|
/// Draw a pixel using geometry. Can be slow, use with care.
pub fn draw_pixel(pos_x : Int, pos_y : Int, color : Color) -> Unit {
  @ffi.draw_pixel(pos_x, pos_y, color.to_bytes())
}

///|
/// Draw a pixel using geometry (Vector version). Can be slow, use with care.
pub fn draw_pixel_v(position : Vector2, color : Color) -> Unit {
  @ffi.draw_pixel_v(position.to_bytes(), color.to_bytes())
}

///|
/// Draw a line.
pub fn draw_line(
  start_x : Int,
  start_y : Int,
  end_x : Int,
  end_y : Int,
  color : Color,
) -> Unit {
  @ffi.draw_line(start_x, start_y, end_x, end_y, color.to_bytes())
}

///|
/// Draw a line (using gl lines).
pub fn draw_line_v(
  start_pos : Vector2,
  end_pos : Vector2,
  color : Color,
) -> Unit {
  @ffi.draw_line_v(start_pos.to_bytes(), end_pos.to_bytes(), color.to_bytes())
}

///|
/// Draw a line (using triangles/quads).
pub fn draw_line_ex(
  start_pos : Vector2,
  end_pos : Vector2,
  thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_line_ex(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

///|
/// Draw line segment cubic-bezier in-out interpolation.
pub fn draw_line_bezier(
  start_pos : Vector2,
  end_pos : Vector2,
  thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_line_bezier(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

///|
/// Draw a color-filled circle.
pub fn draw_circle(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Color,
) -> Unit {
  @ffi.draw_circle(center_x, center_y, radius, color.to_bytes())
}

///|
/// Draw a piece of a circle.
pub fn draw_circle_sector(
  center : Vector2,
  radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Color,
) -> Unit {
  @ffi.draw_circle_sector(
    center.to_bytes(),
    radius,
    start_angle,
    end_angle,
    segments,
    color.to_bytes(),
  )
}

///|
/// Draw a gradient-filled circle.
pub fn draw_circle_gradient(
  center_x : Int,
  center_y : Int,
  radius : Float,
  inner : Color,
  outer : Color,
) -> Unit {
  @ffi.draw_circle_gradient(
    center_x,
    center_y,
    radius,
    inner.to_bytes(),
    outer.to_bytes(),
  )
}

///|
/// Draw a color-filled circle (Vector version).
pub fn draw_circle_v(center : Vector2, radius : Float, color : Color) -> Unit {
  @ffi.draw_circle_v(center.to_bytes(), radius, color.to_bytes())
}

///|
/// Draw circle outline.
pub fn draw_circle_lines(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Color,
) -> Unit {
  @ffi.draw_circle_lines(center_x, center_y, radius, color.to_bytes())
}

///|
/// Draw circle outline (Vector version).
pub fn draw_circle_lines_v(
  center : Vector2,
  radius : Float,
  color : Color,
) -> Unit {
  @ffi.draw_circle_lines_v(center.to_bytes(), radius, color.to_bytes())
}

///|
/// Draw ellipse.
pub fn draw_ellipse(
  center_x : Int,
  center_y : Int,
  radius_h : Float,
  radius_v : Float,
  color : Color,
) -> Unit {
  @ffi.draw_ellipse(center_x, center_y, radius_h, radius_v, color.to_bytes())
}

///|
/// Draw ellipse outline.
pub fn draw_ellipse_lines(
  center_x : Int,
  center_y : Int,
  radius_h : Float,
  radius_v : Float,
  color : Color,
) -> Unit {
  @ffi.draw_ellipse_lines(
    center_x,
    center_y,
    radius_h,
    radius_v,
    color.to_bytes(),
  )
}

///|
/// Draw ring.
pub fn draw_ring(
  center : Vector2,
  inner_radius : Float,
  outer_radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Color,
) -> Unit {
  @ffi.draw_ring(
    center.to_bytes(),
    inner_radius,
    outer_radius,
    start_angle,
    end_angle,
    segments,
    color.to_bytes(),
  )
}

///|
/// Draw ring outline.
pub fn draw_ring_lines(
  center : Vector2,
  inner_radius : Float,
  outer_radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Color,
) -> Unit {
  @ffi.draw_ring_lines(
    center.to_bytes(),
    inner_radius,
    outer_radius,
    start_angle,
    end_angle,
    segments,
    color.to_bytes(),
  )
}

///|
/// Draw a color-filled rectangle.
pub fn draw_rectangle(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  color : Color,
) -> Unit {
  @ffi.draw_rectangle(pos_x, pos_y, width, height, color.to_bytes())
}

///|
/// Draw a color-filled rectangle (Vector version).
pub fn draw_rectangle_v(
  position : Vector2,
  size : Vector2,
  color : Color,
) -> Unit {
  @ffi.draw_rectangle_v(position.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
/// Draw a color-filled rectangle.
pub fn draw_rectangle_rec(rec : Rectangle, color : Color) -> Unit {
  @ffi.draw_rectangle_rec(rec.to_bytes(), color.to_bytes())
}

///|
/// Draw a color-filled rectangle with pro parameters.
pub fn draw_rectangle_pro(
  rec : Rectangle,
  origin : Vector2,
  rotation : Float,
  color : Color,
) -> Unit {
  @ffi.draw_rectangle_pro(
    rec.to_bytes(),
    origin.to_bytes(),
    rotation,
    color.to_bytes(),
  )
}

///|
/// Draw a vertical-gradient-filled rectangle.
pub fn draw_rectangle_gradient_v(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  top : Color,
  bottom : Color,
) -> Unit {
  @ffi.draw_rectangle_gradient_v(
    pos_x,
    pos_y,
    width,
    height,
    top.to_bytes(),
    bottom.to_bytes(),
  )
}

///|
/// Draw a horizontal-gradient-filled rectangle.
pub fn draw_rectangle_gradient_h(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  left : Color,
  right : Color,
) -> Unit {
  @ffi.draw_rectangle_gradient_h(
    pos_x,
    pos_y,
    width,
    height,
    left.to_bytes(),
    right.to_bytes(),
  )
}

///|
/// Draw a gradient-filled rectangle with custom vertex colors.
pub fn draw_rectangle_gradient_ex(
  rec : Rectangle,
  top_left : Color,
  bottom_left : Color,
  top_right : Color,
  bottom_right : Color,
) -> Unit {
  @ffi.draw_rectangle_gradient_ex(
    rec.to_bytes(),
    top_left.to_bytes(),
    bottom_left.to_bytes(),
    top_right.to_bytes(),
    bottom_right.to_bytes(),
  )
}

///|
/// Draw rectangle outline.
pub fn draw_rectangle_lines(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  color : Color,
) -> Unit {
  @ffi.draw_rectangle_lines(pos_x, pos_y, width, height, color.to_bytes())
}

///|
/// Draw rectangle outline with extended parameters.
pub fn draw_rectangle_lines_ex(
  rec : Rectangle,
  line_thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_rectangle_lines_ex(rec.to_bytes(), line_thick, color.to_bytes())
}

///|
/// Draw rectangle with rounded edges.
pub fn draw_rectangle_rounded(
  rec : Rectangle,
  roundness : Float,
  segments : Int,
  color : Color,
) -> Unit {
  @ffi.draw_rectangle_rounded(
    rec.to_bytes(),
    roundness,
    segments,
    color.to_bytes(),
  )
}

///|
/// Draw rectangle lines with rounded edges.
pub fn draw_rectangle_rounded_lines(
  rec : Rectangle,
  roundness : Float,
  segments : Int,
  color : Color,
) -> Unit {
  @ffi.draw_rectangle_rounded_lines(
    rec.to_bytes(),
    roundness,
    segments,
    color.to_bytes(),
  )
}

///|
/// Draw rectangle with rounded edges outline.
pub fn draw_rectangle_rounded_lines_ex(
  rec : Rectangle,
  roundness : Float,
  segments : Int,
  line_thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_rectangle_rounded_lines_ex(
    rec.to_bytes(),
    roundness,
    segments,
    line_thick,
    color.to_bytes(),
  )
}

///|
/// Draw a color-filled triangle (vertex in counter-clockwise order!).
pub fn draw_triangle(
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  color : Color,
) -> Unit {
  @ffi.draw_triangle(
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    color.to_bytes(),
  )
}

///|
/// Draw triangle outline (vertex in counter-clockwise order!).
pub fn draw_triangle_lines(
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  color : Color,
) -> Unit {
  @ffi.draw_triangle_lines(
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    color.to_bytes(),
  )
}

///|
/// Draw a regular polygon (Vector version).
pub fn draw_poly(
  center : Vector2,
  sides : Int,
  radius : Float,
  rotation : Float,
  color : Color,
) -> Unit {
  @ffi.draw_poly(center.to_bytes(), sides, radius, rotation, color.to_bytes())
}

///|
/// Draw a polygon outline of n sides.
pub fn draw_poly_lines(
  center : Vector2,
  sides : Int,
  radius : Float,
  rotation : Float,
  color : Color,
) -> Unit {
  @ffi.draw_poly_lines(
    center.to_bytes(),
    sides,
    radius,
    rotation,
    color.to_bytes(),
  )
}

///|
/// Draw a polygon outline of n sides with extended parameters.
pub fn draw_poly_lines_ex(
  center : Vector2,
  sides : Int,
  radius : Float,
  rotation : Float,
  line_thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_poly_lines_ex(
    center.to_bytes(),
    sides,
    radius,
    rotation,
    line_thick,
    color.to_bytes(),
  )
}

// ============================================================================
// Collision detection (pure MoonBit)
// ============================================================================

///|
/// Check collision between two rectangles.
pub fn check_collision_recs(rec1 : Rectangle, rec2 : Rectangle) -> Bool {
  rec1.x < rec2.x + rec2.width &&
  rec1.x + rec1.width > rec2.x &&
  rec1.y < rec2.y + rec2.height &&
  rec1.y + rec1.height > rec2.y
}

///|
/// Check collision between two circles.
pub fn check_collision_circles(
  center1 : Vector2,
  radius1 : Float,
  center2 : Vector2,
  radius2 : Float,
) -> Bool {
  let dx = center2.x - center1.x
  let dy = center2.y - center1.y
  let distance_squared = dx * dx + dy * dy
  let radius_sum = radius1 + radius2
  distance_squared <= radius_sum * radius_sum
}

///|
/// Check collision between circle and rectangle.
pub fn check_collision_circle_rec(
  center : Vector2,
  radius : Float,
  rec : Rectangle,
) -> Bool {
  let rec_center_x = rec.x + rec.width / 2.0
  let rec_center_y = rec.y + rec.height / 2.0
  let dx = fabsf(center.x - rec_center_x)
  let dy = fabsf(center.y - rec_center_y)
  if dx > rec.width / 2.0 + radius {
    return false
  }
  if dy > rec.height / 2.0 + radius {
    return false
  }
  if dx <= rec.width / 2.0 {
    return true
  }
  if dy <= rec.height / 2.0 {
    return true
  }
  let corner_dist_sq = (dx - rec.width / 2.0) * (dx - rec.width / 2.0) +
    (dy - rec.height / 2.0) * (dy - rec.height / 2.0)
  corner_dist_sq <= radius * radius
}

///|
/// Check if point is inside rectangle.
pub fn check_collision_point_rec(point : Vector2, rec : Rectangle) -> Bool {
  point.x >= rec.x &&
  point.x < rec.x + rec.width &&
  point.y >= rec.y &&
  point.y < rec.y + rec.height
}

///|
/// Check if point is inside circle.
pub fn check_collision_point_circle(
  point : Vector2,
  center : Vector2,
  radius : Float,
) -> Bool {
  let distance_squared = (point.x - center.x) * (point.x - center.x) +
    (point.y - center.y) * (point.y - center.y)
  distance_squared <= radius * radius
}

///|
/// Check if point is inside a triangle.
pub fn check_collision_point_triangle(
  point : Vector2,
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
) -> Bool {
  let alpha = (
      (p2.y - p3.y) * (point.x - p3.x) + (p3.x - p2.x) * (point.y - p3.y)
    ) /
    ((p2.y - p3.y) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.y - p3.y))
  let beta = (
      (p3.y - p1.y) * (point.x - p3.x) + (p1.x - p3.x) * (point.y - p3.y)
    ) /
    ((p2.y - p3.y) * (p1.x - p3.x) + (p3.x - p2.x) * (p1.y - p3.y))
  let gamma = (1.0 : Float) - alpha - beta
  alpha > 0.0 && beta > 0.0 && gamma > 0.0
}

///|
/// Get collision rectangle for two rectangles collision.
pub fn get_collision_rec(rec1 : Rectangle, rec2 : Rectangle) -> Rectangle {
  let left = if rec1.x > rec2.x { rec1.x } else { rec2.x }
  let right1 = rec1.x + rec1.width
  let right2 = rec2.x + rec2.width
  let right = if right1 < right2 { right1 } else { right2 }
  let top = if rec1.y > rec2.y { rec1.y } else { rec2.y }
  let bottom1 = rec1.y + rec1.height
  let bottom2 = rec2.y + rec2.height
  let bottom = if bottom1 < bottom2 { bottom1 } else { bottom2 }
  if left < right && top < bottom {
    { x: left, y: top, width: right - left, height: bottom - top }
  } else {
    { x: 0.0, y: 0.0, width: 0.0, height: 0.0 }
  }
}

// ============================================================================
// Missing basic shapes (array-based + circle sector lines)
// ============================================================================

///|
/// Draw circle sector outline.
pub fn draw_circle_sector_lines(
  center : Vector2,
  radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Color,
) -> Unit {
  @ffi.draw_circle_sector_lines(
    center.to_bytes(),
    radius,
    start_angle,
    end_angle,
    segments,
    color.to_bytes(),
  )
}

///|
fn vector2_array_to_bytes(points : Array[Vector2]) -> Bytes {
  let buf = @buffer.new(size_hint=points.length() * 8)
  for p in points {
    buf.write_float_le(p.x)
    buf.write_float_le(p.y)
  }
  buf.to_bytes()
}

///|
/// Draw lines sequence (using gl lines).
pub fn draw_line_strip(points : Array[Vector2], color : Color) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_line_strip(bytes, points.length(), color.to_bytes())
}

///|
/// Draw a triangle fan defined by points (first vertex is the center).
pub fn draw_triangle_fan(points : Array[Vector2], color : Color) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_triangle_fan(bytes, points.length(), color.to_bytes())
}

///|
/// Draw a triangle strip defined by points.
pub fn draw_triangle_strip(points : Array[Vector2], color : Color) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_triangle_strip(bytes, points.length(), color.to_bytes())
}

// ============================================================================
// Spline drawing (array-based)
// ============================================================================

///|
/// Draw spline: Linear, minimum 2 points.
pub fn draw_spline_linear(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_spline_linear(bytes, points.length(), thick, color.to_bytes())
}

///|
/// Draw spline: B-Spline, minimum 4 points.
pub fn draw_spline_basis(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_spline_basis(bytes, points.length(), thick, color.to_bytes())
}

///|
/// Draw spline: Catmull-Rom, minimum 4 points.
pub fn draw_spline_catmull_rom(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_spline_catmull_rom(bytes, points.length(), thick, color.to_bytes())
}

///|
/// Draw spline: Quadratic Bezier, minimum 3 points (1 control point).
pub fn draw_spline_bezier_quadratic(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_spline_bezier_quadratic(
    bytes,
    points.length(),
    thick,
    color.to_bytes(),
  )
}

///|
/// Draw spline: Cubic Bezier, minimum 4 points (2 control points).
pub fn draw_spline_bezier_cubic(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_spline_bezier_cubic(bytes, points.length(), thick, color.to_bytes())
}

// ============================================================================
// Spline segments
// ============================================================================

///|
/// Draw spline segment: Linear, 2 points.
pub fn draw_spline_segment_linear(
  p1 : Vector2,
  p2 : Vector2,
  thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_spline_segment_linear(
    p1.to_bytes(),
    p2.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

///|
/// Draw spline segment: B-Spline, 4 points.
pub fn draw_spline_segment_basis(
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
  p4 : Vector2,
  thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_spline_segment_basis(
    p1.to_bytes(),
    p2.to_bytes(),
    p3.to_bytes(),
    p4.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

///|
/// Draw spline segment: Catmull-Rom, 4 points.
pub fn draw_spline_segment_catmull_rom(
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
  p4 : Vector2,
  thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_spline_segment_catmull_rom(
    p1.to_bytes(),
    p2.to_bytes(),
    p3.to_bytes(),
    p4.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

///|
/// Draw spline segment: Quadratic Bezier, 2 points, 1 control point.
pub fn draw_spline_segment_bezier_quadratic(
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
  thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_spline_segment_bezier_quadratic(
    p1.to_bytes(),
    p2.to_bytes(),
    p3.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

///|
/// Draw spline segment: Cubic Bezier, 2 points, 2 control points.
pub fn draw_spline_segment_bezier_cubic(
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
  p4 : Vector2,
  thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_spline_segment_bezier_cubic(
    p1.to_bytes(),
    p2.to_bytes(),
    p3.to_bytes(),
    p4.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

// ============================================================================
// Spline point evaluation (pure MoonBit)
// ============================================================================

///|
/// Get (evaluate) spline point: Linear.
pub fn get_spline_point_linear(
  start_pos : Vector2,
  end_pos : Vector2,
  t : Float,
) -> Vector2 {
  let one_minus_t : Float = 1.0 - t
  Vector2::new(
    start_pos.x * one_minus_t + end_pos.x * t,
    start_pos.y * one_minus_t + end_pos.y * t,
  )
}

///|
/// Get (evaluate) spline point: B-Spline.
pub fn get_spline_point_basis(
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
  p4 : Vector2,
  t : Float,
) -> Vector2 {
  let a0 : Float = (-p1.x + 3.0 * p2.x - 3.0 * p3.x + p4.x) / 6.0
  let a1 : Float = (3.0 * p1.x - 6.0 * p2.x + 3.0 * p3.x) / 6.0
  let a2 : Float = (-3.0 * p1.x + 3.0 * p3.x) / 6.0
  let a3 : Float = (p1.x + 4.0 * p2.x + p3.x) / 6.0
  let b0 : Float = (-p1.y + 3.0 * p2.y - 3.0 * p3.y + p4.y) / 6.0
  let b1 : Float = (3.0 * p1.y - 6.0 * p2.y + 3.0 * p3.y) / 6.0
  let b2 : Float = (-3.0 * p1.y + 3.0 * p3.y) / 6.0
  let b3 : Float = (p1.y + 4.0 * p2.y + p3.y) / 6.0
  Vector2::new(
    a3 + t * (a2 + t * (a1 + t * a0)),
    b3 + t * (b2 + t * (b1 + t * b0)),
  )
}

///|
/// Get (evaluate) spline point: Catmull-Rom.
pub fn get_spline_point_catmull_rom(
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
  p4 : Vector2,
  t : Float,
) -> Vector2 {
  let t2 = t * t
  let t3 = t2 * t
  let q0 : Float = -t3 + 2.0 * t2 - t
  let q1 : Float = 3.0 * t3 - 5.0 * t2 + 2.0
  let q2 : Float = -3.0 * t3 + 4.0 * t2 + t
  let q3 = t3 - t2
  Vector2::new(
    (0.5 : Float) * (p1.x * q0 + p2.x * q1 + p3.x * q2 + p4.x * q3),
    (0.5 : Float) * (p1.y * q0 + p2.y * q1 + p3.y * q2 + p4.y * q3),
  )
}

///|
/// Get (evaluate) spline point: Quadratic Bezier.
pub fn get_spline_point_bezier_quad(
  start_pos : Vector2,
  control_pos : Vector2,
  end_pos : Vector2,
  t : Float,
) -> Vector2 {
  let one_minus_t : Float = 1.0 - t
  let a = one_minus_t * one_minus_t
  let b : Float = 2.0 * one_minus_t * t
  let c = t * t
  Vector2::new(
    a * start_pos.x + b * control_pos.x + c * end_pos.x,
    a * start_pos.y + b * control_pos.y + c * end_pos.y,
  )
}

///|
/// Get (evaluate) spline point: Cubic Bezier.
pub fn get_spline_point_bezier_cubic(
  start_pos : Vector2,
  start_control_pos : Vector2,
  end_control_pos : Vector2,
  end_pos : Vector2,
  t : Float,
) -> Vector2 {
  let one_minus_t : Float = 1.0 - t
  let a = one_minus_t * one_minus_t * one_minus_t
  let b : Float = 3.0 * one_minus_t * one_minus_t * t
  let c : Float = 3.0 * one_minus_t * t * t
  let d = t * t * t
  Vector2::new(
    a * start_pos.x +
    b * start_control_pos.x +
    c * end_control_pos.x +
    d * end_pos.x,
    a * start_pos.y +
    b * start_control_pos.y +
    c * end_control_pos.y +
    d * end_pos.y,
  )
}

// ============================================================================
// Additional 2D collision detection (pure MoonBit)
// ============================================================================

///|
/// Check if circle collides with a line created between two points.
pub fn check_collision_circle_line(
  center : Vector2,
  radius : Float,
  p1 : Vector2,
  p2 : Vector2,
) -> Bool {
  let flt_epsilon : Float = 1.1920929e-7
  let dx = p1.x - p2.x
  let dy = p1.y - p2.y
  if fabsf(dx) + fabsf(dy) <= flt_epsilon {
    return check_collision_circles(p1, 0.0, center, radius)
  }
  let length_sq = dx * dx + dy * dy
  let mut dot_product = (
      (center.x - p1.x) * (p2.x - p1.x) + (center.y - p1.y) * (p2.y - p1.y)
    ) /
    length_sq
  if dot_product > 1.0 {
    dot_product = 1.0
  } else if dot_product < 0.0 {
    dot_product = 0.0
  }
  let dx2 = p1.x - dot_product * dx - center.x
  let dy2 = p1.y - dot_product * dy - center.y
  let distance_sq = dx2 * dx2 + dy2 * dy2
  distance_sq <= radius * radius
}

///|
/// Check if point belongs to line created between two points with defined margin in pixels.
pub fn check_collision_point_line(
  point : Vector2,
  p1 : Vector2,
  p2 : Vector2,
  threshold : Int,
) -> Bool {
  let dxc = point.x - p1.x
  let dyc = point.y - p1.y
  let dxl = p2.x - p1.x
  let dyl = p2.y - p1.y
  let cross = dxc * dyl - dyc * dxl
  if fabsf(cross) < Float::from_int(threshold) * fmaxf(fabsf(dxl), fabsf(dyl)) {
    if fabsf(dxl) >= fabsf(dyl) {
      if dxl > 0.0 {
        p1.x <= point.x && point.x <= p2.x
      } else {
        p2.x <= point.x && point.x <= p1.x
      }
    } else if dyl > 0.0 {
      p1.y <= point.y && point.y <= p2.y
    } else {
      p2.y <= point.y && point.y <= p1.y
    }
  } else {
    false
  }
}

// ============================================================================
// 3D triangle strip
// ============================================================================

///|
fn vector3_array_to_bytes(points : Array[Vector3]) -> Bytes {
  let buf = @buffer.new(size_hint=points.length() * 12)
  for p in points {
    buf.write_float_le(p.x)
    buf.write_float_le(p.y)
    buf.write_float_le(p.z)
  }
  buf.to_bytes()
}

///|
/// Draw a triangle strip defined by points in 3D space.
pub fn draw_triangle_strip_3d(points : Array[Vector3], color : Color) -> Unit {
  let bytes = vector3_array_to_bytes(points)
  @ffi.draw_triangle_strip_3d(bytes, points.length(), color.to_bytes())
}

// ============================================================================
// Additional collision detection (pure MoonBit)
// ============================================================================

///|
/// Check if point is within a polygon described by array of vertices.
pub fn check_collision_point_poly(
  point : Vector2,
  points : Array[Vector2],
) -> Bool {
  let point_count = points.length()
  if point_count <= 2 {
    return false
  }
  let mut inside = false
  let mut j = point_count - 1
  for i in 0..<point_count {
    if (points[i].y > point.y) != (points[j].y > point.y) &&
      point.x <
      (points[j].x - points[i].x) *
      (point.y - points[i].y) /
      (points[j].y - points[i].y) +
      points[i].x {
      inside = !inside
    }
    j = i
  }
  inside
}

///|
/// Check the collision between two lines defined by two points each, returns collision point.
pub fn check_collision_lines(
  start_pos1 : Vector2,
  end_pos1 : Vector2,
  start_pos2 : Vector2,
  end_pos2 : Vector2,
) -> Vector2? {
  let flt_epsilon : Float = 1.1920929e-7
  let div = (end_pos2.y - start_pos2.y) * (end_pos1.x - start_pos1.x) -
    (end_pos2.x - start_pos2.x) * (end_pos1.y - start_pos1.y)
  if fabsf(div) < flt_epsilon {
    return None
  }
  let cross1 = start_pos1.x * end_pos1.y - start_pos1.y * end_pos1.x
  let cross2 = start_pos2.x * end_pos2.y - start_pos2.y * end_pos2.x
  let xi = (
      (start_pos2.x - end_pos2.x) * cross1 -
      (start_pos1.x - end_pos1.x) * cross2
    ) /
    div
  let yi = (
      (start_pos2.y - end_pos2.y) * cross1 -
      (start_pos1.y - end_pos1.y) * cross2
    ) /
    div
  if fabsf(start_pos1.x - end_pos1.x) > flt_epsilon &&
    (
      xi < fminf(start_pos1.x, end_pos1.x) ||
      xi > fmaxf(start_pos1.x, end_pos1.x)
    ) {
    return None
  }
  if fabsf(start_pos2.x - end_pos2.x) > flt_epsilon &&
    (
      xi < fminf(start_pos2.x, end_pos2.x) ||
      xi > fmaxf(start_pos2.x, end_pos2.x)
    ) {
    return None
  }
  if fabsf(start_pos1.y - end_pos1.y) > flt_epsilon &&
    (
      yi < fminf(start_pos1.y, end_pos1.y) ||
      yi > fmaxf(start_pos1.y, end_pos1.y)
    ) {
    return None
  }
  if fabsf(start_pos2.y - end_pos2.y) > flt_epsilon &&
    (
      yi < fminf(start_pos2.y, end_pos2.y) ||
      yi > fmaxf(start_pos2.y, end_pos2.y)
    ) {
    return None
  }
  Some({ x: xi, y: yi })
}
