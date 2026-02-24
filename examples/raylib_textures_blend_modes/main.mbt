///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let _ = @raylib.change_directory("examples/raylib_textures_blend_modes")
  @raylib.init_window(
    screen_width, screen_height, "raylib [textures] example - blend modes",
  )

  // NOTE: Textures MUST be loaded after Window initialization (OpenGL context is required)
  let bg_image = @raylib.load_image("resources/cyberpunk_street_background.png")
  let bg_texture = @raylib.load_texture_from_image(bg_image)
  let fg_image = @raylib.load_image("resources/cyberpunk_street_foreground.png")
  let fg_texture = @raylib.load_texture_from_image(fg_image)

  // Once images have been converted to textures, they can be unloaded from RAM
  @raylib.unload_image(bg_image)
  @raylib.unload_image(fg_image)

  // Hardcoded dimensions since Texture is opaque
  let bg_width = 512
  let bg_height = 192
  let fg_width = 704
  let fg_height = 192

  let blend_count_max = 4
  let mut blend_mode = 0
  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      if blend_mode >= blend_count_max - 1 {
        blend_mode = 0
      } else {
        blend_mode += 1
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_texture(
      bg_texture,
      screen_width / 2 - bg_width / 2,
      screen_height / 2 - bg_height / 2,
      @raylib.white,
    )

    // Apply the blend mode and then draw the foreground texture
    @raylib.begin_blend_mode(blend_mode)
    @raylib.draw_texture(
      fg_texture,
      screen_width / 2 - fg_width / 2,
      screen_height / 2 - fg_height / 2,
      @raylib.white,
    )
    @raylib.end_blend_mode()

    // Draw the texts
    @raylib.draw_text(
      "Press SPACE to change blend modes.", 310, 350, 10, @raylib.gray,
    )
    let blend_text = match blend_mode {
      0 => "Current: BLEND_ALPHA"
      1 => "Current: BLEND_ADDITIVE"
      2 => "Current: BLEND_MULTIPLIED"
      3 => "Current: BLEND_ADD_COLORS"
      _ => ""
    }
    @raylib.draw_text(blend_text, screen_width / 2 - 60, 370, 10, @raylib.gray)
    @raylib.draw_text(
      "(c) Cyberpunk Street Environment by Luis Zuno (@ansimuz)",
      screen_width - 330,
      screen_height - 20,
      10,
      @raylib.gray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_texture(fg_texture)
  @raylib.unload_texture(bg_texture)
  @raylib.close_window()
}
