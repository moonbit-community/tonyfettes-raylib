// Image processing methods and wrappers

///|
/// Convert image data to desired format.
#as_free_fn(image_format)
pub fn Image::set_format(self : Image, new_format : Int) -> Unit {
  @ffi.image_format(self.0, new_format)
}

///|
/// Crop image depending on alpha value.
#as_free_fn(image_alpha_crop)
pub fn Image::alpha_crop(self : Image, threshold : Float) -> Unit {
  @ffi.image_alpha_crop(self.0, threshold)
}

///|
/// Premultiply alpha channel.
#as_free_fn(image_alpha_premultiply)
pub fn Image::alpha_premultiply(self : Image) -> Unit {
  @ffi.image_alpha_premultiply(self.0)
}

///|
/// Apply Gaussian blur using a box blur approximation.
#as_free_fn(image_blur_gaussian)
pub fn Image::blur_gaussian(self : Image, blur_size : Int) -> Unit {
  @ffi.image_blur_gaussian(self.0, blur_size)
}

///|
/// Resize image (Bicubic scaling algorithm).
#as_free_fn(image_resize)
pub fn Image::resize(self : Image, new_width : Int, new_height : Int) -> Unit {
  @ffi.image_resize(self.0, new_width, new_height)
}

///|
/// Resize image (Nearest-Neighbor scaling algorithm).
#as_free_fn(image_resize_nn)
pub fn Image::resize_nn(
  self : Image,
  new_width : Int,
  new_height : Int,
) -> Unit {
  @ffi.image_resize_nn(self.0, new_width, new_height)
}

///|
/// Compute all mipmap levels for a provided image.
#as_free_fn(image_mipmaps)
pub fn Image::gen_mipmaps(self : Image) -> Unit {
  @ffi.image_mipmaps(self.0)
}

///|
/// Dither image data to 16bpp or lower (Floyd-Steinberg dithering).
#as_free_fn(image_dither)
pub fn Image::dither(
  self : Image,
  r_bpp : Int,
  g_bpp : Int,
  b_bpp : Int,
  a_bpp : Int,
) -> Unit {
  @ffi.image_dither(self.0, r_bpp, g_bpp, b_bpp, a_bpp)
}

///|
/// Flip image vertically.
#as_free_fn(image_flip_vertical)
pub fn Image::flip_vertical(self : Image) -> Unit {
  @ffi.image_flip_vertical(self.0)
}

///|
/// Flip image horizontally.
#as_free_fn(image_flip_horizontal)
pub fn Image::flip_horizontal(self : Image) -> Unit {
  @ffi.image_flip_horizontal(self.0)
}

///|
/// Rotate image by input angle in degrees (-359 to 359).
#as_free_fn(image_rotate)
pub fn Image::rotate(self : Image, degrees : Int) -> Unit {
  @ffi.image_rotate(self.0, degrees)
}

///|
/// Rotate image clockwise 90deg.
#as_free_fn(image_rotate_cw)
pub fn Image::rotate_cw(self : Image) -> Unit {
  @ffi.image_rotate_cw(self.0)
}

///|
/// Rotate image counter-clockwise 90deg.
#as_free_fn(image_rotate_ccw)
pub fn Image::rotate_ccw(self : Image) -> Unit {
  @ffi.image_rotate_ccw(self.0)
}

///|
/// Modify image color: invert.
#as_free_fn(image_color_invert)
pub fn Image::color_invert(self : Image) -> Unit {
  @ffi.image_color_invert(self.0)
}

///|
/// Modify image color: grayscale.
#as_free_fn(image_color_grayscale)
pub fn Image::color_grayscale(self : Image) -> Unit {
  @ffi.image_color_grayscale(self.0)
}

///|
/// Apply alpha mask to image.
#as_free_fn(image_alpha_mask)
pub fn Image::alpha_mask(self : Image, alpha_mask : Image) -> Unit {
  @ffi.image_alpha_mask(self.0, alpha_mask.0)
}

///|
/// Modify image color: contrast (-100 to 100).
#as_free_fn(image_color_contrast)
pub fn Image::adjust_contrast(self : Image, contrast : Float) -> Unit {
  @ffi.image_color_contrast(self.0, contrast)
}

///|
/// Modify image color: brightness (-255 to 255).
#as_free_fn(image_color_brightness)
pub fn Image::adjust_brightness(self : Image, brightness : Int) -> Unit {
  @ffi.image_color_brightness(self.0, brightness)
}

///|
/// Apply custom square convolution kernel to image.
#as_free_fn(image_kernel_convolution)
pub fn Image::kernel_convolution(
  self : Image,
  kernel : Bytes,
  kernel_size : Int,
) -> Unit {
  @ffi.image_kernel_convolution(self.0, kernel, kernel_size)
}

// ============================================================================
// Image loading (wrappers)
// ============================================================================

///|
/// Load image from RAW file data.
#as_free_fn(load_image_raw)
pub fn Image::load_raw(
  file_name : String,
  width : Int,
  height : Int,
  format : Int,
  header_size : Int,
) -> Image {
  @ffi.load_image_raw(
    @utf8.encode(file_name),
    width,
    height,
    format,
    header_size,
  )
}

///|
/// Load image sequence from file (frames appended to image.data). Returns the image and frame count.
pub fn Image::load_anim(file_name : String) -> (Image, Int) {
  let frames = Ref::new(0)
  let image = @ffi.load_image_anim(@utf8.encode(file_name), frames)
  (image, frames.val)
}

///|
/// Load image sequence from memory buffer. Returns the image and frame count.
pub fn Image::load_anim_from_memory(
  file_type : String,
  file_data : Bytes,
  data_size : Int,
) -> (Image, Int) {
  let frames = Ref::new(0)
  let image = @ffi.load_image_anim_from_memory(
    @utf8.encode(file_type),
    file_data,
    data_size,
    frames,
  )
  (image, frames.val)
}

///|
/// Load image sequence from file (frames appended to image.data).
#deprecated("Use Image::load_anim instead (returns (Image, Int) with frame count)")
pub fn load_image_anim(file_name : String) -> Image {
  let frames = Ref::new(0)
  @ffi.load_image_anim(@utf8.encode(file_name), frames)
}

///|
/// Load image sequence from memory buffer.
#deprecated("Use Image::load_anim_from_memory instead (returns (Image, Int) with frame count)")
pub fn load_image_anim_from_memory(
  file_type : String,
  file_data : Bytes,
  data_size : Int,
) -> Image {
  let frames = Ref::new(0)
  @ffi.load_image_anim_from_memory(
    @utf8.encode(file_type),
    file_data,
    data_size,
    frames,
  )
}

// ============================================================================
// In-place mutations: value type param wrappers
// ============================================================================

///|
/// Convert image to POT (power-of-two).
#as_free_fn(image_to_pot)
pub fn Image::to_pot(self : Image, fill : Color) -> Unit {
  @ffi.image_to_pot(self.0, fill.to_bytes())
}

///|
/// Crop an image to a defined rectangle.
#as_free_fn(image_crop)
pub fn Image::crop(self : Image, crop : Rectangle) -> Unit {
  @ffi.image_crop(self.0, crop.to_bytes())
}

///|
/// Clear alpha channel to desired color.
#as_free_fn(image_alpha_clear)
pub fn Image::alpha_clear(
  self : Image,
  color : Color,
  threshold : Float,
) -> Unit {
  @ffi.image_alpha_clear(self.0, color.to_bytes(), threshold)
}

///|
/// Resize canvas and fill with color.
#as_free_fn(image_resize_canvas)
pub fn Image::resize_canvas(
  self : Image,
  new_width : Int,
  new_height : Int,
  offset_x : Int,
  offset_y : Int,
  fill : Color,
) -> Unit {
  @ffi.image_resize_canvas(
    self.0,
    new_width,
    new_height,
    offset_x,
    offset_y,
    fill.to_bytes(),
  )
}

///|
/// Modify image color: tint.
#as_free_fn(image_color_tint)
pub fn Image::color_tint(self : Image, color : Color) -> Unit {
  @ffi.image_color_tint(self.0, color.to_bytes())
}

///|
/// Modify image color: replace color.
#as_free_fn(image_color_replace)
pub fn Image::color_replace(
  self : Image,
  color : Color,
  replace : Color,
) -> Unit {
  @ffi.image_color_replace(self.0, color.to_bytes(), replace.to_bytes())
}

// ============================================================================
// Image creation (wrappers)
// ============================================================================

///|
/// Create an image from text (default font).
#as_free_fn(image_text)
pub fn Image::text(text : String, font_size : Int, color : Color) -> Image {
  @ffi.image_text(@utf8.encode(text), font_size, color.to_bytes())
}

///|
/// Create an image from text (custom sprite font).
#as_free_fn(image_text_ex)
pub fn Image::text_ex(
  font : Font,
  text : String,
  font_size : Float,
  spacing : Float,
  tint : Color,
) -> Image {
  @ffi.image_text_ex(
    font.0,
    @utf8.encode(text),
    font_size,
    spacing,
    tint.to_bytes(),
  )
}

// ============================================================================
// Queries (wrappers)
// ============================================================================

///|
/// Get image alpha border rectangle.
#as_free_fn(get_image_alpha_border)
pub fn Image::alpha_border(self : Image, threshold : Float) -> Rectangle {
  Rectangle::from_bytes(@ffi.get_image_alpha_border(self.0, threshold))
}

///|
/// Get image pixel color at (x, y) position.
#as_free_fn(get_image_color)
pub fn Image::get_color(self : Image, x : Int, y : Int) -> Color {
  Color::from_bytes(@ffi.get_image_color(self.0, x, y))
}

// ============================================================================
// Export (wrappers)
// ============================================================================

///|
/// Export image to memory buffer.
#as_free_fn(export_image_to_memory)
pub fn Image::export_to_memory(self : Image, file_type : String) -> Bytes {
  @ffi.export_image_to_memory(self.0, @utf8.encode(file_type))
}

///|
/// Export image as code file defining an array of bytes, returns true on success.
#as_free_fn(export_image_as_code)
pub fn Image::export_as_code(self : Image, file_name : String) -> Bool {
  @ffi.export_image_as_code(self.0, @utf8.encode(file_name))
}
