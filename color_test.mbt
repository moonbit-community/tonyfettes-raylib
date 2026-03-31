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
test "fade clamps alpha and sets alpha channel" {
  let c = @raylib.Color::new(200, 100, 50, 255)
  // Normal alpha
  let faded = @raylib.fade(c, 0.5)
  assert_eq(faded.r, c.r)
  assert_eq(faded.g, c.g)
  assert_eq(faded.b, c.b)
  assert_eq(faded.a, b'\x7F') // floor(255*0.5) = 127
  // Clamp below zero
  let faded_low = @raylib.fade(c, -1.0)
  assert_eq(faded_low.a, b'\x00')
  // Clamp above one
  let faded_high = @raylib.fade(c, 2.0)
  assert_eq(faded_high.a, b'\xFF')
}

///|
test "color_alpha is identical to fade" {
  let c = @raylib.Color::new(100, 150, 200, 255)
  assert_eq(@raylib.color_alpha(c, 0.3), @raylib.fade(c, 0.3))
}

///|
test "color_to_int packs RGBA" {
  let c = @raylib.Color::new(0x12, 0x34, 0x56, 0x78)
  let i = @raylib.color_to_int(c)
  // 0x12345678
  assert_eq(i, 0x12345678)
}

///|
test "get_color unpacks int to RGBA" {
  let c = @raylib.get_color(0x12345678)
  assert_eq(c, @raylib.Color::new(0x12, 0x34, 0x56, 0x78))
}

///|
test "color_to_int and get_color are inverses" {
  let c = @raylib.Color::new(123, 45, 67, 89)
  assert_eq(@raylib.get_color(@raylib.color_to_int(c)), c)
}

///|
test "color_from_hsv pure red" {
  let c = @raylib.color_from_hsv(0.0, 1.0, 1.0)
  assert_eq(c.r, b'\xFF')
  assert_eq(c.g, b'\x00')
  assert_eq(c.b, b'\x00')
  assert_eq(c.a, b'\xFF')
}

///|
test "color_from_hsv pure green" {
  let c = @raylib.color_from_hsv(120.0, 1.0, 1.0)
  assert_eq(c.r, b'\x00')
  assert_eq(c.g, b'\xFF')
  assert_eq(c.b, b'\x00')
}

///|
test "color_from_hsv pure blue" {
  let c = @raylib.color_from_hsv(240.0, 1.0, 1.0)
  assert_eq(c.r, b'\x00')
  assert_eq(c.g, b'\x00')
  assert_eq(c.b, b'\xFF')
}

///|
test "color_from_hsv zero saturation gives gray" {
  let c = @raylib.color_from_hsv(0.0, 0.0, 0.5)
  assert_eq(c.r, c.g)
  assert_eq(c.g, c.b)
  // 0.5 * 255 = 127
  assert_eq(c.r, b'\x7F')
}

///|
test "color_tint multiplies channels" {
  let c = @raylib.Color::new(200, 100, 50, 255)
  let t = @raylib.Color::new(255, 128, 0, 255)
  let result = @raylib.color_tint(c, t)
  assert_eq(result.r, (200 * 255 / 255).to_byte())
  assert_eq(result.g, (100 * 128 / 255).to_byte())
  assert_eq(result.b, (50 * 0 / 255).to_byte())
  assert_eq(result.a, (255 * 255 / 255).to_byte())
}

///|
test "color_tint with white is identity" {
  let c = @raylib.Color::new(123, 45, 67, 89)
  assert_eq(@raylib.color_tint(c, @raylib.white), c)
}

///|
test "color_brightness darkens with negative factor" {
  let c = @raylib.Color::new(200, 100, 50, 128)
  let dark = @raylib.color_brightness(c, -0.5)
  // factor < 0: multiply by (1 + factor) = 0.5
  assert_eq(dark.r, (100).to_byte()) // 200 * 0.5 = 100
  assert_eq(dark.g, (50).to_byte()) // 100 * 0.5 = 50
  assert_eq(dark.b, (25).to_byte()) // 50 * 0.5 = 25
  assert_eq(dark.a, c.a) // alpha unchanged
}

///|
test "color_brightness lightens with positive factor" {
  let c = @raylib.Color::new(100, 100, 100, 255)
  let light = @raylib.color_brightness(c, 1.0)
  // factor = 1: (255 - c) * 1 + c = 255
  assert_eq(light.r, b'\xFF')
  assert_eq(light.g, b'\xFF')
  assert_eq(light.b, b'\xFF')
}

///|
test "color_brightness clamps factor" {
  let c = @raylib.Color::new(128, 128, 128, 255)
  let result_lo = @raylib.color_brightness(c, -5.0)
  assert_eq(result_lo.r, b'\x00') // clamped to -1.0, multiply by 0
  let result_hi = @raylib.color_brightness(c, 5.0)
  assert_eq(result_hi.r, b'\xFF') // clamped to 1.0, full brightness
}

///|
test "color_lerp at endpoints" {
  let c1 = @raylib.Color::new(0, 0, 0, 0)
  let c2 = @raylib.Color::new(255, 255, 255, 255)
  assert_eq(@raylib.color_lerp(c1, c2, 0.0), c1)
  assert_eq(@raylib.color_lerp(c1, c2, 1.0), c2)
}

///|
test "color_lerp at midpoint" {
  let c1 = @raylib.Color::new(0, 0, 0, 0)
  let c2 = @raylib.Color::new(200, 100, 50, 254)
  let mid = @raylib.color_lerp(c1, c2, 0.5)
  assert_eq(mid.r, (100).to_byte())
  assert_eq(mid.g, (50).to_byte())
  assert_eq(mid.b, (25).to_byte())
  assert_eq(mid.a, (127).to_byte())
}

///|
test "color_lerp clamps factor" {
  let c1 = @raylib.Color::new(100, 100, 100, 100)
  let c2 = @raylib.Color::new(200, 200, 200, 200)
  assert_eq(@raylib.color_lerp(c1, c2, -1.0), c1)
  assert_eq(@raylib.color_lerp(c1, c2, 2.0), c2)
}

///|
test "color_is_equal" {
  let c1 = @raylib.Color::new(10, 20, 30, 40)
  let c2 = @raylib.Color::new(10, 20, 30, 40)
  let c3 = @raylib.Color::new(10, 20, 30, 41)
  assert_true(@raylib.color_is_equal(c1, c2))
  assert_false(@raylib.color_is_equal(c1, c3))
}

///|
test "color_normalize" {
  let c = @raylib.Color::new(255, 0, 128, 255)
  let v = @raylib.color_normalize(c)
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 0.0)
  assert_true((v.z - 128.0 / 255.0).abs() < 0.001)
  assert_eq(v.w, 1.0)
}

///|
test "color_from_normalized" {
  let v = @raylib.Vector4::new(1.0, 0.0, 0.5, 1.0)
  let c = @raylib.color_from_normalized(v)
  assert_eq(c.r, b'\xFF')
  assert_eq(c.g, b'\x00')
  assert_eq(c.b, (127).to_byte()) // floor(0.5 * 255) = 127
  assert_eq(c.a, b'\xFF')
}

///|
test "color_normalize and color_from_normalized round-trip" {
  let c = @raylib.Color::new(200, 100, 50, 180)
  let normalized = @raylib.color_normalize(c)
  let restored = @raylib.color_from_normalized(normalized)
  // May lose 1 bit due to float precision
  assert_true((c.r.to_int() - restored.r.to_int()).abs() <= 1)
  assert_true((c.g.to_int() - restored.g.to_int()).abs() <= 1)
  assert_true((c.b.to_int() - restored.b.to_int()).abs() <= 1)
  assert_true((c.a.to_int() - restored.a.to_int()).abs() <= 1)
}

///|
test "color_to_hsv pure red" {
  let c = @raylib.Color::new(255, 0, 0, 255)
  let hsv = @raylib.color_to_hsv(c)
  assert_true(hsv.x.abs() < 0.001) // hue ~ 0
  assert_true((hsv.y - 1.0).abs() < 0.001) // saturation ~ 1
  assert_true((hsv.z - 1.0).abs() < 0.001) // value ~ 1
}

///|
test "color_to_hsv pure green" {
  let c = @raylib.Color::new(0, 255, 0, 255)
  let hsv = @raylib.color_to_hsv(c)
  assert_true((hsv.x - 120.0).abs() < 0.001)
  assert_true((hsv.y - 1.0).abs() < 0.001)
  assert_true((hsv.z - 1.0).abs() < 0.001)
}

///|
test "color_to_hsv gray has zero saturation" {
  let c = @raylib.Color::new(128, 128, 128, 255)
  let hsv = @raylib.color_to_hsv(c)
  assert_true(hsv.y.abs() < 0.001) // saturation ~ 0
}

///|
test "color_to_hsv and color_from_hsv round-trip" {
  let original = @raylib.Color::new(200, 100, 50, 255)
  let hsv = @raylib.color_to_hsv(original)
  let restored = @raylib.color_from_hsv(hsv.x, hsv.y, hsv.z)
  // Allow 1 unit rounding error per channel
  assert_true((original.r.to_int() - restored.r.to_int()).abs() <= 1)
  assert_true((original.g.to_int() - restored.g.to_int()).abs() <= 1)
  assert_true((original.b.to_int() - restored.b.to_int()).abs() <= 1)
}

///|
test "color_contrast zero contrast is identity" {
  let c = @raylib.Color::new(100, 150, 200, 255)
  let result = @raylib.color_contrast(c, 0.0)
  // contrast=0 => factor=(1+0)^2=1, (c/255 - 0.5)*1 + 0.5 = c/255
  assert_eq(result, c)
}

///|
test "color_contrast positive increases contrast" {
  let c = @raylib.Color::new(200, 50, 128, 255)
  let high = @raylib.color_contrast(c, 0.5)
  // Higher contrast pushes values away from midpoint (128)
  assert_true(high.r.to_int() > c.r.to_int()) // above mid, pushed higher
  assert_true(high.b.to_int() == c.b.to_int()) // at mid, stays same
}

///|
test "color_contrast clamps result to 0..255" {
  let c = @raylib.Color::new(250, 5, 128, 255)
  let max_contrast = @raylib.color_contrast(c, 1.0)
  // With max contrast, extremes clip
  assert_eq(max_contrast.r, b'\xFF')
  assert_eq(max_contrast.g, b'\x00')
}

///|
test "color_contrast preserves alpha" {
  let c = @raylib.Color::new(100, 150, 200, 42)
  let result = @raylib.color_contrast(c, 0.5)
  assert_eq(result.a, c.a)
}

///|
test "color_alpha_blend fully opaque src replaces dst" {
  let dst = @raylib.Color::new(100, 100, 100, 255)
  let src = @raylib.Color::new(200, 50, 30, 255)
  let tint = @raylib.white
  let result = @raylib.color_alpha_blend(dst, src, tint)
  assert_eq(result.r, src.r)
  assert_eq(result.g, src.g)
  assert_eq(result.b, src.b)
}

///|
test "color_alpha_blend fully transparent src returns dst" {
  let dst = @raylib.Color::new(100, 100, 100, 255)
  let src = @raylib.Color::new(200, 50, 30, 0)
  let tint = @raylib.white
  let result = @raylib.color_alpha_blend(dst, src, tint)
  assert_eq(result, dst)
}

///|
test "color_alpha_blend partial alpha blends" {
  let dst = @raylib.Color::new(0, 0, 0, 255)
  let src = @raylib.Color::new(255, 255, 255, 128)
  let tint = @raylib.white
  let result = @raylib.color_alpha_blend(dst, src, tint)
  // With partial alpha, result should be between dst and src
  assert_true(result.r.to_int() > 0)
  assert_true(result.r.to_int() < 255)
}

///|
test "color_alpha_blend tint affects source" {
  let dst = @raylib.Color::new(0, 0, 0, 255)
  let src = @raylib.Color::new(255, 255, 255, 255)
  let tint = @raylib.Color::new(128, 128, 128, 255)
  let result = @raylib.color_alpha_blend(dst, src, tint)
  // Tinted source should be darker than full white
  assert_true(result.r.to_int() < 255)
  assert_true(result.r.to_int() > 0)
}

///|
test "color_to_hsv pure blue" {
  let c = @raylib.Color::new(0, 0, 255, 255)
  let hsv = @raylib.color_to_hsv(c)
  assert_true((hsv.x - 240.0).abs() < 0.001) // hue ~ 240
  assert_true((hsv.y - 1.0).abs() < 0.001) // saturation ~ 1
  assert_true((hsv.z - 1.0).abs() < 0.001) // value ~ 1
}

///|
test "color_to_hsv black" {
  let c = @raylib.Color::new(0, 0, 0, 255)
  let hsv = @raylib.color_to_hsv(c)
  assert_true(hsv.z.abs() < 0.001) // value ~ 0
}

///|
test "color_from_hsv yellow" {
  let c = @raylib.color_from_hsv(60.0, 1.0, 1.0)
  assert_eq(c.r, b'\xFF')
  assert_eq(c.g, b'\xFF')
  assert_eq(c.b, b'\x00')
}

///|
test "color_from_hsv cyan" {
  let c = @raylib.color_from_hsv(180.0, 1.0, 1.0)
  assert_eq(c.r, b'\x00')
  assert_eq(c.g, b'\xFF')
  assert_eq(c.b, b'\xFF')
}

///|
test "color_from_hsv magenta" {
  let c = @raylib.color_from_hsv(300.0, 1.0, 1.0)
  assert_eq(c.r, b'\xFF')
  assert_eq(c.g, b'\x00')
  assert_eq(c.b, b'\xFF')
}
