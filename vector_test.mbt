///|
test "Vector2 round-trip through Bytes" {
  let v = @raylib.Vector2::new(3.14, -2.71)
  let bytes = v.to_bytes()
  let v2 = @raylib.Vector2::from_bytes(bytes)
  assert_eq(v, v2)
}

///|
test "Vector3 round-trip through Bytes" {
  let v = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let bytes = v.to_bytes()
  let v2 = @raylib.Vector3::from_bytes(bytes)
  assert_eq(v, v2)
}

///|
test "Vector4 round-trip through Bytes" {
  let v = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let bytes = v.to_bytes()
  let v2 = @raylib.Vector4::from_bytes(bytes)
  assert_eq(v, v2)
}
