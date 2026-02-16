// Scalar math utilities and Vector2 math functions
// Ported from raymath.h (raylib 5.5)
// Private math helpers are in math_helpers.mbt

// ----- Scalar math functions -----

///|
pub fn clamp(value : Float, min : Float, max : Float) -> Float {
  let result = if value < min { min } else { value }
  if result > max {
    max
  } else {
    result
  }
}

///|
pub fn lerp(start : Float, end_ : Float, amount : Float) -> Float {
  start + amount * (end_ - start)
}

///|
pub fn normalize(value : Float, start : Float, end_ : Float) -> Float {
  (value - start) / (end_ - start)
}

///|
pub fn remap(
  value : Float,
  input_start : Float,
  input_end : Float,
  output_start : Float,
  output_end : Float,
) -> Float {
  (value - input_start) /
  (input_end - input_start) *
  (output_end - output_start) +
  output_start
}

///|
pub fn wrap(value : Float, min : Float, max : Float) -> Float {
  let range = max - min
  value - range * floorf((value - min) / range)
}

///|
pub fn float_equals(x : Float, y : Float) -> Bool {
  let epsilon : Float = 0.000001
  absf(x - y) <= epsilon * fmaxf((1.0 : Float), fmaxf(absf(x), absf(y)))
}

// ----- Vector2 math functions -----

///|
pub fn Vector2::zero() -> Vector2 {
  { x: 0.0, y: 0.0 }
}

///|
pub fn Vector2::one() -> Vector2 {
  { x: 1.0, y: 1.0 }
}

///|
pub fn Vector2::add(v1 : Vector2, v2 : Vector2) -> Vector2 {
  { x: v1.x + v2.x, y: v1.y + v2.y }
}

///|
pub fn Vector2::add_value(v : Vector2, add : Float) -> Vector2 {
  { x: v.x + add, y: v.y + add }
}

///|
pub fn Vector2::subtract(v1 : Vector2, v2 : Vector2) -> Vector2 {
  { x: v1.x - v2.x, y: v1.y - v2.y }
}

///|
pub fn Vector2::subtract_value(v : Vector2, sub : Float) -> Vector2 {
  { x: v.x - sub, y: v.y - sub }
}

///|
pub fn Vector2::length(v : Vector2) -> Float {
  sqrtf(v.x * v.x + v.y * v.y)
}

///|
pub fn Vector2::length_sqr(v : Vector2) -> Float {
  v.x * v.x + v.y * v.y
}

///|
pub fn Vector2::dot_product(v1 : Vector2, v2 : Vector2) -> Float {
  v1.x * v2.x + v1.y * v2.y
}

///|
pub fn Vector2::distance(v1 : Vector2, v2 : Vector2) -> Float {
  let dx = v1.x - v2.x
  let dy = v1.y - v2.y
  sqrtf(dx * dx + dy * dy)
}

///|
pub fn Vector2::distance_sqr(v1 : Vector2, v2 : Vector2) -> Float {
  let dx = v1.x - v2.x
  let dy = v1.y - v2.y
  dx * dx + dy * dy
}

///|
pub fn Vector2::angle(v1 : Vector2, v2 : Vector2) -> Float {
  let dot = v1.x * v2.x + v1.y * v2.y
  let det = v1.x * v2.y - v1.y * v2.x
  atan2f(det, dot)
}

///|
pub fn Vector2::line_angle(start : Vector2, end_ : Vector2) -> Float {
  -atan2f(end_.y - start.y, end_.x - start.x)
}

///|
pub fn Vector2::scale(v : Vector2, scale : Float) -> Vector2 {
  { x: v.x * scale, y: v.y * scale }
}

///|
pub fn Vector2::multiply(v1 : Vector2, v2 : Vector2) -> Vector2 {
  { x: v1.x * v2.x, y: v1.y * v2.y }
}

///|
pub fn Vector2::negate(v : Vector2) -> Vector2 {
  { x: -v.x, y: -v.y }
}

///|
pub fn Vector2::divide(v1 : Vector2, v2 : Vector2) -> Vector2 {
  { x: v1.x / v2.x, y: v1.y / v2.y }
}

///|
pub fn Vector2::normalize(v : Vector2) -> Vector2 {
  let len = sqrtf(v.x * v.x + v.y * v.y)
  if len > 0.0 {
    let ilength : Float = (1.0 : Float) / len
    { x: v.x * ilength, y: v.y * ilength }
  } else {
    { x: 0.0, y: 0.0 }
  }
}

///|
pub fn Vector2::transform(v : Vector2, mat : Matrix) -> Vector2 {
  let x = v.x
  let y = v.y
  { x: mat.m0 * x + mat.m4 * y + mat.m12, y: mat.m1 * x + mat.m5 * y + mat.m13 }
}

///|
pub fn Vector2::lerp(v1 : Vector2, v2 : Vector2, amount : Float) -> Vector2 {
  { x: v1.x + amount * (v2.x - v1.x), y: v1.y + amount * (v2.y - v1.y) }
}

///|
pub fn Vector2::reflect(v : Vector2, normal : Vector2) -> Vector2 {
  let dot = v.x * normal.x + v.y * normal.y
  let two : Float = 2.0
  { x: v.x - two * normal.x * dot, y: v.y - two * normal.y * dot }
}

///|
pub fn Vector2::min(v1 : Vector2, v2 : Vector2) -> Vector2 {
  { x: fminf(v1.x, v2.x), y: fminf(v1.y, v2.y) }
}

///|
pub fn Vector2::max(v1 : Vector2, v2 : Vector2) -> Vector2 {
  { x: fmaxf(v1.x, v2.x), y: fmaxf(v1.y, v2.y) }
}

///|
pub fn Vector2::rotate(v : Vector2, angle : Float) -> Vector2 {
  let c = cosf(angle)
  let s = sinf(angle)
  { x: v.x * c - v.y * s, y: v.x * s + v.y * c }
}

///|
pub fn Vector2::move_towards(
  v : Vector2,
  target : Vector2,
  max_distance : Float,
) -> Vector2 {
  let dx = target.x - v.x
  let dy = target.y - v.y
  let value = dx * dx + dy * dy
  if value == 0.0 ||
    (max_distance >= 0.0 && value <= max_distance * max_distance) {
    return target
  }
  let dist = sqrtf(value)
  { x: v.x + dx / dist * max_distance, y: v.y + dy / dist * max_distance }
}

///|
pub fn Vector2::invert(v : Vector2) -> Vector2 {
  { x: (1.0 : Float) / v.x, y: (1.0 : Float) / v.y }
}

///|
pub fn Vector2::clamp(v : Vector2, min : Vector2, max : Vector2) -> Vector2 {
  { x: fminf(max.x, fmaxf(min.x, v.x)), y: fminf(max.y, fmaxf(min.y, v.y)) }
}

///|
pub fn Vector2::clamp_value(v : Vector2, min : Float, max : Float) -> Vector2 {
  let length = v.x * v.x + v.y * v.y
  if length > 0.0 {
    let len = sqrtf(length)
    let s : Float = if len < min {
      min / len
    } else if len > max {
      max / len
    } else {
      1.0
    }
    { x: v.x * s, y: v.y * s }
  } else {
    v
  }
}

///|
pub fn Vector2::equals(p : Vector2, q : Vector2) -> Bool {
  let epsilon : Float = 0.000001
  let one : Float = 1.0
  absf(p.x - q.x) <= epsilon * fmaxf(one, fmaxf(absf(p.x), absf(q.x))) &&
  absf(p.y - q.y) <= epsilon * fmaxf(one, fmaxf(absf(p.y), absf(q.y)))
}

///|
pub fn Vector2::refract(v : Vector2, n : Vector2, r : Float) -> Vector2 {
  let dot = v.x * n.x + v.y * n.y
  let one : Float = 1.0
  let d = one - r * r * (one - dot * dot)
  if d >= 0.0 {
    let sd = sqrtf(d)
    let factor = r * dot + sd
    { x: r * v.x - factor * n.x, y: r * v.y - factor * n.y }
  } else {
    { x: 0.0, y: 0.0 }
  }
}
