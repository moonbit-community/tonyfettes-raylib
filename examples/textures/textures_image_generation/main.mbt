///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let num_textures = 9

  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - procedural images generation",
  )

  let vertical_gradient = @raylib.gen_image_gradient_linear(
    screen_width, screen_height, 0, @raylib.red, @raylib.blue,
  )
  let horizontal_gradient = @raylib.gen_image_gradient_linear(
    screen_width, screen_height, 90, @raylib.red, @raylib.blue,
  )
  let diagonal_gradient = @raylib.gen_image_gradient_linear(
    screen_width, screen_height, 45, @raylib.red, @raylib.blue,
  )
  let radial_gradient = @raylib.gen_image_gradient_radial(
    screen_width, screen_height, 0.0, @raylib.white, @raylib.black,
  )
  let square_gradient = @raylib.gen_image_gradient_square(
    screen_width, screen_height, 0.0, @raylib.white, @raylib.black,
  )
  let checked = @raylib.gen_image_checked(
    screen_width, screen_height, 32, 32, @raylib.red, @raylib.blue,
  )
  let white_noise = @raylib.gen_image_white_noise(
    screen_width, screen_height, 0.5,
  )
  let perlin_noise = @raylib.gen_image_perlin_noise(
    screen_width, screen_height, 50, 50, 4.0,
  )
  let cellular = @raylib.gen_image_cellular(screen_width, screen_height, 32)

  let textures = [
    @raylib.load_texture_from_image(vertical_gradient),
    @raylib.load_texture_from_image(horizontal_gradient),
    @raylib.load_texture_from_image(diagonal_gradient),
    @raylib.load_texture_from_image(radial_gradient),
    @raylib.load_texture_from_image(square_gradient),
    @raylib.load_texture_from_image(checked),
    @raylib.load_texture_from_image(white_noise),
    @raylib.load_texture_from_image(perlin_noise),
    @raylib.load_texture_from_image(cellular),
  ]

  // Unload image data (CPU RAM)
  @raylib.unload_image(vertical_gradient)
  @raylib.unload_image(horizontal_gradient)
  @raylib.unload_image(diagonal_gradient)
  @raylib.unload_image(radial_gradient)
  @raylib.unload_image(square_gradient)
  @raylib.unload_image(checked)
  @raylib.unload_image(white_noise)
  @raylib.unload_image(perlin_noise)
  @raylib.unload_image(cellular)

  let mut current_texture = 0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) ||
      @raylib.is_key_pressed(@raylib.KeyRight) {
      current_texture = (current_texture + 1) % num_textures
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_texture(textures[current_texture], 0, 0, @raylib.white)
    @raylib.draw_rectangle(30, 400, 325, 30, @raylib.fade(@raylib.skyblue, 0.5))
    @raylib.draw_rectangle_lines(
      30,
      400,
      325,
      30,
      @raylib.fade(@raylib.white, 0.5),
    )
    @raylib.draw_text(
      "MOUSE LEFT BUTTON to CYCLE PROCEDURAL TEXTURES", 40, 410, 10, @raylib.white,
    )
    match current_texture {
      0 => @raylib.draw_text("VERTICAL GRADIENT", 560, 10, 20, @raylib.raywhite)
      1 =>
        @raylib.draw_text("HORIZONTAL GRADIENT", 540, 10, 20, @raylib.raywhite)
      2 => @raylib.draw_text("DIAGONAL GRADIENT", 540, 10, 20, @raylib.raywhite)
      3 => @raylib.draw_text("RADIAL GRADIENT", 580, 10, 20, @raylib.lightgray)
      4 => @raylib.draw_text("SQUARE GRADIENT", 580, 10, 20, @raylib.lightgray)
      5 => @raylib.draw_text("CHECKED", 680, 10, 20, @raylib.raywhite)
      6 => @raylib.draw_text("WHITE NOISE", 640, 10, 20, @raylib.red)
      7 => @raylib.draw_text("PERLIN NOISE", 640, 10, 20, @raylib.red)
      8 => @raylib.draw_text("CELLULAR", 670, 10, 20, @raylib.raywhite)
      _ => ()
    }
    @raylib.end_drawing()
  }

  // De-Initialization
  // Unload textures data (GPU VRAM)
  for i in 0..<num_textures {
    @raylib.unload_texture(textures[i])
  }

  @raylib.close_window()
}
