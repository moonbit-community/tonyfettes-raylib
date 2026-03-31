// Tests for raylib audio bindings - exercises audio device lifecycle and
// master volume control. Sound/music loading and playback functions are
// not tested here because they require audio asset files.

///|
test "audio device ready before init" {
  assert_eq(@raylib.is_audio_device_ready(), false)
}

///|
test "audio device init/close lifecycle" {
  @raylib.init_audio_device()
  // Audio device may not be available in CI (no sound card); skip assertions
  // but still exercise init/close to verify they don't crash.
  if @raylib.is_audio_device_ready() {
    @raylib.close_audio_device()
    assert_eq(@raylib.is_audio_device_ready(), false)
  } else {
    @raylib.close_audio_device()
  }
}

///|
test "master volume set/get round-trip" {
  @raylib.init_audio_device()
  if @raylib.is_audio_device_ready() {
    @raylib.set_master_volume(0.75)
    let vol = @raylib.get_master_volume()
    assert_true(vol > 0.7 && vol < 0.8)
  }
  @raylib.close_audio_device()
}

///|
test "master volume boundary: 0.0" {
  @raylib.init_audio_device()
  if @raylib.is_audio_device_ready() {
    @raylib.set_master_volume(0.0)
    let vol = @raylib.get_master_volume()
    assert_true(vol < 0.01)
  }
  @raylib.close_audio_device()
}

///|
test "master volume boundary: 1.0" {
  @raylib.init_audio_device()
  if @raylib.is_audio_device_ready() {
    @raylib.set_master_volume(1.0)
    let vol = @raylib.get_master_volume()
    assert_true(vol > 0.99)
  }
  @raylib.close_audio_device()
}

///|
/// Write an ASCII string as raw bytes (1 byte per char) into a buffer.
fn write_ascii(buf : @buffer.Buffer, s : String) -> Unit {
  buf.write_string_utf8(s[:])
}

///|
/// Build a minimal 16-bit mono PCM WAV file in memory.
/// Returns the raw bytes of a valid .wav file with the given number of silent
/// samples at 44100 Hz.
fn build_wav_bytes(num_samples : Int) -> Bytes {
  let data_size = num_samples * 2 // 16-bit = 2 bytes per sample
  let file_size = 36 + data_size // total file size minus 8-byte RIFF header
  let buf = @buffer.new()
  // --- RIFF header (12 bytes) ---
  write_ascii(buf, "RIFF")
  buf.write_int_le(file_size)
  write_ascii(buf, "WAVE")
  // --- fmt sub-chunk (24 bytes) ---
  write_ascii(buf, "fmt ")
  buf.write_int_le(16) // sub-chunk size
  let pcm : UInt16 = 1
  buf.write_uint16_le(pcm) // audio format: PCM
  let mono : UInt16 = 1
  buf.write_uint16_le(mono) // channels: 1
  buf.write_int_le(44100) // sample rate
  buf.write_int_le(44100 * 2) // byte rate (sample_rate * channels * bytes_per_sample)
  let block_align : UInt16 = 2
  buf.write_uint16_le(block_align) // block align (channels * bytes_per_sample)
  let bits : UInt16 = 16
  buf.write_uint16_le(bits) // bits per sample
  // --- data sub-chunk (8 + data bytes) ---
  write_ascii(buf, "data")
  buf.write_int_le(data_size)
  // Write silent samples (all zeros)
  for i = 0; i < num_samples; i = i + 1 {
    buf.write_byte(b'\x00')
    buf.write_byte(b'\x00')
  }
  buf.to_bytes()
}

///|
test "Wave::load_from_memory and basic accessors" {
  @raylib.init_audio_device()
  if !@raylib.is_audio_device_ready() {
    @raylib.close_audio_device()
    return
  }
  let wav_bytes = build_wav_bytes(100)
  let wave = @raylib.Wave::load_from_memory(
    ".wav",
    wav_bytes,
    wav_bytes.length(),
  )
  assert_true(wave.is_valid())
  assert_eq(wave.frame_count(), 100)
  assert_eq(wave.sample_rate(), 44100)
  assert_eq(wave.sample_size(), 16)
  assert_eq(wave.channels(), 1)
  wave.unload()
  @raylib.close_audio_device()
}

///|
test "Wave::copy produces independent copy" {
  @raylib.init_audio_device()
  if !@raylib.is_audio_device_ready() {
    @raylib.close_audio_device()
    return
  }
  let wav_bytes = build_wav_bytes(100)
  let wave = @raylib.Wave::load_from_memory(
    ".wav",
    wav_bytes,
    wav_bytes.length(),
  )
  let copy = wave.copy()
  assert_true(copy.is_valid())
  assert_eq(copy.frame_count(), 100)
  assert_eq(copy.sample_rate(), 44100)
  assert_eq(copy.channels(), 1)
  copy.unload()
  wave.unload()
  @raylib.close_audio_device()
}

///|
test "Wave::crop trims frame count" {
  @raylib.init_audio_device()
  if !@raylib.is_audio_device_ready() {
    @raylib.close_audio_device()
    return
  }
  let wav_bytes = build_wav_bytes(100)
  let wave = @raylib.Wave::load_from_memory(
    ".wav",
    wav_bytes,
    wav_bytes.length(),
  )
  // Crop to frames [10, 60) -> finalFrame - initFrame = 50 frames
  wave.crop(10, 60)
  assert_eq(wave.frame_count(), 50)
  assert_true(wave.is_valid())
  wave.unload()
  @raylib.close_audio_device()
}

///|
test "Wave::format converts sample format" {
  @raylib.init_audio_device()
  if !@raylib.is_audio_device_ready() {
    @raylib.close_audio_device()
    return
  }
  let wav_bytes = build_wav_bytes(100)
  let wave = @raylib.Wave::load_from_memory(
    ".wav",
    wav_bytes,
    wav_bytes.length(),
  )
  // Convert from 16-bit mono 44100 to 32-bit mono 22050
  wave.format(22050, 32, 1)
  assert_eq(wave.sample_size(), 32)
  assert_eq(wave.sample_rate(), 22050)
  assert_eq(wave.channels(), 1)
  assert_true(wave.is_valid())
  wave.unload()
  @raylib.close_audio_device()
}

///|
test "Wave::load_samples returns float array" {
  @raylib.init_audio_device()
  if !@raylib.is_audio_device_ready() {
    @raylib.close_audio_device()
    return
  }
  let wav_bytes = build_wav_bytes(100)
  let wave = @raylib.Wave::load_from_memory(
    ".wav",
    wav_bytes,
    wav_bytes.length(),
  )
  let samples = wave.load_samples()
  // 100 frames * 1 channel = 100 samples
  assert_eq(samples.length(), 100)
  // All samples should be zero (silent WAV)
  for i = 0; i < samples.length(); i = i + 1 {
    assert_true(samples[i] < 0.001 && samples[i] > -0.001)
  }
  samples.unload()
  wave.unload()
  @raylib.close_audio_device()
}

///|
test "Wave::data returns Short variant for 16-bit wave" {
  @raylib.init_audio_device()
  if !@raylib.is_audio_device_ready() {
    @raylib.close_audio_device()
    return
  }
  let wav_bytes = build_wav_bytes(100)
  let wave = @raylib.Wave::load_from_memory(
    ".wav",
    wav_bytes,
    wav_bytes.length(),
  )
  match wave.data() {
    Short(arr) => {
      assert_eq(arr.length(), 100) // 100 frames * 1 channel
      // All values should be zero (silent)
      assert_eq(arr[0], 0)
      assert_eq(arr[99], 0)
    }
    _ => fail("expected Short variant for 16-bit wave")
  }
  wave.unload()
  @raylib.close_audio_device()
}

///|
test "Wave::data returns Float variant for 32-bit wave" {
  @raylib.init_audio_device()
  if !@raylib.is_audio_device_ready() {
    @raylib.close_audio_device()
    return
  }
  let wav_bytes = build_wav_bytes(100)
  let wave = @raylib.Wave::load_from_memory(
    ".wav",
    wav_bytes,
    wav_bytes.length(),
  )
  // Convert to 32-bit float
  wave.format(44100, 32, 1)
  match wave.data() {
    Float(arr) => {
      assert_eq(arr.length(), 100)
      // Silent samples should be near zero
      assert_true(arr[0] < 0.001 && arr[0] > -0.001)
    }
    _ => fail("expected Float variant for 32-bit wave")
  }
  wave.unload()
  @raylib.close_audio_device()
}

///|
test "Wave::data returns UByte variant for 8-bit wave" {
  @raylib.init_audio_device()
  if !@raylib.is_audio_device_ready() {
    @raylib.close_audio_device()
    return
  }
  let wav_bytes = build_wav_bytes(100)
  let wave = @raylib.Wave::load_from_memory(
    ".wav",
    wav_bytes,
    wav_bytes.length(),
  )
  // Convert to 8-bit
  wave.format(44100, 8, 1)
  match wave.data() {
    UByte(arr) => {
      assert_eq(arr.length(), 100)
      // 8-bit PCM uses 128 as the zero point (unsigned)
      assert_eq(arr[0], 128)
    }
    _ => fail("expected UByte variant for 8-bit wave")
  }
  wave.unload()
  @raylib.close_audio_device()
}

///|
test "Wave::load_sound and Sound operations" {
  @raylib.init_audio_device()
  if !@raylib.is_audio_device_ready() {
    @raylib.close_audio_device()
    return
  }
  let wav_bytes = build_wav_bytes(100)
  let wave = @raylib.Wave::load_from_memory(
    ".wav",
    wav_bytes,
    wav_bytes.length(),
  )
  let sound = wave.load_sound()
  assert_true(sound.is_valid())
  // Exercise sound parameter setters (no crash = pass)
  sound.set_volume(0.5)
  sound.set_pitch(1.5)
  sound.set_pan(0.3)
  sound.unload()
  wave.unload()
  @raylib.close_audio_device()
}
