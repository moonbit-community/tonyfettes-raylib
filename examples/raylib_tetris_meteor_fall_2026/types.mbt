///|
struct Cell {
  x : Int
  y : Int
}

///|
struct Game {
  board : Array[Int]
  mut piece_kind : Int
  mut piece_rot : Int
  mut piece_x : Int
  mut piece_y : Int
  mut next_kind : Int
  mut hold_kind : Int
  mut hold_used : Bool
  mut score : Int
  mut lines : Int
  mut level : Int
  mut drop_timer : Float
  mut drop_interval : Float
  mut over : Bool
  bag : Array[Int]
  mut bag_pos : Int
}

///|
fn Game::new() -> Game {
  {
    board: Array::make(board_cols * board_rows, 0),
    piece_kind: 0,
    piece_rot: 0,
    piece_x: board_cols / 2,
    piece_y: 0,
    next_kind: 0,
    hold_kind: -1,
    hold_used: false,
    score: 0,
    lines: 0,
    level: 1,
    drop_timer: 0.0,
    drop_interval: 0.65,
    over: false,
    bag: Array::make(bag_size, 0),
    bag_pos: bag_size,
  }
}
