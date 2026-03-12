#include "moonbit.h"
#include "raylib.h"
#include "stub_internal.h"

// ============================================================================
// Textures: Image loading (resource types)
// ============================================================================

Image *
moonbit_raylib_load_image(moonbit_bytes_t fileName) {
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = LoadImage((const char *)fileName);
  return img;
}

void
moonbit_raylib_unload_image(Image *img) {
  UnloadImage(*img);
}

Image *
moonbit_raylib_gen_image_color(int width, int height, moonbit_bytes_t color) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = GenImageColor(width, height, c);
  return img;
}

Image *
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
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = GenImageChecked(width, height, checksX, checksY, c1, c2);
  return img;
}

// ============================================================================
// Textures: Image generation
// ============================================================================

Image *
moonbit_raylib_gen_image_gradient_linear(
  int width,
  int height,
  int direction,
  moonbit_bytes_t start,
  moonbit_bytes_t end
) {
  Color s;
  memcpy(&s, start, sizeof(Color));
  Color e;
  memcpy(&e, end, sizeof(Color));
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = GenImageGradientLinear(width, height, direction, s, e);
  return img;
}

Image *
moonbit_raylib_gen_image_gradient_radial(
  int width,
  int height,
  float density,
  moonbit_bytes_t inner,
  moonbit_bytes_t outer
) {
  Color i;
  memcpy(&i, inner, sizeof(Color));
  Color o;
  memcpy(&o, outer, sizeof(Color));
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = GenImageGradientRadial(width, height, density, i, o);
  return img;
}

Image *
moonbit_raylib_gen_image_gradient_square(
  int width,
  int height,
  float density,
  moonbit_bytes_t inner,
  moonbit_bytes_t outer
) {
  Color i;
  memcpy(&i, inner, sizeof(Color));
  Color o;
  memcpy(&o, outer, sizeof(Color));
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = GenImageGradientSquare(width, height, density, i, o);
  return img;
}

Image *
moonbit_raylib_gen_image_white_noise(int width, int height, float factor) {
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = GenImageWhiteNoise(width, height, factor);
  return img;
}

Image *
moonbit_raylib_gen_image_perlin_noise(
  int width,
  int height,
  int offsetX,
  int offsetY,
  float scale
) {
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = GenImagePerlinNoise(width, height, offsetX, offsetY, scale);
  return img;
}

Image *
moonbit_raylib_gen_image_cellular(int width, int height, int tileSize) {
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = GenImageCellular(width, height, tileSize);
  return img;
}

Image *
moonbit_raylib_gen_image_text(int width, int height, moonbit_bytes_t text) {
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = GenImageText(width, height, (const char *)text);
  return img;
}

// ============================================================================
// Textures: Image loading extras
// ============================================================================

Image *
moonbit_raylib_load_image_from_memory(
  moonbit_bytes_t fileType,
  moonbit_bytes_t fileData,
  int dataSize
) {
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = LoadImageFromMemory(
    (const char *)fileType, (const unsigned char *)fileData, dataSize
  );
  return img;
}

Image *
moonbit_raylib_load_image_from_texture(DeclareView(Texture, w)) {
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = LoadImageFromTexture(*View(Texture, w));
  return img;
}

Image *
moonbit_raylib_load_image_from_screen(void) {
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *img = LoadImageFromScreen();
  return img;
}

int
moonbit_raylib_is_image_valid(Image *img) {
  return (int)IsImageValid(*img);
}

int
moonbit_raylib_export_image(Image *img, moonbit_bytes_t fileName) {
  return (int)ExportImage(*img, (const char *)fileName);
}

// ============================================================================
// Textures: Image basic ops
// ============================================================================

Image *
moonbit_raylib_image_copy(Image *img) {
  Image *copy = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *copy = ImageCopy(*img);
  return copy;
}

Image *
moonbit_raylib_image_from_image(Image *img, moonbit_bytes_t rec) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  Image *result = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *result = ImageFromImage(*img, r);
  return result;
}

Image *
moonbit_raylib_image_from_channel(Image *img, int selectedChannel) {
  Image *result = (Image *)moonbit_make_bytes(sizeof(Image), 0);
  *result = ImageFromChannel(*img, selectedChannel);
  return result;
}

// ============================================================================
// Textures: Texture loading (resource types)
// ============================================================================

Texture *
moonbit_raylib_load_texture(moonbit_bytes_t fileName) {
  Texture *texture = (Texture *)moonbit_make_bytes(sizeof(Texture), 0);
  *texture = LoadTexture((const char *)fileName);
  return texture;
}

Texture *
moonbit_raylib_load_texture_from_image(Image *img) {
  Texture *texture = (Texture *)moonbit_make_bytes(sizeof(Texture), 0);
  *texture = LoadTextureFromImage(*img);
  return texture;
}

int32_t
moonbit_raylib_is_texture_valid(DeclareView(Texture, w)) {
  return (int32_t)IsTextureValid(*View(Texture, w));
}

void
moonbit_raylib_unload_texture(DeclareView(Texture, w)) {
  UnloadTexture(*View(Texture, w));
}

RenderTexture *
moonbit_raylib_load_render_texture(int width, int height) {
  RenderTexture *rt =
    (RenderTexture *)moonbit_make_bytes(sizeof(RenderTexture), 0);
  *rt = LoadRenderTexture(width, height);
  return rt;
}

int
moonbit_raylib_is_render_texture_valid(DeclareView(RenderTexture, rt)) {
  return (int)IsRenderTextureValid(*View(RenderTexture, rt));
}

void
moonbit_raylib_unload_render_texture(DeclareView(RenderTexture, rt)) {
  UnloadRenderTexture(*View(RenderTexture, rt));
}

// ============================================================================
// Textures: Texture drawing
// ============================================================================

void
moonbit_raylib_draw_texture(
  DeclareView(Texture, w),
  int posX,
  int posY,
  moonbit_bytes_t tint
) {
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTexture(*View(Texture, w), posX, posY, c);
}

void
moonbit_raylib_draw_texture_v(
  DeclareView(Texture, w),
  moonbit_bytes_t position,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureV(*View(Texture, w), pos, c);
}

void
moonbit_raylib_draw_texture_ex(
  DeclareView(Texture, w),
  moonbit_bytes_t position,
  float rotation,
  float scale,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureEx(*View(Texture, w), pos, rotation, scale, c);
}

void
moonbit_raylib_draw_texture_rec(
  DeclareView(Texture, w),
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
  DrawTextureRec(*View(Texture, w), src, pos, c);
}

void
moonbit_raylib_draw_texture_pro(
  DeclareView(Texture, w),
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
  DrawTexturePro(*View(Texture, w), src, dst, org, rotation, c);
}

void
moonbit_raylib_draw_texture_npatch(
  DeclareView(Texture, w),
  moonbit_bytes_t nPatchInfo,
  moonbit_bytes_t dest,
  moonbit_bytes_t origin,
  float rotation,
  moonbit_bytes_t tint
) {
  NPatchInfo npi;
  memcpy(&npi, nPatchInfo, sizeof(NPatchInfo));
  Rectangle dst;
  memcpy(&dst, dest, sizeof(Rectangle));
  Vector2 org;
  memcpy(&org, origin, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureNPatch(*View(Texture, w), npi, dst, org, rotation, c);
}

// ============================================================================
// Textures: Texture configuration
// ============================================================================

void
moonbit_raylib_set_texture_filter(DeclareView(Texture, w), int filter) {
  SetTextureFilter(*View(Texture, w), filter);
}

void
moonbit_raylib_set_texture_wrap(DeclareView(Texture, w), int wrap) {
  SetTextureWrap(*View(Texture, w), wrap);
}

// ============================================================================
// Textures: Texture management extras
// ============================================================================

Texture *
moonbit_raylib_load_texture_cubemap(Image *img, int layout) {
  Texture *texture = (Texture *)moonbit_make_bytes(sizeof(Texture), 0);
  *texture = LoadTextureCubemap(*img, layout);
  return texture;
}

void
moonbit_raylib_update_texture(DeclareView(Texture, w), moonbit_bytes_t pixels) {
  UpdateTexture(*View(Texture, w), (const void *)pixels);
}

void
moonbit_raylib_update_texture_rec(
  DeclareView(Texture, w),
  moonbit_bytes_t rec,
  moonbit_bytes_t pixels
) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  UpdateTextureRec(*View(Texture, w), r, (const void *)pixels);
}

void
moonbit_raylib_gen_texture_mipmaps(DeclareView(Texture, w)) {
  GenTextureMipmaps(View(Texture, w));
}

void
moonbit_raylib_update_texture_from_image_frame(
  DeclareView(Texture, w),
  Image *img,
  int frame
) {
  int offset = img->width * img->height * 4 * frame;
  UpdateTexture(*View(Texture, w), ((unsigned char *)img->data) + offset);
}

uint32_t
moonbit_raylib_get_texture_id(DeclareView(Texture, w)) {
  return (uint32_t)View(Texture, w)->id;
}

void
moonbit_raylib_set_shapes_texture(
  DeclareView(Texture, w),
  moonbit_bytes_t source
) {
  Rectangle r;
  memcpy(&r, source, sizeof(Rectangle));
  SetShapesTexture(*View(Texture, w), r);
}

Texture *
moonbit_raylib_get_shapes_texture(void) {
  Texture *texture = (Texture *)moonbit_make_bytes(sizeof(Texture), 0);
  *texture = GetShapesTexture();
  return texture;
}

moonbit_bytes_t
moonbit_raylib_get_shapes_texture_rectangle(void) {
  Rectangle r = GetShapesTextureRectangle();
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(Rectangle), 0);
  memcpy(res, &r, sizeof(Rectangle));
  return res;
}

// ============================================================================
// Textures: RenderTexture drawing
// ============================================================================

void
moonbit_raylib_draw_render_texture_rec(
  DeclareView(RenderTexture, rt),
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
  DrawTextureRec(View(RenderTexture, rt)->texture, src, pos, c);
}

int
moonbit_raylib_get_render_texture_width(DeclareView(RenderTexture, rt)) {
  return View(RenderTexture, rt)->texture.width;
}

int
moonbit_raylib_get_render_texture_height(DeclareView(RenderTexture, rt)) {
  return View(RenderTexture, rt)->texture.height;
}

void
moonbit_raylib_draw_render_texture_ex(
  DeclareView(RenderTexture, rt),
  moonbit_bytes_t position,
  float rotation,
  float scale,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureEx(View(RenderTexture, rt)->texture, pos, rotation, scale, c);
}

// ============================================================================
// Textures: Clipboard image
// ============================================================================

Image *
moonbit_raylib_get_clipboard_image(void) {
  Image *img = (Image *)moonbit_make_bytes(sizeof(Image), 0);
#ifdef PLATFORM_ANDROID
  *img = (Image){0}; // clipboard image not supported on Android
#else
  *img = GetClipboardImage();
#endif
  return img;
}

void
moonbit_raylib_draw_render_texture_pro(
  DeclareView(RenderTexture, rt),
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
  DrawTexturePro(View(RenderTexture, rt)->texture, src, dst, org, rotation, c);
}

void
moonbit_raylib_set_render_texture_filter(DeclareView(RenderTexture, rt), int filter) {
  SetTextureFilter(View(RenderTexture, rt)->texture, filter);
}

// ============================================================================
// Textures: Get texture width/height
// ============================================================================

int32_t
moonbit_raylib_get_texture_width(DeclareView(Texture, w)) {
  return View(Texture, w)->width;
}

int32_t
moonbit_raylib_get_texture_height(DeclareView(Texture, w)) {
  return View(Texture, w)->height;
}

// ============================================================================
// RenderTexture: Get render texture's texture (non-owning view)
// ============================================================================

int32_t
moonbit_raylib_get_render_texture_texture(void) {
  return (int32_t)offsetof(RenderTexture, texture);
}

// ============================================================================
// RenderTexture: Get render texture's depth texture (non-owning view)
// ============================================================================

int32_t
moonbit_raylib_get_render_texture_depth(void) {
  return (int32_t)offsetof(RenderTexture, depth);
}

// ============================================================================
// RenderTexture: Get IDs for rlgl-level operations
// ============================================================================

uint32_t
moonbit_raylib_get_render_texture_id(DeclareView(RenderTexture, rt)) {
  return View(RenderTexture, rt)->id;
}

unsigned int
moonbit_raylib_get_render_texture_depth_id(DeclareView(RenderTexture, rt)) {
  return View(RenderTexture, rt)->depth.id;
}

// ============================================================================
// RenderTexture: Constructor from raw values
// ============================================================================

RenderTexture *
moonbit_raylib_new_render_texture(
  unsigned int id,
  DeclareView(Texture, texture),
  DeclareView(Texture, depth)
) {
  RenderTexture *rt =
    (RenderTexture *)moonbit_make_bytes(sizeof(RenderTexture), 0);
  rt->id = id;
  rt->texture = *View(Texture, texture);
  rt->depth = *View(Texture, depth);
  return rt;
}

// ============================================================================
// rlgl: Load texture (NULL data, for framebuffer attachments)
// ============================================================================

unsigned int
moonbit_raylib_rl_load_texture(
  int width,
  int height,
  int format,
  int mipmapCount
) {
  return rlLoadTexture(NULL, width, height, format, mipmapCount);
}

// ============================================================================
// Texture from raw GL ID (non-owning, for drawing GBuffer textures)
// ============================================================================

Texture *
moonbit_raylib_new_texture(
  uint32_t id,
  int32_t width,
  int32_t height,
  int32_t mipmaps,
  int32_t format
) {
  Texture *texture = (Texture *)moonbit_make_bytes(sizeof(Texture), 0);
  *texture = (Texture){
    .id = id,
    .width = width,
    .height = height,
    .mipmaps = mipmaps,
    .format = format,
  };
  return texture;
}
