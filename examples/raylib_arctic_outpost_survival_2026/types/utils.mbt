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
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn normalize(dx : Float, dy : Float) -> (Float, Float) {
  let d1 : Float = absf(dx) + absf(dy)
  if d1 <= 0.00001 {
    (0.0, -1.0)
  } else {
    (dx / d1, dy / d1)
  }
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

///|
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
pub fn pickup_radius(kind : Int) -> Float {
  if kind == pickup_overdrive {
    21.0
  } else if kind == pickup_fuel {
    19.0
  } else {
    17.0
  }
}
