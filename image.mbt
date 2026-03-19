///|
struct Image(@ffi.Image)

///|
/// Unload image from CPU memory (RAM).
#as_free_fn(unload_image)
pub fn Image::unload(self : Image) -> Unit {
  @ffi.unload_image(self.0)
}

///|
/// Check if an image is valid (data and parameters).
#as_free_fn(is_image_valid)
pub fn Image::is_valid(self : Image) -> Bool {
  @ffi.is_image_valid(self.0)
}

///|
/// Create an image duplicate (useful for transformations).
#as_free_fn(image_copy)
pub fn Image::copy(self : Image) -> Image {
  @ffi.image_copy(self.0)
}

///|
/// Create an image from a selected channel of another image (GRAYSCALE).
#as_free_fn(image_from_channel)
pub fn Image::from_channel(self : Image, selected_channel : Int) -> Image {
  @ffi.image_from_channel(self.0, selected_channel)
}

///|
/// Get image width.
#as_free_fn(get_image_width)
#as_free_fn(image_width, deprecated="Use @raylib.Image::width() instead")
pub fn Image::width(self : Image) -> Int {
  @ffi.image_width(self.0)
}

///|
/// Get image height.
#as_free_fn(get_image_height)
#as_free_fn(image_height, deprecated="Use @raylib.Image::height() instead")
pub fn Image::height(self : Image) -> Int {
  @ffi.image_height(self.0)
}

///|
/// Get image mipmap levels.
#as_free_fn(get_image_mipmaps)
pub fn Image::mipmaps(self : Image) -> Int {
  @ffi.image_get_mipmaps(self.0)
}

///|
/// Get image data format.
#as_free_fn(get_image_format)
pub fn Image::format(self : Image) -> Int {
  @ffi.image_get_format(self.0)
}

///|
/// Load image from GPU texture data.
#as_free_fn(load_image_from_texture)
pub fn Image::load_from_texture(texture : Texture) -> Image {
  @ffi.load_image_from_texture(texture.0)
}

///|
/// Load image from screen buffer (screenshot).
#as_free_fn(load_image_from_screen)
pub fn Image::load_from_screen() -> Image {
  @ffi.load_image_from_screen()
}

///|
/// Load color data from image as a Color array (RGBA - 32bit).
#as_free_fn(load_image_colors)
pub fn Image::load_colors(self : Image) -> Bytes {
  @ffi.load_image_colors(self.0)
}

///|
/// Load colors palette from image as a Color array (RGBA - 32bit).
#as_free_fn(load_image_palette)
pub fn Image::load_palette(self : Image, max_palette_size : Int) -> Bytes {
  @ffi.load_image_palette(self.0, max_palette_size)
}

///|
/// Generate image: white noise.
#as_free_fn(gen_image_white_noise)
pub fn Image::gen_white_noise(
  width : Int,
  height : Int,
  factor : Float,
) -> Image {
  @ffi.gen_image_white_noise(width, height, factor)
}

///|
/// Generate image: perlin noise.
#as_free_fn(gen_image_perlin_noise)
pub fn Image::gen_perlin_noise(
  width : Int,
  height : Int,
  offset_x : Int,
  offset_y : Int,
  scale : Float,
) -> Image {
  @ffi.gen_image_perlin_noise(width, height, offset_x, offset_y, scale)
}

///|
/// Generate image: cellular algorithm, bigger tileSize means bigger cells.
#as_free_fn(gen_image_cellular)
pub fn Image::gen_cellular(width : Int, height : Int, tile_size : Int) -> Image {
  @ffi.gen_image_cellular(width, height, tile_size)
}

///|
/// Load texture from image data.
#as_free_fn(load_texture_from_image)
pub fn Image::to_texture(self : Image) -> Texture {
  @ffi.load_texture_from_image(self.0)
}

///|
/// Load cubemap from image, multiple image cubemap layouts supported.
#as_free_fn(load_texture_cubemap)
pub fn Image::to_texture_cubemap(self : Image, layout : Int) -> Texture {
  @ffi.load_texture_cubemap(self.0, layout)
}

///|
/// Load image from file into CPU memory (RAM).
#as_free_fn(load_image)
pub fn Image::load(file_name : String) -> Image {
  @ffi.load_image(@utf8.encode(file_name))
}

///|
/// Generate image: plain color.
#as_free_fn(gen_image_color)
pub fn Image::gen_color(width : Int, height : Int, color : Color) -> Image {
  @ffi.gen_image_color(width, height, color.to_bytes())
}

///|
/// Generate image: checked.
#as_free_fn(gen_image_checked)
pub fn Image::gen_checked(
  width : Int,
  height : Int,
  checks_x : Int,
  checks_y : Int,
  col1 : Color,
  col2 : Color,
) -> Image {
  @ffi.gen_image_checked(
    width,
    height,
    checks_x,
    checks_y,
    col1.to_bytes(),
    col2.to_bytes(),
  )
}

///|
/// Generate image: linear gradient, direction in degrees [0..360], 0=Vertical gradient.
#as_free_fn(gen_image_gradient_linear)
pub fn Image::gen_gradient_linear(
  width : Int,
  height : Int,
  direction : Int,
  start : Color,
  end_ : Color,
) -> Image {
  @ffi.gen_image_gradient_linear(
    width,
    height,
    direction,
    start.to_bytes(),
    end_.to_bytes(),
  )
}

///|
/// Generate image: radial gradient.
#as_free_fn(gen_image_gradient_radial)
pub fn Image::gen_gradient_radial(
  width : Int,
  height : Int,
  density : Float,
  inner : Color,
  outer : Color,
) -> Image {
  @ffi.gen_image_gradient_radial(
    width,
    height,
    density,
    inner.to_bytes(),
    outer.to_bytes(),
  )
}

///|
/// Generate image: square gradient.
#as_free_fn(gen_image_gradient_square)
pub fn Image::gen_gradient_square(
  width : Int,
  height : Int,
  density : Float,
  inner : Color,
  outer : Color,
) -> Image {
  @ffi.gen_image_gradient_square(
    width,
    height,
    density,
    inner.to_bytes(),
    outer.to_bytes(),
  )
}

///|
/// Generate image: grayscale image from text data.
#as_free_fn(gen_image_text)
pub fn Image::gen_text(width : Int, height : Int, text : String) -> Image {
  @ffi.gen_image_text(width, height, @utf8.encode(text))
}

///|
/// Load image from memory buffer, fileType refers to extension: i.e. '.png'.
#as_free_fn(load_image_from_memory)
pub fn Image::load_from_memory(
  file_type : String,
  file_data : Bytes,
  data_size : Int,
) -> Image {
  @ffi.load_image_from_memory(@utf8.encode(file_type), file_data, data_size)
}

///|
/// Export image data to file, returns true on success.
#as_free_fn(export_image)
pub fn Image::export_(self : Image, file_name : String) -> Bool {
  @ffi.export_image(self.0, @utf8.encode(file_name))
}

///|
/// Create an image from another image piece.
#as_free_fn(image_from_image)
pub fn Image::from_image(self : Image, rec : Rectangle) -> Image {
  @ffi.image_from_image(self.0, rec.to_bytes())
}
