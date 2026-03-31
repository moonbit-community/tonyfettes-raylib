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
