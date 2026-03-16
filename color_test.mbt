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
