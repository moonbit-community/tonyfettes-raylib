#include "raylib.h"
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
moonbit_raylib_begin_texture_mode(DeclareView(RenderTexture, rt)) {
  BeginTextureMode(*View(RenderTexture, rt));
}

// ============================================================================
// Shader management
// ============================================================================

Shader *
moonbit_raylib_load_shader(
  moonbit_bytes_t vsFileName,
  moonbit_bytes_t fsFileName
) {
  const char *vs = (const char *)vsFileName;
  const char *fs = (const char *)fsFileName;
  if (vs[0] == '\0')
    vs = NULL;
  if (fs[0] == '\0')
    fs = NULL;
  Shader *s = (Shader *)moonbit_make_bytes(sizeof(Shader), 0);
  *s = LoadShader(vs, fs);
  return s;
}

Shader *
moonbit_raylib_load_shader_from_memory(
  moonbit_bytes_t vsCode,
  moonbit_bytes_t fsCode
) {
  const char *vs = (const char *)vsCode;
  const char *fs = (const char *)fsCode;
  if (vs[0] == '\0')
    vs = NULL;
  if (fs[0] == '\0')
    fs = NULL;
  Shader *s = (Shader *)moonbit_make_bytes(sizeof(Shader), 0);
  *s = LoadShaderFromMemory(vs, fs);
  return s;
}

int
moonbit_raylib_is_shader_valid(Shader *s) {
  return (int)IsShaderValid(*s);
}

int
moonbit_raylib_get_shader_location(Shader *s, moonbit_bytes_t uniformName) {
  return GetShaderLocation(*s, (const char *)uniformName);
}

int
moonbit_raylib_get_shader_location_attrib(
  Shader *s,
  moonbit_bytes_t attribName
) {
  return GetShaderLocationAttrib(*s, (const char *)attribName);
}

void
moonbit_raylib_set_shader_value(
  Shader *s,
  int locIndex,
  moonbit_bytes_t value,
  int uniformType
) {
  SetShaderValue(*s, locIndex, (const void *)value, uniformType);
}

void
moonbit_raylib_set_shader_value_v(
  Shader *s,
  int locIndex,
  moonbit_bytes_t value,
  int uniformType,
  int count
) {
  SetShaderValueV(*s, locIndex, (const void *)value, uniformType, count);
}

void
moonbit_raylib_set_shader_value_matrix(
  Shader *s,
  int locIndex,
  moonbit_bytes_t mat
) {
  Matrix m;
  memcpy(&m, mat, sizeof(Matrix));
  SetShaderValueMatrix(*s, locIndex, m);
}

void
moonbit_raylib_set_shader_value_texture(Shader *s, int locIndex, DeclareView(Texture, w)) {
  SetShaderValueTexture(*s, locIndex, *View(Texture, w));
}

void
moonbit_raylib_unload_shader(Shader *s) {
  UnloadShader(*s);
}

void
moonbit_raylib_set_shader_location(Shader *s, int locIndex, int value) {
  if (locIndex >= 0 && locIndex < RL_MAX_SHADER_LOCATIONS) {
    s->locs[locIndex] = value;
  }
}

int
moonbit_raylib_get_shader_id(Shader *s) {
  return (int)s->id;
}

void
moonbit_raylib_begin_shader_mode(Shader *s) {
  BeginShaderMode(*s);
}

void
moonbit_raylib_set_shader_locs(Shader *s, int loc_index, int loc_value) {
  s->locs[loc_index] = loc_value;
}

// ============================================================================
// VR Stereo
// ============================================================================

VrStereoConfig *
moonbit_raylib_load_vr_stereo_config(moonbit_bytes_t device) {
  VrDeviceInfo info;
  memcpy(&info, device, sizeof(VrDeviceInfo));
  VrStereoConfig *cfg =
    (VrStereoConfig *)moonbit_make_bytes(sizeof(VrStereoConfig), 0);
  *cfg = LoadVrStereoConfig(info);
  return cfg;
}

void
moonbit_raylib_unload_vr_stereo_config(VrStereoConfig *cfg) {
  UnloadVrStereoConfig(*cfg);
}

void
moonbit_raylib_begin_vr_stereo_mode(VrStereoConfig *cfg) {
  BeginVrStereoMode(*cfg);
}

// VrStereoConfig field accessors (return raw bytes for use with SetShaderValue)

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_left_lens_center(VrStereoConfig *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->leftLensCenter, sizeof(float) * 2);
  return res;
}

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_right_lens_center(VrStereoConfig *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->rightLensCenter, sizeof(float) * 2);
  return res;
}

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_left_screen_center(VrStereoConfig *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->leftScreenCenter, sizeof(float) * 2);
  return res;
}

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_right_screen_center(VrStereoConfig *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->rightScreenCenter, sizeof(float) * 2);
  return res;
}

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_scale(VrStereoConfig *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->scale, sizeof(float) * 2);
  return res;
}

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_scale_in(VrStereoConfig *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->scaleIn, sizeof(float) * 2);
  return res;
}

// ============================================================================
// rlgl: Matrix getters
// ============================================================================

moonbit_bytes_t
moonbit_raylib_rl_get_matrix_modelview(void) {
  Matrix m = rlGetMatrixModelview();
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(Matrix), 0);
  memcpy(res, &m, sizeof(Matrix));
  return res;
}

moonbit_bytes_t
moonbit_raylib_rl_get_matrix_projection(void) {
  Matrix m = rlGetMatrixProjection();
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(Matrix), 0);
  memcpy(res, &m, sizeof(Matrix));
  return res;
}

// ============================================================================
// rlgl: SetUniform (low-level uniform setting)
// ============================================================================

void
moonbit_raylib_rl_set_uniform(
  int loc_index,
  moonbit_bytes_t value,
  int uniform_type,
  int count
) {
  rlSetUniform(loc_index, (const void *)value, uniform_type, count);
}

// ============================================================================
// rlgl: bool → int32_t wrappers (MoonBit Bool ABI)
// ============================================================================

int32_t
moonbit_raylib_rl_check_render_batch_limit(int32_t vCount) {
  return (int32_t)rlCheckRenderBatchLimit(vCount);
}

int32_t
moonbit_raylib_rl_framebuffer_complete(uint32_t id) {
  return (int32_t)rlFramebufferComplete(id);
}

uint32_t
moonbit_raylib_rl_load_texture_depth(
  int32_t width,
  int32_t height,
  int32_t useRenderBuffer
) {
  return rlLoadTextureDepth(width, height, (bool)useRenderBuffer);
}
