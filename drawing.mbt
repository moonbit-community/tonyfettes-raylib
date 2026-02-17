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
pub fn set_shader_location(shader : Shader, loc_index : Int, value : Int) -> Unit {
  @raylib.set_shader_location(shader, loc_index, value)
}

///|
pub fn get_shader_id(shader : Shader) -> Int {
  @raylib.get_shader_id(shader)
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

///|
pub fn rl_get_location_uniform(shader_id : UInt, uniform_name : String) -> Int {
  @raylib.rl_get_location_uniform(shader_id, @utf8.encode(uniform_name))
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

///|
pub let shader_loc_map_albedo : Int = 15

///|
pub let shader_loc_map_metalness : Int = 16

///|
pub let shader_loc_map_normal : Int = 17

///|
pub let shader_loc_map_roughness : Int = 18

///|
pub let shader_loc_map_occlusion : Int = 19

///|
pub let shader_loc_map_emission : Int = 20

///|
pub let shader_loc_map_height : Int = 21

///|
pub let shader_loc_map_cubemap : Int = 22

///|
pub let shader_loc_map_irradiance : Int = 23

///|
pub let shader_loc_map_prefilter : Int = 24

///|
pub let shader_loc_map_brdf : Int = 25

///|
pub let shader_loc_vertex_boneids : Int = 26

///|
pub let shader_loc_vertex_boneweights : Int = 27

///|
pub let shader_loc_bone_matrices : Int = 28
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
  // rlgl: Geometry submission
  rl_begin,
  rl_end,
  rl_vertex2f,
  rl_vertex3f,
  rl_tex_coord2f,
  rl_color4ub,
  rl_normal3f,
  rl_set_texture,
  // rlgl: Matrix stack
  rl_push_matrix,
  rl_pop_matrix,
  rl_translatef,
  rl_rotatef,
  rl_scalef,
  rl_mult_matrixf,
  // rlgl: State control
  rl_enable_backface_culling,
  rl_disable_backface_culling,
  rl_check_render_batch_limit,
  rl_enable_depth_test,
  rl_disable_depth_test,
  rl_enable_depth_mask,
  rl_disable_depth_mask,
  rl_enable_color_blend,
  rl_disable_color_blend,
  rl_active_texture_slot,
  rl_enable_texture,
  rl_disable_texture,
  rl_enable_shader,
  rl_disable_shader,
  rl_enable_framebuffer,
  rl_disable_framebuffer,
  rl_active_draw_buffers,
  rl_viewport,
  rl_clear_screen_buffers,
  // rlgl: Framebuffer management
  rl_load_framebuffer,
  rl_framebuffer_complete,
  rl_framebuffer_attach,
  rl_unload_framebuffer,
  // rlgl: Texture management
  rl_load_texture_depth,
  rl_load_texture,
  rl_unload_texture,
  // rlgl: Shader management
  rl_set_uniform_sampler,
  rl_get_shader_id_default,
  // rlgl: Draw helpers
  rl_load_draw_quad,
  rl_load_draw_cube,
  // rlgl: Misc
  rl_get_framebuffer_width,
  rl_get_framebuffer_height,
  rl_bind_framebuffer,
  rl_blit_framebuffer,
  // rlgl: Low-level uniform setting
  rl_set_uniform,
}

// rlgl: Matrix getters (wrappers returning Matrix value type)

///|
pub fn rl_get_matrix_modelview() -> Matrix {
  Matrix::from_bytes(@raylib.rl_get_matrix_modelview())
}

///|
pub fn rl_get_matrix_projection() -> Matrix {
  Matrix::from_bytes(@raylib.rl_get_matrix_projection())
}

// rlgl draw mode constants

///|
pub let rl_lines : Int = 0x0001

///|
pub let rl_triangles : Int = 0x0004

///|
pub let rl_quads : Int = 0x0007

// rlgl framebuffer target constants

///|
pub let rl_read_framebuffer : UInt = 0x8CA8U

///|
pub let rl_draw_framebuffer : UInt = 0x8CA9U

// rlgl framebuffer attach type constants

///|
pub let rl_attachment_color_channel0 : Int = 0

///|
pub let rl_attachment_color_channel1 : Int = 1

///|
pub let rl_attachment_color_channel2 : Int = 2

///|
pub let rl_attachment_color_channel3 : Int = 3

///|
pub let rl_attachment_depth : Int = 100

///|
pub let rl_attachment_stencil : Int = 200

// rlgl framebuffer texture type constants

///|
pub let rl_attachment_cubemap_positive_x : Int = 0

///|
pub let rl_attachment_cubemap_negative_x : Int = 1

///|
pub let rl_attachment_cubemap_positive_y : Int = 2

///|
pub let rl_attachment_cubemap_negative_y : Int = 3

///|
pub let rl_attachment_cubemap_positive_z : Int = 4

///|
pub let rl_attachment_cubemap_negative_z : Int = 5

///|
pub let rl_attachment_texture2d : Int = 100

///|
pub let rl_attachment_renderbuffer : Int = 200

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
