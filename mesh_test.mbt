// Tests for Mesh::new, field accessors, and typed array round-trips.

///|
test "Mesh::new sets vertex_count and triangle_count" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  // A single triangle: 3 vertices, no indices
  let vertices : FixedArray[Float] = [
    0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0,
  ]
  let mesh = @raylib.Mesh::new(vertices)
  assert_eq(mesh.vertex_count(), 3)
  assert_eq(mesh.triangle_count(), 1)
  mesh.unload()
  @raylib.close_window()
}

///|
test "Mesh::new with indices" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  // A quad: 4 vertices, 2 triangles via indices
  let vertices : FixedArray[Float] = [
    0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0,
  ]
  let indices : FixedArray[UInt16] = [0, 1, 2, 0, 2, 3]
  let mesh = @raylib.Mesh::new(vertices, indices=indices)
  assert_eq(mesh.vertex_count(), 4)
  assert_eq(mesh.triangle_count(), 2)
  mesh.unload()
  @raylib.close_window()
}

///|
test "Mesh vertices round-trip read/write" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let vertices : FixedArray[Float] = [
    1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0,
  ]
  let mesh = @raylib.Mesh::new(vertices)
  guard mesh.vertices() is Some(v) else { fail("expected vertices to be Some") }
  assert_eq(v.length(), 9)
  // Read back original values
  assert_eq(v[0], 1.0)
  assert_eq(v[3], 4.0)
  assert_eq(v[8], 9.0)
  // Write and read back
  v[0] = 99.0
  assert_eq(v[0], 99.0)
  mesh.unload()
  @raylib.close_window()
}

///|
test "Mesh texcoords round-trip" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let vertices : FixedArray[Float] = [
    0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0,
  ]
  let texcoords : FixedArray[Float] = [0.0, 0.0, 1.0, 0.0, 0.5, 1.0]
  let mesh = @raylib.Mesh::new(vertices, texcoords=texcoords)
  guard mesh.texcoords() is Some(t) else { fail("expected texcoords to be Some") }
  assert_eq(t.length(), 6)
  assert_eq(t[0], 0.0)
  assert_eq(t[2], 1.0)
  assert_eq(t[5], 1.0)
  // Write and read back
  t[0] = 0.5
  assert_eq(t[0], 0.5)
  mesh.unload()
  @raylib.close_window()
}

///|
test "Mesh indices round-trip" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let vertices : FixedArray[Float] = [
    0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0,
  ]
  let indices : FixedArray[UInt16] = [0, 1, 2, 0, 2, 3]
  let mesh = @raylib.Mesh::new(vertices, indices=indices)
  guard mesh.indices() is Some(idx) else { fail("expected indices to be Some") }
  assert_eq(idx.length(), 6)
  assert_eq(idx[0], 0)
  assert_eq(idx[1], 1)
  assert_eq(idx[5], 3)
  mesh.unload()
  @raylib.close_window()
}

///|
test "Mesh colors round-trip" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let vertices : FixedArray[Float] = [
    0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0,
  ]
  // 3 vertices * 4 RGBA components = 12 bytes
  let colors : FixedArray[Byte] = [
    255, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255,
  ]
  let mesh = @raylib.Mesh::new(vertices, colors=colors)
  guard mesh.colors() is Some(c) else { fail("expected colors to be Some") }
  assert_eq(c.length(), 12)
  assert_eq(c[0], 255)
  assert_eq(c[1], 0)
  assert_eq(c[4], 0)
  assert_eq(c[5], 255)
  mesh.unload()
  @raylib.close_window()
}

///|
test "Mesh without optional attributes returns None" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let vertices : FixedArray[Float] = [
    0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0,
  ]
  let mesh = @raylib.Mesh::new(vertices)
  assert_true(mesh.texcoords() is None)
  assert_true(mesh.normals() is None)
  assert_true(mesh.tangents() is None)
  assert_true(mesh.colors() is None)
  assert_true(mesh.indices() is None)
  mesh.unload()
  @raylib.close_window()
}

///|
test "Mesh from gen_cube: field accessors" {
  @raylib.set_config_flags(@raylib.FlagWindowHidden)
  @raylib.init_window(1, 1, "test")
  let mesh = @raylib.Mesh::gen_cube(1.0, 1.0, 1.0)
  assert_true(mesh.vertex_count() > 0)
  assert_true(mesh.triangle_count() > 0)
  guard mesh.vertices() is Some(v) else { fail("expected vertices to be Some") }
  assert_eq(v.length(), mesh.vertex_count() * 3)
  guard mesh.normals() is Some(n) else { fail("expected normals to be Some") }
  assert_eq(n.length(), mesh.vertex_count() * 3)
  guard mesh.texcoords() is Some(tc) else { fail("expected texcoords to be Some") }
  assert_eq(tc.length(), mesh.vertex_count() * 2)
  mesh.unload()
  @raylib.close_window()
}
