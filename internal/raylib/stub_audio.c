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

Sound *
moonbit_raylib_load_sound(moonbit_bytes_t fileName) {
  Sound *s = (Sound *)moonbit_make_bytes(sizeof(Sound), 0);
  *s = LoadSound((const char *)fileName);
  return s;
}

void
moonbit_raylib_unload_sound(Sound *s) {
  UnloadSound(*s);
}

void
moonbit_raylib_play_sound(Sound *s) {
  PlaySound(*s);
}
void
moonbit_raylib_stop_sound(Sound *s) {
  StopSound(*s);
}
void
moonbit_raylib_pause_sound(Sound *s) {
  PauseSound(*s);
}
void
moonbit_raylib_resume_sound(Sound *s) {
  ResumeSound(*s);
}
int
moonbit_raylib_is_sound_playing(Sound *s) {
  return (int)IsSoundPlaying(*s);
}
void
moonbit_raylib_set_sound_volume(Sound *s, float volume) {
  SetSoundVolume(*s, volume);
}
void
moonbit_raylib_set_sound_pitch(Sound *s, float pitch) {
  SetSoundPitch(*s, pitch);
}
void
moonbit_raylib_set_sound_pan(Sound *s, float pan) {
  SetSoundPan(*s, pan);
}
int
moonbit_raylib_is_sound_valid(Sound *s) {
  return (int)IsSoundValid(*s);
}

Sound *
moonbit_raylib_load_sound_alias(Sound *source) {
  Sound *alias = (Sound *)moonbit_make_bytes(sizeof(Sound), 0);
  *alias = LoadSoundAlias(*source);
  return alias;
}

void
moonbit_raylib_unload_sound_alias(Sound *s) {
  UnloadSoundAlias(*s);
}

// ============================================================================
// Audio: Music (resource types)
// ============================================================================

Music *
moonbit_raylib_load_music_stream(moonbit_bytes_t fileName) {
  Music *m = (Music *)moonbit_make_bytes(sizeof(Music), 0);
  *m = LoadMusicStream((const char *)fileName);
  return m;
}

void
moonbit_raylib_unload_music_stream(Music *m) {
  UnloadMusicStream(*m);
}

void
moonbit_raylib_play_music_stream(Music *m) {
  PlayMusicStream(*m);
}
void
moonbit_raylib_stop_music_stream(Music *m) {
  StopMusicStream(*m);
}
void
moonbit_raylib_pause_music_stream(Music *m) {
  PauseMusicStream(*m);
}
void
moonbit_raylib_resume_music_stream(Music *m) {
  ResumeMusicStream(*m);
}
void
moonbit_raylib_update_music_stream(Music *m) {
  UpdateMusicStream(*m);
}
int
moonbit_raylib_is_music_stream_playing(Music *m) {
  return (int)IsMusicStreamPlaying(*m);
}
void
moonbit_raylib_set_music_volume(Music *m, float volume) {
  SetMusicVolume(*m, volume);
}
void
moonbit_raylib_set_music_pitch(Music *m, float pitch) {
  SetMusicPitch(*m, pitch);
}
void
moonbit_raylib_seek_music_stream(Music *m, float position) {
  SeekMusicStream(*m, position);
}
float
moonbit_raylib_get_music_time_length(Music *m) {
  return GetMusicTimeLength(*m);
}
float
moonbit_raylib_get_music_time_played(Music *m) {
  return GetMusicTimePlayed(*m);
}
int
moonbit_raylib_is_music_valid(Music *m) {
  return (int)IsMusicValid(*m);
}
void
moonbit_raylib_set_music_pan(Music *m, float pan) {
  SetMusicPan(*m, pan);
}

// ============================================================================
// Audio: Wave (resource types)
// ============================================================================

Wave *
moonbit_raylib_load_wave(moonbit_bytes_t fileName) {
  Wave *w = (Wave *)moonbit_make_bytes(sizeof(Wave), 0);
  *w = LoadWave((const char *)fileName);
  return w;
}

Wave *
moonbit_raylib_load_wave_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t fileData, int dataSize) {
  Wave *w = (Wave *)moonbit_make_bytes(sizeof(Wave), 0);
  *w = LoadWaveFromMemory((const char *)fileType, (const unsigned char *)fileData, dataSize);
  return w;
}

int
moonbit_raylib_is_wave_valid(Wave *w) {
  return (int)IsWaveValid(*w);
}

Sound *
moonbit_raylib_load_sound_from_wave(Wave *w) {
  Sound *s = (Sound *)moonbit_make_bytes(sizeof(Sound), 0);
  *s = LoadSoundFromWave(*w);
  return s;
}

void
moonbit_raylib_unload_wave(Wave *w) {
  UnloadWave(*w);
}

int
moonbit_raylib_export_wave(Wave *w, moonbit_bytes_t fileName) {
  return (int)ExportWave(*w, (const char *)fileName);
}

int
moonbit_raylib_export_wave_as_code(Wave *w, moonbit_bytes_t fileName) {
  return (int)ExportWaveAsCode(*w, (const char *)fileName);
}

Wave *
moonbit_raylib_wave_copy(Wave *w) {
  Wave *copy = (Wave *)moonbit_make_bytes(sizeof(Wave), 0);
  *copy = WaveCopy(*w);
  return copy;
}

void
moonbit_raylib_wave_crop(Wave *w, int initFrame, int finalFrame) {
  WaveCrop(w, initFrame, finalFrame);
}

void
moonbit_raylib_wave_format(Wave *w, int sampleRate, int sampleSize, int channels) {
  WaveFormat(w, sampleRate, sampleSize, channels);
}

moonbit_bytes_t
moonbit_raylib_load_wave_samples(Wave *w) {
  float *samples = LoadWaveSamples(*w);
  int count = w->frameCount * w->channels;
  moonbit_bytes_t r = moonbit_make_bytes(count * sizeof(float), 0);
  memcpy(r, samples, count * sizeof(float));
  UnloadWaveSamples(samples);
  return r;
}

// ============================================================================
// Audio: AudioStream (resource types)
// ============================================================================

AudioStream *
moonbit_raylib_load_audio_stream(unsigned int sampleRate, unsigned int sampleSize, unsigned int channels) {
  AudioStream *as = (AudioStream *)moonbit_make_bytes(sizeof(AudioStream), 0);
  *as = LoadAudioStream(sampleRate, sampleSize, channels);
  return as;
}

int
moonbit_raylib_is_audio_stream_valid(AudioStream *as) {
  return (int)IsAudioStreamValid(*as);
}

void
moonbit_raylib_unload_audio_stream(AudioStream *as) {
  UnloadAudioStream(*as);
}

void
moonbit_raylib_update_audio_stream(AudioStream *as, moonbit_bytes_t data, int frameCount) {
  UpdateAudioStream(*as, (const void *)data, frameCount);
}

int
moonbit_raylib_is_audio_stream_processed(AudioStream *as) {
  return (int)IsAudioStreamProcessed(*as);
}

void
moonbit_raylib_play_audio_stream(AudioStream *as) {
  PlayAudioStream(*as);
}

void
moonbit_raylib_pause_audio_stream(AudioStream *as) {
  PauseAudioStream(*as);
}

void
moonbit_raylib_resume_audio_stream(AudioStream *as) {
  ResumeAudioStream(*as);
}

int
moonbit_raylib_is_audio_stream_playing(AudioStream *as) {
  return (int)IsAudioStreamPlaying(*as);
}

void
moonbit_raylib_stop_audio_stream(AudioStream *as) {
  StopAudioStream(*as);
}

void
moonbit_raylib_set_audio_stream_volume(AudioStream *as, float volume) {
  SetAudioStreamVolume(*as, volume);
}

void
moonbit_raylib_set_audio_stream_pitch(AudioStream *as, float pitch) {
  SetAudioStreamPitch(*as, pitch);
}

void
moonbit_raylib_set_audio_stream_pan(AudioStream *as, float pan) {
  SetAudioStreamPan(*as, pan);
}

// ============================================================================
// Audio: Music stream from memory
// ============================================================================

Music *
moonbit_raylib_load_music_stream_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t data, int dataSize) {
  Music *m = (Music *)moonbit_make_bytes(sizeof(Music), 0);
  *m = LoadMusicStreamFromMemory((const char *)fileType, (const unsigned char *)data, dataSize);
  return m;
}

// ============================================================================
// Audio: UpdateSound
// ============================================================================

void
moonbit_raylib_update_sound(Sound *s, moonbit_bytes_t data, int sample_count) {
  UpdateSound(*s, (const void *)data, sample_count);
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
moonbit_raylib_attach_audio_stream_processor(AudioStream *as, AudioCallback processor) {
  AttachAudioStreamProcessor(*as, processor);
}

void
moonbit_raylib_detach_audio_stream_processor(AudioStream *as, AudioCallback processor) {
  DetachAudioStreamProcessor(*as, processor);
}

// ============================================================================
// Audio: Music stream processor attach/detach (accesses music.stream)
// ============================================================================

void
moonbit_raylib_attach_music_stream_processor(Music *m, AudioCallback processor) {
  AttachAudioStreamProcessor(m->stream, processor);
}

void
moonbit_raylib_detach_music_stream_processor(Music *m, AudioCallback processor) {
  DetachAudioStreamProcessor(m->stream, processor);
}
