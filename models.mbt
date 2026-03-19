// Re-export passthrough functions from internal FFI layer

///|
pub using @ffi {draw_grid}

// ============================================================================
// 3D shape drawing (wrappers)
// ============================================================================

///|
/// Draw a line in 3D world space.
pub fn draw_line_3d(
  start_pos : Vector3,
  end_pos : Vector3,
  color : Color,
) -> Unit {
  @ffi.draw_line_3d(start_pos.to_bytes(), end_pos.to_bytes(), color.to_bytes())
}

///|
/// Draw a point in 3D space, actually a small line.
pub fn draw_point_3d(position : Vector3, color : Color) -> Unit {
  @ffi.draw_point_3d(position.to_bytes(), color.to_bytes())
}

///|
/// Draw a circle in 3D world space.
pub fn draw_circle_3d(
  center : Vector3,
  radius : Float,
  rot_axis : Vector3,
  rot_angle : Float,
  color : Color,
) -> Unit {
  @ffi.draw_circle_3d(
    center.to_bytes(),
    radius,
    rot_axis.to_bytes(),
    rot_angle,
    color.to_bytes(),
  )
}

///|
/// Draw cube.
pub fn draw_cube(
  position : Vector3,
  width : Float,
  height : Float,
  length : Float,
  color : Color,
) -> Unit {
  @ffi.draw_cube(position.to_bytes(), width, height, length, color.to_bytes())
}

///|
/// Draw cube (Vector version).
pub fn draw_cube_v(position : Vector3, size : Vector3, color : Color) -> Unit {
  @ffi.draw_cube_v(position.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
/// Draw cube wires.
pub fn draw_cube_wires(
  position : Vector3,
  width : Float,
  height : Float,
  length : Float,
  color : Color,
) -> Unit {
  @ffi.draw_cube_wires(
    position.to_bytes(),
    width,
    height,
    length,
    color.to_bytes(),
  )
}

///|
/// Draw cube wires (Vector version).
pub fn draw_cube_wires_v(
  position : Vector3,
  size : Vector3,
  color : Color,
) -> Unit {
  @ffi.draw_cube_wires_v(position.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
/// Draw sphere.
pub fn draw_sphere(center : Vector3, radius : Float, color : Color) -> Unit {
  @ffi.draw_sphere(center.to_bytes(), radius, color.to_bytes())
}

///|
/// Draw sphere with extended parameters.
pub fn draw_sphere_ex(
  center : Vector3,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Color,
) -> Unit {
  @ffi.draw_sphere_ex(
    center.to_bytes(),
    radius,
    rings,
    slices,
    color.to_bytes(),
  )
}

///|
/// Draw sphere wires.
pub fn draw_sphere_wires(
  center : Vector3,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Color,
) -> Unit {
  @ffi.draw_sphere_wires(
    center.to_bytes(),
    radius,
    rings,
    slices,
    color.to_bytes(),
  )
}

///|
/// Draw a cylinder/cone.
pub fn draw_cylinder(
  position : Vector3,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Color,
) -> Unit {
  @ffi.draw_cylinder(
    position.to_bytes(),
    radius_top,
    radius_bottom,
    height,
    slices,
    color.to_bytes(),
  )
}

///|
/// Draw a cylinder/cone wires.
pub fn draw_cylinder_wires(
  position : Vector3,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Color,
) -> Unit {
  @ffi.draw_cylinder_wires(
    position.to_bytes(),
    radius_top,
    radius_bottom,
    height,
    slices,
    color.to_bytes(),
  )
}

///|
/// Draw a color-filled triangle (vertex in counter-clockwise order!).
pub fn draw_triangle_3d(
  v1 : Vector3,
  v2 : Vector3,
  v3 : Vector3,
  color : Color,
) -> Unit {
  @ffi.draw_triangle_3d(
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    color.to_bytes(),
  )
}

///|
/// Draw a cylinder with base at startPos and top at endPos.
pub fn draw_cylinder_ex(
  start_pos : Vector3,
  end_pos : Vector3,
  start_radius : Float,
  end_radius : Float,
  sides : Int,
  color : Color,
) -> Unit {
  @ffi.draw_cylinder_ex(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    start_radius,
    end_radius,
    sides,
    color.to_bytes(),
  )
}

///|
/// Draw a cylinder wires with base at startPos and top at endPos.
pub fn draw_cylinder_wires_ex(
  start_pos : Vector3,
  end_pos : Vector3,
  start_radius : Float,
  end_radius : Float,
  sides : Int,
  color : Color,
) -> Unit {
  @ffi.draw_cylinder_wires_ex(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    start_radius,
    end_radius,
    sides,
    color.to_bytes(),
  )
}

///|
/// Draw a capsule with the center of its sphere caps at startPos and endPos.
pub fn draw_capsule(
  start_pos : Vector3,
  end_pos : Vector3,
  radius : Float,
  slices : Int,
  rings : Int,
  color : Color,
) -> Unit {
  @ffi.draw_capsule(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    radius,
    slices,
    rings,
    color.to_bytes(),
  )
}

///|
/// Draw capsule wireframe with the center of its sphere caps at startPos and endPos.
pub fn draw_capsule_wires(
  start_pos : Vector3,
  end_pos : Vector3,
  radius : Float,
  slices : Int,
  rings : Int,
  color : Color,
) -> Unit {
  @ffi.draw_capsule_wires(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    radius,
    slices,
    rings,
    color.to_bytes(),
  )
}

///|
/// Draw a plane XZ.
pub fn draw_plane(center : Vector3, size : Vector2, color : Color) -> Unit {
  @ffi.draw_plane(center.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
/// Draw a ray line.
pub fn draw_ray(ray : Ray, color : Color) -> Unit {
  @ffi.draw_ray(ray.to_bytes(), color.to_bytes())
}

///|
/// Draw bounding box (wires).
pub fn draw_bounding_box(box_ : BoundingBox, color : Color) -> Unit {
  @ffi.draw_bounding_box(box_.to_bytes(), color.to_bytes())
}

// ============================================================================
// Billboard drawing (wrappers)
// ============================================================================

///|
/// Draw a billboard texture.
pub fn draw_billboard(
  camera : Camera3D,
  texture : Texture,
  position : Vector3,
  scale : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_billboard(
    camera.to_bytes(),
    texture.0,
    position.to_bytes(),
    scale,
    tint.to_bytes(),
  )
}

///|
/// Draw a billboard texture defined by source.
pub fn draw_billboard_rec(
  camera : Camera3D,
  texture : Texture,
  source : Rectangle,
  position : Vector3,
  size : Vector2,
  tint : Color,
) -> Unit {
  @ffi.draw_billboard_rec(
    camera.to_bytes(),
    texture.0,
    source.to_bytes(),
    position.to_bytes(),
    size.to_bytes(),
    tint.to_bytes(),
  )
}

///|
/// Draw a billboard texture defined by source and rotation.
pub fn draw_billboard_pro(
  camera : Camera3D,
  texture : Texture,
  source : Rectangle,
  position : Vector3,
  up : Vector3,
  size : Vector2,
  origin : Vector2,
  rotation : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_billboard_pro(
    camera.to_bytes(),
    texture.0,
    source.to_bytes(),
    position.to_bytes(),
    up.to_bytes(),
    size.to_bytes(),
    origin.to_bytes(),
    rotation,
    tint.to_bytes(),
  )
}

// ============================================================================
// 3D collision detection (wrappers)
// ============================================================================

///|
/// Check collision between two spheres.
pub fn check_collision_spheres(
  center1 : Vector3,
  radius1 : Float,
  center2 : Vector3,
  radius2 : Float,
) -> Bool {
  @ffi.check_collision_spheres(
    center1.to_bytes(),
    radius1,
    center2.to_bytes(),
    radius2,
  )
}

///|
/// Check collision between two bounding boxes.
pub fn check_collision_boxes(box1 : BoundingBox, box2 : BoundingBox) -> Bool {
  @ffi.check_collision_boxes(box1.to_bytes(), box2.to_bytes())
}

///|
/// Check collision between box and sphere.
pub fn check_collision_box_sphere(
  box_ : BoundingBox,
  center : Vector3,
  radius : Float,
) -> Bool {
  @ffi.check_collision_box_sphere(box_.to_bytes(), center.to_bytes(), radius)
}

///|
/// Get collision info between ray and sphere.
pub fn get_ray_collision_sphere(
  ray : Ray,
  center : Vector3,
  radius : Float,
) -> RayCollision {
  RayCollision::from_bytes(
    @ffi.get_ray_collision_sphere(ray.to_bytes(), center.to_bytes(), radius),
  )
}

///|
/// Get collision info between ray and box.
pub fn get_ray_collision_box(ray : Ray, box_ : BoundingBox) -> RayCollision {
  RayCollision::from_bytes(
    @ffi.get_ray_collision_box(ray.to_bytes(), box_.to_bytes()),
  )
}

///|
/// Get collision info between ray and triangle.
pub fn get_ray_collision_triangle(
  ray : Ray,
  p1 : Vector3,
  p2 : Vector3,
  p3 : Vector3,
) -> RayCollision {
  RayCollision::from_bytes(
    @ffi.get_ray_collision_triangle(
      ray.to_bytes(),
      p1.to_bytes(),
      p2.to_bytes(),
      p3.to_bytes(),
    ),
  )
}

///|
/// Get collision info between ray and mesh.
pub fn get_ray_collision_mesh(
  ray : Ray,
  mesh : Mesh,
  transform : Matrix,
) -> RayCollision {
  RayCollision::from_bytes(
    @ffi.get_ray_collision_mesh(ray.to_bytes(), mesh.0, transform.to_bytes()),
  )
}

///|
/// Get collision info between ray and quad.
pub fn get_ray_collision_quad(
  ray : Ray,
  p1 : Vector3,
  p2 : Vector3,
  p3 : Vector3,
  p4 : Vector3,
) -> RayCollision {
  RayCollision::from_bytes(
    @ffi.get_ray_collision_quad(
      ray.to_bytes(),
      p1.to_bytes(),
      p2.to_bytes(),
      p3.to_bytes(),
      p4.to_bytes(),
    ),
  )
}

// ============================================================================
// Material map type constants
// ============================================================================

///|
/// Albedo material map type (same as diffuse).
pub const MaterialMapAlbedo : Int = 0

///|
/// Metalness material map type (same as specular).
pub const MaterialMapMetalness : Int = 1

///|
/// Normal material map type.
pub const MaterialMapNormal : Int = 2

///|
/// Roughness material map type.
pub const MaterialMapRoughness : Int = 3

///|
/// Ambient occlusion material map type.
pub const MaterialMapOcclusion : Int = 4

///|
/// Emission material map type.
pub const MaterialMapEmission : Int = 5

///|
/// Heightmap material map type.
pub const MaterialMapHeight : Int = 6

///|
/// Cubemap material map type (NOTE: Uses GL_TEXTURE_CUBE_MAP).
pub const MaterialMapCubemap : Int = 7

///|
/// Irradiance material map type (NOTE: Uses GL_TEXTURE_CUBE_MAP).
pub const MaterialMapIrradiance : Int = 8

///|
/// Prefilter material map type (NOTE: Uses GL_TEXTURE_CUBE_MAP).
pub const MaterialMapPrefilter : Int = 9

///|
/// BRDF material map type.
pub const MaterialMapBrdf : Int = 10
