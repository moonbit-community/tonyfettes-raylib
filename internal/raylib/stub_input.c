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

// ============================================================================
// Core: Input bool → int32_t wrappers (MoonBit Bool ABI)
// ============================================================================

// Cursor

int32_t
moonbit_raylib_is_cursor_hidden(void) {
  return (int32_t)IsCursorHidden();
}

int32_t
moonbit_raylib_is_cursor_on_screen(void) {
  return (int32_t)IsCursorOnScreen();
}

// Keyboard

int32_t
moonbit_raylib_is_key_pressed(int32_t key) {
  return (int32_t)IsKeyPressed(key);
}

int32_t
moonbit_raylib_is_key_pressed_repeat(int32_t key) {
  return (int32_t)IsKeyPressedRepeat(key);
}

int32_t
moonbit_raylib_is_key_down(int32_t key) {
  return (int32_t)IsKeyDown(key);
}

int32_t
moonbit_raylib_is_key_released(int32_t key) {
  return (int32_t)IsKeyReleased(key);
}

int32_t
moonbit_raylib_is_key_up(int32_t key) {
  return (int32_t)IsKeyUp(key);
}

// Mouse

int32_t
moonbit_raylib_is_mouse_button_pressed(int32_t button) {
  return (int32_t)IsMouseButtonPressed(button);
}

int32_t
moonbit_raylib_is_mouse_button_down(int32_t button) {
  return (int32_t)IsMouseButtonDown(button);
}

int32_t
moonbit_raylib_is_mouse_button_released(int32_t button) {
  return (int32_t)IsMouseButtonReleased(button);
}

int32_t
moonbit_raylib_is_mouse_button_up(int32_t button) {
  return (int32_t)IsMouseButtonUp(button);
}

// Gamepad

int32_t
moonbit_raylib_is_gamepad_available(int32_t gamepad) {
  return (int32_t)IsGamepadAvailable(gamepad);
}

int32_t
moonbit_raylib_is_gamepad_button_pressed(int32_t gamepad, int32_t button) {
  return (int32_t)IsGamepadButtonPressed(gamepad, button);
}

int32_t
moonbit_raylib_is_gamepad_button_down(int32_t gamepad, int32_t button) {
  return (int32_t)IsGamepadButtonDown(gamepad, button);
}

int32_t
moonbit_raylib_is_gamepad_button_released(int32_t gamepad, int32_t button) {
  return (int32_t)IsGamepadButtonReleased(gamepad, button);
}

int32_t
moonbit_raylib_is_gamepad_button_up(int32_t gamepad, int32_t button) {
  return (int32_t)IsGamepadButtonUp(gamepad, button);
}

// Gesture

int32_t
moonbit_raylib_is_gesture_detected(int32_t gesture) {
  return (int32_t)IsGestureDetected(gesture);
}
