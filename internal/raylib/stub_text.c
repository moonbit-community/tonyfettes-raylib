#include "stub_internal.h"
#include <stdlib.h>

// ============================================================================
// Text: Font loading (resource types)
// ============================================================================

Font *
moonbit_raylib_get_font_default(void) {
  Font *f = (Font *)malloc(sizeof(Font));
  *f = GetFontDefault();
  return f;
}

Font *
moonbit_raylib_load_font(moonbit_bytes_t fileName) {
  Font *f = (Font *)malloc(sizeof(Font));
  *f = LoadFont((const char *)fileName);
  return f;
}

Font *
moonbit_raylib_load_font_ex(moonbit_bytes_t fileName, int fontSize) {
  Font *f = (Font *)malloc(sizeof(Font));
  *f = LoadFontEx((const char *)fileName, fontSize, NULL, 0);
  return f;
}

Font *
moonbit_raylib_load_font_ex_codepoints(moonbit_bytes_t fileName, int fontSize, moonbit_bytes_t codepoints, int codepointCount) {
  Font *f = (Font *)malloc(sizeof(Font));
  *f = LoadFontEx((const char *)fileName, fontSize, (int *)codepoints, codepointCount);
  return f;
}

int
moonbit_raylib_is_font_valid(Font *f) {
  return (int)IsFontValid(*f);
}

void
moonbit_raylib_unload_font(Font *f) {
  if (f) {
    UnloadFont(*f);
    free(f);
  }
}

int
moonbit_raylib_get_font_base_size(Font *f) {
  return f->baseSize;
}

int
moonbit_raylib_get_font_glyph_count(Font *f) {
  return f->glyphCount;
}

int
moonbit_raylib_get_font_glyph_padding(Font *f) {
  return f->glyphPadding;
}

Texture2D *
moonbit_raylib_get_font_texture(Font *f) {
  return &f->texture;
}

void
moonbit_raylib_gen_font_texture_mipmaps(Font *f) {
  GenTextureMipmaps(&f->texture);
}

void
moonbit_raylib_set_font_texture_filter(Font *f, int filter) {
  SetTextureFilter(f->texture, filter);
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
  Font *f,
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
  DrawTextEx(*f, (const char *)text, pos, fontSize, spacing, c);
}

void
moonbit_raylib_draw_text_pro(
  Font *f,
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
    *f, (const char *)text, pos, org, rotation, fontSize, spacing, c
  );
}

int
moonbit_raylib_measure_text(moonbit_bytes_t text, int fontSize) {
  return MeasureText((const char *)text, fontSize);
}

moonbit_bytes_t
moonbit_raylib_measure_text_ex(
  Font *f,
  moonbit_bytes_t text,
  float fontSize,
  float spacing
) {
  Vector2 result =
    MeasureTextEx(*f, (const char *)text, fontSize, spacing);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

// ============================================================================
// Text extras
// ============================================================================

void
moonbit_raylib_draw_text_codepoint(Font *f, int codepoint, moonbit_bytes_t position, float fontSize, moonbit_bytes_t tint) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextCodepoint(*f, codepoint, pos, fontSize, c);
}

int
moonbit_raylib_get_glyph_index(Font *f, int codepoint) {
  return GetGlyphIndex(*f, codepoint);
}

moonbit_bytes_t
moonbit_raylib_get_glyph_atlas_rec(Font *f, int codepoint) {
  Rectangle result = GetGlyphAtlasRec(*f, codepoint);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Rectangle), 0);
  memcpy(r, &result, sizeof(Rectangle));
  return r;
}

// ============================================================================
// Text: Font loading extras
// ============================================================================

Font *
moonbit_raylib_load_font_from_image(Image *img, moonbit_bytes_t key, int firstChar) {
  Color k; memcpy(&k, key, sizeof(Color));
  Font *f = (Font *)malloc(sizeof(Font));
  *f = LoadFontFromImage(*img, k, firstChar);
  return f;
}

Font *
moonbit_raylib_load_font_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t fileData, int dataSize, int fontSize) {
  Font *f = (Font *)malloc(sizeof(Font));
  *f = LoadFontFromMemory((const char *)fileType, (const unsigned char *)fileData, dataSize, fontSize, NULL, 0);
  return f;
}

int
moonbit_raylib_export_font_as_code(Font *f, moonbit_bytes_t fileName) {
  return (int)ExportFontAsCode(*f, (const char *)fileName);
}

// ============================================================================
// Text: Drawing extras
// ============================================================================

void
moonbit_raylib_draw_text_codepoints(Font *f, moonbit_bytes_t codepoints, int codepointCount, moonbit_bytes_t position, float fontSize, float spacing, moonbit_bytes_t tint) {
  int *cp = (int *)codepoints;
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  DrawTextCodepoints(*f, cp, codepointCount, pos, fontSize, spacing, c);
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
  if (!codepoints) return moonbit_make_bytes(0, 0);
  moonbit_bytes_t result = moonbit_make_bytes(4 + count * 4, 0);
  memcpy(result, &count, 4);
  memcpy(result + 4, codepoints, count * 4);
  UnloadCodepoints(codepoints);
  return result;
}

moonbit_bytes_t
moonbit_raylib_load_utf8(moonbit_bytes_t codepoints, int length) {
  char *text = LoadUTF8((const int *)codepoints, length);
  if (!text) return moonbit_make_bytes(0, 0);
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
moonbit_raylib_get_glyph_info(Font *f, int codepoint) {
  GlyphInfo info = GetGlyphInfo(*f, codepoint);
  moonbit_bytes_t result = moonbit_make_bytes(16, 0);
  memcpy(result, &info.value, 4);
  memcpy(result + 4, &info.offsetX, 4);
  memcpy(result + 8, &info.offsetY, 4);
  memcpy(result + 12, &info.advanceX, 4);
  return result;
}

// GlyphInfoArray wrapper for LoadFontData / UnloadFontData

GlyphInfoArrayWrapper *
moonbit_raylib_load_font_data(moonbit_bytes_t fileData, int dataSize, int fontSize, int type) {
  GlyphInfoArrayWrapper *w = (GlyphInfoArrayWrapper *)malloc(sizeof(GlyphInfoArrayWrapper));
  // codepointCount=0, codepoints=NULL loads default character set (95 glyphs)
  w->glyphs = LoadFontData((const unsigned char *)fileData, dataSize, fontSize, NULL, 0, type);
  w->count = w->glyphs ? 95 : 0; // default character set is 95 glyphs
  return w;
}

void
moonbit_raylib_unload_font_data(GlyphInfoArrayWrapper *w) {
  if (w) {
    if (w->glyphs) {
      UnloadFontData(w->glyphs, w->count);
    }
    free(w);
  }
}

int
moonbit_raylib_glyph_info_array_count(GlyphInfoArrayWrapper *wrapper) {
  return wrapper->count;
}

moonbit_bytes_t
moonbit_raylib_glyph_info_array_get(GlyphInfoArrayWrapper *wrapper, int index) {
  moonbit_bytes_t result = moonbit_make_bytes(16, 0);
  if (index < 0 || index >= wrapper->count || !wrapper->glyphs) return result;
  GlyphInfo *info = &wrapper->glyphs[index];
  memcpy(result, &info->value, 4);
  memcpy(result + 4, &info->offsetX, 4);
  memcpy(result + 8, &info->offsetY, 4);
  memcpy(result + 12, &info->advanceX, 4);
  return result;
}

Image *
moonbit_raylib_gen_image_font_atlas(GlyphInfoArrayWrapper *glyphs, int fontSize, int padding, int packMethod) {
  Rectangle *recs = NULL;
  Image atlas = GenImageFontAtlas(glyphs->glyphs, &recs, glyphs->count, fontSize, padding, packMethod);
  // recs is allocated by GenImageFontAtlas but we don't expose it for now; free it
  if (recs) MemFree(recs);
  Image *img = (Image *)malloc(sizeof(Image));
  *img = atlas;
  return img;
}

// Build a Font from raw embedded atlas data (used by raygui binary style loading).
// pixelData: raw image pixels (GRAY_ALPHA format typically)
// imgWidth, imgHeight, imgFormat: image dimensions and pixel format
// recsData: packed array of Rectangles (4 floats each: x, y, w, h), count = glyphCount
// glyphsData: packed array of glyph info (4 ints each: value, offsetX, offsetY, advanceX), count = glyphCount
Font *
moonbit_raylib_load_font_from_atlas(
  moonbit_bytes_t pixelData, int pixelDataSize,
  int imgWidth, int imgHeight, int imgFormat,
  int baseSize, int glyphCount, int fontType,
  moonbit_bytes_t recsData, moonbit_bytes_t glyphsData
) {
  // Construct Image from raw pixel data
  Image imFont = { 0 };
  imFont.width = imgWidth;
  imFont.height = imgHeight;
  imFont.format = imgFormat;
  imFont.mipmaps = 1;
  imFont.data = RL_CALLOC(pixelDataSize, 1);
  memcpy(imFont.data, pixelData, pixelDataSize);

  // Load texture from image
  Texture2D texture = LoadTextureFromImage(imFont);
  RL_FREE(imFont.data);

  if (texture.id == 0) {
    // Failed to load texture, return default font
    Font *f = (Font *)malloc(sizeof(Font));
    *f = GetFontDefault();
    return f;
  }

  // Build recs array from packed data
  Rectangle *recs = (Rectangle *)RL_CALLOC(glyphCount, sizeof(Rectangle));
  for (int i = 0; i < glyphCount; i++) {
    float x, y, w, h;
    memcpy(&x, (unsigned char *)recsData + i * 16, sizeof(float));
    memcpy(&y, (unsigned char *)recsData + i * 16 + 4, sizeof(float));
    memcpy(&w, (unsigned char *)recsData + i * 16 + 8, sizeof(float));
    memcpy(&h, (unsigned char *)recsData + i * 16 + 12, sizeof(float));
    recs[i] = (Rectangle){ x, y, w, h };
  }

  // Build glyphs array from packed data
  GlyphInfo *glyphs = (GlyphInfo *)RL_CALLOC(glyphCount, sizeof(GlyphInfo));
  for (int i = 0; i < glyphCount; i++) {
    int value, offsetX, offsetY, advanceX;
    memcpy(&value, (unsigned char *)glyphsData + i * 16, sizeof(int));
    memcpy(&offsetX, (unsigned char *)glyphsData + i * 16 + 4, sizeof(int));
    memcpy(&offsetY, (unsigned char *)glyphsData + i * 16 + 8, sizeof(int));
    memcpy(&advanceX, (unsigned char *)glyphsData + i * 16 + 12, sizeof(int));
    glyphs[i].value = value;
    glyphs[i].offsetX = offsetX;
    glyphs[i].offsetY = offsetY;
    glyphs[i].advanceX = advanceX;
    glyphs[i].image = (Image){ 0 }; // Individual glyph images not needed
  }

  // Assemble the Font
  Font font = { 0 };
  font.baseSize = baseSize;
  font.glyphCount = glyphCount;
  font.glyphPadding = 0;
  font.texture = texture;
  font.recs = recs;
  font.glyphs = glyphs;

  Font *f = (Font *)malloc(sizeof(Font));
  *f = font;
  return f;
}

Font *
moonbit_raylib_build_font_from_data(moonbit_bytes_t fileData, int dataSize, int fontSize, int fontType, int padding, int packMethod) {
  // Load glyph data from font file in memory
  GlyphInfo *glyphs = LoadFontData((const unsigned char *)fileData, dataSize, fontSize, NULL, 0, fontType);
  if (!glyphs) return NULL;

  int glyphCount = 95; // default character set

  // Generate font atlas image and rectangle array
  Rectangle *recs = NULL;
  Image atlas = GenImageFontAtlas(glyphs, &recs, glyphCount, fontSize, padding, packMethod);

  // Load texture from atlas image
  Texture2D texture = LoadTextureFromImage(atlas);
  UnloadImage(atlas);

  // Assemble the Font struct
  Font font = { 0 };
  font.baseSize = fontSize;
  font.glyphCount = glyphCount;
  font.glyphPadding = padding;
  font.glyphs = glyphs;
  font.recs = recs;
  font.texture = texture;

  Font *f = (Font *)malloc(sizeof(Font));
  *f = font;
  return f;
}
