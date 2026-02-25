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
  let buf = @buffer.new(size_hint=36)
  buf.write_float_le(n.source.x)
  buf.write_float_le(n.source.y)
  buf.write_float_le(n.source.width)
  buf.write_float_le(n.source.height)
  buf.write_int_le(n.left)
  buf.write_int_le(n.top)
  buf.write_int_le(n.right)
  buf.write_int_le(n.bottom)
  buf.write_int_le(n.layout)
  buf.to_bytes()
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
pub const NpatchNinePatch : Int = 0

///|
pub const NpatchThreePatchVertical : Int = 1

///|
pub const NpatchThreePatchHorizontal : Int = 2
