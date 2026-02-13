// ============================================================================
// Basic shapes drawing
// ============================================================================

///|
#borrow(color)
extern "c" fn draw_pixel_ffi(pos_x : Int, pos_y : Int, color : Bytes) = "moonbit_DrawPixel"

///|
pub fn draw_pixel(pos_x : Int, pos_y : Int, color : Color) -> Unit {
  draw_pixel_ffi(pos_x, pos_y, color.to_bytes())
}

///|
#borrow(position, color)
extern "c" fn draw_pixel_v_ffi(position : Bytes, color : Bytes) = "moonbit_DrawPixelV"

///|
pub fn draw_pixel_v(position : Vector2, color : Color) -> Unit {
  draw_pixel_v_ffi(position.to_bytes(), color.to_bytes())
}

///|
#borrow(color)
extern "c" fn draw_line_ffi(
  start_x : Int,
  start_y : Int,
  end_x : Int,
  end_y : Int,
  color : Bytes,
) = "moonbit_DrawLine"

///|
pub fn draw_line(
  start_x : Int,
  start_y : Int,
  end_x : Int,
  end_y : Int,
  color : Color,
) -> Unit {
  draw_line_ffi(start_x, start_y, end_x, end_y, color.to_bytes())
}

///|
#borrow(start_pos, end_pos, color)
extern "c" fn draw_line_v_ffi(
  start_pos : Bytes,
  end_pos : Bytes,
  color : Bytes,
) = "moonbit_DrawLineV"

///|
pub fn draw_line_v(
  start_pos : Vector2,
  end_pos : Vector2,
  color : Color,
) -> Unit {
  draw_line_v_ffi(start_pos.to_bytes(), end_pos.to_bytes(), color.to_bytes())
}

///|
#borrow(start_pos, end_pos, color)
extern "c" fn draw_line_ex_ffi(
  start_pos : Bytes,
  end_pos : Bytes,
  thick : Float,
  color : Bytes,
) = "moonbit_DrawLineEx"

///|
pub fn draw_line_ex(
  start_pos : Vector2,
  end_pos : Vector2,
  thick : Float,
  color : Color,
) -> Unit {
  draw_line_ex_ffi(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

///|
#borrow(start_pos, end_pos, color)
extern "c" fn draw_line_bezier_ffi(
  start_pos : Bytes,
  end_pos : Bytes,
  thick : Float,
  color : Bytes,
) = "moonbit_DrawLineBezier"

///|
pub fn draw_line_bezier(
  start_pos : Vector2,
  end_pos : Vector2,
  thick : Float,
  color : Color,
) -> Unit {
  draw_line_bezier_ffi(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    thick,
    color.to_bytes(),
  )
}

///|
#borrow(color)
extern "c" fn draw_circle_ffi(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Bytes,
) = "moonbit_DrawCircle"

///|
pub fn draw_circle(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Color,
) -> Unit {
  draw_circle_ffi(center_x, center_y, radius, color.to_bytes())
}

///|
#borrow(center, color)
extern "c" fn draw_circle_sector_ffi(
  center : Bytes,
  radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_DrawCircleSector"

///|
pub fn draw_circle_sector(
  center : Vector2,
  radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Color,
) -> Unit {
  draw_circle_sector_ffi(
    center.to_bytes(),
    radius,
    start_angle,
    end_angle,
    segments,
    color.to_bytes(),
  )
}

///|
#borrow(inner, outer)
extern "c" fn draw_circle_gradient_ffi(
  center_x : Int,
  center_y : Int,
  radius : Float,
  inner : Bytes,
  outer : Bytes,
) = "moonbit_DrawCircleGradient"

///|
pub fn draw_circle_gradient(
  center_x : Int,
  center_y : Int,
  radius : Float,
  inner : Color,
  outer : Color,
) -> Unit {
  draw_circle_gradient_ffi(
    center_x,
    center_y,
    radius,
    inner.to_bytes(),
    outer.to_bytes(),
  )
}

///|
#borrow(center, color)
extern "c" fn draw_circle_v_ffi(center : Bytes, radius : Float, color : Bytes) = "moonbit_DrawCircleV"

///|
pub fn draw_circle_v(center : Vector2, radius : Float, color : Color) -> Unit {
  draw_circle_v_ffi(center.to_bytes(), radius, color.to_bytes())
}

///|
#borrow(color)
extern "c" fn draw_circle_lines_ffi(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Bytes,
) = "moonbit_DrawCircleLines"

///|
pub fn draw_circle_lines(
  center_x : Int,
  center_y : Int,
  radius : Float,
  color : Color,
) -> Unit {
  draw_circle_lines_ffi(center_x, center_y, radius, color.to_bytes())
}

///|
#borrow(center, color)
extern "c" fn draw_circle_lines_v_ffi(
  center : Bytes,
  radius : Float,
  color : Bytes,
) = "moonbit_DrawCircleLinesV"

///|
pub fn draw_circle_lines_v(
  center : Vector2,
  radius : Float,
  color : Color,
) -> Unit {
  draw_circle_lines_v_ffi(center.to_bytes(), radius, color.to_bytes())
}

///|
#borrow(color)
extern "c" fn draw_ellipse_ffi(
  center_x : Int,
  center_y : Int,
  radius_h : Float,
  radius_v : Float,
  color : Bytes,
) = "moonbit_DrawEllipse"

///|
pub fn draw_ellipse(
  center_x : Int,
  center_y : Int,
  radius_h : Float,
  radius_v : Float,
  color : Color,
) -> Unit {
  draw_ellipse_ffi(center_x, center_y, radius_h, radius_v, color.to_bytes())
}

///|
#borrow(color)
extern "c" fn draw_ellipse_lines_ffi(
  center_x : Int,
  center_y : Int,
  radius_h : Float,
  radius_v : Float,
  color : Bytes,
) = "moonbit_DrawEllipseLines"

///|
pub fn draw_ellipse_lines(
  center_x : Int,
  center_y : Int,
  radius_h : Float,
  radius_v : Float,
  color : Color,
) -> Unit {
  draw_ellipse_lines_ffi(
    center_x,
    center_y,
    radius_h,
    radius_v,
    color.to_bytes(),
  )
}

///|
#borrow(center, color)
extern "c" fn draw_ring_ffi(
  center : Bytes,
  inner_radius : Float,
  outer_radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_DrawRing"

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
  draw_ring_ffi(
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
#borrow(center, color)
extern "c" fn draw_ring_lines_ffi(
  center : Bytes,
  inner_radius : Float,
  outer_radius : Float,
  start_angle : Float,
  end_angle : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_DrawRingLines"

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
  draw_ring_lines_ffi(
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
#borrow(color)
extern "c" fn draw_rectangle_ffi(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  color : Bytes,
) = "moonbit_DrawRectangle"

///|
pub fn draw_rectangle(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  color : Color,
) -> Unit {
  draw_rectangle_ffi(pos_x, pos_y, width, height, color.to_bytes())
}

///|
#borrow(position, size, color)
extern "c" fn draw_rectangle_v_ffi(
  position : Bytes,
  size : Bytes,
  color : Bytes,
) = "moonbit_DrawRectangleV"

///|
pub fn draw_rectangle_v(
  position : Vector2,
  size : Vector2,
  color : Color,
) -> Unit {
  draw_rectangle_v_ffi(position.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
#borrow(rec, color)
extern "c" fn draw_rectangle_rec_ffi(rec : Bytes, color : Bytes) = "moonbit_DrawRectangleRec"

///|
pub fn draw_rectangle_rec(rec : Rectangle, color : Color) -> Unit {
  draw_rectangle_rec_ffi(rec.to_bytes(), color.to_bytes())
}

///|
#borrow(rec, origin, color)
extern "c" fn draw_rectangle_pro_ffi(
  rec : Bytes,
  origin : Bytes,
  rotation : Float,
  color : Bytes,
) = "moonbit_DrawRectanglePro"

///|
pub fn draw_rectangle_pro(
  rec : Rectangle,
  origin : Vector2,
  rotation : Float,
  color : Color,
) -> Unit {
  draw_rectangle_pro_ffi(
    rec.to_bytes(),
    origin.to_bytes(),
    rotation,
    color.to_bytes(),
  )
}

///|
#borrow(top, bottom)
extern "c" fn draw_rectangle_gradient_v_ffi(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  top : Bytes,
  bottom : Bytes,
) = "moonbit_DrawRectangleGradientV"

///|
pub fn draw_rectangle_gradient_v(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  top : Color,
  bottom : Color,
) -> Unit {
  draw_rectangle_gradient_v_ffi(
    pos_x,
    pos_y,
    width,
    height,
    top.to_bytes(),
    bottom.to_bytes(),
  )
}

///|
#borrow(left, right)
extern "c" fn draw_rectangle_gradient_h_ffi(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  left : Bytes,
  right : Bytes,
) = "moonbit_DrawRectangleGradientH"

///|
pub fn draw_rectangle_gradient_h(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  left : Color,
  right : Color,
) -> Unit {
  draw_rectangle_gradient_h_ffi(
    pos_x,
    pos_y,
    width,
    height,
    left.to_bytes(),
    right.to_bytes(),
  )
}

///|
#borrow(rec, top_left, bottom_left, top_right, bottom_right)
extern "c" fn draw_rectangle_gradient_ex_ffi(
  rec : Bytes,
  top_left : Bytes,
  bottom_left : Bytes,
  top_right : Bytes,
  bottom_right : Bytes,
) = "moonbit_DrawRectangleGradientEx"

///|
pub fn draw_rectangle_gradient_ex(
  rec : Rectangle,
  top_left : Color,
  bottom_left : Color,
  top_right : Color,
  bottom_right : Color,
) -> Unit {
  draw_rectangle_gradient_ex_ffi(
    rec.to_bytes(),
    top_left.to_bytes(),
    bottom_left.to_bytes(),
    top_right.to_bytes(),
    bottom_right.to_bytes(),
  )
}

///|
#borrow(color)
extern "c" fn draw_rectangle_lines_ffi(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  color : Bytes,
) = "moonbit_DrawRectangleLines"

///|
pub fn draw_rectangle_lines(
  pos_x : Int,
  pos_y : Int,
  width : Int,
  height : Int,
  color : Color,
) -> Unit {
  draw_rectangle_lines_ffi(pos_x, pos_y, width, height, color.to_bytes())
}

///|
#borrow(rec, color)
extern "c" fn draw_rectangle_lines_ex_ffi(
  rec : Bytes,
  line_thick : Float,
  color : Bytes,
) = "moonbit_DrawRectangleLinesEx"

///|
pub fn draw_rectangle_lines_ex(
  rec : Rectangle,
  line_thick : Float,
  color : Color,
) -> Unit {
  draw_rectangle_lines_ex_ffi(rec.to_bytes(), line_thick, color.to_bytes())
}

///|
#borrow(rec, color)
extern "c" fn draw_rectangle_rounded_ffi(
  rec : Bytes,
  roundness : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_DrawRectangleRounded"

///|
pub fn draw_rectangle_rounded(
  rec : Rectangle,
  roundness : Float,
  segments : Int,
  color : Color,
) -> Unit {
  draw_rectangle_rounded_ffi(
    rec.to_bytes(),
    roundness,
    segments,
    color.to_bytes(),
  )
}

///|
#borrow(rec, color)
extern "c" fn draw_rectangle_rounded_lines_ffi(
  rec : Bytes,
  roundness : Float,
  segments : Int,
  color : Bytes,
) = "moonbit_DrawRectangleRoundedLines"

///|
pub fn draw_rectangle_rounded_lines(
  rec : Rectangle,
  roundness : Float,
  segments : Int,
  color : Color,
) -> Unit {
  draw_rectangle_rounded_lines_ffi(
    rec.to_bytes(),
    roundness,
    segments,
    color.to_bytes(),
  )
}

///|
#borrow(rec, color)
extern "c" fn draw_rectangle_rounded_lines_ex_ffi(
  rec : Bytes,
  roundness : Float,
  segments : Int,
  line_thick : Float,
  color : Bytes,
) = "moonbit_DrawRectangleRoundedLinesEx"

///|
pub fn draw_rectangle_rounded_lines_ex(
  rec : Rectangle,
  roundness : Float,
  segments : Int,
  line_thick : Float,
  color : Color,
) -> Unit {
  draw_rectangle_rounded_lines_ex_ffi(
    rec.to_bytes(),
    roundness,
    segments,
    line_thick,
    color.to_bytes(),
  )
}

///|
#borrow(v1, v2, v3, color)
extern "c" fn draw_triangle_ffi(
  v1 : Bytes,
  v2 : Bytes,
  v3 : Bytes,
  color : Bytes,
) = "moonbit_DrawTriangle"

///|
pub fn draw_triangle(
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  color : Color,
) -> Unit {
  draw_triangle_ffi(
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    color.to_bytes(),
  )
}

///|
#borrow(v1, v2, v3, color)
extern "c" fn draw_triangle_lines_ffi(
  v1 : Bytes,
  v2 : Bytes,
  v3 : Bytes,
  color : Bytes,
) = "moonbit_DrawTriangleLines"

///|
pub fn draw_triangle_lines(
  v1 : Vector2,
  v2 : Vector2,
  v3 : Vector2,
  color : Color,
) -> Unit {
  draw_triangle_lines_ffi(
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    color.to_bytes(),
  )
}

///|
#borrow(center, color)
extern "c" fn draw_poly_ffi(
  center : Bytes,
  sides : Int,
  radius : Float,
  rotation : Float,
  color : Bytes,
) = "moonbit_DrawPoly"

///|
pub fn draw_poly(
  center : Vector2,
  sides : Int,
  radius : Float,
  rotation : Float,
  color : Color,
) -> Unit {
  draw_poly_ffi(center.to_bytes(), sides, radius, rotation, color.to_bytes())
}

///|
#borrow(center, color)
extern "c" fn draw_poly_lines_ffi(
  center : Bytes,
  sides : Int,
  radius : Float,
  rotation : Float,
  color : Bytes,
) = "moonbit_DrawPolyLines"

///|
pub fn draw_poly_lines(
  center : Vector2,
  sides : Int,
  radius : Float,
  rotation : Float,
  color : Color,
) -> Unit {
  draw_poly_lines_ffi(
    center.to_bytes(),
    sides,
    radius,
    rotation,
    color.to_bytes(),
  )
}

///|
#borrow(center, color)
extern "c" fn draw_poly_lines_ex_ffi(
  center : Bytes,
  sides : Int,
  radius : Float,
  rotation : Float,
  line_thick : Float,
  color : Bytes,
) = "moonbit_DrawPolyLinesEx"

///|
pub fn draw_poly_lines_ex(
  center : Vector2,
  sides : Int,
  radius : Float,
  rotation : Float,
  line_thick : Float,
  color : Color,
) -> Unit {
  draw_poly_lines_ex_ffi(
    center.to_bytes(),
    sides,
    radius,
    rotation,
    line_thick,
    color.to_bytes(),
  )
}

// ============================================================================
// Collision detection
// ============================================================================

///|
#borrow(rec1, rec2)
extern "c" fn check_collision_recs_ffi(rec1 : Bytes, rec2 : Bytes) -> Bool = "moonbit_CheckCollisionRecs"

///|
pub fn check_collision_recs(rec1 : Rectangle, rec2 : Rectangle) -> Bool {
  check_collision_recs_ffi(rec1.to_bytes(), rec2.to_bytes())
}

///|
#borrow(center1, center2)
extern "c" fn check_collision_circles_ffi(
  center1 : Bytes,
  radius1 : Float,
  center2 : Bytes,
  radius2 : Float,
) -> Bool = "moonbit_CheckCollisionCircles"

///|
pub fn check_collision_circles(
  center1 : Vector2,
  radius1 : Float,
  center2 : Vector2,
  radius2 : Float,
) -> Bool {
  check_collision_circles_ffi(
    center1.to_bytes(),
    radius1,
    center2.to_bytes(),
    radius2,
  )
}

///|
#borrow(center, rec)
extern "c" fn check_collision_circle_rec_ffi(
  center : Bytes,
  radius : Float,
  rec : Bytes,
) -> Bool = "moonbit_CheckCollisionCircleRec"

///|
pub fn check_collision_circle_rec(
  center : Vector2,
  radius : Float,
  rec : Rectangle,
) -> Bool {
  check_collision_circle_rec_ffi(center.to_bytes(), radius, rec.to_bytes())
}

///|
#borrow(point, rec)
extern "c" fn check_collision_point_rec_ffi(point : Bytes, rec : Bytes) -> Bool = "moonbit_CheckCollisionPointRec"

///|
pub fn check_collision_point_rec(point : Vector2, rec : Rectangle) -> Bool {
  check_collision_point_rec_ffi(point.to_bytes(), rec.to_bytes())
}

///|
#borrow(point, center)
extern "c" fn check_collision_point_circle_ffi(
  point : Bytes,
  center : Bytes,
  radius : Float,
) -> Bool = "moonbit_CheckCollisionPointCircle"

///|
pub fn check_collision_point_circle(
  point : Vector2,
  center : Vector2,
  radius : Float,
) -> Bool {
  check_collision_point_circle_ffi(point.to_bytes(), center.to_bytes(), radius)
}

///|
#borrow(point, p1, p2, p3)
extern "c" fn check_collision_point_triangle_ffi(
  point : Bytes,
  p1 : Bytes,
  p2 : Bytes,
  p3 : Bytes,
) -> Bool = "moonbit_CheckCollisionPointTriangle"

///|
pub fn check_collision_point_triangle(
  point : Vector2,
  p1 : Vector2,
  p2 : Vector2,
  p3 : Vector2,
) -> Bool {
  check_collision_point_triangle_ffi(
    point.to_bytes(),
    p1.to_bytes(),
    p2.to_bytes(),
    p3.to_bytes(),
  )
}

///|
#borrow(rec1, rec2)
extern "c" fn get_collision_rec_ffi(rec1 : Bytes, rec2 : Bytes) -> Bytes = "moonbit_GetCollisionRec"

///|
pub fn get_collision_rec(rec1 : Rectangle, rec2 : Rectangle) -> Rectangle {
  Rectangle::from_bytes(get_collision_rec_ffi(rec1.to_bytes(), rec2.to_bytes()))
}
