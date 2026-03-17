///|
struct Shader(@ffi.Shader)

///|
pub(all) enum ShaderUniformData {
  Float(Float)
  Vec2(Vector2)
  Vec3(Vector3)
  Vec4(Vector4)
  Int(Int)
  IVec2((Int, Int))
  IVec3((Int, Int, Int))
  IVec4((Int, Int, Int, Int))
  Sampler2D(Int)
}

///|
fn ShaderUniformData::to_bytes(self : ShaderUniformData) -> Bytes {
  match self {
    Float(v) => {
      let buf = @buffer.new(size_hint=4)
      buf.write_float_le(v)
      buf.to_bytes()
    }
    Vec2(v) => v.to_bytes()
    Vec3(v) => v.to_bytes()
    Vec4(v) => v.to_bytes()
    Int(v) | Sampler2D(v) => {
      let buf = @buffer.new(size_hint=4)
      buf.write_int_le(v)
      buf.to_bytes()
    }
    IVec2((x, y)) => {
      let buf = @buffer.new(size_hint=8)
      buf.write_int_le(x)
      buf.write_int_le(y)
      buf.to_bytes()
    }
    IVec3((x, y, z)) => {
      let buf = @buffer.new(size_hint=12)
      buf.write_int_le(x)
      buf.write_int_le(y)
      buf.write_int_le(z)
      buf.to_bytes()
    }
    IVec4((x, y, z, w)) => {
      let buf = @buffer.new(size_hint=16)
      buf.write_int_le(x)
      buf.write_int_le(y)
      buf.write_int_le(z)
      buf.write_int_le(w)
      buf.to_bytes()
    }
  }
}

///|
fn ShaderUniformData::uniform_type(self : ShaderUniformData) -> Int {
  match self {
    Float(_) => 0
    Vec2(_) => 1
    Vec3(_) => 2
    Vec4(_) => 3
    Int(_) => 4
    IVec2(_) => 5
    IVec3(_) => 6
    IVec4(_) => 7
    Sampler2D(_) => 8
  }
}

///|
#as_free_fn(is_shader_valid)
pub fn Shader::is_valid(self : Shader) -> Bool {
  @ffi.is_shader_valid(self.0)
}

///|
#as_free_fn(unload_shader)
pub fn Shader::unload(self : Shader) -> Unit {
  @ffi.unload_shader(self.0)
}

///|
#as_free_fn(begin_shader_mode)
pub fn Shader::begin_mode(self : Shader) -> Unit {
  @ffi.begin_shader_mode(self.0)
}

///|
#as_free_fn(set_shader_value)
pub fn Shader::set_value(
  self : Shader,
  loc_index : Int,
  value : ShaderUniformData,
) -> Unit {
  @ffi.set_shader_value(
    self.0,
    loc_index,
    value.to_bytes(),
    value.uniform_type(),
  )
}

///|
#as_free_fn(set_shader_value_v)
pub fn Shader::set_value_v(
  self : Shader,
  loc_index : Int,
  value : Bytes,
  uniform_type : Int,
  count : Int,
) -> Unit {
  @ffi.set_shader_value_v(self.0, loc_index, value, uniform_type, count)
}

///|
#as_free_fn(set_shader_value_texture)
pub fn Shader::set_value_texture(
  self : Shader,
  loc_index : Int,
  texture : Texture,
) -> Unit {
  @ffi.set_shader_value_texture(self.0, loc_index, texture.0)
}

///|
#as_free_fn(set_shader_locs)
pub fn Shader::set_locs(
  self : Shader,
  loc_index : Int,
  loc_value : Int,
) -> Unit {
  @ffi.set_shader_locs(self.0, loc_index, loc_value)
}

///|
#as_free_fn(load_shader)
pub fn Shader::load(vs_file_name : String, fs_file_name : String) -> Shader {
  @ffi.load_shader(@utf8.encode(vs_file_name), @utf8.encode(fs_file_name))
}

///|
#as_free_fn(load_shader_from_memory)
pub fn Shader::load_from_memory(vs_code : String, fs_code : String) -> Shader {
  @ffi.load_shader_from_memory(@utf8.encode(vs_code), @utf8.encode(fs_code))
}

///|
#as_free_fn(get_shader_location)
pub fn Shader::get_location(self : Shader, uniform_name : String) -> Int {
  @ffi.get_shader_location(self.0, @utf8.encode(uniform_name))
}

///|
#as_free_fn(set_shader_location)
pub fn Shader::set_location(
  self : Shader,
  loc_index : Int,
  value : Int,
) -> Unit {
  @ffi.set_shader_location(self.0, loc_index, value)
}

///|
#as_free_fn(get_shader_id)
pub fn Shader::id(self : Shader) -> Int {
  @ffi.get_shader_id(self.0)
}

///|
#as_free_fn(get_shader_location_attrib)
pub fn Shader::get_location_attrib(self : Shader, attrib_name : String) -> Int {
  @ffi.get_shader_location_attrib(self.0, @utf8.encode(attrib_name))
}

///|
#as_free_fn(set_shader_value_matrix)
pub fn Shader::set_value_matrix(
  self : Shader,
  loc_index : Int,
  mat : Matrix,
) -> Unit {
  @ffi.set_shader_value_matrix(self.0, loc_index, mat.to_bytes())
}
