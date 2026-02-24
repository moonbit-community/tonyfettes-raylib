// Internal drawing helpers for raygui controls

// Draw rectangle with border and fill using raygui style
///|
fn gui_draw_rectangle(
  rec : @raylib.Rectangle,
  border_width : Int,
  border_color : @raylib.Color,
  color : @raylib.Color,
) -> Unit {
  let alpha = gui_globals.alpha
  let rx = rec.x.to_int()
  let ry = rec.y.to_int()
  let rw = rec.width.to_int()
  let rh = rec.height.to_int()
  // Draw fill
  if color.a > b'\x00' {
    @raylib.draw_rectangle(rx, ry, rw, rh, gui_fade(color, alpha))
  }
  // Draw border
  if border_width > 0 {
    // Top
    @raylib.draw_rectangle(
      rx,
      ry,
      rw,
      border_width,
      gui_fade(border_color, alpha),
    )
    // Left
    @raylib.draw_rectangle(
      rx,
      ry + border_width,
      border_width,
      rh - 2 * border_width,
      gui_fade(border_color, alpha),
    )
    // Right
    @raylib.draw_rectangle(
      rx + rw - border_width,
      ry + border_width,
      border_width,
      rh - 2 * border_width,
      gui_fade(border_color, alpha),
    )
    // Bottom
    @raylib.draw_rectangle(
      rx,
      ry + rh - border_width,
      rw,
      border_width,
      gui_fade(border_color, alpha),
    )
  }
}

// Get text bounds considering control bounds, border and padding

///|
fn get_text_bounds(
  control : Int,
  bounds : @raylib.Rectangle,
) -> @raylib.Rectangle {
  let bw = gui_get_style(control, BorderWidth)
  let tp = gui_get_style(control, TextPadding)
  let mut tx = bounds.x + Float::from_int(bw)
  let ty = bounds.y + Float::from_int(bw + tp)
  let tw = bounds.width - Float::from_int(2 * bw + 2 * tp)
  let th = bounds.height - Float::from_int(2 * bw + 2 * tp)
  // Adjust for text alignment
  if gui_get_style(control, TextAlignment) == TextAlignRight {
    tx = tx - Float::from_int(tp)
  } else {
    tx = tx + Float::from_int(tp)
  }
  @raylib.Rectangle::new(tx, ty, tw, th)
}

// Draw text within bounds with alignment (simplified: no per-character rendering)

///|
fn gui_draw_text(
  text : String,
  text_bounds : @raylib.Rectangle,
  alignment : Int,
  tint : @raylib.Color,
) -> Unit {
  if text.length() == 0 {
    return
  }
  let alpha = gui_globals.alpha
  let font = gui_get_font()
  let font_size = Float::from_int(gui_get_style(ControlDefault, TextSize))
  let spacing = Float::from_int(gui_get_style(ControlDefault, TextSpacing))
  let line_spacing = gui_get_style(ControlDefault, TextLineSpacing)
  let alignment_vertical = gui_get_style(ControlDefault, TextAlignmentVertical)
  let tb_x = text_bounds.x
  let tb_y = text_bounds.y
  let tb_w = text_bounds.width
  let tb_h = text_bounds.height
  // Split text into lines
  let lines = get_text_lines(text)
  let line_count = lines.length()
  let total_height : Float = Float::from_int(
    line_count * gui_get_style(ControlDefault, TextSize) +
    (line_count - 1) * line_spacing,
  )
  let mut pos_offset_y : Float = 0.0
  for i = 0; i < line_count; i = i + 1 {
    let (icon_id, line_text) = get_text_icon(lines[i])
    // Measure text size
    let text_size = @raylib.measure_text_ex(font, line_text, font_size, spacing)
    let mut text_size_x : Float = text_size.x
    // Add icon size if needed
    let mut icon_offset_x : Float = 0.0
    if icon_id >= 0 {
      let icon_width = Float::from_int(RayguiIconSize * gui_globals.icon_scale)
      text_size_x = text_size_x + icon_width
      if line_text.length() > 0 {
        text_size_x = text_size_x + Float::from_int(IconTextPadding)
      }
      icon_offset_x = icon_width + Float::from_int(IconTextPadding)
    }
    // Horizontal alignment
    let mut bx : Float = tb_x
    if alignment == TextAlignCenter {
      bx = tb_x + tb_w / 2.0 - text_size_x / 2.0
    } else if alignment == TextAlignRight {
      bx = tb_x + tb_w - text_size_x
    }
    if text_size_x > tb_w {
      bx = tb_x
    }
    // Vertical alignment
    let mut by : Float = tb_y + pos_offset_y
    if alignment_vertical == TextAlignMiddle {
      by = tb_y + pos_offset_y + tb_h / 2.0 - total_height / 2.0
    } else if alignment_vertical == TextAlignBottom {
      by = tb_y + pos_offset_y + tb_h - total_height
    }
    // Pixel-perfect snap
    bx = Float::from_int(bx.to_int())
    by = Float::from_int(by.to_int())
    // Draw icon if present
    if icon_id >= 0 {
      let icon_y : Float = tb_y +
        tb_h / 2.0 -
        Float::from_int(RayguiIconSize * gui_globals.icon_scale) / 2.0
      gui_draw_icon(
        icon_id,
        bx.to_int(),
        icon_y.to_int(),
        gui_globals.icon_scale,
        gui_fade(tint, alpha),
      )
      bx = bx + icon_offset_x
    }
    // Draw text line
    if line_text.length() > 0 {
      let pos = @raylib.Vector2::new(bx, by)
      @raylib.draw_text_ex(
        font,
        line_text,
        pos,
        font_size,
        spacing,
        gui_fade(tint, alpha),
      )
    }
    pos_offset_y = pos_offset_y +
      Float::from_int(gui_get_style(ControlDefault, TextSize) + line_spacing)
  }
}
