// ============================================================================
// Font loading
// ============================================================================

///|
pub extern "c" fn get_font_default() -> Font = "moonbit_raylib_get_font_default"

///|
#borrow(file_name)
pub extern "c" fn load_font(file_name : Bytes) -> Font = "moonbit_raylib_load_font"

///|
#borrow(file_name)
pub extern "c" fn load_font_ex(file_name : Bytes, font_size : Int) -> Font = "moonbit_raylib_load_font_ex"

///|
#borrow(font)
pub extern "c" fn is_font_valid(font : Font) -> Bool = "moonbit_raylib_is_font_valid"

///|
#borrow(font)
pub extern "c" fn unload_font(font : Font) = "moonbit_raylib_unload_font"

// ============================================================================
// Text drawing
// ============================================================================

///|
pub extern "c" fn draw_fps(pos_x : Int, pos_y : Int) = "DrawFPS"

///|
#borrow(text, color)
pub extern "c" fn draw_text(
  text : Bytes,
  pos_x : Int,
  pos_y : Int,
  font_size : Int,
  color : Bytes,
) = "moonbit_raylib_draw_text"

///|
#borrow(font, text, position, tint)
pub extern "c" fn draw_text_ex(
  font : Font,
  text : Bytes,
  position : Bytes,
  font_size : Float,
  spacing : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_text_ex"

///|
#borrow(font, text, position, origin, tint)
pub extern "c" fn draw_text_pro(
  font : Font,
  text : Bytes,
  position : Bytes,
  origin : Bytes,
  rotation : Float,
  font_size : Float,
  spacing : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_text_pro"

// ============================================================================
// Text measurement
// ============================================================================

///|
#borrow(text)
pub extern "c" fn measure_text(text : Bytes, font_size : Int) -> Int = "moonbit_raylib_measure_text"

///|
#borrow(font, text)
pub extern "c" fn measure_text_ex(
  font : Font,
  text : Bytes,
  font_size : Float,
  spacing : Float,
) -> Bytes = "moonbit_raylib_measure_text_ex"

///|
pub extern "c" fn set_text_line_spacing(spacing : Int) = "SetTextLineSpacing"
