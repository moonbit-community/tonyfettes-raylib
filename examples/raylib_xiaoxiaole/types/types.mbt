///|
pub(all) enum GameState {
  Title
  Play
  Swap
  Remove
  Fall
  Over
  Clear
} derive(Eq)

///|
pub(all) enum GemKind {
  Empty
  Red
  Green
  Blue
  Yellow
  Purple
  Orange
} derive(Eq)

///|
pub fn GemKind::from_int(i : Int) -> GemKind {
  match i {
    0 => Red
    1 => Green
    2 => Blue
    3 => Yellow
    4 => Purple
    _ => Orange
  }
}

///|
pub fn GemKind::is_empty(self : GemKind) -> Bool {
  self == Empty
}

///|
pub(all) struct Gem {
  mut kind : GemKind
  mut anim_x : Float
  mut anim_y : Float
  mut target_x : Float
  mut target_y : Float
  mut matched : Bool
  mut flash_t : Float
}

///|
pub fn Gem::empty() -> Gem {
  {
    kind: Empty,
    anim_x: 0.0,
    anim_y: 0.0,
    target_x: 0.0,
    target_y: 0.0,
    matched: false,
    flash_t: 0.0,
  }
}

///|
pub(all) struct Game {
  board : Array[Gem]
  mut state : GameState
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
pub fn Game::new() -> Game {
  {
    board: Array::makei(cell_count, fn(_i) { Gem::empty() }),
    state: Title,
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
