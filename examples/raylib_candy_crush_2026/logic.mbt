///|
fn idx(x : Int, y : Int) -> Int {
  y * board_cols + x
}

///|
fn in_board(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_cols && y >= 0 && y < board_rows
}

///|
fn random_kind() -> Int {
  @raylib.get_random_value(0, candy_kinds - 1)
}

///|
fn clear_selection(game : Game) -> Unit {
  game.selected = false
}

///|
fn set_message(game : Game, text : String) -> Unit {
  game.message = text
  game.message_t = message_ttl_max
}

///|
fn is_adjacent(x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Bool {
  let dx = absi(x0 - x1)
  let dy = absi(y0 - y1)
  dx + dy == 1
}

///|
fn clear_marks(game : Game) -> Unit {
  for i = 0; i < board_cells; i = i + 1 {
    game.marks[i] = false
    game.spawn_special[i] = special_none
  }
}

///|
fn clear_effects(game : Game) -> Unit {
  for i = 0; i < board_cells; i = i + 1 {
    game.flash[i] = 0.0
  }
}

///|
fn merge_special(a : Int, b : Int) -> Int {
  if a == special_bomb || b == special_bomb {
    special_bomb
  } else if a == special_none {
    b
  } else if b == special_none {
    a
  } else if a != b {
    special_bomb
  } else {
    a
  }
}

///|
fn mark_horizontal_run(game : Game, y : Int, start_x : Int, len : Int) -> Unit {
  for k = 0; k < len; k = k + 1 {
    game.marks[idx(start_x + k, y)] = true
  }

  if len == 4 {
    let anchor = idx(start_x + 1, y)
    game.spawn_special[anchor] = merge_special(
      game.spawn_special[anchor],
      special_row,
    )
  } else if len >= 5 {
    let anchor = idx(start_x + len / 2, y)
    game.spawn_special[anchor] = special_bomb
  }
}

///|
fn mark_vertical_run(game : Game, x : Int, start_y : Int, len : Int) -> Unit {
  for k = 0; k < len; k = k + 1 {
    game.marks[idx(x, start_y + k)] = true
  }

  if len == 4 {
    let anchor = idx(x, start_y + 1)
    game.spawn_special[anchor] = merge_special(
      game.spawn_special[anchor],
      special_col,
    )
  } else if len >= 5 {
    let anchor = idx(x, start_y + len / 2)
    game.spawn_special[anchor] = special_bomb
  }
}

///|
fn scan_and_mark_matches(game : Game) -> Int {
  clear_marks(game)

  for y = 0; y < board_rows; y = y + 1 {
    let mut x = 0
    while x < board_cols {
      let t = game.kinds[idx(x, y)]
      if t < 0 {
        x = x + 1
        continue
      }

      let mut len = 1
      while x + len < board_cols && game.kinds[idx(x + len, y)] == t {
        len = len + 1
      }

      if len >= 3 {
        mark_horizontal_run(game, y, x, len)
      }
      x = x + len
    }
  }

  for x = 0; x < board_cols; x = x + 1 {
    let mut y = 0
    while y < board_rows {
      let t = game.kinds[idx(x, y)]
      if t < 0 {
        y = y + 1
        continue
      }

      let mut len = 1
      while y + len < board_rows && game.kinds[idx(x, y + len)] == t {
        len = len + 1
      }

      if len >= 3 {
        mark_vertical_run(game, x, y, len)
      }
      y = y + len
    }
  }

  let mut n = 0
  for i = 0; i < board_cells; i = i + 1 {
    if game.marks[i] {
      n = n + 1
    }
  }
  n
}

///|
fn expand_special_marks(game : Game) -> Unit {
  let mut changed = true

  while changed {
    changed = false

    for i = 0; i < board_cells; i = i + 1 {
      if not(game.marks[i]) {
        continue
      }

      let sp = game.specials[i]
      if sp == special_none {
        continue
      }

      let cx = i % board_cols
      let cy = i / board_cols

      if sp == special_row {
        for x = 0; x < board_cols; x = x + 1 {
          let j = idx(x, cy)
          if not(game.marks[j]) {
            game.marks[j] = true
            changed = true
          }
        }
      } else if sp == special_col {
        for y = 0; y < board_rows; y = y + 1 {
          let j = idx(cx, y)
          if not(game.marks[j]) {
            game.marks[j] = true
            changed = true
          }
        }
      } else if sp == special_bomb {
        for dy = -1; dy <= 1; dy = dy + 1 {
          for dx = -1; dx <= 1; dx = dx + 1 {
            let x = cx + dx
            let y = cy + dy
            if in_board(x, y) {
              let j = idx(x, y)
              if not(game.marks[j]) {
                game.marks[j] = true
                changed = true
              }
            }
          }
        }
      }
    }
  }
}

///|
fn remove_marked_cells(game : Game) -> Int {
  let mut removed = 0

  for i = 0; i < board_cells; i = i + 1 {
    if not(game.marks[i]) {
      continue
    }

    let spawn = game.spawn_special[i]
    if spawn != special_none {
      if game.kinds[i] < 0 {
        game.kinds[i] = random_kind()
      }
      game.specials[i] = spawn
      game.flash[i] = 1.0
      continue
    }

    if game.kinds[i] >= 0 || game.specials[i] != special_none {
      removed = removed + 1
      if game.jelly[i] > 0 {
        game.jelly[i] = game.jelly[i] - 1
        if game.jelly[i] == 0 {
          game.jelly_left = game.jelly_left - 1
        }
      }
      game.kinds[i] = -1
      game.specials[i] = special_none
      game.flash[i] = 1.0
    }
  }

  removed
}

///|
fn collapse_and_refill(game : Game) -> Unit {
  let col_kind : Array[Int] = Array::make(board_rows, -1)
  let col_special : Array[Int] = Array::make(board_rows, special_none)

  for x = 0; x < board_cols; x = x + 1 {
    for y = 0; y < board_rows; y = y + 1 {
      col_kind[y] = -1
      col_special[y] = special_none
    }

    let mut write = board_rows - 1
    for y = board_rows - 1; y >= 0; y = y - 1 {
      let i = idx(x, y)
      if game.kinds[i] >= 0 {
        col_kind[write] = game.kinds[i]
        col_special[write] = game.specials[i]
        write = write - 1
      }
    }

    while write >= 0 {
      col_kind[write] = random_kind()
      col_special[write] = special_none
      write = write - 1
    }

    for y = 0; y < board_rows; y = y + 1 {
      let i = idx(x, y)
      game.kinds[i] = col_kind[y]
      game.specials[i] = col_special[y]
    }
  }
}

///|
fn has_any_match(kinds : Array[Int]) -> Bool {
  for y = 0; y < board_rows; y = y + 1 {
    let mut x = 0
    while x < board_cols {
      let t = kinds[idx(x, y)]
      if t < 0 {
        x = x + 1
        continue
      }

      let mut len = 1
      while x + len < board_cols && kinds[idx(x + len, y)] == t {
        len = len + 1
      }
      if len >= 3 {
        return true
      }
      x = x + len
    }
  }

  for x = 0; x < board_cols; x = x + 1 {
    let mut y = 0
    while y < board_rows {
      let t = kinds[idx(x, y)]
      if t < 0 {
        y = y + 1
        continue
      }

      let mut len = 1
      while y + len < board_rows && kinds[idx(x, y + len)] == t {
        len = len + 1
      }
      if len >= 3 {
        return true
      }
      y = y + len
    }
  }

  false
}

///|
fn would_swap_match(
  kinds : Array[Int],
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Bool {
  let a = idx(x0, y0)
  let b = idx(x1, y1)
  swapi(kinds, a, b)
  let ok = has_any_match(kinds)
  swapi(kinds, a, b)
  ok
}

///|
fn has_possible_swap(kinds : Array[Int]) -> Bool {
  for y = 0; y < board_rows; y = y + 1 {
    for x = 0; x < board_cols; x = x + 1 {
      if x + 1 < board_cols && would_swap_match(kinds, x, y, x + 1, y) {
        return true
      }
      if y + 1 < board_rows && would_swap_match(kinds, x, y, x, y + 1) {
        return true
      }
    }
  }
  false
}

///|
fn shuffle_board(game : Game) -> Bool {
  let bucket : Array[Int] = Array::make(board_cells, 0)

  let mut tries = 0
  while tries < 160 {
    tries = tries + 1

    for i = 0; i < board_cells; i = i + 1 {
      bucket[i] = game.kinds[i]
    }

    for i = board_cells - 1; i > 0; i = i - 1 {
      let j = @raylib.get_random_value(0, i)
      swapi(bucket, i, j)
    }

    for i = 0; i < board_cells; i = i + 1 {
      game.kinds[i] = bucket[i]
      game.specials[i] = special_none
    }

    if not(has_any_match(game.kinds)) && has_possible_swap(game.kinds) {
      return true
    }
  }

  false
}

///|
fn assign_jelly_targets(game : Game) -> Unit {
  for i = 0; i < board_cells; i = i + 1 {
    game.jelly[i] = 0
  }

  let mut target = base_jelly + (game.level - 1) * jelly_level_bonus
  if target > board_cells {
    target = board_cells
  }

  let mut placed = 0
  while placed < target {
    let p = @raylib.get_random_value(0, board_cells - 1)
    if game.jelly[p] == 0 {
      game.jelly[p] = 1
      placed = placed + 1
    }
  }

  game.jelly_left = target
}

///|
fn fill_board_without_initial_matches(game : Game) -> Unit {
  for y = 0; y < board_rows; y = y + 1 {
    for x = 0; x < board_cols; x = x + 1 {
      let mut t = random_kind()
      let mut retries = 0

      while retries < 40 {
        let mut bad = false

        if x >= 2 {
          let a = game.kinds[idx(x - 1, y)]
          let b = game.kinds[idx(x - 2, y)]
          if a == t && b == t {
            bad = true
          }
        }

        if y >= 2 {
          let a = game.kinds[idx(x, y - 1)]
          let b = game.kinds[idx(x, y - 2)]
          if a == t && b == t {
            bad = true
          }
        }

        if not(bad) {
          break
        }

        t = random_kind()
        retries = retries + 1
      }

      let i = idx(x, y)
      game.kinds[i] = t
      game.specials[i] = special_none
    }
  }
}

///|
fn prepare_level_board(game : Game) -> Unit {
  assign_jelly_targets(game)
  clear_effects(game)

  let mut tries = 0
  while tries < 120 {
    tries = tries + 1
    fill_board_without_initial_matches(game)

    if has_possible_swap(game.kinds) {
      return
    }
  }

  ignore(shuffle_board(game))
}

///|
fn restart_run(game : Game) -> Unit {
  game.level = 1
  game.score = 0
  game.chain_best = 0
  game.moves_left = moves_base
  game.cursor_x = 0
  game.cursor_y = 0
  game.selected = false
  game.hint_active = false
  game.swap_flash_t = 0.0
  prepare_level_board(game)
  game.state = state_play
  set_message(game, "Crush all jelly tiles before moves run out.")
}

///|
fn start_next_level(game : Game) -> Unit {
  game.level = game.level + 1
  game.moves_left = moves_base + (game.level - 1) * moves_level_bonus
  game.cursor_x = 0
  game.cursor_y = 0
  game.selected = false
  game.hint_active = false
  game.swap_flash_t = 0.0
  prepare_level_board(game)
  game.state = state_play
  set_message(game, "Level " + game.level.to_string() + " begins.")
}

///|
fn restart_level(game : Game) -> Unit {
  game.moves_left = moves_base + (game.level - 1) * moves_level_bonus
  game.cursor_x = 0
  game.cursor_y = 0
  game.selected = false
  game.hint_active = false
  game.swap_flash_t = 0.0
  prepare_level_board(game)
  game.state = state_play
  set_message(game, "Level reset.")
}

///|
fn begin_level_clear(game : Game) -> Unit {
  game.state = state_level_clear
  if game.score > game.best_score {
    game.best_score = game.score
  }
  set_message(game, "Sweet! Level cleared.")
}

///|
fn begin_game_over(game : Game) -> Unit {
  game.state = state_game_over
  if game.score > game.best_score {
    game.best_score = game.score
  }
  set_message(game, "Out of moves. Try again.")
}

///|
fn find_hint(game : Game) -> Bool {
  for y = 0; y < board_rows; y = y + 1 {
    for x = 0; x < board_cols; x = x + 1 {
      if x + 1 < board_cols && would_swap_match(game.kinds, x, y, x + 1, y) {
        game.hint_active = true
        game.hint_x0 = x
        game.hint_y0 = y
        game.hint_x1 = x + 1
        game.hint_y1 = y
        game.hint_t = hint_ttl_max
        return true
      }
      if y + 1 < board_rows && would_swap_match(game.kinds, x, y, x, y + 1) {
        game.hint_active = true
        game.hint_x0 = x
        game.hint_y0 = y
        game.hint_x1 = x
        game.hint_y1 = y + 1
        game.hint_t = hint_ttl_max
        return true
      }
    }
  }

  game.hint_active = false
  false
}

///|
fn set_swap_flash(game : Game, x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Unit {
  game.swap_flash_t = 0.42
  game.swap_x0 = x0
  game.swap_y0 = y0
  game.swap_x1 = x1
  game.swap_y1 = y1
}

///|
fn run_cascade(game : Game) -> Int {
  let mut chain = 0

  while true {
    let matched = scan_and_mark_matches(game)
    if matched <= 0 {
      break
    }

    expand_special_marks(game)

    let removed = remove_marked_cells(game)
    if removed <= 0 {
      break
    }

    chain = chain + 1
    game.score = game.score + score_for_removed(removed, chain)
    if chain > game.chain_best {
      game.chain_best = chain
    }

    collapse_and_refill(game)
  }

  chain
}

///|
fn attempt_swap(game : Game, x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Bool {
  if not(in_board(x0, y0)) || not(in_board(x1, y1)) {
    return false
  }

  if not(is_adjacent(x0, y0, x1, y1)) {
    return false
  }

  let a = idx(x0, y0)
  let b = idx(x1, y1)

  swapi(game.kinds, a, b)
  swapi(game.specials, a, b)

  if not(has_any_match(game.kinds)) {
    swapi(game.kinds, a, b)
    swapi(game.specials, a, b)
    set_message(game, "Swap did not make a match.")
    return false
  }

  game.moves_left = game.moves_left - 1
  clear_selection(game)
  game.hint_active = false
  set_swap_flash(game, x0, y0, x1, y1)

  ignore(run_cascade(game))

  if game.jelly_left <= 0 {
    begin_level_clear(game)
    return true
  }

  if game.moves_left <= 0 {
    begin_game_over(game)
    return true
  }

  if not(has_possible_swap(game.kinds)) {
    if shuffle_board(game) {
      set_message(game, "No possible swaps. Board shuffled.")
    } else {
      begin_game_over(game)
    }
  }

  true
}

///|
fn select_or_swap(game : Game, x : Int, y : Int) -> Unit {
  if not(in_board(x, y)) {
    return
  }

  game.cursor_x = x
  game.cursor_y = y
  game.hint_active = false

  if not(game.selected) {
    game.selected = true
    game.sel_x = x
    game.sel_y = y
    return
  }

  if game.sel_x == x && game.sel_y == y {
    clear_selection(game)
    return
  }

  if is_adjacent(game.sel_x, game.sel_y, x, y) {
    ignore(attempt_swap(game, game.sel_x, game.sel_y, x, y))
    clear_selection(game)
    return
  }

  game.sel_x = x
  game.sel_y = y
}

///|
fn move_cursor(game : Game, dx : Int, dy : Int) -> Unit {
  game.cursor_x = clampi(game.cursor_x + dx, 0, board_cols - 1)
  game.cursor_y = clampi(game.cursor_y + dy, 0, board_rows - 1)
}

///|
fn use_hint(game : Game) -> Unit {
  if find_hint(game) {
    set_message(game, "Try this swap.")
  } else {
    set_message(game, "No hints found. Shuffling board...")
    ignore(shuffle_board(game))
  }
}

///|
fn try_manual_shuffle(game : Game) -> Unit {
  if shuffle_board(game) {
    game.moves_left = clampi(game.moves_left - 1, 0, 9999)
    set_message(game, "Board shuffled (-1 move).")
    if game.moves_left <= 0 {
      begin_game_over(game)
    }
  } else {
    begin_game_over(game)
  }
}

///|
fn update_timers(game : Game, dt : Float) -> Unit {
  for i = 0; i < board_cells; i = i + 1 {
    game.flash[i] = maxf(0.0, game.flash[i] - dt * 1.4)
  }

  if game.hint_active {
    game.hint_t = game.hint_t - dt
    if game.hint_t <= 0.0 {
      game.hint_active = false
    }
  }

  if game.message_t > 0.0 {
    game.message_t = game.message_t - dt
  }

  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }

  if game.swap_flash_t > 0.0 {
    game.swap_flash_t = game.swap_flash_t - dt
  }
}
