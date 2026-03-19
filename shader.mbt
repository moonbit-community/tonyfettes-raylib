///|
/// Shader program, includes vertex and fragment shaders.
struct Shader(@ffi.Shader)

///|
/// Shader uniform data for a single value, tagged by type.
pub(all) enum ShaderUniformData {
  /// Shader uniform type: float
  Float(Float)
  /// Shader uniform type: vec2 (2 float)
  Vec2(Vector2)
  /// Shader uniform type: vec3 (3 float)
  Vec3(Vector3)
  /// Shader uniform type: vec4 (4 float)
  Vec4(Vector4)
  /// Shader uniform type: int
  Int(Int)
  /// Shader uniform type: ivec2 (2 int)
  IVec2((Int, Int))
  /// Shader uniform type: ivec3 (3 int)
  IVec3((Int, Int, Int))
  /// Shader uniform type: ivec4 (4 int)
  IVec4((Int, Int, Int, Int))
  /// Shader uniform type: sampler2d (texture unit index)
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
/// Shader uniform data for an array of values (vector variant), tagged by type.
pub(all) enum ShaderUniformDataV {
  /// Shader uniform type: float array
  Float(Array[Float])
  /// Shader uniform type: vec2 array (2 float each)
  Vec2(Array[Vector2])
  /// Shader uniform type: vec3 array (3 float each)
  Vec3(Array[Vector3])
  /// Shader uniform type: vec4 array (4 float each)
  Vec4(Array[Vector4])
  /// Shader uniform type: int array
  Int(Array[Int])
  /// Shader uniform type: ivec2 array (2 int each)
  IVec2(Array[(Int, Int)])
  /// Shader uniform type: ivec3 array (3 int each)
  IVec3(Array[(Int, Int, Int)])
  /// Shader uniform type: ivec4 array (4 int each)
  IVec4(Array[(Int, Int, Int, Int)])
  /// Shader uniform type: sampler2d array (texture unit indices)
  Sampler2D(Array[Int])
}

///|
fn ShaderUniformDataV::to_bytes(self : ShaderUniformDataV) -> Bytes {
  let buf = @buffer.new(size_hint=self.count() * self.elem_size())
  match self {
    Float(vs) =>
      for v in vs {
        buf.write_float_le(v)
      }
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
    Int(vs) | Sampler2D(vs) =>
      for v in vs {
        buf.write_int_le(v)
      }
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
/// Check if a shader is valid (loaded on GPU).
#as_free_fn(is_shader_valid)
pub fn Shader::is_valid(self : Shader) -> Bool {
  @ffi.is_shader_valid(self.0)
}

///|
/// Unload shader from GPU memory (VRAM).
#as_free_fn(unload_shader)
pub fn Shader::unload(self : Shader) -> Unit {
  @ffi.unload_shader(self.0)
}

///|
/// Begin custom shader drawing.
#as_free_fn(begin_shader_mode)
pub fn Shader::begin_mode(self : Shader) -> Unit {
  @ffi.begin_shader_mode(self.0)
}

///|
/// Set shader uniform value.
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
/// Set shader uniform value (deprecated, use `Shader::set_value` instead).
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
/// Set shader uniform value vector.
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
/// Set shader uniform value vector (deprecated, use `Shader::set_value_v` instead).
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
/// Set shader uniform value for texture (sampler2d).
#as_free_fn(set_shader_value_texture)
pub fn Shader::set_value_texture(
  self : Shader,
  loc_index : Int,
  texture : Texture,
) -> Unit {
  @ffi.set_shader_value_texture(self.0, loc_index, texture.0)
}

///|
/// Set shader location index for a uniform.
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
/// Load shader from files and bind default locations.
#as_free_fn(load_shader)
pub fn Shader::load(vs_file_name : String, fs_file_name : String) -> Shader {
  @ffi.load_shader(@utf8.encode(vs_file_name), @utf8.encode(fs_file_name))
}

///|
/// Load shader from code strings and bind default locations.
#as_free_fn(load_shader_from_memory)
pub fn Shader::load_from_memory(vs_code : String, fs_code : String) -> Shader {
  @ffi.load_shader_from_memory(@utf8.encode(vs_code), @utf8.encode(fs_code))
}

///|
/// Get shader uniform location.
#as_free_fn(get_shader_location)
pub fn Shader::get_location(self : Shader, uniform_name : String) -> Int {
  @ffi.get_shader_location(self.0, @utf8.encode(uniform_name))
}

///|
/// Get shader program id (OpenGL handle).
#as_free_fn(get_shader_id)
pub fn Shader::id(self : Shader) -> UInt {
  @ffi.get_shader_id(self.0)
}

///|
/// Get shader attribute location.
#as_free_fn(get_shader_location_attrib)
pub fn Shader::get_location_attrib(self : Shader, attrib_name : String) -> Int {
  @ffi.get_shader_location_attrib(self.0, @utf8.encode(attrib_name))
}

///|
/// Set shader uniform value (matrix 4x4).
#as_free_fn(set_shader_value_matrix)
pub fn Shader::set_value_matrix(
  self : Shader,
  loc_index : Int,
  mat : Matrix,
) -> Unit {
  @ffi.set_shader_value_matrix(self.0, loc_index, mat.to_bytes())
}
