///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let num_processes = 9
  let _ = @raylib.change_directory("examples/raylib_textures_image_processing")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - image processing",
  )

  // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  let im_origin = @raylib.load_image("resources/parrots.png")
  @raylib.image_format(im_origin, @raylib.PixelformatUncompressedR8g8b8a8)
  let texture = @raylib.load_texture_from_image(im_origin)

  // parrots.png: 512x384
  let texture_width = 512
  let texture_height = 384

  let mut im_copy = @raylib.image_copy(im_origin)

  let mut current_process = 0
  let mut texture_reload = false

  let process_text : Array[String] = [
    "NO PROCESSING", "COLOR GRAYSCALE", "COLOR TINT", "COLOR INVERT", "COLOR CONTRAST",
    "COLOR BRIGHTNESS", "GAUSSIAN BLUR", "FLIP VERTICAL", "FLIP HORIZONTAL",
  ]

  let mut mouse_hover_rec = -1

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update

    // Mouse toggle group logic
    mouse_hover_rec = -1
    for i in 0..<num_processes {
      let toggle_rec = @raylib.Rectangle::new(
        40.0,
        Float::from_int(50 + 32 * i),
        150.0,
        30.0,
      )
      if @raylib.check_collision_point_rec(
          @raylib.get_mouse_position(),
          toggle_rec,
        ) {
        mouse_hover_rec = i
        if @raylib.is_mouse_button_released(@raylib.MouseButtonLeft) {
          current_process = i
          texture_reload = true
        }
        break
      }
    }

    // Keyboard toggle group logic
    if @raylib.is_key_pressed(@raylib.KeyDown) {
      current_process += 1
      if current_process > num_processes - 1 {
        current_process = 0
      }
      texture_reload = true
    } else if @raylib.is_key_pressed(@raylib.KeyUp) {
      current_process -= 1
      if current_process < 0 {
        current_process = 7
      }
      texture_reload = true
    }

    // Reload texture when required
    if texture_reload {
      @raylib.unload_image(im_copy)
      im_copy = @raylib.image_copy(im_origin)

      match current_process {
        1 => @raylib.image_color_grayscale(im_copy)
        2 => @raylib.image_color_tint(im_copy, @raylib.green)
        3 => @raylib.image_color_invert(im_copy)
        4 => @raylib.image_color_contrast(im_copy, -40.0)
        5 => @raylib.image_color_brightness(im_copy, -80)
        6 => @raylib.image_blur_gaussian(im_copy, 10)
        7 => @raylib.image_flip_vertical(im_copy)
        8 => @raylib.image_flip_horizontal(im_copy)
        _ => ()
      }

      let pixels = @raylib.load_image_colors(im_copy)
      @raylib.update_texture(texture, pixels)

      texture_reload = false
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_text("IMAGE PROCESSING:", 40, 30, 10, @raylib.darkgray)

    // Draw rectangles
    for i in 0..<num_processes {
      let toggle_rec = @raylib.Rectangle::new(
        40.0,
        Float::from_int(50 + 32 * i),
        150.0,
        30.0,
      )
      let highlight = i == current_process || i == mouse_hover_rec
      if highlight {
        @raylib.draw_rectangle_rec(toggle_rec, @raylib.skyblue)
      } else {
        @raylib.draw_rectangle_rec(toggle_rec, @raylib.lightgray)
      }
      let border_color = if highlight { @raylib.blue } else { @raylib.gray }
      @raylib.draw_rectangle_lines(
        toggle_rec.x.to_int(),
        toggle_rec.y.to_int(),
        150,
        30,
        border_color,
      )
      let text_color = if highlight {
        @raylib.darkblue
      } else {
        @raylib.darkgray
      }
      let text_width = @raylib.measure_text(process_text[i], 10)
      @raylib.draw_text(
        process_text[i],
        (toggle_rec.x + 150.0 / 2.0 - Float::from_int(text_width) / 2.0).to_int(),
        toggle_rec.y.to_int() + 11,
        10,
        text_color,
      )
    }

    @raylib.draw_texture(
      texture,
      screen_width - texture_width - 60,
      screen_height / 2 - texture_height / 2,
      @raylib.white,
    )
    @raylib.draw_rectangle_lines(
      screen_width - texture_width - 60,
      screen_height / 2 - texture_height / 2,
      texture_width,
      texture_height,
      @raylib.black,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(texture)
  @raylib.unload_image(im_origin)
  @raylib.unload_image(im_copy)
  @raylib.close_window()
}
