// Private byte helpers used by all value types

///|
fn read_float(b : Bytes, off : Int) -> Float {
  let bits = b[off].to_int() |
    (b[off + 1].to_int() << 8) |
    (b[off + 2].to_int() << 16) |
    (b[off + 3].to_int() << 24)
  Float::reinterpret_from_int(bits)
}

///|
fn read_int(b : Bytes, off : Int) -> Int {
  b[off].to_int() |
  (b[off + 1].to_int() << 8) |
  (b[off + 2].to_int() << 16) |
  (b[off + 3].to_int() << 24)
}

// Vector2: 8 bytes (x, y as float)

///|
pub struct Vector2 {
  x : Float
  y : Float
} derive(Eq, Show)

///|
pub fn Vector2::new(x : Float, y : Float) -> Vector2 {
  { x, y }
}

///|
pub fn Vector2::to_bytes(v : Vector2) -> Bytes {
  let buf = @buffer.new(size_hint=8)
  buf.write_float_le(v.x)
  buf.write_float_le(v.y)
  buf.to_bytes()
}

///|
pub fn Vector2::from_bytes(b : Bytes) -> Vector2 {
  { x: read_float(b, 0), y: read_float(b, 4) }
}

// Vector3: 12 bytes (x, y, z as float)

///|
pub struct Vector3 {
  x : Float
  y : Float
  z : Float
} derive(Eq, Show)

///|
pub fn Vector3::new(x : Float, y : Float, z : Float) -> Vector3 {
  { x, y, z }
}

///|
pub fn Vector3::to_bytes(v : Vector3) -> Bytes {
  let buf = @buffer.new(size_hint=12)
  buf.write_float_le(v.x)
  buf.write_float_le(v.y)
  buf.write_float_le(v.z)
  buf.to_bytes()
}

///|
pub fn Vector3::from_bytes(b : Bytes) -> Vector3 {
  { x: read_float(b, 0), y: read_float(b, 4), z: read_float(b, 8) }
}

// Vector4: 16 bytes (x, y, z, w as float)

///|
pub struct Vector4 {
  x : Float
  y : Float
  z : Float
  w : Float
} derive(Eq, Show)

///|
pub fn Vector4::new(x : Float, y : Float, z : Float, w : Float) -> Vector4 {
  { x, y, z, w }
}

///|
pub fn Vector4::to_bytes(v : Vector4) -> Bytes {
  let buf = @buffer.new(size_hint=16)
  buf.write_float_le(v.x)
  buf.write_float_le(v.y)
  buf.write_float_le(v.z)
  buf.write_float_le(v.w)
  buf.to_bytes()
}

///|
pub fn Vector4::from_bytes(b : Bytes) -> Vector4 {
  {
    x: read_float(b, 0),
    y: read_float(b, 4),
    z: read_float(b, 8),
    w: read_float(b, 12),
  }
}
