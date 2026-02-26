// Re-export passthrough functions from internal FFI layer

///|
pub using @ffi {
  type Font,
  type GlyphInfoArray,
  get_font_default,
  get_font_base_size,
  get_font_glyph_count,
  get_font_glyph_padding,
  get_font_texture,
  gen_font_texture_mipmaps,
  set_font_texture_filter,
  is_font_valid,
  unload_font,
  draw_fps,
  set_text_line_spacing,
  get_glyph_index,
  unload_font_data,
  glyph_info_array_count,
}

// ============================================================================
// Font loading (wrappers)
// ============================================================================

///|
pub fn load_font(file_name : String) -> Font {
  @ffi.load_font(@utf8.encode(file_name))
}

///|
pub fn load_font_ex(file_name : String, font_size : Int) -> Font {
  @ffi.load_font_ex(@utf8.encode(file_name), font_size)
}

///|
pub fn load_font_ex_codepoints(
  file_name : String,
  font_size : Int,
  codepoints : Array[Int],
) -> Font {
  let buf = @buffer.new(size_hint=codepoints.length() * 4)
  for cp in codepoints {
    buf.write_int_le(cp)
  }
  let bytes = buf.to_bytes()
  @ffi.load_font_ex_codepoints(
    @utf8.encode(file_name),
    font_size,
    bytes,
    codepoints.length(),
  )
}

// ============================================================================
// Text drawing (wrappers)
// ============================================================================

///|
pub fn draw_text(
  text : String,
  pos_x : Int,
  pos_y : Int,
  font_size : Int,
  color : Color,
) -> Unit {
  @ffi.draw_text(
    @utf8.encode(text),
    pos_x,
    pos_y,
    font_size,
    color.to_bytes(),
  )
}

///|
pub fn draw_text_ex(
  font : Font,
  text : String,
  position : Vector2,
  font_size : Float,
  spacing : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_text_ex(
    font,
    @utf8.encode(text),
    position.to_bytes(),
    font_size,
    spacing,
    tint.to_bytes(),
  )
}

///|
pub fn draw_text_pro(
  font : Font,
  text : String,
  position : Vector2,
  origin : Vector2,
  rotation : Float,
  font_size : Float,
  spacing : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_text_pro(
    font,
    @utf8.encode(text),
    position.to_bytes(),
    origin.to_bytes(),
    rotation,
    font_size,
    spacing,
    tint.to_bytes(),
  )
}

// ============================================================================
// Text measurement (wrappers)
// ============================================================================

///|
pub fn measure_text(text : String, font_size : Int) -> Int {
  @ffi.measure_text(@utf8.encode(text), font_size)
}

///|
pub fn measure_text_ex(
  font : Font,
  text : String,
  font_size : Float,
  spacing : Float,
) -> Vector2 {
  Vector2::from_bytes(
    @ffi.measure_text_ex(font, @utf8.encode(text), font_size, spacing),
  )
}

// ============================================================================
// Text extras (wrappers)
// ============================================================================

///|
pub fn draw_text_codepoint(
  font : Font,
  codepoint : Int,
  position : Vector2,
  font_size : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_text_codepoint(
    font,
    codepoint,
    position.to_bytes(),
    font_size,
    tint.to_bytes(),
  )
}

///|
pub fn get_glyph_atlas_rec(font : Font, codepoint : Int) -> Rectangle {
  Rectangle::from_bytes(@ffi.get_glyph_atlas_rec(font, codepoint))
}

// ============================================================================
// Font loading extras (wrappers)
// ============================================================================

///|
pub fn load_font_from_image(
  image : Image,
  key : Color,
  first_char : Int,
) -> Font {
  @ffi.load_font_from_image(image, key.to_bytes(), first_char)
}

///|
pub fn load_font_from_memory(
  file_type : String,
  file_data : Bytes,
  data_size : Int,
  font_size : Int,
) -> Font {
  @ffi.load_font_from_memory(
    @utf8.encode(file_type),
    file_data,
    data_size,
    font_size,
  )
}

///|
pub fn load_font_from_atlas(
  pixel_data : Bytes,
  pixel_data_size : Int,
  img_width : Int,
  img_height : Int,
  img_format : Int,
  base_size : Int,
  glyph_count : Int,
  font_type : Int,
  recs_data : Bytes,
  glyphs_data : Bytes,
) -> Font {
  @ffi.load_font_from_atlas(
    pixel_data, pixel_data_size, img_width, img_height, img_format, base_size, glyph_count,
    font_type, recs_data, glyphs_data,
  )
}

///|
pub fn export_font_as_code(font : Font, file_name : String) -> Bool {
  @ffi.export_font_as_code(font, @utf8.encode(file_name))
}

// ============================================================================
// Text drawing extras (wrappers)
// ============================================================================

///|
pub fn draw_text_codepoints(
  font : Font,
  codepoints : Array[Int],
  position : Vector2,
  font_size : Float,
  spacing : Float,
  tint : Color,
) -> Unit {
  let buf = @buffer.new(size_hint=codepoints.length() * 4)
  for cp in codepoints {
    buf.write_int_le(cp)
  }
  let bytes = buf.to_bytes()
  @ffi.draw_text_codepoints(
    font,
    bytes,
    codepoints.length(),
    position.to_bytes(),
    font_size,
    spacing,
    tint.to_bytes(),
  )
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
  for i = 0; i < count; i = i + 1 {
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
// Text: GlyphInfo struct + advanced font wrappers
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

///|
pub fn get_glyph_info(font : Font, codepoint : Int) -> GlyphInfo {
  GlyphInfo::from_bytes(@ffi.get_glyph_info(font, codepoint))
}

///|
pub fn load_font_data(
  file_data : Bytes,
  data_size : Int,
  font_size : Int,
  font_type : Int,
) -> GlyphInfoArray {
  @ffi.load_font_data(file_data, data_size, font_size, font_type)
}

///|
pub fn glyph_info_array_get(glyphs : GlyphInfoArray, index : Int) -> GlyphInfo {
  GlyphInfo::from_bytes(@ffi.glyph_info_array_get(glyphs, index))
}

///|
pub fn gen_image_font_atlas(
  glyphs : GlyphInfoArray,
  font_size : Int,
  padding : Int,
  pack_method : Int,
) -> Image {
  @ffi.gen_image_font_atlas(glyphs, font_size, padding, pack_method)
}

///|
pub fn build_font_from_data(
  file_data : Bytes,
  data_size : Int,
  font_size : Int,
  font_type : Int,
  padding : Int,
  pack_method : Int,
) -> Font {
  @ffi.build_font_from_data(
    file_data, data_size, font_size, font_type, padding, pack_method,
  )
}

// Font data type constants

///|
pub const FontDefault : Int = 0

///|
pub const FontBitmap : Int = 1

///|
pub const FontSdf : Int = 2
