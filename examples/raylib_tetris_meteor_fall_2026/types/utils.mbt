///|
pub fn board_index(x : Int, y : Int) -> Int {
  y * board_cols + x
}

///|
pub fn collides(game : Game, kind : Int, rot : Int, px : Int, py : Int) -> Bool {
  for i in 0..<4 {
    let c = piece_cell(kind, rot, i)
    let x = px + c.x
    let y = py + c.y
    if x < 0 || x >= board_cols || y >= board_rows {
      return true
    }
    if y >= 0 && game.board[board_index(x, y)] != 0 {
      return true
    }
  }
  false
}
