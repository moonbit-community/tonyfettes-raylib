// Deprecated rlgl re-exports — use tonyfettes/raylib/rl (@rl) instead.
// These will be removed in a future release.

// rlgl re-exports (passthrough)

///|
/// @deprecated Set blending mode.
#deprecated("Use @rl.set_blend_mode from tonyfettes/raylib/rl instead")
pub fn rl_set_blend_mode(mode : Int) -> Unit {
  @ffi.rl_set_blend_mode(mode)
}

///|
/// @deprecated Set blending mode factor and equation (using OpenGL factors).
#deprecated("Use @rl.set_blend_factors from tonyfettes/raylib/rl instead")
pub fn rl_set_blend_factors(
  gl_src_factor : Int,
  gl_dst_factor : Int,
  gl_equation : Int,
) -> Unit {
  @ffi.rl_set_blend_factors(gl_src_factor, gl_dst_factor, gl_equation)
}

///|
/// @deprecated Update and draw internal render batch.
#deprecated("Use @rl.draw_render_batch_active from tonyfettes/raylib/rl instead")
pub fn rl_draw_render_batch_active() -> Unit {
  @ffi.rl_draw_render_batch_active()
}

// Geometry submission

///|
/// @deprecated Initialize drawing mode (how to organize vertex).
#deprecated("Use @rl.begin from tonyfettes/raylib/rl instead")
pub fn rl_begin(mode : Int) -> Unit {
  @ffi.rl_begin(mode)
}

///|
/// @deprecated Finish vertex providing.
#deprecated("Use @rl.end_ from tonyfettes/raylib/rl instead")
pub fn rl_end() -> Unit {
  @ffi.rl_end()
}

///|
/// @deprecated Define one vertex (position) - 2 float.
#deprecated("Use @rl.vertex2f from tonyfettes/raylib/rl instead")
pub fn rl_vertex2f(x : Float, y : Float) -> Unit {
  @ffi.rl_vertex2f(x, y)
}

///|
/// @deprecated Define one vertex (position) - 3 float.
#deprecated("Use @rl.vertex3f from tonyfettes/raylib/rl instead")
pub fn rl_vertex3f(x : Float, y : Float, z : Float) -> Unit {
  @ffi.rl_vertex3f(x, y, z)
}

///|
/// @deprecated Define one vertex (texture coordinate) - 2 float.
#deprecated("Use @rl.tex_coord2f from tonyfettes/raylib/rl instead")
pub fn rl_tex_coord2f(x : Float, y : Float) -> Unit {
  @ffi.rl_tex_coord2f(x, y)
}

///|
/// @deprecated Define one vertex (color) - 4 byte.
#deprecated("Use @rl.color4ub from tonyfettes/raylib/rl instead")
pub fn rl_color4ub(r : Byte, g : Byte, b : Byte, a : Byte) -> Unit {
  @ffi.rl_color4ub(r, g, b, a)
}

///|
/// @deprecated Define one vertex (normal) - 3 float.
#deprecated("Use @rl.normal3f from tonyfettes/raylib/rl instead")
pub fn rl_normal3f(x : Float, y : Float, z : Float) -> Unit {
  @ffi.rl_normal3f(x, y, z)
}

///|
/// @deprecated Set current texture for render batch and check buffers limits.
#deprecated("Use @rl.set_texture from tonyfettes/raylib/rl instead")
pub fn rl_set_texture(id : UInt) -> Unit {
  @ffi.rl_set_texture(id)
}

// Matrix stack

///|
/// @deprecated Push the current matrix to stack.
#deprecated("Use @rl.push_matrix from tonyfettes/raylib/rl instead")
pub fn rl_push_matrix() -> Unit {
  @ffi.rl_push_matrix()
}

///|
/// @deprecated Pop latest inserted matrix from stack.
#deprecated("Use @rl.pop_matrix from tonyfettes/raylib/rl instead")
pub fn rl_pop_matrix() -> Unit {
  @ffi.rl_pop_matrix()
}

///|
/// @deprecated Multiply the current matrix by a translation matrix.
#deprecated("Use @rl.translatef from tonyfettes/raylib/rl instead")
pub fn rl_translatef(x : Float, y : Float, z : Float) -> Unit {
  @ffi.rl_translatef(x, y, z)
}

///|
/// @deprecated Multiply the current matrix by a rotation matrix.
#deprecated("Use @rl.rotatef from tonyfettes/raylib/rl instead")
pub fn rl_rotatef(angle : Float, x : Float, y : Float, z : Float) -> Unit {
  @ffi.rl_rotatef(angle, x, y, z)
}

///|
/// @deprecated Multiply the current matrix by a scaling matrix.
#deprecated("Use @rl.scalef from tonyfettes/raylib/rl instead")
pub fn rl_scalef(x : Float, y : Float, z : Float) -> Unit {
  @ffi.rl_scalef(x, y, z)
}

///|
/// @deprecated Multiply the current matrix by another matrix.
#deprecated("Use @rl.mult_matrixf from tonyfettes/raylib/rl instead")
pub fn rl_mult_matrixf(matf : Bytes) -> Unit {
  @ffi.rl_mult_matrixf(matf)
}

// State control

///|
/// @deprecated Enable backface culling.
#deprecated("Use @rl.enable_backface_culling from tonyfettes/raylib/rl instead")
pub fn rl_enable_backface_culling() -> Unit {
  @ffi.rl_enable_backface_culling()
}

///|
/// @deprecated Disable backface culling.
#deprecated("Use @rl.disable_backface_culling from tonyfettes/raylib/rl instead")
pub fn rl_disable_backface_culling() -> Unit {
  @ffi.rl_disable_backface_culling()
}

///|
/// @deprecated Check internal buffer overflow for a given number of vertex.
#deprecated("Use @rl.check_render_batch_limit from tonyfettes/raylib/rl instead")
pub fn rl_check_render_batch_limit(v_count : Int) -> Bool {
  @ffi.rl_check_render_batch_limit(v_count)
}

///|
/// @deprecated Enable depth test.
#deprecated("Use @rl.enable_depth_test from tonyfettes/raylib/rl instead")
pub fn rl_enable_depth_test() -> Unit {
  @ffi.rl_enable_depth_test()
}

///|
/// @deprecated Disable depth test.
#deprecated("Use @rl.disable_depth_test from tonyfettes/raylib/rl instead")
pub fn rl_disable_depth_test() -> Unit {
  @ffi.rl_disable_depth_test()
}

///|
/// @deprecated Enable depth write.
#deprecated("Use @rl.enable_depth_mask from tonyfettes/raylib/rl instead")
pub fn rl_enable_depth_mask() -> Unit {
  @ffi.rl_enable_depth_mask()
}

///|
/// @deprecated Disable depth write.
#deprecated("Use @rl.disable_depth_mask from tonyfettes/raylib/rl instead")
pub fn rl_disable_depth_mask() -> Unit {
  @ffi.rl_disable_depth_mask()
}

///|
/// @deprecated Enable color blending.
#deprecated("Use @rl.enable_color_blend from tonyfettes/raylib/rl instead")
pub fn rl_enable_color_blend() -> Unit {
  @ffi.rl_enable_color_blend()
}

///|
/// @deprecated Disable color blending.
#deprecated("Use @rl.disable_color_blend from tonyfettes/raylib/rl instead")
pub fn rl_disable_color_blend() -> Unit {
  @ffi.rl_disable_color_blend()
}

///|
/// @deprecated Select and active a texture slot.
#deprecated("Use @rl.active_texture_slot from tonyfettes/raylib/rl instead")
pub fn rl_active_texture_slot(slot : Int) -> Unit {
  @ffi.rl_active_texture_slot(slot)
}

///|
/// @deprecated Enable texture.
#deprecated("Use @rl.enable_texture from tonyfettes/raylib/rl instead")
pub fn rl_enable_texture(id : UInt) -> Unit {
  @ffi.rl_enable_texture(id)
}

///|
/// @deprecated Disable texture.
#deprecated("Use @rl.disable_texture from tonyfettes/raylib/rl instead")
pub fn rl_disable_texture() -> Unit {
  @ffi.rl_disable_texture()
}

///|
/// @deprecated Enable shader program.
#deprecated("Use @rl.enable_shader from tonyfettes/raylib/rl instead")
pub fn rl_enable_shader(id : UInt) -> Unit {
  @ffi.rl_enable_shader(id)
}

///|
/// @deprecated Disable shader program.
#deprecated("Use @rl.disable_shader from tonyfettes/raylib/rl instead")
pub fn rl_disable_shader() -> Unit {
  @ffi.rl_disable_shader()
}

///|
/// @deprecated Enable render texture (fbo).
#deprecated("Use @rl.enable_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_enable_framebuffer(id : UInt) -> Unit {
  @ffi.rl_enable_framebuffer(id)
}

///|
/// @deprecated Disable render texture (fbo), return to default framebuffer.
#deprecated("Use @rl.disable_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_disable_framebuffer() -> Unit {
  @ffi.rl_disable_framebuffer()
}

///|
/// @deprecated Activate multiple draw color buffers.
#deprecated("Use @rl.active_draw_buffers from tonyfettes/raylib/rl instead")
pub fn rl_active_draw_buffers(count : Int) -> Unit {
  @ffi.rl_active_draw_buffers(count)
}

///|
/// @deprecated Set the viewport area.
#deprecated("Use @rl.viewport from tonyfettes/raylib/rl instead")
pub fn rl_viewport(x : Int, y : Int, width : Int, height : Int) -> Unit {
  @ffi.rl_viewport(x, y, width, height)
}

///|
/// @deprecated Clear used screen buffers (color and depth).
#deprecated("Use @rl.clear_screen_buffers from tonyfettes/raylib/rl instead")
pub fn rl_clear_screen_buffers() -> Unit {
  @ffi.rl_clear_screen_buffers()
}

// Framebuffer management

///|
/// @deprecated Load an empty framebuffer.
#deprecated("Use @rl.load_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_load_framebuffer() -> UInt {
  @ffi.rl_load_framebuffer()
}

///|
/// @deprecated Verify framebuffer is complete.
#deprecated("Use @rl.framebuffer_complete from tonyfettes/raylib/rl instead")
pub fn rl_framebuffer_complete(id : UInt) -> Bool {
  @ffi.rl_framebuffer_complete(id)
}

///|
/// @deprecated Attach texture/renderbuffer to a framebuffer.
#deprecated("Use @rl.framebuffer_attach from tonyfettes/raylib/rl instead")
pub fn rl_framebuffer_attach(
  fbo_id : UInt,
  tex_id : UInt,
  attach_type : Int,
  tex_type : Int,
  mip_level : Int,
) -> Unit {
  @ffi.rl_framebuffer_attach(fbo_id, tex_id, attach_type, tex_type, mip_level)
}

///|
/// @deprecated Delete framebuffer from GPU.
#deprecated("Use @rl.unload_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_unload_framebuffer(id : UInt) -> Unit {
  @ffi.rl_unload_framebuffer(id)
}

// Texture management

///|
/// @deprecated Load depth texture/renderbuffer (to be attached to fbo).
#deprecated("Use @rl.load_texture_depth from tonyfettes/raylib/rl instead")
pub fn rl_load_texture_depth(
  width : Int,
  height : Int,
  use_render_buffer : Bool,
) -> UInt {
  @ffi.rl_load_texture_depth(width, height, use_render_buffer)
}

///|
/// @deprecated Load texture data.
#deprecated("Use @rl.load_texture from tonyfettes/raylib/rl instead")
pub fn rl_load_texture(
  width : Int,
  height : Int,
  format : Int,
  mipmap_count : Int,
) -> UInt {
  @ffi.rl_load_texture(width, height, format, mipmap_count)
}

///|
/// @deprecated Unload texture from GPU memory.
#deprecated("Use @rl.unload_texture from tonyfettes/raylib/rl instead")
pub fn rl_unload_texture(id : UInt) -> Unit {
  @ffi.rl_unload_texture(id)
}

// Shader management

///|
/// @deprecated Set shader value sampler.
#deprecated("Use @rl.set_uniform_sampler from tonyfettes/raylib/rl instead")
pub fn rl_set_uniform_sampler(loc_index : Int, texture_id : UInt) -> Unit {
  @ffi.rl_set_uniform_sampler(loc_index, texture_id)
}

///|
/// @deprecated Get default shader id.
#deprecated("Use @rl.get_shader_id_default from tonyfettes/raylib/rl instead")
pub fn rl_get_shader_id_default() -> UInt {
  @ffi.rl_get_shader_id_default()
}

///|
/// @deprecated Get shader location uniform.
#deprecated("Use @rl.get_location_uniform from tonyfettes/raylib/rl instead")
pub fn rl_get_location_uniform(shader_id : UInt, uniform_name : String) -> Int {
  @ffi.rl_get_location_uniform(shader_id, @utf8.encode(uniform_name))
}

// Draw helpers

///|
/// @deprecated Load and draw a quad.
#deprecated("Use @rl.load_draw_quad from tonyfettes/raylib/rl instead")
pub fn rl_load_draw_quad() -> Unit {
  @ffi.rl_load_draw_quad()
}

///|
/// @deprecated Load and draw a cube.
#deprecated("Use @rl.load_draw_cube from tonyfettes/raylib/rl instead")
pub fn rl_load_draw_cube() -> Unit {
  @ffi.rl_load_draw_cube()
}

// Misc

///|
/// @deprecated Get default framebuffer width.
#deprecated("Use @rl.get_framebuffer_width from tonyfettes/raylib/rl instead")
pub fn rl_get_framebuffer_width() -> Int {
  @ffi.rl_get_framebuffer_width()
}

///|
/// @deprecated Get default framebuffer height.
#deprecated("Use @rl.get_framebuffer_height from tonyfettes/raylib/rl instead")
pub fn rl_get_framebuffer_height() -> Int {
  @ffi.rl_get_framebuffer_height()
}

///|
/// @deprecated Bind framebuffer (FBO).
#deprecated("Use @rl.bind_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_bind_framebuffer(target : UInt, fbo : UInt) -> Unit {
  @ffi.rl_bind_framebuffer(target, fbo)
}

///|
/// @deprecated Blit active framebuffer to main framebuffer.
#deprecated("Use @rl.blit_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_blit_framebuffer(
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
  @ffi.rl_blit_framebuffer(
    src_x, src_y, src_w, src_h, dst_x, dst_y, dst_w, dst_h, buffer_mask,
  )
}

// Low-level uniform setting

///|
/// @deprecated Set shader value uniform.
#deprecated("Use @rl.set_uniform from tonyfettes/raylib/rl instead")
pub fn rl_set_uniform(
  loc_index : Int,
  value : Bytes,
  uniform_type : Int,
  count : Int,
) -> Unit {
  @ffi.rl_set_uniform(loc_index, value, uniform_type, count)
}

// Matrix getters

///|
/// @deprecated Get internal modelview matrix.
#deprecated("Use @rl.get_matrix_modelview from tonyfettes/raylib/rl instead")
pub fn rl_get_matrix_modelview() -> Matrix {
  Matrix::from_bytes(@ffi.rl_get_matrix_modelview())
}

///|
/// @deprecated Get internal projection matrix.
#deprecated("Use @rl.get_matrix_projection from tonyfettes/raylib/rl instead")
pub fn rl_get_matrix_projection() -> Matrix {
  Matrix::from_bytes(@ffi.rl_get_matrix_projection())
}

// rlgl draw mode constants

///|
/// @deprecated OpenGL draw mode: Lines.
#deprecated("Use @rl.Lines from tonyfettes/raylib/rl instead")
pub const RlLines : Int = 0x0001

///|
/// @deprecated OpenGL draw mode: Triangles.
#deprecated("Use @rl.Triangles from tonyfettes/raylib/rl instead")
pub const RlTriangles : Int = 0x0004

///|
/// @deprecated OpenGL draw mode: Quads.
#deprecated("Use @rl.Quads from tonyfettes/raylib/rl instead")
pub const RlQuads : Int = 0x0007

// rlgl framebuffer target constants

///|
/// @deprecated Framebuffer target: read framebuffer.
#deprecated("Use @rl.ReadFramebuffer from tonyfettes/raylib/rl instead")
pub const RlReadFramebuffer : UInt = 0x8CA8U

///|
/// @deprecated Framebuffer target: draw framebuffer.
#deprecated("Use @rl.DrawFramebuffer from tonyfettes/raylib/rl instead")
pub const RlDrawFramebuffer : UInt = 0x8CA9U

// rlgl framebuffer attach type constants

///|
/// @deprecated Framebuffer attach type: color channel 0.
#deprecated("Use @rl.AttachmentColorChannel0 from tonyfettes/raylib/rl instead")
pub const RlAttachmentColorChannel0 : Int = 0

///|
/// @deprecated Framebuffer attach type: color channel 1.
#deprecated("Use @rl.AttachmentColorChannel1 from tonyfettes/raylib/rl instead")
pub const RlAttachmentColorChannel1 : Int = 1

///|
/// @deprecated Framebuffer attach type: color channel 2.
#deprecated("Use @rl.AttachmentColorChannel2 from tonyfettes/raylib/rl instead")
pub const RlAttachmentColorChannel2 : Int = 2

///|
/// @deprecated Framebuffer attach type: color channel 3.
#deprecated("Use @rl.AttachmentColorChannel3 from tonyfettes/raylib/rl instead")
pub const RlAttachmentColorChannel3 : Int = 3

///|
/// @deprecated Framebuffer attach type: depth.
#deprecated("Use @rl.AttachmentDepth from tonyfettes/raylib/rl instead")
pub const RlAttachmentDepth : Int = 100

///|
/// @deprecated Framebuffer attach type: stencil.
#deprecated("Use @rl.AttachmentStencil from tonyfettes/raylib/rl instead")
pub const RlAttachmentStencil : Int = 200

// rlgl framebuffer texture type constants

///|
/// @deprecated Framebuffer texture type: cubemap positive X.
#deprecated("Use @rl.AttachmentCubemapPositiveX from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapPositiveX : Int = 0

///|
/// @deprecated Framebuffer texture type: cubemap negative X.
#deprecated("Use @rl.AttachmentCubemapNegativeX from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapNegativeX : Int = 1

///|
/// @deprecated Framebuffer texture type: cubemap positive Y.
#deprecated("Use @rl.AttachmentCubemapPositiveY from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapPositiveY : Int = 2

///|
/// @deprecated Framebuffer texture type: cubemap negative Y.
#deprecated("Use @rl.AttachmentCubemapNegativeY from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapNegativeY : Int = 3

///|
/// @deprecated Framebuffer texture type: cubemap positive Z.
#deprecated("Use @rl.AttachmentCubemapPositiveZ from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapPositiveZ : Int = 4

///|
/// @deprecated Framebuffer texture type: cubemap negative Z.
#deprecated("Use @rl.AttachmentCubemapNegativeZ from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapNegativeZ : Int = 5

///|
/// @deprecated Framebuffer texture type: texture 2D.
#deprecated("Use @rl.AttachmentTexture2d from tonyfettes/raylib/rl instead")
pub const RlAttachmentTexture2d : Int = 100

///|
/// @deprecated Framebuffer texture type: renderbuffer.
#deprecated("Use @rl.AttachmentRenderbuffer from tonyfettes/raylib/rl instead")
pub const RlAttachmentRenderbuffer : Int = 200
