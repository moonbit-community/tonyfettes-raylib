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
  board : Array[Int]
  prev_board : Array[Int]
  sparks : Array[Spark]
  line_vals : Array[Int]
  line_out : Array[Int]
  mut state : Int
  mut score : Int
  mut best_score : Int
  mut moves : Int
  mut max_tile : Int
  mut target_reached : Bool
  mut win : Bool
  mut cursor_x : Int
  mut cursor_y : Int
  mut zap_charge : Int
  mut zap_ready : Bool
  mut blockers_spawned : Int
  mut turns_to_storm : Int
  mut can_undo : Bool
  mut prev_score : Int
  mut prev_moves : Int
  mut prev_max_tile : Int
  mut prev_zap_charge : Int
  mut prev_zap_ready : Bool
  mut prev_turns_to_storm : Int
  mut prev_blockers_spawned : Int
  mut prev_target_reached : Bool
  mut game_t : Float
  mut ui_t : Float
  mut combo_t : Float
  mut msg : String
  mut msg_t : Float
  mut shake_t : Float
  mut touch_cd : Float
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
    board: Array::make(max_cells, 0),
    prev_board: Array::make(max_cells, 0),
    sparks: Array::makei(1200, fn(_i) { Spark::new() }),
    line_vals: Array::make(board_n, 0),
    line_out: Array::make(board_n, 0),
    state: state_title,
    score: 0,
    best_score: 0,
    moves: 0,
    max_tile: 0,
    target_reached: false,
    win: false,
    cursor_x: board_n / 2,
    cursor_y: board_n / 2,
    zap_charge: 0,
    zap_ready: false,
    blockers_spawned: 0,
    turns_to_storm: 4,
    can_undo: false,
    prev_score: 0,
    prev_moves: 0,
    prev_max_tile: 0,
    prev_zap_charge: 0,
    prev_zap_ready: false,
    prev_turns_to_storm: 4,
    prev_blockers_spawned: 0,
    prev_target_reached: false,
    game_t: 0.0,
    ui_t: 0.0,
    combo_t: 0.0,
    msg: "",
    msg_t: 0.0,
    shake_t: 0.0,
    touch_cd: 0.0,
  }
}
