#include "stub_internal.h"

// ============================================================================
// Core: Drawing - struct parameters
// ============================================================================

void
moonbit_raylib_clear_background(moonbit_bytes_t color) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  ClearBackground(c);
}

void
moonbit_raylib_begin_mode_2d(moonbit_bytes_t camera) {
  Camera2D c;
  memcpy(&c, camera, sizeof(Camera2D));
  BeginMode2D(c);
}

void
moonbit_raylib_begin_mode_3d(moonbit_bytes_t camera) {
  Camera3D c;
  memcpy(&c, camera, sizeof(Camera3D));
  BeginMode3D(c);
}

// ============================================================================
// Textures: BeginTextureMode needs RenderTexture
// ============================================================================

void
moonbit_raylib_begin_texture_mode(RenderTextureWrapper *wrapper) {
  BeginTextureMode(wrapper->render_texture);
}

// ============================================================================
// Shader management
// ============================================================================

static void
shader_destructor(void *ptr) {
  ShaderWrapper *w = (ShaderWrapper *)ptr;
  if (!w->freed)
    UnloadShader(w->shader);
}

ShaderWrapper *
moonbit_raylib_load_shader(moonbit_bytes_t vsFileName, moonbit_bytes_t fsFileName) {
  const char *vs = (const char *)vsFileName;
  const char *fs = (const char *)fsFileName;
  if (vs[0] == '\0') vs = NULL;
  if (fs[0] == '\0') fs = NULL;
  ShaderWrapper *w = (ShaderWrapper *)moonbit_make_external_object(
    shader_destructor, sizeof(ShaderWrapper)
  );
  w->shader = LoadShader(vs, fs);
  w->freed = 0;
  return w;
}

ShaderWrapper *
moonbit_raylib_load_shader_from_memory(moonbit_bytes_t vsCode, moonbit_bytes_t fsCode) {
  const char *vs = (const char *)vsCode;
  const char *fs = (const char *)fsCode;
  if (vs[0] == '\0') vs = NULL;
  if (fs[0] == '\0') fs = NULL;
  ShaderWrapper *w = (ShaderWrapper *)moonbit_make_external_object(
    shader_destructor, sizeof(ShaderWrapper)
  );
  w->shader = LoadShaderFromMemory(vs, fs);
  w->freed = 0;
  return w;
}

int
moonbit_raylib_is_shader_valid(ShaderWrapper *wrapper) {
  return (int)IsShaderValid(wrapper->shader);
}

int
moonbit_raylib_get_shader_location(ShaderWrapper *wrapper, moonbit_bytes_t uniformName) {
  return GetShaderLocation(wrapper->shader, (const char *)uniformName);
}

int
moonbit_raylib_get_shader_location_attrib(ShaderWrapper *wrapper, moonbit_bytes_t attribName) {
  return GetShaderLocationAttrib(wrapper->shader, (const char *)attribName);
}

void
moonbit_raylib_set_shader_value(ShaderWrapper *wrapper, int locIndex, moonbit_bytes_t value, int uniformType) {
  SetShaderValue(wrapper->shader, locIndex, (const void *)value, uniformType);
}

void
moonbit_raylib_set_shader_value_v(ShaderWrapper *wrapper, int locIndex, moonbit_bytes_t value, int uniformType, int count) {
  SetShaderValueV(wrapper->shader, locIndex, (const void *)value, uniformType, count);
}

void
moonbit_raylib_set_shader_value_matrix(ShaderWrapper *wrapper, int locIndex, moonbit_bytes_t mat) {
  Matrix m;
  memcpy(&m, mat, sizeof(Matrix));
  SetShaderValueMatrix(wrapper->shader, locIndex, m);
}

void
moonbit_raylib_set_shader_value_texture(ShaderWrapper *wrapper, int locIndex, TextureWrapper *texWrapper) {
  SetShaderValueTexture(wrapper->shader, locIndex, texWrapper->texture);
}

void
moonbit_raylib_unload_shader(ShaderWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadShader(wrapper->shader);
    wrapper->freed = 1;
  }
}

void
moonbit_raylib_begin_shader_mode(ShaderWrapper *wrapper) {
  BeginShaderMode(wrapper->shader);
}

// ============================================================================
// VR Stereo
// ============================================================================

typedef struct {
  VrStereoConfig config;
  int freed;
} VrStereoConfigWrapper;

static void
vr_stereo_config_destructor(void *ptr) {
  VrStereoConfigWrapper *w = (VrStereoConfigWrapper *)ptr;
  if (!w->freed) {
    UnloadVrStereoConfig(w->config);
  }
}

VrStereoConfigWrapper *
moonbit_raylib_load_vr_stereo_config(moonbit_bytes_t device) {
  VrDeviceInfo info;
  memcpy(&info, device, sizeof(VrDeviceInfo));
  VrStereoConfigWrapper *w = (VrStereoConfigWrapper *)moonbit_make_external_object(
    vr_stereo_config_destructor, sizeof(VrStereoConfigWrapper));
  w->config = LoadVrStereoConfig(info);
  w->freed = 0;
  return w;
}

void
moonbit_raylib_unload_vr_stereo_config(VrStereoConfigWrapper *w) {
  if (w && !w->freed) {
    UnloadVrStereoConfig(w->config);
    w->freed = 1;
  }
}

void
moonbit_raylib_begin_vr_stereo_mode(VrStereoConfigWrapper *w) {
  BeginVrStereoMode(w->config);
}
