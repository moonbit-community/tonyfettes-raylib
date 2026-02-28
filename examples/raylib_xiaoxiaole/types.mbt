///|
struct Gem {
  mut kind : Int // 0..5 color, -1 = empty
  mut anim_x : Float
  mut anim_y : Float
  mut target_x : Float
  mut target_y : Float
  mut matched : Bool
  mut flash_t : Float
}

///|
fn Gem::empty() -> Gem {
  {
    kind: -1,
    anim_x: 0.0,
    anim_y: 0.0,
    target_x: 0.0,
    target_y: 0.0,
    matched: false,
    flash_t: 0.0,
  }
}

///|
struct Game {
  board : Array[Gem]
  mut state : Int
  mut score : Int
  mut best_score : Int
  mut moves_left : Int
  mut target_score : Int
  mut level : Int
  mut combo : Int
  mut max_combo : Int
  mut sel_r : Int // selected row (-1 = none)
  mut sel_c : Int // selected col (-1 = none)
  mut swap_r1 : Int
  mut swap_c1 : Int
  mut swap_r2 : Int
  mut swap_c2 : Int
  mut hint_r1 : Int
  mut hint_c1 : Int
  mut hint_r2 : Int
  mut hint_c2 : Int
  mut hint_t : Float
  mut msg : String
  mut msg_t : Float
}

///|
fn Game::new() -> Game {
  {
    board: Array::makei(cell_count, fn(_i) { Gem::empty() }),
    state: state_title,
    score: 0,
    best_score: 0,
    moves_left: base_moves,
    target_score: base_target,
    level: 1,
    combo: 0,
    max_combo: 0,
    sel_r: -1,
    sel_c: -1,
    swap_r1: -1,
    swap_c1: -1,
    swap_r2: -1,
    swap_c2: -1,
    hint_r1: -1,
    hint_c1: -1,
    hint_r2: -1,
    hint_c2: -1,
    hint_t: 0.0,
    msg: "",
    msg_t: 0.0,
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
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
fn cell_x(col : Int) -> Float {
  Float::from_int(board_left + col * (cell_px + cell_gap))
}

///|
fn cell_y(row : Int) -> Float {
  Float::from_int(board_top + row * (cell_px + cell_gap))
}


///|
fn idx(r : Int, c : Int) -> Int {
  r * grid_cols + c
}
