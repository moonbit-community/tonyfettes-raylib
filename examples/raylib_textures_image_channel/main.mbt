///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_textures_image_channel")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - extract channel from image",
  )

  let fudesumi_image = @raylib.load_image("resources/fudesumi.png")

  // fudesumi.png: 384x512
  let image_width : Float = 384.0
  let image_height : Float = 512.0

  let image_alpha = @raylib.image_from_channel(fudesumi_image, 3)
  @raylib.image_alpha_mask(image_alpha, image_alpha)

  let image_red = @raylib.image_from_channel(fudesumi_image, 0)
  @raylib.image_alpha_mask(image_red, image_alpha)

  let image_green = @raylib.image_from_channel(fudesumi_image, 1)
  @raylib.image_alpha_mask(image_green, image_alpha)

  let image_blue = @raylib.image_from_channel(fudesumi_image, 2)
  @raylib.image_alpha_mask(image_blue, image_alpha)

  let background_image = @raylib.gen_image_checked(
    screen_width,
    screen_height,
    screen_width / 20,
    screen_height / 20,
    @raylib.orange,
    @raylib.yellow,
  )

  let fudesumi_texture = @raylib.load_texture_from_image(fudesumi_image)
  let texture_alpha = @raylib.load_texture_from_image(image_alpha)
  let texture_red = @raylib.load_texture_from_image(image_red)
  let texture_green = @raylib.load_texture_from_image(image_green)
  let texture_blue = @raylib.load_texture_from_image(image_blue)
  let background_texture = @raylib.load_texture_from_image(background_image)

  @raylib.unload_image(fudesumi_image)
  @raylib.unload_image(image_alpha)
  @raylib.unload_image(image_red)
  @raylib.unload_image(image_green)
  @raylib.unload_image(image_blue)
  @raylib.unload_image(background_image)

  @raylib.set_target_fps(60)

  let fudesumi_rec = @raylib.Rectangle::new(0.0, 0.0, image_width, image_height)
  let fudesumi_pos = @raylib.Rectangle::new(
    50.0,
    10.0,
    image_width * 0.8,
    image_height * 0.8,
  )
  let red_pos = @raylib.Rectangle::new(
    410.0,
    10.0,
    image_width * 0.8 / 2.0,
    image_height * 0.8 / 2.0,
  )
  let green_pos = @raylib.Rectangle::new(
    600.0,
    10.0,
    image_width * 0.8 / 2.0,
    image_height * 0.8 / 2.0,
  )
  let blue_pos = @raylib.Rectangle::new(
    410.0,
    230.0,
    image_width * 0.8 / 2.0,
    image_height * 0.8 / 2.0,
  )
  let alpha_pos = @raylib.Rectangle::new(
    600.0,
    230.0,
    image_width * 0.8 / 2.0,
    image_height * 0.8 / 2.0,
  )

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Draw
    @raylib.begin_drawing()

    @raylib.draw_texture(background_texture, 0, 0, @raylib.white)
    @raylib.draw_texture_pro(
      fudesumi_texture,
      fudesumi_rec,
      fudesumi_pos,
      @raylib.Vector2::new(0.0, 0.0),
      0.0,
      @raylib.white,
    )

    @raylib.draw_texture_pro(
      texture_red,
      fudesumi_rec,
      red_pos,
      @raylib.Vector2::new(0.0, 0.0),
      0.0,
      @raylib.red,
    )
    @raylib.draw_texture_pro(
      texture_green,
      fudesumi_rec,
      green_pos,
      @raylib.Vector2::new(0.0, 0.0),
      0.0,
      @raylib.green,
    )
    @raylib.draw_texture_pro(
      texture_blue,
      fudesumi_rec,
      blue_pos,
      @raylib.Vector2::new(0.0, 0.0),
      0.0,
      @raylib.blue,
    )
    @raylib.draw_texture_pro(
      texture_alpha,
      fudesumi_rec,
      alpha_pos,
      @raylib.Vector2::new(0.0, 0.0),
      0.0,
      @raylib.white,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(background_texture)
  @raylib.unload_texture(fudesumi_texture)
  @raylib.unload_texture(texture_red)
  @raylib.unload_texture(texture_green)
  @raylib.unload_texture(texture_blue)
  @raylib.unload_texture(texture_alpha)
  @raylib.close_window()
}
