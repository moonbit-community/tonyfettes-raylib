#include "stub_internal.h"

// ============================================================================
// Image drawing: Clear
// ============================================================================

void
moonbit_raylib_image_clear_background(ImageWrapper *img, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageClearBackground(img->data, c);
}

// ============================================================================
// Image drawing: Pixel
// ============================================================================

void
moonbit_raylib_image_draw_pixel(ImageWrapper *img, int posX, int posY, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawPixel(img->data, posX, posY, c);
}

void
moonbit_raylib_image_draw_pixel_v(ImageWrapper *img, moonbit_bytes_t position, moonbit_bytes_t color) {
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawPixelV(img->data, pos, c);
}

// ============================================================================
// Image drawing: Line
// ============================================================================

void
moonbit_raylib_image_draw_line(
  ImageWrapper *img,
  int startPosX,
  int startPosY,
  int endPosX,
  int endPosY,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawLine(img->data, startPosX, startPosY, endPosX, endPosY, c);
}

void
moonbit_raylib_image_draw_line_v(
  ImageWrapper *img,
  moonbit_bytes_t start,
  moonbit_bytes_t end,
  moonbit_bytes_t color
) {
  Vector2 s; memcpy(&s, start, sizeof(Vector2));
  Vector2 e; memcpy(&e, end, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawLineV(img->data, s, e, c);
}

void
moonbit_raylib_image_draw_line_ex(
  ImageWrapper *img,
  moonbit_bytes_t start,
  moonbit_bytes_t end,
  int thick,
  moonbit_bytes_t color
) {
  Vector2 s; memcpy(&s, start, sizeof(Vector2));
  Vector2 e; memcpy(&e, end, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawLineEx(img->data, s, e, thick, c);
}

// ============================================================================
// Image drawing: Circle
// ============================================================================

void
moonbit_raylib_image_draw_circle(
  ImageWrapper *img,
  int centerX,
  int centerY,
  int radius,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircle(img->data, centerX, centerY, radius, c);
}

void
moonbit_raylib_image_draw_circle_v(
  ImageWrapper *img,
  moonbit_bytes_t center,
  int radius,
  moonbit_bytes_t color
) {
  Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircleV(img->data, ctr, radius, c);
}

void
moonbit_raylib_image_draw_circle_lines(
  ImageWrapper *img,
  int centerX,
  int centerY,
  int radius,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircleLines(img->data, centerX, centerY, radius, c);
}

void
moonbit_raylib_image_draw_circle_lines_v(
  ImageWrapper *img,
  moonbit_bytes_t center,
  int radius,
  moonbit_bytes_t color
) {
  Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircleLinesV(img->data, ctr, radius, c);
}

// ============================================================================
// Image drawing: Rectangle
// ============================================================================

void
moonbit_raylib_image_draw_rectangle(
  ImageWrapper *img,
  int posX,
  int posY,
  int width,
  int height,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangle(img->data, posX, posY, width, height, c);
}

void
moonbit_raylib_image_draw_rectangle_v(
  ImageWrapper *img,
  moonbit_bytes_t position,
  moonbit_bytes_t size,
  moonbit_bytes_t color
) {
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Vector2 sz; memcpy(&sz, size, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangleV(img->data, pos, sz, c);
}

void
moonbit_raylib_image_draw_rectangle_rec(
  ImageWrapper *img,
  moonbit_bytes_t rec,
  moonbit_bytes_t color
) {
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangleRec(img->data, r, c);
}

void
moonbit_raylib_image_draw_rectangle_lines(
  ImageWrapper *img,
  moonbit_bytes_t rec,
  int thick,
  moonbit_bytes_t color
) {
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangleLines(img->data, r, thick, c);
}

// ============================================================================
// Image drawing: Triangle
// ============================================================================

void
moonbit_raylib_image_draw_triangle(
  ImageWrapper *img,
  moonbit_bytes_t v1,
  moonbit_bytes_t v2,
  moonbit_bytes_t v3,
  moonbit_bytes_t color
) {
  Vector2 a; memcpy(&a, v1, sizeof(Vector2));
  Vector2 b; memcpy(&b, v2, sizeof(Vector2));
  Vector2 cv; memcpy(&cv, v3, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangle(img->data, a, b, cv, c);
}

void
moonbit_raylib_image_draw_triangle_ex(
  ImageWrapper *img,
  moonbit_bytes_t v1,
  moonbit_bytes_t v2,
  moonbit_bytes_t v3,
  moonbit_bytes_t c1,
  moonbit_bytes_t c2,
  moonbit_bytes_t c3
) {
  Vector2 a; memcpy(&a, v1, sizeof(Vector2));
  Vector2 b; memcpy(&b, v2, sizeof(Vector2));
  Vector2 cv; memcpy(&cv, v3, sizeof(Vector2));
  Color col1; memcpy(&col1, c1, sizeof(Color));
  Color col2; memcpy(&col2, c2, sizeof(Color));
  Color col3; memcpy(&col3, c3, sizeof(Color));
  ImageDrawTriangleEx(img->data, a, b, cv, col1, col2, col3);
}

void
moonbit_raylib_image_draw_triangle_lines(
  ImageWrapper *img,
  moonbit_bytes_t v1,
  moonbit_bytes_t v2,
  moonbit_bytes_t v3,
  moonbit_bytes_t color
) {
  Vector2 a; memcpy(&a, v1, sizeof(Vector2));
  Vector2 b; memcpy(&b, v2, sizeof(Vector2));
  Vector2 cv; memcpy(&cv, v3, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangleLines(img->data, a, b, cv, c);
}

void
moonbit_raylib_image_draw_triangle_fan(
  ImageWrapper *img,
  moonbit_bytes_t points,
  int pointCount,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangleFan(img->data, (Vector2 *)points, pointCount, c);
}

void
moonbit_raylib_image_draw_triangle_strip(
  ImageWrapper *img,
  moonbit_bytes_t points,
  int pointCount,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangleStrip(img->data, (Vector2 *)points, pointCount, c);
}

// ============================================================================
// Image drawing: Compositing
// ============================================================================

void
moonbit_raylib_image_draw(
  ImageWrapper *dst,
  ImageWrapper *src,
  moonbit_bytes_t srcRec,
  moonbit_bytes_t dstRec,
  moonbit_bytes_t tint
) {
  Rectangle sr; memcpy(&sr, srcRec, sizeof(Rectangle));
  Rectangle dr; memcpy(&dr, dstRec, sizeof(Rectangle));
  Color c; memcpy(&c, tint, sizeof(Color));
  ImageDraw(dst->data, *src->data, sr, dr, c);
}

// ============================================================================
// Image drawing: Text
// ============================================================================

void
moonbit_raylib_image_draw_text(
  ImageWrapper *img,
  moonbit_bytes_t text,
  int posX,
  int posY,
  int fontSize,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawText(img->data, (const char *)text, posX, posY, fontSize, c);
}

void
moonbit_raylib_image_draw_text_ex(
  ImageWrapper *img,
  FontWrapper *f,
  moonbit_bytes_t text,
  moonbit_bytes_t position,
  float fontSize,
  float spacing,
  moonbit_bytes_t tint
) {
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  ImageDrawTextEx(img->data, *f->data, (const char *)text, pos, fontSize, spacing, c);
}
