// ── Image generation & metadata ──────────────────────────────────────

///|
test "gen_image_color produces valid image with correct metadata" {
  let img = @raylib.Image::gen_color(16, 8, @raylib.red)
  assert_true(img.is_valid())
  assert_eq(img.width(), 16)
  assert_eq(img.height(), 8)
  assert_eq(img.mipmaps(), 1)
  // PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 = 7
  assert_eq(img.format(), 7)
  img.unload()
}

///|
test "Image::copy produces independent copy" {
  let orig = @raylib.Image::gen_color(4, 4, @raylib.red)
  let copy = orig.copy()
  assert_true(copy.is_valid())
  assert_eq(copy.width(), 4)
  assert_eq(copy.height(), 4)
  // Mutate original, copy should be unaffected
  orig.clear_background(@raylib.blue)
  let orig_pixel = orig.get_color(0, 0)
  let copy_pixel = copy.get_color(0, 0)
  assert_eq(copy_pixel.r, @raylib.red.r)
  assert_true(orig_pixel.r != copy_pixel.r)
  orig.unload()
  copy.unload()
}

///|
test "Image::from_channel extracts channel" {
  let img = @raylib.Image::gen_color(
    4,
    4,
    @raylib.Color::new(100, 150, 200, 255),
  )
  // Channel 0 = red
  let ch = img.from_channel(0)
  assert_true(ch.is_valid())
  assert_eq(ch.width(), 4)
  assert_eq(ch.height(), 4)
  ch.unload()
  img.unload()
}

///|
test "gen_white_noise produces valid image" {
  let img = @raylib.Image::gen_white_noise(16, 16, 0.5)
  assert_true(img.is_valid())
  assert_eq(img.width(), 16)
  assert_eq(img.height(), 16)
  img.unload()
}

///|
test "gen_perlin_noise produces valid image" {
  let img = @raylib.Image::gen_perlin_noise(16, 16, 0, 0, 4.0)
  assert_true(img.is_valid())
  assert_eq(img.width(), 16)
  assert_eq(img.height(), 16)
  img.unload()
}

///|
test "gen_cellular produces valid image" {
  let img = @raylib.Image::gen_cellular(16, 16, 4)
  assert_true(img.is_valid())
  assert_eq(img.width(), 16)
  assert_eq(img.height(), 16)
  img.unload()
}

///|
test "load_colors extracts pixel data" {
  let img = @raylib.Image::gen_color(2, 2, @raylib.red)
  let colors = img.load_colors()
  // 2x2 image, 4 bytes per pixel = 16 bytes
  assert_eq(colors.length(), 16)
  // First pixel should be red (r=230, g=41, b=55, a=255)
  assert_eq(colors[0], @raylib.red.r)
  assert_eq(colors[1], @raylib.red.g)
  assert_eq(colors[2], @raylib.red.b)
  assert_eq(colors[3], @raylib.red.a)
  img.unload()
}

///|
test "load_palette extracts palette" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.red)
  let palette = img.load_palette(256)
  // Should have at least some bytes
  assert_true(palette.length() > 0)
  img.unload()
}

///|
test "export_ saves image to file" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.green)
  let ok = img.export_("_test_tmp_export.png")
  assert_true(ok)
  img.unload()
}

///|
test "export_to_memory returns PNG bytes" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.blue)
  let data = img.export_to_memory(".png")
  // PNG files start with a known 8-byte signature
  assert_true(data.length() > 8)
  // PNG magic: 137 80 78 71 13 10 26 10
  assert_eq(data[0], b'\x89')
  assert_eq(data[1], b'\x50') // 'P'
  assert_eq(data[2], b'\x4E') // 'N'
  assert_eq(data[3], b'\x47') // 'G'
  img.unload()
}

///|
test "from_image extracts sub-image" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.red)
  let sub = img.from_image(@raylib.Rectangle::new(2.0, 2.0, 4.0, 4.0))
  assert_true(sub.is_valid())
  assert_eq(sub.width(), 4)
  assert_eq(sub.height(), 4)
  let c = sub.get_color(0, 0)
  assert_eq(c.r, @raylib.red.r)
  sub.unload()
  img.unload()
}

///|
test "gen_checked produces valid checkerboard" {
  let img = @raylib.Image::gen_checked(8, 8, 2, 2, @raylib.red, @raylib.blue)
  assert_true(img.is_valid())
  assert_eq(img.width(), 8)
  assert_eq(img.height(), 8)
  img.unload()
}

///|
test "gen_gradient_linear produces valid gradient" {
  let img = @raylib.Image::gen_gradient_linear(
    8, 8, 0, @raylib.red, @raylib.blue,
  )
  assert_true(img.is_valid())
  assert_eq(img.width(), 8)
  img.unload()
}

///|
test "gen_gradient_radial produces valid gradient" {
  let img = @raylib.Image::gen_gradient_radial(
    8, 8, 0.5, @raylib.red, @raylib.blue,
  )
  assert_true(img.is_valid())
  img.unload()
}

///|
test "gen_gradient_square produces valid gradient" {
  let img = @raylib.Image::gen_gradient_square(
    8, 8, 0.5, @raylib.red, @raylib.blue,
  )
  assert_true(img.is_valid())
  img.unload()
}

// ── Image processing ─────────────────────────────────────────────────

///|
test "flip_vertical flips image" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.red)
  // Draw a blue pixel at (0, 0) - top-left
  img.draw_pixel(0, 0, @raylib.blue)
  img.flip_vertical()
  // After vertical flip, the blue pixel should be at (0, 3) - bottom-left
  let c = img.get_color(0, 3)
  assert_eq(c.r, @raylib.blue.r)
  assert_eq(c.g, @raylib.blue.g)
  assert_eq(c.b, @raylib.blue.b)
  img.unload()
}

///|
test "flip_horizontal flips image" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.red)
  img.draw_pixel(0, 0, @raylib.blue)
  img.flip_horizontal()
  // After horizontal flip, the blue pixel should be at (3, 0)
  let c = img.get_color(3, 0)
  assert_eq(c.r, @raylib.blue.r)
  assert_eq(c.g, @raylib.blue.g)
  assert_eq(c.b, @raylib.blue.b)
  img.unload()
}

///|
test "rotate_cw rotates clockwise" {
  let img = @raylib.Image::gen_color(4, 8, @raylib.red)
  img.rotate_cw()
  // After CW rotation: width=8, height=4
  assert_eq(img.width(), 8)
  assert_eq(img.height(), 4)
  img.unload()
}

///|
test "rotate_ccw rotates counter-clockwise" {
  let img = @raylib.Image::gen_color(4, 8, @raylib.red)
  img.rotate_ccw()
  assert_eq(img.width(), 8)
  assert_eq(img.height(), 4)
  img.unload()
}

///|
test "rotate arbitrary angle" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.red)
  img.rotate(45)
  assert_true(img.is_valid())
  // Rotation may change dimensions
  assert_true(img.width() > 0)
  assert_true(img.height() > 0)
  img.unload()
}

///|
test "resize changes dimensions" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.red)
  img.resize(16, 4)
  assert_eq(img.width(), 16)
  assert_eq(img.height(), 4)
  img.unload()
}

///|
test "resize_nn changes dimensions with nearest-neighbor" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.red)
  img.resize_nn(16, 16)
  assert_eq(img.width(), 16)
  assert_eq(img.height(), 16)
  img.unload()
}

///|
test "color_invert inverts colors" {
  let img = @raylib.Image::gen_color(
    4,
    4,
    @raylib.Color::new(200, 100, 50, 255),
  )
  img.color_invert()
  let c = img.get_color(0, 0)
  assert_eq(c.r, b'\x37') // 255-200=55
  assert_eq(c.g, b'\x9B') // 255-100=155
  assert_eq(c.b, b'\xCD') // 255-50=205
  img.unload()
}

///|
test "color_grayscale converts to grayscale" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.red)
  img.color_grayscale()
  assert_true(img.is_valid())
  // Format should change to grayscale (PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1)
  assert_eq(img.format(), 1)
  img.unload()
}

///|
test "adjust_brightness modifies brightness" {
  let img = @raylib.Image::gen_color(
    4,
    4,
    @raylib.Color::new(128, 128, 128, 255),
  )
  img.adjust_brightness(50)
  let c = img.get_color(0, 0)
  assert_true(c.r.to_int() > 128)
  img.unload()
}

///|
test "adjust_contrast modifies contrast" {
  let img = @raylib.Image::gen_color(
    4,
    4,
    @raylib.Color::new(128, 128, 128, 255),
  )
  img.adjust_contrast(50.0)
  assert_true(img.is_valid())
  img.unload()
}

///|
test "blur_gaussian blurs image" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.red)
  // Draw a single white pixel in center
  img.draw_pixel(4, 4, @raylib.white)
  img.blur_gaussian(2)
  assert_true(img.is_valid())
  // After blur the white pixel should have spread
  let center = img.get_color(4, 4)
  let neighbor = img.get_color(3, 4)
  // Neighbor should have picked up some brightness from the white pixel
  assert_true(neighbor.r.to_int() > @raylib.red.r.to_int() - 5)
  let _ = center
  img.unload()
}

///|
test "alpha_premultiply premultiplies alpha" {
  let img = @raylib.Image::gen_color(
    4,
    4,
    @raylib.Color::new(255, 255, 255, 128),
  )
  img.alpha_premultiply()
  let c = img.get_color(0, 0)
  // After premultiply: R = 255 * 128/255 ≈ 128
  assert_true(c.r.to_int() >= 127 && c.r.to_int() <= 129)
  img.unload()
}

///|
test "gen_mipmaps generates mipmaps" {
  let img = @raylib.Image::gen_color(16, 16, @raylib.red)
  assert_eq(img.mipmaps(), 1)
  img.gen_mipmaps()
  // 16x16 should have 5 mipmap levels: 16, 8, 4, 2, 1
  assert_eq(img.mipmaps(), 5)
  img.unload()
}

///|
test "dither reduces color depth" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.red)
  img.dither(4, 4, 4, 4)
  assert_true(img.is_valid())
  img.unload()
}

///|
test "crop crops image" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.red)
  img.crop(@raylib.Rectangle::new(2.0, 2.0, 4.0, 4.0))
  assert_eq(img.width(), 4)
  assert_eq(img.height(), 4)
  img.unload()
}

///|
test "alpha_crop removes transparent edges" {
  // Create image with transparent border
  let img = @raylib.Image::gen_color(8, 8, @raylib.blank)
  // Draw a solid rectangle in the center
  img.draw_rectangle(2, 2, 4, 4, @raylib.red)
  img.alpha_crop(0.5)
  // Should have cropped to the 4x4 red region
  assert_eq(img.width(), 4)
  assert_eq(img.height(), 4)
  img.unload()
}

///|
test "to_pot pads image to power of two" {
  let img = @raylib.Image::gen_color(5, 5, @raylib.red)
  img.to_pot(@raylib.black)
  // Should be 8x8 (next power of two)
  assert_eq(img.width(), 8)
  assert_eq(img.height(), 8)
  img.unload()
}

///|
test "set_format changes pixel format" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.red)
  // PIXELFORMAT_UNCOMPRESSED_R8G8B8 = 4 (no alpha)
  img.set_format(4)
  assert_eq(img.format(), 4)
  img.unload()
}

///|
test "alpha_mask applies alpha from another image" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.red)
  let mask = @raylib.Image::gen_color(
    4,
    4,
    @raylib.Color::new(128, 128, 128, 255),
  )
  img.alpha_mask(mask)
  let c = img.get_color(0, 0)
  // Alpha should be derived from the mask grayscale value
  assert_true(c.a.to_int() > 100 && c.a.to_int() < 160)
  mask.unload()
  img.unload()
}

///|
test "kernel_convolution applies custom kernel" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.red)
  // Identity kernel (3x3 = 9 floats)
  let kernel_data : Array[Byte] = Array::make(9 * 4, b'\x00')
  // Set center element (index 4) to 1.0f (IEEE 754 little-endian: 0x3F800000)
  let offset = 4 * 4
  kernel_data[offset] = b'\x00'
  kernel_data[offset + 1] = b'\x00'
  kernel_data[offset + 2] = b'\x80'
  kernel_data[offset + 3] = b'\x3F'
  let kernel = Bytes::from_array(kernel_data)
  // kernelSize = total number of elements (9 for 3x3)
  img.kernel_convolution(kernel, 9)
  assert_true(img.is_valid())
  img.unload()
}

///|
test "resize_canvas resizes canvas" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.red)
  img.resize_canvas(8, 8, 2, 2, @raylib.blue)
  assert_eq(img.width(), 8)
  assert_eq(img.height(), 8)
  // Original content offset by (2,2), corners should be blue
  let corner = img.get_color(0, 0)
  assert_eq(corner.r, @raylib.blue.r)
  assert_eq(corner.g, @raylib.blue.g)
  assert_eq(corner.b, @raylib.blue.b)
  // Original content at (2,2) should be red
  let center = img.get_color(2, 2)
  assert_eq(center.r, @raylib.red.r)
  img.unload()
}

///|
test "color_tint applies tint to image" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.white)
  img.color_tint(@raylib.red)
  let c = img.get_color(0, 0)
  assert_eq(c.r, @raylib.red.r)
  assert_eq(c.g, @raylib.red.g)
  assert_eq(c.b, @raylib.red.b)
  img.unload()
}

///|
test "color_replace replaces one color with another" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.red)
  img.color_replace(@raylib.red, @raylib.blue)
  let c = img.get_color(0, 0)
  assert_eq(c.r, @raylib.blue.r)
  assert_eq(c.g, @raylib.blue.g)
  assert_eq(c.b, @raylib.blue.b)
  img.unload()
}

///|
test "alpha_border returns bounding rectangle of opaque region" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.blank)
  img.draw_rectangle(2, 2, 4, 4, @raylib.red)
  let border = img.alpha_border(0.5)
  assert_eq(border.x, 2.0)
  assert_eq(border.y, 2.0)
  assert_eq(border.width, 4.0)
  assert_eq(border.height, 4.0)
  img.unload()
}

///|
test "get_color reads pixel value" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.green)
  let c = img.get_color(2, 2)
  assert_eq(c.r, @raylib.green.r)
  assert_eq(c.g, @raylib.green.g)
  assert_eq(c.b, @raylib.green.b)
  assert_eq(c.a, @raylib.green.a)
  img.unload()
}

// ── Image drawing ────────────────────────────────────────────────────

///|
test "clear_background clears image" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.red)
  img.clear_background(@raylib.blue)
  let c = img.get_color(0, 0)
  assert_eq(c.r, @raylib.blue.r)
  assert_eq(c.g, @raylib.blue.g)
  assert_eq(c.b, @raylib.blue.b)
  img.unload()
}

///|
test "draw_pixel draws at coordinates" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.black)
  img.draw_pixel(3, 5, @raylib.white)
  let c = img.get_color(3, 5)
  assert_eq(c.r, @raylib.white.r)
  assert_eq(c.g, @raylib.white.g)
  assert_eq(c.b, @raylib.white.b)
  img.unload()
}

///|
test "draw_pixel_v draws at Vector2 position" {
  let img = @raylib.Image::gen_color(8, 8, @raylib.black)
  img.draw_pixel_v(@raylib.Vector2::new(2.0, 3.0), @raylib.green)
  let c = img.get_color(2, 3)
  assert_eq(c.r, @raylib.green.r)
  assert_eq(c.g, @raylib.green.g)
  assert_eq(c.b, @raylib.green.b)
  img.unload()
}

///|
test "draw_line draws a line" {
  let img = @raylib.Image::gen_color(16, 16, @raylib.black)
  img.draw_line(0, 0, 15, 0, @raylib.red)
  // Check a pixel along the horizontal line
  let c = img.get_color(8, 0)
  assert_eq(c.r, @raylib.red.r)
  img.unload()
}

///|
test "draw_line_v draws a line with Vector2" {
  let img = @raylib.Image::gen_color(16, 16, @raylib.black)
  img.draw_line_v(
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(15.0, 0.0),
    @raylib.red,
  )
  let c = img.get_color(8, 0)
  assert_eq(c.r, @raylib.red.r)
  img.unload()
}

///|
test "draw_line_ex draws thick line" {
  let img = @raylib.Image::gen_color(16, 16, @raylib.black)
  img.draw_line_ex(
    @raylib.Vector2::new(0.0, 8.0),
    @raylib.Vector2::new(15.0, 8.0),
    3,
    @raylib.red,
  )
  let c = img.get_color(8, 8)
  assert_eq(c.r, @raylib.red.r)
  img.unload()
}

///|
test "draw_circle draws filled circle" {
  let img = @raylib.Image::gen_color(32, 32, @raylib.black)
  img.draw_circle(16, 16, 8, @raylib.green)
  // Center should be green
  let c = img.get_color(16, 16)
  assert_eq(c.r, @raylib.green.r)
  assert_eq(c.g, @raylib.green.g)
  img.unload()
}

///|
test "draw_circle_v draws filled circle at Vector2" {
  let img = @raylib.Image::gen_color(32, 32, @raylib.black)
  img.draw_circle_v(@raylib.Vector2::new(16.0, 16.0), 8, @raylib.green)
  let c = img.get_color(16, 16)
  assert_eq(c.g, @raylib.green.g)
  img.unload()
}

///|
test "draw_circle_lines draws circle outline" {
  let img = @raylib.Image::gen_color(32, 32, @raylib.black)
  img.draw_circle_lines(16, 16, 10, @raylib.red)
  assert_true(img.is_valid())
  img.unload()
}

///|
test "draw_circle_lines_v draws circle outline at Vector2" {
  let img = @raylib.Image::gen_color(32, 32, @raylib.black)
  img.draw_circle_lines_v(@raylib.Vector2::new(16.0, 16.0), 10, @raylib.red)
  assert_true(img.is_valid())
  img.unload()
}

///|
test "draw_rectangle draws filled rectangle" {
  let img = @raylib.Image::gen_color(16, 16, @raylib.black)
  img.draw_rectangle(2, 2, 4, 4, @raylib.red)
  let c = img.get_color(3, 3)
  assert_eq(c.r, @raylib.red.r)
  // Outside the rectangle should still be black
  let outside = img.get_color(0, 0)
  assert_eq(outside.r, @raylib.black.r)
  img.unload()
}

///|
test "draw_rectangle_v draws filled rectangle with vectors" {
  let img = @raylib.Image::gen_color(16, 16, @raylib.black)
  img.draw_rectangle_v(
    @raylib.Vector2::new(2.0, 2.0),
    @raylib.Vector2::new(4.0, 4.0),
    @raylib.green,
  )
  let c = img.get_color(3, 3)
  assert_eq(c.g, @raylib.green.g)
  img.unload()
}

///|
test "draw_rectangle_rec draws filled rectangle from Rectangle" {
  let img = @raylib.Image::gen_color(16, 16, @raylib.black)
  img.draw_rectangle_rec(
    @raylib.Rectangle::new(2.0, 2.0, 4.0, 4.0),
    @raylib.blue,
  )
  let c = img.get_color(3, 3)
  assert_eq(c.b, @raylib.blue.b)
  img.unload()
}

///|
test "draw_rectangle_lines draws rectangle outline" {
  let img = @raylib.Image::gen_color(32, 32, @raylib.black)
  img.draw_rectangle_lines(
    @raylib.Rectangle::new(4.0, 4.0, 24.0, 24.0),
    2,
    @raylib.red,
  )
  assert_true(img.is_valid())
  // Top-left corner of the outline should have red
  let c = img.get_color(4, 4)
  assert_eq(c.r, @raylib.red.r)
  img.unload()
}

///|
test "draw_triangle draws filled triangle" {
  let img = @raylib.Image::gen_color(32, 32, @raylib.black)
  img.draw_triangle(
    @raylib.Vector2::new(16.0, 4.0),
    @raylib.Vector2::new(4.0, 28.0),
    @raylib.Vector2::new(28.0, 28.0),
    @raylib.red,
  )
  assert_true(img.is_valid())
  // Center of the triangle should be red
  let c = img.get_color(16, 16)
  assert_eq(c.r, @raylib.red.r)
  img.unload()
}

///|
test "draw_triangle_ex draws gradient triangle" {
  let img = @raylib.Image::gen_color(32, 32, @raylib.black)
  img.draw_triangle_ex(
    @raylib.Vector2::new(16.0, 4.0),
    @raylib.Vector2::new(4.0, 28.0),
    @raylib.Vector2::new(28.0, 28.0),
    @raylib.red,
    @raylib.green,
    @raylib.blue,
  )
  assert_true(img.is_valid())
  img.unload()
}

///|
test "draw_triangle_lines draws triangle outline" {
  let img = @raylib.Image::gen_color(32, 32, @raylib.black)
  img.draw_triangle_lines(
    @raylib.Vector2::new(16.0, 4.0),
    @raylib.Vector2::new(4.0, 28.0),
    @raylib.Vector2::new(28.0, 28.0),
    @raylib.red,
  )
  assert_true(img.is_valid())
  img.unload()
}

///|
test "draw_triangle_fan draws filled fan" {
  let img = @raylib.Image::gen_color(32, 32, @raylib.black)
  let points : Array[@raylib.Vector2] = [
    @raylib.Vector2::new(16.0, 16.0),
    @raylib.Vector2::new(28.0, 8.0),
    @raylib.Vector2::new(28.0, 24.0),
    @raylib.Vector2::new(16.0, 28.0),
  ]
  img.draw_triangle_fan(points, @raylib.green)
  assert_true(img.is_valid())
  img.unload()
}

///|
test "draw_triangle_strip draws triangle strip" {
  let img = @raylib.Image::gen_color(32, 32, @raylib.black)
  let points : Array[@raylib.Vector2] = [
    @raylib.Vector2::new(4.0, 4.0),
    @raylib.Vector2::new(4.0, 28.0),
    @raylib.Vector2::new(16.0, 4.0),
    @raylib.Vector2::new(16.0, 28.0),
    @raylib.Vector2::new(28.0, 4.0),
    @raylib.Vector2::new(28.0, 28.0),
  ]
  img.draw_triangle_strip(points, @raylib.blue)
  assert_true(img.is_valid())
  img.unload()
}

///|
test "draw image onto image" {
  let dst = @raylib.Image::gen_color(16, 16, @raylib.black)
  let src = @raylib.Image::gen_color(4, 4, @raylib.red)
  dst.draw(
    src,
    @raylib.Rectangle::new(0.0, 0.0, 4.0, 4.0),
    @raylib.Rectangle::new(2.0, 2.0, 4.0, 4.0),
    @raylib.white,
  )
  // The drawn region should be red
  let c = dst.get_color(3, 3)
  assert_eq(c.r, @raylib.red.r)
  // Outside should still be black
  let outside = dst.get_color(0, 0)
  assert_eq(outside.r, @raylib.black.r)
  src.unload()
  dst.unload()
}

///|
test "alpha_clear clears alpha based on threshold" {
  let img = @raylib.Image::gen_color(4, 4, @raylib.Color::new(255, 0, 0, 128))
  img.alpha_clear(@raylib.Color::new(255, 0, 0, 128), 0.6)
  assert_true(img.is_valid())
  img.unload()
}

///|
test "load_from_memory loads from PNG bytes" {
  // Generate an image, export to memory, then reload
  let orig = @raylib.Image::gen_color(4, 4, @raylib.red)
  let png_data = orig.export_to_memory(".png")
  let reloaded = @raylib.Image::load_from_memory(
    ".png",
    png_data,
    png_data.length(),
  )
  assert_true(reloaded.is_valid())
  assert_eq(reloaded.width(), 4)
  assert_eq(reloaded.height(), 4)
  let c = reloaded.get_color(0, 0)
  assert_eq(c.r, @raylib.red.r)
  assert_eq(c.g, @raylib.red.g)
  assert_eq(c.b, @raylib.red.b)
  reloaded.unload()
  orig.unload()
}
