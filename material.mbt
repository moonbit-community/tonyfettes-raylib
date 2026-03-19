///|
/// Material type, includes shader and maps.
struct Material(@ffi.Material)

///|
/// Load default material (supports: DIFFUSE, SPECULAR, NORMAL maps).
pub impl Default for Material with default() -> Material {
  @ffi.load_material_default()
}

///|
/// Load default material (deprecated, use `Material::default()` instead).
#as_free_fn(load_material_default, deprecated="Use Material::default() instead")
#deprecated("Use Material::default() instead")
pub fn Material::load_default() -> Material {
  @ffi.load_material_default()
}

///|
/// Check if a material is valid (shader assigned, map textures loaded in GPU).
#as_free_fn(is_material_valid)
pub fn Material::is_valid(self : Material) -> Bool {
  @ffi.is_material_valid(self.0)
}

///|
/// Unload material from GPU memory (VRAM).
#as_free_fn(unload_material)
pub fn Material::unload(self : Material) -> Unit {
  @ffi.unload_material(self.0)
}

///|
/// Set texture for a material map type (MATERIAL_MAP_DIFFUSE, MATERIAL_MAP_SPECULAR...).
#as_free_fn(set_material_texture)
pub fn Material::set_texture(
  self : Material,
  map_type : Int,
  texture : Texture,
) -> Unit {
  @ffi.set_material_texture(self.0, map_type, texture.0)
}

///|
/// Set shader for a material.
#as_free_fn(set_material_shader)
pub fn Material::set_shader(self : Material, shader : Shader) -> Unit {
  @ffi.set_material_shader(self.0, shader.0)
}

///|
/// Set color for a material map type.
#as_free_fn(set_material_map_color)
pub fn Material::set_map_color(
  self : Material,
  map_type : Int,
  color : Color,
) -> Unit {
  @ffi.set_material_map_color(self.0, map_type, color.to_bytes())
}

///|
/// Set value for a material map type.
#as_free_fn(set_material_map_value)
pub fn Material::set_map_value(
  self : Material,
  map_type : Int,
  value : Float,
) -> Unit {
  @ffi.set_material_map_value(self.0, map_type, value)
}

///|
/// Get shader assigned to the material.
#as_free_fn(get_material_shader)
pub fn Material::shader(self : Material) -> Shader {
  @ffi.get_material_shader(self.0)
}

///|
/// Get material maps array.
#as_free_fn(get_material_maps)
pub fn Material::maps(self : Material) -> MaterialMapArray {
  MaterialMapArray(@ffi.get_material_maps(self.0), 12)
}

// ============================================================================
// MaterialMapArray
// ============================================================================

///|
/// Array of material maps, accessed by index.
struct MaterialMapArray(@ffi.MaterialMapArray, Int)

///|
/// Get the number of material maps in the array.
pub fn MaterialMapArray::count(self : MaterialMapArray) -> Int {
  self.1
}

///|
/// Get a material map by index.
pub fn MaterialMapArray::op_get(
  self : MaterialMapArray,
  index : Int,
) -> MaterialMap {
  guard index >= 0 && index < self.1
  @ffi.material_map_array_op_get(self.0, index)
}

///|
/// Set a material map at the given index.
pub fn MaterialMapArray::op_set(
  self : MaterialMapArray,
  index : Int,
  value : MaterialMap,
) -> Unit {
  guard index >= 0 && index < self.1
  @ffi.material_map_array_op_set(self.0, index, value.0)
}

// ============================================================================
// MaterialMap
// ============================================================================

///|
/// Material map, contains texture, color, and value.
struct MaterialMap(@ffi.MaterialMap)

///|
/// Get material map texture.
pub fn MaterialMap::texture(self : MaterialMap) -> Texture {
  @ffi.material_map_get_texture(self.0)
}

///|
/// Set material map texture.
pub fn MaterialMap::set_texture(self : MaterialMap, texture : Texture) -> Unit {
  @ffi.material_map_set_texture(self.0, texture.0)
}

///|
/// Get material map color.
pub fn MaterialMap::color(self : MaterialMap) -> Color {
  Color::from_bytes(@ffi.material_map_get_color(self.0))
}

///|
/// Set material map color.
pub fn MaterialMap::set_color(self : MaterialMap, color : Color) -> Unit {
  @ffi.material_map_set_color(self.0, color.to_bytes())
}

///|
/// Get material map value.
pub fn MaterialMap::value(self : MaterialMap) -> Float {
  @ffi.material_map_get_value(self.0)
}

///|
/// Set material map value.
pub fn MaterialMap::set_value(self : MaterialMap, value : Float) -> Unit {
  @ffi.material_map_set_value(self.0, value)
}

///|
/// Model animations array, loaded from file.
struct ModelAnimations(@ffi.ModelAnimations)

///|
/// Get the number of animations in the array.
#as_free_fn(model_animations_count)
pub fn ModelAnimations::count(self : ModelAnimations) -> Int {
  @ffi.model_animations_count(self.0)
}

///|
/// Unload animation array data.
#as_free_fn(unload_model_animations)
pub fn ModelAnimations::unload(self : ModelAnimations) -> Unit {
  @ffi.unload_model_animations(self.0)
}

///|
/// Load model animations from file.
#as_free_fn(load_model_animations)
pub fn ModelAnimations::load(file_name : String) -> ModelAnimations {
  @ffi.load_model_animations(@utf8.encode(file_name))
}

///|
/// Get the frame count for a specific animation.
#as_free_fn(get_model_animation_frame_count)
pub fn ModelAnimations::frame_count(
  self : ModelAnimations,
  anim_index : Int,
) -> Int {
  @ffi.get_model_animation_frame_count(self.0, anim_index)
}

///|
/// Get the bone count for a specific animation.
#as_free_fn(get_model_animation_bone_count)
pub fn ModelAnimations::bone_count(
  self : ModelAnimations,
  anim_index : Int,
) -> Int {
  @ffi.get_model_animation_bone_count(self.0, anim_index)
}

///|
/// Get the parent bone index for a specific bone in an animation.
#as_free_fn(get_model_animation_bone_parent)
pub fn ModelAnimations::bone_parent(
  self : ModelAnimations,
  anim_index : Int,
  bone_index : Int,
) -> Int {
  @ffi.get_model_animation_bone_parent(self.0, anim_index, bone_index)
}

///|
/// Get the translation of a bone pose at a specific animation frame.
#as_free_fn(get_model_animation_frame_pose_translation)
pub fn ModelAnimations::frame_pose_translation(
  self : ModelAnimations,
  anim_index : Int,
  frame : Int,
  bone_index : Int,
) -> Vector3 {
  Vector3::from_bytes(
    @ffi.get_model_animation_frame_pose_translation(
      self.0,
      anim_index,
      frame,
      bone_index,
    ),
  )
}

///|
/// Get the rotation quaternion of a bone pose at a specific animation frame.
#as_free_fn(get_model_animation_frame_pose_rotation)
pub fn ModelAnimations::frame_pose_rotation(
  self : ModelAnimations,
  anim_index : Int,
  frame : Int,
  bone_index : Int,
) -> Vector4 {
  Vector4::from_bytes(
    @ffi.get_model_animation_frame_pose_rotation(
      self.0,
      anim_index,
      frame,
      bone_index,
    ),
  )
}

///|
/// Array of materials loaded from a model file.
struct MaterialsArray(@ffi.MaterialsArray)

///|
/// Unload materials array data.
#as_free_fn(unload_materials_array)
pub fn MaterialsArray::unload(self : MaterialsArray) -> Unit {
  @ffi.unload_materials_array(self.0)
}

///|
/// Get the number of materials in the array.
#as_free_fn(materials_array_count)
pub fn MaterialsArray::count(self : MaterialsArray) -> Int {
  @ffi.materials_array_count(self.0)
}

///|
/// Get a material from the array by index.
#as_free_fn(materials_array_get)
pub fn MaterialsArray::get(self : MaterialsArray, index : Int) -> Material {
  @ffi.materials_array_get(self.0, index)
}

///|
/// Load materials from model file.
#as_free_fn(load_materials)
pub fn MaterialsArray::load(file_name : String) -> MaterialsArray {
  @ffi.load_materials(@utf8.encode(file_name))
}
