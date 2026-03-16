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
moonbit_raylib_begin_texture_mode(RenderTextureWrapper *rt) {
  BeginTextureMode(*rt->data);
}

// ============================================================================
// Shader management
// ============================================================================

ShaderWrapper *
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
  return MakeShaderWrapper(LoadShader(vs, fs));
}

ShaderWrapper *
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
  return MakeShaderWrapper(LoadShaderFromMemory(vs, fs));
}

int
moonbit_raylib_is_shader_valid(ShaderWrapper *s) {
  return (int)IsShaderValid(*s->data);
}

int
moonbit_raylib_get_shader_location(ShaderWrapper *s, moonbit_bytes_t uniformName) {
  return GetShaderLocation(*s->data, (const char *)uniformName);
}

int
moonbit_raylib_get_shader_location_attrib(
  ShaderWrapper *s,
  moonbit_bytes_t attribName
) {
  return GetShaderLocationAttrib(*s->data, (const char *)attribName);
}

void
moonbit_raylib_set_shader_value(
  ShaderWrapper *s,
  int locIndex,
  moonbit_bytes_t value,
  int uniformType
) {
  SetShaderValue(*s->data, locIndex, (const void *)value, uniformType);
}

void
moonbit_raylib_set_shader_value_v(
  ShaderWrapper *s,
  int locIndex,
  moonbit_bytes_t value,
  int uniformType,
  int count
) {
  SetShaderValueV(*s->data, locIndex, (const void *)value, uniformType, count);
}

void
moonbit_raylib_set_shader_value_matrix(
  ShaderWrapper *s,
  int locIndex,
  moonbit_bytes_t mat
) {
  Matrix m;
  memcpy(&m, mat, sizeof(Matrix));
  SetShaderValueMatrix(*s->data, locIndex, m);
}

void
moonbit_raylib_set_shader_value_texture(ShaderWrapper *s, int locIndex, TextureWrapper *w) {
  SetShaderValueTexture(*s->data, locIndex, *w->data);
}

void
moonbit_raylib_unload_shader(ShaderWrapper *s) {
  UnloadShader(*s->data);
}

void
moonbit_raylib_set_shader_location(ShaderWrapper *s, int locIndex, int value) {
  if (locIndex >= 0 && locIndex < RL_MAX_SHADER_LOCATIONS) {
    s->data->locs[locIndex] = value;
  }
}

int
moonbit_raylib_get_shader_id(ShaderWrapper *s) {
  return (int)s->data->id;
}

void
moonbit_raylib_begin_shader_mode(ShaderWrapper *s) {
  BeginShaderMode(*s->data);
}

void
moonbit_raylib_set_shader_locs(ShaderWrapper *s, int loc_index, int loc_value) {
  s->data->locs[loc_index] = loc_value;
}

// ============================================================================
// VR Stereo
// ============================================================================

VrStereoConfigWrapper *
moonbit_raylib_load_vr_stereo_config(moonbit_bytes_t device) {
  VrDeviceInfo info;
  memcpy(&info, device, sizeof(VrDeviceInfo));
  return MakeVrStereoConfigWrapper(LoadVrStereoConfig(info));
}

void
moonbit_raylib_unload_vr_stereo_config(VrStereoConfigWrapper *cfg) {
  UnloadVrStereoConfig(*cfg->data);
}

void
moonbit_raylib_begin_vr_stereo_mode(VrStereoConfigWrapper *cfg) {
  BeginVrStereoMode(*cfg->data);
}

// VrStereoConfig field accessors (return raw bytes for use with SetShaderValue)

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_left_lens_center(VrStereoConfigWrapper *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->data->leftLensCenter, sizeof(float) * 2);
  return res;
}

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_right_lens_center(VrStereoConfigWrapper *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->data->rightLensCenter, sizeof(float) * 2);
  return res;
}

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_left_screen_center(VrStereoConfigWrapper *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->data->leftScreenCenter, sizeof(float) * 2);
  return res;
}

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_right_screen_center(VrStereoConfigWrapper *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->data->rightScreenCenter, sizeof(float) * 2);
  return res;
}

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_scale(VrStereoConfigWrapper *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->data->scale, sizeof(float) * 2);
  return res;
}

moonbit_bytes_t
moonbit_raylib_vr_stereo_config_scale_in(VrStereoConfigWrapper *cfg) {
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(float) * 2, 0);
  memcpy(res, cfg->data->scaleIn, sizeof(float) * 2);
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
