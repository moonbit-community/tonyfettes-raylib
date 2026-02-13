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
  let (x0, x1, x2, x3) = write_float(r.x)
  let (y0, y1, y2, y3) = write_float(r.y)
  let (w0, w1, w2, w3) = write_float(r.width)
  let (h0, h1, h2, h3) = write_float(r.height)
  [x0, x1, x2, x3, y0, y1, y2, y3, w0, w1, w2, w3, h0, h1, h2, h3]
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
