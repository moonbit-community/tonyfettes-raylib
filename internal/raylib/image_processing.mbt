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
#borrow(image)
pub extern "c" fn image_frame_count(image : Image) -> Int = "moonbit_raylib_image_frame_count"

///|
#borrow(file_type, file_data)
pub extern "c" fn load_image_anim_from_memory(
  file_type : Bytes,
  file_data : Bytes,
  data_size : Int,
) -> Image = "moonbit_raylib_load_image_anim_from_memory"

// ============================================================================
// In-place mutations: primitives only
// ============================================================================

///|
#borrow(image)
pub extern "c" fn image_format(image : Image, new_format : Int) = "moonbit_raylib_image_format"

///|
#borrow(image)
pub extern "c" fn image_alpha_crop(image : Image, threshold : Float) = "moonbit_raylib_image_alpha_crop"

///|
#borrow(image)
pub extern "c" fn image_alpha_premultiply(image : Image) = "moonbit_raylib_image_alpha_premultiply"

///|
#borrow(image)
pub extern "c" fn image_blur_gaussian(image : Image, blur_size : Int) = "moonbit_raylib_image_blur_gaussian"

///|
#borrow(image)
pub extern "c" fn image_resize(image : Image, new_width : Int, new_height : Int) = "moonbit_raylib_image_resize"

///|
#borrow(image)
pub extern "c" fn image_resize_nn(image : Image, new_width : Int, new_height : Int) = "moonbit_raylib_image_resize_nn"

///|
#borrow(image)
pub extern "c" fn image_mipmaps(image : Image) = "moonbit_raylib_image_mipmaps"

///|
#borrow(image)
pub extern "c" fn image_dither(
  image : Image,
  r_bpp : Int,
  g_bpp : Int,
  b_bpp : Int,
  a_bpp : Int,
) = "moonbit_raylib_image_dither"

///|
#borrow(image)
pub extern "c" fn image_flip_vertical(image : Image) = "moonbit_raylib_image_flip_vertical"

///|
#borrow(image)
pub extern "c" fn image_flip_horizontal(image : Image) = "moonbit_raylib_image_flip_horizontal"

///|
#borrow(image)
pub extern "c" fn image_rotate(image : Image, degrees : Int) = "moonbit_raylib_image_rotate"

///|
#borrow(image)
pub extern "c" fn image_rotate_cw(image : Image) = "moonbit_raylib_image_rotate_cw"

///|
#borrow(image)
pub extern "c" fn image_rotate_ccw(image : Image) = "moonbit_raylib_image_rotate_ccw"

///|
#borrow(image)
pub extern "c" fn image_color_invert(image : Image) = "moonbit_raylib_image_color_invert"

///|
#borrow(image)
pub extern "c" fn image_color_grayscale(image : Image) = "moonbit_raylib_image_color_grayscale"

// ============================================================================
// In-place mutations: value type params
// ============================================================================

///|
#borrow(image, fill)
pub extern "c" fn image_to_pot(image : Image, fill : Bytes) = "moonbit_raylib_image_to_pot"

///|
#borrow(image, crop)
pub extern "c" fn image_crop(image : Image, crop : Bytes) = "moonbit_raylib_image_crop"

///|
#borrow(image, color)
pub extern "c" fn image_alpha_clear(image : Image, color : Bytes, threshold : Float) = "moonbit_raylib_image_alpha_clear"

///|
#borrow(image, alpha_mask)
pub extern "c" fn image_alpha_mask(image : Image, alpha_mask : Image) = "moonbit_raylib_image_alpha_mask"

///|
#borrow(image, fill)
pub extern "c" fn image_resize_canvas(
  image : Image,
  new_width : Int,
  new_height : Int,
  offset_x : Int,
  offset_y : Int,
  fill : Bytes,
) = "moonbit_raylib_image_resize_canvas"

///|
#borrow(image, color)
pub extern "c" fn image_color_tint(image : Image, color : Bytes) = "moonbit_raylib_image_color_tint"

///|
#borrow(image)
pub extern "c" fn image_color_contrast(image : Image, contrast : Float) = "moonbit_raylib_image_color_contrast"

///|
#borrow(image)
pub extern "c" fn image_color_brightness(image : Image, brightness : Int) = "moonbit_raylib_image_color_brightness"

///|
#borrow(image, color, replace)
pub extern "c" fn image_color_replace(image : Image, color : Bytes, replace : Bytes) = "moonbit_raylib_image_color_replace"

///|
#borrow(image, kernel)
pub extern "c" fn image_kernel_convolution(image : Image, kernel : Bytes, kernel_size : Int) = "moonbit_raylib_image_kernel_convolution"

// ============================================================================
// Image creation: ImageText, ImageTextEx
// ============================================================================

///|
#borrow(text, color)
pub extern "c" fn image_text(text : Bytes, font_size : Int, color : Bytes) -> Image = "moonbit_raylib_image_text"

///|
#borrow(font, text, tint)
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
#borrow(image)
pub extern "c" fn get_image_alpha_border(image : Image, threshold : Float) -> Bytes = "moonbit_raylib_get_image_alpha_border"

///|
#borrow(image)
pub extern "c" fn get_image_color(image : Image, x : Int, y : Int) -> Bytes = "moonbit_raylib_get_image_color"

// ============================================================================
// Copy-and-free: LoadImageColors, LoadImagePalette
// ============================================================================

///|
#borrow(image)
pub extern "c" fn load_image_colors(image : Image) -> Bytes = "moonbit_raylib_load_image_colors"

///|
#borrow(image)
pub extern "c" fn load_image_palette(image : Image, max_palette_size : Int) -> Bytes = "moonbit_raylib_load_image_palette"

// ============================================================================
// Export: ExportImageToMemory, ExportImageAsCode
// ============================================================================

///|
#borrow(image, file_type)
pub extern "c" fn export_image_to_memory(image : Image, file_type : Bytes) -> Bytes = "moonbit_raylib_export_image_to_memory"

///|
#borrow(image, file_name)
pub extern "c" fn export_image_as_code(image : Image, file_name : Bytes) -> Bool = "moonbit_raylib_export_image_as_code"
