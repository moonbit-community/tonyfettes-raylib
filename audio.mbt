// Re-export passthrough functions from internal FFI layer

///|
pub using @raylib {
  type Sound,
  type Music,
  type Wave,
  type AudioStream,
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
  is_sound_valid,
  load_sound_alias,
  unload_sound_alias,
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
  is_music_valid,
  set_music_volume,
  set_music_pitch,
  set_music_pan,
  seek_music_stream,
  get_music_time_length,
  get_music_time_played,
  // Wave
  is_wave_valid,
  load_sound_from_wave,
  unload_wave,
  wave_copy,
  wave_crop,
  wave_format,
  load_wave_samples,
  // AudioStream
  load_audio_stream,
  is_audio_stream_valid,
  unload_audio_stream,
  update_audio_stream,
  is_audio_stream_processed,
  play_audio_stream,
  pause_audio_stream,
  resume_audio_stream,
  is_audio_stream_playing,
  stop_audio_stream,
  set_audio_stream_volume,
  set_audio_stream_pitch,
  set_audio_stream_pan,
  set_audio_stream_buffer_size_default,
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

// ============================================================================
// Wave loading (wrappers)
// ============================================================================

///|
pub fn load_wave(file_name : String) -> Wave {
  @raylib.load_wave(@utf8.encode(file_name))
}

///|
pub fn load_wave_from_memory(
  file_type : String,
  file_data : Bytes,
  data_size : Int
) -> Wave {
  @raylib.load_wave_from_memory(@utf8.encode(file_type), file_data, data_size)
}

///|
pub fn export_wave(wave : Wave, file_name : String) -> Bool {
  @raylib.export_wave(wave, @utf8.encode(file_name))
}

///|
pub fn export_wave_as_code(wave : Wave, file_name : String) -> Bool {
  @raylib.export_wave_as_code(wave, @utf8.encode(file_name))
}

// ============================================================================
// Music stream from memory (wrappers)
// ============================================================================

///|
pub fn load_music_stream_from_memory(file_type : String, data : Bytes, data_size : Int) -> Music {
  @raylib.load_music_stream_from_memory(@utf8.encode(file_type), data, data_size)
}
