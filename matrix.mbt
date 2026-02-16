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
