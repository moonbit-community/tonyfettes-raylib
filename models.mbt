// ============================================================================
// 3D shape drawing
// ============================================================================

///|
#borrow(start_pos, end_pos, color)
extern "c" fn raylib_draw_line_3d(
  start_pos : Bytes,
  end_pos : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_line_3d"

///|
pub fn draw_line_3d(
  start_pos : Vector3,
  end_pos : Vector3,
  color : Color,
) -> Unit {
  raylib_draw_line_3d(start_pos.to_bytes(), end_pos.to_bytes(), color.to_bytes())
}

///|
#borrow(position, color)
extern "c" fn raylib_draw_point_3d(position : Bytes, color : Bytes) = "moonbit_raylib_draw_point_3d"

///|
pub fn draw_point_3d(position : Vector3, color : Color) -> Unit {
  raylib_draw_point_3d(position.to_bytes(), color.to_bytes())
}

///|
#borrow(center, rot_axis, color)
extern "c" fn raylib_draw_circle_3d(
  center : Bytes,
  radius : Float,
  rot_axis : Bytes,
  rot_angle : Float,
  color : Bytes,
) = "moonbit_raylib_draw_circle_3d"

///|
pub fn draw_circle_3d(
  center : Vector3,
  radius : Float,
  rot_axis : Vector3,
  rot_angle : Float,
  color : Color,
) -> Unit {
  raylib_draw_circle_3d(
    center.to_bytes(),
    radius,
    rot_axis.to_bytes(),
    rot_angle,
    color.to_bytes(),
  )
}

///|
#borrow(position, color)
extern "c" fn raylib_draw_cube(
  position : Bytes,
  width : Float,
  height : Float,
  length : Float,
  color : Bytes,
) = "moonbit_raylib_draw_cube"

///|
pub fn draw_cube(
  position : Vector3,
  width : Float,
  height : Float,
  length : Float,
  color : Color,
) -> Unit {
  raylib_draw_cube(position.to_bytes(), width, height, length, color.to_bytes())
}

///|
#borrow(position, size, color)
extern "c" fn raylib_draw_cube_v(position : Bytes, size : Bytes, color : Bytes) = "moonbit_raylib_draw_cube_v"

///|
pub fn draw_cube_v(position : Vector3, size : Vector3, color : Color) -> Unit {
  raylib_draw_cube_v(position.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
#borrow(position, color)
extern "c" fn raylib_draw_cube_wires(
  position : Bytes,
  width : Float,
  height : Float,
  length : Float,
  color : Bytes,
) = "moonbit_raylib_draw_cube_wires"

///|
pub fn draw_cube_wires(
  position : Vector3,
  width : Float,
  height : Float,
  length : Float,
  color : Color,
) -> Unit {
  raylib_draw_cube_wires(
    position.to_bytes(),
    width,
    height,
    length,
    color.to_bytes(),
  )
}

///|
#borrow(position, size, color)
extern "c" fn raylib_draw_cube_wires_v(
  position : Bytes,
  size : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_cube_wires_v"

///|
pub fn draw_cube_wires_v(
  position : Vector3,
  size : Vector3,
  color : Color,
) -> Unit {
  raylib_draw_cube_wires_v(position.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
#borrow(center, color)
extern "c" fn raylib_draw_sphere(center : Bytes, radius : Float, color : Bytes) = "moonbit_raylib_draw_sphere"

///|
pub fn draw_sphere(center : Vector3, radius : Float, color : Color) -> Unit {
  raylib_draw_sphere(center.to_bytes(), radius, color.to_bytes())
}

///|
#borrow(center, color)
extern "c" fn raylib_draw_sphere_ex(
  center : Bytes,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_sphere_ex"

///|
pub fn draw_sphere_ex(
  center : Vector3,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Color,
) -> Unit {
  raylib_draw_sphere_ex(center.to_bytes(), radius, rings, slices, color.to_bytes())
}

///|
#borrow(center, color)
extern "c" fn raylib_draw_sphere_wires(
  center : Bytes,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_sphere_wires"

///|
pub fn draw_sphere_wires(
  center : Vector3,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Color,
) -> Unit {
  raylib_draw_sphere_wires(
    center.to_bytes(),
    radius,
    rings,
    slices,
    color.to_bytes(),
  )
}

///|
#borrow(position, color)
extern "c" fn raylib_draw_cylinder(
  position : Bytes,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_cylinder"

///|
pub fn draw_cylinder(
  position : Vector3,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Color,
) -> Unit {
  raylib_draw_cylinder(
    position.to_bytes(),
    radius_top,
    radius_bottom,
    height,
    slices,
    color.to_bytes(),
  )
}

///|
#borrow(position, color)
extern "c" fn raylib_draw_cylinder_wires(
  position : Bytes,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_cylinder_wires"

///|
pub fn draw_cylinder_wires(
  position : Vector3,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Color,
) -> Unit {
  raylib_draw_cylinder_wires(
    position.to_bytes(),
    radius_top,
    radius_bottom,
    height,
    slices,
    color.to_bytes(),
  )
}

///|
#borrow(center, size, color)
extern "c" fn raylib_draw_plane(center : Bytes, size : Bytes, color : Bytes) = "moonbit_raylib_draw_plane"

///|
pub fn draw_plane(center : Vector3, size : Vector2, color : Color) -> Unit {
  raylib_draw_plane(center.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
#borrow(ray, color)
extern "c" fn raylib_draw_ray(ray : Bytes, color : Bytes) = "moonbit_raylib_draw_ray"

///|
pub fn draw_ray(ray : Ray, color : Color) -> Unit {
  raylib_draw_ray(ray.to_bytes(), color.to_bytes())
}

///|
extern "c" fn raylib_draw_grid(slices : Int, spacing : Float) = "DrawGrid"

///|
pub fn draw_grid(slices : Int, spacing : Float) -> Unit {
  raylib_draw_grid(slices, spacing)
}

///|
#borrow(box_, color)
extern "c" fn raylib_draw_bounding_box(box_ : Bytes, color : Bytes) = "moonbit_raylib_draw_bounding_box"

///|
pub fn draw_bounding_box(box_ : BoundingBox, color : Color) -> Unit {
  raylib_draw_bounding_box(box_.to_bytes(), color.to_bytes())
}

// ============================================================================
// Model loading
// ============================================================================

///|
#borrow(file_name)
extern "c" fn raylib_load_model(file_name : Bytes) -> Model = "moonbit_raylib_load_model"

///|
pub fn load_model(file_name : String) -> Model {
  raylib_load_model(@utf8.encode(file_name))
}

///|
#borrow(model)
extern "c" fn raylib_unload_model(model : Model) = "moonbit_raylib_unload_model"

///|
pub fn unload_model(model : Model) -> Unit {
  raylib_unload_model(model)
}

///|
#borrow(model, position, tint)
extern "c" fn raylib_draw_model(
  model : Model,
  position : Bytes,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_model"

///|
pub fn draw_model(
  model : Model,
  position : Vector3,
  scale : Float,
  tint : Color,
) -> Unit {
  raylib_draw_model(model, position.to_bytes(), scale, tint.to_bytes())
}

// ============================================================================
// 3D collision detection
// ============================================================================

///|
#borrow(center1, center2)
extern "c" fn raylib_check_collision_spheres(
  center1 : Bytes,
  radius1 : Float,
  center2 : Bytes,
  radius2 : Float,
) -> Bool = "moonbit_raylib_check_collision_spheres"

///|
pub fn check_collision_spheres(
  center1 : Vector3,
  radius1 : Float,
  center2 : Vector3,
  radius2 : Float,
) -> Bool {
  raylib_check_collision_spheres(
    center1.to_bytes(),
    radius1,
    center2.to_bytes(),
    radius2,
  )
}

///|
#borrow(box1, box2)
extern "c" fn raylib_check_collision_boxes(box1 : Bytes, box2 : Bytes) -> Bool = "moonbit_raylib_check_collision_boxes"

///|
pub fn check_collision_boxes(box1 : BoundingBox, box2 : BoundingBox) -> Bool {
  raylib_check_collision_boxes(box1.to_bytes(), box2.to_bytes())
}

///|
#borrow(box_, center)
extern "c" fn raylib_check_collision_box_sphere(
  box_ : Bytes,
  center : Bytes,
  radius : Float,
) -> Bool = "moonbit_raylib_check_collision_box_sphere"

///|
pub fn check_collision_box_sphere(
  box_ : BoundingBox,
  center : Vector3,
  radius : Float,
) -> Bool {
  raylib_check_collision_box_sphere(box_.to_bytes(), center.to_bytes(), radius)
}

///|
#borrow(ray, center)
extern "c" fn raylib_get_ray_collision_sphere(
  ray : Bytes,
  center : Bytes,
  radius : Float,
) -> Bytes = "moonbit_raylib_get_ray_collision_sphere"

///|
pub fn get_ray_collision_sphere(
  ray : Ray,
  center : Vector3,
  radius : Float,
) -> RayCollision {
  RayCollision::from_bytes(
    raylib_get_ray_collision_sphere(ray.to_bytes(), center.to_bytes(), radius),
  )
}

///|
#borrow(ray, box_)
extern "c" fn raylib_get_ray_collision_box(ray : Bytes, box_ : Bytes) -> Bytes = "moonbit_raylib_get_ray_collision_box"

///|
pub fn get_ray_collision_box(ray : Ray, box_ : BoundingBox) -> RayCollision {
  RayCollision::from_bytes(
    raylib_get_ray_collision_box(ray.to_bytes(), box_.to_bytes()),
  )
}
