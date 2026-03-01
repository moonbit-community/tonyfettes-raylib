///|
pub fn street_w() -> Int {
  street_right - street_left
}

///|
pub fn street_h() -> Int {
  (lane_count - 1) * lane_gap + lane_height
}

///|
pub fn lane_y(lane : Int) -> Float {
  Float::from_int(lane_top + lane * lane_gap + lane_height / 2)
}

///|
pub fn lane_from_y(y : Float) -> Int {
  let raw = ((y - Float::from_int(lane_top)) / Float::from_int(lane_gap)).to_int()
  clampi(raw, 0, lane_count - 1)
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
pub fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn squaref(v : Float) -> Float {
  v * v
}

///|
pub fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
pub fn pulse(game : Game, f : Float) -> Float {
  0.5 + 0.5 * @math.sinf(game.time_s * f)
}
