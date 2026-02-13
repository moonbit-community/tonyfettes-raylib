// Re-export passthrough functions from internal FFI layer
pub using @raylib {
  get_font_default,
  is_font_valid,
  unload_font,
  draw_fps,
  set_text_line_spacing,
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
  @raylib.draw_text(@utf8.encode(text), pos_x, pos_y, font_size, color.to_bytes())
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
