// Vector4 math functions and Quaternion operations (as Vector4::quat_*)
// Ported from raymath.h (raylib 5.5)
// Private math helpers are in math_helpers.mbt

// ----- Vector4 math functions -----

///|
pub fn Vector4::zero() -> Vector4 {
  { x: 0.0, y: 0.0, z: 0.0, w: 0.0 }
}

///|
pub fn Vector4::one() -> Vector4 {
  { x: 1.0, y: 1.0, z: 1.0, w: 1.0 }
}

///|
pub fn Vector4::add(v1 : Vector4, v2 : Vector4) -> Vector4 {
  { x: v1.x + v2.x, y: v1.y + v2.y, z: v1.z + v2.z, w: v1.w + v2.w }
}

///|
pub fn Vector4::add_value(v : Vector4, add : Float) -> Vector4 {
  { x: v.x + add, y: v.y + add, z: v.z + add, w: v.w + add }
}

///|
pub fn Vector4::subtract(v1 : Vector4, v2 : Vector4) -> Vector4 {
  { x: v1.x - v2.x, y: v1.y - v2.y, z: v1.z - v2.z, w: v1.w - v2.w }
}

///|
pub fn Vector4::subtract_value(v : Vector4, sub : Float) -> Vector4 {
  { x: v.x - sub, y: v.y - sub, z: v.z - sub, w: v.w - sub }
}

///|
pub fn Vector4::length(v : Vector4) -> Float {
  sqrtf(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w)
}

///|
pub fn Vector4::scale(v : Vector4, scalar : Float) -> Vector4 {
  { x: v.x * scalar, y: v.y * scalar, z: v.z * scalar, w: v.w * scalar }
}

///|
pub fn Vector4::multiply(v1 : Vector4, v2 : Vector4) -> Vector4 {
  { x: v1.x * v2.x, y: v1.y * v2.y, z: v1.z * v2.z, w: v1.w * v2.w }
}

///|
pub fn Vector4::negate(v : Vector4) -> Vector4 {
  { x: -v.x, y: -v.y, z: -v.z, w: -v.w }
}

///|
pub fn Vector4::divide(v1 : Vector4, v2 : Vector4) -> Vector4 {
  { x: v1.x / v2.x, y: v1.y / v2.y, z: v1.z / v2.z, w: v1.w / v2.w }
}

///|
pub fn Vector4::normalize(v : Vector4) -> Vector4 {
  let len = sqrtf(v.x * v.x + v.y * v.y + v.z * v.z + v.w * v.w)
  if len > 0.0 {
    let ilength : Float = (1.0 : Float) / len
    { x: v.x * ilength, y: v.y * ilength, z: v.z * ilength, w: v.w * ilength }
  } else {
    { x: 0.0, y: 0.0, z: 0.0, w: 0.0 }
  }
}

///|
pub fn Vector4::min(v1 : Vector4, v2 : Vector4) -> Vector4 {
  {
    x: fminf(v1.x, v2.x),
    y: fminf(v1.y, v2.y),
    z: fminf(v1.z, v2.z),
    w: fminf(v1.w, v2.w),
  }
}

///|
pub fn Vector4::max(v1 : Vector4, v2 : Vector4) -> Vector4 {
  {
    x: fmaxf(v1.x, v2.x),
    y: fmaxf(v1.y, v2.y),
    z: fmaxf(v1.z, v2.z),
    w: fmaxf(v1.w, v2.w),
  }
}

///|
pub fn Vector4::equals(p : Vector4, q : Vector4) -> Bool {
  let epsilon : Float = 0.000001
  fabsf(p.x - q.x) <=
  epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.x), fabsf(q.x))) &&
  fabsf(p.y - q.y) <=
  epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.y), fabsf(q.y))) &&
  fabsf(p.z - q.z) <=
  epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.z), fabsf(q.z))) &&
  fabsf(p.w - q.w) <=
  epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.w), fabsf(q.w)))
}

// ----- Quaternion functions (as Vector4::quat_*) -----

///|
pub fn Vector4::quat_identity() -> Vector4 {
  { x: 0.0, y: 0.0, z: 0.0, w: 1.0 }
}

///|
pub fn Vector4::quat_length(q : Vector4) -> Float {
  sqrtf(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w)
}

///|
pub fn Vector4::quat_normalize(q : Vector4) -> Vector4 {
  let len = sqrtf(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w)
  let length : Float = if len == 0.0 { 1.0 } else { len }
  let ilength : Float = (1.0 : Float) / length
  { x: q.x * ilength, y: q.y * ilength, z: q.z * ilength, w: q.w * ilength }
}

///|
pub fn Vector4::quat_invert(q : Vector4) -> Vector4 {
  let length_sq = q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w
  if length_sq != 0.0 {
    let inv_length : Float = (1.0 : Float) / length_sq
    {
      x: q.x * -inv_length,
      y: q.y * -inv_length,
      z: q.z * -inv_length,
      w: q.w * inv_length,
    }
  } else {
    q
  }
}

///|
pub fn Vector4::quat_multiply(q1 : Vector4, q2 : Vector4) -> Vector4 {
  let qax = q1.x
  let qay = q1.y
  let qaz = q1.z
  let qaw = q1.w
  let qbx = q2.x
  let qby = q2.y
  let qbz = q2.z
  let qbw = q2.w
  {
    x: qax * qbw + qaw * qbx + qay * qbz - qaz * qby,
    y: qay * qbw + qaw * qby + qaz * qbx - qax * qbz,
    z: qaz * qbw + qaw * qbz + qax * qby - qay * qbx,
    w: qaw * qbw - qax * qbx - qay * qby - qaz * qbz,
  }
}

///|
pub fn Vector4::quat_scale(q : Vector4, mul : Float) -> Vector4 {
  { x: q.x * mul, y: q.y * mul, z: q.z * mul, w: q.w * mul }
}

///|
pub fn Vector4::quat_divide(q1 : Vector4, q2 : Vector4) -> Vector4 {
  { x: q1.x / q2.x, y: q1.y / q2.y, z: q1.z / q2.z, w: q1.w / q2.w }
}

///|
pub fn Vector4::quat_lerp(
  q1 : Vector4,
  q2 : Vector4,
  amount : Float,
) -> Vector4 {
  {
    x: q1.x + amount * (q2.x - q1.x),
    y: q1.y + amount * (q2.y - q1.y),
    z: q1.z + amount * (q2.z - q1.z),
    w: q1.w + amount * (q2.w - q1.w),
  }
}

///|
pub fn Vector4::quat_nlerp(
  q1 : Vector4,
  q2 : Vector4,
  amount : Float,
) -> Vector4 {
  // QuaternionLerp(q1, q2, amount)
  let rx = q1.x + amount * (q2.x - q1.x)
  let ry = q1.y + amount * (q2.y - q1.y)
  let rz = q1.z + amount * (q2.z - q1.z)
  let rw = q1.w + amount * (q2.w - q1.w)
  // QuaternionNormalize(q)
  let len = sqrtf(rx * rx + ry * ry + rz * rz + rw * rw)
  let length : Float = if len == 0.0 { 1.0 } else { len }
  let ilength : Float = (1.0 : Float) / length
  { x: rx * ilength, y: ry * ilength, z: rz * ilength, w: rw * ilength }
}

///|
pub fn Vector4::quat_slerp(
  q1 : Vector4,
  q2 : Vector4,
  amount : Float,
) -> Vector4 {
  let epsilon : Float = 0.000001
  let mut cos_half_theta = q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w
  let mut q2x = q2.x
  let mut q2y = q2.y
  let mut q2z = q2.z
  let mut q2w = q2.w
  if cos_half_theta < 0.0 {
    q2x = -q2x
    q2y = -q2y
    q2z = -q2z
    q2w = -q2w
    cos_half_theta = -cos_half_theta
  }
  if fabsf(cos_half_theta) >= (1.0 : Float) {
    q1
  } else if cos_half_theta > (0.95 : Float) {
    Vector4::quat_nlerp(q1, { x: q2x, y: q2y, z: q2z, w: q2w }, amount)
  } else {
    let half_theta = acosf(cos_half_theta)
    let sin_half_theta = sqrtf((1.0 : Float) - cos_half_theta * cos_half_theta)
    if fabsf(sin_half_theta) < epsilon {
      let half : Float = 0.5
      {
        x: q1.x * half + q2x * half,
        y: q1.y * half + q2y * half,
        z: q1.z * half + q2z * half,
        w: q1.w * half + q2w * half,
      }
    } else {
      let ratio_a = sinf(((1.0 : Float) - amount) * half_theta) / sin_half_theta
      let ratio_b = sinf(amount * half_theta) / sin_half_theta
      {
        x: q1.x * ratio_a + q2x * ratio_b,
        y: q1.y * ratio_a + q2y * ratio_b,
        z: q1.z * ratio_a + q2z * ratio_b,
        w: q1.w * ratio_a + q2w * ratio_b,
      }
    }
  }
}

///|
pub fn Vector4::quat_cubic_hermite_spline(
  q1 : Vector4,
  out_tangent1 : Vector4,
  q2 : Vector4,
  in_tangent2 : Vector4,
  t : Float,
) -> Vector4 {
  let t2 = t * t
  let t3 = t2 * t
  let two : Float = 2.0
  let three : Float = 3.0
  let one : Float = 1.0
  let h00 = two * t3 - three * t2 + one
  let h10 = t3 - two * t2 + t
  let h01 = -two * t3 + three * t2
  let h11 = t3 - t2
  let p0 = Vector4::quat_scale(q1, h00)
  let m0 = Vector4::quat_scale(out_tangent1, h10)
  let p1 = Vector4::quat_scale(q2, h01)
  let m1 = Vector4::quat_scale(in_tangent2, h11)
  let result = Vector4::quat_add(p0, m0)
  let result = Vector4::quat_add(result, p1)
  let result = Vector4::quat_add(result, m1)
  Vector4::quat_normalize(result)
}

///|
pub fn Vector4::quat_from_vector3_to_vector3(
  from_ : Vector3,
  to : Vector3,
) -> Vector4 {
  // Vector3DotProduct(from_, to)
  let cos2_theta = from_.x * to.x + from_.y * to.y + from_.z * to.z
  // Vector3CrossProduct(from_, to)
  let cross_x = from_.y * to.z - from_.z * to.y
  let cross_y = from_.z * to.x - from_.x * to.z
  let cross_z = from_.x * to.y - from_.y * to.x
  let qx = cross_x
  let qy = cross_y
  let qz = cross_z
  let qw : Float = (1.0 : Float) + cos2_theta
  // QuaternionNormalize(q)
  let len = sqrtf(qx * qx + qy * qy + qz * qz + qw * qw)
  let length : Float = if len == 0.0 { 1.0 } else { len }
  let ilength : Float = (1.0 : Float) / length
  { x: qx * ilength, y: qy * ilength, z: qz * ilength, w: qw * ilength }
}

///|
pub fn Vector4::quat_from_matrix(mat : Matrix) -> Vector4 {
  let four_w_sq_minus1 = mat.m0 + mat.m5 + mat.m10
  let four_x_sq_minus1 = mat.m0 - mat.m5 - mat.m10
  let four_y_sq_minus1 = mat.m5 - mat.m0 - mat.m10
  let four_z_sq_minus1 = mat.m10 - mat.m0 - mat.m5
  let mut biggest_index = 0
  let mut four_biggest_sq_minus1 = four_w_sq_minus1
  if four_x_sq_minus1 > four_biggest_sq_minus1 {
    four_biggest_sq_minus1 = four_x_sq_minus1
    biggest_index = 1
  }
  if four_y_sq_minus1 > four_biggest_sq_minus1 {
    four_biggest_sq_minus1 = four_y_sq_minus1
    biggest_index = 2
  }
  if four_z_sq_minus1 > four_biggest_sq_minus1 {
    four_biggest_sq_minus1 = four_z_sq_minus1
    biggest_index = 3
  }
  let biggest_val = sqrtf(four_biggest_sq_minus1 + (1.0 : Float)) *
    (0.5 : Float)
  let mult : Float = (0.25 : Float) / biggest_val
  if biggest_index == 0 {
    {
      x: (mat.m6 - mat.m9) * mult,
      y: (mat.m8 - mat.m2) * mult,
      z: (mat.m1 - mat.m4) * mult,
      w: biggest_val,
    }
  } else if biggest_index == 1 {
    {
      x: biggest_val,
      y: (mat.m1 + mat.m4) * mult,
      z: (mat.m8 + mat.m2) * mult,
      w: (mat.m6 - mat.m9) * mult,
    }
  } else if biggest_index == 2 {
    {
      x: (mat.m1 + mat.m4) * mult,
      y: biggest_val,
      z: (mat.m6 + mat.m9) * mult,
      w: (mat.m8 - mat.m2) * mult,
    }
  } else {
    {
      x: (mat.m8 + mat.m2) * mult,
      y: (mat.m6 + mat.m9) * mult,
      z: biggest_val,
      w: (mat.m1 - mat.m4) * mult,
    }
  }
}

///|
pub fn Vector4::quat_to_matrix(q : Vector4) -> Matrix {
  let a2 = q.x * q.x
  let b2 = q.y * q.y
  let c2 = q.z * q.z
  let ac = q.x * q.z
  let ab = q.x * q.y
  let bc = q.y * q.z
  let ad = q.w * q.x
  let bd = q.w * q.y
  let cd = q.w * q.z
  let two : Float = 2.0
  let one : Float = 1.0
  {
    m0: one - two * (b2 + c2),
    m1: two * (ab + cd),
    m2: two * (ac - bd),
    m3: 0.0,
    m4: two * (ab - cd),
    m5: one - two * (a2 + c2),
    m6: two * (bc + ad),
    m7: 0.0,
    m8: two * (ac + bd),
    m9: two * (bc - ad),
    m10: one - two * (a2 + b2),
    m11: 0.0,
    m12: 0.0,
    m13: 0.0,
    m14: 0.0,
    m15: 1.0,
  }
}

///|
pub fn Vector4::quat_from_axis_angle(axis : Vector3, angle : Float) -> Vector4 {
  let axis_length = sqrtf(axis.x * axis.x + axis.y * axis.y + axis.z * axis.z)
  if axis_length != 0.0 {
    let half_angle = angle * (0.5 : Float)
    // Vector3Normalize(axis)
    let length : Float = if axis_length == 0.0 { 1.0 } else { axis_length }
    let ilength : Float = (1.0 : Float) / length
    let ax = axis.x * ilength
    let ay = axis.y * ilength
    let az = axis.z * ilength
    let sinres = sinf(half_angle)
    let cosres = cosf(half_angle)
    let qx = ax * sinres
    let qy = ay * sinres
    let qz = az * sinres
    let qw = cosres
    // QuaternionNormalize(q)
    let len = sqrtf(qx * qx + qy * qy + qz * qz + qw * qw)
    let norm_length : Float = if len == 0.0 { 1.0 } else { len }
    let inv_len : Float = (1.0 : Float) / norm_length
    { x: qx * inv_len, y: qy * inv_len, z: qz * inv_len, w: qw * inv_len }
  } else {
    { x: 0.0, y: 0.0, z: 0.0, w: 1.0 }
  }
}

///|
pub fn Vector4::quat_to_axis_angle(q : Vector4) -> (Vector3, Float) {
  let epsilon : Float = 0.000001
  let mut qx = q.x
  let mut qy = q.y
  let mut qz = q.z
  let mut qw = q.w
  if fabsf(qw) > (1.0 : Float) {
    // QuaternionNormalize(q)
    let len = sqrtf(qx * qx + qy * qy + qz * qz + qw * qw)
    let length : Float = if len == 0.0 { 1.0 } else { len }
    let ilength : Float = (1.0 : Float) / length
    qx = qx * ilength
    qy = qy * ilength
    qz = qz * ilength
    qw = qw * ilength
  }
  let res_angle : Float = (2.0 : Float) * acosf(qw)
  let den = sqrtf((1.0 : Float) - qw * qw)
  let res_axis : Vector3 = if den > epsilon {
    { x: qx / den, y: qy / den, z: qz / den }
  } else {
    // Angle is zero, set arbitrary normalized axis
    { x: 1.0, y: 0.0, z: 0.0 }
  }
  (res_axis, res_angle)
}

///|
pub fn Vector4::quat_from_euler(
  pitch : Float,
  yaw : Float,
  roll : Float,
) -> Vector4 {
  let half : Float = 0.5
  let x0 = cosf(pitch * half)
  let x1 = sinf(pitch * half)
  let y0 = cosf(yaw * half)
  let y1 = sinf(yaw * half)
  let z0 = cosf(roll * half)
  let z1 = sinf(roll * half)
  {
    x: x1 * y0 * z0 - x0 * y1 * z1,
    y: x0 * y1 * z0 + x1 * y0 * z1,
    z: x0 * y0 * z1 - x1 * y1 * z0,
    w: x0 * y0 * z0 + x1 * y1 * z1,
  }
}

///|
pub fn Vector4::quat_to_euler(q : Vector4) -> Vector3 {
  let two : Float = 2.0
  let one : Float = 1.0
  // Roll (x-axis rotation)
  let x0 = two * (q.w * q.x + q.y * q.z)
  let x1 = one - two * (q.x * q.x + q.y * q.y)
  let roll = atan2f(x0, x1)
  // Pitch (y-axis rotation)
  let mut y0 = two * (q.w * q.y - q.z * q.x)
  if y0 > (1.0 : Float) {
    y0 = 1.0
  }
  if y0 < (-1.0 : Float) {
    y0 = -1.0
  }
  let pitch = asinf(y0)
  // Yaw (z-axis rotation)
  let z0 = two * (q.w * q.z + q.x * q.y)
  let z1 = one - two * (q.y * q.y + q.z * q.z)
  let yaw = atan2f(z0, z1)
  { x: roll, y: pitch, z: yaw }
}

///|
pub fn Vector4::quat_transform(q : Vector4, mat : Matrix) -> Vector4 {
  {
    x: mat.m0 * q.x + mat.m4 * q.y + mat.m8 * q.z + mat.m12 * q.w,
    y: mat.m1 * q.x + mat.m5 * q.y + mat.m9 * q.z + mat.m13 * q.w,
    z: mat.m2 * q.x + mat.m6 * q.y + mat.m10 * q.z + mat.m14 * q.w,
    w: mat.m3 * q.x + mat.m7 * q.y + mat.m11 * q.z + mat.m15 * q.w,
  }
}

///|
pub fn Vector4::quat_equals(p : Vector4, q : Vector4) -> Bool {
  let epsilon : Float = 0.000001
  (
    fabsf(p.x - q.x) <=
    epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.x), fabsf(q.x))) &&
    fabsf(p.y - q.y) <=
    epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.y), fabsf(q.y))) &&
    fabsf(p.z - q.z) <=
    epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.z), fabsf(q.z))) &&
    fabsf(p.w - q.w) <=
    epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.w), fabsf(q.w)))
  ) ||
  (
    fabsf(p.x + q.x) <=
    epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.x), fabsf(q.x))) &&
    fabsf(p.y + q.y) <=
    epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.y), fabsf(q.y))) &&
    fabsf(p.z + q.z) <=
    epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.z), fabsf(q.z))) &&
    fabsf(p.w + q.w) <=
    epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.w), fabsf(q.w)))
  )
}

///|
pub fn Vector4::quat_add(q1 : Vector4, q2 : Vector4) -> Vector4 {
  { x: q1.x + q2.x, y: q1.y + q2.y, z: q1.z + q2.z, w: q1.w + q2.w }
}

///|
pub fn Vector4::quat_add_value(q : Vector4, add : Float) -> Vector4 {
  { x: q.x + add, y: q.y + add, z: q.z + add, w: q.w + add }
}

///|
pub fn Vector4::quat_subtract(q1 : Vector4, q2 : Vector4) -> Vector4 {
  { x: q1.x - q2.x, y: q1.y - q2.y, z: q1.z - q2.z, w: q1.w - q2.w }
}

///|
pub fn Vector4::quat_subtract_value(q : Vector4, sub : Float) -> Vector4 {
  { x: q.x - sub, y: q.y - sub, z: q.z - sub, w: q.w - sub }
}
