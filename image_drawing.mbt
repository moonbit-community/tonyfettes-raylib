// ============================================================================
// Image drawing: Clear
// ============================================================================

///|
/// Clear image background with given color.
#as_free_fn(image_clear_background)
pub fn Image::clear_background(self : Image, color : Color) -> Unit {
  @ffi.image_clear_background(self.0, color.to_bytes())
}

// ============================================================================
// Image drawing: Pixel
// ============================================================================

///|
/// Draw pixel within an image.
#as_free_fn(image_draw_pixel)
pub fn Image::draw_pixel(
  self : Image,
  pos_x : Int,
  pos_y : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_pixel(self.0, pos_x, pos_y, color.to_bytes())
}

///|
/// Draw pixel within an image (Vector version).
#as_free_fn(image_draw_pixel_v)
pub fn Image::draw_pixel_v(
  self : Image,
  position : Vector2,
  color : Color,
) -> Unit {
  @ffi.image_draw_pixel_v(self.0, position.to_bytes(), color.to_bytes())
}

// ============================================================================
// Image drawing: Line
// ============================================================================

///|
/// Draw line within an image.
#as_free_fn(image_draw_line)
pub fn Image::draw_line(
  self : Image,
  start_pos_x : Int,
  start_pos_y : Int,
  end_pos_x : Int,
  end_pos_y : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_line(
    self.0,
    start_pos_x,
    start_pos_y,
    end_pos_x,
    end_pos_y,
    color.to_bytes(),
  )
}

///|
/// Draw line within an image (Vector version).
#as_free_fn(image_draw_line_v)
pub fn Image::draw_line_v(
  self : Image,
  start : Vector2,
  end_ : Vector2,
  color : Color,
) -> Unit {
  @ffi.image_draw_line_v(
    self.0,
    start.to_bytes(),
    end_.to_bytes(),
    color.to_bytes(),
  )
}

///|
/// Draw a line defining thickness within an image.
#as_free_fn(image_draw_line_ex)
pub fn Image::draw_line_ex(
  self : Image,
  start : Vector2,
  end_ : Vector2,
  thick : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_line_ex(
    self.0,
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
/// Draw a filled circle within an image.
#as_free_fn(image_draw_circle)
pub fn Image::draw_circle(
  self : Image,
  center_x : Int,
  center_y : Int,
  radius : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_circle(self.0, center_x, center_y, radius, color.to_bytes())
}

///|
/// Draw a filled circle within an image (Vector version).
#as_free_fn(image_draw_circle_v)
pub fn Image::draw_circle_v(
  self : Image,
  center : Vector2,
  radius : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_circle_v(self.0, center.to_bytes(), radius, color.to_bytes())
}

///|
/// Draw circle outline within an image.
#as_free_fn(image_draw_circle_lines)
pub fn Image::draw_circle_lines(
  self : Image,
  center_x : Int,
  center_y : Int,
  radius : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_circle_lines(
    self.0,
    center_x,
    center_y,
    radius,
    color.to_bytes(),
  )
}

///|
/// Draw circle outline within an image (Vector version).
#as_free_fn(image_draw_circle_lines_v)
pub fn Image::draw_circle_lines_v(
  self : Image,
  center : Vector2,
  radius : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_circle_lines_v(
    self.0,
    center.to_bytes(),
    radius,
    color.to_bytes(),
  )
}

// ============================================================================
// Image drawing: Rectangle
// ============================================================================

///|
/// Draw rectangle within an image.
#as_free_fn(image_draw_rectangle)
pub fn Image::draw_rectangle(
  self : Image,
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_rectangle(
    self.0,
    pos_x,
    pos_y,
    width,
    height,
    color.to_bytes(),
  )
}

///|
/// Draw rectangle within an image (Vector version).
#as_free_fn(image_draw_rectangle_v)
pub fn Image::draw_rectangle_v(
  self : Image,
  position : Vector2,
  size : Vector2,
  color : Color,
) -> Unit {
  @ffi.image_draw_rectangle_v(
    self.0,
    position.to_bytes(),
    size.to_bytes(),
    color.to_bytes(),
  )
}

///|
/// Draw rectangle within an image.
#as_free_fn(image_draw_rectangle_rec)
pub fn Image::draw_rectangle_rec(
  self : Image,
  rec : Rectangle,
  color : Color,
) -> Unit {
  @ffi.image_draw_rectangle_rec(self.0, rec.to_bytes(), color.to_bytes())
}

///|
/// Draw rectangle lines within an image.
#as_free_fn(image_draw_rectangle_lines)
pub fn Image::draw_rectangle_lines(
  self : Image,
  rec : Rectangle,
  thick : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_rectangle_lines(
    self.0,
    rec.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

// ============================================================================
// Image drawing: Triangle
// ============================================================================

///|
/// Draw triangle within an image.
#as_free_fn(image_draw_triangle)
pub fn Image::draw_triangle(
  self : Image,
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  color : Color,
) -> Unit {
  @ffi.image_draw_triangle(
    self.0,
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    color.to_bytes(),
  )
}

///|
/// Draw triangle with interpolated colors within an image.
#as_free_fn(image_draw_triangle_ex)
pub fn Image::draw_triangle_ex(
  self : Image,
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  c1 : Color,
  c2 : Color,
  c3 : Color,
) -> Unit {
  @ffi.image_draw_triangle_ex(
    self.0,
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    c1.to_bytes(),
    c2.to_bytes(),
    c3.to_bytes(),
  )
}

///|
/// Draw triangle outline within an image.
#as_free_fn(image_draw_triangle_lines)
pub fn Image::draw_triangle_lines(
  self : Image,
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  color : Color,
) -> Unit {
  @ffi.image_draw_triangle_lines(
    self.0,
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    color.to_bytes(),
  )
}

///|
/// Draw a triangle fan defined by points within an image (first vertex is the center).
#as_free_fn(image_draw_triangle_fan)
pub fn Image::draw_triangle_fan(
  self : Image,
  points : Array[Vector2],
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.image_draw_triangle_fan(self.0, bytes, points.length(), color.to_bytes())
}

///|
/// Draw a triangle strip defined by points within an image.
#as_free_fn(image_draw_triangle_strip)
pub fn Image::draw_triangle_strip(
  self : Image,
  points : Array[Vector2],
  color : Color,
) -> Unit {
  let bytes = vector2_array_to_bytes(points)
  @ffi.image_draw_triangle_strip(
    self.0,
    bytes,
    points.length(),
    color.to_bytes(),
  )
}

// ============================================================================
// Image drawing: Compositing
// ============================================================================

///|
/// Draw a source image within a destination image (tint applied to source).
#as_free_fn(image_draw)
pub fn Image::draw(
  self : Image,
  src : Image,
  src_rec : Rectangle,
  dst_rec : Rectangle,
  tint : Color,
) -> Unit {
  @ffi.image_draw(
    self.0,
    src.0,
    src_rec.to_bytes(),
    dst_rec.to_bytes(),
    tint.to_bytes(),
  )
}

// ============================================================================
// Image drawing: Text
// ============================================================================

///|
/// Draw text (using default font) within an image (destination).
#as_free_fn(image_draw_text)
pub fn Image::draw_text(
  self : Image,
  text : String,
  pos_x : Int,
  pos_y : Int,
  font_size : Int,
  color : Color,
) -> Unit {
  @ffi.image_draw_text(
    self.0,
    @utf8.encode(text),
    pos_x,
    pos_y,
    font_size,
    color.to_bytes(),
  )
}

///|
/// Draw text (custom sprite font) within an image (destination).
#as_free_fn(image_draw_text_ex)
pub fn Image::draw_text_ex(
  self : Image,
  font : Font,
  text : String,
  position : Vector2,
  font_size : Float,
  spacing : Float,
  tint : Color,
) -> Unit {
  @ffi.image_draw_text_ex(
    self.0,
    font.0,
    @utf8.encode(text),
    position.to_bytes(),
    font_size,
    spacing,
    tint.to_bytes(),
  )
}
