#include "stub_internal.h"

// ============================================================================
// Core: Camera
// ============================================================================

moonbit_bytes_t
moonbit_raylib_update_camera(moonbit_bytes_t camera_bytes, int mode) {
  Camera3D camera;
  memcpy(&camera, camera_bytes, sizeof(Camera3D));
  UpdateCamera(&camera, mode);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Camera3D), 0);
  memcpy(r, &camera, sizeof(Camera3D));
  return r;
}

moonbit_bytes_t
moonbit_raylib_update_camera_pro(
  moonbit_bytes_t camera_bytes,
  moonbit_bytes_t movement,
  moonbit_bytes_t rotation,
  float zoom
) {
  Camera3D camera;
  memcpy(&camera, camera_bytes, sizeof(Camera3D));
  Vector3 mov;
  memcpy(&mov, movement, sizeof(Vector3));
  Vector3 rot;
  memcpy(&rot, rotation, sizeof(Vector3));
  UpdateCameraPro(&camera, mov, rot, zoom);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Camera3D), 0);
  memcpy(r, &camera, sizeof(Camera3D));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_world_to_screen(
  moonbit_bytes_t position,
  moonbit_bytes_t camera
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Camera3D cam;
  memcpy(&cam, camera, sizeof(Camera3D));
  Vector2 result = GetWorldToScreen(pos, cam);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_screen_to_world_2d(
  moonbit_bytes_t position,
  moonbit_bytes_t camera
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Camera2D cam;
  memcpy(&cam, camera, sizeof(Camera2D));
  Vector2 result = GetScreenToWorld2D(pos, cam);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_world_to_screen_2d(
  moonbit_bytes_t position,
  moonbit_bytes_t camera
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Camera2D cam;
  memcpy(&cam, camera, sizeof(Camera2D));
  Vector2 result = GetWorldToScreen2D(pos, cam);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

// ============================================================================
// Camera matrix
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_camera_matrix(moonbit_bytes_t camera) {
  Camera3D cam;
  memcpy(&cam, camera, sizeof(Camera3D));
  Matrix result = GetCameraMatrix(cam);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Matrix), 0);
  memcpy(r, &result, sizeof(Matrix));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_camera_matrix_2d(moonbit_bytes_t camera) {
  Camera2D cam;
  memcpy(&cam, camera, sizeof(Camera2D));
  Matrix result = GetCameraMatrix2D(cam);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Matrix), 0);
  memcpy(r, &result, sizeof(Matrix));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_screen_to_world_ray(moonbit_bytes_t position, moonbit_bytes_t camera) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Camera3D cam;
  memcpy(&cam, camera, sizeof(Camera3D));
  Ray result = GetScreenToWorldRay(pos, cam);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Ray), 0);
  memcpy(r, &result, sizeof(Ray));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_world_to_screen_ex(moonbit_bytes_t position, moonbit_bytes_t camera, int width, int height) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Camera3D cam;
  memcpy(&cam, camera, sizeof(Camera3D));
  Vector2 result = GetWorldToScreenEx(pos, cam, width, height);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}
