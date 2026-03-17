// Re-export passthrough functions from internal FFI layer

///|
pub using @ffi {draw_fps, set_text_line_spacing}

// ============================================================================
// Text drawing (wrappers — default font, no resource type param)
// ============================================================================

///|
pub fn draw_text(
  text : String,
  pos_x : Int,
  pos_y : Int,
  font_size : Int,
  color : Color,
) -> Unit {
  @ffi.draw_text(@utf8.encode(text), pos_x, pos_y, font_size, color.to_bytes())
}

// ============================================================================
// Text measurement (wrappers — default font, no resource type param)
// ============================================================================

///|
pub fn measure_text(text : String, font_size : Int) -> Int {
  @ffi.measure_text(@utf8.encode(text), font_size)
}

// ============================================================================
// Text: Codepoint functions (wrappers)
// ============================================================================

///|
pub fn get_codepoint_count(text : String) -> Int {
  @ffi.get_codepoint_count(@utf8.encode(text))
}

///|
pub fn get_codepoint(text : String) -> (Int, Int) {
  let bytes = @ffi.get_codepoint(@utf8.encode(text))
  (read_int(bytes, 0), read_int(bytes, 4))
}

///|
pub fn get_codepoint_next(text : String) -> (Int, Int) {
  let bytes = @ffi.get_codepoint_next(@utf8.encode(text))
  (read_int(bytes, 0), read_int(bytes, 4))
}

///|
pub fn get_codepoint_previous(text : String) -> (Int, Int) {
  let bytes = @ffi.get_codepoint_previous(@utf8.encode(text))
  (read_int(bytes, 0), read_int(bytes, 4))
}

///|
pub fn codepoint_to_utf8(codepoint : Int) -> Bytes {
  @ffi.codepoint_to_utf8(codepoint)
}

///|
pub fn load_codepoints(text : String) -> Array[Int] {
  let bytes = @ffi.load_codepoints(@utf8.encode(text))
  if bytes.length() < 4 {
    return []
  }
  let count = read_int(bytes, 0)
  let result = Array::make(count, 0)
  for i in 0..<count {
    result[i] = read_int(bytes, 4 + i * 4)
  }
  result
}

///|
pub fn load_utf8(codepoints : Array[Int]) -> Bytes {
  let buf = @buffer.new(size_hint=codepoints.length() * 4)
  for cp in codepoints {
    buf.write_int_le(cp)
  }
  let bytes = buf.to_bytes()
  @ffi.load_utf8(bytes, codepoints.length())
}

// ============================================================================
// Text: GlyphInfo struct
// ============================================================================

///|
pub struct GlyphInfo {
  value : Int
  offset_x : Int
  offset_y : Int
  advance_x : Int
} derive(Eq, Show)

///|
pub fn GlyphInfo::from_bytes(b : Bytes) -> GlyphInfo {
  {
    value: read_int(b, 0),
    offset_x: read_int(b, 4),
    offset_y: read_int(b, 8),
    advance_x: read_int(b, 12),
  }
}

// Font data type constants

///|
pub const FontDefault : Int = 0

///|
pub const FontBitmap : Int = 1

///|
pub const FontSdf : Int = 2
