// Text input controls: TextBox, ValueBox, Spinner

///|
let textbox_auto_cursor_cooldown : Int = 20

///|
let textbox_auto_cursor_delay : Int = 1

// Text box control, basic text input with cursor
// Returns true when edit mode should be toggled (Enter pressed or click outside in edit mode, click inside when not in edit mode)

///|
pub fn gui_text_box(
  bounds : @raylib.Rectangle,
  text : Ref[String],
  text_size : Int,
  edit_mode : Bool,
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let bh = bounds.height
  let text_bounds = get_text_bounds(ControlTextbox, bounds)
  let text_length = text.val.length()
  let mut cursor_index = gui_globals.text_box_cursor_index
  if cursor_index > text_length {
    cursor_index = text_length
  }
  // Update control
  if state != GuiState::Disabled &&
    gui_get_style(ControlTextbox, TextReadonly) == 0 &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if edit_mode {
      state = GuiState::Pressed
      // Auto-cursor logic for key repeat
      if @raylib.is_key_down(KeyLeft) ||
        @raylib.is_key_down(KeyRight) ||
        @raylib.is_key_down(KeyBackspace) ||
        @raylib.is_key_down(KeyDelete) {
        gui_globals.auto_cursor_counter = gui_globals.auto_cursor_counter + 1
      } else {
        gui_globals.auto_cursor_counter = 0
      }
      let auto_trigger = gui_globals.auto_cursor_counter >
        textbox_auto_cursor_cooldown &&
        gui_globals.auto_cursor_counter % textbox_auto_cursor_delay == 0
      // Clamp cursor
      if gui_globals.text_box_cursor_index > text_length {
        gui_globals.text_box_cursor_index = text_length
      }
      // Character input
      let codepoint = @raylib.get_char_pressed()
      if codepoint >= 32 && text_length < text_size - 1 {
        // Insert character at cursor position
        let ch = Int::unsafe_to_char(codepoint)
        let buf = StringBuilder::new()
        for i = 0; i < gui_globals.text_box_cursor_index; i = i + 1 {
          buf.write_char(Int::unsafe_to_char(text.val[i].to_int()))
        }
        buf.write_char(ch)
        for i = gui_globals.text_box_cursor_index; i < text_length; i = i + 1 {
          buf.write_char(Int::unsafe_to_char(text.val[i].to_int()))
        }
        text.val = buf.to_string()
        gui_globals.text_box_cursor_index = gui_globals.text_box_cursor_index +
          1
      }
      // Home key
      if text_length > 0 && @raylib.is_key_pressed(KeyHome) {
        gui_globals.text_box_cursor_index = 0
      }
      // End key
      if text_length > gui_globals.text_box_cursor_index &&
        @raylib.is_key_pressed(KeyEnd) {
        gui_globals.text_box_cursor_index = text_length
      }
      // Delete key
      if text_length > gui_globals.text_box_cursor_index &&
        (
          @raylib.is_key_pressed(KeyDelete) ||
          (@raylib.is_key_down(KeyDelete) && auto_trigger)
        ) {
        let buf = StringBuilder::new()
        for i = 0; i < gui_globals.text_box_cursor_index; i = i + 1 {
          buf.write_char(Int::unsafe_to_char(text.val[i].to_int()))
        }
        // Skip one character at cursor
        for i = gui_globals.text_box_cursor_index + 1
            i < text_length
            i = i + 1 {
          buf.write_char(Int::unsafe_to_char(text.val[i].to_int()))
        }
        text.val = buf.to_string()
      }
      // Backspace key
      if gui_globals.text_box_cursor_index > 0 &&
        (
          @raylib.is_key_pressed(KeyBackspace) ||
          (@raylib.is_key_down(KeyBackspace) && auto_trigger)
        ) {
        let buf = StringBuilder::new()
        for i = 0; i < gui_globals.text_box_cursor_index - 1; i = i + 1 {
          buf.write_char(Int::unsafe_to_char(text.val[i].to_int()))
        }
        for i = gui_globals.text_box_cursor_index; i < text_length; i = i + 1 {
          buf.write_char(Int::unsafe_to_char(text.val[i].to_int()))
        }
        text.val = buf.to_string()
        gui_globals.text_box_cursor_index = gui_globals.text_box_cursor_index -
          1
      }
      // Cursor movement
      if gui_globals.text_box_cursor_index > 0 &&
        (
          @raylib.is_key_pressed(KeyLeft) ||
          (@raylib.is_key_down(KeyLeft) && auto_trigger)
        ) {
        gui_globals.text_box_cursor_index = gui_globals.text_box_cursor_index -
          1
      }
      if text_length > gui_globals.text_box_cursor_index &&
        (
          @raylib.is_key_pressed(KeyRight) ||
          (@raylib.is_key_down(KeyRight) && auto_trigger)
        ) {
        gui_globals.text_box_cursor_index = gui_globals.text_box_cursor_index +
          1
      }
      // Exit edit mode on Enter or click outside
      if @raylib.is_key_pressed(KeyEnter) ||
        (
          not(check_collision_point_rec(mouse, bounds)) &&
          @raylib.is_mouse_button_pressed(MouseButtonLeft)
        ) {
        gui_globals.text_box_cursor_index = 0
        gui_globals.auto_cursor_counter = 0
        result = true
      }
    } else if check_collision_point_rec(mouse, bounds) {
      state = GuiState::Focused
      if @raylib.is_mouse_button_pressed(MouseButtonLeft) {
        gui_globals.text_box_cursor_index = text_length
        gui_globals.auto_cursor_counter = 0
        result = true
      }
    }
  }
  // Draw control
  let si = state.to_int()
  let base_color = match state {
    GuiState::Pressed =>
      get_color(gui_get_style(ControlTextbox, BaseColorPressed))
    GuiState::Disabled =>
      get_color(gui_get_style(ControlTextbox, BaseColorDisabled))
    _ => blank
  }
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlTextbox, BorderWidth),
    get_color(gui_get_style(ControlTextbox, BorderColorNormal + si * 3)),
    base_color,
  )
  gui_draw_text(
    text.val,
    text_bounds,
    gui_get_style(ControlTextbox, TextAlignment),
    get_color(gui_get_style(ControlTextbox, TextColorNormal + si * 3)),
  )
  // Draw cursor
  if edit_mode && gui_get_style(ControlTextbox, TextReadonly) == 0 {
    let cursor_text = string_sub(text.val, 0, gui_globals.text_box_cursor_index)
    let cursor_text_w : Float = Float::from_int(gui_get_text_width(cursor_text))
    let tbx = text_bounds.x
    let tby = text_bounds.y
    let tbh = text_bounds.height
    let cursor_x : Float = tbx +
      cursor_text_w +
      Float::from_int(gui_get_style(ControlDefault, TextSpacing))
    let cursor_h : Float = Float::from_int(
      gui_get_style(ControlDefault, TextSize) * 2,
    )
    let actual_h : Float = if cursor_h > bh {
      bh - Float::from_int(gui_get_style(ControlTextbox, BorderWidth) * 2)
    } else {
      cursor_h
    }
    let cursor_y : Float = tby + tbh / 2.0 - actual_h / 2.0
    let cursor_rec = @raylib.Rectangle::new(cursor_x, cursor_y, 2.0, actual_h)
    gui_draw_rectangle(
      cursor_rec,
      0,
      blank,
      get_color(gui_get_style(ControlTextbox, BorderColorPressed)),
    )
  }
  result
}

// Value box control, allows integer value editing
// Returns true when edit mode should be toggled

///|
pub fn gui_value_box(
  bounds : @raylib.Rectangle,
  text : String,
  value : Ref[Int],
  min_value : Int,
  max_value : Int,
  edit_mode : Bool,
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let mut text_value = value.val.to_string()
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if edit_mode {
      state = GuiState::Pressed
      let mut key_count = text_value.length()
      // Handle minus sign toggle
      if @raylib.is_key_pressed(45) {
        // KEY_MINUS = 45
        if key_count > 0 && text_value[0] == '-' {
          text_value = string_sub(text_value, 1, key_count)
          key_count = key_count - 1
        } else if key_count < 32 {
          text_value = "-" + text_value
          key_count = key_count + 1
        }
      }
      // Digit input (0-9 = codepoints 48-57)
      if key_count < 32 {
        let key = @raylib.get_char_pressed()
        if key >= 48 && key <= 57 {
          let buf = StringBuilder::new()
          for i = 0; i < key_count; i = i + 1 {
            buf.write_char(Int::unsafe_to_char(text_value[i].to_int()))
          }
          buf.write_char(Int::unsafe_to_char(key))
          text_value = buf.to_string()
          key_count = key_count + 1
        }
      }
      // Backspace
      if key_count > 0 && @raylib.is_key_pressed(KeyBackspace) {
        text_value = string_sub(text_value, 0, key_count - 1)
        key_count = key_count - 1
      }
      // Parse value
      if key_count > 0 {
        value.val = parse_int(text_value)
      } else {
        value.val = 0
      }
      // Exit edit mode on Enter or click outside
      if @raylib.is_key_pressed(KeyEnter) ||
        (
          not(check_collision_point_rec(mouse, bounds)) &&
          @raylib.is_mouse_button_pressed(MouseButtonLeft)
        ) {
        if value.val > max_value {
          value.val = max_value
        } else if value.val < min_value {
          value.val = min_value
        }
        result = true
      }
    } else {
      if value.val > max_value {
        value.val = max_value
      } else if value.val < min_value {
        value.val = min_value
      }
      if check_collision_point_rec(mouse, bounds) {
        state = GuiState::Focused
        if @raylib.is_mouse_button_pressed(MouseButtonLeft) {
          result = true
        }
      }
    }
  }
  // Draw control
  let si = state.to_int()
  let base_color = match state {
    GuiState::Pressed =>
      get_color(gui_get_style(ControlValuebox, BaseColorPressed))
    GuiState::Disabled =>
      get_color(gui_get_style(ControlValuebox, BaseColorDisabled))
    _ => blank
  }
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlValuebox, BorderWidth),
    get_color(gui_get_style(ControlValuebox, BorderColorNormal + si * 3)),
    base_color,
  )
  let display_text = value.val.to_string()
  gui_draw_text(
    display_text,
    get_text_bounds(ControlValuebox, bounds),
    TextAlignCenter,
    get_color(gui_get_style(ControlValuebox, TextColorNormal + si * 3)),
  )
  // Draw cursor in edit mode
  if edit_mode {
    let vt_w : Float = Float::from_int(gui_get_text_width(display_text))
    let cursor_x : Float = bx + vt_w / 2.0 + bw / 2.0 + 1.0
    let border_w = gui_get_style(ControlValuebox, BorderWidth)
    let cursor_rec = @raylib.Rectangle::new(
      cursor_x,
      by + Float::from_int(border_w + 2),
      2.0,
      bh - Float::from_int(border_w * 2 + 4),
    )
    gui_draw_rectangle(
      cursor_rec,
      0,
      blank,
      get_color(gui_get_style(ControlValuebox, BorderColorPressed)),
    )
  }
  // Draw text label if provided
  if text.length() > 0 {
    let tw : Float = Float::from_int(gui_get_text_width(text) + 2)
    let th : Float = Float::from_int(gui_get_style(ControlDefault, TextSize))
    let tp : Float = Float::from_int(
      gui_get_style(ControlValuebox, TextPadding),
    )
    let label_x : Float = if gui_get_style(ControlValuebox, TextAlignment) ==
      TextAlignLeft {
      bx - tw - tp
    } else {
      bx + bw + tp
    }
    let label_bounds = @raylib.Rectangle::new(
      label_x,
      by + bh / 2.0 - th / 2.0,
      tw,
      th,
    )
    let label_align = if gui_get_style(ControlValuebox, TextAlignment) ==
      TextAlignRight {
      TextAlignLeft
    } else {
      TextAlignRight
    }
    gui_draw_text(
      text,
      label_bounds,
      label_align,
      get_color(gui_get_style(ControlLabel, TextColorNormal + si * 3)),
    )
  }
  result
}

// Spinner control (value box with +/- buttons)
// Returns true when edit mode should be toggled

///|
pub fn gui_spinner(
  bounds : @raylib.Rectangle,
  text : String,
  value : Ref[Int],
  min_value : Int,
  max_value : Int,
  edit_mode : Bool,
) -> Bool {
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let btn_w = Float::from_int(
    gui_get_style(ControlValuebox, SpinnerButtonWidth),
  )
  let btn_sp = Float::from_int(
    gui_get_style(ControlValuebox, SpinnerButtonSpacing),
  )
  // Value box bounds (center)
  let vb_x : Float = bx + btn_w + btn_sp
  let vb_w : Float = bw - 2.0 * (btn_w + btn_sp)
  let value_bounds = @raylib.Rectangle::new(vb_x, by, vb_w, bh)
  // Button bounds
  let left_bounds = @raylib.Rectangle::new(bx, by, btn_w, bh)
  let right_bounds = @raylib.Rectangle::new(bx + bw - btn_w, by, btn_w, bh)
  // Left/right buttons
  let mut temp = value.val
  if gui_button(left_bounds, "<") {
    temp = temp - 1
  }
  if gui_button(right_bounds, ">") {
    temp = temp + 1
  }
  if not(edit_mode) {
    if temp < min_value {
      temp = min_value
    }
    if temp > max_value {
      temp = max_value
    }
  }
  value.val = temp
  // Value box (center)
  gui_value_box(value_bounds, text, value, min_value, max_value, edit_mode)
}

// Simple integer parser

///|
fn parse_int(s : String) -> Int {
  let len = s.length()
  if len == 0 {
    return 0
  }
  let mut result = 0
  let mut negative = false
  let mut start = 0
  if s[0] == '-' {
    negative = true
    start = 1
  } else if s[0] == '+' {
    start = 1
  }
  for i = start; i < len; i = i + 1 {
    let c = s[i].to_int()
    if c >= 48 && c <= 57 {
      result = result * 10 + (c - 48)
    }
  }
  if negative {
    -result
  } else {
    result
  }
}

// Simple float parser

///|
fn parse_float(s : String) -> Float {
  let len = s.length()
  if len == 0 {
    return 0.0
  }
  let mut result : Float = 0.0
  let mut negative = false
  let mut start = 0
  if s[0] == '-' {
    negative = true
    start = 1
  } else if s[0] == '+' {
    start = 1
  }
  // Integer part
  let mut i = start
  while i < len && s[i] >= '0' && s[i] <= '9' {
    result = result * 10.0 + Float::from_int(s[i].to_int() - 48)
    i = i + 1
  }
  // Fractional part
  if i < len && s[i] == '.' {
    i = i + 1
    let mut frac : Float = 0.1
    while i < len && s[i] >= '0' && s[i] <= '9' {
      result = result + Float::from_int(s[i].to_int() - 48) * frac
      frac = frac * 0.1
      i = i + 1
    }
  }
  if negative {
    -result
  } else {
    result
  }
}

// Value box control for float values
// Returns true when edit mode should be toggled

///|
pub fn gui_value_box_float(
  bounds : @raylib.Rectangle,
  text : String,
  text_value : Ref[String],
  value : Ref[Float],
  edit_mode : Bool,
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if edit_mode {
      state = GuiState::Pressed
      let mut key_count = text_value.val.length()
      // Character input with filtering
      if key_count < 32 {
        let key = @raylib.get_char_pressed()
        if key >= 48 && key <= 57 {
          // Digits 0-9
          let buf = StringBuilder::new()
          for i = 0; i < key_count; i = i + 1 {
            buf.write_char(Int::unsafe_to_char(text_value.val[i].to_int()))
          }
          buf.write_char(Int::unsafe_to_char(key))
          text_value.val = buf.to_string()
          key_count = key_count + 1
        } else if key == 46 {
          // '.' - only if no dot already present
          let mut has_dot = false
          for i = 0; i < key_count; i = i + 1 {
            if text_value.val[i] == '.' {
              has_dot = true
            }
          }
          if not(has_dot) {
            let buf = StringBuilder::new()
            for i = 0; i < key_count; i = i + 1 {
              buf.write_char(Int::unsafe_to_char(text_value.val[i].to_int()))
            }
            buf.write_char('.')
            text_value.val = buf.to_string()
            key_count = key_count + 1
          }
        } else if key == 43 || key == 45 {
          // '+' or '-' - only at position 0
          if key_count == 0 {
            let buf = StringBuilder::new()
            buf.write_char(Int::unsafe_to_char(key))
            text_value.val = buf.to_string()
            key_count = key_count + 1
          } else if key == 45 {
            // Toggle minus sign
            if text_value.val[0] == '-' {
              text_value.val = string_sub(text_value.val, 1, key_count)
              key_count = key_count - 1
            } else if text_value.val[0] == '+' {
              let buf = StringBuilder::new()
              buf.write_char('-')
              for i = 1; i < key_count; i = i + 1 {
                buf.write_char(Int::unsafe_to_char(text_value.val[i].to_int()))
              }
              text_value.val = buf.to_string()
            } else {
              text_value.val = "-" + text_value.val
              key_count = key_count + 1
            }
          } else if key == 43 {
            // Toggle plus sign
            if text_value.val[0] == '+' {
              text_value.val = string_sub(text_value.val, 1, key_count)
              key_count = key_count - 1
            } else if text_value.val[0] == '-' {
              let buf = StringBuilder::new()
              buf.write_char('+')
              for i = 1; i < key_count; i = i + 1 {
                buf.write_char(Int::unsafe_to_char(text_value.val[i].to_int()))
              }
              text_value.val = buf.to_string()
            } else {
              text_value.val = "+" + text_value.val
              key_count = key_count + 1
            }
          }
        }
      }
      // Backspace
      if key_count > 0 && @raylib.is_key_pressed(KeyBackspace) {
        text_value.val = string_sub(text_value.val, 0, key_count - 1)
        key_count = key_count - 1
      }
      // Exit edit mode on Enter or click outside
      if @raylib.is_key_pressed(KeyEnter) ||
        (
          not(check_collision_point_rec(mouse, bounds)) &&
          @raylib.is_mouse_button_pressed(MouseButtonLeft)
        ) {
        // Parse float from text_value on exit
        if key_count > 0 {
          value.val = parse_float(text_value.val)
        } else {
          value.val = 0.0
        }
        result = true
      }
    } else if check_collision_point_rec(mouse, bounds) {
      state = GuiState::Focused
      if @raylib.is_mouse_button_pressed(MouseButtonLeft) {
        result = true
      }
    }
  }
  // Draw control
  let si = state.to_int()
  let base_color = match state {
    GuiState::Pressed =>
      get_color(gui_get_style(ControlValuebox, BaseColorPressed))
    GuiState::Disabled =>
      get_color(gui_get_style(ControlValuebox, BaseColorDisabled))
    _ => blank
  }
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlValuebox, BorderWidth),
    get_color(gui_get_style(ControlValuebox, BorderColorNormal + si * 3)),
    base_color,
  )
  // Display text_value string
  let display_text = text_value.val
  gui_draw_text(
    display_text,
    get_text_bounds(ControlValuebox, bounds),
    TextAlignCenter,
    get_color(gui_get_style(ControlValuebox, TextColorNormal + si * 3)),
  )
  // Draw cursor in edit mode
  if edit_mode {
    let vt_w : Float = Float::from_int(gui_get_text_width(display_text))
    let cursor_x : Float = bx + vt_w / 2.0 + bw / 2.0 + 1.0
    let border_w = gui_get_style(ControlValuebox, BorderWidth)
    let cursor_rec = @raylib.Rectangle::new(
      cursor_x,
      by + Float::from_int(border_w + 2),
      2.0,
      bh - Float::from_int(border_w * 2 + 4),
    )
    gui_draw_rectangle(
      cursor_rec,
      0,
      blank,
      get_color(gui_get_style(ControlValuebox, BorderColorPressed)),
    )
  }
  // Draw text label if provided
  if text.length() > 0 {
    let tw : Float = Float::from_int(gui_get_text_width(text) + 2)
    let th : Float = Float::from_int(gui_get_style(ControlDefault, TextSize))
    let tp : Float = Float::from_int(
      gui_get_style(ControlValuebox, TextPadding),
    )
    let label_x : Float = if gui_get_style(ControlValuebox, TextAlignment) ==
      TextAlignLeft {
      bx - tw - tp
    } else {
      bx + bw + tp
    }
    let label_bounds = @raylib.Rectangle::new(
      label_x,
      by + bh / 2.0 - th / 2.0,
      tw,
      th,
    )
    let label_align = if gui_get_style(ControlValuebox, TextAlignment) ==
      TextAlignRight {
      TextAlignLeft
    } else {
      TextAlignRight
    }
    gui_draw_text(
      text,
      label_bounds,
      label_align,
      get_color(gui_get_style(ControlLabel, TextColorNormal + si * 3)),
    )
  }
  result
}
