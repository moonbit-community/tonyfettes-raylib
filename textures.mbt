// Texture: 20 bytes (id as uint, width/height/mipmaps/format as int)

///|
pub struct Texture {
  id : UInt
  width : Int
  height : Int
  mipmaps : Int
  format : Int
} derive(Eq, Show)

///|
pub fn Texture::to_bytes(t : Texture) -> Bytes {
  let buf = @buffer.new(size_hint=20)
  buf.write_int_le(t.id.reinterpret_as_int())
  buf.write_int_le(t.width)
  buf.write_int_le(t.height)
  buf.write_int_le(t.mipmaps)
  buf.write_int_le(t.format)
  buf.to_bytes()
}

///|
pub fn Texture::from_bytes(b : Bytes) -> Texture {
  {
    id: read_int(b, 0).reinterpret_as_uint(),
    width: read_int(b, 4),
    height: read_int(b, 8),
    mipmaps: read_int(b, 12),
    format: read_int(b, 16),
  }
}

// Re-export passthrough functions from internal FFI layer

///|
pub using @ffi {
  type Image,
  unload_image,
  is_image_valid,
  image_copy,
  image_from_channel,
  load_image_from_screen,
  load_render_texture,
  load_render_texture_depth_tex,
  is_render_texture_valid,
  unload_render_texture,
  gen_image_white_noise,
  gen_image_perlin_noise,
  gen_image_cellular,
  unload_render_texture_depth_tex,
  get_render_texture_fbo_id,
  get_render_texture_depth_id,
  load_shadowmap_render_texture,
  unload_shadowmap_render_texture,
  get_render_texture_width,
  get_render_texture_height,
}

// ============================================================================
// Image loading (wrappers)
// ============================================================================

///|
pub fn load_image(file_name : String) -> Image {
  @ffi.load_image(@utf8.encode(file_name))
}

///|
pub fn gen_image_color(width : Int, height : Int, color : Color) -> Image {
  @ffi.gen_image_color(width, height, color.to_bytes())
}

///|
pub fn gen_image_checked(
  width : Int,
  height : Int,
  checks_x : Int,
  checks_y : Int,
  col1 : Color,
  col2 : Color,
) -> Image {
  @ffi.gen_image_checked(
    width,
    height,
    checks_x,
    checks_y,
    col1.to_bytes(),
    col2.to_bytes(),
  )
}

///|
pub fn gen_image_gradient_linear(
  width : Int,
  height : Int,
  direction : Int,
  start : Color,
  end_ : Color,
) -> Image {
  @ffi.gen_image_gradient_linear(
    width,
    height,
    direction,
    start.to_bytes(),
    end_.to_bytes(),
  )
}

///|
pub fn gen_image_gradient_radial(
  width : Int,
  height : Int,
  density : Float,
  inner : Color,
  outer : Color,
) -> Image {
  @ffi.gen_image_gradient_radial(
    width,
    height,
    density,
    inner.to_bytes(),
    outer.to_bytes(),
  )
}

///|
pub fn gen_image_gradient_square(
  width : Int,
  height : Int,
  density : Float,
  inner : Color,
  outer : Color,
) -> Image {
  @ffi.gen_image_gradient_square(
    width,
    height,
    density,
    inner.to_bytes(),
    outer.to_bytes(),
  )
}

///|
pub fn gen_image_text(width : Int, height : Int, text : String) -> Image {
  @ffi.gen_image_text(width, height, @utf8.encode(text))
}

// ============================================================================
// Image loading extras (wrappers)
// ============================================================================

///|
pub fn load_image_from_memory(
  file_type : String,
  file_data : Bytes,
  data_size : Int,
) -> Image {
  @ffi.load_image_from_memory(@utf8.encode(file_type), file_data, data_size)
}

///|
pub fn export_image(image : Image, file_name : String) -> Bool {
  @ffi.export_image(image, @utf8.encode(file_name))
}

// ============================================================================
// Image basic ops (wrappers)
// ============================================================================

///|
pub fn image_from_image(image : Image, rec : Rectangle) -> Image {
  @ffi.image_from_image(image, rec.to_bytes())
}

// ============================================================================
// Texture loading (wrappers)
// ============================================================================

///|
pub fn load_texture(file_name : String) -> Texture {
  Texture::from_bytes(@ffi.load_texture(@utf8.encode(file_name)))
}

///|
pub fn load_texture_from_image(image : Image) -> Texture {
  Texture::from_bytes(@ffi.load_texture_from_image(image))
}

///|
pub fn is_texture_valid(texture : Texture) -> Bool {
  @ffi.is_texture_valid(texture.to_bytes())
}

///|
pub fn unload_texture(texture : Texture) -> Unit {
  @ffi.unload_texture(texture.to_bytes())
}

///|
pub fn load_image_from_texture(texture : Texture) -> Image {
  @ffi.load_image_from_texture(texture.to_bytes())
}

///|
pub fn load_texture_cubemap(image : Image, layout : Int) -> Texture {
  Texture::from_bytes(@ffi.load_texture_cubemap(image, layout))
}

///|
pub fn update_texture(texture : Texture, pixels : Bytes) -> Unit {
  @ffi.update_texture(texture.to_bytes(), pixels)
}

///|
pub fn update_texture_from_image_frame(
  texture : Texture,
  image : Image,
  frame : Int,
) -> Unit {
  @ffi.update_texture_from_image_frame(texture.to_bytes(), image, frame)
}

///|
pub fn gen_texture_mipmaps(texture : Texture) -> Texture {
  Texture::from_bytes(@ffi.gen_texture_mipmaps(texture.to_bytes()))
}

///|
pub fn set_texture_filter(texture : Texture, filter : Int) -> Unit {
  @ffi.set_texture_filter(texture.to_bytes(), filter)
}

///|
pub fn set_texture_wrap(texture : Texture, wrap : Int) -> Unit {
  @ffi.set_texture_wrap(texture.to_bytes(), wrap)
}

///|
pub fn get_shapes_texture() -> Texture {
  Texture::from_bytes(@ffi.get_shapes_texture())
}

///|
pub fn get_render_texture_texture(target : RenderTexture) -> Texture {
  Texture::from_bytes(@ffi.get_render_texture_texture(target))
}

///|
pub fn Texture::new(
  id~ : UInt,
  width~ : Int,
  height~ : Int,
  mipmaps~ : Int = 1,
  format~ : Int = PixelformatUncompressedR8g8b8a8,
) -> Texture {
  { id, width, height, mipmaps, format }
}

///|
#deprecated("Use Texture::new")
pub fn texture_from_id(id : UInt, width : Int, height : Int) -> Texture {
  Texture::new(id~, width~, height~)
}

// ============================================================================
// Backward-compatible accessors (Texture is now a struct with public fields,
// but these functions are kept so existing code continues to compile)
// ============================================================================

///|
#deprecated("Use texture.width")
pub fn get_texture_width(texture : Texture) -> Int {
  texture.width
}

///|
#deprecated("Use texture.height")
pub fn get_texture_height(texture : Texture) -> Int {
  texture.height
}

///|
#deprecated("Use texture.id.reinterpret_as_int()")
pub fn get_texture_id(texture : Texture) -> Int {
  texture.id.reinterpret_as_int()
}

// ============================================================================
// RenderTexture drawing (wrappers)
// ============================================================================

///|
pub fn draw_render_texture_rec(
  target : RenderTexture,
  source : Rectangle,
  position : Vector2,
  tint : Color,
) -> Unit {
  @ffi.draw_render_texture_rec(
    target,
    source.to_bytes(),
    position.to_bytes(),
    tint.to_bytes(),
  )
}

///|
pub fn draw_render_texture_ex(
  target : RenderTexture,
  position : Vector2,
  rotation : Float,
  scale : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_render_texture_ex(
    target,
    position.to_bytes(),
    rotation,
    scale,
    tint.to_bytes(),
  )
}

///|
pub fn draw_render_texture_pro(
  target : RenderTexture,
  source : Rectangle,
  dest : Rectangle,
  origin : Vector2,
  rotation : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_render_texture_pro(
    target,
    source.to_bytes(),
    dest.to_bytes(),
    origin.to_bytes(),
    rotation,
    tint.to_bytes(),
  )
}

///|
pub fn set_render_texture_filter(target : RenderTexture, filter : Int) -> Unit {
  @ffi.set_render_texture_filter(target, filter)
}

// ============================================================================
// Texture drawing (wrappers)
// ============================================================================

///|
pub fn draw_texture(
  texture : Texture,
  pos_x : Int,
  pos_y : Int,
  tint : Color,
) -> Unit {
  @ffi.draw_texture(texture.to_bytes(), pos_x, pos_y, tint.to_bytes())
}

///|
pub fn draw_texture_v(
  texture : Texture,
  position : Vector2,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_v(texture.to_bytes(), position.to_bytes(), tint.to_bytes())
}

///|
pub fn draw_texture_ex(
  texture : Texture,
  position : Vector2,
  rotation : Float,
  scale : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_ex(
    texture.to_bytes(),
    position.to_bytes(),
    rotation,
    scale,
    tint.to_bytes(),
  )
}

///|
pub fn draw_texture_rec(
  texture : Texture,
  source : Rectangle,
  position : Vector2,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_rec(
    texture.to_bytes(),
    source.to_bytes(),
    position.to_bytes(),
    tint.to_bytes(),
  )
}

///|
pub fn draw_texture_pro(
  texture : Texture,
  source : Rectangle,
  dest : Rectangle,
  origin : Vector2,
  rotation : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_pro(
    texture.to_bytes(),
    source.to_bytes(),
    dest.to_bytes(),
    origin.to_bytes(),
    rotation,
    tint.to_bytes(),
  )
}

///|
pub fn draw_texture_npatch(
  texture : Texture,
  npatch_info : NPatchInfo,
  dest : Rectangle,
  origin : Vector2,
  rotation : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_npatch(
    texture.to_bytes(),
    npatch_info.to_bytes(),
    dest.to_bytes(),
    origin.to_bytes(),
    rotation,
    tint.to_bytes(),
  )
}

// ============================================================================
// Texture filter constants
// ============================================================================

///|
pub const TextureFilterPoint : Int = 0

///|
pub const TextureFilterBilinear : Int = 1

///|
pub const TextureFilterTrilinear : Int = 2

///|
pub const TextureFilterAnisotropic4x : Int = 3

///|
pub const TextureFilterAnisotropic8x : Int = 4

///|
pub const TextureFilterAnisotropic16x : Int = 5

// ============================================================================
// Texture wrap constants
// ============================================================================

///|
pub const TextureWrapRepeat : Int = 0

///|
pub const TextureWrapClamp : Int = 1

///|
pub const TextureWrapMirrorRepeat : Int = 2

///|
pub const TextureWrapMirrorClamp : Int = 3

// ============================================================================
// Pixel format constants
// ============================================================================

///|
pub const PixelformatUncompressedGrayscale : Int = 1

///|
pub const PixelformatUncompressedGrayAlpha : Int = 2

///|
pub const PixelformatUncompressedR5g6b5 : Int = 3

///|
pub const PixelformatUncompressedR8g8b8 : Int = 4

///|
pub const PixelformatUncompressedR5g5b5a1 : Int = 5

///|
pub const PixelformatUncompressedR4g4b4a4 : Int = 6

///|
pub const PixelformatUncompressedR8g8b8a8 : Int = 7

///|
pub const PixelformatUncompressedR32 : Int = 8

///|
pub const PixelformatUncompressedR32g32b32 : Int = 9

///|
pub const PixelformatUncompressedR32g32b32a32 : Int = 10

// ============================================================================
// Texture management extras (wrappers)
// ============================================================================

///|
pub fn update_texture_rec(
  texture : Texture,
  rec : Rectangle,
  pixels : Bytes,
) -> Unit {
  @ffi.update_texture_rec(texture.to_bytes(), rec.to_bytes(), pixels)
}

///|
pub fn set_shapes_texture(texture : Texture, source : Rectangle) -> Unit {
  @ffi.set_shapes_texture(texture.to_bytes(), source.to_bytes())
}

///|
pub fn get_shapes_texture_rectangle() -> Rectangle {
  Rectangle::from_bytes(@ffi.get_shapes_texture_rectangle())
}

// ============================================================================
// Cubemap layout constants
// ============================================================================

///|
pub const CubemapLayoutAutoDetect : Int = 0

///|
pub const CubemapLayoutLineVertical : Int = 1

///|
pub const CubemapLayoutLineHorizontal : Int = 2

///|
pub const CubemapLayoutCrossThreeByFour : Int = 3

///|
pub const CubemapLayoutCrossFourByThree : Int = 4
