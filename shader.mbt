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
    Float(_) => ShaderUniformFloat
    Vec2(_) => ShaderUniformVec2
    Vec3(_) => ShaderUniformVec3
    Vec4(_) => ShaderUniformVec4
    Int(_) => ShaderUniformInt
    IVec2(_) => ShaderUniformIvec2
    IVec3(_) => ShaderUniformIvec3
    IVec4(_) => ShaderUniformIvec4
    Sampler2D(_) => ShaderUniformSampler2d
  }
}

///|
pub(all) enum ShaderUniformDataV {
  Float(Array[Float])
  Vec2(Array[Vector2])
  Vec3(Array[Vector3])
  Vec4(Array[Vector4])
  Int(Array[Int])
  IVec2(Array[(Int, Int)])
  IVec3(Array[(Int, Int, Int)])
  IVec4(Array[(Int, Int, Int, Int)])
  Sampler2D(Array[Int])
}

///|
fn ShaderUniformDataV::to_bytes(self : ShaderUniformDataV) -> Bytes {
  let buf = @buffer.new(size_hint=self.count() * self.elem_size())
  match self {
    Float(vs) => for v in vs { buf.write_float_le(v) }
    Vec2(vs) =>
      for v in vs {
        buf.write_float_le(v.x)
        buf.write_float_le(v.y)
      }
    Vec3(vs) =>
      for v in vs {
        buf.write_float_le(v.x)
        buf.write_float_le(v.y)
        buf.write_float_le(v.z)
      }
    Vec4(vs) =>
      for v in vs {
        buf.write_float_le(v.x)
        buf.write_float_le(v.y)
        buf.write_float_le(v.z)
        buf.write_float_le(v.w)
      }
    Int(vs) | Sampler2D(vs) => for v in vs { buf.write_int_le(v) }
    IVec2(vs) =>
      for v in vs {
        buf.write_int_le(v.0)
        buf.write_int_le(v.1)
      }
    IVec3(vs) =>
      for v in vs {
        buf.write_int_le(v.0)
        buf.write_int_le(v.1)
        buf.write_int_le(v.2)
      }
    IVec4(vs) =>
      for v in vs {
        buf.write_int_le(v.0)
        buf.write_int_le(v.1)
        buf.write_int_le(v.2)
        buf.write_int_le(v.3)
      }
  }
  buf.to_bytes()
}

///|
fn ShaderUniformDataV::uniform_type(self : ShaderUniformDataV) -> Int {
  match self {
    Float(_) => ShaderUniformFloat
    Vec2(_) => ShaderUniformVec2
    Vec3(_) => ShaderUniformVec3
    Vec4(_) => ShaderUniformVec4
    Int(_) => ShaderUniformInt
    IVec2(_) => ShaderUniformIvec2
    IVec3(_) => ShaderUniformIvec3
    IVec4(_) => ShaderUniformIvec4
    Sampler2D(_) => ShaderUniformSampler2d
  }
}

///|
fn ShaderUniformDataV::count(self : ShaderUniformDataV) -> Int {
  match self {
    Float(vs) => vs.length()
    Vec2(vs) => vs.length()
    Vec3(vs) => vs.length()
    Vec4(vs) => vs.length()
    Int(vs) | Sampler2D(vs) => vs.length()
    IVec2(vs) => vs.length()
    IVec3(vs) => vs.length()
    IVec4(vs) => vs.length()
  }
}

///|
fn ShaderUniformDataV::elem_size(self : ShaderUniformDataV) -> Int {
  match self {
    Float(_) | Int(_) | Sampler2D(_) => 4
    Vec2(_) | IVec2(_) => 8
    Vec3(_) | IVec3(_) => 12
    Vec4(_) | IVec4(_) => 16
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
#deprecated("Use Shader::set_value instead")
pub fn set_shader_value(
  shader : Shader,
  loc_index : Int,
  value : Bytes,
  uniform_type : Int,
) -> Unit {
  @ffi.set_shader_value(shader.0, loc_index, value, uniform_type)
}

///|
pub fn Shader::set_value_v(
  self : Shader,
  loc_index : Int,
  values : ShaderUniformDataV,
) -> Unit {
  let count = values.count()
  if count == 0 {
    return
  }
  @ffi.set_shader_value_v(
    self.0,
    loc_index,
    values.to_bytes(),
    values.uniform_type(),
    count,
  )
}

///|
#deprecated("Use Shader::set_value_v instead")
pub fn set_shader_value_v(
  shader : Shader,
  loc_index : Int,
  value : Bytes,
  uniform_type : Int,
  count : Int,
) -> Unit {
  @ffi.set_shader_value_v(shader.0, loc_index, value, uniform_type, count)
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
#as_free_fn(set_shader_location, deprecated="Use Shader::set_locs or set_shader_locs instead")
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
#as_free_fn(get_shader_id)
pub fn Shader::id(self : Shader) -> UInt {
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
