///|
struct Font(@ffi.Font)

///|
pub impl Default for Font with default() -> Font {
  @ffi.get_font_default()
}

///|
#as_free_fn(get_font_default, deprecated="Use Font::default() instead")
#deprecated("Use Font::default() instead")
pub fn Font::get_default() -> Font {
  @ffi.get_font_default()
}

///|
#as_free_fn(get_font_base_size)
pub fn Font::base_size(self : Font) -> Int {
  @ffi.get_font_base_size(self.0)
}

///|
#as_free_fn(get_font_glyph_count)
pub fn Font::glyph_count(self : Font) -> Int {
  @ffi.get_font_glyph_count(self.0)
}

///|
#as_free_fn(get_font_glyph_padding)
pub fn Font::glyph_padding(self : Font) -> Int {
  @ffi.get_font_glyph_padding(self.0)
}

///|
#as_free_fn(get_font_texture)
pub fn Font::texture(self : Font) -> Texture {
  @ffi.get_font_texture(self.0)
}

///|
#as_free_fn(is_font_valid)
pub fn Font::is_valid(self : Font) -> Bool {
  @ffi.is_font_valid(self.0)
}

///|
#as_free_fn(unload_font)
pub fn Font::unload(self : Font) -> Unit {
  @ffi.unload_font(self.0)
}

///|
struct GlyphInfoArray(@ffi.GlyphInfoArray)

///|
#as_free_fn(glyph_info_array_count)
pub fn GlyphInfoArray::count(self : GlyphInfoArray) -> Int {
  @ffi.glyph_info_array_count(self.0)
}

///|
#as_free_fn(unload_font_data)
pub fn GlyphInfoArray::unload(self : GlyphInfoArray) -> Unit {
  @ffi.unload_font_data(self.0)
}

///|
#as_free_fn(load_font)
pub fn Font::load(file_name : String) -> Font {
  @ffi.load_font(@utf8.encode(file_name))
}

///|
#as_free_fn(load_font_ex)
pub fn Font::load_ex(file_name : String, font_size : Int) -> Font {
  @ffi.load_font_ex(@utf8.encode(file_name), font_size, None, 0)
}

///|
#as_free_fn(load_font_ex_codepoints)
pub fn Font::load_ex_codepoints(
  file_name : String,
  font_size : Int,
  codepoints : Array[Int],
) -> Font {
  @ffi.load_font_ex(
    @utf8.encode(file_name),
    font_size,
    Some(FixedArray::from_array(codepoints)),
    codepoints.length(),
  )
}

///|
#as_free_fn(draw_text_ex)
pub fn Font::draw_text(
  self : Font,
  text : String,
  position : Vector2,
  font_size : Float,
  spacing : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_text_ex(
    self.0,
    @utf8.encode(text),
    position.to_bytes(),
    font_size,
    spacing,
    tint.to_bytes(),
  )
}

///|
#as_free_fn(draw_text_pro)
pub fn Font::draw_text_pro(
  self : Font,
  text : String,
  position : Vector2,
  origin : Vector2,
  rotation : Float,
  font_size : Float,
  spacing : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_text_pro(
    self.0,
    @utf8.encode(text),
    position.to_bytes(),
    origin.to_bytes(),
    rotation,
    font_size,
    spacing,
    tint.to_bytes(),
  )
}

///|
#as_free_fn(measure_text_ex)
pub fn Font::measure_text(
  self : Font,
  text : String,
  font_size : Float,
  spacing : Float,
) -> Vector2 {
  Vector2::from_bytes(
    @ffi.measure_text_ex(self.0, @utf8.encode(text), font_size, spacing),
  )
}

///|
#as_free_fn(draw_text_codepoint)
pub fn Font::draw_codepoint(
  self : Font,
  codepoint : Int,
  position : Vector2,
  font_size : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_text_codepoint(
    self.0,
    codepoint,
    position.to_bytes(),
    font_size,
    tint.to_bytes(),
  )
}

///|
#as_free_fn(get_glyph_atlas_rec)
pub fn Font::glyph_atlas_rec(self : Font, codepoint : Int) -> Rectangle {
  Rectangle::from_bytes(@ffi.get_glyph_atlas_rec(self.0, codepoint))
}

///|
#as_free_fn(get_glyph_index)
pub fn Font::glyph_index(self : Font, codepoint : Int) -> Int {
  @ffi.get_glyph_index(self.0, codepoint)
}

///|
#as_free_fn(load_font_from_image)
pub fn Font::load_from_image(
  image : Image,
  key : Color,
  first_char : Int,
) -> Font {
  @ffi.load_font_from_image(image.0, key.to_bytes(), first_char)
}

///|
#as_free_fn(load_font_from_memory)
pub fn Font::load_from_memory(
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
#as_free_fn(load_font_from_atlas)
pub fn Font::load_from_atlas(
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
#as_free_fn(export_font_as_code)
pub fn Font::export_as_code(self : Font, file_name : String) -> Bool {
  @ffi.export_font_as_code(self.0, @utf8.encode(file_name))
}

///|
#as_free_fn(draw_text_codepoints)
pub fn Font::draw_codepoints(
  self : Font,
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
    self.0,
    bytes,
    codepoints.length(),
    position.to_bytes(),
    font_size,
    spacing,
    tint.to_bytes(),
  )
}

///|
#as_free_fn(get_glyph_info)
pub fn Font::glyph_info(self : Font, codepoint : Int) -> GlyphInfo {
  GlyphInfo::from_bytes(@ffi.get_glyph_info(self.0, codepoint))
}

///|
#as_free_fn(build_font_from_data)
pub fn Font::build_from_data(
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

///|
#as_free_fn(load_font_data)
pub fn GlyphInfoArray::load(
  file_data : Bytes,
  data_size : Int,
  font_size : Int,
  font_type : Int,
) -> GlyphInfoArray {
  @ffi.load_font_data(file_data, data_size, font_size, font_type)
}

///|
#as_free_fn(glyph_info_array_get)
pub fn GlyphInfoArray::get(self : GlyphInfoArray, index : Int) -> GlyphInfo {
  GlyphInfo::from_bytes(@ffi.glyph_info_array_get(self.0, index))
}

///|
#as_free_fn(gen_image_font_atlas)
pub fn GlyphInfoArray::gen_image_atlas(
  self : GlyphInfoArray,
  font_size : Int,
  padding : Int,
  pack_method : Int,
) -> Image {
  @ffi.gen_image_font_atlas(self.0, font_size, padding, pack_method)
}

///|
#deprecated("Use font.texture().gen_mipmaps() instead")
pub fn gen_font_texture_mipmaps(font : Font) -> Unit {
  font.texture().gen_mipmaps()
}

///|
#deprecated("Use font.texture().set_filter(filter) instead")
pub fn set_font_texture_filter(font : Font, filter : Int) -> Unit {
  font.texture().set_filter(filter)
}
