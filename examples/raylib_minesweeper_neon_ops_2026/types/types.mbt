///|
pub(all) enum GameState {
  Title
  Play
  Result
} derive(Eq)

///|
pub(all) enum PlayMode {
  Reveal
  Flag
} derive(Eq)

///|
pub(all) enum Grade {
  GradeS
  GradeA
  GradeB
  GradeC
  GradeD
} derive(Eq)

///|
pub(all) struct Cell {
  mut mine : Bool
  mut revealed : Bool
  mut flagged : Bool
  mut exploded : Bool
  mut around : Int
}

///|
pub(all) struct Spark {
  mut active : Bool
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut life : Float
  mut size : Float
  mut kind : Int
}

///|
pub(all) struct Game {
  cells : Array[Cell]
  sparks : Array[Spark]
  queue_x : Array[Int]
  queue_y : Array[Int]
  mut state : GameState
  mut mode : PlayMode
  mut first_move : Bool
  mut frame_seed : Int
  mut mine_count : Int
  mut revealed_safe : Int
  mut flagged_count : Int
  mut cursor_x : Int
  mut cursor_y : Int
  mut last_reveal_x : Int
  mut last_reveal_y : Int
  mut lives : Int
  mut hints : Int
  mut mistakes : Int
  mut combo : Int
  mut combo_best : Int
  mut score : Int
  mut best_score : Int
  mut game_t : Float
  mut ui_t : Float
  mut combo_t : Float
  mut msg : String
  mut msg_t : Float
  mut shake_t : Float
  mut grade : Grade
  mut win : Bool
  mut touch_cd : Float
  mut mouse_x : Float
  mut mouse_y : Float
  mut mouse_hold : Bool
  mut touch_count : Int
}

///|
pub fn Cell::new() -> Cell {
  { mine: false, revealed: false, flagged: false, exploded: false, around: 0 }
}

///|
pub fn Spark::new() -> Spark {
  {
    active: false,
    x: 0.0,
    y: 0.0,
    vx: 0.0,
    vy: 0.0,
    life: 0.0,
    size: 0.0,
    kind: 0,
  }
}

///|
pub fn Game::new() -> Game {
  {
    cells: Array::makei(max_cells, fn(_i) { Cell::new() }),
    sparks: Array::makei(1400, fn(_i) { Spark::new() }),
    queue_x: Array::make(max_cells, 0),
    queue_y: Array::make(max_cells, 0),
    state: Title,
    mode: Reveal,
    first_move: true,
    frame_seed: 0,
    mine_count: mine_count_default,
    revealed_safe: 0,
    flagged_count: 0,
    cursor_x: board_w / 2,
    cursor_y: board_h / 2,
    last_reveal_x: -1,
    last_reveal_y: -1,
    lives: lives_default,
    hints: hints_default,
    mistakes: 0,
    combo: 0,
    combo_best: 0,
    score: 0,
    best_score: 0,
    game_t: 0.0,
    ui_t: 0.0,
    combo_t: 0.0,
    msg: "",
    msg_t: 0.0,
    shake_t: 0.0,
    grade: GradeD,
    win: false,
    touch_cd: 0.0,
    mouse_x: 0.0,
    mouse_y: 0.0,
    mouse_hold: false,
    touch_count: 0,
  }
}
