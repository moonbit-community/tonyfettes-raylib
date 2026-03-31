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
pub extern "c" fn draw_line_bezier(
  start_pos : Bytes,
  end_pos : Bytes,
  thick : Float,
  color : Bytes,
) = "moonbit_raylib_draw_line_bezier"

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

// ============================================================================
// Missing basic shapes (array-based + circle sector lines)
// ============================================================================

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
