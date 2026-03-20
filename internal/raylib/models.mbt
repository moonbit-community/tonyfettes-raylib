// ============================================================================
// 3D shape drawing
// ============================================================================

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_line_3d(
  start_pos : Bytes,
  end_pos : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_line_3d"

///|
#borrow(position, color)
pub extern "c" fn draw_point_3d(position : Bytes, color : Bytes) = "moonbit_raylib_draw_point_3d"

///|
#borrow(center, rot_axis, color)
pub extern "c" fn draw_circle_3d(
  center : Bytes,
  radius : Float,
  rot_axis : Bytes,
  rot_angle : Float,
  color : Bytes,
) = "moonbit_raylib_draw_circle_3d"

///|
#borrow(position, color)
pub extern "c" fn draw_cube(
  position : Bytes,
  width : Float,
  height : Float,
  length : Float,
  color : Bytes,
) = "moonbit_raylib_draw_cube"

///|
#borrow(position, size, color)
pub extern "c" fn draw_cube_v(position : Bytes, size : Bytes, color : Bytes) = "moonbit_raylib_draw_cube_v"

///|
#borrow(position, color)
pub extern "c" fn draw_cube_wires(
  position : Bytes,
  width : Float,
  height : Float,
  length : Float,
  color : Bytes,
) = "moonbit_raylib_draw_cube_wires"

///|
#borrow(position, size, color)
pub extern "c" fn draw_cube_wires_v(
  position : Bytes,
  size : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_cube_wires_v"

///|
#borrow(center, color)
pub extern "c" fn draw_sphere(center : Bytes, radius : Float, color : Bytes) = "moonbit_raylib_draw_sphere"

///|
#borrow(center, color)
pub extern "c" fn draw_sphere_ex(
  center : Bytes,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_sphere_ex"

///|
#borrow(center, color)
pub extern "c" fn draw_sphere_wires(
  center : Bytes,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_sphere_wires"

///|
#borrow(position, color)
pub extern "c" fn draw_cylinder(
  position : Bytes,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_cylinder"

///|
#borrow(position, color)
pub extern "c" fn draw_cylinder_wires(
  position : Bytes,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_cylinder_wires"

///|
#borrow(v1, v2, v3, color)
pub extern "c" fn draw_triangle_3d(
  v1 : Bytes,
  v2 : Bytes,
  v3 : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_triangle_3d"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_cylinder_ex(
  start_pos : Bytes,
  end_pos : Bytes,
  start_radius : Float,
  end_radius : Float,
  sides : Int,
  color : Bytes,
) = "moonbit_raylib_draw_cylinder_ex"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_cylinder_wires_ex(
  start_pos : Bytes,
  end_pos : Bytes,
  start_radius : Float,
  end_radius : Float,
  sides : Int,
  color : Bytes,
) = "moonbit_raylib_draw_cylinder_wires_ex"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_capsule(
  start_pos : Bytes,
  end_pos : Bytes,
  radius : Float,
  slices : Int,
  rings : Int,
  color : Bytes,
) = "moonbit_raylib_draw_capsule"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_capsule_wires(
  start_pos : Bytes,
  end_pos : Bytes,
  radius : Float,
  slices : Int,
  rings : Int,
  color : Bytes,
) = "moonbit_raylib_draw_capsule_wires"

///|
#borrow(center, size, color)
pub extern "c" fn draw_plane(center : Bytes, size : Bytes, color : Bytes) = "moonbit_raylib_draw_plane"

///|
#borrow(ray, color)
pub extern "c" fn draw_ray(ray : Bytes, color : Bytes) = "moonbit_raylib_draw_ray"

///|
/// Draw a grid (centered at (0, 0, 0)).
pub extern "c" fn draw_grid(slices : Int, spacing : Float) = "DrawGrid"

///|
#borrow(box_, color)
pub extern "c" fn draw_bounding_box(box_ : Bytes, color : Bytes) = "moonbit_raylib_draw_bounding_box"

// ============================================================================
// Model loading
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_model(file_name : Bytes) -> Model = "moonbit_raylib_load_model"

///|
#borrow(model)
pub extern "c" fn unload_model(model : Model) = "moonbit_raylib_unload_model"

///|
#borrow(model, position, tint)
pub extern "c" fn draw_model(
  model : Model,
  position : Bytes,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_model"

///|
#borrow(model, position, rotation_axis, scale, tint)
pub extern "c" fn draw_model_ex(
  model : Model,
  position : Bytes,
  rotation_axis : Bytes,
  rotation_angle : Float,
  scale : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_model_ex"

///|
#borrow(model, position, tint)
pub extern "c" fn draw_model_wires(
  model : Model,
  position : Bytes,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_model_wires"

///|
#borrow(model, position, rotation_axis, scale, tint)
pub extern "c" fn draw_model_wires_ex(
  model : Model,
  position : Bytes,
  rotation_axis : Bytes,
  rotation_angle : Float,
  scale : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_model_wires_ex"

///|
#borrow(model, position, tint)
pub extern "c" fn draw_model_points(
  model : Model,
  position : Bytes,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_model_points"

///|
#borrow(model, position, rotation_axis, scale, tint)
pub extern "c" fn draw_model_points_ex(
  model : Model,
  position : Bytes,
  rotation_axis : Bytes,
  rotation_angle : Float,
  scale : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_model_points_ex"

// ============================================================================
// Model management
// ============================================================================

///|
#borrow(model)
pub extern "c" fn is_model_valid(model : Model) -> Bool = "moonbit_raylib_is_model_valid"

///|
#borrow(model)
pub extern "c" fn get_model_bounding_box(model : Model) -> Bytes = "moonbit_raylib_get_model_bounding_box"

// ============================================================================
// Billboard drawing
// ============================================================================

///|
#borrow(camera, texture, position, tint)
pub extern "c" fn draw_billboard(
  camera : Bytes,
  texture : Texture,
  position : Bytes,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_billboard"

///|
#borrow(camera, texture, source, position, size, tint)
pub extern "c" fn draw_billboard_rec(
  camera : Bytes,
  texture : Texture,
  source : Bytes,
  position : Bytes,
  size : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_billboard_rec"

///|
#borrow(camera, texture, source, position, up, size, origin, tint)
pub extern "c" fn draw_billboard_pro(
  camera : Bytes,
  texture : Texture,
  source : Bytes,
  position : Bytes,
  up : Bytes,
  size : Bytes,
  origin : Bytes,
  rotation : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_billboard_pro"

// ============================================================================
// 3D collision detection
// ============================================================================

///|
#borrow(center1, center2)
pub extern "c" fn check_collision_spheres(
  center1 : Bytes,
  radius1 : Float,
  center2 : Bytes,
  radius2 : Float,
) -> Bool = "moonbit_raylib_check_collision_spheres"

///|
#borrow(box1, box2)
pub extern "c" fn check_collision_boxes(box1 : Bytes, box2 : Bytes) -> Bool = "moonbit_raylib_check_collision_boxes"

///|
#borrow(box_, center)
pub extern "c" fn check_collision_box_sphere(
  box_ : Bytes,
  center : Bytes,
  radius : Float,
) -> Bool = "moonbit_raylib_check_collision_box_sphere"

///|
#borrow(ray, center)
pub extern "c" fn get_ray_collision_sphere(
  ray : Bytes,
  center : Bytes,
  radius : Float,
) -> Bytes = "moonbit_raylib_get_ray_collision_sphere"

///|
#borrow(ray, box_)
pub extern "c" fn get_ray_collision_box(ray : Bytes, box_ : Bytes) -> Bytes = "moonbit_raylib_get_ray_collision_box"

///|
#borrow(ray, p1, p2, p3)
pub extern "c" fn get_ray_collision_triangle(
  ray : Bytes,
  p1 : Bytes,
  p2 : Bytes,
  p3 : Bytes,
) -> Bytes = "moonbit_raylib_get_ray_collision_triangle"

// ============================================================================
// Mesh generation
// ============================================================================

///|
pub extern "c" fn gen_mesh_poly(sides : Int, radius : Float) -> Mesh = "moonbit_raylib_gen_mesh_poly"

///|
pub extern "c" fn gen_mesh_plane(
  width : Float,
  length : Float,
  res_x : Int,
  res_z : Int,
) -> Mesh = "moonbit_raylib_gen_mesh_plane"

///|
pub extern "c" fn gen_mesh_cube(
  width : Float,
  height : Float,
  length : Float,
) -> Mesh = "moonbit_raylib_gen_mesh_cube"

///|
pub extern "c" fn gen_mesh_sphere(
  radius : Float,
  rings : Int,
  slices : Int,
) -> Mesh = "moonbit_raylib_gen_mesh_sphere"

///|
pub extern "c" fn gen_mesh_hemisphere(
  radius : Float,
  rings : Int,
  slices : Int,
) -> Mesh = "moonbit_raylib_gen_mesh_hemisphere"

///|
pub extern "c" fn gen_mesh_cylinder(
  radius : Float,
  height : Float,
  slices : Int,
) -> Mesh = "moonbit_raylib_gen_mesh_cylinder"

///|
pub extern "c" fn gen_mesh_cone(
  radius : Float,
  height : Float,
  slices : Int,
) -> Mesh = "moonbit_raylib_gen_mesh_cone"

///|
pub extern "c" fn gen_mesh_torus(
  radius : Float,
  size : Float,
  rad_seg : Int,
  sides : Int,
) -> Mesh = "moonbit_raylib_gen_mesh_torus"

///|
pub extern "c" fn gen_mesh_knot(
  radius : Float,
  size : Float,
  rad_seg : Int,
  sides : Int,
) -> Mesh = "moonbit_raylib_gen_mesh_knot"

///|
#borrow(heightmap, size)
pub extern "c" fn gen_mesh_heightmap(heightmap : Image, size : Bytes) -> Mesh = "moonbit_raylib_gen_mesh_heightmap"

///|
#borrow(cubicmap, cube_size)
pub extern "c" fn gen_mesh_cubicmap(
  cubicmap : Image,
  cube_size : Bytes,
) -> Mesh = "moonbit_raylib_gen_mesh_cubicmap"

// ============================================================================
// Mesh utilities
// ============================================================================

///|
#borrow(mesh)
pub extern "c" fn unload_mesh(mesh : Mesh) = "moonbit_raylib_unload_mesh"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_bounding_box(mesh : Mesh) -> Bytes = "moonbit_raylib_get_mesh_bounding_box"

///|
#borrow(mesh, file_name)
pub extern "c" fn export_mesh(mesh : Mesh, file_name : Bytes) -> Bool = "moonbit_raylib_export_mesh"

///|
#borrow(mesh)
pub extern "c" fn upload_mesh(mesh : Mesh, dynamic : Int) = "moonbit_raylib_upload_mesh"

///|
#borrow(mesh)
pub extern "c" fn gen_mesh_tangents(mesh : Mesh) = "moonbit_raylib_gen_mesh_tangents"

///|
#borrow(ray, mesh, transform)
pub extern "c" fn get_ray_collision_mesh(
  ray : Bytes,
  mesh : Mesh,
  transform : Bytes,
) -> Bytes = "moonbit_raylib_get_ray_collision_mesh"

///|
#borrow(mesh)
pub extern "c" fn load_model_from_mesh(mesh : Mesh) -> Model = "moonbit_raylib_load_model_from_mesh"

// ============================================================================
// Material management
// ============================================================================

///|
pub extern "c" fn load_material_default() -> Material = "moonbit_raylib_load_material_default"

///|
#borrow(material)
pub extern "c" fn is_material_valid(material : Material) -> Bool = "moonbit_raylib_is_material_valid"

///|
#borrow(material)
pub extern "c" fn unload_material(material : Material) = "moonbit_raylib_unload_material"

///|
#borrow(material, texture)
pub extern "c" fn set_material_texture(
  material : Material,
  map_type : Int,
  texture : Texture,
) = "moonbit_raylib_set_material_texture"

///|
#borrow(material, shader)
pub extern "c" fn set_material_shader(material : Material, shader : Shader) = "moonbit_raylib_set_material_shader"

///|
#borrow(material, color)
pub extern "c" fn set_material_map_color(
  material : Material,
  map_type : Int,
  color : Bytes,
) = "moonbit_raylib_set_material_map_color"

///|
#borrow(material)
pub extern "c" fn set_material_map_value(
  material : Material,
  map_type : Int,
  value : Float,
) = "moonbit_raylib_set_material_map_value"

///|
#borrow(model)
pub extern "c" fn set_model_mesh_material(
  model : Model,
  mesh_id : Int,
  material_id : Int,
) = "moonbit_raylib_set_model_mesh_material"

///|
#borrow(model, texture)
pub extern "c" fn set_model_material_texture(
  model : Model,
  material_index : Int,
  map_type : Int,
  texture : Texture,
) = "moonbit_raylib_set_model_material_texture"

///|
#borrow(model, shader)
pub extern "c" fn set_model_material_shader(
  model : Model,
  material_index : Int,
  shader : Shader,
) = "moonbit_raylib_set_model_material_shader"
// ============================================================================
// Mesh drawing
// ============================================================================

///|
#borrow(mesh, material, transform)
pub extern "c" fn draw_mesh(
  mesh : Mesh,
  material : Material,
  transform : Bytes,
) = "moonbit_raylib_draw_mesh"

///|
#borrow(mesh, material, transforms)
pub extern "c" fn draw_mesh_instanced(
  mesh : Mesh,
  material : Material,
  transforms : Bytes,
  instances : Int,
) = "moonbit_raylib_draw_mesh_instanced"

// ============================================================================
// Model animations
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_model_animations(file_name : Bytes) -> ModelAnimations = "moonbit_raylib_load_model_animations"

///|
#borrow(anims)
pub extern "c" fn model_animations_count(anims : ModelAnimations) -> Int = "moonbit_raylib_model_animations_count"

///|
#borrow(model, anims)
pub extern "c" fn update_model_animation(
  model : Model,
  anims : ModelAnimations,
  index : Int,
  frame : Int,
) = "moonbit_raylib_update_model_animation"

///|
#borrow(model, anims)
pub extern "c" fn update_model_animation_bones(
  model : Model,
  anims : ModelAnimations,
  index : Int,
  frame : Int,
) = "moonbit_raylib_update_model_animation_bones"

///|
#borrow(model, anims)
pub extern "c" fn is_model_animation_valid(
  model : Model,
  anims : ModelAnimations,
  index : Int,
) -> Bool = "moonbit_raylib_is_model_animation_valid"

///|
#borrow(anims)
pub extern "c" fn unload_model_animations(anims : ModelAnimations) = "moonbit_raylib_unload_model_animations"

// ============================================================================
// Ray collision: quad
// ============================================================================

///|
#borrow(ray, p1, p2, p3, p4)
pub extern "c" fn get_ray_collision_quad(
  ray : Bytes,
  p1 : Bytes,
  p2 : Bytes,
  p3 : Bytes,
  p4 : Bytes,
) -> Bytes = "moonbit_raylib_get_ray_collision_quad"

// ============================================================================
// Mesh: Export as code
// ============================================================================

///|
#borrow(mesh, file_name)
pub extern "c" fn export_mesh_as_code(mesh : Mesh, file_name : Bytes) -> Bool = "moonbit_raylib_export_mesh_as_code"

// ============================================================================
// Mesh: UpdateMeshBuffer
// ============================================================================

///|
#borrow(mesh, data)
pub extern "c" fn update_mesh_buffer(
  mesh : Mesh,
  index : Int,
  data : Bytes,
  data_size : Int,
  offset : Int,
) = "moonbit_raylib_update_mesh_buffer"

// ============================================================================
// LoadMaterials
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_materials(file_name : Bytes) -> MaterialsArray = "moonbit_raylib_load_materials"

///|
#borrow(materials)
pub extern "c" fn unload_materials_array(materials : MaterialsArray) = "moonbit_raylib_unload_materials_array"

///|
#borrow(materials)
pub extern "c" fn materials_array_count(materials : MaterialsArray) -> Int = "moonbit_raylib_materials_array_count"

///|
#borrow(materials)
pub extern "c" fn materials_array_get(
  materials : MaterialsArray,
  index : Int,
) -> Material = "moonbit_raylib_materials_array_get"

// ============================================================================
// Model: set transform
// ============================================================================

///|
#borrow(model, transform)
pub extern "c" fn set_model_transform(model : Model, transform : Bytes) = "moonbit_raylib_set_model_transform"

// ============================================================================
// Model: get mesh count
// ============================================================================

///|
#borrow(model)
pub extern "c" fn get_model_mesh_count(model : Model) -> Int = "moonbit_raylib_get_model_mesh_count"

// ============================================================================
// Model: get mesh by index
// ============================================================================

///|
#borrow(model)
pub extern "c" fn get_model_mesh(model : Model, index : Int) -> Mesh = "moonbit_raylib_get_model_mesh"

// ============================================================================
// Model: get transform
// ============================================================================

///|
#borrow(model)
pub extern "c" fn get_model_transform(model : Model) -> Bytes = "moonbit_raylib_get_model_transform"

///|
#borrow(model)
pub extern "c" fn get_model_material_count(model : Model) -> Int = "moonbit_raylib_get_model_material_count"

///|
#borrow(model)
pub extern "c" fn get_model_material(model : Model, index : Int) -> Material = "moonbit_raylib_get_model_material"

///|
#borrow(model)
pub extern "c" fn get_model_bone_count(model : Model) -> Int = "moonbit_raylib_get_model_bone_count"

///|
#borrow(model)
pub extern "c" fn get_model_bone_parent(model : Model, bone_index : Int) -> Int = "moonbit_raylib_get_model_bone_parent"

///|
#borrow(model)
pub extern "c" fn get_model_bind_pose_translation(
  model : Model,
  bone_index : Int,
) -> Bytes = "moonbit_raylib_get_model_bind_pose_translation"

///|
#borrow(anims)
pub extern "c" fn get_model_animation_frame_count(
  anims : ModelAnimations,
  anim_index : Int,
) -> Int = "moonbit_raylib_get_model_animation_frame_count"

///|
#borrow(anims)
pub extern "c" fn get_model_animation_bone_count(
  anims : ModelAnimations,
  anim_index : Int,
) -> Int = "moonbit_raylib_get_model_animation_bone_count"

///|
#borrow(anims)
pub extern "c" fn get_model_animation_bone_parent(
  anims : ModelAnimations,
  anim_index : Int,
  bone_index : Int,
) -> Int = "moonbit_raylib_get_model_animation_bone_parent"

///|
#borrow(anims)
pub extern "c" fn get_model_animation_frame_pose_translation(
  anims : ModelAnimations,
  anim_index : Int,
  frame : Int,
  bone_index : Int,
) -> Bytes = "moonbit_raylib_get_model_animation_frame_pose_translation"

///|
#borrow(anims)
pub extern "c" fn get_model_animation_frame_pose_rotation(
  anims : ModelAnimations,
  anim_index : Int,
  frame : Int,
  bone_index : Int,
) -> Bytes = "moonbit_raylib_get_model_animation_frame_pose_rotation"

///|
#borrow(model)
pub extern "c" fn get_model_bone_name(model : Model, bone_index : Int) -> Bytes = "moonbit_raylib_get_model_bone_name"

///|
#borrow(model)
pub extern "c" fn get_model_bind_pose_rotation(
  model : Model,
  bone_index : Int,
) -> Bytes = "moonbit_raylib_get_model_bind_pose_rotation"

// ============================================================================
// Mesh: Generate point cloud from vertex+color data
// ============================================================================

///|
#borrow(vertices, colors)
pub extern "c" fn gen_mesh_from_points(
  vertices : Bytes,
  colors : Bytes,
  num_points : Int,
) -> Mesh = "moonbit_raylib_gen_mesh_from_points"

// ============================================================================
// FloatPointer operations (#external — raw float*)
// ============================================================================

///|
pub extern "c" fn float_array_is_null(arr : FloatPointer) -> Bool = "moonbit_raylib_float_array_is_null"

///|
pub extern "c" fn float_array_get(arr : FloatPointer, index : Int) -> Float = "moonbit_raylib_float_array_get"

///|
pub extern "c" fn float_array_set(
  arr : FloatPointer,
  index : Int,
  value : Float,
) = "moonbit_raylib_float_array_set"

// ============================================================================
// UBytePointer operations (#external — raw unsigned char*)
// ============================================================================

///|
pub extern "c" fn ubyte_array_is_null(arr : UBytePointer) -> Bool = "moonbit_raylib_ubyte_array_is_null"

///|
pub extern "c" fn ubyte_array_get(arr : UBytePointer, index : Int) -> Int = "moonbit_raylib_ubyte_array_get"

///|
pub extern "c" fn ubyte_array_set(
  arr : UBytePointer,
  index : Int,
  value : Byte,
) = "moonbit_raylib_ubyte_array_set"

// ============================================================================
// UShortPointer operations (#external — raw unsigned short*)
// ============================================================================

///|
pub extern "c" fn ushort_array_is_null(arr : UShortPointer) -> Bool = "moonbit_raylib_ushort_array_is_null"

///|
pub extern "c" fn ushort_array_get(arr : UShortPointer, index : Int) -> Int = "moonbit_raylib_ushort_array_get"

///|
pub extern "c" fn ushort_array_set(
  arr : UShortPointer,
  index : Int,
  value : UInt16,
) = "moonbit_raylib_ushort_array_set"

// ============================================================================
// ShortPointer operations (#external — raw short*)
// ============================================================================

///|
pub extern "c" fn short_array_is_null(arr : ShortPointer) -> Bool = "moonbit_raylib_short_array_is_null"

///|
pub extern "c" fn short_array_get(arr : ShortPointer, index : Int) -> Int = "moonbit_raylib_short_array_get"

///|
pub extern "c" fn short_array_set(arr : ShortPointer, index : Int, value : Int) = "moonbit_raylib_short_array_set"

// ============================================================================
// MatrixArray operations (#external — raw Matrix*)
// ============================================================================

///|
pub extern "c" fn matrix_array_is_null(arr : MatrixArray) -> Bool = "moonbit_raylib_matrix_array_is_null"

///|
pub extern "c" fn matrix_array_op_get(arr : MatrixArray, index : Int) -> Bytes = "moonbit_raylib_matrix_array_op_get"

///|
#borrow(value)
pub extern "c" fn matrix_array_op_set(
  arr : MatrixArray,
  index : Int,
  value : Bytes,
) = "moonbit_raylib_matrix_array_op_set"

// ============================================================================
// MaterialMapArray operations (#external — raw MaterialMap*)
// ============================================================================

///|
pub extern "c" fn material_map_array_is_null(arr : MaterialMapArray) -> Bool = "moonbit_raylib_material_map_array_is_null"

///|
pub extern "c" fn material_map_array_op_get(
  arr : MaterialMapArray,
  index : Int,
) -> MaterialMap = "moonbit_raylib_material_map_array_op_get"

///|
#borrow(value)
pub extern "c" fn material_map_array_op_set(
  arr : MaterialMapArray,
  index : Int,
  value : MaterialMap,
) = "moonbit_raylib_material_map_array_op_set"

// ============================================================================
// MaterialMap field accessors
// ============================================================================

///|
#borrow(map)
pub extern "c" fn material_map_get_texture(map : MaterialMap) -> Texture = "moonbit_raylib_material_map_get_texture"

///|
#borrow(map, texture)
pub extern "c" fn material_map_set_texture(
  map : MaterialMap,
  texture : Texture,
) = "moonbit_raylib_material_map_set_texture"

///|
#borrow(map)
pub extern "c" fn material_map_get_color(map : MaterialMap) -> Bytes = "moonbit_raylib_material_map_get_color"

///|
#borrow(map, color)
pub extern "c" fn material_map_set_color(map : MaterialMap, color : Bytes) = "moonbit_raylib_material_map_set_color"

///|
#borrow(map)
pub extern "c" fn material_map_get_value(map : MaterialMap) -> Float = "moonbit_raylib_material_map_get_value"

///|
#borrow(map)
pub extern "c" fn material_map_set_value(map : MaterialMap, value : Float) = "moonbit_raylib_material_map_set_value"

// ============================================================================
// Material: shader and maps accessors
// ============================================================================

///|
#borrow(material)
pub extern "c" fn get_material_shader(material : Material) -> Shader = "moonbit_raylib_get_material_shader"

///|
#borrow(material)
pub extern "c" fn get_material_maps(material : Material) -> MaterialMapArray = "moonbit_raylib_get_material_maps"

// ============================================================================
// Mesh: bone matrices accessor
// ============================================================================

///|
#borrow(mesh)
pub extern "c" fn get_mesh_bone_count(mesh : Mesh) -> Int = "moonbit_raylib_get_mesh_bone_count"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_bone_matrices(mesh : Mesh) -> MatrixArray = "moonbit_raylib_get_mesh_bone_matrices"

// ============================================================================
// Mesh: constructor and attribute accessors
// ============================================================================

///|
#borrow(vertices, texcoords, texcoords2, normals, tangents, colors, indices)
pub extern "c" fn new_mesh(
  vertex_count : Int,
  triangle_count : Int,
  vertices : FixedArray[Float],
  texcoords : FixedArray[Float]?,
  texcoords2 : FixedArray[Float]?,
  normals : FixedArray[Float]?,
  tangents : FixedArray[Float]?,
  colors : FixedArray[Byte]?,
  indices : FixedArray[UInt16]?,
) -> Mesh = "moonbit_raylib_new_mesh"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_vertex_count(mesh : Mesh) -> Int = "moonbit_raylib_get_mesh_vertex_count"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_triangle_count(mesh : Mesh) -> Int = "moonbit_raylib_get_mesh_triangle_count"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_vertices(mesh : Mesh) -> FloatPointer = "moonbit_raylib_get_mesh_vertices"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_texcoords(mesh : Mesh) -> FloatPointer = "moonbit_raylib_get_mesh_texcoords"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_texcoords2(mesh : Mesh) -> FloatPointer = "moonbit_raylib_get_mesh_texcoords2"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_normals(mesh : Mesh) -> FloatPointer = "moonbit_raylib_get_mesh_normals"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_tangents(mesh : Mesh) -> FloatPointer = "moonbit_raylib_get_mesh_tangents"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_colors(mesh : Mesh) -> UBytePointer = "moonbit_raylib_get_mesh_colors"

///|
#borrow(mesh)
pub extern "c" fn get_mesh_indices(mesh : Mesh) -> UShortPointer = "moonbit_raylib_get_mesh_indices"
