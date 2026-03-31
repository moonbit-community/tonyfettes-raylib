// ============================================================================
// Basic shapes drawing
// ============================================================================

///|
#borrow(color)
pub extern "c" fn draw_pixel(pos_x : Int, pos_y : Int, color : Bytes) = "moonbit_raylib_draw_pixel"

///|
#borrow(position, color)
pub extern "c" fn draw_pixel_v(position : Bytes, color : Bytes) = "moonbit_raylib_draw_pixel_v"

///|
#borrow(color)
pub extern "c" fn draw_line(
  start_x : Int,
  start_y : Int,
  end_x : Int,
  end_y : Int,
  color : Bytes,
) = "moonbit_raylib_draw_line"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_line_v(
  start_pos : Bytes,
  end_pos : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_line_v"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_line_ex(
  start_pos : Bytes,
  end_pos : Bytes,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_line_ex"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_line_bezier(
  start_pos : Bytes,
  end_pos : Bytes,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_line_bezier"

///|
#borrow(color)
pub extern "c" fn draw_circle(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Bytes,
) = "moonbit_raylib_draw_circle"

///|
#borrow(center, color)
pub extern "c" fn draw_circle_sector(
  center : Bytes,
  radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_raylib_draw_circle_sector"

///|
#borrow(inner, outer)
pub extern "c" fn draw_circle_gradient(
  center_x : Int,
  center_y : Int,
  radius : Float,
  inner : Bytes,
  outer : Bytes,
) = "moonbit_raylib_draw_circle_gradient"

///|
#borrow(center, color)
pub extern "c" fn draw_circle_v(center : Bytes, radius : Float, color : Bytes) = "moonbit_raylib_draw_circle_v"

///|
#borrow(color)
pub extern "c" fn draw_circle_lines(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Bytes,
) = "moonbit_raylib_draw_circle_lines"

///|
#borrow(center, color)
pub extern "c" fn draw_circle_lines_v(
  center : Bytes,
  radius : Float,
  color : Bytes,
) = "moonbit_raylib_draw_circle_lines_v"

///|
#borrow(color)
pub extern "c" fn draw_ellipse(
  center_x : Int,
  center_y : Int,
  radius_h : Float,
  radius_v : Float,
  color : Bytes,
) = "moonbit_raylib_draw_ellipse"

///|
#borrow(color)
pub extern "c" fn draw_ellipse_lines(
  center_x : Int,
  center_y : Int,
  radius_h : Float,
  radius_v : Float,
  color : Bytes,
) = "moonbit_raylib_draw_ellipse_lines"

///|
#borrow(center, color)
pub extern "c" fn draw_ring(
  center : Bytes,
  inner_radius : Float,
  outer_radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_raylib_draw_ring"

///|
#borrow(center, color)
pub extern "c" fn draw_ring_lines(
  center : Bytes,
  inner_radius : Float,
  outer_radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_raylib_draw_ring_lines"

///|
#borrow(rec, color)
pub extern "c" fn draw_rectangle_rounded(
  rec : Bytes,
  roundness : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_raylib_draw_rectangle_rounded"

///|
#borrow(rec, color)
pub extern "c" fn draw_rectangle_rounded_lines(
  rec : Bytes,
  roundness : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_raylib_draw_rectangle_rounded_lines"

///|
#borrow(rec, color)
pub extern "c" fn draw_rectangle_rounded_lines_ex(
  rec : Bytes,
  roundness : Float,
  segments : Int,
  line_thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_rectangle_rounded_lines_ex"

///|
#borrow(v1, v2, v3, color)
pub extern "c" fn draw_triangle(
  v1 : Bytes,
  v2 : Bytes,
  v3 : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_triangle"

///|
#borrow(v1, v2, v3, color)
pub extern "c" fn draw_triangle_lines(
  v1 : Bytes,
  v2 : Bytes,
  v3 : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_triangle_lines"

///|
#borrow(center, color)
pub extern "c" fn draw_poly(
  center : Bytes,
  sides : Int,
  radius : Float,
  rotation : Float,
  color : Bytes,
) = "moonbit_raylib_draw_poly"

///|
#borrow(center, color)
pub extern "c" fn draw_poly_lines(
  center : Bytes,
  sides : Int,
  radius : Float,
  rotation : Float,
  color : Bytes,
) = "moonbit_raylib_draw_poly_lines"

///|
#borrow(center, color)
pub extern "c" fn draw_poly_lines_ex(
  center : Bytes,
  sides : Int,
  radius : Float,
  rotation : Float,
  line_thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_poly_lines_ex"

// ============================================================================
// Missing basic shapes (array-based + circle sector lines)
// ============================================================================

///|
#borrow(center, color)
pub extern "c" fn draw_circle_sector_lines(
  center : Bytes,
  radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_raylib_draw_circle_sector_lines"

///|
#borrow(points, color)
pub extern "c" fn draw_line_strip(
  points : Bytes,
  point_count : Int,
  color : Bytes,
) = "moonbit_raylib_draw_line_strip"

///|
#borrow(points, color)
pub extern "c" fn draw_triangle_fan(
  points : Bytes,
  point_count : Int,
  color : Bytes,
) = "moonbit_raylib_draw_triangle_fan"

///|
#borrow(points, color)
pub extern "c" fn draw_triangle_strip(
  points : Bytes,
  point_count : Int,
  color : Bytes,
) = "moonbit_raylib_draw_triangle_strip"

// ============================================================================
// Spline drawing (array-based)
// ============================================================================

///|
#borrow(points, color)
pub extern "c" fn draw_spline_linear(
  points : Bytes,
  point_count : Int,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_spline_linear"

///|
#borrow(points, color)
pub extern "c" fn draw_spline_basis(
  points : Bytes,
  point_count : Int,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_spline_basis"

///|
#borrow(points, color)
pub extern "c" fn draw_spline_catmull_rom(
  points : Bytes,
  point_count : Int,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_spline_catmull_rom"

///|
#borrow(points, color)
pub extern "c" fn draw_spline_bezier_quadratic(
  points : Bytes,
  point_count : Int,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_spline_bezier_quadratic"

///|
#borrow(points, color)
pub extern "c" fn draw_spline_bezier_cubic(
  points : Bytes,
  point_count : Int,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_spline_bezier_cubic"

// ============================================================================
// Spline segments
// ============================================================================

///|
#borrow(p1, p2, color)
pub extern "c" fn draw_spline_segment_linear(
  p1 : Bytes,
  p2 : Bytes,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_spline_segment_linear"

///|
#borrow(p1, p2, p3, p4, color)
pub extern "c" fn draw_spline_segment_basis(
  p1 : Bytes,
  p2 : Bytes,
  p3 : Bytes,
  p4 : Bytes,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_spline_segment_basis"

///|
#borrow(p1, p2, p3, p4, color)
pub extern "c" fn draw_spline_segment_catmull_rom(
  p1 : Bytes,
  p2 : Bytes,
  p3 : Bytes,
  p4 : Bytes,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_spline_segment_catmull_rom"

///|
#borrow(p1, p2, p3, color)
pub extern "c" fn draw_spline_segment_bezier_quadratic(
  p1 : Bytes,
  p2 : Bytes,
  p3 : Bytes,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_spline_segment_bezier_quadratic"

///|
#borrow(p1, p2, p3, p4, color)
pub extern "c" fn draw_spline_segment_bezier_cubic(
  p1 : Bytes,
  p2 : Bytes,
  p3 : Bytes,
  p4 : Bytes,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_spline_segment_bezier_cubic"

// ============================================================================
// 3D triangle strip
// ============================================================================

///|
#borrow(points, color)
pub extern "c" fn draw_triangle_strip_3d(
  points : Bytes,
  point_count : Int,
  color : Bytes,
) = "moonbit_raylib_draw_triangle_strip_3d"
