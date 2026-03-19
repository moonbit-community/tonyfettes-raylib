#include "stub_internal.h"

// ============================================================================
// rlgl: Bool returns (bool → int32_t)
// ============================================================================

int32_t
moonbit_raylib_rl_enable_vertex_array(uint32_t vaoId) {
  return (int32_t)rlEnableVertexArray(vaoId);
}

int32_t
moonbit_raylib_rl_is_stereo_render_enabled(void) {
  return (int32_t)rlIsStereoRenderEnabled();
}

// ============================================================================
// rlgl: Bool params (int32_t → bool)
// ============================================================================

void
moonbit_raylib_rl_color_mask(
  int32_t r,
  int32_t g,
  int32_t b,
  int32_t a
) {
  rlColorMask((bool)r, (bool)g, (bool)b, (bool)a);
}

void
moonbit_raylib_rl_bind_image_texture(
  uint32_t id,
  uint32_t index,
  int format,
  int32_t readonly
) {
  rlBindImageTexture(id, index, format, (bool)readonly);
}

void
moonbit_raylib_rl_set_vertex_attribute(
  uint32_t index,
  int compSize,
  int type,
  int32_t normalized,
  int stride,
  int offset
) {
  rlSetVertexAttribute(index, compSize, type, (bool)normalized, stride, offset);
}

// ============================================================================
// rlgl: Bool + void* params
// ============================================================================

uint32_t
moonbit_raylib_rl_load_vertex_buffer(
  moonbit_bytes_t buffer,
  int size,
  int32_t dynamic
) {
  return rlLoadVertexBuffer((const void *)buffer, size, (bool)dynamic);
}

uint32_t
moonbit_raylib_rl_load_vertex_buffer_element(
  moonbit_bytes_t buffer,
  int size,
  int32_t dynamic
) {
  return rlLoadVertexBufferElement((const void *)buffer, size, (bool)dynamic);
}

// ============================================================================
// rlgl: void* data params (Bytes → const void*)
// ============================================================================

void
moonbit_raylib_rl_update_vertex_buffer(
  uint32_t bufferId,
  moonbit_bytes_t data,
  int dataSize,
  int offset
) {
  rlUpdateVertexBuffer(bufferId, (const void *)data, dataSize, offset);
}

void
moonbit_raylib_rl_update_vertex_buffer_elements(
  uint32_t id,
  moonbit_bytes_t data,
  int dataSize,
  int offset
) {
  rlUpdateVertexBufferElements(id, (const void *)data, dataSize, offset);
}

void
moonbit_raylib_rl_set_vertex_attribute_default(
  int locIndex,
  moonbit_bytes_t value,
  int attribType,
  int count
) {
  rlSetVertexAttributeDefault(locIndex, (const void *)value, attribType, count);
}

uint32_t
moonbit_raylib_rl_load_texture_cubemap(
  moonbit_bytes_t data,
  int size,
  int format,
  int mipmapCount
) {
  return rlLoadTextureCubemap((const void *)data, size, format, mipmapCount);
}

void
moonbit_raylib_rl_update_texture(
  uint32_t id,
  int offsetX,
  int offsetY,
  int width,
  int height,
  int format,
  moonbit_bytes_t data
) {
  rlUpdateTexture(id, offsetX, offsetY, width, height, format, (const void *)data);
}

uint32_t
moonbit_raylib_rl_load_shader_buffer(
  uint32_t size,
  moonbit_bytes_t data,
  int usageHint
) {
  return rlLoadShaderBuffer(size, (const void *)data, usageHint);
}

uint32_t
moonbit_raylib_rl_load_shader_buffer_empty(
  uint32_t size,
  int usageHint
) {
  return rlLoadShaderBuffer(size, NULL, usageHint);
}

void
moonbit_raylib_rl_update_shader_buffer(
  uint32_t id,
  moonbit_bytes_t data,
  uint32_t dataSize,
  uint32_t offset
) {
  rlUpdateShaderBuffer(id, (const void *)data, dataSize, offset);
}

moonbit_bytes_t
moonbit_raylib_rl_read_shader_buffer(
  uint32_t id,
  uint32_t count,
  uint32_t offset
) {
  moonbit_bytes_t res = moonbit_make_bytes(count, 0);
  rlReadShaderBuffer(id, (void *)res, count, offset);
  return res;
}

// ============================================================================
// rlgl: DrawVertexArrayElements — NULL buffer (EBO path)
// ============================================================================

void
moonbit_raylib_rl_draw_vertex_array_elements(
  int offset,
  int count
) {
  rlDrawVertexArrayElements(offset, count, NULL);
}

void
moonbit_raylib_rl_draw_vertex_array_elements_instanced(
  int offset,
  int count,
  int instances
) {
  rlDrawVertexArrayElementsInstanced(offset, count, NULL, instances);
}

// ============================================================================
// rlgl: DrawVertexArrayElements — client-side UShortArray buffer
// ============================================================================

void
moonbit_raylib_rl_draw_vertex_array_elements_client(
  int offset,
  int count,
  unsigned short *buffer
) {
  rlDrawVertexArrayElements(offset, count, (const void *)buffer);
}

void
moonbit_raylib_rl_draw_vertex_array_elements_instanced_client(
  int offset,
  int count,
  unsigned short *buffer,
  int instances
) {
  rlDrawVertexArrayElementsInstanced(offset, count, (const void *)buffer, instances);
}

// ============================================================================
// rlgl: String params (const char* — check for empty → NULL)
// ============================================================================

uint32_t
moonbit_raylib_rl_load_shader_code(
  moonbit_bytes_t vsCode,
  moonbit_bytes_t fsCode
) {
  const char *vs = (const char *)vsCode;
  const char *fs = (const char *)fsCode;
  if (vs[0] == '\0') vs = NULL;
  if (fs[0] == '\0') fs = NULL;
  return rlLoadShaderCode(vs, fs);
}

// ============================================================================
// rlgl: Matrix returns (Matrix → Bytes)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_rl_get_matrix_transform(void) {
  Matrix m = rlGetMatrixTransform();
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(Matrix), 0);
  memcpy(res, &m, sizeof(Matrix));
  return res;
}

moonbit_bytes_t
moonbit_raylib_rl_get_matrix_projection_stereo(int eye) {
  Matrix m = rlGetMatrixProjectionStereo(eye);
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(Matrix), 0);
  memcpy(res, &m, sizeof(Matrix));
  return res;
}

moonbit_bytes_t
moonbit_raylib_rl_get_matrix_view_offset_stereo(int eye) {
  Matrix m = rlGetMatrixViewOffsetStereo(eye);
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(Matrix), 0);
  memcpy(res, &m, sizeof(Matrix));
  return res;
}

// ============================================================================
// rlgl: Matrix params (Bytes → Matrix)
// ============================================================================

void
moonbit_raylib_rl_set_matrix_projection(moonbit_bytes_t proj) {
  Matrix p;
  memcpy(&p, proj, sizeof(Matrix));
  rlSetMatrixProjection(p);
}

void
moonbit_raylib_rl_set_matrix_modelview(moonbit_bytes_t view) {
  Matrix v;
  memcpy(&v, view, sizeof(Matrix));
  rlSetMatrixModelview(v);
}

void
moonbit_raylib_rl_set_uniform_matrix(int locIndex, moonbit_bytes_t mat) {
  Matrix m;
  memcpy(&m, mat, sizeof(Matrix));
  rlSetUniformMatrix(locIndex, m);
}

// ============================================================================
// rlgl: Matrix×2 params
// ============================================================================

void
moonbit_raylib_rl_set_matrix_projection_stereo(
  moonbit_bytes_t right,
  moonbit_bytes_t left
) {
  Matrix r, l;
  memcpy(&r, right, sizeof(Matrix));
  memcpy(&l, left, sizeof(Matrix));
  rlSetMatrixProjectionStereo(r, l);
}

void
moonbit_raylib_rl_set_matrix_view_offset_stereo(
  moonbit_bytes_t right,
  moonbit_bytes_t left
) {
  Matrix r, l;
  memcpy(&r, right, sizeof(Matrix));
  memcpy(&l, left, sizeof(Matrix));
  rlSetMatrixViewOffsetStereo(r, l);
}

// ============================================================================
// rlgl: Matrix* array param
// ============================================================================

void
moonbit_raylib_rl_set_uniform_matrices(
  int locIndex,
  moonbit_bytes_t mat,
  int count
) {
  rlSetUniformMatrices(locIndex, (const Matrix *)mat, count);
}
