// Re-export passthrough functions from internal FFI layer
///|
pub using @raylib {
  type Sound,
  type Music,
  // Audio device
  init_audio_device,
  close_audio_device,
  is_audio_device_ready,
  set_master_volume,
  get_master_volume,
  // Sound
  unload_sound,
  play_sound,
  stop_sound,
  pause_sound,
  resume_sound,
  is_sound_playing,
  set_sound_volume,
  set_sound_pitch,
  set_sound_pan,
  // Music
  unload_music_stream,
  play_music_stream,
  stop_music_stream,
  pause_music_stream,
  resume_music_stream,
  update_music_stream,
  is_music_stream_playing,
  set_music_volume,
  set_music_pitch,
  seek_music_stream,
  get_music_time_length,
  get_music_time_played,
}

// ============================================================================
// Sound loading (wrappers)
// ============================================================================

///|
pub fn load_sound(file_name : String) -> Sound {
  @raylib.load_sound(@utf8.encode(file_name))
}

// ============================================================================
// Music stream (wrappers)
// ============================================================================

///|
pub fn load_music_stream(file_name : String) -> Music {
  @raylib.load_music_stream(@utf8.encode(file_name))
}
