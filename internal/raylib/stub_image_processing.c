#include "stub_internal.h"
#include <stdlib.h>

// ============================================================================
// Image loading: LoadImageRaw, LoadImageAnim, LoadImageAnimFromMemory
// ============================================================================

ImageWrapper *
moonbit_raylib_load_image_raw(moonbit_bytes_t fileName, int width, int height, int format, int headerSize) {
  return MakeImageWrapper(LoadImageRaw((const char *)fileName, width, height, format, headerSize));
}

ImageWrapper *
moonbit_raylib_load_image_anim(moonbit_bytes_t fileName, int32_t *out_frames) {
  int frames = 0;
  Image img = LoadImageAnim((const char *)fileName, &frames);
  *out_frames = frames;
  return MakeImageWrapper(img);
}

int
moonbit_raylib_image_width(ImageWrapper *img) {
  return img->data->width;
}

int
moonbit_raylib_image_height(ImageWrapper *img) {
  return img->data->height;
}

int
moonbit_raylib_image_get_mipmaps(ImageWrapper *img) {
  return img->data->mipmaps;
}

int
moonbit_raylib_image_get_format(ImageWrapper *img) {
  return img->data->format;
}

ImageWrapper *
moonbit_raylib_load_image_anim_from_memory(moonbit_bytes_t fileType, moonbit_bytes_t fileData, int dataSize, int32_t *out_frames) {
  int frames = 0;
  Image img = LoadImageAnimFromMemory((const char *)fileType, (const unsigned char *)fileData, dataSize, &frames);
  *out_frames = frames;
  return MakeImageWrapper(img);
}

// ============================================================================
// In-place mutations: primitives only
// ============================================================================

void
moonbit_raylib_image_format(ImageWrapper *img, int newFormat) {
  ImageFormat(img->data, newFormat);
}

void
moonbit_raylib_image_alpha_crop(ImageWrapper *img, float threshold) {
  ImageAlphaCrop(img->data, threshold);
}

void
moonbit_raylib_image_alpha_premultiply(ImageWrapper *img) {
  ImageAlphaPremultiply(img->data);
}

void
moonbit_raylib_image_blur_gaussian(ImageWrapper *img, int blurSize) {
  ImageBlurGaussian(img->data, blurSize);
}

void
moonbit_raylib_image_resize(ImageWrapper *img, int newWidth, int newHeight) {
  ImageResize(img->data, newWidth, newHeight);
}

void
moonbit_raylib_image_resize_nn(ImageWrapper *img, int newWidth, int newHeight) {
  ImageResizeNN(img->data, newWidth, newHeight);
}

void
moonbit_raylib_image_mipmaps(ImageWrapper *img) {
  ImageMipmaps(img->data);
}

void
moonbit_raylib_image_dither(ImageWrapper *img, int rBpp, int gBpp, int bBpp, int aBpp) {
  ImageDither(img->data, rBpp, gBpp, bBpp, aBpp);
}

void
moonbit_raylib_image_flip_vertical(ImageWrapper *img) {
  ImageFlipVertical(img->data);
}

void
moonbit_raylib_image_flip_horizontal(ImageWrapper *img) {
  ImageFlipHorizontal(img->data);
}

void
moonbit_raylib_image_rotate(ImageWrapper *img, int degrees) {
  ImageRotate(img->data, degrees);
}

void
moonbit_raylib_image_rotate_cw(ImageWrapper *img) {
  ImageRotateCW(img->data);
}

void
moonbit_raylib_image_rotate_ccw(ImageWrapper *img) {
  ImageRotateCCW(img->data);
}

void
moonbit_raylib_image_color_invert(ImageWrapper *img) {
  ImageColorInvert(img->data);
}

void
moonbit_raylib_image_color_grayscale(ImageWrapper *img) {
  ImageColorGrayscale(img->data);
}

// ============================================================================
// In-place mutations: value type params
// ============================================================================

void
moonbit_raylib_image_to_pot(ImageWrapper *img, moonbit_bytes_t fill) {
  Color c; memcpy(&c, fill, sizeof(Color));
  ImageToPOT(img->data, c);
}

void
moonbit_raylib_image_crop(ImageWrapper *img, moonbit_bytes_t crop) {
  Rectangle r; memcpy(&r, crop, sizeof(Rectangle));
  ImageCrop(img->data, r);
}

void
moonbit_raylib_image_alpha_clear(ImageWrapper *img, moonbit_bytes_t color, float threshold) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageAlphaClear(img->data, c, threshold);
}

void
moonbit_raylib_image_alpha_mask(ImageWrapper *img, ImageWrapper *alphaMask) {
  ImageAlphaMask(img->data, *alphaMask->data);
}

void
moonbit_raylib_image_resize_canvas(ImageWrapper *img, int newWidth, int newHeight, int offsetX, int offsetY, moonbit_bytes_t fill) {
  Color c; memcpy(&c, fill, sizeof(Color));
  ImageResizeCanvas(img->data, newWidth, newHeight, offsetX, offsetY, c);
}

void
moonbit_raylib_image_color_tint(ImageWrapper *img, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageColorTint(img->data, c);
}

void
moonbit_raylib_image_color_contrast(ImageWrapper *img, float contrast) {
  ImageColorContrast(img->data, contrast);
}

void
moonbit_raylib_image_color_brightness(ImageWrapper *img, int brightness) {
  ImageColorBrightness(img->data, brightness);
}

void
moonbit_raylib_image_color_replace(ImageWrapper *img, moonbit_bytes_t color, moonbit_bytes_t replace) {
  Color c; memcpy(&c, color, sizeof(Color));
  Color r; memcpy(&r, replace, sizeof(Color));
  ImageColorReplace(img->data, c, r);
}

void
moonbit_raylib_image_kernel_convolution(ImageWrapper *img, moonbit_bytes_t kernel, int kernelSize) {
  ImageKernelConvolution(img->data, (float *)kernel, kernelSize);
}

// ============================================================================
// Image creation: ImageText, ImageTextEx
// ============================================================================

ImageWrapper *
moonbit_raylib_image_text(moonbit_bytes_t text, int fontSize, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  return MakeImageWrapper(ImageText((const char *)text, fontSize, c));
}

ImageWrapper *
moonbit_raylib_image_text_ex(FontWrapper *f, moonbit_bytes_t text, float fontSize, float spacing, moonbit_bytes_t tint) {
  Color c; memcpy(&c, tint, sizeof(Color));
  return MakeImageWrapper(ImageTextEx(*f->data, (const char *)text, fontSize, spacing, c));
}

// ============================================================================
// Queries: GetImageAlphaBorder, GetImageColor
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_image_alpha_border(ImageWrapper *img, float threshold) {
  Rectangle result = GetImageAlphaBorder(*img->data, threshold);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Rectangle), 0);
  memcpy(r, &result, sizeof(Rectangle));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_image_color(ImageWrapper *img, int x, int y) {
  Color result = GetImageColor(*img->data, x, y);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &result, sizeof(Color));
  return r;
}

// ============================================================================
// Copy-and-free: LoadImageColors, LoadImagePalette
// ============================================================================

moonbit_bytes_t
moonbit_raylib_load_image_colors(ImageWrapper *img) {
  int count = img->data->width * img->data->height;
  Color *colors = LoadImageColors(*img->data);
  moonbit_bytes_t r = moonbit_make_bytes(count * sizeof(Color), 0);
  memcpy(r, colors, count * sizeof(Color));
  UnloadImageColors(colors);
  return r;
}

moonbit_bytes_t
moonbit_raylib_load_image_palette(ImageWrapper *img, int maxPaletteSize) {
  int colorCount = 0;
  Color *colors = LoadImagePalette(*img->data, maxPaletteSize, &colorCount);
  moonbit_bytes_t r = moonbit_make_bytes(colorCount * sizeof(Color), 0);
  memcpy(r, colors, colorCount * sizeof(Color));
  UnloadImagePalette(colors);
  return r;
}

// ============================================================================
// Export: ExportImageToMemory, ExportImageAsCode
// ============================================================================

moonbit_bytes_t
moonbit_raylib_export_image_to_memory(ImageWrapper *img, moonbit_bytes_t fileType) {
  int dataSize = 0;
  unsigned char *data = ExportImageToMemory(*img->data, (const char *)fileType, &dataSize);
  moonbit_bytes_t r = moonbit_make_bytes(dataSize, 0);
  memcpy(r, data, dataSize);
  RL_FREE(data);
  return r;
}

int
moonbit_raylib_export_image_as_code(ImageWrapper *img, moonbit_bytes_t fileName) {
  return (int)ExportImageAsCode(*img->data, (const char *)fileName);
}
