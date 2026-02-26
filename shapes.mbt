// ============================================================================
// Basic shapes drawing (all wrappers — every function takes Color/Vector2/Rectangle)
// ============================================================================

///|
pub fn draw_pixel(pos_x : Int, pos_y : Int, color : Color) -> Unit {
  @ffi.draw_pixel(pos_x, pos_y, color.to_bytes())
}

///|
pub fn draw_pixel_v(position : Vector2, color : Color) -> Unit {
  @ffi.draw_pixel_v(position.to_bytes(), color.to_bytes())
}

///|
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
pub fn draw_line_v(
  start_pos : Vector2,
  end_pos : Vector2,
  color : Color,
) -> Unit {
  @ffi.draw_line_v(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    color.to_bytes(),
  )
}

///|
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
pub fn draw_circle(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Color,
) -> Unit {
  @ffi.draw_circle(center_x, center_y, radius, color.to_bytes())
}

///|
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
pub fn draw_circle_v(center : Vector2, radius : Float, color : Color) -> Unit {
  @ffi.draw_circle_v(center.to_bytes(), radius, color.to_bytes())
}

///|
pub fn draw_circle_lines(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Color,
) -> Unit {
  @ffi.draw_circle_lines(center_x, center_y, radius, color.to_bytes())
}

///|
pub fn draw_circle_lines_v(
  center : Vector2,
  radius : Float,
  color : Color,
) -> Unit {
  @ffi.draw_circle_lines_v(center.to_bytes(), radius, color.to_bytes())
}

///|
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
pub fn draw_rectangle_v(
  position : Vector2,
  size : Vector2,
  color : Color,
) -> Unit {
  @ffi.draw_rectangle_v(
    position.to_bytes(),
    size.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn draw_rectangle_rec(rec : Rectangle, color : Color) -> Unit {
  @ffi.draw_rectangle_rec(rec.to_bytes(), color.to_bytes())
}

///|
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
pub fn draw_rectangle_lines_ex(
  rec : Rectangle,
  line_thick : Float,
  color : Color,
) -> Unit {
  @ffi.draw_rectangle_lines_ex(rec.to_bytes(), line_thick, color.to_bytes())
}

///|
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
pub fn draw_poly(
  center : Vector2,
  sides : Int,
  radius : Float,
  rotation : Float,
  color : Color,
) -> Unit {
  @ffi.draw_poly(
    center.to_bytes(),
    sides,
    radius,
    rotation,
    color.to_bytes(),
  )
}

///|
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
// Collision detection (wrappers)
// ============================================================================

///|
pub fn check_collision_recs(rec1 : Rectangle, rec2 : Rectangle) -> Bool {
  @ffi.check_collision_recs(rec1.to_bytes(), rec2.to_bytes())
}

///|
pub fn check_collision_circles(
  center1 : Vector2,
  radius1 : Float,
  center2 : Vector2,
  radius2 : Float,
) -> Bool {
  @ffi.check_collision_circles(
    center1.to_bytes(),
    radius1,
    center2.to_bytes(),
    radius2,
  )
}

///|
pub fn check_collision_circle_rec(
  center : Vector2,
  radius : Float,
  rec : Rectangle,
) -> Bool {
  @ffi.check_collision_circle_rec(center.to_bytes(), radius, rec.to_bytes())
}

///|
pub fn check_collision_point_rec(point : Vector2, rec : Rectangle) -> Bool {
  @ffi.check_collision_point_rec(point.to_bytes(), rec.to_bytes())
}

///|
pub fn check_collision_point_circle(
  point : Vector2,
  center : Vector2,
  radius : Float,
) -> Bool {
  @ffi.check_collision_point_circle(
    point.to_bytes(),
    center.to_bytes(),
    radius,
  )
}

///|
pub fn check_collision_point_triangle(
  point : Vector2,
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
) -> Bool {
  @ffi.check_collision_point_triangle(
    point.to_bytes(),
    p1.to_bytes(),
    p2.to_bytes(),
    p3.to_bytes(),
  )
}

///|
pub fn get_collision_rec(rec1 : Rectangle, rec2 : Rectangle) -> Rectangle {
  Rectangle::from_bytes(
    @ffi.get_collision_rec(rec1.to_bytes(), rec2.to_bytes()),
  )
}

// ============================================================================
// Missing basic shapes (array-based + circle sector lines)
// ============================================================================

///|
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
pub fn draw_line_strip(points : Array[Vector2], color : Color) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_line_strip(bytes, points.length(), color.to_bytes())
}

///|
pub fn draw_triangle_fan(points : Array[Vector2], color : Color) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_triangle_fan(bytes, points.length(), color.to_bytes())
}

///|
pub fn draw_triangle_strip(points : Array[Vector2], color : Color) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_triangle_strip(bytes, points.length(), color.to_bytes())
}

// ============================================================================
// Spline drawing (array-based)
// ============================================================================

///|
pub fn draw_spline_linear(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_spline_linear(bytes, points.length(), thick, color.to_bytes())
}

///|
pub fn draw_spline_basis(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_spline_basis(bytes, points.length(), thick, color.to_bytes())
}

///|
pub fn draw_spline_catmull_rom(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_spline_catmull_rom(
    bytes,
    points.length(),
    thick,
    color.to_bytes(),
  )
}

///|
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
pub fn draw_spline_bezier_cubic(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.draw_spline_bezier_cubic(
    bytes,
    points.length(),
    thick,
    color.to_bytes(),
  )
}

// ============================================================================
// Spline segments
// ============================================================================

///|
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
// Spline point evaluation
// ============================================================================

///|
pub fn get_spline_point_linear(
  start_pos : Vector2,
  end_pos : Vector2,
  t : Float,
) -> Vector2 {
  Vector2::from_bytes(
    @ffi.get_spline_point_linear(start_pos.to_bytes(), end_pos.to_bytes(), t),
  )
}

///|
pub fn get_spline_point_basis(
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
  p4 : Vector2,
  t : Float,
) -> Vector2 {
  Vector2::from_bytes(
    @ffi.get_spline_point_basis(
      p1.to_bytes(),
      p2.to_bytes(),
      p3.to_bytes(),
      p4.to_bytes(),
      t,
    ),
  )
}

///|
pub fn get_spline_point_catmull_rom(
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
  p4 : Vector2,
  t : Float,
) -> Vector2 {
  Vector2::from_bytes(
    @ffi.get_spline_point_catmull_rom(
      p1.to_bytes(),
      p2.to_bytes(),
      p3.to_bytes(),
      p4.to_bytes(),
      t,
    ),
  )
}

///|
pub fn get_spline_point_bezier_quad(
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
  t : Float,
) -> Vector2 {
  Vector2::from_bytes(
    @ffi.get_spline_point_bezier_quad(
      p1.to_bytes(),
      p2.to_bytes(),
      p3.to_bytes(),
      t,
    ),
  )
}

///|
pub fn get_spline_point_bezier_cubic(
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
  p4 : Vector2,
  t : Float,
) -> Vector2 {
  Vector2::from_bytes(
    @ffi.get_spline_point_bezier_cubic(
      p1.to_bytes(),
      p2.to_bytes(),
      p3.to_bytes(),
      p4.to_bytes(),
      t,
    ),
  )
}

// ============================================================================
// Additional 2D collision detection
// ============================================================================

///|
pub fn check_collision_circle_line(
  center : Vector2,
  radius : Float,
  p1 : Vector2,
  p2 : Vector2,
) -> Bool {
  @ffi.check_collision_circle_line(
    center.to_bytes(),
    radius,
    p1.to_bytes(),
    p2.to_bytes(),
  )
}

///|
pub fn check_collision_point_line(
  point : Vector2,
  p1 : Vector2,
  p2 : Vector2,
  threshold : Int,
) -> Bool {
  @ffi.check_collision_point_line(
    point.to_bytes(),
    p1.to_bytes(),
    p2.to_bytes(),
    threshold,
  )
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
pub fn draw_triangle_strip_3d(points : Array[Vector3], color : Color) -> Unit {
  let bytes = vector3_array_to_bytes(points)
  @ffi.draw_triangle_strip_3d(bytes, points.length(), color.to_bytes())
}

// ============================================================================
// Additional collision detection
// ============================================================================

///|
pub fn check_collision_point_poly(
  point : Vector2,
  points : Array[Vector2],
) -> Bool {
  let bytes = vector2_array_to_bytes(points)
  @ffi.check_collision_point_poly(point.to_bytes(), bytes, points.length())
}

///|
pub fn check_collision_lines(
  start_pos1 : Vector2,
  end_pos1 : Vector2,
  start_pos2 : Vector2,
  end_pos2 : Vector2,
) -> Vector2? {
  let result = @ffi.check_collision_lines(
    start_pos1.to_bytes(),
    end_pos1.to_bytes(),
    start_pos2.to_bytes(),
    end_pos2.to_bytes(),
  )
  if result.length() > 0 {
    Some(Vector2::from_bytes(result))
  } else {
    None
  }
}
