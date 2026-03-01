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
pub fn squaref(v : Float) -> Float {
  v * v
}

///|
pub fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let roll = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * roll
}

///|
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
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
pub fn a_col(c : @raylib.Color, a : Int) -> @raylib.Color {
  @raylib.Color::new(
    c.r.to_int(),
    c.g.to_int(),
    c.b.to_int(),
    clampi(a, 0, 255),
  )
}

///|
pub fn night_top() -> @raylib.Color {
  @raylib.Color::new(12, 20, 42, 255)
}

///|
pub fn night_bottom() -> @raylib.Color {
  @raylib.Color::new(36, 52, 96, 255)
}

///|
pub fn street_dark() -> @raylib.Color {
  @raylib.Color::new(30, 28, 40, 255)
}

///|
pub fn street_mid() -> @raylib.Color {
  @raylib.Color::new(52, 46, 64, 255)
}

///|
pub fn lantern_frame_col() -> @raylib.Color {
  @raylib.Color::new(212, 178, 124, 255)
}

///|
pub fn lantern_flame_col(flame : Float) -> @raylib.Color {
  let t = clampf(flame / 100.0, 0.0, 1.0)
  @raylib.Color::new(
    246,
    118 + (t * 122.0).to_int(),
    62 + (t * 130.0).to_int(),
    250,
  )
}

///|
pub fn shrine_col() -> @raylib.Color {
  @raylib.Color::new(114, 208, 188, 255)
}

///|
pub fn danger_col() -> @raylib.Color {
  @raylib.Color::new(244, 110, 94, 255)
}

///|
pub fn calm_col() -> @raylib.Color {
  @raylib.Color::new(118, 212, 252, 255)
}
