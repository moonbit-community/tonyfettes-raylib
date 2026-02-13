// ============================================================================
// Basic shapes drawing (all wrappers — every function takes Color/Vector2/Rectangle)
// ============================================================================

///|
pub fn draw_pixel(pos_x : Int, pos_y : Int, color : Color) -> Unit {
  @raylib.draw_pixel(pos_x, pos_y, color.to_bytes())
}

///|
pub fn draw_pixel_v(position : Vector2, color : Color) -> Unit {
  @raylib.draw_pixel_v(position.to_bytes(), color.to_bytes())
}

///|
pub fn draw_line(
  start_x : Int,
  start_y : Int,
  end_x : Int,
  end_y : Int,
  color : Color,
) -> Unit {
  @raylib.draw_line(start_x, start_y, end_x, end_y, color.to_bytes())
}

///|
pub fn draw_line_v(
  start_pos : Vector2,
  end_pos : Vector2,
  color : Color,
) -> Unit {
  @raylib.draw_line_v(
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
  @raylib.draw_line_ex(
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
  @raylib.draw_line_bezier(
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
  @raylib.draw_circle(center_x, center_y, radius, color.to_bytes())
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
  @raylib.draw_circle_sector(
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
  @raylib.draw_circle_gradient(
    center_x,
    center_y,
    radius,
    inner.to_bytes(),
    outer.to_bytes(),
  )
}

///|
pub fn draw_circle_v(center : Vector2, radius : Float, color : Color) -> Unit {
  @raylib.draw_circle_v(center.to_bytes(), radius, color.to_bytes())
}

///|
pub fn draw_circle_lines(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Color,
) -> Unit {
  @raylib.draw_circle_lines(center_x, center_y, radius, color.to_bytes())
}

///|
pub fn draw_circle_lines_v(
  center : Vector2,
  radius : Float,
  color : Color,
) -> Unit {
  @raylib.draw_circle_lines_v(center.to_bytes(), radius, color.to_bytes())
}

///|
pub fn draw_ellipse(
  center_x : Int,
  center_y : Int,
  radius_h : Float,
  radius_v : Float,
  color : Color,
) -> Unit {
  @raylib.draw_ellipse(center_x, center_y, radius_h, radius_v, color.to_bytes())
}

///|
pub fn draw_ellipse_lines(
  center_x : Int,
  center_y : Int,
  radius_h : Float,
  radius_v : Float,
  color : Color,
) -> Unit {
  @raylib.draw_ellipse_lines(
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
  @raylib.draw_ring(
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
  @raylib.draw_ring_lines(
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
  @raylib.draw_rectangle(pos_x, pos_y, width, height, color.to_bytes())
}

///|
pub fn draw_rectangle_v(
  position : Vector2,
  size : Vector2,
  color : Color,
) -> Unit {
  @raylib.draw_rectangle_v(
    position.to_bytes(),
    size.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn draw_rectangle_rec(rec : Rectangle, color : Color) -> Unit {
  @raylib.draw_rectangle_rec(rec.to_bytes(), color.to_bytes())
}

///|
pub fn draw_rectangle_pro(
  rec : Rectangle,
  origin : Vector2,
  rotation : Float,
  color : Color,
) -> Unit {
  @raylib.draw_rectangle_pro(
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
  @raylib.draw_rectangle_gradient_v(
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
  @raylib.draw_rectangle_gradient_h(
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
  @raylib.draw_rectangle_gradient_ex(
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
  @raylib.draw_rectangle_lines(pos_x, pos_y, width, height, color.to_bytes())
}

///|
pub fn draw_rectangle_lines_ex(
  rec : Rectangle,
  line_thick : Float,
  color : Color,
) -> Unit {
  @raylib.draw_rectangle_lines_ex(rec.to_bytes(), line_thick, color.to_bytes())
}

///|
pub fn draw_rectangle_rounded(
  rec : Rectangle,
  roundness : Float,
  segments : Int,
  color : Color,
) -> Unit {
  @raylib.draw_rectangle_rounded(
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
  @raylib.draw_rectangle_rounded_lines(
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
  @raylib.draw_rectangle_rounded_lines_ex(
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
  @raylib.draw_triangle(
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
  @raylib.draw_triangle_lines(
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
  @raylib.draw_poly(
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
  @raylib.draw_poly_lines(
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
  @raylib.draw_poly_lines_ex(
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
  @raylib.check_collision_recs(rec1.to_bytes(), rec2.to_bytes())
}

///|
pub fn check_collision_circles(
  center1 : Vector2,
  radius1 : Float,
  center2 : Vector2,
  radius2 : Float,
) -> Bool {
  @raylib.check_collision_circles(
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
  @raylib.check_collision_circle_rec(center.to_bytes(), radius, rec.to_bytes())
}

///|
pub fn check_collision_point_rec(point : Vector2, rec : Rectangle) -> Bool {
  @raylib.check_collision_point_rec(point.to_bytes(), rec.to_bytes())
}

///|
pub fn check_collision_point_circle(
  point : Vector2,
  center : Vector2,
  radius : Float,
) -> Bool {
  @raylib.check_collision_point_circle(
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
  @raylib.check_collision_point_triangle(
    point.to_bytes(),
    p1.to_bytes(),
    p2.to_bytes(),
    p3.to_bytes(),
  )
}

///|
pub fn get_collision_rec(rec1 : Rectangle, rec2 : Rectangle) -> Rectangle {
  Rectangle::from_bytes(
    @raylib.get_collision_rec(rec1.to_bytes(), rec2.to_bytes()),
  )
}
