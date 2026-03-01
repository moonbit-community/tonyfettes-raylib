///|
pub fn mini(a : Int, b : Int) -> Int {
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
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn in_board(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_w && y >= 0 && y < board_h
}

///|
pub fn idx(x : Int, y : Int) -> Int {
  y * board_w + x
}

///|
pub fn board_metrics(game : Game) -> (Int, Int, Int) {
  let area_x : Int = board_area_x()
  let area_y : Int = board_area_y()
  let area_w : Int = board_area_w()
  let area_h : Int = board_area_h()

  let tile_x : Int = area_w / board_w
  let tile_y : Int = area_h / board_h

  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 36, 56)

  let mut x0 : Int = area_x + (area_w - board_w * tile) / 2
  let mut y0 : Int = area_y + (area_h - board_h * tile) / 2

  if game.shake_t > 0.0 {
    x0 = x0 + @raylib.get_random_value(-3, 3)
    y0 = y0 + @raylib.get_random_value(-3, 3)
  }

  (x0, y0, tile)
}

///|
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
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

  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)

  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
pub fn safe_cells_total(game : Game) -> Int {
  board_w * board_h - game.mine_count
}

///|
pub fn flags_left(game : Game) -> Int {
  game.mine_count - game.flagged_count
}

///|
pub fn unrevealed_safe_cells(game : Game) -> Int {
  let left : Int = safe_cells_total(game) - game.revealed_safe
  if left < 0 {
    0
  } else {
    left
  }
}

///|
pub fn clear_ratio_pct(game : Game) -> Int {
  let total : Int = safe_cells_total(game)
  if total <= 0 {
    return 0
  }

  let mut pct : Int = game.revealed_safe * 100 / total
  if pct < 0 {
    pct = 0
  }
  if pct > 100 {
    pct = 100
  }
  pct
}

///|
pub fn compute_grade(
  score : Int,
  time_s : Int,
  mistakes : Int,
  lives : Int,
) -> Int {
  let mut v : Int = score

  if time_s <= 130 {
    v = v + 380
  } else if time_s <= 200 {
    v = v + 250
  } else if time_s <= 280 {
    v = v + 120
  }

  v = v + lives * 170 - mistakes * 220

  if v >= 7000 {
    grade_s
  } else if v >= 5200 {
    grade_a
  } else if v >= 3600 {
    grade_b
  } else if v >= 2200 {
    grade_c
  } else {
    grade_d
  }
}

///|
pub fn grade_name(grade : Int) -> String {
  if grade == grade_s {
    "S"
  } else if grade == grade_a {
    "A"
  } else if grade == grade_b {
    "B"
  } else if grade == grade_c {
    "C"
  } else {
    "D"
  }
}

///|
pub fn grade_title(grade : Int) -> String {
  if grade == grade_s {
    "Neon Oracle"
  } else if grade == grade_a {
    "City Detective"
  } else if grade == grade_b {
    "Field Agent"
  } else if grade == grade_c {
    "Cadet"
  } else {
    "Rookie"
  }
}
