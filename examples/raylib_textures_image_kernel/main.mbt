///|
fn make_kernel_bytes(kernel : FixedArray[Float]) -> Bytes {
  let size = kernel.length()
  let result : Array[Byte] = []
  for i in 0..<size {
    let bits = kernel[i].reinterpret_as_int()
    result.push((bits & 0xFF).to_byte())
    result.push(((bits >> 8) & 0xFF).to_byte())
    result.push(((bits >> 16) & 0xFF).to_byte())
    result.push(((bits >> 24) & 0xFF).to_byte())
  }
  Bytes::from_array(result)
}

///|
fn normalize_kernel(kernel : FixedArray[Float]) -> Unit {
  let mut sum : Float = 0.0
  for i in 0..<kernel.length() {
    sum += kernel[i]
  }
  if sum != 0.0 {
    for i in 0..<kernel.length() {
      kernel[i] /= sum
    }
  }
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_textures_image_kernel")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - image convolution",
  )

  let image = @raylib.load_image("resources/cat.png")
  // cat.png: 384x512

  let gaussian_kernel : FixedArray[Float] = [
    1.0, 2.0, 1.0, 2.0, 4.0, 2.0, 1.0, 2.0, 1.0,
  ]

  let sobel_kernel : FixedArray[Float] = [
    1.0, 0.0, -1.0, 2.0, 0.0, -2.0, 1.0, 0.0, -1.0,
  ]

  let sharpen_kernel : FixedArray[Float] = [
    0.0, -1.0, 0.0, -1.0, 5.0, -1.0, 0.0, -1.0, 0.0,
  ]

  normalize_kernel(gaussian_kernel)
  normalize_kernel(sharpen_kernel)
  normalize_kernel(sobel_kernel)

  let gaussian_bytes = make_kernel_bytes(gaussian_kernel)
  let sobel_bytes = make_kernel_bytes(sobel_kernel)
  let sharpen_bytes = make_kernel_bytes(sharpen_kernel)

  let cat_sharpened = @raylib.image_copy(image)
  @raylib.image_kernel_convolution(cat_sharpened, sharpen_bytes, 9)

  let cat_sobel = @raylib.image_copy(image)
  @raylib.image_kernel_convolution(cat_sobel, sobel_bytes, 9)

  let cat_gaussian = @raylib.image_copy(image)
  for _ in 0..<6 {
    @raylib.image_kernel_convolution(cat_gaussian, gaussian_bytes, 9)
  }

  @raylib.image_crop(image, @raylib.Rectangle::new(0.0, 0.0, 200.0, 450.0))
  @raylib.image_crop(
    cat_gaussian,
    @raylib.Rectangle::new(0.0, 0.0, 200.0, 450.0),
  )
  @raylib.image_crop(cat_sobel, @raylib.Rectangle::new(0.0, 0.0, 200.0, 450.0))
  @raylib.image_crop(
    cat_sharpened,
    @raylib.Rectangle::new(0.0, 0.0, 200.0, 450.0),
  )

  // Images converted to texture, GPU memory (VRAM)
  let texture = @raylib.load_texture_from_image(image)
  let cat_sharpened_texture = @raylib.load_texture_from_image(cat_sharpened)
  let cat_sobel_texture = @raylib.load_texture_from_image(cat_sobel)
  let cat_gaussian_texture = @raylib.load_texture_from_image(cat_gaussian)

  // Once images have been converted to texture and uploaded to VRAM,
  // they can be unloaded from RAM
  @raylib.unload_image(image)
  @raylib.unload_image(cat_gaussian)
  @raylib.unload_image(cat_sobel)
  @raylib.unload_image(cat_sharpened)

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_texture(cat_sharpened_texture, 0, 0, @raylib.white)
    @raylib.draw_texture(cat_sobel_texture, 200, 0, @raylib.white)
    @raylib.draw_texture(cat_gaussian_texture, 400, 0, @raylib.white)
    @raylib.draw_texture(texture, 600, 0, @raylib.white)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.unload_texture(cat_gaussian_texture)
  @raylib.unload_texture(cat_sobel_texture)
  @raylib.unload_texture(cat_sharpened_texture)
  @raylib.close_window()
}
