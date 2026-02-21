///|
fn board_index(x : Int, y : Int) -> Int {
  y * board_cols + x
}

///|
fn refill_bag(game : Game) -> Unit {
  for i = 0; i < bag_size; i = i + 1 {
    game.bag[i] = i
  }
  let mut i = bag_size - 1
  while i > 0 {
    let j = @raylib.get_random_value(0, i)
    let tmp = game.bag[i]
    game.bag[i] = game.bag[j]
    game.bag[j] = tmp
    i = i - 1
  }
  game.bag_pos = 0
}

///|
fn take_bag_piece(game : Game) -> Int {
  if game.bag_pos >= bag_size {
    refill_bag(game)
  }
  let kind = game.bag[game.bag_pos]
  game.bag_pos = game.bag_pos + 1
  kind
}

///|
fn collides(game : Game, kind : Int, rot : Int, px : Int, py : Int) -> Bool {
  for i = 0; i < 4; i = i + 1 {
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

///|
fn lock_piece(game : Game) -> Unit {
  for i = 0; i < 4; i = i + 1 {
    let c = piece_cell(game.piece_kind, game.piece_rot, i)
    let x = game.piece_x + c.x
    let y = game.piece_y + c.y
    if y < 0 {
      game.over = true
      continue
    }
    if x >= 0 && x < board_cols && y >= 0 && y < board_rows {
      game.board[board_index(x, y)] = game.piece_kind + 1
    }
  }
}

///|
fn clear_lines(game : Game) -> Int {
  let mut cleared = 0
  let mut y = board_rows - 1
  while y >= 0 {
    let mut full = true
    for x = 0; x < board_cols; x = x + 1 {
      if game.board[board_index(x, y)] == 0 {
        full = false
      }
    }
    if full {
      cleared = cleared + 1
      let mut yy = y
      while yy > 0 {
        for x = 0; x < board_cols; x = x + 1 {
          game.board[board_index(x, yy)] = game.board[board_index(x, yy - 1)]
        }
        yy = yy - 1
      }
      for x = 0; x < board_cols; x = x + 1 {
        game.board[board_index(x, 0)] = 0
      }
      // Keep y the same and recheck after shift.
    } else {
      y = y - 1
    }
  }
  cleared
}

///|
fn recalc_speed(game : Game) -> Unit {
  let raw : Float =
    (0.70 : Float) - Float::from_int(game.level - 1) * (0.05 : Float)
  game.drop_interval = if raw < (0.09 : Float) { (0.09 : Float) } else { raw }
}

///|
fn apply_line_score(game : Game, cleared : Int) -> Unit {
  if cleared <= 0 {
    return
  }
  game.lines = game.lines + cleared
  game.level = 1 + game.lines / 10
  recalc_speed(game)
  let base = match cleared {
    1 => score_single
    2 => score_double
    3 => score_triple
    _ => score_tetris
  }
  game.score = game.score + base * game.level
}

///|
fn spawn_piece(game : Game) -> Unit {
  game.piece_kind = game.next_kind
  game.next_kind = take_bag_piece(game)
  game.piece_rot = 0
  game.piece_x = board_cols / 2
  game.piece_y = 0
  game.hold_used = false
  if collides(game, game.piece_kind, game.piece_rot, game.piece_x, game.piece_y) {
    game.over = true
  }
}

///|
fn hard_drop(game : Game) -> Unit {
  let mut traveled = 0
  while not(collides(game, game.piece_kind, game.piece_rot, game.piece_x, game.piece_y + 1)) {
    game.piece_y = game.piece_y + 1
    traveled = traveled + 1
  }
  game.score = game.score + traveled * 2
  lock_piece(game)
  let cleared = clear_lines(game)
  apply_line_score(game, cleared)
  if not(game.over) {
    spawn_piece(game)
  }
}

///|
fn try_move(game : Game, dx : Int, dy : Int) -> Bool {
  let nx = game.piece_x + dx
  let ny = game.piece_y + dy
  if collides(game, game.piece_kind, game.piece_rot, nx, ny) {
    return false
  }
  game.piece_x = nx
  game.piece_y = ny
  true
}

///|
fn try_rotate(game : Game, dir : Int) -> Unit {
  let new_rot = normalize_rot(game.piece_rot + dir)
  let kicks : Array[Int] = [0, -1, 1, -2, 2]
  for i = 0; i < kicks.length(); i = i + 1 {
    let x = game.piece_x + kicks[i]
    if not(collides(game, game.piece_kind, new_rot, x, game.piece_y)) {
      game.piece_rot = new_rot
      game.piece_x = x
      return
    }
  }
}

///|
fn use_hold(game : Game) -> Unit {
  if game.hold_used {
    return
  }
  let current = game.piece_kind
  if game.hold_kind < 0 {
    game.hold_kind = current
    game.piece_kind = game.next_kind
    game.next_kind = take_bag_piece(game)
  } else {
    game.piece_kind = game.hold_kind
    game.hold_kind = current
  }
  game.piece_rot = 0
  game.piece_x = board_cols / 2
  game.piece_y = 0
  game.hold_used = true
  if collides(game, game.piece_kind, game.piece_rot, game.piece_x, game.piece_y) {
    game.over = true
  }
}

///|
fn reset_game(game : Game) -> Unit {
  for i = 0; i < game.board.length(); i = i + 1 {
    game.board[i] = 0
  }
  game.score = 0
  game.lines = 0
  game.level = 1
  game.drop_timer = 0.0
  game.drop_interval = 0.70
  game.over = false
  game.hold_kind = -1
  game.hold_used = false
  game.bag_pos = bag_size
  game.next_kind = take_bag_piece(game)
  game.piece_kind = take_bag_piece(game)
  game.piece_rot = 0
  game.piece_x = board_cols / 2
  game.piece_y = 0
  recalc_speed(game)
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  if game.over {
    if @raylib.is_key_pressed(@raylib.KeyR) {
      reset_game(game)
    }
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    ignore(try_move(game, -1, 0))
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    ignore(try_move(game, 1, 0))
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyX) {
    try_rotate(game, 1)
  }
  if @raylib.is_key_pressed(@raylib.KeyZ) {
    try_rotate(game, -1)
  }
  if @raylib.is_key_pressed(@raylib.KeyC) {
    use_hold(game)
  }
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    hard_drop(game)
    game.drop_timer = 0.0
    return
  }

  if @raylib.is_key_pressed(@raylib.KeyDown) {
    if try_move(game, 0, 1) {
      game.score = game.score + 1
    }
  }

  let speed_scale : Float =
    if @raylib.is_key_down(@raylib.KeyDown) { (0.08 : Float) } else { 1.0 }
  game.drop_timer = game.drop_timer + dt
  let interval = game.drop_interval * speed_scale
  if game.drop_timer >= interval {
    game.drop_timer = 0.0
    if not(try_move(game, 0, 1)) {
      lock_piece(game)
      let cleared = clear_lines(game)
      apply_line_score(game, cleared)
      if not(game.over) {
        spawn_piece(game)
      }
    }
  }
}
