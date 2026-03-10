///|
struct Mesh(@ffi.Mesh)

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
#as_free_fn(mesh_setup_texcoords2)
pub fn Mesh::setup_texcoords2(
  self : Mesh,
  data : Bytes,
  float_count : Int,
) -> Unit {
  @ffi.mesh_setup_texcoords2(self.0, data, float_count)
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
