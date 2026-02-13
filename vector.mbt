// Private byte helpers used by all value types

///|
fn write_float(value : Float) -> (Byte, Byte, Byte, Byte) {
  let bits = value.reinterpret_as_int()
  (
    (bits & 0xFF).to_byte(),
    ((bits >> 8) & 0xFF).to_byte(),
    ((bits >> 16) & 0xFF).to_byte(),
    ((bits >> 24) & 0xFF).to_byte(),
  )
}

///|
fn read_float(b : Bytes, off : Int) -> Float {
  let bits = b[off].to_int() |
    (b[off + 1].to_int() << 8) |
    (b[off + 2].to_int() << 16) |
    (b[off + 3].to_int() << 24)
  Float::reinterpret_from_int(bits)
}

///|
fn write_int(value : Int) -> (Byte, Byte, Byte, Byte) {
  (
    (value & 0xFF).to_byte(),
    ((value >> 8) & 0xFF).to_byte(),
    ((value >> 16) & 0xFF).to_byte(),
    ((value >> 24) & 0xFF).to_byte(),
  )
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
  let (x0, x1, x2, x3) = write_float(v.x)
  let (y0, y1, y2, y3) = write_float(v.y)
  [x0, x1, x2, x3, y0, y1, y2, y3]
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
  let (x0, x1, x2, x3) = write_float(v.x)
  let (y0, y1, y2, y3) = write_float(v.y)
  let (z0, z1, z2, z3) = write_float(v.z)
  [x0, x1, x2, x3, y0, y1, y2, y3, z0, z1, z2, z3]
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
  let (x0, x1, x2, x3) = write_float(v.x)
  let (y0, y1, y2, y3) = write_float(v.y)
  let (z0, z1, z2, z3) = write_float(v.z)
  let (w0, w1, w2, w3) = write_float(v.w)
  [x0, x1, x2, x3, y0, y1, y2, y3, z0, z1, z2, z3, w0, w1, w2, w3]
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
