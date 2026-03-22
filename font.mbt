///|
/// Font, font texture and GlyphInfo array data.
struct Font(@ffi.Font)

///|
/// Get the default font.
pub impl Default for Font with default() -> Font {
  @ffi.get_font_default()
}

///|
/// Get the default font.
#as_free_fn(get_font_default, deprecated="Use Font::default() instead")
#deprecated("Use Font::default() instead")
pub fn Font::get_default() -> Font {
  @ffi.get_font_default()
}

///|
/// Get font base size (default chars height).
#as_free_fn(get_font_base_size)
pub fn Font::base_size(self : Font) -> Int {
  @ffi.get_font_base_size(self.0)
}

///|
/// Get font number of glyph characters.
#as_free_fn(get_font_glyph_count)
pub fn Font::glyph_count(self : Font) -> Int {
  @ffi.get_font_glyph_count(self.0)
}

///|
/// Get font glyph padding.
#as_free_fn(get_font_glyph_padding)
pub fn Font::glyph_padding(self : Font) -> Int {
  @ffi.get_font_glyph_padding(self.0)
}

///|
/// Get font texture atlas.
#as_free_fn(get_font_texture)
pub fn Font::texture(self : Font) -> Texture {
  @ffi.get_font_texture(self.0)
}

///|
/// Check if a font is valid (font data loaded, WARNING: GPU texture not checked).
#as_free_fn(is_font_valid)
pub fn Font::is_valid(self : Font) -> Bool {
  @ffi.is_font_valid(self.0)
}

///|
/// Unload font from GPU memory (VRAM).
#as_free_fn(unload_font)
pub fn Font::unload(self : Font) -> Unit {
  @ffi.unload_font(self.0)
}

///|
/// Array of glyph info data for font characters.
struct GlyphInfoArray(@ffi.GlyphInfoArray)

///|
/// Get the number of glyphs in the array.
#as_free_fn(glyph_info_array_count)
pub fn GlyphInfoArray::count(self : GlyphInfoArray) -> Int {
  @ffi.glyph_info_array_count(self.0)
}

///|
/// Unload font chars info data (RAM).
#as_free_fn(unload_font_data)
pub fn GlyphInfoArray::unload(self : GlyphInfoArray) -> Unit {
  @ffi.unload_font_data(self.0)
}

///|
/// Load font from file into GPU memory (VRAM).
#as_free_fn(load_font)
pub fn Font::load(file_name : String) -> Font {
  @ffi.load_font(@utf8.encode(file_name))
}

///|
/// Load font from file with extended parameters, loading the default character set.
#as_free_fn(load_font_ex)
pub fn Font::load_ex(file_name : String, font_size : Int) -> Font {
  @ffi.load_font_ex(@utf8.encode(file_name), font_size, None, 0)
}

///|
/// Load font from file with extended parameters and custom codepoints.
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
/// Draw text using font and additional parameters.
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
/// Draw text using font and pro parameters (rotation).
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
/// Measure string size for font.
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
/// Draw one character (codepoint).
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
/// Get glyph rectangle in font atlas for a codepoint, fallback to '?' if not found.
#as_free_fn(get_glyph_atlas_rec)
pub fn Font::glyph_atlas_rec(self : Font, codepoint : Int) -> Rectangle {
  Rectangle::from_bytes(@ffi.get_glyph_atlas_rec(self.0, codepoint))
}

///|
/// Get glyph index position in font for a codepoint, fallback to '?' if not found.
#as_free_fn(get_glyph_index)
pub fn Font::glyph_index(self : Font, codepoint : Int) -> Int {
  @ffi.get_glyph_index(self.0, codepoint)
}

///|
/// Load font from Image (XNA style).
#as_free_fn(load_font_from_image)
pub fn Font::load_from_image(
  image : Image,
  key : Color,
  first_char : Int,
) -> Font {
  @ffi.load_font_from_image(image.0, key.to_bytes(), first_char)
}

///|
/// Load font from memory buffer, file_type refers to extension: i.e. '.ttf'.
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
/// Construct a Font from its components. Copies the glyphs and recs data.
/// The texture value is copied — caller should not unload it separately.
#as_free_fn(new_font)
pub fn Font::new(
  texture : Texture,
  base_size : Int,
  glyph_padding~ : Int,
  glyphs : GlyphInfoArray,
  recs : FixedArray[Rectangle],
) -> Font {
  let buf = @buffer.new(size_hint=recs.length() * 16)
  for rec in recs {
    buf.write_float_le(rec.x)
    buf.write_float_le(rec.y)
    buf.write_float_le(rec.width)
    buf.write_float_le(rec.height)
  }
  @ffi.new_font(texture.0, base_size, glyph_padding, glyphs.0, buf.to_bytes())
}

///|
/// Load font from texture atlas components.
/// Deprecated: use Font::new(...) instead.
#as_free_fn(load_font_from_atlas, deprecated="Use Font::new(...) instead")
#deprecated("Use Font::new(...) instead")
pub fn Font::load_from_atlas(
  texture : Texture,
  base_size : Int,
  glyph_padding~ : Int,
  glyphs : GlyphInfoArray,
  recs : FixedArray[Rectangle],
) -> Font {
  Font::new(texture, base_size, glyph_padding, glyphs, recs)
}

///|
/// Export font as code file, returns true on success.
#as_free_fn(export_font_as_code)
pub fn Font::export_as_code(self : Font, file_name : String) -> Bool {
  @ffi.export_font_as_code(self.0, @utf8.encode(file_name))
}

///|
/// Draw multiple characters (codepoints).
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
/// Get glyph font info data for a codepoint, fallback to '?' if not found.
#as_free_fn(get_glyph_info)
pub fn Font::glyph_info(self : Font, codepoint : Int) -> GlyphInfo {
  GlyphInfo::from_bytes(@ffi.get_glyph_info(self.0, codepoint))
}

///|
/// Allocate an empty GlyphInfoArray of the given size.
#as_free_fn(new_glyph_info_array)
pub fn GlyphInfoArray::new(count : Int) -> GlyphInfoArray {
  @ffi.new_glyph_info_array(count)
}

///|
/// Set a glyph at the given index.
pub fn GlyphInfoArray::op_set(
  self : GlyphInfoArray,
  index : Int,
  info : GlyphInfo,
) -> Unit {
  @ffi.glyph_info_array_set(
    self.0,
    index,
    info.value,
    info.offset_x,
    info.offset_y,
    info.advance_x,
  )
}

///|
/// Load font data for further use.
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
/// Get glyph info at the given index in the array.
#as_free_fn(glyph_info_array_get)
pub fn GlyphInfoArray::get(self : GlyphInfoArray, index : Int) -> GlyphInfo {
  GlyphInfo::from_bytes(@ffi.glyph_info_array_get(self.0, index))
}

///|
/// Generate image font atlas using chars info. Returns the atlas image and
/// the glyph rectangle array.
pub fn GlyphInfoArray::gen_image_atlas(
  self : GlyphInfoArray,
  font_size : Int,
  padding : Int,
  pack_method : Int,
) -> (Image, FixedArray[Rectangle]) {
  let recs_ref : Ref[Bytes] = Ref::new(Bytes::new(0))
  let image = @ffi.gen_image_font_atlas(
    self.0,
    font_size,
    padding,
    pack_method,
    recs_ref,
  )
  let recs_bytes = recs_ref.val
  let count = @ffi.glyph_info_array_count(self.0)
  let recs = FixedArray::makei(count, fn(i) {
    let off = i * 16
    Rectangle::new(
      read_float(recs_bytes, off),
      read_float(recs_bytes, off + 4),
      read_float(recs_bytes, off + 8),
      read_float(recs_bytes, off + 12),
    )
  })
  (image, recs)
}

///|
/// Generate mipmaps for font texture atlas.
#deprecated("Use font.texture().gen_mipmaps() instead")
pub fn gen_font_texture_mipmaps(font : Font) -> Unit {
  font.texture().gen_mipmaps()
}

///|
/// Set texture filtering mode for font texture atlas.
#deprecated("Use font.texture().set_filter(filter) instead")
pub fn set_font_texture_filter(font : Font, filter : Int) -> Unit {
  font.texture().set_filter(filter)
}
