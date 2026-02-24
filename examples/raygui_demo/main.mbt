///|
fn main {
  @raylib.init_window(800, 560, "raygui - MoonBit Demo")
  @raylib.set_target_fps(60)
  // Load default style
  @raygui.gui_load_style_default()
  // Control state variables
  let slider_val : Ref[Float] = { val: 50.0 }
  let progress_val : Ref[Float] = { val: 0.4 }
  let check_val : Ref[Bool] = { val: false }
  let toggle_val : Ref[Bool] = { val: false }
  let combo_val : Ref[Int] = { val: 0 }
  let spinner_val : Ref[Int] = { val: 5 }
  let mut spinner_edit = false
  let text_val : Ref[String] = { val: "Edit me!" }
  let scroll_val : Ref[Int] = { val: 0 }
  let list_val : Ref[Int] = { val: 0 }
  let dropdown_val : Ref[Int] = { val: 0 }
  let mut dropdown_edit = false
  let color_val : Ref[@raylib.Color] = {
    val: @raylib.Color::new(0xE6, 0x1E, 0x32, 0xFF),
  }
  let mut show_message_box = false
  // Main loop
  while not(@raylib.window_should_close()) {
    // Update
    progress_val.val = progress_val.val + 0.001
    if progress_val.val > 1.0 {
      progress_val.val = 0.0
    }
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    // Title
    @raygui.gui_label(
      @raylib.Rectangle::new(20.0, 10.0, 300.0, 30.0),
      "raygui MoonBit Demo",
    )
    @raygui.gui_line(@raylib.Rectangle::new(20.0, 40.0, 760.0, 1.0), "")
    // Row 1: Basic controls
    @raygui.gui_group_box(
      @raylib.Rectangle::new(20.0, 55.0, 370.0, 160.0),
      "Basic Controls",
    )
    // Button
    if @raygui.gui_button(
        @raylib.Rectangle::new(35.0, 75.0, 120.0, 30.0),
        "Button",
      ) {
      show_message_box = true
    }
    // Label button
    let _ = @raygui.gui_label_button(
      @raylib.Rectangle::new(35.0, 115.0, 120.0, 30.0),
      "Label Button",
    )
    // Toggle
    let _ = @raygui.gui_toggle(
      @raylib.Rectangle::new(170.0, 75.0, 100.0, 30.0),
      "Toggle",
      toggle_val,
    )
    // CheckBox
    let _ = @raygui.gui_check_box(
      @raylib.Rectangle::new(170.0, 115.0, 20.0, 20.0),
      "CheckBox",
      check_val,
    )
    // ComboBox
    @raygui.gui_combo_box(
      @raylib.Rectangle::new(35.0, 155.0, 235.0, 30.0),
      "Option A;Option B;Option C;Option D",
      combo_val,
    )
    // Spinner
    if @raygui.gui_spinner(
        @raylib.Rectangle::new(35.0, 195.0, 235.0, 30.0),
        "",
        spinner_val,
        0,
        100,
        spinner_edit,
      ) {
      spinner_edit = not(spinner_edit)
    }
    // Row 2: Slider controls
    @raygui.gui_group_box(
      @raylib.Rectangle::new(410.0, 55.0, 370.0, 160.0),
      "Slider Controls",
    )
    // Slider
    let _ = @raygui.gui_slider(
      @raylib.Rectangle::new(460.0, 75.0, 260.0, 20.0),
      "Min",
      "Max",
      slider_val,
      0.0,
      100.0,
    )
    // Slider bar
    let slider_bar_val : Ref[Float] = { val: slider_val.val }
    let _ = @raygui.gui_slider_bar(
      @raylib.Rectangle::new(460.0, 110.0, 260.0, 20.0),
      "0",
      "100",
      slider_bar_val,
      0.0,
      100.0,
    )
    // Progress bar
    @raygui.gui_progress_bar(
      @raylib.Rectangle::new(460.0, 145.0, 260.0, 20.0),
      "0%",
      "100%",
      progress_val,
      0.0,
      1.0,
    )
    // Row 3: Text controls + List
    @raygui.gui_group_box(
      @raylib.Rectangle::new(20.0, 230.0, 370.0, 130.0),
      "Text Controls",
    )
    // TextBox
    let _ = @raygui.gui_text_box(
      @raylib.Rectangle::new(35.0, 250.0, 235.0, 30.0),
      text_val,
      64,
      true,
    )
    // StatusBar
    @raygui.gui_status_bar(
      @raylib.Rectangle::new(35.0, 295.0, 235.0, 25.0),
      "Status: Ready",
    )
    // DummyRec
    @raygui.gui_dummy_rec(
      @raylib.Rectangle::new(35.0, 325.0, 235.0, 25.0),
      "Dummy",
    )
    // List View
    @raygui.gui_group_box(
      @raylib.Rectangle::new(410.0, 230.0, 370.0, 130.0),
      "List Controls",
    )
    let _ = @raygui.gui_list_view(
      @raylib.Rectangle::new(425.0, 250.0, 160.0, 100.0),
      "Item 1;Item 2;Item 3;Item 4;Item 5",
      scroll_val,
      list_val,
    )
    // Dropdown
    if @raygui.gui_dropdown_box(
        @raylib.Rectangle::new(600.0, 250.0, 160.0, 30.0),
        "Drop A;Drop B;Drop C",
        dropdown_val,
        dropdown_edit,
      ) {
      dropdown_edit = not(dropdown_edit)
    }
    // Row 4: Color picker
    @raygui.gui_group_box(
      @raylib.Rectangle::new(20.0, 375.0, 370.0, 170.0),
      "Color Picker",
    )
    let _ = @raygui.gui_color_picker(
      @raylib.Rectangle::new(35.0, 395.0, 130.0, 130.0),
      color_val,
    )
    // Panel
    @raygui.gui_panel(
      @raylib.Rectangle::new(410.0, 375.0, 370.0, 170.0),
      "Panel",
    )
    // Message box (modal overlay)
    if show_message_box {
      let msg_result = @raygui.gui_message_box(
        @raylib.Rectangle::new(200.0, 150.0, 400.0, 200.0),
        "Message Box",
        "Hello from raygui MoonBit!",
        "OK;Cancel",
      )
      if msg_result >= 0 {
        show_message_box = false
      }
    }
    @raylib.draw_fps(740, 10)
    @raylib.end_drawing()
  }
  @raylib.close_window()
}
