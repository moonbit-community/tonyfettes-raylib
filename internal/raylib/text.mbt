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
#borrow(file_name, codepoints)
pub extern "c" fn load_font_ex_codepoints(
  file_name : Bytes,
  font_size : Int,
  codepoints : Bytes,
  codepoint_count : Int,
) -> Font = "moonbit_raylib_load_font_ex_codepoints"

///|
#borrow(font)
pub extern "c" fn is_font_valid(font : Font) -> Bool = "moonbit_raylib_is_font_valid"

///|
#borrow(font)
pub extern "c" fn unload_font(font : Font) = "moonbit_raylib_unload_font"

///|
#borrow(font)
pub extern "c" fn get_font_base_size(font : Font) -> Int = "moonbit_raylib_get_font_base_size"

///|
#borrow(font)
pub extern "c" fn get_font_glyph_count(font : Font) -> Int = "moonbit_raylib_get_font_glyph_count"

///|
#borrow(font)
pub extern "c" fn get_font_glyph_padding(font : Font) -> Int = "moonbit_raylib_get_font_glyph_padding"

///|
#borrow(font)
pub extern "c" fn get_font_texture(font : Font) -> Texture = "moonbit_raylib_get_font_texture"

///|
#borrow(font)
pub extern "c" fn gen_font_texture_mipmaps(font : Font) -> Unit = "moonbit_raylib_gen_font_texture_mipmaps"

///|
#borrow(font)
pub extern "c" fn set_font_texture_filter(font : Font, filter : Int) -> Unit = "moonbit_raylib_set_font_texture_filter"

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

// ============================================================================
// Text extras
// ============================================================================

///|
#borrow(font, position, tint)
pub extern "c" fn draw_text_codepoint(
  font : Font,
  codepoint : Int,
  position : Bytes,
  font_size : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_text_codepoint"

///|
#borrow(font)
pub extern "c" fn get_glyph_index(font : Font, codepoint : Int) -> Int = "moonbit_raylib_get_glyph_index"

///|
#borrow(font)
pub extern "c" fn get_glyph_atlas_rec(font : Font, codepoint : Int) -> Bytes = "moonbit_raylib_get_glyph_atlas_rec"

// ============================================================================
// Font loading extras
// ============================================================================

///|
#borrow(image, key)
pub extern "c" fn load_font_from_image(
  image : Image,
  key : Bytes,
  first_char : Int,
) -> Font = "moonbit_raylib_load_font_from_image"

///|
#borrow(file_type, file_data)
pub extern "c" fn load_font_from_memory(
  file_type : Bytes,
  file_data : Bytes,
  data_size : Int,
  font_size : Int,
) -> Font = "moonbit_raylib_load_font_from_memory"

///|
#borrow(pixel_data, recs_data, glyphs_data)
pub extern "c" fn load_font_from_atlas(
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
) -> Font = "moonbit_raylib_load_font_from_atlas"

///|
#borrow(font, file_name)
pub extern "c" fn export_font_as_code(font : Font, file_name : Bytes) -> Bool = "moonbit_raylib_export_font_as_code"

// ============================================================================
// Text drawing extras
// ============================================================================

///|
#borrow(font, codepoints, position, tint)
pub extern "c" fn draw_text_codepoints(
  font : Font,
  codepoints : Bytes,
  codepoint_count : Int,
  position : Bytes,
  font_size : Float,
  spacing : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_text_codepoints"

// ============================================================================
// Text: Codepoint functions
// ============================================================================

///|
#borrow(text)
pub extern "c" fn get_codepoint_count(text : Bytes) -> Int = "moonbit_raylib_get_codepoint_count"

///|
#borrow(text)
pub extern "c" fn get_codepoint(text : Bytes) -> Bytes = "moonbit_raylib_get_codepoint"

///|
#borrow(text)
pub extern "c" fn get_codepoint_next(text : Bytes) -> Bytes = "moonbit_raylib_get_codepoint_next"

///|
#borrow(text)
pub extern "c" fn get_codepoint_previous(text : Bytes) -> Bytes = "moonbit_raylib_get_codepoint_previous"

///|
pub extern "c" fn codepoint_to_utf8(codepoint : Int) -> Bytes = "moonbit_raylib_codepoint_to_utf8"

///|
#borrow(text)
pub extern "c" fn load_codepoints(text : Bytes) -> Bytes = "moonbit_raylib_load_codepoints"

///|
#borrow(codepoints)
pub extern "c" fn load_utf8(codepoints : Bytes, length : Int) -> Bytes = "moonbit_raylib_load_utf8"

// ============================================================================
// Text: Advanced font / GlyphInfo functions
// ============================================================================

///|
#borrow(font)
pub extern "c" fn get_glyph_info(font : Font, codepoint : Int) -> Bytes = "moonbit_raylib_get_glyph_info"

///|
#borrow(file_data)
pub extern "c" fn load_font_data(
  file_data : Bytes,
  data_size : Int,
  font_size : Int,
  font_type : Int,
) -> GlyphInfoArray = "moonbit_raylib_load_font_data"

///|
#borrow(wrapper)
pub extern "c" fn unload_font_data(wrapper : GlyphInfoArray) = "moonbit_raylib_unload_font_data"

///|
#borrow(wrapper)
pub extern "c" fn glyph_info_array_count(wrapper : GlyphInfoArray) -> Int = "moonbit_raylib_glyph_info_array_count"

///|
#borrow(wrapper)
pub extern "c" fn glyph_info_array_get(
  wrapper : GlyphInfoArray,
  index : Int,
) -> Bytes = "moonbit_raylib_glyph_info_array_get"

///|
#borrow(glyphs)
pub extern "c" fn gen_image_font_atlas(
  glyphs : GlyphInfoArray,
  font_size : Int,
  padding : Int,
  pack_method : Int,
) -> Image = "moonbit_raylib_gen_image_font_atlas"

///|
#borrow(file_data)
pub extern "c" fn build_font_from_data(
  file_data : Bytes,
  data_size : Int,
  font_size : Int,
  font_type : Int,
  padding : Int,
  pack_method : Int,
) -> Font = "moonbit_raylib_build_font_from_data"
