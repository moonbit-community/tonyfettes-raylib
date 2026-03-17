// Tests for Issue 1: non-owning view wrappers and parent lifetime.
// The incref/decref fix ensures views keep their parent alive during GC.
// Full verification requires ASan; these are smoke tests.

///|
test "mesh view from model: basic access works" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")

  let mesh = @raylib.Mesh::gen_cube(1.0, 1.0, 1.0)
  let model = @raylib.Model::load_from_mesh(mesh)
  let mesh_view = model.mesh(0)

  // Access mesh view while model is alive - should work
  let bbox = mesh_view.bounding_box()
  assert_true(bbox.min.x <= bbox.max.x)

  @raylib.close_window()
}

///|
test "material view from model: basic access works" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")

  let mesh = @raylib.Mesh::gen_cube(1.0, 1.0, 1.0)
  let model = @raylib.Model::load_from_mesh(mesh)
  let material_view = model.material(0)

  // Access material view while model is alive - should work
  let valid = material_view.is_valid()
  assert_true(valid)

  @raylib.close_window()
}

///|
test "font texture view: basic access works" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")

  let font = @raylib.Font::default()
  let tex_view = font.texture()

  // Access texture view while font is alive - should work
  assert_true(tex_view.width() > 0)

  @raylib.close_window()
}

///|
test "render texture view: basic access works" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")

  let rt = @raylib.RenderTexture::load(16, 16)
  let tex_view = rt.texture()

  // Access texture view while render texture is alive - should work
  assert_true(tex_view.width() > 0)

  @raylib.close_window()
}
