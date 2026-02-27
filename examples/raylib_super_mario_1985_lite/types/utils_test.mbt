///|
test "tile_is_solid: ground is solid" {
  assert_true(tile_is_solid(tile_ground))
}

///|
test "tile_is_solid: brick is solid" {
  assert_true(tile_is_solid(tile_brick))
}

///|
test "tile_is_solid: question is solid" {
  assert_true(tile_is_solid(tile_question))
}

///|
test "tile_is_solid: used is solid" {
  assert_true(tile_is_solid(tile_used))
}

///|
test "tile_is_solid: pipe is solid" {
  assert_true(tile_is_solid(tile_pipe))
}

///|
test "tile_is_solid: castle is solid" {
  assert_true(tile_is_solid(tile_castle))
}

///|
test "tile_is_solid: empty is not solid" {
  assert_false(tile_is_solid(tile_empty))
}

///|
test "tile_is_solid: flag_pole is not solid" {
  assert_false(tile_is_solid(tile_flag_pole))
}

///|
test "rects_overlap: overlapping rects" {
  assert_true(rects_overlap(0.0, 0.0, 10.0, 10.0, 5.0, 5.0, 15.0, 15.0))
}

///|
test "rects_overlap: non-overlapping rects" {
  assert_false(rects_overlap(0.0, 0.0, 10.0, 10.0, 20.0, 20.0, 30.0, 30.0))
}

///|
test "rects_overlap: touching edges do not overlap" {
  assert_false(rects_overlap(0.0, 0.0, 10.0, 10.0, 10.0, 0.0, 20.0, 10.0))
}

///|
test "rects_overlap: contained rect" {
  assert_true(rects_overlap(0.0, 0.0, 20.0, 20.0, 5.0, 5.0, 10.0, 10.0))
}

///|
test "clampf: within range" {
  assert_eq(clampf(5.0, 0.0, 10.0), 5.0)
}

///|
test "clampf: below min" {
  assert_eq(clampf(-3.0, 0.0, 10.0), 0.0)
}

///|
test "clampf: above max" {
  assert_eq(clampf(15.0, 0.0, 10.0), 10.0)
}

///|
test "clampf: at boundaries" {
  assert_eq(clampf(0.0, 0.0, 10.0), 0.0)
  assert_eq(clampf(10.0, 0.0, 10.0), 10.0)
}

///|
test "clampi: within range" {
  assert_eq(clampi(5, 0, 10), 5)
}

///|
test "clampi: below min" {
  assert_eq(clampi(-3, 0, 10), 0)
}

///|
test "clampi: above max" {
  assert_eq(clampi(15, 0, 10), 10)
}

///|
test "world_to_tile_x: zero" {
  assert_eq(world_to_tile_x(0.0), 0)
}

///|
test "world_to_tile_x: negative clamps to 0" {
  assert_eq(world_to_tile_x(-10.0), 0)
}

///|
test "world_to_tile_x: mid-tile" {
  assert_eq(world_to_tile_x(48.0), 1)
}

///|
test "world_to_tile_x: tile boundary" {
  assert_eq(world_to_tile_x(64.0), 2)
}

///|
test "world_to_tile_x: large value clamps" {
  assert_eq(world_to_tile_x(100000.0), world_tiles_w - 1)
}

///|
test "world_to_tile_y: zero" {
  assert_eq(world_to_tile_y(0.0), 0)
}

///|
test "world_to_tile_y: negative clamps to 0" {
  assert_eq(world_to_tile_y(-5.0), 0)
}

///|
test "world_to_tile_y: large value clamps" {
  assert_eq(world_to_tile_y(100000.0), world_tiles_h - 1)
}
