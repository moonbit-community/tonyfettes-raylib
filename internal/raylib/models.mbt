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
#borrow(v1, v2, v3, color)
pub extern "c" fn draw_triangle_3d(
  v1 : Bytes,
  v2 : Bytes,
  v3 : Bytes,
  color : Bytes,
) = "moonbit_raylib_draw_triangle_3d"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_cylinder_ex(
  start_pos : Bytes,
  end_pos : Bytes,
  start_radius : Float,
  end_radius : Float,
  sides : Int,
  color : Bytes,
) = "moonbit_raylib_draw_cylinder_ex"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_cylinder_wires_ex(
  start_pos : Bytes,
  end_pos : Bytes,
  start_radius : Float,
  end_radius : Float,
  sides : Int,
  color : Bytes,
) = "moonbit_raylib_draw_cylinder_wires_ex"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_capsule(
  start_pos : Bytes,
  end_pos : Bytes,
  radius : Float,
  slices : Int,
  rings : Int,
  color : Bytes,
) = "moonbit_raylib_draw_capsule"

///|
#borrow(start_pos, end_pos, color)
pub extern "c" fn draw_capsule_wires(
  start_pos : Bytes,
  end_pos : Bytes,
  radius : Float,
  slices : Int,
  rings : Int,
  color : Bytes,
) = "moonbit_raylib_draw_capsule_wires"

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

///|
#borrow(model, position, rotation_axis, scale, tint)
pub extern "c" fn draw_model_ex(
  model : Model,
  position : Bytes,
  rotation_axis : Bytes,
  rotation_angle : Float,
  scale : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_model_ex"

///|
#borrow(model, position, tint)
pub extern "c" fn draw_model_wires(
  model : Model,
  position : Bytes,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_model_wires"

///|
#borrow(model, position, rotation_axis, scale, tint)
pub extern "c" fn draw_model_wires_ex(
  model : Model,
  position : Bytes,
  rotation_axis : Bytes,
  rotation_angle : Float,
  scale : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_model_wires_ex"

///|
#borrow(model, position, tint)
pub extern "c" fn draw_model_points(
  model : Model,
  position : Bytes,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_model_points"

///|
#borrow(model, position, rotation_axis, scale, tint)
pub extern "c" fn draw_model_points_ex(
  model : Model,
  position : Bytes,
  rotation_axis : Bytes,
  rotation_angle : Float,
  scale : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_model_points_ex"

// ============================================================================
// Model management
// ============================================================================

///|
#borrow(model)
pub extern "c" fn is_model_valid(model : Model) -> Bool = "moonbit_raylib_is_model_valid"

///|
#borrow(model)
pub extern "c" fn get_model_bounding_box(model : Model) -> Bytes = "moonbit_raylib_get_model_bounding_box"

// ============================================================================
// Billboard drawing
// ============================================================================

///|
#borrow(camera, texture, position, tint)
pub extern "c" fn draw_billboard(
  camera : Bytes,
  texture : Texture,
  position : Bytes,
  scale : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_billboard"

///|
#borrow(camera, texture, source, position, size, tint)
pub extern "c" fn draw_billboard_rec(
  camera : Bytes,
  texture : Texture,
  source : Bytes,
  position : Bytes,
  size : Bytes,
  tint : Bytes,
) = "moonbit_raylib_draw_billboard_rec"

///|
#borrow(camera, texture, source, position, up, size, origin, tint)
pub extern "c" fn draw_billboard_pro(
  camera : Bytes,
  texture : Texture,
  source : Bytes,
  position : Bytes,
  up : Bytes,
  size : Bytes,
  origin : Bytes,
  rotation : Float,
  tint : Bytes,
) = "moonbit_raylib_draw_billboard_pro"

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

///|
#borrow(ray, p1, p2, p3)
pub extern "c" fn get_ray_collision_triangle(
  ray : Bytes,
  p1 : Bytes,
  p2 : Bytes,
  p3 : Bytes,
) -> Bytes = "moonbit_raylib_get_ray_collision_triangle"
