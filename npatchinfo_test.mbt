///|
test "NPatchInfo::new and field access" {
  let rect = @raylib.Rectangle::new(0.0, 0.0, 64.0, 64.0)
  let npi = @raylib.NPatchInfo::new(rect, 4, 4, 4, 4, 0)
  assert_eq(npi.left, 4)
  assert_eq(npi.top, 4)
  assert_eq(npi.right, 4)
  assert_eq(npi.bottom, 4)
  assert_eq(npi.layout, 0)
}

///|
test "NPatchInfo::to_bytes/from_bytes round-trip" {
  let rect = @raylib.Rectangle::new(10.0, 20.0, 100.0, 200.0)
  let npi = @raylib.NPatchInfo::new(rect, 1, 2, 3, 4, 1)
  let bytes = npi.to_bytes()
  let npi2 = @raylib.NPatchInfo::from_bytes(bytes)
  assert_eq(npi2.left, 1)
  assert_eq(npi2.top, 2)
  assert_eq(npi2.right, 3)
  assert_eq(npi2.bottom, 4)
  assert_eq(npi2.layout, 1)
  assert_true((npi2.source.x - 10.0).abs() < 0.001)
  assert_true((npi2.source.y - 20.0).abs() < 0.001)
  assert_true((npi2.source.width - 100.0).abs() < 0.001)
  assert_true((npi2.source.height - 200.0).abs() < 0.001)
}
