// Deprecated rlgl re-exports — use tonyfettes/raylib/rl (@rl) instead.
// These will be removed in a future release.

// rlgl re-exports (passthrough)

///|
#deprecated("Use @rl.set_blend_mode from tonyfettes/raylib/rl instead")
pub fn rl_set_blend_mode(mode : Int) -> Unit {
  @ffi.rl_set_blend_mode(mode)
}

///|
#deprecated("Use @rl.set_blend_factors from tonyfettes/raylib/rl instead")
pub fn rl_set_blend_factors(
  gl_src_factor : Int,
  gl_dst_factor : Int,
  gl_equation : Int,
) -> Unit {
  @ffi.rl_set_blend_factors(gl_src_factor, gl_dst_factor, gl_equation)
}

///|
#deprecated("Use @rl.draw_render_batch_active from tonyfettes/raylib/rl instead")
pub fn rl_draw_render_batch_active() -> Unit {
  @ffi.rl_draw_render_batch_active()
}

// Geometry submission

///|
#deprecated("Use @rl.begin from tonyfettes/raylib/rl instead")
pub fn rl_begin(mode : Int) -> Unit {
  @ffi.rl_begin(mode)
}

///|
#deprecated("Use @rl.end_ from tonyfettes/raylib/rl instead")
pub fn rl_end() -> Unit {
  @ffi.rl_end()
}

///|
#deprecated("Use @rl.vertex2f from tonyfettes/raylib/rl instead")
pub fn rl_vertex2f(x : Float, y : Float) -> Unit {
  @ffi.rl_vertex2f(x, y)
}

///|
#deprecated("Use @rl.vertex3f from tonyfettes/raylib/rl instead")
pub fn rl_vertex3f(x : Float, y : Float, z : Float) -> Unit {
  @ffi.rl_vertex3f(x, y, z)
}

///|
#deprecated("Use @rl.tex_coord2f from tonyfettes/raylib/rl instead")
pub fn rl_tex_coord2f(x : Float, y : Float) -> Unit {
  @ffi.rl_tex_coord2f(x, y)
}

///|
#deprecated("Use @rl.color4ub from tonyfettes/raylib/rl instead")
pub fn rl_color4ub(r : Byte, g : Byte, b : Byte, a : Byte) -> Unit {
  @ffi.rl_color4ub(r, g, b, a)
}

///|
#deprecated("Use @rl.normal3f from tonyfettes/raylib/rl instead")
pub fn rl_normal3f(x : Float, y : Float, z : Float) -> Unit {
  @ffi.rl_normal3f(x, y, z)
}

///|
#deprecated("Use @rl.set_texture from tonyfettes/raylib/rl instead")
pub fn rl_set_texture(id : UInt) -> Unit {
  @ffi.rl_set_texture(id)
}

// Matrix stack

///|
#deprecated("Use @rl.push_matrix from tonyfettes/raylib/rl instead")
pub fn rl_push_matrix() -> Unit {
  @ffi.rl_push_matrix()
}

///|
#deprecated("Use @rl.pop_matrix from tonyfettes/raylib/rl instead")
pub fn rl_pop_matrix() -> Unit {
  @ffi.rl_pop_matrix()
}

///|
#deprecated("Use @rl.translatef from tonyfettes/raylib/rl instead")
pub fn rl_translatef(x : Float, y : Float, z : Float) -> Unit {
  @ffi.rl_translatef(x, y, z)
}

///|
#deprecated("Use @rl.rotatef from tonyfettes/raylib/rl instead")
pub fn rl_rotatef(angle : Float, x : Float, y : Float, z : Float) -> Unit {
  @ffi.rl_rotatef(angle, x, y, z)
}

///|
#deprecated("Use @rl.scalef from tonyfettes/raylib/rl instead")
pub fn rl_scalef(x : Float, y : Float, z : Float) -> Unit {
  @ffi.rl_scalef(x, y, z)
}

///|
#deprecated("Use @rl.mult_matrixf from tonyfettes/raylib/rl instead")
pub fn rl_mult_matrixf(matf : Bytes) -> Unit {
  @ffi.rl_mult_matrixf(matf)
}

// State control

///|
#deprecated("Use @rl.enable_backface_culling from tonyfettes/raylib/rl instead")
pub fn rl_enable_backface_culling() -> Unit {
  @ffi.rl_enable_backface_culling()
}

///|
#deprecated("Use @rl.disable_backface_culling from tonyfettes/raylib/rl instead")
pub fn rl_disable_backface_culling() -> Unit {
  @ffi.rl_disable_backface_culling()
}

///|
#deprecated("Use @rl.check_render_batch_limit from tonyfettes/raylib/rl instead")
pub fn rl_check_render_batch_limit(v_count : Int) -> Bool {
  @ffi.rl_check_render_batch_limit(v_count)
}

///|
#deprecated("Use @rl.enable_depth_test from tonyfettes/raylib/rl instead")
pub fn rl_enable_depth_test() -> Unit {
  @ffi.rl_enable_depth_test()
}

///|
#deprecated("Use @rl.disable_depth_test from tonyfettes/raylib/rl instead")
pub fn rl_disable_depth_test() -> Unit {
  @ffi.rl_disable_depth_test()
}

///|
#deprecated("Use @rl.enable_depth_mask from tonyfettes/raylib/rl instead")
pub fn rl_enable_depth_mask() -> Unit {
  @ffi.rl_enable_depth_mask()
}

///|
#deprecated("Use @rl.disable_depth_mask from tonyfettes/raylib/rl instead")
pub fn rl_disable_depth_mask() -> Unit {
  @ffi.rl_disable_depth_mask()
}

///|
#deprecated("Use @rl.enable_color_blend from tonyfettes/raylib/rl instead")
pub fn rl_enable_color_blend() -> Unit {
  @ffi.rl_enable_color_blend()
}

///|
#deprecated("Use @rl.disable_color_blend from tonyfettes/raylib/rl instead")
pub fn rl_disable_color_blend() -> Unit {
  @ffi.rl_disable_color_blend()
}

///|
#deprecated("Use @rl.active_texture_slot from tonyfettes/raylib/rl instead")
pub fn rl_active_texture_slot(slot : Int) -> Unit {
  @ffi.rl_active_texture_slot(slot)
}

///|
#deprecated("Use @rl.enable_texture from tonyfettes/raylib/rl instead")
pub fn rl_enable_texture(id : UInt) -> Unit {
  @ffi.rl_enable_texture(id)
}

///|
#deprecated("Use @rl.disable_texture from tonyfettes/raylib/rl instead")
pub fn rl_disable_texture() -> Unit {
  @ffi.rl_disable_texture()
}

///|
#deprecated("Use @rl.enable_shader from tonyfettes/raylib/rl instead")
pub fn rl_enable_shader(id : UInt) -> Unit {
  @ffi.rl_enable_shader(id)
}

///|
#deprecated("Use @rl.disable_shader from tonyfettes/raylib/rl instead")
pub fn rl_disable_shader() -> Unit {
  @ffi.rl_disable_shader()
}

///|
#deprecated("Use @rl.enable_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_enable_framebuffer(id : UInt) -> Unit {
  @ffi.rl_enable_framebuffer(id)
}

///|
#deprecated("Use @rl.disable_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_disable_framebuffer() -> Unit {
  @ffi.rl_disable_framebuffer()
}

///|
#deprecated("Use @rl.active_draw_buffers from tonyfettes/raylib/rl instead")
pub fn rl_active_draw_buffers(count : Int) -> Unit {
  @ffi.rl_active_draw_buffers(count)
}

///|
#deprecated("Use @rl.viewport from tonyfettes/raylib/rl instead")
pub fn rl_viewport(x : Int, y : Int, width : Int, height : Int) -> Unit {
  @ffi.rl_viewport(x, y, width, height)
}

///|
#deprecated("Use @rl.clear_screen_buffers from tonyfettes/raylib/rl instead")
pub fn rl_clear_screen_buffers() -> Unit {
  @ffi.rl_clear_screen_buffers()
}

// Framebuffer management

///|
#deprecated("Use @rl.load_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_load_framebuffer() -> UInt {
  @ffi.rl_load_framebuffer()
}

///|
#deprecated("Use @rl.framebuffer_complete from tonyfettes/raylib/rl instead")
pub fn rl_framebuffer_complete(id : UInt) -> Bool {
  @ffi.rl_framebuffer_complete(id)
}

///|
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
#deprecated("Use @rl.unload_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_unload_framebuffer(id : UInt) -> Unit {
  @ffi.rl_unload_framebuffer(id)
}

// Texture management

///|
#deprecated("Use @rl.load_texture_depth from tonyfettes/raylib/rl instead")
pub fn rl_load_texture_depth(
  width : Int,
  height : Int,
  use_render_buffer : Bool,
) -> UInt {
  @ffi.rl_load_texture_depth(width, height, use_render_buffer)
}

///|
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
#deprecated("Use @rl.unload_texture from tonyfettes/raylib/rl instead")
pub fn rl_unload_texture(id : UInt) -> Unit {
  @ffi.rl_unload_texture(id)
}

// Shader management

///|
#deprecated("Use @rl.set_uniform_sampler from tonyfettes/raylib/rl instead")
pub fn rl_set_uniform_sampler(loc_index : Int, texture_id : UInt) -> Unit {
  @ffi.rl_set_uniform_sampler(loc_index, texture_id)
}

///|
#deprecated("Use @rl.get_shader_id_default from tonyfettes/raylib/rl instead")
pub fn rl_get_shader_id_default() -> UInt {
  @ffi.rl_get_shader_id_default()
}

///|
#deprecated("Use @rl.get_location_uniform from tonyfettes/raylib/rl instead")
pub fn rl_get_location_uniform(shader_id : UInt, uniform_name : String) -> Int {
  @ffi.rl_get_location_uniform(shader_id, @utf8.encode(uniform_name))
}

// Draw helpers

///|
#deprecated("Use @rl.load_draw_quad from tonyfettes/raylib/rl instead")
pub fn rl_load_draw_quad() -> Unit {
  @ffi.rl_load_draw_quad()
}

///|
#deprecated("Use @rl.load_draw_cube from tonyfettes/raylib/rl instead")
pub fn rl_load_draw_cube() -> Unit {
  @ffi.rl_load_draw_cube()
}

// Misc

///|
#deprecated("Use @rl.get_framebuffer_width from tonyfettes/raylib/rl instead")
pub fn rl_get_framebuffer_width() -> Int {
  @ffi.rl_get_framebuffer_width()
}

///|
#deprecated("Use @rl.get_framebuffer_height from tonyfettes/raylib/rl instead")
pub fn rl_get_framebuffer_height() -> Int {
  @ffi.rl_get_framebuffer_height()
}

///|
#deprecated("Use @rl.bind_framebuffer from tonyfettes/raylib/rl instead")
pub fn rl_bind_framebuffer(target : UInt, fbo : UInt) -> Unit {
  @ffi.rl_bind_framebuffer(target, fbo)
}

///|
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
#deprecated("Use @rl.get_matrix_modelview from tonyfettes/raylib/rl instead")
pub fn rl_get_matrix_modelview() -> Matrix {
  Matrix::from_bytes(@ffi.rl_get_matrix_modelview())
}

///|
#deprecated("Use @rl.get_matrix_projection from tonyfettes/raylib/rl instead")
pub fn rl_get_matrix_projection() -> Matrix {
  Matrix::from_bytes(@ffi.rl_get_matrix_projection())
}

// rlgl draw mode constants

///|
#deprecated("Use @rl.Lines from tonyfettes/raylib/rl instead")
pub const RlLines : Int = 0x0001

///|
#deprecated("Use @rl.Triangles from tonyfettes/raylib/rl instead")
pub const RlTriangles : Int = 0x0004

///|
#deprecated("Use @rl.Quads from tonyfettes/raylib/rl instead")
pub const RlQuads : Int = 0x0007

// rlgl framebuffer target constants

///|
#deprecated("Use @rl.ReadFramebuffer from tonyfettes/raylib/rl instead")
pub const RlReadFramebuffer : UInt = 0x8CA8U

///|
#deprecated("Use @rl.DrawFramebuffer from tonyfettes/raylib/rl instead")
pub const RlDrawFramebuffer : UInt = 0x8CA9U

// rlgl framebuffer attach type constants

///|
#deprecated("Use @rl.AttachmentColorChannel0 from tonyfettes/raylib/rl instead")
pub const RlAttachmentColorChannel0 : Int = 0

///|
#deprecated("Use @rl.AttachmentColorChannel1 from tonyfettes/raylib/rl instead")
pub const RlAttachmentColorChannel1 : Int = 1

///|
#deprecated("Use @rl.AttachmentColorChannel2 from tonyfettes/raylib/rl instead")
pub const RlAttachmentColorChannel2 : Int = 2

///|
#deprecated("Use @rl.AttachmentColorChannel3 from tonyfettes/raylib/rl instead")
pub const RlAttachmentColorChannel3 : Int = 3

///|
#deprecated("Use @rl.AttachmentDepth from tonyfettes/raylib/rl instead")
pub const RlAttachmentDepth : Int = 100

///|
#deprecated("Use @rl.AttachmentStencil from tonyfettes/raylib/rl instead")
pub const RlAttachmentStencil : Int = 200

// rlgl framebuffer texture type constants

///|
#deprecated("Use @rl.AttachmentCubemapPositiveX from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapPositiveX : Int = 0

///|
#deprecated("Use @rl.AttachmentCubemapNegativeX from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapNegativeX : Int = 1

///|
#deprecated("Use @rl.AttachmentCubemapPositiveY from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapPositiveY : Int = 2

///|
#deprecated("Use @rl.AttachmentCubemapNegativeY from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapNegativeY : Int = 3

///|
#deprecated("Use @rl.AttachmentCubemapPositiveZ from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapPositiveZ : Int = 4

///|
#deprecated("Use @rl.AttachmentCubemapNegativeZ from tonyfettes/raylib/rl instead")
pub const RlAttachmentCubemapNegativeZ : Int = 5

///|
#deprecated("Use @rl.AttachmentTexture2d from tonyfettes/raylib/rl instead")
pub const RlAttachmentTexture2d : Int = 100

///|
#deprecated("Use @rl.AttachmentRenderbuffer from tonyfettes/raylib/rl instead")
pub const RlAttachmentRenderbuffer : Int = 200
