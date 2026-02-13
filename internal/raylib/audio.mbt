// ============================================================================
// Audio device management
// ============================================================================

///|
pub extern "c" fn init_audio_device() = "InitAudioDevice"

///|
pub extern "c" fn close_audio_device() = "CloseAudioDevice"

///|
pub extern "c" fn is_audio_device_ready() -> Bool = "IsAudioDeviceReady"

///|
pub extern "c" fn set_master_volume(volume : Float) = "SetMasterVolume"

///|
pub extern "c" fn get_master_volume() -> Float = "GetMasterVolume"

// ============================================================================
// Sound loading/playing
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_sound(file_name : Bytes) -> Sound = "moonbit_raylib_load_sound"

///|
#borrow(sound)
pub extern "c" fn unload_sound(sound : Sound) = "moonbit_raylib_unload_sound"

///|
#borrow(sound)
pub extern "c" fn play_sound(sound : Sound) = "moonbit_raylib_play_sound"

///|
#borrow(sound)
pub extern "c" fn stop_sound(sound : Sound) = "moonbit_raylib_stop_sound"

///|
#borrow(sound)
pub extern "c" fn pause_sound(sound : Sound) = "moonbit_raylib_pause_sound"

///|
#borrow(sound)
pub extern "c" fn resume_sound(sound : Sound) = "moonbit_raylib_resume_sound"

///|
#borrow(sound)
pub extern "c" fn is_sound_playing(sound : Sound) -> Bool = "moonbit_raylib_is_sound_playing"

///|
#borrow(sound)
pub extern "c" fn set_sound_volume(sound : Sound, volume : Float) = "moonbit_raylib_set_sound_volume"

///|
#borrow(sound)
pub extern "c" fn set_sound_pitch(sound : Sound, pitch : Float) = "moonbit_raylib_set_sound_pitch"

///|
#borrow(sound)
pub extern "c" fn set_sound_pan(sound : Sound, pan : Float) = "moonbit_raylib_set_sound_pan"

// ============================================================================
// Music stream
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_music_stream(file_name : Bytes) -> Music = "moonbit_raylib_load_music_stream"

///|
#borrow(music)
pub extern "c" fn unload_music_stream(music : Music) = "moonbit_raylib_unload_music_stream"

///|
#borrow(music)
pub extern "c" fn play_music_stream(music : Music) = "moonbit_raylib_play_music_stream"

///|
#borrow(music)
pub extern "c" fn stop_music_stream(music : Music) = "moonbit_raylib_stop_music_stream"

///|
#borrow(music)
pub extern "c" fn pause_music_stream(music : Music) = "moonbit_raylib_pause_music_stream"

///|
#borrow(music)
pub extern "c" fn resume_music_stream(music : Music) = "moonbit_raylib_resume_music_stream"

///|
#borrow(music)
pub extern "c" fn update_music_stream(music : Music) = "moonbit_raylib_update_music_stream"

///|
#borrow(music)
pub extern "c" fn is_music_stream_playing(music : Music) -> Bool = "moonbit_raylib_is_music_stream_playing"

///|
#borrow(music)
pub extern "c" fn set_music_volume(music : Music, volume : Float) = "moonbit_raylib_set_music_volume"

///|
#borrow(music)
pub extern "c" fn set_music_pitch(music : Music, pitch : Float) = "moonbit_raylib_set_music_pitch"

///|
#borrow(music)
pub extern "c" fn seek_music_stream(music : Music, position : Float) = "moonbit_raylib_seek_music_stream"

///|
#borrow(music)
pub extern "c" fn get_music_time_length(music : Music) -> Float = "moonbit_raylib_get_music_time_length"

///|
#borrow(music)
pub extern "c" fn get_music_time_played(music : Music) -> Float = "moonbit_raylib_get_music_time_played"
