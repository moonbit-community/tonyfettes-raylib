///|
test "measure_text returns non-negative width" {
  // Without a window context, default font is not loaded, so width may be 0
  let w = measure_text("Hello", 20)
  assert_true(w >= 0)
}

///|
test "set_text_line_spacing does not crash" {
  set_text_line_spacing(15)
  // If we reach here, no crash occurred
  assert_true(true)
}
