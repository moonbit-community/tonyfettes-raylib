// Dialog controls: MessageBox, TextInputBox, Grid

///|
let messagebox_button_height : Int = 24

///|
let messagebox_button_padding : Int = 12

// Message box control, shows title + message + buttons
// Returns -1 when no action, 0 when window closed, 1+ for button index

///|
pub fn gui_message_box(
  bounds : @raylib.Rectangle,
  title : String,
  message : String,
  buttons : String,
) -> Int {
  let mut result = -1
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let (button_items, _) = gui_text_split(buttons)
  let button_count = button_items.length()
  let btn_pad : Float = Float::from_int(messagebox_button_padding)
  let btn_h : Float = Float::from_int(messagebox_button_height)
  let btn_w : Float = if button_count > 0 {
    (bw - btn_pad * Float::from_int(button_count + 1)) /
    Float::from_int(button_count)
  } else {
    0.0
  }
  let sbh : Float = Float::from_int(window_statusbar_height)
  // Message text bounds
  let text_bounds = @raylib.Rectangle::new(
    bx + btn_pad,
    by + sbh + btn_pad,
    bw - btn_pad * 2.0,
    bh - sbh - 3.0 * btn_pad - btn_h,
  )
  // Draw window box (returns true if close button clicked)
  if gui_window_box(bounds, title) {
    result = 0
  }
  // Draw message
  let prev_align = gui_get_style(ControlLabel, TextAlignment)
  gui_set_style(ControlLabel, TextAlignment, TextAlignCenter)
  gui_label(text_bounds, message)
  gui_set_style(ControlLabel, TextAlignment, prev_align)
  // Draw buttons
  let prev_btn_align = gui_get_style(ControlButton, TextAlignment)
  gui_set_style(ControlButton, TextAlignment, TextAlignCenter)
  let mut btn_x : Float = bx + btn_pad
  let btn_y : Float = by + bh - btn_h - btn_pad
  for i in 0..<button_count {
    let btn_bounds = @raylib.Rectangle::new(btn_x, btn_y, btn_w, btn_h)
    if gui_button(btn_bounds, button_items[i]) {
      result = i + 1
    }
    btn_x = btn_x + btn_w + btn_pad
  }
  gui_set_style(ControlButton, TextAlignment, prev_btn_align)
  result
}

// Text input box control, dialog with text input
// Returns -1 when no action, 0 when window closed, 1+ for button index
// When secret_view_active is Some(ref), enables password/secret mode with eye toggle

///|
pub fn gui_text_input_box(
  bounds : @raylib.Rectangle,
  title : String,
  message : String,
  buttons : String,
  text : Ref[String],
  text_max_size : Int,
  secret_view_active? : Ref[Bool]? = None,
) -> Int {
  let mut result = -1
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let (button_items, _) = gui_text_split(buttons)
  let button_count = button_items.length()
  let btn_pad : Float = Float::from_int(messagebox_button_padding)
  let btn_h : Float = Float::from_int(messagebox_button_height)
  let btn_w : Float = if button_count > 0 {
    (bw - btn_pad * Float::from_int(button_count + 1)) /
    Float::from_int(button_count)
  } else {
    0.0
  }
  let sbh : Float = Float::from_int(window_statusbar_height)
  let textbox_h : Float = 26.0
  let msg_area_h : Float = bh -
    sbh -
    Float::from_int(gui_get_style(ControlStatusbar, BorderWidth)) -
    btn_h -
    2.0 * btn_pad
  // Draw window box
  if gui_window_box(bounds, title) {
    result = 0
  }
  // Draw message if provided
  if message.length() > 0 {
    let msg_tw : Float = Float::from_int(gui_get_text_width(message) + 2)
    let msg_th : Float = Float::from_int(
      gui_get_style(ControlDefault, TextSize),
    )
    let msg_bounds = @raylib.Rectangle::new(
      bx + bw / 2.0 - msg_tw / 2.0,
      by + sbh + msg_area_h / 4.0 - msg_th / 2.0,
      msg_tw,
      msg_th,
    )
    let prev_align = gui_get_style(ControlLabel, TextAlignment)
    gui_set_style(ControlLabel, TextAlignment, TextAlignCenter)
    gui_label(msg_bounds, message)
    gui_set_style(ControlLabel, TextAlignment, prev_align)
  }
  // Draw text box
  let tb_y : Float = if message.length() == 0 {
    by + 24.0 + btn_pad
  } else {
    by + sbh - textbox_h / 2.0 + msg_area_h / 2.0 + msg_area_h / 4.0
  }
  let textbox_bounds = @raylib.Rectangle::new(
    bx + btn_pad,
    tb_y,
    bw - btn_pad * 2.0,
    textbox_h,
  )
  // Calculate actual textbox bounds (narrower when secret mode to make room for eye toggle)
  let (actual_textbox_bounds, has_secret) = match secret_view_active {
    Some(_) => {
      let eye_btn_size = textbox_h
      let narrow_bounds = @raylib.Rectangle::new(
        bx + btn_pad,
        tb_y,
        bw - btn_pad * 2.0 - eye_btn_size - btn_pad,
        textbox_h,
      )
      (narrow_bounds, true)
    }
    None => (textbox_bounds, false)
  }
  let prev_tb_align = gui_get_style(ControlTextbox, TextAlignment)
  gui_set_style(ControlTextbox, TextAlignment, TextAlignLeft)
  // Handle text box with secret mode support
  match secret_view_active {
    Some(view_ref) =>
      // In secret mode, use text_edit_mode to track editing state
      if gui_globals.text_edit_mode {
        // In edit mode: show actual text, pass real text ref for editing
        if gui_text_box(actual_textbox_bounds, text, text_max_size, true) {
          gui_globals.text_edit_mode = not(gui_globals.text_edit_mode)
        }
      } else if view_ref.val {
        // Not editing but viewing: show actual text, not editable
        if gui_text_box(actual_textbox_bounds, text, text_max_size, false) {
          gui_globals.text_edit_mode = not(gui_globals.text_edit_mode)
        }
      } else {
        // Not editing, not viewing: show stars
        let buf = StringBuilder::new()
        for i in 0..<text.val.length() {
          buf.write_char('*')
        }
        let display_text : Ref[String] = { val: buf.to_string() }
        if gui_text_box(
            actual_textbox_bounds, display_text, text_max_size, false,
          ) {
          gui_globals.text_edit_mode = not(gui_globals.text_edit_mode)
        }
      }
    None => {
      // No secret mode: text box always in edit mode for input dialogs
      let _ = gui_text_box(actual_textbox_bounds, text, text_max_size, true)
    }
  }
  gui_set_style(ControlTextbox, TextAlignment, prev_tb_align)
  // Draw eye toggle button for secret mode
  if has_secret {
    match secret_view_active {
      Some(view_ref) => {
        let eye_x = bx + bw - btn_pad - textbox_h
        let eye_bounds = @raylib.Rectangle::new(
          eye_x, tb_y, textbox_h, textbox_h,
        )
        let icon_text = if view_ref.val {
          gui_icon_text(44, "")
        } else {
          gui_icon_text(45, "")
        }
        let _ = gui_toggle(eye_bounds, icon_text, view_ref)
      }
      None => ()
    }
  }
  // Draw buttons
  let prev_btn_align = gui_get_style(ControlButton, TextAlignment)
  gui_set_style(ControlButton, TextAlignment, TextAlignCenter)
  let mut btn_x : Float = bx + btn_pad
  let btn_y : Float = by + bh - btn_h - btn_pad
  for i in 0..<button_count {
    let btn_bounds = @raylib.Rectangle::new(btn_x, btn_y, btn_w, btn_h)
    if gui_button(btn_bounds, button_items[i]) {
      result = i + 1
    }
    btn_x = btn_x + btn_w + btn_pad
  }
  gui_set_style(ControlButton, TextAlignment, prev_btn_align)
  result
}

// Grid control, draws a grid and returns mouse cell position
// Returns true when mouse is over a cell

///|
pub fn gui_grid(
  bounds : @raylib.Rectangle,
  spacing : Float,
  subdivs : Int,
  mouse_cell : Ref[@raylib.Vector2],
) -> Bool {
  let state = gui_globals.state
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let mouse = @raylib.get_mouse_position()
  let mut cell_x : Float = -1.0
  let mut cell_y : Float = -1.0
  let space_w : Float = spacing / Float::from_int(subdivs)
  let lines_v = (bw / space_w).to_int() + 1
  let lines_h = (bh / space_w).to_int() + 1
  let mut color = gui_get_style(ControlDefault, LineColor)
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    if check_collision_point_rec(mouse, bounds) {
      let mx = mouse.x
      let my = mouse.y
      cell_x = ((mx - bx) / spacing).floor()
      cell_y = ((my - by) / spacing).floor()
      result = true
    }
  }
  // Draw control
  if state == GuiState::Disabled {
    color = gui_get_style(ControlDefault, BorderColorDisabled)
  }
  let grid_alpha : Float = 0.15
  if subdivs > 0 {
    // Draw vertical lines
    for i in 0..<lines_v {
      let lx : Float = bx +
        spacing * Float::from_int(i) / Float::from_int(subdivs)
      let line_rec = @raylib.Rectangle::new(lx, by, 1.0, bh + 1.0)
      let alpha : Float = if i % subdivs == 0 {
        grid_alpha * 4.0
      } else {
        grid_alpha
      }
      gui_draw_rectangle(line_rec, 0, blank, gui_fade(get_color(color), alpha))
    }
    // Draw horizontal lines
    for i in 0..<lines_h {
      let ly : Float = by +
        spacing * Float::from_int(i) / Float::from_int(subdivs)
      let line_rec = @raylib.Rectangle::new(bx, ly, bw + 1.0, 1.0)
      let alpha : Float = if i % subdivs == 0 {
        grid_alpha * 4.0
      } else {
        grid_alpha
      }
      gui_draw_rectangle(line_rec, 0, blank, gui_fade(get_color(color), alpha))
    }
  }
  mouse_cell.val = @raylib.Vector2::new(cell_x, cell_y)
  result
}
