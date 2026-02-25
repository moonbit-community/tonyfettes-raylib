// Container controls: WindowBox, GroupBox, Panel

///|
let window_statusbar_height : Int = 24

// Window box control with close button, returns true when close button clicked

///|
pub fn gui_window_box(bounds : @raylib.Rectangle, title : String) -> Bool {
  let state = gui_globals.state
  let si = state.to_int()
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let _bh = bounds.height
  let sbh = Float::from_int(window_statusbar_height)
  // Status bar (title)
  let status_bar = @raylib.Rectangle::new(bx, by, bw, sbh)
  // Close button
  let close_size : Float = sbh - 4.0
  let close_bounds = @raylib.Rectangle::new(
    bx + bw - Float::from_int(window_statusbar_height) + 2.0,
    by + 2.0,
    close_size,
    close_size,
  )
  // Draw window body
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlDefault, BorderWidth),
    get_color(gui_get_style(ControlDefault, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlDefault, BackgroundColor)),
  )
  // Draw status bar
  gui_status_bar(status_bar, title)
  // Draw close button
  let close_text = "#128#"
  let close_clicked = gui_button(close_bounds, close_text)
  close_clicked
}

// Group box control with text label

///|
pub fn gui_group_box(bounds : @raylib.Rectangle, text : String) -> Unit {
  let state = gui_globals.state
  let si = state.to_int()
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlDefault, BorderWidth),
    get_color(gui_get_style(ControlDefault, LineColor)),
    blank,
  )
  if text.length() > 0 {
    let text_w = Float::from_int(gui_get_text_width(text) + 2)
    let text_bounds = @raylib.Rectangle::new(
      bounds.x + 12.0,
      bounds.y - Float::from_int(gui_get_style(ControlDefault, TextSize) / 2),
      text_w,
      Float::from_int(gui_get_style(ControlDefault, TextSize)),
    )
    gui_draw_text(
      text,
      text_bounds,
      TextAlignLeft,
      get_color(gui_get_style(ControlLabel, TextColorNormal + si * 3)),
    )
  }
}

// Panel control with optional header

///|
pub fn gui_panel(bounds : @raylib.Rectangle, text : String) -> Unit {
  let state = gui_globals.state
  let si = state.to_int()
  let bx = bounds.x
  let mut by = bounds.y
  let bw = bounds.width
  let mut bh = bounds.height
  if text.length() > 0 {
    let sbh = Float::from_int(window_statusbar_height)
    if bh < sbh * 2.0 {
      bh = sbh * 2.0
    }
    let status_bar = @raylib.Rectangle::new(bx, by, bw, sbh)
    gui_status_bar(status_bar, text)
    by = by + sbh - 1.0
    bh = bh - sbh + 1.0
  }
  let body = @raylib.Rectangle::new(bx, by, bw, bh)
  gui_draw_rectangle(
    body,
    1,
    get_color(gui_get_style(ControlDefault, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlDefault, BackgroundColor)),
  )
}

///|
let min_scrollbar_width : Int = 40

///|
let min_scrollbar_height : Int = 40

///|
let min_mouse_wheel_speed : Int = 20

// Scroll panel control with scrollbars
// Returns the visible view rectangle; updates scroll position

///|
pub fn gui_scroll_panel(
  bounds : @raylib.Rectangle,
  text : String,
  content : @raylib.Rectangle,
  scroll : Ref[@raylib.Vector2],
  view : Ref[@raylib.Rectangle],
) -> Unit {
  let mut state = gui_globals.state
  let bx = bounds.x
  let mut by = bounds.y
  let bw = bounds.width
  let mut bh = bounds.height
  let content_w = content.width
  let content_h = content.height
  let mut scroll_x : Float = scroll.val.x
  let mut scroll_y : Float = scroll.val.y
  let sbh : Float = Float::from_int(window_statusbar_height)
  let border = gui_get_style(ControlDefault, BorderWidth)
  let scrollbar_w = gui_get_style(ControlListview, ScrollbarWidth)
  // Draw header if text provided
  if text.length() > 0 {
    if bh < sbh * 2.0 {
      bh = sbh * 2.0
    }
    let status_bar = @raylib.Rectangle::new(bx, by, bw, sbh)
    gui_status_bar(status_bar, text)
    by = by + sbh - 1.0
    bh = bh - sbh + 1.0
  }
  // Check if scrollbars are needed
  let mut has_h_scroll = content_w > bw - Float::from_int(2 * border)
  let mut has_v_scroll = content_h > bh - Float::from_int(2 * border)
  if not(has_h_scroll) {
    has_h_scroll = has_v_scroll &&
      content_w > bw - Float::from_int(2 * border + scrollbar_w)
  }
  if not(has_v_scroll) {
    has_v_scroll = has_h_scroll &&
      content_h > bh - Float::from_int(2 * border + scrollbar_w)
  }
  let h_scroll_h = if has_h_scroll { scrollbar_w } else { 0 }
  let v_scroll_w = if has_v_scroll { scrollbar_w } else { 0 }
  // Calculate view area
  let scroll_side = gui_get_style(ControlListview, ScrollbarSide)
  let view_x : Float = if scroll_side == ScrollbarLeftSide {
    bx + Float::from_int(v_scroll_w + border)
  } else {
    bx + Float::from_int(border)
  }
  let view_y : Float = by + Float::from_int(border)
  let mut view_w : Float = bw - Float::from_int(2 * border + v_scroll_w)
  let mut view_h : Float = bh - Float::from_int(2 * border + h_scroll_h)
  if view_w > content_w {
    view_w = content_w
  }
  if view_h > content_h {
    view_h = content_h
  }
  view.val = @raylib.Rectangle::new(view_x, view_y, view_w, view_h)
  // Calculate scroll limits
  let h_min : Float = if has_h_scroll {
    if scroll_side == ScrollbarLeftSide {
      -Float::from_int(v_scroll_w) - Float::from_int(border)
    } else {
      -Float::from_int(border)
    }
  } else {
    -Float::from_int(border)
  }
  let h_max : Float = if has_h_scroll {
    content_w - bw + Float::from_int(v_scroll_w + border)
  } else {
    -Float::from_int(border)
  }
  let v_min : Float = if has_v_scroll { 0.0 } else { -1.0 }
  let v_max : Float = if has_v_scroll {
    content_h - bh + Float::from_int(h_scroll_h + border)
  } else {
    -Float::from_int(border)
  }
  // Update control
  let panel_bounds = @raylib.Rectangle::new(bx, by, bw, bh)
  if state != GuiState::Disabled && not(gui_globals.locked) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, panel_bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
      } else {
        state = GuiState::Focused
      }
      let wheel = @raylib.get_mouse_wheel_move()
      // Scroll speed based on content/bounds ratio
      let mut speed_y : Float = content_h / bh
      if speed_y < Float::from_int(min_mouse_wheel_speed) {
        speed_y = Float::from_int(min_mouse_wheel_speed)
      }
      scroll_y = scroll_y + wheel * speed_y
    }
  }
  // Clamp scroll values
  if scroll_x > -h_min {
    scroll_x = -h_min
  }
  if scroll_x < -h_max {
    scroll_x = -h_max
  }
  if scroll_y > -v_min {
    scroll_y = -v_min
  }
  if scroll_y < -v_max {
    scroll_y = -v_max
  }
  // Draw control
  gui_draw_rectangle(
    panel_bounds,
    0,
    blank,
    get_color(gui_get_style(ControlDefault, BackgroundColor)),
  )
  // Draw scrollbars
  let prev_slider_size = gui_get_style(ControlScrollbar, ScrollSliderSize)
  // Horizontal scrollbar
  if has_h_scroll {
    let h_bar_x : Float = if scroll_side == ScrollbarLeftSide {
      bx + Float::from_int(v_scroll_w + border)
    } else {
      bx + Float::from_int(border)
    }
    let h_bar_y : Float = by + bh - Float::from_int(h_scroll_h + border)
    let h_bar_w : Float = bw - Float::from_int(v_scroll_w + 2 * border)
    let h_bar_h : Float = Float::from_int(h_scroll_h)
    let h_bar = @raylib.Rectangle::new(h_bar_x, h_bar_y, h_bar_w, h_bar_h)
    let h_slider : Int = ((bw - Float::from_int(2 * border + v_scroll_w)) /
    content_w *
    (bw - Float::from_int(2 * border + v_scroll_w))).to_int()
    let h_slider = if h_slider < min_scrollbar_width {
      min_scrollbar_width
    } else {
      h_slider
    }
    gui_set_style(ControlScrollbar, ScrollSliderSize, h_slider)
    scroll_x = -Float::from_int(
      gui_scroll_bar(
        h_bar,
        (-scroll_x).to_int(),
        h_min.to_int(),
        h_max.to_int(),
      ),
    )
  } else {
    scroll_x = 0.0
  }
  // Vertical scrollbar
  if has_v_scroll {
    let v_bar_x : Float = if scroll_side == ScrollbarLeftSide {
      bx + Float::from_int(border)
    } else {
      bx + bw - Float::from_int(v_scroll_w + border)
    }
    let v_bar_y : Float = by + Float::from_int(border)
    let v_bar_w : Float = Float::from_int(v_scroll_w)
    let v_bar_h : Float = bh - Float::from_int(h_scroll_h + 2 * border)
    let v_bar = @raylib.Rectangle::new(v_bar_x, v_bar_y, v_bar_w, v_bar_h)
    let v_slider : Int = ((bh - Float::from_int(2 * border + h_scroll_h)) /
    content_h *
    (bh - Float::from_int(2 * border + h_scroll_h))).to_int()
    let v_slider = if v_slider < min_scrollbar_height {
      min_scrollbar_height
    } else {
      v_slider
    }
    gui_set_style(ControlScrollbar, ScrollSliderSize, v_slider)
    scroll_y = -Float::from_int(
      gui_scroll_bar(
        v_bar,
        (-scroll_y).to_int(),
        v_min.to_int(),
        v_max.to_int(),
      ),
    )
  } else {
    scroll_y = 0.0
  }
  gui_set_style(ControlScrollbar, ScrollSliderSize, prev_slider_size)
  // Draw corner if both scrollbars visible
  if has_h_scroll && has_v_scroll {
    let corner_x : Float = if scroll_side == ScrollbarLeftSide {
      bx + Float::from_int(border) + 2.0
    } else {
      bx + bw - Float::from_int(v_scroll_w + border) + 2.0
    }
    let corner_y : Float = by + bh - Float::from_int(h_scroll_h + border) + 2.0
    let corner = @raylib.Rectangle::new(
      corner_x,
      corner_y,
      Float::from_int(h_scroll_h - 4),
      Float::from_int(v_scroll_w - 4),
    )
    let si = state.to_int()
    gui_draw_rectangle(
      corner,
      0,
      blank,
      get_color(gui_get_style(ControlListview, TextColorNormal + si * 3)),
    )
  }
  // Draw border
  let si = state.to_int()
  gui_draw_rectangle(
    panel_bounds,
    gui_get_style(ControlListview, BorderWidth),
    get_color(gui_get_style(ControlListview, BorderColorNormal + si * 3)),
    blank,
  )
  scroll.val = @raylib.Vector2::new(scroll_x, scroll_y)
}

// Tab bar control with closeable tabs
// Returns -1 normally, or the index of a tab that was closed

///|
pub fn gui_tab_bar(
  bounds : @raylib.Rectangle,
  texts : Array[String],
  active : Ref[Int],
) -> Int {
  let mut result = -1
  let tab_bar_item_width : Float = 148.0
  let count = texts.length()
  // Calculate tab width based on count and bounds
  let tab_width : Float = if tab_bar_item_width * Float::from_int(count) >
    bounds.width {
    bounds.width / Float::from_int(count)
  } else {
    tab_bar_item_width
  }
  // Draw all tabs
  for i = 0; i < count; i = i + 1 {
    let tab_x = bounds.x + (tab_width + 4.0) * Float::from_int(i)
    let tab_bounds = @raylib.Rectangle::new(
      tab_x,
      bounds.y,
      tab_width,
      bounds.height,
    )
    // Toggle for each tab
    let toggle_active : Ref[Bool] = { val: i == active.val }
    let _ = gui_toggle(tab_bounds, texts[i], toggle_active)
    if toggle_active.val {
      active.val = i
    }
    // Close button (small X)
    let close_size : Float = 14.0
    let close_bounds = @raylib.Rectangle::new(
      tab_x + tab_width - close_size - 5.0,
      bounds.y + (bounds.height - close_size) / 2.0,
      close_size,
      close_size,
    )
    // Check for middle click to close
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, tab_bounds) &&
      @raylib.is_mouse_button_pressed(MouseButtonMiddle) {
      result = i
    }
    // Draw close button
    if gui_button(close_bounds, gui_icon_text(128, "")) {
      result = i
    }
  }
  // Draw bottom separator line
  let si = gui_globals.state.to_int()
  let line_color = get_color(
    gui_get_style(ControlToggle, BorderColorNormal + si * 3),
  )
  @raylib.draw_line(
    bounds.x.to_int(),
    (bounds.y + bounds.height - 1.0).to_int(),
    (bounds.x + bounds.width).to_int(),
    (bounds.y + bounds.height - 1.0).to_int(),
    line_color,
  )
  result
}
