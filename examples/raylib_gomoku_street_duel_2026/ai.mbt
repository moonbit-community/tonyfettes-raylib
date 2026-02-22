///|
fn has_neighbor(game : Game, x : Int, y : Int, r : Int) -> Bool {
  for yy = y - r; yy <= y + r; yy = yy + 1 {
    for xx = x - r; xx <= x + r; xx = xx + 1 {
      if xx == x && yy == y {
        continue
      }

      if in_board(xx, yy) && cell_at(game, xx, yy) != player_empty {
        return true
      }
    }
  }

  false
}

///|
fn count_chain_and_open(
  game : Game,
  x : Int,
  y : Int,
  p : Int,
  dx : Int,
  dy : Int,
) -> (Int, Int) {
  let mut cx : Int = x + dx
  let mut cy : Int = y + dy
  let mut c : Int = 0

  while in_board(cx, cy) && cell_at(game, cx, cy) == p {
    c = c + 1
    cx = cx + dx
    cy = cy + dy
  }

  let open : Int = if in_board(cx, cy) && cell_at(game, cx, cy) == player_empty {
    1
  } else {
    0
  }

  (c, open)
}

///|
fn line_pattern_score(total : Int, open : Int) -> Int {
  if total >= 4 {
    220000
  } else if total == 3 && open == 2 {
    36000
  } else if total == 3 && open == 1 {
    7600
  } else if total == 2 && open == 2 {
    2100
  } else if total == 2 && open == 1 {
    460
  } else if total == 1 && open == 2 {
    130
  } else if total == 1 && open == 1 {
    48
  } else {
    10
  }
}

///|
fn score_dir(game : Game, x : Int, y : Int, p : Int, dx : Int, dy : Int) -> Int {
  let left = count_chain_and_open(game, x, y, p, -dx, -dy)
  let right = count_chain_and_open(game, x, y, p, dx, dy)

  let total : Int = left.0 + right.0
  let open : Int = left.1 + right.1

  line_pattern_score(total, open) + total * 11 + open * 5
}

///|
fn score_cell_for(game : Game, x : Int, y : Int, p : Int) -> Int {
  if cell_at(game, x, y) != player_empty {
    return -1
  }

  let mut score : Int = 0
  score = score + score_dir(game, x, y, p, 1, 0)
  score = score + score_dir(game, x, y, p, 0, 1)
  score = score + score_dir(game, x, y, p, 1, 1)
  score = score + score_dir(game, x, y, p, 1, -1)

  let cx : Int = board_n / 2
  let dist : Int = absf(Float::from_int(x - cx)).to_int() +
    absf(Float::from_int(y - cx)).to_int()
  score = score + maxi(0, 50 - dist * 3)

  score
}

///|
fn would_win_if_place(game : Game, x : Int, y : Int, p : Int) -> Bool {
  if cell_at(game, x, y) != player_empty {
    return false
  }

  set_cell(game, x, y, p)
  let win : Bool = check_five_from(game, x, y, p)
  set_cell(game, x, y, player_empty)
  win
}

///|
fn best_move_for(game : Game, p : Int, opp : Int) -> (Bool, Int, Int, Int) {
  if game.move_count == 0 {
    return (true, board_n / 2, board_n / 2, 100)
  }

  let mut found : Bool = false
  let mut best_score : Int = -1
  let mut best_x : Int = board_n / 2
  let mut best_y : Int = board_n / 2

  for y = 0; y < board_n; y = y + 1 {
    for x = 0; x < board_n; x = x + 1 {
      if cell_at(game, x, y) != player_empty {
        continue
      }

      if not(has_neighbor(game, x, y, 2)) {
        continue
      }

      let mut s : Int = 0

      if would_win_if_place(game, x, y, p) {
        s = 1000000
      } else if would_win_if_place(game, x, y, opp) {
        s = 760000
      } else {
        let off : Int = score_cell_for(game, x, y, p)
        let def : Int = score_cell_for(game, x, y, opp)
        s = off + def * 11 / 10
      }

      s = s + @raylib.get_random_value(0, 6)

      if not(found) || s > best_score {
        found = true
        best_score = s
        best_x = x
        best_y = y
      }
    }
  }

  if not(found) {
    for y = 0; y < board_n; y = y + 1 {
      for x = 0; x < board_n; x = x + 1 {
        if cell_at(game, x, y) == player_empty {
          return (true, x, y, 1)
        }
      }
    }
    return (false, 0, 0, 0)
  }

  (true, best_x, best_y, best_score)
}

///|
fn ai_step(game : Game) -> Unit {
  if game.state != state_play || game.turn != player_ai || game.ai_delay > 0.0 {
    return
  }

  let mv = best_move_for(game, player_ai, player_human)
  if not(mv.0) {
    game.state = state_result
    game.winner = player_empty
    game.draws = game.draws + 1
    set_message(game, "No move, draw", 1.4)
    return
  }

  let x : Int = mv.1
  let y : Int = mv.2
  ignore(place_stone(game, x, y, player_ai))

  if game.state == state_play {
    set_message(game, "AI moved", 0.45)
  }
}

///|
fn use_hint(game : Game) -> Bool {
  if game.state != state_play || game.turn != player_human {
    return false
  }

  if game.hints_left <= 0 {
    set_message(game, "No hints left", 0.8)
    return false
  }

  let mv = best_move_for(game, player_human, player_ai)
  if not(mv.0) {
    set_message(game, "No suggestion", 0.8)
    return false
  }

  game.hints_left = game.hints_left - 1
  game.hint_active = true
  game.hint_ttl = 3.0
  game.hint_x = mv.1
  game.hint_y = mv.2

  game.cursor_x = mv.1
  game.cursor_y = mv.2

  set_message(game, "Hint suggested", 0.9)
  burst_move(game, mv.1, mv.2, 10, 3)

  true
}
