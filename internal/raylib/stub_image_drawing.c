#include "stub_internal.h"

// ============================================================================
// Image drawing: Clear
// ============================================================================

void
moonbit_raylib_image_clear_background(Image *img, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageClearBackground(img, c);
}

// ============================================================================
// Image drawing: Pixel
// ============================================================================

void
moonbit_raylib_image_draw_pixel(Image *img, int posX, int posY, moonbit_bytes_t color) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawPixel(img, posX, posY, c);
}

void
moonbit_raylib_image_draw_pixel_v(Image *img, moonbit_bytes_t position, moonbit_bytes_t color) {
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawPixelV(img, pos, c);
}

// ============================================================================
// Image drawing: Line
// ============================================================================

void
moonbit_raylib_image_draw_line(
  Image *img,
  int startPosX,
  int startPosY,
  int endPosX,
  int endPosY,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawLine(img, startPosX, startPosY, endPosX, endPosY, c);
}

void
moonbit_raylib_image_draw_line_v(
  Image *img,
  moonbit_bytes_t start,
  moonbit_bytes_t end,
  moonbit_bytes_t color
) {
  Vector2 s; memcpy(&s, start, sizeof(Vector2));
  Vector2 e; memcpy(&e, end, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawLineV(img, s, e, c);
}

void
moonbit_raylib_image_draw_line_ex(
  Image *img,
  moonbit_bytes_t start,
  moonbit_bytes_t end,
  int thick,
  moonbit_bytes_t color
) {
  Vector2 s; memcpy(&s, start, sizeof(Vector2));
  Vector2 e; memcpy(&e, end, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawLineEx(img, s, e, thick, c);
}

// ============================================================================
// Image drawing: Circle
// ============================================================================

void
moonbit_raylib_image_draw_circle(
  Image *img,
  int centerX,
  int centerY,
  int radius,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircle(img, centerX, centerY, radius, c);
}

void
moonbit_raylib_image_draw_circle_v(
  Image *img,
  moonbit_bytes_t center,
  int radius,
  moonbit_bytes_t color
) {
  Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircleV(img, ctr, radius, c);
}

void
moonbit_raylib_image_draw_circle_lines(
  Image *img,
  int centerX,
  int centerY,
  int radius,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircleLines(img, centerX, centerY, radius, c);
}

void
moonbit_raylib_image_draw_circle_lines_v(
  Image *img,
  moonbit_bytes_t center,
  int radius,
  moonbit_bytes_t color
) {
  Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawCircleLinesV(img, ctr, radius, c);
}

// ============================================================================
// Image drawing: Rectangle
// ============================================================================

void
moonbit_raylib_image_draw_rectangle(
  Image *img,
  int posX,
  int posY,
  int width,
  int height,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangle(img, posX, posY, width, height, c);
}

void
moonbit_raylib_image_draw_rectangle_v(
  Image *img,
  moonbit_bytes_t position,
  moonbit_bytes_t size,
  moonbit_bytes_t color
) {
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Vector2 sz; memcpy(&sz, size, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangleV(img, pos, sz, c);
}

void
moonbit_raylib_image_draw_rectangle_rec(
  Image *img,
  moonbit_bytes_t rec,
  moonbit_bytes_t color
) {
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangleRec(img, r, c);
}

void
moonbit_raylib_image_draw_rectangle_lines(
  Image *img,
  moonbit_bytes_t rec,
  int thick,
  moonbit_bytes_t color
) {
  Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawRectangleLines(img, r, thick, c);
}

// ============================================================================
// Image drawing: Triangle
// ============================================================================

void
moonbit_raylib_image_draw_triangle(
  Image *img,
  moonbit_bytes_t v1,
  moonbit_bytes_t v2,
  moonbit_bytes_t v3,
  moonbit_bytes_t color
) {
  Vector2 a; memcpy(&a, v1, sizeof(Vector2));
  Vector2 b; memcpy(&b, v2, sizeof(Vector2));
  Vector2 cv; memcpy(&cv, v3, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangle(img, a, b, cv, c);
}

void
moonbit_raylib_image_draw_triangle_ex(
  Image *img,
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
  ImageDrawTriangleEx(img, a, b, cv, col1, col2, col3);
}

void
moonbit_raylib_image_draw_triangle_lines(
  Image *img,
  moonbit_bytes_t v1,
  moonbit_bytes_t v2,
  moonbit_bytes_t v3,
  moonbit_bytes_t color
) {
  Vector2 a; memcpy(&a, v1, sizeof(Vector2));
  Vector2 b; memcpy(&b, v2, sizeof(Vector2));
  Vector2 cv; memcpy(&cv, v3, sizeof(Vector2));
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangleLines(img, a, b, cv, c);
}

void
moonbit_raylib_image_draw_triangle_fan(
  Image *img,
  moonbit_bytes_t points,
  int pointCount,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangleFan(img, (Vector2 *)points, pointCount, c);
}

void
moonbit_raylib_image_draw_triangle_strip(
  Image *img,
  moonbit_bytes_t points,
  int pointCount,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawTriangleStrip(img, (Vector2 *)points, pointCount, c);
}

// ============================================================================
// Image drawing: Compositing
// ============================================================================

void
moonbit_raylib_image_draw(
  Image *dst,
  Image *src,
  moonbit_bytes_t srcRec,
  moonbit_bytes_t dstRec,
  moonbit_bytes_t tint
) {
  Rectangle sr; memcpy(&sr, srcRec, sizeof(Rectangle));
  Rectangle dr; memcpy(&dr, dstRec, sizeof(Rectangle));
  Color c; memcpy(&c, tint, sizeof(Color));
  ImageDraw(dst, *src, sr, dr, c);
}

// ============================================================================
// Image drawing: Text
// ============================================================================

void
moonbit_raylib_image_draw_text(
  Image *img,
  moonbit_bytes_t text,
  int posX,
  int posY,
  int fontSize,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  ImageDrawText(img, (const char *)text, posX, posY, fontSize, c);
}

void
moonbit_raylib_image_draw_text_ex(
  Image *img,
  FontWrapper *w,
  moonbit_bytes_t text,
  moonbit_bytes_t position,
  float fontSize,
  float spacing,
  moonbit_bytes_t tint
) {
  assert(w->data && "use of unloaded font");
  Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
  Color c; memcpy(&c, tint, sizeof(Color));
  ImageDrawTextEx(img, *w->data, (const char *)text, pos, fontSize, spacing, c);
}
