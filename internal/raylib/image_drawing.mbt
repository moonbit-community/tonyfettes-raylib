// ============================================================================
// Image drawing: Clear
// ============================================================================

///|
#borrow(dst, color)
pub extern "c" fn image_clear_background(dst : Image, color : Bytes) = "moonbit_raylib_image_clear_background"

// ============================================================================
// Image drawing: Pixel
// ============================================================================

///|
#borrow(dst, color)
pub extern "c" fn image_draw_pixel(dst : Image, pos_x : Int, pos_y : Int, color : Bytes) = "moonbit_raylib_image_draw_pixel"

///|
#borrow(dst, position, color)
pub extern "c" fn image_draw_pixel_v(dst : Image, position : Bytes, color : Bytes) = "moonbit_raylib_image_draw_pixel_v"

// ============================================================================
// Image drawing: Line
// ============================================================================

///|
#borrow(dst, color)
pub extern "c" fn image_draw_line(
  dst : Image,
  start_pos_x : Int,
  start_pos_y : Int,
  end_pos_x : Int,
  end_pos_y : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_line"

///|
#borrow(dst, start, end_, color)
pub extern "c" fn image_draw_line_v(
  dst : Image,
  start : Bytes,
  end_ : Bytes,
  color : Bytes,
) = "moonbit_raylib_image_draw_line_v"

///|
#borrow(dst, start, end_, color)
pub extern "c" fn image_draw_line_ex(
  dst : Image,
  start : Bytes,
  end_ : Bytes,
  thick : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_line_ex"

// ============================================================================
// Image drawing: Circle
// ============================================================================

///|
#borrow(dst, color)
pub extern "c" fn image_draw_circle(
  dst : Image,
  center_x : Int,
  center_y : Int,
  radius : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_circle"

///|
#borrow(dst, center, color)
pub extern "c" fn image_draw_circle_v(
  dst : Image,
  center : Bytes,
  radius : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_circle_v"

///|
#borrow(dst, color)
pub extern "c" fn image_draw_circle_lines(
  dst : Image,
  center_x : Int,
  center_y : Int,
  radius : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_circle_lines"

///|
#borrow(dst, center, color)
pub extern "c" fn image_draw_circle_lines_v(
  dst : Image,
  center : Bytes,
  radius : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_circle_lines_v"

// ============================================================================
// Image drawing: Rectangle
// ============================================================================

///|
#borrow(dst, color)
pub extern "c" fn image_draw_rectangle(
  dst : Image,
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_rectangle"

///|
#borrow(dst, position, size, color)
pub extern "c" fn image_draw_rectangle_v(
  dst : Image,
  position : Bytes,
  size : Bytes,
  color : Bytes,
) = "moonbit_raylib_image_draw_rectangle_v"

///|
#borrow(dst, rec, color)
pub extern "c" fn image_draw_rectangle_rec(
  dst : Image,
  rec : Bytes,
  color : Bytes,
) = "moonbit_raylib_image_draw_rectangle_rec"

///|
#borrow(dst, rec, color)
pub extern "c" fn image_draw_rectangle_lines(
  dst : Image,
  rec : Bytes,
  thick : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_rectangle_lines"

// ============================================================================
// Image drawing: Triangle
// ============================================================================

///|
#borrow(dst, v1, v2, v3, color)
pub extern "c" fn image_draw_triangle(
  dst : Image,
  v1 : Bytes,
  v2 : Bytes,
  v3 : Bytes,
  color : Bytes,
) = "moonbit_raylib_image_draw_triangle"

///|
#borrow(dst, v1, v2, v3, c1, c2, c3)
pub extern "c" fn image_draw_triangle_ex(
  dst : Image,
  v1 : Bytes,
  v2 : Bytes,
  v3 : Bytes,
  c1 : Bytes,
  c2 : Bytes,
  c3 : Bytes,
) = "moonbit_raylib_image_draw_triangle_ex"

///|
#borrow(dst, v1, v2, v3, color)
pub extern "c" fn image_draw_triangle_lines(
  dst : Image,
  v1 : Bytes,
  v2 : Bytes,
  v3 : Bytes,
  color : Bytes,
) = "moonbit_raylib_image_draw_triangle_lines"

///|
#borrow(dst, points, color)
pub extern "c" fn image_draw_triangle_fan(
  dst : Image,
  points : Bytes,
  point_count : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_triangle_fan"

///|
#borrow(dst, points, color)
pub extern "c" fn image_draw_triangle_strip(
  dst : Image,
  points : Bytes,
  point_count : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_triangle_strip"

// ============================================================================
// Image drawing: Compositing
// ============================================================================

///|
#borrow(dst, src, src_rec, dst_rec, tint)
pub extern "c" fn image_draw(
  dst : Image,
  src : Image,
  src_rec : Bytes,
  dst_rec : Bytes,
  tint : Bytes,
) = "moonbit_raylib_image_draw"

// ============================================================================
// Image drawing: Text
// ============================================================================

///|
#borrow(dst, text, color)
pub extern "c" fn image_draw_text(
  dst : Image,
  text : Bytes,
  pos_x : Int,
  pos_y : Int,
  font_size : Int,
  color : Bytes,
) = "moonbit_raylib_image_draw_text"

///|
#borrow(dst, font, text, position, tint)
pub extern "c" fn image_draw_text_ex(
  dst : Image,
  font : Font,
  text : Bytes,
  position : Bytes,
  font_size : Float,
  spacing : Float,
  tint : Bytes,
) = "moonbit_raylib_image_draw_text_ex"
