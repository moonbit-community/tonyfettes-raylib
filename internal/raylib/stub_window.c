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
