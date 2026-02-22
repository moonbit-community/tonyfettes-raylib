///|
struct Cell {
  mut mine : Bool
  mut revealed : Bool
  mut flagged : Bool
  mut exploded : Bool
  mut around : Int
}

///|
struct Spark {
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
struct Game {
  cells : Array[Cell]
  sparks : Array[Spark]
  queue_x : Array[Int]
  queue_y : Array[Int]
  mut state : Int
  mut mode : Int
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
  mut grade : Int
  mut win : Bool
  mut touch_cd : Float
}

///|
fn Cell::new() -> Cell {
  { mine: false, revealed: false, flagged: false, exploded: false, around: 0 }
}

///|
fn Spark::new() -> Spark {
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
fn Game::new() -> Game {
  {
    cells: Array::makei(max_cells, fn(_i) { Cell::new() }),
    sparks: Array::makei(1400, fn(_i) { Spark::new() }),
    queue_x: Array::make(max_cells, 0),
    queue_y: Array::make(max_cells, 0),
    state: state_title,
    mode: mode_reveal,
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
    grade: grade_d,
    win: false,
    touch_cd: 0.0,
  }
}
