// Re-export passthrough functions from internal FFI layer
///|
pub using @raylib {
  type Image,
  type Texture,
  unload_image,
  load_texture_from_image,
  is_texture_valid,
  unload_texture,
  load_render_texture,
  is_render_texture_valid,
  unload_render_texture,
}

// ============================================================================
// Image loading (wrappers)
// ============================================================================

///|
pub fn load_image(file_name : String) -> Image {
  @raylib.load_image(@utf8.encode(file_name))
}

///|
pub fn gen_image_color(width : Int, height : Int, color : Color) -> Image {
  @raylib.gen_image_color(width, height, color.to_bytes())
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
  @raylib.gen_image_checked(
    width,
    height,
    checks_x,
    checks_y,
    col1.to_bytes(),
    col2.to_bytes(),
  )
}

// ============================================================================
// Texture loading (wrappers)
// ============================================================================

///|
pub fn load_texture(file_name : String) -> Texture {
  @raylib.load_texture(@utf8.encode(file_name))
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
  @raylib.draw_texture(texture, pos_x, pos_y, tint.to_bytes())
}

///|
pub fn draw_texture_v(
  texture : Texture,
  position : Vector2,
  tint : Color,
) -> Unit {
  @raylib.draw_texture_v(texture, position.to_bytes(), tint.to_bytes())
}

///|
pub fn draw_texture_ex(
  texture : Texture,
  position : Vector2,
  rotation : Float,
  scale : Float,
  tint : Color,
) -> Unit {
  @raylib.draw_texture_ex(
    texture,
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
  @raylib.draw_texture_rec(
    texture,
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
  @raylib.draw_texture_pro(
    texture,
    source.to_bytes(),
    dest.to_bytes(),
    origin.to_bytes(),
    rotation,
    tint.to_bytes(),
  )
}
