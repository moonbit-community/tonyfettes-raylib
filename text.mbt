// ============================================================================
// Font loading
// ============================================================================

///|
extern "c" fn raylib_get_font_default() -> Font = "moonbit_raylib_get_font_default"

///|
pub fn get_font_default() -> Font {
  raylib_get_font_default()
}

///|
#borrow(file_name)
extern "c" fn raylib_load_font(file_name : Bytes) -> Font = "moonbit_raylib_load_font"

///|
pub fn load_font(file_name : String) -> Font {
  raylib_load_font(@utf8.encode(file_name))
}

///|
#borrow(file_name)
extern "c" fn raylib_load_font_ex(file_name : Bytes, font_size : Int) -> Font = "moonbit_raylib_load_font_ex"

///|
pub fn load_font_ex(file_name : String, font_size : Int) -> Font {
  raylib_load_font_ex(@utf8.encode(file_name), font_size)
}

///|
#borrow(font)
extern "c" fn raylib_is_font_valid(font : Font) -> Bool = "moonbit_raylib_is_font_valid"

///|
pub fn is_font_valid(font : Font) -> Bool {
  raylib_is_font_valid(font)
}

///|
#borrow(font)
extern "c" fn raylib_unload_font(font : Font) = "moonbit_raylib_unload_font"

///|
pub fn unload_font(font : Font) -> Unit {
  raylib_unload_font(font)
}

// ============================================================================
// Text drawing
// ============================================================================

///|
extern "c" fn raylib_draw_fps(pos_x : Int, pos_y : Int) = "DrawFPS"

///|
pub fn draw_fps(pos_x : Int, pos_y : Int) -> Unit {
  raylib_draw_fps(pos_x, pos_y)
}

///|
#borrow(text, color)
extern "c" fn raylib_draw_text(
  text : Bytes,
  pos_x : Int,
  pos_y : Int,
  font_size : Int,
  color : Bytes,
) = "moonbit_raylib_draw_text"

///|
pub fn draw_text(
  text : String,
  pos_x : Int,
  pos_y : Int,
  font_size : Int,
  color : Color,
) -> Unit {
  raylib_draw_text(@utf8.encode(text), pos_x, pos_y, font_size, color.to_bytes())
}

///|
#borrow(font, text, position, tint)
extern "c" fn raylib_draw_text_ex(
  font : Font,
  text : Bytes,
  position : Bytes,
  font_size : Float,
  spacing : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_text_ex"

///|
pub fn draw_text_ex(
  font : Font,
  text : String,
  position : Vector2,
  font_size : Float,
  spacing : Float,
  tint : Color,
) -> Unit {
  raylib_draw_text_ex(
    font,
    @utf8.encode(text),
    position.to_bytes(),
    font_size,
    spacing,
    tint.to_bytes(),
  )
}

///|
#borrow(font, text, position, origin, tint)
extern "c" fn raylib_draw_text_pro(
  font : Font,
  text : Bytes,
  position : Bytes,
  origin : Bytes,
  rotation : Float,
  font_size : Float,
  spacing : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_text_pro"

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
  raylib_draw_text_pro(
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
// Text measurement
// ============================================================================

///|
#borrow(text)
extern "c" fn raylib_measure_text(text : Bytes, font_size : Int) -> Int = "moonbit_raylib_measure_text"

///|
pub fn measure_text(text : String, font_size : Int) -> Int {
  raylib_measure_text(@utf8.encode(text), font_size)
}

///|
#borrow(font, text)
extern "c" fn raylib_measure_text_ex(
  font : Font,
  text : Bytes,
  font_size : Float,
  spacing : Float,
) -> Bytes = "moonbit_raylib_measure_text_ex"

///|
pub fn measure_text_ex(
  font : Font,
  text : String,
  font_size : Float,
  spacing : Float,
) -> Vector2 {
  Vector2::from_bytes(
    raylib_measure_text_ex(font, @utf8.encode(text), font_size, spacing),
  )
}

///|
extern "c" fn raylib_set_text_line_spacing(spacing : Int) = "SetTextLineSpacing"

///|
pub fn set_text_line_spacing(spacing : Int) -> Unit {
  raylib_set_text_line_spacing(spacing)
}
