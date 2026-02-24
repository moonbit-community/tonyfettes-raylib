// Text utility functions for raygui

// Parse icon prefix from text (format: "#NNN#text")
// Returns (icon_id, text_after_icon). icon_id is -1 if no icon prefix.
///|
fn get_text_icon(text : String) -> (Int, String) {
  if text.length() == 0 || text[0] != '#' {
    return (-1, text)
  }
  let mut pos = 1
  while pos < 4 && pos < text.length() && text[pos] >= '0' && text[pos] <= '9' {
    pos = pos + 1
  }
  if pos < text.length() && text[pos] == '#' {
    // Parse the icon id number
    let mut icon_id = 0
    for i = 1; i < pos; i = i + 1 {
      icon_id = icon_id * 10 + (text[i].to_int() - '0'.to_int())
    }
    // Build remaining text after "#NNN#"
    let rest_start = pos + 1
    let buf = StringBuilder::new()
    for i = rest_start; i < text.length(); i = i + 1 {
      buf.write_char(Int::unsafe_to_char(text[i].to_int()))
    }
    (icon_id, buf.to_string())
  } else {
    (-1, text)
  }
}

// Get text with icon id prepended (format: "#NNN#text")

///|
pub fn gui_icon_text(icon_id : Int, text : String) -> String {
  let icon_str = if icon_id < 10 {
    "#00" + icon_id.to_string() + "#"
  } else if icon_id < 100 {
    "#0" + icon_id.to_string() + "#"
  } else {
    "#" + icon_id.to_string() + "#"
  }
  icon_str + text
}

// Get text width considering gui style (simplified: uses measure_text_ex)

///|
pub fn gui_get_text_width(text : String) -> Int {
  if text.length() == 0 {
    return 0
  }
  // Skip icon prefix if present
  let (icon_id, clean_text) = get_text_icon(text)
  let font = gui_get_font()
  let font_size = Float::from_int(gui_get_style(ControlDefault, TextSize))
  let spacing = Float::from_int(gui_get_style(ControlDefault, TextSpacing))
  let text_size = @raylib.measure_text_ex(font, clean_text, font_size, spacing)
  let mut width = text_size.x.to_int()
  if icon_id >= 0 {
    width = width + RayguiIconSize * gui_globals.icon_scale
    if clean_text.length() > 0 {
      width = width + IconTextPadding
    }
  }
  width
}

// Build a substring from start to end (exclusive) without using error-returning slice

///|
fn string_sub(s : String, start : Int, end : Int) -> String {
  let buf = StringBuilder::new()
  for i = start; i < end; i = i + 1 {
    buf.write_char(Int::unsafe_to_char(s[i].to_int()))
  }
  buf.to_string()
}

// Build a substring from start to end of string

///|
fn string_sub_from(s : String, start : Int) -> String {
  string_sub(s, start, s.length())
}

// Split text by ';' delimiter, returns array of substrings and row indices
// (raygui always uses ';' as delimiter, '\n' increments row)

///|
pub fn gui_text_split(text : String) -> (Array[String], Array[Int]) {
  let results : Array[String] = []
  let rows : Array[Int] = []
  let mut current_row = 0
  let mut start = 0
  for i = 0; i < text.length(); i = i + 1 {
    if text[i] == ';' || text[i] == '\n' {
      results.push(string_sub(text, start, i))
      rows.push(current_row)
      if text[i] == '\n' {
        current_row = current_row + 1
      }
      start = i + 1
    }
  }
  // Add remaining text
  results.push(string_sub_from(text, start))
  rows.push(current_row)
  (results, rows)
}

// Split text into lines by '\n'

///|
fn get_text_lines(text : String) -> Array[String] {
  let lines : Array[String] = []
  let mut start = 0
  for i = 0; i < text.length(); i = i + 1 {
    if text[i] == '\n' {
      lines.push(string_sub(text, start, i))
      start = i + 1
    }
  }
  lines.push(string_sub_from(text, start))
  lines
}
