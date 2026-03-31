///|
test "gui_icon_text formats icon prefix" {
  // Single digit
  let s1 = @raygui.gui_icon_text(5, "File")
  assert_eq(s1, "#005#File")
  // Two digits
  let s2 = @raygui.gui_icon_text(42, "Edit")
  assert_eq(s2, "#042#Edit")
  // Three digits
  let s3 = @raygui.gui_icon_text(128, "View")
  assert_eq(s3, "#128#View")
  // Empty text
  let s4 = @raygui.gui_icon_text(1, "")
  assert_eq(s4, "#001#")
}

///|
test "gui_text_split splits on semicolons" {
  let (parts, rows) = @raygui.gui_text_split("One;Two;Three")
  assert_eq(parts.length(), 3)
  assert_eq(parts[0], "One")
  assert_eq(parts[1], "Two")
  assert_eq(parts[2], "Three")
  // All on row 0
  assert_eq(rows[0], 0)
  assert_eq(rows[1], 0)
  assert_eq(rows[2], 0)
}

///|
test "gui_text_split handles newlines as row separators" {
  let (parts, rows) = @raygui.gui_text_split("A;B\nC;D")
  assert_eq(parts.length(), 4)
  assert_eq(parts[0], "A")
  assert_eq(parts[1], "B")
  assert_eq(parts[2], "C")
  assert_eq(parts[3], "D")
  // A,B on row 0; C,D on row 1
  assert_eq(rows[0], 0)
  assert_eq(rows[1], 0)
  assert_eq(rows[2], 1)
  assert_eq(rows[3], 1)
}

///|
test "gui_text_split empty string" {
  let (parts, _rows) = @raygui.gui_text_split("")
  assert_eq(parts.length(), 1)
  assert_eq(parts[0], "")
}

///|
test "gui_text_split single item" {
  let (parts, rows) = @raygui.gui_text_split("Only")
  assert_eq(parts.length(), 1)
  assert_eq(parts[0], "Only")
  assert_eq(rows[0], 0)
}

///|
test "gui_get_text_width measures text" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raygui.gui_load_style_default()
  // Empty text should be 0
  assert_eq(@raygui.gui_get_text_width(""), 0)
  // Non-empty text should have positive width
  let w = @raygui.gui_get_text_width("Hello")
  assert_true(w > 0)
  // Longer text should be wider
  let w2 = @raygui.gui_get_text_width("Hello World")
  assert_true(w2 > w)
  // Text with icon prefix
  let icon_text = @raygui.gui_icon_text(5, "File")
  let w3 = @raygui.gui_get_text_width(icon_text)
  assert_true(w3 > 0)
  @raylib.close_window()
}
