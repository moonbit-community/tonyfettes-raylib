#include "stub_internal.h"

// ============================================================================
// Textures: Image loading (resource types)
// ============================================================================

Image *
moonbit_raylib_load_image(moonbit_bytes_t fileName) {
  Image *img = (Image *)malloc(sizeof(Image));
  *img = LoadImage((const char *)fileName);
  return img;
}

void
moonbit_raylib_unload_image(Image *img) {
  UnloadImage(*img);
  free(img);
}

Image *
moonbit_raylib_gen_image_color(int width, int height, moonbit_bytes_t color) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  Image *img = (Image *)malloc(sizeof(Image));
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
  Image *img = (Image *)malloc(sizeof(Image));
  *img = GenImageChecked(width, height, checksX, checksY, c1, c2);
  return img;
}

// ============================================================================
// Textures: Image generation
// ============================================================================

Image *
moonbit_raylib_gen_image_gradient_linear(int width, int height, int direction, moonbit_bytes_t start, moonbit_bytes_t end) {
  Color s; memcpy(&s, start, sizeof(Color));
  Color e; memcpy(&e, end, sizeof(Color));
  Image *img = (Image *)malloc(sizeof(Image));
  *img = GenImageGradientLinear(width, height, direction, s, e);
  return img;
}

Image *
moonbit_raylib_gen_image_gradient_radial(int width, int height, float density, moonbit_bytes_t inner, moonbit_bytes_t outer) {
  Color i; memcpy(&i, inner, sizeof(Color));
  Color o; memcpy(&o, outer, sizeof(Color));
  Image *img = (Image *)malloc(sizeof(Image));
  *img = GenImageGradientRadial(width, height, density, i, o);
  return img;
}

Image *
moonbit_raylib_gen_image_gradient_square(int width, int height, float density, moonbit_bytes_t inner, moonbit_bytes_t outer) {
  Color i; memcpy(&i, inner, sizeof(Color));
  Color o; memcpy(&o, outer, sizeof(Color));
  Image *img = (Image *)malloc(sizeof(Image));
  *img = GenImageGradientSquare(width, height, density, i, o);
  return img;
}

Image *
moonbit_raylib_gen_image_white_noise(int width, int height, float factor) {
  Image *img = (Image *)malloc(sizeof(Image));
  *img = GenImageWhiteNoise(width, height, factor);
  return img;
}

Image *
moonbit_raylib_gen_image_perlin_noise(int width, int height, int offsetX, int offsetY, float scale) {
  Image *img = (Image *)malloc(sizeof(Image));
  *img = GenImagePerlinNoise(width, height, offsetX, offsetY, scale);
  return img;
}

Image *
moonbit_raylib_gen_image_cellular(int width, int height, int tileSize) {
  Image *img = (Image *)malloc(sizeof(Image));
  *img = GenImageCellular(width, height, tileSize);
  return img;
}

Image *
moonbit_raylib_gen_image_text(int width, int height, moonbit_bytes_t text) {
  Image *img = (Image *)malloc(sizeof(Image));
  *img = GenImageText(width, height, (const char *)text);
  return img;
}

// ============================================================================
// Textures: Image loading extras
// ============================================================================

Image *
moonbit_raylib_load_image_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t fileData, int dataSize) {
  Image *img = (Image *)malloc(sizeof(Image));
  *img = LoadImageFromMemory((const char *)fileType, (const unsigned char *)fileData, dataSize);
  return img;
}

Image *
moonbit_raylib_load_image_from_texture(TextureWrapper *w) {
  assert(w->data && "use of unloaded texture");
  Image *img = (Image *)malloc(sizeof(Image));
  *img = LoadImageFromTexture(*w->data);
  return img;
}

Image *
moonbit_raylib_load_image_from_screen(void) {
  Image *img = (Image *)malloc(sizeof(Image));
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
  Image *copy = (Image *)malloc(sizeof(Image));
  *copy = ImageCopy(*img);
  return copy;
}

Image *
moonbit_raylib_image_from_image(Image *img, moonbit_bytes_t rec) {
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  Image *result = (Image *)malloc(sizeof(Image));
  *result = ImageFromImage(*img, r);
  return result;
}

Image *
moonbit_raylib_image_from_channel(Image *img, int selectedChannel) {
  Image *result = (Image *)malloc(sizeof(Image));
  *result = ImageFromChannel(*img, selectedChannel);
  return result;
}

// ============================================================================
// Textures: Texture loading (resource types)
// ============================================================================

TextureWrapper *
moonbit_raylib_load_texture(moonbit_bytes_t fileName) {
  TextureWrapper *w = (TextureWrapper *)malloc(sizeof(TextureWrapper));
  w->data = (Texture2D *)malloc(sizeof(Texture2D));
  *w->data = LoadTexture((const char *)fileName);
  w->is_view = false;
  w->data_owned = true;
  return w;
}

TextureWrapper *
moonbit_raylib_load_texture_from_image(Image *img) {
  TextureWrapper *w = (TextureWrapper *)malloc(sizeof(TextureWrapper));
  w->data = (Texture2D *)malloc(sizeof(Texture2D));
  *w->data = LoadTextureFromImage(*img);
  w->is_view = false;
  w->data_owned = true;
  return w;
}

int
moonbit_raylib_is_texture_valid(TextureWrapper *w) {
  assert(w->data && "use of unloaded texture");
  return (int)IsTextureValid(*w->data);
}

void
moonbit_raylib_unload_texture(TextureWrapper *w) {
  assert(w->data && "unload called on already-unloaded texture");
  if (!w->is_view) {
    UnloadTexture(*w->data);
  }
  if (w->data_owned) {
    free(w->data);
  }
  w->data = NULL;
  free(w);
}

RenderTexture *
moonbit_raylib_load_render_texture(int width, int height) {
  RenderTexture *rt = (RenderTexture *)malloc(sizeof(RenderTexture));
  *rt = LoadRenderTexture(width, height);
  return rt;
}

int
moonbit_raylib_is_render_texture_valid(RenderTexture *rt) {
  return (int)IsRenderTextureValid(*rt);
}

void
moonbit_raylib_unload_render_texture(RenderTexture *rt) {
  UnloadRenderTexture(*rt);
  free(rt);
}

// ============================================================================
// Textures: Texture drawing
// ============================================================================

void
moonbit_raylib_draw_texture(
  TextureWrapper *w,
  int posX,
  int posY,
  moonbit_bytes_t tint
) {
  assert(w->data && "use of unloaded texture");
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTexture(*w->data, posX, posY, c);
}

void
moonbit_raylib_draw_texture_v(
  TextureWrapper *w,
  moonbit_bytes_t position,
  moonbit_bytes_t tint
) {
  assert(w->data && "use of unloaded texture");
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureV(*w->data, pos, c);
}

void
moonbit_raylib_draw_texture_ex(
  TextureWrapper *w,
  moonbit_bytes_t position,
  float rotation,
  float scale,
  moonbit_bytes_t tint
) {
  assert(w->data && "use of unloaded texture");
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureEx(*w->data, pos, rotation, scale, c);
}

void
moonbit_raylib_draw_texture_rec(
  TextureWrapper *w,
  moonbit_bytes_t source,
  moonbit_bytes_t position,
  moonbit_bytes_t tint
) {
  assert(w->data && "use of unloaded texture");
  Rectangle src;
  memcpy(&src, source, sizeof(Rectangle));
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureRec(*w->data, src, pos, c);
}

void
moonbit_raylib_draw_texture_pro(
  TextureWrapper *w,
  moonbit_bytes_t source,
  moonbit_bytes_t dest,
  moonbit_bytes_t origin,
  float rotation,
  moonbit_bytes_t tint
) {
  assert(w->data && "use of unloaded texture");
  Rectangle src;
  memcpy(&src, source, sizeof(Rectangle));
  Rectangle dst;
  memcpy(&dst, dest, sizeof(Rectangle));
  Vector2 org;
  memcpy(&org, origin, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTexturePro(*w->data, src, dst, org, rotation, c);
}

void
moonbit_raylib_draw_texture_npatch(
  TextureWrapper *w,
  moonbit_bytes_t nPatchInfo,
  moonbit_bytes_t dest,
  moonbit_bytes_t origin,
  float rotation,
  moonbit_bytes_t tint
) {
  assert(w->data && "use of unloaded texture");
  NPatchInfo npi; memcpy(&npi, nPatchInfo, sizeof(NPatchInfo));
  Rectangle dst; memcpy(&dst, dest, sizeof(Rectangle));
  Vector2 org; memcpy(&org, origin, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  DrawTextureNPatch(*w->data, npi, dst, org, rotation, c);
}

// ============================================================================
// Textures: Texture configuration
// ============================================================================

void
moonbit_raylib_set_texture_filter(TextureWrapper *w, int filter) {
  assert(w->data && "use of unloaded texture");
  SetTextureFilter(*w->data, filter);
}

void
moonbit_raylib_set_texture_wrap(TextureWrapper *w, int wrap) {
  assert(w->data && "use of unloaded texture");
  SetTextureWrap(*w->data, wrap);
}

// ============================================================================
// Textures: Texture management extras
// ============================================================================

TextureWrapper *
moonbit_raylib_load_texture_cubemap(Image *img, int layout) {
  TextureWrapper *w = (TextureWrapper *)malloc(sizeof(TextureWrapper));
  w->data = (Texture2D *)malloc(sizeof(Texture2D));
  *w->data = LoadTextureCubemap(*img, layout);
  w->is_view = false;
  w->data_owned = true;
  return w;
}

void
moonbit_raylib_update_texture(TextureWrapper *w, moonbit_bytes_t pixels) {
  assert(w->data && "use of unloaded texture");
  UpdateTexture(*w->data, (const void *)pixels);
}

void
moonbit_raylib_update_texture_rec(TextureWrapper *w, moonbit_bytes_t rec, moonbit_bytes_t pixels) {
  assert(w->data && "use of unloaded texture");
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  UpdateTextureRec(*w->data, r, (const void *)pixels);
}

void
moonbit_raylib_gen_texture_mipmaps(TextureWrapper *w) {
  assert(w->data && "use of unloaded texture");
  GenTextureMipmaps(w->data);
}

void
moonbit_raylib_update_texture_from_image_frame(TextureWrapper *w, Image *img, int frame) {
  assert(w->data && "use of unloaded texture");
  int offset = img->width * img->height * 4 * frame;
  UpdateTexture(*w->data, ((unsigned char *)img->data) + offset);
}

int
moonbit_raylib_get_texture_id(TextureWrapper *w) {
  assert(w->data && "use of unloaded texture");
  return (int)w->data->id;
}

void
moonbit_raylib_set_shapes_texture(TextureWrapper *w, moonbit_bytes_t source) {
  assert(w->data && "use of unloaded texture");
  Rectangle r; memcpy(&r, source, sizeof(Rectangle));
  SetShapesTexture(*w->data, r);
}

TextureWrapper *
moonbit_raylib_get_shapes_texture(void) {
  TextureWrapper *w = (TextureWrapper *)malloc(sizeof(TextureWrapper));
  w->data = (Texture2D *)malloc(sizeof(Texture2D));
  *w->data = GetShapesTexture();
  w->is_view = true;
  w->data_owned = true;
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
// Textures: RenderTexture drawing
// ============================================================================

void
moonbit_raylib_draw_render_texture_rec(
  RenderTexture *rt,
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
  DrawTextureRec(rt->texture, src, pos, c);
}

int
moonbit_raylib_get_render_texture_width(RenderTexture *rt) {
  return rt->texture.width;
}

int
moonbit_raylib_get_render_texture_height(RenderTexture *rt) {
  return rt->texture.height;
}

void
moonbit_raylib_draw_render_texture_ex(
  RenderTexture *rt,
  moonbit_bytes_t position,
  float rotation,
  float scale,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureEx(rt->texture, pos, rotation, scale, c);
}

// ============================================================================
// Textures: Clipboard image
// ============================================================================

Image *
moonbit_raylib_get_clipboard_image(void) {
  Image *img = (Image *)malloc(sizeof(Image));
#ifdef PLATFORM_ANDROID
  *img = (Image){0};   // clipboard image not supported on Android
#else
  *img = GetClipboardImage();
#endif
  return img;
}

void
moonbit_raylib_draw_render_texture_pro(
  RenderTexture *rt,
  moonbit_bytes_t source,
  moonbit_bytes_t dest,
  moonbit_bytes_t origin,
  float rotation,
  moonbit_bytes_t tint
) {
  Rectangle src; memcpy(&src, source, sizeof(Rectangle));
  Rectangle dst; memcpy(&dst, dest, sizeof(Rectangle));
  Vector2 org; memcpy(&org, origin, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  DrawTexturePro(rt->texture, src, dst, org, rotation, c);
}

void
moonbit_raylib_set_render_texture_filter(RenderTexture *rt, int filter) {
  SetTextureFilter(rt->texture, filter);
}

// ============================================================================
// Textures: Get texture width/height
// ============================================================================

int
moonbit_raylib_get_texture_width(TextureWrapper *w) {
  assert(w->data && "use of unloaded texture");
  return w->data->width;
}

int
moonbit_raylib_get_texture_height(TextureWrapper *w) {
  assert(w->data && "use of unloaded texture");
  return w->data->height;
}

// ============================================================================
// RenderTexture: Get render texture's texture (non-owning view)
// ============================================================================

TextureWrapper *
moonbit_raylib_get_render_texture_texture(RenderTexture *rt) {
  TextureWrapper *w = (TextureWrapper *)malloc(sizeof(TextureWrapper));
  w->data = &rt->texture;
  w->is_view = true;
  w->data_owned = false;
  return w;
}

// ============================================================================
// RenderTexture: Get render texture's depth texture (non-owning view)
// ============================================================================

TextureWrapper *
moonbit_raylib_get_render_texture_depth(RenderTexture *rt) {
  TextureWrapper *w = (TextureWrapper *)malloc(sizeof(TextureWrapper));
  w->data = &rt->depth;
  w->is_view = true;
  w->data_owned = false;
  return w;
}

// ============================================================================
// RenderTexture: Get IDs for rlgl-level operations
// ============================================================================

unsigned int
moonbit_raylib_get_render_texture_fbo_id(RenderTexture *rt) {
  return rt->id;
}

unsigned int
moonbit_raylib_get_render_texture_depth_id(RenderTexture *rt) {
  return rt->depth.id;
}

// ============================================================================
// RenderTexture: Constructor from raw values
// ============================================================================

RenderTexture *moonbit_raylib_new_render_texture(
  unsigned int id,
  unsigned int tex_id, int tex_width, int tex_height, int tex_mipmaps, int tex_format,
  unsigned int depth_id, int depth_width, int depth_height, int depth_mipmaps, int depth_format
) {
  RenderTexture *rt = (RenderTexture *)malloc(sizeof(RenderTexture));
  rt->id = id;
  rt->texture = (Texture2D){ tex_id, tex_width, tex_height, tex_mipmaps, tex_format };
  rt->depth = (Texture2D){ depth_id, depth_width, depth_height, depth_mipmaps, depth_format };
  return rt;
}

// ============================================================================
// rlgl: Load texture (NULL data, for framebuffer attachments)
// ============================================================================

unsigned int
moonbit_raylib_rl_load_texture(int width, int height, int format, int mipmapCount) {
  return rlLoadTexture(NULL, width, height, format, mipmapCount);
}

// ============================================================================
// Texture from raw GL ID (non-owning, for drawing GBuffer textures)
// ============================================================================

TextureWrapper *
moonbit_raylib_texture_from_id(unsigned int id, int width, int height) {
  TextureWrapper *w = (TextureWrapper *)malloc(sizeof(TextureWrapper));
  w->data = (Texture2D *)malloc(sizeof(Texture2D));
  w->data->id = id;
  w->data->width = width;
  w->data->height = height;
  w->data->mipmaps = 1;
  w->data->format = PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
  w->is_view = true;
  w->data_owned = true;
  return w;
}
