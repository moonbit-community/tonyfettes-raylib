#ifndef STUB_INTERNAL_H
#define STUB_INTERNAL_H

#include "raylib.h"
#include "config.h"
#include "rlgl.h"
#include <moonbit.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

typedef struct {
  Texture2D *data;
  bool is_view;
  bool data_owned;
} TextureWrapper;

typedef struct {
  Font *data;
  bool is_view;
  bool data_owned;
} FontWrapper;

typedef struct {
  Mesh *data;
  bool is_view;
  bool data_owned;
} MeshWrapper;

typedef struct {
  Material *data;
  bool is_view;
  bool data_owned;
} MaterialWrapper;

typedef struct {
  ModelAnimation *anims;
  int count;
} ModelAnimationsWrapper;

typedef struct {
  GlyphInfo *glyphs;
  int count;
} GlyphInfoArrayWrapper;

typedef struct {
  FilePathList list;
  int is_dropped;
} FilePathListWrapper;

typedef struct {
  AutomationEventList list;
} AutomationEventListWrapper;

typedef struct {
  Material *materials;
  int count;
} MaterialsArrayWrapper;

#endif
