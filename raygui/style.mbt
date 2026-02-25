// raygui style system
// Style array: 16 controls * (16 base + 8 extended) = 384 entries

///|
let gui_style : FixedArray[Int] = FixedArray::make(
  max_controls * (max_props_base + max_props_extended),
  0,
)

// Set control style property value

///|
pub fn gui_set_style(control : Int, property : Int, value : Int) -> Unit {
  if not(gui_globals.style_loaded) {
    gui_load_style_default()
  }
  gui_style[control * (max_props_base + max_props_extended) + property] = value
  // Default properties are propagated to all controls
  if control == 0 && property < max_props_base {
    for i = 1; i < max_controls; i = i + 1 {
      gui_style[i * (max_props_base + max_props_extended) + property] = value
    }
  }
}

// Get control style property value

///|
pub fn gui_get_style(control : Int, property : Int) -> Int {
  if not(gui_globals.style_loaded) {
    gui_load_style_default()
  }
  gui_style[control * (max_props_base + max_props_extended) + property]
}

// Load default style values

///|
pub fn gui_load_style_default() -> Unit {
  // Set flag first to avoid cyclic calls
  gui_globals.style_loaded = true
  // Default LIGHT style base colors
  gui_set_style(ControlDefault, BorderColorNormal, 0x838383ff)
  gui_set_style(ControlDefault, BaseColorNormal, 0xc9c9c9ff)
  gui_set_style(ControlDefault, TextColorNormal, 0x686868ff)
  gui_set_style(ControlDefault, BorderColorFocused, 0x5bb2d9ff)
  gui_set_style(ControlDefault, BaseColorFocused, 0xc9effeff)
  gui_set_style(ControlDefault, TextColorFocused, 0x6c9bbcff)
  gui_set_style(ControlDefault, BorderColorPressed, 0x0492c7ff)
  gui_set_style(ControlDefault, BaseColorPressed, 0x97e8ffff)
  gui_set_style(ControlDefault, TextColorPressed, 0x368bafff)
  gui_set_style(ControlDefault, BorderColorDisabled, 0xb5c1c2ff)
  gui_set_style(ControlDefault, BaseColorDisabled, 0xe6e9e9ff)
  gui_set_style(ControlDefault, TextColorDisabled, 0xaeb7b8ff)
  gui_set_style(ControlDefault, BorderWidth, 1)
  gui_set_style(ControlDefault, TextPadding, 0)
  gui_set_style(ControlDefault, TextAlignment, TextAlignCenter)
  // Default extended properties
  gui_set_style(ControlDefault, TextSize, 10)
  gui_set_style(ControlDefault, TextSpacing, 1)
  gui_set_style(ControlDefault, LineColor, 0x90abb5ff)
  gui_set_style(ControlDefault, BackgroundColor, 0xf5f5f5ff)
  gui_set_style(ControlDefault, TextLineSpacing, 5)
  gui_set_style(ControlDefault, TextAlignmentVertical, TextAlignMiddle)
  // Control-specific property overrides
  gui_set_style(ControlLabel, TextAlignment, TextAlignLeft)
  gui_set_style(ControlButton, BorderWidth, 2)
  gui_set_style(ControlSlider, TextPadding, 4)
  gui_set_style(ControlProgressbar, TextPadding, 4)
  gui_set_style(ControlCheckbox, TextPadding, 4)
  gui_set_style(ControlCheckbox, TextAlignment, TextAlignRight)
  gui_set_style(ControlDropdownbox, TextPadding, 0)
  gui_set_style(ControlDropdownbox, TextAlignment, TextAlignCenter)
  gui_set_style(ControlTextbox, TextPadding, 4)
  gui_set_style(ControlTextbox, TextAlignment, TextAlignLeft)
  gui_set_style(ControlValuebox, TextPadding, 0)
  gui_set_style(ControlValuebox, TextAlignment, TextAlignLeft)
  gui_set_style(ControlStatusbar, TextPadding, 8)
  gui_set_style(ControlStatusbar, TextAlignment, TextAlignLeft)
  // Extended property values
  gui_set_style(ControlToggle, GroupPadding, 2)
  gui_set_style(ControlSlider, SliderWidth, 16)
  gui_set_style(ControlSlider, SliderPadding, 1)
  gui_set_style(ControlProgressbar, ProgressPadding, 1)
  gui_set_style(ControlCheckbox, CheckPadding, 1)
  gui_set_style(ControlCombobox, ComboButtonWidth, 32)
  gui_set_style(ControlCombobox, ComboButtonSpacing, 2)
  gui_set_style(ControlDropdownbox, ArrowPadding, 16)
  gui_set_style(ControlDropdownbox, DropdownItemsSpacing, 2)
  gui_set_style(ControlValuebox, SpinnerButtonWidth, 24)
  gui_set_style(ControlValuebox, SpinnerButtonSpacing, 2)
  gui_set_style(ControlScrollbar, BorderWidth, 0)
  gui_set_style(ControlScrollbar, ArrowsVisible, 0)
  gui_set_style(ControlScrollbar, ArrowsSize, 6)
  gui_set_style(ControlScrollbar, ScrollSliderPadding, 0)
  gui_set_style(ControlScrollbar, ScrollSliderSize, 16)
  gui_set_style(ControlScrollbar, ScrollPadding, 0)
  gui_set_style(ControlScrollbar, ScrollSpeed, 12)
  gui_set_style(ControlListview, ListItemsHeight, 28)
  gui_set_style(ControlListview, ListItemsSpacing, 2)
  gui_set_style(ControlListview, ListItemsBorderWidth, 1)
  gui_set_style(ControlListview, ScrollbarWidth, 12)
  gui_set_style(ControlListview, ScrollbarSide, ScrollbarRightSide)
  gui_set_style(ControlColorpicker, ColorSelectorSize, 8)
  gui_set_style(ControlColorpicker, HuebarWidth, 16)
  gui_set_style(ControlColorpicker, HuebarPadding, 8)
  gui_set_style(ControlColorpicker, HuebarSelectorHeight, 8)
  gui_set_style(ControlColorpicker, HuebarSelectorOverflow, 2)
  // Initialize font
  gui_globals.font = Some(@raylib.get_font_default())
}

// ============================================================================
// Byte-reading helpers for binary style parsing
// ============================================================================

///|
fn style_read_short(b : Bytes, off : Int) -> Int {
  let v = b[off].to_int() | (b[off + 1].to_int() << 8)
  if v >= 0x8000 {
    v - 0x10000
  } else {
    v
  }
}

///|
fn style_read_ushort(b : Bytes, off : Int) -> Int {
  b[off].to_int() | (b[off + 1].to_int() << 8)
}

///|
fn style_read_int(b : Bytes, off : Int) -> Int {
  b[off].to_int() |
  (b[off + 1].to_int() << 8) |
  (b[off + 2].to_int() << 16) |
  (b[off + 3].to_int() << 24)
}

// ============================================================================
// Text format parsing helpers
// ============================================================================

///|
fn skip_spaces(s : String, pos : Int) -> Int {
  let mut p = pos
  while p < s.length() && (s[p] == ' ' || s[p] == '\t') {
    p = p + 1
  }
  p
}

///|
fn parse_word(s : String, pos : Int) -> (String, Int) {
  let start = pos
  let mut p = pos
  while p < s.length() &&
        s[p] != ' ' &&
        s[p] != '\t' &&
        s[p] != '\n' &&
        s[p] != '\r' {
    p = p + 1
  }
  (string_sub(s, start, p), p)
}

///|
fn parse_int_at(s : String, pos : Int) -> (Int, Int) {
  let p = skip_spaces(s, pos)
  let mut result = 0
  let mut negative = false
  let mut i = p
  if i < s.length() && s[i] == '-' {
    negative = true
    i = i + 1
  } else if i < s.length() && s[i] == '+' {
    i = i + 1
  }
  while i < s.length() && s[i] >= '0' && s[i] <= '9' {
    result = result * 10 + (s[i].to_int() - 48)
    i = i + 1
  }
  if negative {
    (-result, i)
  } else {
    (result, i)
  }
}

///|
fn parse_hex_at(s : String, pos : Int) -> (Int, Int) {
  let p = skip_spaces(s, pos)
  let mut i = p
  // Skip "0x" or "0X" prefix
  if i + 1 < s.length() && s[i] == '0' && (s[i + 1] == 'x' || s[i + 1] == 'X') {
    i = i + 2
  }
  let mut result = 0
  while i < s.length() {
    let c = s[i].to_int()
    if c >= 48 && c <= 57 {
      result = (result << 4) | (c - 48)
    } else if c >= 65 && c <= 70 {
      result = (result << 4) | (c - 55)
    } else if c >= 97 && c <= 102 {
      result = (result << 4) | (c - 87)
    } else {
      break
    }
    i = i + 1
  }
  (result, i)
}

// ============================================================================
// Style loading: main entry point
// ============================================================================

// Load raygui style from file (.rgs format, text or binary)

///|
pub fn gui_load_style(file_name : String) -> Unit {
  let data = @raylib.load_file_data(file_name)
  if data.length() < 4 {
    return
  }
  // Check binary signature "rGS "
  if data[0] == b'r' && data[1] == b'G' && data[2] == b'S' && data[3] == b' ' {
    gui_load_style_from_binary(data)
  } else {
    // Text format
    let text = @raylib.load_file_text(file_name)
    if text.length() > 0 {
      gui_load_style_from_text(text)
    }
  }
}

// ============================================================================
// Style loading: text format parser
// ============================================================================

// Parse text format style file.
// Lines are:
//   p <control> <property> 0x<value>   -- property
//   f <size> <spacing> <font_file>     -- font
//   # comment                          -- comment (ignored)

///|
fn gui_load_style_from_text(text : String) -> Unit {
  let lines = get_text_lines(text)
  for i = 0; i < lines.length(); i = i + 1 {
    let line = lines[i]
    if line.length() == 0 {
      continue
    }
    let first_char = line[0]
    // Skip comments and empty lines
    if first_char == '#' || first_char == '\r' {
      continue
    }
    if first_char == 'p' {
      // Property: p <control> <property> 0x<value>
      let (_, p1) = parse_word(line, 0) // skip 'p'
      let (ctrl, p2) = parse_int_at(line, p1)
      let (prop, p3) = parse_int_at(line, p2)
      let (value, _) = parse_hex_at(line, p3)
      gui_set_style(ctrl, prop, value)
    } else if first_char == 'f' {
      // Font: f <size> <spacing> <font_file>
      let (_, p1) = parse_word(line, 0) // skip 'f'
      let (font_size, p2) = parse_int_at(line, p1)
      let (_, p3) = parse_int_at(line, p2) // spacing (used below via style)
      let p4 = skip_spaces(line, p3)
      let (font_file, _) = parse_word(line, p4)
      if font_file.length() > 0 {
        let font = @raylib.load_font_ex(font_file, font_size)
        if @raylib.is_font_valid(font) {
          gui_set_font(font)
          gui_set_style(ControlDefault, TextSize, font_size)
        }
      }
    }
  }
  gui_globals.style_loaded = true
}

// ============================================================================
// Style loading: binary format parser
// ============================================================================

// Parse binary format style file (.rgs binary).
// Header: "rGS " (4 bytes), version (2), reserved (2), prop_count (2), reserved (2)
// Properties: prop_count * { control_id (2), property_id (2), property_value (4) }
// Optionally followed by embedded font data (not yet implemented).

///|
fn bytes_sub(b : Bytes, start : Int, length : Int) -> Bytes {
  Bytes::makei(length, fn(i) { b[start + i] })
}

///|
fn gui_load_style_from_binary(data : Bytes) -> Unit {
  if data.length() < 12 {
    return
  }
  let mut offset = 4 // skip "rGS " signature
  let version = style_read_short(data, offset)
  offset = offset + 2
  let _reserved = style_read_short(data, offset)
  offset = offset + 2
  let prop_count = style_read_int(data, offset)
  offset = offset + 4
  // Read properties
  for i = 0; i < prop_count; i = i + 1 {
    if offset + 8 > data.length() {
      break
    }
    let control_id = style_read_ushort(data, offset)
    offset = offset + 2
    let property_id = style_read_ushort(data, offset)
    offset = offset + 2
    let property_value = style_read_int(data, offset)
    offset = offset + 4
    gui_set_style(control_id, property_id, property_value)
  }
  // Load embedded font if present
  if offset + 4 <= data.length() {
    let font_data_size = style_read_int(data, offset)
    offset = offset + 4
    if font_data_size > 0 && offset + 12 <= data.length() {
      let base_size = style_read_int(data, offset)
      let glyph_count = style_read_int(data, offset + 4)
      let font_type = style_read_int(data, offset + 8)
      offset = offset + 12
      // Skip font white rectangle (16 bytes: x, y, w, h as floats)
      if offset + 16 <= data.length() {
        offset = offset + 16
      }
      // Read image parameters
      if offset + 8 <= data.length() {
        let img_uncomp_size = style_read_int(data, offset)
        let img_comp_size = style_read_int(data, offset + 4)
        offset = offset + 8
        if offset + 12 <= data.length() {
          let img_width = style_read_int(data, offset)
          let img_height = style_read_int(data, offset + 4)
          let img_format = style_read_int(data, offset + 8)
          offset = offset + 12
          // Read pixel data (compressed or uncompressed)
          let pixel_data : Bytes = if img_comp_size > 0 &&
            img_comp_size != img_uncomp_size {
            // Compressed
            if offset + img_comp_size <= data.length() {
              let comp_data = bytes_sub(data, offset, img_comp_size)
              offset = offset + img_comp_size
              @raylib.decompress_data(comp_data)
            } else {
              Bytes::make(0, b'\x00')
            }
            // Uncompressed
          } else if offset + img_uncomp_size <= data.length() {
            let raw = bytes_sub(data, offset, img_uncomp_size)
            offset = offset + img_uncomp_size
            raw
          } else {
            Bytes::make(0, b'\x00')
          }
          if pixel_data.length() > 0 {
            // Read glyph recs data (16 bytes per glyph: x, y, w, h as floats)
            let recs_data_size = glyph_count * 16
            let mut recs_data_comp_size = 0
            if version >= 400 && offset + 4 <= data.length() {
              recs_data_comp_size = style_read_int(data, offset)
              offset = offset + 4
            }
            let recs_data : Bytes = if recs_data_comp_size > 0 &&
              recs_data_comp_size != recs_data_size {
              if offset + recs_data_comp_size <= data.length() {
                let comp = bytes_sub(data, offset, recs_data_comp_size)
                offset = offset + recs_data_comp_size
                @raylib.decompress_data(comp)
              } else {
                Bytes::make(0, b'\x00')
              }
            } else if offset + recs_data_size <= data.length() {
              let raw = bytes_sub(data, offset, recs_data_size)
              offset = offset + recs_data_size
              raw
            } else {
              Bytes::make(0, b'\x00')
            }
            // Read glyph info data (16 bytes per glyph: value, offsetX, offsetY, advanceX as ints)
            let glyphs_data_size = glyph_count * 16
            let mut glyphs_data_comp_size = 0
            if version >= 400 && offset + 4 <= data.length() {
              glyphs_data_comp_size = style_read_int(data, offset)
              offset = offset + 4
            }
            let glyphs_data : Bytes = if glyphs_data_comp_size > 0 &&
              glyphs_data_comp_size != glyphs_data_size {
              if offset + glyphs_data_comp_size <= data.length() {
                let comp = bytes_sub(data, offset, glyphs_data_comp_size)
                let _ = offset + glyphs_data_comp_size
                @raylib.decompress_data(comp)
              } else {
                Bytes::make(0, b'\x00')
              }
            } else if offset + glyphs_data_size <= data.length() {
              let raw = bytes_sub(data, offset, glyphs_data_size)
              let _ = offset + glyphs_data_size
              raw
            } else {
              Bytes::make(0, b'\x00')
            }
            if recs_data.length() >= recs_data_size &&
              glyphs_data.length() >= glyphs_data_size {
              let font = @raylib.load_font_from_atlas(
                pixel_data,
                pixel_data.length(),
                img_width,
                img_height,
                img_format,
                base_size,
                glyph_count,
                font_type,
                recs_data,
                glyphs_data,
              )
              if @raylib.is_font_valid(font) {
                gui_set_font(font)
                gui_set_style(ControlDefault, TextSize, base_size)
              }
            }
          }
        }
      }
    }
  }
  gui_globals.style_loaded = true
}
