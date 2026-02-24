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
  y * board_cols + x
}

///|
fn tile_at(game : Game, x : Int, y : Int) -> Int {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    tile_void
  } else {
    game.tiles[board_index(x, y)]
  }
}

///|
fn set_tile(game : Game, x : Int, y : Int, tile : Int) -> Unit {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    return
  }
  game.tiles[board_index(x, y)] = tile
}

///|
fn box_at(game : Game, x : Int, y : Int) -> Bool {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    false
  } else {
    game.boxes[board_index(x, y)]
  }
}

///|
fn set_box(game : Game, x : Int, y : Int, has_box : Bool) -> Unit {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    return
  }
  game.boxes[board_index(x, y)] = has_box
}

///|
fn walkable_tile(tile : Int) -> Bool {
  tile == tile_floor || tile == tile_goal
}

///|
fn clear_board(game : Game) -> Unit {
  for i = 0; i < game.tiles.length(); i = i + 1 {
    game.tiles[i] = tile_void
    game.boxes[i] = false
  }
}

///|
fn clear_undo(game : Game) -> Unit {
  game.undo_len = 0
  for i = 0; i < game.undo.length(); i = i + 1 {
    game.undo[i].valid = false
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
fn apply_level_rows(
  game : Game,
  rows : Array[Array[Int]],
  title : String,
  par : Int,
) -> Unit {
  clear_board(game)
  clear_undo(game)
  clear_sparks(game)

  game.level_name = title
  game.level_par = par
  game.moves = 0
  game.pushes = 0
  game.elapsed = 0.0
  game.goals_total = 0
  game.last_level_stars = 0
  game.shake_t = 0.0
  game.pulse_t = 0.0
  game.hold_dir = touch_none
  game.repeat_t = 0.0
  game.touch_action_cd = 0.0

  let mut found_player : Bool = false
  game.grid_h = mini(rows.length(), board_rows)
  game.grid_w = 0

  for y = 0; y < game.grid_h; y = y + 1 {
    let row = rows[y]
    if row.length() > game.grid_w {
      game.grid_w = row.length()
    }
  }
  game.grid_w = mini(game.grid_w, board_cols)

  for y = 0; y < game.grid_h; y = y + 1 {
    let row = rows[y]
    for x = 0; x < game.grid_w; x = x + 1 {
      let code : Int = if x < row.length() { row[x] } else { 0 }

      let mut base : Int = tile_void
      let mut has_box : Bool = false

      if code == 2 {
        base = tile_wall
      } else if code == 1 {
        base = tile_floor
      } else if code == 3 {
        base = tile_goal
      } else if code == 4 {
        base = tile_floor
        has_box = true
      } else if code == 5 {
        base = tile_floor
        game.player_x = x
        game.player_y = y
        found_player = true
      } else if code == 6 {
        base = tile_goal
        has_box = true
      } else if code == 7 {
        base = tile_goal
        game.player_x = x
        game.player_y = y
        found_player = true
      }

      set_tile(game, x, y, base)
      set_box(game, x, y, has_box)

      if base == tile_goal {
        game.goals_total = game.goals_total + 1
      }
    }
  }

  if not(found_player) {
    let mut placed : Bool = false
    for y = 0; y < game.grid_h; y = y + 1 {
      for x = 0; x < game.grid_w; x = x + 1 {
        let t = tile_at(game, x, y)
        if t == tile_floor || t == tile_goal {
          game.player_x = x
          game.player_y = y
          placed = true
          break
        }
      }
      if placed {
        break
      }
    }
  }

  if game.goals_total <= 0 {
    // Fallback for malformed levels.
    let gx : Int = clampi(game.grid_w / 2, 0, board_cols - 1)
    let gy : Int = clampi(game.grid_h / 2, 0, board_rows - 1)
    set_tile(game, gx, gy, tile_goal)
    game.goals_total = 1
  }
}

///|
fn goal_filled_count(game : Game) -> Int {
  let mut n : Int = 0
  for y = 0; y < game.grid_h; y = y + 1 {
    for x = 0; x < game.grid_w; x = x + 1 {
      if tile_at(game, x, y) == tile_goal && box_at(game, x, y) {
        n = n + 1
      }
    }
  }
  n
}

///|
fn level_completed(game : Game) -> Bool {
  if game.goals_total <= 0 {
    return false
  }
  goal_filled_count(game) >= game.goals_total
}

///|
fn direction_delta(dir : Int) -> (Int, Int) {
  if dir == touch_left {
    (-1, 0)
  } else if dir == touch_right {
    (1, 0)
  } else if dir == touch_up {
    (0, -1)
  } else if dir == touch_down {
    (0, 1)
  } else {
    (0, 0)
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
fn burst_cell(
  game : Game,
  cell_x : Int,
  cell_y : Int,
  amount : Int,
  kind : Int,
) -> Unit {
  let cx : Float = Float::from_int(cell_x) + 0.5
  let cy : Float = Float::from_int(cell_y) + 0.5

  for _i = 0; _i < amount; _i = _i + 1 {
    spawn_spark(
      game,
      cx + randf(-0.18, 0.18),
      cy + randf(-0.18, 0.18),
      randf(-2.4, 2.4),
      randf(-2.2, 2.2),
      randf(0.22, 0.85),
      randf(0.05, 0.16),
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
    game.sparks[i].vy = game.sparks[i].vy * (1.0 - dt * 1.8) + dt * 1.3
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
fn blocked_feedback(game : Game, x : Int, y : Int) -> Unit {
  game.shake_t = 0.17
  game.message = "Blocked"
  game.message_t = 0.32
  burst_cell(game, x, y, 7, 2)
}

///|
fn attempt_move(game : Game, dx : Int, dy : Int) -> Bool {
  if dx == 0 && dy == 0 {
    return false
  }

  let nx : Int = game.player_x + dx
  let ny : Int = game.player_y + dy

  if nx < 0 || nx >= game.grid_w || ny < 0 || ny >= game.grid_h {
    blocked_feedback(game, game.player_x, game.player_y)
    return false
  }

  let target_tile : Int = tile_at(game, nx, ny)
  if not(walkable_tile(target_tile)) {
    blocked_feedback(game, nx, ny)
    return false
  }

  let step : UndoStep = {
    valid: true,
    player_x: game.player_x,
    player_y: game.player_y,
    moves_before: game.moves,
    pushes_before: game.pushes,
    pushed_box: false,
    box_from_x: 0,
    box_from_y: 0,
    box_to_x: 0,
    box_to_y: 0,
  }

  if box_at(game, nx, ny) {
    let bx : Int = nx + dx
    let by : Int = ny + dy

    if bx < 0 || bx >= game.grid_w || by < 0 || by >= game.grid_h {
      blocked_feedback(game, nx, ny)
      return false
    }

    let behind_tile : Int = tile_at(game, bx, by)
    if not(walkable_tile(behind_tile)) || box_at(game, bx, by) {
      blocked_feedback(game, nx, ny)
      return false
    }

    step.pushed_box = true
    step.box_from_x = nx
    step.box_from_y = ny
    step.box_to_x = bx
    step.box_to_y = by

    set_box(game, nx, ny, false)
    set_box(game, bx, by, true)
    game.pushes = game.pushes + 1

    burst_cell(game, nx, ny, 10, 1)
    if tile_at(game, bx, by) == tile_goal {
      burst_cell(game, bx, by, 16, 0)
      game.message = "Crate locked"
      game.message_t = 0.5
    }
  }

  game.player_x = nx
  game.player_y = ny
  game.moves = game.moves + 1
  game.pulse_t = game.pulse_t + 0.13

  push_undo(game, step)
  burst_cell(game, game.player_x, game.player_y, 6, 3)

  true
}

///|
fn undo_move(game : Game) -> Bool {
  if game.undo_len <= 0 {
    return false
  }

  game.undo_len = game.undo_len - 1
  let step = game.undo[game.undo_len]

  if not(step.valid) {
    return false
  }

  game.player_x = step.player_x
  game.player_y = step.player_y
  game.moves = step.moves_before
  game.pushes = step.pushes_before

  if step.pushed_box {
    set_box(game, step.box_to_x, step.box_to_y, false)
    set_box(game, step.box_from_x, step.box_from_y, true)
    burst_cell(game, step.box_from_x, step.box_from_y, 12, 2)
  }

  game.shake_t = 0.08
  game.message = "Undo"
  game.message_t = 0.22

  true
}

///|
fn score_stars(game : Game) -> Int {
  let mut stars : Int = 1

  if game.moves <= game.level_par {
    stars = 3
  } else if game.moves <= game.level_par + 10 {
    stars = 2
  }

  if game.pushes > game.level_par + 12 && stars > 1 {
    stars = stars - 1
  }

  if game.elapsed > 220.0 && stars > 1 {
    stars = stars - 1
  }

  stars
}

///|
fn complete_level(game : Game) -> Unit {
  let stars : Int = score_stars(game)
  game.last_level_stars = stars
  game.campaign_stars = game.campaign_stars + stars

  game.total_moves = game.total_moves + game.moves
  game.total_pushes = game.total_pushes + game.pushes
  game.total_elapsed = game.total_elapsed + game.elapsed

  game.shake_t = 0.28
  game.message = "Level clear"
  game.message_t = 1.5

  for y = 0; y < game.grid_h; y = y + 1 {
    for x = 0; x < game.grid_w; x = x + 1 {
      if tile_at(game, x, y) == tile_goal {
        burst_cell(game, x, y, 18, 0)
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
fn advance_to_next_level(game : Game) -> Unit {
  let next_id : Int = game.level_index + 1
  if next_id >= game.level_count {
    game.state = state_campaign_clear
    return
  }
  load_level(game, next_id)
}

///|
fn update_active_game(
  game : Game,
  dt : Float,
  held_dir : Int,
  press_undo : Bool,
  press_reset : Bool,
) -> Unit {
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

  game.pulse_t = game.pulse_t + dt
  update_sparks(game, dt)

  if game.state != state_play {
    return
  }

  game.elapsed = game.elapsed + dt
  if game.touch_action_cd > 0.0 {
    game.touch_action_cd = game.touch_action_cd - dt
    if game.touch_action_cd < 0.0 {
      game.touch_action_cd = 0.0
    }
  }

  if press_reset && game.touch_action_cd <= 0.0 {
    game.touch_action_cd = 0.2
    reload_level(game)
    return
  }

  if press_undo && game.touch_action_cd <= 0.0 {
    game.touch_action_cd = 0.2
    ignore(undo_move(game))
    return
  }

  if held_dir == touch_none {
    game.hold_dir = touch_none
    game.repeat_t = 0.0
    return
  }

  if game.hold_dir != held_dir {
    game.hold_dir = held_dir
    game.repeat_t = 0.18
    let (dx, dy) = direction_delta(held_dir)
    ignore(attempt_move(game, dx, dy))
  } else {
    game.repeat_t = game.repeat_t - dt
    if game.repeat_t <= 0.0 {
      game.repeat_t = 0.09
      let (dx, dy) = direction_delta(held_dir)
      ignore(attempt_move(game, dx, dy))
    }
  }

  if level_completed(game) {
    complete_level(game)
  }
}
