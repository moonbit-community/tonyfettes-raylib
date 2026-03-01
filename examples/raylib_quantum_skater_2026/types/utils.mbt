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
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
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
pub fn randf(lo : Float, hi : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
pub fn chance(p : Int) -> Bool {
  randi(0, 99) < p
}

///|
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn proj_scale(z : Float) -> Float {
  1.0 / (1.0 + z * 0.0042)
}

///|
pub fn lane_world_x(lane : Int) -> Float {
  let half = Float::from_int(lane_count - 1) * 0.5
  (Float::from_int(lane) - half) * 220.0
}

///|
pub fn lane_screen_x(lane : Float, z : Float) -> Float {
  let cx = Float::from_int(screen_w / 2)
  cx + lane * proj_scale(z)
}

///|
pub fn track_y(z : Float) -> Float {
  let near : Float = Float::from_int(screen_h) - Float::from_int(118)
  let far : Float = Float::from_int(162)
  lerpf(near, far, clampf(z / 2400.0, 0.0, 1.0))
}

///|
pub fn color_bg_top() -> @raylib.Color {
  @raylib.Color::new(8, 12, 32, 255)
}

///|
pub fn color_bg_bottom() -> @raylib.Color {
  @raylib.Color::new(10, 18, 44, 255)
}

///|
pub fn color_lane_alpha() -> @raylib.Color {
  @raylib.Color::new(86, 236, 255, 255)
}

///|
pub fn color_lane_beta() -> @raylib.Color {
  @raylib.Color::new(255, 124, 228, 255)
}

///|
pub fn color_phase_bar() -> @raylib.Color {
  @raylib.Color::new(136, 230, 255, 255)
}

///|
pub fn color_hp_bar() -> @raylib.Color {
  @raylib.Color::new(255, 118, 152, 255)
}

///|
pub fn button_left_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(22),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn button_right_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(140),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn button_jump_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(screen_w) - s - Float::from_int(20),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}

///|
pub fn button_phase_rect() -> (Float, Float, Float, Float) {
  let s : Float = Float::from_int(104)
  (
    Float::from_int(screen_w) - s * Float::from_int(2) - Float::from_int(34),
    Float::from_int(screen_h) - s - Float::from_int(20),
    s,
    s,
  )
}
