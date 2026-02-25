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
  let buf = @buffer.new(size_hint=24)
  buf.write_float_le(r.position.x)
  buf.write_float_le(r.position.y)
  buf.write_float_le(r.position.z)
  buf.write_float_le(r.direction.x)
  buf.write_float_le(r.direction.y)
  buf.write_float_le(r.direction.z)
  buf.to_bytes()
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
  let buf = @buffer.new(size_hint=24)
  buf.write_float_le(bb.min.x)
  buf.write_float_le(bb.min.y)
  buf.write_float_le(bb.min.z)
  buf.write_float_le(bb.max.x)
  buf.write_float_le(bb.max.y)
  buf.write_float_le(bb.max.z)
  buf.to_bytes()
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
pub fn RayCollision::new(
  hit : Bool,
  distance : Float,
  point : Vector3,
  normal : Vector3,
) -> RayCollision {
  { hit, distance, point, normal }
}

///|
pub fn RayCollision::from_bytes(b : Bytes) -> RayCollision {
  {
    hit: b[0] != b'\x00',
    distance: read_float(b, 4),
    point: { x: read_float(b, 8), y: read_float(b, 12), z: read_float(b, 16) },
    normal: { x: read_float(b, 20), y: read_float(b, 24), z: read_float(b, 28) },
  }
}
