// Re-export passthrough functions from internal FFI layer
///|
pub using @raylib {type Model, unload_model, draw_grid}

// ============================================================================
// 3D shape drawing (wrappers)
// ============================================================================

///|
pub fn draw_line_3d(
  start_pos : Vector3,
  end_pos : Vector3,
  color : Color,
) -> Unit {
  @raylib.draw_line_3d(
    start_pos.to_bytes(),
    end_pos.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn draw_point_3d(position : Vector3, color : Color) -> Unit {
  @raylib.draw_point_3d(position.to_bytes(), color.to_bytes())
}

///|
pub fn draw_circle_3d(
  center : Vector3,
  radius : Float,
  rot_axis : Vector3,
  rot_angle : Float,
  color : Color,
) -> Unit {
  @raylib.draw_circle_3d(
    center.to_bytes(),
    radius,
    rot_axis.to_bytes(),
    rot_angle,
    color.to_bytes(),
  )
}

///|
pub fn draw_cube(
  position : Vector3,
  width : Float,
  height : Float,
  length : Float,
  color : Color,
) -> Unit {
  @raylib.draw_cube(
    position.to_bytes(),
    width,
    height,
    length,
    color.to_bytes(),
  )
}

///|
pub fn draw_cube_v(position : Vector3, size : Vector3, color : Color) -> Unit {
  @raylib.draw_cube_v(position.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
pub fn draw_cube_wires(
  position : Vector3,
  width : Float,
  height : Float,
  length : Float,
  color : Color,
) -> Unit {
  @raylib.draw_cube_wires(
    position.to_bytes(),
    width,
    height,
    length,
    color.to_bytes(),
  )
}

///|
pub fn draw_cube_wires_v(
  position : Vector3,
  size : Vector3,
  color : Color,
) -> Unit {
  @raylib.draw_cube_wires_v(
    position.to_bytes(),
    size.to_bytes(),
    color.to_bytes(),
  )
}

///|
pub fn draw_sphere(center : Vector3, radius : Float, color : Color) -> Unit {
  @raylib.draw_sphere(center.to_bytes(), radius, color.to_bytes())
}

///|
pub fn draw_sphere_ex(
  center : Vector3,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Color,
) -> Unit {
  @raylib.draw_sphere_ex(
    center.to_bytes(),
    radius,
    rings,
    slices,
    color.to_bytes(),
  )
}

///|
pub fn draw_sphere_wires(
  center : Vector3,
  radius : Float,
  rings : Int,
  slices : Int,
  color : Color,
) -> Unit {
  @raylib.draw_sphere_wires(
    center.to_bytes(),
    radius,
    rings,
    slices,
    color.to_bytes(),
  )
}

///|
pub fn draw_cylinder(
  position : Vector3,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Color,
) -> Unit {
  @raylib.draw_cylinder(
    position.to_bytes(),
    radius_top,
    radius_bottom,
    height,
    slices,
    color.to_bytes(),
  )
}

///|
pub fn draw_cylinder_wires(
  position : Vector3,
  radius_top : Float,
  radius_bottom : Float,
  height : Float,
  slices : Int,
  color : Color,
) -> Unit {
  @raylib.draw_cylinder_wires(
    position.to_bytes(),
    radius_top,
    radius_bottom,
    height,
    slices,
    color.to_bytes(),
  )
}

///|
pub fn draw_plane(center : Vector3, size : Vector2, color : Color) -> Unit {
  @raylib.draw_plane(center.to_bytes(), size.to_bytes(), color.to_bytes())
}

///|
pub fn draw_ray(ray : Ray, color : Color) -> Unit {
  @raylib.draw_ray(ray.to_bytes(), color.to_bytes())
}

///|
pub fn draw_bounding_box(box_ : BoundingBox, color : Color) -> Unit {
  @raylib.draw_bounding_box(box_.to_bytes(), color.to_bytes())
}

// ============================================================================
// Model loading (wrappers)
// ============================================================================

///|
pub fn load_model(file_name : String) -> Model {
  @raylib.load_model(@utf8.encode(file_name))
}

///|
pub fn draw_model(
  model : Model,
  position : Vector3,
  scale : Float,
  tint : Color,
) -> Unit {
  @raylib.draw_model(model, position.to_bytes(), scale, tint.to_bytes())
}

// ============================================================================
// 3D collision detection (wrappers)
// ============================================================================

///|
pub fn check_collision_spheres(
  center1 : Vector3,
  radius1 : Float,
  center2 : Vector3,
  radius2 : Float,
) -> Bool {
  @raylib.check_collision_spheres(
    center1.to_bytes(),
    radius1,
    center2.to_bytes(),
    radius2,
  )
}

///|
pub fn check_collision_boxes(box1 : BoundingBox, box2 : BoundingBox) -> Bool {
  @raylib.check_collision_boxes(box1.to_bytes(), box2.to_bytes())
}

///|
pub fn check_collision_box_sphere(
  box_ : BoundingBox,
  center : Vector3,
  radius : Float,
) -> Bool {
  @raylib.check_collision_box_sphere(box_.to_bytes(), center.to_bytes(), radius)
}

///|
pub fn get_ray_collision_sphere(
  ray : Ray,
  center : Vector3,
  radius : Float,
) -> RayCollision {
  RayCollision::from_bytes(
    @raylib.get_ray_collision_sphere(ray.to_bytes(), center.to_bytes(), radius),
  )
}

///|
pub fn get_ray_collision_box(ray : Ray, box_ : BoundingBox) -> RayCollision {
  RayCollision::from_bytes(
    @raylib.get_ray_collision_box(ray.to_bytes(), box_.to_bytes()),
  )
}
