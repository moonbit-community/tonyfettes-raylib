///|
test "measure_text returns non-negative width" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")
  let w = measure_text("Hello", 20)
  assert_true(w >= 0)
  close_window()
}

///|
test "set_text_line_spacing does not crash" {
  set_text_line_spacing(15)
  // If we reach here, no crash occurred
  assert_true(true)
}
