#include "stub_internal.h"
#include <stdlib.h>

// ============================================================================
// Resource destructor: Model
// ============================================================================

static void
model_destructor(void *ptr) {
  ModelWrapper *w = (ModelWrapper *)ptr;
  if (!w->freed)
    UnloadModel(w->model);
}

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

ModelWrapper *
moonbit_raylib_load_model(moonbit_bytes_t fileName) {
  ModelWrapper *w = (ModelWrapper *)moonbit_make_external_object(
    model_destructor, sizeof(ModelWrapper)
  );
  w->model = LoadModel((const char *)fileName);
  w->freed = 0;
  return w;
}

void
moonbit_raylib_unload_model(ModelWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadModel(wrapper->model);
    wrapper->freed = 1;
  }
}

void
moonbit_raylib_draw_model(
  ModelWrapper *wrapper,
  moonbit_bytes_t position,
  float scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModel(wrapper->model, pos, scale, c);
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
  ModelWrapper *wrapper,
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
  DrawModelEx(wrapper->model, pos, axis, rotationAngle, sc, c);
}

void
moonbit_raylib_draw_model_wires(
  ModelWrapper *wrapper,
  moonbit_bytes_t position,
  float scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModelWires(wrapper->model, pos, scale, c);
}

void
moonbit_raylib_draw_model_wires_ex(
  ModelWrapper *wrapper,
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
  DrawModelWiresEx(wrapper->model, pos, axis, rotationAngle, sc, c);
}

void
moonbit_raylib_draw_model_points(
  ModelWrapper *wrapper,
  moonbit_bytes_t position,
  float scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModelPoints(wrapper->model, pos, scale, c);
}

void
moonbit_raylib_draw_model_points_ex(
  ModelWrapper *wrapper,
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
  DrawModelPointsEx(wrapper->model, pos, axis, rotationAngle, sc, c);
}

// ============================================================================
// Models: Model management
// ============================================================================

int
moonbit_raylib_is_model_valid(ModelWrapper *wrapper) {
  return (int)IsModelValid(wrapper->model);
}

moonbit_bytes_t
moonbit_raylib_get_model_bounding_box(ModelWrapper *wrapper) {
  BoundingBox bb = GetModelBoundingBox(wrapper->model);
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
  TextureWrapper *tex_wrapper,
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
  DrawBillboard(cam, tex_wrapper->texture, pos, scale, c);
}

void
moonbit_raylib_draw_billboard_rec(
  moonbit_bytes_t camera,
  TextureWrapper *tex_wrapper,
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
  DrawBillboardRec(cam, tex_wrapper->texture, src, pos, sz, c);
}

void
moonbit_raylib_draw_billboard_pro(
  moonbit_bytes_t camera,
  TextureWrapper *tex_wrapper,
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
  DrawBillboardPro(cam, tex_wrapper->texture, src, pos, u, sz, org, rotation, c);
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
// Resource destructor: Mesh
// ============================================================================

static void
mesh_destructor(void *ptr) {
  MeshWrapper *w = (MeshWrapper *)ptr;
  if (!w->freed)
    UnloadMesh(w->mesh);
}

// ============================================================================
// Mesh generation
// ============================================================================

MeshWrapper *
moonbit_raylib_gen_mesh_poly(int sides, float radius) {
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshPoly(sides, radius);
  w->freed = 0;
  return w;
}

MeshWrapper *
moonbit_raylib_gen_mesh_plane(float width, float length, int resX, int resZ) {
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshPlane(width, length, resX, resZ);
  w->freed = 0;
  return w;
}

MeshWrapper *
moonbit_raylib_gen_mesh_cube(float width, float height, float length) {
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshCube(width, height, length);
  w->freed = 0;
  return w;
}

MeshWrapper *
moonbit_raylib_gen_mesh_sphere(float radius, int rings, int slices) {
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshSphere(radius, rings, slices);
  w->freed = 0;
  return w;
}

MeshWrapper *
moonbit_raylib_gen_mesh_hemisphere(float radius, int rings, int slices) {
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshHemiSphere(radius, rings, slices);
  w->freed = 0;
  return w;
}

MeshWrapper *
moonbit_raylib_gen_mesh_cylinder(float radius, float height, int slices) {
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshCylinder(radius, height, slices);
  w->freed = 0;
  return w;
}

MeshWrapper *
moonbit_raylib_gen_mesh_cone(float radius, float height, int slices) {
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshCone(radius, height, slices);
  w->freed = 0;
  return w;
}

MeshWrapper *
moonbit_raylib_gen_mesh_torus(
  float radius,
  float size,
  int radSeg,
  int sides
) {
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshTorus(radius, size, radSeg, sides);
  w->freed = 0;
  return w;
}

MeshWrapper *
moonbit_raylib_gen_mesh_knot(
  float radius,
  float size,
  int radSeg,
  int sides
) {
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshKnot(radius, size, radSeg, sides);
  w->freed = 0;
  return w;
}

MeshWrapper *
moonbit_raylib_gen_mesh_heightmap(ImageWrapper *img, moonbit_bytes_t size) {
  Vector3 sz;
  memcpy(&sz, size, sizeof(Vector3));
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshHeightmap(img->image, sz);
  w->freed = 0;
  return w;
}

MeshWrapper *
moonbit_raylib_gen_mesh_cubicmap(ImageWrapper *img, moonbit_bytes_t cubeSize) {
  Vector3 cs;
  memcpy(&cs, cubeSize, sizeof(Vector3));
  MeshWrapper *w = (MeshWrapper *)moonbit_make_external_object(
    mesh_destructor, sizeof(MeshWrapper)
  );
  w->mesh = GenMeshCubicmap(img->image, cs);
  w->freed = 0;
  return w;
}

// ============================================================================
// Mesh utilities
// ============================================================================

void
moonbit_raylib_unload_mesh(MeshWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadMesh(wrapper->mesh);
    wrapper->freed = 1;
  }
}

moonbit_bytes_t
moonbit_raylib_get_mesh_bounding_box(MeshWrapper *wrapper) {
  BoundingBox bb = GetMeshBoundingBox(wrapper->mesh);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(BoundingBox), 0);
  memcpy(r, &bb, sizeof(BoundingBox));
  return r;
}

int
moonbit_raylib_export_mesh(MeshWrapper *wrapper, moonbit_bytes_t fileName) {
  return (int)ExportMesh(wrapper->mesh, (const char *)fileName);
}

void
moonbit_raylib_upload_mesh(MeshWrapper *wrapper, int dynamic) {
  UploadMesh(&wrapper->mesh, (bool)dynamic);
}

void
moonbit_raylib_gen_mesh_tangents(MeshWrapper *wrapper) {
  GenMeshTangents(&wrapper->mesh);
}

moonbit_bytes_t
moonbit_raylib_get_ray_collision_mesh(
  moonbit_bytes_t ray,
  MeshWrapper *wrapper,
  moonbit_bytes_t transform
) {
  Ray r;
  memcpy(&r, ray, sizeof(Ray));
  Matrix m;
  memcpy(&m, transform, sizeof(Matrix));
  RayCollision result = GetRayCollisionMesh(r, wrapper->mesh, m);
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(RayCollision), 0);
  memcpy(res, &result, sizeof(RayCollision));
  return res;
}

ModelWrapper *
moonbit_raylib_load_model_from_mesh(MeshWrapper *wrapper) {
  ModelWrapper *w = (ModelWrapper *)moonbit_make_external_object(
    model_destructor, sizeof(ModelWrapper)
  );
  w->model = LoadModelFromMesh(wrapper->mesh);
  w->freed = 0;
  return w;
}

// ============================================================================
// Resource destructor: Material
// ============================================================================

static void
material_destructor(void *ptr) {
  MaterialWrapper *w = (MaterialWrapper *)ptr;
  if (!w->freed)
    UnloadMaterial(w->material);
}

// ============================================================================
// Material management
// ============================================================================

MaterialWrapper *
moonbit_raylib_load_material_default(void) {
  MaterialWrapper *w = (MaterialWrapper *)moonbit_make_external_object(
    material_destructor, sizeof(MaterialWrapper)
  );
  w->material = LoadMaterialDefault();
  w->freed = 0;
  return w;
}

int
moonbit_raylib_is_material_valid(MaterialWrapper *wrapper) {
  return (int)IsMaterialValid(wrapper->material);
}

void
moonbit_raylib_unload_material(MaterialWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadMaterial(wrapper->material);
    wrapper->freed = 1;
  }
}

void
moonbit_raylib_set_material_texture(
  MaterialWrapper *wrapper,
  int mapType,
  TextureWrapper *tex_wrapper
) {
  SetMaterialTexture(&wrapper->material, mapType, tex_wrapper->texture);
}

void
moonbit_raylib_set_model_mesh_material(
  ModelWrapper *wrapper,
  int meshId,
  int materialId
) {
  SetModelMeshMaterial(&wrapper->model, meshId, materialId);
}

// ============================================================================
// Mesh drawing
// ============================================================================

void
moonbit_raylib_draw_mesh(
  MeshWrapper *mesh_wrapper,
  MaterialWrapper *mat_wrapper,
  moonbit_bytes_t transform
) {
  Matrix m;
  memcpy(&m, transform, sizeof(Matrix));
  DrawMesh(mesh_wrapper->mesh, mat_wrapper->material, m);
}

void
moonbit_raylib_draw_mesh_instanced(
  MeshWrapper *mesh_wrapper,
  MaterialWrapper *mat_wrapper,
  moonbit_bytes_t transforms,
  int instances
) {
  Matrix *mats = (Matrix *)transforms;
  DrawMeshInstanced(mesh_wrapper->mesh, mat_wrapper->material, mats, instances);
}

// ============================================================================
// Model animations
// ============================================================================

static void model_animations_destructor(void *ptr) {
  ModelAnimationsWrapper *w = (ModelAnimationsWrapper *)ptr;
  if (!w->freed) UnloadModelAnimations(w->anims, w->count);
}

ModelAnimationsWrapper *
moonbit_raylib_load_model_animations(moonbit_bytes_t fileName) {
  int count = 0;
  ModelAnimation *anims = LoadModelAnimations((const char *)fileName, &count);
  ModelAnimationsWrapper *w = (ModelAnimationsWrapper *)moonbit_make_external_object(
    model_animations_destructor, sizeof(ModelAnimationsWrapper)
  );
  w->anims = anims;
  w->count = count;
  w->freed = 0;
  return w;
}

int moonbit_raylib_model_animations_count(ModelAnimationsWrapper *wrapper) {
  return wrapper->count;
}

void moonbit_raylib_update_model_animation(ModelWrapper *model, ModelAnimationsWrapper *anims, int index, int frame) {
  if (index >= 0 && index < anims->count)
    UpdateModelAnimation(model->model, anims->anims[index], frame);
}

void moonbit_raylib_update_model_animation_bones(ModelWrapper *model, ModelAnimationsWrapper *anims, int index, int frame) {
  if (index >= 0 && index < anims->count)
    UpdateModelAnimationBones(model->model, anims->anims[index], frame);
}

int moonbit_raylib_is_model_animation_valid(ModelWrapper *model, ModelAnimationsWrapper *anims, int index) {
  if (index >= 0 && index < anims->count)
    return (int)IsModelAnimationValid(model->model, anims->anims[index]);
  return 0;
}

void moonbit_raylib_unload_model_animations(ModelAnimationsWrapper *wrapper) {
  if (wrapper && !wrapper->freed) {
    UnloadModelAnimations(wrapper->anims, wrapper->count);
    wrapper->freed = 1;
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
moonbit_raylib_export_mesh_as_code(MeshWrapper *wrapper, moonbit_bytes_t fileName) {
  return (int)ExportMeshAsCode(wrapper->mesh, (const char *)fileName);
}

// ============================================================================
// Mesh: UpdateMeshBuffer
// ============================================================================

void
moonbit_raylib_update_mesh_buffer(MeshWrapper *wrapper, int index, moonbit_bytes_t data, int data_size, int offset) {
  UpdateMeshBuffer(wrapper->mesh, index, (const void *)data, data_size, offset);
}

// ============================================================================
// LoadMaterials
// ============================================================================

typedef struct {
  Material *materials;
  int count;
  int freed;
} MaterialsArrayWrapper;

static void
materials_array_destructor(void *ptr) {
  MaterialsArrayWrapper *w = (MaterialsArrayWrapper *)ptr;
  if (!w->freed && w->materials) {
    for (int i = 0; i < w->count; i++) {
      UnloadMaterial(w->materials[i]);
    }
    RL_FREE(w->materials);
  }
}

MaterialsArrayWrapper *
moonbit_raylib_load_materials(moonbit_bytes_t fileName) {
  int count = 0;
  Material *mats = LoadMaterials((const char *)fileName, &count);
  MaterialsArrayWrapper *w = (MaterialsArrayWrapper *)moonbit_make_external_object(
    materials_array_destructor, sizeof(MaterialsArrayWrapper));
  w->materials = mats;
  w->count = count;
  w->freed = 0;
  return w;
}

void
moonbit_raylib_unload_materials_array(MaterialsArrayWrapper *w) {
  if (w && !w->freed && w->materials) {
    for (int i = 0; i < w->count; i++) {
      UnloadMaterial(w->materials[i]);
    }
    RL_FREE(w->materials);
    w->freed = 1;
  }
}

int
moonbit_raylib_materials_array_count(MaterialsArrayWrapper *w) {
  return w->count;
}

// Get a single material from the array, wrapping it as a MaterialWrapper
// The returned material shares resources with the array; user should manage lifetime carefully.
MaterialWrapper *
moonbit_raylib_materials_array_get(MaterialsArrayWrapper *w, int index) {
  MaterialWrapper *mw = (MaterialWrapper *)moonbit_make_external_object(
    material_destructor, sizeof(MaterialWrapper));
  if (index >= 0 && index < w->count) {
    mw->material = w->materials[index];
  } else {
    mw->material = LoadMaterialDefault();
  }
  mw->freed = 0;
  return mw;
}
