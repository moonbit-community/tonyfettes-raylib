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
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
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
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn idx(x : Int, y : Int) -> Int {
  y * board_n + x
}

///|
fn in_board(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_n && y >= 0 && y < board_n
}

///|
fn board_metrics(game : Game) -> (Int, Int, Int) {
  let area_x : Int = board_area_x()
  let area_y : Int = board_area_y()
  let area_w : Int = board_area_w()
  let area_h : Int = board_area_h()

  let tile_x : Int = area_w / board_n
  let tile_y : Int = area_h / board_n

  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 120, 170)

  let mut bx : Int = area_x + (area_w - board_n * tile) / 2
  let mut by : Int = area_y + (area_h - board_n * tile) / 2

  if game.shake_t > 0.0 {
    bx = bx + @raylib.get_random_value(-3, 3)
    by = by + @raylib.get_random_value(-3, 3)
  }

  (bx, by, tile)
}

///|
fn cell_world_center(game : Game, x : Int, y : Int) -> (Float, Float) {
  let (bx, by, tile) = board_metrics(game)
  (
    Float::from_int(bx + x * tile + tile / 2),
    Float::from_int(by + y * tile + tile / 2),
  )
}

///|
fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
fn clear_effects(game : Game) -> Unit {
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
fn burst(game : Game, x : Float, y : Float, n : Int, kind : Int) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    spawn_spark(
      game,
      x + randf(-14.0, 14.0),
      y + randf(-14.0, 14.0),
      randf(-240.0, 240.0),
      randf(-260.0, 120.0),
      randf(0.2, 1.0),
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
    game.sparks[i].vx = game.sparks[i].vx * (1.0 - dt * 2.5)
    game.sparks[i].vy = game.sparks[i].vy * (1.0 - dt * 2.2) + dt * 180.0
  }
}

///|
fn clear_board(game : Game) -> Unit {
  for i = 0; i < game.board.length(); i = i + 1 {
    game.board[i] = 0
  }
}

///|
fn copy_board(dst : Array[Int], src : Array[Int]) -> Unit {
  for i = 0; i < dst.length(); i = i + 1 {
    dst[i] = src[i]
  }
}

///|
fn save_undo(game : Game) -> Unit {
  copy_board(game.prev_board, game.board)

  game.prev_score = game.score
  game.prev_moves = game.moves
  game.prev_max_tile = game.max_tile
  game.prev_zap_charge = game.zap_charge
  game.prev_zap_ready = game.zap_ready
  game.prev_turns_to_storm = game.turns_to_storm
  game.prev_blockers_spawned = game.blockers_spawned
  game.prev_target_reached = game.target_reached

  game.can_undo = true
}

///|
fn restore_undo(game : Game) -> Bool {
  if not(game.can_undo) {
    set_msg(game, "Nothing to undo", 0.7)
    return false
  }

  copy_board(game.board, game.prev_board)

  game.score = game.prev_score
  game.moves = game.prev_moves
  game.max_tile = game.prev_max_tile
  game.zap_charge = game.prev_zap_charge
  game.zap_ready = game.prev_zap_ready
  game.turns_to_storm = game.prev_turns_to_storm
  game.blockers_spawned = game.prev_blockers_spawned
  game.target_reached = game.prev_target_reached

  game.can_undo = false

  set_msg(game, "Undo", 0.6)
  true
}

///|
fn line_index(line : Int, pos : Int, dir : Int) -> Int {
  if dir == dir_left {
    idx(pos, line)
  } else if dir == dir_right {
    idx(board_n - 1 - pos, line)
  } else if dir == dir_up {
    idx(line, pos)
  } else {
    idx(line, board_n - 1 - pos)
  }
}

///|
fn spawn_tile(game : Game, kind : Int) -> Bool {
  let mut empty_count : Int = 0

  for i = 0; i < game.board.length(); i = i + 1 {
    if game.board[i] == 0 {
      empty_count = empty_count + 1
    }
  }

  if empty_count <= 0 {
    return false
  }

  let pick : Int = @raylib.get_random_value(0, empty_count - 1)
  let mut seen : Int = 0

  for y = 0; y < board_n; y = y + 1 {
    for x = 0; x < board_n; x = x + 1 {
      let i : Int = idx(x, y)
      if game.board[i] != 0 {
        continue
      }

      if seen == pick {
        let roll : Int = @raylib.get_random_value(0, 99)
        let v : Int = if roll < 72 {
          2
        } else if roll < 94 {
          4
        } else if roll < 99 {
          8
        } else {
          16
        }

        game.board[i] = v
        if v > game.max_tile {
          game.max_tile = v
        }

        let (wx, wy) = cell_world_center(game, x, y)
        burst(game, wx, wy, if kind == 0 { 10 } else { 8 }, kind)
        return true
      }

      seen = seen + 1
    }
  }

  false
}

///|
fn spawn_blocker(game : Game) -> Bool {
  let mut empty_count : Int = 0

  for i = 0; i < game.board.length(); i = i + 1 {
    if game.board[i] == 0 {
      empty_count = empty_count + 1
    }
  }

  if empty_count <= 0 {
    return false
  }

  let pick : Int = @raylib.get_random_value(0, empty_count - 1)
  let mut seen : Int = 0

  for y = 0; y < board_n; y = y + 1 {
    for x = 0; x < board_n; x = x + 1 {
      let i : Int = idx(x, y)
      if game.board[i] != 0 {
        continue
      }

      if seen == pick {
        game.board[i] = blocker_value
        game.blockers_spawned = game.blockers_spawned + 1

        let (wx, wy) = cell_world_center(game, x, y)
        burst(game, wx, wy, 18, 2)
        game.shake_t = maxf(game.shake_t, 0.14)
        set_msg(game, "Storm debris dropped", 0.9)
        return true
      }

      seen = seen + 1
    }
  }

  false
}

///|
fn start_match(game : Game) -> Unit {
  clear_board(game)
  clear_effects(game)

  game.state = state_play
  game.score = 0
  game.moves = 0
  game.max_tile = 0
  game.target_reached = false
  game.win = false

  game.cursor_x = board_n / 2
  game.cursor_y = board_n / 2

  game.zap_charge = 0
  game.zap_ready = false

  game.blockers_spawned = 0
  game.turns_to_storm = 4

  game.can_undo = false

  game.game_t = 0.0
  game.ui_t = 0.0
  game.combo_t = 0.0
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.touch_cd = 0.0

  ignore(spawn_tile(game, 0))
  ignore(spawn_tile(game, 0))

  set_msg(game, "Merge to 2048 before the storm locks your board.", 2.2)
}

///|
fn board_has_move(game : Game) -> Bool {
  for y = 0; y < board_n; y = y + 1 {
    for x = 0; x < board_n; x = x + 1 {
      let i : Int = idx(x, y)
      let v : Int = game.board[i]

      if v == 0 {
        return true
      }

      if v <= 0 {
        continue
      }

      if x + 1 < board_n {
        let r : Int = game.board[idx(x + 1, y)]
        if r == v {
          return true
        }
      }
      if y + 1 < board_n {
        let d : Int = game.board[idx(x, y + 1)]
        if d == v {
          return true
        }
      }
    }
  }

  false
}

///|
fn finish_win(game : Game) -> Unit {
  game.state = state_result
  game.win = true

  if game.score > game.best_score {
    game.best_score = game.score
  }

  set_msg(game, "Target reached!", 1.8)
}

///|
fn finish_lose(game : Game) -> Unit {
  game.state = state_result
  game.win = false

  if game.score > game.best_score {
    game.best_score = game.score
  }

  set_msg(game, "No moves left", 1.6)
}

///|
fn apply_post_turn(game : Game) -> Unit {
  if game.max_tile >= target_tile {
    game.target_reached = true
    finish_win(game)
    return
  }

  if not(board_has_move(game)) {
    finish_lose(game)
  }
}

///|
fn process_line(
  game : Game,
  line : Int,
  dir : Int,
) -> (Bool, Int, Int, Int, Int) {
  // returns: changed, score_add, max_seen, charge_add, merges
  for p = 0; p < board_n; p = p + 1 {
    game.line_vals[p] = game.board[line_index(line, p, dir)]
    game.line_out[p] = game.line_vals[p]
  }

  let mut score_add : Int = 0
  let mut max_seen : Int = 0
  let mut charge_add : Int = 0
  let mut merges : Int = 0

  let mut seg_start : Int = 0
  while seg_start < board_n {
    if game.line_vals[seg_start] == blocker_value {
      game.line_out[seg_start] = blocker_value
      seg_start = seg_start + 1
      continue
    }

    let mut seg_end : Int = seg_start
    while seg_end < board_n && game.line_vals[seg_end] != blocker_value {
      seg_end = seg_end + 1
    }

    let pack : Array[Int] = Array::make(board_n, 0)
    let mut len : Int = 0

    for p = seg_start; p < seg_end; p = p + 1 {
      let v : Int = game.line_vals[p]
      if v > 0 {
        pack[len] = v
        len = len + 1
      }
      game.line_out[p] = 0
    }

    let mut read : Int = 0
    let mut write : Int = seg_start

    while read < len {
      let a : Int = pack[read]
      if read + 1 < len && pack[read + 1] == a {
        let merged : Int = a * 2
        game.line_out[write] = merged

        score_add = score_add + merged
        charge_add = charge_add + charge_for_merge(merged)
        merges = merges + 1

        if merged > max_seen {
          max_seen = merged
        }

        read = read + 2
      } else {
        game.line_out[write] = a
        if a > max_seen {
          max_seen = a
        }
        read = read + 1
      }
      write = write + 1
    }

    seg_start = seg_end
  }

  if merges > 1 {
    score_add = score_add + bonus_for_chain(merges)
  }

  let mut changed : Bool = false

  for p = 0; p < board_n; p = p + 1 {
    if game.line_vals[p] != game.line_out[p] {
      changed = true
    }
    game.board[line_index(line, p, dir)] = game.line_out[p]
  }

  (changed, score_add, max_seen, charge_add, merges)
}

///|
fn try_move(game : Game, dir : Int) -> Bool {
  if game.state != state_play {
    return false
  }

  save_undo(game)

  let mut changed_any : Bool = false
  let mut score_add : Int = 0
  let mut charge_add : Int = 0
  let mut max_seen : Int = game.max_tile
  let mut merge_count : Int = 0

  for line = 0; line < board_n; line = line + 1 {
    let r = process_line(game, line, dir)
    if r.0 {
      changed_any = true
    }
    score_add = score_add + r.1
    if r.2 > max_seen {
      max_seen = r.2
    }
    charge_add = charge_add + r.3
    merge_count = merge_count + r.4
  }

  if not(changed_any) {
    game.can_undo = false
    set_msg(game, "No movement", 0.45)
    return false
  }

  game.moves = game.moves + 1
  game.score = game.score + score_add
  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.max_tile = max_seen

  game.zap_charge = clampi(game.zap_charge + charge_add + 4, 0, 100)
  if game.zap_charge >= 100 {
    game.zap_ready = true
    game.zap_charge = 100
  }

  if merge_count > 0 {
    game.combo_t = 0.9
    set_msg(game, "Combo x\{merge_count}", 0.7)
  }

  ignore(spawn_tile(game, 1))

  game.turns_to_storm = game.turns_to_storm - 1
  if game.turns_to_storm <= 0 {
    ignore(spawn_blocker(game))
    game.turns_to_storm = @raylib.get_random_value(4, 7)
  }

  apply_post_turn(game)
  true
}

///|
fn use_zap(game : Game, x : Int, y : Int) -> Bool {
  if game.state != state_play {
    return false
  }

  if not(game.zap_ready) {
    set_msg(game, "Zap not charged", 0.7)
    return false
  }

  if not(in_board(x, y)) {
    return false
  }

  let i : Int = idx(x, y)
  let v : Int = game.board[i]
  if v == 0 {
    set_msg(game, "Empty cell", 0.6)
    return false
  }

  save_undo(game)

  game.board[i] = 0
  game.zap_charge = 0
  game.zap_ready = false

  let (wx, wy) = cell_world_center(game, x, y)
  burst(game, wx, wy, if v == blocker_value { 22 } else { 20 }, 2)
  game.shake_t = maxf(game.shake_t, 0.16)

  if v == blocker_value {
    set_msg(game, "Debris vaporized", 0.9)
  } else {
    game.score = game.score + maxi(16, v / 2)
    set_msg(game, "Tile zapped", 0.8)
  }

  game.moves = game.moves + 1
  ignore(spawn_tile(game, 0))

  game.turns_to_storm = game.turns_to_storm - 1
  if game.turns_to_storm <= 0 {
    ignore(spawn_blocker(game))
    game.turns_to_storm = @raylib.get_random_value(4, 7)
  }

  apply_post_turn(game)
  true
}

///|
fn pointer_cell(game : Game, mx : Float, my : Float) -> (Bool, Int, Int) {
  let (bx, by, tile) = board_metrics(game)

  let x : Int = (mx.to_int() - bx) / tile
  let y : Int = (my.to_int() - by) / tile

  if in_board(x, y) {
    (true, x, y)
  } else {
    (false, 0, 0)
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.game_t = game.game_t + dt
  game.ui_t = game.ui_t + dt

  if game.msg_t > 0.0 {
    game.msg_t = game.msg_t - dt
  }
  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
  }
  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
  }
  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }

  update_sparks(game, dt)
}
