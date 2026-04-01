///|
fn open_hidden_window(width : Int, height : Int) -> Unit {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(width, height, "test")
}

///|
fn begin_hidden_render(width : Int, height : Int) -> @raylib.RenderTexture {
  open_hidden_window(width, height)
  let target = @raylib.RenderTexture::load(width, height)
  target.begin_mode()
  target
}

///|
fn capture_render_target_image(target : @raylib.RenderTexture) -> @raylib.Image {
  @raylib.end_texture_mode()
  let image = @raylib.Image::load_from_texture(target.texture())
  target.unload()
  image
}

///|
fn region_contains_color(
  image : @raylib.Image,
  left : Int,
  top : Int,
  right : Int,
  bottom : Int,
  color : @raylib.Color,
) -> Bool {
  let mut found = false
  for y in top..<(bottom + 1) {
    for x in left..<(right + 1) {
      if image.get_color(x, y) == color {
        found = true
      }
    }
  }
  found
}

///|
test "collision detection - recs" {
  let r1 = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = @raylib.Rectangle::new(5.0, 5.0, 10.0, 10.0)
  let r3 = @raylib.Rectangle::new(20.0, 20.0, 10.0, 10.0)
  assert_true(@raylib.check_collision_recs(r1, r2))
  assert_true(!@raylib.check_collision_recs(r1, r3))
}

///|
test "collision detection - circles" {
  let c1 = @raylib.Vector2::new(0.0, 0.0)
  let c2 = @raylib.Vector2::new(3.0, 0.0)
  let c3 = @raylib.Vector2::new(100.0, 0.0)
  assert_true(@raylib.check_collision_circles(c1, 5.0, c2, 5.0))
  assert_true(!@raylib.check_collision_circles(c1, 5.0, c3, 5.0))
}

///|
test "collision detection - point in rect" {
  let r = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  assert_true(
    @raylib.check_collision_point_rec(@raylib.Vector2::new(5.0, 5.0), r),
  )
  assert_true(
    !@raylib.check_collision_point_rec(@raylib.Vector2::new(15.0, 15.0), r),
  )
}

///|
test "collision detection - point in circle" {
  let center = @raylib.Vector2::new(0.0, 0.0)
  assert_true(
    @raylib.check_collision_point_circle(
      @raylib.Vector2::new(1.0, 1.0),
      center,
      5.0,
    ),
  )
  assert_true(
    !@raylib.check_collision_point_circle(
      @raylib.Vector2::new(10.0, 10.0),
      center,
      5.0,
    ),
  )
}

///|
test "collision detection - circle vs rect" {
  let r = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  assert_true(
    @raylib.check_collision_circle_rec(@raylib.Vector2::new(5.0, 5.0), 3.0, r),
  )
  assert_true(
    !@raylib.check_collision_circle_rec(
      @raylib.Vector2::new(50.0, 50.0),
      3.0,
      r,
    ),
  )
}

///|
test "get_collision_rec returns overlap" {
  let r1 = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = @raylib.Rectangle::new(5.0, 5.0, 10.0, 10.0)
  let overlap = @raylib.get_collision_rec(r1, r2)
  assert_eq(overlap.x, 5.0)
  assert_eq(overlap.y, 5.0)
  assert_eq(overlap.width, 5.0)
  assert_eq(overlap.height, 5.0)
}

///|
test "check_collision_point_triangle - inside and outside" {
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(10.0, 0.0)
  let p3 = @raylib.Vector2::new(5.0, 10.0)
  // Point inside the triangle
  let inside = @raylib.Vector2::new(5.0, 3.0)
  assert_true(@raylib.check_collision_point_triangle(inside, p1, p2, p3))
  // Point outside the triangle
  let outside = @raylib.Vector2::new(20.0, 20.0)
  assert_true(!@raylib.check_collision_point_triangle(outside, p1, p2, p3))
}

///|
test "draw_rectangle_pro rotates rectangle through public rendering" {
  let target = begin_hidden_render(48, 48)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_rectangle_pro(
    @raylib.Rectangle::new(20.0, 20.0, 10.0, 6.0),
    @raylib.Vector2::new(5.0, 3.0),
    90.0,
    @raylib.red,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(18, 28), @raylib.red)
  assert_eq(image.get_color(20, 26), @raylib.red)
  assert_eq(image.get_color(24, 20), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_rectangle_lines_ex clamps oversized thickness through public rendering" {
  let target = begin_hidden_render(32, 32)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_rectangle_lines_ex(
    @raylib.Rectangle::new(10.0, 10.0, 8.0, 6.0),
    10.0,
    @raylib.blue,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(14, 18), @raylib.blue)
  assert_eq(image.get_color(12, 13), @raylib.white)
  assert_eq(image.get_color(12, 23), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_triangle_strip fills connected triangles through public rendering" {
  let target = begin_hidden_render(32, 32)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_triangle_strip(
    [
      @raylib.Vector2::new(8.0, 8.0),
      @raylib.Vector2::new(8.0, 24.0),
      @raylib.Vector2::new(24.0, 8.0),
      @raylib.Vector2::new(24.0, 24.0),
    ],
    @raylib.green,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(12, 12), @raylib.green)
  assert_eq(image.get_color(20, 20), @raylib.green)
  assert_eq(image.get_color(4, 4), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_line_ex renders a thick diagonal through public rendering" {
  let target = begin_hidden_render(32, 32)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_line_ex(
    @raylib.Vector2::new(8.0, 8.0),
    @raylib.Vector2::new(24.0, 24.0),
    6.0,
    @raylib.blue,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(16, 16), @raylib.blue)
  assert_eq(image.get_color(16, 10), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_circle_sector normalizes reversed angles through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_circle_sector(
    @raylib.Vector2::new(20.0, 20.0),
    8.0,
    180.0,
    0.0,
    0,
    @raylib.red,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(23, 16), @raylib.red)
  assert_eq(image.get_color(20, 24), @raylib.white)
  assert_eq(image.get_color(24, 18), @raylib.red)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_ring swaps radii through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_ring(
    @raylib.Vector2::new(20.0, 20.0),
    8.0,
    4.0,
    0.0,
    360.0,
    36,
    @raylib.purple,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(26, 20), @raylib.purple)
  assert_eq(image.get_color(20, 20), @raylib.white)
  assert_eq(image.get_color(29, 20), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_triangle fills triangle through public rendering" {
  let target = begin_hidden_render(32, 32)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_triangle(
    @raylib.Vector2::new(16.0, 8.0),
    @raylib.Vector2::new(8.0, 24.0),
    @raylib.Vector2::new(24.0, 24.0),
    @raylib.maroon,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(16, 12), @raylib.maroon)
  assert_eq(image.get_color(16, 26), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_line_strip renders connected segments through public rendering" {
  let target = begin_hidden_render(36, 36)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_line_strip(
    [
      @raylib.Vector2::new(6.0, 6.0),
      @raylib.Vector2::new(18.0, 6.0),
      @raylib.Vector2::new(18.0, 22.0),
      @raylib.Vector2::new(28.0, 22.0),
    ],
    @raylib.black,
  )
  let image = capture_render_target_image(target)
  // OpenGL line rasterization can shift 1px coverage across drivers.
  assert_true(region_contains_color(image, 19, 12, 21, 14, @raylib.black))
  assert_true(region_contains_color(image, 16, 19, 18, 21, @raylib.black))
  assert_true(region_contains_color(image, 11, 28, 13, 30, @raylib.black))
  assert_eq(image.get_color(12, 12), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_triangle_fan fills fan through public rendering" {
  let target = begin_hidden_render(32, 32)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_triangle_fan(
    [
      @raylib.Vector2::new(16.0, 8.0),
      @raylib.Vector2::new(8.0, 24.0),
      @raylib.Vector2::new(24.0, 24.0),
    ],
    @raylib.orange,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(16, 12), @raylib.orange)
  assert_eq(image.get_color(16, 26), @raylib.white)
  assert_eq(image.get_color(6, 6), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_poly_lines_ex renders thick polygon outline through public rendering" {
  let target = begin_hidden_render(48, 48)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_poly_lines_ex(
    @raylib.Vector2::new(24.0, 24.0),
    6,
    10.0,
    -90.0,
    4.0,
    @raylib.darkgreen,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(24, 14), @raylib.darkgreen)
  assert_eq(image.get_color(24, 24), @raylib.white)
  assert_eq(image.get_color(24, 6), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_spline_linear renders a thick polyline through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_spline_linear(
    [
      @raylib.Vector2::new(8.0, 8.0),
      @raylib.Vector2::new(20.0, 8.0),
      @raylib.Vector2::new(28.0, 20.0),
    ],
    4.0,
    @raylib.blue,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(14, 32), @raylib.blue)
  assert_eq(image.get_color(25, 25), @raylib.blue)
  assert_eq(image.get_color(8, 20), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_spline_basis renders a capped basis spline through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_spline_basis(
    [
      @raylib.Vector2::new(8.0, 24.0),
      @raylib.Vector2::new(12.0, 8.0),
      @raylib.Vector2::new(24.0, 8.0),
      @raylib.Vector2::new(28.0, 24.0),
    ],
    4.0,
    @raylib.darkgreen,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(16, 30), @raylib.darkgreen)
  assert_eq(image.get_color(13, 29), @raylib.darkgreen)
  assert_eq(image.get_color(10, 16), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_spline_segment_basis renders a basis curve through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_spline_segment_basis(
    @raylib.Vector2::new(8.0, 24.0),
    @raylib.Vector2::new(12.0, 8.0),
    @raylib.Vector2::new(24.0, 8.0),
    @raylib.Vector2::new(28.0, 24.0),
    4.0,
    @raylib.green,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(16, 30), @raylib.green)
  assert_eq(image.get_color(10, 16), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_spline_segment_catmull_rom renders a Catmull-Rom curve through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_spline_segment_catmull_rom(
    @raylib.Vector2::new(8.0, 24.0),
    @raylib.Vector2::new(8.0, 8.0),
    @raylib.Vector2::new(24.0, 8.0),
    @raylib.Vector2::new(24.0, 24.0),
    4.0,
    @raylib.maroon,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(16, 33), @raylib.maroon)
  assert_eq(image.get_color(16, 16), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_spline_catmull_rom renders a capped curve through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_spline_catmull_rom(
    [
      @raylib.Vector2::new(8.0, 24.0),
      @raylib.Vector2::new(8.0, 8.0),
      @raylib.Vector2::new(24.0, 8.0),
      @raylib.Vector2::new(24.0, 24.0),
    ],
    4.0,
    @raylib.orange,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(16, 33), @raylib.orange)
  assert_eq(image.get_color(8, 31), @raylib.orange)
  assert_eq(image.get_color(16, 16), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_spline_bezier_quadratic renders a curved strip through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_spline_bezier_quadratic(
    [
      @raylib.Vector2::new(8.0, 24.0),
      @raylib.Vector2::new(20.0, 8.0),
      @raylib.Vector2::new(32.0, 24.0),
    ],
    4.0,
    @raylib.red,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(20, 22), @raylib.red)
  assert_eq(image.get_color(20, 10), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_spline_bezier_cubic renders a cubic curve through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_spline_bezier_cubic(
    [
      @raylib.Vector2::new(8.0, 24.0),
      @raylib.Vector2::new(8.0, 8.0),
      @raylib.Vector2::new(24.0, 8.0),
      @raylib.Vector2::new(24.0, 24.0),
    ],
    4.0,
    @raylib.purple,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(14, 27), @raylib.purple)
  assert_eq(image.get_color(20, 27), @raylib.purple)
  assert_eq(image.get_color(16, 16), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_pixel renders a single pixel through public rendering" {
  let target = begin_hidden_render(8, 8)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_pixel(3, 4, @raylib.red)
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(3, 3), @raylib.red)
  assert_eq(image.get_color(2, 3), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_line renders a line through public rendering" {
  let target = begin_hidden_render(8, 8)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_line(1, 2, 6, 2, @raylib.black)
  let image = capture_render_target_image(target)
  assert_true(region_contains_color(image, 3, 4, 5, 6, @raylib.black))
  assert_eq(image.get_color(4, 1), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_line_bezier renders a curved thick line through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_line_bezier(
    @raylib.Vector2::new(8.0, 28.0),
    @raylib.Vector2::new(32.0, 8.0),
    4.0,
    @raylib.blue,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(20, 20), @raylib.blue)
  assert_eq(image.get_color(4, 4), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_circle_gradient renders inner and outer colors through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_circle_gradient(20, 20, 8.0, @raylib.red, @raylib.blue)
  let image = capture_render_target_image(target)
  let center = image.get_color(20, 19)
  let edge = image.get_color(27, 19)
  assert_true(center != @raylib.white)
  assert_true(center.r > center.b)
  assert_true(edge != @raylib.white)
  assert_true(edge.b > edge.r)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_circle_lines renders circle outline through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_circle_lines(20, 20, 8.0, @raylib.green)
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(27, 19), @raylib.green)
  assert_eq(image.get_color(20, 19), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_ellipse renders a filled ellipse through public rendering" {
  let target = begin_hidden_render(48, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_ellipse(24, 20, 12.0, 8.0, @raylib.orange)
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(24, 19), @raylib.orange)
  assert_eq(image.get_color(24, 31), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_ellipse_lines renders ellipse outline through public rendering" {
  let target = begin_hidden_render(48, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_ellipse_lines(24, 20, 12.0, 8.0, @raylib.purple)
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(35, 19), @raylib.purple)
  assert_eq(image.get_color(24, 19), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_rectangle_rounded renders rounded corners through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_rectangle_rounded(
    @raylib.Rectangle::new(8.0, 8.0, 24.0, 16.0),
    0.5,
    0,
    @raylib.maroon,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(20, 23), @raylib.maroon)
  assert_eq(image.get_color(8, 31), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_rectangle_rounded_lines_ex renders rounded outline through public rendering" {
  let target = begin_hidden_render(40, 40)
  @raylib.clear_background(@raylib.white)
  @raylib.draw_rectangle_rounded_lines_ex(
    @raylib.Rectangle::new(8.0, 8.0, 24.0, 16.0),
    0.5,
    0,
    3.0,
    @raylib.darkgreen,
  )
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(20, 32), @raylib.darkgreen)
  assert_eq(image.get_color(20, 23), @raylib.white)
  image.unload()
  @raylib.close_window()
}

///|
test "draw_triangle_strip_3d renders a strip through public rendering" {
  let target = begin_hidden_render(64, 64)
  @raylib.clear_background(@raylib.white)
  let camera = @raylib.Camera3D::new(
    @raylib.Vector3::new(0.0, 0.0, 4.0),
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    60.0,
    @raylib.CameraPerspective,
  )
  @raylib.begin_mode_3d(camera)
  @raylib.draw_triangle_strip_3d(
    [
      @raylib.Vector3::new(-1.0, 1.0, 0.0),
      @raylib.Vector3::new(-1.0, -1.0, 0.0),
      @raylib.Vector3::new(1.0, 1.0, 0.0),
      @raylib.Vector3::new(1.0, -1.0, 0.0),
    ],
    @raylib.red,
  )
  @raylib.end_mode_3d()
  let image = capture_render_target_image(target)
  assert_eq(image.get_color(32, 32), @raylib.red)
  assert_eq(image.get_color(4, 4), @raylib.white)
  image.unload()
  @raylib.close_window()
}
