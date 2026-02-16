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
// Textures: Image generation
// ============================================================================

ImageWrapper *
moonbit_raylib_gen_image_gradient_linear(int width, int height, int direction, moonbit_bytes_t start, moonbit_bytes_t end) {
  Color s; memcpy(&s, start, sizeof(Color));
  Color e; memcpy(&e, end, sizeof(Color));
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = GenImageGradientLinear(width, height, direction, s, e);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_gen_image_gradient_radial(int width, int height, float density, moonbit_bytes_t inner, moonbit_bytes_t outer) {
  Color i; memcpy(&i, inner, sizeof(Color));
  Color o; memcpy(&o, outer, sizeof(Color));
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = GenImageGradientRadial(width, height, density, i, o);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_gen_image_gradient_square(int width, int height, float density, moonbit_bytes_t inner, moonbit_bytes_t outer) {
  Color i; memcpy(&i, inner, sizeof(Color));
  Color o; memcpy(&o, outer, sizeof(Color));
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = GenImageGradientSquare(width, height, density, i, o);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_gen_image_white_noise(int width, int height, float factor) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = GenImageWhiteNoise(width, height, factor);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_gen_image_perlin_noise(int width, int height, int offsetX, int offsetY, float scale) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = GenImagePerlinNoise(width, height, offsetX, offsetY, scale);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_gen_image_cellular(int width, int height, int tileSize) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = GenImageCellular(width, height, tileSize);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_gen_image_text(int width, int height, moonbit_bytes_t text) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = GenImageText(width, height, (const char *)text);
  w->freed = 0;
  return w;
}

// ============================================================================
// Textures: Image loading extras
// ============================================================================

ImageWrapper *
moonbit_raylib_load_image_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t fileData, int dataSize) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = LoadImageFromMemory((const char *)fileType, (const unsigned char *)fileData, dataSize);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_load_image_from_texture(TextureWrapper *tw) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = LoadImageFromTexture(tw->texture);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_load_image_from_screen(void) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = LoadImageFromScreen();
  w->freed = 0;
  return w;
}

int
moonbit_raylib_is_image_valid(ImageWrapper *wrapper) {
  return (int)IsImageValid(wrapper->image);
}

int
moonbit_raylib_export_image(ImageWrapper *wrapper, moonbit_bytes_t fileName) {
  return (int)ExportImage(wrapper->image, (const char *)fileName);
}

// ============================================================================
// Textures: Image basic ops
// ============================================================================

ImageWrapper *
moonbit_raylib_image_copy(ImageWrapper *wrapper) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = ImageCopy(wrapper->image);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_image_from_image(ImageWrapper *wrapper, moonbit_bytes_t rec) {
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = ImageFromImage(wrapper->image, r);
  w->freed = 0;
  return w;
}

ImageWrapper *
moonbit_raylib_image_from_channel(ImageWrapper *wrapper, int selectedChannel) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = ImageFromChannel(wrapper->image, selectedChannel);
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

void
moonbit_raylib_draw_texture_npatch(
  TextureWrapper *wrapper,
  moonbit_bytes_t nPatchInfo,
  moonbit_bytes_t dest,
  moonbit_bytes_t origin,
  float rotation,
  moonbit_bytes_t tint
) {
  NPatchInfo npi; memcpy(&npi, nPatchInfo, sizeof(NPatchInfo));
  Rectangle dst; memcpy(&dst, dest, sizeof(Rectangle));
  Vector2 org; memcpy(&org, origin, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  DrawTextureNPatch(wrapper->texture, npi, dst, org, rotation, c);
}

// ============================================================================
// Textures: Texture configuration
// ============================================================================

void
moonbit_raylib_set_texture_filter(TextureWrapper *wrapper, int filter) {
  SetTextureFilter(wrapper->texture, filter);
}

void
moonbit_raylib_set_texture_wrap(TextureWrapper *wrapper, int wrap) {
  SetTextureWrap(wrapper->texture, wrap);
}

// ============================================================================
// Textures: Texture management extras
// ============================================================================

TextureWrapper *
moonbit_raylib_load_texture_cubemap(ImageWrapper *img, int layout) {
  TextureWrapper *w = (TextureWrapper *)moonbit_make_external_object(texture_destructor, sizeof(TextureWrapper));
  w->texture = LoadTextureCubemap(img->image, layout);
  w->freed = 0;
  return w;
}

void
moonbit_raylib_update_texture(TextureWrapper *wrapper, moonbit_bytes_t pixels) {
  UpdateTexture(wrapper->texture, (const void *)pixels);
}

void
moonbit_raylib_update_texture_rec(TextureWrapper *wrapper, moonbit_bytes_t rec, moonbit_bytes_t pixels) {
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  UpdateTextureRec(wrapper->texture, r, (const void *)pixels);
}

void
moonbit_raylib_gen_texture_mipmaps(TextureWrapper *wrapper) {
  GenTextureMipmaps(&wrapper->texture);
}

void
moonbit_raylib_set_shapes_texture(TextureWrapper *wrapper, moonbit_bytes_t source) {
  Rectangle r; memcpy(&r, source, sizeof(Rectangle));
  SetShapesTexture(wrapper->texture, r);
}

TextureWrapper *
moonbit_raylib_get_shapes_texture(void) {
  TextureWrapper *w = (TextureWrapper *)moonbit_make_external_object(texture_destructor, sizeof(TextureWrapper));
  w->texture = GetShapesTexture();
  w->freed = 1;  // Non-owning - don't unload
  return w;
}

moonbit_bytes_t
moonbit_raylib_get_shapes_texture_rectangle(void) {
  Rectangle r = GetShapesTextureRectangle();
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(Rectangle), 0);
  memcpy(res, &r, sizeof(Rectangle));
  return res;
}

// ============================================================================
// Textures: Clipboard image (needs image_destructor)
// ============================================================================

ImageWrapper *
moonbit_raylib_get_clipboard_image(void) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = GetClipboardImage();
  w->freed = 0;
  w->frame_count = 1;
  return w;
}
