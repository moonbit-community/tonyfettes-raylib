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
