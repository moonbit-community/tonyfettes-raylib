///|
/// A mesh containing vertex data and GPU buffer IDs.
struct Mesh(@ffi.Mesh)

///|
/// Create a new mesh from vertex data arrays.
pub fn Mesh::new(
  vertices : FixedArray[Float],
  texcoords? : FixedArray[Float],
  texcoords2? : FixedArray[Float],
  normals? : FixedArray[Float],
  tangents? : FixedArray[Float],
  colors? : FixedArray[Byte],
  indices? : FixedArray[UInt16],
) -> Mesh {
  guard vertices.length() % 3 == 0 else {
    abort(
      "Mesh::new: vertices length must be a multiple of 3, got \{vertices.length()}",
    )
  }
  let vertex_count = vertices.length() / 3
  if texcoords is Some(tc) && tc.length() != vertex_count * 2 {
    abort(
      "Mesh::new: texcoords length must be \{vertex_count * 2} (vertex_count * 2), got \{tc.length()}",
    )
  }
  if texcoords2 is Some(tc2) && tc2.length() != vertex_count * 2 {
    abort(
      "Mesh::new: texcoords2 length must be \{vertex_count * 2} (vertex_count * 2), got \{tc2.length()}",
    )
  }
  if normals is Some(n) && n.length() != vertex_count * 3 {
    abort(
      "Mesh::new: normals length must be \{vertex_count * 3} (vertex_count * 3), got \{n.length()}",
    )
  }
  if tangents is Some(t) && t.length() != vertex_count * 4 {
    abort(
      "Mesh::new: tangents length must be \{vertex_count * 4} (vertex_count * 4), got \{t.length()}",
    )
  }
  if colors is Some(c) && c.length() != vertex_count * 4 {
    abort(
      "Mesh::new: colors length must be \{vertex_count * 4} (vertex_count * 4), got \{c.length()}",
    )
  }
  if indices is Some(idx) && idx.length() % 3 != 0 {
    abort(
      "Mesh::new: indices length must be a multiple of 3, got \{idx.length()}",
    )
  }
  let triangle_count = match indices {
    Some(idx) => idx.length() / 3
    None => vertex_count / 3
  }
  @ffi.new_mesh(
    vertex_count, triangle_count, vertices, texcoords, texcoords2, normals, tangents,
    colors, indices,
  )
}

///|
/// Unload mesh data from CPU and GPU.
#as_free_fn(unload_mesh)
pub fn Mesh::unload(self : Mesh) -> Unit {
  @ffi.unload_mesh(self.0)
}

///|
/// Upload mesh vertex data in GPU and provide VAO/VBO ids.
pub fn Mesh::upload(self : Mesh, dynamic : Bool) -> Unit {
  @ffi.upload_mesh(self.0, if dynamic { 1 } else { 0 })
}

///|
/// Upload mesh vertex data in GPU and provide VAO/VBO ids.
#deprecated("Use Mesh::upload instead")
pub fn upload_mesh(mesh : Mesh, dynamic : Int) -> Unit {
  @ffi.upload_mesh(mesh.0, dynamic)
}

///|
/// Compute mesh tangents.
#as_free_fn(gen_mesh_tangents)
pub fn Mesh::gen_tangents(self : Mesh) -> Unit {
  @ffi.gen_mesh_tangents(self.0)
}

///|
/// Generate polygonal mesh.
#as_free_fn(gen_mesh_poly)
pub fn Mesh::gen_poly(sides : Int, radius : Float) -> Mesh {
  @ffi.gen_mesh_poly(sides, radius)
}

///|
/// Generate plane mesh (with subdivisions).
#as_free_fn(gen_mesh_plane)
pub fn Mesh::gen_plane(
  width : Float,
  length : Float,
  res_x : Int,
  res_z : Int,
) -> Mesh {
  @ffi.gen_mesh_plane(width, length, res_x, res_z)
}

///|
/// Generate cuboid mesh.
#as_free_fn(gen_mesh_cube)
pub fn Mesh::gen_cube(width : Float, height : Float, length : Float) -> Mesh {
  @ffi.gen_mesh_cube(width, height, length)
}

///|
/// Generate sphere mesh (standard sphere).
#as_free_fn(gen_mesh_sphere)
pub fn Mesh::gen_sphere(radius : Float, rings : Int, slices : Int) -> Mesh {
  @ffi.gen_mesh_sphere(radius, rings, slices)
}

///|
/// Generate half-sphere mesh (no bottom cap).
#as_free_fn(gen_mesh_hemisphere)
pub fn Mesh::gen_hemisphere(radius : Float, rings : Int, slices : Int) -> Mesh {
  @ffi.gen_mesh_hemisphere(radius, rings, slices)
}

///|
/// Generate cylinder mesh.
#as_free_fn(gen_mesh_cylinder)
pub fn Mesh::gen_cylinder(radius : Float, height : Float, slices : Int) -> Mesh {
  @ffi.gen_mesh_cylinder(radius, height, slices)
}

///|
/// Generate cone/pyramid mesh.
#as_free_fn(gen_mesh_cone)
pub fn Mesh::gen_cone(radius : Float, height : Float, slices : Int) -> Mesh {
  @ffi.gen_mesh_cone(radius, height, slices)
}

///|
/// Generate torus mesh.
#as_free_fn(gen_mesh_torus)
pub fn Mesh::gen_torus(
  radius : Float,
  size : Float,
  rad_seg : Int,
  sides : Int,
) -> Mesh {
  @ffi.gen_mesh_torus(radius, size, rad_seg, sides)
}

///|
/// Generate trefoil knot mesh.
#as_free_fn(gen_mesh_knot)
pub fn Mesh::gen_knot(
  radius : Float,
  size : Float,
  rad_seg : Int,
  sides : Int,
) -> Mesh {
  @ffi.gen_mesh_knot(radius, size, rad_seg, sides)
}

///|
/// Generate heightmap mesh from image data.
#as_free_fn(gen_mesh_heightmap)
pub fn Mesh::gen_heightmap(heightmap : Image, size : Vector3) -> Mesh {
  @ffi.gen_mesh_heightmap(heightmap.0, size.to_bytes())
}

///|
/// Generate cubes-based map mesh from image data.
#as_free_fn(gen_mesh_cubicmap)
pub fn Mesh::gen_cubicmap(cubicmap : Image, cube_size : Vector3) -> Mesh {
  @ffi.gen_mesh_cubicmap(cubicmap.0, cube_size.to_bytes())
}

///|
/// Compute mesh bounding box limits.
#as_free_fn(get_mesh_bounding_box)
pub fn Mesh::bounding_box(self : Mesh) -> BoundingBox {
  BoundingBox::from_bytes(@ffi.get_mesh_bounding_box(self.0))
}

///|
/// Export mesh data to file, returns true on success.
#as_free_fn(export_mesh)
pub fn Mesh::export_(self : Mesh, file_name : String) -> Bool {
  @ffi.export_mesh(self.0, @utf8.encode(file_name))
}

///|
/// Export mesh as code file (.h) defining multiple arrays of vertex attributes.
#as_free_fn(export_mesh_as_code)
pub fn Mesh::export_as_code(self : Mesh, file_name : String) -> Bool {
  @ffi.export_mesh_as_code(self.0, @utf8.encode(file_name))
}

///|
/// Draw a 3D mesh with material and transform.
#as_free_fn(draw_mesh)
pub fn Mesh::draw(self : Mesh, material : Material, transform : Matrix) -> Unit {
  @ffi.draw_mesh(self.0, material.0, transform.to_bytes())
}

///|
/// Draw multiple mesh instances with material and different transforms.
#as_free_fn(draw_mesh_instanced)
pub fn Mesh::draw_instanced(
  self : Mesh,
  material : Material,
  transforms : Array[Matrix],
  instances : Int,
) -> Unit {
  let arr = FixedArray::make(instances * 64, b'\x00')
  for i in 0..<instances {
    let m = transforms[i].to_bytes()
    arr.blit_from_bytes(i * 64, m, 0, 64)
  }
  let buf = FixedArray::unsafe_reinterpret_as_bytes(arr)
  @ffi.draw_mesh_instanced(self.0, material.0, buf, instances)
}

///|
/// Update mesh vertex data in GPU for a specific buffer index.
#as_free_fn(update_mesh_buffer)
pub fn Mesh::update_buffer(
  self : Mesh,
  index : Int,
  data : Bytes,
  data_size : Int,
  offset : Int,
) -> Unit {
  @ffi.update_mesh_buffer(self.0, index, data, data_size, offset)
}

///|
/// Generate a mesh from raw vertex positions and colors.
#as_free_fn(gen_mesh_from_points)
pub fn Mesh::gen_from_points(
  vertices : Bytes,
  colors : Bytes,
  num_points : Int,
) -> Mesh {
  @ffi.gen_mesh_from_points(vertices, colors, num_points)
}

// ============================================================================
// Mesh: field accessors
// ============================================================================

///|
/// Get the number of vertices in the mesh.
#as_free_fn(get_mesh_vertex_count)
pub fn Mesh::vertex_count(self : Mesh) -> Int {
  @ffi.get_mesh_vertex_count(self.0)
}

///|
/// Get the number of triangles in the mesh.
#as_free_fn(get_mesh_triangle_count)
pub fn Mesh::triangle_count(self : Mesh) -> Int {
  @ffi.get_mesh_triangle_count(self.0)
}

///|
/// Get vertex positions array (3 floats per vertex), or None if not available.
#as_free_fn(get_mesh_vertices)
pub fn Mesh::vertices(self : Mesh) -> FloatArray? {
  let arr = FloatArray(@ffi.get_mesh_vertices(self.0), self.vertex_count() * 3)
  if arr.is_null() {
    None
  } else {
    Some(arr)
  }
}

///|
/// Get texture coordinates array (2 floats per vertex), or None if not available.
#as_free_fn(get_mesh_texcoords)
pub fn Mesh::texcoords(self : Mesh) -> FloatArray? {
  let arr = FloatArray(@ffi.get_mesh_texcoords(self.0), self.vertex_count() * 2)
  if arr.is_null() {
    None
  } else {
    Some(arr)
  }
}

///|
/// Get second texture coordinates array (2 floats per vertex), or None if not available.
#as_free_fn(get_mesh_texcoords2)
pub fn Mesh::texcoords2(self : Mesh) -> FloatArray? {
  let arr = FloatArray(
    @ffi.get_mesh_texcoords2(self.0),
    self.vertex_count() * 2,
  )
  if arr.is_null() {
    None
  } else {
    Some(arr)
  }
}

///|
/// Get vertex normals array (3 floats per vertex), or None if not available.
#as_free_fn(get_mesh_normals)
pub fn Mesh::normals(self : Mesh) -> FloatArray? {
  let arr = FloatArray(@ffi.get_mesh_normals(self.0), self.vertex_count() * 3)
  if arr.is_null() {
    None
  } else {
    Some(arr)
  }
}

///|
/// Get vertex tangents array (4 floats per vertex), or None if not available.
#as_free_fn(get_mesh_tangents)
pub fn Mesh::tangents(self : Mesh) -> FloatArray? {
  let arr = FloatArray(@ffi.get_mesh_tangents(self.0), self.vertex_count() * 4)
  if arr.is_null() {
    None
  } else {
    Some(arr)
  }
}

///|
/// Get vertex colors array (4 bytes per vertex as RGBA), or None if not available.
#as_free_fn(get_mesh_colors)
pub fn Mesh::colors(self : Mesh) -> UByteArray? {
  let arr = UByteArray(@ffi.get_mesh_colors(self.0), self.vertex_count() * 4)
  if arr.is_null() {
    None
  } else {
    Some(arr)
  }
}

///|
/// Get vertex indices array (3 per triangle), or None if not available.
#as_free_fn(get_mesh_indices)
pub fn Mesh::indices(self : Mesh) -> UShortArray? {
  let arr = UShortArray(
    @ffi.get_mesh_indices(self.0),
    self.triangle_count() * 3,
  )
  if arr.is_null() {
    None
  } else {
    Some(arr)
  }
}
