// Vector3 math functions — pure MoonBit port of raymath Vector3 operations
// Private math helpers are in math_helpers.mbt

// Private helper: matrix inversion (needed by Vector3::unproject)

///|
fn matrix_invert(m : Matrix) -> Matrix {
  let a00 = m.m0
  let a01 = m.m1
  let a02 = m.m2
  let a03 = m.m3
  let a10 = m.m4
  let a11 = m.m5
  let a12 = m.m6
  let a13 = m.m7
  let a20 = m.m8
  let a21 = m.m9
  let a22 = m.m10
  let a23 = m.m11
  let a30 = m.m12
  let a31 = m.m13
  let a32 = m.m14
  let a33 = m.m15
  let b00 = a00 * a11 - a01 * a10
  let b01 = a00 * a12 - a02 * a10
  let b02 = a00 * a13 - a03 * a10
  let b03 = a01 * a12 - a02 * a11
  let b04 = a01 * a13 - a03 * a11
  let b05 = a02 * a13 - a03 * a12
  let b06 = a20 * a31 - a21 * a30
  let b07 = a20 * a32 - a22 * a30
  let b08 = a20 * a33 - a23 * a30
  let b09 = a21 * a32 - a22 * a31
  let b10 = a21 * a33 - a23 * a31
  let b11 = a22 * a33 - a23 * a32
  let inv_det : Float = (1.0 : Float) /
    (b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06)
  {
    m0: (a11 * b11 - a12 * b10 + a13 * b09) * inv_det,
    m1: (-a01 * b11 + a02 * b10 - a03 * b09) * inv_det,
    m2: (a31 * b05 - a32 * b04 + a33 * b03) * inv_det,
    m3: (-a21 * b05 + a22 * b04 - a23 * b03) * inv_det,
    m4: (-a10 * b11 + a12 * b08 - a13 * b07) * inv_det,
    m5: (a00 * b11 - a02 * b08 + a03 * b07) * inv_det,
    m6: (-a30 * b05 + a32 * b02 - a33 * b01) * inv_det,
    m7: (a20 * b05 - a22 * b02 + a23 * b01) * inv_det,
    m8: (a10 * b10 - a11 * b08 + a13 * b06) * inv_det,
    m9: (-a00 * b10 + a01 * b08 - a03 * b06) * inv_det,
    m10: (a30 * b04 - a31 * b02 + a33 * b00) * inv_det,
    m11: (-a20 * b04 + a21 * b02 - a23 * b00) * inv_det,
    m12: (-a10 * b09 + a11 * b07 - a12 * b06) * inv_det,
    m13: (a00 * b09 - a01 * b07 + a02 * b06) * inv_det,
    m14: (-a30 * b03 + a31 * b01 - a32 * b00) * inv_det,
    m15: (a20 * b03 - a21 * b01 + a22 * b00) * inv_det,
  }
}

// Vector3 math functions

///|
pub fn Vector3::zero() -> Vector3 {
  { x: 0.0, y: 0.0, z: 0.0 }
}

///|
pub fn Vector3::one() -> Vector3 {
  { x: 1.0, y: 1.0, z: 1.0 }
}

///|
pub fn Vector3::add(v1 : Vector3, v2 : Vector3) -> Vector3 {
  { x: v1.x + v2.x, y: v1.y + v2.y, z: v1.z + v2.z }
}

///|
pub fn Vector3::add_value(v : Vector3, add : Float) -> Vector3 {
  { x: v.x + add, y: v.y + add, z: v.z + add }
}

///|
pub fn Vector3::subtract(v1 : Vector3, v2 : Vector3) -> Vector3 {
  { x: v1.x - v2.x, y: v1.y - v2.y, z: v1.z - v2.z }
}

///|
pub fn Vector3::subtract_value(v : Vector3, sub : Float) -> Vector3 {
  { x: v.x - sub, y: v.y - sub, z: v.z - sub }
}

///|
pub fn Vector3::scale(v : Vector3, scalar : Float) -> Vector3 {
  { x: v.x * scalar, y: v.y * scalar, z: v.z * scalar }
}

///|
pub fn Vector3::multiply(v1 : Vector3, v2 : Vector3) -> Vector3 {
  { x: v1.x * v2.x, y: v1.y * v2.y, z: v1.z * v2.z }
}

///|
pub fn Vector3::cross_product(v1 : Vector3, v2 : Vector3) -> Vector3 {
  {
    x: v1.y * v2.z - v1.z * v2.y,
    y: v1.z * v2.x - v1.x * v2.z,
    z: v1.x * v2.y - v1.y * v2.x,
  }
}

///|
pub fn Vector3::perpendicular(v : Vector3) -> Vector3 {
  let mut min = fabsf(v.x)
  let mut cardinal_x : Float = 1.0
  let mut cardinal_y : Float = 0.0
  let mut cardinal_z : Float = 0.0
  if fabsf(v.y) < min {
    min = fabsf(v.y)
    cardinal_x = 0.0
    cardinal_y = 1.0
    cardinal_z = 0.0
  }
  if fabsf(v.z) < min {
    cardinal_x = 0.0
    cardinal_y = 0.0
    cardinal_z = 1.0
  }
  ignore(min)
  {
    x: v.y * cardinal_z - v.z * cardinal_y,
    y: v.z * cardinal_x - v.x * cardinal_z,
    z: v.x * cardinal_y - v.y * cardinal_x,
  }
}

///|
pub fn Vector3::length(v : Vector3) -> Float {
  sqrtf(v.x * v.x + v.y * v.y + v.z * v.z)
}

///|
pub fn Vector3::length_sqr(v : Vector3) -> Float {
  v.x * v.x + v.y * v.y + v.z * v.z
}

///|
pub fn Vector3::dot_product(v1 : Vector3, v2 : Vector3) -> Float {
  v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
}

///|
pub fn Vector3::distance(v1 : Vector3, v2 : Vector3) -> Float {
  let dx = v2.x - v1.x
  let dy = v2.y - v1.y
  let dz = v2.z - v1.z
  sqrtf(dx * dx + dy * dy + dz * dz)
}

///|
pub fn Vector3::distance_sqr(v1 : Vector3, v2 : Vector3) -> Float {
  let dx = v2.x - v1.x
  let dy = v2.y - v1.y
  let dz = v2.z - v1.z
  dx * dx + dy * dy + dz * dz
}

///|
pub fn Vector3::angle(v1 : Vector3, v2 : Vector3) -> Float {
  let cross_x = v1.y * v2.z - v1.z * v2.y
  let cross_y = v1.z * v2.x - v1.x * v2.z
  let cross_z = v1.x * v2.y - v1.y * v2.x
  let len = sqrtf(cross_x * cross_x + cross_y * cross_y + cross_z * cross_z)
  let dot = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
  atan2f(len, dot)
}

///|
pub fn Vector3::normalize(v : Vector3) -> Vector3 {
  let length = sqrtf(v.x * v.x + v.y * v.y + v.z * v.z)
  if length != 0.0 {
    let ilength : Float = (1.0 : Float) / length
    { x: v.x * ilength, y: v.y * ilength, z: v.z * ilength }
  } else {
    v
  }
}

///|
pub fn Vector3::project(v1 : Vector3, v2 : Vector3) -> Vector3 {
  let v1dv2 = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
  let v2dv2 = v2.x * v2.x + v2.y * v2.y + v2.z * v2.z
  let mag = v1dv2 / v2dv2
  { x: v2.x * mag, y: v2.y * mag, z: v2.z * mag }
}

///|
pub fn Vector3::reject(v1 : Vector3, v2 : Vector3) -> Vector3 {
  let v1dv2 = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
  let v2dv2 = v2.x * v2.x + v2.y * v2.y + v2.z * v2.z
  let mag = v1dv2 / v2dv2
  { x: v1.x - v2.x * mag, y: v1.y - v2.y * mag, z: v1.z - v2.z * mag }
}

///|
pub fn Vector3::lerp(v1 : Vector3, v2 : Vector3, amount : Float) -> Vector3 {
  {
    x: v1.x + amount * (v2.x - v1.x),
    y: v1.y + amount * (v2.y - v1.y),
    z: v1.z + amount * (v2.z - v1.z),
  }
}

///|
pub fn Vector3::reflect(v : Vector3, normal : Vector3) -> Vector3 {
  let dot = v.x * normal.x + v.y * normal.y + v.z * normal.z
  {
    x: v.x - (2.0 : Float) * normal.x * dot,
    y: v.y - (2.0 : Float) * normal.y * dot,
    z: v.z - (2.0 : Float) * normal.z * dot,
  }
}

///|
pub fn Vector3::min(v1 : Vector3, v2 : Vector3) -> Vector3 {
  { x: fminf(v1.x, v2.x), y: fminf(v1.y, v2.y), z: fminf(v1.z, v2.z) }
}

///|
pub fn Vector3::max(v1 : Vector3, v2 : Vector3) -> Vector3 {
  { x: fmaxf(v1.x, v2.x), y: fmaxf(v1.y, v2.y), z: fmaxf(v1.z, v2.z) }
}

///|
pub fn Vector3::barycenter(
  p : Vector3,
  a : Vector3,
  b : Vector3,
  c : Vector3,
) -> Vector3 {
  let v0 : Vector3 = { x: b.x - a.x, y: b.y - a.y, z: b.z - a.z }
  let v1 : Vector3 = { x: c.x - a.x, y: c.y - a.y, z: c.z - a.z }
  let v2 : Vector3 = { x: p.x - a.x, y: p.y - a.y, z: p.z - a.z }
  let d00 = v0.x * v0.x + v0.y * v0.y + v0.z * v0.z
  let d01 = v0.x * v1.x + v0.y * v1.y + v0.z * v1.z
  let d11 = v1.x * v1.x + v1.y * v1.y + v1.z * v1.z
  let d20 = v2.x * v0.x + v2.y * v0.y + v2.z * v0.z
  let d21 = v2.x * v1.x + v2.y * v1.y + v2.z * v1.z
  let denom = d00 * d11 - d01 * d01
  let ry = (d11 * d20 - d01 * d21) / denom
  let rz = (d00 * d21 - d01 * d20) / denom
  let rx : Float = (1.0 : Float) - (rz + ry)
  { x: rx, y: ry, z: rz }
}

///|
pub fn Vector3::unproject(
  source : Vector3,
  projection : Matrix,
  view : Matrix,
) -> Vector3 {
  // Calculate unprojected matrix (multiply view matrix by projection matrix) and invert it
  let mat_view_proj : Matrix = {
    m0: view.m0 * projection.m0 +
    view.m1 * projection.m4 +
    view.m2 * projection.m8 +
    view.m3 * projection.m12,
    m1: view.m0 * projection.m1 +
    view.m1 * projection.m5 +
    view.m2 * projection.m9 +
    view.m3 * projection.m13,
    m2: view.m0 * projection.m2 +
    view.m1 * projection.m6 +
    view.m2 * projection.m10 +
    view.m3 * projection.m14,
    m3: view.m0 * projection.m3 +
    view.m1 * projection.m7 +
    view.m2 * projection.m11 +
    view.m3 * projection.m15,
    m4: view.m4 * projection.m0 +
    view.m5 * projection.m4 +
    view.m6 * projection.m8 +
    view.m7 * projection.m12,
    m5: view.m4 * projection.m1 +
    view.m5 * projection.m5 +
    view.m6 * projection.m9 +
    view.m7 * projection.m13,
    m6: view.m4 * projection.m2 +
    view.m5 * projection.m6 +
    view.m6 * projection.m10 +
    view.m7 * projection.m14,
    m7: view.m4 * projection.m3 +
    view.m5 * projection.m7 +
    view.m6 * projection.m11 +
    view.m7 * projection.m15,
    m8: view.m8 * projection.m0 +
    view.m9 * projection.m4 +
    view.m10 * projection.m8 +
    view.m11 * projection.m12,
    m9: view.m8 * projection.m1 +
    view.m9 * projection.m5 +
    view.m10 * projection.m9 +
    view.m11 * projection.m13,
    m10: view.m8 * projection.m2 +
    view.m9 * projection.m6 +
    view.m10 * projection.m10 +
    view.m11 * projection.m14,
    m11: view.m8 * projection.m3 +
    view.m9 * projection.m7 +
    view.m10 * projection.m11 +
    view.m11 * projection.m15,
    m12: view.m12 * projection.m0 +
    view.m13 * projection.m4 +
    view.m14 * projection.m8 +
    view.m15 * projection.m12,
    m13: view.m12 * projection.m1 +
    view.m13 * projection.m5 +
    view.m14 * projection.m9 +
    view.m15 * projection.m13,
    m14: view.m12 * projection.m2 +
    view.m13 * projection.m6 +
    view.m14 * projection.m10 +
    view.m15 * projection.m14,
    m15: view.m12 * projection.m3 +
    view.m13 * projection.m7 +
    view.m14 * projection.m11 +
    view.m15 * projection.m15,
  }
  // Invert the view-projection matrix
  let inv = matrix_invert(mat_view_proj)
  // Create quaternion from source point and transform by inverted matrix
  let qx = inv.m0 * source.x + inv.m4 * source.y + inv.m8 * source.z + inv.m12
  let qy = inv.m1 * source.x + inv.m5 * source.y + inv.m9 * source.z + inv.m13
  let qz = inv.m2 * source.x + inv.m6 * source.y + inv.m10 * source.z + inv.m14
  let qw = inv.m3 * source.x + inv.m7 * source.y + inv.m11 * source.z + inv.m15
  // Normalized world points
  { x: qx / qw, y: qy / qw, z: qz / qw }
}

///|
pub fn Vector3::ortho_normalize(
  v1 : Vector3,
  v2 : Vector3,
) -> (Vector3, Vector3) {
  // Normalize v1
  let mut length = sqrtf(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z)
  if length == 0.0 {
    length = 1.0
  }
  let ilength : Float = (1.0 : Float) / length
  let nv1 : Vector3 = {
    x: v1.x * ilength,
    y: v1.y * ilength,
    z: v1.z * ilength,
  }
  // Cross product of nv1 and v2
  let vn1_x = nv1.y * v2.z - nv1.z * v2.y
  let vn1_y = nv1.z * v2.x - nv1.x * v2.z
  let vn1_z = nv1.x * v2.y - nv1.y * v2.x
  // Normalize vn1
  let mut length2 = sqrtf(vn1_x * vn1_x + vn1_y * vn1_y + vn1_z * vn1_z)
  if length2 == 0.0 {
    length2 = 1.0
  }
  let ilength2 : Float = (1.0 : Float) / length2
  let nvn1_x = vn1_x * ilength2
  let nvn1_y = vn1_y * ilength2
  let nvn1_z = vn1_z * ilength2
  // Cross product of nvn1 and nv1
  let nv2 : Vector3 = {
    x: nvn1_y * nv1.z - nvn1_z * nv1.y,
    y: nvn1_z * nv1.x - nvn1_x * nv1.z,
    z: nvn1_x * nv1.y - nvn1_y * nv1.x,
  }
  (nv1, nv2)
}

///|
pub fn Vector3::transform(v : Vector3, mat : Matrix) -> Vector3 {
  let x = v.x
  let y = v.y
  let z = v.z
  {
    x: mat.m0 * x + mat.m4 * y + mat.m8 * z + mat.m12,
    y: mat.m1 * x + mat.m5 * y + mat.m9 * z + mat.m13,
    z: mat.m2 * x + mat.m6 * y + mat.m10 * z + mat.m14,
  }
}

///|
pub fn Vector3::rotate_by_quaternion(v : Vector3, q : Vector4) -> Vector3 {
  {
    x: v.x * (q.x * q.x + q.w * q.w - q.y * q.y - q.z * q.z) +
    v.y * ((2.0 : Float) * q.x * q.y - (2.0 : Float) * q.w * q.z) +
    v.z * ((2.0 : Float) * q.x * q.z + (2.0 : Float) * q.w * q.y),
    y: v.x * ((2.0 : Float) * q.w * q.z + (2.0 : Float) * q.x * q.y) +
    v.y * (q.w * q.w - q.x * q.x + q.y * q.y - q.z * q.z) +
    v.z * (-(2.0 : Float) * q.w * q.x + (2.0 : Float) * q.y * q.z),
    z: v.x * (-(2.0 : Float) * q.w * q.y + (2.0 : Float) * q.x * q.z) +
    v.y * ((2.0 : Float) * q.w * q.x + (2.0 : Float) * q.y * q.z) +
    v.z * (q.w * q.w - q.x * q.x - q.y * q.y + q.z * q.z),
  }
}

///|
pub fn Vector3::rotate_by_axis_angle(
  v : Vector3,
  axis : Vector3,
  angle : Float,
) -> Vector3 {
  // Normalize axis
  let mut length = sqrtf(axis.x * axis.x + axis.y * axis.y + axis.z * axis.z)
  if length == 0.0 {
    length = 1.0
  }
  let ilength : Float = (1.0 : Float) / length
  let ax = axis.x * ilength
  let ay = axis.y * ilength
  let az = axis.z * ilength
  let half_angle = angle / (2.0 : Float)
  let a_sin = sinf(half_angle)
  let b = ax * a_sin
  let c = ay * a_sin
  let d = az * a_sin
  let a_cos = cosf(half_angle)
  let w : Vector3 = { x: b, y: c, z: d }
  // Cross product w x v
  let wv_x = w.y * v.z - w.z * v.y
  let wv_y = w.z * v.x - w.x * v.z
  let wv_z = w.x * v.y - w.y * v.x
  // Cross product w x wv
  let wwv_x = w.y * wv_z - w.z * wv_y
  let wwv_y = w.z * wv_x - w.x * wv_z
  let wwv_z = w.x * wv_y - w.y * wv_x
  // Scale wv by 2*a, scale wwv by 2
  let sa = a_cos * (2.0 : Float)
  {
    x: v.x + wv_x * sa + wwv_x * (2.0 : Float),
    y: v.y + wv_y * sa + wwv_y * (2.0 : Float),
    z: v.z + wv_z * sa + wwv_z * (2.0 : Float),
  }
}

///|
pub fn Vector3::move_towards(
  v : Vector3,
  target : Vector3,
  max_distance : Float,
) -> Vector3 {
  let dx = target.x - v.x
  let dy = target.y - v.y
  let dz = target.z - v.z
  let value = dx * dx + dy * dy + dz * dz
  if value == 0.0 ||
    (max_distance >= 0.0 && value <= max_distance * max_distance) {
    return target
  }
  let dist = sqrtf(value)
  {
    x: v.x + dx / dist * max_distance,
    y: v.y + dy / dist * max_distance,
    z: v.z + dz / dist * max_distance,
  }
}

///|
pub fn Vector3::invert(v : Vector3) -> Vector3 {
  { x: (1.0 : Float) / v.x, y: (1.0 : Float) / v.y, z: (1.0 : Float) / v.z }
}

///|
pub fn Vector3::clamp(v : Vector3, min : Vector3, max : Vector3) -> Vector3 {
  {
    x: fminf(max.x, fmaxf(min.x, v.x)),
    y: fminf(max.y, fmaxf(min.y, v.y)),
    z: fminf(max.z, fmaxf(min.z, v.z)),
  }
}

///|
pub fn Vector3::equals(p : Vector3, q : Vector3) -> Bool {
  let epsilon : Float = 0.000001
  fabsf(p.x - q.x) <=
  epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.x), fabsf(q.x))) &&
  fabsf(p.y - q.y) <=
  epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.y), fabsf(q.y))) &&
  fabsf(p.z - q.z) <=
  epsilon * fmaxf((1.0 : Float), fmaxf(fabsf(p.z), fabsf(q.z)))
}

///|
pub fn Vector3::refract(v : Vector3, n : Vector3, r : Float) -> Vector3 {
  let dot = v.x * n.x + v.y * n.y + v.z * n.z
  let d : Float = (1.0 : Float) - r * r * ((1.0 : Float) - dot * dot)
  if d >= 0.0 {
    let d_sqrt = sqrtf(d)
    {
      x: r * v.x - (r * dot + d_sqrt) * n.x,
      y: r * v.y - (r * dot + d_sqrt) * n.y,
      z: r * v.z - (r * dot + d_sqrt) * n.z,
    }
  } else {
    { x: 0.0, y: 0.0, z: 0.0 }
  }
}
