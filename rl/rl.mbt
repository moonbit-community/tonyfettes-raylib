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
pub const Lines : Int = 0x0001

///|
pub const Triangles : Int = 0x0004

///|
pub const Quads : Int = 0x0007

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
