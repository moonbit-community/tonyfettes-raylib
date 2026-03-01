///|
fn clear_solution_and_cells(game : @types.Game) -> Unit {
  for i in 0..<@types.max_cells {
    game.solution[i] = false
    game.cells[i] = @types.cell_unknown
    game.row_clues[i] = 0
    game.col_clues[i] = 0
  }

  for i in 0..<@types.max_board {
    game.row_clue_counts[i] = 0
    game.col_clue_counts[i] = 0
  }
}

///|
fn clear_undo(game : @types.Game) -> Unit {
  game.undo_len = 0
  for i in 0..<game.undo.length() {
    game.undo[i] = {
      valid: false,
      x: 0,
      y: 0,
      prev_state: @types.cell_unknown,
      prev_mistakes: 0,
      prev_filled_correct: 0,
      prev_filled_wrong: 0,
      prev_hints_left: 0,
      prev_hints_used: 0,
    }
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
    spark.kind = 0
  }
}

///|
fn contribution_correct(cell_state : Int, sol : Bool) -> Int {
  if cell_state == @types.cell_fill {
    if sol { 1 } else { 0 }
  } else {
    0
  }
}

///|
fn contribution_wrong(cell_state : Int, sol : Bool) -> Int {
  if cell_state == @types.cell_fill {
    if not(sol) { 1 } else { 0 }
  } else {
    0
  }
}

///|
fn compute_row_clues(game : @types.Game, y : Int) -> Unit {
  let base : Int = y * @types.max_board

  for k in 0..<@types.max_board {
    game.row_clues[base + k] = 0
  }

  let mut run : Int = 0
  let mut cnt : Int = 0

  for x in 0..<game.grid_w {
    if @types.solution_at(game, x, y) {
      run = run + 1
    } else if run > 0 {
      game.row_clues[base + cnt] = run
      cnt = cnt + 1
      run = 0
    }
  }

  if run > 0 {
    game.row_clues[base + cnt] = run
    cnt = cnt + 1
  }

  if cnt == 0 {
    game.row_clues[base] = 0
    cnt = 1
  }

  game.row_clue_counts[y] = cnt
}

///|
fn compute_col_clues(game : @types.Game, x : Int) -> Unit {
  let base : Int = x * @types.max_board

  for k in 0..<@types.max_board {
    game.col_clues[base + k] = 0
  }

  let mut run : Int = 0
  let mut cnt : Int = 0

  for y in 0..<game.grid_h {
    if @types.solution_at(game, x, y) {
      run = run + 1
    } else if run > 0 {
      game.col_clues[base + cnt] = run
      cnt = cnt + 1
      run = 0
    }
  }

  if run > 0 {
    game.col_clues[base + cnt] = run
    cnt = cnt + 1
  }

  if cnt == 0 {
    game.col_clues[base] = 0
    cnt = 1
  }

  game.col_clue_counts[x] = cnt
}

///|
fn compute_all_clues(game : @types.Game) -> Unit {
  for y in 0..<game.grid_h {
    compute_row_clues(game, y)
  }

  for x in 0..<game.grid_w {
    compute_col_clues(game, x)
  }
}

///|
fn apply_level_rows(
  game : @types.Game,
  rows : Array[Array[Int]],
  title : String,
  par_time : Int,
  mistake_limit : Int,
  hints : Int,
) -> Unit {
  clear_solution_and_cells(game)
  clear_undo(game)
  clear_sparks(game)

  game.level_name = title
  game.level_par_time = par_time
  game.level_mistake_limit = mistake_limit

  game.grid_h = @types.mini(rows.length(), @types.max_board)
  game.grid_w = 0
  for y in 0..<game.grid_h {
    if rows[y].length() > game.grid_w {
      game.grid_w = rows[y].length()
    }
  }
  game.grid_w = @types.mini(game.grid_w, @types.max_board)

  game.solution_total = 0
  for y in 0..<game.grid_h {
    let row = rows[y]
    for x in 0..<game.grid_w {
      let filled : Bool = x < row.length() && row[x] != 0
      @types.set_solution(game, x, y, filled)
      @types.set_cell(game, x, y, @types.cell_unknown)
      if filled {
        game.solution_total = game.solution_total + 1
      }
    }
  }

  compute_all_clues(game)

  game.cursor_x = game.grid_w / 2
  game.cursor_y = game.grid_h / 2
  game.tool_mode = @types.tool_fill

  game.level_time = 0.0
  game.mistakes = 0
  game.hints_left = hints
  game.hints_used = 0
  game.filled_correct = 0
  game.filled_wrong = 0
  game.last_level_stars = 0

  game.message = ""
  game.message_t = 0.0
  game.shake_t = 0.0
  game.hold_dir = @types.dir_none
  game.move_repeat_t = 0.0
  game.touch_action_cd = 0.0
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
fn burst_cell(
  game : @types.Game,
  x : Int,
  y : Int,
  amount : Int,
  kind : Int,
) -> Unit {
  let (cx, cy, tile_f) = @types.world_for_cell(game, x, y)

  for _i in 0..<amount {
    let spread : Float = @types.maxf(6.0, tile_f * 0.22)
    spawn_spark(
      game,
      cx + @types.randf(-spread, spread),
      cy + @types.randf(-spread, spread),
      @types.randf(-120.0, 120.0),
      @types.randf(-130.0, 125.0),
      @types.randf(0.22, 0.88),
      @types.randf(1.8, 5.2),
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
    spark.vx = spark.vx * (1.0 - dt * 1.8)
    spark.vy = spark.vy * (1.0 - dt * 1.8) + dt * 22.0
  }
}

///|
fn push_undo(game : @types.Game, step : @types.UndoStep) -> Unit {
  if game.undo_len >= game.undo.length() {
    for i in 1..<game.undo.length() {
      game.undo[i - 1] = game.undo[i]
    }
    game.undo_len = game.undo.length() - 1
  }

  game.undo[game.undo_len] = step
  game.undo_len = game.undo_len + 1
}

///|
fn score_stars(game : @types.Game) -> Int {
  let mut stars : Int = 3

  if game.level_time > Float::from_int(game.level_par_time) {
    stars = stars - 1
  }

  if game.mistakes > 0 {
    stars = stars - 1
  }

  if game.hints_used > 0 {
    stars = stars - 1
  }

  if stars < 1 {
    stars = 1
  }

  stars
}

///|
fn finalize_level_success(game : @types.Game) -> Unit {
  let stars : Int = score_stars(game)
  game.last_level_stars = stars

  game.total_time = game.total_time + game.level_time
  game.total_mistakes = game.total_mistakes + game.mistakes
  game.total_hints = game.total_hints + game.hints_used
  game.total_stars = game.total_stars + stars
  game.total_completed = game.total_completed + 1
}

///|
fn complete_level(game : @types.Game) -> Unit {
  if game.state != @types.state_play {
    return
  }

  finalize_level_success(game)
  game.message = "Board solved"
  game.message_t = 1.4
  game.shake_t = 0.24

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if @types.solution_at(game, x, y) {
        burst_cell(game, x, y, 12, 0)
      }
    }
  }

  if game.level_index + 1 >= game.level_count {
    game.state = @types.state_campaign_clear
  } else {
    game.state = @types.state_level_clear
  }
}

///|
fn fail_level(game : @types.Game) -> Unit {
  if game.state != @types.state_play {
    return
  }

  game.message = "Too many mistakes"
  game.message_t = 1.2
  game.shake_t = 0.3
  game.state = @types.state_level_fail

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if @types.cell_at(game, x, y) == @types.cell_fill &&
        not(@types.solution_at(game, x, y)) {
        burst_cell(game, x, y, 10, 2)
      }
    }
  }
}

///|
fn apply_cell_state(
  game : @types.Game,
  x : Int,
  y : Int,
  new_state : Int,
  count_mistake : Bool,
  consume_hint : Bool,
  spark_kind : Int,
) -> Bool {
  if game.state != @types.state_play {
    return false
  }

  if not(@types.in_grid(game, x, y)) {
    return false
  }

  let idx : Int = @types.board_index(x, y)
  let prev_state : Int = game.cells[idx]
  if prev_state == new_state {
    return false
  }

  let sol : Bool = game.solution[idx]

  let step : @types.UndoStep = {
    valid: true,
    x,
    y,
    prev_state,
    prev_mistakes: game.mistakes,
    prev_filled_correct: game.filled_correct,
    prev_filled_wrong: game.filled_wrong,
    prev_hints_left: game.hints_left,
    prev_hints_used: game.hints_used,
  }
  push_undo(game, step)

  game.filled_correct = game.filled_correct -
    contribution_correct(prev_state, sol)
  game.filled_wrong = game.filled_wrong - contribution_wrong(prev_state, sol)

  game.cells[idx] = new_state

  game.filled_correct = game.filled_correct +
    contribution_correct(new_state, sol)
  game.filled_wrong = game.filled_wrong + contribution_wrong(new_state, sol)

  if count_mistake {
    if new_state == @types.cell_fill &&
      not(sol) &&
      prev_state != @types.cell_fill {
      game.mistakes = game.mistakes + 1
      game.message = "Wrong fill"
      game.message_t = 0.8
      game.shake_t = 0.1
    } else if new_state == @types.cell_cross &&
      sol &&
      prev_state != @types.cell_cross {
      game.mistakes = game.mistakes + 1
      game.message = "Marked a required cell"
      game.message_t = 0.9
      game.shake_t = 0.12
    }
  }

  if consume_hint {
    game.hints_left = @types.maxi(0, game.hints_left - 1)
    game.hints_used = game.hints_used + 1
    game.message = "Hint used"
    game.message_t = 0.9
  }

  burst_cell(game, x, y, 10, spark_kind)

  if @types.puzzle_solved(game) {
    complete_level(game)
  } else if game.mistakes > game.level_mistake_limit {
    fail_level(game)
  }

  true
}

///|
fn apply_tool_on_cell(
  game : @types.Game,
  x : Int,
  y : Int,
  tool : Int,
) -> Bool {
  if game.state != @types.state_play {
    return false
  }

  let prev : Int = @types.cell_at(game, x, y)

  let next_state : Int = if tool == @types.tool_fill {
    if prev == @types.cell_fill {
      @types.cell_unknown
    } else {
      @types.cell_fill
    }
  } else {
    if prev == @types.cell_cross {
      @types.cell_unknown
    } else {
      @types.cell_cross
    }
  }

  let spark_kind : Int = if tool == @types.tool_fill { 1 } else { 3 }
  let ok : Bool = apply_cell_state(
    game, x, y, next_state, true, false, spark_kind,
  )

  if ok {
    game.cursor_x = x
    game.cursor_y = y
  }

  ok
}

///|
fn apply_tool_at_cursor(game : @types.Game, tool : Int) -> Bool {
  apply_tool_on_cell(game, game.cursor_x, game.cursor_y, tool)
}

///|
fn use_hint(game : @types.Game) -> Bool {
  if game.state != @types.state_play {
    return false
  }
  if game.hints_left <= 0 {
    return false
  }

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if @types.solution_at(game, x, y) &&
        @types.cell_at(game, x, y) != @types.cell_fill {
        game.cursor_x = x
        game.cursor_y = y
        return apply_cell_state(
          game, x, y, @types.cell_fill, false, true, 0,
        )
      }
    }
  }

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if not(@types.solution_at(game, x, y)) &&
        @types.cell_at(game, x, y) == @types.cell_fill {
        game.cursor_x = x
        game.cursor_y = y
        return apply_cell_state(
          game, x, y, @types.cell_cross, false, true, 0,
        )
      }
    }
  }

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if not(@types.solution_at(game, x, y)) &&
        @types.cell_at(game, x, y) == @types.cell_unknown {
        game.cursor_x = x
        game.cursor_y = y
        return apply_cell_state(
          game, x, y, @types.cell_cross, false, true, 0,
        )
      }
    }
  }

  false
}

///|
fn undo_action(game : @types.Game) -> Bool {
  if game.undo_len <= 0 {
    return false
  }

  game.undo_len = game.undo_len - 1
  let step : @types.UndoStep = game.undo[game.undo_len]
  if not(step.valid) {
    return false
  }

  if @types.in_grid(game, step.x, step.y) {
    game.cells[@types.board_index(step.x, step.y)] = step.prev_state
  }

  game.mistakes = step.prev_mistakes
  game.filled_correct = step.prev_filled_correct
  game.filled_wrong = step.prev_filled_wrong
  game.hints_left = step.prev_hints_left
  game.hints_used = step.prev_hints_used

  game.cursor_x = step.x
  game.cursor_y = step.y
  game.state = @types.state_play
  game.message = "Undo"
  game.message_t = 0.45
  game.shake_t = 0.08
  burst_cell(game, step.x, step.y, 8, 2)

  true
}

///|
fn update_frame_timers(game : @types.Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.state == @types.state_play {
    game.level_time = game.level_time + dt
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

  update_sparks(game, dt)
}

///|
fn move_cursor_once(game : @types.Game, dir : Int) -> Unit {
  if game.state != @types.state_play {
    return
  }

  if dir == @types.dir_left {
    game.cursor_x = @types.clampi(game.cursor_x - 1, 0, game.grid_w - 1)
  } else if dir == @types.dir_right {
    game.cursor_x = @types.clampi(game.cursor_x + 1, 0, game.grid_w - 1)
  } else if dir == @types.dir_up {
    game.cursor_y = @types.clampi(game.cursor_y - 1, 0, game.grid_h - 1)
  } else if dir == @types.dir_down {
    game.cursor_y = @types.clampi(game.cursor_y + 1, 0, game.grid_h - 1)
  }
}

///|
fn update_cursor_hold(
  game : @types.Game,
  dt : Float,
  held_dir : Int,
) -> Unit {
  if game.state != @types.state_play {
    game.hold_dir = @types.dir_none
    game.move_repeat_t = 0.0
    return
  }

  if held_dir == @types.dir_none {
    game.hold_dir = @types.dir_none
    game.move_repeat_t = 0.0
    return
  }

  if game.hold_dir != held_dir {
    game.hold_dir = held_dir
    game.move_repeat_t = 0.19
    move_cursor_once(game, held_dir)
  } else {
    game.move_repeat_t = game.move_repeat_t - dt
    if game.move_repeat_t <= 0.0 {
      game.move_repeat_t = 0.095
      move_cursor_once(game, held_dir)
    }
  }
}

///|
fn switch_tool(game : @types.Game) -> Unit {
  if game.tool_mode == @types.tool_fill {
    game.tool_mode = @types.tool_cross
    game.message = "Tool: Mark"
  } else {
    game.tool_mode = @types.tool_fill
    game.message = "Tool: Fill"
  }
  game.message_t = 0.5
}

///|
fn load_level(game : @types.Game, level_id : Int) -> Unit {
  let mut id : Int = level_id
  if id < 0 {
    id = 0
  }
  if id >= game.level_count {
    id = game.level_count - 1
  }

  if id == 0 {
    let rows : Array[Array[Int]] = [[0,0,1,1,0,0,0,0],[0,1,1,1,1,0,0,0],[0,0,1,1,0,0,0,0],[0,0,1,1,0,0,0,0],[0,0,1,1,0,0,0,0],[0,1,1,1,1,0,0,0],[1,1,1,1,1,1,0,0],[0,1,1,1,1,0,0,0]]
    apply_level_rows(game, rows, "Lighthouse Watch", 70, 7, 3)
  } else if id == 1 {
    let rows : Array[Array[Int]] = [[0,0,0,0,1,0,0,0,0],[0,0,0,1,1,1,0,0,0],[0,0,1,1,1,1,1,0,0],[0,1,1,1,1,1,1,1,0],[0,0,0,1,1,1,0,0,0],[1,1,1,1,1,1,1,1,1],[0,0,1,1,1,1,1,0,0],[0,1,1,0,0,0,1,1,0],[1,1,0,0,0,0,0,1,1]]
    apply_level_rows(game, rows, "Tugboat Shift", 82, 8, 3)
  } else if id == 2 {
    let rows : Array[Array[Int]] = [[0,0,0,1,1,1,1,0,0,0],[0,0,1,1,1,1,1,1,0,0],[0,1,1,0,0,1,1,0,0,0],[0,0,1,1,1,1,1,1,0,0],[0,0,0,1,1,1,1,0,0,0],[0,0,0,0,1,1,0,0,0,0],[0,0,0,0,1,1,0,0,0,0],[0,0,1,1,1,1,1,1,0,0],[0,1,1,0,1,1,0,1,1,0],[1,1,0,0,1,1,0,0,1,1]]
    apply_level_rows(game, rows, "Anchor Draft", 96, 9, 3)
  } else if id == 3 {
    let rows : Array[Array[Int]] = [[1,1,1,1,1,0,0,0,0,0],[0,0,0,1,1,0,0,0,0,0],[0,0,0,1,1,0,0,0,0,0],[0,0,0,1,1,0,0,0,0,0],[0,0,0,1,1,0,0,0,0,0],[0,0,0,1,1,1,1,0,0,0],[0,0,0,0,0,1,1,0,0,0],[0,0,0,0,0,1,1,0,0,0],[0,0,0,1,1,1,1,0,0,0],[0,0,0,0,1,0,0,0,0,0]]
    apply_level_rows(game, rows, "Crane Hook", 96, 8, 3)
  } else if id == 4 {
    let rows : Array[Array[Int]] = [[0,0,1,1,1,1,1,1,0,0],[0,1,1,0,0,0,0,1,1,0],[1,1,0,0,0,0,0,0,1,1],[1,1,0,1,1,1,1,0,1,1],[1,1,0,1,0,0,1,0,1,1],[1,1,0,1,1,1,1,0,1,1],[1,1,0,0,0,0,0,0,1,1],[0,1,1,0,0,0,0,1,1,0],[0,0,1,1,1,1,1,1,0,0],[0,0,0,1,1,0,0,0,0,0]]
    apply_level_rows(game, rows, "Cargo Crate", 104, 9, 3)
  } else if id == 5 {
    let rows : Array[Array[Int]] = [[0,0,0,0,0,1,0,0,0,0,0],[0,0,0,0,1,1,1,0,0,0,0],[0,0,0,0,0,1,0,0,0,0,0],[0,0,0,0,0,1,0,0,0,0,0],[0,0,1,1,1,1,1,1,1,0,0],[0,1,1,0,0,0,0,0,1,1,0],[1,1,0,0,1,1,1,0,0,1,1],[0,0,0,1,1,0,0,1,1,0,0],[0,0,1,1,0,0,0,0,1,1,0],[0,1,1,0,0,0,0,0,0,1,1],[1,1,0,0,0,0,0,0,0,0,1]]
    apply_level_rows(game, rows, "Wave Beacon", 118, 10, 3)
  } else if id == 6 {
    let rows : Array[Array[Int]] = [[1,1,1,1,1,1,1,1,1,1,1,1],[0,0,0,0,0,0,1,1,0,0,0,0],[0,0,0,0,0,1,1,1,1,0,0,0],[0,0,0,0,1,1,0,0,1,1,0,0],[1,1,1,1,1,1,1,1,1,1,1,1],[1,1,0,0,0,0,0,0,0,0,1,1],[1,1,1,1,1,1,1,1,1,1,1,1],[0,0,1,1,0,0,0,0,0,0,1,1],[0,0,0,1,1,1,1,1,1,1,0,0],[0,0,0,0,0,1,1,0,0,0,0,0]]
    apply_level_rows(game, rows, "Harbor Bridge", 126, 10, 3)
  } else if id == 7 {
    let rows : Array[Array[Int]] = [[0,0,0,0,1,1,0,0,0,1,1,0],[0,0,0,1,1,1,1,0,1,1,1,1],[0,0,1,1,1,1,1,1,1,1,1,0],[0,1,1,1,0,0,1,1,1,0,0,0],[1,1,1,0,0,0,1,1,0,0,0,0],[0,1,1,0,0,0,1,1,0,0,0,0],[0,0,1,1,0,0,1,1,1,0,0,0],[0,0,0,1,1,1,1,1,1,1,0,0],[0,0,0,0,1,1,0,1,1,0,0,0],[0,0,0,0,0,1,0,0,1,0,0,0]]
    apply_level_rows(game, rows, "Seagull Pass", 132, 11, 3)
  } else if id == 8 {
    let rows : Array[Array[Int]] = [[0,0,0,0,0,0,1,1,0,0,0,0],[0,0,0,0,1,1,1,1,1,1,0,0],[0,0,1,1,1,1,1,1,1,1,1,0],[0,1,1,1,1,1,1,1,1,1,1,1],[1,1,1,1,1,1,1,1,1,1,1,1],[1,1,1,0,0,1,1,1,1,0,0,1],[1,1,1,1,1,1,1,1,1,1,1,1],[0,1,1,1,1,1,1,1,1,1,1,1],[0,0,1,1,1,1,1,1,1,1,1,0],[0,0,0,0,1,1,1,1,1,1,0,0],[0,0,0,0,0,0,1,1,0,0,0,0],[0,0,0,1,1,1,1,1,1,0,0,0]]
    apply_level_rows(game, rows, "Submarine Echo", 142, 12, 2)
  } else if id == 9 {
    let rows : Array[Array[Int]] = [[0,0,1,1,0,0,1,1,0,0,0,0],[1,1,1,1,1,1,1,1,1,1,0,0],[1,1,0,0,1,1,0,0,1,1,0,0],[1,1,0,0,1,1,0,0,1,1,0,0],[1,1,1,1,1,1,1,1,1,1,0,0],[0,0,1,1,0,0,1,1,0,0,1,1],[0,0,0,0,1,1,0,0,1,1,1,1],[0,0,1,1,1,1,1,1,1,1,1,1],[0,0,1,1,0,0,1,1,0,0,1,1],[0,0,1,1,0,0,1,1,0,0,1,1],[0,0,1,1,1,1,1,1,1,1,1,1],[0,0,0,0,1,1,0,0,1,1,0,0]]
    apply_level_rows(game, rows, "Shipyard Gear", 152, 12, 2)
  } else if id == 10 {
    let rows : Array[Array[Int]] = [[0,0,0,0,0,1,1,0,0,0,0,0],[0,0,0,0,1,1,1,1,0,0,0,0],[0,0,0,1,1,1,1,1,1,0,0,0],[0,0,1,1,1,1,1,1,1,1,0,0],[0,1,1,1,1,1,1,1,1,1,1,0],[1,1,1,1,1,1,1,1,1,1,1,1],[0,0,1,0,0,1,1,0,0,1,0,0],[0,0,1,0,0,1,1,0,0,1,0,0],[0,0,1,0,0,1,1,0,0,1,0,0],[0,0,1,1,1,1,1,1,1,1,0,0],[0,0,0,1,1,1,1,1,1,0,0,0],[0,0,0,0,1,1,1,1,0,0,0,0]]
    apply_level_rows(game, rows, "Fleet Signal", 160, 13, 2)
  } else {
    let rows : Array[Array[Int]] = [[1,1,1,1,1,1,1,1,1,1,1,1],[1,0,0,0,0,0,0,0,0,0,0,1],[1,0,1,1,1,1,1,1,1,1,0,1],[1,0,1,0,0,0,0,0,0,1,0,1],[1,0,1,0,1,1,1,1,0,1,0,1],[1,0,1,0,1,0,0,1,0,1,0,1],[1,0,1,0,1,1,1,1,0,1,0,1],[1,0,1,0,0,0,0,0,0,1,0,1],[1,0,1,1,1,1,1,1,1,1,0,1],[1,0,0,0,0,0,0,0,0,0,0,1],[1,1,1,1,1,1,1,1,1,1,1,1],[0,0,0,1,1,1,1,1,1,0,0,0]]
    apply_level_rows(game, rows, "Storm Port", 176, 14, 2)
  }

  game.level_index = id
  game.state = @types.state_play
  game.message = "Level \{id + 1}: \{game.level_name}"
  game.message_t = 1.4
}

///|
fn reload_level(game : @types.Game) -> Unit {
  load_level(game, game.level_index)
}

///|
fn restart_campaign(game : @types.Game) -> Unit {
  game.total_time = 0.0
  game.total_mistakes = 0
  game.total_hints = 0
  game.total_stars = 0
  game.total_completed = 0
  load_level(game, 0)
}

///|
fn advance_level(game : @types.Game) -> Unit {
  if game.level_index + 1 >= game.level_count {
    game.state = @types.state_campaign_clear
    return
  }
  load_level(game, game.level_index + 1)
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  let mouse = @raylib.get_mouse_position()
  game.mouse_x = mouse.x
  game.mouse_y = mouse.y
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
  game.mouse_press = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  let mut tc : Int = @raylib.get_touch_point_count()
  if tc < 0 {
    tc = 0
  }
  game.touch_count = tc

  if @raylib.is_key_pressed(@raylib.KeyF11) {
    @raylib.toggle_borderless_windowed()
  }

  update_frame_timers(game, dt)

  let start_press : Bool = detect_start_press(game)
  let next_press : Bool = detect_next_press(game)
  let reset_press : Bool = detect_reset_press(game)

  if game.state == @types.state_title {
    if start_press {
      restart_campaign(game)
    }
  } else if game.state == @types.state_play {
    let held_dir : Int = detect_held_dir(game)
    update_cursor_hold(game, dt, held_dir)

    if detect_toggle_tool() {
      switch_tool(game)
    }

    let undo_press : Bool = detect_undo_press(game)
    let hint_press : Bool = detect_hint_press(game)
    let fill_press : Bool = detect_fill_press(game)
    let cross_press : Bool = detect_cross_press(game)
    let board_tap = detect_board_tap(game)

    if reset_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.2
      reload_level(game)
    } else if undo_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.16
      ignore(undo_action(game))
    } else if hint_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.2
      ignore(use_hint(game))
    } else if board_tap.0 && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.12
      ignore(
        apply_tool_on_cell(game, board_tap.1, board_tap.2, game.tool_mode),
      )
    } else if fill_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.1
      ignore(apply_tool_at_cursor(game, @types.tool_fill))
    } else if cross_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.1
      ignore(apply_tool_at_cursor(game, @types.tool_cross))
    }
  } else if game.state == @types.state_level_clear {
    if next_press {
      advance_level(game)
    }
  } else if game.state == @types.state_campaign_clear {
    if next_press {
      restart_campaign(game)
    }
  } else if game.state == @types.state_level_fail {
    if reset_press || next_press {
      reload_level(game)
    }
  }
}
