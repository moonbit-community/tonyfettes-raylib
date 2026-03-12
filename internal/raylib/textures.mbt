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
#borrow(texture_memory)
pub extern "c" fn load_image_from_texture(
  texture_memory : Bytes,
  texture_offset : Int,
) -> Image = "moonbit_raylib_load_image_from_texture"

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
pub extern "c" fn load_texture(file_name : Bytes) -> Bytes = "moonbit_raylib_load_texture"

///|
#borrow(image)
pub extern "c" fn load_texture_from_image(image : Image) -> Bytes = "moonbit_raylib_load_texture_from_image"

///|
#borrow(texture_memory)
pub extern "c" fn is_texture_valid(
  texture_memory : Bytes,
  texture_offset : Int,
) -> Bool = "moonbit_raylib_is_texture_valid"

///|
#borrow(texture_memory)
pub extern "c" fn unload_texture(texture_memory : Bytes, texture_offset : Int) = "moonbit_raylib_unload_texture"

///|
pub extern "c" fn load_render_texture(width : Int, height : Int) -> Bytes = "moonbit_raylib_load_render_texture"

///|
#borrow(render_texture_memory)
pub extern "c" fn is_render_texture_valid(
  render_texture_memory : Bytes,
  render_texture_offset : Int,
) -> Bool = "moonbit_raylib_is_render_texture_valid"

///|
#borrow(render_texture_memory)
pub extern "c" fn unload_render_texture(
  render_texture_memory : Bytes,
  render_texture_offset : Int,
) = "moonbit_raylib_unload_render_texture"

///|
pub fn load_render_texture_depth_tex(width : Int, height : Int) -> Bytes {
  let fbo_id = rl_load_framebuffer()
  let color_tex_id = rl_load_texture(width, height, 7, 1) // 7 = PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
  let depth_tex_id = rl_load_texture_depth(width, height, false)
  rl_framebuffer_attach(fbo_id, color_tex_id, 0, 100, 0) // 0 = RL_ATTACHMENT_COLOR_CHANNEL0, 100 = RL_ATTACHMENT_TEXTURE2D
  rl_framebuffer_attach(fbo_id, depth_tex_id, 100, 100, 0) // 100 = RL_ATTACHMENT_DEPTH, 100 = RL_ATTACHMENT_TEXTURE2D
  let _ = rl_framebuffer_complete(fbo_id)
  new_render_texture(
    fbo_id,
    new_texture(color_tex_id, width, height, 1, 7),
    0,
    new_texture(depth_tex_id, width, height, 1, 7),
    0,
  )
}

// ============================================================================
// RenderTexture: constructor from raw IDs
// ============================================================================

///|
#borrow(texture_memory, depth_memory)
pub extern "c" fn new_render_texture(
  id : UInt,
  texture_memory : Bytes,
  texture_offset : Int,
  depth_memory : Bytes,
  depth_offset : Int,
) -> Bytes = "moonbit_raylib_new_render_texture"

// ============================================================================
// RenderTexture drawing
// ============================================================================

///|
#borrow(render_texture_memory, source, position, tint)
pub extern "c" fn draw_render_texture_rec(
  render_texture_memory : Bytes,
  render_texture_offset : Int,
  source : Bytes,
  position : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_render_texture_rec"

///|
#borrow(render_texture_memory)
pub extern "c" fn get_render_texture_width(
  render_texture_memory : Bytes,
  render_texture_offset : Int,
) -> Int = "moonbit_raylib_get_render_texture_width"

///|
#borrow(render_texture_memory)
pub extern "c" fn get_render_texture_height(
  render_texture_memory : Bytes,
  render_texture_offset : Int,
) -> Int = "moonbit_raylib_get_render_texture_height"

///|
#borrow(render_texture_memory, position, tint)
pub extern "c" fn draw_render_texture_ex(
  render_texture_memory : Bytes,
  render_texture_offset : Int,
  position : Bytes,
  rotation : Float,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_render_texture_ex"

///|
#borrow(render_texture_memory, source, dest, origin, tint)
pub extern "c" fn draw_render_texture_pro(
  render_texture_memory : Bytes,
  render_texture_offset : Int,
  source : Bytes,
  dest : Bytes,
  origin : Bytes,
  rotation : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_render_texture_pro"

///|
#borrow(render_texture_memory)
pub extern "c" fn set_render_texture_filter(
  render_texture_memory : Bytes,
  render_texture_offset : Int,
  filter : Int,
) = "moonbit_raylib_set_render_texture_filter"

// ============================================================================
// Texture: get width/height
// ============================================================================

///|
#borrow(texture_memory)
pub extern "c" fn get_texture_width(
  texture_memory : Bytes,
  texture_offset : Int,
) -> Int = "moonbit_raylib_get_texture_width"

///|
#borrow(texture_memory)
pub extern "c" fn get_texture_height(
  texture_memory : Bytes,
  texture_offset : Int,
) -> Int = "moonbit_raylib_get_texture_height"

// ============================================================================
// RenderTexture: get texture
// ============================================================================

///|
pub extern "c" fn get_render_texture_texture() -> Int = "moonbit_raylib_get_render_texture_texture"

///|
pub extern "c" fn get_render_texture_depth() -> Int = "moonbit_raylib_get_render_texture_depth"

// ============================================================================
// RenderTexture: ID accessors for rlgl-level operations
// ============================================================================

///|
#borrow(render_texture_memory)
pub extern "c" fn get_render_texture_id(
  render_texture_memory : Bytes,
  render_texture_offset : Int,
) -> UInt = "moonbit_raylib_get_render_texture_id"

///|
#borrow(render_texture_memory)
pub extern "c" fn get_render_texture_depth_id(
  render_texture_memory : Bytes,
  render_texture_offset : Int,
) -> UInt = "moonbit_raylib_get_render_texture_depth_id"

// ============================================================================
// Shadowmap: Load/Unload depth-only render texture
// ============================================================================

///|
pub fn load_shadowmap_render_texture(width : Int, height : Int) -> Bytes {
  let fbo_id = rl_load_framebuffer()
  let depth_tex_id = rl_load_texture_depth(width, height, false)
  rl_framebuffer_attach(fbo_id, depth_tex_id, 100, 100, 0)
  let _ = rl_framebuffer_complete(fbo_id)
  new_render_texture(
    fbo_id,
    new_texture(0U, width, height, 1, 7),
    0,
    new_texture(depth_tex_id, width, height, 1, 7),
    0,
  )
}

// ============================================================================
// Texture drawing
// ============================================================================

///|
#borrow(texture_memory, tint)
pub extern "c" fn draw_texture(
  texture_memory : Bytes,
  texture_offset : Int,
  pos_x : Int,
  pos_y : Int,
  tint : Bytes,
) = "moonbit_raylib_draw_texture"

///|
#borrow(texture_memory, position, tint)
pub extern "c" fn draw_texture_v(
  texture_memory : Bytes,
  texture_offset : Int,
  position : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_texture_v"

///|
#borrow(texture_memory, position, tint)
pub extern "c" fn draw_texture_ex(
  texture_memory : Bytes,
  texture_offset : Int,
  position : Bytes,
  rotation : Float,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_texture_ex"

///|
#borrow(texture_memory, source, position, tint)
pub extern "c" fn draw_texture_rec(
  texture_memory : Bytes,
  texture_offset : Int,
  source : Bytes,
  position : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_texture_rec"

///|
#borrow(texture_memory, source, dest, origin, tint)
pub extern "c" fn draw_texture_pro(
  texture_memory : Bytes,
  texture_offset : Int,
  source : Bytes,
  dest : Bytes,
  origin : Bytes,
  rotation : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_texture_pro"

///|
#borrow(texture_memory, npatch_info, dest, origin, tint)
pub extern "c" fn draw_texture_npatch(
  texture_memory : Bytes,
  texture_offset : Int,
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
#borrow(texture_memory)
pub extern "c" fn set_texture_filter(
  texture_memory : Bytes,
  texture_offset : Int,
  filter : Int,
) = "moonbit_raylib_set_texture_filter"

///|
#borrow(texture_memory)
pub extern "c" fn set_texture_wrap(
  texture_memory : Bytes,
  texture_offset : Int,
  wrap : Int,
) = "moonbit_raylib_set_texture_wrap"

// ============================================================================
// Texture management extras
// ============================================================================

///|
#borrow(image)
pub extern "c" fn load_texture_cubemap(image : Image, layout : Int) -> Bytes = "moonbit_raylib_load_texture_cubemap"

///|
#borrow(texture_memory, pixels)
pub extern "c" fn update_texture(
  texture_memory : Bytes,
  texture_offset : Int,
  pixels : Bytes,
) = "moonbit_raylib_update_texture"

///|
#borrow(texture_memory, rec, pixels)
pub extern "c" fn update_texture_rec(
  texture_memory : Bytes,
  texture_offset : Int,
  rec : Bytes,
  pixels : Bytes,
) = "moonbit_raylib_update_texture_rec"

///|
#borrow(texture_memory)
pub extern "c" fn gen_texture_mipmaps(
  texture_memory : Bytes,
  texture_offset : Int,
) = "moonbit_raylib_gen_texture_mipmaps"

///|
#borrow(texture_memory, image)
pub extern "c" fn update_texture_from_image_frame(
  texture_memory : Bytes,
  texture_offset : Int,
  image : Image,
  frame : Int,
) = "moonbit_raylib_update_texture_from_image_frame"

///|
#borrow(texture_memory)
pub extern "c" fn get_texture_id(
  texture_memory : Bytes,
  texture_offset : Int,
) -> UInt = "moonbit_raylib_get_texture_id"

///|
#borrow(texture_memory, source)
pub extern "c" fn set_shapes_texture(
  texture_memory : Bytes,
  texture_offset : Int,
  source : Bytes,
) = "moonbit_raylib_set_shapes_texture"

///|
pub extern "c" fn get_shapes_texture() -> Bytes = "moonbit_raylib_get_shapes_texture"

///|
pub extern "c" fn get_shapes_texture_rectangle() -> Bytes = "moonbit_raylib_get_shapes_texture_rectangle"

// ============================================================================
// Clipboard image
// ============================================================================

///|
pub extern "c" fn get_clipboard_image() -> Image = "moonbit_raylib_get_clipboard_image"

// ============================================================================
// rlgl: Load texture (NULL data, for framebuffer color attachments)
// ============================================================================

///|
pub extern "c" fn rl_load_texture(
  width : Int,
  height : Int,
  format : Int,
  mipmap_count : Int,
) -> UInt = "moonbit_raylib_rl_load_texture"

// ============================================================================
// Texture from raw GL ID (non-owning, for drawing GBuffer textures)
// ============================================================================

///|
pub extern "c" fn new_texture(
  id : UInt,
  width : Int,
  height : Int,
  mipmaps : Int,
  format : Int,
) -> Bytes = "moonbit_raylib_new_texture"
