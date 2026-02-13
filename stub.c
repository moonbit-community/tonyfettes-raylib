#include <moonbit.h>
#include <string.h>
#include "raylib.h"

// ============================================================================
// Resource type wrappers with GC finalizers
// ============================================================================

typedef struct { Image image; int freed; } ImageWrapper;
typedef struct { Texture texture; int freed; } TextureWrapper;
typedef struct { RenderTexture render_texture; int freed; } RenderTextureWrapper;
typedef struct { Font font; int freed; } FontWrapper;
typedef struct { Sound sound; int freed; } SoundWrapper;
typedef struct { Music music; int freed; } MusicWrapper;
typedef struct { Model model; int freed; } ModelWrapper;

static void image_destructor(void *ptr) {
    ImageWrapper *w = (ImageWrapper*)ptr;
    if (!w->freed) UnloadImage(w->image);
}
static void texture_destructor(void *ptr) {
    TextureWrapper *w = (TextureWrapper*)ptr;
    if (!w->freed) UnloadTexture(w->texture);
}
static void render_texture_destructor(void *ptr) {
    RenderTextureWrapper *w = (RenderTextureWrapper*)ptr;
    if (!w->freed) UnloadRenderTexture(w->render_texture);
}
static void font_destructor(void *ptr) {
    FontWrapper *w = (FontWrapper*)ptr;
    if (!w->freed) UnloadFont(w->font);
}
static void sound_destructor(void *ptr) {
    SoundWrapper *w = (SoundWrapper*)ptr;
    if (!w->freed) UnloadSound(w->sound);
}
static void music_destructor(void *ptr) {
    MusicWrapper *w = (MusicWrapper*)ptr;
    if (!w->freed) UnloadMusicStream(w->music);
}
static void model_destructor(void *ptr) {
    ModelWrapper *w = (ModelWrapper*)ptr;
    if (!w->freed) UnloadModel(w->model);
}

// ============================================================================
// Core: Window management
// ============================================================================

void moonbit_raylib_init_window(int width, int height, moonbit_bytes_t title) {
    InitWindow(width, height, (const char*)title);
}

void moonbit_raylib_set_window_title(moonbit_bytes_t title) {
    SetWindowTitle((const char*)title);
}

// ============================================================================
// Core: Drawing - struct parameters
// ============================================================================

void moonbit_raylib_clear_background(moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    ClearBackground(c);
}

void moonbit_raylib_begin_mode_2d(moonbit_bytes_t camera) {
    Camera2D c; memcpy(&c, camera, sizeof(Camera2D));
    BeginMode2D(c);
}

void moonbit_raylib_begin_mode_3d(moonbit_bytes_t camera) {
    Camera3D c; memcpy(&c, camera, sizeof(Camera3D));
    BeginMode3D(c);
}

// ============================================================================
// Core: Input - returns structs
// ============================================================================

moonbit_bytes_t moonbit_raylib_get_mouse_position(void) {
    Vector2 v = GetMousePosition();
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
    memcpy(r, &v, sizeof(Vector2));
    return r;
}

moonbit_bytes_t moonbit_raylib_get_mouse_delta(void) {
    Vector2 v = GetMouseDelta();
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
    memcpy(r, &v, sizeof(Vector2));
    return r;
}

moonbit_bytes_t moonbit_raylib_get_mouse_wheel_move_v(void) {
    Vector2 v = GetMouseWheelMoveV();
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
    memcpy(r, &v, sizeof(Vector2));
    return r;
}

// ============================================================================
// Core: Camera
// ============================================================================

moonbit_bytes_t moonbit_raylib_update_camera(moonbit_bytes_t camera_bytes, int mode) {
    Camera3D camera; memcpy(&camera, camera_bytes, sizeof(Camera3D));
    UpdateCamera(&camera, mode);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Camera3D), 0);
    memcpy(r, &camera, sizeof(Camera3D));
    return r;
}

moonbit_bytes_t moonbit_raylib_update_camera_pro(moonbit_bytes_t camera_bytes, moonbit_bytes_t movement, moonbit_bytes_t rotation, float zoom) {
    Camera3D camera; memcpy(&camera, camera_bytes, sizeof(Camera3D));
    Vector3 mov; memcpy(&mov, movement, sizeof(Vector3));
    Vector3 rot; memcpy(&rot, rotation, sizeof(Vector3));
    UpdateCameraPro(&camera, mov, rot, zoom);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Camera3D), 0);
    memcpy(r, &camera, sizeof(Camera3D));
    return r;
}

moonbit_bytes_t moonbit_raylib_get_world_to_screen(moonbit_bytes_t position, moonbit_bytes_t camera) {
    Vector3 pos; memcpy(&pos, position, sizeof(Vector3));
    Camera3D cam; memcpy(&cam, camera, sizeof(Camera3D));
    Vector2 result = GetWorldToScreen(pos, cam);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
    memcpy(r, &result, sizeof(Vector2));
    return r;
}

moonbit_bytes_t moonbit_raylib_get_screen_to_world_2d(moonbit_bytes_t position, moonbit_bytes_t camera) {
    Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
    Camera2D cam; memcpy(&cam, camera, sizeof(Camera2D));
    Vector2 result = GetScreenToWorld2D(pos, cam);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
    memcpy(r, &result, sizeof(Vector2));
    return r;
}

moonbit_bytes_t moonbit_raylib_get_world_to_screen_2d(moonbit_bytes_t position, moonbit_bytes_t camera) {
    Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
    Camera2D cam; memcpy(&cam, camera, sizeof(Camera2D));
    Vector2 result = GetWorldToScreen2D(pos, cam);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
    memcpy(r, &result, sizeof(Vector2));
    return r;
}

// ============================================================================
// Core: Misc (string params)
// ============================================================================

void moonbit_raylib_take_screenshot(moonbit_bytes_t fileName) {
    TakeScreenshot((const char*)fileName);
}

void moonbit_raylib_open_url(moonbit_bytes_t url) {
    OpenURL((const char*)url);
}

// ============================================================================
// Core: Color utilities
// ============================================================================

moonbit_bytes_t moonbit_raylib_fade(moonbit_bytes_t color, float alpha) {
    Color c; memcpy(&c, color, sizeof(Color));
    Color result = Fade(c, alpha);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
    memcpy(r, &result, sizeof(Color));
    return r;
}

moonbit_bytes_t moonbit_raylib_color_alpha(moonbit_bytes_t color, float alpha) {
    Color c; memcpy(&c, color, sizeof(Color));
    Color result = ColorAlpha(c, alpha);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
    memcpy(r, &result, sizeof(Color));
    return r;
}

int moonbit_raylib_color_to_int(moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    return ColorToInt(c);
}

moonbit_bytes_t moonbit_raylib_get_color(unsigned int hexValue) {
    Color result = GetColor(hexValue);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
    memcpy(r, &result, sizeof(Color));
    return r;
}

moonbit_bytes_t moonbit_raylib_color_from_hsv(float hue, float saturation, float value) {
    Color result = ColorFromHSV(hue, saturation, value);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
    memcpy(r, &result, sizeof(Color));
    return r;
}

moonbit_bytes_t moonbit_raylib_color_tint(moonbit_bytes_t color, moonbit_bytes_t tint) {
    Color c; memcpy(&c, color, sizeof(Color));
    Color t; memcpy(&t, tint, sizeof(Color));
    Color result = ColorTint(c, t);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
    memcpy(r, &result, sizeof(Color));
    return r;
}

moonbit_bytes_t moonbit_raylib_color_brightness(moonbit_bytes_t color, float factor) {
    Color c; memcpy(&c, color, sizeof(Color));
    Color result = ColorBrightness(c, factor);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
    memcpy(r, &result, sizeof(Color));
    return r;
}

moonbit_bytes_t moonbit_raylib_color_lerp(moonbit_bytes_t color1, moonbit_bytes_t color2, float factor) {
    Color c1; memcpy(&c1, color1, sizeof(Color));
    Color c2; memcpy(&c2, color2, sizeof(Color));
    Color result = ColorLerp(c1, c2, factor);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
    memcpy(r, &result, sizeof(Color));
    return r;
}

int moonbit_raylib_color_is_equal(moonbit_bytes_t col1, moonbit_bytes_t col2) {
    Color c1; memcpy(&c1, col1, sizeof(Color));
    Color c2; memcpy(&c2, col2, sizeof(Color));
    return (int)ColorIsEqual(c1, c2);
}

// ============================================================================
// Shapes: Basic drawing
// ============================================================================

void moonbit_raylib_draw_pixel(int posX, int posY, moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    DrawPixel(posX, posY, c);
}

void moonbit_raylib_draw_pixel_v(moonbit_bytes_t position, moonbit_bytes_t color) {
    Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawPixelV(pos, c);
}

void moonbit_raylib_draw_line(int startX, int startY, int endX, int endY, moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    DrawLine(startX, startY, endX, endY, c);
}

void moonbit_raylib_draw_line_v(moonbit_bytes_t start, moonbit_bytes_t end, moonbit_bytes_t color) {
    Vector2 s; memcpy(&s, start, sizeof(Vector2));
    Vector2 e; memcpy(&e, end, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawLineV(s, e, c);
}

void moonbit_raylib_draw_line_ex(moonbit_bytes_t start, moonbit_bytes_t end, float thick, moonbit_bytes_t color) {
    Vector2 s; memcpy(&s, start, sizeof(Vector2));
    Vector2 e; memcpy(&e, end, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawLineEx(s, e, thick, c);
}

void moonbit_raylib_draw_line_bezier(moonbit_bytes_t start, moonbit_bytes_t end, float thick, moonbit_bytes_t color) {
    Vector2 s; memcpy(&s, start, sizeof(Vector2));
    Vector2 e; memcpy(&e, end, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawLineBezier(s, e, thick, c);
}

void moonbit_raylib_draw_circle(int centerX, int centerY, float radius, moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCircle(centerX, centerY, radius, c);
}

void moonbit_raylib_draw_circle_sector(moonbit_bytes_t center, float radius, float startAngle, float endAngle, int segments, moonbit_bytes_t color) {
    Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCircleSector(ctr, radius, startAngle, endAngle, segments, c);
}

void moonbit_raylib_draw_circle_gradient(int centerX, int centerY, float radius, moonbit_bytes_t inner, moonbit_bytes_t outer) {
    Color ci; memcpy(&ci, inner, sizeof(Color));
    Color co; memcpy(&co, outer, sizeof(Color));
    DrawCircleGradient(centerX, centerY, radius, ci, co);
}

void moonbit_raylib_draw_circle_v(moonbit_bytes_t center, float radius, moonbit_bytes_t color) {
    Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCircleV(ctr, radius, c);
}

void moonbit_raylib_draw_circle_lines(int centerX, int centerY, float radius, moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCircleLines(centerX, centerY, radius, c);
}

void moonbit_raylib_draw_circle_lines_v(moonbit_bytes_t center, float radius, moonbit_bytes_t color) {
    Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCircleLinesV(ctr, radius, c);
}

void moonbit_raylib_draw_ellipse(int centerX, int centerY, float radiusH, float radiusV, moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    DrawEllipse(centerX, centerY, radiusH, radiusV, c);
}

void moonbit_raylib_draw_ellipse_lines(int centerX, int centerY, float radiusH, float radiusV, moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    DrawEllipseLines(centerX, centerY, radiusH, radiusV, c);
}

void moonbit_raylib_draw_ring(moonbit_bytes_t center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, moonbit_bytes_t color) {
    Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRing(ctr, innerRadius, outerRadius, startAngle, endAngle, segments, c);
}

void moonbit_raylib_draw_ring_lines(moonbit_bytes_t center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, moonbit_bytes_t color) {
    Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRingLines(ctr, innerRadius, outerRadius, startAngle, endAngle, segments, c);
}

void moonbit_raylib_draw_rectangle(int posX, int posY, int width, int height, moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRectangle(posX, posY, width, height, c);
}

void moonbit_raylib_draw_rectangleV(moonbit_bytes_t position, moonbit_bytes_t size, moonbit_bytes_t color) {
    Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
    Vector2 sz; memcpy(&sz, size, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRectangleV(pos, sz, c);
}

void moonbit_raylib_draw_rectangle_rec(moonbit_bytes_t rec, moonbit_bytes_t color) {
    Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRectangleRec(r, c);
}

void moonbit_raylib_draw_rectangle_pro(moonbit_bytes_t rec, moonbit_bytes_t origin, float rotation, moonbit_bytes_t color) {
    Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
    Vector2 o; memcpy(&o, origin, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRectanglePro(r, o, rotation, c);
}

void moonbit_raylib_draw_rectangle_gradient_v(int posX, int posY, int width, int height, moonbit_bytes_t top, moonbit_bytes_t bottom) {
    Color t; memcpy(&t, top, sizeof(Color));
    Color b; memcpy(&b, bottom, sizeof(Color));
    DrawRectangleGradientV(posX, posY, width, height, t, b);
}

void moonbit_raylib_draw_rectangle_gradient_h(int posX, int posY, int width, int height, moonbit_bytes_t left, moonbit_bytes_t right) {
    Color l; memcpy(&l, left, sizeof(Color));
    Color r; memcpy(&r, right, sizeof(Color));
    DrawRectangleGradientH(posX, posY, width, height, l, r);
}

void moonbit_raylib_draw_rectangle_gradient_ex(moonbit_bytes_t rec, moonbit_bytes_t tl, moonbit_bytes_t bl, moonbit_bytes_t tr, moonbit_bytes_t br) {
    Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
    Color c_tl; memcpy(&c_tl, tl, sizeof(Color));
    Color c_bl; memcpy(&c_bl, bl, sizeof(Color));
    Color c_tr; memcpy(&c_tr, tr, sizeof(Color));
    Color c_br; memcpy(&c_br, br, sizeof(Color));
    DrawRectangleGradientEx(r, c_tl, c_bl, c_tr, c_br);
}

void moonbit_raylib_draw_rectangle_lines(int posX, int posY, int width, int height, moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRectangleLines(posX, posY, width, height, c);
}

void moonbit_raylib_draw_rectangle_lines_ex(moonbit_bytes_t rec, float lineThick, moonbit_bytes_t color) {
    Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRectangleLinesEx(r, lineThick, c);
}

void moonbit_raylib_draw_rectangle_rounded(moonbit_bytes_t rec, float roundness, int segments, moonbit_bytes_t color) {
    Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRectangleRounded(r, roundness, segments, c);
}

void moonbit_raylib_draw_rectangle_rounded_lines(moonbit_bytes_t rec, float roundness, int segments, moonbit_bytes_t color) {
    Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRectangleRoundedLines(r, roundness, segments, c);
}

void moonbit_raylib_draw_rectangle_rounded_lines_ex(moonbit_bytes_t rec, float roundness, int segments, float lineThick, moonbit_bytes_t color) {
    Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRectangleRoundedLinesEx(r, roundness, segments, lineThick, c);
}

void moonbit_raylib_draw_triangle(moonbit_bytes_t v1, moonbit_bytes_t v2, moonbit_bytes_t v3, moonbit_bytes_t color) {
    Vector2 a; memcpy(&a, v1, sizeof(Vector2));
    Vector2 b; memcpy(&b, v2, sizeof(Vector2));
    Vector2 cv; memcpy(&cv, v3, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawTriangle(a, b, cv, c);
}

void moonbit_raylib_draw_triangle_lines(moonbit_bytes_t v1, moonbit_bytes_t v2, moonbit_bytes_t v3, moonbit_bytes_t color) {
    Vector2 a; memcpy(&a, v1, sizeof(Vector2));
    Vector2 b; memcpy(&b, v2, sizeof(Vector2));
    Vector2 cv; memcpy(&cv, v3, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawTriangleLines(a, b, cv, c);
}

void moonbit_raylib_draw_poly(moonbit_bytes_t center, int sides, float radius, float rotation, moonbit_bytes_t color) {
    Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawPoly(ctr, sides, radius, rotation, c);
}

void moonbit_raylib_draw_poly_lines(moonbit_bytes_t center, int sides, float radius, float rotation, moonbit_bytes_t color) {
    Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawPolyLines(ctr, sides, radius, rotation, c);
}

void moonbit_raylib_draw_poly_lines_ex(moonbit_bytes_t center, int sides, float radius, float rotation, float lineThick, moonbit_bytes_t color) {
    Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawPolyLinesEx(ctr, sides, radius, rotation, lineThick, c);
}

// ============================================================================
// Shapes: Collision detection
// ============================================================================

int moonbit_raylib_check_collision_recs(moonbit_bytes_t rec1, moonbit_bytes_t rec2) {
    Rectangle r1; memcpy(&r1, rec1, sizeof(Rectangle));
    Rectangle r2; memcpy(&r2, rec2, sizeof(Rectangle));
    return (int)CheckCollisionRecs(r1, r2);
}

int moonbit_raylib_check_collision_circles(moonbit_bytes_t c1, float r1, moonbit_bytes_t c2, float r2) {
    Vector2 center1; memcpy(&center1, c1, sizeof(Vector2));
    Vector2 center2; memcpy(&center2, c2, sizeof(Vector2));
    return (int)CheckCollisionCircles(center1, r1, center2, r2);
}

int moonbit_raylib_check_collision_circle_rec(moonbit_bytes_t center, float radius, moonbit_bytes_t rec) {
    Vector2 ctr; memcpy(&ctr, center, sizeof(Vector2));
    Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
    return (int)CheckCollisionCircleRec(ctr, radius, r);
}

int moonbit_raylib_check_collision_point_rec(moonbit_bytes_t point, moonbit_bytes_t rec) {
    Vector2 p; memcpy(&p, point, sizeof(Vector2));
    Rectangle r; memcpy(&r, rec, sizeof(Rectangle));
    return (int)CheckCollisionPointRec(p, r);
}

int moonbit_raylib_check_collision_point_circle(moonbit_bytes_t point, moonbit_bytes_t center, float radius) {
    Vector2 p; memcpy(&p, point, sizeof(Vector2));
    Vector2 c; memcpy(&c, center, sizeof(Vector2));
    return (int)CheckCollisionPointCircle(p, c, radius);
}

int moonbit_raylib_check_collision_point_triangle(moonbit_bytes_t point, moonbit_bytes_t p1, moonbit_bytes_t p2, moonbit_bytes_t p3) {
    Vector2 pt; memcpy(&pt, point, sizeof(Vector2));
    Vector2 a; memcpy(&a, p1, sizeof(Vector2));
    Vector2 b; memcpy(&b, p2, sizeof(Vector2));
    Vector2 c; memcpy(&c, p3, sizeof(Vector2));
    return (int)CheckCollisionPointTriangle(pt, a, b, c);
}

moonbit_bytes_t moonbit_raylib_get_collision_rec(moonbit_bytes_t rec1, moonbit_bytes_t rec2) {
    Rectangle r1; memcpy(&r1, rec1, sizeof(Rectangle));
    Rectangle r2; memcpy(&r2, rec2, sizeof(Rectangle));
    Rectangle result = GetCollisionRec(r1, r2);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Rectangle), 0);
    memcpy(r, &result, sizeof(Rectangle));
    return r;
}

// ============================================================================
// Textures: Image loading (resource types)
// ============================================================================

ImageWrapper* moonbit_raylib_load_image(moonbit_bytes_t fileName) {
    ImageWrapper *w = (ImageWrapper*)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
    w->image = LoadImage((const char*)fileName);
    w->freed = 0;
    return w;
}

void moonbit_raylib_unload_image(ImageWrapper *wrapper) {
    if (wrapper && !wrapper->freed) {
        UnloadImage(wrapper->image);
        wrapper->freed = 1;
    }
}

ImageWrapper* moonbit_raylib_gen_image_color(int width, int height, moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    ImageWrapper *w = (ImageWrapper*)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
    w->image = GenImageColor(width, height, c);
    w->freed = 0;
    return w;
}

ImageWrapper* moonbit_raylib_gen_image_checked(int width, int height, int checksX, int checksY, moonbit_bytes_t col1, moonbit_bytes_t col2) {
    Color c1; memcpy(&c1, col1, sizeof(Color));
    Color c2; memcpy(&c2, col2, sizeof(Color));
    ImageWrapper *w = (ImageWrapper*)moonbit_make_external_object(image_destructor, sizeof(ImageWrapper));
    w->image = GenImageChecked(width, height, checksX, checksY, c1, c2);
    w->freed = 0;
    return w;
}

// ============================================================================
// Textures: Texture loading (resource types)
// ============================================================================

TextureWrapper* moonbit_raylib_load_texture(moonbit_bytes_t fileName) {
    TextureWrapper *w = (TextureWrapper*)moonbit_make_external_object(texture_destructor, sizeof(TextureWrapper));
    w->texture = LoadTexture((const char*)fileName);
    w->freed = 0;
    return w;
}

TextureWrapper* moonbit_raylib_load_texture_from_image(ImageWrapper *img) {
    TextureWrapper *w = (TextureWrapper*)moonbit_make_external_object(texture_destructor, sizeof(TextureWrapper));
    w->texture = LoadTextureFromImage(img->image);
    w->freed = 0;
    return w;
}

int moonbit_raylib_is_texture_valid(TextureWrapper *wrapper) {
    return (int)IsTextureValid(wrapper->texture);
}

void moonbit_raylib_unload_texture(TextureWrapper *wrapper) {
    if (wrapper && !wrapper->freed) {
        UnloadTexture(wrapper->texture);
        wrapper->freed = 1;
    }
}

RenderTextureWrapper* moonbit_raylib_load_render_texture(int width, int height) {
    RenderTextureWrapper *w = (RenderTextureWrapper*)moonbit_make_external_object(render_texture_destructor, sizeof(RenderTextureWrapper));
    w->render_texture = LoadRenderTexture(width, height);
    w->freed = 0;
    return w;
}

int moonbit_raylib_is_render_texture_valid(RenderTextureWrapper *wrapper) {
    return (int)IsRenderTextureValid(wrapper->render_texture);
}

void moonbit_raylib_unload_render_texture(RenderTextureWrapper *wrapper) {
    if (wrapper && !wrapper->freed) {
        UnloadRenderTexture(wrapper->render_texture);
        wrapper->freed = 1;
    }
}

// ============================================================================
// Textures: Texture drawing
// ============================================================================

void moonbit_raylib_draw_texture(TextureWrapper *wrapper, int posX, int posY, moonbit_bytes_t tint) {
    Color c; memcpy(&c, tint, sizeof(Color));
    DrawTexture(wrapper->texture, posX, posY, c);
}

void moonbit_raylib_draw_texture_v(TextureWrapper *wrapper, moonbit_bytes_t position, moonbit_bytes_t tint) {
    Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
    Color c; memcpy(&c, tint, sizeof(Color));
    DrawTextureV(wrapper->texture, pos, c);
}

void moonbit_raylib_draw_texture_ex(TextureWrapper *wrapper, moonbit_bytes_t position, float rotation, float scale, moonbit_bytes_t tint) {
    Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
    Color c; memcpy(&c, tint, sizeof(Color));
    DrawTextureEx(wrapper->texture, pos, rotation, scale, c);
}

void moonbit_raylib_draw_texture_rec(TextureWrapper *wrapper, moonbit_bytes_t source, moonbit_bytes_t position, moonbit_bytes_t tint) {
    Rectangle src; memcpy(&src, source, sizeof(Rectangle));
    Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
    Color c; memcpy(&c, tint, sizeof(Color));
    DrawTextureRec(wrapper->texture, src, pos, c);
}

void moonbit_raylib_draw_texture_pro(TextureWrapper *wrapper, moonbit_bytes_t source, moonbit_bytes_t dest, moonbit_bytes_t origin, float rotation, moonbit_bytes_t tint) {
    Rectangle src; memcpy(&src, source, sizeof(Rectangle));
    Rectangle dst; memcpy(&dst, dest, sizeof(Rectangle));
    Vector2 org; memcpy(&org, origin, sizeof(Vector2));
    Color c; memcpy(&c, tint, sizeof(Color));
    DrawTexturePro(wrapper->texture, src, dst, org, rotation, c);
}

// ============================================================================
// Text: Font loading (resource types)
// ============================================================================

FontWrapper* moonbit_raylib_get_font_default(void) {
    FontWrapper *w = (FontWrapper*)moonbit_make_external_object(font_destructor, sizeof(FontWrapper));
    w->font = GetFontDefault();
    w->freed = 1;  // Default font should NOT be unloaded
    return w;
}

FontWrapper* moonbit_raylib_load_font(moonbit_bytes_t fileName) {
    FontWrapper *w = (FontWrapper*)moonbit_make_external_object(font_destructor, sizeof(FontWrapper));
    w->font = LoadFont((const char*)fileName);
    w->freed = 0;
    return w;
}

FontWrapper* moonbit_raylib_load_font_ex(moonbit_bytes_t fileName, int fontSize) {
    FontWrapper *w = (FontWrapper*)moonbit_make_external_object(font_destructor, sizeof(FontWrapper));
    w->font = LoadFontEx((const char*)fileName, fontSize, NULL, 0);
    w->freed = 0;
    return w;
}

int moonbit_raylib_is_font_valid(FontWrapper *wrapper) {
    return (int)IsFontValid(wrapper->font);
}

void moonbit_raylib_unload_font(FontWrapper *wrapper) {
    if (wrapper && !wrapper->freed) {
        UnloadFont(wrapper->font);
        wrapper->freed = 1;
    }
}

// ============================================================================
// Text: Drawing
// ============================================================================

void moonbit_raylib_draw_text(moonbit_bytes_t text, int posX, int posY, int fontSize, moonbit_bytes_t color) {
    Color c; memcpy(&c, color, sizeof(Color));
    DrawText((const char*)text, posX, posY, fontSize, c);
}

void moonbit_raylib_draw_text_ex(FontWrapper *font, moonbit_bytes_t text, moonbit_bytes_t position, float fontSize, float spacing, moonbit_bytes_t tint) {
    Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
    Color c; memcpy(&c, tint, sizeof(Color));
    DrawTextEx(font->font, (const char*)text, pos, fontSize, spacing, c);
}

void moonbit_raylib_draw_text_pro(FontWrapper *font, moonbit_bytes_t text, moonbit_bytes_t position, moonbit_bytes_t origin, float rotation, float fontSize, float spacing, moonbit_bytes_t tint) {
    Vector2 pos; memcpy(&pos, position, sizeof(Vector2));
    Vector2 org; memcpy(&org, origin, sizeof(Vector2));
    Color c; memcpy(&c, tint, sizeof(Color));
    DrawTextPro(font->font, (const char*)text, pos, org, rotation, fontSize, spacing, c);
}

int moonbit_raylib_measure_text(moonbit_bytes_t text, int fontSize) {
    return MeasureText((const char*)text, fontSize);
}

moonbit_bytes_t moonbit_raylib_measure_text_ex(FontWrapper *font, moonbit_bytes_t text, float fontSize, float spacing) {
    Vector2 result = MeasureTextEx(font->font, (const char*)text, fontSize, spacing);
    moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector2), 0);
    memcpy(r, &result, sizeof(Vector2));
    return r;
}

// ============================================================================
// Models: 3D shape drawing
// ============================================================================

void moonbit_raylib_draw_line_3d(moonbit_bytes_t start, moonbit_bytes_t end, moonbit_bytes_t color) {
    Vector3 s; memcpy(&s, start, sizeof(Vector3));
    Vector3 e; memcpy(&e, end, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawLine3D(s, e, c);
}

void moonbit_raylib_draw_point_3d(moonbit_bytes_t position, moonbit_bytes_t color) {
    Vector3 p; memcpy(&p, position, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawPoint3D(p, c);
}

void moonbit_raylib_draw_circle_3d(moonbit_bytes_t center, float radius, moonbit_bytes_t rotAxis, float rotAngle, moonbit_bytes_t color) {
    Vector3 ctr; memcpy(&ctr, center, sizeof(Vector3));
    Vector3 axis; memcpy(&axis, rotAxis, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCircle3D(ctr, radius, axis, rotAngle, c);
}

void moonbit_raylib_draw_cube(moonbit_bytes_t position, float width, float height, float length, moonbit_bytes_t color) {
    Vector3 pos; memcpy(&pos, position, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCube(pos, width, height, length, c);
}

void moonbit_raylib_draw_cube_v(moonbit_bytes_t position, moonbit_bytes_t size, moonbit_bytes_t color) {
    Vector3 pos; memcpy(&pos, position, sizeof(Vector3));
    Vector3 sz; memcpy(&sz, size, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCubeV(pos, sz, c);
}

void moonbit_raylib_draw_cube_wires(moonbit_bytes_t position, float width, float height, float length, moonbit_bytes_t color) {
    Vector3 pos; memcpy(&pos, position, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCubeWires(pos, width, height, length, c);
}

void moonbit_raylib_draw_cube_wires_v(moonbit_bytes_t position, moonbit_bytes_t size, moonbit_bytes_t color) {
    Vector3 pos; memcpy(&pos, position, sizeof(Vector3));
    Vector3 sz; memcpy(&sz, size, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCubeWiresV(pos, sz, c);
}

void moonbit_raylib_draw_sphere(moonbit_bytes_t center, float radius, moonbit_bytes_t color) {
    Vector3 ctr; memcpy(&ctr, center, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawSphere(ctr, radius, c);
}

void moonbit_raylib_draw_sphere_ex(moonbit_bytes_t center, float radius, int rings, int slices, moonbit_bytes_t color) {
    Vector3 ctr; memcpy(&ctr, center, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawSphereEx(ctr, radius, rings, slices, c);
}

void moonbit_raylib_draw_sphere_wires(moonbit_bytes_t center, float radius, int rings, int slices, moonbit_bytes_t color) {
    Vector3 ctr; memcpy(&ctr, center, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawSphereWires(ctr, radius, rings, slices, c);
}

void moonbit_raylib_draw_cylinder(moonbit_bytes_t position, float radiusTop, float radiusBottom, float height, int slices, moonbit_bytes_t color) {
    Vector3 pos; memcpy(&pos, position, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCylinder(pos, radiusTop, radiusBottom, height, slices, c);
}

void moonbit_raylib_draw_cylinder_wires(moonbit_bytes_t position, float radiusTop, float radiusBottom, float height, int slices, moonbit_bytes_t color) {
    Vector3 pos; memcpy(&pos, position, sizeof(Vector3));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawCylinderWires(pos, radiusTop, radiusBottom, height, slices, c);
}

void moonbit_raylib_draw_plane(moonbit_bytes_t center, moonbit_bytes_t size, moonbit_bytes_t color) {
    Vector3 ctr; memcpy(&ctr, center, sizeof(Vector3));
    Vector2 sz; memcpy(&sz, size, sizeof(Vector2));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawPlane(ctr, sz, c);
}

void moonbit_raylib_draw_ray(moonbit_bytes_t ray, moonbit_bytes_t color) {
    Ray r; memcpy(&r, ray, sizeof(Ray));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawRay(r, c);
}

void moonbit_raylib_draw_bounding_box(moonbit_bytes_t box, moonbit_bytes_t color) {
    BoundingBox bb; memcpy(&bb, box, sizeof(BoundingBox));
    Color c; memcpy(&c, color, sizeof(Color));
    DrawBoundingBox(bb, c);
}

// ============================================================================
// Models: Loading (resource types)
// ============================================================================

ModelWrapper* moonbit_raylib_load_model(moonbit_bytes_t fileName) {
    ModelWrapper *w = (ModelWrapper*)moonbit_make_external_object(model_destructor, sizeof(ModelWrapper));
    w->model = LoadModel((const char*)fileName);
    w->freed = 0;
    return w;
}

void moonbit_raylib_unload_model(ModelWrapper *wrapper) {
    if (wrapper && !wrapper->freed) {
        UnloadModel(wrapper->model);
        wrapper->freed = 1;
    }
}

void moonbit_raylib_draw_model(ModelWrapper *wrapper, moonbit_bytes_t position, float scale, moonbit_bytes_t tint) {
    Vector3 pos; memcpy(&pos, position, sizeof(Vector3));
    Color c; memcpy(&c, tint, sizeof(Color));
    DrawModel(wrapper->model, pos, scale, c);
}

// ============================================================================
// Models: 3D collision detection
// ============================================================================

int moonbit_raylib_check_collision_spheres(moonbit_bytes_t c1, float r1, moonbit_bytes_t c2, float r2) {
    Vector3 center1; memcpy(&center1, c1, sizeof(Vector3));
    Vector3 center2; memcpy(&center2, c2, sizeof(Vector3));
    return (int)CheckCollisionSpheres(center1, r1, center2, r2);
}

int moonbit_raylib_check_collision_boxes(moonbit_bytes_t box1, moonbit_bytes_t box2) {
    BoundingBox b1; memcpy(&b1, box1, sizeof(BoundingBox));
    BoundingBox b2; memcpy(&b2, box2, sizeof(BoundingBox));
    return (int)CheckCollisionBoxes(b1, b2);
}

int moonbit_raylib_check_collision_box_sphere(moonbit_bytes_t box, moonbit_bytes_t center, float radius) {
    BoundingBox b; memcpy(&b, box, sizeof(BoundingBox));
    Vector3 c; memcpy(&c, center, sizeof(Vector3));
    return (int)CheckCollisionBoxSphere(b, c, radius);
}

moonbit_bytes_t moonbit_raylib_get_ray_collision_sphere(moonbit_bytes_t ray, moonbit_bytes_t center, float radius) {
    Ray r; memcpy(&r, ray, sizeof(Ray));
    Vector3 c; memcpy(&c, center, sizeof(Vector3));
    RayCollision result = GetRayCollisionSphere(r, c, radius);
    moonbit_bytes_t res = moonbit_make_bytes(sizeof(RayCollision), 0);
    memcpy(res, &result, sizeof(RayCollision));
    return res;
}

moonbit_bytes_t moonbit_raylib_get_ray_collision_box(moonbit_bytes_t ray, moonbit_bytes_t box) {
    Ray r; memcpy(&r, ray, sizeof(Ray));
    BoundingBox b; memcpy(&b, box, sizeof(BoundingBox));
    RayCollision result = GetRayCollisionBox(r, b);
    moonbit_bytes_t res = moonbit_make_bytes(sizeof(RayCollision), 0);
    memcpy(res, &result, sizeof(RayCollision));
    return res;
}

// ============================================================================
// Audio: Device management
// ============================================================================

// InitAudioDevice, CloseAudioDevice, IsAudioDeviceReady, SetMasterVolume, GetMasterVolume
// can be called directly (no struct params)

// ============================================================================
// Audio: Sound (resource types)
// ============================================================================

SoundWrapper* moonbit_raylib_load_sound(moonbit_bytes_t fileName) {
    SoundWrapper *w = (SoundWrapper*)moonbit_make_external_object(sound_destructor, sizeof(SoundWrapper));
    w->sound = LoadSound((const char*)fileName);
    w->freed = 0;
    return w;
}

void moonbit_raylib_unload_sound(SoundWrapper *wrapper) {
    if (wrapper && !wrapper->freed) {
        UnloadSound(wrapper->sound);
        wrapper->freed = 1;
    }
}

void moonbit_raylib_play_sound(SoundWrapper *wrapper) { PlaySound(wrapper->sound); }
void moonbit_raylib_stop_sound(SoundWrapper *wrapper) { StopSound(wrapper->sound); }
void moonbit_raylib_pause_sound(SoundWrapper *wrapper) { PauseSound(wrapper->sound); }
void moonbit_raylib_resume_sound(SoundWrapper *wrapper) { ResumeSound(wrapper->sound); }
int moonbit_raylib_is_sound_playing(SoundWrapper *wrapper) { return (int)IsSoundPlaying(wrapper->sound); }
void moonbit_raylib_set_sound_volume(SoundWrapper *wrapper, float volume) { SetSoundVolume(wrapper->sound, volume); }
void moonbit_raylib_set_sound_pitch(SoundWrapper *wrapper, float pitch) { SetSoundPitch(wrapper->sound, pitch); }
void moonbit_raylib_set_sound_pan(SoundWrapper *wrapper, float pan) { SetSoundPan(wrapper->sound, pan); }

// ============================================================================
// Audio: Music (resource types)
// ============================================================================

MusicWrapper* moonbit_raylib_load_music_stream(moonbit_bytes_t fileName) {
    MusicWrapper *w = (MusicWrapper*)moonbit_make_external_object(music_destructor, sizeof(MusicWrapper));
    w->music = LoadMusicStream((const char*)fileName);
    w->freed = 0;
    return w;
}

void moonbit_raylib_unload_music_stream(MusicWrapper *wrapper) {
    if (wrapper && !wrapper->freed) {
        UnloadMusicStream(wrapper->music);
        wrapper->freed = 1;
    }
}

void moonbit_raylib_play_music_stream(MusicWrapper *wrapper) { PlayMusicStream(wrapper->music); }
void moonbit_raylib_stop_music_stream(MusicWrapper *wrapper) { StopMusicStream(wrapper->music); }
void moonbit_raylib_pause_music_stream(MusicWrapper *wrapper) { PauseMusicStream(wrapper->music); }
void moonbit_raylib_resume_music_stream(MusicWrapper *wrapper) { ResumeMusicStream(wrapper->music); }
void moonbit_raylib_update_music_stream(MusicWrapper *wrapper) { UpdateMusicStream(wrapper->music); }
int moonbit_raylib_is_music_stream_playing(MusicWrapper *wrapper) { return (int)IsMusicStreamPlaying(wrapper->music); }
void moonbit_raylib_set_music_volume(MusicWrapper *wrapper, float volume) { SetMusicVolume(wrapper->music, volume); }
void moonbit_raylib_set_music_pitch(MusicWrapper *wrapper, float pitch) { SetMusicPitch(wrapper->music, pitch); }
void moonbit_raylib_seek_music_stream(MusicWrapper *wrapper, float position) { SeekMusicStream(wrapper->music, position); }
float moonbit_raylib_get_music_time_length(MusicWrapper *wrapper) { return GetMusicTimeLength(wrapper->music); }
float moonbit_raylib_get_music_time_played(MusicWrapper *wrapper) { return GetMusicTimePlayed(wrapper->music); }

// ============================================================================
// Textures: BeginTextureMode needs RenderTexture
// ============================================================================

void moonbit_raylib_begin_texture_mode(RenderTextureWrapper *wrapper) {
    BeginTextureMode(wrapper->render_texture);
}
