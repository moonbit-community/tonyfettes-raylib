// NPatchInfo: 36 bytes (source as Rectangle + 5 ints)

///|
pub struct NPatchInfo {
  source : Rectangle
  left : Int
  top : Int
  right : Int
  bottom : Int
  layout : Int
} derive(Eq, Show)

///|
pub fn NPatchInfo::new(
  source : Rectangle,
  left : Int,
  top : Int,
  right : Int,
  bottom : Int,
  layout : Int,
) -> NPatchInfo {
  { source, left, top, right, bottom, layout }
}

///|
pub fn NPatchInfo::to_bytes(n : NPatchInfo) -> Bytes {
  let (a0, a1, a2, a3) = write_float(n.source.x)
  let (a4, a5, a6, a7) = write_float(n.source.y)
  let (a8, a9, aa, ab) = write_float(n.source.width)
  let (ac, ad, ae, af) = write_float(n.source.height)
  let (b0, b1, b2, b3) = write_int(n.left)
  let (b4, b5, b6, b7) = write_int(n.top)
  let (b8, b9, ba, bb) = write_int(n.right)
  let (bc, bd, be, bf) = write_int(n.bottom)
  let (c0, c1, c2, c3) = write_int(n.layout)
  [
    a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, aa, ab, ac, ad, ae, af, b0, b1, b2, b3,
    b4, b5, b6, b7, b8, b9, ba, bb, bc, bd, be, bf, c0, c1, c2, c3,
  ]
}

///|
pub fn NPatchInfo::from_bytes(b : Bytes) -> NPatchInfo {
  {
    source: {
      x: read_float(b, 0),
      y: read_float(b, 4),
      width: read_float(b, 8),
      height: read_float(b, 12),
    },
    left: read_int(b, 16),
    top: read_int(b, 20),
    right: read_int(b, 24),
    bottom: read_int(b, 28),
    layout: read_int(b, 32),
  }
}

// NPatchLayout constants

///|
pub let npatch_nine_patch : Int = 0

///|
pub let npatch_three_patch_vertical : Int = 1

///|
pub let npatch_three_patch_horizontal : Int = 2
