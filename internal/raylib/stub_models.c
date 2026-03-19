#include "raylib.h"
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

ModelWrapper *
moonbit_raylib_load_model(moonbit_bytes_t fileName) {
  return MakeModelWrapper(LoadModel((const char *)fileName));
}

void
moonbit_raylib_unload_model(ModelWrapper *m) {
  if (m) {
    UnloadModel(*m->data);
  }
}

void
moonbit_raylib_draw_model(
  ModelWrapper *m,
  moonbit_bytes_t position,
  float scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModel(*m->data, pos, scale, c);
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
  ModelWrapper *m,
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
  DrawModelEx(*m->data, pos, axis, rotationAngle, sc, c);
}

void
moonbit_raylib_draw_model_wires(
  ModelWrapper *m,
  moonbit_bytes_t position,
  float scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModelWires(*m->data, pos, scale, c);
}

void
moonbit_raylib_draw_model_wires_ex(
  ModelWrapper *m,
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
  DrawModelWiresEx(*m->data, pos, axis, rotationAngle, sc, c);
}

void
moonbit_raylib_draw_model_points(
  ModelWrapper *m,
  moonbit_bytes_t position,
  float scale,
  moonbit_bytes_t tint
) {
  Vector3 pos;
  memcpy(&pos, position, sizeof(Vector3));
  Color c;
  memcpy(&c, tint, sizeof(Color));
  DrawModelPoints(*m->data, pos, scale, c);
}

void
moonbit_raylib_draw_model_points_ex(
  ModelWrapper *m,
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
  DrawModelPointsEx(*m->data, pos, axis, rotationAngle, sc, c);
}

// ============================================================================
// Models: Model management
// ============================================================================

int
moonbit_raylib_is_model_valid(ModelWrapper *m) {
  return (int)IsModelValid(*m->data);
}

moonbit_bytes_t
moonbit_raylib_get_model_bounding_box(ModelWrapper *m) {
  BoundingBox bb = GetModelBoundingBox(*m->data);
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
  TextureWrapper *tw,
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
  DrawBillboard(cam, *tw->data, pos, scale, c);
}

void
moonbit_raylib_draw_billboard_rec(
  moonbit_bytes_t camera,
  TextureWrapper *tw,
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
  DrawBillboardRec(cam, *tw->data, src, pos, sz, c);
}

void
moonbit_raylib_draw_billboard_pro(
  moonbit_bytes_t camera,
  TextureWrapper *tw,
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
  DrawBillboardPro(cam, *tw->data, src, pos, u, sz, org, rotation, c);
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

MeshWrapper *
moonbit_raylib_gen_mesh_poly(int sides, float radius) {
  return MakeMeshWrapper(GenMeshPoly(sides, radius));
}

MeshWrapper *
moonbit_raylib_gen_mesh_plane(float width, float length, int resX, int resZ) {
  return MakeMeshWrapper(GenMeshPlane(width, length, resX, resZ));
}

MeshWrapper *
moonbit_raylib_gen_mesh_cube(float width, float height, float length) {
  return MakeMeshWrapper(GenMeshCube(width, height, length));
}

MeshWrapper *
moonbit_raylib_gen_mesh_sphere(float radius, int rings, int slices) {
  return MakeMeshWrapper(GenMeshSphere(radius, rings, slices));
}

MeshWrapper *
moonbit_raylib_gen_mesh_hemisphere(float radius, int rings, int slices) {
  return MakeMeshWrapper(GenMeshHemiSphere(radius, rings, slices));
}

MeshWrapper *
moonbit_raylib_gen_mesh_cylinder(float radius, float height, int slices) {
  return MakeMeshWrapper(GenMeshCylinder(radius, height, slices));
}

MeshWrapper *
moonbit_raylib_gen_mesh_cone(float radius, float height, int slices) {
  return MakeMeshWrapper(GenMeshCone(radius, height, slices));
}

MeshWrapper *
moonbit_raylib_gen_mesh_torus(float radius, float size, int radSeg, int sides) {
  return MakeMeshWrapper(GenMeshTorus(radius, size, radSeg, sides));
}

MeshWrapper *
moonbit_raylib_gen_mesh_knot(float radius, float size, int radSeg, int sides) {
  return MakeMeshWrapper(GenMeshKnot(radius, size, radSeg, sides));
}

MeshWrapper *
moonbit_raylib_gen_mesh_heightmap(ImageWrapper *img, moonbit_bytes_t size) {
  Vector3 sz;
  memcpy(&sz, size, sizeof(Vector3));
  return MakeMeshWrapper(GenMeshHeightmap(*img->data, sz));
}

MeshWrapper *
moonbit_raylib_gen_mesh_cubicmap(ImageWrapper *img, moonbit_bytes_t cubeSize) {
  Vector3 cs;
  memcpy(&cs, cubeSize, sizeof(Vector3));
  return MakeMeshWrapper(GenMeshCubicmap(*img->data, cs));
}

// ============================================================================
// Mesh utilities
// ============================================================================

void
moonbit_raylib_unload_mesh(MeshWrapper *w) {
  UnloadMesh(*w->data);
}

moonbit_bytes_t
moonbit_raylib_get_mesh_bounding_box(MeshWrapper *w) {
  BoundingBox bb = GetMeshBoundingBox(*w->data);
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(BoundingBox), 0);
  memcpy(r, &bb, sizeof(BoundingBox));
  return r;
}

int
moonbit_raylib_export_mesh(MeshWrapper *w, moonbit_bytes_t fileName) {
  return (int)ExportMesh(*w->data, (const char *)fileName);
}

void
moonbit_raylib_upload_mesh(MeshWrapper *w, int dynamic) {
  UploadMesh(w->data, (bool)dynamic);
}

void
moonbit_raylib_gen_mesh_tangents(MeshWrapper *w) {
  GenMeshTangents(w->data);
}

moonbit_bytes_t
moonbit_raylib_get_ray_collision_mesh(
  moonbit_bytes_t ray,
  MeshWrapper *w,
  moonbit_bytes_t transform
) {
  Ray r;
  memcpy(&r, ray, sizeof(Ray));
  Matrix mat;
  memcpy(&mat, transform, sizeof(Matrix));
  RayCollision result = GetRayCollisionMesh(r, *w->data, mat);
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(RayCollision), 0);
  memcpy(res, &result, sizeof(RayCollision));
  return res;
}

ModelWrapper *
moonbit_raylib_load_model_from_mesh(MeshWrapper *w) {
  ModelWrapper *model = MakeModelWrapper(LoadModelFromMesh(*w->data));
  // Zero out the source mesh to prevent double-free of shared vertex data.
  // LoadModelFromMesh copies the Mesh struct (which contains pointers to
  // vertex data), so both the original and the model's copy would point to
  // the same data. Zeroing prevents UnloadMesh from freeing shared data.
  // Only zero owned meshes — views point into parent memory we must not touch.
  if (w->owner == NULL) {
    memset(w->data, 0, sizeof(Mesh));
  }
  return model;
}

// ============================================================================
// Material management
// ============================================================================

MaterialWrapper *
moonbit_raylib_load_material_default(void) {
  return MakeMaterialWrapper(LoadMaterialDefault());
}

int
moonbit_raylib_is_material_valid(MaterialWrapper *w) {
  return (int)IsMaterialValid(*w->data);
}

void
moonbit_raylib_unload_material(MaterialWrapper *w) {
  UnloadMaterial(*w->data);
}

void
moonbit_raylib_set_material_texture(
  MaterialWrapper *w,
  int mapType,
  TextureWrapper *tw
) {
  if (mapType >= 0 && mapType < MAX_MATERIAL_MAPS) {
    w->data->maps[mapType].texture = *tw->data;
  }
}

void
moonbit_raylib_set_model_mesh_material(
  ModelWrapper *m,
  int meshId,
  int materialId
) {
  SetModelMeshMaterial(m->data, meshId, materialId);
}

void
moonbit_raylib_set_model_material_texture(
  ModelWrapper *m,
  int materialIndex,
  int mapType,
  TextureWrapper *tw
) {
  if (materialIndex >= 0 && materialIndex < m->data->materialCount &&
      mapType >= 0 && mapType < MAX_MATERIAL_MAPS) {
    m->data->materials[materialIndex].maps[mapType].texture = *tw->data;
  }
}

// ============================================================================
// Model: set material shader
// ============================================================================

void
moonbit_raylib_set_model_material_shader(
  ModelWrapper *m,
  int material_index,
  ShaderWrapper *s
) {
  if (material_index >= 0 && material_index < m->data->materialCount) {
    m->data->materials[material_index].shader = *s->data;
  }
}

// ============================================================================
// Material: set shader on standalone material
// ============================================================================

void
moonbit_raylib_set_material_shader(MaterialWrapper *w, ShaderWrapper *s) {
  w->data->shader = *s->data;
}

// ============================================================================
// Material: set material map color
// ============================================================================

void
moonbit_raylib_set_material_map_color(
  MaterialWrapper *w,
  int mapType,
  moonbit_bytes_t color
) {
  Color c;
  memcpy(&c, color, sizeof(Color));
  if (mapType >= 0 && mapType < MAX_MATERIAL_MAPS) {
    w->data->maps[mapType].color = c;
  }
}

// ============================================================================
// Material: set material map value
// ============================================================================

void
moonbit_raylib_set_material_map_value(
  MaterialWrapper *w,
  int mapType,
  float value
) {
  if (mapType >= 0 && mapType < MAX_MATERIAL_MAPS) {
    w->data->maps[mapType].value = value;
  }
}

// ============================================================================
// Mesh drawing
// ============================================================================

void
moonbit_raylib_draw_mesh(
  MeshWrapper *mw,
  MaterialWrapper *matw,
  moonbit_bytes_t transform
) {
  Matrix m;
  memcpy(&m, transform, sizeof(Matrix));
  DrawMesh(*mw->data, *matw->data, m);
}

void
moonbit_raylib_draw_mesh_instanced(
  MeshWrapper *mw,
  MaterialWrapper *matw,
  moonbit_bytes_t transforms,
  int instances
) {
  Matrix *mats = (Matrix *)transforms;
  DrawMeshInstanced(*mw->data, *matw->data, mats, instances);
}

// ============================================================================
// Model animations
// ============================================================================

ModelAnimationsWrapper *
moonbit_raylib_load_model_animations(moonbit_bytes_t fileName) {
  int count = 0;
  ModelAnimation *anims = LoadModelAnimations((const char *)fileName, &count);
  return MakeModelAnimationsWrapper(anims, count);
}

int
moonbit_raylib_model_animations_count(ModelAnimationsWrapper *wrapper) {
  return wrapper->count;
}

void
moonbit_raylib_update_model_animation(
  ModelWrapper *m,
  ModelAnimationsWrapper *anims,
  int index,
  int frame
) {
  if (index >= 0 && index < anims->count)
    UpdateModelAnimation(*m->data, anims->anims[index], frame);
}

void
moonbit_raylib_update_model_animation_bones(
  ModelWrapper *m,
  ModelAnimationsWrapper *anims,
  int index,
  int frame
) {
  if (index >= 0 && index < anims->count)
    UpdateModelAnimationBones(*m->data, anims->anims[index], frame);
}

int
moonbit_raylib_is_model_animation_valid(
  ModelWrapper *m,
  ModelAnimationsWrapper *anims,
  int index
) {
  if (index >= 0 && index < anims->count)
    return (int)IsModelAnimationValid(*m->data, anims->anims[index]);
  return 0;
}

void
moonbit_raylib_unload_model_animations(ModelAnimationsWrapper *w) {
  if (w) {
    UnloadModelAnimations(w->anims, w->count);
  }
}

// ============================================================================
// Ray collision: quad
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_ray_collision_quad(
  moonbit_bytes_t ray,
  moonbit_bytes_t p1,
  moonbit_bytes_t p2,
  moonbit_bytes_t p3,
  moonbit_bytes_t p4
) {
  Ray r;
  memcpy(&r, ray, sizeof(Ray));
  Vector3 v1;
  memcpy(&v1, p1, sizeof(Vector3));
  Vector3 v2;
  memcpy(&v2, p2, sizeof(Vector3));
  Vector3 v3;
  memcpy(&v3, p3, sizeof(Vector3));
  Vector3 v4;
  memcpy(&v4, p4, sizeof(Vector3));
  RayCollision result = GetRayCollisionQuad(r, v1, v2, v3, v4);
  moonbit_bytes_t res = moonbit_make_bytes(sizeof(RayCollision), 0);
  memcpy(res, &result, sizeof(RayCollision));
  return res;
}

// ============================================================================
// Mesh: Export as code
// ============================================================================

int
moonbit_raylib_export_mesh_as_code(MeshWrapper *w, moonbit_bytes_t fileName) {
  return (int)ExportMeshAsCode(*w->data, (const char *)fileName);
}

// ============================================================================
// Mesh: UpdateMeshBuffer
// ============================================================================

void
moonbit_raylib_update_mesh_buffer(
  MeshWrapper *w,
  int index,
  moonbit_bytes_t data,
  int data_size,
  int offset
) {
  UpdateMeshBuffer(*w->data, index, (const void *)data, data_size, offset);
}

// ============================================================================
// LoadMaterials
// ============================================================================

MaterialsArrayWrapper *
moonbit_raylib_load_materials(moonbit_bytes_t fileName) {
  int count = 0;
  Material *mats = LoadMaterials((const char *)fileName, &count);
  return MakeMaterialsArrayWrapper(mats, count);
}

void
moonbit_raylib_unload_materials_array(MaterialsArrayWrapper *w) {
  if (w) {
    if (w->materials) {
      for (int i = 0; i < w->count; i++) {
        UnloadMaterial(w->materials[i]);
      }
      RL_FREE(w->materials);
    }
  }
}

int
moonbit_raylib_materials_array_count(MaterialsArrayWrapper *w) {
  return w->count;
}

// Get a single material from the array (non-owning view into the array)
MaterialWrapper *
moonbit_raylib_materials_array_get(MaterialsArrayWrapper *w, int index) {
  assert(
    index >= 0 && index < w->count && "materials array index out of bounds"
  );
  return MakeMaterialWrapperView(&w->materials[index], w);
}

// ============================================================================
// Model: set transform
// ============================================================================

void
moonbit_raylib_set_model_transform(ModelWrapper *m, moonbit_bytes_t transform) {
  Matrix mat;
  memcpy(&mat, transform, sizeof(Matrix));
  m->data->transform = mat;
}

// ============================================================================
// Model: get mesh count
// ============================================================================

int
moonbit_raylib_get_model_mesh_count(ModelWrapper *m) {
  return m->data->meshCount;
}

// ============================================================================
// Model: get mesh by index (non-owning view into Model's array)
// ============================================================================

MeshWrapper *
moonbit_raylib_get_model_mesh(ModelWrapper *m, int index) {
  assert(
    index >= 0 && index < m->data->meshCount && "model mesh index out of bounds"
  );
  return MakeMeshWrapperView(&m->data->meshes[index], m);
}

// ============================================================================
// Model: get transform
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_transform(ModelWrapper *m) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Matrix), 0);
  memcpy(r, &m->data->transform, sizeof(Matrix));
  return r;
}

// ============================================================================
// Model: get material count
// ============================================================================

int
moonbit_raylib_get_model_material_count(ModelWrapper *m) {
  return m->data->materialCount;
}

// ============================================================================
// Model: get material by index (non-owning view into Model's array)
// ============================================================================

MaterialWrapper *
moonbit_raylib_get_model_material(ModelWrapper *m, int index) {
  assert(
    index >= 0 && index < m->data->materialCount &&
    "model material index out of bounds"
  );
  return MakeMaterialWrapperView(&m->data->materials[index], m);
}

// ============================================================================
// Model: get bone count
// ============================================================================

int
moonbit_raylib_get_model_bone_count(ModelWrapper *m) {
  return m->data->boneCount;
}

// ============================================================================
// Model: get bone parent
// ============================================================================

int
moonbit_raylib_get_model_bone_parent(ModelWrapper *m, int bone_index) {
  if (bone_index >= 0 && bone_index < m->data->boneCount) {
    return m->data->bones[bone_index].parent;
  }
  return -1;
}

// ============================================================================
// Model: get bind pose translation (Vector3 as Bytes)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_bind_pose_translation(
  ModelWrapper *m,
  int bone_index
) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector3), 0);
  if (bone_index >= 0 && bone_index < m->data->boneCount) {
    memcpy(r, &m->data->bindPose[bone_index].translation, sizeof(Vector3));
  }
  return r;
}

// ============================================================================
// ModelAnimations: get animation frame count
// ============================================================================

int
moonbit_raylib_get_model_animation_frame_count(
  ModelAnimationsWrapper *wrapper,
  int anim_index
) {
  if (anim_index >= 0 && anim_index < wrapper->count) {
    return wrapper->anims[anim_index].frameCount;
  }
  return 0;
}

// ============================================================================
// ModelAnimations: get animation bone count
// ============================================================================

int
moonbit_raylib_get_model_animation_bone_count(
  ModelAnimationsWrapper *wrapper,
  int anim_index
) {
  if (anim_index >= 0 && anim_index < wrapper->count) {
    return wrapper->anims[anim_index].boneCount;
  }
  return 0;
}

// ============================================================================
// ModelAnimations: get animation bone parent
// ============================================================================

int
moonbit_raylib_get_model_animation_bone_parent(
  ModelAnimationsWrapper *wrapper,
  int anim_index,
  int bone_index
) {
  if (anim_index >= 0 && anim_index < wrapper->count && bone_index >= 0 &&
      bone_index < wrapper->anims[anim_index].boneCount) {
    return wrapper->anims[anim_index].bones[bone_index].parent;
  }
  return -1;
}

// ============================================================================
// ModelAnimations: get frame pose translation (Vector3 as Bytes)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_animation_frame_pose_translation(
  ModelAnimationsWrapper *wrapper,
  int anim_index,
  int frame,
  int bone_index
) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector3), 0);
  if (anim_index >= 0 && anim_index < wrapper->count && frame >= 0 &&
      frame < wrapper->anims[anim_index].frameCount && bone_index >= 0 &&
      bone_index < wrapper->anims[anim_index].boneCount) {
    memcpy(
      r, &wrapper->anims[anim_index].framePoses[frame][bone_index].translation,
      sizeof(Vector3)
    );
  }
  return r;
}

// ============================================================================
// ModelAnimations: get frame pose rotation (Quaternion/Vector4 as Bytes)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_animation_frame_pose_rotation(
  ModelAnimationsWrapper *wrapper,
  int anim_index,
  int frame,
  int bone_index
) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector4), 0);
  if (anim_index >= 0 && anim_index < wrapper->count && frame >= 0 &&
      frame < wrapper->anims[anim_index].frameCount && bone_index >= 0 &&
      bone_index < wrapper->anims[anim_index].boneCount) {
    memcpy(
      r, &wrapper->anims[anim_index].framePoses[frame][bone_index].rotation,
      sizeof(Vector4)
    );
  }
  return r;
}

// ============================================================================
// Model: get bone name (returns Bytes / UTF-8 string)
// ============================================================================

moonbit_bytes_t
moonbit_raylib_get_model_bone_name(ModelWrapper *m, int bone_index) {
  if (bone_index >= 0 && bone_index < m->data->boneCount) {
    const char *name = m->data->bones[bone_index].name;
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
moonbit_raylib_get_model_bind_pose_rotation(ModelWrapper *m, int bone_index) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Vector4), 0);
  if (bone_index >= 0 && bone_index < m->data->boneCount) {
    memcpy(r, &m->data->bindPose[bone_index].rotation, sizeof(Vector4));
  }
  return r;
}

// ============================================================================
// Mesh: Generate point cloud from vertex+color data
// ============================================================================

MeshWrapper *
moonbit_raylib_gen_mesh_from_points(
  moonbit_bytes_t vertices,
  moonbit_bytes_t colors,
  int num_points
) {
  Mesh mesh = {0};
  mesh.triangleCount = 1;
  mesh.vertexCount = num_points;
  mesh.vertices = (float *)MemAlloc(num_points * 3 * sizeof(float));
  mesh.colors =
    (unsigned char *)MemAlloc(num_points * 4 * sizeof(unsigned char));
  memcpy(mesh.vertices, vertices, num_points * 3 * sizeof(float));
  memcpy(mesh.colors, colors, num_points * 4 * sizeof(unsigned char));
  MeshWrapper *w = MakeMeshWrapper(mesh);
  UploadMesh(w->data, false);
  return w;
}

// ============================================================================
// FloatArray: raw float* operations (#external, no wrapper)
// ============================================================================

int32_t
moonbit_raylib_float_array_is_null(float *arr) {
  return arr == NULL;
}

float
moonbit_raylib_float_array_get(float *arr, int32_t index) {
  return arr[index];
}

void
moonbit_raylib_float_array_set(float *arr, int32_t index, float value) {
  arr[index] = value;
}

// ============================================================================
// UByteArray: raw unsigned char* operations (#external, no wrapper)
// ============================================================================

int32_t
moonbit_raylib_ubyte_array_is_null(unsigned char *arr) {
  return arr == NULL;
}

int32_t
moonbit_raylib_ubyte_array_get(unsigned char *arr, int32_t index) {
  return (int32_t)arr[index];
}

void
moonbit_raylib_ubyte_array_set(
  unsigned char *arr,
  int32_t index,
  int32_t value
) {
  arr[index] = (unsigned char)value;
}

// ============================================================================
// UShortArray: raw unsigned short* operations (#external, no wrapper)
// ============================================================================

int32_t
moonbit_raylib_ushort_array_is_null(unsigned short *arr) {
  return arr == NULL;
}

int32_t
moonbit_raylib_ushort_array_get(unsigned short *arr, int32_t index) {
  return (int32_t)arr[index];
}

void
moonbit_raylib_ushort_array_set(
  unsigned short *arr,
  int32_t index,
  int32_t value
) {
  arr[index] = (unsigned short)value;
}

// ============================================================================
// ShortArray: raw short* operations (#external, no wrapper)
// ============================================================================

int32_t
moonbit_raylib_short_array_is_null(short *arr) {
  return arr == NULL;
}

int32_t
moonbit_raylib_short_array_get(short *arr, int32_t index) {
  return (int32_t)arr[index];
}

void
moonbit_raylib_short_array_set(
  short *arr,
  int32_t index,
  int32_t value
) {
  arr[index] = (short)value;
}

// ============================================================================
// MatrixArray: raw Matrix* operations (#external, no wrapper)
// ============================================================================

int32_t
moonbit_raylib_matrix_array_is_null(Matrix *arr) {
  return arr == NULL;
}

moonbit_bytes_t
moonbit_raylib_matrix_array_op_get(Matrix *arr, int32_t index) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Matrix), 0);
  memcpy(r, &arr[index], sizeof(Matrix));
  return r;
}

void
moonbit_raylib_matrix_array_op_set(
  Matrix *arr,
  int32_t index,
  moonbit_bytes_t value
) {
  memcpy(&arr[index], value, sizeof(Matrix));
}

// ============================================================================
// MaterialMapArray: raw MaterialMap* operations (#external, no wrapper)
// ============================================================================

int32_t
moonbit_raylib_material_map_array_is_null(MaterialMap *arr) {
  return arr == NULL;
}

MaterialMapWrapper *
moonbit_raylib_material_map_array_op_get(MaterialMap *arr, int32_t index) {
  return MakeMaterialMapWrapperView(&arr[index], NULL);
}

void
moonbit_raylib_material_map_array_op_set(
  MaterialMap *arr,
  int32_t index,
  MaterialMapWrapper *src
) {
  arr[index] = *src->data;
}

// ============================================================================
// MaterialMap: field accessors
// ============================================================================

TextureWrapper *
moonbit_raylib_material_map_get_texture(MaterialMapWrapper *w) {
  return MakeTextureWrapperView(&w->data->texture, w);
}

void
moonbit_raylib_material_map_set_texture(
  MaterialMapWrapper *w,
  TextureWrapper *tw
) {
  w->data->texture = *tw->data;
}

moonbit_bytes_t
moonbit_raylib_material_map_get_color(MaterialMapWrapper *w) {
  moonbit_bytes_t r = moonbit_make_bytes(sizeof(Color), 0);
  memcpy(r, &w->data->color, sizeof(Color));
  return r;
}

void
moonbit_raylib_material_map_set_color(
  MaterialMapWrapper *w,
  moonbit_bytes_t color
) {
  memcpy(&w->data->color, color, sizeof(Color));
}

float
moonbit_raylib_material_map_get_value(MaterialMapWrapper *w) {
  return w->data->value;
}

void
moonbit_raylib_material_map_set_value(MaterialMapWrapper *w, float value) {
  w->data->value = value;
}

// ============================================================================
// Material: shader and maps accessors
// ============================================================================

ShaderWrapper *
moonbit_raylib_get_material_shader(MaterialWrapper *w) {
  return MakeShaderWrapperView(&w->data->shader, w);
}

MaterialMap *
moonbit_raylib_get_material_maps(MaterialWrapper *w) {
  return w->data->maps;
}

// ============================================================================
// Mesh: bone matrices accessor
// ============================================================================

int32_t
moonbit_raylib_get_mesh_bone_count(MeshWrapper *w) {
  return w->data->boneCount;
}

Matrix *
moonbit_raylib_get_mesh_bone_matrices(MeshWrapper *w) {
  return w->data->boneMatrices;
}

// ============================================================================
// Mesh: constructor and field accessors
// ============================================================================

static void *
copy_fixed_array(void *arr, size_t elem_size) {
  if (!arr) return NULL;
  int32_t len = Moonbit_array_length(arr);
  if (len <= 0) return NULL;
  size_t size = (size_t)len * elem_size;
  return memcpy(RL_MALLOC(size), arr, size);
}

MeshWrapper *
moonbit_raylib_new_mesh(
  int32_t vertex_count,
  int32_t triangle_count,
  float *vertices,
  float *texcoords,
  float *texcoords2,
  float *normals,
  float *tangents,
  moonbit_bytes_t colors,
  uint16_t *indices
) {
  Mesh mesh = {0};
  mesh.vertexCount = vertex_count;
  mesh.triangleCount = triangle_count;
  mesh.vertices = copy_fixed_array(vertices, sizeof(float));
  mesh.texcoords = copy_fixed_array(texcoords, sizeof(float));
  mesh.texcoords2 = copy_fixed_array(texcoords2, sizeof(float));
  mesh.normals = copy_fixed_array(normals, sizeof(float));
  mesh.tangents = copy_fixed_array(tangents, sizeof(float));
  mesh.colors = copy_fixed_array(colors, sizeof(unsigned char));
  mesh.indices = copy_fixed_array(indices, sizeof(unsigned short));
  return MakeMeshWrapper(mesh);
}

int32_t
moonbit_raylib_get_mesh_vertex_count(MeshWrapper *w) {
  return w->data->vertexCount;
}

int32_t
moonbit_raylib_get_mesh_triangle_count(MeshWrapper *w) {
  return w->data->triangleCount;
}

float *
moonbit_raylib_get_mesh_vertices(MeshWrapper *w) {
  return w->data->vertices;
}

float *
moonbit_raylib_get_mesh_texcoords(MeshWrapper *w) {
  return w->data->texcoords;
}

float *
moonbit_raylib_get_mesh_texcoords2(MeshWrapper *w) {
  return w->data->texcoords2;
}

float *
moonbit_raylib_get_mesh_normals(MeshWrapper *w) {
  return w->data->normals;
}

float *
moonbit_raylib_get_mesh_tangents(MeshWrapper *w) {
  return w->data->tangents;
}

unsigned char *
moonbit_raylib_get_mesh_colors(MeshWrapper *w) {
  return w->data->colors;
}

unsigned short *
moonbit_raylib_get_mesh_indices(MeshWrapper *w) {
  return w->data->indices;
}
