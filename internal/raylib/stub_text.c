#include "stub_internal.h"

// ============================================================================
// Resource destructor: Font
// ============================================================================

static void
font_destructor(void *ptr) {
  FontWrapper *w = (FontWrapper *)ptr;
  if (!w->freed)
    UnloadFont(w->font);
}

// ============================================================================
// Text: Font loading (resource types)
// ============================================================================

FontWrapper *
moonbit_raylib_get_font_default(void) {
  FontWrapper *w = (FontWrapper *)moonbit_make_external_object(
    font_destructor, sizeof(FontWrapper)
  );
  w->font = GetFontDefault();
  w->freed = 1; // Default font should NOT be unloaded
  return w;
}

FontWrapper *
moonbit_raylib_load_font(moonbit_bytes_t fileName) {
  FontWrapper *w = (FontWrapper *)moonbit_make_external_object(
    font_destructor, sizeof(FontWrapper)
  );
  w->font = LoadFont((const char *)fileName);
  w->freed = 0;
  return w;
}

FontWrapper *
moonbit_raylib_load_font_ex(moonbit_bytes_t fileName, int fontSize) {
  FontWrapper *w = (FontWrapper *)moonbit_make_external_object(
    font_destructor, sizeof(FontWrapper)
  );
  w->font = LoadFontEx((const char *)fileName, fontSize, NULL, 0);
  w->freed = 0;
  return w;
}

int
moonbit_raylib_is_font_valid(FontWrapper *wrapper) {
  return (int)IsFontValid(wrapper->font);
}

void
moonbit_raylib_unload_font(FontWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadFont(wrapper->font);
    wrapper->freed = 1;
  }
}

// ============================================================================
// Text: Drawing
// ============================================================================

void
moonbit_raylib_draw_text(
  moonbit_bytes_t text,
  int posX,
  int posY,
  int fontSize,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawText((const char *)text, posX, posY, fontSize, c);
}

void
moonbit_raylib_draw_text_ex(
  FontWrapper *font,
  moonbit_bytes_t text,
  moonbit_bytes_t position,
  float fontSize,
  float spacing,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextEx(font->font, (const char *)text, pos, fontSize, spacing, c);
}

void
moonbit_raylib_draw_text_pro(
  FontWrapper *font,
  moonbit_bytes_t text,
  moonbit_bytes_t position,
  moonbit_bytes_t origin,
  float rotation,
  float fontSize,
  float spacing,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Vector2 org;
  memcpy(&org, origin, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextPro(
    font->font, (const char *)text, pos, org, rotation, fontSize, spacing, c
  );
}

int
moonbit_raylib_measure_text(moonbit_bytes_t text, int fontSize) {
  return MeasureText((const char *)text, fontSize);
}

moonbit_bytes_t
moonbit_raylib_measure_text_ex(
  FontWrapper *font,
  moonbit_bytes_t text,
  float fontSize,
  float spacing
) {
  Vector2 result =
    MeasureTextEx(font->font, (const char *)text, fontSize, spacing);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}
