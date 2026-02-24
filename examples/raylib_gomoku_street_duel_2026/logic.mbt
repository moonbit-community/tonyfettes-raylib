///|
fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn board_index(x : Int, y : Int) -> Int {
  y * board_n + x
}

///|
fn in_board(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_n && y >= 0 && y < board_n
}

///|
fn cell_at(game : Game, x : Int, y : Int) -> Int {
  if in_board(x, y) {
    game.board[board_index(x, y)]
  } else {
    player_empty
  }
}

///|
fn set_cell(game : Game, x : Int, y : Int, p : Int) -> Unit {
  if in_board(x, y) {
    game.board[board_index(x, y)] = p
  }
}

///|
fn clear_board(game : Game) -> Unit {
  for i = 0; i < game.board.length(); i = i + 1 {
    game.board[i] = player_empty
  }
}

///|
fn clear_history(game : Game) -> Unit {
  game.hist_len = 0
  for i = 0; i < game.hist_x.length(); i = i + 1 {
    game.hist_x[i] = 0
    game.hist_y[i] = 0
    game.hist_p[i] = player_empty
  }
}

///|
fn clear_sparks(game : Game) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    game.sparks[i].active = false
    game.sparks[i].x = 0.0
    game.sparks[i].y = 0.0
    game.sparks[i].vx = 0.0
    game.sparks[i].vy = 0.0
    game.sparks[i].life = 0.0
    game.sparks[i].size = 0.0
    game.sparks[i].kind = 0
  }
}

///|
fn clear_hint(game : Game) -> Unit {
  game.hint_active = false
  game.hint_ttl = 0.0
  game.hint_x = 0
  game.hint_y = 0
}

///|
fn clear_last_moves(game : Game) -> Unit {
  game.last_hx = -1
  game.last_hy = -1
  game.last_ax = -1
  game.last_ay = -1
}

///|
fn set_message(game : Game, msg : String, ttl : Float) -> Unit {
  game.message = msg
  game.message_t = ttl
}

///|
fn spawn_spark(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if game.sparks[i].active {
      continue
    }

    game.sparks[i].active = true
    game.sparks[i].x = x
    game.sparks[i].y = y
    game.sparks[i].vx = vx
    game.sparks[i].vy = vy
    game.sparks[i].life = life
    game.sparks[i].size = size
    game.sparks[i].kind = kind
    break
  }
}

///|
fn board_metrics(game : Game) -> (Int, Int, Int) {
  let area_x : Int = 24
  let area_y : Int = 22
  let area_w : Int = screen_w - 460
  let area_h : Int = screen_h - 44

  let tile_x : Int = (area_w - 24) / board_n
  let tile_y : Int = (area_h - 24) / board_n

  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 42, 72)

  let mut board_x : Int = area_x + (area_w - board_n * tile) / 2
  let mut board_y : Int = area_y + (area_h - board_n * tile) / 2

  if game.shake_t > 0.0 {
    board_x = board_x + @raylib.get_random_value(-3, 3)
    board_y = board_y + @raylib.get_random_value(-3, 3)
  }

  (board_x, board_y, tile)
}

///|
fn world_center(game : Game, x : Int, y : Int) -> (Float, Float, Float) {
  let (bx, by, tile) = board_metrics(game)
  let cx : Float = Float::from_int(bx + x * tile + tile / 2)
  let cy : Float = Float::from_int(by + y * tile + tile / 2)
  (cx, cy, Float::from_int(tile))
}

///|
fn burst_move(game : Game, x : Int, y : Int, amount : Int, kind : Int) -> Unit {
  let (cx, cy, tilef) = world_center(game, x, y)
  let spread : Float = maxf(8.0, tilef * 0.22)

  for _i = 0; _i < amount; _i = _i + 1 {
    spawn_spark(
      game,
      cx + randf(-spread, spread),
      cy + randf(-spread, spread),
      randf(-150.0, 150.0),
      randf(-160.0, 150.0),
      randf(0.2, 0.9),
      randf(1.6, 5.4),
      kind,
    )
  }
}

///|
fn update_sparks(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    game.sparks[i].life = game.sparks[i].life - dt
    if game.sparks[i].life <= 0.0 {
      game.sparks[i].active = false
      continue
    }

    game.sparks[i].x = game.sparks[i].x + game.sparks[i].vx * dt
    game.sparks[i].y = game.sparks[i].y + game.sparks[i].vy * dt
    game.sparks[i].vx = game.sparks[i].vx * (1.0 - dt * 1.8)
    game.sparks[i].vy = game.sparks[i].vy * (1.0 - dt * 1.8) + dt * 34.0
  }
}

///|
fn reset_round(game : Game, human_first : Bool) -> Unit {
  clear_board(game)
  clear_history(game)
  clear_sparks(game)
  clear_hint(game)
  clear_last_moves(game)

  game.state = state_play
  game.turn = if human_first { player_human } else { player_ai }
  game.winner = player_empty
  game.move_count = 0

  game.cursor_x = board_n / 2
  game.cursor_y = board_n / 2

  game.hints_left = 4
  game.ai_delay = if game.turn == player_ai { 0.35 } else { 0.0 }
  game.game_time = 0.0

  game.hold_dir = dir_none
  game.repeat_t = 0.0
  game.touch_action_cd = 0.0

  set_message(game, "Round started", 0.9)
}

///|
fn push_history(game : Game, x : Int, y : Int, p : Int) -> Unit {
  if game.hist_len >= game.hist_x.length() {
    return
  }

  game.hist_x[game.hist_len] = x
  game.hist_y[game.hist_len] = y
  game.hist_p[game.hist_len] = p
  game.hist_len = game.hist_len + 1
}

///|
fn pop_history(game : Game) -> (Bool, Int, Int, Int) {
  if game.hist_len <= 0 {
    return (false, 0, 0, player_empty)
  }

  game.hist_len = game.hist_len - 1
  (
    true,
    game.hist_x[game.hist_len],
    game.hist_y[game.hist_len],
    game.hist_p[game.hist_len],
  )
}

///|
fn count_one_side(
  game : Game,
  x : Int,
  y : Int,
  p : Int,
  dx : Int,
  dy : Int,
) -> Int {
  let mut cx : Int = x + dx
  let mut cy : Int = y + dy
  let mut c : Int = 0

  while in_board(cx, cy) && cell_at(game, cx, cy) == p {
    c = c + 1
    cx = cx + dx
    cy = cy + dy
  }

  c
}

///|
fn check_five_from(game : Game, x : Int, y : Int, p : Int) -> Bool {
  let dirs : Array[(Int, Int)] = [(1, 0), (0, 1), (1, 1), (1, -1)]

  for i = 0; i < dirs.length(); i = i + 1 {
    let (dx, dy) = dirs[i]
    let c1 : Int = count_one_side(game, x, y, p, dx, dy)
    let c2 : Int = count_one_side(game, x, y, p, -dx, -dy)

    if 1 + c1 + c2 >= 5 {
      return true
    }
  }

  false
}

///|
fn board_full(game : Game) -> Bool {
  game.move_count >= board_n * board_n
}

///|
fn place_stone(game : Game, x : Int, y : Int, p : Int) -> Bool {
  if game.state != state_play {
    return false
  }

  if not(in_board(x, y)) {
    return false
  }

  if cell_at(game, x, y) != player_empty {
    return false
  }

  set_cell(game, x, y, p)
  push_history(game, x, y, p)
  game.move_count = game.move_count + 1

  if p == player_human {
    game.last_hx = x
    game.last_hy = y
    burst_move(game, x, y, 12, 1)
  } else {
    game.last_ax = x
    game.last_ay = y
    burst_move(game, x, y, 12, 0)
  }

  if check_five_from(game, x, y, p) {
    game.state = state_result
    game.winner = p
    if p == player_human {
      game.human_wins = game.human_wins + 1
      set_message(game, "You win!", 1.6)
    } else {
      game.ai_wins = game.ai_wins + 1
      set_message(game, "AI wins", 1.6)
    }
    game.shake_t = 0.24
    return true
  }

  if board_full(game) {
    game.state = state_result
    game.winner = player_empty
    game.draws = game.draws + 1
    set_message(game, "Draw", 1.4)
    return true
  }

  game.turn = if p == player_human { player_ai } else { player_human }
  game.ai_delay = if game.turn == player_ai { 0.26 } else { 0.0 }

  true
}

///|
fn undo_round_step(game : Game) -> Bool {
  let pop = pop_history(game)
  if not(pop.0) {
    return false
  }

  let x : Int = pop.1
  let y : Int = pop.2

  if in_board(x, y) && cell_at(game, x, y) != player_empty {
    set_cell(game, x, y, player_empty)
    game.move_count = maxi(0, game.move_count - 1)
    burst_move(game, x, y, 8, 2)
  }

  true
}

///|
fn undo_last_turn(game : Game) -> Bool {
  if game.state != state_play {
    set_message(game, "Undo only during play", 0.8)
    return false
  }

  if game.hist_len <= 0 {
    set_message(game, "Nothing to undo", 0.8)
    return false
  }

  if game.turn == player_ai {
    // Human just moved, rollback one move.
    if not(undo_round_step(game)) {
      return false
    }
    game.turn = player_human
  } else {
    // AI just moved, rollback AI + previous human when possible.
    if not(undo_round_step(game)) {
      return false
    }
    ignore(undo_round_step(game))
    game.turn = player_human
  }

  clear_hint(game)
  game.ai_delay = 0.0

  // Rebuild last move markers.
  clear_last_moves(game)
  for i = 0; i < game.hist_len; i = i + 1 {
    let p : Int = game.hist_p[i]
    if p == player_human {
      game.last_hx = game.hist_x[i]
      game.last_hy = game.hist_y[i]
    } else if p == player_ai {
      game.last_ax = game.hist_x[i]
      game.last_ay = game.hist_y[i]
    }
  }

  set_message(game, "Undo", 0.6)
  game.shake_t = 0.08

  true
}

///|
fn move_cursor_once(game : Game, dir : Int) -> Unit {
  if game.state != state_play {
    return
  }

  if dir == dir_left {
    game.cursor_x = clampi(game.cursor_x - 1, 0, board_n - 1)
  } else if dir == dir_right {
    game.cursor_x = clampi(game.cursor_x + 1, 0, board_n - 1)
  } else if dir == dir_up {
    game.cursor_y = clampi(game.cursor_y - 1, 0, board_n - 1)
  } else if dir == dir_down {
    game.cursor_y = clampi(game.cursor_y + 1, 0, board_n - 1)
  }
}

///|
fn update_cursor_hold(game : Game, dt : Float, held_dir : Int) -> Unit {
  if game.state != state_play {
    game.hold_dir = dir_none
    game.repeat_t = 0.0
    return
  }

  if held_dir == dir_none {
    game.hold_dir = dir_none
    game.repeat_t = 0.0
    return
  }

  if game.hold_dir != held_dir {
    game.hold_dir = held_dir
    game.repeat_t = 0.2
    move_cursor_once(game, held_dir)
  } else {
    game.repeat_t = game.repeat_t - dt
    if game.repeat_t <= 0.0 {
      game.repeat_t = 0.095
      move_cursor_once(game, held_dir)
    }
  }
}

///|
fn update_timers(game : Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.state == state_play {
    game.game_time = game.game_time + dt
  }

  if game.ai_delay > 0.0 {
    game.ai_delay = game.ai_delay - dt
    if game.ai_delay < 0.0 {
      game.ai_delay = 0.0
    }
  }

  if game.message_t > 0.0 {
    game.message_t = game.message_t - dt
    if game.message_t < 0.0 {
      game.message_t = 0.0
    }
  }

  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
    if game.shake_t < 0.0 {
      game.shake_t = 0.0
    }
  }

  if game.touch_action_cd > 0.0 {
    game.touch_action_cd = game.touch_action_cd - dt
    if game.touch_action_cd < 0.0 {
      game.touch_action_cd = 0.0
    }
  }

  if game.hint_active {
    game.hint_ttl = game.hint_ttl - dt
    if game.hint_ttl <= 0.0 {
      clear_hint(game)
    }
  }

  update_sparks(game, dt)
}
