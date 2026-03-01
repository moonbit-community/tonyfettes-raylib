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
pub fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
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
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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
pub fn sqrtf(v : Float) -> Float {
  if v <= 0.0 {
    0.0
  } else {
    v.sqrt()
  }
}

///|
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
pub fn chance(pct : Int) -> Bool {
  randi(0, 99) < pct
}

///|
pub fn checkpoint_span(idx : Int) -> Float {
  checkpoint_base_span + Float::from_int(maxi(idx, 0)) * checkpoint_span_step
}

///|
pub fn caravan_speed(checkpoint : Int) -> Float {
  caravan_speed_base + Float::from_int(maxi(checkpoint, 0)) * caravan_speed_step
}

///|
pub fn wagon_slot_x(index : Int) -> Float {
  caravan_center_x + Float::from_int(index - wagon_count / 2) * wagon_gap
}

///|
pub fn wagon_slot_y(index : Int) -> Float {
  if index % 2 == 0 {
    caravan_center_y - 24.0
  } else {
    caravan_center_y + 20.0
  }
}

///|
pub fn lane_base_y(index : Int) -> Float {
  desert_lane_top +
  Float::from_int(clampi(index, 0, lane_count - 1)) * desert_lane_gap
}

///|
pub fn ellipse_norm(dx : Float, dy : Float, rx : Float, ry : Float) -> Float {
  let nx = dx / maxf(rx, 0.001)
  let ny = dy / maxf(ry, 0.001)
  sqrtf(nx * nx + ny * ny)
}
