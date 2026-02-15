#include "stub_internal.h"

// ============================================================================
// Core: Window management
// ============================================================================

void
moonbit_raylib_init_window(int width, int height, moonbit_bytes_t title) {
  InitWindow(width, height, (const char *)title);
}

void
moonbit_raylib_set_window_title(moonbit_bytes_t title) {
  SetWindowTitle((const char *)title);
}

// ============================================================================
// Core: Misc (string params)
// ============================================================================

void
moonbit_raylib_take_screenshot(moonbit_bytes_t fileName) {
  TakeScreenshot((const char *)fileName);
}

void
moonbit_raylib_open_url(moonbit_bytes_t url) {
  OpenURL((const char *)url);
}

// ============================================================================
// Core: Window state (Vector2 returns)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_window_position(void) {
  Vector2 result = GetWindowPosition();
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_window_scale_dpi(void) {
  Vector2 result = GetWindowScaleDPI();
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

// ============================================================================
// Core: Monitor management (Vector2/String returns)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_monitor_position(int monitor) {
  Vector2 result = GetMonitorPosition(monitor);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_monitor_name(int monitor) {
  const char *str = GetMonitorName(monitor);
  int32_t len = strlen(str);
  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  memcpy(bytes, str, len);
  return bytes;
}

// ============================================================================
// Core: Clipboard
// ============================================================================

void
moonbit_raylib_set_clipboard_text(moonbit_bytes_t text) {
  SetClipboardText((const char *)text);
}

moonbit_bytes_t
moonbit_raylib_get_clipboard_text(void) {
  const char *str = GetClipboardText();
  int32_t len = strlen(str);
  moonbit_bytes_t bytes = moonbit_make_bytes(len, 0);
  memcpy(bytes, str, len);
  return bytes;
}
