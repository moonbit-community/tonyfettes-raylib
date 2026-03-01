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
pub fn sqrtf(v : Float) -> Float {
  v.sqrt()
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
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn normalize_deg(a : Float) -> Float {
  let mut v = a
  while v > 180.0 {
    v = v - 360.0
  }
  while v < -180.0 {
    v = v + 360.0
  }
  v
}

///|
pub fn angle_delta_deg(a : Float, b : Float) -> Float {
  absf(normalize_deg(a - b))
}

///|
pub fn heading_deg(dx : Float, dy : Float) -> Float {
  @math.atan2f(dy, dx) * rad_to_deg
}

///|
pub fn world_w() -> Float {
  world_right - world_left
}

///|
pub fn world_h() -> Float {
  world_bottom - world_top
}

///|
pub fn world_center_x() -> Float {
  (world_left + world_right) * 0.5
}

///|
pub fn player_spawn_x() -> Float {
  world_center_x()
}

///|
pub fn player_spawn_y() -> Float {
  world_bottom - 86.0
}

///|
pub fn default_exit_pos(i : Int) -> (Float, Float) {
  if i % max_exits == 0 {
    (world_left + 104.0, world_top + 84.0)
  } else if i % max_exits == 1 {
    (world_center_x(), world_top + 76.0)
  } else {
    (world_right - 104.0, world_bottom - 94.0)
  }
}

///|
pub fn col_bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 14, 23, 255)
}

///|
pub fn col_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(12, 21, 32, 255)
}

///|
pub fn col_floor() -> @raylib.Color {
  @raylib.Color::new(24, 34, 46, 255)
}

///|
pub fn col_floor_grid() -> @raylib.Color {
  @raylib.Color::new(44, 58, 74, 150)
}

///|
pub fn col_wall() -> @raylib.Color {
  @raylib.Color::new(56, 66, 84, 255)
}

///|
pub fn col_player() -> @raylib.Color {
  @raylib.Color::new(114, 232, 190, 255)
}

///|
pub fn col_guard() -> @raylib.Color {
  @raylib.Color::new(255, 122, 122, 255)
}

///|
pub fn col_parcel() -> @raylib.Color {
  @raylib.Color::new(250, 222, 120, 255)
}

///|
pub fn col_exit() -> @raylib.Color {
  @raylib.Color::new(126, 172, 255, 255)
}

///|
pub fn col_trap() -> @raylib.Color {
  @raylib.Color::new(242, 88, 142, 255)
}

///|
pub fn col_health() -> @raylib.Color {
  @raylib.Color::new(238, 98, 114, 255)
}

///|
pub fn col_stealth() -> @raylib.Color {
  @raylib.Color::new(118, 216, 196, 255)
}
