///|
struct Texture(@ffi.Texture)

///|
#as_free_fn(new_texture)
pub fn Texture::new(
  id : UInt,
  width : Int,
  height : Int,
  mipmaps : Int,
  format : Int,
) -> Texture {
  @ffi.new_texture(id, width, height, mipmaps, format)
}

///|
#as_free_fn(get_texture_id)
pub fn Texture::id(self : Texture) -> UInt {
  @ffi.get_texture_id(self.0)
}

///|
#as_free_fn(get_texture_width)
pub fn Texture::width(self : Texture) -> Int {
  @ffi.get_texture_width(self.0)
}

///|
#as_free_fn(get_texture_height)
pub fn Texture::height(self : Texture) -> Int {
  @ffi.get_texture_height(self.0)
}

///|
#as_free_fn(get_texture_mipmaps)
pub fn Texture::mipmaps(self : Texture) -> Int {
  @ffi.get_texture_mipmaps(self.0)
}

///|
#as_free_fn(get_texture_format)
pub fn Texture::format(self : Texture) -> Int {
  @ffi.get_texture_format(self.0)
}

///|
#as_free_fn(set_texture_filter)
pub fn Texture::set_filter(self : Texture, filter : Int) -> Unit {
  @ffi.set_texture_filter(self.0, filter)
}

///|
#as_free_fn(set_texture_wrap)
pub fn Texture::set_wrap(self : Texture, wrap : Int) -> Unit {
  @ffi.set_texture_wrap(self.0, wrap)
}

///|
#as_free_fn(unload_texture)
pub fn Texture::unload(self : Texture) -> Unit {
  @ffi.unload_texture(self.0)
}

///|
#as_free_fn(update_texture)
pub fn Texture::update(self : Texture, pixels : Bytes) -> Unit {
  @ffi.update_texture(self.0, pixels)
}

///|
#as_free_fn(load_texture)
pub fn Texture::load(file_name : String) -> Texture {
  @ffi.load_texture(@utf8.encode(file_name))
}

///|
#as_free_fn(draw_texture)
pub fn Texture::draw(
  self : Texture,
  pos_x : Int,
  pos_y : Int,
  tint : Color,
) -> Unit {
  @ffi.draw_texture(self.0, pos_x, pos_y, tint.to_bytes())
}

///|
#as_free_fn(draw_texture_v)
pub fn Texture::draw_v(
  self : Texture,
  position : Vector2,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_v(self.0, position.to_bytes(), tint.to_bytes())
}

///|
#as_free_fn(draw_texture_ex)
pub fn Texture::draw_ex(
  self : Texture,
  position : Vector2,
  rotation : Float,
  scale : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_ex(
    self.0,
    position.to_bytes(),
    rotation,
    scale,
    tint.to_bytes(),
  )
}

///|
#as_free_fn(draw_texture_rec)
pub fn Texture::draw_rec(
  self : Texture,
  source : Rectangle,
  position : Vector2,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_rec(
    self.0,
    source.to_bytes(),
    position.to_bytes(),
    tint.to_bytes(),
  )
}

///|
#as_free_fn(draw_texture_pro)
pub fn Texture::draw_pro(
  self : Texture,
  source : Rectangle,
  dest : Rectangle,
  origin : Vector2,
  rotation : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_pro(
    self.0,
    source.to_bytes(),
    dest.to_bytes(),
    origin.to_bytes(),
    rotation,
    tint.to_bytes(),
  )
}

///|
#as_free_fn(draw_texture_npatch)
pub fn Texture::draw_npatch(
  self : Texture,
  npatch_info : NPatchInfo,
  dest : Rectangle,
  origin : Vector2,
  rotation : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_texture_npatch(
    self.0,
    npatch_info.to_bytes(),
    dest.to_bytes(),
    origin.to_bytes(),
    rotation,
    tint.to_bytes(),
  )
}

///|
#as_free_fn(update_texture_rec)
pub fn Texture::update_rec(
  self : Texture,
  rec : Rectangle,
  pixels : Bytes,
) -> Unit {
  @ffi.update_texture_rec(self.0, rec.to_bytes(), pixels)
}

///|
#as_free_fn(set_shapes_texture)
pub fn Texture::set_shapes(self : Texture, source : Rectangle) -> Unit {
  @ffi.set_shapes_texture(self.0, source.to_bytes())
}

///|
#as_free_fn(gen_texture_mipmaps)
pub fn Texture::gen_mipmaps(self : Texture) -> Unit {
  @ffi.gen_texture_mipmaps(self.0)
}

///|
#as_free_fn(texture_from_id, deprecated="Use Texture::new instead")
#deprecated("Use Texture::new instead")
pub fn Texture::from_id(id : UInt, width : Int, height : Int) -> Texture {
  @ffi.new_texture(id, width, height, 1, PixelformatUncompressedR8g8b8a8)
}

///|
#as_free_fn(get_shapes_texture)
pub fn Texture::get_shapes() -> Texture {
  @ffi.get_shapes_texture()
}

///|
#as_free_fn(update_texture_from_image_frame)
pub fn Texture::update_from_image_frame(
  self : Texture,
  image : Image,
  frame : Int,
) -> Unit {
  @ffi.update_texture_from_image_frame(self.0, image.0, frame)
}

///|
#as_free_fn(is_texture_valid)
pub fn Texture::is_valid(self : Texture) -> Bool {
  @ffi.is_texture_valid(self.0)
}
