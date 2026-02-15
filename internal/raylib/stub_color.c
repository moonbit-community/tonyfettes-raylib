#include "stub_internal.h"

// ============================================================================
// Core: Color utilities
// ============================================================================

moonbit_bytes_t
moonbit_raylib_fade(moonbit_bytes_t color, float alpha) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  Color result = Fade(c, alpha);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &result, sizeof(Color));
  return r;
}

moonbit_bytes_t
moonbit_raylib_color_alpha(moonbit_bytes_t color, float alpha) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  Color result = ColorAlpha(c, alpha);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &result, sizeof(Color));
  return r;
}

int
moonbit_raylib_color_to_int(moonbit_bytes_t color) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  return ColorToInt(c);
}

moonbit_bytes_t
moonbit_raylib_get_color(unsigned int hexValue) {
  Color result = GetColor(hexValue);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &result, sizeof(Color));
  return r;
}

moonbit_bytes_t
moonbit_raylib_color_from_hsv(float hue, float saturation, float value) {
  Color result = ColorFromHSV(hue, saturation, value);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &result, sizeof(Color));
  return r;
}

moonbit_bytes_t
moonbit_raylib_color_tint(moonbit_bytes_t color, moonbit_bytes_t tint) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  Color t;
  memcpy(&t, tint, sizeof(Color));
  Color result = ColorTint(c, t);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &result, sizeof(Color));
  return r;
}

moonbit_bytes_t
moonbit_raylib_color_brightness(moonbit_bytes_t color, float factor) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  Color result = ColorBrightness(c, factor);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &result, sizeof(Color));
  return r;
}

moonbit_bytes_t
moonbit_raylib_color_lerp(
  moonbit_bytes_t color1,
  moonbit_bytes_t color2,
  float factor
) {
  Color c1;
  memcpy(&c1, color1, sizeof(Color));
  Color c2;
  memcpy(&c2, color2, sizeof(Color));
  Color result = ColorLerp(c1, c2, factor);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &result, sizeof(Color));
  return r;
}

int
moonbit_raylib_color_is_equal(moonbit_bytes_t col1, moonbit_bytes_t col2) {
  Color c1;
  memcpy(&c1, col1, sizeof(Color));
  Color c2;
  memcpy(&c2, col2, sizeof(Color));
  return (int)ColorIsEqual(c1, c2);
}
