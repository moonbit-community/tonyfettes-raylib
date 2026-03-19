///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  @raylib.init_window(
    screen_width, screen_height, "raylib [others] example - embedded files loading",
  )

  @raylib.init_audio_device()

  // Load wave from embedded data (coin.wav bytes embedded in audio_data.mbt)
  let wave = @raylib.load_wave_from_memory(
    ".wav",
    audio_data,
    audio_data.length(),
  )
  let sound = @raylib.load_sound_from_wave(wave)
  @raylib.unload_wave(wave)

  // Load image from embedded data (raylib_logo.png bytes embedded in image_data.mbt)
  let image = @raylib.load_image_from_memory(
    ".png",
    image_data,
    image_data.length(),
  )
  let texture = @raylib.load_texture_from_image(image)
  @raylib.unload_image(image)

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      @raylib.play_sound(sound)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_texture(
      texture,
      screen_width / 2 - texture.width() / 2,
      40,
      @raylib.white,
    )

    @raylib.draw_text(
      "raylib logo and sound loaded from embedded data", 150, 320, 20, @raylib.lightgray,
    )
    @raylib.draw_text(
      "Press SPACE to PLAY the sound!", 220, 370, 20, @raylib.lightgray,
    )

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_sound(sound)
  @raylib.unload_texture(texture)
  @raylib.close_audio_device()
  @raylib.close_window()
}
