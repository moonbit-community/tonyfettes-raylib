#ifndef STUB_INTERNAL_H
#define STUB_INTERNAL_H

#include "config.h"
#include "raylib.h"
#include "rlgl.h"
#include <assert.h>
#include <moonbit.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  Mesh *data;
  Mesh storage[];
} MoonBitMesh;

static inline MoonBitMesh *
moonbit_raylib_make_moonbit_mesh(Mesh mesh) {
  MoonBitMesh *w =
    (MoonBitMesh *)moonbit_make_bytes(sizeof(MoonBitMesh) + sizeof(Mesh), 0);
  w->storage[0] = mesh;
  w->data = w->storage;
  return w;
}

static inline MoonBitMesh *
moonbit_raylib_make_moonbit_mesh_view(Mesh *mesh) {
  MoonBitMesh *w = (MoonBitMesh *)moonbit_make_bytes(sizeof(MoonBitMesh), 0);
  w->data = mesh;
  return w;
}

typedef struct {
  Material *data;
  Material storage[];
} MoonBitMaterial;

static inline MoonBitMaterial *
moonbit_raylib_make_moonbit_material(Material material) {
  MoonBitMaterial *w = (MoonBitMaterial *)moonbit_make_bytes(
    sizeof(MoonBitMaterial) + sizeof(Material), 0
  );
  w->storage[0] = material;
  w->data = w->storage;
  return w;
}

static inline MoonBitMaterial *
moonbit_raylib_make_moonbit_material_view(Material *material) {
  MoonBitMaterial *w =
    (MoonBitMaterial *)moonbit_make_bytes(sizeof(MoonBitMaterial), 0);
  w->data = material;
  return w;
}

typedef struct {
  ModelAnimation *anims;
  int count;
} MoonBitModelAnimations;

typedef struct {
  GlyphInfo *glyphs;
  int count;
} MoonBitGlyphInfoArray;

typedef struct {
  FilePathList list;
  int is_dropped;
} MoonBitFilePathList;

typedef struct {
  AutomationEventList list;
} MoonBitAutomationEventList;

typedef struct {
  Material *materials;
  int count;
} MoonBitMaterialsArray;

#define DeclareView(T, var)                                                    \
  T *moonbit_view_##var##_memory, int32_t moonbit_view_##var##_offset

#define View(T, var)                                                           \
  ((T *)((moonbit_bytes_t)moonbit_view_##var##_memory +                        \
         moonbit_view_##var##_offset))

#endif
