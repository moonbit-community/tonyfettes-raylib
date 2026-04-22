// Drawing lifecycle re-exports

///|
pub using @ffi {
  begin_drawing,
  end_drawing,
  begin_scissor_mode,
  end_scissor_mode,
  begin_blend_mode,
  end_blend_mode,
  end_texture_mode,
  end_shader_mode,
  end_vr_stereo_mode,
}

// Drawing wrapper

///|
/// Set background color (framebuffer clear color).
pub fn clear_background(color : Color) -> Unit {
  @ffi.clear_background(color.to_bytes())
}

// Shader uniform type constants

///|
/// Shader uniform type: float
pub const ShaderUniformFloat : Int = 0

///|
/// Shader uniform type: vec2 (2 float)
pub const ShaderUniformVec2 : Int = 1

///|
/// Shader uniform type: vec3 (3 float)
pub const ShaderUniformVec3 : Int = 2

///|
/// Shader uniform type: vec4 (4 float)
pub const ShaderUniformVec4 : Int = 3

///|
/// Shader uniform type: int
pub const ShaderUniformInt : Int = 4

///|
/// Shader uniform type: ivec2 (2 int)
pub const ShaderUniformIvec2 : Int = 5

///|
/// Shader uniform type: ivec3 (3 int)
pub const ShaderUniformIvec3 : Int = 6

///|
/// Shader uniform type: ivec4 (4 int)
pub const ShaderUniformIvec4 : Int = 7

///|
/// Shader uniform type: sampler2d
pub const ShaderUniformSampler2d : Int = 8

// Shader location index constants

///|
/// Shader location: vertex attribute: position
pub const ShaderLocVertexPosition : Int = 0

///|
/// Shader location: vertex attribute: texcoord01
pub const ShaderLocVertexTexcoord01 : Int = 1

///|
/// Shader location: vertex attribute: texcoord02
pub const ShaderLocVertexTexcoord02 : Int = 2

///|
/// Shader location: vertex attribute: normal
pub const ShaderLocVertexNormal : Int = 3

///|
/// Shader location: vertex attribute: tangent
pub const ShaderLocVertexTangent : Int = 4

///|
/// Shader location: vertex attribute: color
pub const ShaderLocVertexColor : Int = 5

///|
/// Shader location: matrix uniform: model-view-projection
pub const ShaderLocMatrixMvp : Int = 6

///|
/// Shader location: matrix uniform: view (camera transform)
pub const ShaderLocMatrixView : Int = 7

///|
/// Shader location: matrix uniform: projection
pub const ShaderLocMatrixProjection : Int = 8

///|
/// Shader location: matrix uniform: model (transform)
pub const ShaderLocMatrixModel : Int = 9

///|
/// Shader location: matrix uniform: normal
pub const ShaderLocMatrixNormal : Int = 10

///|
/// Shader location: vector uniform: view
pub const ShaderLocVectorView : Int = 11

///|
/// Shader location: vector uniform: diffuse color
pub const ShaderLocColorDiffuse : Int = 12

///|
/// Shader location: vector uniform: specular color
pub const ShaderLocColorSpecular : Int = 13

///|
/// Shader location: vector uniform: ambient color
pub const ShaderLocColorAmbient : Int = 14

///|
/// Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
pub const ShaderLocMapAlbedo : Int = 15

///|
/// Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
pub const ShaderLocMapMetalness : Int = 16

///|
/// Shader location: sampler2d texture: normal
pub const ShaderLocMapNormal : Int = 17

///|
/// Shader location: sampler2d texture: roughness
pub const ShaderLocMapRoughness : Int = 18

///|
/// Shader location: sampler2d texture: occlusion
pub const ShaderLocMapOcclusion : Int = 19

///|
/// Shader location: sampler2d texture: emission
pub const ShaderLocMapEmission : Int = 20

///|
/// Shader location: sampler2d texture: height
pub const ShaderLocMapHeight : Int = 21

///|
/// Shader location: samplerCube texture: cubemap
pub const ShaderLocMapCubemap : Int = 22

///|
/// Shader location: samplerCube texture: irradiance
pub const ShaderLocMapIrradiance : Int = 23

///|
/// Shader location: samplerCube texture: prefilter
pub const ShaderLocMapPrefilter : Int = 24

///|
/// Shader location: sampler2d texture: brdf
pub const ShaderLocMapBrdf : Int = 25

///|
/// Shader location: vertex attribute: boneIds
pub const ShaderLocVertexBoneids : Int = 26

///|
/// Shader location: vertex attribute: boneWeights
pub const ShaderLocVertexBoneweights : Int = 27

///|
/// Shader location: array of matrices uniform: boneMatrices
pub const ShaderLocBoneMatrices : Int = 28
// Blend mode constants

///|
/// Blend mode: alpha blending (default)
pub const BlendAlpha : Int = 0

///|
/// Blend mode: additive blending
pub const BlendAdditive : Int = 1

///|
/// Blend mode: multiplied blending
pub const BlendMultiplied : Int = 2

///|
/// Blend mode: custom blending using src/dst factors (use rlSetBlendFactors())
pub const BlendCustom : Int = 6

// ============================================================================
// VR stereo
// ============================================================================

///|
/// VR stereo rendering configuration for simulator.
struct VrStereoConfig(@ffi.VrStereoConfig)

///|
/// Unload VR stereo config.
#as_free_fn(unload_vr_stereo_config)
pub fn VrStereoConfig::unload(self : VrStereoConfig) -> Unit {
  @ffi.unload_vr_stereo_config(self.0)
}

///|
/// Load VR stereo config for VR simulator device parameters.
#as_free_fn(load_vr_stereo_config)
pub fn VrStereoConfig::load(device : VrDeviceInfo) -> VrStereoConfig {
  @ffi.load_vr_stereo_config(device.to_bytes())
}

///|
/// Begin stereo rendering (requires VR simulator).
#as_free_fn(begin_vr_stereo_mode)
pub fn VrStereoConfig::begin_mode(self : VrStereoConfig) -> Unit {
  @ffi.begin_vr_stereo_mode(self.0)
}

// VrStereoConfig field accessors

///|
/// Get VR left lens center.
pub fn VrStereoConfig::left_lens_center(self : VrStereoConfig) -> Vector2 {
  Vector2::from_bytes(@ffi.vr_stereo_config_left_lens_center(self.0))
}

///|
/// Get VR right lens center.
pub fn VrStereoConfig::right_lens_center(self : VrStereoConfig) -> Vector2 {
  Vector2::from_bytes(@ffi.vr_stereo_config_right_lens_center(self.0))
}

///|
/// Get VR left screen center.
pub fn VrStereoConfig::left_screen_center(self : VrStereoConfig) -> Vector2 {
  Vector2::from_bytes(@ffi.vr_stereo_config_left_screen_center(self.0))
}

///|
/// Get VR right screen center.
pub fn VrStereoConfig::right_screen_center(self : VrStereoConfig) -> Vector2 {
  Vector2::from_bytes(@ffi.vr_stereo_config_right_screen_center(self.0))
}

///|
/// Get VR distortion scale.
pub fn VrStereoConfig::scale(self : VrStereoConfig) -> Vector2 {
  Vector2::from_bytes(@ffi.vr_stereo_config_scale(self.0))
}

///|
/// Get VR distortion scale in.
pub fn VrStereoConfig::scale_in(self : VrStereoConfig) -> Vector2 {
  Vector2::from_bytes(@ffi.vr_stereo_config_scale_in(self.0))
}

///|
/// Get VR left lens center (deprecated: use VrStereoConfig::left_lens_center instead).
#deprecated("Use VrStereoConfig::left_lens_center instead")
pub fn vr_stereo_config_left_lens_center(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_left_lens_center(config.0)
}

///|
/// Get VR right lens center (deprecated: use VrStereoConfig::right_lens_center instead).
#deprecated("Use VrStereoConfig::right_lens_center instead")
pub fn vr_stereo_config_right_lens_center(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_right_lens_center(config.0)
}

///|
/// Get VR left screen center (deprecated: use VrStereoConfig::left_screen_center instead).
#deprecated("Use VrStereoConfig::left_screen_center instead")
pub fn vr_stereo_config_left_screen_center(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_left_screen_center(config.0)
}

///|
/// Get VR right screen center (deprecated: use VrStereoConfig::right_screen_center instead).
#deprecated("Use VrStereoConfig::right_screen_center instead")
pub fn vr_stereo_config_right_screen_center(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_right_screen_center(config.0)
}

///|
/// Get VR distortion scale (deprecated: use VrStereoConfig::scale instead).
#deprecated("Use VrStereoConfig::scale instead")
pub fn vr_stereo_config_scale(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_scale(config.0)
}

///|
/// Get VR distortion scale in (deprecated: use VrStereoConfig::scale_in instead).
#deprecated("Use VrStereoConfig::scale_in instead")
pub fn vr_stereo_config_scale_in(config : VrStereoConfig) -> Bytes {
  @ffi.vr_stereo_config_scale_in(config.0)
}

// VrDeviceInfo value type: 60 bytes
// hResolution(int), vResolution(int), hScreenSize(float), vScreenSize(float),
// eyeToScreenDistance(float), lensSeparationDistance(float), interpupillaryDistance(float),
// lensDistortionValues[4](float), chromaAbCorrection[4](float)

///|
/// Head-Mounted-Display device parameters.
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
} derive(Debug)

///|
/// Create a new VrDeviceInfo with the given parameters.
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
/// Serialize VrDeviceInfo to bytes for FFI passing.
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
