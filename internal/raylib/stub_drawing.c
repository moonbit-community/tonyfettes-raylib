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
