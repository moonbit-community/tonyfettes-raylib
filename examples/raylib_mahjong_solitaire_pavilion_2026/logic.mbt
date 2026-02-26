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
fn idx(x : Int, y : Int) -> Int {
  (y - 1) * max_cols + (x - 1)
}

///|
fn in_board(game : Game, x : Int, y : Int) -> Bool {
  x >= 1 && x <= game.board_w && y >= 1 && y <= game.board_h
}

///|
fn active_at(game : Game, x : Int, y : Int) -> Bool {
  if in_board(game, x, y) {
    game.active[idx(x, y)]
  } else {
    false
  }
}

///|
fn cell_at(game : Game, x : Int, y : Int) -> Int {
  if in_board(game, x, y) && game.active[idx(x, y)] {
    game.cells[idx(x, y)]
  } else {
    0
  }
}

///|
fn set_cell(game : Game, x : Int, y : Int, value : Int) -> Unit {
  if in_board(game, x, y) && game.active[idx(x, y)] {
    game.cells[idx(x, y)] = value
  }
}

///|
fn clear_board(game : Game) -> Unit {
  for i = 0; i < game.active.length(); i = i + 1 {
    game.active[i] = false
    game.cells[i] = 0
  }
}

///|
fn clear_undo(game : Game) -> Unit {
  game.undo_len = 0
  for i = 0; i < game.undo.length(); i = i + 1 {
    game.undo[i] = {
      valid: false,
      x1: 0,
      y1: 0,
      kind1: 0,
      x2: 0,
      y2: 0,
      kind2: 0,
      prev_score: 0,
      prev_combo: 0,
      prev_timer: 0.0,
      prev_remaining: 0,
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
fn clear_selection(game : Game) -> Unit {
  game.select_active = false
  game.select_x = 1
  game.select_y = 1
}

///|
fn clear_hint(game : Game) -> Unit {
  game.hint_active = false
  game.hint_ttl = 0.0
}

///|
fn board_metrics(game : Game) -> (Int, Int, Int) {
  let area_x : Int = 24
  let area_y : Int = 22
  let area_w : Int = screen_w - 460
  let area_h : Int = screen_h - 44

  let safe_w : Int = maxi(1, game.board_w)
  let safe_h : Int = maxi(1, game.board_h)

  let tile_x : Int = (area_w - 24) / safe_w
  let tile_y : Int = (area_h - 24) / safe_h
  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 36, 86)

  let mut board_x : Int = area_x + (area_w - safe_w * tile) / 2
  let mut board_y : Int = area_y + (area_h - safe_h * tile) / 2

  if game.shake_t > 0.0 {
    board_x = board_x + @raylib.get_random_value(-3, 3)
    board_y = board_y + @raylib.get_random_value(-3, 3)
  }

  (board_x, board_y, tile)
}

///|
fn world_center(game : Game, x : Int, y : Int) -> (Float, Float, Float) {
  let (board_x, board_y, tile) = board_metrics(game)
  let cx : Float = Float::from_int(board_x + (x - 1) * tile + tile / 2)
  let cy : Float = Float::from_int(board_y + (y - 1) * tile + tile / 2)
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
fn burst_tile(game : Game, x : Int, y : Int, amount : Int, kind : Int) -> Unit {
  let (cx, cy, tilef) = world_center(game, x, y)
  let spread : Float = maxf(8.0, tilef * 0.22)

  for _i = 0; _i < amount; _i = _i + 1 {
    spawn_spark(
      game,
      cx + randf(-spread, spread),
      cy + randf(-spread, spread),
      randf(-160.0, 160.0),
      randf(-170.0, 156.0),
      randf(0.20, 0.92),
      randf(1.6, 5.6),
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
    game.sparks[i].vx = game.sparks[i].vx * (1.0 - dt * 1.9)
    game.sparks[i].vy = game.sparks[i].vy * (1.0 - dt * 1.9) + dt * 36.0
  }
}

///|
fn shuffle_ints(arr : Array[Int]) -> Unit {
  let mut i : Int = arr.length() - 1
  while i > 0 {
    let j : Int = @raylib.get_random_value(0, i)
    let t : Int = arr[i]
    arr[i] = arr[j]
    arr[j] = t
    i = i - 1
  }
}

///|
fn active_count(game : Game) -> Int {
  let mut n : Int = 0
  for y = 1; y <= game.board_h; y = y + 1 {
    for x = 1; x <= game.board_w; x = x + 1 {
      if active_at(game, x, y) {
        n = n + 1
      }
    }
  }
  n
}

///|
fn set_pattern_active(game : Game, pattern : Int) -> Unit {
  clear_board(game)

  let cx : Float = (Float::from_int(game.board_w) + 1.0) * 0.5
  let cy : Float = (Float::from_int(game.board_h) + 1.0) * 0.5

  for y = 1; y <= game.board_h; y = y + 1 {
    for x = 1; x <= game.board_w; x = x + 1 {
      let xf : Float = Float::from_int(x)
      let yf : Float = Float::from_int(y)
      let nx : Float = (xf - cx) /
        (Float::from_int(maxi(1, game.board_w)) * 0.5)
      let ny : Float = (yf - cy) /
        (Float::from_int(maxi(1, game.board_h)) * 0.5)

      let mut on : Bool = true

      if pattern == 0 {
        on = true
      } else if pattern == 1 {
        on = nx * nx + ny * ny <= 1.05
      } else if pattern == 2 {
        on = absf(nx) + absf(ny) <= 1.05
      } else if pattern == 3 {
        on = absf(nx) <= 0.36 || absf(ny) <= 0.32 || absf(nx) + absf(ny) <= 1.0
      } else if pattern == 4 {
        let edge : Bool = x <= 2 ||
          x >= game.board_w - 1 ||
          y <= 2 ||
          y >= game.board_h - 1
        let core : Bool = nx * nx + ny * ny <= 0.5
        on = edge || core
      } else if pattern == 5 {
        let wing_l : Bool = x <= game.board_w / 2 - 1 && absf(ny) <= 0.72
        let wing_r : Bool = x >= game.board_w / 2 + 2 && absf(ny) <= 0.72
        let spine : Bool = absf(nx) <= 0.18
        on = wing_l || wing_r || spine
      } else if pattern == 6 {
        let band : Float = Float::from_double(
            @math.sin((xf * 0.62).to_double()),
          ) *
          0.36
        on = absf(ny - band) <= 0.44 || absf(nx) <= 0.18
      } else if pattern == 7 {
        let stair_a : Bool = y <= x * game.board_h / maxi(1, game.board_w) + 2
        let stair_b : Bool = y >=
          game.board_h - x * game.board_h / maxi(1, game.board_w) - 1
        on = stair_a && stair_b
      } else if pattern == 8 {
        let r2 : Float = nx * nx + ny * ny
        on = (r2 >= 0.18 && r2 <= 1.08) || absf(nx) <= 0.12 || absf(ny) <= 0.12
      } else {
        let ring : Bool = nx * nx + ny * ny <= 1.08
        let cut1 : Bool = not(absf(nx) < 0.22 && ny < -0.32)
        let cut2 : Bool = not(absf(nx) < 0.22 && ny > 0.32)
        let cut3 : Bool = not(absf(ny) < 0.2 && nx < -0.42)
        let cut4 : Bool = not(absf(ny) < 0.2 && nx > 0.42)
        on = ring && cut1 && cut2 && cut3 && cut4
      }

      game.active[idx(x, y)] = on
      game.cells[idx(x, y)] = 0
    }
  }

  let mut n : Int = active_count(game)
  if n % 2 == 1 {
    let mut removed : Bool = false
    for y = game.board_h; y >= 1; y = y - 1 {
      for x = game.board_w; x >= 1; x = x - 1 {
        if game.active[idx(x, y)] {
          game.active[idx(x, y)] = false
          removed = true
          break
        }
      }
      if removed {
        break
      }
    }

    if removed {
      n = n - 1
    }
  }

  if n < 16 {
    for y = 1; y <= game.board_h; y = y + 1 {
      for x = 1; x <= game.board_w; x = x + 1 {
        game.active[idx(x, y)] = true
      }
    }

    if active_count(game) % 2 == 1 {
      game.active[idx(game.board_w, game.board_h)] = false
    }
  }
}

///|
fn free_tile(game : Game, x : Int, y : Int) -> Bool {
  let k : Int = cell_at(game, x, y)
  if k <= 0 {
    return false
  }

  let left_block : Bool = x > 1 &&
    active_at(game, x - 1, y) &&
    cell_at(game, x - 1, y) > 0
  let right_block : Bool = x < game.board_w &&
    active_at(game, x + 1, y) &&
    cell_at(game, x + 1, y) > 0

  not(left_block && right_block)
}

///|
fn fill_board_with_pairs(game : Game) -> Unit {
  let active_n : Int = active_count(game)
  let pair_n : Int = active_n / 2

  let vals : Array[Int] = []
  for i = 0; i < pair_n; i = i + 1 {
    let kind : Int = i % maxi(2, game.kind_count) + 1
    vals.push(kind)
    vals.push(kind)
  }

  shuffle_ints(vals)

  let mut p : Int = 0
  for y = 1; y <= game.board_h; y = y + 1 {
    for x = 1; x <= game.board_w; x = x + 1 {
      if active_at(game, x, y) {
        set_cell(game, x, y, vals[p])
        p = p + 1
      }
    }
  }

  game.remaining = active_n
}

///|
fn find_any_move(game : Game) -> (Bool, Int, Int, Int, Int) {
  for y1 = 1; y1 <= game.board_h; y1 = y1 + 1 {
    for x1 = 1; x1 <= game.board_w; x1 = x1 + 1 {
      let k1 : Int = cell_at(game, x1, y1)
      if k1 <= 0 || not(free_tile(game, x1, y1)) {
        continue
      }

      let mut y2 : Int = y1
      while y2 <= game.board_h {
        let mut x2 : Int = if y2 == y1 { x1 + 1 } else { 1 }
        while x2 <= game.board_w {
          if cell_at(game, x2, y2) == k1 && free_tile(game, x2, y2) {
            return (true, x1, y1, x2, y2)
          }
          x2 = x2 + 1
        }
        y2 = y2 + 1
      }
    }
  }

  (false, 0, 0, 0, 0)
}

///|
fn reshuffle(game : Game, consume_ticket : Bool) -> Bool {
  if game.state != state_play {
    return false
  }

  if consume_ticket && game.shuffles_left <= 0 {
    game.message = "No shuffles left"
    game.message_t = 0.8
    return false
  }

  let vals : Array[Int] = []
  for y = 1; y <= game.board_h; y = y + 1 {
    for x = 1; x <= game.board_w; x = x + 1 {
      let k : Int = cell_at(game, x, y)
      if k > 0 {
        vals.push(k)
      }
    }
  }

  if vals.length() <= 1 {
    return false
  }

  let mut good : Bool = false
  for _t = 0; _t < 32; _t = _t + 1 {
    shuffle_ints(vals)

    let mut p : Int = 0
    for y = 1; y <= game.board_h; y = y + 1 {
      for x = 1; x <= game.board_w; x = x + 1 {
        if active_at(game, x, y) && cell_at(game, x, y) > 0 {
          set_cell(game, x, y, vals[p])
          p = p + 1
        }
      }
    }

    if find_any_move(game).0 {
      good = true
      break
    }
  }

  if not(good) {
    game.message = "Unable to shuffle"
    game.message_t = 0.8
    return false
  }

  if consume_ticket {
    game.shuffles_left = game.shuffles_left - 1
  }

  clear_selection(game)
  clear_hint(game)
  game.combo = 0
  game.message = "Tiles shuffled"
  game.message_t = 0.9
  game.shake_t = 0.12

  true
}

///|
fn ensure_moves(game : Game) -> Unit {
  if game.state != state_play || game.remaining <= 0 {
    return
  }

  if find_any_move(game).0 {
    return
  }

  if reshuffle(game, true) {
    game.message = "No moves, auto shuffle"
    game.message_t = 1.0
    return
  }

  if reshuffle(game, false) {
    game.message = "No moves, forced shuffle"
    game.message_t = 1.0
    return
  }

  game.state = state_fail
  game.message = "No possible pairs"
  game.message_t = 1.2
}

///|
fn push_undo_pair(game : Game, step : UndoPair) -> Unit {
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
fn award_match(game : Game, kind : Int) -> Int {
  let gain : Int = 90 + game.combo * 25 + kind % 8 * 6
  game.score = game.score + gain
  gain
}

///|
fn on_match(
  game : Game,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  kind : Int,
) -> Unit {
  let step : UndoPair = {
    valid: true,
    x1,
    y1,
    kind1: kind,
    x2,
    y2,
    kind2: kind,
    prev_score: game.score,
    prev_combo: game.combo,
    prev_timer: game.timer,
    prev_remaining: game.remaining,
  }
  push_undo_pair(game, step)

  set_cell(game, x1, y1, 0)
  set_cell(game, x2, y2, 0)

  game.remaining = game.remaining - 2
  game.combo = game.combo + 1

  let gain : Int = award_match(game, kind)
  game.timer = game.timer + 2.1 + Float::from_int(game.combo) * 0.18
  if game.timer > game.time_limit {
    game.timer = game.time_limit
  }

  clear_selection(game)
  clear_hint(game)

  game.message = "Combo x\{game.combo} +\{gain}"
  game.message_t = 0.95

  burst_tile(game, x1, y1, 12, 0)
  burst_tile(game, x2, y2, 12, 1)

  if game.remaining <= 0 {
    game.total_levels = game.total_levels + 1
    game.total_time = game.total_time + (game.time_limit - game.timer)

    if game.level_index + 1 >= game.level_count {
      game.state = state_campaign_clear
    } else {
      game.state = state_level_clear
    }

    game.message = "Board cleared"
    game.message_t = 1.3
    game.shake_t = 0.2
    return
  }

  ensure_moves(game)
}

///|
fn on_bad_pick(game : Game, x : Int, y : Int) -> Unit {
  game.combo = 0
  game.message = "Tile blocked"
  game.message_t = 0.6
  game.shake_t = 0.08
  burst_tile(game, x, y, 8, 2)
}

///|
fn pick_tile(game : Game, x : Int, y : Int) -> Unit {
  if game.state != state_play {
    return
  }

  let kind : Int = cell_at(game, x, y)
  if kind <= 0 {
    return
  }

  if not(free_tile(game, x, y)) {
    on_bad_pick(game, x, y)
    return
  }

  game.cursor_x = x
  game.cursor_y = y

  if not(game.select_active) {
    game.select_active = true
    game.select_x = x
    game.select_y = y
    game.message = "Tile selected"
    game.message_t = 0.34
    return
  }

  if game.select_x == x && game.select_y == y {
    clear_selection(game)
    game.message = "Selection cleared"
    game.message_t = 0.3
    return
  }

  let sx : Int = game.select_x
  let sy : Int = game.select_y
  let sk : Int = cell_at(game, sx, sy)

  if sk <= 0 || not(free_tile(game, sx, sy)) {
    game.select_x = x
    game.select_y = y
    game.message = "Switched selection"
    game.message_t = 0.3
    return
  }

  if sk == kind {
    on_match(game, sx, sy, x, y, kind)
  } else {
    game.select_x = x
    game.select_y = y
    game.combo = 0
    game.message = "Kinds differ"
    game.message_t = 0.45
  }
}

///|
fn pick_cursor(game : Game) -> Unit {
  pick_tile(game, game.cursor_x, game.cursor_y)
}

///|
fn use_hint(game : Game) -> Bool {
  if game.state != state_play {
    return false
  }

  if game.hints_left <= 0 {
    game.message = "No hints left"
    game.message_t = 0.8
    return false
  }

  let m = find_any_move(game)
  if not(m.0) {
    game.message = "No pair available"
    game.message_t = 0.9
    return false
  }

  game.hints_left = game.hints_left - 1
  game.hint_active = true
  game.hint_ttl = 2.8
  game.hint_x1 = m.1
  game.hint_y1 = m.2
  game.hint_x2 = m.3
  game.hint_y2 = m.4
  game.cursor_x = m.1
  game.cursor_y = m.2

  game.message = "Hint shown"
  game.message_t = 0.9

  burst_tile(game, m.1, m.2, 9, 3)
  burst_tile(game, m.3, m.4, 9, 3)

  true
}

///|
fn undo_last(game : Game) -> Bool {
  if game.undo_len <= 0 {
    game.message = "Nothing to undo"
    game.message_t = 0.8
    return false
  }

  if game.undos_left <= 0 {
    game.message = "No undo credits"
    game.message_t = 0.8
    return false
  }

  if game.state != state_play {
    game.message = "Undo during play only"
    game.message_t = 0.8
    return false
  }

  game.undo_len = game.undo_len - 1
  let step : UndoPair = game.undo[game.undo_len]
  if not(step.valid) {
    return false
  }

  set_cell(game, step.x1, step.y1, step.kind1)
  set_cell(game, step.x2, step.y2, step.kind2)

  game.score = step.prev_score
  game.combo = step.prev_combo
  game.timer = step.prev_timer
  game.remaining = step.prev_remaining

  game.undos_left = game.undos_left - 1
  clear_selection(game)
  clear_hint(game)

  game.cursor_x = step.x1
  game.cursor_y = step.y1

  game.message = "Undo used"
  game.message_t = 0.75
  game.shake_t = 0.08

  burst_tile(game, step.x1, step.y1, 8, 2)
  burst_tile(game, step.x2, step.y2, 8, 2)

  true
}

///|
fn move_cursor_once(game : Game, dir : Int) -> Unit {
  if game.state != state_play {
    return
  }

  if dir == dir_left {
    game.cursor_x = clampi(game.cursor_x - 1, 1, game.board_w)
  } else if dir == dir_right {
    game.cursor_x = clampi(game.cursor_x + 1, 1, game.board_w)
  } else if dir == dir_up {
    game.cursor_y = clampi(game.cursor_y - 1, 1, game.board_h)
  } else if dir == dir_down {
    game.cursor_y = clampi(game.cursor_y + 1, 1, game.board_h)
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

  if game.state == state_play {
    game.timer = game.timer - dt
    if game.timer <= 0.0 {
      game.timer = 0.0
      game.state = state_fail
      game.combo = 0
      clear_selection(game)
      clear_hint(game)
      game.message = "Time up"
      game.message_t = 1.2
      game.shake_t = 0.25
    }
  }

  update_sparks(game, dt)
}

///|
fn place_cursor_on_first_tile(game : Game) -> Unit {
  let mut found : Bool = false
  for y = 1; y <= game.board_h; y = y + 1 {
    for x = 1; x <= game.board_w; x = x + 1 {
      if cell_at(game, x, y) > 0 {
        game.cursor_x = x
        game.cursor_y = y
        found = true
        break
      }
    }
    if found {
      break
    }
  }
}

///|
fn load_level(game : Game, level_id : Int) -> Unit {
  let mut id : Int = level_id
  if id < 0 {
    id = 0
  }
  if id >= game.level_count {
    id = game.level_count - 1
  }

  let (w, h, kinds, limit, hints, shuffles, undos, pattern, name) = configure_level(
    id,
  )

  game.level_index = id
  game.level_name = name

  game.board_w = mini(w, max_cols)
  game.board_h = mini(h, max_rows)
  game.kind_count = maxi(2, kinds)

  game.time_limit = limit
  game.timer = limit

  game.hints_left = hints
  game.shuffles_left = shuffles
  game.undos_left = undos

  game.combo = 0
  game.hold_dir = dir_none
  game.repeat_t = 0.0
  game.touch_action_cd = 0.0

  clear_selection(game)
  clear_hint(game)
  clear_undo(game)
  clear_sparks(game)

  set_pattern_active(game, pattern)
  fill_board_with_pairs(game)

  for _t = 0; _t < 24; _t = _t + 1 {
    if find_any_move(game).0 {
      break
    }
    ignore(reshuffle(game, false))
  }

  place_cursor_on_first_tile(game)

  game.state = state_play
  game.message = "Level \{id + 1}: \{name}"
  game.message_t = 1.2
}

///|
fn reload_level(game : Game) -> Unit {
  load_level(game, game.level_index)
}

///|
fn restart_campaign(game : Game) -> Unit {
  game.score = 0
  game.total_levels = 0
  game.total_time = 0.0
  load_level(game, 0)
}

///|
fn next_level(game : Game) -> Unit {
  if game.level_index + 1 >= game.level_count {
    game.state = state_campaign_clear
    return
  }

  load_level(game, game.level_index + 1)
}
