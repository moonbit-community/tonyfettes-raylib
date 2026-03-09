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
moonbit_raylib_load_image_from_texture(moonbit_bytes_t texture) {
  Texture2D tex = bytes_to_texture(texture);
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = LoadImageFromTexture(tex);
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
// Textures: Texture loading (value types)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_load_texture(moonbit_bytes_t fileName) {
  return texture_to_bytes(LoadTexture((const char *)fileName));
}

moonbit_bytes_t
moonbit_raylib_load_texture_from_image(ImageWrapper *img) {
  return texture_to_bytes(LoadTextureFromImage(img->image));
}

int
moonbit_raylib_is_texture_valid(moonbit_bytes_t texture) {
  Texture2D tex = bytes_to_texture(texture);
  return (int)IsTextureValid(tex);
}

void
moonbit_raylib_unload_texture(moonbit_bytes_t texture) {
  Texture2D tex = bytes_to_texture(texture);
  UnloadTexture(tex);
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

// Custom destructor for depth-tex render textures (manual rlgl cleanup)
static void
render_texture_depth_tex_destructor(void *ptr) {
  RenderTextureWrapper *w = (RenderTextureWrapper *)ptr;
  if (!w->freed) {
    if (w->render_texture.id > 0) {
      rlUnloadTexture(w->render_texture.texture.id);
      rlUnloadTexture(w->render_texture.depth.id);
      rlUnloadFramebuffer(w->render_texture.id);
    }
  }
}

RenderTextureWrapper *
moonbit_raylib_load_render_texture_depth_tex(int width, int height) {
  RenderTextureWrapper *w =
    (RenderTextureWrapper *)moonbit_make_external_object(
      render_texture_depth_tex_destructor, sizeof(RenderTextureWrapper)
    );
  memset(&w->render_texture, 0, sizeof(RenderTexture));
  w->freed = 0;

  w->render_texture.id = rlLoadFramebuffer();

  if (w->render_texture.id > 0) {
    rlEnableFramebuffer(w->render_texture.id);

    // Create color texture (default to RGBA)
    w->render_texture.texture.id = rlLoadTexture(0, width, height, PIXELFORMAT_UNCOMPRESSED_R8G8B8A8, 1);
    w->render_texture.texture.width = width;
    w->render_texture.texture.height = height;
    w->render_texture.texture.format = PIXELFORMAT_UNCOMPRESSED_R8G8B8A8;
    w->render_texture.texture.mipmaps = 1;

    // Create depth texture buffer (instead of raylib default renderbuffer)
    w->render_texture.depth.id = rlLoadTextureDepth(width, height, false);
    w->render_texture.depth.width = width;
    w->render_texture.depth.height = height;
    w->render_texture.depth.format = 19; // DEPTH_COMPONENT_24BIT
    w->render_texture.depth.mipmaps = 1;

    // Attach color texture and depth texture to FBO
    rlFramebufferAttach(w->render_texture.id, w->render_texture.texture.id,
                        RL_ATTACHMENT_COLOR_CHANNEL0, RL_ATTACHMENT_TEXTURE2D, 0);
    rlFramebufferAttach(w->render_texture.id, w->render_texture.depth.id,
                        RL_ATTACHMENT_DEPTH, RL_ATTACHMENT_TEXTURE2D, 0);

    // Check if fbo is complete with attachments (valid)
    if (rlFramebufferComplete(w->render_texture.id))
      TRACELOG(LOG_INFO, "FBO: [ID %i] Framebuffer object created successfully", w->render_texture.id);

    rlDisableFramebuffer();
  } else {
    TRACELOG(LOG_WARNING, "FBO: Framebuffer object can not be created");
  }

  return w;
}

void
moonbit_raylib_unload_render_texture_depth_tex(RenderTextureWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    if (wrapper->render_texture.id > 0) {
      rlUnloadTexture(wrapper->render_texture.texture.id);
      rlUnloadTexture(wrapper->render_texture.depth.id);
      rlUnloadFramebuffer(wrapper->render_texture.id);
    }
    wrapper->freed = 1;
  }
}

// ============================================================================
// Textures: Texture drawing
// ============================================================================

void
moonbit_raylib_draw_texture(
  moonbit_bytes_t texture, int posX, int posY, moonbit_bytes_t tint
) {
  Texture2D tex = bytes_to_texture(texture);
  Color c; memcpy(&c, tint, sizeof(Color));
  DrawTexture(tex, posX, posY, c);
}

void
moonbit_raylib_draw_texture_v(
  moonbit_bytes_t texture, moonbit_bytes_t position, moonbit_bytes_t tint
) {
  Texture2D tex = bytes_to_texture(texture);
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  DrawTextureV(tex, pos, c);
}

void
moonbit_raylib_draw_texture_ex(
  moonbit_bytes_t texture, moonbit_bytes_t position, float rotation, float scale, moonbit_bytes_t tint
) {
  Texture2D tex = bytes_to_texture(texture);
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  DrawTextureEx(tex, pos, rotation, scale, c);
}

void
moonbit_raylib_draw_texture_rec(
  moonbit_bytes_t texture, moonbit_bytes_t source, moonbit_bytes_t position, moonbit_bytes_t tint
) {
  Texture2D tex = bytes_to_texture(texture);
  Rectangle src; memcpy(&src, source, sizeof(Rectangle));
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  DrawTextureRec(tex, src, pos, c);
}

void
moonbit_raylib_draw_texture_pro(
  moonbit_bytes_t texture, moonbit_bytes_t source, moonbit_bytes_t dest,
  moonbit_bytes_t origin, float rotation, moonbit_bytes_t tint
) {
  Texture2D tex = bytes_to_texture(texture);
  Rectangle src; memcpy(&src, source, sizeof(Rectangle));
  Rectangle dst; memcpy(&dst, dest, sizeof(Rectangle));
  Vector2 org; memcpy(&org, origin, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  DrawTexturePro(tex, src, dst, org, rotation, c);
}

void
moonbit_raylib_draw_texture_npatch(
  moonbit_bytes_t texture, moonbit_bytes_t nPatchInfo, moonbit_bytes_t dest,
  moonbit_bytes_t origin, float rotation, moonbit_bytes_t tint
) {
  Texture2D tex = bytes_to_texture(texture);
  NPatchInfo npi; memcpy(&npi, nPatchInfo, sizeof(NPatchInfo));
  Rectangle dst; memcpy(&dst, dest, sizeof(Rectangle));
  Vector2 org; memcpy(&org, origin, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  DrawTextureNPatch(tex, npi, dst, org, rotation, c);
}

// ============================================================================
// Textures: Texture configuration
// ============================================================================

void
moonbit_raylib_set_texture_filter(moonbit_bytes_t texture, int filter) {
  Texture2D tex = bytes_to_texture(texture);
  SetTextureFilter(tex, filter);
}

void
moonbit_raylib_set_texture_wrap(moonbit_bytes_t texture, int wrap) {
  Texture2D tex = bytes_to_texture(texture);
  SetTextureWrap(tex, wrap);
}

// ============================================================================
// Textures: Texture management extras
// ============================================================================

moonbit_bytes_t
moonbit_raylib_load_texture_cubemap(ImageWrapper *img, int layout) {
  return texture_to_bytes(LoadTextureCubemap(img->image, layout));
}

void
moonbit_raylib_update_texture(moonbit_bytes_t texture, moonbit_bytes_t pixels) {
  Texture2D tex = bytes_to_texture(texture);
  UpdateTexture(tex, (const void *)pixels);
}

void
moonbit_raylib_update_texture_rec(moonbit_bytes_t texture, moonbit_bytes_t rec, moonbit_bytes_t pixels) {
  Texture2D tex = bytes_to_texture(texture);
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  UpdateTextureRec(tex, r, (const void *)pixels);
}

moonbit_bytes_t
moonbit_raylib_gen_texture_mipmaps(moonbit_bytes_t texture) {
  Texture2D tex = bytes_to_texture(texture);
  GenTextureMipmaps(&tex);
  return texture_to_bytes(tex);
}

void
moonbit_raylib_update_texture_from_image_frame(moonbit_bytes_t texture, ImageWrapper *iw, int frame) {
  Texture2D tex = bytes_to_texture(texture);
  int offset = iw->image.width * iw->image.height * 4 * frame;
  UpdateTexture(tex, ((unsigned char *)iw->image.data) + offset);
}

void
moonbit_raylib_set_shapes_texture(moonbit_bytes_t texture, moonbit_bytes_t source) {
  Texture2D tex = bytes_to_texture(texture);
  Rectangle r; memcpy(&r, source, sizeof(Rectangle));
  SetShapesTexture(tex, r);
}

moonbit_bytes_t
moonbit_raylib_get_shapes_texture(void) {
  return texture_to_bytes(GetShapesTexture());
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
  RenderTextureWrapper *wrapper,
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
  DrawTextureRec(wrapper->render_texture.texture, src, pos, c);
}

int
moonbit_raylib_get_render_texture_width(RenderTextureWrapper *wrapper) {
  return wrapper->render_texture.texture.width;
}

int
moonbit_raylib_get_render_texture_height(RenderTextureWrapper *wrapper) {
  return wrapper->render_texture.texture.height;
}

void
moonbit_raylib_draw_render_texture_ex(
  RenderTextureWrapper *wrapper,
  moonbit_bytes_t position,
  float rotation,
  float scale,
  moonbit_bytes_t tint
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawTextureEx(wrapper->render_texture.texture, pos, rotation, scale, c);
}

// ============================================================================
// Textures: Clipboard image (needs image_destructor)
// ============================================================================

ImageWrapper *
moonbit_raylib_get_clipboard_image(void) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
#ifdef PLATFORM_ANDROID
  w->image = (Image){0};   // clipboard image not supported on Android
#else
  w->image = GetClipboardImage();
#endif
  w->freed = 0;
  w->frame_count = 1;
  return w;
}

void
moonbit_raylib_draw_render_texture_pro(
  RenderTextureWrapper *wrapper,
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
  DrawTexturePro(wrapper->render_texture.texture, src, dst, org, rotation, c);
}

void
moonbit_raylib_set_render_texture_filter(RenderTextureWrapper *wrapper, int filter) {
  SetTextureFilter(wrapper->render_texture.texture, filter);
}

// ============================================================================
// RenderTexture: Get render texture's texture (value copy)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_render_texture_texture(RenderTextureWrapper *wrapper) {
  return texture_to_bytes(wrapper->render_texture.texture);
}

// ============================================================================
// RenderTexture: Get IDs for rlgl-level operations
// ============================================================================

unsigned int
moonbit_raylib_get_render_texture_fbo_id(RenderTextureWrapper *wrapper) {
  return wrapper->render_texture.id;
}

unsigned int
moonbit_raylib_get_render_texture_depth_id(RenderTextureWrapper *wrapper) {
  return wrapper->render_texture.depth.id;
}

// ============================================================================
// Shadowmap: Load a depth-only render texture for shadow mapping
// ============================================================================

RenderTextureWrapper *
moonbit_raylib_load_shadowmap_render_texture(int width, int height) {
  RenderTextureWrapper *w =
    (RenderTextureWrapper *)moonbit_make_external_object(
      render_texture_destructor, sizeof(RenderTextureWrapper)
  );
  w->freed = 0;

  RenderTexture2D target = { 0 };
  target.id = rlLoadFramebuffer();
  target.texture.width = width;
  target.texture.height = height;

  if (target.id > 0) {
    rlEnableFramebuffer(target.id);

    // Create depth texture (no color texture needed for shadow mapping)
    target.depth.id = rlLoadTextureDepth(width, height, false);
    target.depth.width = width;
    target.depth.height = height;
    target.depth.format = 19; // DEPTH_COMPONENT_24BIT
    target.depth.mipmaps = 1;

    // Attach depth texture to FBO
    rlFramebufferAttach(target.id, target.depth.id, RL_ATTACHMENT_DEPTH, RL_ATTACHMENT_TEXTURE2D, 0);

    // Verify framebuffer is complete
    if (rlFramebufferComplete(target.id)) {
      TraceLog(LOG_INFO, "FBO: [ID %i] Shadowmap framebuffer object created successfully", target.id);
    }

    rlDisableFramebuffer();
  } else {
    TraceLog(LOG_WARNING, "FBO: Shadowmap framebuffer object can not be created");
  }

  w->render_texture = target;
  return w;
}

// ============================================================================
// Unload shadowmap (just unload the framebuffer, depth is auto-cleaned)
// ============================================================================

void
moonbit_raylib_unload_shadowmap_render_texture(RenderTextureWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    if (wrapper->render_texture.id > 0) {
      rlUnloadFramebuffer(wrapper->render_texture.id);
    }
    wrapper->freed = 1;
  }
}

// ============================================================================
// rlgl: Load texture (NULL data, for framebuffer attachments)
// ============================================================================

unsigned int
moonbit_raylib_rl_load_texture(int width, int height, int format, int mipmapCount) {
  return rlLoadTexture(NULL, width, height, format, mipmapCount);
}

