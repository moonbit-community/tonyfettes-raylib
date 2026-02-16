#include "stub_internal.h"
#include <stdlib.h>

// ============================================================================
// Resource destructor: Image (local copy needed since static in stub_textures.c)
// ============================================================================

static void
image_destructor(void *ptr) {
  ImageWrapper *w = (ImageWrapper *)ptr;
  if (!w->freed)
    UnloadImage(w->image);
}

// ============================================================================
// Image loading: LoadImageRaw, LoadImageAnim, LoadImageAnimFromMemory
// ============================================================================

ImageWrapper *
moonbit_raylib_load_image_raw(moonbit_bytes_t fileName, int width, int height, int format, int headerSize) {
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = LoadImageRaw((const char *)fileName, width, height, format, headerSize);
  w->freed = 0;
  w->frame_count = 1;
  return w;
}

ImageWrapper *
moonbit_raylib_load_image_anim(moonbit_bytes_t fileName) {
  int frames = 0;
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = LoadImageAnim((const char *)fileName, &frames);
  w->freed = 0;
  w->frame_count = frames;
  return w;
}

int
moonbit_raylib_image_frame_count(ImageWrapper *wrapper) {
  return wrapper->frame_count;
}

int
moonbit_raylib_image_width(ImageWrapper *wrapper) {
  return wrapper->image.width;
}

int
moonbit_raylib_image_height(ImageWrapper *wrapper) {
  return wrapper->image.height;
}

ImageWrapper *
moonbit_raylib_load_image_anim_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t fileData, int dataSize) {
  int frames = 0;
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = LoadImageAnimFromMemory((const char *)fileType, (const unsigned char *)fileData, dataSize, &frames);
  w->freed = 0;
  w->frame_count = frames;
  return w;
}

// ============================================================================
// In-place mutations: primitives only
// ============================================================================

void
moonbit_raylib_image_format(ImageWrapper *wrapper, int newFormat) {
  ImageFormat(&wrapper->image, newFormat);
}

void
moonbit_raylib_image_alpha_crop(ImageWrapper *wrapper, float threshold) {
  ImageAlphaCrop(&wrapper->image, threshold);
}

void
moonbit_raylib_image_alpha_premultiply(ImageWrapper *wrapper) {
  ImageAlphaPremultiply(&wrapper->image);
}

void
moonbit_raylib_image_blur_gaussian(ImageWrapper *wrapper, int blurSize) {
  ImageBlurGaussian(&wrapper->image, blurSize);
}

void
moonbit_raylib_image_resize(ImageWrapper *wrapper, int newWidth, int newHeight) {
  ImageResize(&wrapper->image, newWidth, newHeight);
}

void
moonbit_raylib_image_resize_nn(ImageWrapper *wrapper, int newWidth, int newHeight) {
  ImageResizeNN(&wrapper->image, newWidth, newHeight);
}

void
moonbit_raylib_image_mipmaps(ImageWrapper *wrapper) {
  ImageMipmaps(&wrapper->image);
}

void
moonbit_raylib_image_dither(ImageWrapper *wrapper, int rBpp, int gBpp, int bBpp, int aBpp) {
  ImageDither(&wrapper->image, rBpp, gBpp, bBpp, aBpp);
}

void
moonbit_raylib_image_flip_vertical(ImageWrapper *wrapper) {
  ImageFlipVertical(&wrapper->image);
}

void
moonbit_raylib_image_flip_horizontal(ImageWrapper *wrapper) {
  ImageFlipHorizontal(&wrapper->image);
}

void
moonbit_raylib_image_rotate(ImageWrapper *wrapper, int degrees) {
  ImageRotate(&wrapper->image, degrees);
}

void
moonbit_raylib_image_rotate_cw(ImageWrapper *wrapper) {
  ImageRotateCW(&wrapper->image);
}

void
moonbit_raylib_image_rotate_ccw(ImageWrapper *wrapper) {
  ImageRotateCCW(&wrapper->image);
}

void
moonbit_raylib_image_color_invert(ImageWrapper *wrapper) {
  ImageColorInvert(&wrapper->image);
}

void
moonbit_raylib_image_color_grayscale(ImageWrapper *wrapper) {
  ImageColorGrayscale(&wrapper->image);
}

// ============================================================================
// In-place mutations: value type params
// ============================================================================

void
moonbit_raylib_image_to_pot(ImageWrapper *wrapper, moonbit_bytes_t fill) {
  Color c; memcpy(&c, fill, sizeof(Color));
  ImageToPOT(&wrapper->image, c);
}

void
moonbit_raylib_image_crop(ImageWrapper *wrapper, moonbit_bytes_t crop) {
  Rectangle r; memcpy(&r, crop, sizeof(Rectangle));
  ImageCrop(&wrapper->image, r);
}

void
moonbit_raylib_image_alpha_clear(ImageWrapper *wrapper, moonbit_bytes_t color, float threshold) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageAlphaClear(&wrapper->image, c, threshold);
}

void
moonbit_raylib_image_alpha_mask(ImageWrapper *wrapper, ImageWrapper *alphaMask) {
  ImageAlphaMask(&wrapper->image, alphaMask->image);
}

void
moonbit_raylib_image_resize_canvas(ImageWrapper *wrapper, int newWidth, int newHeight, int offsetX, int offsetY, moonbit_bytes_t fill) {
  Color c; memcpy(&c, fill, sizeof(Color));
  ImageResizeCanvas(&wrapper->image, newWidth, newHeight, offsetX, offsetY, c);
}

void
moonbit_raylib_image_color_tint(ImageWrapper *wrapper, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageColorTint(&wrapper->image, c);
}

void
moonbit_raylib_image_color_contrast(ImageWrapper *wrapper, float contrast) {
  ImageColorContrast(&wrapper->image, contrast);
}

void
moonbit_raylib_image_color_brightness(ImageWrapper *wrapper, int brightness) {
  ImageColorBrightness(&wrapper->image, brightness);
}

void
moonbit_raylib_image_color_replace(ImageWrapper *wrapper, moonbit_bytes_t color, moonbit_bytes_t replace) {
  Color c; memcpy(&c, color, sizeof(Color));
  Color r; memcpy(&r, replace, sizeof(Color));
  ImageColorReplace(&wrapper->image, c, r);
}

void
moonbit_raylib_image_kernel_convolution(ImageWrapper *wrapper, moonbit_bytes_t kernel, int kernelSize) {
  ImageKernelConvolution(&wrapper->image, (float *)kernel, kernelSize);
}

// ============================================================================
// Image creation: ImageText, ImageTextEx
// ============================================================================

ImageWrapper *
moonbit_raylib_image_text(moonbit_bytes_t text, int fontSize, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = ImageText((const char *)text, fontSize, c);
  w->freed = 0;
  w->frame_count = 1;
  return w;
}

ImageWrapper *
moonbit_raylib_image_text_ex(FontWrapper *font, moonbit_bytes_t text, float fontSize, float spacing, moonbit_bytes_t tint) {
  Color c; memcpy(&c, tint, sizeof(Color));
  ImageWrapper *w = (ImageWrapper *)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
  w->image = ImageTextEx(font->font, (const char *)text, fontSize, spacing, c);
  w->freed = 0;
  w->frame_count = 1;
  return w;
}

// ============================================================================
// Queries: GetImageAlphaBorder, GetImageColor
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_image_alpha_border(ImageWrapper *wrapper, float threshold) {
  Rectangle result = GetImageAlphaBorder(wrapper->image, threshold);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Rectangle), 0);
  memcpy(r, &result, sizeof(Rectangle));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_image_color(ImageWrapper *wrapper, int x, int y) {
  Color result = GetImageColor(wrapper->image, x, y);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &result, sizeof(Color));
  return r;
}

// ============================================================================
// Copy-and-free: LoadImageColors, LoadImagePalette
// ============================================================================

moonbit_bytes_t
moonbit_raylib_load_image_colors(ImageWrapper *wrapper) {
  int count = wrapper->image.width * wrapper->image.height;
  Color *colors = LoadImageColors(wrapper->image);
  moonbit_bytes_t r = moonbit_make_bytes(count * sizeof(Color), 0);
  memcpy(r, colors, count * sizeof(Color));
  UnloadImageColors(colors);
  return r;
}

moonbit_bytes_t
moonbit_raylib_load_image_palette(ImageWrapper *wrapper, int maxPaletteSize) {
  int colorCount = 0;
  Color *colors = LoadImagePalette(wrapper->image, maxPaletteSize, &colorCount);
  moonbit_bytes_t r = moonbit_make_bytes(colorCount * sizeof(Color), 0);
  memcpy(r, colors, colorCount * sizeof(Color));
  UnloadImagePalette(colors);
  return r;
}

// ============================================================================
// Export: ExportImageToMemory, ExportImageAsCode
// ============================================================================

moonbit_bytes_t
moonbit_raylib_export_image_to_memory(ImageWrapper *wrapper, moonbit_bytes_t fileType) {
  int dataSize = 0;
  unsigned char *data = ExportImageToMemory(wrapper->image, (const char *)fileType, &dataSize);
  moonbit_bytes_t r = moonbit_make_bytes(dataSize, 0);
  memcpy(r, data, dataSize);
  RL_FREE(data);
  return r;
}

int
moonbit_raylib_export_image_as_code(ImageWrapper *wrapper, moonbit_bytes_t fileName) {
  return (int)ExportImageAsCode(wrapper->image, (const char *)fileName);
}
