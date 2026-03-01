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
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
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
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn world_left() -> Float {
  Float::from_int(world_x0)
}

///|
pub fn world_right() -> Float {
  Float::from_int(world_x0 + world_w)
}

///|
pub fn world_top() -> Float {
  Float::from_int(world_y0)
}

///|
pub fn world_bottom() -> Float {
  Float::from_int(world_y0 + world_h)
}

///|
pub fn point_dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn water_current_x(game : Game, y : Float) -> Float {
  let n0 : Float = sinf(game.ui_t * 0.80 + y * 0.011)
  let n1 : Float = cosf(game.ui_t * 1.53 + y * 0.006)
  (n0 * 92.0 + n1 * 68.0) * (0.6 + Float::from_int(game.level) * 0.08)
}

///|
pub fn water_current_y(game : Game, x : Float) -> Float {
  let n0 : Float = sinf(game.ui_t * 0.66 + x * 0.008)
  let n1 : Float = cosf(game.ui_t * 1.18 + x * 0.014)
  180.0 + Float::from_int(game.level) * 18.0 + n0 * 26.0 + n1 * 14.0
}

///|
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
pub fn point_in_rect(
  x : Float,
  y : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)

  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
pub fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  if hold && point_in_rect(mx, my, rx, ry, rw, rh) {
    return true
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }

  false
}
