///|
pub fn city_w_i() -> Int {
  city_cols * cell_w_i
}

///|
pub fn city_h_i() -> Int {
  city_rows * cell_h_i
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
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
}

///|
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
}

///|
pub fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
pub fn cell_index(cell_x : Int, cell_y : Int) -> Int {
  cell_y * city_cols + cell_x
}

///|
pub fn cell_left_i(cell_x : Int) -> Int {
  city_origin_x_i + cell_x * cell_w_i
}

///|
pub fn cell_top_i(cell_y : Int) -> Int {
  city_origin_y_i + cell_y * cell_h_i
}

///|
pub fn cell_center_x(cell_x : Int) -> Float {
  Float::from_int(cell_left_i(cell_x) + cell_w_i / 2)
}

///|
pub fn cell_center_y(cell_y : Int) -> Float {
  Float::from_int(cell_top_i(cell_y) + cell_h_i / 2)
}

///|
pub fn chain_slot(suspect : Int, chain : Int) -> Int {
  suspect * chains_per_suspect + chain
}

///|
pub fn incident_need_score(severity : Int) -> Int {
  10 + severity * 8
}

///|
pub fn incident_timer_for_severity(severity : Int) -> Float {
  incident_timer_base - Float::from_int(severity - 1) * incident_timer_drop
}
