///|
let screen_w : Int = 1420

///|
let screen_h : Int = 900

///|
let target_fps : Int = 120

///|
let board_cols : Int = 8

///|
let board_rows : Int = 8

///|
let board_cells : Int = board_cols * board_rows

///|
let candy_kinds : Int = 6

///|
let cell_px : Int = 84

///|
let board_pad : Int = 18

///|
let ui_panel_w : Int = 360

///|
let moves_base : Int = 28

///|
let moves_level_bonus : Int = 2

///|
let base_jelly : Int = 16

///|
let jelly_level_bonus : Int = 3

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_level_clear : Int = 2

///|
let state_game_over : Int = 3

///|
let special_none : Int = 0

///|
let special_row : Int = 1

///|
let special_col : Int = 2

///|
let special_bomb : Int = 3

///|
let hint_ttl_max : Float = 2.2

///|
let message_ttl_max : Float = 2.4

///|
let touch_action_cooldown : Float = 0.1

///|
fn board_pixel_w() -> Int {
  board_cols * cell_px
}

///|
fn board_pixel_h() -> Int {
  board_rows * cell_px
}

///|
fn board_x() -> Int {
  (screen_w - ui_panel_w - board_pixel_w()) / 2 - 20
}

///|
fn board_y() -> Int {
  (screen_h - board_pixel_h()) / 2
}

///|
fn panel_x() -> Int {
  screen_w - ui_panel_w
}

///|
fn panel_y() -> Int {
  0
}

///|
fn score_for_removed(cleared : Int, chain : Int) -> Int {
  cleared * (42 + chain * 18)
}

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn swapi(xs : Array[Int], i : Int, j : Int) -> Unit {
  let t = xs[i]
  xs[i] = xs[j]
  xs[j] = t
}
