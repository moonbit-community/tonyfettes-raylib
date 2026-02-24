// LPF state (left, right)

///|
let low : FixedArray[Float] = [0.0, 0.0]

// Delay buffer: 48000*2 = 96000 samples (1 second at 48kHz stereo)

///|
const DelayBufferSize : Int = 96000

///|
let delay_buffer : FixedArray[Float] = FixedArray::make(96000, 0.0)

// Delay read/write indices stored as FixedArray for mutation from callback

///|
let delay_read_index : FixedArray[Int] = [2]

///|
let delay_write_index : FixedArray[Int] = [0]

///|
fn audio_process_effect_lpf_impl(
  buffer : @raylib.AudioBuffer,
  frames : UInt,
) -> Unit {
  let cutoff : Float = 70.0 / 44100.0
  let k : Float = cutoff / (cutoff + (0.1591549431 : Float))
  for i = 0U; i < frames * 2U; i = i + 2U {
    let l = @raylib.audio_buffer_get_sample(buffer, i)
    let r = @raylib.audio_buffer_get_sample(buffer, i + 1U)
    low[0] += k * (l - low[0])
    low[1] += k * (r - low[1])
    @raylib.audio_buffer_set_sample(buffer, i, low[0])
    @raylib.audio_buffer_set_sample(buffer, i + 1U, low[1])
  }
}

///|
let audio_process_effect_lpf : FuncRef[(@raylib.AudioBuffer, UInt) -> Unit] = (
  buffer,
  frames,
) => audio_process_effect_lpf_impl(buffer, frames)

///|
fn audio_process_effect_delay_impl(
  buffer : @raylib.AudioBuffer,
  frames : UInt,
) -> Unit {
  for i = 0U; i < frames * 2U; i = i + 2U {
    let left_delay = delay_buffer[delay_read_index[0]]
    delay_read_index[0] += 1
    let right_delay = delay_buffer[delay_read_index[0]]
    delay_read_index[0] += 1
    if delay_read_index[0] == DelayBufferSize {
      delay_read_index[0] = 0
    }
    let left_sample = @raylib.audio_buffer_get_sample(buffer, i)
    let right_sample = @raylib.audio_buffer_get_sample(buffer, i + 1U)
    let new_left : Float = (0.5 : Float) * left_sample +
      (0.5 : Float) * left_delay
    let new_right : Float = (0.5 : Float) * right_sample +
      (0.5 : Float) * right_delay
    @raylib.audio_buffer_set_sample(buffer, i, new_left)
    @raylib.audio_buffer_set_sample(buffer, i + 1U, new_right)
    delay_buffer[delay_write_index[0]] = new_left
    delay_write_index[0] += 1
    delay_buffer[delay_write_index[0]] = new_right
    delay_write_index[0] += 1
    if delay_write_index[0] == DelayBufferSize {
      delay_write_index[0] = 0
    }
  }
}

///|
let audio_process_effect_delay : FuncRef[(@raylib.AudioBuffer, UInt) -> Unit] = (
  buffer,
  frames,
) => audio_process_effect_delay_impl(buffer, frames)

///|
fn main {
  let screen_width = 800
  let screen_height = 450
  @raylib.init_window(
    screen_width, screen_height, "raylib [audio] example - stream effects",
  )
  @raylib.init_audio_device()
  let music = @raylib.load_music_stream("resources/country.mp3")
  @raylib.play_music_stream(music)
  let mut pause = false
  let mut enable_effect_lpf = false
  let mut enable_effect_delay = false
  @raylib.set_target_fps(60)
  while not(@raylib.window_should_close()) {
    @raylib.update_music_stream(music)
    // Restart music
    if @raylib.is_key_pressed(@raylib.KeySpace) {
      @raylib.stop_music_stream(music)
      @raylib.play_music_stream(music)
    }
    // Pause/Resume
    if @raylib.is_key_pressed(@raylib.KeyP) {
      pause = not(pause)
      if pause {
        @raylib.pause_music_stream(music)
      } else {
        @raylib.resume_music_stream(music)
      }
    }
    // Toggle LPF effect
    if @raylib.is_key_pressed(@raylib.KeyF) {
      enable_effect_lpf = not(enable_effect_lpf)
      if enable_effect_lpf {
        @raylib.attach_music_stream_processor(music, audio_process_effect_lpf)
      } else {
        @raylib.detach_music_stream_processor(music, audio_process_effect_lpf)
      }
    }
    // Toggle delay effect
    if @raylib.is_key_pressed(@raylib.KeyD) {
      enable_effect_delay = not(enable_effect_delay)
      if enable_effect_delay {
        @raylib.attach_music_stream_processor(music, audio_process_effect_delay)
      } else {
        @raylib.detach_music_stream_processor(music, audio_process_effect_delay)
      }
    }
    // Get normalized time played
    let mut time_played = @raylib.get_music_time_played(music) /
      @raylib.get_music_time_length(music)
    if time_played > 1.0 {
      time_played = 1.0
    }
    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)
    @raylib.draw_text(
      "MUSIC SHOULD BE PLAYING!", 245, 150, 20, @raylib.lightgray,
    )
    @raylib.draw_rectangle(200, 180, 400, 12, @raylib.lightgray)
    @raylib.draw_rectangle(
      200,
      180,
      (time_played * 400.0).to_int(),
      12,
      @raylib.maroon,
    )
    @raylib.draw_rectangle_lines(200, 180, 400, 12, @raylib.gray)
    @raylib.draw_text(
      "PRESS SPACE TO RESTART MUSIC", 215, 230, 20, @raylib.lightgray,
    )
    @raylib.draw_text(
      "PRESS P TO PAUSE/RESUME MUSIC", 208, 260, 20, @raylib.lightgray,
    )
    let lpf_status = if enable_effect_lpf { "ON" } else { "OFF" }
    @raylib.draw_text(
      "PRESS F TO TOGGLE LPF EFFECT: \{lpf_status}",
      200,
      320,
      20,
      @raylib.gray,
    )
    let delay_status = if enable_effect_delay { "ON" } else { "OFF" }
    @raylib.draw_text(
      "PRESS D TO TOGGLE DELAY EFFECT: \{delay_status}",
      180,
      350,
      20,
      @raylib.gray,
    )
    @raylib.end_drawing()
  }
  @raylib.unload_music_stream(music)
  @raylib.close_audio_device()
  @raylib.close_window()
}
