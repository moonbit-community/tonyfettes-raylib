// ============================================================================
// Collision detection tests
// ============================================================================

// --- check_collision_recs ---

///|
test "check_collision_recs overlapping" {
  let r1 = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = @raylib.Rectangle::new(5.0, 5.0, 10.0, 10.0)
  assert_true(@raylib.check_collision_recs(r1, r2))
}

///|
test "check_collision_recs non-overlapping" {
  let r1 = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = @raylib.Rectangle::new(20.0, 20.0, 10.0, 10.0)
  assert_false(@raylib.check_collision_recs(r1, r2))
}

///|
test "check_collision_recs touching edges" {
  let r1 = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = @raylib.Rectangle::new(10.0, 0.0, 10.0, 10.0)
  // Touching at edge: r1.x + r1.width == r2.x, so > fails
  assert_false(@raylib.check_collision_recs(r1, r2))
}

///|
test "check_collision_recs contained" {
  let outer = @raylib.Rectangle::new(0.0, 0.0, 100.0, 100.0)
  let inner = @raylib.Rectangle::new(10.0, 10.0, 5.0, 5.0)
  assert_true(@raylib.check_collision_recs(outer, inner))
  assert_true(@raylib.check_collision_recs(inner, outer))
}

// --- check_collision_circles ---

///|
test "check_collision_circles overlapping" {
  let c1 = @raylib.Vector2::new(0.0, 0.0)
  let c2 = @raylib.Vector2::new(3.0, 4.0)
  // distance = 5, sum of radii = 6
  assert_true(@raylib.check_collision_circles(c1, 3.0, c2, 3.0))
}

///|
test "check_collision_circles non-overlapping" {
  let c1 = @raylib.Vector2::new(0.0, 0.0)
  let c2 = @raylib.Vector2::new(10.0, 0.0)
  assert_false(@raylib.check_collision_circles(c1, 2.0, c2, 2.0))
}

///|
test "check_collision_circles touching" {
  let c1 = @raylib.Vector2::new(0.0, 0.0)
  let c2 = @raylib.Vector2::new(5.0, 0.0)
  // distance = 5, sum of radii = 5 => <=, so true
  assert_true(@raylib.check_collision_circles(c1, 2.0, c2, 3.0))
}

///|
test "check_collision_circles concentric" {
  let c = @raylib.Vector2::new(5.0, 5.0)
  assert_true(@raylib.check_collision_circles(c, 10.0, c, 3.0))
}

// --- check_collision_circle_rec ---

///|
test "check_collision_circle_rec inside" {
  let center = @raylib.Vector2::new(5.0, 5.0)
  let rec = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  assert_true(@raylib.check_collision_circle_rec(center, 2.0, rec))
}

///|
test "check_collision_circle_rec outside" {
  let center = @raylib.Vector2::new(50.0, 50.0)
  let rec = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  assert_false(@raylib.check_collision_circle_rec(center, 2.0, rec))
}

///|
test "check_collision_circle_rec corner overlap" {
  let center = @raylib.Vector2::new(11.0, 11.0)
  let rec = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  // distance from corner (10,10) = sqrt(2) ~ 1.414
  assert_true(@raylib.check_collision_circle_rec(center, 2.0, rec))
}

///|
test "check_collision_circle_rec corner miss" {
  let center = @raylib.Vector2::new(12.0, 12.0)
  let rec = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  // distance from corner (10,10) = sqrt(8) ~ 2.828
  assert_false(@raylib.check_collision_circle_rec(center, 2.0, rec))
}

///|
test "check_collision_circle_rec edge overlap" {
  let center = @raylib.Vector2::new(5.0, -1.0)
  let rec = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  // Circle center is above rect, within x range, dy = 1 <= 5+2
  assert_true(@raylib.check_collision_circle_rec(center, 2.0, rec))
}

// --- check_collision_point_rec ---

///|
test "check_collision_point_rec inside" {
  let point = @raylib.Vector2::new(5.0, 5.0)
  let rec = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  assert_true(@raylib.check_collision_point_rec(point, rec))
}

///|
test "check_collision_point_rec outside" {
  let point = @raylib.Vector2::new(15.0, 15.0)
  let rec = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  assert_false(@raylib.check_collision_point_rec(point, rec))
}

///|
test "check_collision_point_rec on top-left corner" {
  let point = @raylib.Vector2::new(0.0, 0.0)
  let rec = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  // >= for x and y, so corner is inside
  assert_true(@raylib.check_collision_point_rec(point, rec))
}

///|
test "check_collision_point_rec on bottom-right edge" {
  let point = @raylib.Vector2::new(10.0, 10.0)
  let rec = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  // < for both, 10.0 < 10.0 is false
  assert_false(@raylib.check_collision_point_rec(point, rec))
}

// --- check_collision_point_circle ---

///|
test "check_collision_point_circle inside" {
  let point = @raylib.Vector2::new(1.0, 1.0)
  let center = @raylib.Vector2::new(0.0, 0.0)
  assert_true(@raylib.check_collision_point_circle(point, center, 5.0))
}

///|
test "check_collision_point_circle outside" {
  let point = @raylib.Vector2::new(10.0, 10.0)
  let center = @raylib.Vector2::new(0.0, 0.0)
  assert_false(@raylib.check_collision_point_circle(point, center, 5.0))
}

///|
test "check_collision_point_circle on boundary" {
  let point = @raylib.Vector2::new(3.0, 4.0)
  let center = @raylib.Vector2::new(0.0, 0.0)
  // distance = 5, radius = 5, <= so true
  assert_true(@raylib.check_collision_point_circle(point, center, 5.0))
}

// --- check_collision_point_triangle ---

///|
test "check_collision_point_triangle inside" {
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(10.0, 0.0)
  let p3 = @raylib.Vector2::new(5.0, 10.0)
  let point = @raylib.Vector2::new(5.0, 3.0)
  assert_true(@raylib.check_collision_point_triangle(point, p1, p2, p3))
}

///|
test "check_collision_point_triangle outside" {
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(10.0, 0.0)
  let p3 = @raylib.Vector2::new(5.0, 10.0)
  let point = @raylib.Vector2::new(20.0, 20.0)
  assert_false(@raylib.check_collision_point_triangle(point, p1, p2, p3))
}

///|
test "check_collision_point_triangle on edge is outside (strict)" {
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(10.0, 0.0)
  let p3 = @raylib.Vector2::new(5.0, 10.0)
  // Point on edge p1-p2 (y=0)
  let point = @raylib.Vector2::new(5.0, 0.0)
  // barycentric: alpha or beta or gamma will be 0, so > 0 fails
  assert_false(@raylib.check_collision_point_triangle(point, p1, p2, p3))
}

// --- check_collision_point_poly ---

///|
test "check_collision_point_poly inside square" {
  let points = [
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(10.0, 0.0),
    @raylib.Vector2::new(10.0, 10.0),
    @raylib.Vector2::new(0.0, 10.0),
  ]
  let point = @raylib.Vector2::new(5.0, 5.0)
  assert_true(@raylib.check_collision_point_poly(point, points))
}

///|
test "check_collision_point_poly outside square" {
  let points = [
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(10.0, 0.0),
    @raylib.Vector2::new(10.0, 10.0),
    @raylib.Vector2::new(0.0, 10.0),
  ]
  let point = @raylib.Vector2::new(15.0, 5.0)
  assert_false(@raylib.check_collision_point_poly(point, points))
}

///|
test "check_collision_point_poly too few points" {
  let points = [@raylib.Vector2::new(0.0, 0.0), @raylib.Vector2::new(10.0, 0.0)]
  let point = @raylib.Vector2::new(5.0, 0.0)
  assert_false(@raylib.check_collision_point_poly(point, points))
}

///|
test "check_collision_point_poly inside triangle" {
  let points = [
    @raylib.Vector2::new(0.0, 0.0),
    @raylib.Vector2::new(10.0, 0.0),
    @raylib.Vector2::new(5.0, 10.0),
  ]
  let point = @raylib.Vector2::new(5.0, 3.0)
  assert_true(@raylib.check_collision_point_poly(point, points))
}

// --- check_collision_lines ---

///|
test "check_collision_lines crossing" {
  let s1 = @raylib.Vector2::new(0.0, 0.0)
  let e1 = @raylib.Vector2::new(10.0, 10.0)
  let s2 = @raylib.Vector2::new(10.0, 0.0)
  let e2 = @raylib.Vector2::new(0.0, 10.0)
  let result = @raylib.check_collision_lines(s1, e1, s2, e2)
  assert_true(result is Some(_))
  match result {
    Some(p) => {
      assert_true((p.x - 5.0).abs() < 0.01)
      assert_true((p.y - 5.0).abs() < 0.01)
    }
    None => fail("expected collision point")
  }
}

///|
test "check_collision_lines parallel" {
  let s1 = @raylib.Vector2::new(0.0, 0.0)
  let e1 = @raylib.Vector2::new(10.0, 0.0)
  let s2 = @raylib.Vector2::new(0.0, 5.0)
  let e2 = @raylib.Vector2::new(10.0, 5.0)
  assert_true(@raylib.check_collision_lines(s1, e1, s2, e2) is None)
}

///|
test "check_collision_lines non-intersecting segments" {
  // Lines would cross if extended, but segments don't overlap
  let s1 = @raylib.Vector2::new(0.0, 0.0)
  let e1 = @raylib.Vector2::new(1.0, 1.0)
  let s2 = @raylib.Vector2::new(5.0, 0.0)
  let e2 = @raylib.Vector2::new(6.0, -1.0)
  assert_true(@raylib.check_collision_lines(s1, e1, s2, e2) is None)
}

///|
test "check_collision_lines T-intersection" {
  let s1 = @raylib.Vector2::new(0.0, 5.0)
  let e1 = @raylib.Vector2::new(10.0, 5.0)
  let s2 = @raylib.Vector2::new(5.0, 0.0)
  let e2 = @raylib.Vector2::new(5.0, 10.0)
  let result = @raylib.check_collision_lines(s1, e1, s2, e2)
  assert_true(result is Some(_))
  match result {
    Some(p) => {
      assert_true((p.x - 5.0).abs() < 0.01)
      assert_true((p.y - 5.0).abs() < 0.01)
    }
    None => fail("expected collision point")
  }
}

// --- check_collision_point_line ---

///|
test "check_collision_point_line on line" {
  let point = @raylib.Vector2::new(5.0, 5.0)
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(10.0, 10.0)
  assert_true(@raylib.check_collision_point_line(point, p1, p2, 1))
}

///|
test "check_collision_point_line off line" {
  let point = @raylib.Vector2::new(5.0, 0.0)
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(0.0, 10.0)
  assert_false(@raylib.check_collision_point_line(point, p1, p2, 1))
}

///|
test "check_collision_point_line beyond segment" {
  let point = @raylib.Vector2::new(20.0, 20.0)
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(10.0, 10.0)
  // Collinear but beyond the segment
  assert_false(@raylib.check_collision_point_line(point, p1, p2, 1))
}

///|
test "check_collision_point_line horizontal" {
  let point = @raylib.Vector2::new(5.0, 0.0)
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(10.0, 0.0)
  assert_true(@raylib.check_collision_point_line(point, p1, p2, 1))
}

///|
test "check_collision_point_line vertical" {
  let point = @raylib.Vector2::new(0.0, 5.0)
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(0.0, 10.0)
  assert_true(@raylib.check_collision_point_line(point, p1, p2, 1))
}

// --- check_collision_circle_line ---

///|
test "check_collision_circle_line intersecting" {
  let center = @raylib.Vector2::new(5.0, 5.0)
  let p1 = @raylib.Vector2::new(0.0, 5.0)
  let p2 = @raylib.Vector2::new(10.0, 5.0)
  assert_true(@raylib.check_collision_circle_line(center, 2.0, p1, p2))
}

///|
test "check_collision_circle_line not intersecting" {
  let center = @raylib.Vector2::new(5.0, 20.0)
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(10.0, 0.0)
  assert_false(@raylib.check_collision_circle_line(center, 2.0, p1, p2))
}

///|
test "check_collision_circle_line near endpoint" {
  let center = @raylib.Vector2::new(11.0, 0.0)
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(10.0, 0.0)
  // distance to closest point on segment (endpoint p2) = 1
  assert_true(@raylib.check_collision_circle_line(center, 2.0, p1, p2))
}

///|
test "check_collision_circle_line degenerate segment" {
  let center = @raylib.Vector2::new(1.0, 0.0)
  let p = @raylib.Vector2::new(0.0, 0.0)
  // Degenerate: p1 == p2, falls back to circle-circle check
  assert_true(@raylib.check_collision_circle_line(center, 2.0, p, p))
}

///|
test "check_collision_circle_line far from endpoint" {
  let center = @raylib.Vector2::new(15.0, 0.0)
  let p1 = @raylib.Vector2::new(0.0, 0.0)
  let p2 = @raylib.Vector2::new(10.0, 0.0)
  // distance to closest point (endpoint p2) = 5
  assert_false(@raylib.check_collision_circle_line(center, 2.0, p1, p2))
}

// --- get_collision_rec ---

///|
test "get_collision_rec overlapping" {
  let r1 = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = @raylib.Rectangle::new(5.0, 5.0, 10.0, 10.0)
  let result = @raylib.get_collision_rec(r1, r2)
  assert_eq(result.x, 5.0)
  assert_eq(result.y, 5.0)
  assert_eq(result.width, 5.0)
  assert_eq(result.height, 5.0)
}

///|
test "get_collision_rec non-overlapping" {
  let r1 = @raylib.Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = @raylib.Rectangle::new(20.0, 20.0, 10.0, 10.0)
  let result = @raylib.get_collision_rec(r1, r2)
  assert_eq(result.x, 0.0)
  assert_eq(result.y, 0.0)
  assert_eq(result.width, 0.0)
  assert_eq(result.height, 0.0)
}

///|
test "get_collision_rec contained" {
  let outer = @raylib.Rectangle::new(0.0, 0.0, 100.0, 100.0)
  let inner = @raylib.Rectangle::new(10.0, 20.0, 30.0, 40.0)
  let result = @raylib.get_collision_rec(outer, inner)
  assert_eq(result.x, 10.0)
  assert_eq(result.y, 20.0)
  assert_eq(result.width, 30.0)
  assert_eq(result.height, 40.0)
}
