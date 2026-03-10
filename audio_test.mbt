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
