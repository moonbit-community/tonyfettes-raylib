///|
test "Rectangle round-trip through Bytes" {
  let r = @raylib.Rectangle::new(10.0, 20.0, 100.0, 50.0)
  let bytes = r.to_bytes()
  let r2 = @raylib.Rectangle::from_bytes(bytes)
  assert_eq(r, r2)
}
