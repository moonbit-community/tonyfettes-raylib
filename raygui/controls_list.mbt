// List controls: ComboBox, DropdownBox, ListView

// Combo box control, cycles through items on click, modifies active index
///|
pub fn gui_combo_box(
  bounds : @raylib.Rectangle,
  text : String,
  active : Ref[Int],
) -> Unit {
  let mut state = gui_globals.state
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let btn_w = Float::from_int(gui_get_style(ControlCombobox, ComboButtonWidth))
  let btn_sp = Float::from_int(
    gui_get_style(ControlCombobox, ComboButtonSpacing),
  )
  let combo_w = bw - btn_w - btn_sp
  let combo_bounds = @raylib.Rectangle::new(bx, by, combo_w, bh)
  let selector_bounds = @raylib.Rectangle::new(
    bx + combo_w + btn_sp,
    by,
    btn_w,
    bh,
  )
  let (items, _) = gui_text_split(text)
  let item_count = items.length()
  if active.val < 0 {
    active.val = 0
  } else if active.val > item_count - 1 {
    active.val = item_count - 1
  }
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    item_count > 1 &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, combo_bounds) ||
      check_collision_point_rec(mouse, selector_bounds) {
      if @raylib.is_mouse_button_pressed(MouseButtonLeft) {
        active.val = active.val + 1
        if active.val >= item_count {
          active.val = 0
        }
      }
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
      } else {
        state = GuiState::Focused
      }
    }
  }
  // Draw control
  let si = state.to_int()
  gui_draw_rectangle(
    combo_bounds,
    gui_get_style(ControlCombobox, BorderWidth),
    get_color(gui_get_style(ControlCombobox, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlCombobox, BaseColorNormal + si * 3)),
  )
  gui_draw_text(
    items[active.val],
    get_text_bounds(ControlCombobox, combo_bounds),
    gui_get_style(ControlCombobox, TextAlignment),
    get_color(gui_get_style(ControlCombobox, TextColorNormal + si * 3)),
  )
  // Draw selector button
  let selector_text = (active.val + 1).to_string() +
    "/" +
    item_count.to_string()
  let prev_bw = gui_get_style(ControlButton, BorderWidth)
  let prev_ta = gui_get_style(ControlButton, TextAlignment)
  gui_set_style(ControlButton, BorderWidth, 1)
  gui_set_style(ControlButton, TextAlignment, TextAlignCenter)
  let _ = gui_button(selector_bounds, selector_text)
  gui_set_style(ControlButton, TextAlignment, prev_ta)
  gui_set_style(ControlButton, BorderWidth, prev_bw)
}

// Dropdown box control, shows/hides items list
// In edit_mode, the dropdown is open and items are shown
// Returns true when edit mode should be toggled

///|
pub fn gui_dropdown_box(
  bounds : @raylib.Rectangle,
  text : String,
  active : Ref[Int],
  edit_mode : Bool,
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let (items, _) = gui_text_split(text)
  let item_count = items.length()
  let item_spacing = Float::from_int(
    gui_get_style(ControlDropdownbox, DropdownItemsSpacing),
  )
  let roll_up = gui_get_style(ControlDropdownbox, DropdownRollUp) != 0
  let mut item_focused = -1
  // Update control
  if state != GuiState::Disabled &&
    (edit_mode || not(gui_globals.locked)) &&
    item_count > 1 &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if edit_mode {
      state = GuiState::Pressed
      // Check click outside to close
      let bounds_open = if roll_up {
        let open_y = by -
          Float::from_int(item_count) * (bh + item_spacing)
        @raylib.Rectangle::new(
          bx,
          open_y,
          bw,
          Float::from_int(item_count + 1) * (bh + item_spacing),
        )
      } else {
        @raylib.Rectangle::new(
          bx,
          by,
          bw,
          Float::from_int(item_count + 1) * (bh + item_spacing),
        )
      }
      if not(check_collision_point_rec(mouse, bounds_open)) {
        if @raylib.is_mouse_button_pressed(MouseButtonLeft) ||
          @raylib.is_mouse_button_released(MouseButtonLeft) {
          result = true
        }
      }
      // Check item selection and focus
      for i = 0; i < item_count; i = i + 1 {
        let item_y = if roll_up {
          by - Float::from_int(i + 1) * (bh + item_spacing)
        } else {
          by + Float::from_int(i + 1) * (bh + item_spacing)
        }
        let item_bounds = @raylib.Rectangle::new(bx, item_y, bw, bh)
        if check_collision_point_rec(mouse, item_bounds) {
          item_focused = i
          if @raylib.is_mouse_button_released(MouseButtonLeft) {
            active.val = i
            result = true
          }
        }
      }
    } else if check_collision_point_rec(mouse, bounds) {
      if @raylib.is_mouse_button_pressed(MouseButtonLeft) {
        result = true
      }
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
      } else {
        state = GuiState::Focused
      }
    }
  }
  // Draw control
  let si = state.to_int()
  // Draw main box
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlDropdownbox, BorderWidth),
    get_color(gui_get_style(ControlDropdownbox, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlDropdownbox, BaseColorNormal + si * 3)),
  )
  let display_text = if active.val >= 0 && active.val < item_count {
    items[active.val]
  } else {
    ""
  }
  gui_draw_text(
    display_text,
    get_text_bounds(ControlDropdownbox, bounds),
    gui_get_style(ControlDropdownbox, TextAlignment),
    get_color(gui_get_style(ControlDropdownbox, TextColorNormal + si * 3)),
  )
  // Draw arrow icon on main box
  if gui_get_style(ControlDropdownbox, DropdownArrowHidden) == 0 {
    let arrow_padding = Float::from_int(
      gui_get_style(ControlDropdownbox, ArrowPadding),
    )
    let arrow_icon = if edit_mode { 120 } else { 121 }
    gui_draw_icon(
      arrow_icon,
      (bx + bw - arrow_padding).to_int(),
      (by + (bh - Float::from_int(RayguiIconSize)) / 2.0).to_int(),
      1,
      get_color(
        gui_get_style(ControlDropdownbox, TextColorNormal + si * 3),
      ),
    )
  }
  // Draw dropdown items when in edit mode
  if edit_mode {
    // Draw background panel
    let bounds_open = if roll_up {
      let open_y = by - Float::from_int(item_count) * (bh + item_spacing)
      @raylib.Rectangle::new(
        bx,
        open_y,
        bw,
        Float::from_int(item_count) * (bh + item_spacing),
      )
    } else {
      @raylib.Rectangle::new(
        bx,
        by + bh + item_spacing,
        bw,
        Float::from_int(item_count) * (bh + item_spacing),
      )
    }
    gui_panel(bounds_open, "")
    // Draw individual items
    for i = 0; i < item_count; i = i + 1 {
      let item_y = if roll_up {
        by - Float::from_int(i + 1) * (bh + item_spacing)
      } else {
        by + Float::from_int(i + 1) * (bh + item_spacing)
      }
      let item_bounds = @raylib.Rectangle::new(bx, item_y, bw, bh)
      let item_state = if i == active.val {
        2 // Pressed
      } else if i == item_focused {
        1 // Focused
      } else {
        0 // Normal
      }
      gui_draw_rectangle(
        item_bounds,
        gui_get_style(ControlDropdownbox, BorderWidth),
        get_color(
          gui_get_style(ControlDropdownbox, BorderColorNormal + item_state * 3),
        ),
        get_color(
          gui_get_style(ControlDropdownbox, BaseColorNormal + item_state * 3),
        ),
      )
      gui_draw_text(
        items[i],
        get_text_bounds(ControlDropdownbox, item_bounds),
        gui_get_style(ControlDropdownbox, TextAlignment),
        get_color(
          gui_get_style(ControlDropdownbox, TextColorNormal + item_state * 3),
        ),
      )
    }
  }
  result
}

// List view control, shows scrollable list of items
// Returns true when active item changes

///|
pub fn gui_list_view(
  bounds : @raylib.Rectangle,
  text : String,
  scroll_index : Ref[Int],
  active : Ref[Int],
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let (items, _) = gui_text_split(text)
  let item_count = items.length()
  let item_height = gui_get_style(ControlListview, ListItemsHeight)
  let item_spacing = gui_get_style(ControlListview, ListItemsSpacing)
  let visible_count = bh.to_int() / (item_height + item_spacing)
  // Update control
  if state != GuiState::Disabled && not(gui_globals.locked) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, bounds) {
      state = GuiState::Focused
      // Mouse wheel scrolling
      let wheel = @raylib.get_mouse_wheel_move()
      if wheel != 0.0 {
        scroll_index.val = scroll_index.val - wheel.to_int()
      }
      // Check item clicks
      for i = 0
          i < visible_count && scroll_index.val + i < item_count
          i = i + 1 {
        let item_y = by + Float::from_int(i * (item_height + item_spacing))
        let item_bounds = @raylib.Rectangle::new(
          bx,
          item_y,
          bw,
          Float::from_int(item_height),
        )
        if check_collision_point_rec(mouse, item_bounds) {
          if @raylib.is_mouse_button_pressed(MouseButtonLeft) {
            let new_active = scroll_index.val + i
            if new_active != active.val {
              active.val = new_active
              result = true
            }
          }
        }
      }
    }
  }
  // Clamp scroll index
  if scroll_index.val < 0 {
    scroll_index.val = 0
  }
  if scroll_index.val > item_count - visible_count {
    scroll_index.val = if item_count > visible_count {
      item_count - visible_count
    } else {
      0
    }
  }
  // Draw control
  let si = state.to_int()
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlListview, BorderWidth),
    get_color(gui_get_style(ControlListview, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlDefault, BackgroundColor)),
  )
  // Draw visible items
  for i = 0; i < visible_count && scroll_index.val + i < item_count; i = i + 1 {
    let item_idx = scroll_index.val + i
    let item_y = by + Float::from_int(i * (item_height + item_spacing))
    let item_bounds = @raylib.Rectangle::new(
      bx + Float::from_int(gui_get_style(ControlListview, BorderWidth)),
      item_y,
      bw - Float::from_int(2 * gui_get_style(ControlListview, BorderWidth)),
      Float::from_int(item_height),
    )
    let item_si = if item_idx == active.val { 2 } else { 0 }
    gui_draw_rectangle(
      item_bounds,
      0,
      blank,
      get_color(gui_get_style(ControlListview, BaseColorNormal + item_si * 3)),
    )
    gui_draw_text(
      items[item_idx],
      item_bounds,
      gui_get_style(ControlListview, TextAlignment),
      get_color(gui_get_style(ControlListview, TextColorNormal + item_si * 3)),
    )
  }
  result
}

// List view control with extended parameters (separate items array)
// Returns true when active item changes

///|
pub fn gui_list_view_ex(
  bounds : @raylib.Rectangle,
  items : Array[String],
  scroll_index : Ref[Int],
  active : Ref[Int],
  focus : Ref[Int],
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let count = items.length()
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let item_height = gui_get_style(ControlListview, ListItemsHeight)
  let item_spacing = gui_get_style(ControlListview, ListItemsSpacing)
  let border = gui_get_style(ControlDefault, BorderWidth)
  let scrollbar_w = gui_get_style(ControlListview, ScrollbarWidth)
  let mut item_focused = focus.val
  let mut item_selected = active.val
  // Check if scrollbar needed
  let use_scrollbar = (item_height + item_spacing) * count > bh.to_int()
  // Base item bounds
  let item_x : Float = bx + Float::from_int(item_spacing)
  let item_start_y : Float = by + Float::from_int(item_spacing + border)
  let mut item_w : Float = bw - Float::from_int(2 * item_spacing + border)
  if use_scrollbar {
    item_w = item_w - Float::from_int(scrollbar_w)
  }
  let item_h : Float = Float::from_int(item_height)
  // Calculate visible items
  let mut visible_items = bh.to_int() / (item_height + item_spacing)
  if visible_items > count {
    visible_items = count
  }
  let mut start_index = scroll_index.val
  if start_index < 0 || start_index > count - visible_items {
    start_index = 0
  }
  let mut end_index = start_index + visible_items
  if end_index > count {
    end_index = count
  }
  // Update control
  if state != GuiState::Disabled &&
    not(gui_globals.locked) &&
    not(gui_globals.control_exclusive_mode) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, bounds) {
      state = GuiState::Focused
      // Check focused and selected item
      let mut check_y : Float = item_start_y
      for i = 0; i < visible_items; i = i + 1 {
        let ib = @raylib.Rectangle::new(item_x, check_y, item_w, item_h)
        if check_collision_point_rec(mouse, ib) {
          item_focused = start_index + i
          if @raylib.is_mouse_button_pressed(MouseButtonLeft) {
            if item_selected == start_index + i {
              item_selected = -1
            } else {
              item_selected = start_index + i
            }
            result = true
          }
          break
        }
        check_y = check_y + Float::from_int(item_height + item_spacing)
      }
      // Mouse wheel scrolling
      if use_scrollbar {
        let wheel = @raylib.get_mouse_wheel_move()
        if wheel != 0.0 {
          start_index = start_index - wheel.to_int()
          if start_index < 0 {
            start_index = 0
          } else if start_index > count - visible_items {
            start_index = count - visible_items
          }
          end_index = start_index + visible_items
          if end_index > count {
            end_index = count
          }
        }
      }
    } else {
      item_focused = -1
    }
  }
  // Draw control
  let si = state.to_int()
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlListview, BorderWidth),
    get_color(gui_get_style(ControlListview, BorderColorNormal + si * 3)),
    get_color(gui_get_style(ControlDefault, BackgroundColor)),
  )
  // Draw visible items
  let mut draw_y : Float = item_start_y
  for i = 0; i < visible_items && start_index + i < count; i = i + 1 {
    let item_idx = start_index + i
    let item_bounds = @raylib.Rectangle::new(item_x, draw_y, item_w, item_h)
    // Draw item borders if configured
    if gui_get_style(ControlListview, ListItemsBorderNormal) != 0 {
      gui_draw_rectangle(
        item_bounds,
        gui_get_style(ControlListview, ListItemsBorderWidth),
        get_color(gui_get_style(ControlListview, BorderColorNormal)),
        blank,
      )
    }
    if state == GuiState::Disabled {
      if item_idx == item_selected {
        gui_draw_rectangle(
          item_bounds,
          gui_get_style(ControlListview, ListItemsBorderWidth),
          get_color(gui_get_style(ControlListview, BorderColorDisabled)),
          get_color(gui_get_style(ControlListview, BaseColorDisabled)),
        )
      }
      gui_draw_text(
        items[item_idx],
        get_text_bounds(ControlDefault, item_bounds),
        gui_get_style(ControlListview, TextAlignment),
        get_color(gui_get_style(ControlListview, TextColorDisabled)),
      )
    } else if item_idx == item_selected {
      gui_draw_rectangle(
        item_bounds,
        gui_get_style(ControlListview, ListItemsBorderWidth),
        get_color(gui_get_style(ControlListview, BorderColorPressed)),
        get_color(gui_get_style(ControlListview, BaseColorPressed)),
      )
      gui_draw_text(
        items[item_idx],
        get_text_bounds(ControlDefault, item_bounds),
        gui_get_style(ControlListview, TextAlignment),
        get_color(gui_get_style(ControlListview, TextColorPressed)),
      )
    } else if item_idx == item_focused {
      gui_draw_rectangle(
        item_bounds,
        gui_get_style(ControlListview, ListItemsBorderWidth),
        get_color(gui_get_style(ControlListview, BorderColorFocused)),
        get_color(gui_get_style(ControlListview, BaseColorFocused)),
      )
      gui_draw_text(
        items[item_idx],
        get_text_bounds(ControlDefault, item_bounds),
        gui_get_style(ControlListview, TextAlignment),
        get_color(gui_get_style(ControlListview, TextColorFocused)),
      )
    } else {
      gui_draw_text(
        items[item_idx],
        get_text_bounds(ControlDefault, item_bounds),
        gui_get_style(ControlListview, TextAlignment),
        get_color(gui_get_style(ControlListview, TextColorNormal)),
      )
    }
    draw_y = draw_y + Float::from_int(item_height + item_spacing)
  }
  // Draw scrollbar if needed
  if use_scrollbar {
    let sb_x : Float = bx + bw - Float::from_int(border + scrollbar_w)
    let sb_y : Float = by + Float::from_int(border)
    let sb_w : Float = Float::from_int(scrollbar_w)
    let sb_h : Float = bh - Float::from_int(2 * border)
    let sb_bounds = @raylib.Rectangle::new(sb_x, sb_y, sb_w, sb_h)
    let percent_visible : Float = Float::from_int(end_index - start_index) /
      Float::from_int(count)
    let slider_size : Int = (bh * percent_visible).to_int()
    let prev_slider = gui_get_style(ControlScrollbar, ScrollSliderSize)
    let prev_speed = gui_get_style(ControlScrollbar, ScrollSpeed)
    gui_set_style(ControlScrollbar, ScrollSliderSize, slider_size)
    gui_set_style(ControlScrollbar, ScrollSpeed, count - visible_items)
    start_index = gui_scroll_bar(
      sb_bounds,
      start_index,
      0,
      count - visible_items,
    )
    gui_set_style(ControlScrollbar, ScrollSpeed, prev_speed)
    gui_set_style(ControlScrollbar, ScrollSliderSize, prev_slider)
  }
  active.val = item_selected
  focus.val = item_focused
  scroll_index.val = start_index
  result
}
