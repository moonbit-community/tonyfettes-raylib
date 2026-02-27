// Board logic: Cell struct, board helpers, and cell operations

///|
priv struct Cell {
  mut has_mine : Bool
  mut is_revealed : Bool
  mut is_flagged : Bool
  mut neighbor_mines : Int
}

///|
fn Cell::new() -> Cell {
  { has_mine: false, is_revealed: false, is_flagged: false, neighbor_mines: 0 }
}

///|
fn cell_index(row : Int, col : Int, cols : Int) -> Int {
  row * cols + col
}

///|
fn is_valid_cell(row : Int, col : Int, rows : Int, cols : Int) -> Bool {
  row >= 0 && row < rows && col >= 0 && col < cols
}

///|
fn place_mines(
  board : Array[Cell],
  rows : Int,
  cols : Int,
  total_mines : Int,
  safe_row : Int,
  safe_col : Int,
) -> Unit {
  let mut placed = 0
  while placed < total_mines {
    let idx = @raylib.get_random_value(0, rows * cols - 1)
    let r = idx / cols
    let c = idx % cols
    if int_abs(r - safe_row) <= 1 && int_abs(c - safe_col) <= 1 {
      continue
    }
    if board[idx].has_mine {
      continue
    }
    board[idx].has_mine = true
    placed = placed + 1
  }
  // Count neighbor mines
  for r = 0; r < rows; r = r + 1 {
    for c = 0; c < cols; c = c + 1 {
      let idx = cell_index(r, c, cols)
      if board[idx].has_mine {
        continue
      }
      let mut count = 0
      for dr = -1; dr <= 1; dr = dr + 1 {
        for dc = -1; dc <= 1; dc = dc + 1 {
          let nr = r + dr
          let nc = c + dc
          if is_valid_cell(nr, nc, rows, cols) &&
            board[cell_index(nr, nc, cols)].has_mine {
            count = count + 1
          }
        }
      }
      board[idx].neighbor_mines = count
    }
  }
}

///|
fn reveal_cell(
  board : Array[Cell],
  rows : Int,
  cols : Int,
  row : Int,
  col : Int,
) -> Bool {
  // Returns true if mine was hit
  if not(is_valid_cell(row, col, rows, cols)) {
    return false
  }
  let idx = cell_index(row, col, cols)
  if board[idx].is_revealed || board[idx].is_flagged {
    return false
  }
  board[idx].is_revealed = true
  game.revealed_count = game.revealed_count + 1
  if board[idx].has_mine {
    // Reveal all mines
    for i = 0; i < rows * cols; i = i + 1 {
      if board[i].has_mine {
        board[i].is_revealed = true
      }
    }
    return true
  }
  // BFS flood fill for zero-neighbor cells
  if board[idx].neighbor_mines == 0 {
    let queue : Array[(Int, Int)] = [(row, col)]
    let mut head = 0
    while head < queue.length() {
      let (cr, cc) = queue[head]
      head = head + 1
      for dr = -1; dr <= 1; dr = dr + 1 {
        for dc = -1; dc <= 1; dc = dc + 1 {
          let nr = cr + dr
          let nc = cc + dc
          if not(is_valid_cell(nr, nc, rows, cols)) {
            continue
          }
          let ni = cell_index(nr, nc, cols)
          if board[ni].is_revealed || board[ni].is_flagged || board[ni].has_mine {
            continue
          }
          board[ni].is_revealed = true
          game.revealed_count = game.revealed_count + 1
          if board[ni].neighbor_mines == 0 {
            queue.push((nr, nc))
          }
        }
      }
    }
  }
  false
}

///|
fn toggle_flag(
  board : Array[Cell],
  rows : Int,
  cols : Int,
  row : Int,
  col : Int,
) -> Unit {
  if not(is_valid_cell(row, col, rows, cols)) {
    return
  }
  let idx = cell_index(row, col, cols)
  if board[idx].is_revealed {
    return
  }
  board[idx].is_flagged = not(board[idx].is_flagged)
  if board[idx].is_flagged {
    game.flag_count = game.flag_count + 1
  } else {
    game.flag_count = game.flag_count - 1
  }
}

///|
fn chord_reveal(
  board : Array[Cell],
  rows : Int,
  cols : Int,
  row : Int,
  col : Int,
) -> Bool {
  // Returns true if a mine was hit
  if not(is_valid_cell(row, col, rows, cols)) {
    return false
  }
  let idx = cell_index(row, col, cols)
  let cell = board[idx]
  if not(cell.is_revealed) || cell.neighbor_mines == 0 {
    return false
  }
  // Count flags around this cell
  let mut flags = 0
  for dr = -1; dr <= 1; dr = dr + 1 {
    for dc = -1; dc <= 1; dc = dc + 1 {
      let nr = row + dr
      let nc = col + dc
      if is_valid_cell(nr, nc, rows, cols) &&
        board[cell_index(nr, nc, cols)].is_flagged {
        flags = flags + 1
      }
    }
  }
  if flags != cell.neighbor_mines {
    return false
  }
  // Reveal all unflagged unrevealed neighbors
  let mut hit_mine = false
  for dr = -1; dr <= 1; dr = dr + 1 {
    for dc = -1; dc <= 1; dc = dc + 1 {
      let nr = row + dr
      let nc = col + dc
      if is_valid_cell(nr, nc, rows, cols) {
        let ni = cell_index(nr, nc, cols)
        if not(board[ni].is_revealed) && not(board[ni].is_flagged) {
          if reveal_cell(board, rows, cols, nr, nc) {
            hit_mine = true
          }
        }
      }
    }
  }
  hit_mine
}
