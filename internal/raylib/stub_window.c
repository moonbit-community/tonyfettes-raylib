#include "stub_internal.h"

static char *
moonbit_raylib_copy_bytes_to_cstr(moonbit_bytes_t bytes) {
  int32_t len = Moonbit_array_length(bytes);
  char *cstr = (char *)libc_malloc((size_t)len + 1);
  if (len > 0) memcpy(cstr, bytes, (size_t)len);
  cstr[len] = '\0';
  return cstr;
}

// ============================================================================
// Core: Window management
// ============================================================================

void
moonbit_raylib_init_window(int width, int height, moonbit_bytes_t title) {
  char *title_cstr = moonbit_raylib_copy_bytes_to_cstr(title);
  InitWindow(width, height, (const char *)title_cstr);
  libc_free(title_cstr);
}

void
moonbit_raylib_set_window_title(moonbit_bytes_t title) {
  char *title_cstr = moonbit_raylib_copy_bytes_to_cstr(title);
  SetWindowTitle((const char *)title_cstr);
  libc_free(title_cstr);
}

// ============================================================================
// Core: Logging
// ============================================================================

void
moonbit_raylib_trace_log(int logLevel, moonbit_bytes_t text) {
  char *text_cstr = moonbit_raylib_copy_bytes_to_cstr(text);
  TraceLog(logLevel, "%s", (const char *)text_cstr);
  libc_free(text_cstr);
}

// ============================================================================
// Core: Misc (string params)
// ============================================================================

void
moonbit_raylib_take_screenshot(moonbit_bytes_t fileName) {
  char *file_name_cstr = moonbit_raylib_copy_bytes_to_cstr(fileName);
  TakeScreenshot((const char *)file_name_cstr);
  libc_free(file_name_cstr);
}

void
moonbit_raylib_open_url(moonbit_bytes_t url) {
  char *url_cstr = moonbit_raylib_copy_bytes_to_cstr(url);
  OpenURL((const char *)url_cstr);
  libc_free(url_cstr);
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
  char *text_cstr = moonbit_raylib_copy_bytes_to_cstr(text);
  SetClipboardText((const char *)text_cstr);
  libc_free(text_cstr);
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
moonbit_raylib_set_window_icon(ImageWrapper *wrapper) {
  SetWindowIcon(wrapper->image);
}
