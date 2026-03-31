///|
test "FloatArray new/get/set/free" {
  let arr = @raylib.FloatArray::new(4)
  arr[0] = 1.5
  arr[1] = 2.5
  assert_true((arr[0] - 1.5).abs() < 0.001)
  assert_true((arr[1] - 2.5).abs() < 0.001)
  assert_eq(arr.length(), 4)
  let _ = arr.pointer()
  arr.free()
}

///|
test "UByteArray new/get/set/free" {
  let arr = @raylib.UByteArray::new(4)
  arr[0] = b'A'
  arr[1] = b'B'
  assert_eq(arr[0], 0x41)
  assert_eq(arr[1], 0x42)
  assert_eq(arr.length(), 4)
  let _ = arr.pointer()
  arr.free()
}

///|
test "ShortArray new/get/set/free" {
  let arr = @raylib.ShortArray::new(4)
  arr[0] = 100
  arr[1] = -200
  assert_eq(arr[0], 100)
  assert_eq(arr[1], -200)
  assert_eq(arr.length(), 4)
  let _ = arr.pointer()
  arr.free()
}

///|
test "UShortArray new/get/set/free" {
  let arr = @raylib.UShortArray::new(4)
  let val : UInt16 = 500
  arr[0] = val
  assert_eq(arr[0], 500)
  assert_eq(arr.length(), 4)
  let _ = arr.pointer()
  arr.free()
}
