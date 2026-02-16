// Re-export opaque types for drawing

///|
pub using @raylib {type Shader, type RenderTexture}

// Drawing lifecycle re-exports

///|
pub using @raylib {
  begin_drawing,
  end_drawing,
  begin_scissor_mode,
  end_scissor_mode,
  begin_blend_mode,
  end_blend_mode,
  begin_texture_mode,
  end_texture_mode,
}

// Shader re-exports (passthrough: primitives/opaque types only)

///|
pub using @raylib {
  is_shader_valid,
  unload_shader,
  begin_shader_mode,
  end_shader_mode,
  set_shader_value,
  set_shader_value_v,
  set_shader_value_texture,
}

// Drawing wrapper

///|
pub fn clear_background(color : Color) -> Unit {
  @raylib.clear_background(color.to_bytes())
}

// ============================================================================
// Shader management (wrappers)
// ============================================================================

///|
pub fn load_shader(vs_file_name : String, fs_file_name : String) -> Shader {
  @raylib.load_shader(@utf8.encode(vs_file_name), @utf8.encode(fs_file_name))
}

///|
pub fn load_shader_from_memory(vs_code : String, fs_code : String) -> Shader {
  @raylib.load_shader_from_memory(@utf8.encode(vs_code), @utf8.encode(fs_code))
}

///|
pub fn get_shader_location(shader : Shader, uniform_name : String) -> Int {
  @raylib.get_shader_location(shader, @utf8.encode(uniform_name))
}

///|
pub fn get_shader_location_attrib(shader : Shader, attrib_name : String) -> Int {
  @raylib.get_shader_location_attrib(shader, @utf8.encode(attrib_name))
}

///|
pub fn set_shader_value_matrix(
  shader : Shader,
  loc_index : Int,
  mat : Matrix,
) -> Unit {
  @raylib.set_shader_value_matrix(shader, loc_index, mat.to_bytes())
}

// Shader uniform type constants

///|
pub let shader_uniform_float : Int = 0

///|
pub let shader_uniform_vec2 : Int = 1

///|
pub let shader_uniform_vec3 : Int = 2

///|
pub let shader_uniform_vec4 : Int = 3

///|
pub let shader_uniform_int : Int = 4

///|
pub let shader_uniform_ivec2 : Int = 5

///|
pub let shader_uniform_ivec3 : Int = 6

///|
pub let shader_uniform_ivec4 : Int = 7

///|
pub let shader_uniform_sampler2d : Int = 8

// Blend mode constants

///|
pub const BlendAlpha : Int = 0

///|
pub const BlendAdditive : Int = 1

///|
pub const BlendMultiplied : Int = 2
