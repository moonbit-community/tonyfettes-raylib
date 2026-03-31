///|
test "get_color extracts RGBA from hex" {
  let c = @raygui.get_color(0xFF8040C0)
  assert_eq(c.r, b'\xFF')
  assert_eq(c.g, b'\x80')
  assert_eq(c.b, b'\x40')
  assert_eq(c.a, b'\xC0')
}

///|
test "color_to_int packs RGBA into hex" {
  let c = @raylib.Color::new(255, 128, 64, 192)
  let hex = @raygui.color_to_int(c)
  assert_eq(hex, 0xFF8040C0)
}

///|
test "get_color and color_to_int round-trip" {
  let original = 0x12345678
  let c = @raygui.get_color(original)
  let result = @raygui.color_to_int(c)
  assert_eq(result, original)
}

///|
test "gui_fade applies alpha multiplier" {
  let c = @raylib.Color::new(100, 150, 200, 255)
  let faded = @raygui.gui_fade(c, 0.5)
  assert_eq(faded.r, b'\x64')
  assert_eq(faded.g, b'\x96')
  assert_eq(faded.b, b'\xC8')
  assert_eq(faded.a, b'\x7F') // 255 * 0.5 = 127
}

///|
test "gui_fade clamps alpha" {
  let c = @raylib.Color::new(100, 150, 200, 200)
  let below = @raygui.gui_fade(c, -1.0)
  assert_eq(below.a, b'\x00') // clamped to 0
  let above = @raygui.gui_fade(c, 2.0)
  assert_eq(above.a, b'\xC8') // clamped to 1.0, 200 * 1.0 = 200
}

///|
test "convert_rgb_to_hsv and convert_hsv_to_rgb round-trip" {
  // Pure red: RGB(1,0,0) -> HSV(0,1,1)
  let red_rgb = @raygui.Vector3::new(1.0, 0.0, 0.0)
  let hsv = @raygui.convert_rgb_to_hsv(red_rgb)
  assert_true((hsv.x - 0.0).abs() < 1.0) // H ~ 0 (or 360)
  assert_true((hsv.y - 1.0).abs() < 0.01) // S ~ 1
  assert_true((hsv.z - 1.0).abs() < 0.01) // V ~ 1
  let back = @raygui.convert_hsv_to_rgb(hsv)
  assert_true((back.x - 1.0).abs() < 0.01)
  assert_true((back.y - 0.0).abs() < 0.01)
  assert_true((back.z - 0.0).abs() < 0.01)
}

///|
test "convert_rgb_to_hsv gray (zero saturation)" {
  // Gray: all components equal -> S=0
  let gray = @raygui.Vector3::new(0.5, 0.5, 0.5)
  let hsv = @raygui.convert_rgb_to_hsv(gray)
  assert_true(hsv.y < 0.01) // saturation near zero
  assert_true((hsv.z - 0.5).abs() < 0.01) // value = 0.5
}

///|
test "convert_rgb_to_hsv black (zero max)" {
  let black = @raygui.Vector3::new(0.0, 0.0, 0.0)
  let hsv = @raygui.convert_rgb_to_hsv(black)
  assert_true(hsv.z < 0.01) // value near zero
}

///|
test "convert_rgb_to_hsv blue channel dominant" {
  // Blue: RGB(0,0,1) -> HSV(240,1,1)
  let blue_rgb = @raygui.Vector3::new(0.0, 0.0, 1.0)
  let hsv = @raygui.convert_rgb_to_hsv(blue_rgb)
  assert_true((hsv.x - 240.0).abs() < 1.0) // H ~ 240
  assert_true((hsv.y - 1.0).abs() < 0.01)
  assert_true((hsv.z - 1.0).abs() < 0.01)
}

///|
test "convert_hsv_to_rgb various hues" {
  // Green: HSV(120, 1, 1) -> RGB(0, 1, 0)
  let green = @raygui.convert_hsv_to_rgb(@raygui.Vector3::new(120.0, 1.0, 1.0))
  assert_true((green.x - 0.0).abs() < 0.01)
  assert_true((green.y - 1.0).abs() < 0.01)
  assert_true((green.z - 0.0).abs() < 0.01)
  // Cyan: HSV(180, 1, 1) -> RGB(0, 1, 1)
  let cyan = @raygui.convert_hsv_to_rgb(@raygui.Vector3::new(180.0, 1.0, 1.0))
  assert_true((cyan.x - 0.0).abs() < 0.01)
  assert_true((cyan.y - 1.0).abs() < 0.01)
  assert_true((cyan.z - 1.0).abs() < 0.01)
}

///|
test "convert_hsv_to_rgb zero saturation returns gray" {
  let gray = @raygui.convert_hsv_to_rgb(@raygui.Vector3::new(0.0, 0.0, 0.7))
  assert_true((gray.x - 0.7).abs() < 0.01)
  assert_true((gray.y - 0.7).abs() < 0.01)
  assert_true((gray.z - 0.7).abs() < 0.01)
}

///|
test "check_collision_point_rec" {
  let rec = @raylib.Rectangle::new(10.0, 10.0, 100.0, 50.0)
  // Inside
  assert_true(
    @raygui.check_collision_point_rec(@raylib.Vector2::new(50.0, 30.0), rec),
  )
  // Outside
  assert_false(
    @raygui.check_collision_point_rec(@raylib.Vector2::new(0.0, 0.0), rec),
  )
  // Edge
  assert_true(
    @raygui.check_collision_point_rec(@raylib.Vector2::new(10.0, 10.0), rec),
  )
}
