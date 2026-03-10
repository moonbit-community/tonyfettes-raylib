///|
struct RenderTexture(@ffi.RenderTexture)

///|
#as_free_fn(new_render_texture)
pub fn RenderTexture::new(
  id : UInt,
  texture : Texture,
  depth : Texture,
) -> RenderTexture {
  @ffi.new_render_texture(id, texture.0, depth.0)
}

///|
#as_free_fn(get_render_texture_texture)
pub fn RenderTexture::texture(self : RenderTexture) -> Texture {
  @ffi.get_render_texture_texture(self.0)
}

///|
#as_free_fn(get_render_texture_depth)
pub fn RenderTexture::depth(self : RenderTexture) -> Texture {
  @ffi.get_render_texture_depth(self.0)
}

///|
#as_free_fn(load_render_texture)
pub fn RenderTexture::load(width : Int, height : Int) -> RenderTexture {
  @ffi.load_render_texture(width, height)
}

///|
#as_free_fn(is_render_texture_valid)
pub fn RenderTexture::is_valid(self : RenderTexture) -> Bool {
  @ffi.is_render_texture_valid(self.0)
}

///|
#as_free_fn(unload_render_texture)
pub fn RenderTexture::unload(self : RenderTexture) -> Unit {
  @ffi.unload_render_texture(self.0)
}

///|
#as_free_fn(draw_render_texture_rec)
pub fn RenderTexture::draw_rec(
  self : RenderTexture,
  source : Rectangle,
  position : Vector2,
  tint : Color,
) -> Unit {
  @ffi.draw_render_texture_rec(
    self.0,
    source.to_bytes(),
    position.to_bytes(),
    tint.to_bytes(),
  )
}

///|
#as_free_fn(draw_render_texture_ex)
pub fn RenderTexture::draw_ex(
  self : RenderTexture,
  position : Vector2,
  rotation : Float,
  scale : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_render_texture_ex(
    self.0,
    position.to_bytes(),
    rotation,
    scale,
    tint.to_bytes(),
  )
}

///|
#as_free_fn(draw_render_texture_pro)
pub fn RenderTexture::draw_pro(
  self : RenderTexture,
  source : Rectangle,
  dest : Rectangle,
  origin : Vector2,
  rotation : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_render_texture_pro(
    self.0,
    source.to_bytes(),
    dest.to_bytes(),
    origin.to_bytes(),
    rotation,
    tint.to_bytes(),
  )
}

///|
#as_free_fn(set_render_texture_filter)
pub fn RenderTexture::set_filter(self : RenderTexture, filter : Int) -> Unit {
  @ffi.set_render_texture_filter(self.0, filter)
}

///|
#as_free_fn(get_render_texture_width)
pub fn RenderTexture::width(self : RenderTexture) -> Int {
  @ffi.get_render_texture_width(self.0)
}

///|
#as_free_fn(get_render_texture_height)
pub fn RenderTexture::height(self : RenderTexture) -> Int {
  @ffi.get_render_texture_height(self.0)
}

///|
#as_free_fn(get_render_texture_fbo_id)
pub fn RenderTexture::fbo_id(self : RenderTexture) -> UInt {
  @ffi.get_render_texture_fbo_id(self.0)
}

///|
#as_free_fn(get_render_texture_depth_id)
pub fn RenderTexture::depth_id(self : RenderTexture) -> UInt {
  @ffi.get_render_texture_depth_id(self.0)
}

///|
#as_free_fn(begin_texture_mode)
pub fn RenderTexture::begin_mode(self : RenderTexture) -> Unit {
  @ffi.begin_texture_mode(self.0)
}
