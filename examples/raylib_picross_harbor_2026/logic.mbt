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
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn board_index(x : Int, y : Int) -> Int {
  y * max_board + x
}

///|
fn in_grid(game : Game, x : Int, y : Int) -> Bool {
  x >= 0 && x < game.grid_w && y >= 0 && y < game.grid_h
}

///|
fn solution_at(game : Game, x : Int, y : Int) -> Bool {
  if not(in_grid(game, x, y)) {
    false
  } else {
    game.solution[board_index(x, y)]
  }
}

///|
fn cell_at(game : Game, x : Int, y : Int) -> Int {
  if not(in_grid(game, x, y)) {
    cell_unknown
  } else {
    game.cells[board_index(x, y)]
  }
}

///|
fn set_solution(game : Game, x : Int, y : Int, v : Bool) -> Unit {
  if in_grid(game, x, y) {
    game.solution[board_index(x, y)] = v
  }
}

///|
fn set_cell(game : Game, x : Int, y : Int, state : Int) -> Unit {
  if in_grid(game, x, y) {
    game.cells[board_index(x, y)] = state
  }
}

///|
fn clear_solution_and_cells(game : Game) -> Unit {
  for i = 0; i < max_cells; i = i + 1 {
    game.solution[i] = false
    game.cells[i] = cell_unknown
    game.row_clues[i] = 0
    game.col_clues[i] = 0
  }

  for i = 0; i < max_board; i = i + 1 {
    game.row_clue_counts[i] = 0
    game.col_clue_counts[i] = 0
  }
}

///|
fn clear_undo(game : Game) -> Unit {
  game.undo_len = 0
  for i = 0; i < game.undo.length(); i = i + 1 {
    game.undo[i] = {
      valid: false,
      x: 0,
      y: 0,
      prev_state: cell_unknown,
      prev_mistakes: 0,
      prev_filled_correct: 0,
      prev_filled_wrong: 0,
      prev_hints_left: 0,
      prev_hints_used: 0,
    }
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
fn contribution_correct(cell_state : Int, sol : Bool) -> Int {
  if cell_state == cell_fill && sol {
    1
  } else {
    0
  }
}

///|
fn contribution_wrong(cell_state : Int, sol : Bool) -> Int {
  if cell_state == cell_fill && not(sol) {
    1
  } else {
    0
  }
}

///|
fn compute_row_clues(game : Game, y : Int) -> Unit {
  let base : Int = y * max_board

  for k = 0; k < max_board; k = k + 1 {
    game.row_clues[base + k] = 0
  }

  let mut run : Int = 0
  let mut cnt : Int = 0

  for x = 0; x < game.grid_w; x = x + 1 {
    if solution_at(game, x, y) {
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
fn compute_col_clues(game : Game, x : Int) -> Unit {
  let base : Int = x * max_board

  for k = 0; k < max_board; k = k + 1 {
    game.col_clues[base + k] = 0
  }

  let mut run : Int = 0
  let mut cnt : Int = 0

  for y = 0; y < game.grid_h; y = y + 1 {
    if solution_at(game, x, y) {
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
fn compute_all_clues(game : Game) -> Unit {
  for y = 0; y < game.grid_h; y = y + 1 {
    compute_row_clues(game, y)
  }

  for x = 0; x < game.grid_w; x = x + 1 {
    compute_col_clues(game, x)
  }
}

///|
fn apply_level_rows(
  game : Game,
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

  game.grid_h = mini(rows.length(), max_board)
  game.grid_w = 0
  for y = 0; y < game.grid_h; y = y + 1 {
    if rows[y].length() > game.grid_w {
      game.grid_w = rows[y].length()
    }
  }
  game.grid_w = mini(game.grid_w, max_board)

  game.solution_total = 0
  for y = 0; y < game.grid_h; y = y + 1 {
    let row = rows[y]
    for x = 0; x < game.grid_w; x = x + 1 {
      let filled : Bool = x < row.length() && row[x] != 0
      set_solution(game, x, y, filled)
      set_cell(game, x, y, cell_unknown)
      if filled {
        game.solution_total = game.solution_total + 1
      }
    }
  }

  compute_all_clues(game)

  game.cursor_x = game.grid_w / 2
  game.cursor_y = game.grid_h / 2
  game.tool_mode = tool_fill

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
  game.hold_dir = dir_none
  game.move_repeat_t = 0.0
  game.touch_action_cd = 0.0
}

///|
fn max_row_clues(game : Game) -> Int {
  let mut out : Int = 1
  for y = 0; y < game.grid_h; y = y + 1 {
    if game.row_clue_counts[y] > out {
      out = game.row_clue_counts[y]
    }
  }
  out
}

///|
fn max_col_clues(game : Game) -> Int {
  let mut out : Int = 1
  for x = 0; x < game.grid_w; x = x + 1 {
    if game.col_clue_counts[x] > out {
      out = game.col_clue_counts[x]
    }
  }
  out
}

///|
fn board_metrics(game : Game) -> (Int, Int, Int, Int, Int, Int, Int) {
  let area_x : Int = 26
  let area_y : Int = 24
  let area_w : Int = screen_w - 472
  let area_h : Int = screen_h - 38

  let clue_l : Int = max_row_clues(game)
  let clue_t : Int = max_col_clues(game)

  let den_w : Int = maxi(1, game.grid_w + clue_l)
  let den_h : Int = maxi(1, game.grid_h + clue_t)

  let tile_x : Int = (area_w - 30) / den_w
  let tile_y : Int = (area_h - 30) / den_h

  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 24, 68)

  let total_w : Int = den_w * tile
  let total_h : Int = den_h * tile

  let mut origin_x : Int = area_x + (area_w - total_w) / 2
  let mut origin_y : Int = area_y + (area_h - total_h) / 2

  if game.shake_t > 0.0 {
    origin_x = origin_x + @raylib.get_random_value(-2, 2)
    origin_y = origin_y + @raylib.get_random_value(-2, 2)
  }

  let board_x : Int = origin_x + clue_l * tile
  let board_y : Int = origin_y + clue_t * tile

  (board_x, board_y, tile, clue_l, clue_t, origin_x, origin_y)
}

///|
fn row_solved(game : Game, y : Int) -> Bool {
  for x = 0; x < game.grid_w; x = x + 1 {
    let sol : Bool = solution_at(game, x, y)
    let state : Int = cell_at(game, x, y)

    if sol && state != cell_fill {
      return false
    }

    if not(sol) && state == cell_fill {
      return false
    }
  }

  true
}

///|
fn col_solved(game : Game, x : Int) -> Bool {
  for y = 0; y < game.grid_h; y = y + 1 {
    let sol : Bool = solution_at(game, x, y)
    let state : Int = cell_at(game, x, y)

    if sol && state != cell_fill {
      return false
    }

    if not(sol) && state == cell_fill {
      return false
    }
  }

  true
}

///|
fn puzzle_solved(game : Game) -> Bool {
  game.filled_correct >= game.solution_total && game.filled_wrong == 0
}

///|
fn world_for_cell(game : Game, x : Int, y : Int) -> (Float, Float, Float) {
  let (board_x, board_y, tile, _, _, _, _) = board_metrics(game)
  let cx : Float = Float::from_int(board_x + x * tile + tile / 2)
  let cy : Float = Float::from_int(board_y + y * tile + tile / 2)
  (cx, cy, Float::from_int(tile))
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
fn burst_cell(game : Game, x : Int, y : Int, amount : Int, kind : Int) -> Unit {
  let (cx, cy, tile_f) = world_for_cell(game, x, y)

  for _i = 0; _i < amount; _i = _i + 1 {
    let spread : Float = maxf(6.0, tile_f * 0.22)
    spawn_spark(
      game,
      cx + randf(-spread, spread),
      cy + randf(-spread, spread),
      randf(-120.0, 120.0),
      randf(-130.0, 125.0),
      randf(0.22, 0.88),
      randf(1.8, 5.2),
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
    game.sparks[i].vy = game.sparks[i].vy * (1.0 - dt * 1.8) + dt * 22.0
  }
}

///|
fn push_undo(game : Game, step : UndoStep) -> Unit {
  if game.undo_len >= game.undo.length() {
    for i = 1; i < game.undo.length(); i = i + 1 {
      game.undo[i - 1] = game.undo[i]
    }
    game.undo_len = game.undo.length() - 1
  }

  game.undo[game.undo_len] = step
  game.undo_len = game.undo_len + 1
}

///|
fn score_stars(game : Game) -> Int {
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
fn finalize_level_success(game : Game) -> Unit {
  let stars : Int = score_stars(game)
  game.last_level_stars = stars

  game.total_time = game.total_time + game.level_time
  game.total_mistakes = game.total_mistakes + game.mistakes
  game.total_hints = game.total_hints + game.hints_used
  game.total_stars = game.total_stars + stars
  game.total_completed = game.total_completed + 1
}

///|
fn complete_level(game : Game) -> Unit {
  if game.state != state_play {
    return
  }

  finalize_level_success(game)
  game.message = "Board solved"
  game.message_t = 1.4
  game.shake_t = 0.24

  for y = 0; y < game.grid_h; y = y + 1 {
    for x = 0; x < game.grid_w; x = x + 1 {
      if solution_at(game, x, y) {
        burst_cell(game, x, y, 12, 0)
      }
    }
  }

  if game.level_index + 1 >= game.level_count {
    game.state = state_campaign_clear
  } else {
    game.state = state_level_clear
  }
}

///|
fn fail_level(game : Game) -> Unit {
  if game.state != state_play {
    return
  }

  game.message = "Too many mistakes"
  game.message_t = 1.2
  game.shake_t = 0.3
  game.state = state_level_fail

  for y = 0; y < game.grid_h; y = y + 1 {
    for x = 0; x < game.grid_w; x = x + 1 {
      if cell_at(game, x, y) == cell_fill && not(solution_at(game, x, y)) {
        burst_cell(game, x, y, 10, 2)
      }
    }
  }
}

///|
fn apply_cell_state(
  game : Game,
  x : Int,
  y : Int,
  new_state : Int,
  count_mistake : Bool,
  consume_hint : Bool,
  spark_kind : Int,
) -> Bool {
  if game.state != state_play {
    return false
  }

  if not(in_grid(game, x, y)) {
    return false
  }

  let idx : Int = board_index(x, y)
  let prev_state : Int = game.cells[idx]
  if prev_state == new_state {
    return false
  }

  let sol : Bool = game.solution[idx]

  let step : UndoStep = {
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
    if new_state == cell_fill && not(sol) && prev_state != cell_fill {
      game.mistakes = game.mistakes + 1
      game.message = "Wrong fill"
      game.message_t = 0.8
      game.shake_t = 0.1
    } else if new_state == cell_cross && sol && prev_state != cell_cross {
      game.mistakes = game.mistakes + 1
      game.message = "Marked a required cell"
      game.message_t = 0.9
      game.shake_t = 0.12
    }
  }

  if consume_hint {
    game.hints_left = maxi(0, game.hints_left - 1)
    game.hints_used = game.hints_used + 1
    game.message = "Hint used"
    game.message_t = 0.9
  }

  burst_cell(game, x, y, 10, spark_kind)

  if puzzle_solved(game) {
    complete_level(game)
  } else if game.mistakes > game.level_mistake_limit {
    fail_level(game)
  }

  true
}

///|
fn apply_tool_on_cell(game : Game, x : Int, y : Int, tool : Int) -> Bool {
  if game.state != state_play {
    return false
  }

  let prev : Int = cell_at(game, x, y)

  let mut next_state : Int = cell_unknown
  if tool == tool_fill {
    next_state = if prev == cell_fill { cell_unknown } else { cell_fill }
  } else {
    next_state = if prev == cell_cross { cell_unknown } else { cell_cross }
  }

  let spark_kind : Int = if tool == tool_fill { 1 } else { 3 }
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
fn apply_tool_at_cursor(game : Game, tool : Int) -> Bool {
  apply_tool_on_cell(game, game.cursor_x, game.cursor_y, tool)
}

///|
fn use_hint(game : Game) -> Bool {
  if game.state != state_play || game.hints_left <= 0 {
    return false
  }

  // Priority 1: fill required cells that are not filled.
  for y = 0; y < game.grid_h; y = y + 1 {
    for x = 0; x < game.grid_w; x = x + 1 {
      if solution_at(game, x, y) && cell_at(game, x, y) != cell_fill {
        game.cursor_x = x
        game.cursor_y = y
        return apply_cell_state(game, x, y, cell_fill, false, true, 0)
      }
    }
  }

  // Priority 2: remove wrong fills by setting cross.
  for y = 0; y < game.grid_h; y = y + 1 {
    for x = 0; x < game.grid_w; x = x + 1 {
      if not(solution_at(game, x, y)) && cell_at(game, x, y) == cell_fill {
        game.cursor_x = x
        game.cursor_y = y
        return apply_cell_state(game, x, y, cell_cross, false, true, 0)
      }
    }
  }

  // Priority 3: suggest a non-solution cross.
  for y = 0; y < game.grid_h; y = y + 1 {
    for x = 0; x < game.grid_w; x = x + 1 {
      if not(solution_at(game, x, y)) && cell_at(game, x, y) == cell_unknown {
        game.cursor_x = x
        game.cursor_y = y
        return apply_cell_state(game, x, y, cell_cross, false, true, 0)
      }
    }
  }

  false
}

///|
fn undo_action(game : Game) -> Bool {
  if game.undo_len <= 0 {
    return false
  }

  game.undo_len = game.undo_len - 1
  let step : UndoStep = game.undo[game.undo_len]
  if not(step.valid) {
    return false
  }

  if in_grid(game, step.x, step.y) {
    game.cells[board_index(step.x, step.y)] = step.prev_state
  }

  game.mistakes = step.prev_mistakes
  game.filled_correct = step.prev_filled_correct
  game.filled_wrong = step.prev_filled_wrong
  game.hints_left = step.prev_hints_left
  game.hints_used = step.prev_hints_used

  game.cursor_x = step.x
  game.cursor_y = step.y
  game.state = state_play
  game.message = "Undo"
  game.message_t = 0.45
  game.shake_t = 0.08
  burst_cell(game, step.x, step.y, 8, 2)

  true
}

///|
fn update_frame_timers(game : Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.state == state_play {
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
fn move_cursor_once(game : Game, dir : Int) -> Unit {
  if game.state != state_play {
    return
  }

  if dir == dir_left {
    game.cursor_x = clampi(game.cursor_x - 1, 0, game.grid_w - 1)
  } else if dir == dir_right {
    game.cursor_x = clampi(game.cursor_x + 1, 0, game.grid_w - 1)
  } else if dir == dir_up {
    game.cursor_y = clampi(game.cursor_y - 1, 0, game.grid_h - 1)
  } else if dir == dir_down {
    game.cursor_y = clampi(game.cursor_y + 1, 0, game.grid_h - 1)
  }
}

///|
fn update_cursor_hold(game : Game, dt : Float, held_dir : Int) -> Unit {
  if game.state != state_play {
    game.hold_dir = dir_none
    game.move_repeat_t = 0.0
    return
  }

  if held_dir == dir_none {
    game.hold_dir = dir_none
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
fn switch_tool(game : Game) -> Unit {
  if game.tool_mode == tool_fill {
    game.tool_mode = tool_cross
    game.message = "Tool: Mark"
  } else {
    game.tool_mode = tool_fill
    game.message = "Tool: Fill"
  }
  game.message_t = 0.5
}
