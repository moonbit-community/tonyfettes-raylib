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
  return MakeSoundWrapper(LoadSound((const char *)fileName));
}

void
moonbit_raylib_unload_sound(SoundWrapper *s) {
  UnloadSound(*s->data);
}

void
moonbit_raylib_play_sound(SoundWrapper *s) {
  PlaySound(*s->data);
}
void
moonbit_raylib_stop_sound(SoundWrapper *s) {
  StopSound(*s->data);
}
void
moonbit_raylib_pause_sound(SoundWrapper *s) {
  PauseSound(*s->data);
}
void
moonbit_raylib_resume_sound(SoundWrapper *s) {
  ResumeSound(*s->data);
}
int
moonbit_raylib_is_sound_playing(SoundWrapper *s) {
  return (int)IsSoundPlaying(*s->data);
}
void
moonbit_raylib_set_sound_volume(SoundWrapper *s, float volume) {
  SetSoundVolume(*s->data, volume);
}
void
moonbit_raylib_set_sound_pitch(SoundWrapper *s, float pitch) {
  SetSoundPitch(*s->data, pitch);
}
void
moonbit_raylib_set_sound_pan(SoundWrapper *s, float pan) {
  SetSoundPan(*s->data, pan);
}
int
moonbit_raylib_is_sound_valid(SoundWrapper *s) {
  return (int)IsSoundValid(*s->data);
}

SoundWrapper *
moonbit_raylib_load_sound_alias(SoundWrapper *source) {
  return MakeSoundWrapper(LoadSoundAlias(*source->data));
}

void
moonbit_raylib_unload_sound_alias(SoundWrapper *s) {
  UnloadSoundAlias(*s->data);
}

// ============================================================================
// Audio: Music (resource types)
// ============================================================================

MusicWrapper *
moonbit_raylib_load_music_stream(moonbit_bytes_t fileName) {
  return MakeMusicWrapper(LoadMusicStream((const char *)fileName));
}

void
moonbit_raylib_unload_music_stream(MusicWrapper *m) {
  UnloadMusicStream(*m->data);
}

void
moonbit_raylib_play_music_stream(MusicWrapper *m) {
  PlayMusicStream(*m->data);
}
void
moonbit_raylib_stop_music_stream(MusicWrapper *m) {
  StopMusicStream(*m->data);
}
void
moonbit_raylib_pause_music_stream(MusicWrapper *m) {
  PauseMusicStream(*m->data);
}
void
moonbit_raylib_resume_music_stream(MusicWrapper *m) {
  ResumeMusicStream(*m->data);
}
void
moonbit_raylib_update_music_stream(MusicWrapper *m) {
  UpdateMusicStream(*m->data);
}
int
moonbit_raylib_is_music_stream_playing(MusicWrapper *m) {
  return (int)IsMusicStreamPlaying(*m->data);
}
void
moonbit_raylib_set_music_volume(MusicWrapper *m, float volume) {
  SetMusicVolume(*m->data, volume);
}
void
moonbit_raylib_set_music_pitch(MusicWrapper *m, float pitch) {
  SetMusicPitch(*m->data, pitch);
}
void
moonbit_raylib_seek_music_stream(MusicWrapper *m, float position) {
  SeekMusicStream(*m->data, position);
}
float
moonbit_raylib_get_music_time_length(MusicWrapper *m) {
  return GetMusicTimeLength(*m->data);
}
float
moonbit_raylib_get_music_time_played(MusicWrapper *m) {
  return GetMusicTimePlayed(*m->data);
}
int
moonbit_raylib_is_music_valid(MusicWrapper *m) {
  return (int)IsMusicValid(*m->data);
}
void
moonbit_raylib_set_music_pan(MusicWrapper *m, float pan) {
  SetMusicPan(*m->data, pan);
}

// ============================================================================
// Audio: Wave (resource types)
// ============================================================================

WaveWrapper *
moonbit_raylib_load_wave(moonbit_bytes_t fileName) {
  return MakeWaveWrapper(LoadWave((const char *)fileName));
}

WaveWrapper *
moonbit_raylib_load_wave_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t fileData, int dataSize) {
  return MakeWaveWrapper(LoadWaveFromMemory((const char *)fileType, (const unsigned char *)fileData, dataSize));
}

int
moonbit_raylib_is_wave_valid(WaveWrapper *w) {
  return (int)IsWaveValid(*w->data);
}

SoundWrapper *
moonbit_raylib_load_sound_from_wave(WaveWrapper *w) {
  return MakeSoundWrapper(LoadSoundFromWave(*w->data));
}

void
moonbit_raylib_unload_wave(WaveWrapper *w) {
  UnloadWave(*w->data);
}

int
moonbit_raylib_export_wave(WaveWrapper *w, moonbit_bytes_t fileName) {
  return (int)ExportWave(*w->data, (const char *)fileName);
}

int
moonbit_raylib_export_wave_as_code(WaveWrapper *w, moonbit_bytes_t fileName) {
  return (int)ExportWaveAsCode(*w->data, (const char *)fileName);
}

WaveWrapper *
moonbit_raylib_wave_copy(WaveWrapper *w) {
  return MakeWaveWrapper(WaveCopy(*w->data));
}

void
moonbit_raylib_wave_crop(WaveWrapper *w, int initFrame, int finalFrame) {
  WaveCrop(w->data, initFrame, finalFrame);
}

void
moonbit_raylib_wave_format(WaveWrapper *w, int sampleRate, int sampleSize, int channels) {
  WaveFormat(w->data, sampleRate, sampleSize, channels);
}

moonbit_bytes_t
moonbit_raylib_load_wave_samples(WaveWrapper *w) {
  float *samples = LoadWaveSamples(*w->data);
  int count = w->data->frameCount * w->data->channels;
  moonbit_bytes_t r = moonbit_make_bytes(count * sizeof(float), 0);
  memcpy(r, samples, count * sizeof(float));
  UnloadWaveSamples(samples);
  return r;
}

int32_t
moonbit_raylib_get_wave_frame_count(WaveWrapper *w) {
  return (int32_t)w->data->frameCount;
}

int32_t
moonbit_raylib_get_wave_sample_rate(WaveWrapper *w) {
  return (int32_t)w->data->sampleRate;
}

int32_t
moonbit_raylib_get_wave_sample_size(WaveWrapper *w) {
  return (int32_t)w->data->sampleSize;
}

int32_t
moonbit_raylib_get_wave_channels(WaveWrapper *w) {
  return (int32_t)w->data->channels;
}

// ============================================================================
// Audio: AudioStream (resource types)
// ============================================================================

AudioStreamWrapper *
moonbit_raylib_load_audio_stream(int sampleRate, int sampleSize, int channels) {
  return MakeAudioStreamWrapper(LoadAudioStream(sampleRate, sampleSize, channels));
}

int
moonbit_raylib_is_audio_stream_valid(AudioStreamWrapper *as) {
  return (int)IsAudioStreamValid(*as->data);
}

void
moonbit_raylib_unload_audio_stream(AudioStreamWrapper *as) {
  UnloadAudioStream(*as->data);
}

void
moonbit_raylib_update_audio_stream(AudioStreamWrapper *as, moonbit_bytes_t data, int frameCount) {
  UpdateAudioStream(*as->data, (const void *)data, frameCount);
}

int
moonbit_raylib_is_audio_stream_processed(AudioStreamWrapper *as) {
  return (int)IsAudioStreamProcessed(*as->data);
}

void
moonbit_raylib_play_audio_stream(AudioStreamWrapper *as) {
  PlayAudioStream(*as->data);
}

void
moonbit_raylib_pause_audio_stream(AudioStreamWrapper *as) {
  PauseAudioStream(*as->data);
}

void
moonbit_raylib_resume_audio_stream(AudioStreamWrapper *as) {
  ResumeAudioStream(*as->data);
}

int
moonbit_raylib_is_audio_stream_playing(AudioStreamWrapper *as) {
  return (int)IsAudioStreamPlaying(*as->data);
}

void
moonbit_raylib_stop_audio_stream(AudioStreamWrapper *as) {
  StopAudioStream(*as->data);
}

void
moonbit_raylib_set_audio_stream_volume(AudioStreamWrapper *as, float volume) {
  SetAudioStreamVolume(*as->data, volume);
}

void
moonbit_raylib_set_audio_stream_pitch(AudioStreamWrapper *as, float pitch) {
  SetAudioStreamPitch(*as->data, pitch);
}

void
moonbit_raylib_set_audio_stream_pan(AudioStreamWrapper *as, float pan) {
  SetAudioStreamPan(*as->data, pan);
}

// ============================================================================
// Audio: Music stream from memory
// ============================================================================

MusicWrapper *
moonbit_raylib_load_music_stream_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t data, int dataSize) {
  return MakeMusicWrapper(LoadMusicStreamFromMemory((const char *)fileType, (const unsigned char *)data, dataSize));
}

// ============================================================================
// Audio: UpdateSound
// ============================================================================

void
moonbit_raylib_update_sound(SoundWrapper *s, moonbit_bytes_t data, int sample_count) {
  UpdateSound(*s->data, (const void *)data, sample_count);
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
moonbit_raylib_attach_audio_stream_processor(AudioStreamWrapper *as, AudioCallback processor) {
  AttachAudioStreamProcessor(*as->data, processor);
}

void
moonbit_raylib_detach_audio_stream_processor(AudioStreamWrapper *as, AudioCallback processor) {
  DetachAudioStreamProcessor(*as->data, processor);
}

// ============================================================================
// Audio: Music stream processor attach/detach (accesses music.stream)
// ============================================================================

void
moonbit_raylib_attach_music_stream_processor(MusicWrapper *m, AudioCallback processor) {
  AttachAudioStreamProcessor(m->data->stream, processor);
}

void
moonbit_raylib_detach_music_stream_processor(MusicWrapper *m, AudioCallback processor) {
  DetachAudioStreamProcessor(m->data->stream, processor);
}
