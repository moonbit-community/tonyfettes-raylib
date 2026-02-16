// Re-export passthrough functions from internal FFI layer

///|
pub using @raylib {
  type Model,
  type Mesh,
  type Material,
  type ModelAnimations,
  unload_model,
  draw_grid,
  is_model_valid,
  // Mesh generation (passthrough)
  gen_mesh_poly,
  gen_mesh_plane,
  gen_mesh_cube,
  gen_mesh_sphere,
  gen_mesh_hemisphere,
  gen_mesh_cylinder,
  gen_mesh_cone,
  gen_mesh_torus,
  gen_mesh_knot,
  // Mesh utilities (passthrough)
  unload_mesh,
  upload_mesh,
  gen_mesh_tangents,
  load_model_from_mesh,
  // Material (passthrough)
  load_material_default,
  is_material_valid,
  unload_material,
  set_material_texture,
  set_model_mesh_material,
  // Model animations (passthrough)
  model_animations_count,
  update_model_animation,
  update_model_animation_bones,
  is_model_animation_valid,
  unload_model_animations,
}

// ============================================================================
// 3D shape drawing (wrappers)
// ============================================================================

///|
pub fn draw_line_3d(
  start_pos : Vector3,
  end_pos : Vector3,
  color : Color,
) -> Unit {
  @raylib.draw_line_3d(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn draw_point_3d(position : Vector3, color : Color) -> Unit {
  @raylib.draw_point_3d(position.to_bytes(), color.to_bytes())
}

///|
pub fn draw_circle_3d(
  center : Vector3,
  radius : Float,
  rot_axis : Vector3,
  rot_angle : Float,
  color : Color,
) -> Unit {
  @raylib.draw_circle_3d(
    center.to_bytes(),
    radius,
    rot_axis.to_bytes(),
    rot_angle,
    color.to_bytes(),
  )
}

///|
pub fn draw_cube(
  position : Vector3,
  width : Float,
  height : Float,
  length : Float,
  color : Color,
) -> Unit {
  @raylib.draw_cube(
    position.to_bytes(),
    width,
    height,
    length,
    color.to_bytes(),
  )
}

///|
pub fn draw_cube_v(position : Vector3, size : Vector3, color : Color) -> Unit {
  @raylib.draw_cube_v(position.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
pub fn draw_cube_wires(
  position : Vector3,
  width : Float,
  height : Float,
  length : Float,
  color : Color,
) -> Unit {
  @raylib.draw_cube_wires(
    position.to_bytes(),
    width,
    height,
    length,
    color.to_bytes(),
  )
}

///|
pub fn draw_cube_wires_v(
  position : Vector3,
  size : Vector3,
  color : Color,
) -> Unit {
  @raylib.draw_cube_wires_v(
    position.to_bytes(),
    size.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn draw_sphere(center : Vector3, radius : Float, color : Color) -> Unit {
  @raylib.draw_sphere(center.to_bytes(), radius, color.to_bytes())
}

///|
pub fn draw_sphere_ex(
  center : Vector3,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Color,
) -> Unit {
  @raylib.draw_sphere_ex(
    center.to_bytes(),
    radius,
    rings,
    slices,
    color.to_bytes(),
  )
}

///|
pub fn draw_sphere_wires(
  center : Vector3,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Color,
) -> Unit {
  @raylib.draw_sphere_wires(
    center.to_bytes(),
    radius,
    rings,
    slices,
    color.to_bytes(),
  )
}

///|
pub fn draw_cylinder(
  position : Vector3,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Color,
) -> Unit {
  @raylib.draw_cylinder(
    position.to_bytes(),
    radius_top,
    radius_bottom,
    height,
    slices,
    color.to_bytes(),
  )
}

///|
pub fn draw_cylinder_wires(
  position : Vector3,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Color,
) -> Unit {
  @raylib.draw_cylinder_wires(
    position.to_bytes(),
    radius_top,
    radius_bottom,
    height,
    slices,
    color.to_bytes(),
  )
}

///|
pub fn draw_triangle_3d(
  v1 : Vector3,
  v2 : Vector3,
  v3 : Vector3,
  color : Color,
) -> Unit {
  @raylib.draw_triangle_3d(
    v1.to_bytes(),
    v2.to_bytes(),
    v3.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn draw_cylinder_ex(
  start_pos : Vector3,
  end_pos : Vector3,
  start_radius : Float,
  end_radius : Float,
  sides : Int,
  color : Color,
) -> Unit {
  @raylib.draw_cylinder_ex(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    start_radius,
    end_radius,
    sides,
    color.to_bytes(),
  )
}

///|
pub fn draw_cylinder_wires_ex(
  start_pos : Vector3,
  end_pos : Vector3,
  start_radius : Float,
  end_radius : Float,
  sides : Int,
  color : Color,
) -> Unit {
  @raylib.draw_cylinder_wires_ex(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    start_radius,
    end_radius,
    sides,
    color.to_bytes(),
  )
}

///|
pub fn draw_capsule(
  start_pos : Vector3,
  end_pos : Vector3,
  radius : Float,
  slices : Int,
  rings : Int,
  color : Color,
) -> Unit {
  @raylib.draw_capsule(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    radius,
    slices,
    rings,
    color.to_bytes(),
  )
}

///|
pub fn draw_capsule_wires(
  start_pos : Vector3,
  end_pos : Vector3,
  radius : Float,
  slices : Int,
  rings : Int,
  color : Color,
) -> Unit {
  @raylib.draw_capsule_wires(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    radius,
    slices,
    rings,
    color.to_bytes(),
  )
}

///|
pub fn draw_plane(center : Vector3, size : Vector2, color : Color) -> Unit {
  @raylib.draw_plane(center.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
pub fn draw_ray(ray : Ray, color : Color) -> Unit {
  @raylib.draw_ray(ray.to_bytes(), color.to_bytes())
}

///|
pub fn draw_bounding_box(box_ : BoundingBox, color : Color) -> Unit {
  @raylib.draw_bounding_box(box_.to_bytes(), color.to_bytes())
}

// ============================================================================
// Model loading (wrappers)
// ============================================================================

///|
pub fn load_model(file_name : String) -> Model {
  @raylib.load_model(@utf8.encode(file_name))
}

///|
pub fn draw_model(
  model : Model,
  position : Vector3,
  scale : Float,
  tint : Color,
) -> Unit {
  @raylib.draw_model(model, position.to_bytes(), scale, tint.to_bytes())
}

///|
pub fn draw_model_ex(
  model : Model,
  position : Vector3,
  rotation_axis : Vector3,
  rotation_angle : Float,
  scale : Vector3,
  tint : Color,
) -> Unit {
  @raylib.draw_model_ex(
    model,
    position.to_bytes(),
    rotation_axis.to_bytes(),
    rotation_angle,
    scale.to_bytes(),
    tint.to_bytes(),
  )
}

///|
pub fn draw_model_wires(
  model : Model,
  position : Vector3,
  scale : Float,
  tint : Color,
) -> Unit {
  @raylib.draw_model_wires(model, position.to_bytes(), scale, tint.to_bytes())
}

///|
pub fn draw_model_wires_ex(
  model : Model,
  position : Vector3,
  rotation_axis : Vector3,
  rotation_angle : Float,
  scale : Vector3,
  tint : Color,
) -> Unit {
  @raylib.draw_model_wires_ex(
    model,
    position.to_bytes(),
    rotation_axis.to_bytes(),
    rotation_angle,
    scale.to_bytes(),
    tint.to_bytes(),
  )
}

///|
pub fn draw_model_points(
  model : Model,
  position : Vector3,
  scale : Float,
  tint : Color,
) -> Unit {
  @raylib.draw_model_points(model, position.to_bytes(), scale, tint.to_bytes())
}

///|
pub fn draw_model_points_ex(
  model : Model,
  position : Vector3,
  rotation_axis : Vector3,
  rotation_angle : Float,
  scale : Vector3,
  tint : Color,
) -> Unit {
  @raylib.draw_model_points_ex(
    model,
    position.to_bytes(),
    rotation_axis.to_bytes(),
    rotation_angle,
    scale.to_bytes(),
    tint.to_bytes(),
  )
}

// ============================================================================
// Model material shader (wrappers)
// ============================================================================

///|
pub fn set_model_material_shader(
  model : Model,
  material_index : Int,
  shader : Shader,
) -> Unit {
  @raylib.set_model_material_shader(model, material_index, shader)
}

// ============================================================================
// Model management (wrappers)
// ============================================================================

///|
pub fn get_model_bounding_box(model : Model) -> BoundingBox {
  BoundingBox::from_bytes(@raylib.get_model_bounding_box(model))
}

// ============================================================================
// Model material texture (wrappers)
// ============================================================================

///|
pub fn set_model_material_texture(
  model : Model,
  material_index : Int,
  map_type : Int,
  texture : Texture,
) -> Unit {
  @raylib.set_model_material_texture(model, material_index, map_type, texture)
}

// ============================================================================
// Billboard drawing (wrappers)
// ============================================================================

///|
pub fn draw_billboard(
  camera : Camera3D,
  texture : Texture,
  position : Vector3,
  scale : Float,
  tint : Color,
) -> Unit {
  @raylib.draw_billboard(
    camera.to_bytes(),
    texture,
    position.to_bytes(),
    scale,
    tint.to_bytes(),
  )
}

///|
pub fn draw_billboard_rec(
  camera : Camera3D,
  texture : Texture,
  source : Rectangle,
  position : Vector3,
  size : Vector2,
  tint : Color,
) -> Unit {
  @raylib.draw_billboard_rec(
    camera.to_bytes(),
    texture,
    source.to_bytes(),
    position.to_bytes(),
    size.to_bytes(),
    tint.to_bytes(),
  )
}

///|
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
  @raylib.draw_billboard_pro(
    camera.to_bytes(),
    texture,
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
pub fn check_collision_spheres(
  center1 : Vector3,
  radius1 : Float,
  center2 : Vector3,
  radius2 : Float,
) -> Bool {
  @raylib.check_collision_spheres(
    center1.to_bytes(),
    radius1,
    center2.to_bytes(),
    radius2,
  )
}

///|
pub fn check_collision_boxes(box1 : BoundingBox, box2 : BoundingBox) -> Bool {
  @raylib.check_collision_boxes(box1.to_bytes(), box2.to_bytes())
}

///|
pub fn check_collision_box_sphere(
  box_ : BoundingBox,
  center : Vector3,
  radius : Float,
) -> Bool {
  @raylib.check_collision_box_sphere(box_.to_bytes(), center.to_bytes(), radius)
}

///|
pub fn get_ray_collision_sphere(
  ray : Ray,
  center : Vector3,
  radius : Float,
) -> RayCollision {
  RayCollision::from_bytes(
    @raylib.get_ray_collision_sphere(ray.to_bytes(), center.to_bytes(), radius),
  )
}

///|
pub fn get_ray_collision_box(ray : Ray, box_ : BoundingBox) -> RayCollision {
  RayCollision::from_bytes(
    @raylib.get_ray_collision_box(ray.to_bytes(), box_.to_bytes()),
  )
}

///|
pub fn get_ray_collision_triangle(
  ray : Ray,
  p1 : Vector3,
  p2 : Vector3,
  p3 : Vector3,
) -> RayCollision {
  RayCollision::from_bytes(
    @raylib.get_ray_collision_triangle(
      ray.to_bytes(),
      p1.to_bytes(),
      p2.to_bytes(),
      p3.to_bytes(),
    ),
  )
}

// ============================================================================
// Mesh generation (wrappers)
// ============================================================================

///|
pub fn gen_mesh_heightmap(heightmap : Image, size : Vector3) -> Mesh {
  @raylib.gen_mesh_heightmap(heightmap, size.to_bytes())
}

///|
pub fn gen_mesh_cubicmap(cubicmap : Image, cube_size : Vector3) -> Mesh {
  @raylib.gen_mesh_cubicmap(cubicmap, cube_size.to_bytes())
}

// ============================================================================
// Mesh utilities (wrappers)
// ============================================================================

///|
pub fn get_mesh_bounding_box(mesh : Mesh) -> BoundingBox {
  BoundingBox::from_bytes(@raylib.get_mesh_bounding_box(mesh))
}

///|
pub fn export_mesh(mesh : Mesh, file_name : String) -> Bool {
  @raylib.export_mesh(mesh, @utf8.encode(file_name))
}

///|
pub fn get_ray_collision_mesh(
  ray : Ray,
  mesh : Mesh,
  transform : Matrix,
) -> RayCollision {
  RayCollision::from_bytes(
    @raylib.get_ray_collision_mesh(ray.to_bytes(), mesh, transform.to_bytes()),
  )
}

// ============================================================================
// Mesh drawing (wrappers)
// ============================================================================

///|
pub fn draw_mesh(mesh : Mesh, material : Material, transform : Matrix) -> Unit {
  @raylib.draw_mesh(mesh, material, transform.to_bytes())
}

///|
pub fn draw_mesh_instanced(
  mesh : Mesh,
  material : Material,
  transforms : Array[Matrix],
  instances : Int,
) -> Unit {
  let arr = FixedArray::make(instances * 64, b'\x00')
  for i in 0..<instances {
    let m = transforms[i].to_bytes()
    arr.blit_from_bytes(i * 64, m, 0, 64)
  }
  let buf = FixedArray::unsafe_reinterpret_as_bytes(arr)
  @raylib.draw_mesh_instanced(mesh, material, buf, instances)
}

// ============================================================================
// Material map type constants
// ============================================================================

///|
pub let material_map_albedo : Int = 0

///|
pub let material_map_metalness : Int = 1

///|
pub let material_map_normal : Int = 2

///|
pub let material_map_roughness : Int = 3

///|
pub let material_map_occlusion : Int = 4

///|
pub let material_map_emission : Int = 5

///|
pub let material_map_height : Int = 6

// ============================================================================
// Model animations (wrappers)
// ============================================================================

///|
pub fn load_model_animations(file_name : String) -> ModelAnimations {
  @raylib.load_model_animations(@utf8.encode(file_name))
}

// ============================================================================
// Ray collision: quad (wrapper)
// ============================================================================

///|
pub fn get_ray_collision_quad(
  ray : Ray,
  p1 : Vector3,
  p2 : Vector3,
  p3 : Vector3,
  p4 : Vector3,
) -> RayCollision {
  RayCollision::from_bytes(
    @raylib.get_ray_collision_quad(
      ray.to_bytes(),
      p1.to_bytes(),
      p2.to_bytes(),
      p3.to_bytes(),
      p4.to_bytes(),
    ),
  )
}

// ============================================================================
// Mesh: Export as code (wrappers)
// ============================================================================

///|
pub fn export_mesh_as_code(mesh : Mesh, file_name : String) -> Bool {
  @raylib.export_mesh_as_code(mesh, @utf8.encode(file_name))
}

// ============================================================================
// Mesh: UpdateMeshBuffer (re-export)
// ============================================================================

///|
pub using @raylib {update_mesh_buffer}

// ============================================================================
// LoadMaterials (wrappers)
// ============================================================================

///|
pub using @raylib {
  type MaterialsArray,
  unload_materials_array,
  materials_array_count,
  materials_array_get,
}

///|
pub fn load_materials(file_name : String) -> MaterialsArray {
  @raylib.load_materials(@utf8.encode(file_name))
}
