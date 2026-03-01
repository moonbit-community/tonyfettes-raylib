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
pub fn ease_out_quad(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  1.0 - (1.0 - x) * (1.0 - x)
}

///|
pub fn ease_in_out(t : Float) -> Float {
  let x = clampf(t, 0.0, 1.0)
  if x < 0.5 {
    2.0 * x * x
  } else {
    1.0 - (-2.0 * x + 2.0) * (-2.0 * x + 2.0) * 0.5
  }
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
pub fn chance(percent : Int) -> Bool {
  randi(0, 99) < percent
}

///|
pub fn rect_contains(
  px : Float,
  py : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  px >= rx && py >= ry && px <= rx + rw && py <= ry + rh
}

///|
pub fn rect_overlap(
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
pub fn dist_sq(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn color_mix(
  a : @raylib.Color,
  b : @raylib.Color,
  t : Float,
) -> @raylib.Color {
  let x = clampf(t, 0.0, 1.0)
  let r = (Float::from_int(a.r.to_int()) +
  Float::from_int(b.r.to_int() - a.r.to_int()) * x).to_int()
  let g = (Float::from_int(a.g.to_int()) +
  Float::from_int(b.g.to_int() - a.g.to_int()) * x).to_int()
  let bb = (Float::from_int(a.b.to_int()) +
  Float::from_int(b.b.to_int() - a.b.to_int()) * x).to_int()
  let aa = (Float::from_int(a.a.to_int()) +
  Float::from_int(b.a.to_int() - a.a.to_int()) * x).to_int()
  @raylib.Color::new(
    clampi(r, 0, 255),
    clampi(g, 0, 255),
    clampi(bb, 0, 255),
    clampi(aa, 0, 255),
  )
}

///|
pub fn neon_blue() -> @raylib.Color {
  @raylib.Color::new(58, 214, 255, 255)
}

///|
pub fn neon_pink() -> @raylib.Color {
  @raylib.Color::new(255, 88, 182, 255)
}

///|
pub fn neon_lime() -> @raylib.Color {
  @raylib.Color::new(145, 255, 82, 255)
}

///|
pub fn neon_orange() -> @raylib.Color {
  @raylib.Color::new(255, 184, 74, 255)
}

///|
pub fn bg_night() -> @raylib.Color {
  @raylib.Color::new(10, 12, 28, 255)
}

///|
pub fn bg_haze() -> @raylib.Color {
  @raylib.Color::new(24, 28, 52, 255)
}

///|
pub fn ui_dark() -> @raylib.Color {
  @raylib.Color::new(24, 28, 36, 240)
}

///|
pub fn ui_light() -> @raylib.Color {
  @raylib.Color::new(232, 242, 252, 255)
}

///|
pub fn button_jump_rect() -> (Float, Float, Float, Float) {
  let s : Float = ui_button_size
  let x : Float = Float::from_int(screen_w) - s - Float::from_int(22)
  let y : Float = Float::from_int(screen_h) - s - Float::from_int(20)
  (x, y, s, s)
}

///|
pub fn button_slide_rect() -> (Float, Float, Float, Float) {
  let s : Float = ui_button_size
  let x : Float = Float::from_int(22)
  let y : Float = Float::from_int(screen_h) - s - Float::from_int(20)
  (x, y, s, s)
}

///|
pub fn button_grapple_rect() -> (Float, Float, Float, Float) {
  let s : Float = ui_button_size
  let x : Float = Float::from_int(screen_w) -
    s * Float::from_int(2) -
    ui_button_gap -
    Float::from_int(22)
  let y : Float = Float::from_int(screen_h) - s - Float::from_int(20)
  (x, y, s, s)
}
