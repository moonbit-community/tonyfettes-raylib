///|
test "basic controls smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raygui.gui_load_style_default()
  @raylib.begin_drawing()
  let bounds = @raylib.Rectangle::new(0.0, 0.0, 100.0, 30.0)
  // Label
  @raygui.gui_label(bounds, "Test Label")
  // Button
  let _clicked = @raygui.gui_button(bounds, "Test Button")
  // Label button
  let _clicked2 = @raygui.gui_label_button(bounds, "Label Btn")
  // Toggle
  let toggle_val : Ref[Bool] = { val: false }
  let _toggled = @raygui.gui_toggle(bounds, "Toggle", toggle_val)
  // Checkbox
  let check_val : Ref[Bool] = { val: false }
  let _checked = @raygui.gui_check_box(bounds, "Check", check_val)
  // Dummy rec
  @raygui.gui_dummy_rec(bounds, "Dummy")
  // Line separator
  @raygui.gui_line(bounds, "Section")
  // Line without text
  @raygui.gui_line(bounds, "")
  // Status bar
  @raygui.gui_status_bar(bounds, "Status")
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "slider controls smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raygui.gui_load_style_default()
  @raylib.begin_drawing()
  let bounds = @raylib.Rectangle::new(0.0, 0.0, 200.0, 30.0)
  // Slider
  let slider_val : Ref[Float] = { val: 50.0 }
  let _s = @raygui.gui_slider(bounds, "Min", "Max", slider_val, 0.0, 100.0)
  // Slider bar
  let bar_val : Ref[Float] = { val: 0.5 }
  let _sb = @raygui.gui_slider_bar(bounds, "Lo", "Hi", bar_val, 0.0, 1.0)
  // Progress bar
  let progress_val : Ref[Float] = { val: 0.3 }
  @raygui.gui_progress_bar(bounds, "0%", "100%", progress_val, 0.0, 1.0)
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "text input controls smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raygui.gui_load_style_default()
  @raylib.begin_drawing()
  let bounds = @raylib.Rectangle::new(0.0, 0.0, 200.0, 30.0)
  // Text box
  let text : Ref[String] = { val: "Hello" }
  let _tb = @raygui.gui_text_box(bounds, text, 64, false)
  // Spinner
  let spin_val : Ref[Int] = { val: 5 }
  let _sp = @raygui.gui_spinner(bounds, "Spin", spin_val, 0, 100, false)
  // Value box
  let val_int : Ref[Int] = { val: 42 }
  let _vb = @raygui.gui_value_box(bounds, "Val", val_int, 0, 100, false)
  // Value box float
  let val_text : Ref[String] = { val: "3.14" }
  let val_float : Ref[Float] = { val: 3.14 }
  let _vbf = @raygui.gui_value_box_float(
    bounds, "Float", val_text, val_float, false,
  )
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "list and combo controls smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raygui.gui_load_style_default()
  @raylib.begin_drawing()
  let bounds = @raylib.Rectangle::new(0.0, 0.0, 200.0, 100.0)
  // Combo box
  let combo_active : Ref[Int] = { val: 0 }
  @raygui.gui_combo_box(bounds, "One;Two;Three", combo_active)
  // Toggle group
  let group_active : Ref[Int] = { val: 0 }
  @raygui.gui_toggle_group(
    @raylib.Rectangle::new(0.0, 0.0, 300.0, 30.0),
    "A;B;C",
    group_active,
  )
  // Toggle slider
  let tslider_active : Ref[Int] = { val: 0 }
  let _ts = @raygui.gui_toggle_slider(
    @raylib.Rectangle::new(0.0, 0.0, 150.0, 30.0),
    "X;Y;Z",
    tslider_active,
  )
  // Dropdown box (closed mode)
  let dd_active : Ref[Int] = { val: 0 }
  let _dd = @raygui.gui_dropdown_box(
    bounds, "Alpha;Beta;Gamma", dd_active, false,
  )
  // List view
  let list_scroll : Ref[Int] = { val: 0 }
  let list_active : Ref[Int] = { val: 0 }
  let _lv = @raygui.gui_list_view(
    bounds, "Item1;Item2;Item3", list_scroll, list_active,
  )
  // List view ex
  let lvex_scroll : Ref[Int] = { val: 0 }
  let lvex_active : Ref[Int] = { val: 0 }
  let lvex_focus : Ref[Int] = { val: 0 }
  let _lve = @raygui.gui_list_view_ex(
    bounds,
    ["Alpha", "Beta", "Gamma"],
    lvex_scroll,
    lvex_active,
    lvex_focus,
  )
  // Tab bar
  let tab_active : Ref[Int] = { val: 0 }
  let _tab = @raygui.gui_tab_bar(
    @raylib.Rectangle::new(0.0, 0.0, 300.0, 30.0),
    ["Tab1", "Tab2"],
    tab_active,
  )
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "container controls smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raygui.gui_load_style_default()
  @raylib.begin_drawing()
  let bounds = @raylib.Rectangle::new(0.0, 0.0, 200.0, 200.0)
  // Window box
  let _closed = @raygui.gui_window_box(bounds, "Window Title")
  // Group box
  @raygui.gui_group_box(bounds, "Group")
  // Panel
  @raygui.gui_panel(bounds, "Panel")
  // Panel without text
  @raygui.gui_panel(bounds, "")
  // Scroll panel
  let scroll_offset : Ref[@raylib.Vector2] = {
    val: @raylib.Vector2::new(0.0, 0.0),
  }
  let scroll_view : Ref[@raylib.Rectangle] = {
    val: @raylib.Rectangle::new(0.0, 0.0, 0.0, 0.0),
  }
  let content_rec = @raylib.Rectangle::new(0.0, 0.0, 400.0, 400.0)
  @raygui.gui_scroll_panel(
    bounds, "Scroll", content_rec, scroll_offset, scroll_view,
  )
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "color controls smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raygui.gui_load_style_default()
  @raylib.begin_drawing()
  let bounds = @raylib.Rectangle::new(0.0, 0.0, 200.0, 200.0)
  // Color panel
  let color_val : Ref[@raylib.Color] = { val: @raylib.red }
  let _cp = @raygui.gui_color_panel(bounds, color_val)
  // Color panel HSV
  let hsv_val : Ref[@raygui.Vector3] = {
    val: @raygui.Vector3::new(0.0, 1.0, 1.0),
  }
  let _cph = @raygui.gui_color_panel_hsv(bounds, hsv_val)
  // Color bar alpha
  let alpha_val : Ref[Float] = { val: 1.0 }
  let _cba = @raygui.gui_color_bar_alpha(
    @raylib.Rectangle::new(0.0, 0.0, 200.0, 20.0),
    alpha_val,
  )
  // Color bar hue
  let hue_val : Ref[Float] = { val: 0.0 }
  let _cbh = @raygui.gui_color_bar_hue(
    @raylib.Rectangle::new(0.0, 0.0, 20.0, 200.0),
    hue_val,
  )
  // Color picker
  let picker_color : Ref[@raylib.Color] = { val: @raylib.blue }
  let _cpk = @raygui.gui_color_picker(bounds, picker_color)
  // Color picker HSV
  let picker_hsv : Ref[@raygui.Vector3] = {
    val: @raygui.Vector3::new(180.0, 0.5, 0.8),
  }
  let _cpkh = @raygui.gui_color_picker_hsv(bounds, picker_hsv)
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "dialog controls smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raygui.gui_load_style_default()
  @raylib.begin_drawing()
  let bounds = @raylib.Rectangle::new(0.0, 0.0, 400.0, 200.0)
  // Message box
  let _mb = @raygui.gui_message_box(bounds, "Title", "Message", "OK;Cancel")
  // Text input box
  let input_text : Ref[String] = { val: "" }
  let _tib = @raygui.gui_text_input_box(
    bounds, "Input", "Enter text:", "OK;Cancel", input_text, 64,
  )
  // Text input box with secret view
  let secret_text : Ref[String] = { val: "password" }
  let secret_active : Ref[Bool] = { val: false }
  let _tibs = @raygui.gui_text_input_box(
    bounds,
    "Secret",
    "Enter password:",
    "OK;Cancel",
    secret_text,
    64,
    secret_view_active=Some(secret_active),
  )
  @raylib.end_drawing()
  @raylib.close_window()
}

///|
test "grid and draw_icon smoke test" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  @raygui.gui_load_style_default()
  @raylib.begin_drawing()
  // Grid
  let grid_cell : Ref[@raylib.Vector2] = { val: @raylib.Vector2::new(0.0, 0.0) }
  let _g = @raygui.gui_grid(
    @raylib.Rectangle::new(0.0, 0.0, 200.0, 200.0),
    20.0,
    2,
    grid_cell,
  )
  // Draw icon
  @raygui.gui_draw_icon(1, 10, 10, 1, @raylib.black)
  // Tooltip
  @raygui.gui_enable_tooltip()
  @raygui.gui_set_tooltip("Tip")
  @raygui.gui_tooltip(@raylib.Rectangle::new(0.0, 0.0, 50.0, 20.0))
  @raygui.gui_disable_tooltip()
  @raylib.end_drawing()
  @raylib.close_window()
}
