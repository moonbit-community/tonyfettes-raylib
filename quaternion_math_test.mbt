// Helper: check if two Vector4 are approximately equal

///|
fn approx_v4(a : @raylib.Vector4, b : @raylib.Vector4) -> Bool {
  approx(a.x, b.x) && approx(a.y, b.y) && approx(a.z, b.z) && approx(a.w, b.w)
}

// Helper: check if two Vector3 are approximately equal

///|
fn approx_v3(a : @raylib.Vector3, b : @raylib.Vector3) -> Bool {
  approx(a.x, b.x) && approx(a.y, b.y) && approx(a.z, b.z)
}

// ===== Vector4 basic functions =====

///|
test "Vector4::zero" {
  let v = @raylib.Vector4::zero()
  assert_eq(v, @raylib.Vector4::new(0.0, 0.0, 0.0, 0.0))
}

///|
test "Vector4::one" {
  let v = @raylib.Vector4::one()
  assert_eq(v, @raylib.Vector4::new(1.0, 1.0, 1.0, 1.0))
}

///|
test "Vector4::add" {
  let a = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let b = @raylib.Vector4::new(5.0, 6.0, 7.0, 8.0)
  let r = @raylib.Vector4::add(a, b)
  assert_eq(r, @raylib.Vector4::new(6.0, 8.0, 10.0, 12.0))
}

///|
test "Vector4::add_value" {
  let v = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let r = @raylib.Vector4::add_value(v, 10.0)
  assert_eq(r, @raylib.Vector4::new(11.0, 12.0, 13.0, 14.0))
}

///|
test "Vector4::subtract" {
  let a = @raylib.Vector4::new(10.0, 20.0, 30.0, 40.0)
  let b = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let r = @raylib.Vector4::subtract(a, b)
  assert_eq(r, @raylib.Vector4::new(9.0, 18.0, 27.0, 36.0))
}

///|
test "Vector4::subtract_value" {
  let v = @raylib.Vector4::new(10.0, 20.0, 30.0, 40.0)
  let r = @raylib.Vector4::subtract_value(v, 5.0)
  assert_eq(r, @raylib.Vector4::new(5.0, 15.0, 25.0, 35.0))
}

///|
test "Vector4::length" {
  let v = @raylib.Vector4::new(1.0, 0.0, 0.0, 0.0)
  assert_true(approx(@raylib.Vector4::length(v), 1.0))
  let v2 = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  // sqrt(1+4+9+16) = sqrt(30) ~= 5.477
  assert_true(approx(@raylib.Vector4::length(v2), 5.477))
}

///|
test "Vector4::scale" {
  let v = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let r = @raylib.Vector4::scale(v, 2.0)
  assert_eq(r, @raylib.Vector4::new(2.0, 4.0, 6.0, 8.0))
}

///|
test "Vector4::multiply" {
  let a = @raylib.Vector4::new(2.0, 3.0, 4.0, 5.0)
  let b = @raylib.Vector4::new(10.0, 20.0, 30.0, 40.0)
  let r = @raylib.Vector4::multiply(a, b)
  assert_eq(r, @raylib.Vector4::new(20.0, 60.0, 120.0, 200.0))
}

///|
test "Vector4::negate" {
  let v = @raylib.Vector4::new(1.0, -2.0, 3.0, -4.0)
  let r = @raylib.Vector4::negate(v)
  assert_eq(r, @raylib.Vector4::new(-1.0, 2.0, -3.0, 4.0))
}

///|
test "Vector4::divide" {
  let a = @raylib.Vector4::new(10.0, 20.0, 30.0, 40.0)
  let b = @raylib.Vector4::new(2.0, 4.0, 5.0, 8.0)
  let r = @raylib.Vector4::divide(a, b)
  assert_eq(r, @raylib.Vector4::new(5.0, 5.0, 6.0, 5.0))
}

///|
test "Vector4::normalize normal vector" {
  let v = @raylib.Vector4::new(3.0, 0.0, 0.0, 4.0)
  let r = @raylib.Vector4::normalize(v)
  // length = 5, so x=0.6, w=0.8
  assert_true(approx(r.x, 0.6))
  assert_true(approx(r.y, 0.0))
  assert_true(approx(r.z, 0.0))
  assert_true(approx(r.w, 0.8))
  assert_true(approx(@raylib.Vector4::length(r), 1.0))
}

///|
test "Vector4::normalize zero vector" {
  let v = @raylib.Vector4::new(0.0, 0.0, 0.0, 0.0)
  let r = @raylib.Vector4::normalize(v)
  assert_eq(r, @raylib.Vector4::new(0.0, 0.0, 0.0, 0.0))
}

///|
test "Vector4::min" {
  let a = @raylib.Vector4::new(1.0, 5.0, 3.0, 7.0)
  let b = @raylib.Vector4::new(4.0, 2.0, 6.0, 0.0)
  let r = @raylib.Vector4::min(a, b)
  assert_eq(r, @raylib.Vector4::new(1.0, 2.0, 3.0, 0.0))
}

///|
test "Vector4::max" {
  let a = @raylib.Vector4::new(1.0, 5.0, 3.0, 7.0)
  let b = @raylib.Vector4::new(4.0, 2.0, 6.0, 0.0)
  let r = @raylib.Vector4::max(a, b)
  assert_eq(r, @raylib.Vector4::new(4.0, 5.0, 6.0, 7.0))
}

///|
test "Vector4::equals equal vectors" {
  let a = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let b = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  assert_true(@raylib.Vector4::equals(a, b))
}

///|
test "Vector4::equals not equal vectors" {
  let a = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let b = @raylib.Vector4::new(1.0, 2.0, 3.0, 5.0)
  assert_false(@raylib.Vector4::equals(a, b))
}

// ===== Quaternion operations =====

///|
test "Vector4::quat_identity" {
  let q = @raylib.Vector4::quat_identity()
  assert_eq(q, @raylib.Vector4::new(0.0, 0.0, 0.0, 1.0))
}

///|
test "Vector4::quat_length" {
  let q = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  // sqrt(1+4+9+16) = sqrt(30) ~= 5.477
  assert_true(approx(@raylib.Vector4::quat_length(q), 5.477))
  // identity quat has length 1
  assert_true(
    approx(@raylib.Vector4::quat_length(@raylib.Vector4::quat_identity()), 1.0),
  )
}

///|
test "Vector4::quat_normalize normal" {
  let q = @raylib.Vector4::new(0.0, 0.0, 0.0, 2.0)
  let r = @raylib.Vector4::quat_normalize(q)
  assert_true(approx(r.w, 1.0))
  assert_true(approx(r.x, 0.0))
  assert_true(approx(@raylib.Vector4::quat_length(r), 1.0))
}

///|
test "Vector4::quat_normalize zero quaternion" {
  // When length is 0, quat_normalize uses length=1 (no division by zero)
  let q = @raylib.Vector4::new(0.0, 0.0, 0.0, 0.0)
  let r = @raylib.Vector4::quat_normalize(q)
  assert_eq(r, @raylib.Vector4::new(0.0, 0.0, 0.0, 0.0))
}

///|
test "Vector4::quat_invert normal" {
  // For a unit quaternion (0,0,0,1), inverse is (0,0,0,1)
  let q = @raylib.Vector4::quat_identity()
  let r = @raylib.Vector4::quat_invert(q)
  assert_true(approx(r.x, 0.0))
  assert_true(approx(r.y, 0.0))
  assert_true(approx(r.z, 0.0))
  assert_true(approx(r.w, 1.0))
  // For q = (1,0,0,0), inverse is (-1,0,0,0) since length_sq = 1
  let q2 = @raylib.Vector4::new(1.0, 0.0, 0.0, 0.0)
  let r2 = @raylib.Vector4::quat_invert(q2)
  assert_true(approx(r2.x, -1.0))
  assert_true(approx(r2.w, 0.0))
}

///|
test "Vector4::quat_invert zero length" {
  let q = @raylib.Vector4::new(0.0, 0.0, 0.0, 0.0)
  let r = @raylib.Vector4::quat_invert(q)
  // Returns q unchanged when length_sq == 0
  assert_eq(r, q)
}

///|
test "Vector4::quat_multiply" {
  let identity = @raylib.Vector4::quat_identity()
  let q = @raylib.Vector4::new(0.5, 0.5, 0.5, 0.5)
  // Multiplying by identity should return the same quaternion
  let r = @raylib.Vector4::quat_multiply(q, identity)
  assert_true(approx_v4(r, q))
  // Multiplying identity by q should also return q
  let r2 = @raylib.Vector4::quat_multiply(identity, q)
  assert_true(approx_v4(r2, q))
  // Non-trivial multiplication: 90-degree rotations about x and y
  let qx = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(1.0, 0.0, 0.0),
    pi / 2.0,
  )
  let qy = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    pi / 2.0,
  )
  let combined = @raylib.Vector4::quat_multiply(qx, qy)
  // Result should be a unit quaternion
  assert_true(approx(@raylib.Vector4::quat_length(combined), 1.0))
}

///|
test "Vector4::quat_scale" {
  let q = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let r = @raylib.Vector4::quat_scale(q, 0.5)
  assert_eq(r, @raylib.Vector4::new(0.5, 1.0, 1.5, 2.0))
}

///|
test "Vector4::quat_divide" {
  let a = @raylib.Vector4::new(10.0, 20.0, 30.0, 40.0)
  let b = @raylib.Vector4::new(2.0, 4.0, 5.0, 8.0)
  let r = @raylib.Vector4::quat_divide(a, b)
  assert_eq(r, @raylib.Vector4::new(5.0, 5.0, 6.0, 5.0))
}

///|
test "Vector4::quat_lerp" {
  let a = @raylib.Vector4::new(0.0, 0.0, 0.0, 1.0)
  let b = @raylib.Vector4::new(1.0, 0.0, 0.0, 0.0)
  // t=0 -> a
  let r0 = @raylib.Vector4::quat_lerp(a, b, 0.0)
  assert_true(approx_v4(r0, a))
  // t=1 -> b
  let r1 = @raylib.Vector4::quat_lerp(a, b, 1.0)
  assert_true(approx_v4(r1, b))
  // t=0.5 -> midpoint
  let r = @raylib.Vector4::quat_lerp(a, b, 0.5)
  assert_true(approx(r.x, 0.5))
  assert_true(approx(r.w, 0.5))
}

///|
test "Vector4::quat_nlerp" {
  let a = @raylib.Vector4::new(0.0, 0.0, 0.0, 1.0)
  let b = @raylib.Vector4::new(1.0, 0.0, 0.0, 0.0)
  // t=0 -> normalized a = identity
  let r0 = @raylib.Vector4::quat_nlerp(a, b, 0.0)
  assert_true(approx_v4(r0, a))
  // t=1 -> normalized b
  let r1 = @raylib.Vector4::quat_nlerp(a, b, 1.0)
  assert_true(approx_v4(r1, b))
  // t=0.5 -> normalized midpoint, length should be 1
  let r = @raylib.Vector4::quat_nlerp(a, b, 0.5)
  assert_true(approx(@raylib.Vector4::quat_length(r), 1.0))
}

///|
test "Vector4::quat_slerp same quaternion (cos >= 1)" {
  let q = @raylib.Vector4::quat_identity()
  let r = @raylib.Vector4::quat_slerp(q, q, 0.5)
  assert_true(approx_v4(r, q))
}

///|
test "Vector4::quat_slerp opposite quaternions (cos < 0 branch)" {
  let q1 = @raylib.Vector4::quat_identity() // (0,0,0,1)
  // Negate to get (0,0,0,-1) which represents the same rotation but cos_half_theta < 0
  let q2 = @raylib.Vector4::new(0.0, 0.0, 0.0, -1.0)
  let r = @raylib.Vector4::quat_slerp(q1, q2, 0.5)
  // The code negates q2 and then cos becomes positive again (actually 1.0),
  // so it hits the fabsf(cos_half_theta) >= 1.0 branch and returns q1
  assert_true(approx_v4(r, q1))
}

///|
test "Vector4::quat_slerp nearly equal quaternions (cos > 0.95 branch)" {
  let q1 = @raylib.Vector4::quat_identity()
  // A very tiny rotation around z axis -- cos will be very close to 1 (> 0.95)
  let q2 = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 1.0),
    0.01,
  )
  let r = @raylib.Vector4::quat_slerp(q1, q2, 0.5)
  // Should be approximately halfway, and normalized
  assert_true(approx(@raylib.Vector4::quat_length(r), 1.0))
  // Should be between q1 and q2
  assert_true(r.w > q2.w - 0.001)
  assert_true(r.w < q1.w + 0.001)
}

///|
test "Vector4::quat_slerp general case (full slerp)" {
  // 90 degrees apart, cos(45deg) ~= 0.707 which is between 0 and 0.95
  let q1 = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 1.0),
    0.0,
  )
  let q2 = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 1.0),
    pi / 2.0,
  )
  // At t=0, should be close to q1
  let r0 = @raylib.Vector4::quat_slerp(q1, q2, 0.0)
  assert_true(approx_v4(r0, q1))
  // At t=1, should be close to q2
  let r1 = @raylib.Vector4::quat_slerp(q1, q2, 1.0)
  assert_true(approx_v4(r1, q2))
  // At t=0.5, should be a 45-degree rotation about z
  let r = @raylib.Vector4::quat_slerp(q1, q2, 0.5)
  let expected_mid = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 1.0),
    pi / 4.0,
  )
  assert_true(approx_v4(r, expected_mid))
}

///|
test "Vector4::quat_cubic_hermite_spline" {
  let q1 = @raylib.Vector4::quat_identity()
  let q2 = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    pi / 2.0,
  )
  let tangent = @raylib.Vector4::new(0.0, 0.0, 0.0, 0.0)
  // At t=0, result should be q1 (normalized)
  let r0 = @raylib.Vector4::quat_cubic_hermite_spline(
    q1, tangent, q2, tangent, 0.0,
  )
  assert_true(approx_v4(r0, @raylib.Vector4::quat_normalize(q1)))
  // At t=1, result should be q2 (normalized)
  let r1 = @raylib.Vector4::quat_cubic_hermite_spline(
    q1, tangent, q2, tangent, 1.0,
  )
  assert_true(approx_v4(r1, @raylib.Vector4::quat_normalize(q2)))
  // At t=0.5, result should be unit quaternion
  let r = @raylib.Vector4::quat_cubic_hermite_spline(
    q1, tangent, q2, tangent, 0.5,
  )
  assert_true(approx(@raylib.Vector4::quat_length(r), 1.0))
}

///|
test "Vector4::quat_from_vector3_to_vector3" {
  let from_ = @raylib.Vector3::new(1.0, 0.0, 0.0)
  let to = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let q = @raylib.Vector4::quat_from_vector3_to_vector3(from_, to)
  // Should be a unit quaternion
  assert_true(approx(@raylib.Vector4::quat_length(q), 1.0))
  // 90-degree rotation about z, so q.z should be sin(45deg) ~= 0.7071
  assert_true(approx(q.z, 0.7071))
  // Same vector -> identity (no rotation)
  let same = @raylib.Vector4::quat_from_vector3_to_vector3(from_, from_)
  assert_true(approx(same.w, 1.0))
  assert_true(approx(same.x, 0.0))
}

///|
test "Vector4::quat_from_matrix identity matrix (biggest_index 0, w dominant)" {
  let mat = @raylib.Matrix::identity()
  let q = @raylib.Vector4::quat_from_matrix(mat)
  // Identity matrix -> identity quaternion (0,0,0,1)
  assert_true(approx(q.x, 0.0))
  assert_true(approx(q.y, 0.0))
  assert_true(approx(q.z, 0.0))
  assert_true(approx(q.w, 1.0))
}

///|
test "Vector4::quat_from_matrix rotate_x pi (biggest_index 1, x dominant)" {
  // rotate_x(pi): m0=1, m5=cos(pi)=-1, m10=cos(pi)=-1
  // four_w = 1 + (-1) + (-1) = -1
  // four_x = 1 - (-1) - (-1) = 3  <-- winner
  // four_y = (-1) - 1 - (-1) = -1
  // four_z = (-1) - 1 - (-1) = -1
  let mat = @raylib.Matrix::rotate_x(pi)
  let q = @raylib.Vector4::quat_from_matrix(mat)
  // Should represent 180-degree rotation about x: q = (+/-1, 0, 0, 0)
  assert_true(approx(q.x.abs(), 1.0))
  assert_true(approx(q.y, 0.0))
  assert_true(approx(q.z, 0.0))
  assert_true(approx(q.w, 0.0))
}

///|
test "Vector4::quat_from_matrix rotate_y pi (biggest_index 2, y dominant)" {
  // rotate_y(pi): m0=cos(pi)=-1, m5=1, m10=cos(pi)=-1
  // four_w = -1 + 1 + (-1) = -1
  // four_x = -1 - 1 - (-1) = -1
  // four_y = 1 - (-1) - (-1) = 3  <-- winner
  // four_z = (-1) - (-1) - 1 = -1
  let mat = @raylib.Matrix::rotate_y(pi)
  let q = @raylib.Vector4::quat_from_matrix(mat)
  // Should represent 180-degree rotation about y: q = (0, +/-1, 0, 0)
  assert_true(approx(q.x, 0.0))
  assert_true(approx(q.y.abs(), 1.0))
  assert_true(approx(q.z, 0.0))
  assert_true(approx(q.w, 0.0))
}

///|
test "Vector4::quat_from_matrix rotate_z pi (biggest_index 3, z dominant)" {
  // rotate_z(pi): m0=cos(pi)=-1, m5=cos(pi)=-1, m10=1
  // four_w = -1 + (-1) + 1 = -1
  // four_x = -1 - (-1) - 1 = -1
  // four_y = (-1) - (-1) - 1 = -1
  // four_z = 1 - (-1) - (-1) = 3  <-- winner
  let mat = @raylib.Matrix::rotate_z(pi)
  let q = @raylib.Vector4::quat_from_matrix(mat)
  // Should represent 180-degree rotation about z: q = (0, 0, +/-1, 0)
  assert_true(approx(q.x, 0.0))
  assert_true(approx(q.y, 0.0))
  assert_true(approx(q.z.abs(), 1.0))
  assert_true(approx(q.w, 0.0))
}

///|
test "Vector4::quat_to_matrix identity quaternion" {
  let q = @raylib.Vector4::quat_identity()
  let mat = @raylib.Vector4::quat_to_matrix(q)
  let identity = @raylib.Matrix::identity()
  assert_eq(mat, identity)
}

///|
test "Vector4::quat_to_matrix rotation quaternion" {
  // 90-degree rotation around z
  let q = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 1.0),
    pi / 2.0,
  )
  let mat = @raylib.Vector4::quat_to_matrix(q)
  // For 90-degree rotation about z: m0~0, m1~1, m4~-1, m5~0, m10~1
  assert_true(approx(mat.m0, 0.0))
  assert_true(approx(mat.m1, 1.0))
  assert_true(approx(mat.m4, -1.0))
  assert_true(approx(mat.m5, 0.0))
  assert_true(approx(mat.m10, 1.0))
  assert_true(approx(mat.m15, 1.0))
}

///|
test "Vector4::quat_from_matrix and quat_to_matrix round-trip" {
  // Create a quaternion, convert to matrix, convert back, should match
  let original = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(1.0, 1.0, 1.0),
    pi / 3.0,
  )
  let mat = @raylib.Vector4::quat_to_matrix(original)
  let recovered = @raylib.Vector4::quat_from_matrix(mat)
  // Quaternions can differ by sign but represent the same rotation
  assert_true(
    approx_v4(recovered, original) ||
    approx_v4(recovered, @raylib.Vector4::negate(original)),
  )
}

///|
test "Vector4::quat_from_axis_angle normal axis" {
  // 90 degrees about z-axis
  let q = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 1.0),
    pi / 2.0,
  )
  assert_true(approx(@raylib.Vector4::quat_length(q), 1.0))
  // q should be (0, 0, sin(45deg), cos(45deg)) = (0, 0, 0.7071, 0.7071)
  assert_true(approx(q.x, 0.0))
  assert_true(approx(q.y, 0.0))
  assert_true(approx(q.z, 0.7071))
  assert_true(approx(q.w, 0.7071))
}

///|
test "Vector4::quat_from_axis_angle zero axis" {
  // Zero-length axis -> identity quaternion
  let q = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 0.0),
    pi / 2.0,
  )
  assert_eq(q, @raylib.Vector4::new(0.0, 0.0, 0.0, 1.0))
}

///|
test "Vector4::quat_to_axis_angle real rotation (den > epsilon)" {
  // 90 degrees about z-axis
  let q = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 1.0),
    pi / 2.0,
  )
  let (axis, angle) = @raylib.Vector4::quat_to_axis_angle(q)
  assert_true(approx(angle, pi / 2.0))
  assert_true(approx(axis.x, 0.0))
  assert_true(approx(axis.y, 0.0))
  assert_true(approx(axis.z, 1.0))
}

///|
test "Vector4::quat_to_axis_angle near identity (den <= epsilon, angle ~ 0)" {
  let q = @raylib.Vector4::quat_identity()
  let (axis, angle) = @raylib.Vector4::quat_to_axis_angle(q)
  // Angle should be ~0
  assert_true(approx(angle, 0.0))
  // Axis defaults to (1,0,0) when angle is zero
  assert_true(approx(axis.x, 1.0))
  assert_true(approx(axis.y, 0.0))
  assert_true(approx(axis.z, 0.0))
}

///|
test "Vector4::quat_from_axis_angle and quat_to_axis_angle round-trip" {
  let original_axis = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let original_angle : Float = pi / 3.0
  let q = @raylib.Vector4::quat_from_axis_angle(original_axis, original_angle)
  let (axis, angle) = @raylib.Vector4::quat_to_axis_angle(q)
  assert_true(approx(angle, original_angle))
  assert_true(approx_v3(axis, original_axis))
}

///|
test "Vector4::quat_from_euler" {
  // Zero euler angles -> identity quaternion
  let q = @raylib.Vector4::quat_from_euler(0.0, 0.0, 0.0)
  assert_true(approx_v4(q, @raylib.Vector4::quat_identity()))
  // Pure pitch (rotation about x)
  let qx = @raylib.Vector4::quat_from_euler(pi / 2.0, 0.0, 0.0)
  assert_true(approx(@raylib.Vector4::quat_length(qx), 1.0))
}

///|
test "Vector4::quat_to_euler" {
  // Identity quaternion -> zero euler angles
  let euler = @raylib.Vector4::quat_to_euler(@raylib.Vector4::quat_identity())
  assert_true(approx(euler.x, 0.0)) // roll
  assert_true(approx(euler.y, 0.0)) // pitch
  assert_true(approx(euler.z, 0.0)) // yaw
}

///|
test "Vector4::quat_from_euler and quat_to_euler round-trip" {
  // quat_from_euler(pitch, yaw, roll) maps: pitch->x-axis, yaw->y-axis, roll->z-axis
  // quat_to_euler returns { x: x-axis rot, y: y-axis rot, z: z-axis rot }
  let pitch : Float = 0.3 // x-axis rotation
  let yaw : Float = 0.5 // y-axis rotation
  let roll : Float = 0.7 // z-axis rotation
  let q = @raylib.Vector4::quat_from_euler(pitch, yaw, roll)
  let euler = @raylib.Vector4::quat_to_euler(q)
  // euler.x = x-axis rotation = pitch (first param), euler.y = y-axis = yaw, euler.z = z-axis = roll
  assert_true(approx(euler.x, pitch))
  assert_true(approx(euler.y, yaw))
  assert_true(approx(euler.z, roll))
}

///|
test "Vector4::quat_transform identity matrix preserves quaternion" {
  let q = @raylib.Vector4::new(0.5, 0.5, 0.5, 0.5)
  let mat = @raylib.Matrix::identity()
  let r = @raylib.Vector4::quat_transform(q, mat)
  assert_true(approx_v4(r, q))
}

///|
test "Vector4::quat_transform with scale matrix" {
  let q = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  // Scale matrix: diagonal is (2,2,2,1)
  let mat = @raylib.Matrix::scale(2.0, 2.0, 2.0)
  let r = @raylib.Vector4::quat_transform(q, mat)
  // x,y,z scaled by 2, w stays the same (m15=1, m3=m7=m11=0, m12=m13=m14=0)
  assert_true(approx(r.x, 2.0))
  assert_true(approx(r.y, 4.0))
  assert_true(approx(r.z, 6.0))
  assert_true(approx(r.w, 4.0))
}

///|
test "Vector4::quat_equals equal quaternions" {
  let a = @raylib.Vector4::new(0.5, 0.5, 0.5, 0.5)
  let b = @raylib.Vector4::new(0.5, 0.5, 0.5, 0.5)
  assert_true(@raylib.Vector4::quat_equals(a, b))
}

///|
test "Vector4::quat_equals not equal quaternions" {
  let a = @raylib.Vector4::new(0.5, 0.5, 0.5, 0.5)
  let b = @raylib.Vector4::new(0.5, 0.5, 0.5, -0.3)
  assert_false(@raylib.Vector4::quat_equals(a, b))
}

///|
test "Vector4::quat_equals negated but equal quaternion" {
  // A quaternion and its negation represent the same rotation
  let a = @raylib.Vector4::new(0.5, 0.5, 0.5, 0.5)
  let b = @raylib.Vector4::new(-0.5, -0.5, -0.5, -0.5)
  assert_true(@raylib.Vector4::quat_equals(a, b))
}

///|
test "Vector4::quat_add" {
  let a = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let b = @raylib.Vector4::new(5.0, 6.0, 7.0, 8.0)
  let r = @raylib.Vector4::quat_add(a, b)
  assert_eq(r, @raylib.Vector4::new(6.0, 8.0, 10.0, 12.0))
}

///|
test "Vector4::quat_add_value" {
  let q = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let r = @raylib.Vector4::quat_add_value(q, 10.0)
  assert_eq(r, @raylib.Vector4::new(11.0, 12.0, 13.0, 14.0))
}

///|
test "Vector4::quat_subtract" {
  let a = @raylib.Vector4::new(10.0, 20.0, 30.0, 40.0)
  let b = @raylib.Vector4::new(1.0, 2.0, 3.0, 4.0)
  let r = @raylib.Vector4::quat_subtract(a, b)
  assert_eq(r, @raylib.Vector4::new(9.0, 18.0, 27.0, 36.0))
}

///|
test "Vector4::quat_subtract_value" {
  let q = @raylib.Vector4::new(10.0, 20.0, 30.0, 40.0)
  let r = @raylib.Vector4::quat_subtract_value(q, 5.0)
  assert_eq(r, @raylib.Vector4::new(5.0, 15.0, 25.0, 35.0))
}

///|
test "Vector4::quat_to_axis_angle unnormalized quaternion (|w| > 1 triggers normalization)" {
  // Unnormalized quaternion with |w| = 2 > 1, triggers the normalization branch
  let q = @raylib.Vector4::new(0.0, 0.0, 2.0, 2.0)
  let (axis, angle) = @raylib.Vector4::quat_to_axis_angle(q)
  // After normalization: (0, 0, 1/sqrt(2), 1/sqrt(2)), same as 90-deg rotation about z
  // angle = 2 * acos(1/sqrt(2)) = 2 * pi/4 = pi/2
  assert_true(approx(angle, pi / 2.0))
  assert_true(approx(axis.x, 0.0))
  assert_true(approx(axis.y, 0.0))
  assert_true(approx(axis.z, 1.0))
}

///|
test "Vector4::quat_to_euler gimbal lock (clamping branches)" {
  // Quaternion representing pitch = pi/2 (gimbal lock)
  // q = (0, sin(pi/4), 0, cos(pi/4))
  let s = @math.sinf(pi / 4.0)
  let c = @math.cosf(pi / 4.0)
  let q = @raylib.Vector4::new(0.0, s, 0.0, c)
  let euler = @raylib.Vector4::quat_to_euler(q)
  // y0 = 2*(w*y - z*x) = 2*(cos(pi/4)*sin(pi/4) - 0) = 2*0.5 = 1.0
  // This should hit or approach the clamping boundary y0 >= 1.0
  // pitch = asin(1.0) = pi/2
  assert_true(approx(euler.y, pi / 2.0))
}

///|
test "Vector4::quat_slerp normal path (~144 degrees apart)" {
  // Create two quaternions ~144 degrees apart so cos_half_theta ~ 0.3
  // which is well below 0.95 threshold, exercising the full slerp path
  let q1 = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 1.0),
    0.0,
  )
  let q2 = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 1.0),
    pi * 0.8,
  )
  // At t=0.5, should be halfway between the two rotations
  let r = @raylib.Vector4::quat_slerp(q1, q2, 0.5)
  let expected = @raylib.Vector4::quat_from_axis_angle(
    @raylib.Vector3::new(0.0, 0.0, 1.0),
    pi * 0.4,
  )
  assert_true(approx_v4(r, expected))
  // Result should be unit quaternion
  assert_true(approx(@raylib.Vector4::quat_length(r), 1.0))
}
