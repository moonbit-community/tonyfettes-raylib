///|
pub fn board_pixel_w() -> Int {
  board_cols * cell_px
}

///|
pub fn board_pixel_h() -> Int {
  board_rows * cell_px
}

///|
pub fn board_x() -> Int {
  (screen_w - ui_panel_w - board_pixel_w()) / 2 - 20
}

///|
pub fn board_y() -> Int {
  (screen_h - board_pixel_h()) / 2
}

///|
pub fn panel_x() -> Int {
  screen_w - ui_panel_w
}

///|
pub fn panel_y() -> Int {
  0
}

///|
pub fn score_for_removed(cleared : Int, chain : Int) -> Int {
  cleared * (42 + chain * 18)
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
pub fn absi(v : Int) -> Int {
  if v < 0 {
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
pub fn swapi(xs : Array[Int], i : Int, j : Int) -> Unit {
  let t = xs[i]
  xs[i] = xs[j]
  xs[j] = t
}

///|
pub fn idx(x : Int, y : Int) -> Int {
  y * board_cols + x
}

///|
pub fn in_board(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_cols && y >= 0 && y < board_rows
}

///|
pub fn is_adjacent(x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Bool {
  let dx = absi(x0 - x1)
  let dy = absi(y0 - y1)
  dx + dy == 1
}

///|
pub fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
pub fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  if mouse_press && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    return true
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if inside_rect(p.x, p.y, x, y, w, h) {
      return true
    }
  }

  false
}

///|
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, screen_h - 170, 460, 96)
}

///|
pub fn hint_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 30, 280, ui_panel_w - 60, 70)
}

///|
pub fn shuffle_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 30, 366, ui_panel_w - 60, 70)
}

///|
pub fn restart_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 30, 452, ui_panel_w - 60, 70)
}

///|
pub fn result_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, screen_h - 180, 440, 92)
}

///|
pub fn candy_color(kind : Int) -> @raylib.Color {
  if kind == 0 {
    @raylib.Color::new(246, 92, 118, 255)
  } else if kind == 1 {
    @raylib.Color::new(255, 166, 80, 255)
  } else if kind == 2 {
    @raylib.Color::new(255, 225, 104, 255)
  } else if kind == 3 {
    @raylib.Color::new(109, 220, 138, 255)
  } else if kind == 4 {
    @raylib.Color::new(104, 186, 255, 255)
  } else {
    @raylib.Color::new(188, 142, 255, 255)
  }
}

///|
pub fn tint(c : @raylib.Color, delta : Int) -> @raylib.Color {
  let r = clampi(c.r.to_int() + delta, 0, 255)
  let g = clampi(c.g.to_int() + delta, 0, 255)
  let b = clampi(c.b.to_int() + delta, 0, 255)
  @raylib.Color::new(r, g, b, c.a.to_int())
}

///|
pub fn pointer_to_cell(
  mouse_x : Float,
  mouse_y : Float,
  mouse_press : Bool,
  touch_count : Int,
) -> (Bool, Int, Int) {
  let bx = board_x()
  let by = board_y()
  let bw = board_pixel_w()
  let bh = board_pixel_h()

  fn to_cell(px : Float, py : Float) -> (Bool, Int, Int) {
    if not(inside_rect(px, py, bx, by, bw, bh)) {
      return (false, 0, 0)
    }

    let cx = clampi((px.to_int() - bx) / cell_px, 0, board_cols - 1)
    let cy = clampi((py.to_int() - by) / cell_px, 0, board_rows - 1)
    (true, cx, cy)
  }

  if mouse_press {
    let cell = to_cell(mouse_x, mouse_y)
    if cell.0 {
      return cell
    }
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    let cell = to_cell(p.x, p.y)
    if cell.0 {
      return cell
    }
  }

  (false, 0, 0)
}
