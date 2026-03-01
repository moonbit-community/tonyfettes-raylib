///|
pub fn tile_color(value : Int) -> @raylib.Color {
  match value {
    2 => @raylib.Color::new(238, 228, 218, 255)
    4 => @raylib.Color::new(237, 224, 200, 255)
    8 => @raylib.Color::new(242, 177, 121, 255)
    16 => @raylib.Color::new(245, 149, 99, 255)
    32 => @raylib.Color::new(246, 124, 95, 255)
    64 => @raylib.Color::new(246, 94, 59, 255)
    128 => @raylib.Color::new(237, 207, 114, 255)
    256 => @raylib.Color::new(237, 204, 97, 255)
    512 => @raylib.Color::new(237, 200, 80, 255)
    1024 => @raylib.Color::new(237, 197, 63, 255)
    2048 => @raylib.Color::new(237, 194, 46, 255)
    _ => @raylib.Color::new(60, 58, 50, 255)
  }
}

///|
pub fn tile_text_color(value : Int) -> @raylib.Color {
  if value <= 4 {
    @raylib.Color::new(119, 110, 101, 255)
  } else {
    @raylib.Color::new(249, 246, 242, 255)
  }
}

///|
pub fn tile_font_size(value : Int) -> Int {
  if value < 100 {
    40
  } else if value < 1000 {
    32
  } else if value < 10000 {
    26
  } else {
    20
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
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn cell_screen_x(col : Int) -> Float {
  Float::from_int(board_left + board_padding + col * (cell_size + cell_gap))
}

///|
pub fn cell_screen_y(row : Int) -> Float {
  Float::from_int(board_top + board_padding + row * (cell_size + cell_gap))
}

///|
pub fn rect(x : Int, y : Int, w : Int, h : Int) -> @raylib.Rectangle {
  @raylib.Rectangle::new(
    Float::from_int(x),
    Float::from_int(y),
    Float::from_int(w),
    Float::from_int(h),
  )
}

///|
pub fn rectf(
  x : Float,
  y : Float,
  w : Float,
  h : Float,
) -> @raylib.Rectangle {
  @raylib.Rectangle::new(x, y, w, h)
}
