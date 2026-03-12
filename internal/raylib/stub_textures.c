#include "moonbit.h"
#include "raylib.h"
#include "stub_internal.h"

// ============================================================================
// Textures: Image loading (resource types)
// ============================================================================

ImageWrapper *
moonbit_raylib_load_image(moonbit_bytes_t fileName) {
  return MakeImageWrapper(LoadImage((const char *)fileName));
}

void
moonbit_raylib_unload_image(ImageWrapper *img) {
  UnloadImage(*img->data);
}

ImageWrapper *
moonbit_raylib_gen_image_color(int width, int height, moonbit_bytes_t color) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  return MakeImageWrapper(GenImageColor(width, height, c));
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
  return MakeImageWrapper(
    GenImageChecked(width, height, checksX, checksY, c1, c2)
  );
}

// ============================================================================
// Textures: Image generation
// ============================================================================

ImageWrapper *
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
  return MakeImageWrapper(
    GenImageGradientLinear(width, height, direction, s, e)
  );
}

ImageWrapper *
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
  return MakeImageWrapper(GenImageGradientRadial(width, height, density, i, o)
  );
}

ImageWrapper *
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
  return MakeImageWrapper(GenImageGradientSquare(width, height, density, i, o)
  );
}

ImageWrapper *
moonbit_raylib_gen_image_white_noise(int width, int height, float factor) {
  return MakeImageWrapper(GenImageWhiteNoise(width, height, factor));
}

ImageWrapper *
moonbit_raylib_gen_image_perlin_noise(
  int width,
  int height,
  int offsetX,
  int offsetY,
  float scale
) {
  return MakeImageWrapper(
    GenImagePerlinNoise(width, height, offsetX, offsetY, scale)
  );
}

ImageWrapper *
moonbit_raylib_gen_image_cellular(int width, int height, int tileSize) {
  return MakeImageWrapper(GenImageCellular(width, height, tileSize));
}

ImageWrapper *
moonbit_raylib_gen_image_text(int width, int height, moonbit_bytes_t text) {
  return MakeImageWrapper(GenImageText(width, height, (const char *)text));
}

// ============================================================================
// Textures: Image loading extras
// ============================================================================

ImageWrapper *
moonbit_raylib_load_image_from_memory(
  moonbit_bytes_t fileType,
  moonbit_bytes_t fileData,
  int dataSize
) {
  return MakeImageWrapper(LoadImageFromMemory(
    (const char *)fileType, (const unsigned char *)fileData, dataSize
  ));
}

ImageWrapper *
moonbit_raylib_load_image_from_texture(TextureWrapper *w) {
  return MakeImageWrapper(LoadImageFromTexture(*w->data));
}

ImageWrapper *
moonbit_raylib_load_image_from_screen(void) {
  return MakeImageWrapper(LoadImageFromScreen());
}

int
moonbit_raylib_is_image_valid(ImageWrapper *img) {
  return (int)IsImageValid(*img->data);
}

int
moonbit_raylib_export_image(ImageWrapper *img, moonbit_bytes_t fileName) {
  return (int)ExportImage(*img->data, (const char *)fileName);
}

// ============================================================================
// Textures: Image basic ops
// ============================================================================

ImageWrapper *
moonbit_raylib_image_copy(ImageWrapper *img) {
  return MakeImageWrapper(ImageCopy(*img->data));
}

ImageWrapper *
moonbit_raylib_image_from_image(ImageWrapper *img, moonbit_bytes_t rec) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  return MakeImageWrapper(ImageFromImage(*img->data, r));
}

ImageWrapper *
moonbit_raylib_image_from_channel(ImageWrapper *img, int selectedChannel) {
  return MakeImageWrapper(ImageFromChannel(*img->data, selectedChannel));
}

// ============================================================================
// Textures: Texture loading (resource types)
// ============================================================================

TextureWrapper *
moonbit_raylib_load_texture(moonbit_bytes_t fileName) {
  return MakeTextureWrapper(LoadTexture((const char *)fileName));
}

TextureWrapper *
moonbit_raylib_load_texture_from_image(ImageWrapper *img) {
  return MakeTextureWrapper(LoadTextureFromImage(*img->data));
}

int32_t
moonbit_raylib_is_texture_valid(TextureWrapper *w) {
  return (int32_t)IsTextureValid(*w->data);
}

void
moonbit_raylib_unload_texture(TextureWrapper *w) {
  UnloadTexture(*w->data);
}

RenderTextureWrapper *
moonbit_raylib_load_render_texture(int width, int height) {
  return MakeRenderTextureWrapper(LoadRenderTexture(width, height));
}

int
moonbit_raylib_is_render_texture_valid(RenderTextureWrapper *rt) {
  return (int)IsRenderTextureValid(*rt->data);
}

void
moonbit_raylib_unload_render_texture(RenderTextureWrapper *rt) {
  UnloadRenderTexture(*rt->data);
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
  NPatchInfo npi;
  memcpy(&npi, nPatchInfo, sizeof(NPatchInfo));
  Rectangle dst;
  memcpy(&dst, dest, sizeof(Rectangle));
  Vector2 org;
  memcpy(&org, origin, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureNPatch(*w->data, npi, dst, org, rotation, c);
}

// ============================================================================
// Textures: Texture configuration
// ============================================================================

void
moonbit_raylib_set_texture_filter(TextureWrapper *w, int filter) {
  SetTextureFilter(*w->data, filter);
}

void
moonbit_raylib_set_texture_wrap(TextureWrapper *w, int wrap) {
  SetTextureWrap(*w->data, wrap);
}

// ============================================================================
// Textures: Texture management extras
// ============================================================================

TextureWrapper *
moonbit_raylib_load_texture_cubemap(ImageWrapper *img, int layout) {
  return MakeTextureWrapper(LoadTextureCubemap(*img->data, layout));
}

void
moonbit_raylib_update_texture(TextureWrapper *w, moonbit_bytes_t pixels) {
  UpdateTexture(*w->data, (const void *)pixels);
}

void
moonbit_raylib_update_texture_rec(
  TextureWrapper *w,
  moonbit_bytes_t rec,
  moonbit_bytes_t pixels
) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  UpdateTextureRec(*w->data, r, (const void *)pixels);
}

void
moonbit_raylib_gen_texture_mipmaps(TextureWrapper *w) {
  GenTextureMipmaps(w->data);
}

void
moonbit_raylib_update_texture_from_image_frame(
  TextureWrapper *w,
  ImageWrapper *img,
  int frame
) {
  int offset = img->data->width * img->data->height * 4 * frame;
  UpdateTexture(*w->data, ((unsigned char *)img->data->data) + offset);
}

uint32_t
moonbit_raylib_get_texture_id(TextureWrapper *w) {
  return (uint32_t)w->data->id;
}

void
moonbit_raylib_set_shapes_texture(TextureWrapper *w, moonbit_bytes_t source) {
  Rectangle r;
  memcpy(&r, source, sizeof(Rectangle));
  SetShapesTexture(*w->data, r);
}

TextureWrapper *
moonbit_raylib_get_shapes_texture(void) {
  return MakeTextureWrapper(GetShapesTexture());
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
  RenderTextureWrapper *rt,
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
  DrawTextureRec(rt->data->texture, src, pos, c);
}

int
moonbit_raylib_get_render_texture_width(RenderTextureWrapper *rt) {
  return rt->data->texture.width;
}

int
moonbit_raylib_get_render_texture_height(RenderTextureWrapper *rt) {
  return rt->data->texture.height;
}

void
moonbit_raylib_draw_render_texture_ex(
  RenderTextureWrapper *rt,
  moonbit_bytes_t position,
  float rotation,
  float scale,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureEx(rt->data->texture, pos, rotation, scale, c);
}

// ============================================================================
// Textures: Clipboard image
// ============================================================================

ImageWrapper *
moonbit_raylib_get_clipboard_image(void) {
#ifdef PLATFORM_ANDROID
  return MakeImageWrapper((Image){0}
  ); // clipboard image not supported on Android
#else
  return MakeImageWrapper(GetClipboardImage());
#endif
}

void
moonbit_raylib_draw_render_texture_pro(
  RenderTextureWrapper *rt,
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
  DrawTexturePro(rt->data->texture, src, dst, org, rotation, c);
}

void
moonbit_raylib_set_render_texture_filter(RenderTextureWrapper *rt, int filter) {
  SetTextureFilter(rt->data->texture, filter);
}

// ============================================================================
// Textures: Get texture width/height
// ============================================================================

int32_t
moonbit_raylib_get_texture_width(TextureWrapper *w) {
  return w->data->width;
}

int32_t
moonbit_raylib_get_texture_height(TextureWrapper *w) {
  return w->data->height;
}

// ============================================================================
// RenderTexture: Get render texture's texture (non-owning view)
// ============================================================================

TextureWrapper *
moonbit_raylib_get_render_texture_texture(RenderTextureWrapper *rt) {
  return MakeTextureWrapperView(&rt->data->texture, rt);
}

// ============================================================================
// RenderTexture: Get render texture's depth texture (non-owning view)
// ============================================================================

TextureWrapper *
moonbit_raylib_get_render_texture_depth(RenderTextureWrapper *rt) {
  return MakeTextureWrapperView(&rt->data->depth, rt);
}

// ============================================================================
// RenderTexture: Get IDs for rlgl-level operations
// ============================================================================

uint32_t
moonbit_raylib_get_render_texture_id(RenderTextureWrapper *rt) {
  return rt->data->id;
}

unsigned int
moonbit_raylib_get_render_texture_depth_id(RenderTextureWrapper *rt) {
  return rt->data->depth.id;
}

// ============================================================================
// RenderTexture: Constructor from raw values
// ============================================================================

RenderTextureWrapper *
moonbit_raylib_new_render_texture(
  unsigned int id,
  TextureWrapper *texture,
  TextureWrapper *depth
) {
  RenderTexture rt;
  rt.id = id;
  rt.texture = *texture->data;
  rt.depth = *depth->data;
  return MakeRenderTextureWrapper(rt);
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

TextureWrapper *
moonbit_raylib_new_texture(
  uint32_t id,
  int32_t width,
  int32_t height,
  int32_t mipmaps,
  int32_t format
) {
  return MakeTextureWrapper((Texture){
    .id = id,
    .width = width,
    .height = height,
    .mipmaps = mipmaps,
    .format = format,
  });
}
