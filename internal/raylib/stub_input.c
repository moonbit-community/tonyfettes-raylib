#include "stub_internal.h"

// ============================================================================
// Core: Input - returns structs
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_mouse_position(void) {
  Vector2 v = GetMousePosition();
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &v, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_mouse_delta(void) {
  Vector2 v = GetMouseDelta();
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &v, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_mouse_wheel_move_v(void) {
  Vector2 v = GetMouseWheelMoveV();
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &v, sizeof(Vector2));
  return r;
}
