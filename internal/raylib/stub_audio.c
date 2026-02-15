#include "stub_internal.h"

// ============================================================================
// Resource destructors: Sound, Music
// ============================================================================

static void
sound_destructor(void *ptr) {
  SoundWrapper *w = (SoundWrapper *)ptr;
  if (!w->freed)
    UnloadSound(w->sound);
}
static void
music_destructor(void *ptr) {
  MusicWrapper *w = (MusicWrapper *)ptr;
  if (!w->freed)
    UnloadMusicStream(w->music);
}

// ============================================================================
// Audio: Sound (resource types)
// ============================================================================

SoundWrapper *
moonbit_raylib_load_sound(moonbit_bytes_t fileName) {
  SoundWrapper *w = (SoundWrapper *)moonbit_make_external_object(
    sound_destructor, sizeof(SoundWrapper)
  );
  w->sound = LoadSound((const char *)fileName);
  w->freed = 0;
  return w;
}

void
moonbit_raylib_unload_sound(SoundWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadSound(wrapper->sound);
    wrapper->freed = 1;
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

// ============================================================================
// Audio: Music (resource types)
// ============================================================================

MusicWrapper *
moonbit_raylib_load_music_stream(moonbit_bytes_t fileName) {
  MusicWrapper *w = (MusicWrapper *)moonbit_make_external_object(
    music_destructor, sizeof(MusicWrapper)
  );
  w->music = LoadMusicStream((const char *)fileName);
  w->freed = 0;
  return w;
}

void
moonbit_raylib_unload_music_stream(MusicWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadMusicStream(wrapper->music);
    wrapper->freed = 1;
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
