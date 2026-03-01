///|
fn clear_board(game : @types.Game) -> Unit {
  for i in 0..<game.board.length() {
    game.board[i] = @types.Empty
  }
}

///|
fn clear_history(game : @types.Game) -> Unit {
  game.hist_len = 0
  for i in 0..<game.hist_x.length() {
    game.hist_x[i] = 0
    game.hist_y[i] = 0
    game.hist_p[i] = @types.Empty
  }
}

///|
fn clear_sparks(game : @types.Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = @types.SparkAI
  }
}

///|
fn clear_last_moves(game : @types.Game) -> Unit {
  game.last_hx = -1
  game.last_hy = -1
  game.last_ax = -1
  game.last_ay = -1
}

///|
fn push_history(
  game : @types.Game,
  x : Int,
  y : Int,
  p : @types.Player,
) -> Unit {
  if game.hist_len >= game.hist_x.length() {
    return
  }

  game.hist_x[game.hist_len] = x
  game.hist_y[game.hist_len] = y
  game.hist_p[game.hist_len] = p
  game.hist_len = game.hist_len + 1
}

///|
fn pop_history(game : @types.Game) -> (Bool, Int, Int, @types.Player) {
  if game.hist_len <= 0 {
    return (false, 0, 0, @types.Empty)
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
  game : @types.Game,
  x : Int,
  y : Int,
  p : @types.Player,
  dx : Int,
  dy : Int,
) -> Int {
  let mut cx : Int = x + dx
  let mut cy : Int = y + dy
  let mut c : Int = 0

  while @types.in_board(cx, cy) && @types.cell_at(game, cx, cy) == p {
    c = c + 1
    cx = cx + dx
    cy = cy + dy
  }

  c
}

///|
fn check_five_from(
  game : @types.Game,
  x : Int,
  y : Int,
  p : @types.Player,
) -> Bool {
  let dirs : Array[(Int, Int)] = [(1, 0), (0, 1), (1, 1), (1, -1)]

  for dir in dirs {
    let (dx, dy) = dir
    let c1 : Int = count_one_side(game, x, y, p, dx, dy)
    let c2 : Int = count_one_side(game, x, y, p, -dx, -dy)

    if 1 + c1 + c2 >= 5 {
      return true
    }
  }

  false
}

///|
fn board_full(game : @types.Game) -> Bool {
  game.move_count >= @types.board_n * @types.board_n
}

///|
fn place_stone(game : @types.Game, x : Int, y : Int, p : @types.Player) -> Bool {
  if game.state != @types.Play {
    return false
  }

  if not(@types.in_board(x, y)) {
    return false
  }

  if @types.cell_at(game, x, y) != @types.Empty {
    return false
  }

  @types.set_cell(game, x, y, p)
  push_history(game, x, y, p)
  game.move_count = game.move_count + 1

  match p {
    @types.Human => {
      game.last_hx = x
      game.last_hy = y
      @types.burst_move(game, x, y, 12, @types.SparkHuman)
    }
    _ => {
      game.last_ax = x
      game.last_ay = y
      @types.burst_move(game, x, y, 12, @types.SparkAI)
    }
  }

  if check_five_from(game, x, y, p) {
    game.state = @types.Result
    game.winner = p
    match p {
      @types.Human => {
        game.human_wins = game.human_wins + 1
        @types.set_message(game, "You win!", 1.6)
      }
      _ => {
        game.ai_wins = game.ai_wins + 1
        @types.set_message(game, "AI wins", 1.6)
      }
    }
    game.shake_t = 0.24
    return true
  }

  if board_full(game) {
    game.state = @types.Result
    game.winner = @types.Empty
    game.draws = game.draws + 1
    @types.set_message(game, "Draw", 1.4)
    return true
  }

  game.turn = match p {
    @types.Human => @types.AI
    _ => @types.Human
  }
  game.ai_delay = if game.turn == @types.AI { 0.26 } else { 0.0 }

  true
}

///|
fn undo_round_step(game : @types.Game) -> Bool {
  let pop = pop_history(game)
  if not(pop.0) {
    return false
  }

  let x : Int = pop.1
  let y : Int = pop.2

  if @types.in_board(x, y) && @types.cell_at(game, x, y) != @types.Empty {
    @types.set_cell(game, x, y, @types.Empty)
    game.move_count = @types.maxi(0, game.move_count - 1)
    @types.burst_move(game, x, y, 8, @types.SparkUndo)
  }

  true
}

///|
fn undo_last_turn(game : @types.Game) -> Bool {
  if game.state != @types.Play {
    @types.set_message(game, "Undo only during play", 0.8)
    return false
  }

  if game.hist_len <= 0 {
    @types.set_message(game, "Nothing to undo", 0.8)
    return false
  }

  if game.turn == @types.AI {
    // Human just moved, rollback one move.
    if not(undo_round_step(game)) {
      return false
    }
    game.turn = @types.Human
  } else {
    // AI just moved, rollback AI + previous human when possible.
    if not(undo_round_step(game)) {
      return false
    }
    ignore(undo_round_step(game))
    game.turn = @types.Human
  }

  @types.clear_hint(game)
  game.ai_delay = 0.0

  // Rebuild last move markers.
  clear_last_moves(game)
  for i in 0..<game.hist_len {
    let p : @types.Player = game.hist_p[i]
    match p {
      @types.Human => {
        game.last_hx = game.hist_x[i]
        game.last_hy = game.hist_y[i]
      }
      @types.AI => {
        game.last_ax = game.hist_x[i]
        game.last_ay = game.hist_y[i]
      }
      _ => ()
    }
  }

  @types.set_message(game, "Undo", 0.6)
  game.shake_t = 0.08

  true
}

///|
fn move_cursor_once(game : @types.Game, dir : @types.Dir) -> Unit {
  if game.state != @types.Play {
    return
  }

  match dir {
    @types.Left =>
      game.cursor_x = @types.clampi(game.cursor_x - 1, 0, @types.board_n - 1)
    @types.Right =>
      game.cursor_x = @types.clampi(game.cursor_x + 1, 0, @types.board_n - 1)
    @types.Up =>
      game.cursor_y = @types.clampi(game.cursor_y - 1, 0, @types.board_n - 1)
    @types.Down =>
      game.cursor_y = @types.clampi(game.cursor_y + 1, 0, @types.board_n - 1)
    @types.DirNone => ()
  }
}

///|
fn update_cursor_hold(
  game : @types.Game,
  dt : Float,
  held_dir : @types.Dir,
) -> Unit {
  if game.state != @types.Play {
    game.hold_dir = @types.DirNone
    game.repeat_t = 0.0
    return
  }

  if held_dir == @types.DirNone {
    game.hold_dir = @types.DirNone
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
fn update_sparks(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.life = spark.life - dt
    if spark.life <= 0.0 {
      spark.active = false
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.vx = spark.vx * (1.0 - dt * 1.8)
    spark.vy = spark.vy * (1.0 - dt * 1.8) + dt * 34.0
  }
}

///|
fn update_timers(game : @types.Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.state == @types.Play {
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
      @types.clear_hint(game)
    }
  }

  update_sparks(game, dt)
}

///|
fn reset_round(game : @types.Game, human_first : Bool) -> Unit {
  clear_board(game)
  clear_history(game)
  clear_sparks(game)
  @types.clear_hint(game)
  clear_last_moves(game)

  game.state = @types.Play
  game.turn = if human_first { @types.Human } else { @types.AI }
  game.winner = @types.Empty
  game.move_count = 0

  game.cursor_x = @types.board_n / 2
  game.cursor_y = @types.board_n / 2

  game.hints_left = 4
  game.ai_delay = if game.turn == @types.AI { 0.35 } else { 0.0 }
  game.game_time = 0.0

  game.hold_dir = @types.DirNone
  game.repeat_t = 0.0
  game.touch_action_cd = 0.0

  @types.set_message(game, "Round started", 0.9)
}
