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
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn cell_x(col : Int) -> Float {
  Float::from_int(board_left + col * (cell_px + cell_gap))
}

///|
pub fn cell_y(row : Int) -> Float {
  Float::from_int(board_top + row * (cell_px + cell_gap))
}

///|
pub fn idx(r : Int, c : Int) -> Int {
  r * grid_cols + c
}
