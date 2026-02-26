// Helper: serialize a Float to 4 little-endian bytes for SetShaderValue

///|
fn float_to_bytes(f : Float) -> Bytes {
  let bits = f.reinterpret_as_int()
  let arr : FixedArray[Byte] = [
    (bits & 0xFF).to_byte(),
    ((bits >> 8) & 0xFF).to_byte(),
    ((bits >> 16) & 0xFF).to_byte(),
    ((bits >> 24) & 0xFF).to_byte(),
  ]
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_shaders_color_correction")

  @raylib.init_window(
    screen_width, screen_height, "raylib [shaders] example - color correction",
  )

  // Load textures. Since Texture is opaque, load as Image first to get dimensions.
  let max_textures = 4

  let img0 = @raylib.load_image("resources/parrots.png")
  let img1 = @raylib.load_image("resources/cat.png")
  let img2 = @raylib.load_image("resources/mandrill.png")
  let img3 = @raylib.load_image("resources/fudesumi.png")

  let tex_widths = [
    @raylib.image_width(img0),
    @raylib.image_width(img1),
    @raylib.image_width(img2),
    @raylib.image_width(img3),
  ]
  let tex_heights = [
    @raylib.image_height(img0),
    @raylib.image_height(img1),
    @raylib.image_height(img2),
    @raylib.image_height(img3),
  ]

  let textures = [
    @raylib.load_texture_from_image(img0),
    @raylib.load_texture_from_image(img1),
    @raylib.load_texture_from_image(img2),
    @raylib.load_texture_from_image(img3),
  ]

  @raylib.unload_image(img0)
  @raylib.unload_image(img1)
  @raylib.unload_image(img2)
  @raylib.unload_image(img3)

  // Load color correction shader (pass empty string for NULL vertex shader)
  let shdr_color_correction = @raylib.load_shader(
    "", "resources/shaders/glsl330/color_correction.fs",
  )

  let image_index : Ref[Int] = { val: 0 }

  let contrast : Ref[Float] = { val: 0.0 }
  let saturation : Ref[Float] = { val: 0.0 }
  let brightness : Ref[Float] = { val: 0.0 }

  // Get shader locations
  let contrast_loc = @raylib.get_shader_location(
    shdr_color_correction, "contrast",
  )
  let saturation_loc = @raylib.get_shader_location(
    shdr_color_correction, "saturation",
  )
  let brightness_loc = @raylib.get_shader_location(
    shdr_color_correction, "brightness",
  )

  // Set initial shader values
  @raylib.set_shader_value(
    shdr_color_correction,
    contrast_loc,
    float_to_bytes(contrast.val),
    0,
  )
  @raylib.set_shader_value(
    shdr_color_correction,
    saturation_loc,
    float_to_bytes(saturation.val),
    0,
  )
  @raylib.set_shader_value(
    shdr_color_correction,
    brightness_loc,
    float_to_bytes(brightness.val),
    0,
  )

  @raylib.set_target_fps(60)

  // Key constants
  let key_one = 49
  let key_two = 50
  let key_three = 51
  let key_four = 52
  let key_r = 82

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    // Select texture to draw
    if @raylib.is_key_pressed(key_one) {
      image_index.val = 0
    } else if @raylib.is_key_pressed(key_two) {
      image_index.val = 1
    } else if @raylib.is_key_pressed(key_three) {
      image_index.val = 2
    } else if @raylib.is_key_pressed(key_four) {
      image_index.val = 3
    }

    // Reset values to 0
    let reset_button_clicked = @raygui.gui_button(
      @raylib.Rectangle::new(645.0, 190.0, 40.0, 20.0),
      "Reset",
    )
    if @raylib.is_key_pressed(key_r) || reset_button_clicked {
      contrast.val = 0.0
      saturation.val = 0.0
      brightness.val = 0.0
    }

    // Send the values to the shader
    @raylib.set_shader_value(
      shdr_color_correction,
      contrast_loc,
      float_to_bytes(contrast.val),
      0,
    )
    @raylib.set_shader_value(
      shdr_color_correction,
      saturation_loc,
      float_to_bytes(saturation.val),
      0,
    )
    @raylib.set_shader_value(
      shdr_color_correction,
      brightness_loc,
      float_to_bytes(brightness.val),
      0,
    )

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.begin_shader_mode(shdr_color_correction)
    let idx = image_index.val
    @raylib.draw_texture(
      textures[idx],
      580 / 2 - tex_widths[idx] / 2,
      @raylib.get_screen_height() / 2 - tex_heights[idx] / 2,
      @raylib.white,
    )
    @raylib.end_shader_mode()

    @raylib.draw_line(
      580,
      0,
      580,
      @raylib.get_screen_height(),
      @raylib.Color::new(218, 218, 218, 255),
    )
    @raylib.draw_rectangle(
      580,
      0,
      @raylib.get_screen_width(),
      @raylib.get_screen_height(),
      @raylib.Color::new(232, 232, 232, 255),
    )

    // Draw UI info text
    @raylib.draw_text("Color Correction", 585, 40, 20, @raylib.gray)
    @raylib.draw_text("Picture", 602, 75, 10, @raylib.gray)
    @raylib.draw_text(
      "Press [1] - [4] to Change Picture", 600, 230, 8, @raylib.gray,
    )
    @raylib.draw_text("Press [R] to Reset Values", 600, 250, 8, @raylib.gray)

    // Draw GUI controls
    @raygui.gui_toggle_group(
      @raylib.Rectangle::new(645.0, 70.0, 20.0, 20.0),
      "1;2;3;4",
      image_index,
    )

    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(645.0, 100.0, 120.0, 20.0),
      "Contrast",
      contrast.val.to_int().to_string(),
      contrast,
      -100.0,
      100.0,
    )
    |> ignore

    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(645.0, 130.0, 120.0, 20.0),
      "Saturation",
      saturation.val.to_int().to_string(),
      saturation,
      -100.0,
      100.0,
    )
    |> ignore

    @raygui.gui_slider_bar(
      @raylib.Rectangle::new(645.0, 160.0, 120.0, 20.0),
      "Brightness",
      brightness.val.to_int().to_string(),
      brightness,
      -100.0,
      100.0,
    )
    |> ignore

    @raylib.draw_fps(710, 10)

    @raylib.end_drawing()
  }

  // De-Initialization
  for i = 0; i < max_textures; i = i + 1 {
    @raylib.unload_texture(textures[i])
  }
  @raylib.unload_shader(shdr_color_correction)
  @raylib.close_window()
}
