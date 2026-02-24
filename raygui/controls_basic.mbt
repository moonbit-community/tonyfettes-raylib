// Basic raygui controls: Label, Button, LabelButton, Toggle, ToggleGroup,
// ToggleSlider, CheckBox, Line, DummyRec, StatusBar

// Transparent color constant (alpha = 0)
///|
let blank : @raylib.Color = @raylib.Color::new(0, 0, 0, 0)

// Label control

///|
pub fn gui_label(bounds : @raylib.Rectangle, text : String) -> Unit {
  let state = gui_globals.state
  let text_color = get_color(
    gui_get_style(ControlLabel, TextColorNormal + state.to_int() * 3),
  )
  gui_draw_text(
    text,
    get_text_bounds(ControlLabel, bounds),
    gui_get_style(ControlLabel, TextAlignment),
    text_color,
  )
}

// Button control, returns true when clicked

///|
pub fn gui_button(bounds : @raylib.Rectangle, text : String) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
      } else {
        state = GuiState::Focused
      }
      if @raylib.is_mouse_button_released(MouseButtonLeft) {
        result = true
      }
    }
  }
  // Draw control
  let si = state.to_int()
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlButton, BorderWidth),
    get_color(gui_get_style(ControlButton, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlButton, BaseColorNormal + si * 3)),
  )
  gui_draw_text(
    text,
    get_text_bounds(ControlButton, bounds),
    gui_get_style(ControlButton, TextAlignment),
    get_color(gui_get_style(ControlButton, TextColorNormal + si * 3)),
  )
  if state == GuiState::Focused {
    gui_tooltip(bounds)
  }
  result
}

// Label button control, returns true when clicked

///|
pub fn gui_label_button(bounds : @raylib.Rectangle, text : String) -> Bool {
  let mut state = gui_globals.state
  let mut pressed = false
  // Expand bounds to fit text
  let text_width = Float::from_int(gui_get_text_width(text))
  let padding = Float::from_int(
    2 * gui_get_style(ControlLabel, BorderWidth) +
    2 * gui_get_style(ControlLabel, TextPadding),
  )
  let bounds = if bounds.width - padding < text_width {
    @raylib.Rectangle::new(
      bounds.x,
      bounds.y,
      text_width + padding + 2.0,
      bounds.height,
    )
  } else {
    bounds
  }
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
      } else {
        state = GuiState::Focused
      }
      if @raylib.is_mouse_button_released(MouseButtonLeft) {
        pressed = true
      }
    }
  }
  // Draw control
  gui_draw_text(
    text,
    get_text_bounds(ControlLabel, bounds),
    gui_get_style(ControlLabel, TextAlignment),
    get_color(gui_get_style(ControlLabel, TextColorNormal + state.to_int() * 3)),
  )
  if state == GuiState::Focused {
    gui_tooltip(bounds)
  }
  pressed
}

// Toggle button control, modifies active state, returns true when toggled

///|
pub fn gui_toggle(
  bounds : @raylib.Rectangle,
  text : String,
  active : Ref[Bool],
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
      } else if @raylib.is_mouse_button_released(MouseButtonLeft) {
        state = GuiState::Normal
        active.val = not(active.val)
        result = true
      } else {
        state = GuiState::Focused
      }
    }
  }
  // Draw control
  let si = state.to_int()
  if state == GuiState::Normal {
    let border_prop = if active.val {
      BorderColorPressed
    } else {
      BorderColorNormal + si * 3
    }
    let base_prop = if active.val {
      BaseColorPressed
    } else {
      BaseColorNormal + si * 3
    }
    let text_prop = if active.val {
      TextColorPressed
    } else {
      TextColorNormal + si * 3
    }
    gui_draw_rectangle(
      bounds,
      gui_get_style(ControlToggle, BorderWidth),
      get_color(gui_get_style(ControlToggle, border_prop)),
      get_color(gui_get_style(ControlToggle, base_prop)),
    )
    gui_draw_text(
      text,
      get_text_bounds(ControlToggle, bounds),
      gui_get_style(ControlToggle, TextAlignment),
      get_color(gui_get_style(ControlToggle, text_prop)),
    )
  } else {
    gui_draw_rectangle(
      bounds,
      gui_get_style(ControlToggle, BorderWidth),
      get_color(gui_get_style(ControlToggle, BorderColorNormal + si * 3)),
      get_color(gui_get_style(ControlToggle, BaseColorNormal + si * 3)),
    )
    gui_draw_text(
      text,
      get_text_bounds(ControlToggle, bounds),
      gui_get_style(ControlToggle, TextAlignment),
      get_color(gui_get_style(ControlToggle, TextColorNormal + si * 3)),
    )
  }
  result
}

// Toggle group control, modifies active index

///|
pub fn gui_toggle_group(
  bounds : @raylib.Rectangle,
  text : String,
  active : Ref[Int],
) -> Unit {
  let init_x = bounds.x
  let bw = bounds.width
  let bh = bounds.height
  let (items, rows) = gui_text_split(text)
  let item_count = items.length()
  let mut prev_row = rows[0]
  let mut cur_x = init_x
  let mut cur_y = bounds.y
  for i = 0; i < item_count; i = i + 1 {
    if prev_row != rows[i] {
      cur_x = init_x
      cur_y = cur_y +
        bh +
        Float::from_int(gui_get_style(ControlToggle, GroupPadding))
      prev_row = rows[i]
    }
    let item_bounds = @raylib.Rectangle::new(cur_x, cur_y, bw, bh)
    let toggle_active : Ref[Bool] = { val: i == active.val }
    let _ = gui_toggle(item_bounds, items[i], toggle_active)
    if toggle_active.val && i != active.val {
      active.val = i
    }
    cur_x = cur_x +
      bw +
      Float::from_int(gui_get_style(ControlToggle, GroupPadding))
  }
}

// Check box control, modifies checked state, returns true when changed

///|
pub fn gui_check_box(
  bounds : @raylib.Rectangle,
  text : String,
  checked : Ref[Bool],
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  // Calculate text bounds
  let text_w = Float::from_int(gui_get_text_width(text) + 2)
  let text_h = Float::from_int(gui_get_style(ControlDefault, TextSize))
  let text_pad = Float::from_int(gui_get_style(ControlCheckbox, TextPadding))
  let alignment = gui_get_style(ControlCheckbox, TextAlignment)
  let text_x = if alignment == TextAlignLeft {
    bx - text_w - text_pad
  } else {
    bx + bw + text_pad
  }
  let text_y = by + bh / 2.0 - text_h / 2.0
  let text_bounds = @raylib.Rectangle::new(text_x, text_y, text_w, text_h)
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    let total_x = if alignment == TextAlignLeft { text_x } else { bx }
    let total_bounds = @raylib.Rectangle::new(
      total_x,
      by,
      bw + text_w + text_pad,
      bh,
    )
    if check_collision_point_rec(mouse, total_bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
      } else {
        state = GuiState::Focused
      }
      if @raylib.is_mouse_button_released(MouseButtonLeft) {
        checked.val = not(checked.val)
        result = true
      }
    }
  }
  // Draw control
  let si = state.to_int()
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlCheckbox, BorderWidth),
    get_color(gui_get_style(ControlCheckbox, BorderColorNormal + si * 3)),
    blank,
  )
  if checked.val {
    let cp = Float::from_int(
      gui_get_style(ControlCheckbox, BorderWidth) +
      gui_get_style(ControlCheckbox, CheckPadding),
    )
    let check_bounds = @raylib.Rectangle::new(
      bx + cp,
      by + cp,
      bw - 2.0 * cp,
      bh - 2.0 * cp,
    )
    gui_draw_rectangle(
      check_bounds,
      0,
      blank,
      get_color(gui_get_style(ControlCheckbox, TextColorNormal + si * 3)),
    )
  }
  let draw_align = if alignment == TextAlignRight {
    TextAlignLeft
  } else {
    TextAlignRight
  }
  gui_draw_text(
    text,
    text_bounds,
    draw_align,
    get_color(gui_get_style(ControlLabel, TextColorNormal + si * 3)),
  )
  result
}

// Line control with optional text label

///|
pub fn gui_line(bounds : @raylib.Rectangle, text : String) -> Unit {
  let state = gui_globals.state
  let color = if state == GuiState::Disabled {
    get_color(gui_get_style(ControlDefault, BorderColorDisabled))
  } else {
    get_color(gui_get_style(ControlDefault, LineColor))
  }
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  if text.length() == 0 {
    let line_rec = @raylib.Rectangle::new(bx, by + bh / 2.0, bw, 1.0)
    gui_draw_rectangle(line_rec, 0, blank, color)
  } else {
    let text_w = Float::from_int(gui_get_text_width(text) + 2)
    let margin : Float = 12.0
    let pad : Float = 4.0
    // Left line segment
    let left_rec = @raylib.Rectangle::new(bx, by + bh / 2.0, margin - pad, 1.0)
    gui_draw_rectangle(left_rec, 0, blank, color)
    // Text
    let text_bounds = @raylib.Rectangle::new(bx + margin, by, text_w, bh)
    gui_draw_text(text, text_bounds, TextAlignLeft, color)
    // Right line segment
    let right_x = bx + margin + text_w + pad
    let right_rec = @raylib.Rectangle::new(
      right_x,
      by + bh / 2.0,
      bw - text_w - margin - pad,
      1.0,
    )
    gui_draw_rectangle(right_rec, 0, blank, color)
  }
}

// Dummy rectangle control (placeholder)

///|
pub fn gui_dummy_rec(bounds : @raylib.Rectangle, text : String) -> Unit {
  let mut state = gui_globals.state
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
      } else {
        state = GuiState::Focused
      }
    }
  }
  // Draw control
  let base_prop = if state != GuiState::Disabled {
    BaseColorNormal
  } else {
    BaseColorDisabled
  }
  let text_prop = if state != GuiState::Disabled {
    TextColorNormal
  } else {
    TextColorDisabled
  }
  gui_draw_rectangle(
    bounds,
    0,
    blank,
    get_color(gui_get_style(ControlDefault, base_prop)),
  )
  gui_draw_text(
    text,
    get_text_bounds(ControlDefault, bounds),
    TextAlignCenter,
    get_color(gui_get_style(ControlButton, text_prop)),
  )
}

// Status bar control

///|
pub fn gui_status_bar(bounds : @raylib.Rectangle, text : String) -> Unit {
  let state = gui_globals.state
  let si = state.to_int()
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlStatusbar, BorderWidth),
    get_color(gui_get_style(ControlStatusbar, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlStatusbar, BaseColorNormal + si * 3)),
  )
  gui_draw_text(
    text,
    get_text_bounds(ControlStatusbar, bounds),
    gui_get_style(ControlStatusbar, TextAlignment),
    get_color(gui_get_style(ControlStatusbar, TextColorNormal + si * 3)),
  )
}

// Toggle slider control, cycles through semicolon-delimited items
// Returns true when active index changes (on click)

///|
pub fn gui_toggle_slider(
  bounds : @raylib.Rectangle,
  text : String,
  active : Ref[Int],
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  // Parse semicolon-delimited items
  let (items, _rows) = gui_text_split(text)
  let item_count = items.length()
  if item_count == 0 {
    return false
  }
  // Clamp active index
  if active.val < 0 {
    active.val = 0
  } else if active.val >= item_count {
    active.val = item_count - 1
  }
  // Calculate slider dimensions
  let slider_width = bw / Float::from_int(item_count)
  let slider_value = Float::from_int(active.val) * slider_width
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
      } else {
        state = GuiState::Focused
      }
      if @raylib.is_mouse_button_released(MouseButtonLeft) {
        active.val = (active.val + 1) % item_count
        result = true
      }
    }
  }
  // Draw control - SLIDER style border, TOGGLE style base
  let si = state.to_int()
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlSlider, BorderWidth),
    get_color(gui_get_style(ControlSlider, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlSlider, BaseColorNormal)),
  )
  // Draw active toggle area
  let slider_bounds = @raylib.Rectangle::new(
    bx + slider_value,
    by,
    slider_width,
    bh,
  )
  gui_draw_rectangle(
    slider_bounds,
    0,
    blank,
    get_color(gui_get_style(ControlToggle, BaseColorNormal + si * 3)),
  )
  // Draw text for each item
  for i = 0; i < item_count; i = i + 1 {
    let item_x = bx + Float::from_int(i) * slider_width
    let item_bounds = @raylib.Rectangle::new(item_x, by, slider_width, bh)
    gui_draw_text(
      items[i],
      item_bounds,
      TextAlignCenter,
      get_color(gui_get_style(ControlToggle, TextColorNormal + si * 3)),
    )
  }
  result
}
