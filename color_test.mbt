///|
test "Color round-trip through Bytes" {
  let c = @raylib.Color::new(255, 128, 64, 200)
  let bytes = c.to_bytes()
  let c2 = @raylib.Color::from_bytes(bytes)
  assert_eq(c, c2)
}

///|
test "Color constants are valid" {
  assert_eq(@raylib.raywhite.a, b'\xFF')
  assert_eq(@raylib.blank.a, b'\x00')
  assert_eq(@raylib.red.r, b'\xE6')
}

///|
test "fade calls C and returns valid Color" {
  let c = @raylib.fade(@raylib.red, 0.5)
  assert_eq(c.r, @raylib.red.r)
  assert_eq(c.g, @raylib.red.g)
  assert_eq(c.b, @raylib.red.b)
  // Alpha should be approximately half
  assert_true(c.a.to_int() > 100 && c.a.to_int() < 140)
}

///|
test "color_alpha adjusts alpha channel" {
  let c = @raylib.Color::new(230, 41, 55, 255)
  let result = @raylib.color_alpha(c, 0.5)
  // Alpha should be roughly half of 255 (around 127-128)
  assert_true(result.a.to_int() >= 127 && result.a.to_int() <= 128)
  // RGB channels should remain unchanged
  assert_eq(result.r, c.r)
  assert_eq(result.g, c.g)
  assert_eq(result.b, c.b)
}

///|
test "color_to_int and get_color round-trip" {
  let hex = @raylib.color_to_int(@raylib.red)
  let c = @raylib.get_color(hex)
  assert_eq(c, @raylib.red)
}

///|
test "color_from_hsv returns valid Color" {
  let c = @raylib.color_from_hsv(0.0, 1.0, 1.0) // Pure red in HSV
  assert_eq(c.r, b'\xFF')
  assert_eq(c.a, b'\xFF')
}

///|
test "color_lerp blends between two colors" {
  let c = @raylib.color_lerp(@raylib.black, @raylib.white, 0.5)
  // Should be roughly middle gray
  assert_true(c.r.to_int() > 120 && c.r.to_int() < 136)
}

///|
test "color_is_equal works" {
  assert_true(@raylib.color_is_equal(@raylib.red, @raylib.red))
  assert_true(not(@raylib.color_is_equal(@raylib.red, @raylib.blue)))
}

///|
test "color_brightness adjusts brightness" {
  let brighter = @raylib.color_brightness(@raylib.gray, 0.5)
  assert_true(brighter.r.to_int() > @raylib.gray.r.to_int())
}

///|
test "color_tint applies tint" {
  let tinted = @raylib.color_tint(@raylib.white, @raylib.red)
  assert_eq(tinted.r, @raylib.red.r)
}

///|
test "color_normalize returns normalized RGBA" {
  let n = @raylib.color_normalize(@raylib.red)
  // red = (230, 41, 55, 255)
  assert_true((n.x - 230.0 / 255.0).abs() < 0.01)
  assert_true((n.y - 41.0 / 255.0).abs() < 0.01)
  assert_true((n.z - 55.0 / 255.0).abs() < 0.01)
  assert_true((n.w - 1.0).abs() < 0.01)
}

///|
test "color_from_normalized round-trips with color_normalize" {
  let c = @raylib.Color::new(100, 150, 200, 255)
  let normalized = @raylib.color_normalize(c)
  let back = @raylib.color_from_normalized(normalized)
  assert_eq(back, c)
}

///|
test "color_to_hsv and color_from_hsv round-trip" {
  let c = @raylib.Color::new(200, 100, 50, 255)
  let hsv = @raylib.color_to_hsv(c)
  let back = @raylib.color_from_hsv(hsv.x, hsv.y, hsv.z)
  assert_true((c.r.to_int() - back.r.to_int()).abs() <= 1)
  assert_true((c.g.to_int() - back.g.to_int()).abs() <= 1)
  assert_true((c.b.to_int() - back.b.to_int()).abs() <= 1)
}

///|
test "color_contrast adjusts contrast" {
  let c = @raylib.Color::new(128, 128, 128, 255)
  let high = @raylib.color_contrast(c, 1.0)
  let low = @raylib.color_contrast(c, -1.0)
  let _ = high
  let _ = low
}

///|
test "color_alpha_blend blends src over dst" {
  let dst = @raylib.Color::new(255, 0, 0, 255)
  let src = @raylib.Color::new(0, 0, 255, 128)
  let tint = @raylib.white
  let result = @raylib.color_alpha_blend(dst, src, tint)
  assert_true(result.r.to_int() > 0)
  assert_true(result.b.to_int() > 0)
  assert_true(result.a.to_int() == 255)
}
