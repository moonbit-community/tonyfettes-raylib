///|
test "Color round-trip through Bytes" {
  let c = Color::new(255, 128, 64, 200)
  let bytes = c.to_bytes()
  let c2 = Color::from_bytes(bytes)
  assert_eq(c, c2)
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
test "color_alpha adjusts alpha channel" {
  let c = Color::new(230, 41, 55, 255)
  let result = color_alpha(c, 0.5)
  // Alpha should be roughly half of 255 (around 127-128)
  assert_true(result.a.to_int() >= 127 && result.a.to_int() <= 128)
  // RGB channels should remain unchanged
  assert_eq(result.r, c.r)
  assert_eq(result.g, c.g)
  assert_eq(result.b, c.b)
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
