///|
test "gui state management" {
  // gui_enable sets state to Normal
  @raygui.gui_enable()
  assert_true(@raygui.gui_get_state() is Normal)
  // gui_disable sets state to Disabled
  @raygui.gui_disable()
  assert_true(@raygui.gui_get_state() is Disabled)
  // gui_set_state round-trip: save, change, restore
  let saved = @raygui.gui_get_state()
  @raygui.gui_enable()
  assert_true(@raygui.gui_get_state() is Normal)
  @raygui.gui_set_state(saved)
  assert_true(@raygui.gui_get_state() is Disabled)
  // Restore to Normal
  @raygui.gui_enable()
}

///|
test "gui lock/unlock" {
  assert_false(@raygui.gui_is_locked())
  @raygui.gui_lock()
  assert_true(@raygui.gui_is_locked())
  @raygui.gui_unlock()
  assert_false(@raygui.gui_is_locked())
}

///|
test "gui alpha get/set with clamping" {
  let original = @raygui.gui_get_alpha()
  // Normal set
  @raygui.gui_set_alpha(0.5)
  assert_true((@raygui.gui_get_alpha() - 0.5).abs() < 0.01)
  // Clamp below
  @raygui.gui_set_alpha(-1.0)
  assert_true(@raygui.gui_get_alpha() < 0.01)
  // Clamp above
  @raygui.gui_set_alpha(2.0)
  assert_true((@raygui.gui_get_alpha() - 1.0).abs() < 0.01)
  // Restore
  @raygui.gui_set_alpha(original)
}

///|
test "gui tooltip enable/disable" {
  @raygui.gui_enable_tooltip()
  @raygui.gui_disable_tooltip()
  @raygui.gui_set_tooltip("test tooltip")
  // No crash = success
}

///|
test "gui_get_icons returns icon data" {
  let icons = @raygui.gui_get_icons()
  assert_eq(icons.length(), 2048)
}

///|
test "gui style get/set" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  // gui_load_style_default initializes styles (needs window for Font::default)
  @raygui.gui_load_style_default()
  // Read a known default value
  let border_width = @raygui.gui_get_style(0, 12) // ControlDefault, BorderWidth
  assert_eq(border_width, 1) // default is 1
  // Set and read back
  @raygui.gui_set_style(0, 12, 3)
  assert_eq(@raygui.gui_get_style(0, 12), 3)
  // Restore
  @raygui.gui_set_style(0, 12, border_width)
  @raylib.close_window()
}

///|
test "gui_load_style_default initializes all styles" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raygui.gui_load_style_default()
  // Check text size default (property index 16 = TextSize for ControlDefault)
  let text_size = @raygui.gui_get_style(0, 16)
  assert_eq(text_size, 10)
  // Check text spacing (property index 17 = TextSpacing)
  let text_spacing = @raygui.gui_get_style(0, 17)
  assert_eq(text_spacing, 1)
  @raylib.close_window()
}
