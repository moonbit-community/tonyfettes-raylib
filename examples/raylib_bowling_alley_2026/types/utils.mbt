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
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
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
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn dist2(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
pub fn deg_to_rad(d : Float) -> Float {
  d * 0.01745329252
}

///|
pub fn sqrtf(v : Float) -> Float {
  if v <= 0.0 {
    return 0.0
  }

  let mut x : Float = if v < 1.0 { 1.0 } else { v }
  for _i in 0..<6 {
    x = (x + v / x) * 0.5
  }
  x
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

  let fx0 : Float = Float::from_int(rx)
  let fy0 : Float = Float::from_int(ry)
  let fx1 : Float = Float::from_int(rx + rw)
  let fy1 : Float = Float::from_int(ry + rh)

  x >= fx0 && x <= fx1 && y >= fy0 && y <= fy1
}

///|
pub fn title_start_hover(
  mouse_x : Float,
  mouse_y : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  let (x, y, w, h) = title_start_button()
  pointer_on_rect(mouse_x, mouse_y, hold, touch_count, x, y, w, h)
}

///|
pub fn result_retry_hover(
  mouse_x : Float,
  mouse_y : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  let (x, y, w, h) = retry_button()
  pointer_on_rect(mouse_x, mouse_y, hold, touch_count, x, y, w, h)
}
