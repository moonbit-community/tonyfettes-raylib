///|
test "Vector3::zero" {
  let v = @raylib.Vector3::zero()
  assert_eq(v, @raylib.Vector3::new(0.0, 0.0, 0.0))
}

///|
test "Vector3::one" {
  let v = @raylib.Vector3::one()
  assert_eq(v, @raylib.Vector3::new(1.0, 1.0, 1.0))
}

///|
test "Vector3::add" {
  let v1 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let v2 = @raylib.Vector3::new(4.0, 5.0, 6.0)
  let result = @raylib.Vector3::add(v1, v2)
  assert_eq(result, @raylib.Vector3::new(5.0, 7.0, 9.0))
}

///|
test "Vector3::add_value" {
  let v = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let result = @raylib.Vector3::add_value(v, 10.0)
  assert_eq(result, @raylib.Vector3::new(11.0, 12.0, 13.0))
}

///|
test "Vector3::subtract" {
  let v1 = @raylib.Vector3::new(5.0, 7.0, 9.0)
  let v2 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let result = @raylib.Vector3::subtract(v1, v2)
  assert_eq(result, @raylib.Vector3::new(4.0, 5.0, 6.0))
}

///|
test "Vector3::subtract_value" {
  let v = @raylib.Vector3::new(11.0, 12.0, 13.0)
  let result = @raylib.Vector3::subtract_value(v, 10.0)
  assert_eq(result, @raylib.Vector3::new(1.0, 2.0, 3.0))
}

///|
test "Vector3::scale" {
  let v = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let result = @raylib.Vector3::scale(v, 3.0)
  assert_eq(result, @raylib.Vector3::new(3.0, 6.0, 9.0))
}

///|
test "Vector3::multiply" {
  let v1 = @raylib.Vector3::new(2.0, 3.0, 4.0)
  let v2 = @raylib.Vector3::new(5.0, 6.0, 7.0)
  let result = @raylib.Vector3::multiply(v1, v2)
  assert_eq(result, @raylib.Vector3::new(10.0, 18.0, 28.0))
}

///|
test "Vector3::cross_product i x j = k" {
  let i = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let j = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let result = @raylib.Vector3::cross_product(i, j)
  assert_eq(result, @raylib.Vector3::new(0.0, 0.0, 1.0))
}

///|
test "Vector3::cross_product j x k = i" {
  let j = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let k = @raylib.Vector3::new(0.0, 0.0, 1.0)
  let result = @raylib.Vector3::cross_product(j, k)
  assert_eq(result, @raylib.Vector3::new(1.0, 0.0, 0.0))
}

///|
test "Vector3::perpendicular" {
  let v = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let p = @raylib.Vector3::perpendicular(v)
  // The result should be perpendicular to v: dot product should be ~0
  let dot = @raylib.Vector3::dot_product(v, p)
  assert_true(dot.abs() < 0.001)
  // The result should be non-zero
  let len = @raylib.Vector3::length(p)
  assert_true(len > 0.001)
}

///|
test "Vector3::perpendicular general vector" {
  let v = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let p = @raylib.Vector3::perpendicular(v)
  let dot = @raylib.Vector3::dot_product(v, p)
  assert_true(dot.abs() < 0.001)
}

///|
test "Vector3::length" {
  let v = @raylib.Vector3::new(3.0, 4.0, 0.0)
  let result = @raylib.Vector3::length(v)
  assert_true((result - 5.0).abs() < 0.001)
}

///|
test "Vector3::length_sqr" {
  let v = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let result = @raylib.Vector3::length_sqr(v)
  assert_true((result - 14.0).abs() < 0.001)
}

///|
test "Vector3::dot_product" {
  let v1 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let v2 = @raylib.Vector3::new(4.0, 5.0, 6.0)
  let result = @raylib.Vector3::dot_product(v1, v2)
  // 1*4 + 2*5 + 3*6 = 4 + 10 + 18 = 32
  assert_true((result - 32.0).abs() < 0.001)
}

///|
test "Vector3::distance" {
  let v1 = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let v2 = @raylib.Vector3::new(4.0, 0.0, 0.0)
  let result = @raylib.Vector3::distance(v1, v2)
  assert_true((result - 3.0).abs() < 0.001)
}

///|
test "Vector3::distance_sqr" {
  let v1 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let v2 = @raylib.Vector3::new(4.0, 6.0, 3.0)
  let result = @raylib.Vector3::distance_sqr(v1, v2)
  // (3)^2 + (4)^2 + (0)^2 = 9 + 16 = 25
  assert_true((result - 25.0).abs() < 0.001)
}

///|
test "Vector3::angle" {
  let v1 = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let v2 = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let result = @raylib.Vector3::angle(v1, v2)
  // Angle between x-axis and y-axis is PI/2
  let pi : Float = 3.14159265358979323846
  assert_true((result - pi / 2.0).abs() < 0.001)
}

///|
test "Vector3::normalize" {
  let v = @raylib.Vector3::new(3.0, 0.0, 4.0)
  let result = @raylib.Vector3::normalize(v)
  // length = 5, normalized = (0.6, 0.0, 0.8)
  assert_true((result.x - 0.6).abs() < 0.001)
  assert_true((result.y - 0.0).abs() < 0.001)
  assert_true((result.z - 0.8).abs() < 0.001)
}

///|
test "Vector3::normalize zero vector" {
  let v = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let result = @raylib.Vector3::normalize(v)
  assert_eq(result, @raylib.Vector3::new(0.0, 0.0, 0.0))
}

///|
test "Vector3::project" {
  // Project (1,2,3) onto (1,0,0) should give (1,0,0)
  let v1 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let v2 = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let result = @raylib.Vector3::project(v1, v2)
  assert_true((result.x - 1.0).abs() < 0.001)
  assert_true((result.y - 0.0).abs() < 0.001)
  assert_true((result.z - 0.0).abs() < 0.001)
}

///|
test "Vector3::reject" {
  // Reject (1,2,3) from (1,0,0) should give (0,2,3)
  let v1 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let v2 = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let result = @raylib.Vector3::reject(v1, v2)
  assert_true((result.x - 0.0).abs() < 0.001)
  assert_true((result.y - 2.0).abs() < 0.001)
  assert_true((result.z - 3.0).abs() < 0.001)
}

///|
test "Vector3::lerp" {
  let v1 = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let v2 = @raylib.Vector3::new(10.0, 20.0, 30.0)
  let result = @raylib.Vector3::lerp(v1, v2, 0.5)
  assert_eq(result, @raylib.Vector3::new(5.0, 10.0, 15.0))
}

///|
test "Vector3::lerp endpoints" {
  let v1 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let v2 = @raylib.Vector3::new(4.0, 5.0, 6.0)
  assert_eq(@raylib.Vector3::lerp(v1, v2, 0.0), v1)
  assert_eq(@raylib.Vector3::lerp(v1, v2, 1.0), v2)
}

///|
test "Vector3::reflect" {
  // Reflect (1, -1, 0) off horizontal surface normal (0, 1, 0)
  let v = @raylib.Vector3::new(1.0, -1.0, 0.0)
  let normal = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let result = @raylib.Vector3::reflect(v, normal)
  assert_true((result.x - 1.0).abs() < 0.001)
  assert_true((result.y - 1.0).abs() < 0.001)
  assert_true((result.z - 0.0).abs() < 0.001)
}

///|
test "Vector3::min" {
  let v1 = @raylib.Vector3::new(1.0, 5.0, 3.0)
  let v2 = @raylib.Vector3::new(4.0, 2.0, 6.0)
  let result = @raylib.Vector3::min(v1, v2)
  assert_eq(result, @raylib.Vector3::new(1.0, 2.0, 3.0))
}

///|
test "Vector3::max" {
  let v1 = @raylib.Vector3::new(1.0, 5.0, 3.0)
  let v2 = @raylib.Vector3::new(4.0, 2.0, 6.0)
  let result = @raylib.Vector3::max(v1, v2)
  assert_eq(result, @raylib.Vector3::new(4.0, 5.0, 6.0))
}

///|
test "Vector3::barycenter at vertex a" {
  let a = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let b = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let c = @raylib.Vector3::new(0.0, 1.0, 0.0)
  // Point at vertex a should give barycentric (1, 0, 0)
  let result = @raylib.Vector3::barycenter(a, a, b, c)
  assert_true((result.x - 1.0).abs() < 0.001)
  assert_true((result.y - 0.0).abs() < 0.001)
  assert_true((result.z - 0.0).abs() < 0.001)
}

///|
test "Vector3::barycenter at vertex b" {
  let a = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let b = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let c = @raylib.Vector3::new(0.0, 1.0, 0.0)
  // Point at vertex b should give barycentric (0, 1, 0)
  let result = @raylib.Vector3::barycenter(b, a, b, c)
  assert_true((result.x - 0.0).abs() < 0.001)
  assert_true((result.y - 1.0).abs() < 0.001)
  assert_true((result.z - 0.0).abs() < 0.001)
}

///|
test "Vector3::unproject with identity matrices" {
  let source = @raylib.Vector3::new(0.5, 0.5, 0.5)
  let identity = @raylib.Matrix::identity()
  let result = @raylib.Vector3::unproject(source, identity, identity)
  // With identity projection and view, unproject should return the source
  assert_true((result.x - 0.5).abs() < 0.001)
  assert_true((result.y - 0.5).abs() < 0.001)
  assert_true((result.z - 0.5).abs() < 0.001)
}

///|
test "Vector3::ortho_normalize" {
  let v1 = @raylib.Vector3::new(1.0, 2.0, 0.0)
  let v2 = @raylib.Vector3::new(0.0, 1.0, 1.0)
  let (r1, r2) = @raylib.Vector3::ortho_normalize(v1, v2)
  // r1 should be unit length
  let len1 = @raylib.Vector3::length(r1)
  assert_true((len1 - 1.0).abs() < 0.001)
  // r2 should be unit length
  let len2 = @raylib.Vector3::length(r2)
  assert_true((len2 - 1.0).abs() < 0.001)
  // r1 and r2 should be orthogonal
  let dot = @raylib.Vector3::dot_product(r1, r2)
  assert_true(dot.abs() < 0.001)
}

///|
test "Vector3::transform with identity matrix" {
  let v = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let identity = @raylib.Matrix::identity()
  let result = @raylib.Vector3::transform(v, identity)
  assert_true((result.x - 1.0).abs() < 0.001)
  assert_true((result.y - 2.0).abs() < 0.001)
  assert_true((result.z - 3.0).abs() < 0.001)
}

///|
test "Vector3::rotate_by_quaternion identity" {
  let v = @raylib.Vector3::new(1.0, 2.0, 3.0)
  // Identity quaternion: (0, 0, 0, 1)
  let q = @raylib.Vector4::new(0.0, 0.0, 0.0, 1.0)
  let result = @raylib.Vector3::rotate_by_quaternion(v, q)
  assert_true((result.x - 1.0).abs() < 0.001)
  assert_true((result.y - 2.0).abs() < 0.001)
  assert_true((result.z - 3.0).abs() < 0.001)
}

///|
test "Vector3::rotate_by_quaternion 180 around z" {
  let v = @raylib.Vector3::new(1.0, 0.0, 0.0)
  // 180 degree rotation around z-axis: quaternion (0, 0, 1, 0)
  // sin(90)=1, cos(90)=0 -> q = (0, 0, sin(90), cos(90)) = (0, 0, 1, 0)
  let q = @raylib.Vector4::new(0.0, 0.0, 1.0, 0.0)
  let result = @raylib.Vector3::rotate_by_quaternion(v, q)
  assert_true((result.x - -1.0).abs() < 0.001)
  assert_true((result.y - 0.0).abs() < 0.001)
  assert_true((result.z - 0.0).abs() < 0.001)
}

///|
test "Vector3::rotate_by_axis_angle 90 degrees around z" {
  let v = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let axis = @raylib.Vector3::new(0.0, 0.0, 1.0)
  let angle : Float = 3.14159265358979323846 / 2.0
  let result = @raylib.Vector3::rotate_by_axis_angle(v, axis, angle)
  // Rotating (1,0,0) by 90 degrees around z should give (0,1,0)
  assert_true((result.x - 0.0).abs() < 0.001)
  assert_true((result.y - 1.0).abs() < 0.001)
  assert_true((result.z - 0.0).abs() < 0.001)
}

///|
test "Vector3::rotate_by_axis_angle 180 degrees around y" {
  let v = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let axis = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let angle : Float = 3.14159265358979323846
  let result = @raylib.Vector3::rotate_by_axis_angle(v, axis, angle)
  // Rotating (1,0,0) by 180 degrees around y should give (-1,0,0)
  assert_true((result.x - -1.0).abs() < 0.001)
  assert_true((result.y - 0.0).abs() < 0.001)
  assert_true((result.z - 0.0).abs() < 0.001)
}

///|
test "Vector3::move_towards within range" {
  let v = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let target = @raylib.Vector3::new(3.0, 4.0, 0.0)
  // Distance is 5, max_distance is 10, so we reach the target
  let result = @raylib.Vector3::move_towards(v, target, 10.0)
  assert_eq(result, target)
}

///|
test "Vector3::move_towards partial" {
  let v = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let target = @raylib.Vector3::new(3.0, 4.0, 0.0)
  // Distance is 5, move only 2.5 units
  let result = @raylib.Vector3::move_towards(v, target, 2.5)
  // Direction is (0.6, 0.8, 0), moved 2.5 -> (1.5, 2.0, 0)
  assert_true((result.x - 1.5).abs() < 0.001)
  assert_true((result.y - 2.0).abs() < 0.001)
  assert_true((result.z - 0.0).abs() < 0.001)
}

///|
test "Vector3::invert" {
  let v = @raylib.Vector3::new(2.0, 4.0, 5.0)
  let result = @raylib.Vector3::invert(v)
  assert_true((result.x - 0.5).abs() < 0.001)
  assert_true((result.y - 0.25).abs() < 0.001)
  assert_true((result.z - 0.2).abs() < 0.001)
}

///|
test "Vector3::clamp" {
  let v = @raylib.Vector3::new(-5.0, 3.0, 15.0)
  let min = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let max = @raylib.Vector3::new(10.0, 10.0, 10.0)
  let result = @raylib.Vector3::clamp(v, min, max)
  assert_eq(result, @raylib.Vector3::new(0.0, 3.0, 10.0))
}

///|
test "Vector3::equals true" {
  let v1 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let v2 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  assert_true(@raylib.Vector3::equals(v1, v2))
}

///|
test "Vector3::equals false" {
  let v1 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let v2 = @raylib.Vector3::new(1.0, 2.0, 4.0)
  assert_false(@raylib.Vector3::equals(v1, v2))
}

///|
test "Vector3::equals nearly equal" {
  let v1 = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let v2 = @raylib.Vector3::new(1.0000001, 2.0000001, 3.0000001)
  assert_true(@raylib.Vector3::equals(v1, v2))
}

///|
test "Vector3::refract normal case" {
  // Light going straight down, hitting a horizontal surface
  let v = @raylib.Vector3::new(0.0, -1.0, 0.0)
  let n = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let r : Float = 0.5 // ratio of indices of refraction
  let result = @raylib.Vector3::refract(v, n, r)
  // For normal incidence: refracted = r*v - (r*dot + sqrt(1 - r^2*(1-dot^2)))*n
  // dot = -1, d = 1 - 0.25*(1-1) = 1, sqrt(d) = 1
  // refracted = 0.5*(0,-1,0) - (0.5*(-1) + 1)*(0,1,0) = (0,-0.5,0) - (0.5)*(0,1,0) = (0,-1,0)
  assert_true((result.x - 0.0).abs() < 0.001)
  assert_true((result.y - -1.0).abs() < 0.001)
  assert_true((result.z - 0.0).abs() < 0.001)
}

///|
test "Vector3::refract total internal reflection" {
  // Angle too steep for the refraction ratio -> total internal reflection -> zero vector
  // Use a large ratio and a grazing angle
  let v = @raylib.Vector3::normalize(@raylib.Vector3::new(1.0, -0.1, 0.0))
  let n = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let r : Float = 10.0 // very high ratio to force total internal reflection
  let result = @raylib.Vector3::refract(v, n, r)
  // d = 1 - r^2 * (1 - dot^2) should be negative -> returns zero
  assert_eq(result, @raylib.Vector3::new(0.0, 0.0, 0.0))
}

///|
test "Vector3::perpendicular z-smallest branch" {
  // Vector where |z| < |y| < |x|, so the fabsf(v.z) < min branch triggers
  let v = @raylib.Vector3::new(5.0, 3.0, 1.0)
  let p = @raylib.Vector3::perpendicular(v)
  // Result should be perpendicular to v (dot product ~0)
  let dot = @raylib.Vector3::dot_product(v, p)
  assert_true(dot.abs() < 0.001)
  // Result should be non-zero
  let len = @raylib.Vector3::length(p)
  assert_true(len > 0.001)
}
