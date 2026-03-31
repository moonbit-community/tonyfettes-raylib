// rlgl wrapper functions with rl_ prefix stripped

///|
pub fn set_blend_mode(mode : Int) -> Unit {
  @raylib.rl_set_blend_mode(mode)
}

///|
pub fn set_blend_factors(
  gl_src_factor : Int,
  gl_dst_factor : Int,
  gl_equation : Int,
) -> Unit {
  @raylib.rl_set_blend_factors(gl_src_factor, gl_dst_factor, gl_equation)
}

///|
pub fn draw_render_batch_active() -> Unit {
  @raylib.rl_draw_render_batch_active()
}

// Geometry submission

///|
pub fn begin(mode : Int) -> Unit {
  @raylib.rl_begin(mode)
}

///|
pub fn end_() -> Unit {
  @raylib.rl_end()
}

///|
pub fn vertex2f(x : Float, y : Float) -> Unit {
  @raylib.rl_vertex2f(x, y)
}

///|
pub fn vertex3f(x : Float, y : Float, z : Float) -> Unit {
  @raylib.rl_vertex3f(x, y, z)
}

///|
pub fn tex_coord2f(x : Float, y : Float) -> Unit {
  @raylib.rl_tex_coord2f(x, y)
}

///|
pub fn color4ub(r : Byte, g : Byte, b : Byte, a : Byte) -> Unit {
  @raylib.rl_color4ub(r, g, b, a)
}

///|
pub fn normal3f(x : Float, y : Float, z : Float) -> Unit {
  @raylib.rl_normal3f(x, y, z)
}

///|
pub fn set_texture(id : UInt) -> Unit {
  @raylib.rl_set_texture(id)
}

// Matrix stack

///|
pub fn push_matrix() -> Unit {
  @raylib.rl_push_matrix()
}

///|
pub fn pop_matrix() -> Unit {
  @raylib.rl_pop_matrix()
}

///|
pub fn translatef(x : Float, y : Float, z : Float) -> Unit {
  @raylib.rl_translatef(x, y, z)
}

///|
pub fn rotatef(angle : Float, x : Float, y : Float, z : Float) -> Unit {
  @raylib.rl_rotatef(angle, x, y, z)
}

///|
pub fn scalef(x : Float, y : Float, z : Float) -> Unit {
  @raylib.rl_scalef(x, y, z)
}

///|
pub fn mult_matrixf(matf : Bytes) -> Unit {
  @raylib.rl_mult_matrixf(matf)
}

// State control

///|
pub fn enable_backface_culling() -> Unit {
  @raylib.rl_enable_backface_culling()
}

///|
pub fn disable_backface_culling() -> Unit {
  @raylib.rl_disable_backface_culling()
}

///|
pub fn check_render_batch_limit(v_count : Int) -> Bool {
  @raylib.rl_check_render_batch_limit(v_count)
}

///|
pub fn enable_depth_test() -> Unit {
  @raylib.rl_enable_depth_test()
}

///|
pub fn disable_depth_test() -> Unit {
  @raylib.rl_disable_depth_test()
}

///|
pub fn enable_depth_mask() -> Unit {
  @raylib.rl_enable_depth_mask()
}

///|
pub fn disable_depth_mask() -> Unit {
  @raylib.rl_disable_depth_mask()
}

///|
pub fn enable_color_blend() -> Unit {
  @raylib.rl_enable_color_blend()
}

///|
pub fn disable_color_blend() -> Unit {
  @raylib.rl_disable_color_blend()
}

///|
pub fn active_texture_slot(slot : Int) -> Unit {
  @raylib.rl_active_texture_slot(slot)
}

///|
pub fn enable_texture(id : UInt) -> Unit {
  @raylib.rl_enable_texture(id)
}

///|
pub fn disable_texture() -> Unit {
  @raylib.rl_disable_texture()
}

///|
pub fn enable_shader(id : UInt) -> Unit {
  @raylib.rl_enable_shader(id)
}

///|
pub fn disable_shader() -> Unit {
  @raylib.rl_disable_shader()
}

///|
pub fn enable_framebuffer(id : UInt) -> Unit {
  @raylib.rl_enable_framebuffer(id)
}

///|
pub fn disable_framebuffer() -> Unit {
  @raylib.rl_disable_framebuffer()
}

///|
pub fn active_draw_buffers(count : Int) -> Unit {
  @raylib.rl_active_draw_buffers(count)
}

///|
pub fn viewport(x : Int, y : Int, width : Int, height : Int) -> Unit {
  @raylib.rl_viewport(x, y, width, height)
}

///|
pub fn clear_screen_buffers() -> Unit {
  @raylib.rl_clear_screen_buffers()
}

// Framebuffer management

///|
pub fn load_framebuffer() -> UInt {
  @raylib.rl_load_framebuffer()
}

///|
pub fn framebuffer_complete(id : UInt) -> Bool {
  @raylib.rl_framebuffer_complete(id)
}

///|
pub fn framebuffer_attach(
  fbo_id : UInt,
  tex_id : UInt,
  attach_type : Int,
  tex_type : Int,
  mip_level : Int,
) -> Unit {
  @raylib.rl_framebuffer_attach(
    fbo_id, tex_id, attach_type, tex_type, mip_level,
  )
}

///|
pub fn unload_framebuffer(id : UInt) -> Unit {
  @raylib.rl_unload_framebuffer(id)
}

// Texture management

///|
pub fn load_texture_depth(
  width : Int,
  height : Int,
  use_render_buffer : Bool,
) -> UInt {
  @raylib.rl_load_texture_depth(width, height, use_render_buffer)
}

///|
pub fn load_texture(
  width : Int,
  height : Int,
  format : Int,
  mipmap_count : Int,
) -> UInt {
  @raylib.rl_load_texture(width, height, format, mipmap_count)
}

///|
pub fn unload_texture(id : UInt) -> Unit {
  @raylib.rl_unload_texture(id)
}

// Shader management

///|
pub fn set_uniform_sampler(loc_index : Int, texture_id : UInt) -> Unit {
  @raylib.rl_set_uniform_sampler(loc_index, texture_id)
}

///|
pub fn get_shader_id_default() -> UInt {
  @raylib.rl_get_shader_id_default()
}

///|
pub fn get_location_uniform(shader_id : UInt, uniform_name : String) -> Int {
  @raylib.rl_get_location_uniform(shader_id, @utf8.encode(uniform_name))
}

// Draw helpers

///|
pub fn load_draw_quad() -> Unit {
  @raylib.rl_load_draw_quad()
}

///|
pub fn load_draw_cube() -> Unit {
  @raylib.rl_load_draw_cube()
}

// Misc

///|
pub fn get_framebuffer_width() -> Int {
  @raylib.rl_get_framebuffer_width()
}

///|
pub fn get_framebuffer_height() -> Int {
  @raylib.rl_get_framebuffer_height()
}

///|
pub fn bind_framebuffer(target : UInt, fbo : UInt) -> Unit {
  @raylib.rl_bind_framebuffer(target, fbo)
}

///|
pub fn blit_framebuffer(
  src_x : Int,
  src_y : Int,
  src_w : Int,
  src_h : Int,
  dst_x : Int,
  dst_y : Int,
  dst_w : Int,
  dst_h : Int,
  buffer_mask : Int,
) -> Unit {
  @raylib.rl_blit_framebuffer(
    src_x, src_y, src_w, src_h, dst_x, dst_y, dst_w, dst_h, buffer_mask,
  )
}

// Low-level uniform setting

///|
pub fn set_uniform(
  loc_index : Int,
  value : Bytes,
  uniform_type : Int,
  count : Int,
) -> Unit {
  @raylib.rl_set_uniform(loc_index, value, uniform_type, count)
}

// Matrix getters

///|
pub fn get_matrix_modelview() -> @root.Matrix {
  @root.Matrix::from_bytes(@raylib.rl_get_matrix_modelview())
}

///|
pub fn get_matrix_projection() -> @root.Matrix {
  @root.Matrix::from_bytes(@raylib.rl_get_matrix_projection())
}

// rlgl draw mode constants

///|
pub const Lines : Int = @raylib.RlLinesMode

///|
pub const Triangles : Int = @raylib.RlTrianglesMode

///|
pub const Quads : Int = @raylib.RlQuadsMode

// rlgl framebuffer target constants

///|
pub const ReadFramebuffer : UInt = 0x8CA8U

///|
pub const DrawFramebuffer : UInt = 0x8CA9U

// rlgl framebuffer attach type constants

///|
pub const AttachmentColorChannel0 : Int = 0

///|
pub const AttachmentColorChannel1 : Int = 1

///|
pub const AttachmentColorChannel2 : Int = 2

///|
pub const AttachmentColorChannel3 : Int = 3

///|
pub const AttachmentDepth : Int = 100

///|
pub const AttachmentStencil : Int = 200

// rlgl framebuffer texture type constants

///|
pub const AttachmentCubemapPositiveX : Int = 0

///|
pub const AttachmentCubemapNegativeX : Int = 1

///|
pub const AttachmentCubemapPositiveY : Int = 2

///|
pub const AttachmentCubemapNegativeY : Int = 3

///|
pub const AttachmentCubemapPositiveZ : Int = 4

///|
pub const AttachmentCubemapNegativeZ : Int = 5

///|
pub const AttachmentTexture2d : Int = 100

///|
pub const AttachmentRenderbuffer : Int = 200

// ============================================================================
// rlgl: Matrix operations
// ============================================================================

///|
/// Choose the current matrix to be transformed.
pub fn matrix_mode(mode : Int) -> Unit {
  @raylib.rl_matrix_mode(mode)
}

///|
/// Reset current matrix to identity matrix.
pub fn load_identity() -> Unit {
  @raylib.rl_load_identity()
}

///|
/// Set up a perspective projection matrix.
pub fn frustum(
  left : Double,
  right : Double,
  bottom : Double,
  top : Double,
  znear : Double,
  zfar : Double,
) -> Unit {
  @raylib.rl_frustum(left, right, bottom, top, znear, zfar)
}

///|
/// Set up an orthographic projection matrix.
pub fn ortho(
  left : Double,
  right : Double,
  bottom : Double,
  top : Double,
  znear : Double,
  zfar : Double,
) -> Unit {
  @raylib.rl_ortho(left, right, bottom, top, znear, zfar)
}

///|
/// Set clip planes distances.
pub fn set_clip_planes(near_plane : Double, far_plane : Double) -> Unit {
  @raylib.rl_set_clip_planes(near_plane, far_plane)
}

///|
/// Get cull plane distance near.
pub fn get_cull_distance_near() -> Double {
  @raylib.rl_get_cull_distance_near()
}

///|
/// Get cull plane distance far.
pub fn get_cull_distance_far() -> Double {
  @raylib.rl_get_cull_distance_far()
}

// ============================================================================
// rlgl: Vertex level (additional)
// ============================================================================

///|
/// Define one vertex (position) - 2 int.
pub fn vertex2i(x : Int, y : Int) -> Unit {
  @raylib.rl_vertex2i(x, y)
}

///|
/// Define one vertex (color) - 3 float.
pub fn color3f(x : Float, y : Float, z : Float) -> Unit {
  @raylib.rl_color3f(x, y, z)
}

///|
/// Define one vertex (color) - 4 float.
pub fn color4f(x : Float, y : Float, z : Float, w : Float) -> Unit {
  @raylib.rl_color4f(x, y, z, w)
}

// ============================================================================
// rlgl: Vertex buffers state
// ============================================================================

///|
/// Enable vertex array (VAO, if supported).
pub fn enable_vertex_array(vao_id : UInt) -> Bool {
  @raylib.rl_enable_vertex_array(vao_id)
}

///|
/// Disable vertex array (VAO, if supported).
pub fn disable_vertex_array() -> Unit {
  @raylib.rl_disable_vertex_array()
}

///|
/// Enable vertex buffer (VBO).
pub fn enable_vertex_buffer(id : UInt) -> Unit {
  @raylib.rl_enable_vertex_buffer(id)
}

///|
/// Disable vertex buffer (VBO).
pub fn disable_vertex_buffer() -> Unit {
  @raylib.rl_disable_vertex_buffer()
}

///|
/// Enable vertex buffer element (VBO element).
pub fn enable_vertex_buffer_element(id : UInt) -> Unit {
  @raylib.rl_enable_vertex_buffer_element(id)
}

///|
/// Disable vertex buffer element (VBO element).
pub fn disable_vertex_buffer_element() -> Unit {
  @raylib.rl_disable_vertex_buffer_element()
}

///|
/// Enable vertex attribute index.
pub fn enable_vertex_attribute(index : UInt) -> Unit {
  @raylib.rl_enable_vertex_attribute(index)
}

///|
/// Disable vertex attribute index.
pub fn disable_vertex_attribute(index : UInt) -> Unit {
  @raylib.rl_disable_vertex_attribute(index)
}

// ============================================================================
// rlgl: Textures state (additional)
// ============================================================================

///|
/// Enable texture cubemap.
pub fn enable_texture_cubemap(id : UInt) -> Unit {
  @raylib.rl_enable_texture_cubemap(id)
}

///|
/// Disable texture cubemap.
pub fn disable_texture_cubemap() -> Unit {
  @raylib.rl_disable_texture_cubemap()
}

///|
/// Set texture parameters (filter, wrap).
pub fn texture_parameters(id : UInt, param : Int, value : Int) -> Unit {
  @raylib.rl_texture_parameters(id, param, value)
}

///|
/// Set cubemap parameters (filter, wrap).
pub fn cubemap_parameters(id : UInt, param : Int, value : Int) -> Unit {
  @raylib.rl_cubemap_parameters(id, param, value)
}

// ============================================================================
// rlgl: Framebuffer state (additional)
// ============================================================================

///|
/// Get the currently active render texture (fbo), 0 for default framebuffer.
pub fn get_active_framebuffer() -> UInt {
  @raylib.rl_get_active_framebuffer()
}

// ============================================================================
// rlgl: General render state
// ============================================================================

///|
/// Set face culling mode.
pub fn set_cull_face(mode : Int) -> Unit {
  @raylib.rl_set_cull_face(mode)
}

///|
/// Enable scissor test.
pub fn enable_scissor_test() -> Unit {
  @raylib.rl_enable_scissor_test()
}

///|
/// Disable scissor test.
pub fn disable_scissor_test() -> Unit {
  @raylib.rl_disable_scissor_test()
}

///|
/// Scissor test.
pub fn scissor(x : Int, y : Int, width : Int, height : Int) -> Unit {
  @raylib.rl_scissor(x, y, width, height)
}

///|
/// Enable wire mode.
pub fn enable_wire_mode() -> Unit {
  @raylib.rl_enable_wire_mode()
}

///|
/// Enable point mode.
pub fn enable_point_mode() -> Unit {
  @raylib.rl_enable_point_mode()
}

///|
/// Disable wire (and point) mode.
pub fn disable_wire_mode() -> Unit {
  @raylib.rl_disable_wire_mode()
}

///|
/// Set the line drawing width.
pub fn set_line_width(width : Float) -> Unit {
  @raylib.rl_set_line_width(width)
}

///|
/// Get the line drawing width.
pub fn get_line_width() -> Float {
  @raylib.rl_get_line_width()
}

///|
/// Enable line aliasing.
pub fn enable_smooth_lines() -> Unit {
  @raylib.rl_enable_smooth_lines()
}

///|
/// Disable line aliasing.
pub fn disable_smooth_lines() -> Unit {
  @raylib.rl_disable_smooth_lines()
}

///|
/// Enable stereo rendering.
pub fn enable_stereo_render() -> Unit {
  @raylib.rl_enable_stereo_render()
}

///|
/// Disable stereo rendering.
pub fn disable_stereo_render() -> Unit {
  @raylib.rl_disable_stereo_render()
}

///|
/// Check if stereo render is enabled.
pub fn is_stereo_render_enabled() -> Bool {
  @raylib.rl_is_stereo_render_enabled()
}

///|
/// Clear color buffer with color.
pub fn clear_color(r : Byte, g : Byte, b : Byte, a : Byte) -> Unit {
  @raylib.rl_clear_color(r, g, b, a)
}

///|
/// Check and log OpenGL error codes.
pub fn check_errors() -> Unit {
  @raylib.rl_check_errors()
}

///|
/// Set blending mode factors and equations separately (using OpenGL factors).
pub fn set_blend_factors_separate(
  gl_src_rgb : Int,
  gl_dst_rgb : Int,
  gl_src_alpha : Int,
  gl_dst_alpha : Int,
  gl_eq_rgb : Int,
  gl_eq_alpha : Int,
) -> Unit {
  @raylib.rl_set_blend_factors_separate(
    gl_src_rgb, gl_dst_rgb, gl_src_alpha, gl_dst_alpha, gl_eq_rgb, gl_eq_alpha,
  )
}

///|
/// Color mask control.
pub fn color_mask(r : Bool, g : Bool, b : Bool, a : Bool) -> Unit {
  @raylib.rl_color_mask(r, g, b, a)
}

// ============================================================================
// rlgl: Init / version
// ============================================================================

///|
/// Get current OpenGL version.
pub fn get_version() -> Int {
  @raylib.rl_get_version()
}

///|
/// Set current framebuffer width.
pub fn set_framebuffer_width(width : Int) -> Unit {
  @raylib.rl_set_framebuffer_width(width)
}

///|
/// Set current framebuffer height.
pub fn set_framebuffer_height(height : Int) -> Unit {
  @raylib.rl_set_framebuffer_height(height)
}

// ============================================================================
// rlgl: Default resource
// ============================================================================

///|
/// Get default texture id.
pub fn get_texture_id_default() -> UInt {
  @raylib.rl_get_texture_id_default()
}

// ============================================================================
// rlgl: Vertex buffers management
// ============================================================================

///|
/// Load vertex array (vao) if supported.
pub fn load_vertex_array() -> UInt {
  @raylib.rl_load_vertex_array()
}

///|
/// Load a vertex buffer object. Size in bytes is auto-computed from the data.
pub fn load_vertex_buffer(data : Buffer, dynamic : Bool) -> UInt {
  let size = data.byte_size()
  @raylib.rl_load_vertex_buffer(data.to_pointer(), size, dynamic)
}

///|
/// Load vertex buffer elements object. Size in bytes is auto-computed.
pub fn load_vertex_buffer_element(data : Buffer, dynamic : Bool) -> UInt {
  let size = data.byte_size()
  @raylib.rl_load_vertex_buffer_element(data.to_pointer(), size, dynamic)
}

///|
/// Unload vertex array (vao).
pub fn unload_vertex_array(vao_id : UInt) -> Unit {
  @raylib.rl_unload_vertex_array(vao_id)
}

///|
/// Unload vertex buffer object.
pub fn unload_vertex_buffer(vbo_id : UInt) -> Unit {
  @raylib.rl_unload_vertex_buffer(vbo_id)
}

///|
/// Update vertex buffer object data on GPU buffer. Data size is auto-computed.
pub fn update_vertex_buffer(
  buffer_id : UInt,
  data : Buffer,
  offset : Int,
) -> Unit {
  let size = data.byte_size()
  @raylib.rl_update_vertex_buffer(buffer_id, data.to_pointer(), size, offset)
}

///|
/// Update vertex buffer elements data on GPU buffer. Data size is auto-computed.
pub fn update_vertex_buffer_elements(
  id : UInt,
  data : Buffer,
  offset : Int,
) -> Unit {
  let size = data.byte_size()
  @raylib.rl_update_vertex_buffer_elements(id, data.to_pointer(), size, offset)
}

///|
/// Set vertex attribute data divisor.
pub fn set_vertex_attribute_divisor(index : UInt, divisor : Int) -> Unit {
  @raylib.rl_set_vertex_attribute_divisor(index, divisor)
}

///|
/// Set vertex attribute data configuration.
pub fn set_vertex_attribute(
  index : UInt,
  comp_size : Int,
  type_ : Int,
  normalized : Bool,
  stride : Int,
  offset : Int,
) -> Unit {
  @raylib.rl_set_vertex_attribute(
    index, comp_size, type_, normalized, stride, offset,
  )
}

///|
/// Set vertex attribute default value, when attribute is not provided.
pub fn set_vertex_attribute_default(
  loc_index : Int,
  value : Buffer,
  attrib_type : Int,
  count : Int,
) -> Unit {
  @raylib.rl_set_vertex_attribute_default(
    loc_index,
    value.to_pointer(),
    attrib_type,
    count,
  )
}

///|
/// Draw vertex array (currently active vao).
pub fn draw_vertex_array(offset : Int, count : Int) -> Unit {
  @raylib.rl_draw_vertex_array(offset, count)
}

///|
/// Draw vertex array (currently active vao) with instancing.
pub fn draw_vertex_array_instanced(
  offset : Int,
  count : Int,
  instances : Int,
) -> Unit {
  @raylib.rl_draw_vertex_array_instanced(offset, count, instances)
}

///|
/// Draw vertex array elements. When `buffer` is `None`, uses the bound EBO
/// (the common path). When `buffer` is `Some(indices)`, uses client-side
/// index data (OpenGL ES 2.0 / OpenGL 1.1 path).
pub fn draw_vertex_array_elements(
  offset : Int,
  count : Int,
  buffer? : @root.UShortArray,
) -> Unit {
  match buffer {
    None => @raylib.rl_draw_vertex_array_elements(offset, count)
    Some(buf) =>
      @raylib.rl_draw_vertex_array_elements_client(offset, count, buf.pointer())
  }
}

///|
/// Draw vertex array elements with instancing. When `buffer` is `None`, uses
/// the bound EBO. When `buffer` is `Some(indices)`, uses client-side index data.
pub fn draw_vertex_array_elements_instanced(
  offset : Int,
  count : Int,
  instances : Int,
  buffer? : @root.UShortArray,
) -> Unit {
  match buffer {
    None =>
      @raylib.rl_draw_vertex_array_elements_instanced(offset, count, instances)
    Some(buf) =>
      @raylib.rl_draw_vertex_array_elements_instanced_client(
        offset,
        count,
        buf.pointer(),
        instances,
      )
  }
}

// ============================================================================
// rlgl: Textures management (additional)
// ============================================================================

///|
/// Load texture cubemap data.
pub fn load_texture_cubemap(
  data : Bytes,
  size : Int,
  format : Int,
  mipmap_count : Int,
) -> UInt {
  @raylib.rl_load_texture_cubemap(data, size, format, mipmap_count)
}

///|
/// Update texture with new data on GPU.
pub fn update_texture(
  id : UInt,
  offset_x : Int,
  offset_y : Int,
  width : Int,
  height : Int,
  format : Int,
  data : Bytes,
) -> Unit {
  @raylib.rl_update_texture(id, offset_x, offset_y, width, height, format, data)
}

// ============================================================================
// rlgl: Shader management (additional)
// ============================================================================

///|
/// Load shader from code strings.
pub fn load_shader_code(vs_code : String, fs_code : String) -> UInt {
  @raylib.rl_load_shader_code(@utf8.encode(vs_code), @utf8.encode(fs_code))
}

///|
/// Compile custom shader and return shader id.
pub fn compile_shader(shader_code : String, type_ : Int) -> UInt {
  @raylib.rl_compile_shader(@utf8.encode(shader_code), type_)
}

///|
/// Load custom shader program.
pub fn load_shader_program(v_shader_id : UInt, f_shader_id : UInt) -> UInt {
  @raylib.rl_load_shader_program(v_shader_id, f_shader_id)
}

///|
/// Unload shader program.
pub fn unload_shader_program(id : UInt) -> Unit {
  @raylib.rl_unload_shader_program(id)
}

///|
/// Get shader location attribute.
pub fn get_location_attrib(shader_id : UInt, attrib_name : String) -> Int {
  @raylib.rl_get_location_attrib(shader_id, @utf8.encode(attrib_name))
}

///|
/// Set shader value matrix.
pub fn set_uniform_matrix(loc_index : Int, mat : @root.Matrix) -> Unit {
  @raylib.rl_set_uniform_matrix(loc_index, mat.to_bytes())
}

///|
/// Set shader value matrices.
pub fn set_uniform_matrices(loc_index : Int, mat : Bytes, count : Int) -> Unit {
  @raylib.rl_set_uniform_matrices(loc_index, mat, count)
}

// ============================================================================
// rlgl: Compute shader
// ============================================================================

///|
/// Load compute shader program.
pub fn load_compute_shader_program(shader_id : UInt) -> UInt {
  @raylib.rl_load_compute_shader_program(shader_id)
}

///|
/// Dispatch compute shader (equivalent to draw for graphics pipeline).
pub fn compute_shader_dispatch(
  group_x : UInt,
  group_y : UInt,
  group_z : UInt,
) -> Unit {
  @raylib.rl_compute_shader_dispatch(group_x, group_y, group_z)
}

// ============================================================================
// rlgl: Shader storage buffer object (SSBO)
// ============================================================================

///|
/// Load shader storage buffer object (SSBO) with initial data.
/// Size in bytes is auto-computed from the data.
pub fn load_shader_buffer(data : Buffer, usage_hint : Int) -> UInt {
  let size = data.byte_size().reinterpret_as_uint()
  @raylib.rl_load_shader_buffer(size, data.to_pointer(), usage_hint)
}

///|
/// Load shader storage buffer object (SSBO) with no initial data.
pub fn load_shader_buffer_empty(size : UInt, usage_hint : Int) -> UInt {
  @raylib.rl_load_shader_buffer_empty(size, usage_hint)
}

///|
/// Unload shader storage buffer object (SSBO).
pub fn unload_shader_buffer(ssbo_id : UInt) -> Unit {
  @raylib.rl_unload_shader_buffer(ssbo_id)
}

///|
/// Update SSBO buffer data. Data size is auto-computed.
pub fn update_shader_buffer(id : UInt, data : Buffer, offset : UInt) -> Unit {
  let size = data.byte_size().reinterpret_as_uint()
  @raylib.rl_update_shader_buffer(id, data.to_pointer(), size, offset)
}

///|
/// Read SSBO buffer data (GPU->CPU).
pub fn read_shader_buffer(id : UInt, count : UInt, offset : UInt) -> Bytes {
  @raylib.rl_read_shader_buffer(id, count, offset)
}

///|
/// Bind SSBO buffer.
pub fn bind_shader_buffer(id : UInt, index : UInt) -> Unit {
  @raylib.rl_bind_shader_buffer(id, index)
}

///|
/// Copy SSBO data between buffers.
pub fn copy_shader_buffer(
  dest_id : UInt,
  src_id : UInt,
  dest_offset : UInt,
  src_offset : UInt,
  count : UInt,
) -> Unit {
  @raylib.rl_copy_shader_buffer(dest_id, src_id, dest_offset, src_offset, count)
}

///|
/// Get SSBO buffer size.
pub fn get_shader_buffer_size(id : UInt) -> UInt {
  @raylib.rl_get_shader_buffer_size(id)
}

// ============================================================================
// rlgl: Bind image texture
// ============================================================================

///|
/// Bind image texture.
pub fn bind_image_texture(
  id : UInt,
  index : UInt,
  format : Int,
  read_only : Bool,
) -> Unit {
  @raylib.rl_bind_image_texture(id, index, format, read_only)
}

// ============================================================================
// rlgl: Matrix setters
// ============================================================================

///|
/// Set a custom projection matrix (replaces internal projection matrix).
pub fn set_matrix_projection(proj : @root.Matrix) -> Unit {
  @raylib.rl_set_matrix_projection(proj.to_bytes())
}

///|
/// Set a custom modelview matrix (replaces internal modelview matrix).
pub fn set_matrix_modelview(view : @root.Matrix) -> Unit {
  @raylib.rl_set_matrix_modelview(view.to_bytes())
}

// ============================================================================
// rlgl: Matrix getters (additional)
// ============================================================================

///|
/// Get internal accumulated transform matrix.
pub fn get_matrix_transform() -> @root.Matrix {
  @root.Matrix::from_bytes(@raylib.rl_get_matrix_transform())
}

///|
/// Get internal projection matrix for stereo render (selected eye).
pub fn get_matrix_projection_stereo(eye : Int) -> @root.Matrix {
  @root.Matrix::from_bytes(@raylib.rl_get_matrix_projection_stereo(eye))
}

///|
/// Get internal view offset matrix for stereo render (selected eye).
pub fn get_matrix_view_offset_stereo(eye : Int) -> @root.Matrix {
  @root.Matrix::from_bytes(@raylib.rl_get_matrix_view_offset_stereo(eye))
}

// ============================================================================
// rlgl: Stereo matrix setters
// ============================================================================

///|
/// Set eyes projection matrices for stereo rendering.
pub fn set_matrix_projection_stereo(
  right : @root.Matrix,
  left : @root.Matrix,
) -> Unit {
  @raylib.rl_set_matrix_projection_stereo(right.to_bytes(), left.to_bytes())
}

///|
/// Set eyes view offsets matrices for stereo rendering.
pub fn set_matrix_view_offset_stereo(
  right : @root.Matrix,
  left : @root.Matrix,
) -> Unit {
  @raylib.rl_set_matrix_view_offset_stereo(right.to_bytes(), left.to_bytes())
}

// ============================================================================
// rlgl: Constants — Matrix modes
// ============================================================================

///|
/// GL_MODELVIEW matrix mode.
pub const Modelview : Int = 0x1700

///|
/// GL_PROJECTION matrix mode.
pub const Projection : Int = 0x1701

///|
/// GL_TEXTURE matrix mode.
pub const TextureMode : Int = 0x1702

// ============================================================================
// rlgl: Constants — Shader types
// ============================================================================

///|
/// GL_VERTEX_SHADER type.
pub const VertexShader : Int = 0x8B31

///|
/// GL_FRAGMENT_SHADER type.
pub const FragmentShader : Int = 0x8B30

///|
/// GL_COMPUTE_SHADER type.
pub const ComputeShader : Int = 0x91B9

// ============================================================================
// rlgl: Constants — Data types
// ============================================================================

///|
/// GL_UNSIGNED_BYTE data type.
pub const UnsignedByte : Int = 0x1401

///|
/// GL_FLOAT data type.
pub const FloatType : Int = 0x1406

// ============================================================================
// rlgl: Constants — Buffer usage hints
// ============================================================================

///|
/// GL_STREAM_DRAW buffer usage hint.
pub const StreamDraw : Int = 0x88E0

///|
/// GL_STREAM_READ buffer usage hint.
pub const StreamRead : Int = 0x88E1

///|
/// GL_STREAM_COPY buffer usage hint.
pub const StreamCopy : Int = 0x88E2

///|
/// GL_STATIC_DRAW buffer usage hint.
pub const StaticDraw : Int = 0x88E4

///|
/// GL_STATIC_READ buffer usage hint.
pub const StaticRead : Int = 0x88E5

///|
/// GL_STATIC_COPY buffer usage hint.
pub const StaticCopy : Int = 0x88E6

///|
/// GL_DYNAMIC_DRAW buffer usage hint.
pub const DynamicDraw : Int = 0x88E8

///|
/// GL_DYNAMIC_READ buffer usage hint.
pub const DynamicRead : Int = 0x88E9

///|
/// GL_DYNAMIC_COPY buffer usage hint.
pub const DynamicCopy : Int = 0x88EA

// ============================================================================
// rlgl: Constants — Texture params
// ============================================================================

///|
/// GL_TEXTURE_WRAP_S parameter.
pub const TextureWrapS : Int = 0x2802

///|
/// GL_TEXTURE_WRAP_T parameter.
pub const TextureWrapT : Int = 0x2803

///|
/// GL_TEXTURE_MAG_FILTER parameter.
pub const TextureMagFilter : Int = 0x2800

///|
/// GL_TEXTURE_MIN_FILTER parameter.
pub const TextureMinFilter : Int = 0x2801

///|
/// GL_NEAREST texture filter.
pub const TextureFilterNearest : Int = 0x2600

///|
/// GL_LINEAR texture filter.
pub const TextureFilterLinear : Int = 0x2601

///|
/// GL_NEAREST_MIPMAP_NEAREST texture filter.
pub const TextureFilterMipNearest : Int = 0x2700

///|
/// GL_NEAREST_MIPMAP_LINEAR texture filter.
pub const TextureFilterNearestMipLinear : Int = 0x2702

///|
/// GL_LINEAR_MIPMAP_NEAREST texture filter.
pub const TextureFilterLinearMipNearest : Int = 0x2701

///|
/// GL_LINEAR_MIPMAP_LINEAR texture filter.
pub const TextureFilterMipLinear : Int = 0x2703

///|
/// Anisotropic filter (custom identifier).
pub const TextureFilterAnisotropic : Int = 0x3000

///|
/// Texture mipmap bias, percentage ratio (custom identifier).
pub const TextureMipmapBiasRatio : Int = 0x4000

///|
/// GL_REPEAT texture wrap mode.
pub const TextureWrapRepeat : Int = 0x2901

///|
/// GL_CLAMP_TO_EDGE texture wrap mode.
pub const TextureWrapClamp : Int = 0x812F

///|
/// GL_MIRRORED_REPEAT texture wrap mode.
pub const TextureWrapMirrorRepeat : Int = 0x8370

///|
/// GL_MIRROR_CLAMP_EXT texture wrap mode.
pub const TextureWrapMirrorClamp : Int = 0x8742

// ============================================================================
// rlgl: Constants — Cull face modes
// ============================================================================

///|
/// Cull front faces.
pub const CullFaceFront : Int = 0

///|
/// Cull back faces.
pub const CullFaceBack : Int = 1

// ============================================================================
// rlgl: Constants — Blend factors
// ============================================================================

///|
/// GL_ZERO blend factor.
pub const Zero : Int = 0

///|
/// GL_ONE blend factor.
pub const One : Int = 1

///|
/// GL_SRC_COLOR blend factor.
pub const SrcColor : Int = 0x0300

///|
/// GL_ONE_MINUS_SRC_COLOR blend factor.
pub const OneMinusSrcColor : Int = 0x0301

///|
/// GL_SRC_ALPHA blend factor.
pub const SrcAlpha : Int = 0x0302

///|
/// GL_ONE_MINUS_SRC_ALPHA blend factor.
pub const OneMinusSrcAlpha : Int = 0x0303

///|
/// GL_DST_ALPHA blend factor.
pub const DstAlpha : Int = 0x0304

///|
/// GL_ONE_MINUS_DST_ALPHA blend factor.
pub const OneMinusDstAlpha : Int = 0x0305

///|
/// GL_DST_COLOR blend factor.
pub const DstColor : Int = 0x0306

///|
/// GL_ONE_MINUS_DST_COLOR blend factor.
pub const OneMinusDstColor : Int = 0x0307

///|
/// GL_SRC_ALPHA_SATURATE blend factor.
pub const SrcAlphaSaturate : Int = 0x0308

///|
/// GL_CONSTANT_COLOR blend factor.
pub const ConstantColor : Int = 0x8001

///|
/// GL_ONE_MINUS_CONSTANT_COLOR blend factor.
pub const OneMinusConstantColor : Int = 0x8002

///|
/// GL_CONSTANT_ALPHA blend factor.
pub const ConstantAlpha : Int = 0x8003

///|
/// GL_ONE_MINUS_CONSTANT_ALPHA blend factor.
pub const OneMinusConstantAlpha : Int = 0x8004

// ============================================================================
// rlgl: Constants — Blend equations
// ============================================================================

///|
/// GL_FUNC_ADD blend equation.
pub const FuncAdd : Int = 0x8006

///|
/// GL_MIN blend equation.
pub const Min : Int = 0x8007

///|
/// GL_MAX blend equation.
pub const Max : Int = 0x8008

///|
/// GL_FUNC_SUBTRACT blend equation.
pub const FuncSubtract : Int = 0x800A

///|
/// GL_FUNC_REVERSE_SUBTRACT blend equation.
pub const FuncReverseSubtract : Int = 0x800B

///|
/// GL_BLEND_EQUATION blend state.
pub const BlendEquation : Int = 0x8009

///|
/// GL_BLEND_EQUATION_RGB blend state (same as BlendEquation).
pub const BlendEquationRgb : Int = 0x8009

///|
/// GL_BLEND_EQUATION_ALPHA blend state.
pub const BlendEquationAlpha : Int = 0x883D

///|
/// GL_BLEND_DST_RGB blend state.
pub const BlendDstRgb : Int = 0x80C8

///|
/// GL_BLEND_SRC_RGB blend state.
pub const BlendSrcRgb : Int = 0x80C9

///|
/// GL_BLEND_DST_ALPHA blend state.
pub const BlendDstAlpha : Int = 0x80CA

///|
/// GL_BLEND_SRC_ALPHA blend state.
pub const BlendSrcAlpha : Int = 0x80CB

///|
/// GL_BLEND_COLOR blend state.
pub const BlendColor : Int = 0x8005
