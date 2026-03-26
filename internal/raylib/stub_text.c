#include "moonbit.h"
#include "raylib.h"
#include "stub_internal.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// ============================================================================
// Text: Font loading (resource types)
// ============================================================================

FontWrapper *
moonbit_raylib_get_font_default(void) {
  return MakeFontWrapper(GetFontDefault());
}

FontWrapper *
moonbit_raylib_load_font(moonbit_bytes_t fileName) {
  return MakeFontWrapper(LoadFont((const char *)fileName));
}

FontWrapper *
moonbit_raylib_load_font_ex(
  moonbit_bytes_t fileName,
  int fontSize,
  int32_t *codepoints,
  int32_t codepointCount
) {
  return MakeFontWrapper(LoadFontEx((const char *)fileName, fontSize, codepoints, codepointCount));
}

int
moonbit_raylib_is_font_valid(FontWrapper *f) {
  return (int)IsFontValid(*f->data);
}

void
moonbit_raylib_unload_font(FontWrapper *f) {
  UnloadFont(*f->data);
}

int
moonbit_raylib_get_font_base_size(FontWrapper *f) {
  return f->data->baseSize;
}

int
moonbit_raylib_get_font_glyph_count(FontWrapper *f) {
  return f->data->glyphCount;
}

int
moonbit_raylib_get_font_glyph_padding(FontWrapper *f) {
  return f->data->glyphPadding;
}

TextureWrapper *
moonbit_raylib_get_font_texture(FontWrapper *f) {
  return MakeTextureWrapperView(&f->data->texture, f);
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
  FontWrapper *f,
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
  DrawTextEx(*f->data, (const char *)text, pos, fontSize, spacing, c);
}

void
moonbit_raylib_draw_text_pro(
  FontWrapper *f,
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
  DrawTextPro(*f->data, (const char *)text, pos, org, rotation, fontSize, spacing, c);
}

int
moonbit_raylib_measure_text(moonbit_bytes_t text, int fontSize) {
  return MeasureText((const char *)text, fontSize);
}

moonbit_bytes_t
moonbit_raylib_measure_text_ex(
  FontWrapper *f,
  moonbit_bytes_t text,
  float fontSize,
  float spacing
) {
  Vector2 result = MeasureTextEx(*f->data, (const char *)text, fontSize, spacing);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

// ============================================================================
// Text extras
// ============================================================================

void
moonbit_raylib_draw_text_codepoint(
  FontWrapper *f,
  int codepoint,
  moonbit_bytes_t position,
  float fontSize,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextCodepoint(*f->data, codepoint, pos, fontSize, c);
}

int
moonbit_raylib_get_glyph_index(FontWrapper *f, int codepoint) {
  return GetGlyphIndex(*f->data, codepoint);
}

moonbit_bytes_t
moonbit_raylib_get_glyph_atlas_rec(FontWrapper *f, int codepoint) {
  Rectangle result = GetGlyphAtlasRec(*f->data, codepoint);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Rectangle), 0);
  memcpy(r, &result, sizeof(Rectangle));
  return r;
}

// ============================================================================
// Text: Font loading extras
// ============================================================================

FontWrapper *
moonbit_raylib_load_font_from_image(
  ImageWrapper *img,
  moonbit_bytes_t key,
  int firstChar
) {
  Color k;
  memcpy(&k, key, sizeof(Color));
  return MakeFontWrapper(LoadFontFromImage(*img->data, k, firstChar));
}

FontWrapper *
moonbit_raylib_load_font_from_memory(
  moonbit_bytes_t fileType,
  moonbit_bytes_t fileData,
  int dataSize,
  int fontSize
) {
  return MakeFontWrapper(LoadFontFromMemory(
    (const char *)fileType, (const unsigned char *)fileData, dataSize, fontSize,
    NULL, 0
  ));
}

int
moonbit_raylib_export_font_as_code(FontWrapper *f, moonbit_bytes_t fileName) {
  return (int)ExportFontAsCode(*f->data, (const char *)fileName);
}

// ============================================================================
// Text: Drawing extras
// ============================================================================

void
moonbit_raylib_draw_text_codepoints(
  FontWrapper *f,
  moonbit_bytes_t codepoints,
  int codepointCount,
  moonbit_bytes_t position,
  float fontSize,
  float spacing,
  moonbit_bytes_t tint
) {
  int *cp = (int *)codepoints;
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextCodepoints(*f->data, cp, codepointCount, pos, fontSize, spacing, c);
}

// ============================================================================
// Text: Codepoint functions
// ============================================================================

int
moonbit_raylib_get_codepoint_count(moonbit_bytes_t text) {
  return GetCodepointCount((const char *)text);
}

moonbit_bytes_t
moonbit_raylib_get_codepoint(moonbit_bytes_t text) {
  int codepointSize = 0;
  int codepoint = GetCodepoint((const char *)text, &codepointSize);
  moonbit_bytes_t result = moonbit_make_bytes(8, 0);
  memcpy(result, &codepoint, 4);
  memcpy(result + 4, &codepointSize, 4);
  return result;
}

moonbit_bytes_t
moonbit_raylib_get_codepoint_next(moonbit_bytes_t text) {
  int codepointSize = 0;
  int codepoint = GetCodepointNext((const char *)text, &codepointSize);
  moonbit_bytes_t result = moonbit_make_bytes(8, 0);
  memcpy(result, &codepoint, 4);
  memcpy(result + 4, &codepointSize, 4);
  return result;
}

moonbit_bytes_t
moonbit_raylib_get_codepoint_previous(moonbit_bytes_t text) {
  int codepointSize = 0;
  int codepoint = GetCodepointPrevious((const char *)text, &codepointSize);
  moonbit_bytes_t result = moonbit_make_bytes(8, 0);
  memcpy(result, &codepoint, 4);
  memcpy(result + 4, &codepointSize, 4);
  return result;
}

moonbit_bytes_t
moonbit_raylib_codepoint_to_utf8(int codepoint) {
  int utf8Size = 0;
  const char *utf8 = CodepointToUTF8(codepoint, &utf8Size);
  moonbit_bytes_t result = moonbit_make_bytes(utf8Size, 0);
  memcpy(result, utf8, utf8Size);
  return result;
}

moonbit_bytes_t
moonbit_raylib_load_codepoints(moonbit_bytes_t text) {
  int count = 0;
  int *codepoints = LoadCodepoints((const char *)text, &count);
  if (!codepoints)
    return moonbit_make_bytes(0, 0);
  moonbit_bytes_t result = moonbit_make_bytes(4 + count * 4, 0);
  memcpy(result, &count, 4);
  memcpy(result + 4, codepoints, count * 4);
  UnloadCodepoints(codepoints);
  return result;
}

moonbit_bytes_t
moonbit_raylib_load_utf8(moonbit_bytes_t codepoints, int length) {
  char *text = LoadUTF8((const int *)codepoints, length);
  if (!text)
    return moonbit_make_bytes(0, 0);
  int len = (int)strlen(text);
  moonbit_bytes_t result = moonbit_make_bytes(len, 0);
  memcpy(result, text, len);
  UnloadUTF8(text);
  return result;
}

// ============================================================================
// Text: Advanced font / GlyphInfo functions
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_glyph_info(FontWrapper *f, int codepoint) {
  GlyphInfo info = GetGlyphInfo(*f->data, codepoint);
  moonbit_bytes_t result = moonbit_make_bytes(16, 0);
  memcpy(result, &info.value, 4);
  memcpy(result + 4, &info.offsetX, 4);
  memcpy(result + 8, &info.offsetY, 4);
  memcpy(result + 12, &info.advanceX, 4);
  return result;
}

// GlyphInfoArray wrapper for LoadFontData / UnloadFontData

GlyphInfoArrayWrapper *
moonbit_raylib_load_font_data(
  moonbit_bytes_t fileData,
  int dataSize,
  int fontSize,
  int type
) {
  // codepointCount=0, codepoints=NULL loads default character set (95 glyphs)
  GlyphInfo *glyphs = LoadFontData(
    (const unsigned char *)fileData, dataSize, fontSize, NULL, 0, type
  );
  int count = glyphs ? 95 : 0; // default character set is 95 glyphs
  return MakeGlyphInfoArrayWrapper(glyphs, count);
}

void
moonbit_raylib_unload_font_data(GlyphInfoArrayWrapper *w) {
  if (w) {
    if (w->glyphs) {
      UnloadFontData(w->glyphs, w->count);
    }
  }
}

int
moonbit_raylib_glyph_info_array_count(GlyphInfoArrayWrapper *wrapper) {
  return wrapper->count;
}

moonbit_bytes_t
moonbit_raylib_glyph_info_array_get(GlyphInfoArrayWrapper *wrapper, int index) {
  moonbit_bytes_t result = moonbit_make_bytes(16, 0);
  if (index < 0 || index >= wrapper->count || !wrapper->glyphs)
    return result;
  GlyphInfo *info = &wrapper->glyphs[index];
  memcpy(result, &info->value, 4);
  memcpy(result + 4, &info->offsetX, 4);
  memcpy(result + 8, &info->offsetY, 4);
  memcpy(result + 12, &info->advanceX, 4);
  return result;
}

ImageWrapper *
moonbit_raylib_gen_image_font_atlas(
  GlyphInfoArrayWrapper *glyphs,
  int fontSize,
  int padding,
  int packMethod,
  moonbit_bytes_t *out_recs
) {
  Rectangle *recs = NULL;
  Image atlas = GenImageFontAtlas(
    glyphs->glyphs, &recs, glyphs->count, fontSize, padding, packMethod
  );
  // Pack recs into Bytes for MoonBit
  int size = glyphs->count * (int)sizeof(Rectangle);
  moonbit_bytes_t recs_bytes = moonbit_make_bytes(size, 0);
  if (recs) {
    memcpy(recs_bytes, recs, size);
    MemFree(recs);
  }
  *out_recs = recs_bytes;
  return MakeImageWrapper(atlas);
}

// Allocate an empty GlyphInfoArray of the given size.
GlyphInfoArrayWrapper *
moonbit_raylib_new_glyph_info_array(int count) {
  GlyphInfo *glyphs = (GlyphInfo *)RL_CALLOC(count, sizeof(GlyphInfo));
  return MakeGlyphInfoArrayWrapper(glyphs, count);
}

// Set a glyph at the given index.
void
moonbit_raylib_glyph_info_array_set(
  GlyphInfoArrayWrapper *w,
  int index,
  int value,
  int offsetX,
  int offsetY,
  int advanceX
) {
  if (index >= 0 && index < w->count) {
    w->glyphs[index].value = value;
    w->glyphs[index].offsetX = offsetX;
    w->glyphs[index].offsetY = offsetY;
    w->glyphs[index].advanceX = advanceX;
    w->glyphs[index].image = (Image){0};
  }
}

// Assemble a Font from its components. Copies the glyphs and recs data.
// The texture value is copied — caller should not unload it separately.
FontWrapper *
moonbit_raylib_new_font(
  TextureWrapper *tex,
  int baseSize,
  int glyphPadding,
  GlyphInfoArrayWrapper *glyphs,
  moonbit_bytes_t recsData
) {
  int glyphCount = glyphs->count;

  // Copy glyphs (zero out images to prevent double-free)
  GlyphInfo *glyphsCopy = (GlyphInfo *)RL_CALLOC(glyphCount, sizeof(GlyphInfo));
  memcpy(glyphsCopy, glyphs->glyphs, glyphCount * sizeof(GlyphInfo));
  for (int i = 0; i < glyphCount; i++) {
    glyphsCopy[i].image = (Image){0};
  }

  // Copy recs from packed bytes
  Rectangle *recs = (Rectangle *)RL_CALLOC(glyphCount, sizeof(Rectangle));
  memcpy(recs, recsData, glyphCount * sizeof(Rectangle));

  // Assemble the Font
  Font font = {0};
  font.baseSize = baseSize;
  font.glyphCount = glyphCount;
  font.glyphPadding = glyphPadding;
  font.texture = *tex->data;
  font.recs = recs;
  font.glyphs = glyphsCopy;

  return MakeFontWrapper(font);
}
