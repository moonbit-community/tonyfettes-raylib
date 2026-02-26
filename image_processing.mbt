// Re-export passthrough functions from internal FFI layer

///|
pub using @ffi {
  image_format,
  image_alpha_crop,
  image_alpha_premultiply,
  image_blur_gaussian,
  image_resize,
  image_resize_nn,
  image_mipmaps,
  image_dither,
  image_flip_vertical,
  image_flip_horizontal,
  image_rotate,
  image_rotate_cw,
  image_rotate_ccw,
  image_color_invert,
  image_color_grayscale,
  image_alpha_mask,
  image_color_contrast,
  image_color_brightness,
  image_kernel_convolution,
  image_frame_count,
  image_width,
  image_height,
  load_image_colors,
  load_image_palette,
}

// ============================================================================
// Image loading (wrappers)
// ============================================================================

///|
pub fn load_image_raw(
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
pub fn load_image_anim(file_name : String) -> Image {
  @ffi.load_image_anim(@utf8.encode(file_name))
}

///|
pub fn load_image_anim_from_memory(
  file_type : String,
  file_data : Bytes,
  data_size : Int,
) -> Image {
  @ffi.load_image_anim_from_memory(
    @utf8.encode(file_type),
    file_data,
    data_size,
  )
}

// ============================================================================
// In-place mutations: value type param wrappers
// ============================================================================

///|
pub fn image_to_pot(image : Image, fill : Color) -> Unit {
  @ffi.image_to_pot(image, fill.to_bytes())
}

///|
pub fn image_crop(image : Image, crop : Rectangle) -> Unit {
  @ffi.image_crop(image, crop.to_bytes())
}

///|
pub fn image_alpha_clear(
  image : Image,
  color : Color,
  threshold : Float,
) -> Unit {
  @ffi.image_alpha_clear(image, color.to_bytes(), threshold)
}

///|
pub fn image_resize_canvas(
  image : Image,
  new_width : Int,
  new_height : Int,
  offset_x : Int,
  offset_y : Int,
  fill : Color,
) -> Unit {
  @ffi.image_resize_canvas(
    image,
    new_width,
    new_height,
    offset_x,
    offset_y,
    fill.to_bytes(),
  )
}

///|
pub fn image_color_tint(image : Image, color : Color) -> Unit {
  @ffi.image_color_tint(image, color.to_bytes())
}

///|
pub fn image_color_replace(
  image : Image,
  color : Color,
  replace : Color,
) -> Unit {
  @ffi.image_color_replace(image, color.to_bytes(), replace.to_bytes())
}

// ============================================================================
// Image creation (wrappers)
// ============================================================================

///|
pub fn image_text(text : String, font_size : Int, color : Color) -> Image {
  @ffi.image_text(@utf8.encode(text), font_size, color.to_bytes())
}

///|
pub fn image_text_ex(
  font : Font,
  text : String,
  font_size : Float,
  spacing : Float,
  tint : Color,
) -> Image {
  @ffi.image_text_ex(
    font,
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
pub fn get_image_alpha_border(image : Image, threshold : Float) -> Rectangle {
  Rectangle::from_bytes(@ffi.get_image_alpha_border(image, threshold))
}

///|
pub fn get_image_color(image : Image, x : Int, y : Int) -> Color {
  Color::from_bytes(@ffi.get_image_color(image, x, y))
}

// ============================================================================
// Export (wrappers)
// ============================================================================

///|
pub fn export_image_to_memory(image : Image, file_type : String) -> Bytes {
  @ffi.export_image_to_memory(image, @utf8.encode(file_type))
}

///|
pub fn export_image_as_code(image : Image, file_name : String) -> Bool {
  @ffi.export_image_as_code(image, @utf8.encode(file_name))
}
