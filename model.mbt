///|
struct Model(@ffi.Model)

///|
#as_free_fn(unload_model)
pub fn Model::unload(self : Model) -> Unit {
  @ffi.unload_model(self.0)
}

///|
#as_free_fn(is_model_valid)
pub fn Model::is_valid(self : Model) -> Bool {
  @ffi.is_model_valid(self.0)
}

///|
#as_free_fn(load_model)
pub fn Model::load(file_name : String) -> Model {
  @ffi.load_model(@utf8.encode(file_name))
}

///|
#as_free_fn(draw_model)
pub fn Model::draw(
  self : Model,
  position : Vector3,
  scale : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_model(self.0, position.to_bytes(), scale, tint.to_bytes())
}

///|
#as_free_fn(draw_model_ex)
pub fn Model::draw_ex(
  self : Model,
  position : Vector3,
  rotation_axis : Vector3,
  rotation_angle : Float,
  scale : Vector3,
  tint : Color,
) -> Unit {
  @ffi.draw_model_ex(
    self.0,
    position.to_bytes(),
    rotation_axis.to_bytes(),
    rotation_angle,
    scale.to_bytes(),
    tint.to_bytes(),
  )
}

///|
#as_free_fn(draw_model_wires)
pub fn Model::draw_wires(
  self : Model,
  position : Vector3,
  scale : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_model_wires(self.0, position.to_bytes(), scale, tint.to_bytes())
}

///|
#as_free_fn(draw_model_wires_ex)
pub fn Model::draw_wires_ex(
  self : Model,
  position : Vector3,
  rotation_axis : Vector3,
  rotation_angle : Float,
  scale : Vector3,
  tint : Color,
) -> Unit {
  @ffi.draw_model_wires_ex(
    self.0,
    position.to_bytes(),
    rotation_axis.to_bytes(),
    rotation_angle,
    scale.to_bytes(),
    tint.to_bytes(),
  )
}

///|
#as_free_fn(draw_model_points)
pub fn Model::draw_points(
  self : Model,
  position : Vector3,
  scale : Float,
  tint : Color,
) -> Unit {
  @ffi.draw_model_points(self.0, position.to_bytes(), scale, tint.to_bytes())
}

///|
#as_free_fn(draw_model_points_ex)
pub fn Model::draw_points_ex(
  self : Model,
  position : Vector3,
  rotation_axis : Vector3,
  rotation_angle : Float,
  scale : Vector3,
  tint : Color,
) -> Unit {
  @ffi.draw_model_points_ex(
    self.0,
    position.to_bytes(),
    rotation_axis.to_bytes(),
    rotation_angle,
    scale.to_bytes(),
    tint.to_bytes(),
  )
}

///|
#as_free_fn(set_model_material_shader)
pub fn Model::set_material_shader(
  self : Model,
  material_index : Int,
  shader : Shader,
) -> Unit {
  @ffi.set_model_material_shader(self.0, material_index, shader.0)
}

///|
#as_free_fn(get_model_bounding_box)
pub fn Model::bounding_box(self : Model) -> BoundingBox {
  BoundingBox::from_bytes(@ffi.get_model_bounding_box(self.0))
}

///|
#as_free_fn(set_model_material_texture)
pub fn Model::set_material_texture(
  self : Model,
  material_index : Int,
  map_type : Int,
  texture : Texture,
) -> Unit {
  @ffi.set_model_material_texture(self.0, material_index, map_type, texture.0)
}

///|
#as_free_fn(set_model_transform)
pub fn Model::set_transform(self : Model, transform : Matrix) -> Unit {
  @ffi.set_model_transform(self.0, transform.to_bytes())
}

///|
#as_free_fn(get_model_mesh_count)
pub fn Model::mesh_count(self : Model) -> Int {
  @ffi.get_model_mesh_count(self.0)
}

///|
#as_free_fn(get_model_mesh)
pub fn Model::mesh(self : Model, index : Int) -> Mesh {
  @ffi.get_model_mesh(self.0, index)
}

///|
#as_free_fn(get_model_transform)
pub fn Model::transform(self : Model) -> Matrix {
  Matrix::from_bytes(@ffi.get_model_transform(self.0))
}

///|
#as_free_fn(get_model_material_count)
pub fn Model::material_count(self : Model) -> Int {
  @ffi.get_model_material_count(self.0)
}

///|
#as_free_fn(get_model_material)
pub fn Model::material(self : Model, index : Int) -> Material {
  @ffi.get_model_material(self.0, index)
}

///|
#as_free_fn(get_model_bone_count)
pub fn Model::bone_count(self : Model) -> Int {
  @ffi.get_model_bone_count(self.0)
}

///|
#as_free_fn(get_model_bone_parent)
pub fn Model::bone_parent(self : Model, bone_index : Int) -> Int {
  @ffi.get_model_bone_parent(self.0, bone_index)
}

///|
#as_free_fn(get_model_bind_pose_translation)
pub fn Model::bind_pose_translation(self : Model, bone_index : Int) -> Vector3 {
  Vector3::from_bytes(
    @ffi.get_model_bind_pose_translation(self.0, bone_index),
  )
}

///|
#as_free_fn(get_model_bind_pose_rotation)
pub fn Model::bind_pose_rotation(self : Model, bone_index : Int) -> Vector4 {
  Vector4::from_bytes(@ffi.get_model_bind_pose_rotation(self.0, bone_index))
}

///|
#as_free_fn(get_model_bone_name)
pub fn Model::bone_name(self : Model, bone_index : Int) -> String {
  @utf8.decode_lossy(@ffi.get_model_bone_name(self.0, bone_index))
}

///|
#as_free_fn(set_model_mesh_material)
pub fn Model::set_mesh_material(
  self : Model,
  mesh_id : Int,
  material_id : Int,
) -> Unit {
  @ffi.set_model_mesh_material(self.0, mesh_id, material_id)
}

///|
#as_free_fn(load_model_from_mesh)
pub fn Model::load_from_mesh(mesh : Mesh) -> Model {
  @ffi.load_model_from_mesh(mesh.0)
}

///|
#as_free_fn(update_model_animation)
pub fn Model::update_animation(
  self : Model,
  anims : ModelAnimations,
  index : Int,
  frame : Int,
) -> Unit {
  @ffi.update_model_animation(self.0, anims.0, index, frame)
}

///|
#as_free_fn(update_model_animation_bones)
pub fn Model::update_animation_bones(
  self : Model,
  anims : ModelAnimations,
  index : Int,
  frame : Int,
) -> Unit {
  @ffi.update_model_animation_bones(self.0, anims.0, index, frame)
}

///|
#as_free_fn(is_model_animation_valid)
pub fn Model::is_animation_valid(
  self : Model,
  anims : ModelAnimations,
  index : Int,
) -> Bool {
  @ffi.is_model_animation_valid(self.0, anims.0, index)
}
