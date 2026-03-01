///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn dir_dx(dir : Int) -> Int {
  if dir == dir_left {
    -1
  } else if dir == dir_right {
    1
  } else {
    0
  }
}

///|
pub fn dir_dy(dir : Int) -> Int {
  if dir == dir_up {
    -1
  } else if dir == dir_down {
    1
  } else {
    0
  }
}

///|
pub fn opposite_dir(a : Int, b : Int) -> Bool {
  (a == dir_left && b == dir_right) ||
  (a == dir_right && b == dir_left) ||
  (a == dir_up && b == dir_down) ||
  (a == dir_down && b == dir_up)
}

///|
pub fn wrap_x(x : Int) -> Int {
  if x < 0 {
    grid_w - 1
  } else if x >= grid_w {
    0
  } else {
    x
  }
}

///|
pub fn wrap_y(y : Int) -> Int {
  if y < 0 {
    grid_h - 1
  } else if y >= grid_h {
    0
  } else {
    y
  }
}

///|
pub fn board_metrics(shake_t : Float) -> (Int, Int, Int) {
  let tile_x : Int = board_area_w / grid_w
  let tile_y : Int = board_area_h / grid_h

  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 30, 45)

  let mut bx : Int = board_area_x + (board_area_w - grid_w * tile) / 2
  let mut by : Int = board_area_y + (board_area_h - grid_h * tile) / 2

  if shake_t > 0.0 {
    bx = bx + @raylib.get_random_value(-3, 3)
    by = by + @raylib.get_random_value(-3, 3)
  }

  (bx, by, tile)
}

///|
pub fn cell_world_center(game : Game, x : Int, y : Int) -> (Float, Float) {
  let (bx, by, tile) = board_metrics(game.shake_t)
  (
    Float::from_int(bx + x * tile + tile / 2),
    Float::from_int(by + y * tile + tile / 2),
  )
}

///|
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
pub fn pointer_on_rect(
  x : Float,
  y : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  if not(hold) && touch_count <= 0 {
    return false
  }

  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)

  x >= x0 && x <= x1 && y >= y0 && y <= y1
}
