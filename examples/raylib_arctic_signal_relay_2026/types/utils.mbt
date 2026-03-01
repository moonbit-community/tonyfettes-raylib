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
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
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
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn depot_x() -> Float {
  Float::from_int(world_x0 + 132)
}

///|
pub fn depot_y() -> Float {
  Float::from_int(world_y0 + world_h - 126)
}

///|
pub fn depot_r() -> Float {
  70.0
}

///|
pub fn tower_hit_r() -> Float {
  30.0
}

///|
pub fn tower_interact_r() -> Float {
  66.0
}

///|
pub fn title_start_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, screen_h / 2 + 128, 440, 92)
}

///|
pub fn result_primary_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 236, screen_h / 2 + 116, 472, 88)
}

///|
pub fn result_secondary_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 236, screen_h / 2 + 224, 472, 74)
}

///|
pub fn touch_left_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 24, screen_h - 190, 76, 76)
}

///|
pub fn touch_right_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 184, screen_h - 190, 76, 76)
}

///|
pub fn touch_up_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 104, screen_h - 270, 76, 76)
}

///|
pub fn touch_down_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 104, screen_h - 110, 76, 76)
}

///|
pub fn touch_action_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + panel_w - 128, screen_h - 228, 104, 104)
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
  let fx0 = Float::from_int(rx)
  let fy0 = Float::from_int(ry)
  let fx1 = Float::from_int(rx + rw)
  let fy1 = Float::from_int(ry + rh)
  x >= fx0 && x <= fx1 && y >= fy0 && y <= fy1
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
