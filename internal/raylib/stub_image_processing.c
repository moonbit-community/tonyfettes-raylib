#include "stub_internal.h"
#include <stdlib.h>

// ============================================================================
// Image loading: LoadImageRaw, LoadImageAnim, LoadImageAnimFromMemory
// ============================================================================

Image *
moonbit_raylib_load_image_raw(moonbit_bytes_t fileName, int width, int height, int format, int headerSize) {
  Image *img = (Image *)malloc(sizeof(Image));
  *img = LoadImageRaw((const char *)fileName, width, height, format, headerSize);
  return img;
}

Image *
moonbit_raylib_load_image_anim(moonbit_bytes_t fileName, int32_t *out_frames) {
  int frames = 0;
  Image *img = (Image *)malloc(sizeof(Image));
  *img = LoadImageAnim((const char *)fileName, &frames);
  *out_frames = frames;
  return img;
}

int
moonbit_raylib_image_width(Image *img) {
  return img->width;
}

int
moonbit_raylib_image_height(Image *img) {
  return img->height;
}

Image *
moonbit_raylib_load_image_anim_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t fileData, int dataSize, int32_t *out_frames) {
  int frames = 0;
  Image *img = (Image *)malloc(sizeof(Image));
  *img = LoadImageAnimFromMemory((const char *)fileType, (const unsigned char *)fileData, dataSize, &frames);
  *out_frames = frames;
  return img;
}

// ============================================================================
// In-place mutations: primitives only
// ============================================================================

void
moonbit_raylib_image_format(Image *img, int newFormat) {
  ImageFormat(img, newFormat);
}

void
moonbit_raylib_image_alpha_crop(Image *img, float threshold) {
  ImageAlphaCrop(img, threshold);
}

void
moonbit_raylib_image_alpha_premultiply(Image *img) {
  ImageAlphaPremultiply(img);
}

void
moonbit_raylib_image_blur_gaussian(Image *img, int blurSize) {
  ImageBlurGaussian(img, blurSize);
}

void
moonbit_raylib_image_resize(Image *img, int newWidth, int newHeight) {
  ImageResize(img, newWidth, newHeight);
}

void
moonbit_raylib_image_resize_nn(Image *img, int newWidth, int newHeight) {
  ImageResizeNN(img, newWidth, newHeight);
}

void
moonbit_raylib_image_mipmaps(Image *img) {
  ImageMipmaps(img);
}

void
moonbit_raylib_image_dither(Image *img, int rBpp, int gBpp, int bBpp, int aBpp) {
  ImageDither(img, rBpp, gBpp, bBpp, aBpp);
}

void
moonbit_raylib_image_flip_vertical(Image *img) {
  ImageFlipVertical(img);
}

void
moonbit_raylib_image_flip_horizontal(Image *img) {
  ImageFlipHorizontal(img);
}

void
moonbit_raylib_image_rotate(Image *img, int degrees) {
  ImageRotate(img, degrees);
}

void
moonbit_raylib_image_rotate_cw(Image *img) {
  ImageRotateCW(img);
}

void
moonbit_raylib_image_rotate_ccw(Image *img) {
  ImageRotateCCW(img);
}

void
moonbit_raylib_image_color_invert(Image *img) {
  ImageColorInvert(img);
}

void
moonbit_raylib_image_color_grayscale(Image *img) {
  ImageColorGrayscale(img);
}

// ============================================================================
// In-place mutations: value type params
// ============================================================================

void
moonbit_raylib_image_to_pot(Image *img, moonbit_bytes_t fill) {
  Color c; memcpy(&c, fill, sizeof(Color));
  ImageToPOT(img, c);
}

void
moonbit_raylib_image_crop(Image *img, moonbit_bytes_t crop) {
  Rectangle r; memcpy(&r, crop, sizeof(Rectangle));
  ImageCrop(img, r);
}

void
moonbit_raylib_image_alpha_clear(Image *img, moonbit_bytes_t color, float threshold) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageAlphaClear(img, c, threshold);
}

void
moonbit_raylib_image_alpha_mask(Image *img, Image *alphaMask) {
  ImageAlphaMask(img, *alphaMask);
}

void
moonbit_raylib_image_resize_canvas(Image *img, int newWidth, int newHeight, int offsetX, int offsetY, moonbit_bytes_t fill) {
  Color c; memcpy(&c, fill, sizeof(Color));
  ImageResizeCanvas(img, newWidth, newHeight, offsetX, offsetY, c);
}

void
moonbit_raylib_image_color_tint(Image *img, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageColorTint(img, c);
}

void
moonbit_raylib_image_color_contrast(Image *img, float contrast) {
  ImageColorContrast(img, contrast);
}

void
moonbit_raylib_image_color_brightness(Image *img, int brightness) {
  ImageColorBrightness(img, brightness);
}

void
moonbit_raylib_image_color_replace(Image *img, moonbit_bytes_t color, moonbit_bytes_t replace) {
  Color c; memcpy(&c, color, sizeof(Color));
  Color r; memcpy(&r, replace, sizeof(Color));
  ImageColorReplace(img, c, r);
}

void
moonbit_raylib_image_kernel_convolution(Image *img, moonbit_bytes_t kernel, int kernelSize) {
  ImageKernelConvolution(img, (float *)kernel, kernelSize);
}

// ============================================================================
// Image creation: ImageText, ImageTextEx
// ============================================================================

Image *
moonbit_raylib_image_text(moonbit_bytes_t text, int fontSize, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  Image *img = (Image *)malloc(sizeof(Image));
  *img = ImageText((const char *)text, fontSize, c);
  return img;
}

Image *
moonbit_raylib_image_text_ex(FontWrapper *w, moonbit_bytes_t text, float fontSize, float spacing, moonbit_bytes_t tint) {
  assert(w->data && "use of unloaded font");
  Color c; memcpy(&c, tint, sizeof(Color));
  Image *img = (Image *)malloc(sizeof(Image));
  *img = ImageTextEx(*w->data, (const char *)text, fontSize, spacing, c);
  return img;
}

// ============================================================================
// Queries: GetImageAlphaBorder, GetImageColor
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_image_alpha_border(Image *img, float threshold) {
  Rectangle result = GetImageAlphaBorder(*img, threshold);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Rectangle), 0);
  memcpy(r, &result, sizeof(Rectangle));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_image_color(Image *img, int x, int y) {
  Color result = GetImageColor(*img, x, y);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &result, sizeof(Color));
  return r;
}

// ============================================================================
// Copy-and-free: LoadImageColors, LoadImagePalette
// ============================================================================

moonbit_bytes_t
moonbit_raylib_load_image_colors(Image *img) {
  int count = img->width * img->height;
  Color *colors = LoadImageColors(*img);
  moonbit_bytes_t r = moonbit_make_bytes(count * sizeof(Color), 0);
  memcpy(r, colors, count * sizeof(Color));
  UnloadImageColors(colors);
  return r;
}

moonbit_bytes_t
moonbit_raylib_load_image_palette(Image *img, int maxPaletteSize) {
  int colorCount = 0;
  Color *colors = LoadImagePalette(*img, maxPaletteSize, &colorCount);
  moonbit_bytes_t r = moonbit_make_bytes(colorCount * sizeof(Color), 0);
  memcpy(r, colors, colorCount * sizeof(Color));
  UnloadImagePalette(colors);
  return r;
}

// ============================================================================
// Export: ExportImageToMemory, ExportImageAsCode
// ============================================================================

moonbit_bytes_t
moonbit_raylib_export_image_to_memory(Image *img, moonbit_bytes_t fileType) {
  int dataSize = 0;
  unsigned char *data = ExportImageToMemory(*img, (const char *)fileType, &dataSize);
  moonbit_bytes_t r = moonbit_make_bytes(dataSize, 0);
  memcpy(r, data, dataSize);
  RL_FREE(data);
  return r;
}

int
moonbit_raylib_export_image_as_code(Image *img, moonbit_bytes_t fileName) {
  return (int)ExportImageAsCode(*img, (const char *)fileName);
}
