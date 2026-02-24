///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let max_sounds = 10

  let _ = @raylib.change_directory("examples/raylib_audio_sound_multi")

  @raylib.init_window(
    screen_width, screen_height, "raylib [audio] example - playing sound multiple times",
  )

  @raylib.init_audio_device()

  // Load the sound list
  let sound_array = Array::make(
    max_sounds,
    @raylib.load_sound("resources/sound.wav"),
  )
  // slot 0 is the 'source' sound that owns the sample data
  // slots 1..9 are aliases that share the same audio buffer
  for i in 1..<max_sounds {
    sound_array[i] = @raylib.load_sound_alias(sound_array[0])
  }
  let mut current_sound = 0

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      @raylib.play_sound(sound_array[current_sound])
      current_sound += 1
      if current_sound >= max_sounds {
        current_sound = 0
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text(
      "Press SPACE to PLAY a WAV sound!", 200, 180, 20, @raylib.lightgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  for i in 1..<max_sounds {
    @raylib.unload_sound_alias(sound_array[i])
  }
  @raylib.unload_sound(sound_array[0])
  @raylib.close_audio_device()
  @raylib.close_window()
}
