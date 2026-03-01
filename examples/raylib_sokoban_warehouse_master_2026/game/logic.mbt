///|
fn clear_board(game : @types.Game) -> Unit {
  for i in 0..<game.tiles.length() {
    game.tiles[i] = @types.tile_void
    game.boxes[i] = false
  }
}

///|
fn clear_undo(game : @types.Game) -> Unit {
  game.undo_len = 0
  for undo_elem in game.undo {
    undo_elem.valid = false
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
fn apply_level_rows(
  game : @types.Game,
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
  game.hold_dir = @types.touch_none
  game.repeat_t = 0.0
  game.touch_action_cd = 0.0

  let mut found_player : Bool = false
  game.grid_h = @types.mini(rows.length(), @types.board_rows)
  game.grid_w = 0

  for y in 0..<game.grid_h {
    let row = rows[y]
    if row.length() > game.grid_w {
      game.grid_w = row.length()
    }
  }
  game.grid_w = @types.mini(game.grid_w, @types.board_cols)

  for y in 0..<game.grid_h {
    let row = rows[y]
    for x in 0..<game.grid_w {
      let code : Int = if x < row.length() { row[x] } else { 0 }

      let mut base : Int = @types.tile_void
      let mut has_box : Bool = false

      if code == 2 {
        base = @types.tile_wall
      } else if code == 1 {
        base = @types.tile_floor
      } else if code == 3 {
        base = @types.tile_goal
      } else if code == 4 {
        base = @types.tile_floor
        has_box = true
      } else if code == 5 {
        base = @types.tile_floor
        game.player_x = x
        game.player_y = y
        found_player = true
      } else if code == 6 {
        base = @types.tile_goal
        has_box = true
      } else if code == 7 {
        base = @types.tile_goal
        game.player_x = x
        game.player_y = y
        found_player = true
      }

      @types.set_tile(game, x, y, base)
      @types.set_box(game, x, y, has_box)

      if base == @types.tile_goal {
        game.goals_total = game.goals_total + 1
      }
    }
  }

  if not(found_player) {
    let mut placed : Bool = false
    for y in 0..<game.grid_h {
      for x in 0..<game.grid_w {
        let t = @types.tile_at(game, x, y)
        if t == @types.tile_floor || t == @types.tile_goal {
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
    let gx : Int = @types.clampi(game.grid_w / 2, 0, @types.board_cols - 1)
    let gy : Int = @types.clampi(game.grid_h / 2, 0, @types.board_rows - 1)
    @types.set_tile(game, gx, gy, @types.tile_goal)
    game.goals_total = 1
  }
}

///|
fn level_completed(game : @types.Game) -> Bool {
  if game.goals_total <= 0 {
    return false
  }
  @types.goal_filled_count(game) >= game.goals_total
}

///|
fn direction_delta(dir : Int) -> (Int, Int) {
  if dir == @types.touch_left {
    (-1, 0)
  } else if dir == @types.touch_right {
    (1, 0)
  } else if dir == @types.touch_up {
    (0, -1)
  } else if dir == @types.touch_down {
    (0, 1)
  } else {
    (0, 0)
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
fn burst_cell(
  game : @types.Game,
  cell_x : Int,
  cell_y : Int,
  amount : Int,
  kind : Int,
) -> Unit {
  let cx : Float = Float::from_int(cell_x) + 0.5
  let cy : Float = Float::from_int(cell_y) + 0.5

  for _i in 0..<amount {
    spawn_spark(
      game,
      cx + @types.randf(-0.18, 0.18),
      cy + @types.randf(-0.18, 0.18),
      @types.randf(-2.4, 2.4),
      @types.randf(-2.2, 2.2),
      @types.randf(0.22, 0.85),
      @types.randf(0.05, 0.16),
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
    spark.vy = spark.vy * (1.0 - dt * 1.8) + dt * 1.3
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
fn blocked_feedback(game : @types.Game, x : Int, y : Int) -> Unit {
  game.shake_t = 0.17
  game.message = "Blocked"
  game.message_t = 0.32
  burst_cell(game, x, y, 7, 2)
}

///|
fn attempt_move(game : @types.Game, dx : Int, dy : Int) -> Bool {
  if dx == 0 && dy == 0 {
    return false
  }

  let nx : Int = game.player_x + dx
  let ny : Int = game.player_y + dy

  if nx < 0 || nx >= game.grid_w || ny < 0 || ny >= game.grid_h {
    blocked_feedback(game, game.player_x, game.player_y)
    return false
  }

  let target_tile : Int = @types.tile_at(game, nx, ny)
  if not(@types.walkable_tile(target_tile)) {
    blocked_feedback(game, nx, ny)
    return false
  }

  let step : @types.UndoStep = {
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

  if @types.box_at(game, nx, ny) {
    let bx : Int = nx + dx
    let by : Int = ny + dy

    if bx < 0 || bx >= game.grid_w || by < 0 || by >= game.grid_h {
      blocked_feedback(game, nx, ny)
      return false
    }

    let behind_tile : Int = @types.tile_at(game, bx, by)
    if not(@types.walkable_tile(behind_tile)) || @types.box_at(game, bx, by) {
      blocked_feedback(game, nx, ny)
      return false
    }

    step.pushed_box = true
    step.box_from_x = nx
    step.box_from_y = ny
    step.box_to_x = bx
    step.box_to_y = by

    @types.set_box(game, nx, ny, false)
    @types.set_box(game, bx, by, true)
    game.pushes = game.pushes + 1

    burst_cell(game, nx, ny, 10, 1)
    if @types.tile_at(game, bx, by) == @types.tile_goal {
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
fn undo_move(game : @types.Game) -> Bool {
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
    @types.set_box(game, step.box_to_x, step.box_to_y, false)
    @types.set_box(game, step.box_from_x, step.box_from_y, true)
    burst_cell(game, step.box_from_x, step.box_from_y, 12, 2)
  }

  game.shake_t = 0.08
  game.message = "Undo"
  game.message_t = 0.22

  true
}

///|
fn score_stars(game : @types.Game) -> Int {
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
fn complete_level(game : @types.Game) -> Unit {
  let stars : Int = score_stars(game)
  game.last_level_stars = stars
  game.campaign_stars = game.campaign_stars + stars

  game.total_moves = game.total_moves + game.moves
  game.total_pushes = game.total_pushes + game.pushes
  game.total_elapsed = game.total_elapsed + game.elapsed

  game.shake_t = 0.28
  game.message = "Level clear"
  game.message_t = 1.5

  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if @types.tile_at(game, x, y) == @types.tile_goal {
        burst_cell(game, x, y, 18, 0)
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
fn advance_to_next_level(game : @types.Game) -> Unit {
  let next_id : Int = game.level_index + 1
  if next_id >= game.level_count {
    game.state = @types.state_campaign_clear
    return
  }
  load_level(game, next_id)
}

///|
fn update_active_game(
  game : @types.Game,
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

  if game.state != @types.state_play {
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

  if held_dir == @types.touch_none {
    game.hold_dir = @types.touch_none
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

///|
fn load_level(game : @types.Game, level_id : Int) -> Unit {
  let mut id : Int = level_id
  if id < 0 {
    id = 0
  }
  if id >= game.level_count {
    id = game.level_count - 1
  }

  let v : Int = 0
  let f : Int = 1
  let w : Int = 2
  let g : Int = 3
  let b : Int = 4
  let p : Int = 5

  if id == 0 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, v, v, v],
      [v, w, w, f, f, f, w, w, v, v],
      [w, w, f, f, b, f, f, w, w, v],
      [w, f, f, g, f, g, f, f, w, v],
      [w, f, f, f, p, f, f, f, w, v],
      [w, w, f, f, b, f, f, w, w, v],
      [v, w, w, f, f, f, w, w, v, v],
      [v, v, w, w, w, w, w, v, v, v],
    ]
    apply_level_rows(game, rows, "Dock Warmup", 14)
  } else if id == 1 {
    let rows : Array[Array[Int]] = [
      [v, w, w, w, w, w, w, w, v],
      [w, w, f, f, f, f, f, w, w],
      [w, f, f, b, f, b, f, f, w],
      [w, f, g, f, p, f, g, f, w],
      [w, f, f, b, f, b, f, f, w],
      [w, w, f, f, g, f, f, w, w],
      [v, w, w, w, w, w, w, w, v],
    ]
    apply_level_rows(game, rows, "Twin Lift Hall", 22)
  } else if id == 2 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, w, w, v],
      [w, w, f, f, w, f, f, f, w, w],
      [w, f, f, b, w, g, b, f, f, w],
      [w, f, g, f, p, f, f, g, f, w],
      [w, f, f, b, w, g, b, f, f, w],
      [w, w, f, f, w, f, f, f, w, w],
      [v, w, w, f, f, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Gear Junction", 28)
  } else if id == 3 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, f, w, w, v],
      [w, w, f, f, b, f, b, f, f, w, w],
      [w, f, f, w, f, f, f, w, f, f, w],
      [w, f, g, w, f, p, f, w, g, f, w],
      [w, f, f, w, b, f, b, w, f, f, w],
      [w, w, f, f, f, g, f, f, f, w, w],
      [v, w, w, f, f, f, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Steel Switchback", 34)
  } else if id == 4 {
    let rows : Array[Array[Int]] = [
      [v, w, w, w, w, w, w, w, w, w, v],
      [w, w, f, f, f, g, f, f, f, w, w],
      [w, f, f, b, w, f, w, b, f, f, w],
      [w, f, g, f, w, f, w, f, g, f, w],
      [w, f, f, b, w, p, w, b, f, f, w],
      [w, f, g, f, w, f, w, f, g, f, w],
      [w, f, f, b, w, f, w, b, f, f, w],
      [w, w, f, f, f, g, f, f, f, w, w],
      [v, w, w, w, w, w, w, w, w, w, v],
    ]
    apply_level_rows(game, rows, "Crane Cross", 42)
  } else if id == 5 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, f, w, w, v],
      [w, w, f, b, f, w, f, b, f, w, w],
      [w, f, f, f, f, w, f, f, f, f, w],
      [w, f, g, w, f, p, f, w, g, f, w],
      [w, f, f, f, f, w, f, f, f, f, w],
      [w, w, f, b, f, w, f, b, f, w, w],
      [v, w, w, f, f, g, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Midnight Depot", 44)
  } else if id == 6 {
    let rows : Array[Array[Int]] = [
      [v, w, w, w, w, w, w, w, w, w, w, v],
      [w, w, f, f, f, f, f, f, f, f, w, w],
      [w, f, f, b, f, b, f, b, f, f, f, w],
      [w, f, w, w, f, w, f, w, w, f, f, w],
      [w, f, g, f, f, g, p, f, f, g, f, w],
      [w, f, w, w, f, w, f, w, w, f, f, w],
      [w, f, f, b, f, b, f, b, f, f, f, w],
      [w, w, f, f, f, f, g, f, f, f, w, w],
      [v, w, w, w, w, w, w, w, w, w, w, v],
    ]
    apply_level_rows(game, rows, "Triple Cargo", 52)
  } else if id == 7 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, f, f, w, w, v],
      [w, w, f, f, b, w, b, w, f, f, w, w],
      [w, f, f, g, f, w, f, w, g, f, f, w],
      [w, f, b, f, f, f, p, f, f, b, f, w],
      [w, f, f, g, f, w, f, w, g, f, f, w],
      [w, w, f, f, b, w, b, w, f, f, w, w],
      [v, w, w, f, f, f, f, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Rivet Split", 58)
  } else if id == 8 {
    let rows : Array[Array[Int]] = [
      [v, w, w, w, w, w, w, w, w, w, w, v],
      [w, w, f, f, f, f, g, f, f, f, w, w],
      [w, f, f, b, f, w, f, w, b, f, f, w],
      [w, f, g, f, f, w, f, w, f, g, f, w],
      [w, f, f, w, f, f, p, f, f, w, f, w],
      [w, f, g, f, f, w, f, w, f, g, f, w],
      [w, f, f, b, f, w, f, w, b, f, f, w],
      [w, w, f, f, f, f, g, f, f, f, w, w],
      [v, w, w, w, w, w, w, w, w, w, w, v],
    ]
    apply_level_rows(game, rows, "Relay Loop", 62)
  } else if id == 9 {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, f, f, w, w, v],
      [w, w, f, b, f, b, w, b, f, f, w, w],
      [w, f, f, f, g, f, w, f, g, f, f, w],
      [w, f, w, w, f, f, p, f, f, w, f, w],
      [w, f, f, f, g, f, w, f, g, f, f, w],
      [w, w, f, b, f, b, w, b, f, f, w, w],
      [v, w, w, f, f, f, f, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Night Shift Maze", 68)
  } else if id == 10 {
    let rows : Array[Array[Int]] = [
      [v, w, w, w, w, w, w, w, w, w, w, w, v],
      [w, w, f, f, f, g, f, g, f, f, f, w, w],
      [w, f, f, b, f, f, f, f, f, b, f, f, w],
      [w, f, w, f, w, f, w, f, w, f, w, f, w],
      [w, f, g, f, f, f, p, f, f, f, g, f, w],
      [w, f, w, f, w, f, w, f, w, f, w, f, w],
      [w, f, f, b, f, f, f, f, f, b, f, f, w],
      [w, w, f, f, f, g, f, g, f, f, f, w, w],
      [v, w, w, w, w, w, w, w, w, w, w, w, v],
    ]
    apply_level_rows(game, rows, "Hydraulic Crown", 76)
  } else {
    let rows : Array[Array[Int]] = [
      [v, v, w, w, w, w, w, w, w, w, w, v, v],
      [v, w, w, f, f, f, f, g, f, f, w, w, v],
      [w, w, f, f, b, f, b, f, b, f, f, w, w],
      [w, f, f, w, f, w, f, w, f, w, f, f, w],
      [w, f, g, f, f, f, p, f, f, f, g, f, w],
      [w, f, f, w, f, w, f, w, f, w, f, f, w],
      [w, w, f, f, b, f, b, f, b, f, f, w, w],
      [v, w, w, f, f, f, f, g, f, f, w, w, v],
      [v, v, w, w, w, w, w, w, w, w, w, v, v],
    ]
    apply_level_rows(game, rows, "Master Freight Ring", 84)
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
  game.total_moves = 0
  game.total_pushes = 0
  game.total_elapsed = 0.0
  game.campaign_stars = 0
  load_level(game, 0)
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Read input state into game struct
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

  let start_press : Bool = detect_start_press(game)
  let next_press : Bool = detect_next_press(game)

  if game.state == @types.state_title {
    update_active_game(game, dt, @types.touch_none, false, false)
    if start_press {
      restart_campaign(game)
    }
  } else if game.state == @types.state_play {
    let held_dir : Int = detect_hold_direction(game)
    let undo_press : Bool = detect_undo_press(game)
    let reset_press : Bool = detect_reset_press(game)

    update_active_game(game, dt, held_dir, undo_press, reset_press)
  } else if game.state == @types.state_level_clear {
    update_active_game(game, dt, @types.touch_none, false, false)
    if next_press {
      advance_to_next_level(game)
    }
  } else {
    update_active_game(game, dt, @types.touch_none, false, false)
    if next_press {
      game.state = @types.state_title
    }
  }
}
