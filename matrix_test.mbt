///|
let pi : Float = 3.14159265358979323846

///|
fn approx(a : Float, b : Float) -> Bool {
  (a - b).abs() < 0.001
}

///|
fn mat_approx_eq(a : @raylib.Matrix, b : @raylib.Matrix) -> Bool {
  approx(a.m0, b.m0) &&
  approx(a.m1, b.m1) &&
  approx(a.m2, b.m2) &&
  approx(a.m3, b.m3) &&
  approx(a.m4, b.m4) &&
  approx(a.m5, b.m5) &&
  approx(a.m6, b.m6) &&
  approx(a.m7, b.m7) &&
  approx(a.m8, b.m8) &&
  approx(a.m9, b.m9) &&
  approx(a.m10, b.m10) &&
  approx(a.m11, b.m11) &&
  approx(a.m12, b.m12) &&
  approx(a.m13, b.m13) &&
  approx(a.m14, b.m14) &&
  approx(a.m15, b.m15)
}

///|
test "Matrix::identity - diagonal is 1, rest is 0" {
  let m = @raylib.Matrix::identity()
  assert_eq(m.m0, 1.0)
  assert_eq(m.m5, 1.0)
  assert_eq(m.m10, 1.0)
  assert_eq(m.m15, 1.0)
  assert_eq(m.m1, 0.0)
  assert_eq(m.m2, 0.0)
  assert_eq(m.m3, 0.0)
  assert_eq(m.m4, 0.0)
  assert_eq(m.m6, 0.0)
  assert_eq(m.m7, 0.0)
  assert_eq(m.m8, 0.0)
  assert_eq(m.m9, 0.0)
  assert_eq(m.m11, 0.0)
  assert_eq(m.m12, 0.0)
  assert_eq(m.m13, 0.0)
  assert_eq(m.m14, 0.0)
}

///|
test "Matrix::to_bytes/from_bytes round-trip" {
  let m = @raylib.Matrix::translate(10.0, 20.0, 30.0)
  let bytes = m.to_bytes()
  let m2 = @raylib.Matrix::from_bytes(bytes)
  assert_eq(m, m2)
}

///|
test "Matrix::to_bytes/from_bytes round-trip with scale" {
  let m = @raylib.Matrix::scale(2.0, 3.0, 4.0)
  let bytes = m.to_bytes()
  let m2 = @raylib.Matrix::from_bytes(bytes)
  assert_eq(m, m2)
}

///|
test "Matrix::to_bytes/from_bytes round-trip with rotation" {
  let m = @raylib.Matrix::rotate_z(pi / 3.0)
  let bytes = m.to_bytes()
  let m2 = @raylib.Matrix::from_bytes(bytes)
  assert_eq(m, m2)
}

///|
test "Matrix::determinant - identity determinant is 1" {
  let det = @raylib.Matrix::determinant(@raylib.Matrix::identity())
  assert_true(approx(det, 1.0))
}

///|
test "Matrix::determinant - scaling matrix" {
  // Scaling matrix with factors 2,3,4 should have determinant 2*3*4 = 24
  let s = @raylib.Matrix::scale(2.0, 3.0, 4.0)
  let det = @raylib.Matrix::determinant(s)
  assert_true(approx(det, 24.0))
}

///|
test "Matrix::trace - identity trace is 4" {
  let t = @raylib.Matrix::trace(@raylib.Matrix::identity())
  assert_true(approx(t, 4.0))
}

///|
test "Matrix::trace - scaling matrix" {
  let s = @raylib.Matrix::scale(2.0, 3.0, 4.0)
  let t = @raylib.Matrix::trace(s)
  // trace = 2 + 3 + 4 + 1 = 10
  assert_true(approx(t, 10.0))
}

///|
test "Matrix::transpose - identity is unchanged" {
  let id = @raylib.Matrix::identity()
  let t = @raylib.Matrix::transpose(id)
  assert_eq(t, id)
}

///|
test "Matrix::transpose - non-symmetric matrix" {
  // Translation matrix is non-symmetric: m12,m13,m14 are set but m3,m7,m11 are 0
  let m = @raylib.Matrix::translate(5.0, 6.0, 7.0)
  let t = @raylib.Matrix::transpose(m)
  // Transpose swaps off-diagonal elements
  // Original: m12=5, m13=6, m14=7, m3=0, m7=0, m11=0
  // Transposed: m3=5, m7=6, m11=7, m12=0, m13=0, m14=0
  assert_true(approx(t.m3, 5.0))
  assert_true(approx(t.m7, 6.0))
  assert_true(approx(t.m11, 7.0))
  assert_true(approx(t.m12, 0.0))
  assert_true(approx(t.m13, 0.0))
  assert_true(approx(t.m14, 0.0))
}

///|
test "Matrix::transpose - double transpose is original" {
  let m = @raylib.Matrix::translate(1.0, 2.0, 3.0)
  let tt = @raylib.Matrix::transpose(@raylib.Matrix::transpose(m))
  assert_eq(tt, m)
}

///|
test "Matrix::invert - identity inverse is identity" {
  let inv = @raylib.Matrix::invert(@raylib.Matrix::identity())
  assert_true(mat_approx_eq(inv, @raylib.Matrix::identity()))
}

///|
test "Matrix::invert - A * A_inv is approximately identity" {
  // Use a translation matrix which is always invertible
  let a = @raylib.Matrix::translate(3.0, -5.0, 7.0)
  let a_inv = @raylib.Matrix::invert(a)
  let product = @raylib.Matrix::multiply(a, a_inv)
  assert_true(mat_approx_eq(product, @raylib.Matrix::identity()))
}

///|
test "Matrix::invert - scale matrix inversion" {
  let s = @raylib.Matrix::scale(2.0, 4.0, 5.0)
  let s_inv = @raylib.Matrix::invert(s)
  assert_true(approx(s_inv.m0, 0.5))
  assert_true(approx(s_inv.m5, 0.25))
  assert_true(approx(s_inv.m10, 0.2))
}

///|
test "Matrix::add - adding identity to identity" {
  let id = @raylib.Matrix::identity()
  let sum = @raylib.Matrix::add(id, id)
  assert_eq(sum.m0, 2.0)
  assert_eq(sum.m5, 2.0)
  assert_eq(sum.m10, 2.0)
  assert_eq(sum.m15, 2.0)
  assert_eq(sum.m1, 0.0)
  assert_eq(sum.m4, 0.0)
}

///|
test "Matrix::subtract - M - M is zero" {
  let m = @raylib.Matrix::scale(3.0, 5.0, 7.0)
  let diff = @raylib.Matrix::subtract(m, m)
  assert_eq(diff.m0, 0.0)
  assert_eq(diff.m5, 0.0)
  assert_eq(diff.m10, 0.0)
  assert_eq(diff.m15, 0.0)
  assert_eq(diff.m1, 0.0)
  assert_eq(diff.m12, 0.0)
}

///|
test "Matrix::subtract - add and subtract cancel out" {
  let a = @raylib.Matrix::scale(2.0, 3.0, 4.0)
  let b = @raylib.Matrix::identity()
  let sum = @raylib.Matrix::add(a, b)
  let result = @raylib.Matrix::subtract(sum, b)
  assert_true(mat_approx_eq(result, a))
}

///|
test "Matrix::multiply - identity * M = M" {
  let m = @raylib.Matrix::translate(1.0, 2.0, 3.0)
  let product = @raylib.Matrix::multiply(@raylib.Matrix::identity(), m)
  assert_eq(product, m)
}

///|
test "Matrix::multiply - M * identity = M" {
  let m = @raylib.Matrix::scale(2.0, 3.0, 4.0)
  let product = @raylib.Matrix::multiply(m, @raylib.Matrix::identity())
  assert_eq(product, m)
}

///|
test "Matrix::multiply - scale * translate preserves translation" {
  // multiply(scale, translate): scale applied to geometry, translation unaffected
  let t = @raylib.Matrix::translate(1.0, 2.0, 3.0)
  let s = @raylib.Matrix::scale(2.0, 2.0, 2.0)
  let result = @raylib.Matrix::multiply(s, t)
  assert_true(approx(result.m0, 2.0))
  assert_true(approx(result.m5, 2.0))
  assert_true(approx(result.m10, 2.0))
  // Translation is preserved (not scaled)
  assert_true(approx(result.m12, 1.0))
  assert_true(approx(result.m13, 2.0))
  assert_true(approx(result.m14, 3.0))
}

///|
test "Matrix::translate - m12, m13, m14 are translation values" {
  let m = @raylib.Matrix::translate(10.0, 20.0, 30.0)
  assert_eq(m.m12, 10.0)
  assert_eq(m.m13, 20.0)
  assert_eq(m.m14, 30.0)
  // Rest of diagonal should be 1
  assert_eq(m.m0, 1.0)
  assert_eq(m.m5, 1.0)
  assert_eq(m.m10, 1.0)
  assert_eq(m.m15, 1.0)
}

///|
test "Matrix::rotate - rotate by 0 around any axis gives identity" {
  let m = @raylib.Matrix::rotate(@raylib.Vector3::new(0.0, 1.0, 0.0), 0.0)
  assert_true(mat_approx_eq(m, @raylib.Matrix::identity()))
}

///|
test "Matrix::rotate - 90 degrees around z-axis" {
  let half_pi = pi / 2.0
  let m = @raylib.Matrix::rotate(@raylib.Vector3::new(0.0, 0.0, 1.0), half_pi)
  // cos(pi/2) ~ 0, sin(pi/2) ~ 1
  assert_true(approx(m.m0, 0.0))
  assert_true(approx(m.m1, 1.0))
  assert_true(approx(m.m4, -1.0))
  assert_true(approx(m.m5, 0.0))
  assert_true(approx(m.m10, 1.0))
  assert_true(approx(m.m15, 1.0))
}

///|
test "Matrix::rotate_x - rotate by 0 gives identity" {
  let m = @raylib.Matrix::rotate_x(0.0)
  assert_true(mat_approx_eq(m, @raylib.Matrix::identity()))
}

///|
test "Matrix::rotate_x - rotate by pi/2" {
  let half_pi = pi / 2.0
  let m = @raylib.Matrix::rotate_x(half_pi)
  // m0=1, m5=cos(pi/2)~0, m6=sin(pi/2)~1, m9=-sin(pi/2)~-1, m10=cos(pi/2)~0
  assert_true(approx(m.m0, 1.0))
  assert_true(approx(m.m5, 0.0))
  assert_true(approx(m.m6, 1.0))
  assert_true(approx(m.m9, -1.0))
  assert_true(approx(m.m10, 0.0))
  assert_true(approx(m.m15, 1.0))
}

///|
test "Matrix::rotate_y - rotate by 0 gives identity" {
  let m = @raylib.Matrix::rotate_y(0.0)
  assert_true(mat_approx_eq(m, @raylib.Matrix::identity()))
}

///|
test "Matrix::rotate_y - rotate by pi/2" {
  let half_pi = pi / 2.0
  let m = @raylib.Matrix::rotate_y(half_pi)
  // m0=cos(pi/2)~0, m2=-sin(pi/2)~-1, m5=1, m8=sin(pi/2)~1, m10=cos(pi/2)~0
  assert_true(approx(m.m0, 0.0))
  assert_true(approx(m.m2, -1.0))
  assert_true(approx(m.m5, 1.0))
  assert_true(approx(m.m8, 1.0))
  assert_true(approx(m.m10, 0.0))
  assert_true(approx(m.m15, 1.0))
}

///|
test "Matrix::rotate_z - rotate by 0 gives identity" {
  let m = @raylib.Matrix::rotate_z(0.0)
  assert_true(mat_approx_eq(m, @raylib.Matrix::identity()))
}

///|
test "Matrix::rotate_z - rotate by pi/2" {
  let half_pi = pi / 2.0
  let m = @raylib.Matrix::rotate_z(half_pi)
  // m0=cos(pi/2)~0, m1=sin(pi/2)~1, m4=-sin(pi/2)~-1, m5=cos(pi/2)~0, m10=1
  assert_true(approx(m.m0, 0.0))
  assert_true(approx(m.m1, 1.0))
  assert_true(approx(m.m4, -1.0))
  assert_true(approx(m.m5, 0.0))
  assert_true(approx(m.m10, 1.0))
  assert_true(approx(m.m15, 1.0))
}

///|
test "Matrix::rotate_xyz - zero angles gives identity" {
  let m = @raylib.Matrix::rotate_xyz(@raylib.Vector3::new(0.0, 0.0, 0.0))
  assert_true(mat_approx_eq(m, @raylib.Matrix::identity()))
}

///|
test "Matrix::rotate_xyz - is a valid rotation matrix (det = 1)" {
  let m = @raylib.Matrix::rotate_xyz(@raylib.Vector3::new(0.5, 0.3, 0.7))
  let det = @raylib.Matrix::determinant(m)
  assert_true(approx(det, 1.0))
}

///|
test "Matrix::rotate_zyx - zero angles gives identity" {
  let m = @raylib.Matrix::rotate_zyx(@raylib.Vector3::new(0.0, 0.0, 0.0))
  assert_true(mat_approx_eq(m, @raylib.Matrix::identity()))
}

///|
test "Matrix::rotate_zyx - is a valid rotation matrix (det = 1)" {
  let m = @raylib.Matrix::rotate_zyx(@raylib.Vector3::new(0.5, 0.3, 0.7))
  let det = @raylib.Matrix::determinant(m)
  assert_true(approx(det, 1.0))
}

///|
test "Matrix::scale - diagonal values match scale factors" {
  let m = @raylib.Matrix::scale(2.0, 3.0, 4.0)
  assert_eq(m.m0, 2.0)
  assert_eq(m.m5, 3.0)
  assert_eq(m.m10, 4.0)
  assert_eq(m.m15, 1.0)
  // Off-diagonal should be 0
  assert_eq(m.m1, 0.0)
  assert_eq(m.m2, 0.0)
  assert_eq(m.m3, 0.0)
  assert_eq(m.m4, 0.0)
  assert_eq(m.m6, 0.0)
  assert_eq(m.m7, 0.0)
  assert_eq(m.m8, 0.0)
  assert_eq(m.m9, 0.0)
  assert_eq(m.m11, 0.0)
  assert_eq(m.m12, 0.0)
  assert_eq(m.m13, 0.0)
  assert_eq(m.m14, 0.0)
}

///|
test "Matrix::frustum - basic structure" {
  let m = @raylib.Matrix::frustum(-1.0, 1.0, -1.0, 1.0, 1.0, 100.0)
  // For symmetric frustum: m8 = 0, m9 = 0
  assert_true(approx(m.m8, 0.0))
  assert_true(approx(m.m9, 0.0))
  // m11 should be -1 (perspective divide)
  assert_true(approx(m.m11, -1.0))
  // m15 should be 0
  assert_true(approx(m.m15, 0.0))
  // m0 = 2*near/rl = 2*1/2 = 1
  assert_true(approx(m.m0, 1.0))
  // m5 = 2*near/tb = 2*1/2 = 1
  assert_true(approx(m.m5, 1.0))
}

///|
test "Matrix::perspective - basic properties" {
  let fov = 45.0 * (3.14159265358979323846 / 180.0)
  let m = @raylib.Matrix::perspective(fov, 1.0, 0.1, 100.0)
  // m11 should be -1 (perspective)
  assert_true(approx(m.m11, -1.0))
  // m15 should be 0
  assert_true(approx(m.m15, 0.0))
  // For aspect=1, m0 should equal m5
  assert_true(approx(m.m0, m.m5))
  // m8 and m9 should be 0 for symmetric projection
  assert_true(approx(m.m8, 0.0))
  assert_true(approx(m.m9, 0.0))
}

///|
test "Matrix::ortho - basic properties" {
  let m = @raylib.Matrix::ortho(-10.0, 10.0, -10.0, 10.0, 0.1, 100.0)
  // m15 should be 1 (orthographic, not perspective)
  assert_true(approx(m.m15, 1.0))
  // m11 should be 0 (no perspective divide)
  assert_true(approx(m.m11, 0.0))
  // m0 = 2/rl = 2/20 = 0.1
  assert_true(approx(m.m0, 0.1))
  // m5 = 2/tb = 2/20 = 0.1
  assert_true(approx(m.m5, 0.1))
  // m12 = -(left+right)/rl = 0 for symmetric
  assert_true(approx(m.m12, 0.0))
  // m13 = -(top+bottom)/tb = 0 for symmetric
  assert_true(approx(m.m13, 0.0))
}

///|
test "Matrix::look_at - looking down negative z-axis" {
  let eye = @raylib.Vector3::new(0.0, 0.0, 5.0)
  let target = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let up = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let m = @raylib.Matrix::look_at(eye, target, up)
  // The view matrix should be a valid transformation (det != 0)
  let det = @raylib.Matrix::determinant(m)
  assert_true(det.abs() > 0.001)
  // m15 should be 1 (affine matrix)
  assert_true(approx(m.m15, 1.0))
  // For this simple case looking down -Z:
  // vz = normalize(eye - target) = (0,0,1)
  // vx = normalize(cross(up, vz)) = normalize(cross((0,1,0),(0,0,1))) = (1,0,0)
  // vy = cross(vz, vx) = (0,1,0)
  // So the upper-left 3x3 should be approximately identity
  assert_true(approx(m.m0, 1.0))
  assert_true(approx(m.m5, 1.0))
  assert_true(approx(m.m10, 1.0))
  // Translation: m12 = -dot(vx, eye) = 0, m13 = -dot(vy, eye) = 0, m14 = -dot(vz, eye) = -5
  assert_true(approx(m.m12, 0.0))
  assert_true(approx(m.m13, 0.0))
  assert_true(approx(m.m14, -5.0))
}

///|
test "Matrix::look_at - view matrix is invertible" {
  let eye = @raylib.Vector3::new(3.0, 4.0, 5.0)
  let target = @raylib.Vector3::new(0.0, 0.0, 0.0)
  let up = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let m = @raylib.Matrix::look_at(eye, target, up)
  let m_inv = @raylib.Matrix::invert(m)
  let product = @raylib.Matrix::multiply(m, m_inv)
  assert_true(mat_approx_eq(product, @raylib.Matrix::identity()))
}

///|
test "Matrix::decompose - pure translation" {
  let m = @raylib.Matrix::translate(5.0, -3.0, 7.0)
  let (translation, rotation, scale) = @raylib.Matrix::decompose(m)
  assert_true(approx(translation.x, 5.0))
  assert_true(approx(translation.y, -3.0))
  assert_true(approx(translation.z, 7.0))
  // Scale should be (1,1,1)
  assert_true(approx(scale.x, 1.0))
  assert_true(approx(scale.y, 1.0))
  assert_true(approx(scale.z, 1.0))
  // Rotation quaternion should be identity: (0,0,0,1)
  assert_true(approx(rotation.x, 0.0))
  assert_true(approx(rotation.y, 0.0))
  assert_true(approx(rotation.z, 0.0))
  assert_true(approx(rotation.w, 1.0))
}

///|
test "Matrix::decompose - pure scale" {
  let m = @raylib.Matrix::scale(2.0, 3.0, 4.0)
  let (translation, _rotation, scale) = @raylib.Matrix::decompose(m)
  assert_true(approx(translation.x, 0.0))
  assert_true(approx(translation.y, 0.0))
  assert_true(approx(translation.z, 0.0))
  assert_true(approx(scale.x, 2.0))
  assert_true(approx(scale.y, 3.0))
  assert_true(approx(scale.z, 4.0))
}

///|
test "Matrix::decompose - translate and scale combined" {
  // Compose as scale * translate to get a proper TRS-like matrix
  // where translation is in m12,m13,m14 and scale on the diagonal
  let t = @raylib.Matrix::translate(1.0, 2.0, 3.0)
  let s = @raylib.Matrix::scale(2.0, 3.0, 4.0)
  let m = @raylib.Matrix::multiply(s, t)
  let (translation, rotation, scale) = @raylib.Matrix::decompose(m)
  // Translation should be (1,2,3)
  assert_true(approx(translation.x, 1.0))
  assert_true(approx(translation.y, 2.0))
  assert_true(approx(translation.z, 3.0))
  // Scale should be (2,3,4)
  assert_true(approx(scale.x, 2.0))
  assert_true(approx(scale.y, 3.0))
  assert_true(approx(scale.z, 4.0))
  // Rotation should be identity quaternion (no rotation applied)
  assert_true(approx(rotation.x, 0.0))
  assert_true(approx(rotation.y, 0.0))
  assert_true(approx(rotation.z, 0.0))
  assert_true(approx(rotation.w, 1.0))
}

///|
test "Matrix::rotate - unnormalized axis is normalized internally" {
  // Use an unnormalized axis (2,0,0) which should be normalized to (1,0,0)
  let half_pi = pi / 2.0
  let m_unnorm = @raylib.Matrix::rotate(
    @raylib.Vector3::new(2.0, 0.0, 0.0),
    half_pi,
  )
  // Compare with rotation around the already-normalized axis (1,0,0)
  let m_norm = @raylib.Matrix::rotate_x(half_pi)
  assert_true(mat_approx_eq(m_unnorm, m_norm))
}

///|
test "Matrix::look_at - eye equals target (zero-length vz)" {
  // When eye == target, vz is zero-length, triggering the length==0 guard
  let eye = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let target = @raylib.Vector3::new(1.0, 2.0, 3.0)
  let up = @raylib.Vector3::new(0.0, 1.0, 0.0)
  let m = @raylib.Matrix::look_at(eye, target, up)
  // The function should not crash; m15 should still be 1.0 (affine)
  assert_true(approx(m.m15, 1.0))
}

///|
test "Matrix::decompose - negative determinant" {
  // Matrix::scale(-1, 1, 1) has determinant = -1, triggering the det < 0 branch
  let m = @raylib.Matrix::scale(-1.0, 1.0, 1.0)
  let (translation, _rotation, scale) = @raylib.Matrix::decompose(m)
  // Translation should be zero
  assert_true(approx(translation.x, 0.0))
  assert_true(approx(translation.y, 0.0))
  assert_true(approx(translation.z, 0.0))
  // Negative determinant: scale components are negated
  assert_true(approx(scale.x, -1.0))
  assert_true(approx(scale.y, -1.0))
  assert_true(approx(scale.z, -1.0))
}

///|
test "Matrix::decompose - rotate_x(pi) triggers biggest_index 1" {
  // Rotation by pi around x-axis: the diagonal has m0=1, m5=-1, m10=-1
  // four_x_sq_m1 = m0 - m5 - m10 = 1 -(-1) -(-1) = 3 (biggest)
  let m = @raylib.Matrix::rotate_x(pi)
  let (_translation, rotation, scale) = @raylib.Matrix::decompose(m)
  // Scale should be ~(1,1,1)
  assert_true(approx(scale.x, 1.0))
  assert_true(approx(scale.y, 1.0))
  assert_true(approx(scale.z, 1.0))
  // Rotation quaternion for 180 deg around x: (1, 0, 0, 0) or (-1, 0, 0, 0)
  assert_true(approx(rotation.x.abs(), 1.0))
  assert_true(approx(rotation.y, 0.0))
  assert_true(approx(rotation.z, 0.0))
  assert_true(approx(rotation.w, 0.0))
}

///|
test "Matrix::decompose - rotate_y(pi) triggers biggest_index 2" {
  // Rotation by pi around y-axis: the diagonal has m0=-1, m5=1, m10=-1
  // four_y_sq_m1 = m5 - m0 - m10 = 1 -(-1) -(-1) = 3 (biggest)
  let m = @raylib.Matrix::rotate_y(pi)
  let (_translation, rotation, scale) = @raylib.Matrix::decompose(m)
  // Scale should be ~(1,1,1)
  assert_true(approx(scale.x, 1.0))
  assert_true(approx(scale.y, 1.0))
  assert_true(approx(scale.z, 1.0))
  // Rotation quaternion for 180 deg around y: (0, 1, 0, 0) or (0, -1, 0, 0)
  assert_true(approx(rotation.x, 0.0))
  assert_true(approx(rotation.y.abs(), 1.0))
  assert_true(approx(rotation.z, 0.0))
  assert_true(approx(rotation.w, 0.0))
}

///|
test "Matrix::decompose - rotate_z(pi) triggers biggest_index 3" {
  // Rotation by pi around z-axis: the diagonal has m0=-1, m5=-1, m10=1
  // four_z_sq_m1 = m10 - m0 - m5 = 1 -(-1) -(-1) = 3 (biggest)
  let m = @raylib.Matrix::rotate_z(pi)
  let (_translation, rotation, scale) = @raylib.Matrix::decompose(m)
  // Scale should be ~(1,1,1)
  assert_true(approx(scale.x, 1.0))
  assert_true(approx(scale.y, 1.0))
  assert_true(approx(scale.z, 1.0))
  // Rotation quaternion for 180 deg around z: (0, 0, 1, 0) or (0, 0, -1, 0)
  assert_true(approx(rotation.x, 0.0))
  assert_true(approx(rotation.y, 0.0))
  assert_true(approx(rotation.z.abs(), 1.0))
  assert_true(approx(rotation.w, 0.0))
}

///|
test "Matrix::decompose - zero matrix triggers det == 0 identity quaternion fallback" {
  // Zero matrix (all zeros except m15=1.0) has det == 0, triggering identity quaternion fallback
  // Matrix::scale(0,0,0) produces exactly this: diagonal 0,0,0,1, all else 0
  let m = @raylib.Matrix::scale(0.0, 0.0, 0.0)
  let (translation, rotation, scale) = @raylib.Matrix::decompose(m)
  // Translation should be zero
  assert_true(approx(translation.x, 0.0))
  assert_true(approx(translation.y, 0.0))
  assert_true(approx(translation.z, 0.0))
  // Scale should be zero (all columns have zero length)
  assert_true(approx(scale.x, 0.0))
  assert_true(approx(scale.y, 0.0))
  assert_true(approx(scale.z, 0.0))
  // Rotation should be identity quaternion (det == 0 fallback)
  assert_true(approx(rotation.x, 0.0))
  assert_true(approx(rotation.y, 0.0))
  assert_true(approx(rotation.z, 0.0))
  assert_true(approx(rotation.w, 1.0))
}
