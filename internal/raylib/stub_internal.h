#ifndef STUB_INTERNAL_H
#define STUB_INTERNAL_H

#include "raylib.h"
#include "config.h"
#include "rlgl.h"
#include <moonbit.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
  Image image;
  int frame_count;
} ImageWrapper;
typedef struct {
  RenderTexture render_texture;
} RenderTextureWrapper;
typedef struct {
  Font font;
  int is_view; // 0 = owning, 1 = non-owning (e.g., default font)
} FontWrapper;
typedef struct {
  Sound sound;
} SoundWrapper;
typedef struct {
  Music music;
} MusicWrapper;
typedef struct {
  Model model;
} ModelWrapper;
typedef struct {
  Shader shader;
} ShaderWrapper;
typedef struct {
  Wave wave;
} WaveWrapper;
typedef struct {
  AudioStream stream;
} AudioStreamWrapper;
typedef struct {
  Mesh mesh;
  int is_view; // 0 = owning, 1 = non-owning (e.g., from model)
} MeshWrapper;
typedef struct {
  Material material;
  int is_view; // 0 = owning, 1 = non-owning (e.g., from model)
} MaterialWrapper;
typedef struct {
  ModelAnimation *anims;
  int count;
} ModelAnimationsWrapper;
typedef struct {
  GlyphInfo *glyphs;
  int count;
} GlyphInfoArrayWrapper;

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
