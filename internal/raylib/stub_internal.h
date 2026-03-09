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
  void *parent; // incref'd parent for non-owning views, NULL for owning
} MeshWrapper;
typedef struct {
  Material material;
  int freed;
  void *parent; // incref'd parent for non-owning views, NULL for owning
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

// Texture2D <-> moonbit_bytes_t helpers.
// MoonBit serializes Texture as 5x int32 = 20 bytes.
#if defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L
_Static_assert(sizeof(Texture2D) == 20,
  "Texture2D must be 20 bytes (5x int32) to match MoonBit Texture struct layout");
#else
typedef char assert_texture2d_is_20_bytes[sizeof(Texture2D) == 20 ? 1 : -1];
#endif

static inline Texture2D
bytes_to_texture(moonbit_bytes_t b) {
  Texture2D tex;
  memcpy(&tex, b, sizeof(Texture2D));
  return tex;
}

static inline moonbit_bytes_t
texture_to_bytes(Texture2D tex) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(Texture2D), 0);
  memcpy(res, &tex, sizeof(Texture2D));
  return res;
}

#endif
