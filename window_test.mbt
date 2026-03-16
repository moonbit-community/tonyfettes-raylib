///|
test "get_random_value returns value in range" {
  let v = @raylib.get_random_value(10, 20)
  assert_true(v >= 10 && v <= 20)
}

///|
test "set_random_seed + get_random_value determinism" {
  @raylib.set_random_seed(42)
  let a1 = @raylib.get_random_value(0, 1000)
  let a2 = @raylib.get_random_value(0, 1000)
  @raylib.set_random_seed(42)
  let b1 = @raylib.get_random_value(0, 1000)
  let b2 = @raylib.get_random_value(0, 1000)
  assert_eq(a1, b1)
  assert_eq(a2, b2)
}

///|
test "set_target_fps does not crash" {
  @raylib.set_target_fps(60)
  // If we reach here, no crash occurred
  assert_true(true)
}

///|
test "get_time returns non-negative" {
  let t = @raylib.get_time()
  assert_true(t >= 0.0)
}

///|
test "get_frame_time returns non-negative" {
  let dt = @raylib.get_frame_time()
  assert_true(dt >= 0.0)
}

///|
test "set_trace_log_level does not crash" {
  @raylib.set_trace_log_level(@raylib.LogNone)
  // If we reach here, no crash occurred
  assert_true(true)
}

///|
test "Constants: key codes sample" {
  assert_eq(@raylib.KeySpace, 32)
  assert_eq(@raylib.KeyEscape, 256)
}

///|
test "Constants: flags and modes" {
  assert_eq(@raylib.FlagWindowHidden, 0x80)
  assert_eq(@raylib.CameraPerspective, 0)
  assert_eq(@raylib.BlendAlpha, 0)
  assert_eq(@raylib.MouseButtonLeft, 0)
}
