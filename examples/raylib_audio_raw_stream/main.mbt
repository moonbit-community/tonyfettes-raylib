///|
let pi : Float = 3.14159265358979323846

///|
fn main {
  let screen_width = 800
  let screen_height = 450
  let max_samples = 512
  let max_samples_per_update = 4096

  @raylib.init_window(
    screen_width, screen_height, "raylib [audio] example - raw audio streaming",
  )
  @raylib.init_audio_device()

  @raylib.set_audio_stream_buffer_size_default(max_samples_per_update)

  // Init raw audio stream (sample rate: 44100, sample size: 16bit-short, channels: 1-mono)
  let stream = @raylib.load_audio_stream(44100U, 16U, 1U)

  // Buffer for the single cycle waveform we are synthesizing
  let data : Array[Int] = Array::make(max_samples, 0)

  // Frame buffer for writing to the audio stream
  let write_buf : FixedArray[Byte] = FixedArray::make(
    max_samples_per_update * 2,
    b'\x00',
  )

  @raylib.play_audio_stream(stream)

  let mut frequency : Float = 440.0
  let mut old_frequency : Float = 1.0
  let mut read_cursor = 0
  let mut wave_length = 1

  @raylib.set_target_fps(30)

  while not(@raylib.window_should_close()) {
    // Sample mouse input
    let mouse_pos = @raylib.get_mouse_position()

    if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
      frequency = 40.0 + mouse_pos.y
      let pan = mouse_pos.x / Float::from_int(screen_width)
      @raylib.set_audio_stream_pan(stream, pan)
    }

    // Rewrite the sine wave when frequency changes
    if frequency != old_frequency {
      let rate : Float = 22050.0
      wave_length = (rate / frequency).to_int()
      if wave_length > max_samples / 2 {
        wave_length = max_samples / 2
      }
      if wave_length < 1 {
        wave_length = 1
      }

      // Write sine wave (two cycles)
      for i = 0; i < wave_length * 2; i = i + 1 {
        let sample = @math.sinf(
            2.0 * pi * Float::from_int(i) / Float::from_int(wave_length),
          ) *
          32000.0
        data[i] = sample.to_int()
      }
      // Clear rest of buffer
      for j = wave_length * 2; j < max_samples; j = j + 1 {
        data[j] = 0
      }

      // Reset read cursor to minimize transition artifacts
      read_cursor = 0
      old_frequency = frequency
    }

    // Refill audio stream if required (polling approach)
    if @raylib.is_audio_stream_processed(stream) {
      let mut write_cursor = 0
      while write_cursor < max_samples_per_update {
        let mut write_length = max_samples_per_update - write_cursor
        let read_length = wave_length - read_cursor
        if write_length > read_length {
          write_length = read_length
        }

        // Write the slice (16-bit signed samples, little-endian)
        for i = 0; i < write_length; i = i + 1 {
          let sample = data[read_cursor + i]
          write_buf[(write_cursor + i) * 2] = (sample & 0xFF).to_byte()
          write_buf[(write_cursor + i) * 2 + 1] = ((sample >> 8) & 0xFF).to_byte()
        }

        read_cursor = (read_cursor + write_length) % wave_length
        write_cursor += write_length
      }

      // Convert to Bytes and update stream
      let audio_bytes = FixedArray::unsafe_reinterpret_as_bytes(write_buf)
      @raylib.update_audio_stream(stream, audio_bytes, max_samples_per_update)
    }

    // Draw
    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.raywhite)

    @raylib.draw_text(
      "sine frequency: \{frequency.to_int()}",
      screen_width - 220,
      10,
      20,
      @raylib.red,
    )
    @raylib.draw_text(
      "click mouse button to change frequency or pan", 10, 10, 20, @raylib.darkgray,
    )

    // Draw the current buffer state proportionate to the screen
    for i = 0; i < screen_width; i = i + 1 {
      let pos_x = Float::from_int(i)
      let sample_index = i * max_samples / screen_width
      let pos_y : Float = 250.0 +
        50.0 * Float::from_int(data[sample_index]) / 32000.0
      @raylib.draw_pixel_v(@raylib.Vector2::new(pos_x, pos_y), @raylib.red)
    }

    @raylib.end_drawing()
  }

  @raylib.unload_audio_stream(stream)
  @raylib.close_audio_device()
  @raylib.close_window()
}
