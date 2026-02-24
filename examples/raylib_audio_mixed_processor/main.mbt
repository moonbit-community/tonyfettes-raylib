///|
fn powf(base : Float, exp : Float) -> Float {
  Float::from_double(@math.pow(base.to_double(), exp.to_double()))
}

// Audio exponentiation value (FixedArray to allow mutation from callback)

///|
let exponent : FixedArray[Float] = [1.0]

// Average volume history

///|
let average_volume : FixedArray[Float] = FixedArray::make(400, 0.0)

///|
fn process_audio_impl(buffer : @raylib.AudioBuffer, frames : UInt) -> Unit {
  let mut average : Float = 0.0
  let frames_f = Float::from_int(frames.reinterpret_as_int())
  for frame = 0U; frame < frames; frame = frame + 1U {
    let i_left = frame * 2U
    let i_right = frame * 2U + 1U
    let left = @raylib.audio_buffer_get_sample(buffer, i_left)
    let right = @raylib.audio_buffer_get_sample(buffer, i_right)
    let new_left = powf(left.abs(), exponent[0]) *
      (if left < 0.0 { -1.0 } else { 1.0 })
    let new_right = powf(right.abs(), exponent[0]) *
      (if right < 0.0 { -1.0 } else { 1.0 })
    @raylib.audio_buffer_set_sample(buffer, i_left, new_left)
    @raylib.audio_buffer_set_sample(buffer, i_right, new_right)
    average += new_left.abs() / frames_f
    average += new_right.abs() / frames_f
  }
  // Shift history left
  for i = 0; i < 399; i = i + 1 {
    average_volume[i] = average_volume[i + 1]
  }
  average_volume[399] = average
}

///|
let process_audio : FuncRef[(@raylib.AudioBuffer, UInt) -> Unit] = (
  buffer,
  frames,
) => process_audio_impl(buffer, frames)

///|
fn main {
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [audio] example - processing mixed output",
  )
  @raylib.init_audio_device()
  @raylib.attach_audio_mixed_processor(process_audio)
  let music = @raylib.load_music_stream("resources/country.mp3")
  let sound = @raylib.load_sound("resources/coin.wav")
  @raylib.play_music_stream(music)
  @raylib.set_target_fps(60)
  while not(@raylib.window_should_close()) {
    @raylib.update_music_stream(music)
    if @raylib.is_key_pressed(@raylib.KeyLeft) {
      exponent[0] -= 0.05
    }
    if @raylib.is_key_pressed(@raylib.KeyRight) {
      exponent[0] += 0.05
    }
    if exponent[0] <= 0.5 {
      exponent[0] = 0.5
    }
    if exponent[0] >= 3.0 {
      exponent[0] = 3.0
    }
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      @raylib.play_sound(sound)
    }
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text(
      "MUSIC SHOULD BE PLAYING!", 255, 150, 20, @raylib.lightgray,
    )
    @raylib.draw_text(
      "EXPONENT = \{exponent[0]}",
      215,
      180,
      20,
      @raylib.lightgray,
    )
    @raylib.draw_rectangle(199, 199, 402, 34, @raylib.lightgray)
    for i = 0; i < 400; i = i + 1 {
      @raylib.draw_line(
        201 + i,
        232 - (average_volume[i] * 32.0).to_int(),
        201 + i,
        232,
        @raylib.maroon,
      )
    }
    @raylib.draw_rectangle_lines(199, 199, 402, 34, @raylib.gray)
    @raylib.draw_text(
      "PRESS SPACE TO PLAY OTHER SOUND", 200, 250, 20, @raylib.lightgray,
    )
    @raylib.draw_text(
      "USE LEFT AND RIGHT ARROWS TO ALTER DISTORTION", 140, 280, 20, @raylib.lightgray,
    )
    @raylib.end_drawing()
  }
  @raylib.unload_music_stream(music)
  @raylib.detach_audio_mixed_processor(process_audio)
  @raylib.close_audio_device()
  @raylib.close_window()
}
