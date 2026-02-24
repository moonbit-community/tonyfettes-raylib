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

// Draw text within bounds with alignment and wrapping support.
// Supports 3 wrap modes: TextWrapNone (truncate with ellipsis),
// TextWrapChar (wrap at character boundary), TextWrapWord (wrap at word boundary).

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
  let wrap_mode = gui_get_style(ControlDefault, TextWrapMode)
  let tb_x = text_bounds.x
  let tb_y = text_bounds.y
  let tb_w = text_bounds.width
  let tb_h = text_bounds.height
  // Parse icon from text
  let (icon_id, line_text) = get_text_icon(text)
  // Calculate icon dimensions
  let mut icon_offset_x : Float = 0.0
  if icon_id >= 0 {
    let icon_width = Float::from_int(RayguiIconSize * gui_globals.icon_scale)
    icon_offset_x = icon_width + Float::from_int(IconTextPadding)
  }
  // Load codepoints for per-character rendering
  let codepoints = @raylib.load_codepoints(line_text)
  let cp_count = codepoints.length()
  // Calculate font scale factor
  let base_size = @raylib.get_font_base_size(font)
  let scale_factor = if base_size > 0 {
    font_size / Float::from_int(base_size)
  } else {
    1.0
  }
  // Pixel-perfect vertical alignment offset
  let text_offset_y = if gui_get_style(ControlDefault, TextSize) % 2 == 0 {
    0
  } else {
    1
  }
  let line_height = Float::from_int(
    gui_get_style(ControlDefault, TextSize) + line_spacing,
  )
  // First pass: calculate lines for layout (needed for vertical alignment)
  // Each "line" is a range of codepoint indices [start, end) and its pixel width.
  let line_starts : Array[Int] = []
  let line_ends : Array[Int] = []
  let line_widths : Array[Float] = []
  if wrap_mode == TextWrapNone {
    // No wrapping: single line per newline
    let mut start = 0
    let mut w : Float = 0.0
    for i = 0; i < cp_count; i = i + 1 {
      let cp = codepoints[i]
      if cp == 10 {
        // Newline
        line_starts.push(start)
        line_ends.push(i)
        line_widths.push(w)
        start = i + 1
        w = 0.0
      } else {
        let glyph_info = @raylib.get_glyph_info(font, cp)
        let atlas_rec = @raylib.get_glyph_atlas_rec(font, cp)
        let glyph_width = if glyph_info.advance_x == 0 {
          atlas_rec.width * scale_factor + spacing
        } else {
          Float::from_int(glyph_info.advance_x) * scale_factor + spacing
        }
        w = w + glyph_width
      }
    }
    line_starts.push(start)
    line_ends.push(cp_count)
    line_widths.push(w)
  } else if wrap_mode == TextWrapChar {
    // Wrap at character boundary
    let effective_w = tb_w - icon_offset_x
    let mut start = 0
    let mut w : Float = 0.0
    for i = 0; i < cp_count; i = i + 1 {
      let cp = codepoints[i]
      if cp == 10 {
        line_starts.push(start)
        line_ends.push(i)
        line_widths.push(w)
        start = i + 1
        w = 0.0
      } else {
        let glyph_info = @raylib.get_glyph_info(font, cp)
        let atlas_rec = @raylib.get_glyph_atlas_rec(font, cp)
        let glyph_width = if glyph_info.advance_x == 0 {
          atlas_rec.width * scale_factor + spacing
        } else {
          Float::from_int(glyph_info.advance_x) * scale_factor + spacing
        }
        if w + glyph_width > effective_w && i > start {
          line_starts.push(start)
          line_ends.push(i)
          line_widths.push(w)
          start = i
          w = glyph_width
        } else {
          w = w + glyph_width
        }
      }
    }
    line_starts.push(start)
    line_ends.push(cp_count)
    line_widths.push(w)
  } else {
    // TextWrapWord: wrap at word boundary
    let effective_w = tb_w - icon_offset_x
    let mut start = 0
    let mut w : Float = 0.0
    let mut last_space = -1
    let mut w_at_last_space : Float = 0.0
    for i = 0; i < cp_count; i = i + 1 {
      let cp = codepoints[i]
      if cp == 10 {
        line_starts.push(start)
        line_ends.push(i)
        line_widths.push(w)
        start = i + 1
        w = 0.0
        last_space = -1
        w_at_last_space = 0.0
      } else {
        if cp == 32 {
          last_space = i
          w_at_last_space = w
        }
        let glyph_info = @raylib.get_glyph_info(font, cp)
        let atlas_rec = @raylib.get_glyph_atlas_rec(font, cp)
        let glyph_width = if glyph_info.advance_x == 0 {
          atlas_rec.width * scale_factor + spacing
        } else {
          Float::from_int(glyph_info.advance_x) * scale_factor + spacing
        }
        if w + glyph_width > effective_w && i > start {
          if last_space >= start {
            // Wrap at the last space
            line_starts.push(start)
            line_ends.push(last_space)
            line_widths.push(w_at_last_space)
            start = last_space + 1
            // Recalculate width from new start to current position
            let mut new_w : Float = 0.0
            for j = start; j < i; j = j + 1 {
              let cp_j = codepoints[j]
              let gi_j = @raylib.get_glyph_info(font, cp_j)
              let ar_j = @raylib.get_glyph_atlas_rec(font, cp_j)
              let gw_j = if gi_j.advance_x == 0 {
                ar_j.width * scale_factor + spacing
              } else {
                Float::from_int(gi_j.advance_x) * scale_factor + spacing
              }
              new_w = new_w + gw_j
            }
            w = new_w + glyph_width
            last_space = -1
            w_at_last_space = 0.0
          } else {
            // No space found, wrap at character boundary as fallback
            line_starts.push(start)
            line_ends.push(i)
            line_widths.push(w)
            start = i
            w = glyph_width
            last_space = -1
            w_at_last_space = 0.0
          }
        } else {
          w = w + glyph_width
        }
      }
    }
    line_starts.push(start)
    line_ends.push(cp_count)
    line_widths.push(w)
  }
  let line_count = line_starts.length()
  let total_height = Float::from_int(
    gui_get_style(ControlDefault, TextSize),
  ) + Float::from_int(line_count - 1) * line_height
  // Second pass: render each line
  for line_idx = 0; line_idx < line_count; line_idx = line_idx + 1 {
    let l_start = line_starts[line_idx]
    let l_end = line_ends[line_idx]
    let l_width = line_widths[line_idx]
    // Include icon width in total line width for first line
    let total_line_w = if line_idx == 0 && icon_id >= 0 {
      l_width + icon_offset_x
    } else {
      l_width
    }
    // Horizontal alignment
    let mut bx : Float = tb_x
    if alignment == TextAlignCenter {
      bx = tb_x + tb_w / 2.0 - total_line_w / 2.0
    } else if alignment == TextAlignRight {
      bx = tb_x + tb_w - total_line_w
    }
    if total_line_w > tb_w {
      bx = tb_x
    }
    // Vertical alignment
    let pos_offset_y = Float::from_int(line_idx) * line_height
    let mut by : Float = tb_y + pos_offset_y + Float::from_int(text_offset_y)
    if alignment_vertical == TextAlignMiddle {
      by = tb_y + pos_offset_y + tb_h / 2.0 - total_height / 2.0 + Float::from_int(
        text_offset_y,
      )
    } else if alignment_vertical == TextAlignBottom {
      by = tb_y + pos_offset_y + tb_h - total_height + Float::from_int(
        text_offset_y,
      )
    }
    // Pixel-perfect snap
    bx = Float::from_int(bx.to_int())
    by = Float::from_int(by.to_int())
    // Draw icon on the first line if present
    if line_idx == 0 && icon_id >= 0 {
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
    // Draw codepoints for this line
    if l_end > l_start {
      if wrap_mode == TextWrapNone {
        // Check if text needs truncation with ellipsis
        let effective_w = if line_idx == 0 && icon_id >= 0 {
          tb_w - icon_offset_x
        } else {
          tb_w
        }
        if l_width > effective_w && l_end > l_start {
          // Need to truncate: find how many codepoints fit, then replace last 3 with "..."
          let mut accum_w : Float = 0.0
          let mut fit_count = 0
          // Measure the width of "..."
          let dot_info = @raylib.get_glyph_info(font, 46) // '.'
          let dot_atlas = @raylib.get_glyph_atlas_rec(font, 46)
          let dot_width = if dot_info.advance_x == 0 {
            dot_atlas.width * scale_factor + spacing
          } else {
            Float::from_int(dot_info.advance_x) * scale_factor + spacing
          }
          let ellipsis_w = dot_width * 3.0
          for i = l_start; i < l_end; i = i + 1 {
            let cp = codepoints[i]
            let glyph_info = @raylib.get_glyph_info(font, cp)
            let atlas_rec = @raylib.get_glyph_atlas_rec(font, cp)
            let glyph_width = if glyph_info.advance_x == 0 {
              atlas_rec.width * scale_factor + spacing
            } else {
              Float::from_int(glyph_info.advance_x) * scale_factor + spacing
            }
            if accum_w + glyph_width + ellipsis_w > effective_w {
              break
            }
            accum_w = accum_w + glyph_width
            fit_count = fit_count + 1
          }
          // Draw the codepoints that fit
          let mut cx = bx
          for i = l_start; i < l_start + fit_count; i = i + 1 {
            let cp = codepoints[i]
            let glyph_info = @raylib.get_glyph_info(font, cp)
            let atlas_rec = @raylib.get_glyph_atlas_rec(font, cp)
            let glyph_width = if glyph_info.advance_x == 0 {
              atlas_rec.width * scale_factor + spacing
            } else {
              Float::from_int(glyph_info.advance_x) * scale_factor + spacing
            }
            if cp != 32 {
              let pos = @raylib.Vector2::new(cx, by)
              @raylib.draw_text_codepoint(
                font,
                cp,
                pos,
                font_size,
                gui_fade(tint, alpha),
              )
            }
            cx = cx + glyph_width
          }
          // Draw "..."
          for dot_i = 0; dot_i < 3; dot_i = dot_i + 1 {
            let pos = @raylib.Vector2::new(cx, by)
            @raylib.draw_text_codepoint(
              font,
              46,
              pos,
              font_size,
              gui_fade(tint, alpha),
            )
            cx = cx + dot_width
          }
        } else {
          // Text fits, draw normally
          let mut cx = bx
          for i = l_start; i < l_end; i = i + 1 {
            let cp = codepoints[i]
            let glyph_info = @raylib.get_glyph_info(font, cp)
            let atlas_rec = @raylib.get_glyph_atlas_rec(font, cp)
            let glyph_width = if glyph_info.advance_x == 0 {
              atlas_rec.width * scale_factor + spacing
            } else {
              Float::from_int(glyph_info.advance_x) * scale_factor + spacing
            }
            if cp != 32 {
              let pos = @raylib.Vector2::new(cx, by)
              @raylib.draw_text_codepoint(
                font,
                cp,
                pos,
                font_size,
                gui_fade(tint, alpha),
              )
            }
            cx = cx + glyph_width
          }
        }
      } else {
        // Wrapping modes: draw all codepoints in the line range
        let mut cx = bx
        for i = l_start; i < l_end; i = i + 1 {
          let cp = codepoints[i]
          let glyph_info = @raylib.get_glyph_info(font, cp)
          let atlas_rec = @raylib.get_glyph_atlas_rec(font, cp)
          let glyph_width = if glyph_info.advance_x == 0 {
            atlas_rec.width * scale_factor + spacing
          } else {
            Float::from_int(glyph_info.advance_x) * scale_factor + spacing
          }
          if cp != 32 {
            let pos = @raylib.Vector2::new(cx, by)
            @raylib.draw_text_codepoint(
              font,
              cp,
              pos,
              font_size,
              gui_fade(tint, alpha),
            )
          }
          cx = cx + glyph_width
        }
      }
    }
  }
}

// Draw tooltip below the given control rectangle if tooltips are enabled.

///|
pub fn gui_tooltip(control_rec : @raylib.Rectangle) -> Unit {
  if not(gui_globals.tooltip) {
    return
  }
  match gui_globals.tooltip_ptr {
    None => ()
    Some(tooltip_text) => {
      if tooltip_text.length() == 0 {
        return
      }
      // Calculate tooltip position below control
      let tp = Float::from_int(gui_get_style(ControlDefault, TextPadding))
      let ts = Float::from_int(gui_get_style(ControlDefault, TextSize))
      let tw = Float::from_int(gui_get_text_width(tooltip_text))
      let th = ts + tp * 2.0
      let tooltip_w = tw + tp * 2.0
      let mut tx = control_rec.x
      let mut ty = control_rec.y + control_rec.height + tp
      // Adjust if off-screen
      let screen_w = Float::from_int(@raylib.get_screen_width())
      let screen_h = Float::from_int(@raylib.get_screen_height())
      if tx + tooltip_w > screen_w {
        tx = screen_w - tooltip_w
      }
      if ty + th > screen_h {
        ty = control_rec.y - th - tp
      }
      let tooltip_bounds = @raylib.Rectangle::new(tx, ty, tooltip_w, th)
      gui_panel(tooltip_bounds, "")
      let text_bounds = @raylib.Rectangle::new(tx + tp, ty + tp, tw, ts)
      gui_draw_text(
        tooltip_text,
        text_bounds,
        TextAlignLeft,
        get_color(gui_get_style(ControlDefault, TextColorNormal)),
      )
    }
  }
}
