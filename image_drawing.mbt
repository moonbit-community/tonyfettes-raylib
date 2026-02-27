// ============================================================================
// Image drawing: Clear
// ============================================================================

///|
pub fn image_clear_background(dst : Image, color : Color) -> Unit {
  @ffi.image_clear_background(dst, color.to_bytes())
}

// ============================================================================
// Image drawing: Pixel
// ============================================================================

///|
pub fn image_draw_pixel(
  dst : Image,
  pos_x : Int,
  pos_y : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_pixel(dst, pos_x, pos_y, color.to_bytes())
}

///|
pub fn image_draw_pixel_v(
  dst : Image,
  position : Vector2,
  color : Color,
) -> Unit {
  @ffi.image_draw_pixel_v(dst, position.to_bytes(), color.to_bytes())
}

// ============================================================================
// Image drawing: Line
// ============================================================================

///|
pub fn image_draw_line(
  dst : Image,
  start_pos_x : Int,
  start_pos_y : Int,
  end_pos_x : Int,
  end_pos_y : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_line(
    dst,
    start_pos_x,
    start_pos_y,
    end_pos_x,
    end_pos_y,
    color.to_bytes(),
  )
}

///|
pub fn image_draw_line_v(
  dst : Image,
  start : Vector2,
  end_ : Vector2,
  color : Color,
) -> Unit {
  @ffi.image_draw_line_v(
    dst,
    start.to_bytes(),
    end_.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn image_draw_line_ex(
  dst : Image,
  start : Vector2,
  end_ : Vector2,
  thick : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_line_ex(
    dst,
    start.to_bytes(),
    end_.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

// ============================================================================
// Image drawing: Circle
// ============================================================================

///|
pub fn image_draw_circle(
  dst : Image,
  center_x : Int,
  center_y : Int,
  radius : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_circle(dst, center_x, center_y, radius, color.to_bytes())
}

///|
pub fn image_draw_circle_v(
  dst : Image,
  center : Vector2,
  radius : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_circle_v(dst, center.to_bytes(), radius, color.to_bytes())
}

///|
pub fn image_draw_circle_lines(
  dst : Image,
  center_x : Int,
  center_y : Int,
  radius : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_circle_lines(
    dst,
    center_x,
    center_y,
    radius,
    color.to_bytes(),
  )
}

///|
pub fn image_draw_circle_lines_v(
  dst : Image,
  center : Vector2,
  radius : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_circle_lines_v(
    dst,
    center.to_bytes(),
    radius,
    color.to_bytes(),
  )
}

// ============================================================================
// Image drawing: Rectangle
// ============================================================================

///|
pub fn image_draw_rectangle(
  dst : Image,
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_rectangle(dst, pos_x, pos_y, width, height, color.to_bytes())
}

///|
pub fn image_draw_rectangle_v(
  dst : Image,
  position : Vector2,
  size : Vector2,
  color : Color,
) -> Unit {
  @ffi.image_draw_rectangle_v(
    dst,
    position.to_bytes(),
    size.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn image_draw_rectangle_rec(
  dst : Image,
  rec : Rectangle,
  color : Color,
) -> Unit {
  @ffi.image_draw_rectangle_rec(dst, rec.to_bytes(), color.to_bytes())
}

///|
pub fn image_draw_rectangle_lines(
  dst : Image,
  rec : Rectangle,
  thick : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_rectangle_lines(dst, rec.to_bytes(), thick, color.to_bytes())
}

// ============================================================================
// Image drawing: Triangle
// ============================================================================

///|
pub fn image_draw_triangle(
  dst : Image,
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  color : Color,
) -> Unit {
  @ffi.image_draw_triangle(
    dst,
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn image_draw_triangle_ex(
  dst : Image,
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  c1 : Color,
  c2 : Color,
  c3 : Color,
) -> Unit {
  @ffi.image_draw_triangle_ex(
    dst,
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    c1.to_bytes(),
    c2.to_bytes(),
    c3.to_bytes(),
  )
}

///|
pub fn image_draw_triangle_lines(
  dst : Image,
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  color : Color,
) -> Unit {
  @ffi.image_draw_triangle_lines(
    dst,
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn image_draw_triangle_fan(
  dst : Image,
  points : Array[Vector2],
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.image_draw_triangle_fan(dst, bytes, points.length(), color.to_bytes())
}

///|
pub fn image_draw_triangle_strip(
  dst : Image,
  points : Array[Vector2],
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.image_draw_triangle_strip(dst, bytes, points.length(), color.to_bytes())
}

// ============================================================================
// Image drawing: Compositing
// ============================================================================

///|
pub fn image_draw(
  dst : Image,
  src : Image,
  src_rec : Rectangle,
  dst_rec : Rectangle,
  tint : Color,
) -> Unit {
  @ffi.image_draw(
    dst,
    src,
    src_rec.to_bytes(),
    dst_rec.to_bytes(),
    tint.to_bytes(),
  )
}

// ============================================================================
// Image drawing: Text
// ============================================================================

///|
pub fn image_draw_text(
  dst : Image,
  text : String,
  pos_x : Int,
  pos_y : Int,
  font_size : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_text(
    dst,
    @utf8.encode(text),
    pos_x,
    pos_y,
    font_size,
    color.to_bytes(),
  )
}

///|
pub fn image_draw_text_ex(
  dst : Image,
  font : Font,
  text : String,
  position : Vector2,
  font_size : Float,
  spacing : Float,
  tint : Color,
) -> Unit {
  @ffi.image_draw_text_ex(
    dst,
    font,
    @utf8.encode(text),
    position.to_bytes(),
    font_size,
    spacing,
    tint.to_bytes(),
  )
}
