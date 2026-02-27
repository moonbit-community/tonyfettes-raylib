// Re-export opaque types for drawing

///|
pub using @ffi {type Shader, type RenderTexture, type VrStereoConfig}

// Drawing lifecycle re-exports

///|
pub using @ffi {
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
pub using @ffi {
  is_shader_valid,
  unload_shader,
  begin_shader_mode,
  end_shader_mode,
  set_shader_value,
  set_shader_value_v,
  set_shader_value_texture,
  set_shader_locs,
}

// Drawing wrapper

///|
pub fn clear_background(color : Color) -> Unit {
  @ffi.clear_background(color.to_bytes())
}

// ============================================================================
// Shader management (wrappers)
// ============================================================================

///|
pub fn load_shader(vs_file_name : String, fs_file_name : String) -> Shader {
  @ffi.load_shader(@utf8.encode(vs_file_name), @utf8.encode(fs_file_name))
}

///|
pub fn load_shader_from_memory(vs_code : String, fs_code : String) -> Shader {
  @ffi.load_shader_from_memory(@utf8.encode(vs_code), @utf8.encode(fs_code))
}

///|
pub fn get_shader_location(shader : Shader, uniform_name : String) -> Int {
  @ffi.get_shader_location(shader, @utf8.encode(uniform_name))
}

///|
pub fn set_shader_location(
  shader : Shader,
  loc_index : Int,
  value : Int,
) -> Unit {
  @ffi.set_shader_location(shader, loc_index, value)
}

///|
pub fn get_shader_id(shader : Shader) -> Int {
  @ffi.get_shader_id(shader)
}

///|
pub fn get_shader_location_attrib(shader : Shader, attrib_name : String) -> Int {
  @ffi.get_shader_location_attrib(shader, @utf8.encode(attrib_name))
}

///|
pub fn set_shader_value_matrix(
  shader : Shader,
  loc_index : Int,
  mat : Matrix,
) -> Unit {
  @ffi.set_shader_value_matrix(shader, loc_index, mat.to_bytes())
}

// Shader uniform type constants

///|
pub const ShaderUniformFloat : Int = 0

///|
pub const ShaderUniformVec2 : Int = 1

///|
pub const ShaderUniformVec3 : Int = 2

///|
pub const ShaderUniformVec4 : Int = 3

///|
pub const ShaderUniformInt : Int = 4

///|
pub const ShaderUniformIvec2 : Int = 5

///|
pub const ShaderUniformIvec3 : Int = 6

///|
pub const ShaderUniformIvec4 : Int = 7

///|
pub const ShaderUniformSampler2d : Int = 8

// Shader location index constants

///|
pub const ShaderLocVertexPosition : Int = 0

///|
pub const ShaderLocVertexTexcoord01 : Int = 1

///|
pub const ShaderLocVertexTexcoord02 : Int = 2

///|
pub const ShaderLocVertexNormal : Int = 3

///|
pub const ShaderLocVertexTangent : Int = 4

///|
pub const ShaderLocVertexColor : Int = 5

///|
pub const ShaderLocMatrixMvp : Int = 6

///|
pub const ShaderLocMatrixView : Int = 7

///|
pub const ShaderLocMatrixProjection : Int = 8

///|
pub const ShaderLocMatrixModel : Int = 9

///|
pub const ShaderLocMatrixNormal : Int = 10

///|
pub const ShaderLocVectorView : Int = 11

///|
pub const ShaderLocColorDiffuse : Int = 12

///|
pub const ShaderLocColorSpecular : Int = 13

///|
pub const ShaderLocColorAmbient : Int = 14

///|
pub const ShaderLocMapAlbedo : Int = 15

///|
pub const ShaderLocMapMetalness : Int = 16

///|
pub const ShaderLocMapNormal : Int = 17

///|
pub const ShaderLocMapRoughness : Int = 18

///|
pub const ShaderLocMapOcclusion : Int = 19

///|
pub const ShaderLocMapEmission : Int = 20

///|
pub const ShaderLocMapHeight : Int = 21

///|
pub const ShaderLocMapCubemap : Int = 22

///|
pub const ShaderLocMapIrradiance : Int = 23

///|
pub const ShaderLocMapPrefilter : Int = 24

///|
pub const ShaderLocMapBrdf : Int = 25

///|
pub const ShaderLocVertexBoneids : Int = 26

///|
pub const ShaderLocVertexBoneweights : Int = 27

///|
pub const ShaderLocBoneMatrices : Int = 28
// Blend mode constants

///|
pub const BlendAlpha : Int = 0

///|
pub const BlendAdditive : Int = 1

///|
pub const BlendMultiplied : Int = 2

///|
pub const BlendCustom : Int = 6

// ============================================================================
// VR stereo re-exports
// ============================================================================

///|
pub using @ffi {unload_vr_stereo_config, end_vr_stereo_mode}

// VrDeviceInfo value type: 60 bytes
// hResolution(int), vResolution(int), hScreenSize(float), vScreenSize(float),
// eyeToScreenDistance(float), lensSeparationDistance(float), interpupillaryDistance(float),
// lensDistortionValues[4](float), chromaAbCorrection[4](float)

///|
pub struct VrDeviceInfo {
  h_resolution : Int
  v_resolution : Int
  h_screen_size : Float
  v_screen_size : Float
  eye_to_screen_distance : Float
  lens_separation_distance : Float
  interpupillary_distance : Float
  lens_distortion_values : FixedArray[Float] // length 4
  chroma_ab_correction : FixedArray[Float] // length 4
} derive(Show)

///|
pub fn VrDeviceInfo::new(
  h_resolution : Int,
  v_resolution : Int,
  h_screen_size : Float,
  v_screen_size : Float,
  eye_to_screen_distance : Float,
  lens_separation_distance : Float,
  interpupillary_distance : Float,
  lens_distortion_values : FixedArray[Float],
  chroma_ab_correction : FixedArray[Float],
) -> VrDeviceInfo {
  {
    h_resolution,
    v_resolution,
    h_screen_size,
    v_screen_size,
    eye_to_screen_distance,
    lens_separation_distance,
    interpupillary_distance,
    lens_distortion_values,
    chroma_ab_correction,
  }
}

///|
pub fn VrDeviceInfo::to_bytes(info : VrDeviceInfo) -> Bytes {
  let buf = @buffer.new(size_hint=60)
  buf.write_int_le(info.h_resolution)
  buf.write_int_le(info.v_resolution)
  buf.write_float_le(info.h_screen_size)
  buf.write_float_le(info.v_screen_size)
  buf.write_float_le(info.eye_to_screen_distance)
  buf.write_float_le(info.lens_separation_distance)
  buf.write_float_le(info.interpupillary_distance)
  for i in 0..<4 {
    buf.write_float_le(info.lens_distortion_values[i])
  }
  for i in 0..<4 {
    buf.write_float_le(info.chroma_ab_correction[i])
  }
  buf.to_bytes()
}

///|
pub fn load_vr_stereo_config(device : VrDeviceInfo) -> VrStereoConfig {
  @ffi.load_vr_stereo_config(device.to_bytes())
}

///|
pub fn begin_vr_stereo_mode(config : VrStereoConfig) -> Unit {
  @ffi.begin_vr_stereo_mode(config)
}

// VrStereoConfig field accessors (return raw Bytes for use with set_shader_value)

///|
pub fn vr_stereo_config_left_lens_center(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_left_lens_center(config)
}

///|
pub fn vr_stereo_config_right_lens_center(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_right_lens_center(config)
}

///|
pub fn vr_stereo_config_left_screen_center(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_left_screen_center(config)
}

///|
pub fn vr_stereo_config_right_screen_center(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_right_screen_center(config)
}

///|
pub fn vr_stereo_config_scale(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_scale(config)
}

///|
pub fn vr_stereo_config_scale_in(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_scale_in(config)
}
