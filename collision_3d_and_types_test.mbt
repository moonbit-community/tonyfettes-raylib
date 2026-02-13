// Tests for 3D collision detection and RayCollision type accessors.
// All functions tested here are headless-safe (no window context needed).

///|
test "check_collision_spheres - overlapping" {
  let center1 = Vector3::new(0.0, 0.0, 0.0)
  let center2 = Vector3::new(3.0, 0.0, 0.0)
  // Radii sum to 6.0, distance is 3.0 => overlap
  assert_true(check_collision_spheres(center1, 3.0, center2, 3.0))
}

///|
test "check_collision_spheres - non-overlapping" {
  let center1 = Vector3::new(0.0, 0.0, 0.0)
  let center2 = Vector3::new(100.0, 0.0, 0.0)
  // Radii sum to 4.0, distance is 100.0 => no overlap
  assert_true(not(check_collision_spheres(center1, 2.0, center2, 2.0)))
}

///|
test "check_collision_boxes - overlapping" {
  let box1 = BoundingBox::new(
    Vector3::new(-1.0, -1.0, -1.0),
    Vector3::new(1.0, 1.0, 1.0),
  )
  let box2 = BoundingBox::new(
    Vector3::new(0.0, 0.0, 0.0),
    Vector3::new(2.0, 2.0, 2.0),
  )
  assert_true(check_collision_boxes(box1, box2))
}

///|
test "check_collision_boxes - non-overlapping" {
  let box1 = BoundingBox::new(
    Vector3::new(-1.0, -1.0, -1.0),
    Vector3::new(1.0, 1.0, 1.0),
  )
  let box2 = BoundingBox::new(
    Vector3::new(10.0, 10.0, 10.0),
    Vector3::new(12.0, 12.0, 12.0),
  )
  assert_true(not(check_collision_boxes(box1, box2)))
}

///|
test "check_collision_box_sphere - inside" {
  let box_ = BoundingBox::new(
    Vector3::new(-5.0, -5.0, -5.0),
    Vector3::new(5.0, 5.0, 5.0),
  )
  let center = Vector3::new(0.0, 0.0, 0.0)
  assert_true(check_collision_box_sphere(box_, center, 1.0))
}

///|
test "check_collision_box_sphere - outside" {
  let box_ = BoundingBox::new(
    Vector3::new(-1.0, -1.0, -1.0),
    Vector3::new(1.0, 1.0, 1.0),
  )
  let center = Vector3::new(50.0, 50.0, 50.0)
  assert_true(not(check_collision_box_sphere(box_, center, 1.0)))
}

///|
test "get_ray_collision_sphere - hit" {
  // Ray at origin pointing along +X, sphere at (10,0,0) with radius 2
  let ray = Ray::new(Vector3::new(0.0, 0.0, 0.0), Vector3::new(1.0, 0.0, 0.0))
  let center = Vector3::new(10.0, 0.0, 0.0)
  let result = get_ray_collision_sphere(ray, center, 2.0)
  assert_true(result.hit)
  assert_true(result.distance > 0.0)
}

///|
test "get_ray_collision_sphere - miss" {
  // Ray at origin pointing along +X, sphere far away on Y axis
  let ray = Ray::new(Vector3::new(0.0, 0.0, 0.0), Vector3::new(1.0, 0.0, 0.0))
  let center = Vector3::new(0.0, 100.0, 0.0)
  let result = get_ray_collision_sphere(ray, center, 1.0)
  assert_true(not(result.hit))
}

///|
test "get_ray_collision_box - hit" {
  // Ray at origin pointing along +X, box ahead on X axis
  let ray = Ray::new(Vector3::new(0.0, 0.0, 0.0), Vector3::new(1.0, 0.0, 0.0))
  let box_ = BoundingBox::new(
    Vector3::new(5.0, -1.0, -1.0),
    Vector3::new(7.0, 1.0, 1.0),
  )
  let result = get_ray_collision_box(ray, box_)
  assert_true(result.hit)
  assert_true(result.distance > 0.0)
}

///|
test "get_ray_collision_box - miss" {
  // Ray at origin pointing along +X, box is off to the side on Y axis
  let ray = Ray::new(Vector3::new(0.0, 0.0, 0.0), Vector3::new(1.0, 0.0, 0.0))
  let box_ = BoundingBox::new(
    Vector3::new(5.0, 50.0, 50.0),
    Vector3::new(7.0, 52.0, 52.0),
  )
  let result = get_ray_collision_box(ray, box_)
  assert_true(not(result.hit))
}

///|
test "check_collision_point_triangle - inside and outside" {
  let p1 = Vector2::new(0.0, 0.0)
  let p2 = Vector2::new(10.0, 0.0)
  let p3 = Vector2::new(5.0, 10.0)
  // Point inside the triangle
  let inside = Vector2::new(5.0, 3.0)
  assert_true(check_collision_point_triangle(inside, p1, p2, p3))
  // Point outside the triangle
  let outside = Vector2::new(20.0, 20.0)
  assert_true(not(check_collision_point_triangle(outside, p1, p2, p3)))
}

///|
test "RayCollision field accessors from real collision" {
  // Ray aimed directly at a sphere => guaranteed hit with known geometry
  let ray = Ray::new(Vector3::new(0.0, 0.0, 0.0), Vector3::new(1.0, 0.0, 0.0))
  let center = Vector3::new(10.0, 0.0, 0.0)
  let radius : Float = 2.0
  let rc = get_ray_collision_sphere(ray, center, radius)
  // Verify hit flag
  assert_true(rc.hit)
  // Distance should be 8.0 (sphere surface at x=8 from origin)
  assert_true(rc.distance > 7.5 && rc.distance < 8.5)
  // Hit point should be near (8, 0, 0)
  assert_true(rc.point.x > 7.5 && rc.point.x < 8.5)
  assert_true(rc.point.y > -0.5 && rc.point.y < 0.5)
  assert_true(rc.point.z > -0.5 && rc.point.z < 0.5)
  // Normal at the hit point should point back toward the ray origin (negative X)
  assert_true(rc.normal.x < 0.0)
}
