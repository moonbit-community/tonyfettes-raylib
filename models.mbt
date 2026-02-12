// ============================================================================
// 3D shape drawing
// ============================================================================

#borrow(start_pos, end_pos, color)
extern "c" fn draw_line_3d_ffi(start_pos : Bytes, end_pos : Bytes, color : Bytes) = "moonbit_DrawLine3D"

pub fn draw_line_3d(start_pos : Vector3, end_pos : Vector3, color : Color) -> Unit {
  draw_line_3d_ffi(start_pos.to_bytes(), end_pos.to_bytes(), color.to_bytes())
}

#borrow(position, color)
extern "c" fn draw_point_3d_ffi(position : Bytes, color : Bytes) = "moonbit_DrawPoint3D"

pub fn draw_point_3d(position : Vector3, color : Color) -> Unit {
  draw_point_3d_ffi(position.to_bytes(), color.to_bytes())
}

#borrow(center, rot_axis, color)
extern "c" fn draw_circle_3d_ffi(center : Bytes, radius : Float, rot_axis : Bytes, rot_angle : Float, color : Bytes) = "moonbit_DrawCircle3D"

pub fn draw_circle_3d(center : Vector3, radius : Float, rot_axis : Vector3, rot_angle : Float, color : Color) -> Unit {
  draw_circle_3d_ffi(center.to_bytes(), radius, rot_axis.to_bytes(), rot_angle, color.to_bytes())
}

#borrow(position, color)
extern "c" fn draw_cube_ffi(position : Bytes, width : Float, height : Float, length : Float, color : Bytes) = "moonbit_DrawCube"

pub fn draw_cube(position : Vector3, width : Float, height : Float, length : Float, color : Color) -> Unit {
  draw_cube_ffi(position.to_bytes(), width, height, length, color.to_bytes())
}

#borrow(position, size, color)
extern "c" fn draw_cube_v_ffi(position : Bytes, size : Bytes, color : Bytes) = "moonbit_DrawCubeV"

pub fn draw_cube_v(position : Vector3, size : Vector3, color : Color) -> Unit {
  draw_cube_v_ffi(position.to_bytes(), size.to_bytes(), color.to_bytes())
}

#borrow(position, color)
extern "c" fn draw_cube_wires_ffi(position : Bytes, width : Float, height : Float, length : Float, color : Bytes) = "moonbit_DrawCubeWires"

pub fn draw_cube_wires(position : Vector3, width : Float, height : Float, length : Float, color : Color) -> Unit {
  draw_cube_wires_ffi(position.to_bytes(), width, height, length, color.to_bytes())
}

#borrow(position, size, color)
extern "c" fn draw_cube_wires_v_ffi(position : Bytes, size : Bytes, color : Bytes) = "moonbit_DrawCubeWiresV"

pub fn draw_cube_wires_v(position : Vector3, size : Vector3, color : Color) -> Unit {
  draw_cube_wires_v_ffi(position.to_bytes(), size.to_bytes(), color.to_bytes())
}

#borrow(center, color)
extern "c" fn draw_sphere_ffi(center : Bytes, radius : Float, color : Bytes) = "moonbit_DrawSphere"

pub fn draw_sphere(center : Vector3, radius : Float, color : Color) -> Unit {
  draw_sphere_ffi(center.to_bytes(), radius, color.to_bytes())
}

#borrow(center, color)
extern "c" fn draw_sphere_ex_ffi(center : Bytes, radius : Float, rings : Int, slices : Int, color : Bytes) = "moonbit_DrawSphereEx"

pub fn draw_sphere_ex(center : Vector3, radius : Float, rings : Int, slices : Int, color : Color) -> Unit {
  draw_sphere_ex_ffi(center.to_bytes(), radius, rings, slices, color.to_bytes())
}

#borrow(center, color)
extern "c" fn draw_sphere_wires_ffi(center : Bytes, radius : Float, rings : Int, slices : Int, color : Bytes) = "moonbit_DrawSphereWires"

pub fn draw_sphere_wires(center : Vector3, radius : Float, rings : Int, slices : Int, color : Color) -> Unit {
  draw_sphere_wires_ffi(center.to_bytes(), radius, rings, slices, color.to_bytes())
}

#borrow(position, color)
extern "c" fn draw_cylinder_ffi(position : Bytes, radius_top : Float, radius_bottom : Float, height : Float, slices : Int, color : Bytes) = "moonbit_DrawCylinder"

pub fn draw_cylinder(position : Vector3, radius_top : Float, radius_bottom : Float, height : Float, slices : Int, color : Color) -> Unit {
  draw_cylinder_ffi(position.to_bytes(), radius_top, radius_bottom, height, slices, color.to_bytes())
}

#borrow(position, color)
extern "c" fn draw_cylinder_wires_ffi(position : Bytes, radius_top : Float, radius_bottom : Float, height : Float, slices : Int, color : Bytes) = "moonbit_DrawCylinderWires"

pub fn draw_cylinder_wires(position : Vector3, radius_top : Float, radius_bottom : Float, height : Float, slices : Int, color : Color) -> Unit {
  draw_cylinder_wires_ffi(position.to_bytes(), radius_top, radius_bottom, height, slices, color.to_bytes())
}

#borrow(center, size, color)
extern "c" fn draw_plane_ffi(center : Bytes, size : Bytes, color : Bytes) = "moonbit_DrawPlane"

pub fn draw_plane(center : Vector3, size : Vector2, color : Color) -> Unit {
  draw_plane_ffi(center.to_bytes(), size.to_bytes(), color.to_bytes())
}

#borrow(ray, color)
extern "c" fn draw_ray_ffi(ray : Bytes, color : Bytes) = "moonbit_DrawRay"

pub fn draw_ray(ray : Ray, color : Color) -> Unit {
  draw_ray_ffi(ray.to_bytes(), color.to_bytes())
}

extern "c" fn draw_grid_ffi(slices : Int, spacing : Float) = "DrawGrid"

pub fn draw_grid(slices : Int, spacing : Float) -> Unit {
  draw_grid_ffi(slices, spacing)
}

#borrow(box_, color)
extern "c" fn draw_bounding_box_ffi(box_ : Bytes, color : Bytes) = "moonbit_DrawBoundingBox"

pub fn draw_bounding_box(box_ : BoundingBox, color : Color) -> Unit {
  draw_bounding_box_ffi(box_.to_bytes(), color.to_bytes())
}

// ============================================================================
// Model loading
// ============================================================================

#borrow(file_name)
extern "c" fn load_model_ffi(file_name : Bytes) -> Model = "moonbit_LoadModel"

pub fn load_model(file_name : String) -> Model {
  load_model_ffi(@utf8.encode(file_name))
}

#borrow(model)
extern "c" fn unload_model_ffi(model : Model) = "moonbit_UnloadModel"

pub fn unload_model(model : Model) -> Unit {
  unload_model_ffi(model)
}

#borrow(model, position, tint)
extern "c" fn draw_model_ffi(model : Model, position : Bytes, scale : Float, tint : Bytes) = "moonbit_DrawModel"

pub fn draw_model(model : Model, position : Vector3, scale : Float, tint : Color) -> Unit {
  draw_model_ffi(model, position.to_bytes(), scale, tint.to_bytes())
}

// ============================================================================
// 3D collision detection
// ============================================================================

#borrow(center1, center2)
extern "c" fn check_collision_spheres_ffi(center1 : Bytes, radius1 : Float, center2 : Bytes, radius2 : Float) -> Bool = "moonbit_CheckCollisionSpheres"

pub fn check_collision_spheres(center1 : Vector3, radius1 : Float, center2 : Vector3, radius2 : Float) -> Bool {
  check_collision_spheres_ffi(center1.to_bytes(), radius1, center2.to_bytes(), radius2)
}

#borrow(box1, box2)
extern "c" fn check_collision_boxes_ffi(box1 : Bytes, box2 : Bytes) -> Bool = "moonbit_CheckCollisionBoxes"

pub fn check_collision_boxes(box1 : BoundingBox, box2 : BoundingBox) -> Bool {
  check_collision_boxes_ffi(box1.to_bytes(), box2.to_bytes())
}

#borrow(box_, center)
extern "c" fn check_collision_box_sphere_ffi(box_ : Bytes, center : Bytes, radius : Float) -> Bool = "moonbit_CheckCollisionBoxSphere"

pub fn check_collision_box_sphere(box_ : BoundingBox, center : Vector3, radius : Float) -> Bool {
  check_collision_box_sphere_ffi(box_.to_bytes(), center.to_bytes(), radius)
}

#borrow(ray, center)
extern "c" fn get_ray_collision_sphere_ffi(ray : Bytes, center : Bytes, radius : Float) -> Bytes = "moonbit_GetRayCollisionSphere"

pub fn get_ray_collision_sphere(ray : Ray, center : Vector3, radius : Float) -> RayCollision {
  RayCollision::from_bytes(get_ray_collision_sphere_ffi(ray.to_bytes(), center.to_bytes(), radius))
}

#borrow(ray, box_)
extern "c" fn get_ray_collision_box_ffi(ray : Bytes, box_ : Bytes) -> Bytes = "moonbit_GetRayCollisionBox"

pub fn get_ray_collision_box(ray : Ray, box_ : BoundingBox) -> RayCollision {
  RayCollision::from_bytes(get_ray_collision_box_ffi(ray.to_bytes(), box_.to_bytes()))
}
