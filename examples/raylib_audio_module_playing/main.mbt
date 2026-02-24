///|
fn main {
  // Initialization
  let screen_width = 800
  let screen_height = 450
  let max_circles = 64

  @raylib.set_config_flags(@raylib.FlagMsaa4xHint) // NOTE: Try to enable MSAA 4X

  let _ = @raylib.change_directory("examples/raylib_audio_module_playing")

  @raylib.init_window(
    screen_width, screen_height, "raylib [audio] example - module playing (streaming)",
  )

  @raylib.init_audio_device()

  let colors : Array[@raylib.Color] = [
    @raylib.orange, @raylib.red, @raylib.gold, @raylib.lime, @raylib.blue, @raylib.violet,
    @raylib.brown, @raylib.lightgray, @raylib.pink, @raylib.yellow, @raylib.green,
    @raylib.skyblue, @raylib.purple, @raylib.beige,
  ]

  // Creates some circles for visual effect
  let circle_alpha : Array[Float] = []
  let circle_radius : Array[Float] = []
  let circle_pos_x : Array[Float] = []
  let circle_pos_y : Array[Float] = []
  let circle_speed : Array[Float] = []
  let circle_color : Array[@raylib.Color] = []

  for _i = 0; _i < max_circles; _i = _i + 1 {
    circle_alpha.push(0.0)
    circle_radius.push(0.0)
    circle_pos_x.push(0.0)
    circle_pos_y.push(0.0)
    circle_speed.push(0.0)
    circle_color.push(@raylib.orange)
  }

  for i = max_circles - 1; i >= 0; i = i - 1 {
    circle_alpha[i] = 0.0
    circle_radius[i] = Float::from_int(@raylib.get_random_value(10, 40))
    circle_pos_x[i] = Float::from_int(
      @raylib.get_random_value(
        circle_radius[i].to_int(),
        screen_width - circle_radius[i].to_int(),
      ),
    )
    circle_pos_y[i] = Float::from_int(
      @raylib.get_random_value(
        circle_radius[i].to_int(),
        screen_height - circle_radius[i].to_int(),
      ),
    )
    circle_speed[i] = Float::from_int(@raylib.get_random_value(1, 100)) / 2000.0
    circle_color[i] = colors[@raylib.get_random_value(0, 13)]
  }

  let music = @raylib.load_music_stream("resources/mini1111.xm")
  // NOTE: music.looping = false cannot be set (no setter available)
  // The music will loop by default, which is acceptable
  let mut pitch : Float = 1.0

  @raylib.play_music_stream(music)

  let mut time_played : Float = 0.0
  let mut pause = false

  @raylib.set_target_fps(60)

  // Main game loop
  while not(@raylib.window_should_close()) {
    // Update
    @raylib.update_music_stream(music)

    // Restart music playing (stop and play)
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      @raylib.stop_music_stream(music)
      @raylib.play_music_stream(music)
      pause = false
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

    if @raylib.is_key_down(@raylib.KeyDown) {
      pitch -= 0.01
    } else if @raylib.is_key_down(@raylib.KeyUp) {
      pitch += 0.01
    }

    @raylib.set_music_pitch(music, pitch)

    // Get timePlayed scaled to bar dimensions
    time_played = @raylib.get_music_time_played(music) /
      @raylib.get_music_time_length(music) *
      Float::from_int(screen_width - 40)

    // Color circles animation
    if not(pause) {
      for i = max_circles - 1; i >= 0; i = i - 1 {
        circle_alpha[i] += circle_speed[i]
        circle_radius[i] += circle_speed[i] * 10.0

        if circle_alpha[i] > 1.0 {
          circle_speed[i] *= -1.0
        }

        if circle_alpha[i] <= 0.0 {
          circle_alpha[i] = 0.0
          circle_radius[i] = Float::from_int(@raylib.get_random_value(10, 40))
          circle_pos_x[i] = Float::from_int(
            @raylib.get_random_value(
              circle_radius[i].to_int(),
              screen_width - circle_radius[i].to_int(),
            ),
          )
          circle_pos_y[i] = Float::from_int(
            @raylib.get_random_value(
              circle_radius[i].to_int(),
              screen_height - circle_radius[i].to_int(),
            ),
          )
          circle_color[i] = colors[@raylib.get_random_value(0, 13)]
          circle_speed[i] = Float::from_int(@raylib.get_random_value(1, 100)) /
            2000.0
        }
      }
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    for i = max_circles - 1; i >= 0; i = i - 1 {
      @raylib.draw_circle_v(
        @raylib.Vector2::new(circle_pos_x[i], circle_pos_y[i]),
        circle_radius[i],
        @raylib.fade(circle_color[i], circle_alpha[i]),
      )
    }

    // Draw time bar
    @raylib.draw_rectangle(
      20,
      screen_height - 20 - 12,
      screen_width - 40,
      12,
      @raylib.lightgray,
    )
    @raylib.draw_rectangle(
      20,
      screen_height - 20 - 12,
      time_played.to_int(),
      12,
      @raylib.maroon,
    )
    @raylib.draw_rectangle_lines(
      20,
      screen_height - 20 - 12,
      screen_width - 40,
      12,
      @raylib.gray,
    )

    // Draw help instructions
    @raylib.draw_rectangle(20, 20, 425, 145, @raylib.white)
    @raylib.draw_rectangle_lines(20, 20, 425, 145, @raylib.gray)
    @raylib.draw_text("PRESS SPACE TO RESTART MUSIC", 40, 40, 20, @raylib.black)
    @raylib.draw_text("PRESS P TO PAUSE/RESUME", 40, 70, 20, @raylib.black)
    @raylib.draw_text(
      "PRESS UP/DOWN TO CHANGE SPEED", 40, 100, 20, @raylib.black,
    )
    @raylib.draw_text("SPEED: \{pitch}", 40, 130, 20, @raylib.maroon)

    @raylib.end_drawing()
  }

  // De-Initialization
  @raylib.unload_music_stream(music)
  @raylib.close_audio_device()
  @raylib.close_window()
}
