#include "stub_internal.h"

// ============================================================================
// Resource destructors: Image, Texture, RenderTexture
// ============================================================================

static void
image_destructor(void *ptr) {
  ImageWrapper *w = (ImageWrapper *)ptr;
  if (!w->freed)
    UnloadImage(w->image);
}
static void
texture_destructor(void *ptr) {
  TextureWrapper *w = (TextureWrapper *)ptr;
  if (!w->freed)
    UnloadTexture(w->texture);
}
static void
render_texture_destructor(void *ptr) {
  RenderTextureWrapper *w = (RenderTextureWrapper *)ptr;
  if (!w->freed)
    UnloadRenderTexture(w->render_texture);
}

// ============================================================================
// Textures: Image loading (resource types)
// ============================================================================

ImageWrapper *
moonbit_raylib_load_image(moonbit_bytes_t fileName) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(
    image_destructor, sizeof(ImageWrapper)
  );
  w->image = LoadImage((const char *)fileName);
  w->freed = 0;
  return w;
}

void
moonbit_raylib_unload_image(ImageWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadImage(wrapper->image);
    wrapper->freed = 1;
  }
}

ImageWrapper *
moonbit_raylib_gen_image_color(int width, int height, moonbit_bytes_t color) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(
    image_destructor, sizeof(ImageWrapper)
  );
  w->image = GenImageColor(width, height, c);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_gen_image_checked(
  int width,
  int height,
  int checksX,
  int checksY,
  moonbit_bytes_t col1,
  moonbit_bytes_t col2
) {
  Color c1;
  memcpy(&c1, col1, sizeof(Color));
  Color c2;
  memcpy(&c2, col2, sizeof(Color));
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(
    image_destructor, sizeof(ImageWrapper)
  );
  w->image = GenImageChecked(width, height, checksX, checksY, c1, c2);
  w->freed = 0;
  return w;
}

// ============================================================================
// Textures: Texture loading (resource types)
// ============================================================================

TextureWrapper *
moonbit_raylib_load_texture(moonbit_bytes_t fileName) {
  TextureWrapper *w = (TextureWrapper *)moonbit_make_external_object(
    texture_destructor, sizeof(TextureWrapper)
  );
  w->texture = LoadTexture((const char *)fileName);
  w->freed = 0;
  return w;
}

TextureWrapper *
moonbit_raylib_load_texture_from_image(ImageWrapper *img) {
  TextureWrapper *w = (TextureWrapper *)moonbit_make_external_object(
    texture_destructor, sizeof(TextureWrapper)
  );
  w->texture = LoadTextureFromImage(img->image);
  w->freed = 0;
  return w;
}

int
moonbit_raylib_is_texture_valid(TextureWrapper *wrapper) {
  return (int)IsTextureValid(wrapper->texture);
}

void
moonbit_raylib_unload_texture(TextureWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadTexture(wrapper->texture);
    wrapper->freed = 1;
  }
}

RenderTextureWrapper *
moonbit_raylib_load_render_texture(int width, int height) {
  RenderTextureWrapper *w =
    (RenderTextureWrapper *)moonbit_make_external_object(
      render_texture_destructor, sizeof(RenderTextureWrapper)
    );
  w->render_texture = LoadRenderTexture(width, height);
  w->freed = 0;
  return w;
}

int
moonbit_raylib_is_render_texture_valid(RenderTextureWrapper *wrapper) {
  return (int)IsRenderTextureValid(wrapper->render_texture);
}

void
moonbit_raylib_unload_render_texture(RenderTextureWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadRenderTexture(wrapper->render_texture);
    wrapper->freed = 1;
  }
}

// ============================================================================
// Textures: Texture drawing
// ============================================================================

void
moonbit_raylib_draw_texture(
  TextureWrapper *wrapper,
  int posX,
  int posY,
  moonbit_bytes_t tint
) {
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTexture(wrapper->texture, posX, posY, c);
}

void
moonbit_raylib_draw_texture_v(
  TextureWrapper *wrapper,
  moonbit_bytes_t position,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureV(wrapper->texture, pos, c);
}

void
moonbit_raylib_draw_texture_ex(
  TextureWrapper *wrapper,
  moonbit_bytes_t position,
  float rotation,
  float scale,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureEx(wrapper->texture, pos, rotation, scale, c);
}

void
moonbit_raylib_draw_texture_rec(
  TextureWrapper *wrapper,
  moonbit_bytes_t source,
  moonbit_bytes_t position,
  moonbit_bytes_t tint
) {
  Rectangle src;
  memcpy(&src, source, sizeof(Rectangle));
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureRec(wrapper->texture, src, pos, c);
}

void
moonbit_raylib_draw_texture_pro(
  TextureWrapper *wrapper,
  moonbit_bytes_t source,
  moonbit_bytes_t dest,
  moonbit_bytes_t origin,
  float rotation,
  moonbit_bytes_t tint
) {
  Rectangle src;
  memcpy(&src, source, sizeof(Rectangle));
  Rectangle dst;
  memcpy(&dst, dest, sizeof(Rectangle));
  Vector2 org;
  memcpy(&org, origin, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTexturePro(wrapper->texture, src, dst, org, rotation, c);
}
