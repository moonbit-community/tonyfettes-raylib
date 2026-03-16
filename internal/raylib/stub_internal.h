#ifndef STUB_INTERNAL_H
#define STUB_INTERNAL_H

#include "config.h"
#include "raylib.h"
#include "rlgl.h"
#include <assert.h>
#include <moonbit.h>
#include <stdlib.h>
#include <string.h>

// ============================================================================
// Generic view finalizer: decrefs owner if non-NULL
// ============================================================================

static void view_release_owner(void *self) {
  void **owner_ptr = (void **)((char *)self + sizeof(void *));
  if (*owner_ptr) moonbit_decref(*owner_ptr);
}

// ============================================================================
// Group A: Simple value types (owned only, no views)
// ============================================================================

#define DEFINE_SIMPLE_WRAPPER(T, name)                                         \
  typedef struct {                                                             \
    T *data;                                                                   \
    void *owner;                                                               \
    T storage[];                                                               \
  } name##Wrapper;                                                             \
                                                                               \
  static void name##_wrapper_finalizer(void *self) {                           \
    name##Wrapper *w = (name##Wrapper *)self;                                  \
    if (w->owner) moonbit_decref(w->owner);                                    \
  }                                                                            \
                                                                               \
  static inline name##Wrapper *Make##name##Wrapper(T val) {                    \
    name##Wrapper *w = (name##Wrapper *)moonbit_make_external_object(          \
      name##_wrapper_finalizer, sizeof(name##Wrapper) + sizeof(T)              \
    );                                                                         \
    w->storage[0] = val;                                                       \
    w->data = w->storage;                                                      \
    w->owner = NULL;                                                           \
    return w;                                                                  \
  }                                                                            \
                                                                               \
  static inline name##Wrapper *Make##name##WrapperView(                        \
    T *ptr, void *owner                                                        \
  ) {                                                                          \
    name##Wrapper *w = (name##Wrapper *)moonbit_make_external_object(          \
      name##_wrapper_finalizer, sizeof(name##Wrapper)                          \
    );                                                                         \
    w->data = ptr;                                                             \
    w->owner = owner;                                                          \
    if (owner) moonbit_incref(owner);                                          \
    return w;                                                                  \
  }

// Group A: simple value types
DEFINE_SIMPLE_WRAPPER(Image, Image)
DEFINE_SIMPLE_WRAPPER(Sound, Sound)
DEFINE_SIMPLE_WRAPPER(Music, Music)
DEFINE_SIMPLE_WRAPPER(Model, Model)
DEFINE_SIMPLE_WRAPPER(Shader, Shader)
DEFINE_SIMPLE_WRAPPER(Wave, Wave)
DEFINE_SIMPLE_WRAPPER(AudioStream, AudioStream)
DEFINE_SIMPLE_WRAPPER(VrStereoConfig, VrStereoConfig)
DEFINE_SIMPLE_WRAPPER(Font, Font)

// Group B: types with views (Texture from RenderTexture/Font, etc.)
DEFINE_SIMPLE_WRAPPER(Texture, Texture)
DEFINE_SIMPLE_WRAPPER(RenderTexture, RenderTexture)

// Group C: types that already had data+storage (now unified)
DEFINE_SIMPLE_WRAPPER(Mesh, Mesh)
DEFINE_SIMPLE_WRAPPER(Material, Material)
DEFINE_SIMPLE_WRAPPER(MaterialMap, MaterialMap)

// ============================================================================
// Group D: Array wrappers (C-allocated arrays with metadata)
// ============================================================================

typedef struct {
  ModelAnimation *anims;
  int count;
  void *owner;
} ModelAnimationsWrapper;

static void model_animations_wrapper_finalizer(void *self) {
  ModelAnimationsWrapper *w = (ModelAnimationsWrapper *)self;
  if (w->owner) moonbit_decref(w->owner);
}

static inline ModelAnimationsWrapper *
MakeModelAnimationsWrapper(ModelAnimation *anims, int count) {
  ModelAnimationsWrapper *w =
    (ModelAnimationsWrapper *)moonbit_make_external_object(
      model_animations_wrapper_finalizer, sizeof(ModelAnimationsWrapper)
    );
  w->anims = anims;
  w->count = count;
  w->owner = NULL;
  return w;
}

typedef struct {
  GlyphInfo *glyphs;
  int count;
  void *owner;
} GlyphInfoArrayWrapper;

static void glyph_info_array_wrapper_finalizer(void *self) {
  GlyphInfoArrayWrapper *w = (GlyphInfoArrayWrapper *)self;
  if (w->owner) moonbit_decref(w->owner);
}

static inline GlyphInfoArrayWrapper *
MakeGlyphInfoArrayWrapper(GlyphInfo *glyphs, int count) {
  GlyphInfoArrayWrapper *w =
    (GlyphInfoArrayWrapper *)moonbit_make_external_object(
      glyph_info_array_wrapper_finalizer, sizeof(GlyphInfoArrayWrapper)
    );
  w->glyphs = glyphs;
  w->count = count;
  w->owner = NULL;
  return w;
}

typedef struct {
  FilePathList list;
  int is_dropped;
  void *owner;
} FilePathListWrapper;

static void file_path_list_wrapper_finalizer(void *self) {
  FilePathListWrapper *w = (FilePathListWrapper *)self;
  if (w->owner) moonbit_decref(w->owner);
}

static inline FilePathListWrapper *
MakeFilePathListWrapper(FilePathList list, int is_dropped) {
  FilePathListWrapper *w =
    (FilePathListWrapper *)moonbit_make_external_object(
      file_path_list_wrapper_finalizer, sizeof(FilePathListWrapper)
    );
  w->list = list;
  w->is_dropped = is_dropped;
  w->owner = NULL;
  return w;
}

typedef struct {
  AutomationEventList list;
  void *owner;
} AutomationEventListWrapper;

static void automation_event_list_wrapper_finalizer(void *self) {
  AutomationEventListWrapper *w = (AutomationEventListWrapper *)self;
  if (w->owner) moonbit_decref(w->owner);
}

static inline AutomationEventListWrapper *
MakeAutomationEventListWrapper(AutomationEventList list) {
  AutomationEventListWrapper *w =
    (AutomationEventListWrapper *)moonbit_make_external_object(
      automation_event_list_wrapper_finalizer,
      sizeof(AutomationEventListWrapper)
    );
  w->list = list;
  w->owner = NULL;
  return w;
}

// ============================================================================
// Group E: Typed array wrappers (views into parent-owned arrays + owned copies)
// ============================================================================

#define DEFINE_TYPED_ARRAY_WRAPPER(T, name)                                    \
  typedef struct {                                                             \
    T *data;                                                                   \
    int count;                                                                 \
    void *owner;                                                               \
  } name##Wrapper;                                                             \
                                                                               \
  static void name##_wrapper_finalizer(void *self) {                           \
    name##Wrapper *w = (name##Wrapper *)self;                                  \
    if (w->owner) moonbit_decref(w->owner);                                    \
  }                                                                            \
                                                                               \
  static inline name##Wrapper *Make##name##WrapperOwned(                       \
    const T *src, int count                                                    \
  ) {                                                                          \
    size_t data_size = (size_t)count * sizeof(T);                              \
    name##Wrapper *w = (name##Wrapper *)moonbit_make_external_object(          \
      name##_wrapper_finalizer,                                                \
      sizeof(name##Wrapper) + data_size                                        \
    );                                                                         \
    w->count = count;                                                          \
    w->data = (T *)((char *)(w) + sizeof(name##Wrapper));                      \
    w->owner = NULL;                                                           \
    if (src) memcpy(w->data, src, data_size);                                  \
    return w;                                                                  \
  }                                                                            \
                                                                               \
  static inline name##Wrapper *Make##name##WrapperView(                        \
    T *data, int count, void *owner                                            \
  ) {                                                                          \
    name##Wrapper *w = (name##Wrapper *)moonbit_make_external_object(          \
      name##_wrapper_finalizer, sizeof(name##Wrapper)                          \
    );                                                                         \
    w->data = data;                                                            \
    w->count = count;                                                          \
    w->owner = owner;                                                          \
    if (owner) moonbit_incref(owner);                                          \
    return w;                                                                  \
  }

DEFINE_TYPED_ARRAY_WRAPPER(float, FloatArray)
DEFINE_TYPED_ARRAY_WRAPPER(unsigned char, UByteArray)
DEFINE_TYPED_ARRAY_WRAPPER(unsigned short, UShortArray)
DEFINE_TYPED_ARRAY_WRAPPER(Matrix, MatrixArray)
DEFINE_TYPED_ARRAY_WRAPPER(MaterialMap, MaterialMapArray)

// ============================================================================
// Group F: Legacy array wrappers (pre-existing, manually defined)
// ============================================================================

typedef struct {
  Material *materials;
  int count;
  void *owner;
} MaterialsArrayWrapper;

static void materials_array_wrapper_finalizer(void *self) {
  MaterialsArrayWrapper *w = (MaterialsArrayWrapper *)self;
  if (w->owner) moonbit_decref(w->owner);
}

static inline MaterialsArrayWrapper *
MakeMaterialsArrayWrapper(Material *materials, int count) {
  MaterialsArrayWrapper *w =
    (MaterialsArrayWrapper *)moonbit_make_external_object(
      materials_array_wrapper_finalizer, sizeof(MaterialsArrayWrapper)
    );
  w->materials = materials;
  w->count = count;
  w->owner = NULL;
  return w;
}

#endif
