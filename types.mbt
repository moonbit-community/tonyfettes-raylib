// Helper: write float as 4 little-endian bytes

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

// Helper: read float from Bytes at offset (little-endian)

///|
fn read_float(b : Bytes, off : Int) -> Float {
  let bits = b[off].to_int() |
    (b[off + 1].to_int() << 8) |
    (b[off + 2].to_int() << 16) |
    (b[off + 3].to_int() << 24)
  Float::reinterpret_from_int(bits)
}

// Helper: write int as 4 little-endian bytes

///|
fn write_int(value : Int) -> (Byte, Byte, Byte, Byte) {
  (
    (value & 0xFF).to_byte(),
    ((value >> 8) & 0xFF).to_byte(),
    ((value >> 16) & 0xFF).to_byte(),
    ((value >> 24) & 0xFF).to_byte(),
  )
}

// Helper: read int from Bytes at offset (little-endian)

///|
fn read_int(b : Bytes, off : Int) -> Int {
  b[off].to_int() |
  (b[off + 1].to_int() << 8) |
  (b[off + 2].to_int() << 16) |
  (b[off + 3].to_int() << 24)
}

// Color: 4 bytes (r, g, b, a)

///|
pub struct Color {
  r : Byte
  g : Byte
  b : Byte
  a : Byte
} derive(Eq, Show)

///|
pub fn Color::new(r : Int, g : Int, b : Int, a : Int) -> Color {
  { r: r.to_byte(), g: g.to_byte(), b: b.to_byte(), a: a.to_byte() }
}

///|
pub fn Color::to_bytes(color : Color) -> Bytes {
  [color.r, color.g, color.b, color.a]
}

///|
pub fn Color::from_bytes(b : Bytes) -> Color {
  { r: b[0], g: b[1], b: b[2], a: b[3] }
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

// Camera2D: 24 bytes (offset, target as Vector2; rotation, zoom as float)

///|
pub struct Camera2D {
  offset : Vector2
  target : Vector2
  rotation : Float
  zoom : Float
} derive(Eq, Show)

///|
pub fn Camera2D::new(
  offset : Vector2,
  target : Vector2,
  rotation : Float,
  zoom : Float,
) -> Camera2D {
  { offset, target, rotation, zoom }
}

///|
pub fn Camera2D::to_bytes(c : Camera2D) -> Bytes {
  let (a0, a1, a2, a3) = write_float(c.offset.x)
  let (a4, a5, a6, a7) = write_float(c.offset.y)
  let (b0, b1, b2, b3) = write_float(c.target.x)
  let (b4, b5, b6, b7) = write_float(c.target.y)
  let (c0, c1, c2, c3) = write_float(c.rotation)
  let (d0, d1, d2, d3) = write_float(c.zoom)
  [
    a0, a1, a2, a3, a4, a5, a6, a7, b0, b1, b2, b3, b4, b5, b6, b7, c0, c1, c2, c3,
    d0, d1, d2, d3,
  ]
}

///|
pub fn Camera2D::from_bytes(b : Bytes) -> Camera2D {
  {
    offset: { x: read_float(b, 0), y: read_float(b, 4) },
    target: { x: read_float(b, 8), y: read_float(b, 12) },
    rotation: read_float(b, 16),
    zoom: read_float(b, 20),
  }
}

// Camera3D: 44 bytes (position, target, up as Vector3; fovy as float; projection as int)

///|
pub struct Camera3D {
  position : Vector3
  target : Vector3
  up : Vector3
  fovy : Float
  projection : Int
} derive(Eq, Show)

///|
pub fn Camera3D::new(
  position : Vector3,
  target : Vector3,
  up : Vector3,
  fovy : Float,
  projection : Int,
) -> Camera3D {
  { position, target, up, fovy, projection }
}

///|
pub fn Camera3D::to_bytes(c : Camera3D) -> Bytes {
  let (a0, a1, a2, a3) = write_float(c.position.x)
  let (a4, a5, a6, a7) = write_float(c.position.y)
  let (a8, a9, aa, ab) = write_float(c.position.z)
  let (b0, b1, b2, b3) = write_float(c.target.x)
  let (b4, b5, b6, b7) = write_float(c.target.y)
  let (b8, b9, ba, bb) = write_float(c.target.z)
  let (c0, c1, c2, c3) = write_float(c.up.x)
  let (c4, c5, c6, c7) = write_float(c.up.y)
  let (c8, c9, ca, cb) = write_float(c.up.z)
  let (d0, d1, d2, d3) = write_float(c.fovy)
  let (e0, e1, e2, e3) = write_int(c.projection)
  [
    a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, aa, ab, b0, b1, b2, b3, b4, b5, b6, b7,
    b8, b9, ba, bb, c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, ca, cb, d0, d1, d2, d3,
    e0, e1, e2, e3,
  ]
}

///|
pub fn Camera3D::from_bytes(b : Bytes) -> Camera3D {
  {
    position: { x: read_float(b, 0), y: read_float(b, 4), z: read_float(b, 8) },
    target: { x: read_float(b, 12), y: read_float(b, 16), z: read_float(b, 20) },
    up: { x: read_float(b, 24), y: read_float(b, 28), z: read_float(b, 32) },
    fovy: read_float(b, 36),
    projection: read_int(b, 40),
  }
}

// Ray: 24 bytes (position, direction as Vector3)

///|
pub struct Ray {
  position : Vector3
  direction : Vector3
} derive(Eq, Show)

///|
pub fn Ray::new(position : Vector3, direction : Vector3) -> Ray {
  { position, direction }
}

///|
pub fn Ray::to_bytes(r : Ray) -> Bytes {
  let (a0, a1, a2, a3) = write_float(r.position.x)
  let (a4, a5, a6, a7) = write_float(r.position.y)
  let (a8, a9, aa, ab) = write_float(r.position.z)
  let (b0, b1, b2, b3) = write_float(r.direction.x)
  let (b4, b5, b6, b7) = write_float(r.direction.y)
  let (b8, b9, ba, bb) = write_float(r.direction.z)
  [
    a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, aa, ab, b0, b1, b2, b3, b4, b5, b6, b7,
    b8, b9, ba, bb,
  ]
}

///|
pub fn Ray::from_bytes(b : Bytes) -> Ray {
  {
    position: { x: read_float(b, 0), y: read_float(b, 4), z: read_float(b, 8) },
    direction: {
      x: read_float(b, 12),
      y: read_float(b, 16),
      z: read_float(b, 20),
    },
  }
}

// BoundingBox: 24 bytes (min, max as Vector3)

///|
pub struct BoundingBox {
  min : Vector3
  max : Vector3
} derive(Eq, Show)

///|
pub fn BoundingBox::new(min : Vector3, max : Vector3) -> BoundingBox {
  { min, max }
}

///|
pub fn BoundingBox::to_bytes(bb : BoundingBox) -> Bytes {
  let (a0, a1, a2, a3) = write_float(bb.min.x)
  let (a4, a5, a6, a7) = write_float(bb.min.y)
  let (a8, a9, aa, ab) = write_float(bb.min.z)
  let (b0, b1, b2, b3) = write_float(bb.max.x)
  let (b4, b5, b6, b7) = write_float(bb.max.y)
  let (b8, b9, ba, bb_) = write_float(bb.max.z)
  [
    a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, aa, ab, b0, b1, b2, b3, b4, b5, b6, b7,
    b8, b9, ba, bb_,
  ]
}

///|
pub fn BoundingBox::from_bytes(b : Bytes) -> BoundingBox {
  {
    min: { x: read_float(b, 0), y: read_float(b, 4), z: read_float(b, 8) },
    max: { x: read_float(b, 12), y: read_float(b, 16), z: read_float(b, 20) },
  }
}

// RayCollision: 32 bytes (hit as int32, distance as float, point and normal as Vector3)
// C layout: bool(1) + pad(3) + float + Vector3 + Vector3 = 32 bytes

///|
pub struct RayCollision {
  hit : Bool
  distance : Float
  point : Vector3
  normal : Vector3
} derive(Eq, Show)

///|
pub fn RayCollision::from_bytes(b : Bytes) -> RayCollision {
  {
    hit: b[0] != b'\x00',
    distance: read_float(b, 4),
    point: { x: read_float(b, 8), y: read_float(b, 12), z: read_float(b, 16) },
    normal: { x: read_float(b, 20), y: read_float(b, 24), z: read_float(b, 28) },
  }
}

// Resource types (opaque, backed by C external objects with GC finalizers)

///|
pub type Image

///|
pub type Texture

///|
pub type RenderTexture

///|
pub type Font

///|
pub type Sound

///|
pub type Music

///|
pub type Model

///|
pub type Shader
