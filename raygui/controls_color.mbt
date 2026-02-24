// Color picker controls: ColorPanel, ColorBarAlpha, ColorBarHue, ColorPicker

// Color panel control (2D saturation-value picker)
// Modifies color HSV, returns true when changed
///|
pub fn gui_color_panel_hsv(
  bounds : @raylib.Rectangle,
  color_hsv : Ref[Vector3],
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  // Update control
  if state != GuiState::Disabled && not(gui_globals.locked) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
        let mx = mouse.x
        let my = mouse.y
        let new_s : Float = (mx - bx) / bw
        let new_v : Float = 1.0 - (my - by) / bh
        let clamped_s : Float = if new_s < 0.0 {
          0.0
        } else if new_s > 1.0 {
          1.0
        } else {
          new_s
        }
        let clamped_v : Float = if new_v < 0.0 {
          0.0
        } else if new_v > 1.0 {
          1.0
        } else {
          new_v
        }
        color_hsv.val = { x: color_hsv.val.x, y: clamped_s, z: clamped_v }
        result = true
      } else {
        state = GuiState::Focused
      }
    }
  }
  // Draw control
  let si = state.to_int()
  // Draw base panel with gradient approximation
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlColorpicker, BorderWidth),
    get_color(gui_get_style(ControlColorpicker, BorderColorNormal + si * 3)),
    blank,
  )
  // Draw simplified color gradient using the hue
  let rgb = convert_hsv_to_rgb({ x: color_hsv.val.x, y: 1.0, z: 1.0 })
  let hue_color = @raylib.Color::new(
    (rgb.x * 255.0).to_int(),
    (rgb.y * 255.0).to_int(),
    (rgb.z * 255.0).to_int(),
    0xFF,
  )
  let white = @raylib.Color::new(0xFF, 0xFF, 0xFF, 0xFF)
  let black = @raylib.Color::new(0x00, 0x00, 0x00, 0xFF)
  // Draw gradient: white to hue (horizontal), then overlay black (vertical)
  @raylib.draw_rectangle_gradient_ex(bounds, white, hue_color, hue_color, white)
  let dark_bounds = @raylib.Rectangle::new(bx, by, bw, bh)
  let transparent = @raylib.Color::new(0x00, 0x00, 0x00, 0x00)
  @raylib.draw_rectangle_gradient_ex(
    dark_bounds, transparent, transparent, black, black,
  )
  // Draw selector circle (simplified as a small rectangle)
  let sel_size = gui_get_style(ControlColorpicker, ColorSelectorSize)
  let sel_x : Float = bx + color_hsv.val.y * bw - Float::from_int(sel_size / 2)
  let sel_y : Float = by +
    (1.0 - color_hsv.val.z) * bh -
    Float::from_int(sel_size / 2)
  let sel_bounds = @raylib.Rectangle::new(
    sel_x,
    sel_y,
    Float::from_int(sel_size),
    Float::from_int(sel_size),
  )
  gui_draw_rectangle(sel_bounds, 1, white, blank)
  result
}

// Color bar hue control (vertical hue selector)

///|
pub fn gui_color_bar_hue(
  bounds : @raylib.Rectangle,
  value : Ref[Float],
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  // Update control
  if state != GuiState::Disabled && not(gui_globals.locked) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
        let my = mouse.y
        let new_hue : Float = (my - by) / bh * 360.0
        value.val = if new_hue < 0.0 {
          0.0
        } else if new_hue > 360.0 {
          360.0
        } else {
          new_hue
        }
        result = true
      } else {
        state = GuiState::Focused
      }
    }
  }
  // Draw control - draw 6 hue sectors
  let si = state.to_int()
  let sector_h : Float = bh / 6.0
  let colors : FixedArray[@raylib.Color] = [
    @raylib.Color::new(0xFF, 0x00, 0x00, 0xFF), // Red
    @raylib.Color::new(0xFF, 0xFF, 0x00, 0xFF), // Yellow
    @raylib.Color::new(0x00, 0xFF, 0x00, 0xFF), // Green
    @raylib.Color::new(0x00, 0xFF, 0xFF, 0xFF), // Cyan
    @raylib.Color::new(0x00, 0x00, 0xFF, 0xFF), // Blue
    @raylib.Color::new(0xFF, 0x00, 0xFF, 0xFF), // Magenta
    @raylib.Color::new(0xFF, 0x00, 0x00, 0xFF), // Red (wrap)
  ]
  for i = 0; i < 6; i = i + 1 {
    let sector = @raylib.Rectangle::new(
      bx,
      by + Float::from_int(i) * sector_h,
      bw,
      sector_h,
    )
    @raylib.draw_rectangle_gradient_ex(
      sector,
      colors[i],
      colors[i],
      colors[i + 1],
      colors[i + 1],
    )
  }
  // Draw border
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlColorpicker, BorderWidth),
    get_color(gui_get_style(ControlColorpicker, BorderColorNormal + si * 3)),
    blank,
  )
  // Draw selector
  let sel_h = gui_get_style(ControlColorpicker, HuebarSelectorHeight)
  let sel_y : Float = by + value.val / 360.0 * bh - Float::from_int(sel_h / 2)
  let white = @raylib.Color::new(0xFF, 0xFF, 0xFF, 0xFF)
  let sel_bounds = @raylib.Rectangle::new(
    bx -
    Float::from_int(gui_get_style(ControlColorpicker, HuebarSelectorOverflow)),
    sel_y,
    bw +
    Float::from_int(
      gui_get_style(ControlColorpicker, HuebarSelectorOverflow) * 2,
    ),
    Float::from_int(sel_h),
  )
  gui_draw_rectangle(sel_bounds, 1, white, blank)
  result
}

// Color bar alpha control (horizontal alpha selector)

///|
pub fn gui_color_bar_alpha(
  bounds : @raylib.Rectangle,
  alpha : Ref[Float],
) -> Bool {
  let mut state = gui_globals.state
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  // Update control
  if state != GuiState::Disabled && not(gui_globals.locked) {
    let mouse = @raylib.get_mouse_position()
    if check_collision_point_rec(mouse, bounds) {
      if @raylib.is_mouse_button_down(MouseButtonLeft) {
        state = GuiState::Pressed
        let mx = mouse.x
        let new_alpha : Float = (mx - bx) / bw
        alpha.val = if new_alpha < 0.0 {
          0.0
        } else if new_alpha > 1.0 {
          1.0
        } else {
          new_alpha
        }
        result = true
      } else {
        state = GuiState::Focused
      }
    }
  }
  // Draw control
  let si = state.to_int()
  let transparent = @raylib.Color::new(0x00, 0x00, 0x00, 0x00)
  let white_opaque = @raylib.Color::new(0xFF, 0xFF, 0xFF, 0xFF)
  @raylib.draw_rectangle_gradient_ex(
    bounds, transparent, transparent, white_opaque, white_opaque,
  )
  gui_draw_rectangle(
    bounds,
    gui_get_style(ControlColorpicker, BorderWidth),
    get_color(gui_get_style(ControlColorpicker, BorderColorNormal + si * 3)),
    blank,
  )
  // Draw selector
  let sel_x : Float = bx + alpha.val * bw - 2.0
  let sel_bounds = @raylib.Rectangle::new(sel_x, by, 4.0, bh)
  gui_draw_rectangle(sel_bounds, 1, white_opaque, blank)
  result
}

// Full color picker (panel + hue bar + alpha bar)

///|
pub fn gui_color_picker(
  bounds : @raylib.Rectangle,
  color : Ref[@raylib.Color],
) -> Bool {
  let mut result = false
  let bx = bounds.x
  let by = bounds.y
  let bw = bounds.width
  let bh = bounds.height
  let hue_w = Float::from_int(gui_get_style(ControlColorpicker, HuebarWidth))
  let hue_pad = Float::from_int(
    gui_get_style(ControlColorpicker, HuebarPadding),
  )
  // Convert current color to HSV
  let r : Float = Float::from_int(color.val.r.to_int()) / 255.0
  let g : Float = Float::from_int(color.val.g.to_int()) / 255.0
  let b : Float = Float::from_int(color.val.b.to_int()) / 255.0
  let hsv : Ref[Vector3] = { val: convert_rgb_to_hsv({ x: r, y: g, z: b }) }
  let hue : Ref[Float] = { val: hsv.val.x }
  let alpha_val : Ref[Float] = {
    val: Float::from_int(color.val.a.to_int()) / 255.0,
  }
  // Panel (saturation-value)
  let panel_w = bw - hue_w - hue_pad
  let panel_bounds = @raylib.Rectangle::new(bx, by, panel_w, bh)
  if gui_color_panel_hsv(panel_bounds, hsv) {
    result = true
  }
  // Hue bar
  let hue_bounds = @raylib.Rectangle::new(bx + panel_w + hue_pad, by, hue_w, bh)
  if gui_color_bar_hue(hue_bounds, hue) {
    hsv.val = { x: hue.val, y: hsv.val.y, z: hsv.val.z }
    result = true
  }
  // Alpha bar
  let alpha_bounds = @raylib.Rectangle::new(
    bx,
    by + bh + hue_pad,
    panel_w + hue_w + hue_pad,
    hue_w,
  )
  if gui_color_bar_alpha(alpha_bounds, alpha_val) {
    result = true
  }
  // Convert back to RGB
  if result {
    let rgb = convert_hsv_to_rgb(hsv.val)
    color.val = @raylib.Color::new(
      (rgb.x * 255.0).to_int(),
      (rgb.y * 255.0).to_int(),
      (rgb.z * 255.0).to_int(),
      (alpha_val.val * 255.0).to_int(),
    )
  }
  result
}
