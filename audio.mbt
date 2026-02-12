// ============================================================================
// Audio device management
// ============================================================================

extern "c" fn init_audio_device_ffi() = "InitAudioDevice"

pub fn init_audio_device() -> Unit {
  init_audio_device_ffi()
}

extern "c" fn close_audio_device_ffi() = "CloseAudioDevice"

pub fn close_audio_device() -> Unit {
  close_audio_device_ffi()
}

extern "c" fn is_audio_device_ready_ffi() -> Bool = "IsAudioDeviceReady"

pub fn is_audio_device_ready() -> Bool {
  is_audio_device_ready_ffi()
}

extern "c" fn set_master_volume_ffi(volume : Float) = "SetMasterVolume"

pub fn set_master_volume(volume : Float) -> Unit {
  set_master_volume_ffi(volume)
}

extern "c" fn get_master_volume_ffi() -> Float = "GetMasterVolume"

pub fn get_master_volume() -> Float {
  get_master_volume_ffi()
}

// ============================================================================
// Sound loading/playing
// ============================================================================

#borrow(file_name)
extern "c" fn load_sound_ffi(file_name : Bytes) -> Sound = "moonbit_LoadSound"

pub fn load_sound(file_name : String) -> Sound {
  load_sound_ffi(@utf8.encode(file_name))
}

#borrow(sound)
extern "c" fn unload_sound_ffi(sound : Sound) = "moonbit_UnloadSound"

pub fn unload_sound(sound : Sound) -> Unit {
  unload_sound_ffi(sound)
}

#borrow(sound)
extern "c" fn play_sound_ffi(sound : Sound) = "moonbit_PlaySound"

pub fn play_sound(sound : Sound) -> Unit {
  play_sound_ffi(sound)
}

#borrow(sound)
extern "c" fn stop_sound_ffi(sound : Sound) = "moonbit_StopSound"

pub fn stop_sound(sound : Sound) -> Unit {
  stop_sound_ffi(sound)
}

#borrow(sound)
extern "c" fn pause_sound_ffi(sound : Sound) = "moonbit_PauseSound"

pub fn pause_sound(sound : Sound) -> Unit {
  pause_sound_ffi(sound)
}

#borrow(sound)
extern "c" fn resume_sound_ffi(sound : Sound) = "moonbit_ResumeSound"

pub fn resume_sound(sound : Sound) -> Unit {
  resume_sound_ffi(sound)
}

#borrow(sound)
extern "c" fn is_sound_playing_ffi(sound : Sound) -> Bool = "moonbit_IsSoundPlaying"

pub fn is_sound_playing(sound : Sound) -> Bool {
  is_sound_playing_ffi(sound)
}

#borrow(sound)
extern "c" fn set_sound_volume_ffi(sound : Sound, volume : Float) = "moonbit_SetSoundVolume"

pub fn set_sound_volume(sound : Sound, volume : Float) -> Unit {
  set_sound_volume_ffi(sound, volume)
}

#borrow(sound)
extern "c" fn set_sound_pitch_ffi(sound : Sound, pitch : Float) = "moonbit_SetSoundPitch"

pub fn set_sound_pitch(sound : Sound, pitch : Float) -> Unit {
  set_sound_pitch_ffi(sound, pitch)
}

#borrow(sound)
extern "c" fn set_sound_pan_ffi(sound : Sound, pan : Float) = "moonbit_SetSoundPan"

pub fn set_sound_pan(sound : Sound, pan : Float) -> Unit {
  set_sound_pan_ffi(sound, pan)
}

// ============================================================================
// Music stream
// ============================================================================

#borrow(file_name)
extern "c" fn load_music_stream_ffi(file_name : Bytes) -> Music = "moonbit_LoadMusicStream"

pub fn load_music_stream(file_name : String) -> Music {
  load_music_stream_ffi(@utf8.encode(file_name))
}

#borrow(music)
extern "c" fn unload_music_stream_ffi(music : Music) = "moonbit_UnloadMusicStream"

pub fn unload_music_stream(music : Music) -> Unit {
  unload_music_stream_ffi(music)
}

#borrow(music)
extern "c" fn play_music_stream_ffi(music : Music) = "moonbit_PlayMusicStream"

pub fn play_music_stream(music : Music) -> Unit {
  play_music_stream_ffi(music)
}

#borrow(music)
extern "c" fn stop_music_stream_ffi(music : Music) = "moonbit_StopMusicStream"

pub fn stop_music_stream(music : Music) -> Unit {
  stop_music_stream_ffi(music)
}

#borrow(music)
extern "c" fn pause_music_stream_ffi(music : Music) = "moonbit_PauseMusicStream"

pub fn pause_music_stream(music : Music) -> Unit {
  pause_music_stream_ffi(music)
}

#borrow(music)
extern "c" fn resume_music_stream_ffi(music : Music) = "moonbit_ResumeMusicStream"

pub fn resume_music_stream(music : Music) -> Unit {
  resume_music_stream_ffi(music)
}

#borrow(music)
extern "c" fn update_music_stream_ffi(music : Music) = "moonbit_UpdateMusicStream"

pub fn update_music_stream(music : Music) -> Unit {
  update_music_stream_ffi(music)
}

#borrow(music)
extern "c" fn is_music_stream_playing_ffi(music : Music) -> Bool = "moonbit_IsMusicStreamPlaying"

pub fn is_music_stream_playing(music : Music) -> Bool {
  is_music_stream_playing_ffi(music)
}

#borrow(music)
extern "c" fn set_music_volume_ffi(music : Music, volume : Float) = "moonbit_SetMusicVolume"

pub fn set_music_volume(music : Music, volume : Float) -> Unit {
  set_music_volume_ffi(music, volume)
}

#borrow(music)
extern "c" fn set_music_pitch_ffi(music : Music, pitch : Float) = "moonbit_SetMusicPitch"

pub fn set_music_pitch(music : Music, pitch : Float) -> Unit {
  set_music_pitch_ffi(music, pitch)
}

#borrow(music)
extern "c" fn seek_music_stream_ffi(music : Music, position : Float) = "moonbit_SeekMusicStream"

pub fn seek_music_stream(music : Music, position : Float) -> Unit {
  seek_music_stream_ffi(music, position)
}

#borrow(music)
extern "c" fn get_music_time_length_ffi(music : Music) -> Float = "moonbit_GetMusicTimeLength"

pub fn get_music_time_length(music : Music) -> Float {
  get_music_time_length_ffi(music)
}

#borrow(music)
extern "c" fn get_music_time_played_ffi(music : Music) -> Float = "moonbit_GetMusicTimePlayed"

pub fn get_music_time_played(music : Music) -> Float {
  get_music_time_played_ffi(music)
}
