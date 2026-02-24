///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_textures_image_drawing")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - image drawing",
  )

  // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)

  let cat = @raylib.load_image("resources/cat.png") // Load image in CPU memory (RAM)
  @raylib.image_crop(cat, @raylib.Rectangle::new(100.0, 10.0, 280.0, 380.0)) // Crop an image piece
  @raylib.image_flip_horizontal(cat) // Flip cropped image horizontally
  @raylib.image_resize(cat, 150, 200) // Resize flipped-cropped image

  let parrots = @raylib.load_image("resources/parrots.png") // Load image in CPU memory (RAM)

  // Draw one image over the other with a scaling of 1.5f
  // cat after resize is 150x200
  @raylib.image_draw(
    parrots,
    cat,
    @raylib.Rectangle::new(0.0, 0.0, 150.0, 200.0),
    @raylib.Rectangle::new(30.0, 40.0, 225.0, 300.0),
    @raylib.white,
  )
  // parrots.png is 512x384, crop resulting image
  @raylib.image_crop(parrots, @raylib.Rectangle::new(0.0, 50.0, 512.0, 284.0))

  // Draw on the image with a few image draw methods
  @raylib.image_draw_pixel(parrots, 10, 10, @raylib.raywhite)
  @raylib.image_draw_circle_lines(parrots, 10, 10, 5, @raylib.raywhite)
  @raylib.image_draw_rectangle(parrots, 5, 20, 10, 10, @raylib.raywhite)

  @raylib.unload_image(cat) // Unload image from RAM

  // Load custom font for drawing on image
  let font = @raylib.load_font("resources/custom_jupiter_crash.png")

  // Draw over image using custom font
  @raylib.image_draw_text_ex(
    parrots,
    font,
    "PARROTS & CAT",
    @raylib.Vector2::new(300.0, 230.0),
    32.0,
    -2.0,
    @raylib.white,
  )

  @raylib.unload_font(font) // Unload custom font (already drawn used on image)

  let texture = @raylib.load_texture_from_image(parrots) // Image converted to texture, uploaded to GPU memory (VRAM)
  @raylib.unload_image(parrots) // Once image has been converted to texture and uploaded to VRAM, it can be unloaded from RAM

  // texture dimensions: 512 x 284 (after crop)
  let tex_width = 512
  let tex_height = 284

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_texture(
      texture,
      screen_width / 2 - tex_width / 2,
      screen_height / 2 - tex_height / 2 - 40,
      @raylib.white,
    )
    @raylib.draw_rectangle_lines(
      screen_width / 2 - tex_width / 2,
      screen_height / 2 - tex_height / 2 - 40,
      tex_width,
      tex_height,
      @raylib.darkgray,
    )

    @raylib.draw_text(
      "We are drawing only one texture from various images composed!", 240, 350,
      10, @raylib.darkgray,
    )
    @raylib.draw_text(
      "Source images have been cropped, scaled, flipped and copied one over the other.",
      190, 370, 10, @raylib.darkgray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.close_window()
}
