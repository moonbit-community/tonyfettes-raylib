// Slider and value controls: Slider, SliderBar, ProgressBar

// Internal helper: check if two rectangles match (used for exclusive mode identification)

///|
fn rects_match(a : @raylib.Rectangle, b : @raylib.Rectangle) -> Bool {
  a.x == b.x && a.y == b.y && a.width == b.width && a.height == b.height
}

// Slider control, modifies value, returns true when changed

///|
pub fn gui_slider(
  bounds : @raylib.Rectangle,
  text_left : String,
  text_right : String,
  value : Ref[Float],
  min_value : Float,
  max_value : Float,
) -> Bool {
  let mut state = gui_globals.state
  let old_value = value.val
  let slider_width = gui_get_style(ControlSlider, SliderWidth)
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let border = gui_get_style(ControlSlider, BorderWidth)
  let padding = gui_get_style(ControlSlider, SliderPadding)
  // Update control
  if state != GuiState::Disabled && not(gui_globals.locked) {
    let mouse = @raylib.get_mouse_position()
    let mx = mouse.x
    if gui_globals.control_exclusive_mode {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        match gui_globals.control_exclusive_rec {
          Some(exc_rec) =>
            if rects_match(bounds, exc_rec) {
              state = GuiState::Pressed
              let sw : Float = Float::from_int(slider_width)
              value.val = (max_value - min_value) *
                ((mx - bx - sw / 2.0) / (bw - sw)) +
                min_value
            }
          None => ()
        }
      } else {
        gui_globals.control_exclusive_mode = false
        gui_globals.control_exclusive_rec = None
      }
    } else if check_collision_point_rec(mouse, bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
        gui_globals.control_exclusive_mode = true
        gui_globals.control_exclusive_rec = Some(bounds)
        let sw : Float = Float::from_int(slider_width)
        value.val = (max_value - min_value) * ((mx - bx - sw / 2.0) / (bw - sw)) +
          min_value
      } else {
        state = GuiState::Focused
      }
    }
    if value.val > max_value {
      value.val = max_value
    } else if value.val < min_value {
      value.val = min_value
    }
  }
  let result = old_value != value.val
  // Calculate slider bar position
  let slider_value : Float = (value.val - min_value) /
    (max_value - min_value) *
    (bw - Float::from_int(slider_width) - Float::from_int(2 * border))
  let slider_x : Float = if slider_width > 0 {
    let sx = bx + slider_value
    if sx <= bx + Float::from_int(border) {
      bx + Float::from_int(border)
    } else if sx + Float::from_int(slider_width) >= bx + bw {
      bx + bw - Float::from_int(slider_width) - Float::from_int(border)
    } else {
      sx
    }
  } else {
    bx + Float::from_int(border)
  }
  let slider_w : Float = if slider_width > 0 {
    Float::from_int(slider_width)
  } else if slider_value > bw {
    bw - Float::from_int(2 * border)
  } else {
    slider_value
  }
  let slider_rec = @raylib.Rectangle::new(
    slider_x,
    by + Float::from_int(border + padding),
    slider_w,
    bh - Float::from_int(2 * border + 2 * padding),
  )
  // Draw control
  let si = state.to_int()
  let base_prop = if state != GuiState::Disabled {
    BaseColorNormal
  } else {
    BaseColorDisabled
  }
  gui_draw_rectangle(
    bounds,
    border,
    get_color(gui_get_style(ControlSlider, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlSlider, base_prop)),
  )
  // Draw slider bar
  let slider_color = match state {
    GuiState::Normal =>
      get_color(gui_get_style(ControlSlider, BaseColorPressed))
    GuiState::Focused =>
      get_color(gui_get_style(ControlSlider, TextColorFocused))
    GuiState::Pressed =>
      get_color(gui_get_style(ControlSlider, TextColorPressed))
    GuiState::Disabled =>
      get_color(gui_get_style(ControlSlider, TextColorDisabled))
  }
  gui_draw_rectangle(slider_rec, 0, blank, slider_color)
  // Draw left/right text
  if text_left.length() > 0 {
    let tw = Float::from_int(gui_get_text_width(text_left))
    let th = Float::from_int(gui_get_style(ControlDefault, TextSize))
    let tp = Float::from_int(gui_get_style(ControlSlider, TextPadding))
    let text_bounds = @raylib.Rectangle::new(
      bx - tw - tp,
      by + bh / 2.0 - th / 2.0,
      tw,
      th,
    )
    gui_draw_text(
      text_left,
      text_bounds,
      TextAlignRight,
      get_color(gui_get_style(ControlLabel, TextColorNormal + si * 3)),
    )
  }
  if text_right.length() > 0 {
    let tw = Float::from_int(gui_get_text_width(text_right))
    let th = Float::from_int(gui_get_style(ControlDefault, TextSize))
    let tp = Float::from_int(gui_get_style(ControlSlider, TextPadding))
    let text_bounds = @raylib.Rectangle::new(
      bx + bw + tp,
      by + bh / 2.0 - th / 2.0,
      tw,
      th,
    )
    gui_draw_text(
      text_right,
      text_bounds,
      TextAlignLeft,
      get_color(gui_get_style(ControlLabel, TextColorNormal + si * 3)),
    )
  }
  result
}

// Slider bar control (slider with no knob, just a fill bar)

///|
pub fn gui_slider_bar(
  bounds : @raylib.Rectangle,
  text_left : String,
  text_right : String,
  value : Ref[Float],
  min_value : Float,
  max_value : Float,
) -> Bool {
  let prev_width = gui_get_style(ControlSlider, SliderWidth)
  gui_set_style(ControlSlider, SliderWidth, 0)
  let result = gui_slider(
    bounds, text_left, text_right, value, min_value, max_value,
  )
  gui_set_style(ControlSlider, SliderWidth, prev_width)
  result
}

// Progress bar control, shows current progress

///|
pub fn gui_progress_bar(
  bounds : @raylib.Rectangle,
  text_left : String,
  text_right : String,
  value : Ref[Float],
  min_value : Float,
  max_value : Float,
) -> Unit {
  let state = gui_globals.state
  let si = state.to_int()
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let border = gui_get_style(ControlProgressbar, BorderWidth)
  let padding = gui_get_style(ControlProgressbar, ProgressPadding)
  if value.val > max_value {
    value.val = max_value
  }
  // Calculate progress width
  let progress_w : Float = if state != GuiState::Disabled {
    value.val / (max_value - min_value) * (bw - Float::from_int(2 * border))
  } else {
    0.0
  }
  let progress_rec = @raylib.Rectangle::new(
    bx + Float::from_int(border),
    by + Float::from_int(border + padding),
    progress_w,
    bh - Float::from_int(border + 2 * padding + 1),
  )
  // Draw control
  gui_draw_rectangle(
    bounds,
    border,
    get_color(gui_get_style(ControlProgressbar, BorderColorNormal + si * 3)),
    blank,
  )
  gui_draw_rectangle(
    progress_rec,
    0,
    blank,
    get_color(gui_get_style(ControlProgressbar, BaseColorPressed)),
  )
  // Draw left/right text
  if text_left.length() > 0 {
    let tw = Float::from_int(gui_get_text_width(text_left))
    let th = Float::from_int(gui_get_style(ControlDefault, TextSize))
    let tp = Float::from_int(gui_get_style(ControlProgressbar, TextPadding))
    let text_bounds = @raylib.Rectangle::new(
      bx - tw - tp,
      by + bh / 2.0 - th / 2.0,
      tw,
      th,
    )
    gui_draw_text(
      text_left,
      text_bounds,
      TextAlignRight,
      get_color(gui_get_style(ControlLabel, TextColorNormal + si * 3)),
    )
  }
  if text_right.length() > 0 {
    let tw = Float::from_int(gui_get_text_width(text_right))
    let th = Float::from_int(gui_get_style(ControlDefault, TextSize))
    let tp = Float::from_int(gui_get_style(ControlProgressbar, TextPadding))
    let text_bounds = @raylib.Rectangle::new(
      bx + bw + tp,
      by + bh / 2.0 - th / 2.0,
      tw,
      th,
    )
    gui_draw_text(
      text_right,
      text_bounds,
      TextAlignLeft,
      get_color(gui_get_style(ControlLabel, TextColorNormal + si * 3)),
    )
  }
}

// Scroll bar control (internal, used by ScrollPanel and ListViewEx)

///|
fn gui_scroll_bar(
  bounds : @raylib.Rectangle,
  value : Int,
  min_value : Int,
  max_value : Int,
) -> Int {
  let mut state = gui_globals.state
  let mut val = value
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let is_vertical = bw <= bh
  let border = gui_get_style(ControlScrollbar, BorderWidth)
  // Spinner/arrow button size
  let spinner_size = if gui_get_style(ControlScrollbar, ArrowsVisible) != 0 {
    if is_vertical {
      bw.to_int() - 2 * border
    } else {
      bh.to_int() - 2 * border
    }
  } else {
    0
  }
  // Normalize value
  if val > max_value {
    val = max_value
  }
  if val < min_value {
    val = min_value
  }
  let value_range = if max_value - min_value <= 0 {
    1
  } else {
    max_value - min_value
  }
  let mut slider_size = gui_get_style(ControlScrollbar, ScrollSliderSize)
  if slider_size < 1 {
    slider_size = 1
  }
  // Calculate scrollbar and slider rectangles
  let arrow_up_left = @raylib.Rectangle::new(
    bx + Float::from_int(border),
    by + Float::from_int(border),
    Float::from_int(spinner_size),
    Float::from_int(spinner_size),
  )
  let scroll_padding = gui_get_style(ControlScrollbar, ScrollPadding)
  let slider_padding = gui_get_style(ControlScrollbar, ScrollSliderPadding)
  let (arrow_down_right, scrollbar_rec, slider_rec) = if is_vertical {
    let adr = @raylib.Rectangle::new(
      bx + Float::from_int(border),
      by + bh - Float::from_int(spinner_size + border),
      Float::from_int(spinner_size),
      Float::from_int(spinner_size),
    )
    let sb_x : Float = bx + Float::from_int(border + scroll_padding)
    let sb_y : Float = by + Float::from_int(border + spinner_size)
    let sb_w : Float = bw - Float::from_int(2 * (border + scroll_padding))
    let sb_h : Float = bh - Float::from_int(2 * border + 2 * spinner_size)
    let sbr = @raylib.Rectangle::new(sb_x, sb_y, sb_w, sb_h)
    let actual_ss = if slider_size >= sb_h.to_int() {
      sb_h.to_int() - 2
    } else {
      slider_size
    }
    let sl_x : Float = bx + Float::from_int(border + slider_padding)
    let sl_y : Float = sb_y +
      Float::from_int(val - min_value) /
      Float::from_int(value_range) *
      (sb_h - Float::from_int(actual_ss))
    let sl_w : Float = bw - Float::from_int(2 * (border + slider_padding))
    let slr = @raylib.Rectangle::new(
      sl_x,
      sl_y,
      sl_w,
      Float::from_int(actual_ss),
    )
    (adr, sbr, slr)
  } else {
    let adr = @raylib.Rectangle::new(
      bx + bw - Float::from_int(spinner_size + border),
      by + Float::from_int(border),
      Float::from_int(spinner_size),
      Float::from_int(spinner_size),
    )
    let sb_x : Float = bx + Float::from_int(border + spinner_size)
    let sb_y : Float = by + Float::from_int(border + scroll_padding)
    let sb_w : Float = bw - Float::from_int(2 * border + 2 * spinner_size)
    let sb_h : Float = bh - Float::from_int(2 * (border + scroll_padding))
    let sbr = @raylib.Rectangle::new(sb_x, sb_y, sb_w, sb_h)
    let actual_ss = if slider_size >= sb_w.to_int() {
      sb_w.to_int() - 2
    } else {
      slider_size
    }
    let sl_x : Float = sb_x +
      Float::from_int(val - min_value) /
      Float::from_int(value_range) *
      (sb_w - Float::from_int(actual_ss))
    let sl_y : Float = by + Float::from_int(border + slider_padding)
    let sl_h : Float = bh - Float::from_int(2 * (border + slider_padding))
    let slr = @raylib.Rectangle::new(
      sl_x,
      sl_y,
      Float::from_int(actual_ss),
      sl_h,
    )
    (adr, sbr, slr)
  }
  // Update control
  if state != GuiState::Disabled && not(gui_globals.locked) {
    let mouse = @raylib.get_mouse_position()
    let mx = mouse.x
    let my = mouse.y
    if gui_globals.control_exclusive_mode {
      if @raylib.is_mouse_button_down(MouseButtonLeft) &&
        not(check_collision_point_rec(mouse, arrow_up_left)) &&
        not(check_collision_point_rec(mouse, arrow_down_right)) {
        match gui_globals.control_exclusive_rec {
          Some(exc_rec) =>
            if rects_match(bounds, exc_rec) {
              state = GuiState::Pressed
              if is_vertical {
                val = ((my - scrollbar_rec.y - slider_rec.height / 2.0) *
                Float::from_int(value_range) /
                (scrollbar_rec.height - slider_rec.height) +
                Float::from_int(min_value)).to_int()
              } else {
                val = ((mx - scrollbar_rec.x - slider_rec.width / 2.0) *
                Float::from_int(value_range) /
                (scrollbar_rec.width - slider_rec.width) +
                Float::from_int(min_value)).to_int()
              }
            }
          None => ()
        }
      } else {
        gui_globals.control_exclusive_mode = false
        gui_globals.control_exclusive_rec = None
      }
    } else if check_collision_point_rec(mouse, bounds) {
      state = GuiState::Focused
      let wheel = @raylib.get_mouse_wheel_move()
      if wheel != 0.0 {
        val = val + wheel.to_int()
      }
      if @raylib.is_mouse_button_pressed(MouseButtonLeft) {
        gui_globals.control_exclusive_mode = true
        gui_globals.control_exclusive_rec = Some(bounds)
        if check_collision_point_rec(mouse, arrow_up_left) {
          val = val - value_range / gui_get_style(ControlScrollbar, ScrollSpeed)
        } else if check_collision_point_rec(mouse, arrow_down_right) {
          val = val + value_range / gui_get_style(ControlScrollbar, ScrollSpeed)
        } else if not(check_collision_point_rec(mouse, slider_rec)) {
          if is_vertical {
            val = ((my - scrollbar_rec.y - slider_rec.height / 2.0) *
            Float::from_int(value_range) /
            (scrollbar_rec.height - slider_rec.height) +
            Float::from_int(min_value)).to_int()
          } else {
            val = ((mx - scrollbar_rec.x - slider_rec.width / 2.0) *
            Float::from_int(value_range) /
            (scrollbar_rec.width - slider_rec.width) +
            Float::from_int(min_value)).to_int()
          }
        }
        state = GuiState::Pressed
      }
    }
    if val > max_value {
      val = max_value
    }
    if val < min_value {
      val = min_value
    }
  }
  // Draw control
  let si = state.to_int()
  gui_draw_rectangle(
    bounds,
    border,
    get_color(gui_get_style(ControlListview, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlDefault, BorderColorDisabled)),
  )
  gui_draw_rectangle(
    scrollbar_rec,
    0,
    blank,
    get_color(gui_get_style(ControlButton, BaseColorNormal)),
  )
  gui_draw_rectangle(
    slider_rec,
    0,
    blank,
    get_color(gui_get_style(ControlSlider, BorderColorNormal + si * 3)),
  )
  // Draw arrows
  if gui_get_style(ControlScrollbar, ArrowsVisible) != 0 {
    let arrow_up_text = if is_vertical { "^" } else { "<" }
    let arrow_down_text = if is_vertical { "v" } else { ">" }
    gui_draw_text(
      arrow_up_text,
      arrow_up_left,
      TextAlignCenter,
      get_color(gui_get_style(ControlScrollbar, TextColorNormal + si * 3)),
    )
    gui_draw_text(
      arrow_down_text,
      arrow_down_right,
      TextAlignCenter,
      get_color(gui_get_style(ControlScrollbar, TextColorNormal + si * 3)),
    )
  }
  val
}
