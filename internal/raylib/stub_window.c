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
// Core: Logging
// ============================================================================

void
moonbit_raylib_trace_log(int logLevel, moonbit_bytes_t text) {
  TraceLog(logLevel, "%s", (const char *)text);
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

// ============================================================================
// Core: Window icon
// ============================================================================

void
moonbit_raylib_set_window_icon(ImageWrapper *image) {
  SetWindowIcon(*image->data);
}

// ============================================================================
// Core: Window state (bool → int32_t wrappers for MoonBit Bool ABI)
// ============================================================================

int32_t
moonbit_raylib_window_should_close(void) {
  return (int32_t)WindowShouldClose();
}

int32_t
moonbit_raylib_is_window_ready(void) {
  return (int32_t)IsWindowReady();
}

int32_t
moonbit_raylib_is_window_fullscreen(void) {
  return (int32_t)IsWindowFullscreen();
}

int32_t
moonbit_raylib_is_window_hidden(void) {
  return (int32_t)IsWindowHidden();
}

int32_t
moonbit_raylib_is_window_minimized(void) {
  return (int32_t)IsWindowMinimized();
}

int32_t
moonbit_raylib_is_window_maximized(void) {
  return (int32_t)IsWindowMaximized();
}

int32_t
moonbit_raylib_is_window_focused(void) {
  return (int32_t)IsWindowFocused();
}

int32_t
moonbit_raylib_is_window_resized(void) {
  return (int32_t)IsWindowResized();
}

int32_t
moonbit_raylib_is_window_state(int32_t flag) {
  return (int32_t)IsWindowState(flag);
}
