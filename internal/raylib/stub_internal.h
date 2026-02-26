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
  void *parent; // incref'd parent for non-owning views, NULL for owning
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

// View destructor for non-owning TextureWrappers that hold an incref'd parent.
// Decrefs the parent so the GC can collect it once the view is no longer used.
static inline void texture_view_destructor(void *ptr) {
  TextureWrapper *w = (TextureWrapper *)ptr;
  if (w->parent) moonbit_decref(w->parent);
}

#endif
