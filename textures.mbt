// Re-export passthrough functions from internal FFI layer

///|
pub struct Texture {
  memory : Bytes
  offset : Int
}

///|
pub struct RenderTexture {
  memory : Bytes
  offset : Int
}

///|
pub using @ffi {
  type Image,
  unload_image,
  is_image_valid,
  image_copy,
  image_from_channel,
  load_image_from_screen,
  gen_image_white_noise,
  gen_image_perlin_noise,
  gen_image_cellular,
}

///|
pub fn load_texture_from_image(image : Image) -> Texture {
  Texture::{ memory: @ffi.load_texture_from_image(image), offset: 0 }
}

///|
pub fn is_texture_valid(texture : Texture) -> Bool {
  @ffi.is_texture_valid(texture.memory, texture.offset)
}

///|
pub fn unload_texture(texture : Texture) -> Unit {
  @ffi.unload_texture(texture.memory, texture.offset)
}

///|
pub fn load_render_texture(width : Int, height : Int) -> RenderTexture {
  RenderTexture::{ memory: @ffi.load_render_texture(width, height), offset: 0 }
}

///|
pub fn is_render_texture_valid(render_texture : RenderTexture) -> Bool {
  @ffi.is_render_texture_valid(render_texture.memory, render_texture.offset)
}

///|
pub fn unload_render_texture(render_texture : RenderTexture) -> Unit {
  @ffi.unload_render_texture(render_texture.memory, render_texture.offset)
}

///|
pub fn get_render_texture_texture(render_texture : RenderTexture) -> Texture {
  Texture::{
    memory: render_texture.memory,
    offset: render_texture.offset + @ffi.get_render_texture_texture(),
  }
}

///|
pub fn get_render_texture_depth(render_texture : RenderTexture) -> Texture {
  Texture::{
    memory: render_texture.memory,
    offset: render_texture.offset + @ffi.get_render_texture_depth(),
  }
}

///|
pub fn load_image_from_texture(texture : Texture) -> Image {
  @ffi.load_image_from_texture(texture.memory, texture.offset)
}

///|
pub fn set_texture_filter(texture : Texture, filter : Int) -> Unit {
  @ffi.set_texture_filter(texture.memory, texture.offset, filter)
}

///|
pub fn set_texture_wrap(texture : Texture, wrap : Int) -> Unit {
  @ffi.set_texture_wrap(texture.memory, texture.offset, wrap)
}

///|
pub fn load_texture_cubemap(image : Image, layout : Int) -> Texture {
  Texture::{ memory: @ffi.load_texture_cubemap(image, layout), offset: 0 }
}

///|
pub fn update_texture(texture : Texture, pixels : Bytes) -> Unit {
  @ffi.update_texture(texture.memory, texture.offset, pixels)
}

///|
pub fn update_texture_from_image_frame(
  texture : Texture,
  image : Image,
  frame : Int,
) -> Unit {
  @ffi.update_texture_from_image_frame(
    texture.memory,
    texture.offset,
    image,
    frame,
  )
}

///|
pub fn gen_texture_mipmaps(texture : Texture) -> Unit {
  @ffi.gen_texture_mipmaps(texture.memory, texture.offset)
}

///|
pub fn get_texture_id(texture : Texture) -> UInt {
  @ffi.get_texture_id(texture.memory, texture.offset)
}

///|
pub fn get_shapes_texture() -> Texture {
  Texture::{ memory: @ffi.get_shapes_texture(), offset: 0 }
}

///|
pub fn get_render_texture_width(render_texture : RenderTexture) -> Int {
  @ffi.get_render_texture_width(render_texture.memory, render_texture.offset)
}

///|
pub fn get_render_texture_height(render_texture : RenderTexture) -> Int {
  @ffi.get_render_texture_height(render_texture.memory, render_texture.offset)
}

///|
pub fn get_texture_width(texture : Texture) -> Int {
  @ffi.get_texture_width(texture.memory, texture.offset)
}

///|
pub fn get_texture_height(texture : Texture) -> Int {
  @ffi.get_texture_height(texture.memory, texture.offset)
}

///|
pub fn get_render_texture_id(render_texture : RenderTexture) -> UInt {
  @ffi.get_render_texture_id(render_texture.memory, render_texture.offset)
}

///|
pub fn get_render_texture_depth_id(render_texture : RenderTexture) -> UInt {
  @ffi.get_render_texture_depth_id(render_texture.memory, render_texture.offset)
}

///|
pub fn new_texture(
  id : UInt,
  width : Int,
  height : Int,
  mipmaps : Int,
  format : Int,
) -> Texture {
  Texture::{
    memory: @ffi.new_texture(id, width, height, mipmaps, format),
    offset: 0,
  }
}

///|
pub fn new_render_texture(
  id : UInt,
  texture : Texture,
  depth : Texture,
) -> RenderTexture {
  RenderTexture::{
    memory: @ffi.new_render_texture(
      id,
      texture.memory,
      texture.offset,
      depth.memory,
      depth.offset,
    ),
    offset: 0,
  }
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
  Texture::{ memory: @ffi.load_texture(@utf8.encode(file_name)), offset: 0 }
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
    target.memory,
    target.offset,
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
    target.memory,
    target.offset,
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
    target.memory,
    target.offset,
    source.to_bytes(),
    dest.to_bytes(),
    origin.to_bytes(),
    rotation,
    tint.to_bytes(),
  )
}

///|
pub fn set_render_texture_filter(target : RenderTexture, filter : Int) -> Unit {
  @ffi.set_render_texture_filter(target.memory, target.offset, filter)
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
  @ffi.draw_texture(
    texture.memory,
    texture.offset,
    pos_x,
    pos_y,
    tint.to_bytes(),
  )
}

///|
pub fn draw_texture_v(
  texture : Texture,
  position : Vector2,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_v(
    texture.memory,
    texture.offset,
    position.to_bytes(),
    tint.to_bytes(),
  )
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
    texture.memory,
    texture.offset,
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
    texture.memory,
    texture.offset,
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
    texture.memory,
    texture.offset,
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
    texture.memory,
    texture.offset,
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
  @ffi.update_texture_rec(
    texture.memory,
    texture.offset,
    rec.to_bytes(),
    pixels,
  )
}

///|
pub fn set_shapes_texture(texture : Texture, source : Rectangle) -> Unit {
  @ffi.set_shapes_texture(texture.memory, texture.offset, source.to_bytes())
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

///|
#deprecated("Use new_texture instead")
pub fn texture_from_id(id : UInt, width : Int, height : Int) -> Texture {
  Texture::{
    memory: @ffi.new_texture(
      id,
      width,
      height,
      1,
      PixelformatUncompressedR8g8b8a8,
    ),
    offset: 0,
  }
}

///|
#deprecated("Use @rl.* API to load the texture manually")
pub fn load_render_texture_depth_tex(
  width : Int,
  height : Int,
) -> RenderTexture {
  RenderTexture::{
    memory: @ffi.load_render_texture_depth_tex(width, height),
    offset: 0,
  }
}

///|
#deprecated("Use @rl.* API to load the render texture manually")
pub fn load_shadowmap_render_texture(
  width : Int,
  height : Int,
) -> RenderTexture {
  RenderTexture::{
    memory: @ffi.load_shadowmap_render_texture(width, height),
    offset: 0,
  }
}

///|
#deprecated("Use @rl.* API to unload the render texture manually")
pub fn unload_shadowmap_render_texture(target : RenderTexture) -> Unit {
  @ffi.rl_unload_framebuffer(get_render_texture_id(target))
}

///|
#deprecated("Use get_render_texture_id instead")
pub fn get_render_texture_fbo_id(render_texture : RenderTexture) -> UInt {
  get_render_texture_id(render_texture)
}

///|
#deprecated("Use @rl.* API to unload the render texture manually")
pub fn unload_render_texture_depth_tex(render_texture : RenderTexture) -> Unit {
  @ffi.rl_unload_texture(
    get_texture_id(get_render_texture_texture(render_texture)),
  )
  @ffi.rl_unload_texture(
    get_texture_id(get_render_texture_depth(render_texture)),
  )
  @ffi.rl_unload_framebuffer(get_render_texture_id(render_texture))
}
