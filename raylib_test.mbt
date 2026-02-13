// Tests for raylib FFI bindings - exercises type serialization and
// C functions that don't require a window context.

///|
test "Color round-trip through Bytes" {
  let c = Color::new(255, 128, 64, 200)
  let bytes = c.to_bytes()
  let c2 = Color::from_bytes(bytes)
  assert_eq(c, c2)
}

///|
test "Vector2 round-trip through Bytes" {
  let v = Vector2::new(3.14, -2.71)
  let bytes = v.to_bytes()
  let v2 = Vector2::from_bytes(bytes)
  assert_eq(v, v2)
}

///|
test "Vector3 round-trip through Bytes" {
  let v = Vector3::new(1.0, 2.0, 3.0)
  let bytes = v.to_bytes()
  let v2 = Vector3::from_bytes(bytes)
  assert_eq(v, v2)
}

///|
test "Vector4 round-trip through Bytes" {
  let v = Vector4::new(1.0, 2.0, 3.0, 4.0)
  let bytes = v.to_bytes()
  let v2 = Vector4::from_bytes(bytes)
  assert_eq(v, v2)
}

///|
test "Rectangle round-trip through Bytes" {
  let r = Rectangle::new(10.0, 20.0, 100.0, 50.0)
  let bytes = r.to_bytes()
  let r2 = Rectangle::from_bytes(bytes)
  assert_eq(r, r2)
}

///|
test "Camera2D round-trip through Bytes" {
  let cam = Camera2D::new(
    Vector2::new(400.0, 300.0),
    Vector2::new(0.0, 0.0),
    0.0,
    1.0,
  )
  let bytes = cam.to_bytes()
  let cam2 = Camera2D::from_bytes(bytes)
  assert_eq(cam, cam2)
}

///|
test "Camera3D round-trip through Bytes" {
  let cam = Camera3D::new(
    Vector3::new(0.0, 10.0, 10.0),
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(0.0, 1.0, 0.0),
    45.0,
    0,
  )
  let bytes = cam.to_bytes()
  let cam2 = Camera3D::from_bytes(bytes)
  assert_eq(cam, cam2)
}

///|
test "Ray round-trip through Bytes" {
  let r = Ray::new(Vector3::new(0.0, 0.0, 0.0), Vector3::new(1.0, 0.0, 0.0))
  let bytes = r.to_bytes()
  let r2 = Ray::from_bytes(bytes)
  assert_eq(r, r2)
}

///|
test "BoundingBox round-trip through Bytes" {
  let bb = BoundingBox::new(
    Vector3::new(-1.0, -1.0, -1.0),
    Vector3::new(1.0, 1.0, 1.0),
  )
  let bytes = bb.to_bytes()
  let bb2 = BoundingBox::from_bytes(bytes)
  assert_eq(bb, bb2)
}

///|
test "Color constants are valid" {
  assert_eq(raywhite.a, b'\xFF')
  assert_eq(blank.a, b'\x00')
  assert_eq(red.r, b'\xE6')
}

///|
test "fade calls C and returns valid Color" {
  let c = fade(red, 0.5)
  assert_eq(c.r, red.r)
  assert_eq(c.g, red.g)
  assert_eq(c.b, red.b)
  // Alpha should be approximately half
  assert_true(c.a.to_int() > 100 && c.a.to_int() < 140)
}

///|
test "color_to_int and get_color round-trip" {
  let hex = color_to_int(red)
  let c = get_color(hex)
  assert_eq(c, red)
}

///|
test "color_from_hsv returns valid Color" {
  let c = color_from_hsv(0.0, 1.0, 1.0) // Pure red in HSV
  assert_eq(c.r, b'\xFF')
  assert_eq(c.a, b'\xFF')
}

///|
test "color_lerp blends between two colors" {
  let c = color_lerp(black, white, 0.5)
  // Should be roughly middle gray
  assert_true(c.r.to_int() > 120 && c.r.to_int() < 136)
}

///|
test "color_is_equal works" {
  assert_true(color_is_equal(red, red))
  assert_true(not(color_is_equal(red, blue)))
}

///|
test "color_brightness adjusts brightness" {
  let brighter = color_brightness(gray, 0.5)
  assert_true(brighter.r.to_int() > gray.r.to_int())
}

///|
test "color_tint applies tint" {
  let tinted = color_tint(white, red)
  assert_eq(tinted.r, red.r)
}

///|
test "GenImageColor creates image resource (no window needed)" {
  let img = gen_image_color(16, 16, red)
  unload_image(img)
}

///|
test "GenImageChecked creates image resource (no window needed)" {
  let img = gen_image_checked(16, 16, 4, 4, red, blue)
  unload_image(img)
}

///|
test "collision detection - recs" {
  let r1 = Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = Rectangle::new(5.0, 5.0, 10.0, 10.0)
  let r3 = Rectangle::new(20.0, 20.0, 10.0, 10.0)
  assert_true(check_collision_recs(r1, r2))
  assert_true(not(check_collision_recs(r1, r3)))
}

///|
test "collision detection - circles" {
  let c1 = Vector2::new(0.0, 0.0)
  let c2 = Vector2::new(3.0, 0.0)
  let c3 = Vector2::new(100.0, 0.0)
  assert_true(check_collision_circles(c1, 5.0, c2, 5.0))
  assert_true(not(check_collision_circles(c1, 5.0, c3, 5.0)))
}

///|
test "collision detection - point in rect" {
  let r = Rectangle::new(0.0, 0.0, 10.0, 10.0)
  assert_true(check_collision_point_rec(Vector2::new(5.0, 5.0), r))
  assert_true(not(check_collision_point_rec(Vector2::new(15.0, 15.0), r)))
}

///|
test "collision detection - point in circle" {
  let center = Vector2::new(0.0, 0.0)
  assert_true(check_collision_point_circle(Vector2::new(1.0, 1.0), center, 5.0))
  assert_true(
    not(check_collision_point_circle(Vector2::new(10.0, 10.0), center, 5.0)),
  )
}

///|
test "collision detection - circle vs rect" {
  let r = Rectangle::new(0.0, 0.0, 10.0, 10.0)
  assert_true(check_collision_circle_rec(Vector2::new(5.0, 5.0), 3.0, r))
  assert_true(not(check_collision_circle_rec(Vector2::new(50.0, 50.0), 3.0, r)))
}

///|
test "get_collision_rec returns overlap" {
  let r1 = Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = Rectangle::new(5.0, 5.0, 10.0, 10.0)
  let overlap = get_collision_rec(r1, r2)
  assert_eq(overlap.x, 5.0)
  assert_eq(overlap.y, 5.0)
  assert_eq(overlap.width, 5.0)
  assert_eq(overlap.height, 5.0)
}

///|
test "measure_text returns non-negative width" {
  // Without a window context, default font is not loaded, so width may be 0
  let w = measure_text("Hello", 20)
  assert_true(w >= 0)
}

///|
test "get_random_value returns value in range" {
  let v = get_random_value(10, 20)
  assert_true(v >= 10 && v <= 20)
}
