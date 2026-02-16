// Re-export passthrough functions from internal FFI layer

///|
pub using @raylib {
  type Font,
  get_font_default,
  is_font_valid,
  unload_font,
  draw_fps,
  set_text_line_spacing,
  get_glyph_index,
}

// ============================================================================
// Font loading (wrappers)
// ============================================================================

///|
pub fn load_font(file_name : String) -> Font {
  @raylib.load_font(@utf8.encode(file_name))
}

///|
pub fn load_font_ex(file_name : String, font_size : Int) -> Font {
  @raylib.load_font_ex(@utf8.encode(file_name), font_size)
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
  @raylib.draw_text(
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
  @raylib.draw_text_ex(
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
  @raylib.draw_text_pro(
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
  @raylib.measure_text(@utf8.encode(text), font_size)
}

///|
pub fn measure_text_ex(
  font : Font,
  text : String,
  font_size : Float,
  spacing : Float,
) -> Vector2 {
  Vector2::from_bytes(
    @raylib.measure_text_ex(font, @utf8.encode(text), font_size, spacing),
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
  @raylib.draw_text_codepoint(
    font,
    codepoint,
    position.to_bytes(),
    font_size,
    tint.to_bytes(),
  )
}

///|
pub fn get_glyph_atlas_rec(font : Font, codepoint : Int) -> Rectangle {
  Rectangle::from_bytes(@raylib.get_glyph_atlas_rec(font, codepoint))
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
  @raylib.load_font_from_image(image, key.to_bytes(), first_char)
}

///|
pub fn load_font_from_memory(
  file_type : String,
  file_data : Bytes,
  data_size : Int,
  font_size : Int,
) -> Font {
  @raylib.load_font_from_memory(
    @utf8.encode(file_type),
    file_data,
    data_size,
    font_size,
  )
}

///|
pub fn export_font_as_code(font : Font, file_name : String) -> Bool {
  @raylib.export_font_as_code(font, @utf8.encode(file_name))
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
  let arr = FixedArray::make(codepoints.length() * 4, b'\x00')
  for i, cp in codepoints {
    let (a, b, c, d) = write_int(cp)
    arr[i * 4] = a
    arr[i * 4 + 1] = b
    arr[i * 4 + 2] = c
    arr[i * 4 + 3] = d
  }
  let bytes = FixedArray::unsafe_reinterpret_as_bytes(arr)
  @raylib.draw_text_codepoints(
    font,
    bytes,
    codepoints.length(),
    position.to_bytes(),
    font_size,
    spacing,
    tint.to_bytes(),
  )
}
