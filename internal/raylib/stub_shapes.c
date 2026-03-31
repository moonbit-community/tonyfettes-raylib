#include "stub_internal.h"

// ============================================================================
// Shapes: Basic drawing
// ============================================================================

void
moonbit_raylib_draw_pixel(int posX, int posY, moonbit_bytes_t color) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawPixel(posX, posY, c);
}

void
moonbit_raylib_draw_pixel_v(moonbit_bytes_t position, moonbit_bytes_t color) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawPixelV(pos, c);
}

void
moonbit_raylib_draw_line(
  int startX,
  int startY,
  int endX,
  int endY,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawLine(startX, startY, endX, endY, c);
}

void
moonbit_raylib_draw_line_v(
  moonbit_bytes_t start,
  moonbit_bytes_t end,
  moonbit_bytes_t color
) {
  Vector2 s;
  memcpy(&s, start, sizeof(Vector2));
  Vector2 e;
  memcpy(&e, end, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawLineV(s, e, c);
}

void
moonbit_raylib_draw_line_bezier(
  moonbit_bytes_t start,
  moonbit_bytes_t end,
  float thick,
  moonbit_bytes_t color
) {
  Vector2 s;
  memcpy(&s, start, sizeof(Vector2));
  Vector2 e;
  memcpy(&e, end, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawLineBezier(s, e, thick, c);
}

void
moonbit_raylib_draw_circle_gradient(
  int centerX,
  int centerY,
  float radius,
  moonbit_bytes_t inner,
  moonbit_bytes_t outer
) {
  Color ci;
  memcpy(&ci, inner, sizeof(Color));
  Color co;
  memcpy(&co, outer, sizeof(Color));
  DrawCircleGradient(centerX, centerY, radius, ci, co);
}

void
moonbit_raylib_draw_circle_lines(
  int centerX,
  int centerY,
  float radius,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCircleLines(centerX, centerY, radius, c);
}

void
moonbit_raylib_draw_circle_lines_v(
  moonbit_bytes_t center,
  float radius,
  moonbit_bytes_t color
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCircleLinesV(ctr, radius, c);
}

void
moonbit_raylib_draw_ellipse(
  int centerX,
  int centerY,
  float radiusH,
  float radiusV,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawEllipse(centerX, centerY, radiusH, radiusV, c);
}

void
moonbit_raylib_draw_ellipse_lines(
  int centerX,
  int centerY,
  float radiusH,
  float radiusV,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawEllipseLines(centerX, centerY, radiusH, radiusV, c);
}

void
moonbit_raylib_draw_rectangle_rounded(
  moonbit_bytes_t rec,
  float roundness,
  int segments,
  moonbit_bytes_t color
) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRectangleRounded(r, roundness, segments, c);
}

void
moonbit_raylib_draw_rectangle_rounded_lines(
  moonbit_bytes_t rec,
  float roundness,
  int segments,
  moonbit_bytes_t color
) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRectangleRoundedLines(r, roundness, segments, c);
}

void
moonbit_raylib_draw_rectangle_rounded_lines_ex(
  moonbit_bytes_t rec,
  float roundness,
  int segments,
  float lineThick,
  moonbit_bytes_t color
) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRectangleRoundedLinesEx(r, roundness, segments, lineThick, c);
}

// ============================================================================
// Shapes: Missing basic shapes (array-based + circle sector lines)
// ============================================================================

// ============================================================================
// Shapes: 3D triangle strip
// ============================================================================

void moonbit_raylib_draw_triangle_strip_3d(moonbit_bytes_t points, int pointCount, moonbit_bytes_t color) {
  Vector3 *pts = (Vector3 *)points;
  Color c; memcpy(&c, color, sizeof(Color));
  DrawTriangleStrip3D(pts, pointCount, c);
}
