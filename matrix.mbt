// Matrix: 64 bytes (16 floats in column-major order)
// C layout: m0, m4, m8, m12, m1, m5, m9, m13, m2, m6, m10, m14, m3, m7, m11, m15

///|
pub struct Matrix {
  m0 : Float
  m1 : Float
  m2 : Float
  m3 : Float
  m4 : Float
  m5 : Float
  m6 : Float
  m7 : Float
  m8 : Float
  m9 : Float
  m10 : Float
  m11 : Float
  m12 : Float
  m13 : Float
  m14 : Float
  m15 : Float
} derive(Eq, Show)

///|
pub fn Matrix::identity() -> Matrix {
  {
    m0: 1.0,
    m1: 0.0,
    m2: 0.0,
    m3: 0.0,
    m4: 0.0,
    m5: 1.0,
    m6: 0.0,
    m7: 0.0,
    m8: 0.0,
    m9: 0.0,
    m10: 1.0,
    m11: 0.0,
    m12: 0.0,
    m13: 0.0,
    m14: 0.0,
    m15: 1.0,
  }
}

///|
pub fn Matrix::to_bytes(m : Matrix) -> Bytes {
  // Column-major C layout: m0, m4, m8, m12, m1, m5, m9, m13, m2, m6, m10, m14, m3, m7, m11, m15
  let (a0, a1, a2, a3) = write_float(m.m0)
  let (a4, a5, a6, a7) = write_float(m.m4)
  let (a8, a9, aa, ab) = write_float(m.m8)
  let (ac, ad, ae, af) = write_float(m.m12)
  let (b0, b1, b2, b3) = write_float(m.m1)
  let (b4, b5, b6, b7) = write_float(m.m5)
  let (b8, b9, ba, bb) = write_float(m.m9)
  let (bc, bd, be, bf) = write_float(m.m13)
  let (c0, c1, c2, c3) = write_float(m.m2)
  let (c4, c5, c6, c7) = write_float(m.m6)
  let (c8, c9, ca, cb) = write_float(m.m10)
  let (cc, cd, ce, cf) = write_float(m.m14)
  let (d0, d1, d2, d3) = write_float(m.m3)
  let (d4, d5, d6, d7) = write_float(m.m7)
  let (d8, d9, da, db) = write_float(m.m11)
  let (dc, dd, de, df) = write_float(m.m15)
  [
    a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, aa, ab, ac, ad, ae, af, b0, b1, b2, b3,
    b4, b5, b6, b7, b8, b9, ba, bb, bc, bd, be, bf, c0, c1, c2, c3, c4, c5, c6, c7,
    c8, c9, ca, cb, cc, cd, ce, cf, d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, da, db,
    dc, dd, de, df,
  ]
}

///|
pub fn Matrix::from_bytes(b : Bytes) -> Matrix {
  // Column-major C layout: m0, m4, m8, m12, m1, m5, m9, m13, m2, m6, m10, m14, m3, m7, m11, m15
  {
    m0: read_float(b, 0),
    m4: read_float(b, 4),
    m8: read_float(b, 8),
    m12: read_float(b, 12),
    m1: read_float(b, 16),
    m5: read_float(b, 20),
    m9: read_float(b, 24),
    m13: read_float(b, 28),
    m2: read_float(b, 32),
    m6: read_float(b, 36),
    m10: read_float(b, 40),
    m14: read_float(b, 44),
    m3: read_float(b, 48),
    m7: read_float(b, 52),
    m11: read_float(b, 56),
    m15: read_float(b, 60),
  }
}

// ----- Matrix math functions -----

///|
pub fn Matrix::determinant(mat : Matrix) -> Float {
  // Cache the matrix values (speed optimization)
  let a00 = mat.m0
  let a01 = mat.m1
  let a02 = mat.m2
  let a03 = mat.m3
  let a10 = mat.m4
  let a11 = mat.m5
  let a12 = mat.m6
  let a13 = mat.m7
  let a20 = mat.m8
  let a21 = mat.m9
  let a22 = mat.m10
  let a23 = mat.m11
  let a30 = mat.m12
  let a31 = mat.m13
  let a32 = mat.m14
  let a33 = mat.m15
  a30 * a21 * a12 * a03 -
  a20 * a31 * a12 * a03 -
  a30 * a11 * a22 * a03 +
  a10 * a31 * a22 * a03 +
  a20 * a11 * a32 * a03 -
  a10 * a21 * a32 * a03 -
  a30 * a21 * a02 * a13 +
  a20 * a31 * a02 * a13 +
  a30 * a01 * a22 * a13 -
  a00 * a31 * a22 * a13 -
  a20 * a01 * a32 * a13 +
  a00 * a21 * a32 * a13 +
  a30 * a11 * a02 * a23 -
  a10 * a31 * a02 * a23 -
  a30 * a01 * a12 * a23 +
  a00 * a31 * a12 * a23 +
  a10 * a01 * a32 * a23 -
  a00 * a11 * a32 * a23 -
  a20 * a11 * a02 * a33 +
  a10 * a21 * a02 * a33 +
  a20 * a01 * a12 * a33 -
  a00 * a21 * a12 * a33 -
  a10 * a01 * a22 * a33 +
  a00 * a11 * a22 * a33
}

///|
pub fn Matrix::trace(mat : Matrix) -> Float {
  mat.m0 + mat.m5 + mat.m10 + mat.m15
}

///|
pub fn Matrix::transpose(mat : Matrix) -> Matrix {
  {
    m0: mat.m0,
    m1: mat.m4,
    m2: mat.m8,
    m3: mat.m12,
    m4: mat.m1,
    m5: mat.m5,
    m6: mat.m9,
    m7: mat.m13,
    m8: mat.m2,
    m9: mat.m6,
    m10: mat.m10,
    m11: mat.m14,
    m12: mat.m3,
    m13: mat.m7,
    m14: mat.m11,
    m15: mat.m15,
  }
}

///|
pub fn Matrix::invert(mat : Matrix) -> Matrix {
  // Cache the matrix values (speed optimization)
  let a00 = mat.m0
  let a01 = mat.m1
  let a02 = mat.m2
  let a03 = mat.m3
  let a10 = mat.m4
  let a11 = mat.m5
  let a12 = mat.m6
  let a13 = mat.m7
  let a20 = mat.m8
  let a21 = mat.m9
  let a22 = mat.m10
  let a23 = mat.m11
  let a30 = mat.m12
  let a31 = mat.m13
  let a32 = mat.m14
  let a33 = mat.m15
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
  // Calculate the invert determinant (inlined to avoid double-caching)
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

///|
pub fn Matrix::add(left : Matrix, right : Matrix) -> Matrix {
  {
    m0: left.m0 + right.m0,
    m1: left.m1 + right.m1,
    m2: left.m2 + right.m2,
    m3: left.m3 + right.m3,
    m4: left.m4 + right.m4,
    m5: left.m5 + right.m5,
    m6: left.m6 + right.m6,
    m7: left.m7 + right.m7,
    m8: left.m8 + right.m8,
    m9: left.m9 + right.m9,
    m10: left.m10 + right.m10,
    m11: left.m11 + right.m11,
    m12: left.m12 + right.m12,
    m13: left.m13 + right.m13,
    m14: left.m14 + right.m14,
    m15: left.m15 + right.m15,
  }
}

///|
pub fn Matrix::subtract(left : Matrix, right : Matrix) -> Matrix {
  {
    m0: left.m0 - right.m0,
    m1: left.m1 - right.m1,
    m2: left.m2 - right.m2,
    m3: left.m3 - right.m3,
    m4: left.m4 - right.m4,
    m5: left.m5 - right.m5,
    m6: left.m6 - right.m6,
    m7: left.m7 - right.m7,
    m8: left.m8 - right.m8,
    m9: left.m9 - right.m9,
    m10: left.m10 - right.m10,
    m11: left.m11 - right.m11,
    m12: left.m12 - right.m12,
    m13: left.m13 - right.m13,
    m14: left.m14 - right.m14,
    m15: left.m15 - right.m15,
  }
}

///|
pub fn Matrix::multiply(left : Matrix, right : Matrix) -> Matrix {
  {
    m0: left.m0 * right.m0 +
    left.m1 * right.m4 +
    left.m2 * right.m8 +
    left.m3 * right.m12,
    m1: left.m0 * right.m1 +
    left.m1 * right.m5 +
    left.m2 * right.m9 +
    left.m3 * right.m13,
    m2: left.m0 * right.m2 +
    left.m1 * right.m6 +
    left.m2 * right.m10 +
    left.m3 * right.m14,
    m3: left.m0 * right.m3 +
    left.m1 * right.m7 +
    left.m2 * right.m11 +
    left.m3 * right.m15,
    m4: left.m4 * right.m0 +
    left.m5 * right.m4 +
    left.m6 * right.m8 +
    left.m7 * right.m12,
    m5: left.m4 * right.m1 +
    left.m5 * right.m5 +
    left.m6 * right.m9 +
    left.m7 * right.m13,
    m6: left.m4 * right.m2 +
    left.m5 * right.m6 +
    left.m6 * right.m10 +
    left.m7 * right.m14,
    m7: left.m4 * right.m3 +
    left.m5 * right.m7 +
    left.m6 * right.m11 +
    left.m7 * right.m15,
    m8: left.m8 * right.m0 +
    left.m9 * right.m4 +
    left.m10 * right.m8 +
    left.m11 * right.m12,
    m9: left.m8 * right.m1 +
    left.m9 * right.m5 +
    left.m10 * right.m9 +
    left.m11 * right.m13,
    m10: left.m8 * right.m2 +
    left.m9 * right.m6 +
    left.m10 * right.m10 +
    left.m11 * right.m14,
    m11: left.m8 * right.m3 +
    left.m9 * right.m7 +
    left.m10 * right.m11 +
    left.m11 * right.m15,
    m12: left.m12 * right.m0 +
    left.m13 * right.m4 +
    left.m14 * right.m8 +
    left.m15 * right.m12,
    m13: left.m12 * right.m1 +
    left.m13 * right.m5 +
    left.m14 * right.m9 +
    left.m15 * right.m13,
    m14: left.m12 * right.m2 +
    left.m13 * right.m6 +
    left.m14 * right.m10 +
    left.m15 * right.m14,
    m15: left.m12 * right.m3 +
    left.m13 * right.m7 +
    left.m14 * right.m11 +
    left.m15 * right.m15,
  }
}

///|
pub fn Matrix::translate(x : Float, y : Float, z : Float) -> Matrix {
  {
    m0: 1.0,
    m1: 0.0,
    m2: 0.0,
    m3: 0.0,
    m4: 0.0,
    m5: 1.0,
    m6: 0.0,
    m7: 0.0,
    m8: 0.0,
    m9: 0.0,
    m10: 1.0,
    m11: 0.0,
    m12: x,
    m13: y,
    m14: z,
    m15: 1.0,
  }
}

///|
pub fn Matrix::rotate(axis : Vector3, angle : Float) -> Matrix {
  let mut x = axis.x
  let mut y = axis.y
  let mut z = axis.z
  let length_squared = x * x + y * y + z * z
  if length_squared != 1.0 && length_squared != 0.0 {
    let ilength : Float = (1.0 : Float) / sqrtf(length_squared)
    x *= ilength
    y *= ilength
    z *= ilength
  }
  let sinres = sinf(angle)
  let cosres = cosf(angle)
  let t = (1.0 : Float) - cosres
  {
    m0: x * x * t + cosres,
    m1: y * x * t + z * sinres,
    m2: z * x * t - y * sinres,
    m3: 0.0,
    m4: x * y * t - z * sinres,
    m5: y * y * t + cosres,
    m6: z * y * t + x * sinres,
    m7: 0.0,
    m8: x * z * t + y * sinres,
    m9: y * z * t - x * sinres,
    m10: z * z * t + cosres,
    m11: 0.0,
    m12: 0.0,
    m13: 0.0,
    m14: 0.0,
    m15: 1.0,
  }
}

///|
pub fn Matrix::rotate_x(angle : Float) -> Matrix {
  let cosres = cosf(angle)
  let sinres = sinf(angle)
  {
    m0: 1.0,
    m1: 0.0,
    m2: 0.0,
    m3: 0.0,
    m4: 0.0,
    m5: cosres,
    m6: sinres,
    m7: 0.0,
    m8: 0.0,
    m9: -sinres,
    m10: cosres,
    m11: 0.0,
    m12: 0.0,
    m13: 0.0,
    m14: 0.0,
    m15: 1.0,
  }
}

///|
pub fn Matrix::rotate_y(angle : Float) -> Matrix {
  let cosres = cosf(angle)
  let sinres = sinf(angle)
  {
    m0: cosres,
    m1: 0.0,
    m2: -sinres,
    m3: 0.0,
    m4: 0.0,
    m5: 1.0,
    m6: 0.0,
    m7: 0.0,
    m8: sinres,
    m9: 0.0,
    m10: cosres,
    m11: 0.0,
    m12: 0.0,
    m13: 0.0,
    m14: 0.0,
    m15: 1.0,
  }
}

///|
pub fn Matrix::rotate_z(angle : Float) -> Matrix {
  let cosres = cosf(angle)
  let sinres = sinf(angle)
  {
    m0: cosres,
    m1: sinres,
    m2: 0.0,
    m3: 0.0,
    m4: -sinres,
    m5: cosres,
    m6: 0.0,
    m7: 0.0,
    m8: 0.0,
    m9: 0.0,
    m10: 1.0,
    m11: 0.0,
    m12: 0.0,
    m13: 0.0,
    m14: 0.0,
    m15: 1.0,
  }
}

///|
pub fn Matrix::rotate_xyz(angle : Vector3) -> Matrix {
  let cosz = cosf(-angle.z)
  let sinz = sinf(-angle.z)
  let cosy = cosf(-angle.y)
  let siny = sinf(-angle.y)
  let cosx = cosf(-angle.x)
  let sinx = sinf(-angle.x)
  {
    m0: cosz * cosy,
    m1: cosz * siny * sinx - sinz * cosx,
    m2: cosz * siny * cosx + sinz * sinx,
    m3: 0.0,
    m4: sinz * cosy,
    m5: sinz * siny * sinx + cosz * cosx,
    m6: sinz * siny * cosx - cosz * sinx,
    m7: 0.0,
    m8: -siny,
    m9: cosy * sinx,
    m10: cosy * cosx,
    m11: 0.0,
    m12: 0.0,
    m13: 0.0,
    m14: 0.0,
    m15: 1.0,
  }
}

///|
pub fn Matrix::rotate_zyx(angle : Vector3) -> Matrix {
  let cz = cosf(angle.z)
  let sz = sinf(angle.z)
  let cy = cosf(angle.y)
  let sy = sinf(angle.y)
  let cx = cosf(angle.x)
  let sx = sinf(angle.x)
  {
    m0: cz * cy,
    m1: cy * sz,
    m2: -sy,
    m3: 0.0,
    m4: cz * sy * sx - cx * sz,
    m5: cz * cx + sz * sy * sx,
    m6: cy * sx,
    m7: 0.0,
    m8: sz * sx + cz * cx * sy,
    m9: cx * sz * sy - cz * sx,
    m10: cy * cx,
    m11: 0.0,
    m12: 0.0,
    m13: 0.0,
    m14: 0.0,
    m15: 1.0,
  }
}

///|
pub fn Matrix::scale(x : Float, y : Float, z : Float) -> Matrix {
  {
    m0: x,
    m1: 0.0,
    m2: 0.0,
    m3: 0.0,
    m4: 0.0,
    m5: y,
    m6: 0.0,
    m7: 0.0,
    m8: 0.0,
    m9: 0.0,
    m10: z,
    m11: 0.0,
    m12: 0.0,
    m13: 0.0,
    m14: 0.0,
    m15: 1.0,
  }
}

///|
pub fn Matrix::frustum(
  left : Double,
  right : Double,
  bottom : Double,
  top : Double,
  near_plane : Double,
  far_plane : Double,
) -> Matrix {
  let rl = Float::from_double(right - left)
  let tb = Float::from_double(top - bottom)
  let fn_ = Float::from_double(far_plane - near_plane)
  let near_f = Float::from_double(near_plane)
  let far_f = Float::from_double(far_plane)
  let left_f = Float::from_double(left)
  let right_f = Float::from_double(right)
  let top_f = Float::from_double(top)
  let bottom_f = Float::from_double(bottom)
  {
    m0: near_f * 2.0 / rl,
    m1: 0.0,
    m2: 0.0,
    m3: 0.0,
    m4: 0.0,
    m5: near_f * 2.0 / tb,
    m6: 0.0,
    m7: 0.0,
    m8: (right_f + left_f) / rl,
    m9: (top_f + bottom_f) / tb,
    m10: -(far_f + near_f) / fn_,
    m11: -1.0,
    m12: 0.0,
    m13: 0.0,
    m14: -(far_f * near_f * 2.0) / fn_,
    m15: 0.0,
  }
}

///|
pub fn Matrix::perspective(
  fov_y : Double,
  aspect : Double,
  near_plane : Double,
  far_plane : Double,
) -> Matrix {
  let top = near_plane * @math.tan(fov_y * 0.5)
  let bottom = -top
  let right = top * aspect
  let left = -right
  let rl = Float::from_double(right - left)
  let tb = Float::from_double(top - bottom)
  let fn_ = Float::from_double(far_plane - near_plane)
  let near_f = Float::from_double(near_plane)
  let far_f = Float::from_double(far_plane)
  let left_f = Float::from_double(left)
  let right_f = Float::from_double(right)
  let top_f = Float::from_double(top)
  let bottom_f = Float::from_double(bottom)
  {
    m0: near_f * 2.0 / rl,
    m1: 0.0,
    m2: 0.0,
    m3: 0.0,
    m4: 0.0,
    m5: near_f * 2.0 / tb,
    m6: 0.0,
    m7: 0.0,
    m8: (right_f + left_f) / rl,
    m9: (top_f + bottom_f) / tb,
    m10: -(far_f + near_f) / fn_,
    m11: -1.0,
    m12: 0.0,
    m13: 0.0,
    m14: -(far_f * near_f * 2.0) / fn_,
    m15: 0.0,
  }
}

///|
pub fn Matrix::ortho(
  left : Double,
  right : Double,
  bottom : Double,
  top : Double,
  near_plane : Double,
  far_plane : Double,
) -> Matrix {
  let rl = Float::from_double(right - left)
  let tb = Float::from_double(top - bottom)
  let fn_ = Float::from_double(far_plane - near_plane)
  let left_f = Float::from_double(left)
  let right_f = Float::from_double(right)
  let top_f = Float::from_double(top)
  let bottom_f = Float::from_double(bottom)
  let near_f = Float::from_double(near_plane)
  let far_f = Float::from_double(far_plane)
  {
    m0: 2.0 / rl,
    m1: 0.0,
    m2: 0.0,
    m3: 0.0,
    m4: 0.0,
    m5: 2.0 / tb,
    m6: 0.0,
    m7: 0.0,
    m8: 0.0,
    m9: 0.0,
    m10: -2.0 / fn_,
    m11: 0.0,
    m12: -(left_f + right_f) / rl,
    m13: -(top_f + bottom_f) / tb,
    m14: -(far_f + near_f) / fn_,
    m15: 1.0,
  }
}

///|
pub fn Matrix::look_at(eye : Vector3, target : Vector3, up : Vector3) -> Matrix {
  // Vector3Subtract(eye, target)
  let mut vz_x = eye.x - target.x
  let mut vz_y = eye.y - target.y
  let mut vz_z = eye.z - target.z
  // Vector3Normalize(vz)
  let mut length = sqrtf(vz_x * vz_x + vz_y * vz_y + vz_z * vz_z)
  if length == 0.0 {
    length = 1.0
  }
  let mut ilength : Float = (1.0 : Float) / length
  vz_x *= ilength
  vz_y *= ilength
  vz_z *= ilength
  // Vector3CrossProduct(up, vz)
  let mut vx_x = up.y * vz_z - up.z * vz_y
  let mut vx_y = up.z * vz_x - up.x * vz_z
  let mut vx_z = up.x * vz_y - up.y * vz_x
  // Vector3Normalize(vx)
  length = sqrtf(vx_x * vx_x + vx_y * vx_y + vx_z * vx_z)
  if length == 0.0 {
    length = 1.0
  }
  ilength = (1.0 : Float) / length
  vx_x *= ilength
  vx_y *= ilength
  vx_z *= ilength
  // Vector3CrossProduct(vz, vx)
  let vy_x = vz_y * vx_z - vz_z * vx_y
  let vy_y = vz_z * vx_x - vz_x * vx_z
  let vy_z = vz_x * vx_y - vz_y * vx_x
  {
    m0: vx_x,
    m1: vy_x,
    m2: vz_x,
    m3: 0.0,
    m4: vx_y,
    m5: vy_y,
    m6: vz_y,
    m7: 0.0,
    m8: vx_z,
    m9: vy_z,
    m10: vz_z,
    m11: 0.0,
    m12: -(vx_x * eye.x + vx_y * eye.y + vx_z * eye.z),
    m13: -(vy_x * eye.x + vy_y * eye.y + vy_z * eye.z),
    m14: -(vz_x * eye.x + vz_y * eye.y + vz_z * eye.z),
    m15: 1.0,
  }
}

///|
pub fn Matrix::decompose(mat : Matrix) -> (Vector3, Vector4, Vector3) {
  // Extract translation
  let translation : Vector3 = { x: mat.m12, y: mat.m13, z: mat.m14 }
  // Extract upper-left for determinant computation
  let a = mat.m0
  let b = mat.m4
  let c = mat.m8
  let d = mat.m1
  let e = mat.m5
  let f = mat.m9
  let g = mat.m2
  let h = mat.m6
  let i = mat.m10
  let big_a = e * i - f * h
  let big_b = f * g - d * i
  let big_c = d * h - e * g
  // Extract scale
  let det = a * big_a + b * big_b + c * big_c
  let scalex = sqrtf(a * a + b * b + c * c)
  let scaley = sqrtf(d * d + e * e + f * f)
  let scalez = sqrtf(g * g + h * h + i * i)
  let s : Vector3 = if det < 0.0 {
    { x: -scalex, y: -scaley, z: -scalez }
  } else {
    { x: scalex, y: scaley, z: scalez }
  }
  // Remove scale from the matrix if it is not close to zero
  let rotation : Vector4 = if not(float_equals(det, 0.0)) {
    let clone : Matrix = {
      m0: mat.m0 / s.x,
      m1: mat.m1 / s.y,
      m2: mat.m2 / s.z,
      m3: mat.m3,
      m4: mat.m4 / s.x,
      m5: mat.m5 / s.y,
      m6: mat.m6 / s.z,
      m7: mat.m7,
      m8: mat.m8 / s.x,
      m9: mat.m9 / s.y,
      m10: mat.m10 / s.z,
      m11: mat.m11,
      m12: mat.m12,
      m13: mat.m13,
      m14: mat.m14,
      m15: mat.m15,
    }
    // QuaternionFromMatrix
    quaternion_from_matrix(clone)
  } else {
    // QuaternionIdentity
    { x: 0.0, y: 0.0, z: 0.0, w: 1.0 }
  }
  (translation, rotation, s)
}

// Helper: extract quaternion from a rotation matrix (QuaternionFromMatrix)

///|
fn quaternion_from_matrix(mat : Matrix) -> Vector4 {
  let four_w_sq_m1 = mat.m0 + mat.m5 + mat.m10
  let four_x_sq_m1 = mat.m0 - mat.m5 - mat.m10
  let four_y_sq_m1 = mat.m5 - mat.m0 - mat.m10
  let four_z_sq_m1 = mat.m10 - mat.m0 - mat.m5
  let mut biggest_index = 0
  let mut four_biggest_sq_m1 = four_w_sq_m1
  if four_x_sq_m1 > four_biggest_sq_m1 {
    four_biggest_sq_m1 = four_x_sq_m1
    biggest_index = 1
  }
  if four_y_sq_m1 > four_biggest_sq_m1 {
    four_biggest_sq_m1 = four_y_sq_m1
    biggest_index = 2
  }
  if four_z_sq_m1 > four_biggest_sq_m1 {
    four_biggest_sq_m1 = four_z_sq_m1
    biggest_index = 3
  }
  let biggest_val = sqrtf(four_biggest_sq_m1 + 1.0) * 0.5
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
