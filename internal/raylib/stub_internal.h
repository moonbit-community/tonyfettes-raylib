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
  Texture texture;
  int is_view; // 0 = owning, 1 = non-owning (e.g., from render texture or font)
} TextureWrapper;
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

#endif
