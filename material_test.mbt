// Tests for Material maps accessor round-trips.

///|
test "Material::maps accessor color round-trip" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let mat = @raylib.Material::default()
  let maps = mat.maps()
  assert_true(maps.count() > 0)
  // Get the diffuse map (index 0) and modify its color
  let map0 = maps[0]
  let color1 = @raylib.Color::new(10, 20, 30, 255)
  map0.set_color(color1)
  let c = map0.color()
  assert_eq(c.r, b'\x0A')
  assert_eq(c.g, b'\x14')
  assert_eq(c.b, b'\x1E')
  assert_eq(c.a, b'\xFF')
  // Change to a different color and verify
  let color2 = @raylib.Color::new(200, 100, 50, 128)
  map0.set_color(color2)
  let c2 = map0.color()
  assert_eq(c2.r, b'\xC8')
  assert_eq(c2.g, b'\x64')
  assert_eq(c2.b, b'\x32')
  assert_eq(c2.a, b'\x80')
  mat.unload()
  @raylib.close_window()
}

///|
test "Material::maps accessor value round-trip" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let mat = @raylib.Material::default()
  let maps = mat.maps()
  let map0 = maps[0]
  map0.set_value(0.75)
  assert_eq(map0.value(), 0.75)
  map0.set_value(0.25)
  assert_eq(map0.value(), 0.25)
  mat.unload()
  @raylib.close_window()
}

///|
test "Material::set_map_color mutates via high-level API" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let mat = @raylib.Material::default()
  let color = @raylib.Color::new(11, 22, 33, 44)
  mat.set_map_color(0, color)
  // Read back through maps accessor
  let map0 = mat.maps()[0]
  let c = map0.color()
  assert_eq(c.r, b'\x0B')
  assert_eq(c.g, b'\x16')
  assert_eq(c.b, b'\x21')
  assert_eq(c.a, b'\x2C')
  mat.unload()
  @raylib.close_window()
}
