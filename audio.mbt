// ============================================================================
// Audio device management
// ============================================================================

///|
extern "c" fn init_audio_device_ffi() = "InitAudioDevice"

///|
pub fn init_audio_device() -> Unit {
  init_audio_device_ffi()
}

///|
extern "c" fn close_audio_device_ffi() = "CloseAudioDevice"

///|
pub fn close_audio_device() -> Unit {
  close_audio_device_ffi()
}

///|
extern "c" fn is_audio_device_ready_ffi() -> Bool = "IsAudioDeviceReady"

///|
pub fn is_audio_device_ready() -> Bool {
  is_audio_device_ready_ffi()
}

///|
extern "c" fn set_master_volume_ffi(volume : Float) = "SetMasterVolume"

///|
pub fn set_master_volume(volume : Float) -> Unit {
  set_master_volume_ffi(volume)
}

///|
extern "c" fn get_master_volume_ffi() -> Float = "GetMasterVolume"

///|
pub fn get_master_volume() -> Float {
  get_master_volume_ffi()
}

// ============================================================================
// Sound loading/playing
// ============================================================================

///|
#borrow(file_name)
extern "c" fn load_sound_ffi(file_name : Bytes) -> Sound = "moonbit_raylib_load_sound"

///|
pub fn load_sound(file_name : String) -> Sound {
  load_sound_ffi(@utf8.encode(file_name))
}

///|
#borrow(sound)
extern "c" fn unload_sound_ffi(sound : Sound) = "moonbit_raylib_unload_sound"

///|
pub fn unload_sound(sound : Sound) -> Unit {
  unload_sound_ffi(sound)
}

///|
#borrow(sound)
extern "c" fn play_sound_ffi(sound : Sound) = "moonbit_raylib_play_sound"

///|
pub fn play_sound(sound : Sound) -> Unit {
  play_sound_ffi(sound)
}

///|
#borrow(sound)
extern "c" fn stop_sound_ffi(sound : Sound) = "moonbit_raylib_stop_sound"

///|
pub fn stop_sound(sound : Sound) -> Unit {
  stop_sound_ffi(sound)
}

///|
#borrow(sound)
extern "c" fn pause_sound_ffi(sound : Sound) = "moonbit_raylib_pause_sound"

///|
pub fn pause_sound(sound : Sound) -> Unit {
  pause_sound_ffi(sound)
}

///|
#borrow(sound)
extern "c" fn resume_sound_ffi(sound : Sound) = "moonbit_raylib_resume_sound"

///|
pub fn resume_sound(sound : Sound) -> Unit {
  resume_sound_ffi(sound)
}

///|
#borrow(sound)
extern "c" fn is_sound_playing_ffi(sound : Sound) -> Bool = "moonbit_raylib_is_sound_playing"

///|
pub fn is_sound_playing(sound : Sound) -> Bool {
  is_sound_playing_ffi(sound)
}

///|
#borrow(sound)
extern "c" fn set_sound_volume_ffi(sound : Sound, volume : Float) = "moonbit_raylib_set_sound_volume"

///|
pub fn set_sound_volume(sound : Sound, volume : Float) -> Unit {
  set_sound_volume_ffi(sound, volume)
}

///|
#borrow(sound)
extern "c" fn set_sound_pitch_ffi(sound : Sound, pitch : Float) = "moonbit_raylib_set_sound_pitch"

///|
pub fn set_sound_pitch(sound : Sound, pitch : Float) -> Unit {
  set_sound_pitch_ffi(sound, pitch)
}

///|
#borrow(sound)
extern "c" fn set_sound_pan_ffi(sound : Sound, pan : Float) = "moonbit_raylib_set_sound_pan"

///|
pub fn set_sound_pan(sound : Sound, pan : Float) -> Unit {
  set_sound_pan_ffi(sound, pan)
}

// ============================================================================
// Music stream
// ============================================================================

///|
#borrow(file_name)
extern "c" fn load_music_stream_ffi(file_name : Bytes) -> Music = "moonbit_raylib_load_music_stream"

///|
pub fn load_music_stream(file_name : String) -> Music {
  load_music_stream_ffi(@utf8.encode(file_name))
}

///|
#borrow(music)
extern "c" fn unload_music_stream_ffi(music : Music) = "moonbit_raylib_unload_music_stream"

///|
pub fn unload_music_stream(music : Music) -> Unit {
  unload_music_stream_ffi(music)
}

///|
#borrow(music)
extern "c" fn play_music_stream_ffi(music : Music) = "moonbit_raylib_play_music_stream"

///|
pub fn play_music_stream(music : Music) -> Unit {
  play_music_stream_ffi(music)
}

///|
#borrow(music)
extern "c" fn stop_music_stream_ffi(music : Music) = "moonbit_raylib_stop_music_stream"

///|
pub fn stop_music_stream(music : Music) -> Unit {
  stop_music_stream_ffi(music)
}

///|
#borrow(music)
extern "c" fn pause_music_stream_ffi(music : Music) = "moonbit_raylib_pause_music_stream"

///|
pub fn pause_music_stream(music : Music) -> Unit {
  pause_music_stream_ffi(music)
}

///|
#borrow(music)
extern "c" fn resume_music_stream_ffi(music : Music) = "moonbit_raylib_resume_music_stream"

///|
pub fn resume_music_stream(music : Music) -> Unit {
  resume_music_stream_ffi(music)
}

///|
#borrow(music)
extern "c" fn update_music_stream_ffi(music : Music) = "moonbit_raylib_update_music_stream"

///|
pub fn update_music_stream(music : Music) -> Unit {
  update_music_stream_ffi(music)
}

///|
#borrow(music)
extern "c" fn is_music_stream_playing_ffi(music : Music) -> Bool = "moonbit_raylib_is_music_stream_playing"

///|
pub fn is_music_stream_playing(music : Music) -> Bool {
  is_music_stream_playing_ffi(music)
}

///|
#borrow(music)
extern "c" fn set_music_volume_ffi(music : Music, volume : Float) = "moonbit_raylib_set_music_volume"

///|
pub fn set_music_volume(music : Music, volume : Float) -> Unit {
  set_music_volume_ffi(music, volume)
}

///|
#borrow(music)
extern "c" fn set_music_pitch_ffi(music : Music, pitch : Float) = "moonbit_raylib_set_music_pitch"

///|
pub fn set_music_pitch(music : Music, pitch : Float) -> Unit {
  set_music_pitch_ffi(music, pitch)
}

///|
#borrow(music)
extern "c" fn seek_music_stream_ffi(music : Music, position : Float) = "moonbit_raylib_seek_music_stream"

///|
pub fn seek_music_stream(music : Music, position : Float) -> Unit {
  seek_music_stream_ffi(music, position)
}

///|
#borrow(music)
extern "c" fn get_music_time_length_ffi(music : Music) -> Float = "moonbit_raylib_get_music_time_length"

///|
pub fn get_music_time_length(music : Music) -> Float {
  get_music_time_length_ffi(music)
}

///|
#borrow(music)
extern "c" fn get_music_time_played_ffi(music : Music) -> Float = "moonbit_raylib_get_music_time_played"

///|
pub fn get_music_time_played(music : Music) -> Float {
  get_music_time_played_ffi(music)
}
