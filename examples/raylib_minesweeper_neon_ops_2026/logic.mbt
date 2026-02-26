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
fn in_board(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_w && y >= 0 && y < board_h
}

///|
fn idx(x : Int, y : Int) -> Int {
  y * board_w + x
}

///|
fn board_metrics(game : Game) -> (Int, Int, Int) {
  let area_x : Int = board_area_x()
  let area_y : Int = board_area_y()
  let area_w : Int = board_area_w()
  let area_h : Int = board_area_h()

  let tile_x : Int = area_w / board_w
  let tile_y : Int = area_h / board_h

  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 36, 56)

  let mut x0 : Int = area_x + (area_w - board_w * tile) / 2
  let mut y0 : Int = area_y + (area_h - board_h * tile) / 2

  if game.shake_t > 0.0 {
    x0 = x0 + @raylib.get_random_value(-3, 3)
    y0 = y0 + @raylib.get_random_value(-3, 3)
  }

  (x0, y0, tile)
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
      x + randf(-8.0, 8.0),
      y + randf(-8.0, 8.0),
      randf(-200.0, 200.0),
      randf(-230.0, 120.0),
      randf(0.2, 1.0),
      randf(1.4, 4.8),
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
    game.sparks[i].vx = game.sparks[i].vx * (1.0 - dt * 2.3)
    game.sparks[i].vy = game.sparks[i].vy * (1.0 - dt * 2.1) + dt * 170.0
  }
}

///|
fn clear_board(game : Game) -> Unit {
  for i = 0; i < game.cells.length(); i = i + 1 {
    game.cells[i].mine = false
    game.cells[i].revealed = false
    game.cells[i].flagged = false
    game.cells[i].exploded = false
    game.cells[i].around = 0
  }
}

///|
fn adjacent_mines(game : Game, x : Int, y : Int) -> Int {
  let mut n : Int = 0

  for oy = -1; oy <= 1; oy = oy + 1 {
    for ox = -1; ox <= 1; ox = ox + 1 {
      if ox == 0 && oy == 0 {
        continue
      }
      let nx : Int = x + ox
      let ny : Int = y + oy
      if not(in_board(nx, ny)) {
        continue
      }
      if game.cells[idx(nx, ny)].mine {
        n = n + 1
      }
    }
  }

  n
}

///|
fn recompute_around(game : Game) -> Unit {
  for y = 0; y < board_h; y = y + 1 {
    for x = 0; x < board_w; x = x + 1 {
      let i : Int = idx(x, y)
      if game.cells[i].mine {
        game.cells[i].around = -1
      } else {
        game.cells[i].around = adjacent_mines(game, x, y)
      }
    }
  }
}

///|
fn is_safe_seed_cell(seed_x : Int, seed_y : Int, x : Int, y : Int) -> Bool {
  absf(Float::from_int(seed_x - x)) <= 1.0 &&
  absf(Float::from_int(seed_y - y)) <= 1.0
}

///|
fn place_mines(game : Game, safe_x : Int, safe_y : Int) -> Unit {
  let mut placed : Int = 0

  while placed < game.mine_count {
    let x : Int = @raylib.get_random_value(0, board_w - 1)
    let y : Int = @raylib.get_random_value(0, board_h - 1)

    if is_safe_seed_cell(safe_x, safe_y, x, y) {
      continue
    }

    let i : Int = idx(x, y)
    if game.cells[i].mine {
      continue
    }

    game.cells[i].mine = true
    placed = placed + 1
  }

  recompute_around(game)
}

///|
fn start_match(game : Game) -> Unit {
  clear_board(game)
  clear_effects(game)

  game.state = state_play
  game.mode = mode_reveal
  game.first_move = true
  game.frame_seed = game.frame_seed + 1

  game.mine_count = mine_count_default
  game.revealed_safe = 0
  game.flagged_count = 0

  game.cursor_x = board_w / 2
  game.cursor_y = board_h / 2
  game.last_reveal_x = -1
  game.last_reveal_y = -1

  game.lives = lives_default
  game.hints = hints_default
  game.mistakes = 0
  game.combo = 0
  game.combo_best = 0
  game.score = 0
  game.game_t = 0.0
  game.ui_t = 0.0
  game.combo_t = 0.0
  game.shake_t = 0.0

  game.grade = grade_d
  game.win = false
  game.touch_cd = 0.0

  set_msg(game, "Sweep the grid. First reveal is always safe.", 2.4)
}

///|
fn reveal_all_mines(game : Game) -> Unit {
  for i = 0; i < game.cells.length(); i = i + 1 {
    if game.cells[i].mine {
      game.cells[i].revealed = true
    }
  }
}

///|
fn score_for_reveal(around : Int, combo : Int) -> Int {
  let base : Int = if around <= 0 { 18 } else { 12 + around * 8 }
  base + combo * 5
}

///|
fn award_combo(game : Game) -> Unit {
  game.combo = game.combo + 1
  if game.combo > game.combo_best {
    game.combo_best = game.combo
  }
  game.combo_t = 1.2
}

///|
fn reset_combo(game : Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
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
fn reveal_single(game : Game, x : Int, y : Int) -> Bool {
  if not(in_board(x, y)) {
    return false
  }

  let i : Int = idx(x, y)
  if game.cells[i].revealed || game.cells[i].flagged {
    return false
  }

  game.cells[i].revealed = true
  game.last_reveal_x = x
  game.last_reveal_y = y

  let (wx, wy) = cell_world_center(game, x, y)

  if game.cells[i].mine {
    game.cells[i].exploded = true
    game.mistakes = game.mistakes + 1
    game.lives = game.lives - 1
    reset_combo(game)

    burst(game, wx, wy, 28, 2)
    game.shake_t = maxf(game.shake_t, 0.18)

    set_msg(game, "Mine hit!", 1.0)

    if game.lives <= 0 {
      game.win = false
      game.grade = compute_grade(
        game.score,
        game.game_t.to_int(),
        game.mistakes,
        game.lives,
      )
      reveal_all_mines(game)
      game.state = state_result
      set_msg(game, "Mission failed.", 2.0)
    }

    return true
  }

  game.revealed_safe = game.revealed_safe + 1
  award_combo(game)

  let bonus : Int = score_for_reveal(game.cells[i].around, game.combo)
  game.score = game.score + bonus

  burst(game, wx, wy, if game.cells[i].around == 0 { 9 } else { 6 }, 0)
  true
}

///|
fn flood_reveal(game : Game, sx : Int, sy : Int) -> Unit {
  let mut qh : Int = 0
  let mut qt : Int = 0

  game.queue_x[qt] = sx
  game.queue_y[qt] = sy
  qt = qt + 1

  while qh < qt {
    let x : Int = game.queue_x[qh]
    let y : Int = game.queue_y[qh]
    qh = qh + 1

    if not(in_board(x, y)) {
      continue
    }

    let i : Int = idx(x, y)
    if game.cells[i].revealed || game.cells[i].flagged {
      continue
    }

    if not(reveal_single(game, x, y)) {
      continue
    }

    if game.state != state_play {
      return
    }

    if game.cells[i].around != 0 {
      continue
    }

    for oy = -1; oy <= 1; oy = oy + 1 {
      for ox = -1; ox <= 1; ox = ox + 1 {
        if ox == 0 && oy == 0 {
          continue
        }

        let nx : Int = x + ox
        let ny : Int = y + oy
        if not(in_board(nx, ny)) {
          continue
        }

        if qt < game.queue_x.length() {
          game.queue_x[qt] = nx
          game.queue_y[qt] = ny
          qt = qt + 1
        }
      }
    }
  }
}

///|
fn check_clear(game : Game) -> Bool {
  if game.revealed_safe >= safe_cells_total(game) {
    game.win = true
    game.state = state_result

    // Bonus for remaining resources.
    game.score = game.score + game.lives * 180 + game.hints * 120
    game.grade = compute_grade(
      game.score,
      game.game_t.to_int(),
      game.mistakes,
      game.lives,
    )

    if game.score > game.best_score {
      game.best_score = game.score
    }

    set_msg(game, "Sector cleared!", 2.2)
    return true
  }

  false
}

///|
fn reveal_cell(game : Game, x : Int, y : Int) -> Bool {
  if game.state != state_play {
    return false
  }

  if not(in_board(x, y)) {
    return false
  }

  let i0 : Int = idx(x, y)
  if game.cells[i0].flagged {
    set_msg(game, "Flag removed first", 0.8)
    return false
  }

  if game.first_move {
    place_mines(game, x, y)
    game.first_move = false
  }

  if game.cells[i0].revealed {
    return false
  }

  if game.cells[i0].around == 0 && not(game.cells[i0].mine) {
    flood_reveal(game, x, y)
  } else {
    ignore(reveal_single(game, x, y))
  }

  if game.state == state_play {
    ignore(check_clear(game))
  }

  true
}

///|
fn toggle_flag(game : Game, x : Int, y : Int) -> Bool {
  if game.state != state_play {
    return false
  }
  if not(in_board(x, y)) {
    return false
  }

  let i : Int = idx(x, y)
  if game.cells[i].revealed {
    return false
  }

  if game.cells[i].flagged {
    game.cells[i].flagged = false
    game.flagged_count = maxi(0, game.flagged_count - 1)
    set_msg(game, "Flag removed", 0.6)
    return true
  }

  if game.flagged_count >= game.mine_count {
    set_msg(game, "No flags left", 0.8)
    return false
  }

  game.cells[i].flagged = true
  game.flagged_count = game.flagged_count + 1

  let (wx, wy) = cell_world_center(game, x, y)
  burst(game, wx, wy, 6, 1)

  set_msg(game, "Flag set", 0.6)
  true
}

///|
fn safe_hint_target(game : Game) -> (Bool, Int, Int) {
  let mut tries : Int = 0

  while tries < 900 {
    let x : Int = @raylib.get_random_value(0, board_w - 1)
    let y : Int = @raylib.get_random_value(0, board_h - 1)
    let i : Int = idx(x, y)

    if not(game.cells[i].mine) &&
      not(game.cells[i].revealed) &&
      not(game.cells[i].flagged) {
      return (true, x, y)
    }

    tries = tries + 1
  }

  for y = 0; y < board_h; y = y + 1 {
    for x = 0; x < board_w; x = x + 1 {
      let i : Int = idx(x, y)
      if not(game.cells[i].mine) &&
        not(game.cells[i].revealed) &&
        not(game.cells[i].flagged) {
        return (true, x, y)
      }
    }
  }

  (false, 0, 0)
}

///|
fn use_hint(game : Game) -> Bool {
  if game.state != state_play {
    return false
  }

  if game.hints <= 0 {
    set_msg(game, "No hints", 0.8)
    return false
  }

  if game.first_move {
    place_mines(game, game.cursor_x, game.cursor_y)
    game.first_move = false
  }

  let pick = safe_hint_target(game)
  if not(pick.0) {
    return false
  }

  game.hints = game.hints - 1
  game.score = maxi(0, game.score - 60)

  let x : Int = pick.1
  let y : Int = pick.2

  game.cursor_x = x
  game.cursor_y = y

  ignore(reveal_cell(game, x, y))
  set_msg(game, "Hint used", 1.0)

  true
}

///|
fn click_to_cell(game : Game, mx : Float, my : Float) -> (Bool, Int, Int) {
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

  if game.combo_t <= 0.0 {
    game.combo = maxi(0, game.combo - 1)
    game.combo_t = if game.combo > 0 { 0.55 } else { 0.0 }
  }

  update_sparks(game, dt)
}
