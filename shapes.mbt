// ============================================================================
// Basic shapes drawing (all wrappers — every function takes Color/Vector2/Rectangle)
// ============================================================================

///|
const SmoothCircleErrorRate : Float = 0.5

///|
const SplineSegmentDivisions : Int = 24

///|
fn get_shape_texture_uvs() -> (UInt, Float, Float, Float, Float) {
  let texture = Texture::get_shapes()
  let shape_rect = get_shapes_texture_rectangle()
  let tex_width = Float::from_int(texture.width())
  let tex_height = Float::from_int(texture.height())
  (
    texture.id(),
    shape_rect.x / tex_width,
    shape_rect.y / tex_height,
    (shape_rect.x + shape_rect.width) / tex_width,
    (shape_rect.y + shape_rect.height) / tex_height,
  )
}

///|
fn submit_color(color : Color) -> Unit {
  @ffi.rl_color4ub(color.r, color.g, color.b, color.a)
}

///|
fn submit_shape_textured_quad(
  top_left : Vector2,
  bottom_left : Vector2,
  bottom_right : Vector2,
  top_right : Vector2,
  top_left_color : Color,
  bottom_left_color : Color,
  bottom_right_color : Color,
  top_right_color : Color,
) -> Unit {
  let (texture_id, u0, v0, u1, v1) = get_shape_texture_uvs()

  @ffi.rl_set_texture(texture_id)
  @ffi.rl_begin(@ffi.RlQuadsMode)
  @ffi.rl_normal3f(0.0, 0.0, 1.0)

  submit_color(top_left_color)
  @ffi.rl_tex_coord2f(u0, v0)
  @ffi.rl_vertex2f(top_left.x, top_left.y)

  submit_color(bottom_left_color)
  @ffi.rl_tex_coord2f(u0, v1)
  @ffi.rl_vertex2f(bottom_left.x, bottom_left.y)

  submit_color(bottom_right_color)
  @ffi.rl_tex_coord2f(u1, v1)
  @ffi.rl_vertex2f(bottom_right.x, bottom_right.y)

  submit_color(top_right_color)
  @ffi.rl_tex_coord2f(u1, v0)
  @ffi.rl_vertex2f(top_right.x, top_right.y)

  @ffi.rl_end()
  @ffi.rl_set_texture(0U)
}

///|
fn submit_shape_triangle(
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  color : Color,
) -> Unit {
  submit_shape_textured_quad(v1, v2, v2, v3, color, color, color, color)
}

///|
fn rectangle_pro_vertices(
  rec : Rectangle,
  origin : Vector2,
  rotation : Float,
) -> (Vector2, Vector2, Vector2, Vector2) {
  if rotation == 0.0 {
    let x = rec.x - origin.x
    let y = rec.y - origin.y
    (
      { x, y },
      { x: x + rec.width, y },
      { x, y: y + rec.height },
      { x: x + rec.width, y: y + rec.height },
    )
  } else {
    let sin_rotation = sinf(rotation * @ffi.DegToRad)
    let cos_rotation = cosf(rotation * @ffi.DegToRad)
    let x = rec.x
    let y = rec.y
    let dx = -origin.x
    let dy = -origin.y
    (
      {
        x: x + dx * cos_rotation - dy * sin_rotation,
        y: y + dx * sin_rotation + dy * cos_rotation,
      },
      {
        x: x + (dx + rec.width) * cos_rotation - dy * sin_rotation,
        y: y + (dx + rec.width) * sin_rotation + dy * cos_rotation,
      },
      {
        x: x + dx * cos_rotation - (dy + rec.height) * sin_rotation,
        y: y + dx * sin_rotation + (dy + rec.height) * cos_rotation,
      },
      {
        x: x +
        (dx + rec.width) * cos_rotation -
        (dy + rec.height) * sin_rotation,
        y: y +
        (dx + rec.width) * sin_rotation +
        (dy + rec.height) * cos_rotation,
      },
    )
  }
}

///|
fn circle_point(center : Vector2, angle : Float, radius : Float) -> Vector2 {
  let angle_radians = angle * @ffi.DegToRad
  {
    x: center.x + cosf(angle_radians) * radius,
    y: center.y + sinf(angle_radians) * radius,
  }
}

///|
fn resolve_circle_segments(
  radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
) -> (Float, Float, Int) {
  let (start_angle, end_angle) = if end_angle < start_angle {
    (end_angle, start_angle)
  } else {
    (start_angle, end_angle)
  }
  let angle_span = end_angle - start_angle
  let min_segments = (angle_span / (90.0 : Float)).ceil().to_int()
  let mut resolved_segments = segments
  if resolved_segments < min_segments {
    let ratio = (1.0 : Float) - SmoothCircleErrorRate / radius
    let cosine = fmaxf(
      (-1.0 : Float),
      fminf((1.0 : Float), (2.0 : Float) * ratio * ratio - (1.0 : Float)),
    )
    let theta = acosf(cosine)
    let estimated_segments = if theta > (0.0 : Float) {
      (
        angle_span *
        (((360.0 : Float) * @ffi.DegToRad) / theta).ceil() /
        (360.0 : Float)
      ).to_int()
    } else {
      0
    }
    resolved_segments = if estimated_segments <= 0 {
      min_segments
    } else {
      estimated_segments
    }
  }
  (start_angle, end_angle, resolved_segments)
}

///|
fn submit_triangle_strip(points : Array[Vector2], color : Color) -> Unit {
  if points.length() < 3 {
    return
  }

  @ffi.rl_begin(@ffi.RlTrianglesMode)
  submit_color(color)

  for i in 2..<points.length() {
    if (i % 2) == 0 {
      let point = points[i]
      let point_prev2 = points[i - 2]
      let point_prev1 = points[i - 1]
      @ffi.rl_vertex2f(point.x, point.y)
      @ffi.rl_vertex2f(point_prev2.x, point_prev2.y)
      @ffi.rl_vertex2f(point_prev1.x, point_prev1.y)
    } else {
      let point = points[i]
      let point_prev1 = points[i - 1]
      let point_prev2 = points[i - 2]
      @ffi.rl_vertex2f(point.x, point.y)
      @ffi.rl_vertex2f(point_prev1.x, point_prev1.y)
      @ffi.rl_vertex2f(point_prev2.x, point_prev2.y)
    }
  }

  @ffi.rl_end()
}

///|
fn make_spline_strip_buffer() -> Array[Vector2] {
  Array::make(SplineSegmentDivisions * 2 + 2, { x: 0.0, y: 0.0 })
}

///|
fn write_spline_strip_pair(
  points : Array[Vector2],
  index : Int,
  position : Vector2,
  dx : Float,
  dy : Float,
  size : Float,
) -> Unit {
  points[2 * index] = {
    x: position.x + dy * size,
    y: position.y - dx * size,
  }
  points[2 * index + 1] = {
    x: position.x - dy * size,
    y: position.y + dx * size,
  }
}

///|
fn clamp_rectangle_line_thickness(rec : Rectangle, line_thick : Float) -> Float {
  if line_thick > rec.width || line_thick > rec.height {
    if rec.width >= rec.height {
      rec.height / 2.0
    } else {
      rec.width / 2.0
    }
  } else {
    line_thick
  }
}

///|
fn rectangle_line_segments(
  rec : Rectangle,
  line_thick : Float,
) -> (Rectangle, Rectangle, Rectangle, Rectangle) {
  (
    { x: rec.x, y: rec.y, width: rec.width, height: line_thick },
    {
      x: rec.x,
      y: rec.y - line_thick + rec.height,
      width: rec.width,
      height: line_thick,
    },
    {
      x: rec.x,
      y: rec.y + line_thick,
      width: line_thick,
      height: rec.height - line_thick * 2.0,
    },
    {
      x: rec.x - line_thick + rec.width,
      y: rec.y + line_thick,
      width: line_thick,
      height: rec.height - line_thick * 2.0,
    },
  )
}

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
  let delta_x = end_pos.x - start_pos.x
  let delta_y = end_pos.y - start_pos.y
  let length = sqrtf(delta_x * delta_x + delta_y * delta_y)

  if length > (0.0 : Float) && thick > (0.0 : Float) {
    let scale = thick / ((2.0 : Float) * length)
    let radius_x = -scale * delta_y
    let radius_y = scale * delta_x
    let strip : Array[Vector2] = [
      { x: start_pos.x - radius_x, y: start_pos.y - radius_y },
      { x: start_pos.x + radius_x, y: start_pos.y + radius_y },
      { x: end_pos.x - radius_x, y: end_pos.y - radius_y },
      { x: end_pos.x + radius_x, y: end_pos.y + radius_y },
    ]
    submit_triangle_strip(strip, color)
  }
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
  draw_circle_v(
    { x: Float::from_int(center_x), y: Float::from_int(center_y) },
    radius,
    color,
  )
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
  let radius = if radius <= (0.0 : Float) {
    (0.1 : Float)
  } else {
    radius
  }
  let (start_angle, end_angle, segments) = resolve_circle_segments(
    radius,
    start_angle,
    end_angle,
    segments,
  )
  let step_length = (end_angle - start_angle) / Float::from_int(segments)
  let mut angle = start_angle
  let (texture_id, u0, v0, u1, v1) = get_shape_texture_uvs()

  @ffi.rl_set_texture(texture_id)
  @ffi.rl_begin(@ffi.RlQuadsMode)

  for _ in 0..<(segments / 2) {
    let start = circle_point(center, angle, radius)
    let mid = circle_point(center, angle + step_length, radius)
    let end_ = circle_point(center, angle + step_length * (2.0 : Float), radius)

    submit_color(color)

    @ffi.rl_tex_coord2f(u0, v0)
    @ffi.rl_vertex2f(center.x, center.y)

    @ffi.rl_tex_coord2f(u1, v0)
    @ffi.rl_vertex2f(end_.x, end_.y)

    @ffi.rl_tex_coord2f(u1, v1)
    @ffi.rl_vertex2f(mid.x, mid.y)

    @ffi.rl_tex_coord2f(u0, v1)
    @ffi.rl_vertex2f(start.x, start.y)

    angle = angle + step_length * (2.0 : Float)
  }

  if (segments % 2) == 1 {
    let start = circle_point(center, angle, radius)
    let end_ = circle_point(center, angle + step_length, radius)

    submit_color(color)

    @ffi.rl_tex_coord2f(u0, v0)
    @ffi.rl_vertex2f(center.x, center.y)

    @ffi.rl_tex_coord2f(u1, v1)
    @ffi.rl_vertex2f(end_.x, end_.y)

    @ffi.rl_tex_coord2f(u0, v1)
    @ffi.rl_vertex2f(start.x, start.y)

    @ffi.rl_tex_coord2f(u1, v0)
    @ffi.rl_vertex2f(center.x, center.y)
  }

  @ffi.rl_end()
  @ffi.rl_set_texture(0U)
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
  draw_circle_sector(center, radius, (0.0 : Float), (360.0 : Float), 36, color)
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
  if start_angle == end_angle {
    return
  }

  let mut inner_radius = inner_radius
  let mut outer_radius = outer_radius

  if outer_radius < inner_radius {
    let previous_outer = outer_radius
    outer_radius = inner_radius
    inner_radius = previous_outer

    if outer_radius <= (0.0 : Float) {
      outer_radius = (0.1 : Float)
    }
  }

  let (start_angle, end_angle, segments) = resolve_circle_segments(
    outer_radius,
    start_angle,
    end_angle,
    segments,
  )

  if inner_radius <= (0.0 : Float) {
    draw_circle_sector(center, outer_radius, start_angle, end_angle, segments, color)
    return
  }

  let step_length = (end_angle - start_angle) / Float::from_int(segments)
  let mut angle = start_angle
  let (texture_id, u0, v0, u1, v1) = get_shape_texture_uvs()

  @ffi.rl_set_texture(texture_id)
  @ffi.rl_begin(@ffi.RlQuadsMode)

  for _ in 0..<segments {
    let inner_start = circle_point(center, angle, inner_radius)
    let outer_start = circle_point(center, angle, outer_radius)
    let next_angle = angle + step_length
    let inner_end = circle_point(center, next_angle, inner_radius)
    let outer_end = circle_point(center, next_angle, outer_radius)

    submit_color(color)

    @ffi.rl_tex_coord2f(u0, v1)
    @ffi.rl_vertex2f(outer_start.x, outer_start.y)

    @ffi.rl_tex_coord2f(u0, v0)
    @ffi.rl_vertex2f(inner_start.x, inner_start.y)

    @ffi.rl_tex_coord2f(u1, v0)
    @ffi.rl_vertex2f(inner_end.x, inner_end.y)

    @ffi.rl_tex_coord2f(u1, v1)
    @ffi.rl_vertex2f(outer_end.x, outer_end.y)

    angle = next_angle
  }

  @ffi.rl_end()
  @ffi.rl_set_texture(0U)
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
  if start_angle == end_angle {
    return
  }

  let mut inner_radius = inner_radius
  let mut outer_radius = outer_radius

  if outer_radius < inner_radius {
    let previous_outer = outer_radius
    outer_radius = inner_radius
    inner_radius = previous_outer

    if outer_radius <= (0.0 : Float) {
      outer_radius = (0.1 : Float)
    }
  }

  let (start_angle, end_angle, segments) = resolve_circle_segments(
    outer_radius,
    start_angle,
    end_angle,
    segments,
  )

  if inner_radius <= (0.0 : Float) {
    draw_circle_sector_lines(
      center,
      outer_radius,
      start_angle,
      end_angle,
      segments,
      color,
    )
    return
  }

  let step_length = (end_angle - start_angle) / Float::from_int(segments)
  let mut angle = start_angle

  @ffi.rl_begin(@ffi.RlLinesMode)

  submit_color(color)
  let outer_start = circle_point(center, angle, outer_radius)
  let inner_start = circle_point(center, angle, inner_radius)
  @ffi.rl_vertex2f(outer_start.x, outer_start.y)
  @ffi.rl_vertex2f(inner_start.x, inner_start.y)

  for _ in 0..<segments {
    let current_outer = circle_point(center, angle, outer_radius)
    let current_inner = circle_point(center, angle, inner_radius)
    let next_angle = angle + step_length
    let next_outer = circle_point(center, next_angle, outer_radius)
    let next_inner = circle_point(center, next_angle, inner_radius)

    submit_color(color)

    @ffi.rl_vertex2f(current_outer.x, current_outer.y)
    @ffi.rl_vertex2f(next_outer.x, next_outer.y)

    @ffi.rl_vertex2f(current_inner.x, current_inner.y)
    @ffi.rl_vertex2f(next_inner.x, next_inner.y)

    angle = next_angle
  }

  submit_color(color)
  let outer_end = circle_point(center, angle, outer_radius)
  let inner_end = circle_point(center, angle, inner_radius)
  @ffi.rl_vertex2f(outer_end.x, outer_end.y)
  @ffi.rl_vertex2f(inner_end.x, inner_end.y)

  @ffi.rl_end()
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
  draw_rectangle_v(
    { x: Float::from_int(pos_x), y: Float::from_int(pos_y) },
    { x: Float::from_int(width), y: Float::from_int(height) },
    color,
  )
}

///|
/// Draw a color-filled rectangle (Vector version).
pub fn draw_rectangle_v(
  position : Vector2,
  size : Vector2,
  color : Color,
) -> Unit {
  draw_rectangle_pro(
    { x: position.x, y: position.y, width: size.x, height: size.y },
    { x: 0.0, y: 0.0 },
    0.0,
    color,
  )
}

///|
/// Draw a color-filled rectangle.
pub fn draw_rectangle_rec(rec : Rectangle, color : Color) -> Unit {
  draw_rectangle_pro(rec, { x: 0.0, y: 0.0 }, 0.0, color)
}

///|
/// Draw a color-filled rectangle with pro parameters.
pub fn draw_rectangle_pro(
  rec : Rectangle,
  origin : Vector2,
  rotation : Float,
  color : Color,
) -> Unit {
  let (top_left, top_right, bottom_left, bottom_right) = rectangle_pro_vertices(
    rec, origin, rotation,
  )
  submit_shape_textured_quad(
    top_left, bottom_left, bottom_right, top_right, color, color, color, color,
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
  draw_rectangle_gradient_ex(
    {
      x: Float::from_int(pos_x),
      y: Float::from_int(pos_y),
      width: Float::from_int(width),
      height: Float::from_int(height),
    },
    top,
    bottom,
    bottom,
    top,
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
  draw_rectangle_gradient_ex(
    {
      x: Float::from_int(pos_x),
      y: Float::from_int(pos_y),
      width: Float::from_int(width),
      height: Float::from_int(height),
    },
    left,
    left,
    right,
    right,
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
  submit_shape_textured_quad(
    { x: rec.x, y: rec.y },
    { x: rec.x, y: rec.y + rec.height },
    { x: rec.x + rec.width, y: rec.y + rec.height },
    { x: rec.x + rec.width, y: rec.y },
    top_left,
    bottom_left,
    top_right,
    bottom_right,
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
  let mat = Matrix::from_bytes(@ffi.rl_get_matrix_modelview())
  let zoom_factor : Float = (0.5 : Float) / mat.m0
  let pos_xf = Float::from_int(pos_x)
  let pos_yf = Float::from_int(pos_y)
  let widthf = Float::from_int(width)
  let heightf = Float::from_int(height)

  @ffi.rl_begin(@ffi.RlLinesMode)
  submit_color(color)

  @ffi.rl_vertex2f(pos_xf - zoom_factor, pos_yf)
  @ffi.rl_vertex2f(pos_xf + widthf + zoom_factor, pos_yf)

  @ffi.rl_vertex2f(pos_xf + widthf, pos_yf - zoom_factor)
  @ffi.rl_vertex2f(pos_xf + widthf, pos_yf + heightf + zoom_factor)

  @ffi.rl_vertex2f(pos_xf + widthf + zoom_factor, pos_yf + heightf)
  @ffi.rl_vertex2f(pos_xf - zoom_factor, pos_yf + heightf)

  @ffi.rl_vertex2f(pos_xf, pos_yf + heightf + zoom_factor)
  @ffi.rl_vertex2f(pos_xf, pos_yf - zoom_factor)

  @ffi.rl_end()
}

///|
/// Draw rectangle outline with extended parameters.
pub fn draw_rectangle_lines_ex(
  rec : Rectangle,
  line_thick : Float,
  color : Color,
) -> Unit {
  let line_thick = clamp_rectangle_line_thickness(rec, line_thick)
  let (top, bottom, left, right) = rectangle_line_segments(rec, line_thick)
  draw_rectangle_rec(top, color)
  draw_rectangle_rec(bottom, color)
  draw_rectangle_rec(left, color)
  draw_rectangle_rec(right, color)
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
  submit_shape_triangle(v1, v2, v3, color)
}

///|
/// Draw triangle outline (vertex in counter-clockwise order!).
pub fn draw_triangle_lines(
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  color : Color,
) -> Unit {
  @ffi.rl_begin(@ffi.RlLinesMode)
  submit_color(color)
  @ffi.rl_vertex2f(v1.x, v1.y)
  @ffi.rl_vertex2f(v2.x, v2.y)
  @ffi.rl_vertex2f(v2.x, v2.y)
  @ffi.rl_vertex2f(v3.x, v3.y)
  @ffi.rl_vertex2f(v3.x, v3.y)
  @ffi.rl_vertex2f(v1.x, v1.y)
  @ffi.rl_end()
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
  let sides = if sides < 3 { 3 } else { sides }
  let mut central_angle = rotation * @ffi.DegToRad
  let angle_step = (360.0 : Float) / Float::from_int(sides) * @ffi.DegToRad
  let (texture_id, u0, v0, u1, v1) = get_shape_texture_uvs()

  @ffi.rl_set_texture(texture_id)
  @ffi.rl_begin(@ffi.RlQuadsMode)
  for _ in 0..<sides {
    let next_angle = central_angle + angle_step
    submit_color(color)

    @ffi.rl_tex_coord2f(u0, v0)
    @ffi.rl_vertex2f(center.x, center.y)

    @ffi.rl_tex_coord2f(u0, v1)
    @ffi.rl_vertex2f(
      center.x + cosf(central_angle) * radius,
      center.y + sinf(central_angle) * radius,
    )

    @ffi.rl_tex_coord2f(u1, v0)
    @ffi.rl_vertex2f(
      center.x + cosf(next_angle) * radius,
      center.y + sinf(next_angle) * radius,
    )

    @ffi.rl_tex_coord2f(u1, v1)
    @ffi.rl_vertex2f(
      center.x + cosf(central_angle) * radius,
      center.y + sinf(central_angle) * radius,
    )

    central_angle = next_angle
  }
  @ffi.rl_end()
  @ffi.rl_set_texture(0U)
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
  let sides = if sides < 3 { 3 } else { sides }
  let mut central_angle = rotation * @ffi.DegToRad
  let angle_step = (360.0 : Float) / Float::from_int(sides) * @ffi.DegToRad

  @ffi.rl_begin(@ffi.RlLinesMode)
  for _ in 0..<sides {
    submit_color(color)
    @ffi.rl_vertex2f(
      center.x + cosf(central_angle) * radius,
      center.y + sinf(central_angle) * radius,
    )
    @ffi.rl_vertex2f(
      center.x + cosf(central_angle + angle_step) * radius,
      center.y + sinf(central_angle + angle_step) * radius,
    )
    central_angle = central_angle + angle_step
  }
  @ffi.rl_end()
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
  let sides = if sides < 3 { 3 } else { sides }
  let mut central_angle = rotation * @ffi.DegToRad
  let exterior_angle =
    (360.0 : Float) / Float::from_int(sides) * @ffi.DegToRad
  let inner_radius =
    radius -
    (line_thick * cosf(@ffi.DegToRad * exterior_angle / (2.0 : Float)))
  let (texture_id, u0, v0, u1, v1) = get_shape_texture_uvs()

  @ffi.rl_set_texture(texture_id)
  @ffi.rl_begin(@ffi.RlQuadsMode)
  for _ in 0..<sides {
    let next_angle = central_angle + exterior_angle
    submit_color(color)

    @ffi.rl_tex_coord2f(u0, v1)
    @ffi.rl_vertex2f(
      center.x + cosf(central_angle) * radius,
      center.y + sinf(central_angle) * radius,
    )

    @ffi.rl_tex_coord2f(u0, v0)
    @ffi.rl_vertex2f(
      center.x + cosf(central_angle) * inner_radius,
      center.y + sinf(central_angle) * inner_radius,
    )

    @ffi.rl_tex_coord2f(u1, v1)
    @ffi.rl_vertex2f(
      center.x + cosf(next_angle) * inner_radius,
      center.y + sinf(next_angle) * inner_radius,
    )

    @ffi.rl_tex_coord2f(u1, v0)
    @ffi.rl_vertex2f(
      center.x + cosf(next_angle) * radius,
      center.y + sinf(next_angle) * radius,
    )

    central_angle = next_angle
  }
  @ffi.rl_end()
  @ffi.rl_set_texture(0U)
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
  let radius = if radius <= (0.0 : Float) {
    (0.1 : Float)
  } else {
    radius
  }
  let (start_angle, end_angle, segments) = resolve_circle_segments(
    radius,
    start_angle,
    end_angle,
    segments,
  )
  let step_length = (end_angle - start_angle) / Float::from_int(segments)
  let mut angle = start_angle

  @ffi.rl_begin(@ffi.RlLinesMode)

  submit_color(color)
  let start = circle_point(center, angle, radius)
  @ffi.rl_vertex2f(center.x, center.y)
  @ffi.rl_vertex2f(start.x, start.y)

  for _ in 0..<segments {
    let current = circle_point(center, angle, radius)
    let next_angle = angle + step_length
    let next = circle_point(center, next_angle, radius)

    submit_color(color)
    @ffi.rl_vertex2f(current.x, current.y)
    @ffi.rl_vertex2f(next.x, next.y)

    angle = next_angle
  }

  submit_color(color)
  let end_ = circle_point(center, angle, radius)
  @ffi.rl_vertex2f(center.x, center.y)
  @ffi.rl_vertex2f(end_.x, end_.y)

  @ffi.rl_end()
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
  if points.length() < 2 {
    return
  }

  @ffi.rl_begin(@ffi.RlLinesMode)
  submit_color(color)
  for i in 0..<(points.length() - 1) {
    let point = points[i]
    let next_point = points[i + 1]
    @ffi.rl_vertex2f(point.x, point.y)
    @ffi.rl_vertex2f(next_point.x, next_point.y)
  }
  @ffi.rl_end()
}

///|
/// Draw a triangle fan defined by points (first vertex is the center).
pub fn draw_triangle_fan(points : Array[Vector2], color : Color) -> Unit {
  if points.length() < 3 {
    return
  }

  let (texture_id, u0, v0, u1, v1) = get_shape_texture_uvs()
  @ffi.rl_set_texture(texture_id)
  @ffi.rl_begin(@ffi.RlQuadsMode)
  submit_color(color)

  for i in 1..<(points.length() - 1) {
    let center = points[0]
    let point = points[i]
    let next_point = points[i + 1]

    @ffi.rl_tex_coord2f(u0, v0)
    @ffi.rl_vertex2f(center.x, center.y)

    @ffi.rl_tex_coord2f(u0, v1)
    @ffi.rl_vertex2f(point.x, point.y)

    @ffi.rl_tex_coord2f(u1, v1)
    @ffi.rl_vertex2f(next_point.x, next_point.y)

    @ffi.rl_tex_coord2f(u1, v0)
    @ffi.rl_vertex2f(next_point.x, next_point.y)
  }

  @ffi.rl_end()
  @ffi.rl_set_texture(0U)
}

///|
/// Draw a triangle strip defined by points.
pub fn draw_triangle_strip(points : Array[Vector2], color : Color) -> Unit {
  submit_triangle_strip(points, color)
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
  if points.length() < 2 {
    return
  }

  for i in 0..<(points.length() - 1) {
    draw_spline_segment_linear(points[i], points[i + 1], thick, color)
  }
}

///|
/// Draw spline: B-Spline, minimum 4 points.
pub fn draw_spline_basis(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  if points.length() < 4 {
    return
  }

  let mut dy : Float = 0.0
  let mut dx : Float = 0.0
  let mut size : Float = 0.0
  let mut current_point = { x: 0.0, y: 0.0 }
  let vertices = make_spline_strip_buffer()

  for i in 0..<(points.length() - 3) {
    let p1 = points[i]
    let p2 = points[i + 1]
    let p3 = points[i + 2]
    let p4 = points[i + 3]
    current_point = get_spline_point_basis(p1, p2, p3, p4, 0.0)

    if i == 0 {
      draw_circle_v(current_point, thick / 2.0, color)
    }

    if i > 0 {
      write_spline_strip_pair(vertices, 0, current_point, dx, dy, size)
    }

    for j in 1..<(SplineSegmentDivisions + 1) {
      let t = Float::from_int(j) / Float::from_int(SplineSegmentDivisions)
      let next_point = get_spline_point_basis(p1, p2, p3, p4, t)

      dy = next_point.y - current_point.y
      dx = next_point.x - current_point.x
      size = (0.5 : Float) * thick / sqrtf(dx * dx + dy * dy)

      if i == 0 && j == 1 {
        write_spline_strip_pair(vertices, 0, current_point, dx, dy, size)
      }

      write_spline_strip_pair(vertices, j, next_point, dx, dy, size)
      current_point = next_point
    }

    submit_triangle_strip(vertices, color)
  }

  draw_circle_v(current_point, thick / 2.0, color)
}

///|
/// Draw spline: Catmull-Rom, minimum 4 points.
pub fn draw_spline_catmull_rom(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  if points.length() < 4 {
    return
  }

  let mut dy : Float = 0.0
  let mut dx : Float = 0.0
  let mut size : Float = 0.0
  let mut current_point = points[1]
  let vertices = make_spline_strip_buffer()

  draw_circle_v(current_point, thick / 2.0, color)

  for i in 0..<(points.length() - 3) {
    let p1 = points[i]
    let p2 = points[i + 1]
    let p3 = points[i + 2]
    let p4 = points[i + 3]

    if i > 0 {
      write_spline_strip_pair(vertices, 0, current_point, dx, dy, size)
    }

    for j in 1..<(SplineSegmentDivisions + 1) {
      let t = Float::from_int(j) / Float::from_int(SplineSegmentDivisions)
      let next_point = get_spline_point_catmull_rom(p1, p2, p3, p4, t)

      dy = next_point.y - current_point.y
      dx = next_point.x - current_point.x
      size = (0.5 : Float) * thick / sqrtf(dx * dx + dy * dy)

      if i == 0 && j == 1 {
        write_spline_strip_pair(vertices, 0, current_point, dx, dy, size)
      }

      write_spline_strip_pair(vertices, j, next_point, dx, dy, size)
      current_point = next_point
    }

    submit_triangle_strip(vertices, color)
  }

  draw_circle_v(current_point, thick / 2.0, color)
}

///|
/// Draw spline: Quadratic Bezier, minimum 3 points (1 control point).
pub fn draw_spline_bezier_quadratic(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  for i = 0; i < points.length() - 2; i = i + 2 {
    draw_spline_segment_bezier_quadratic(
      points[i],
      points[i + 1],
      points[i + 2],
      thick,
      color,
    )
  }
}

///|
/// Draw spline: Cubic Bezier, minimum 4 points (2 control points).
pub fn draw_spline_bezier_cubic(
  points : Array[Vector2],
  thick : Float,
  color : Color,
) -> Unit {
  for i = 0; i < points.length() - 3; i = i + 3 {
    draw_spline_segment_bezier_cubic(
      points[i],
      points[i + 1],
      points[i + 2],
      points[i + 3],
      thick,
      color,
    )
  }
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
  draw_line_ex(p1, p2, thick, color)
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
  let step : Float = (1.0 : Float) / Float::from_int(SplineSegmentDivisions)
  let mut current_point = get_spline_point_basis(p1, p2, p3, p4, 0.0)
  let points = make_spline_strip_buffer()

  for i in 0..<(SplineSegmentDivisions + 1) {
    let t : Float = step * Float::from_int(i)
    let next_point = get_spline_point_basis(p1, p2, p3, p4, t)
    let dy = next_point.y - current_point.y
    let dx = next_point.x - current_point.x
    let size = (0.5 : Float) * thick / sqrtf(dx * dx + dy * dy)

    if i == 1 {
      write_spline_strip_pair(points, 0, current_point, dx, dy, size)
    }

    write_spline_strip_pair(points, i, next_point, dx, dy, size)
    current_point = next_point
  }

  submit_triangle_strip(points, color)
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
  let step : Float = (1.0 : Float) / Float::from_int(SplineSegmentDivisions)
  let mut current_point = p1
  let points = make_spline_strip_buffer()

  for i in 0..<(SplineSegmentDivisions + 1) {
    let t : Float = step * Float::from_int(i)
    let next_point = get_spline_point_catmull_rom(p1, p2, p3, p4, t)
    let dy = next_point.y - current_point.y
    let dx = next_point.x - current_point.x
    let size = (0.5 : Float) * thick / sqrtf(dx * dx + dy * dy)

    if i == 1 {
      write_spline_strip_pair(points, 0, current_point, dx, dy, size)
    }

    write_spline_strip_pair(points, i, next_point, dx, dy, size)
    current_point = next_point
  }

  submit_triangle_strip(points, color)
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
  let step : Float = (1.0 : Float) / Float::from_int(SplineSegmentDivisions)
  let mut previous = p1
  let points = make_spline_strip_buffer()

  for i in 1..<(SplineSegmentDivisions + 1) {
    let t : Float = step * Float::from_int(i)
    let current = get_spline_point_bezier_quad(p1, p2, p3, t)
    let dy = current.y - previous.y
    let dx = current.x - previous.x
    let size = (0.5 : Float) * thick / sqrtf(dx * dx + dy * dy)

    if i == 1 {
      write_spline_strip_pair(points, 0, previous, dx, dy, size)
    }

    write_spline_strip_pair(points, i, current, dx, dy, size)
    previous = current
  }

  submit_triangle_strip(points, color)
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
  let step : Float = (1.0 : Float) / Float::from_int(SplineSegmentDivisions)
  let mut previous = p1
  let points = make_spline_strip_buffer()

  for i in 1..<(SplineSegmentDivisions + 1) {
    let t : Float = step * Float::from_int(i)
    let current = get_spline_point_bezier_cubic(p1, p2, p3, p4, t)
    let dy = current.y - previous.y
    let dx = current.x - previous.x
    let size = (0.5 : Float) * thick / sqrtf(dx * dx + dy * dy)

    if i == 1 {
      write_spline_strip_pair(points, 0, previous, dx, dy, size)
    }

    write_spline_strip_pair(points, i, current, dx, dy, size)
    previous = current
  }

  submit_triangle_strip(points, color)
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
