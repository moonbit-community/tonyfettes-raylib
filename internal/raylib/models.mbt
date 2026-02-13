// ============================================================================
// 3D shape drawing
// ============================================================================

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_line_3d(
  start_pos : Bytes,
  end_pos : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_line_3d"

///|
#borrow(position, color)
pub extern "c" fn draw_point_3d(position : Bytes, color : Bytes) = "moonbit_raylib_draw_point_3d"

///|
#borrow(center, rot_axis, color)
pub extern "c" fn draw_circle_3d(
  center : Bytes,
  radius : Float,
  rot_axis : Bytes,
  rot_angle : Float,
  color : Bytes,
) = "moonbit_raylib_draw_circle_3d"

///|
#borrow(position, color)
pub extern "c" fn draw_cube(
  position : Bytes,
  width : Float,
  height : Float,
  length : Float,
  color : Bytes,
) = "moonbit_raylib_draw_cube"

///|
#borrow(position, size, color)
pub extern "c" fn draw_cube_v(position : Bytes, size : Bytes, color : Bytes) = "moonbit_raylib_draw_cube_v"

///|
#borrow(position, color)
pub extern "c" fn draw_cube_wires(
  position : Bytes,
  width : Float,
  height : Float,
  length : Float,
  color : Bytes,
) = "moonbit_raylib_draw_cube_wires"

///|
#borrow(position, size, color)
pub extern "c" fn draw_cube_wires_v(
  position : Bytes,
  size : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_cube_wires_v"

///|
#borrow(center, color)
pub extern "c" fn draw_sphere(center : Bytes, radius : Float, color : Bytes) = "moonbit_raylib_draw_sphere"

///|
#borrow(center, color)
pub extern "c" fn draw_sphere_ex(
  center : Bytes,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_sphere_ex"

///|
#borrow(center, color)
pub extern "c" fn draw_sphere_wires(
  center : Bytes,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_sphere_wires"

///|
#borrow(position, color)
pub extern "c" fn draw_cylinder(
  position : Bytes,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_cylinder"

///|
#borrow(position, color)
pub extern "c" fn draw_cylinder_wires(
  position : Bytes,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Bytes,
) = "moonbit_raylib_draw_cylinder_wires"

///|
#borrow(center, size, color)
pub extern "c" fn draw_plane(center : Bytes, size : Bytes, color : Bytes) = "moonbit_raylib_draw_plane"

///|
#borrow(ray, color)
pub extern "c" fn draw_ray(ray : Bytes, color : Bytes) = "moonbit_raylib_draw_ray"

///|
pub extern "c" fn draw_grid(slices : Int, spacing : Float) = "DrawGrid"

///|
#borrow(box_, color)
pub extern "c" fn draw_bounding_box(box_ : Bytes, color : Bytes) = "moonbit_raylib_draw_bounding_box"

// ============================================================================
// Model loading
// ============================================================================

///|
#borrow(file_name)
pub extern "c" fn load_model(file_name : Bytes) -> Model = "moonbit_raylib_load_model"

///|
#borrow(model)
pub extern "c" fn unload_model(model : Model) = "moonbit_raylib_unload_model"

///|
#borrow(model, position, tint)
pub extern "c" fn draw_model(
  model : Model,
  position : Bytes,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_model"

// ============================================================================
// 3D collision detection
// ============================================================================

///|
#borrow(center1, center2)
pub extern "c" fn check_collision_spheres(
  center1 : Bytes,
  radius1 : Float,
  center2 : Bytes,
  radius2 : Float,
) -> Bool = "moonbit_raylib_check_collision_spheres"

///|
#borrow(box1, box2)
pub extern "c" fn check_collision_boxes(box1 : Bytes, box2 : Bytes) -> Bool = "moonbit_raylib_check_collision_boxes"

///|
#borrow(box_, center)
pub extern "c" fn check_collision_box_sphere(
  box_ : Bytes,
  center : Bytes,
  radius : Float,
) -> Bool = "moonbit_raylib_check_collision_box_sphere"

///|
#borrow(ray, center)
pub extern "c" fn get_ray_collision_sphere(
  ray : Bytes,
  center : Bytes,
  radius : Float,
) -> Bytes = "moonbit_raylib_get_ray_collision_sphere"

///|
#borrow(ray, box_)
pub extern "c" fn get_ray_collision_box(ray : Bytes, box_ : Bytes) -> Bytes = "moonbit_raylib_get_ray_collision_box"
