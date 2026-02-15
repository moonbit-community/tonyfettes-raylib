#ifndef STUB_INTERNAL_H
#define STUB_INTERNAL_H

#include "raylib.h"
#include <moonbit.h>
#include <string.h>

typedef struct {
  Image image;
  int freed;
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

#endif
