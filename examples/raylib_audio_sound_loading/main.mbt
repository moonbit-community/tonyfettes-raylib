///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_audio_sound_loading")

  @raylib.init_window(
    screen_width, screen_height, "raylib [audio] example - sound loading and playing",
  )

  @raylib.init_audio_device() // Initialize audio device

  let fx_wav = @raylib.load_sound("resources/sound.wav") // Load WAV audio file
  let fx_ogg = @raylib.load_sound("resources/target.ogg") // Load OGG audio file

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      @raylib.play_sound(fx_wav) // Play WAV sound
    }
    if @raylib.is_key_pressed(@raylib.KeyEnter) {
      @raylib.play_sound(fx_ogg) // Play OGG sound
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text(
      "Press SPACE to PLAY the WAV sound!", 200, 180, 20, @raylib.lightgray,
    )
    @raylib.draw_text(
      "Press ENTER to PLAY the OGG sound!", 200, 220, 20, @raylib.lightgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_sound(fx_wav)
  @raylib.unload_sound(fx_ogg)
  @raylib.close_audio_device()
  @raylib.close_window()
}
