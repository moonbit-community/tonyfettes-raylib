// Rectangle: 16 bytes (x, y, width, height as float)

///|
pub struct Rectangle {
  x : Float
  y : Float
  width : Float
  height : Float
} derive(Eq, Show)

///|
pub fn Rectangle::new(
  x : Float,
  y : Float,
  width : Float,
  height : Float,
) -> Rectangle {
  { x, y, width, height }
}

///|
pub fn Rectangle::to_bytes(r : Rectangle) -> Bytes {
  let buf = @buffer.new(size_hint=16)
  buf.write_float_le(r.x)
  buf.write_float_le(r.y)
  buf.write_float_le(r.width)
  buf.write_float_le(r.height)
  buf.to_bytes()
}

///|
pub fn Rectangle::from_bytes(b : Bytes) -> Rectangle {
  {
    x: read_float(b, 0),
    y: read_float(b, 4),
    width: read_float(b, 8),
    height: read_float(b, 12),
  }
}
