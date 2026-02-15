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

// ============================================================================
// Gamepad input - string params/returns
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_gamepad_name(int gamepad) {
  const char *name = GetGamepadName(gamepad);
  int32_t len = strlen(name);
  moonbit_bytes_t r = moonbit_make_bytes(len, 0);
  memcpy(r, name, len);
  return r;
}

int
moonbit_raylib_set_gamepad_mappings(moonbit_bytes_t mappings) {
  return SetGamepadMappings((const char *)mappings);
}

// ============================================================================
// Touch input - Vector2 returns
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_touch_position(int index) {
  Vector2 v = GetTouchPosition(index);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &v, sizeof(Vector2));
  return r;
}

// ============================================================================
// Gesture input - Vector2 returns
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_gesture_drag_vector(void) {
  Vector2 v = GetGestureDragVector();
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &v, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_gesture_pinch_vector(void) {
  Vector2 v = GetGesturePinchVector();
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &v, sizeof(Vector2));
  return r;
}
