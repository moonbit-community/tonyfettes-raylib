// Re-export opaque types for drawing

///|
pub using @raylib {type Shader, type RenderTexture, type VrStereoConfig}

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
  set_shader_locs,
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

// Shader location index constants

///|
pub let shader_loc_vertex_position : Int = 0

///|
pub let shader_loc_vertex_texcoord01 : Int = 1

///|
pub let shader_loc_vertex_texcoord02 : Int = 2

///|
pub let shader_loc_vertex_normal : Int = 3

///|
pub let shader_loc_vertex_tangent : Int = 4

///|
pub let shader_loc_vertex_color : Int = 5

///|
pub let shader_loc_matrix_mvp : Int = 6

///|
pub let shader_loc_matrix_view : Int = 7

///|
pub let shader_loc_matrix_projection : Int = 8

///|
pub let shader_loc_matrix_model : Int = 9

///|
pub let shader_loc_matrix_normal : Int = 10

///|
pub let shader_loc_vector_view : Int = 11

///|
pub let shader_loc_color_diffuse : Int = 12

///|
pub let shader_loc_color_specular : Int = 13

///|
pub let shader_loc_color_ambient : Int = 14

// Blend mode constants

///|
pub const BlendAlpha : Int = 0

///|
pub const BlendAdditive : Int = 1

///|
pub const BlendMultiplied : Int = 2

///|
pub const BlendCustom : Int = 6

// rlgl re-exports

///|
pub using @raylib {
  rl_set_blend_mode,
  rl_set_blend_factors,
  rl_draw_render_batch_active,
}

// ============================================================================
// VR stereo re-exports
// ============================================================================

///|
pub using @raylib {unload_vr_stereo_config, end_vr_stereo_mode}

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
  let arr = FixedArray::make(60, b'\x00')
  let (a, b, c, d) = write_int(info.h_resolution)
  arr[0] = a
  arr[1] = b
  arr[2] = c
  arr[3] = d
  let (a, b, c, d) = write_int(info.v_resolution)
  arr[4] = a
  arr[5] = b
  arr[6] = c
  arr[7] = d
  let (a, b, c, d) = write_float(info.h_screen_size)
  arr[8] = a
  arr[9] = b
  arr[10] = c
  arr[11] = d
  let (a, b, c, d) = write_float(info.v_screen_size)
  arr[12] = a
  arr[13] = b
  arr[14] = c
  arr[15] = d
  let (a, b, c, d) = write_float(info.eye_to_screen_distance)
  arr[16] = a
  arr[17] = b
  arr[18] = c
  arr[19] = d
  let (a, b, c, d) = write_float(info.lens_separation_distance)
  arr[20] = a
  arr[21] = b
  arr[22] = c
  arr[23] = d
  let (a, b, c, d) = write_float(info.interpupillary_distance)
  arr[24] = a
  arr[25] = b
  arr[26] = c
  arr[27] = d
  for i in 0..<4 {
    let (a, b, c, d) = write_float(info.lens_distortion_values[i])
    arr[28 + i * 4] = a
    arr[28 + i * 4 + 1] = b
    arr[28 + i * 4 + 2] = c
    arr[28 + i * 4 + 3] = d
  }
  for i in 0..<4 {
    let (a, b, c, d) = write_float(info.chroma_ab_correction[i])
    arr[44 + i * 4] = a
    arr[44 + i * 4 + 1] = b
    arr[44 + i * 4 + 2] = c
    arr[44 + i * 4 + 3] = d
  }
  FixedArray::unsafe_reinterpret_as_bytes(arr)
}

///|
pub fn load_vr_stereo_config(device : VrDeviceInfo) -> VrStereoConfig {
  @raylib.load_vr_stereo_config(device.to_bytes())
}

///|
pub fn begin_vr_stereo_mode(config : VrStereoConfig) -> Unit {
  @raylib.begin_vr_stereo_mode(config)
}

// VrStereoConfig field accessors (return raw Bytes for use with set_shader_value)

///|
pub fn vr_stereo_config_left_lens_center(config : VrStereoConfig) -> Bytes {
  @raylib.vr_stereo_config_left_lens_center(config)
}

///|
pub fn vr_stereo_config_right_lens_center(config : VrStereoConfig) -> Bytes {
  @raylib.vr_stereo_config_right_lens_center(config)
}

///|
pub fn vr_stereo_config_left_screen_center(config : VrStereoConfig) -> Bytes {
  @raylib.vr_stereo_config_left_screen_center(config)
}

///|
pub fn vr_stereo_config_right_screen_center(config : VrStereoConfig) -> Bytes {
  @raylib.vr_stereo_config_right_screen_center(config)
}

///|
pub fn vr_stereo_config_scale(config : VrStereoConfig) -> Bytes {
  @raylib.vr_stereo_config_scale(config)
}

///|
pub fn vr_stereo_config_scale_in(config : VrStereoConfig) -> Bytes {
  @raylib.vr_stereo_config_scale_in(config)
}
