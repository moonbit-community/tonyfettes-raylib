///|
fn clear_effects(game : @types.Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = 0
  }
}

///|
fn spawn_spark(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  for spark in game.sparks {
    if spark.active {
      continue
    }

    spark.active = true
    spark.x = x
    spark.y = y
    spark.vx = vx
    spark.vy = vy
    spark.life = life
    spark.size = size
    spark.kind = kind
    break
  }
}

///|
fn burst(game : @types.Game, x : Float, y : Float, n : Int, kind : Int) -> Unit {
  for _i in 0..<n {
    spawn_spark(
      game,
      x + @types.randf(-14.0, 14.0),
      y + @types.randf(-14.0, 14.0),
      @types.randf(-240.0, 240.0),
      @types.randf(-260.0, 120.0),
      @types.randf(0.2, 1.0),
      @types.randf(1.6, 5.4),
      kind,
    )
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
    spark.vx = spark.vx * (1.0 - dt * 2.5)
    spark.vy = spark.vy * (1.0 - dt * 2.2) + dt * 180.0
  }
}

///|
fn clear_board(game : @types.Game) -> Unit {
  for i in 0..<game.board.length() {
    game.board[i] = 0
  }
}

///|
fn copy_board(dst : Array[Int], src : Array[Int]) -> Unit {
  for i in 0..<dst.length() {
    dst[i] = src[i]
  }
}

///|
fn save_undo(game : @types.Game) -> Unit {
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
fn restore_undo(game : @types.Game) -> Bool {
  if not(game.can_undo) {
    @types.set_msg(game, "Nothing to undo", 0.7)
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

  @types.set_msg(game, "Undo", 0.6)
  true
}

///|
fn line_index(line : Int, pos : Int, dir : Int) -> Int {
  if dir == @types.dir_left {
    @types.idx(pos, line)
  } else if dir == @types.dir_right {
    @types.idx(@types.board_n - 1 - pos, line)
  } else if dir == @types.dir_up {
    @types.idx(line, pos)
  } else {
    @types.idx(line, @types.board_n - 1 - pos)
  }
}

///|
fn spawn_tile(game : @types.Game, kind : Int) -> Bool {
  let mut empty_count : Int = 0

  for board_elem in game.board {
    if board_elem == 0 {
      empty_count = empty_count + 1
    }
  }

  if empty_count <= 0 {
    return false
  }

  let pick : Int = @raylib.get_random_value(0, empty_count - 1)
  let mut seen : Int = 0

  for y in 0..< @types.board_n {
    for x in 0..< @types.board_n {
      let i : Int = @types.idx(x, y)
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

        let (wx, wy) = @types.cell_world_center(game, x, y)
        burst(game, wx, wy, if kind == 0 { 10 } else { 8 }, kind)
        return true
      }

      seen = seen + 1
    }
  }

  false
}

///|
fn spawn_blocker(game : @types.Game) -> Bool {
  let mut empty_count : Int = 0

  for board_elem in game.board {
    if board_elem == 0 {
      empty_count = empty_count + 1
    }
  }

  if empty_count <= 0 {
    return false
  }

  let pick : Int = @raylib.get_random_value(0, empty_count - 1)
  let mut seen : Int = 0

  for y in 0..< @types.board_n {
    for x in 0..< @types.board_n {
      let i : Int = @types.idx(x, y)
      if game.board[i] != 0 {
        continue
      }

      if seen == pick {
        game.board[i] = @types.blocker_value
        game.blockers_spawned = game.blockers_spawned + 1

        let (wx, wy) = @types.cell_world_center(game, x, y)
        burst(game, wx, wy, 18, 2)
        game.shake_t = @types.maxf(game.shake_t, 0.14)
        @types.set_msg(game, "Storm debris dropped", 0.9)
        return true
      }

      seen = seen + 1
    }
  }

  false
}

///|
fn start_match(game : @types.Game) -> Unit {
  clear_board(game)
  clear_effects(game)

  game.state = @types.state_play
  game.score = 0
  game.moves = 0
  game.max_tile = 0
  game.target_reached = false
  game.win = false

  game.cursor_x = @types.board_n / 2
  game.cursor_y = @types.board_n / 2

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

  @types.set_msg(game, "Merge to 2048 before the storm locks your board.", 2.2)
}

///|
fn board_has_move(game : @types.Game) -> Bool {
  for y in 0..< @types.board_n {
    for x in 0..< @types.board_n {
      let i : Int = @types.idx(x, y)
      let v : Int = game.board[i]

      if v == 0 {
        return true
      }

      if v <= 0 {
        continue
      }

      if x + 1 < @types.board_n {
        let r : Int = game.board[@types.idx(x + 1, y)]
        if r == v {
          return true
        }
      }
      if y + 1 < @types.board_n {
        let d : Int = game.board[@types.idx(x, y + 1)]
        if d == v {
          return true
        }
      }
    }
  }

  false
}

///|
fn finish_win(game : @types.Game) -> Unit {
  game.state = @types.state_result
  game.win = true

  if game.score > game.best_score {
    game.best_score = game.score
  }

  @types.set_msg(game, "Target reached!", 1.8)
}

///|
fn finish_lose(game : @types.Game) -> Unit {
  game.state = @types.state_result
  game.win = false

  if game.score > game.best_score {
    game.best_score = game.score
  }

  @types.set_msg(game, "No moves left", 1.6)
}

///|
fn apply_post_turn(game : @types.Game) -> Unit {
  if game.max_tile >= @types.target_tile {
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
  game : @types.Game,
  line : Int,
  dir : Int,
) -> (Bool, Int, Int, Int, Int) {
  // returns: changed, score_add, max_seen, charge_add, merges
  for p in 0..< @types.board_n {
    game.line_vals[p] = game.board[line_index(line, p, dir)]
    game.line_out[p] = game.line_vals[p]
  }

  let mut score_add : Int = 0
  let mut max_seen : Int = 0
  let mut charge_add : Int = 0
  let mut merges : Int = 0

  let mut seg_start : Int = 0
  while seg_start < @types.board_n {
    if game.line_vals[seg_start] == @types.blocker_value {
      game.line_out[seg_start] = @types.blocker_value
      seg_start = seg_start + 1
      continue
    }

    let mut seg_end : Int = seg_start
    while seg_end < @types.board_n &&
      game.line_vals[seg_end] != @types.blocker_value {
      seg_end = seg_end + 1
    }

    let pack : Array[Int] = Array::make(@types.board_n, 0)
    let mut len : Int = 0

    for p in seg_start..<seg_end {
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
        charge_add = charge_add + @types.charge_for_merge(merged)
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
    score_add = score_add + @types.bonus_for_chain(merges)
  }

  let mut changed : Bool = false

  for p in 0..< @types.board_n {
    if game.line_vals[p] != game.line_out[p] {
      changed = true
    }
    game.board[line_index(line, p, dir)] = game.line_out[p]
  }

  (changed, score_add, max_seen, charge_add, merges)
}

///|
fn try_move(game : @types.Game, dir : Int) -> Bool {
  if game.state != @types.state_play {
    return false
  }

  save_undo(game)

  let mut changed_any : Bool = false
  let mut score_add : Int = 0
  let mut charge_add : Int = 0
  let mut max_seen : Int = game.max_tile
  let mut merge_count : Int = 0

  for line in 0..< @types.board_n {
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
    @types.set_msg(game, "No movement", 0.45)
    return false
  }

  game.moves = game.moves + 1
  game.score = game.score + score_add
  if game.score > game.best_score {
    game.best_score = game.score
  }

  game.max_tile = max_seen

  game.zap_charge = @types.clampi(game.zap_charge + charge_add + 4, 0, 100)
  if game.zap_charge >= 100 {
    game.zap_ready = true
    game.zap_charge = 100
  }

  if merge_count > 0 {
    game.combo_t = 0.9
    @types.set_msg(game, "Combo x\{merge_count}", 0.7)
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
fn use_zap(game : @types.Game, x : Int, y : Int) -> Bool {
  if game.state != @types.state_play {
    return false
  }

  if not(game.zap_ready) {
    @types.set_msg(game, "Zap not charged", 0.7)
    return false
  }

  if not(@types.in_board(x, y)) {
    return false
  }

  let i : Int = @types.idx(x, y)
  let v : Int = game.board[i]
  if v == 0 {
    @types.set_msg(game, "Empty cell", 0.6)
    return false
  }

  save_undo(game)

  game.board[i] = 0
  game.zap_charge = 0
  game.zap_ready = false

  let (wx, wy) = @types.cell_world_center(game, x, y)
  burst(
    game,
    wx,
    wy,
    if v == @types.blocker_value { 22 } else { 20 },
    2,
  )
  game.shake_t = @types.maxf(game.shake_t, 0.16)

  if v == @types.blocker_value {
    @types.set_msg(game, "Debris vaporized", 0.9)
  } else {
    game.score = game.score + @types.maxi(16, v / 2)
    @types.set_msg(game, "Tile zapped", 0.8)
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
fn update_play(game : @types.Game, dt : Float) -> Unit {
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

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.mouse_x = @raylib.get_mouse_x() |> Float::from_int
  game.mouse_y = @raylib.get_mouse_y() |> Float::from_int
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  if game.state == @types.state_title {
    update_title_input(game)
    update_play(game, dt)
  } else if game.state == @types.state_play {
    update_play_input(game, dt)
    update_play(game, dt)
  } else {
    update_result_input(game)
    update_play(game, dt)
  }
}
