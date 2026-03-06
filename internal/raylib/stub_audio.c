#include "stub_internal.h"

// ============================================================================
// Audio device (bool → int32_t wrapper for MoonBit Bool ABI)
// ============================================================================

int32_t
moonbit_raylib_is_audio_device_ready(void) {
  return (int32_t)IsAudioDeviceReady();
}

// ============================================================================
// Audio: Sound (resource types)
// ============================================================================

SoundWrapper *
moonbit_raylib_load_sound(moonbit_bytes_t fileName) {
  SoundWrapper *w = (SoundWrapper *)malloc(sizeof(SoundWrapper));
  w->sound = LoadSound((const char *)fileName);
  return w;
}

void
moonbit_raylib_unload_sound(SoundWrapper *wrapper) {
  if (wrapper) {
    UnloadSound(wrapper->sound);
    free(wrapper);
  }
}

void
moonbit_raylib_play_sound(SoundWrapper *wrapper) {
  PlaySound(wrapper->sound);
}
void
moonbit_raylib_stop_sound(SoundWrapper *wrapper) {
  StopSound(wrapper->sound);
}
void
moonbit_raylib_pause_sound(SoundWrapper *wrapper) {
  PauseSound(wrapper->sound);
}
void
moonbit_raylib_resume_sound(SoundWrapper *wrapper) {
  ResumeSound(wrapper->sound);
}
int
moonbit_raylib_is_sound_playing(SoundWrapper *wrapper) {
  return (int)IsSoundPlaying(wrapper->sound);
}
void
moonbit_raylib_set_sound_volume(SoundWrapper *wrapper, float volume) {
  SetSoundVolume(wrapper->sound, volume);
}
void
moonbit_raylib_set_sound_pitch(SoundWrapper *wrapper, float pitch) {
  SetSoundPitch(wrapper->sound, pitch);
}
void
moonbit_raylib_set_sound_pan(SoundWrapper *wrapper, float pan) {
  SetSoundPan(wrapper->sound, pan);
}
int
moonbit_raylib_is_sound_valid(SoundWrapper *wrapper) {
  return (int)IsSoundValid(wrapper->sound);
}

SoundWrapper *
moonbit_raylib_load_sound_alias(SoundWrapper *source) {
  SoundWrapper *w = (SoundWrapper *)malloc(sizeof(SoundWrapper));
  w->sound = LoadSoundAlias(source->sound);
  return w;
}

void
moonbit_raylib_unload_sound_alias(SoundWrapper *wrapper) {
  if (wrapper) {
    UnloadSoundAlias(wrapper->sound);
    free(wrapper);
  }
}

// ============================================================================
// Audio: Music (resource types)
// ============================================================================

MusicWrapper *
moonbit_raylib_load_music_stream(moonbit_bytes_t fileName) {
  MusicWrapper *w = (MusicWrapper *)malloc(sizeof(MusicWrapper));
  w->music = LoadMusicStream((const char *)fileName);
  return w;
}

void
moonbit_raylib_unload_music_stream(MusicWrapper *wrapper) {
  if (wrapper) {
    UnloadMusicStream(wrapper->music);
    free(wrapper);
  }
}

void
moonbit_raylib_play_music_stream(MusicWrapper *wrapper) {
  PlayMusicStream(wrapper->music);
}
void
moonbit_raylib_stop_music_stream(MusicWrapper *wrapper) {
  StopMusicStream(wrapper->music);
}
void
moonbit_raylib_pause_music_stream(MusicWrapper *wrapper) {
  PauseMusicStream(wrapper->music);
}
void
moonbit_raylib_resume_music_stream(MusicWrapper *wrapper) {
  ResumeMusicStream(wrapper->music);
}
void
moonbit_raylib_update_music_stream(MusicWrapper *wrapper) {
  UpdateMusicStream(wrapper->music);
}
int
moonbit_raylib_is_music_stream_playing(MusicWrapper *wrapper) {
  return (int)IsMusicStreamPlaying(wrapper->music);
}
void
moonbit_raylib_set_music_volume(MusicWrapper *wrapper, float volume) {
  SetMusicVolume(wrapper->music, volume);
}
void
moonbit_raylib_set_music_pitch(MusicWrapper *wrapper, float pitch) {
  SetMusicPitch(wrapper->music, pitch);
}
void
moonbit_raylib_seek_music_stream(MusicWrapper *wrapper, float position) {
  SeekMusicStream(wrapper->music, position);
}
float
moonbit_raylib_get_music_time_length(MusicWrapper *wrapper) {
  return GetMusicTimeLength(wrapper->music);
}
float
moonbit_raylib_get_music_time_played(MusicWrapper *wrapper) {
  return GetMusicTimePlayed(wrapper->music);
}
int
moonbit_raylib_is_music_valid(MusicWrapper *wrapper) {
  return (int)IsMusicValid(wrapper->music);
}
void
moonbit_raylib_set_music_pan(MusicWrapper *wrapper, float pan) {
  SetMusicPan(wrapper->music, pan);
}

// ============================================================================
// Audio: Wave (resource types)
// ============================================================================

WaveWrapper *
moonbit_raylib_load_wave(moonbit_bytes_t fileName) {
  WaveWrapper *w = (WaveWrapper *)malloc(sizeof(WaveWrapper));
  w->wave = LoadWave((const char *)fileName);
  return w;
}

WaveWrapper *
moonbit_raylib_load_wave_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t fileData, int dataSize) {
  WaveWrapper *w = (WaveWrapper *)malloc(sizeof(WaveWrapper));
  w->wave = LoadWaveFromMemory((const char *)fileType, (const unsigned char *)fileData, dataSize);
  return w;
}

int
moonbit_raylib_is_wave_valid(WaveWrapper *wrapper) {
  return (int)IsWaveValid(wrapper->wave);
}

SoundWrapper *
moonbit_raylib_load_sound_from_wave(WaveWrapper *wrapper) {
  SoundWrapper *w = (SoundWrapper *)malloc(sizeof(SoundWrapper));
  w->sound = LoadSoundFromWave(wrapper->wave);
  return w;
}

void
moonbit_raylib_unload_wave(WaveWrapper *wrapper) {
  if (wrapper) {
    UnloadWave(wrapper->wave);
    free(wrapper);
  }
}

int
moonbit_raylib_export_wave(WaveWrapper *wrapper, moonbit_bytes_t fileName) {
  return (int)ExportWave(wrapper->wave, (const char *)fileName);
}

int
moonbit_raylib_export_wave_as_code(WaveWrapper *wrapper, moonbit_bytes_t fileName) {
  return (int)ExportWaveAsCode(wrapper->wave, (const char *)fileName);
}

WaveWrapper *
moonbit_raylib_wave_copy(WaveWrapper *wrapper) {
  WaveWrapper *w = (WaveWrapper *)malloc(sizeof(WaveWrapper));
  w->wave = WaveCopy(wrapper->wave);
  return w;
}

void
moonbit_raylib_wave_crop(WaveWrapper *wrapper, int initFrame, int finalFrame) {
  WaveCrop(&wrapper->wave, initFrame, finalFrame);
}

void
moonbit_raylib_wave_format(WaveWrapper *wrapper, int sampleRate, int sampleSize, int channels) {
  WaveFormat(&wrapper->wave, sampleRate, sampleSize, channels);
}

moonbit_bytes_t
moonbit_raylib_load_wave_samples(WaveWrapper *wrapper) {
  float *samples = LoadWaveSamples(wrapper->wave);
  int count = wrapper->wave.frameCount * wrapper->wave.channels;
  moonbit_bytes_t r = moonbit_make_bytes(count * sizeof(float), 0);
  memcpy(r, samples, count * sizeof(float));
  UnloadWaveSamples(samples);
  return r;
}

// ============================================================================
// Audio: AudioStream (resource types)
// ============================================================================

AudioStreamWrapper *
moonbit_raylib_load_audio_stream(unsigned int sampleRate, unsigned int sampleSize, unsigned int channels) {
  AudioStreamWrapper *w = (AudioStreamWrapper *)malloc(sizeof(AudioStreamWrapper));
  w->stream = LoadAudioStream(sampleRate, sampleSize, channels);
  return w;
}

int
moonbit_raylib_is_audio_stream_valid(AudioStreamWrapper *wrapper) {
  return (int)IsAudioStreamValid(wrapper->stream);
}

void
moonbit_raylib_unload_audio_stream(AudioStreamWrapper *wrapper) {
  if (wrapper) {
    UnloadAudioStream(wrapper->stream);
    free(wrapper);
  }
}

void
moonbit_raylib_update_audio_stream(AudioStreamWrapper *wrapper, moonbit_bytes_t data, int frameCount) {
  UpdateAudioStream(wrapper->stream, (const void *)data, frameCount);
}

int
moonbit_raylib_is_audio_stream_processed(AudioStreamWrapper *wrapper) {
  return (int)IsAudioStreamProcessed(wrapper->stream);
}

void
moonbit_raylib_play_audio_stream(AudioStreamWrapper *wrapper) {
  PlayAudioStream(wrapper->stream);
}

void
moonbit_raylib_pause_audio_stream(AudioStreamWrapper *wrapper) {
  PauseAudioStream(wrapper->stream);
}

void
moonbit_raylib_resume_audio_stream(AudioStreamWrapper *wrapper) {
  ResumeAudioStream(wrapper->stream);
}

int
moonbit_raylib_is_audio_stream_playing(AudioStreamWrapper *wrapper) {
  return (int)IsAudioStreamPlaying(wrapper->stream);
}

void
moonbit_raylib_stop_audio_stream(AudioStreamWrapper *wrapper) {
  StopAudioStream(wrapper->stream);
}

void
moonbit_raylib_set_audio_stream_volume(AudioStreamWrapper *wrapper, float volume) {
  SetAudioStreamVolume(wrapper->stream, volume);
}

void
moonbit_raylib_set_audio_stream_pitch(AudioStreamWrapper *wrapper, float pitch) {
  SetAudioStreamPitch(wrapper->stream, pitch);
}

void
moonbit_raylib_set_audio_stream_pan(AudioStreamWrapper *wrapper, float pan) {
  SetAudioStreamPan(wrapper->stream, pan);
}

// ============================================================================
// Audio: Music stream from memory
// ============================================================================

MusicWrapper *
moonbit_raylib_load_music_stream_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t data, int dataSize) {
  MusicWrapper *w = (MusicWrapper *)malloc(sizeof(MusicWrapper));
  w->music = LoadMusicStreamFromMemory((const char *)fileType, (const unsigned char *)data, dataSize);
  return w;
}

// ============================================================================
// Audio: UpdateSound
// ============================================================================

void
moonbit_raylib_update_sound(SoundWrapper *wrapper, moonbit_bytes_t data, int sample_count) {
  UpdateSound(wrapper->sound, (const void *)data, sample_count);
}

// ============================================================================
// Audio: AudioBuffer accessors (read/write float samples from raw void*)
// ============================================================================

float
moonbit_raylib_audio_buffer_get_sample(void *buf, unsigned int index) {
  return ((float *)buf)[index];
}

void
moonbit_raylib_audio_buffer_set_sample(void *buf, unsigned int index, float value) {
  ((float *)buf)[index] = value;
}

// ============================================================================
// Audio: Stream processor attach/detach
// ============================================================================

void
moonbit_raylib_attach_audio_stream_processor(AudioStreamWrapper *wrapper, AudioCallback processor) {
  AttachAudioStreamProcessor(wrapper->stream, processor);
}

void
moonbit_raylib_detach_audio_stream_processor(AudioStreamWrapper *wrapper, AudioCallback processor) {
  DetachAudioStreamProcessor(wrapper->stream, processor);
}

// ============================================================================
// Audio: Music stream processor attach/detach (accesses music.stream)
// ============================================================================

void
moonbit_raylib_attach_music_stream_processor(MusicWrapper *wrapper, AudioCallback processor) {
  AttachAudioStreamProcessor(wrapper->music.stream, processor);
}

void
moonbit_raylib_detach_music_stream_processor(MusicWrapper *wrapper, AudioCallback processor) {
  DetachAudioStreamProcessor(wrapper->music.stream, processor);
}
