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

///|
test "get_codepoint_count ASCII" {
  assert_eq(@raylib.get_codepoint_count("Hello"), 5)
}

///|
test "get_codepoint_count multibyte" {
  // "AB你好吗" has 5 codepoints: A, B, and 3 CJK chars
  assert_eq(@raylib.get_codepoint_count("AB\u4F60\u597D\u5417"), 5)
}

///|
test "get_codepoint returns first codepoint and byte count" {
  let (cp, bytes_read) = @raylib.get_codepoint("A")
  assert_eq(cp, 65)
  assert_eq(bytes_read, 1)
}

///|
test "get_codepoint_next returns first codepoint and byte count" {
  let (cp, bytes_read) = @raylib.get_codepoint_next("A")
  assert_eq(cp, 65)
  assert_eq(bytes_read, 1)
}

///|
test "codepoint_to_utf8 ASCII" {
  let bytes = @raylib.codepoint_to_utf8(65)
  assert_true(bytes.length() > 0)
}

///|
test "load_codepoints returns array of codepoints" {
  let cps = @raylib.load_codepoints("ABC")
  assert_eq(cps.length(), 3)
  assert_eq(cps[0], 65)
  assert_eq(cps[1], 66)
  assert_eq(cps[2], 67)
}

///|
test "load_utf8 encodes codepoints" {
  let cps = @raylib.load_codepoints("Hello")
  let bytes = @raylib.load_utf8(cps)
  assert_true(bytes.length() > 0)
}

///|
test "GlyphInfo::new and fields" {
  let g = @raylib.GlyphInfo::new(65, 1, 2, 10)
  assert_eq(g.value, 65)
  assert_eq(g.offset_x, 1)
  assert_eq(g.offset_y, 2)
  assert_eq(g.advance_x, 10)
}
