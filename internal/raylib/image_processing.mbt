// ============================================================================
// Image loading: LoadImageRaw, LoadImageAnim, LoadImageAnimFromMemory
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_image_raw(
  file_name : Bytes,
  width : Int,
  height : Int,
  format : Int,
  header_size : Int,
) -> Image = "moonbit_raylib_load_image_raw"

///|
#borrow(file_name)
pub extern "c" fn load_image_anim(file_name : Bytes) -> Image = "moonbit_raylib_load_image_anim"

///|
pub extern "c" fn image_frame_count(image : Image) -> Int = "moonbit_raylib_image_frame_count"

///|
#borrow(file_type, file_data)
pub extern "c" fn load_image_anim_from_memory(
  file_type : Bytes,
  file_data : Bytes,
  data_size : Int,
) -> Image = "moonbit_raylib_load_image_anim_from_memory"

// ============================================================================
// Image dimensions
// ============================================================================

///|
pub extern "c" fn image_width(image : Image) -> Int = "moonbit_raylib_image_width"

///|
pub extern "c" fn image_height(image : Image) -> Int = "moonbit_raylib_image_height"

// ============================================================================
// In-place mutations: primitives only
// ============================================================================

///|
pub extern "c" fn image_format(image : Image, new_format : Int) = "moonbit_raylib_image_format"

///|
pub extern "c" fn image_alpha_crop(image : Image, threshold : Float) = "moonbit_raylib_image_alpha_crop"

///|
pub extern "c" fn image_alpha_premultiply(image : Image) = "moonbit_raylib_image_alpha_premultiply"

///|
pub extern "c" fn image_blur_gaussian(image : Image, blur_size : Int) = "moonbit_raylib_image_blur_gaussian"

///|
pub extern "c" fn image_resize(
  image : Image,
  new_width : Int,
  new_height : Int,
) = "moonbit_raylib_image_resize"

///|
pub extern "c" fn image_resize_nn(
  image : Image,
  new_width : Int,
  new_height : Int,
) = "moonbit_raylib_image_resize_nn"

///|
pub extern "c" fn image_mipmaps(image : Image) = "moonbit_raylib_image_mipmaps"

///|
pub extern "c" fn image_dither(
  image : Image,
  r_bpp : Int,
  g_bpp : Int,
  b_bpp : Int,
  a_bpp : Int,
) = "moonbit_raylib_image_dither"

///|
pub extern "c" fn image_flip_vertical(image : Image) = "moonbit_raylib_image_flip_vertical"

///|
pub extern "c" fn image_flip_horizontal(image : Image) = "moonbit_raylib_image_flip_horizontal"

///|
pub extern "c" fn image_rotate(image : Image, degrees : Int) = "moonbit_raylib_image_rotate"

///|
pub extern "c" fn image_rotate_cw(image : Image) = "moonbit_raylib_image_rotate_cw"

///|
pub extern "c" fn image_rotate_ccw(image : Image) = "moonbit_raylib_image_rotate_ccw"

///|
pub extern "c" fn image_color_invert(image : Image) = "moonbit_raylib_image_color_invert"

///|
pub extern "c" fn image_color_grayscale(image : Image) = "moonbit_raylib_image_color_grayscale"

// ============================================================================
// In-place mutations: value type params
// ============================================================================

///|
#borrow(fill)
pub extern "c" fn image_to_pot(image : Image, fill : Bytes) = "moonbit_raylib_image_to_pot"

///|
#borrow(crop)
pub extern "c" fn image_crop(image : Image, crop : Bytes) = "moonbit_raylib_image_crop"

///|
#borrow(color)
pub extern "c" fn image_alpha_clear(
  image : Image,
  color : Bytes,
  threshold : Float,
) = "moonbit_raylib_image_alpha_clear"

///|
pub extern "c" fn image_alpha_mask(image : Image, alpha_mask : Image) = "moonbit_raylib_image_alpha_mask"

///|
#borrow(fill)
pub extern "c" fn image_resize_canvas(
  image : Image,
  new_width : Int,
  new_height : Int,
  offset_x : Int,
  offset_y : Int,
  fill : Bytes,
) = "moonbit_raylib_image_resize_canvas"

///|
#borrow(color)
pub extern "c" fn image_color_tint(image : Image, color : Bytes) = "moonbit_raylib_image_color_tint"

///|
pub extern "c" fn image_color_contrast(image : Image, contrast : Float) = "moonbit_raylib_image_color_contrast"

///|
pub extern "c" fn image_color_brightness(image : Image, brightness : Int) = "moonbit_raylib_image_color_brightness"

///|
#borrow(color, replace)
pub extern "c" fn image_color_replace(
  image : Image,
  color : Bytes,
  replace : Bytes,
) = "moonbit_raylib_image_color_replace"

///|
#borrow(kernel)
pub extern "c" fn image_kernel_convolution(
  image : Image,
  kernel : Bytes,
  kernel_size : Int,
) = "moonbit_raylib_image_kernel_convolution"

// ============================================================================
// Image creation: ImageText, ImageTextEx
// ============================================================================

///|
#borrow(text, color)
pub extern "c" fn image_text(
  text : Bytes,
  font_size : Int,
  color : Bytes,
) -> Image = "moonbit_raylib_image_text"

///|
#borrow(text, tint)
pub extern "c" fn image_text_ex(
  font : Font,
  text : Bytes,
  font_size : Float,
  spacing : Float,
  tint : Bytes,
) -> Image = "moonbit_raylib_image_text_ex"

// ============================================================================
// Queries: GetImageAlphaBorder, GetImageColor
// ============================================================================

///|
pub extern "c" fn get_image_alpha_border(
  image : Image,
  threshold : Float,
) -> Bytes = "moonbit_raylib_get_image_alpha_border"

///|
pub extern "c" fn get_image_color(image : Image, x : Int, y : Int) -> Bytes = "moonbit_raylib_get_image_color"

// ============================================================================
// Copy-and-free: LoadImageColors, LoadImagePalette
// ============================================================================

///|
pub extern "c" fn load_image_colors(image : Image) -> Bytes = "moonbit_raylib_load_image_colors"

///|
pub extern "c" fn load_image_palette(
  image : Image,
  max_palette_size : Int,
) -> Bytes = "moonbit_raylib_load_image_palette"

// ============================================================================
// Export: ExportImageToMemory, ExportImageAsCode
// ============================================================================

///|
#borrow(file_type)
pub extern "c" fn export_image_to_memory(
  image : Image,
  file_type : Bytes,
) -> Bytes = "moonbit_raylib_export_image_to_memory"

///|
#borrow(file_name)
pub extern "c" fn export_image_as_code(
  image : Image,
  file_name : Bytes,
) -> Bool = "moonbit_raylib_export_image_as_code"
