#include "stub_internal.h"

// ============================================================================
// Image drawing: Clear
// ============================================================================

void
moonbit_raylib_image_clear_background(ImageWrapper *wrapper, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageClearBackground(&wrapper->image, c);
}

// ============================================================================
// Image drawing: Pixel
// ============================================================================

void
moonbit_raylib_image_draw_pixel(ImageWrapper *wrapper, int posX, int posY, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawPixel(&wrapper->image, posX, posY, c);
}

void
moonbit_raylib_image_draw_pixel_v(ImageWrapper *wrapper, moonbit_bytes_t position, moonbit_bytes_t color) {
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawPixelV(&wrapper->image, pos, c);
}

// ============================================================================
// Image drawing: Line
// ============================================================================

void
moonbit_raylib_image_draw_line(
  ImageWrapper *wrapper,
  int startPosX,
  int startPosY,
  int endPosX,
  int endPosY,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawLine(&wrapper->image, startPosX, startPosY, endPosX, endPosY, c);
}

void
moonbit_raylib_image_draw_line_v(
  ImageWrapper *wrapper,
  moonbit_bytes_t start,
  moonbit_bytes_t end,
  moonbit_bytes_t color
) {
  Vector2 s; memcpy(&s, start, sizeof(Vector2));
  Vector2 e; memcpy(&e, end, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawLineV(&wrapper->image, s, e, c);
}

void
moonbit_raylib_image_draw_line_ex(
  ImageWrapper *wrapper,
  moonbit_bytes_t start,
  moonbit_bytes_t end,
  int thick,
  moonbit_bytes_t color
) {
  Vector2 s; memcpy(&s, start, sizeof(Vector2));
  Vector2 e; memcpy(&e, end, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawLineEx(&wrapper->image, s, e, thick, c);
}

// ============================================================================
// Image drawing: Circle
// ============================================================================

void
moonbit_raylib_image_draw_circle(
  ImageWrapper *wrapper,
  int centerX,
  int centerY,
  int radius,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircle(&wrapper->image, centerX, centerY, radius, c);
}

void
moonbit_raylib_image_draw_circle_v(
  ImageWrapper *wrapper,
  moonbit_bytes_t center,
  int radius,
  moonbit_bytes_t color
) {
  Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircleV(&wrapper->image, ctr, radius, c);
}

void
moonbit_raylib_image_draw_circle_lines(
  ImageWrapper *wrapper,
  int centerX,
  int centerY,
  int radius,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircleLines(&wrapper->image, centerX, centerY, radius, c);
}

void
moonbit_raylib_image_draw_circle_lines_v(
  ImageWrapper *wrapper,
  moonbit_bytes_t center,
  int radius,
  moonbit_bytes_t color
) {
  Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircleLinesV(&wrapper->image, ctr, radius, c);
}

// ============================================================================
// Image drawing: Rectangle
// ============================================================================

void
moonbit_raylib_image_draw_rectangle(
  ImageWrapper *wrapper,
  int posX,
  int posY,
  int width,
  int height,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangle(&wrapper->image, posX, posY, width, height, c);
}

void
moonbit_raylib_image_draw_rectangle_v(
  ImageWrapper *wrapper,
  moonbit_bytes_t position,
  moonbit_bytes_t size,
  moonbit_bytes_t color
) {
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Vector2 sz; memcpy(&sz, size, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangleV(&wrapper->image, pos, sz, c);
}

void
moonbit_raylib_image_draw_rectangle_rec(
  ImageWrapper *wrapper,
  moonbit_bytes_t rec,
  moonbit_bytes_t color
) {
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangleRec(&wrapper->image, r, c);
}

void
moonbit_raylib_image_draw_rectangle_lines(
  ImageWrapper *wrapper,
  moonbit_bytes_t rec,
  int thick,
  moonbit_bytes_t color
) {
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangleLines(&wrapper->image, r, thick, c);
}

// ============================================================================
// Image drawing: Triangle
// ============================================================================

void
moonbit_raylib_image_draw_triangle(
  ImageWrapper *wrapper,
  moonbit_bytes_t v1,
  moonbit_bytes_t v2,
  moonbit_bytes_t v3,
  moonbit_bytes_t color
) {
  Vector2 a; memcpy(&a, v1, sizeof(Vector2));
  Vector2 b; memcpy(&b, v2, sizeof(Vector2));
  Vector2 cv; memcpy(&cv, v3, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangle(&wrapper->image, a, b, cv, c);
}

void
moonbit_raylib_image_draw_triangle_ex(
  ImageWrapper *wrapper,
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
  ImageDrawTriangleEx(&wrapper->image, a, b, cv, col1, col2, col3);
}

void
moonbit_raylib_image_draw_triangle_lines(
  ImageWrapper *wrapper,
  moonbit_bytes_t v1,
  moonbit_bytes_t v2,
  moonbit_bytes_t v3,
  moonbit_bytes_t color
) {
  Vector2 a; memcpy(&a, v1, sizeof(Vector2));
  Vector2 b; memcpy(&b, v2, sizeof(Vector2));
  Vector2 cv; memcpy(&cv, v3, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangleLines(&wrapper->image, a, b, cv, c);
}

void
moonbit_raylib_image_draw_triangle_fan(
  ImageWrapper *wrapper,
  moonbit_bytes_t points,
  int pointCount,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangleFan(&wrapper->image, (Vector2 *)points, pointCount, c);
}

void
moonbit_raylib_image_draw_triangle_strip(
  ImageWrapper *wrapper,
  moonbit_bytes_t points,
  int pointCount,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangleStrip(&wrapper->image, (Vector2 *)points, pointCount, c);
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
  ImageDraw(&dst->image, src->image, sr, dr, c);
}

// ============================================================================
// Image drawing: Text
// ============================================================================

void
moonbit_raylib_image_draw_text(
  ImageWrapper *wrapper,
  moonbit_bytes_t text,
  int posX,
  int posY,
  int fontSize,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawText(&wrapper->image, (const char *)text, posX, posY, fontSize, c);
}

void
moonbit_raylib_image_draw_text_ex(
  ImageWrapper *wrapper,
  FontWrapper *font,
  moonbit_bytes_t text,
  moonbit_bytes_t position,
  float fontSize,
  float spacing,
  moonbit_bytes_t tint
) {
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  ImageDrawTextEx(&wrapper->image, font->font, (const char *)text, pos, fontSize, spacing, c);
}
