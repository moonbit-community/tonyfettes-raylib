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
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn approachf(v : Float, target : Float, step : Float) -> Float {
  if v < target {
    minf(v + step, target)
  } else {
    maxf(v - step, target)
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
pub fn point_in_rect(
  x : Float,
  y : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  x >= rx && x <= rx + rw && y >= ry && y <= ry + rh
}

///|
pub fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
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
pub fn overlap_rect(
  ax : Float,
  ay : Float,
  aw : Float,
  ah : Float,
  bx : Float,
  by : Float,
  bw : Float,
  bh : Float,
) -> Bool {
  ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
}

///|
pub fn mouse_click_on_rect(
  mx : Float,
  my : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) &&
  point_in_rect(mx, my, rx, ry, rw, rh)
}

///|
pub fn timer_string(v : Float) -> String {
  let ds = clampi((maxf(0.0, v) * 10.0).to_int(), 0, 9999)
  let sec = ds / 10
  let dec = ds % 10
  "\{sec}.\{dec}"
}

///|
pub fn run_string(v : Float) -> String {
  let ds = clampi((maxf(0.0, v) * 10.0).to_int(), 0, 99999)
  let sec = ds / 10
  let dec = ds % 10
  "\{sec}.\{dec}"
}
