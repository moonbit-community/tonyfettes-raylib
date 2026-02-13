///|
test "collision detection - recs" {
  let r1 = Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = Rectangle::new(5.0, 5.0, 10.0, 10.0)
  let r3 = Rectangle::new(20.0, 20.0, 10.0, 10.0)
  assert_true(check_collision_recs(r1, r2))
  assert_true(not(check_collision_recs(r1, r3)))
}

///|
test "collision detection - circles" {
  let c1 = Vector2::new(0.0, 0.0)
  let c2 = Vector2::new(3.0, 0.0)
  let c3 = Vector2::new(100.0, 0.0)
  assert_true(check_collision_circles(c1, 5.0, c2, 5.0))
  assert_true(not(check_collision_circles(c1, 5.0, c3, 5.0)))
}

///|
test "collision detection - point in rect" {
  let r = Rectangle::new(0.0, 0.0, 10.0, 10.0)
  assert_true(check_collision_point_rec(Vector2::new(5.0, 5.0), r))
  assert_true(not(check_collision_point_rec(Vector2::new(15.0, 15.0), r)))
}

///|
test "collision detection - point in circle" {
  let center = Vector2::new(0.0, 0.0)
  assert_true(check_collision_point_circle(Vector2::new(1.0, 1.0), center, 5.0))
  assert_true(
    not(check_collision_point_circle(Vector2::new(10.0, 10.0), center, 5.0)),
  )
}

///|
test "collision detection - circle vs rect" {
  let r = Rectangle::new(0.0, 0.0, 10.0, 10.0)
  assert_true(check_collision_circle_rec(Vector2::new(5.0, 5.0), 3.0, r))
  assert_true(not(check_collision_circle_rec(Vector2::new(50.0, 50.0), 3.0, r)))
}

///|
test "get_collision_rec returns overlap" {
  let r1 = Rectangle::new(0.0, 0.0, 10.0, 10.0)
  let r2 = Rectangle::new(5.0, 5.0, 10.0, 10.0)
  let overlap = get_collision_rec(r1, r2)
  assert_eq(overlap.x, 5.0)
  assert_eq(overlap.y, 5.0)
  assert_eq(overlap.width, 5.0)
  assert_eq(overlap.height, 5.0)
}

///|
test "check_collision_point_triangle - inside and outside" {
  let p1 = Vector2::new(0.0, 0.0)
  let p2 = Vector2::new(10.0, 0.0)
  let p3 = Vector2::new(5.0, 10.0)
  // Point inside the triangle
  let inside = Vector2::new(5.0, 3.0)
  assert_true(check_collision_point_triangle(inside, p1, p2, p3))
  // Point outside the triangle
  let outside = Vector2::new(20.0, 20.0)
  assert_true(not(check_collision_point_triangle(outside, p1, p2, p3)))
}
