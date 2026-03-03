// Tests for raylib audio bindings - exercises audio device lifecycle and
// master volume control. Sound/music loading and playback functions are
// not tested here because they require audio asset files.

///|
test "audio device ready before init" {
  assert_eq(is_audio_device_ready(), false)
}

///|
test "audio device init/close lifecycle" {
  init_audio_device()
  // Audio device may not be available in CI (no sound card); skip assertions
  // but still exercise init/close to verify they don't crash.
  if is_audio_device_ready() {
    close_audio_device()
    assert_eq(is_audio_device_ready(), false)
  } else {
    close_audio_device()
  }
}

///|
test "master volume set/get round-trip" {
  init_audio_device()
  if is_audio_device_ready() {
    set_master_volume(0.75)
    let vol = get_master_volume()
    assert_true(vol > 0.7 && vol < 0.8)
  }
  close_audio_device()
}

///|
test "master volume boundary: 0.0" {
  init_audio_device()
  if is_audio_device_ready() {
    set_master_volume(0.0)
    let vol = get_master_volume()
    assert_true(vol < 0.01)
  }
  close_audio_device()
}

///|
test "master volume boundary: 1.0" {
  init_audio_device()
  if is_audio_device_ready() {
    set_master_volume(1.0)
    let vol = get_master_volume()
    assert_true(vol > 0.99)
  }
  close_audio_device()
}
