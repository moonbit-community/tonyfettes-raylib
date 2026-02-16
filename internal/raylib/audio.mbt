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

///|
#borrow(sound)
pub extern "c" fn is_sound_valid(sound : Sound) -> Bool = "moonbit_raylib_is_sound_valid"

///|
#borrow(source)
pub extern "c" fn load_sound_alias(source : Sound) -> Sound = "moonbit_raylib_load_sound_alias"

///|
#borrow(sound)
pub extern "c" fn unload_sound_alias(sound : Sound) = "moonbit_raylib_unload_sound_alias"

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

///|
#borrow(music)
pub extern "c" fn is_music_valid(music : Music) -> Bool = "moonbit_raylib_is_music_valid"

///|
#borrow(music)
pub extern "c" fn set_music_pan(music : Music, pan : Float) = "moonbit_raylib_set_music_pan"

// ============================================================================
// Wave loading/processing
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_wave(file_name : Bytes) -> Wave = "moonbit_raylib_load_wave"

///|
#borrow(file_type, file_data)
pub extern "c" fn load_wave_from_memory(
  file_type : Bytes,
  file_data : Bytes,
  data_size : Int,
) -> Wave = "moonbit_raylib_load_wave_from_memory"

///|
#borrow(wave)
pub extern "c" fn is_wave_valid(wave : Wave) -> Bool = "moonbit_raylib_is_wave_valid"

///|
#borrow(wave)
pub extern "c" fn load_sound_from_wave(wave : Wave) -> Sound = "moonbit_raylib_load_sound_from_wave"

///|
#borrow(wave)
pub extern "c" fn unload_wave(wave : Wave) = "moonbit_raylib_unload_wave"

///|
#borrow(wave, file_name)
pub extern "c" fn export_wave(wave : Wave, file_name : Bytes) -> Bool = "moonbit_raylib_export_wave"

///|
#borrow(wave, file_name)
pub extern "c" fn export_wave_as_code(wave : Wave, file_name : Bytes) -> Bool = "moonbit_raylib_export_wave_as_code"

///|
#borrow(wave)
pub extern "c" fn wave_copy(wave : Wave) -> Wave = "moonbit_raylib_wave_copy"

///|
#borrow(wave)
pub extern "c" fn wave_crop(wave : Wave, init_frame : Int, final_frame : Int) = "moonbit_raylib_wave_crop"

///|
#borrow(wave)
pub extern "c" fn wave_format(
  wave : Wave,
  sample_rate : Int,
  sample_size : Int,
  channels : Int,
) = "moonbit_raylib_wave_format"

///|
#borrow(wave)
pub extern "c" fn load_wave_samples(wave : Wave) -> Bytes = "moonbit_raylib_load_wave_samples"

// ============================================================================
// AudioStream management
// ============================================================================

///|
pub extern "c" fn load_audio_stream(
  sample_rate : UInt,
  sample_size : UInt,
  channels : UInt,
) -> AudioStream = "moonbit_raylib_load_audio_stream"

///|
#borrow(stream)
pub extern "c" fn is_audio_stream_valid(stream : AudioStream) -> Bool = "moonbit_raylib_is_audio_stream_valid"

///|
#borrow(stream)
pub extern "c" fn unload_audio_stream(stream : AudioStream) = "moonbit_raylib_unload_audio_stream"

///|
#borrow(stream, data)
pub extern "c" fn update_audio_stream(
  stream : AudioStream,
  data : Bytes,
  frame_count : Int,
) = "moonbit_raylib_update_audio_stream"

///|
#borrow(stream)
pub extern "c" fn is_audio_stream_processed(stream : AudioStream) -> Bool = "moonbit_raylib_is_audio_stream_processed"

///|
#borrow(stream)
pub extern "c" fn play_audio_stream(stream : AudioStream) = "moonbit_raylib_play_audio_stream"

///|
#borrow(stream)
pub extern "c" fn pause_audio_stream(stream : AudioStream) = "moonbit_raylib_pause_audio_stream"

///|
#borrow(stream)
pub extern "c" fn resume_audio_stream(stream : AudioStream) = "moonbit_raylib_resume_audio_stream"

///|
#borrow(stream)
pub extern "c" fn is_audio_stream_playing(stream : AudioStream) -> Bool = "moonbit_raylib_is_audio_stream_playing"

///|
#borrow(stream)
pub extern "c" fn stop_audio_stream(stream : AudioStream) = "moonbit_raylib_stop_audio_stream"

///|
#borrow(stream)
pub extern "c" fn set_audio_stream_volume(stream : AudioStream, volume : Float) = "moonbit_raylib_set_audio_stream_volume"

///|
#borrow(stream)
pub extern "c" fn set_audio_stream_pitch(stream : AudioStream, pitch : Float) = "moonbit_raylib_set_audio_stream_pitch"

///|
#borrow(stream)
pub extern "c" fn set_audio_stream_pan(stream : AudioStream, pan : Float) = "moonbit_raylib_set_audio_stream_pan"

///|
pub extern "c" fn set_audio_stream_buffer_size_default(size : Int) = "SetAudioStreamBufferSizeDefault"

// ============================================================================
// Music stream from memory
// ============================================================================

///|
#borrow(file_type, data)
pub extern "c" fn load_music_stream_from_memory(
  file_type : Bytes,
  data : Bytes,
  data_size : Int,
) -> Music = "moonbit_raylib_load_music_stream_from_memory"

// ============================================================================
// UpdateSound
// ============================================================================

///|
#borrow(sound, data)
pub extern "c" fn update_sound(sound : Sound, data : Bytes, sample_count : Int) = "moonbit_raylib_update_sound"
