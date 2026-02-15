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
moonbit_raylib_draw_line_ex(
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
  DrawLineEx(s, e, thick, c);
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
moonbit_raylib_draw_circle(
  int centerX,
  int centerY,
  float radius,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCircle(centerX, centerY, radius, c);
}

void
moonbit_raylib_draw_circle_sector(
  moonbit_bytes_t center,
  float radius,
  float startAngle,
  float endAngle,
  int segments,
  moonbit_bytes_t color
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCircleSector(ctr, radius, startAngle, endAngle, segments, c);
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
moonbit_raylib_draw_circle_v(
  moonbit_bytes_t center,
  float radius,
  moonbit_bytes_t color
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCircleV(ctr, radius, c);
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
moonbit_raylib_draw_ring(
  moonbit_bytes_t center,
  float innerRadius,
  float outerRadius,
  float startAngle,
  float endAngle,
  int segments,
  moonbit_bytes_t color
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRing(ctr, innerRadius, outerRadius, startAngle, endAngle, segments, c);
}

void
moonbit_raylib_draw_ring_lines(
  moonbit_bytes_t center,
  float innerRadius,
  float outerRadius,
  float startAngle,
  float endAngle,
  int segments,
  moonbit_bytes_t color
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRingLines(
    ctr, innerRadius, outerRadius, startAngle, endAngle, segments, c
  );
}

void
moonbit_raylib_draw_rectangle(
  int posX,
  int posY,
  int width,
  int height,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRectangle(posX, posY, width, height, c);
}

void
moonbit_raylib_draw_rectangleV(
  moonbit_bytes_t position,
  moonbit_bytes_t size,
  moonbit_bytes_t color
) {
  Vector2 pos;
  memcpy(&pos, position, sizeof(Vector2));
  Vector2 sz;
  memcpy(&sz, size, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRectangleV(pos, sz, c);
}

void
moonbit_raylib_draw_rectangle_rec(moonbit_bytes_t rec, moonbit_bytes_t color) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRectangleRec(r, c);
}

void
moonbit_raylib_draw_rectangle_pro(
  moonbit_bytes_t rec,
  moonbit_bytes_t origin,
  float rotation,
  moonbit_bytes_t color
) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  Vector2 o;
  memcpy(&o, origin, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRectanglePro(r, o, rotation, c);
}

void
moonbit_raylib_draw_rectangle_gradient_v(
  int posX,
  int posY,
  int width,
  int height,
  moonbit_bytes_t top,
  moonbit_bytes_t bottom
) {
  Color t;
  memcpy(&t, top, sizeof(Color));
  Color b;
  memcpy(&b, bottom, sizeof(Color));
  DrawRectangleGradientV(posX, posY, width, height, t, b);
}

void
moonbit_raylib_draw_rectangle_gradient_h(
  int posX,
  int posY,
  int width,
  int height,
  moonbit_bytes_t left,
  moonbit_bytes_t right
) {
  Color l;
  memcpy(&l, left, sizeof(Color));
  Color r;
  memcpy(&r, right, sizeof(Color));
  DrawRectangleGradientH(posX, posY, width, height, l, r);
}

void
moonbit_raylib_draw_rectangle_gradient_ex(
  moonbit_bytes_t rec,
  moonbit_bytes_t tl,
  moonbit_bytes_t bl,
  moonbit_bytes_t tr,
  moonbit_bytes_t br
) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  Color c_tl;
  memcpy(&c_tl, tl, sizeof(Color));
  Color c_bl;
  memcpy(&c_bl, bl, sizeof(Color));
  Color c_tr;
  memcpy(&c_tr, tr, sizeof(Color));
  Color c_br;
  memcpy(&c_br, br, sizeof(Color));
  DrawRectangleGradientEx(r, c_tl, c_bl, c_tr, c_br);
}

void
moonbit_raylib_draw_rectangle_lines(
  int posX,
  int posY,
  int width,
  int height,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRectangleLines(posX, posY, width, height, c);
}

void
moonbit_raylib_draw_rectangle_lines_ex(
  moonbit_bytes_t rec,
  float lineThick,
  moonbit_bytes_t color
) {
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRectangleLinesEx(r, lineThick, c);
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

void
moonbit_raylib_draw_triangle(
  moonbit_bytes_t v1,
  moonbit_bytes_t v2,
  moonbit_bytes_t v3,
  moonbit_bytes_t color
) {
  Vector2 a;
  memcpy(&a, v1, sizeof(Vector2));
  Vector2 b;
  memcpy(&b, v2, sizeof(Vector2));
  Vector2 cv;
  memcpy(&cv, v3, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawTriangle(a, b, cv, c);
}

void
moonbit_raylib_draw_triangle_lines(
  moonbit_bytes_t v1,
  moonbit_bytes_t v2,
  moonbit_bytes_t v3,
  moonbit_bytes_t color
) {
  Vector2 a;
  memcpy(&a, v1, sizeof(Vector2));
  Vector2 b;
  memcpy(&b, v2, sizeof(Vector2));
  Vector2 cv;
  memcpy(&cv, v3, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawTriangleLines(a, b, cv, c);
}

void
moonbit_raylib_draw_poly(
  moonbit_bytes_t center,
  int sides,
  float radius,
  float rotation,
  moonbit_bytes_t color
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawPoly(ctr, sides, radius, rotation, c);
}

void
moonbit_raylib_draw_poly_lines(
  moonbit_bytes_t center,
  int sides,
  float radius,
  float rotation,
  moonbit_bytes_t color
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawPolyLines(ctr, sides, radius, rotation, c);
}

void
moonbit_raylib_draw_poly_lines_ex(
  moonbit_bytes_t center,
  int sides,
  float radius,
  float rotation,
  float lineThick,
  moonbit_bytes_t color
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawPolyLinesEx(ctr, sides, radius, rotation, lineThick, c);
}

// ============================================================================
// Shapes: Collision detection
// ============================================================================

int
moonbit_raylib_check_collision_recs(
  moonbit_bytes_t rec1,
  moonbit_bytes_t rec2
) {
  Rectangle r1;
  memcpy(&r1, rec1, sizeof(Rectangle));
  Rectangle r2;
  memcpy(&r2, rec2, sizeof(Rectangle));
  return (int)CheckCollisionRecs(r1, r2);
}

int
moonbit_raylib_check_collision_circles(
  moonbit_bytes_t c1,
  float r1,
  moonbit_bytes_t c2,
  float r2
) {
  Vector2 center1;
  memcpy(&center1, c1, sizeof(Vector2));
  Vector2 center2;
  memcpy(&center2, c2, sizeof(Vector2));
  return (int)CheckCollisionCircles(center1, r1, center2, r2);
}

int
moonbit_raylib_check_collision_circle_rec(
  moonbit_bytes_t center,
  float radius,
  moonbit_bytes_t rec
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  return (int)CheckCollisionCircleRec(ctr, radius, r);
}

int
moonbit_raylib_check_collision_point_rec(
  moonbit_bytes_t point,
  moonbit_bytes_t rec
) {
  Vector2 p;
  memcpy(&p, point, sizeof(Vector2));
  Rectangle r;
  memcpy(&r, rec, sizeof(Rectangle));
  return (int)CheckCollisionPointRec(p, r);
}

int
moonbit_raylib_check_collision_point_circle(
  moonbit_bytes_t point,
  moonbit_bytes_t center,
  float radius
) {
  Vector2 p;
  memcpy(&p, point, sizeof(Vector2));
  Vector2 c;
  memcpy(&c, center, sizeof(Vector2));
  return (int)CheckCollisionPointCircle(p, c, radius);
}

int
moonbit_raylib_check_collision_point_triangle(
  moonbit_bytes_t point,
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3
) {
  Vector2 pt;
  memcpy(&pt, point, sizeof(Vector2));
  Vector2 a;
  memcpy(&a, p1, sizeof(Vector2));
  Vector2 b;
  memcpy(&b, p2, sizeof(Vector2));
  Vector2 c;
  memcpy(&c, p3, sizeof(Vector2));
  return (int)CheckCollisionPointTriangle(pt, a, b, c);
}

moonbit_bytes_t
moonbit_raylib_get_collision_rec(moonbit_bytes_t rec1, moonbit_bytes_t rec2) {
  Rectangle r1;
  memcpy(&r1, rec1, sizeof(Rectangle));
  Rectangle r2;
  memcpy(&r2, rec2, sizeof(Rectangle));
  Rectangle result = GetCollisionRec(r1, r2);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Rectangle), 0);
  memcpy(r, &result, sizeof(Rectangle));
  return r;
}

// ============================================================================
// Shapes: Missing basic shapes (array-based + circle sector lines)
// ============================================================================

void
moonbit_raylib_draw_circle_sector_lines(
  moonbit_bytes_t center,
  float radius,
  float startAngle,
  float endAngle,
  int segments,
  moonbit_bytes_t color
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCircleSectorLines(ctr, radius, startAngle, endAngle, segments, c);
}

void
moonbit_raylib_draw_line_strip(
  moonbit_bytes_t points,
  int pointCount,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawLineStrip((Vector2 *)points, pointCount, c);
}

void
moonbit_raylib_draw_triangle_fan(
  moonbit_bytes_t points,
  int pointCount,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawTriangleFan((Vector2 *)points, pointCount, c);
}

void
moonbit_raylib_draw_triangle_strip(
  moonbit_bytes_t points,
  int pointCount,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawTriangleStrip((Vector2 *)points, pointCount, c);
}

// ============================================================================
// Shapes: Spline drawing (array-based)
// ============================================================================

void
moonbit_raylib_draw_spline_linear(
  moonbit_bytes_t points,
  int pointCount,
  float thick,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSplineLinear((Vector2 *)points, pointCount, thick, c);
}

void
moonbit_raylib_draw_spline_basis(
  moonbit_bytes_t points,
  int pointCount,
  float thick,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSplineBasis((Vector2 *)points, pointCount, thick, c);
}

void
moonbit_raylib_draw_spline_catmull_rom(
  moonbit_bytes_t points,
  int pointCount,
  float thick,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSplineCatmullRom((Vector2 *)points, pointCount, thick, c);
}

void
moonbit_raylib_draw_spline_bezier_quadratic(
  moonbit_bytes_t points,
  int pointCount,
  float thick,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSplineBezierQuadratic((Vector2 *)points, pointCount, thick, c);
}

void
moonbit_raylib_draw_spline_bezier_cubic(
  moonbit_bytes_t points,
  int pointCount,
  float thick,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSplineBezierCubic((Vector2 *)points, pointCount, thick, c);
}

// ============================================================================
// Shapes: Spline segments
// ============================================================================

void
moonbit_raylib_draw_spline_segment_linear(
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  float thick,
  moonbit_bytes_t color
) {
  Vector2 v1;
  memcpy(&v1, p1, sizeof(Vector2));
  Vector2 v2;
  memcpy(&v2, p2, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSplineSegmentLinear(v1, v2, thick, c);
}

void
moonbit_raylib_draw_spline_segment_basis(
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3,
  moonbit_bytes_t p4,
  float thick,
  moonbit_bytes_t color
) {
  Vector2 v1;
  memcpy(&v1, p1, sizeof(Vector2));
  Vector2 v2;
  memcpy(&v2, p2, sizeof(Vector2));
  Vector2 v3;
  memcpy(&v3, p3, sizeof(Vector2));
  Vector2 v4;
  memcpy(&v4, p4, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSplineSegmentBasis(v1, v2, v3, v4, thick, c);
}

void
moonbit_raylib_draw_spline_segment_catmull_rom(
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3,
  moonbit_bytes_t p4,
  float thick,
  moonbit_bytes_t color
) {
  Vector2 v1;
  memcpy(&v1, p1, sizeof(Vector2));
  Vector2 v2;
  memcpy(&v2, p2, sizeof(Vector2));
  Vector2 v3;
  memcpy(&v3, p3, sizeof(Vector2));
  Vector2 v4;
  memcpy(&v4, p4, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSplineSegmentCatmullRom(v1, v2, v3, v4, thick, c);
}

void
moonbit_raylib_draw_spline_segment_bezier_quadratic(
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3,
  float thick,
  moonbit_bytes_t color
) {
  Vector2 v1;
  memcpy(&v1, p1, sizeof(Vector2));
  Vector2 v2;
  memcpy(&v2, p2, sizeof(Vector2));
  Vector2 v3;
  memcpy(&v3, p3, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSplineSegmentBezierQuadratic(v1, v2, v3, thick, c);
}

void
moonbit_raylib_draw_spline_segment_bezier_cubic(
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3,
  moonbit_bytes_t p4,
  float thick,
  moonbit_bytes_t color
) {
  Vector2 v1;
  memcpy(&v1, p1, sizeof(Vector2));
  Vector2 v2;
  memcpy(&v2, p2, sizeof(Vector2));
  Vector2 v3;
  memcpy(&v3, p3, sizeof(Vector2));
  Vector2 v4;
  memcpy(&v4, p4, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSplineSegmentBezierCubic(v1, v2, v3, v4, thick, c);
}

// ============================================================================
// Shapes: Spline point evaluation
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_spline_point_linear(
  moonbit_bytes_t startPos,
  moonbit_bytes_t endPos,
  float t
) {
  Vector2 s;
  memcpy(&s, startPos, sizeof(Vector2));
  Vector2 e;
  memcpy(&e, endPos, sizeof(Vector2));
  Vector2 result = GetSplinePointLinear(s, e, t);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_spline_point_basis(
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3,
  moonbit_bytes_t p4,
  float t
) {
  Vector2 v1;
  memcpy(&v1, p1, sizeof(Vector2));
  Vector2 v2;
  memcpy(&v2, p2, sizeof(Vector2));
  Vector2 v3;
  memcpy(&v3, p3, sizeof(Vector2));
  Vector2 v4;
  memcpy(&v4, p4, sizeof(Vector2));
  Vector2 result = GetSplinePointBasis(v1, v2, v3, v4, t);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_spline_point_catmull_rom(
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3,
  moonbit_bytes_t p4,
  float t
) {
  Vector2 v1;
  memcpy(&v1, p1, sizeof(Vector2));
  Vector2 v2;
  memcpy(&v2, p2, sizeof(Vector2));
  Vector2 v3;
  memcpy(&v3, p3, sizeof(Vector2));
  Vector2 v4;
  memcpy(&v4, p4, sizeof(Vector2));
  Vector2 result = GetSplinePointCatmullRom(v1, v2, v3, v4, t);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_spline_point_bezier_quad(
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3,
  float t
) {
  Vector2 v1;
  memcpy(&v1, p1, sizeof(Vector2));
  Vector2 v2;
  memcpy(&v2, p2, sizeof(Vector2));
  Vector2 v3;
  memcpy(&v3, p3, sizeof(Vector2));
  Vector2 result = GetSplinePointBezierQuad(v1, v2, v3, t);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

moonbit_bytes_t
moonbit_raylib_get_spline_point_bezier_cubic(
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3,
  moonbit_bytes_t p4,
  float t
) {
  Vector2 v1;
  memcpy(&v1, p1, sizeof(Vector2));
  Vector2 v2;
  memcpy(&v2, p2, sizeof(Vector2));
  Vector2 v3;
  memcpy(&v3, p3, sizeof(Vector2));
  Vector2 v4;
  memcpy(&v4, p4, sizeof(Vector2));
  Vector2 result = GetSplinePointBezierCubic(v1, v2, v3, v4, t);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
  memcpy(r, &result, sizeof(Vector2));
  return r;
}

// ============================================================================
// Shapes: Additional 2D collision detection
// ============================================================================

int
moonbit_raylib_check_collision_circle_line(
  moonbit_bytes_t center,
  float radius,
  moonbit_bytes_t p1,
  moonbit_bytes_t p2
) {
  Vector2 ctr;
  memcpy(&ctr, center, sizeof(Vector2));
  Vector2 a;
  memcpy(&a, p1, sizeof(Vector2));
  Vector2 b;
  memcpy(&b, p2, sizeof(Vector2));
  return (int)CheckCollisionCircleLine(ctr, radius, a, b);
}

int
moonbit_raylib_check_collision_point_line(
  moonbit_bytes_t point,
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  int threshold
) {
  Vector2 pt;
  memcpy(&pt, point, sizeof(Vector2));
  Vector2 a;
  memcpy(&a, p1, sizeof(Vector2));
  Vector2 b;
  memcpy(&b, p2, sizeof(Vector2));
  return (int)CheckCollisionPointLine(pt, a, b, threshold);
}
