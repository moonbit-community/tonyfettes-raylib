///|
test "Vector2::zero returns (0, 0)" {
  let v = @raylib.Vector2::zero()
  assert_eq(v, @raylib.Vector2::new(0.0, 0.0))
}

///|
test "Vector2::one returns (1, 1)" {
  let v = @raylib.Vector2::one()
  assert_eq(v, @raylib.Vector2::new(1.0, 1.0))
}

///|
test "Vector2::add sums two vectors" {
  let v1 = @raylib.Vector2::new(3.0, 4.0)
  let v2 = @raylib.Vector2::new(1.0, 2.0)
  let result = @raylib.Vector2::add(v1, v2)
  assert_eq(result, @raylib.Vector2::new(4.0, 6.0))
}

///|
test "Vector2::add_value adds scalar to both components" {
  let v = @raylib.Vector2::new(3.0, 4.0)
  let result = @raylib.Vector2::add_value(v, 5.0)
  assert_eq(result, @raylib.Vector2::new(8.0, 9.0))
}

///|
test "Vector2::subtract subtracts two vectors" {
  let v1 = @raylib.Vector2::new(5.0, 7.0)
  let v2 = @raylib.Vector2::new(2.0, 3.0)
  let result = @raylib.Vector2::subtract(v1, v2)
  assert_eq(result, @raylib.Vector2::new(3.0, 4.0))
}

///|
test "Vector2::subtract_value subtracts scalar from both components" {
  let v = @raylib.Vector2::new(10.0, 20.0)
  let result = @raylib.Vector2::subtract_value(v, 3.0)
  assert_eq(result, @raylib.Vector2::new(7.0, 17.0))
}

///|
test "Vector2::length computes magnitude" {
  let v = @raylib.Vector2::new(3.0, 4.0)
  let len = @raylib.Vector2::length(v)
  assert_true((len - 5.0).abs() < 0.001)
}

///|
test "Vector2::length_sqr computes squared magnitude" {
  let v = @raylib.Vector2::new(3.0, 4.0)
  let len_sq = @raylib.Vector2::length_sqr(v)
  assert_true((len_sq - 25.0).abs() < 0.001)
}

///|
test "Vector2::dot_product computes dot product" {
  let v1 = @raylib.Vector2::new(2.0, 3.0)
  let v2 = @raylib.Vector2::new(4.0, 5.0)
  let dot = @raylib.Vector2::dot_product(v1, v2)
  // 2*4 + 3*5 = 8 + 15 = 23
  assert_true((dot - 23.0).abs() < 0.001)
}

///|
test "Vector2::distance computes Euclidean distance" {
  let v1 = @raylib.Vector2::new(1.0, 2.0)
  let v2 = @raylib.Vector2::new(4.0, 6.0)
  let dist = @raylib.Vector2::distance(v1, v2)
  // sqrt(9 + 16) = 5
  assert_true((dist - 5.0).abs() < 0.001)
}

///|
test "Vector2::distance_sqr computes squared distance" {
  let v1 = @raylib.Vector2::new(1.0, 2.0)
  let v2 = @raylib.Vector2::new(4.0, 6.0)
  let dist_sq = @raylib.Vector2::distance_sqr(v1, v2)
  // 9 + 16 = 25
  assert_true((dist_sq - 25.0).abs() < 0.001)
}

///|
test "Vector2::angle computes angle between two vectors" {
  let v1 = @raylib.Vector2::new(1.0, 0.0)
  let v2 = @raylib.Vector2::new(0.0, 1.0)
  let angle = @raylib.Vector2::angle(v1, v2)
  let pi : Float = 3.14159265358979323846
  // Angle from (1,0) to (0,1) should be pi/2
  assert_true((angle - pi / 2.0).abs() < 0.001)
}

///|
test "Vector2::line_angle computes angle of a line segment" {
  let start = @raylib.Vector2::new(0.0, 0.0)
  let end_ = @raylib.Vector2::new(1.0, 0.0)
  let angle = @raylib.Vector2::line_angle(start, end_)
  // Line along positive x-axis: -atan2(0, 1) = 0
  assert_true(angle.abs() < 0.001)
}

///|
test "Vector2::scale multiplies vector by scalar" {
  let v = @raylib.Vector2::new(2.0, 3.0)
  let result = @raylib.Vector2::scale(v, 4.0)
  assert_eq(result, @raylib.Vector2::new(8.0, 12.0))
}

///|
test "Vector2::multiply does component-wise multiplication" {
  let v1 = @raylib.Vector2::new(3.0, 5.0)
  let v2 = @raylib.Vector2::new(2.0, 4.0)
  let result = @raylib.Vector2::multiply(v1, v2)
  assert_eq(result, @raylib.Vector2::new(6.0, 20.0))
}

///|
test "Vector2::negate negates both components" {
  let v = @raylib.Vector2::new(3.0, -7.0)
  let result = @raylib.Vector2::negate(v)
  assert_eq(result, @raylib.Vector2::new(-3.0, 7.0))
}

///|
test "Vector2::divide does component-wise division" {
  let v1 = @raylib.Vector2::new(10.0, 20.0)
  let v2 = @raylib.Vector2::new(2.0, 5.0)
  let result = @raylib.Vector2::divide(v1, v2)
  assert_eq(result, @raylib.Vector2::new(5.0, 4.0))
}

///|
test "Vector2::normalize produces unit vector" {
  let v = @raylib.Vector2::new(3.0, 4.0)
  let result = @raylib.Vector2::normalize(v)
  // Expected: (3/5, 4/5) = (0.6, 0.8)
  assert_true((result.x - 0.6).abs() < 0.001)
  assert_true((result.y - 0.8).abs() < 0.001)
}

///|
test "Vector2::normalize zero vector returns zero" {
  let v = @raylib.Vector2::new(0.0, 0.0)
  let result = @raylib.Vector2::normalize(v)
  assert_eq(result, @raylib.Vector2::new(0.0, 0.0))
}

///|
test "Vector2::transform applies matrix transformation" {
  // Non-identity matrix: scale(2,3,1) * translate(10,20,0) gives
  // m0=2, m5=3, m12=10, m13=20
  let mat = @raylib.Matrix::multiply(
    @raylib.Matrix::scale(2.0, 3.0, 1.0),
    @raylib.Matrix::translate(10.0, 20.0, 0.0),
  )
  let v = @raylib.Vector2::new(5.0, 7.0)
  let result = @raylib.Vector2::transform(v, mat)
  // x' = 2*5 + 0*7 + 10 = 20
  // y' = 0*5 + 3*7 + 20 = 41
  assert_true((result.x - 20.0).abs() < 0.001)
  assert_true((result.y - 41.0).abs() < 0.001)
}

///|
test "Vector2::lerp interpolates between two vectors" {
  let v1 = @raylib.Vector2::new(0.0, 0.0)
  let v2 = @raylib.Vector2::new(10.0, 20.0)
  let result = @raylib.Vector2::lerp(v1, v2, 0.25)
  assert_true((result.x - 2.5).abs() < 0.001)
  assert_true((result.y - 5.0).abs() < 0.001)
}

///|
test "Vector2::reflect computes reflection off a surface" {
  // Reflect (1, -1) off a horizontal surface (normal = (0, 1))
  let v = @raylib.Vector2::new(1.0, -1.0)
  let normal = @raylib.Vector2::new(0.0, 1.0)
  let result = @raylib.Vector2::reflect(v, normal)
  // dot = 1*0 + (-1)*1 = -1
  // reflected = (1 - 0, -1 - 2*1*(-1)) = (1, 1)
  assert_true((result.x - 1.0).abs() < 0.001)
  assert_true((result.y - 1.0).abs() < 0.001)
}

///|
test "Vector2::min returns component-wise minimum" {
  let v1 = @raylib.Vector2::new(3.0, 8.0)
  let v2 = @raylib.Vector2::new(5.0, 2.0)
  let result = @raylib.Vector2::min(v1, v2)
  assert_eq(result, @raylib.Vector2::new(3.0, 2.0))
}

///|
test "Vector2::max returns component-wise maximum" {
  let v1 = @raylib.Vector2::new(3.0, 8.0)
  let v2 = @raylib.Vector2::new(5.0, 2.0)
  let result = @raylib.Vector2::max(v1, v2)
  assert_eq(result, @raylib.Vector2::new(5.0, 8.0))
}

///|
test "Vector2::rotate rotates vector by angle" {
  let pi : Float = 3.14159265358979323846
  let v = @raylib.Vector2::new(1.0, 0.0)
  let result = @raylib.Vector2::rotate(v, pi / 2.0)
  // Rotating (1,0) by 90 degrees gives approximately (0,1)
  assert_true(result.x.abs() < 0.001)
  assert_true((result.y - 1.0).abs() < 0.001)
}

///|
test "Vector2::move_towards when far away moves by max_distance" {
  let v = @raylib.Vector2::new(0.0, 0.0)
  let target = @raylib.Vector2::new(10.0, 0.0)
  let result = @raylib.Vector2::move_towards(v, target, 3.0)
  // Should move 3 units along x-axis toward target
  assert_true((result.x - 3.0).abs() < 0.001)
  assert_true(result.y.abs() < 0.001)
}

///|
test "Vector2::move_towards when already close enough snaps to target" {
  let v = @raylib.Vector2::new(9.0, 0.0)
  let target = @raylib.Vector2::new(10.0, 0.0)
  let result = @raylib.Vector2::move_towards(v, target, 5.0)
  // Distance is 1, max_distance is 5, so we snap to target
  assert_eq(result, target)
}

///|
test "Vector2::invert computes reciprocal of each component" {
  let v = @raylib.Vector2::new(2.0, 4.0)
  let result = @raylib.Vector2::invert(v)
  assert_true((result.x - 0.5).abs() < 0.001)
  assert_true((result.y - 0.25).abs() < 0.001)
}

///|
test "Vector2::clamp clamps components between min and max" {
  let v = @raylib.Vector2::new(-5.0, 15.0)
  let min = @raylib.Vector2::new(0.0, 0.0)
  let max = @raylib.Vector2::new(10.0, 10.0)
  let result = @raylib.Vector2::clamp(v, min, max)
  assert_eq(result, @raylib.Vector2::new(0.0, 10.0))
}

///|
test "Vector2::clamp_value within range stays unchanged" {
  let v = @raylib.Vector2::new(3.0, 4.0)
  // length = 5, which is within [2, 10]
  let result = @raylib.Vector2::clamp_value(v, 2.0, 10.0)
  assert_true((result.x - 3.0).abs() < 0.001)
  assert_true((result.y - 4.0).abs() < 0.001)
}

///|
test "Vector2::clamp_value below min scales up" {
  let v = @raylib.Vector2::new(3.0, 4.0)
  // length = 5, min = 10 => scale up to length 10
  let result = @raylib.Vector2::clamp_value(v, 10.0, 20.0)
  let len = @raylib.Vector2::length(result)
  assert_true((len - 10.0).abs() < 0.01)
  // Direction preserved: (3/5*10, 4/5*10) = (6, 8)
  assert_true((result.x - 6.0).abs() < 0.01)
  assert_true((result.y - 8.0).abs() < 0.01)
}

///|
test "Vector2::clamp_value above max scales down" {
  let v = @raylib.Vector2::new(6.0, 8.0)
  // length = 10, max = 5 => scale down to length 5
  let result = @raylib.Vector2::clamp_value(v, 1.0, 5.0)
  let len = @raylib.Vector2::length(result)
  assert_true((len - 5.0).abs() < 0.01)
  // Direction preserved: (6/10*5, 8/10*5) = (3, 4)
  assert_true((result.x - 3.0).abs() < 0.01)
  assert_true((result.y - 4.0).abs() < 0.01)
}

///|
test "Vector2::equals detects nearly-equal vectors" {
  let v1 = @raylib.Vector2::new(1.0, 2.0)
  let v2 = @raylib.Vector2::new(1.0, 2.0)
  assert_true(@raylib.Vector2::equals(v1, v2))
}

///|
test "Vector2::equals detects different vectors" {
  let v1 = @raylib.Vector2::new(1.0, 2.0)
  let v2 = @raylib.Vector2::new(1.0, 3.0)
  assert_false(@raylib.Vector2::equals(v1, v2))
}

///|
test "Vector2::refract normal refraction" {
  // Light entering glass from above: v = (0, -1), n = (0, 1), r = 1/1.5
  let v = @raylib.Vector2::new(0.0, -1.0)
  let n = @raylib.Vector2::new(0.0, 1.0)
  let r : Float = 1.0 / 1.5
  let result = @raylib.Vector2::refract(v, n, r)
  // For perpendicular incidence, refracted ray should go straight through
  // dot = 0*0 + (-1)*1 = -1
  // d = 1 - r^2*(1 - 1) = 1
  // sd = 1, factor = r*(-1) + 1 = 1 - r
  // x = r*0 - (1-r)*0 = 0
  // y = r*(-1) - (1-r)*1 = -r - 1 + r = -1
  assert_true(result.x.abs() < 0.001)
  assert_true((result.y - -1.0).abs() < 0.001)
}

///|
test "Vector2::refract total internal reflection returns zero" {
  // Total internal reflection: high ratio, grazing angle
  // v nearly parallel to surface => dot ~ 0 => d = 1 - r^2*(1 - 0) < 0 for large r
  let v = @raylib.Vector2::new(1.0, 0.0)
  let n = @raylib.Vector2::new(0.0, 1.0)
  let r : Float = 2.0
  let result = @raylib.Vector2::refract(v, n, r)
  // dot = 0, d = 1 - 4*(1 - 0) = -3 < 0 => total internal reflection
  assert_eq(result, @raylib.Vector2::new(0.0, 0.0))
}

///|
test "Vector2::clamp_value zero vector returns unchanged" {
  let v = @raylib.Vector2::new(0.0, 0.0)
  let result = @raylib.Vector2::clamp_value(v, 1.0, 10.0)
  // Zero vector has length 0, so the length == 0 branch returns v unchanged
  assert_eq(result, @raylib.Vector2::new(0.0, 0.0))
}
