#include "stub_internal.h"
#include <stdlib.h>

// ============================================================================
// Models: 3D shape drawing
// ============================================================================

void
moonbit_raylib_draw_line_3d(
  moonbit_bytes_t start,
  moonbit_bytes_t end,
  moonbit_bytes_t color
) {
  Vector3 s;
  memcpy(&s, start, sizeof(Vector3));
  Vector3 e;
  memcpy(&e, end, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawLine3D(s, e, c);
}

void
moonbit_raylib_draw_point_3d(moonbit_bytes_t position, moonbit_bytes_t color) {
  Vector3 p;
  memcpy(&p, position, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawPoint3D(p, c);
}

void
moonbit_raylib_draw_circle_3d(
  moonbit_bytes_t center,
  float radius,
  moonbit_bytes_t rotAxis,
  float rotAngle,
  moonbit_bytes_t color
) {
  Vector3 ctr;
  memcpy(&ctr, center, sizeof(Vector3));
  Vector3 axis;
  memcpy(&axis, rotAxis, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCircle3D(ctr, radius, axis, rotAngle, c);
}

void
moonbit_raylib_draw_cube(
  moonbit_bytes_t position,
  float width,
  float height,
  float length,
  moonbit_bytes_t color
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCube(pos, width, height, length, c);
}

void
moonbit_raylib_draw_cube_v(
  moonbit_bytes_t position,
  moonbit_bytes_t size,
  moonbit_bytes_t color
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Vector3 sz;
  memcpy(&sz, size, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCubeV(pos, sz, c);
}

void
moonbit_raylib_draw_cube_wires(
  moonbit_bytes_t position,
  float width,
  float height,
  float length,
  moonbit_bytes_t color
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCubeWires(pos, width, height, length, c);
}

void
moonbit_raylib_draw_cube_wires_v(
  moonbit_bytes_t position,
  moonbit_bytes_t size,
  moonbit_bytes_t color
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Vector3 sz;
  memcpy(&sz, size, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCubeWiresV(pos, sz, c);
}

void
moonbit_raylib_draw_sphere(
  moonbit_bytes_t center,
  float radius,
  moonbit_bytes_t color
) {
  Vector3 ctr;
  memcpy(&ctr, center, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSphere(ctr, radius, c);
}

void
moonbit_raylib_draw_sphere_ex(
  moonbit_bytes_t center,
  float radius,
  int rings,
  int slices,
  moonbit_bytes_t color
) {
  Vector3 ctr;
  memcpy(&ctr, center, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSphereEx(ctr, radius, rings, slices, c);
}

void
moonbit_raylib_draw_sphere_wires(
  moonbit_bytes_t center,
  float radius,
  int rings,
  int slices,
  moonbit_bytes_t color
) {
  Vector3 ctr;
  memcpy(&ctr, center, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawSphereWires(ctr, radius, rings, slices, c);
}

void
moonbit_raylib_draw_cylinder(
  moonbit_bytes_t position,
  float radiusTop,
  float radiusBottom,
  float height,
  int slices,
  moonbit_bytes_t color
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCylinder(pos, radiusTop, radiusBottom, height, slices, c);
}

void
moonbit_raylib_draw_cylinder_wires(
  moonbit_bytes_t position,
  float radiusTop,
  float radiusBottom,
  float height,
  int slices,
  moonbit_bytes_t color
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCylinderWires(pos, radiusTop, radiusBottom, height, slices, c);
}

void
moonbit_raylib_draw_plane(
  moonbit_bytes_t center,
  moonbit_bytes_t size,
  moonbit_bytes_t color
) {
  Vector3 ctr;
  memcpy(&ctr, center, sizeof(Vector3));
  Vector2 sz;
  memcpy(&sz, size, sizeof(Vector2));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawPlane(ctr, sz, c);
}

void
moonbit_raylib_draw_ray(moonbit_bytes_t ray, moonbit_bytes_t color) {
  Ray r;
  memcpy(&r, ray, sizeof(Ray));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawRay(r, c);
}

void
moonbit_raylib_draw_bounding_box(moonbit_bytes_t box, moonbit_bytes_t color) {
  BoundingBox bb;
  memcpy(&bb, box, sizeof(BoundingBox));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawBoundingBox(bb, c);
}

// ============================================================================
// Models: Loading (resource types)
// ============================================================================

Model *
moonbit_raylib_load_model(moonbit_bytes_t fileName) {
  Model *m = (Model *)malloc(sizeof(Model));
  *m = LoadModel((const char *)fileName);
  return m;
}

void
moonbit_raylib_unload_model(Model *m) {
  if (m) {
    UnloadModel(*m);
    free(m);
  }
}

void
moonbit_raylib_draw_model(
  Model *m,
  moonbit_bytes_t position,
  float scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModel(*m, pos, scale, c);
}

// ============================================================================
// Models: 3D shape drawing (extended)
// ============================================================================

void
moonbit_raylib_draw_triangle_3d(
  moonbit_bytes_t v1,
  moonbit_bytes_t v2,
  moonbit_bytes_t v3,
  moonbit_bytes_t color
) {
  Vector3 a;
  memcpy(&a, v1, sizeof(Vector3));
  Vector3 b;
  memcpy(&b, v2, sizeof(Vector3));
  Vector3 c;
  memcpy(&c, v3, sizeof(Vector3));
  Color col;
  memcpy(&col, color, sizeof(Color));
  DrawTriangle3D(a, b, c, col);
}

void
moonbit_raylib_draw_cylinder_ex(
  moonbit_bytes_t startPos,
  moonbit_bytes_t endPos,
  float startRadius,
  float endRadius,
  int sides,
  moonbit_bytes_t color
) {
  Vector3 sp;
  memcpy(&sp, startPos, sizeof(Vector3));
  Vector3 ep;
  memcpy(&ep, endPos, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCylinderEx(sp, ep, startRadius, endRadius, sides, c);
}

void
moonbit_raylib_draw_cylinder_wires_ex(
  moonbit_bytes_t startPos,
  moonbit_bytes_t endPos,
  float startRadius,
  float endRadius,
  int sides,
  moonbit_bytes_t color
) {
  Vector3 sp;
  memcpy(&sp, startPos, sizeof(Vector3));
  Vector3 ep;
  memcpy(&ep, endPos, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCylinderWiresEx(sp, ep, startRadius, endRadius, sides, c);
}

void
moonbit_raylib_draw_capsule(
  moonbit_bytes_t startPos,
  moonbit_bytes_t endPos,
  float radius,
  int slices,
  int rings,
  moonbit_bytes_t color
) {
  Vector3 sp;
  memcpy(&sp, startPos, sizeof(Vector3));
  Vector3 ep;
  memcpy(&ep, endPos, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCapsule(sp, ep, radius, slices, rings, c);
}

void
moonbit_raylib_draw_capsule_wires(
  moonbit_bytes_t startPos,
  moonbit_bytes_t endPos,
  float radius,
  int slices,
  int rings,
  moonbit_bytes_t color
) {
  Vector3 sp;
  memcpy(&sp, startPos, sizeof(Vector3));
  Vector3 ep;
  memcpy(&ep, endPos, sizeof(Vector3));
  Color c;
  memcpy(&c, color, sizeof(Color));
  DrawCapsuleWires(sp, ep, radius, slices, rings, c);
}

// ============================================================================
// Models: Model drawing (extended)
// ============================================================================

void
moonbit_raylib_draw_model_ex(
  Model *m,
  moonbit_bytes_t position,
  moonbit_bytes_t rotationAxis,
  float rotationAngle,
  moonbit_bytes_t scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Vector3 axis;
  memcpy(&axis, rotationAxis, sizeof(Vector3));
  Vector3 sc;
  memcpy(&sc, scale, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModelEx(*m, pos, axis, rotationAngle, sc, c);
}

void
moonbit_raylib_draw_model_wires(
  Model *m,
  moonbit_bytes_t position,
  float scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModelWires(*m, pos, scale, c);
}

void
moonbit_raylib_draw_model_wires_ex(
  Model *m,
  moonbit_bytes_t position,
  moonbit_bytes_t rotationAxis,
  float rotationAngle,
  moonbit_bytes_t scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Vector3 axis;
  memcpy(&axis, rotationAxis, sizeof(Vector3));
  Vector3 sc;
  memcpy(&sc, scale, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModelWiresEx(*m, pos, axis, rotationAngle, sc, c);
}

void
moonbit_raylib_draw_model_points(
  Model *m,
  moonbit_bytes_t position,
  float scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModelPoints(*m, pos, scale, c);
}

void
moonbit_raylib_draw_model_points_ex(
  Model *m,
  moonbit_bytes_t position,
  moonbit_bytes_t rotationAxis,
  float rotationAngle,
  moonbit_bytes_t scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Vector3 axis;
  memcpy(&axis, rotationAxis, sizeof(Vector3));
  Vector3 sc;
  memcpy(&sc, scale, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModelPointsEx(*m, pos, axis, rotationAngle, sc, c);
}

// ============================================================================
// Models: Model management
// ============================================================================

int
moonbit_raylib_is_model_valid(Model *m) {
  return (int)IsModelValid(*m);
}

moonbit_bytes_t
moonbit_raylib_get_model_bounding_box(Model *m) {
  BoundingBox bb = GetModelBoundingBox(*m);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(BoundingBox), 0);
  memcpy(r, &bb, sizeof(BoundingBox));
  return r;
}

// ============================================================================
// Models: Billboard drawing
// ============================================================================

void
moonbit_raylib_draw_billboard(
  moonbit_bytes_t camera,
  Texture2D *t,
  moonbit_bytes_t position,
  float scale,
  moonbit_bytes_t tint
) {
  Camera3D cam;
  memcpy(&cam, camera, sizeof(Camera3D));
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawBillboard(cam, *t, pos, scale, c);
}

void
moonbit_raylib_draw_billboard_rec(
  moonbit_bytes_t camera,
  Texture2D *t,
  moonbit_bytes_t source,
  moonbit_bytes_t position,
  moonbit_bytes_t size,
  moonbit_bytes_t tint
) {
  Camera3D cam;
  memcpy(&cam, camera, sizeof(Camera3D));
  Rectangle src;
  memcpy(&src, source, sizeof(Rectangle));
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Vector2 sz;
  memcpy(&sz, size, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawBillboardRec(cam, *t, src, pos, sz, c);
}

void
moonbit_raylib_draw_billboard_pro(
  moonbit_bytes_t camera,
  Texture2D *t,
  moonbit_bytes_t source,
  moonbit_bytes_t position,
  moonbit_bytes_t up,
  moonbit_bytes_t size,
  moonbit_bytes_t origin,
  float rotation,
  moonbit_bytes_t tint
) {
  Camera3D cam;
  memcpy(&cam, camera, sizeof(Camera3D));
  Rectangle src;
  memcpy(&src, source, sizeof(Rectangle));
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Vector3 u;
  memcpy(&u, up, sizeof(Vector3));
  Vector2 sz;
  memcpy(&sz, size, sizeof(Vector2));
  Vector2 org;
  memcpy(&org, origin, sizeof(Vector2));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawBillboardPro(cam, *t, src, pos, u, sz, org, rotation, c);
}

// ============================================================================
// Models: 3D collision detection
// ============================================================================

int
moonbit_raylib_check_collision_spheres(
  moonbit_bytes_t c1,
  float r1,
  moonbit_bytes_t c2,
  float r2
) {
  Vector3 center1;
  memcpy(&center1, c1, sizeof(Vector3));
  Vector3 center2;
  memcpy(&center2, c2, sizeof(Vector3));
  return (int)CheckCollisionSpheres(center1, r1, center2, r2);
}

int
moonbit_raylib_check_collision_boxes(
  moonbit_bytes_t box1,
  moonbit_bytes_t box2
) {
  BoundingBox b1;
  memcpy(&b1, box1, sizeof(BoundingBox));
  BoundingBox b2;
  memcpy(&b2, box2, sizeof(BoundingBox));
  return (int)CheckCollisionBoxes(b1, b2);
}

int
moonbit_raylib_check_collision_box_sphere(
  moonbit_bytes_t box,
  moonbit_bytes_t center,
  float radius
) {
  BoundingBox b;
  memcpy(&b, box, sizeof(BoundingBox));
  Vector3 c;
  memcpy(&c, center, sizeof(Vector3));
  return (int)CheckCollisionBoxSphere(b, c, radius);
}

moonbit_bytes_t
moonbit_raylib_get_ray_collision_sphere(
  moonbit_bytes_t ray,
  moonbit_bytes_t center,
  float radius
) {
  Ray r;
  memcpy(&r, ray, sizeof(Ray));
  Vector3 c;
  memcpy(&c, center, sizeof(Vector3));
  RayCollision result = GetRayCollisionSphere(r, c, radius);
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(RayCollision), 0);
  memcpy(res, &result, sizeof(RayCollision));
  return res;
}

moonbit_bytes_t
moonbit_raylib_get_ray_collision_box(moonbit_bytes_t ray, moonbit_bytes_t box) {
  Ray r;
  memcpy(&r, ray, sizeof(Ray));
  BoundingBox b;
  memcpy(&b, box, sizeof(BoundingBox));
  RayCollision result = GetRayCollisionBox(r, b);
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(RayCollision), 0);
  memcpy(res, &result, sizeof(RayCollision));
  return res;
}

moonbit_bytes_t
moonbit_raylib_get_ray_collision_triangle(
  moonbit_bytes_t ray,
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3
) {
  Ray r;
  memcpy(&r, ray, sizeof(Ray));
  Vector3 v1;
  memcpy(&v1, p1, sizeof(Vector3));
  Vector3 v2;
  memcpy(&v2, p2, sizeof(Vector3));
  Vector3 v3;
  memcpy(&v3, p3, sizeof(Vector3));
  RayCollision result = GetRayCollisionTriangle(r, v1, v2, v3);
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(RayCollision), 0);
  memcpy(res, &result, sizeof(RayCollision));
  return res;
}

// ============================================================================
// Mesh generation
// ============================================================================

Mesh *
moonbit_raylib_gen_mesh_poly(int sides, float radius) {
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshPoly(sides, radius);
  return mesh;
}

Mesh *
moonbit_raylib_gen_mesh_plane(float width, float length, int resX, int resZ) {
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshPlane(width, length, resX, resZ);
  return mesh;
}

Mesh *
moonbit_raylib_gen_mesh_cube(float width, float height, float length) {
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshCube(width, height, length);
  return mesh;
}

Mesh *
moonbit_raylib_gen_mesh_sphere(float radius, int rings, int slices) {
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshSphere(radius, rings, slices);
  return mesh;
}

Mesh *
moonbit_raylib_gen_mesh_hemisphere(float radius, int rings, int slices) {
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshHemiSphere(radius, rings, slices);
  return mesh;
}

Mesh *
moonbit_raylib_gen_mesh_cylinder(float radius, float height, int slices) {
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshCylinder(radius, height, slices);
  return mesh;
}

Mesh *
moonbit_raylib_gen_mesh_cone(float radius, float height, int slices) {
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshCone(radius, height, slices);
  return mesh;
}

Mesh *
moonbit_raylib_gen_mesh_torus(
  float radius,
  float size,
  int radSeg,
  int sides
) {
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshTorus(radius, size, radSeg, sides);
  return mesh;
}

Mesh *
moonbit_raylib_gen_mesh_knot(
  float radius,
  float size,
  int radSeg,
  int sides
) {
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshKnot(radius, size, radSeg, sides);
  return mesh;
}

Mesh *
moonbit_raylib_gen_mesh_heightmap(Image *img, moonbit_bytes_t size) {
  Vector3 sz;
  memcpy(&sz, size, sizeof(Vector3));
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshHeightmap(*img, sz);
  return mesh;
}

Mesh *
moonbit_raylib_gen_mesh_cubicmap(Image *img, moonbit_bytes_t cubeSize) {
  Vector3 cs;
  memcpy(&cs, cubeSize, sizeof(Vector3));
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  *mesh = GenMeshCubicmap(*img, cs);
  return mesh;
}

// ============================================================================
// Mesh utilities
// ============================================================================

void
moonbit_raylib_unload_mesh(Mesh *mesh) {
  if (mesh) {
    UnloadMesh(*mesh);
    free(mesh);
  }
}

moonbit_bytes_t
moonbit_raylib_get_mesh_bounding_box(Mesh *mesh) {
  BoundingBox bb = GetMeshBoundingBox(*mesh);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(BoundingBox), 0);
  memcpy(r, &bb, sizeof(BoundingBox));
  return r;
}

int
moonbit_raylib_export_mesh(Mesh *mesh, moonbit_bytes_t fileName) {
  return (int)ExportMesh(*mesh, (const char *)fileName);
}

void
moonbit_raylib_upload_mesh(Mesh *mesh, int dynamic) {
  UploadMesh(mesh, (bool)dynamic);
}

void
moonbit_raylib_gen_mesh_tangents(Mesh *mesh) {
  GenMeshTangents(mesh);
}

moonbit_bytes_t
moonbit_raylib_get_ray_collision_mesh(
  moonbit_bytes_t ray,
  Mesh *mesh,
  moonbit_bytes_t transform
) {
  Ray r;
  memcpy(&r, ray, sizeof(Ray));
  Matrix mat;
  memcpy(&mat, transform, sizeof(Matrix));
  RayCollision result = GetRayCollisionMesh(r, *mesh, mat);
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(RayCollision), 0);
  memcpy(res, &result, sizeof(RayCollision));
  return res;
}

Model *
moonbit_raylib_load_model_from_mesh(Mesh *mesh) {
  Model *model = (Model *)malloc(sizeof(Model));
  *model = LoadModelFromMesh(*mesh);
  return model;
}

// ============================================================================
// Material management
// ============================================================================

Material *
moonbit_raylib_load_material_default(void) {
  Material *mat = (Material *)malloc(sizeof(Material));
  *mat = LoadMaterialDefault();
  return mat;
}

int
moonbit_raylib_is_material_valid(Material *mat) {
  return (int)IsMaterialValid(*mat);
}

void
moonbit_raylib_unload_material(Material *mat) {
  if (mat) {
    UnloadMaterial(*mat);
    free(mat);
  }
}

void
moonbit_raylib_set_material_texture(
  Material *mat,
  int mapType,
  Texture2D *t
) {
  mat->maps[mapType].texture = *t;
}

void
moonbit_raylib_set_model_mesh_material(
  Model *m,
  int meshId,
  int materialId
) {
  m->meshMaterial[meshId] = materialId;
}

void
moonbit_raylib_set_model_material_texture(
  Model *m,
  int materialIndex,
  int mapType,
  Texture2D *t
) {
  if (materialIndex >= 0 && materialIndex < m->materialCount) {
    m->materials[materialIndex].maps[mapType].texture = *t;
  }
}

// ============================================================================
// Model: set material shader
// ============================================================================

void
moonbit_raylib_set_model_material_shader(
  Model *m,
  int material_index,
  Shader *s
) {
  if (material_index >= 0 && material_index < m->materialCount) {
    m->materials[material_index].shader = *s;
  }
}

// ============================================================================
// Material: set shader on standalone material
// ============================================================================

void
moonbit_raylib_set_material_shader(
  Material *mat,
  Shader *s
) {
  mat->shader = *s;
}

// ============================================================================
// Material: set material map color
// ============================================================================

void
moonbit_raylib_set_material_map_color(
  Material *mat,
  int mapType,
  moonbit_bytes_t color
) {
  Color c; memcpy(&c, color, sizeof(Color));
  if (mapType >= 0 && mapType < 12) {
    mat->maps[mapType].color = c;
  }
}

// ============================================================================
// Material: set material map value
// ============================================================================

void
moonbit_raylib_set_material_map_value(
  Material *mat,
  int mapType,
  float value
) {
  if (mapType >= 0 && mapType < 12) {
    mat->maps[mapType].value = value;
  }
}

// ============================================================================
// Mesh drawing
// ============================================================================

void
moonbit_raylib_draw_mesh(
  Mesh *mesh,
  Material *mat,
  moonbit_bytes_t transform
) {
  Matrix m;
  memcpy(&m, transform, sizeof(Matrix));
  DrawMesh(*mesh, *mat, m);
}

void
moonbit_raylib_draw_mesh_instanced(
  Mesh *mesh,
  Material *mat,
  moonbit_bytes_t transforms,
  int instances
) {
  Matrix *mats = (Matrix *)transforms;
  DrawMeshInstanced(*mesh, *mat, mats, instances);
}

// ============================================================================
// Model animations
// ============================================================================

ModelAnimationsWrapper *
moonbit_raylib_load_model_animations(moonbit_bytes_t fileName) {
  int count = 0;
  ModelAnimation *anims = LoadModelAnimations((const char *)fileName, &count);
  ModelAnimationsWrapper *w = (ModelAnimationsWrapper *)malloc(sizeof(ModelAnimationsWrapper));
  w->anims = anims;
  w->count = count;
  return w;
}

int moonbit_raylib_model_animations_count(ModelAnimationsWrapper *wrapper) {
  return wrapper->count;
}

void moonbit_raylib_update_model_animation(Model *m, ModelAnimationsWrapper *anims, int index, int frame) {
  if (index >= 0 && index < anims->count)
    UpdateModelAnimation(*m, anims->anims[index], frame);
}

void moonbit_raylib_update_model_animation_bones(Model *m, ModelAnimationsWrapper *anims, int index, int frame) {
  if (index >= 0 && index < anims->count)
    UpdateModelAnimationBones(*m, anims->anims[index], frame);
}

int moonbit_raylib_is_model_animation_valid(Model *m, ModelAnimationsWrapper *anims, int index) {
  if (index >= 0 && index < anims->count)
    return (int)IsModelAnimationValid(*m, anims->anims[index]);
  return 0;
}

void moonbit_raylib_unload_model_animations(ModelAnimationsWrapper *w) {
  if (w) {
    UnloadModelAnimations(w->anims, w->count);
    free(w);
  }
}

// ============================================================================
// Ray collision: quad
// ============================================================================

moonbit_bytes_t moonbit_raylib_get_ray_collision_quad(
  moonbit_bytes_t ray, moonbit_bytes_t p1, moonbit_bytes_t p2, moonbit_bytes_t p3, moonbit_bytes_t p4
) {
  Ray r; memcpy(&r, ray, sizeof(Ray));
  Vector3 v1; memcpy(&v1, p1, sizeof(Vector3));
  Vector3 v2; memcpy(&v2, p2, sizeof(Vector3));
  Vector3 v3; memcpy(&v3, p3, sizeof(Vector3));
  Vector3 v4; memcpy(&v4, p4, sizeof(Vector3));
  RayCollision result = GetRayCollisionQuad(r, v1, v2, v3, v4);
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(RayCollision), 0);
  memcpy(res, &result, sizeof(RayCollision));
  return res;
}

// ============================================================================
// Mesh: Export as code
// ============================================================================

int
moonbit_raylib_export_mesh_as_code(Mesh *mesh, moonbit_bytes_t fileName) {
  return (int)ExportMeshAsCode(*mesh, (const char *)fileName);
}

// ============================================================================
// Mesh: UpdateMeshBuffer
// ============================================================================

void
moonbit_raylib_update_mesh_buffer(Mesh *mesh, int index, moonbit_bytes_t data, int data_size, int offset) {
  UpdateMeshBuffer(*mesh, index, (const void *)data, data_size, offset);
}

// ============================================================================
// LoadMaterials
// ============================================================================

MaterialsArrayWrapper *
moonbit_raylib_load_materials(moonbit_bytes_t fileName) {
  int count = 0;
  Material *mats = LoadMaterials((const char *)fileName, &count);
  MaterialsArrayWrapper *w = (MaterialsArrayWrapper *)malloc(sizeof(MaterialsArrayWrapper));
  w->materials = mats;
  w->count = count;
  return w;
}

void
moonbit_raylib_unload_materials_array(MaterialsArrayWrapper *w) {
  if (w && w->materials) {
    for (int i = 0; i < w->count; i++) {
      UnloadMaterial(w->materials[i]);
    }
    RL_FREE(w->materials);
    free(w);
  }
}

int
moonbit_raylib_materials_array_count(MaterialsArrayWrapper *w) {
  return w->count;
}

// Get a single material from the array (non-owning pointer into the array)
Material *
moonbit_raylib_materials_array_get(MaterialsArrayWrapper *w, int index) {
  return &w->materials[index];
}

// ============================================================================
// Model: set transform
// ============================================================================

void
moonbit_raylib_set_model_transform(
  Model *m,
  moonbit_bytes_t transform
) {
  Matrix mat;
  memcpy(&mat, transform, sizeof(Matrix));
  m->transform = mat;
}

// ============================================================================
// Model: get mesh count
// ============================================================================

int
moonbit_raylib_get_model_mesh_count(Model *m) {
  return m->meshCount;
}

// ============================================================================
// Model: get mesh by index (non-owning pointer into Model's array)
// ============================================================================

Mesh *
moonbit_raylib_get_model_mesh(Model *m, int index) {
  return &m->meshes[index];
}

// ============================================================================
// Model: get transform
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_transform(Model *m) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Matrix), 0);
  memcpy(r, &m->transform, sizeof(Matrix));
  return r;
}

// ============================================================================
// Model: get material count
// ============================================================================

int
moonbit_raylib_get_model_material_count(Model *m) {
  return m->materialCount;
}

// ============================================================================
// Model: get material by index (non-owning pointer into Model's array)
// ============================================================================

Material *
moonbit_raylib_get_model_material(Model *m, int index) {
  return &m->materials[index];
}

// ============================================================================
// Model: get bone count
// ============================================================================

int
moonbit_raylib_get_model_bone_count(Model *m) {
  return m->boneCount;
}

// ============================================================================
// Model: get bone parent
// ============================================================================

int
moonbit_raylib_get_model_bone_parent(Model *m, int bone_index) {
  if (bone_index >= 0 && bone_index < m->boneCount) {
    return m->bones[bone_index].parent;
  }
  return -1;
}

// ============================================================================
// Model: get bind pose translation (Vector3 as Bytes)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_bind_pose_translation(Model *m, int bone_index) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector3), 0);
  if (bone_index >= 0 && bone_index < m->boneCount) {
    memcpy(r, &m->bindPose[bone_index].translation, sizeof(Vector3));
  }
  return r;
}

// ============================================================================
// ModelAnimations: get animation frame count
// ============================================================================

int
moonbit_raylib_get_model_animation_frame_count(ModelAnimationsWrapper *wrapper, int anim_index) {
  if (anim_index >= 0 && anim_index < wrapper->count) {
    return wrapper->anims[anim_index].frameCount;
  }
  return 0;
}

// ============================================================================
// ModelAnimations: get animation bone count
// ============================================================================

int
moonbit_raylib_get_model_animation_bone_count(ModelAnimationsWrapper *wrapper, int anim_index) {
  if (anim_index >= 0 && anim_index < wrapper->count) {
    return wrapper->anims[anim_index].boneCount;
  }
  return 0;
}

// ============================================================================
// ModelAnimations: get animation bone parent
// ============================================================================

int
moonbit_raylib_get_model_animation_bone_parent(ModelAnimationsWrapper *wrapper, int anim_index, int bone_index) {
  if (anim_index >= 0 && anim_index < wrapper->count &&
      bone_index >= 0 && bone_index < wrapper->anims[anim_index].boneCount) {
    return wrapper->anims[anim_index].bones[bone_index].parent;
  }
  return -1;
}

// ============================================================================
// ModelAnimations: get frame pose translation (Vector3 as Bytes)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_animation_frame_pose_translation(
  ModelAnimationsWrapper *wrapper, int anim_index, int frame, int bone_index
) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector3), 0);
  if (anim_index >= 0 && anim_index < wrapper->count &&
      frame >= 0 && frame < wrapper->anims[anim_index].frameCount &&
      bone_index >= 0 && bone_index < wrapper->anims[anim_index].boneCount) {
    memcpy(r, &wrapper->anims[anim_index].framePoses[frame][bone_index].translation, sizeof(Vector3));
  }
  return r;
}

// ============================================================================
// ModelAnimations: get frame pose rotation (Quaternion/Vector4 as Bytes)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_animation_frame_pose_rotation(
  ModelAnimationsWrapper *wrapper, int anim_index, int frame, int bone_index
) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector4), 0);
  if (anim_index >= 0 && anim_index < wrapper->count &&
      frame >= 0 && frame < wrapper->anims[anim_index].frameCount &&
      bone_index >= 0 && bone_index < wrapper->anims[anim_index].boneCount) {
    memcpy(r, &wrapper->anims[anim_index].framePoses[frame][bone_index].rotation, sizeof(Vector4));
  }
  return r;
}

// ============================================================================
// Model: get bone name (returns Bytes / UTF-8 string)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_bone_name(Model *m, int bone_index) {
  if (bone_index >= 0 && bone_index < m->boneCount) {
    const char *name = m->bones[bone_index].name;
    int32_t len = strlen(name);
    moonbit_bytes_t r = moonbit_make_bytes(len, 0);
    memcpy(r, name, len);
    return r;
  }
  moonbit_bytes_t r = moonbit_make_bytes(0, 0);
  return r;
}

// ============================================================================
// Model: get bind pose rotation (Quaternion/Vector4 as Bytes)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_bind_pose_rotation(Model *m, int bone_index) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector4), 0);
  if (bone_index >= 0 && bone_index < m->boneCount) {
    memcpy(r, &m->bindPose[bone_index].rotation, sizeof(Vector4));
  }
  return r;
}

// ============================================================================
// Mesh: Generate point cloud from vertex+color data
// ============================================================================

Mesh *
moonbit_raylib_gen_mesh_from_points(
  moonbit_bytes_t vertices,
  moonbit_bytes_t colors,
  int num_points
) {
  Mesh *mesh = (Mesh *)malloc(sizeof(Mesh));
  memset(mesh, 0, sizeof(Mesh));
  mesh->triangleCount = 1;
  mesh->vertexCount = num_points;
  mesh->vertices = (float *)MemAlloc(num_points * 3 * sizeof(float));
  mesh->colors = (unsigned char *)MemAlloc(num_points * 4 * sizeof(unsigned char));
  memcpy(mesh->vertices, vertices, num_points * 3 * sizeof(float));
  memcpy(mesh->colors, colors, num_points * 4 * sizeof(unsigned char));
  UploadMesh(mesh, false);
  return mesh;
}

// ============================================================================
// Mesh: setup texcoords2 (allocate, fill, upload VBO, set vertex attribute)
// ============================================================================

void
moonbit_raylib_mesh_setup_texcoords2(Mesh *mesh, moonbit_bytes_t data, int float_count) {
  // Allocate and copy texcoords2 data
  mesh->texcoords2 = (float *)RL_MALLOC(float_count * sizeof(float));
  memcpy(mesh->texcoords2, data, float_count * sizeof(float));

  // Upload texcoords2 as a new VBO
  mesh->vboId[SHADER_LOC_VERTEX_TEXCOORD02] = rlLoadVertexBuffer(
    mesh->texcoords2, float_count * sizeof(float), false);

  // Bind VAO and set vertex attribute at index 5 (texcoords2)
  rlEnableVertexArray(mesh->vaoId);
  rlSetVertexAttribute(5, 2, RL_FLOAT, 0, 0, 0);
  rlEnableVertexAttribute(5);
  rlDisableVertexArray();
}
