///|
let sw : Int = 1080

///|
let sh : Int = 720

///|
let board_w : Int = 8

///|
let board_h : Int = 8

///|
let tile_count : Int = 6

///|
let cell : Int = 64

///|
let board_px : Int = 220

///|
let board_py : Int = 96

///|
fn idx(x : Int, y : Int) -> Int {
  y * board_w + x
}

///|
fn tile_color(t : Int) -> @raylib.Color {
  if t == 0 {
    @raylib.red
  } else if t == 1 {
    @raylib.orange
  } else if t == 2 {
    @raylib.yellow
  } else if t == 3 {
    @raylib.lime
  } else if t == 4 {
    @raylib.skyblue
  } else {
    @raylib.brown
  }
}

///|
fn random_tile() -> Int {
  @raylib.get_random_value(0, tile_count - 1)
}

///|
fn fill_board_no_matches(board : Array[Int]) -> Unit {
  for y = 0; y < board_h; y = y + 1 {
    for x = 0; x < board_w; x = x + 1 {
      let mut t = random_tile()
      let mut retry_count = 0
      while retry_count < 30 {
        let mut bad = false
        if x >= 2 {
          let a = board[idx(x - 1, y)]
          let b = board[idx(x - 2, y)]
          if a == t && b == t {
            bad = true
          }
        }
        if y >= 2 {
          let a = board[idx(x, y - 1)]
          let b = board[idx(x, y - 2)]
          if a == t && b == t {
            bad = true
          }
        }
        if not(bad) {
          break
        }
        t = random_tile()
        retry_count = retry_count + 1
      }
      board[idx(x, y)] = t
    }
  }
}

///|
fn mark_matches(board : Array[Int], marks : Array[Bool]) -> Int {
  for i = 0; i < marks.length(); i = i + 1 {
    marks[i] = false
  }

  for y = 0; y < board_h; y = y + 1 {
    let mut x = 0
    while x < board_w {
      let t = board[idx(x, y)]
      if t < 0 {
        x = x + 1
        continue
      }
      let mut len = 1
      while x + len < board_w && board[idx(x + len, y)] == t {
        len = len + 1
      }
      if len >= 3 {
        for k = 0; k < len; k = k + 1 {
          marks[idx(x + k, y)] = true
        }
      }
      x = x + len
    }
  }

  for x = 0; x < board_w; x = x + 1 {
    let mut y = 0
    while y < board_h {
      let t = board[idx(x, y)]
      if t < 0 {
        y = y + 1
        continue
      }
      let mut len = 1
      while y + len < board_h && board[idx(x, y + len)] == t {
        len = len + 1
      }
      if len >= 3 {
        for k = 0; k < len; k = k + 1 {
          marks[idx(x, y + k)] = true
        }
      }
      y = y + len
    }
  }

  let mut count = 0
  for i = 0; i < marks.length(); i = i + 1 {
    if marks[i] {
      count = count + 1
    }
  }
  count
}

///|
fn apply_matches_and_refill(board : Array[Int], marks : Array[Bool]) -> Int {
  let mut removed = 0
  for i = 0; i < board.length(); i = i + 1 {
    if marks[i] {
      board[i] = -1
      removed = removed + 1
    }
  }

  for x = 0; x < board_w; x = x + 1 {
    let mut write = board_h - 1
    for y = board_h - 1; y >= 0; y = y - 1 {
      let v = board[idx(x, y)]
      if v >= 0 {
        board[idx(x, write)] = v
        write = write - 1
      }
    }
    while write >= 0 {
      board[idx(x, write)] = random_tile()
      write = write - 1
    }
  }

  removed
}

///|
fn swap_tiles(
  board : Array[Int],
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> Unit {
  let a = idx(x1, y1)
  let b = idx(x2, y2)
  let t = board[a]
  board[a] = board[b]
  board[b] = t
}

///|
fn main {
  @raylib.init_window(sw, sh, "Match-3 Garden 2026")
  @raylib.set_target_fps(60)

  let board : Array[Int] = Array::make(board_w * board_h, 0)
  fill_board_no_matches(board)
  let marks : Array[Bool] = Array::make(board_w * board_h, false)

  let mut cur_x = 0
  let mut cur_y = 0
  let mut sel_x = -1
  let mut sel_y = -1

  let mut moves_left = 30
  let mut score = 0
  let mut best_combo = 0
  let mut msg = "Arrow keys move, Enter/Space select+swap, R restart"

  while not(@raylib.window_should_close()) {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      fill_board_no_matches(board)
      cur_x = 0
      cur_y = 0
      sel_x = -1
      sel_y = -1
      moves_left = 30
      score = 0
      best_combo = 0
      msg = "Garden reset. Plan your chain reactions!"
    }

    if moves_left > 0 {
      if @raylib.is_key_pressed(@raylib.KeyLeft) ||
        @raylib.is_key_pressed(@raylib.KeyA) {
        if cur_x > 0 {
          cur_x = cur_x - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyRight) ||
        @raylib.is_key_pressed(@raylib.KeyD) {
        if cur_x < board_w - 1 {
          cur_x = cur_x + 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyUp) ||
        @raylib.is_key_pressed(@raylib.KeyW) {
        if cur_y > 0 {
          cur_y = cur_y - 1
        }
      }
      if @raylib.is_key_pressed(@raylib.KeyDown) ||
        @raylib.is_key_pressed(@raylib.KeyS) {
        if cur_y < board_h - 1 {
          cur_y = cur_y + 1
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyEnter) ||
        @raylib.is_key_pressed(@raylib.KeySpace) {
        if sel_x < 0 {
          sel_x = cur_x
          sel_y = cur_y
          msg = "Tile selected. Pick one adjacent tile to swap."
        } else {
          let dx = (sel_x - cur_x).abs()
          let dy = (sel_y - cur_y).abs()
          if dx + dy == 1 {
            swap_tiles(board, sel_x, sel_y, cur_x, cur_y)
            let mut matched = mark_matches(board, marks)
            if matched <= 0 {
              swap_tiles(board, sel_x, sel_y, cur_x, cur_y)
              msg = "No match. Swap cancelled."
            } else {
              moves_left = moves_left - 1
              let mut combo = 1
              let mut total_removed = 0
              while matched > 0 {
                let removed = apply_matches_and_refill(board, marks)
                total_removed = total_removed + removed
                score = score + removed * 10 * combo
                if combo > best_combo {
                  best_combo = combo
                }
                combo = combo + 1
                matched = mark_matches(board, marks)
              }
              msg = "Great! Cleared \{total_removed} flowers, combo x\{combo - 1}."
            }
            sel_x = -1
            sel_y = -1
          } else {
            sel_x = cur_x
            sel_y = cur_y
            msg = "Not adjacent. Selection moved to cursor tile."
          }
        }
      }
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(19, 26, 33, 255))

    @raylib.draw_text("MATCH-3 GARDEN 2026", 24, 20, 40, @raylib.lime)
    @raylib.draw_text("Score: \{score}", 24, 76, 30, @raylib.raywhite)
    @raylib.draw_text("Moves: \{moves_left}", 24, 112, 30, @raylib.yellow)
    @raylib.draw_text("Best Combo: x\{best_combo}", 24, 148, 28, @raylib.orange)

    @raylib.draw_rectangle(
      board_px - 10,
      board_py - 10,
      board_w * cell + 20,
      board_h * cell + 20,
      @raylib.Color::new(34, 48, 52, 255),
    )

    for y = 0; y < board_h; y = y + 1 {
      for x = 0; x < board_w; x = x + 1 {
        let v = board[idx(x, y)]
        let px = board_px + x * cell
        let py = board_py + y * cell

        @raylib.draw_rectangle(
          px,
          py,
          cell - 2,
          cell - 2,
          @raylib.Color::new(12, 16, 20, 255),
        )
        if v >= 0 {
          let c = tile_color(v)
          @raylib.draw_circle(px + cell / 2, py + cell / 2, 22.0, c)
          @raylib.draw_circle_lines(
            px + cell / 2,
            py + cell / 2,
            22.0,
            @raylib.white,
          )
        }

        if x == cur_x && y == cur_y {
          @raylib.draw_rectangle_lines(
            px + 1,
            py + 1,
            cell - 4,
            cell - 4,
            @raylib.yellow,
          )
          @raylib.draw_rectangle_lines(
            px + 2,
            py + 2,
            cell - 6,
            cell - 6,
            @raylib.yellow,
          )
        }
        if x == sel_x && y == sel_y {
          @raylib.draw_rectangle_lines(
            px + 5,
            py + 5,
            cell - 12,
            cell - 12,
            @raylib.red,
          )
        }
      }
    }

    @raylib.draw_rectangle(
      200,
      628,
      860,
      64,
      @raylib.Color::new(10, 15, 20, 220),
    )
    @raylib.draw_text(msg, 212, 648, 24, @raylib.raywhite)

    if moves_left <= 0 {
      @raylib.draw_rectangle(
        300,
        260,
        500,
        150,
        @raylib.fade(@raylib.black, 0.8),
      )
      @raylib.draw_text("GARDEN SHIFT ENDED", 350, 294, 36, @raylib.skyblue)
      @raylib.draw_text(
        "Press R to start a new shift", 360, 344, 26, @raylib.white,
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
