// Re-export passthrough functions from internal FFI layer

///|
pub using @raylib {
  type Image,
  type Texture,
  unload_image,
  is_image_valid,
  image_copy,
  image_from_channel,
  load_image_from_texture,
  load_image_from_screen,
  load_texture_from_image,
  is_texture_valid,
  unload_texture,
  load_render_texture,
  load_render_texture_depth_tex,
  is_render_texture_valid,
  unload_render_texture,
  gen_image_white_noise,
  gen_image_perlin_noise,
  gen_image_cellular,
  set_texture_filter,
  set_texture_wrap,
  load_texture_cubemap,
  update_texture,
  update_texture_from_image_frame,
  gen_texture_mipmaps,
  get_texture_id,
  get_shapes_texture,
  get_render_texture_width,
  get_render_texture_height,
  get_texture_width,
  get_texture_height,
  get_render_texture_texture,
  load_render_texture_depth_tex,
  unload_render_texture_depth_tex,
  get_render_texture_fbo_id,
  get_render_texture_depth_id,
  load_shadowmap_render_texture,
  unload_shadowmap_render_texture,
  texture_from_id,
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

///|
pub fn gen_image_gradient_linear(
  width : Int,
  height : Int,
  direction : Int,
  start : Color,
  end_ : Color,
) -> Image {
  @raylib.gen_image_gradient_linear(
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
  @raylib.gen_image_gradient_radial(
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
  @raylib.gen_image_gradient_square(
    width,
    height,
    density,
    inner.to_bytes(),
    outer.to_bytes(),
  )
}

///|
pub fn gen_image_text(width : Int, height : Int, text : String) -> Image {
  @raylib.gen_image_text(width, height, @utf8.encode(text))
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
  @raylib.load_image_from_memory(@utf8.encode(file_type), file_data, data_size)
}

///|
pub fn export_image(image : Image, file_name : String) -> Bool {
  @raylib.export_image(image, @utf8.encode(file_name))
}

// ============================================================================
// Image basic ops (wrappers)
// ============================================================================

///|
pub fn image_from_image(image : Image, rec : Rectangle) -> Image {
  @raylib.image_from_image(image, rec.to_bytes())
}

// ============================================================================
// Texture loading (wrappers)
// ============================================================================

///|
pub fn load_texture(file_name : String) -> Texture {
  @raylib.load_texture(@utf8.encode(file_name))
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
  @raylib.draw_render_texture_rec(
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
  @raylib.draw_render_texture_ex(
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
  @raylib.draw_render_texture_pro(
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
  @raylib.set_render_texture_filter(target, filter)
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

///|
pub fn draw_texture_npatch(
  texture : Texture,
  npatch_info : NPatchInfo,
  dest : Rectangle,
  origin : Vector2,
  rotation : Float,
  tint : Color,
) -> Unit {
  @raylib.draw_texture_npatch(
    texture,
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
pub let texture_filter_point : Int = 0

///|
pub let texture_filter_bilinear : Int = 1

///|
pub let texture_filter_trilinear : Int = 2

///|
pub let texture_filter_anisotropic_4x : Int = 3

///|
pub let texture_filter_anisotropic_8x : Int = 4

///|
pub let texture_filter_anisotropic_16x : Int = 5

// ============================================================================
// Texture wrap constants
// ============================================================================

///|
pub let texture_wrap_repeat : Int = 0

///|
pub let texture_wrap_clamp : Int = 1

///|
pub let texture_wrap_mirror_repeat : Int = 2

///|
pub let texture_wrap_mirror_clamp : Int = 3

// ============================================================================
// Pixel format constants
// ============================================================================

///|
pub let pixelformat_uncompressed_grayscale : Int = 1

///|
pub let pixelformat_uncompressed_gray_alpha : Int = 2

///|
pub let pixelformat_uncompressed_r5g6b5 : Int = 3

///|
pub let pixelformat_uncompressed_r8g8b8 : Int = 4

///|
pub let pixelformat_uncompressed_r5g5b5a1 : Int = 5

///|
pub let pixelformat_uncompressed_r4g4b4a4 : Int = 6

///|
pub let pixelformat_uncompressed_r8g8b8a8 : Int = 7

///|
pub let pixelformat_uncompressed_r32 : Int = 8

///|
pub let pixelformat_uncompressed_r32g32b32 : Int = 9

///|
pub let pixelformat_uncompressed_r32g32b32a32 : Int = 10

// ============================================================================
// Texture management extras (wrappers)
// ============================================================================

///|
pub fn update_texture_rec(
  texture : Texture,
  rec : Rectangle,
  pixels : Bytes,
) -> Unit {
  @raylib.update_texture_rec(texture, rec.to_bytes(), pixels)
}

///|
pub fn set_shapes_texture(texture : Texture, source : Rectangle) -> Unit {
  @raylib.set_shapes_texture(texture, source.to_bytes())
}

///|
pub fn get_shapes_texture_rectangle() -> Rectangle {
  Rectangle::from_bytes(@raylib.get_shapes_texture_rectangle())
}

// ============================================================================
// Cubemap layout constants
// ============================================================================

///|
pub let cubemap_layout_auto_detect : Int = 0

///|
pub let cubemap_layout_line_vertical : Int = 1

///|
pub let cubemap_layout_line_horizontal : Int = 2

///|
pub let cubemap_layout_cross_three_by_four : Int = 3

///|
pub let cubemap_layout_cross_four_by_three : Int = 4

