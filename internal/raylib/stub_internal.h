#ifndef STUB_INTERNAL_H
#define STUB_INTERNAL_H

#include "raylib.h"
#include "config.h"
#include "rlgl.h"
#include <moonbit.h>
#include <string.h>

typedef struct {
  Image image;
  int freed;
  int frame_count;
} ImageWrapper;
typedef struct {
  Texture texture;
  int freed;
} TextureWrapper;
typedef struct {
  RenderTexture render_texture;
  int freed;
} RenderTextureWrapper;
typedef struct {
  Font font;
  int freed;
} FontWrapper;
typedef struct {
  Sound sound;
  int freed;
} SoundWrapper;
typedef struct {
  Music music;
  int freed;
} MusicWrapper;
typedef struct {
  Model model;
  int freed;
} ModelWrapper;
typedef struct {
  Shader shader;
  int freed;
} ShaderWrapper;
typedef struct {
  Wave wave;
  int freed;
} WaveWrapper;
typedef struct {
  AudioStream stream;
  int freed;
} AudioStreamWrapper;
typedef struct {
  Mesh mesh;
  int freed;
} MeshWrapper;
typedef struct {
  Material material;
  int freed;
} MaterialWrapper;
typedef struct {
  ModelAnimation *anims;
  int count;
  int freed;
} ModelAnimationsWrapper;
typedef struct {
  GlyphInfo *glyphs;
  int count;
  int freed;
} GlyphInfoArrayWrapper;

// No-op destructor for non-owning wrappers (freed=1).
// moonbit_make_external_object requires a non-NULL destructor;
// passing NULL causes a crash when the GC calls through the function pointer.
static inline void noop_destructor(void *ptr) { (void)ptr; }

#endif
