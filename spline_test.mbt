// ============================================================================
// Spline point evaluation tests
// ============================================================================

// --- get_spline_point_linear ---

///|
test "get_spline_point_linear at t=0 returns start" {
  let start = @raylib.Vector2::new(1.0, 2.0)
  let end_ = @raylib.Vector2::new(5.0, 8.0)
  let result = @raylib.get_spline_point_linear(start, end_, 0.0)
  assert_eq(result.x, 1.0)
  assert_eq(result.y, 2.0)
}

///|
test "get_spline_point_linear at t=1 returns end" {
  let start = @raylib.Vector2::new(1.0, 2.0)
  let end_ = @raylib.Vector2::new(5.0, 8.0)
  let result = @raylib.get_spline_point_linear(start, end_, 1.0)
  assert_eq(result.x, 5.0)
  assert_eq(result.y, 8.0)
}

///|
test "get_spline_point_linear at t=0.5 returns midpoint" {
  let start = @raylib.Vector2::new(0.0, 0.0)
  let end_ = @raylib.Vector2::new(10.0, 20.0)
  let result = @raylib.get_spline_point_linear(start, end_, 0.5)
  assert_eq(result.x, 5.0)
  assert_eq(result.y, 10.0)
}

///|
test "get_spline_point_linear at t=0.25" {
  let start = @raylib.Vector2::new(0.0, 0.0)
  let end_ = @raylib.Vector2::new(8.0, 4.0)
  let result = @raylib.get_spline_point_linear(start, end_, 0.25)
  assert_eq(result.x, 2.0)
  assert_eq(result.y, 1.0)
}

// --- get_spline_point_basis ---

///|
test "get_spline_point_basis at t=0" {
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(1.0, 2.0)
  let p3 = @raylib.Vector2::new(3.0, 4.0)
  let p4 = @raylib.Vector2::new(5.0, 6.0)
  let result = @raylib.get_spline_point_basis(p1, p2, p3, p4, 0.0)
  // At t=0: point = (p1 + 4*p2 + p3)/6
  let expected_x : Float = (0.0 + 4.0 * 1.0 + 3.0) / 6.0
  let expected_y : Float = (0.0 + 4.0 * 2.0 + 4.0) / 6.0
  assert_true((result.x - expected_x).abs() < 0.001)
  assert_true((result.y - expected_y).abs() < 0.001)
}

///|
test "get_spline_point_basis at t=1" {
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(1.0, 2.0)
  let p3 = @raylib.Vector2::new(3.0, 4.0)
  let p4 = @raylib.Vector2::new(5.0, 6.0)
  let result = @raylib.get_spline_point_basis(p1, p2, p3, p4, 1.0)
  // At t=1: a3 + a2 + a1 + a0 = (p2 + 4*p3 + p4)/6
  let expected_x : Float = (1.0 + 4.0 * 3.0 + 5.0) / 6.0
  let expected_y : Float = (2.0 + 4.0 * 4.0 + 6.0) / 6.0
  assert_true((result.x - expected_x).abs() < 0.001)
  assert_true((result.y - expected_y).abs() < 0.001)
}

///|
test "get_spline_point_basis symmetric control points" {
  // When all points are the same, result should be that point
  let p = @raylib.Vector2::new(3.0, 5.0)
  let result = @raylib.get_spline_point_basis(p, p, p, p, 0.5)
  assert_true((result.x - (3.0 : Float)).abs() < 0.001)
  assert_true((result.y - (5.0 : Float)).abs() < 0.001)
}

// --- get_spline_point_catmull_rom ---

///|
test "get_spline_point_catmull_rom at t=0 returns p2" {
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(1.0, 2.0)
  let p3 = @raylib.Vector2::new(3.0, 4.0)
  let p4 = @raylib.Vector2::new(5.0, 6.0)
  let result = @raylib.get_spline_point_catmull_rom(p1, p2, p3, p4, 0.0)
  // At t=0: q0=0, q1=2, q2=0, q3=0 => 0.5*(0 + 2*p2 + 0 + 0) = p2
  assert_true((result.x - (1.0 : Float)).abs() < 0.001)
  assert_true((result.y - (2.0 : Float)).abs() < 0.001)
}

///|
test "get_spline_point_catmull_rom at t=1 returns p3" {
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(1.0, 2.0)
  let p3 = @raylib.Vector2::new(3.0, 4.0)
  let p4 = @raylib.Vector2::new(5.0, 6.0)
  let result = @raylib.get_spline_point_catmull_rom(p1, p2, p3, p4, 1.0)
  // At t=1: q0=-1+2-1=0, q1=3-5+2=0, q2=-3+4+1=2, q3=1-1=0
  // => 0.5*(0 + 0 + 2*p3 + 0) = p3
  assert_true((result.x - (3.0 : Float)).abs() < 0.001)
  assert_true((result.y - (4.0 : Float)).abs() < 0.001)
}

///|
test "get_spline_point_catmull_rom at t=0.5" {
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(0.0, 0.0)
  let p3 = @raylib.Vector2::new(10.0, 10.0)
  let p4 = @raylib.Vector2::new(10.0, 10.0)
  let result = @raylib.get_spline_point_catmull_rom(p1, p2, p3, p4, 0.5)
  // Midpoint of the curve between p2 and p3
  let t : Float = 0.5
  let t2 = t * t
  let t3 = t2 * t
  // q0 and q1 multiply zero-valued p1/p2, so only q2 and q3 matter
  let q2 : Float = -3.0 * t3 + 4.0 * t2 + t
  let q3 = t3 - t2
  let expected_x : Float = 0.5 * ((10.0 : Float) * q2 + (10.0 : Float) * q3)
  assert_true((result.x - expected_x).abs() < 0.001)
  assert_true((result.y - expected_x).abs() < 0.001)
}

///|
test "get_spline_point_catmull_rom all same point" {
  let p = @raylib.Vector2::new(7.0, 3.0)
  let result = @raylib.get_spline_point_catmull_rom(p, p, p, p, 0.5)
  assert_true((result.x - (7.0 : Float)).abs() < 0.001)
  assert_true((result.y - (3.0 : Float)).abs() < 0.001)
}

// --- get_spline_point_bezier_quad ---

///|
test "get_spline_point_bezier_quad at t=0 returns start" {
  let start = @raylib.Vector2::new(1.0, 2.0)
  let control = @raylib.Vector2::new(5.0, 10.0)
  let end_ = @raylib.Vector2::new(9.0, 3.0)
  let result = @raylib.get_spline_point_bezier_quad(start, control, end_, 0.0)
  assert_eq(result.x, 1.0)
  assert_eq(result.y, 2.0)
}

///|
test "get_spline_point_bezier_quad at t=1 returns end" {
  let start = @raylib.Vector2::new(1.0, 2.0)
  let control = @raylib.Vector2::new(5.0, 10.0)
  let end_ = @raylib.Vector2::new(9.0, 3.0)
  let result = @raylib.get_spline_point_bezier_quad(start, control, end_, 1.0)
  assert_true((result.x - (9.0 : Float)).abs() < 0.001)
  assert_true((result.y - (3.0 : Float)).abs() < 0.001)
}

///|
test "get_spline_point_bezier_quad at t=0.5" {
  let start = @raylib.Vector2::new(0.0, 0.0)
  let control = @raylib.Vector2::new(5.0, 10.0)
  let end_ = @raylib.Vector2::new(10.0, 0.0)
  let result = @raylib.get_spline_point_bezier_quad(start, control, end_, 0.5)
  // a = 0.25, b = 0.5, c = 0.25
  let expected_x : Float = 0.25 * 0.0 + 0.5 * 5.0 + 0.25 * 10.0
  let expected_y : Float = 0.25 * 0.0 + 0.5 * 10.0 + 0.25 * 0.0
  assert_true((result.x - expected_x).abs() < 0.001)
  assert_true((result.y - expected_y).abs() < 0.001)
}

///|
test "get_spline_point_bezier_quad collinear points" {
  // When control point is midpoint, should be linear
  let start = @raylib.Vector2::new(0.0, 0.0)
  let control = @raylib.Vector2::new(5.0, 5.0)
  let end_ = @raylib.Vector2::new(10.0, 10.0)
  let result = @raylib.get_spline_point_bezier_quad(start, control, end_, 0.5)
  assert_true((result.x - (5.0 : Float)).abs() < 0.001)
  assert_true((result.y - (5.0 : Float)).abs() < 0.001)
}

// --- get_spline_point_bezier_cubic ---

///|
test "get_spline_point_bezier_cubic at t=0 returns start" {
  let start = @raylib.Vector2::new(1.0, 2.0)
  let sc = @raylib.Vector2::new(3.0, 8.0)
  let ec = @raylib.Vector2::new(7.0, 8.0)
  let end_ = @raylib.Vector2::new(9.0, 2.0)
  let result = @raylib.get_spline_point_bezier_cubic(start, sc, ec, end_, 0.0)
  assert_eq(result.x, 1.0)
  assert_eq(result.y, 2.0)
}

///|
test "get_spline_point_bezier_cubic at t=1 returns end" {
  let start = @raylib.Vector2::new(1.0, 2.0)
  let sc = @raylib.Vector2::new(3.0, 8.0)
  let ec = @raylib.Vector2::new(7.0, 8.0)
  let end_ = @raylib.Vector2::new(9.0, 2.0)
  let result = @raylib.get_spline_point_bezier_cubic(start, sc, ec, end_, 1.0)
  assert_true((result.x - (9.0 : Float)).abs() < 0.001)
  assert_true((result.y - (2.0 : Float)).abs() < 0.001)
}

///|
test "get_spline_point_bezier_cubic at t=0.5" {
  let start = @raylib.Vector2::new(0.0, 0.0)
  let sc = @raylib.Vector2::new(0.0, 10.0)
  let ec = @raylib.Vector2::new(10.0, 10.0)
  let end_ = @raylib.Vector2::new(10.0, 0.0)
  let result = @raylib.get_spline_point_bezier_cubic(start, sc, ec, end_, 0.5)
  // a = 0.125, b = 0.375, c = 0.375, d = 0.125
  let expected_x : Float = 0.125 * 0.0 +
    0.375 * 0.0 +
    0.375 * 10.0 +
    0.125 * 10.0
  let expected_y : Float = 0.125 * 0.0 +
    0.375 * 10.0 +
    0.375 * 10.0 +
    0.125 * 0.0
  assert_true((result.x - expected_x).abs() < 0.001)
  assert_true((result.y - expected_y).abs() < 0.001)
}

///|
test "get_spline_point_bezier_cubic collinear points" {
  // All points on a line => curve should be linear
  let start = @raylib.Vector2::new(0.0, 0.0)
  let sc = @raylib.Vector2::new(10.0 / 3.0, 10.0 / 3.0)
  let ec = @raylib.Vector2::new(20.0 / 3.0, 20.0 / 3.0)
  let end_ = @raylib.Vector2::new(10.0, 10.0)
  let result = @raylib.get_spline_point_bezier_cubic(start, sc, ec, end_, 0.5)
  assert_true((result.x - (5.0 : Float)).abs() < 0.001)
  assert_true((result.y - (5.0 : Float)).abs() < 0.001)
}

///|
test "get_spline_point_bezier_cubic symmetric S-curve" {
  let start = @raylib.Vector2::new(0.0, 0.0)
  let sc = @raylib.Vector2::new(10.0, 0.0)
  let ec = @raylib.Vector2::new(0.0, 10.0)
  let end_ = @raylib.Vector2::new(10.0, 10.0)
  let result = @raylib.get_spline_point_bezier_cubic(start, sc, ec, end_, 0.5)
  // By symmetry, midpoint should be (5, 5)
  assert_true((result.x - (5.0 : Float)).abs() < 0.001)
  assert_true((result.y - (5.0 : Float)).abs() < 0.001)
}
