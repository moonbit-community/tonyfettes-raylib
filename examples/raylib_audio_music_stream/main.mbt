///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450

  let _ = @raylib.change_directory("examples/raylib_audio_music_stream")

  @raylib.init_window(
    screen_width, screen_height, "raylib [audio] example - music playing (streaming)",
  )

  @raylib.init_audio_device()

  let music = @raylib.load_music_stream("resources/country.mp3")

  @raylib.play_music_stream(music)

  let mut time_played : Float = 0.0 // Time played normalized [0.0..1.0]
  let mut pause = false

  @raylib.set_target_fps(30)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    @raylib.update_music_stream(music)

    // Restart music playing (stop and play)
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      @raylib.stop_music_stream(music)
      @raylib.play_music_stream(music)
    }

    // Pause/Resume music playing
    if @raylib.is_key_pressed(@raylib.KeyP) {
      pause = not(pause)
      if pause {
        @raylib.pause_music_stream(music)
      } else {
        @raylib.resume_music_stream(music)
      }
    }

    // Get normalized time played for current music stream
    time_played = @raylib.get_music_time_played(music) /
      @raylib.get_music_time_length(music)
    if time_played > 1.0 {
      time_played = 1.0
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text(
      "MUSIC SHOULD BE PLAYING!", 255, 150, 20, @raylib.lightgray,
    )
    @raylib.draw_rectangle(200, 200, 400, 12, @raylib.lightgray)
    @raylib.draw_rectangle(
      200,
      200,
      (time_played * 400.0).to_int(),
      12,
      @raylib.maroon,
    )
    @raylib.draw_rectangle_lines(200, 200, 400, 12, @raylib.gray)
    @raylib.draw_text(
      "PRESS SPACE TO RESTART MUSIC", 215, 250, 20, @raylib.lightgray,
    )
    @raylib.draw_text(
      "PRESS P TO PAUSE/RESUME MUSIC", 208, 280, 20, @raylib.lightgray,
    )
    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_music_stream(music)
  @raylib.close_audio_device()
  @raylib.close_window()
}
