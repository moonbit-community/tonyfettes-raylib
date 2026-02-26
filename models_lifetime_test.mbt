// Tests for Issue 1: non-owning view wrappers and parent lifetime.
// The incref/decref fix ensures views keep their parent alive during GC.
// Full verification requires ASan; these are smoke tests.

///|
test "mesh view from model: basic access works" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")

  let mesh = gen_mesh_cube(1.0, 1.0, 1.0)
  let model = load_model_from_mesh(mesh)
  let mesh_view = get_model_mesh(model, 0)

  // Access mesh view while model is alive - should work
  let bbox = get_mesh_bounding_box(mesh_view)
  assert_true(bbox.min.x <= bbox.max.x)

  close_window()
}

///|
test "material view from model: basic access works" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")

  let mesh = gen_mesh_cube(1.0, 1.0, 1.0)
  let model = load_model_from_mesh(mesh)
  let material_view = get_model_material(model, 0)

  // Access material view while model is alive - should work
  let valid = is_material_valid(material_view)
  assert_true(valid)

  close_window()
}

///|
test "font texture view: basic access works" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")

  let font = get_font_default()
  let tex_view = get_font_texture(font)

  // Access texture view while font is alive - should work
  assert_true(is_texture_valid(tex_view))

  close_window()
}

///|
test "render texture view: basic access works" {
  set_config_flags(FlagWindowHidden)
  init_window(1, 1, "test")

  let rt = load_render_texture(16, 16)
  let tex_view = get_render_texture_texture(rt)

  // Access texture view while render texture is alive - should work
  assert_true(is_texture_valid(tex_view))

  close_window()
}
