///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let num_textures = 3
  let _ = @raylib.change_directory("examples/raylib_textures_image_rotate")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - texture rotation",
  )

  // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  let image45 = @raylib.load_image("resources/raylib_logo.png")
  let image90 = @raylib.load_image("resources/raylib_logo.png")
  let image_neg90 = @raylib.load_image("resources/raylib_logo.png")
  @raylib.image_rotate(image45, 45)
  @raylib.image_rotate(image90, 90)
  @raylib.image_rotate(image_neg90, -90)
  let textures = [
    @raylib.load_texture_from_image(image45),
    @raylib.load_texture_from_image(image90),
    @raylib.load_texture_from_image(image_neg90),
  ]

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

    // We need hardcoded dimensions since Texture is opaque.
    // raylib_logo.png is 256x256. After rotation:
    // - 45 degrees: the rotated image is larger (~362x362)
    // - 90 degrees: 256x256
    // - -90 degrees: 256x256
    // For simplicity, we center each texture at the screen center.
    // Since we can't query texture width/height, we use draw_texture with
    // approximate centering. The C code uses texture.width/2, texture.height/2.
    // Original logo: 256x256
    // After 45deg rotation: ~362x362
    // After 90deg rotation: 256x256
    // After -90deg rotation: 256x256
    let tex_widths = [362, 256, 256]
    let tex_heights = [362, 256, 256]
    @raylib.draw_texture(
      textures[current_texture],
      screen_width / 2 - tex_widths[current_texture] / 2,
      screen_height / 2 - tex_heights[current_texture] / 2,
      @raylib.white,
    )
    @raylib.draw_text(
      "Press LEFT MOUSE BUTTON to rotate the image clockwise", 250, 420, 10, @raylib.darkgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  for i in 0..<num_textures {
    @raylib.unload_texture(textures[i])
  }
  @raylib.close_window()
}
