// ============================================================================
// Image loading
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_image(file_name : Bytes) -> Image = "moonbit_raylib_load_image"

///|
#borrow(image)
pub extern "c" fn unload_image(image : Image) = "moonbit_raylib_unload_image"

///|
#borrow(color)
pub extern "c" fn gen_image_color(
  width : Int,
  height : Int,
  color : Bytes,
) -> Image = "moonbit_raylib_gen_image_color"

///|
#borrow(col1, col2)
pub extern "c" fn gen_image_checked(
  width : Int,
  height : Int,
  checks_x : Int,
  checks_y : Int,
  col1 : Bytes,
  col2 : Bytes,
) -> Image = "moonbit_raylib_gen_image_checked"

// ============================================================================
// Image generation
// ============================================================================

///|
#borrow(start_color, end_color)
pub extern "c" fn gen_image_gradient_linear(
  width : Int,
  height : Int,
  direction : Int,
  start_color : Bytes,
  end_color : Bytes,
) -> Image = "moonbit_raylib_gen_image_gradient_linear"

///|
#borrow(inner, outer)
pub extern "c" fn gen_image_gradient_radial(
  width : Int,
  height : Int,
  density : Float,
  inner : Bytes,
  outer : Bytes,
) -> Image = "moonbit_raylib_gen_image_gradient_radial"

///|
#borrow(inner, outer)
pub extern "c" fn gen_image_gradient_square(
  width : Int,
  height : Int,
  density : Float,
  inner : Bytes,
  outer : Bytes,
) -> Image = "moonbit_raylib_gen_image_gradient_square"

///|
pub extern "c" fn gen_image_white_noise(
  width : Int,
  height : Int,
  factor : Float,
) -> Image = "moonbit_raylib_gen_image_white_noise"

///|
pub extern "c" fn gen_image_perlin_noise(
  width : Int,
  height : Int,
  offset_x : Int,
  offset_y : Int,
  scale : Float,
) -> Image = "moonbit_raylib_gen_image_perlin_noise"

///|
pub extern "c" fn gen_image_cellular(
  width : Int,
  height : Int,
  tile_size : Int,
) -> Image = "moonbit_raylib_gen_image_cellular"

///|
#borrow(text)
pub extern "c" fn gen_image_text(
  width : Int,
  height : Int,
  text : Bytes,
) -> Image = "moonbit_raylib_gen_image_text"

// ============================================================================
// Image loading extras
// ============================================================================

///|
#borrow(file_type, file_data)
pub extern "c" fn load_image_from_memory(
  file_type : Bytes,
  file_data : Bytes,
  data_size : Int,
) -> Image = "moonbit_raylib_load_image_from_memory"

///|
#borrow(texture)
pub extern "c" fn load_image_from_texture(texture : Texture) -> Image = "moonbit_raylib_load_image_from_texture"

///|
pub extern "c" fn load_image_from_screen() -> Image = "moonbit_raylib_load_image_from_screen"

///|
#borrow(image)
pub extern "c" fn is_image_valid(image : Image) -> Bool = "moonbit_raylib_is_image_valid"

///|
#borrow(image, file_name)
pub extern "c" fn export_image(image : Image, file_name : Bytes) -> Bool = "moonbit_raylib_export_image"

// ============================================================================
// Image basic ops
// ============================================================================

///|
#borrow(image)
pub extern "c" fn image_copy(image : Image) -> Image = "moonbit_raylib_image_copy"

///|
#borrow(image, rec)
pub extern "c" fn image_from_image(image : Image, rec : Bytes) -> Image = "moonbit_raylib_image_from_image"

///|
#borrow(image)
pub extern "c" fn image_from_channel(
  image : Image,
  selected_channel : Int,
) -> Image = "moonbit_raylib_image_from_channel"

// ============================================================================
// Texture loading
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_texture(file_name : Bytes) -> Texture = "moonbit_raylib_load_texture"

///|
#borrow(image)
pub extern "c" fn load_texture_from_image(image : Image) -> Texture = "moonbit_raylib_load_texture_from_image"

///|
#borrow(texture)
pub extern "c" fn is_texture_valid(texture : Texture) -> Bool = "moonbit_raylib_is_texture_valid"

///|
#borrow(texture)
pub extern "c" fn unload_texture(texture : Texture) = "moonbit_raylib_unload_texture"

///|
pub extern "c" fn load_render_texture(
  width : Int,
  height : Int,
) -> RenderTexture = "moonbit_raylib_load_render_texture"

///|
#borrow(target)
pub extern "c" fn is_render_texture_valid(target : RenderTexture) -> Bool = "moonbit_raylib_is_render_texture_valid"

///|
#borrow(target)
pub extern "c" fn unload_render_texture(target : RenderTexture) = "moonbit_raylib_unload_render_texture"

// ============================================================================
// RenderTexture drawing
// ============================================================================

///|
#borrow(target, source, position, tint)
pub extern "c" fn draw_render_texture_rec(
  target : RenderTexture,
  source : Bytes,
  position : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_render_texture_rec"

///|
#borrow(target)
pub extern "c" fn get_render_texture_width(target : RenderTexture) -> Int = "moonbit_raylib_get_render_texture_width"

///|
#borrow(target)
pub extern "c" fn get_render_texture_height(target : RenderTexture) -> Int = "moonbit_raylib_get_render_texture_height"

///|
#borrow(target, position, tint)
pub extern "c" fn draw_render_texture_ex(
  target : RenderTexture,
  position : Bytes,
  rotation : Float,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_render_texture_ex"

///|
#borrow(target, source, dest, origin, tint)
pub extern "c" fn draw_render_texture_pro(
  target : RenderTexture,
  source : Bytes,
  dest : Bytes,
  origin : Bytes,
  rotation : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_render_texture_pro"

///|
#borrow(target)
pub extern "c" fn set_render_texture_filter(
  target : RenderTexture,
  filter : Int,
) = "moonbit_raylib_set_render_texture_filter"

// ============================================================================
// Texture drawing
// ============================================================================

///|
#borrow(texture, tint)
pub extern "c" fn draw_texture(
  texture : Texture,
  pos_x : Int,
  pos_y : Int,
  tint : Bytes,
) = "moonbit_raylib_draw_texture"

///|
#borrow(texture, position, tint)
pub extern "c" fn draw_texture_v(
  texture : Texture,
  position : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_texture_v"

///|
#borrow(texture, position, tint)
pub extern "c" fn draw_texture_ex(
  texture : Texture,
  position : Bytes,
  rotation : Float,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_texture_ex"

///|
#borrow(texture, source, position, tint)
pub extern "c" fn draw_texture_rec(
  texture : Texture,
  source : Bytes,
  position : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_texture_rec"

///|
#borrow(texture, source, dest, origin, tint)
pub extern "c" fn draw_texture_pro(
  texture : Texture,
  source : Bytes,
  dest : Bytes,
  origin : Bytes,
  rotation : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_texture_pro"

///|
#borrow(texture, npatch_info, dest, origin, tint)
pub extern "c" fn draw_texture_npatch(
  texture : Texture,
  npatch_info : Bytes,
  dest : Bytes,
  origin : Bytes,
  rotation : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_texture_npatch"

// ============================================================================
// Texture configuration
// ============================================================================

///|
#borrow(texture)
pub extern "c" fn set_texture_filter(texture : Texture, filter : Int) = "moonbit_raylib_set_texture_filter"

///|
#borrow(texture)
pub extern "c" fn set_texture_wrap(texture : Texture, wrap : Int) = "moonbit_raylib_set_texture_wrap"

// ============================================================================
// Texture management extras
// ============================================================================

///|
#borrow(image)
pub extern "c" fn load_texture_cubemap(image : Image, layout : Int) -> Texture = "moonbit_raylib_load_texture_cubemap"

///|
#borrow(texture, pixels)
pub extern "c" fn update_texture(texture : Texture, pixels : Bytes) = "moonbit_raylib_update_texture"

///|
#borrow(texture, rec, pixels)
pub extern "c" fn update_texture_rec(
  texture : Texture,
  rec : Bytes,
  pixels : Bytes,
) = "moonbit_raylib_update_texture_rec"

///|
#borrow(texture)
pub extern "c" fn gen_texture_mipmaps(texture : Texture) = "moonbit_raylib_gen_texture_mipmaps"

///|
#borrow(texture, source)
pub extern "c" fn set_shapes_texture(texture : Texture, source : Bytes) = "moonbit_raylib_set_shapes_texture"

///|
pub extern "c" fn get_shapes_texture() -> Texture = "moonbit_raylib_get_shapes_texture"

///|
pub extern "c" fn get_shapes_texture_rectangle() -> Bytes = "moonbit_raylib_get_shapes_texture_rectangle"

// ============================================================================
// Clipboard image
// ============================================================================

///|
pub extern "c" fn get_clipboard_image() -> Image = "moonbit_raylib_get_clipboard_image"

