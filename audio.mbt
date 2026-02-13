// ============================================================================
// Audio device management
// ============================================================================

///|
extern "c" fn raylib_init_audio_device() = "InitAudioDevice"

///|
pub fn init_audio_device() -> Unit {
  raylib_init_audio_device()
}

///|
extern "c" fn raylib_close_audio_device() = "CloseAudioDevice"

///|
pub fn close_audio_device() -> Unit {
  raylib_close_audio_device()
}

///|
extern "c" fn raylib_is_audio_device_ready() -> Bool = "IsAudioDeviceReady"

///|
pub fn is_audio_device_ready() -> Bool {
  raylib_is_audio_device_ready()
}

///|
extern "c" fn raylib_set_master_volume(volume : Float) = "SetMasterVolume"

///|
pub fn set_master_volume(volume : Float) -> Unit {
  raylib_set_master_volume(volume)
}

///|
extern "c" fn raylib_get_master_volume() -> Float = "GetMasterVolume"

///|
pub fn get_master_volume() -> Float {
  raylib_get_master_volume()
}

// ============================================================================
// Sound loading/playing
// ============================================================================

///|
#borrow(file_name)
extern "c" fn raylib_load_sound(file_name : Bytes) -> Sound = "moonbit_raylib_load_sound"

///|
pub fn load_sound(file_name : String) -> Sound {
  raylib_load_sound(@utf8.encode(file_name))
}

///|
#borrow(sound)
extern "c" fn raylib_unload_sound(sound : Sound) = "moonbit_raylib_unload_sound"

///|
pub fn unload_sound(sound : Sound) -> Unit {
  raylib_unload_sound(sound)
}

///|
#borrow(sound)
extern "c" fn raylib_play_sound(sound : Sound) = "moonbit_raylib_play_sound"

///|
pub fn play_sound(sound : Sound) -> Unit {
  raylib_play_sound(sound)
}

///|
#borrow(sound)
extern "c" fn raylib_stop_sound(sound : Sound) = "moonbit_raylib_stop_sound"

///|
pub fn stop_sound(sound : Sound) -> Unit {
  raylib_stop_sound(sound)
}

///|
#borrow(sound)
extern "c" fn raylib_pause_sound(sound : Sound) = "moonbit_raylib_pause_sound"

///|
pub fn pause_sound(sound : Sound) -> Unit {
  raylib_pause_sound(sound)
}

///|
#borrow(sound)
extern "c" fn raylib_resume_sound(sound : Sound) = "moonbit_raylib_resume_sound"

///|
pub fn resume_sound(sound : Sound) -> Unit {
  raylib_resume_sound(sound)
}

///|
#borrow(sound)
extern "c" fn raylib_is_sound_playing(sound : Sound) -> Bool = "moonbit_raylib_is_sound_playing"

///|
pub fn is_sound_playing(sound : Sound) -> Bool {
  raylib_is_sound_playing(sound)
}

///|
#borrow(sound)
extern "c" fn raylib_set_sound_volume(sound : Sound, volume : Float) = "moonbit_raylib_set_sound_volume"

///|
pub fn set_sound_volume(sound : Sound, volume : Float) -> Unit {
  raylib_set_sound_volume(sound, volume)
}

///|
#borrow(sound)
extern "c" fn raylib_set_sound_pitch(sound : Sound, pitch : Float) = "moonbit_raylib_set_sound_pitch"

///|
pub fn set_sound_pitch(sound : Sound, pitch : Float) -> Unit {
  raylib_set_sound_pitch(sound, pitch)
}

///|
#borrow(sound)
extern "c" fn raylib_set_sound_pan(sound : Sound, pan : Float) = "moonbit_raylib_set_sound_pan"

///|
pub fn set_sound_pan(sound : Sound, pan : Float) -> Unit {
  raylib_set_sound_pan(sound, pan)
}

// ============================================================================
// Music stream
// ============================================================================

///|
#borrow(file_name)
extern "c" fn raylib_load_music_stream(file_name : Bytes) -> Music = "moonbit_raylib_load_music_stream"

///|
pub fn load_music_stream(file_name : String) -> Music {
  raylib_load_music_stream(@utf8.encode(file_name))
}

///|
#borrow(music)
extern "c" fn raylib_unload_music_stream(music : Music) = "moonbit_raylib_unload_music_stream"

///|
pub fn unload_music_stream(music : Music) -> Unit {
  raylib_unload_music_stream(music)
}

///|
#borrow(music)
extern "c" fn raylib_play_music_stream(music : Music) = "moonbit_raylib_play_music_stream"

///|
pub fn play_music_stream(music : Music) -> Unit {
  raylib_play_music_stream(music)
}

///|
#borrow(music)
extern "c" fn raylib_stop_music_stream(music : Music) = "moonbit_raylib_stop_music_stream"

///|
pub fn stop_music_stream(music : Music) -> Unit {
  raylib_stop_music_stream(music)
}

///|
#borrow(music)
extern "c" fn raylib_pause_music_stream(music : Music) = "moonbit_raylib_pause_music_stream"

///|
pub fn pause_music_stream(music : Music) -> Unit {
  raylib_pause_music_stream(music)
}

///|
#borrow(music)
extern "c" fn raylib_resume_music_stream(music : Music) = "moonbit_raylib_resume_music_stream"

///|
pub fn resume_music_stream(music : Music) -> Unit {
  raylib_resume_music_stream(music)
}

///|
#borrow(music)
extern "c" fn raylib_update_music_stream(music : Music) = "moonbit_raylib_update_music_stream"

///|
pub fn update_music_stream(music : Music) -> Unit {
  raylib_update_music_stream(music)
}

///|
#borrow(music)
extern "c" fn raylib_is_music_stream_playing(music : Music) -> Bool = "moonbit_raylib_is_music_stream_playing"

///|
pub fn is_music_stream_playing(music : Music) -> Bool {
  raylib_is_music_stream_playing(music)
}

///|
#borrow(music)
extern "c" fn raylib_set_music_volume(music : Music, volume : Float) = "moonbit_raylib_set_music_volume"

///|
pub fn set_music_volume(music : Music, volume : Float) -> Unit {
  raylib_set_music_volume(music, volume)
}

///|
#borrow(music)
extern "c" fn raylib_set_music_pitch(music : Music, pitch : Float) = "moonbit_raylib_set_music_pitch"

///|
pub fn set_music_pitch(music : Music, pitch : Float) -> Unit {
  raylib_set_music_pitch(music, pitch)
}

///|
#borrow(music)
extern "c" fn raylib_seek_music_stream(music : Music, position : Float) = "moonbit_raylib_seek_music_stream"

///|
pub fn seek_music_stream(music : Music, position : Float) -> Unit {
  raylib_seek_music_stream(music, position)
}

///|
#borrow(music)
extern "c" fn raylib_get_music_time_length(music : Music) -> Float = "moonbit_raylib_get_music_time_length"

///|
pub fn get_music_time_length(music : Music) -> Float {
  raylib_get_music_time_length(music)
}

///|
#borrow(music)
extern "c" fn raylib_get_music_time_played(music : Music) -> Float = "moonbit_raylib_get_music_time_played"

///|
pub fn get_music_time_played(music : Music) -> Float {
  raylib_get_music_time_played(music)
}
