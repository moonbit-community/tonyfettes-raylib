///|
struct Mesh(@ffi.Mesh)

///|
pub fn Mesh::new(
  vertex_count : Int,
  triangle_count : Int,
  vertices~ : FloatArray? = None,
  texcoords~ : FloatArray? = None,
  texcoords2~ : FloatArray? = None,
  normals~ : FloatArray? = None,
  tangents~ : FloatArray? = None,
  colors~ : UByteArray? = None,
  indices~ : UShortArray? = None,
) -> Mesh {
  let mesh : Mesh = @ffi.new_mesh(vertex_count, triangle_count)
  match vertices {
    Some(v) => mesh.set_vertices(v)
    None => ()
  }
  match texcoords {
    Some(v) => mesh.set_texcoords(v)
    None => ()
  }
  match texcoords2 {
    Some(v) => mesh.set_texcoords2(v)
    None => ()
  }
  match normals {
    Some(v) => mesh.set_normals(v)
    None => ()
  }
  match tangents {
    Some(v) => mesh.set_tangents(v)
    None => ()
  }
  match colors {
    Some(v) => mesh.set_colors(v)
    None => ()
  }
  match indices {
    Some(v) => mesh.set_indices(v)
    None => ()
  }
  mesh
}

///|
#as_free_fn(unload_mesh)
pub fn Mesh::unload(self : Mesh) -> Unit {
  @ffi.unload_mesh(self.0)
}

///|
#as_free_fn(upload_mesh)
pub fn Mesh::upload(self : Mesh, dynamic : Bool) -> Unit {
  @ffi.upload_mesh(self.0, if dynamic { 1 } else { 0 })
}

///|
#as_free_fn(gen_mesh_tangents)
pub fn Mesh::gen_tangents(self : Mesh) -> Unit {
  @ffi.gen_mesh_tangents(self.0)
}

///|
#as_free_fn(gen_mesh_poly)
pub fn Mesh::gen_poly(sides : Int, radius : Float) -> Mesh {
  @ffi.gen_mesh_poly(sides, radius)
}

///|
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
#as_free_fn(gen_mesh_cube)
pub fn Mesh::gen_cube(width : Float, height : Float, length : Float) -> Mesh {
  @ffi.gen_mesh_cube(width, height, length)
}

///|
#as_free_fn(gen_mesh_sphere)
pub fn Mesh::gen_sphere(radius : Float, rings : Int, slices : Int) -> Mesh {
  @ffi.gen_mesh_sphere(radius, rings, slices)
}

///|
#as_free_fn(gen_mesh_hemisphere)
pub fn Mesh::gen_hemisphere(radius : Float, rings : Int, slices : Int) -> Mesh {
  @ffi.gen_mesh_hemisphere(radius, rings, slices)
}

///|
#as_free_fn(gen_mesh_cylinder)
pub fn Mesh::gen_cylinder(radius : Float, height : Float, slices : Int) -> Mesh {
  @ffi.gen_mesh_cylinder(radius, height, slices)
}

///|
#as_free_fn(gen_mesh_cone)
pub fn Mesh::gen_cone(radius : Float, height : Float, slices : Int) -> Mesh {
  @ffi.gen_mesh_cone(radius, height, slices)
}

///|
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
#as_free_fn(gen_mesh_heightmap)
pub fn Mesh::gen_heightmap(heightmap : Image, size : Vector3) -> Mesh {
  @ffi.gen_mesh_heightmap(heightmap.0, size.to_bytes())
}

///|
#as_free_fn(gen_mesh_cubicmap)
pub fn Mesh::gen_cubicmap(cubicmap : Image, cube_size : Vector3) -> Mesh {
  @ffi.gen_mesh_cubicmap(cubicmap.0, cube_size.to_bytes())
}

///|
#as_free_fn(get_mesh_bounding_box)
pub fn Mesh::bounding_box(self : Mesh) -> BoundingBox {
  BoundingBox::from_bytes(@ffi.get_mesh_bounding_box(self.0))
}

///|
#as_free_fn(export_mesh)
pub fn Mesh::export_(self : Mesh, file_name : String) -> Bool {
  @ffi.export_mesh(self.0, @utf8.encode(file_name))
}

///|
#as_free_fn(export_mesh_as_code)
pub fn Mesh::export_as_code(self : Mesh, file_name : String) -> Bool {
  @ffi.export_mesh_as_code(self.0, @utf8.encode(file_name))
}

///|
#as_free_fn(draw_mesh)
pub fn Mesh::draw(self : Mesh, material : Material, transform : Matrix) -> Unit {
  @ffi.draw_mesh(self.0, material.0, transform.to_bytes())
}

///|
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
#as_free_fn(get_mesh_vertex_count)
pub fn Mesh::vertex_count(self : Mesh) -> Int {
  @ffi.get_mesh_vertex_count(self.0)
}

///|
#as_free_fn(get_mesh_triangle_count)
pub fn Mesh::triangle_count(self : Mesh) -> Int {
  @ffi.get_mesh_triangle_count(self.0)
}

///|
#as_free_fn(get_mesh_vertices)
pub fn Mesh::vertices(self : Mesh) -> FloatArray {
  @ffi.get_mesh_vertices(self.0)
}

///|
#as_free_fn(set_mesh_vertices)
pub fn Mesh::set_vertices(self : Mesh, data : FloatArray) -> Unit {
  @ffi.set_mesh_vertices(self.0, data.0)
}

///|
#as_free_fn(get_mesh_texcoords)
pub fn Mesh::texcoords(self : Mesh) -> FloatArray {
  @ffi.get_mesh_texcoords(self.0)
}

///|
#as_free_fn(set_mesh_texcoords)
pub fn Mesh::set_texcoords(self : Mesh, data : FloatArray) -> Unit {
  @ffi.set_mesh_texcoords(self.0, data.0)
}

///|
#as_free_fn(get_mesh_texcoords2)
pub fn Mesh::texcoords2(self : Mesh) -> FloatArray {
  @ffi.get_mesh_texcoords2(self.0)
}

///|
#as_free_fn(set_mesh_texcoords2)
pub fn Mesh::set_texcoords2(self : Mesh, data : FloatArray) -> Unit {
  @ffi.set_mesh_texcoords2(self.0, data.0)
}

///|
#as_free_fn(get_mesh_normals)
pub fn Mesh::normals(self : Mesh) -> FloatArray {
  @ffi.get_mesh_normals(self.0)
}

///|
#as_free_fn(set_mesh_normals)
pub fn Mesh::set_normals(self : Mesh, data : FloatArray) -> Unit {
  @ffi.set_mesh_normals(self.0, data.0)
}

///|
#as_free_fn(get_mesh_tangents)
pub fn Mesh::tangents(self : Mesh) -> FloatArray {
  @ffi.get_mesh_tangents(self.0)
}

///|
#as_free_fn(set_mesh_tangents)
pub fn Mesh::set_tangents(self : Mesh, data : FloatArray) -> Unit {
  @ffi.set_mesh_tangents(self.0, data.0)
}

///|
#as_free_fn(get_mesh_colors)
pub fn Mesh::colors(self : Mesh) -> UByteArray {
  @ffi.get_mesh_colors(self.0)
}

///|
#as_free_fn(set_mesh_colors)
pub fn Mesh::set_colors(self : Mesh, data : UByteArray) -> Unit {
  @ffi.set_mesh_colors(self.0, data.0)
}

///|
#as_free_fn(get_mesh_indices)
pub fn Mesh::indices(self : Mesh) -> UShortArray {
  @ffi.get_mesh_indices(self.0)
}

///|
#as_free_fn(set_mesh_indices)
pub fn Mesh::set_indices(self : Mesh, data : UShortArray) -> Unit {
  @ffi.set_mesh_indices(self.0, data.0)
}

///|
#as_free_fn(get_mesh_bone_matrices)
pub fn Mesh::bone_matrices(self : Mesh) -> MatrixArray {
  @ffi.get_mesh_bone_matrices(self.0)
}
