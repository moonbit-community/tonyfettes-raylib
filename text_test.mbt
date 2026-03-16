///|
test "measure_text returns non-negative width" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let w = @raylib.measure_text("Hello", 20)
  assert_true(w >= 0)
  @raylib.close_window()
}

///|
test "set_text_line_spacing does not crash" {
  @raylib.set_text_line_spacing(15)
  // If we reach here, no crash occurred
  assert_true(true)
}
