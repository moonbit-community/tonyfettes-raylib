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
fn cell_index(x : Int, y : Int) -> Int {
  (y - 1) * max_cols + (x - 1)
}

///|
fn in_board(game : Game, x : Int, y : Int) -> Bool {
  x >= 1 && x <= game.board_w && y >= 1 && y <= game.board_h
}

///|
fn cell_at(game : Game, x : Int, y : Int) -> Int {
  if in_board(game, x, y) {
    game.cells[cell_index(x, y)]
  } else {
    0
  }
}

///|
fn set_cell(game : Game, x : Int, y : Int, value : Int) -> Unit {
  if in_board(game, x, y) {
    game.cells[cell_index(x, y)] = value
  }
}

///|
fn clear_board(game : Game) -> Unit {
  for i = 0; i < game.cells.length(); i = i + 1 {
    game.cells[i] = 0
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
fn clear_path_flash(game : Game) -> Unit {
  game.path_active = false
  game.path_ttl = 0.0
  game.path_points = 0
}

///|
fn clear_hint_flash(game : Game) -> Unit {
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
  tile = clampi(tile, 36, 84)

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
fn world_center_ext(game : Game, x : Int, y : Int) -> (Float, Float) {
  let (board_x, board_y, tile) = board_metrics(game)

  let cx : Float = Float::from_int(board_x + (x - 1) * tile + tile / 2)
  let cy : Float = Float::from_int(board_y + (y - 1) * tile + tile / 2)
  (cx, cy)
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
  let (cx, cy, tile_f) = world_center(game, x, y)
  let spread : Float = maxf(8.0, tile_f * 0.2)

  for _i = 0; _i < amount; _i = _i + 1 {
    spawn_spark(
      game,
      cx + randf(-spread, spread),
      cy + randf(-spread, spread),
      randf(-160.0, 160.0),
      randf(-170.0, 160.0),
      randf(0.20, 0.92),
      randf(1.6, 5.5),
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
fn build_level_board(game : Game) -> Unit {
  let total : Int = game.board_w * game.board_h
  let pair_count : Int = total / 2

  let vals : Array[Int] = []
  for i = 0; i < pair_count; i = i + 1 {
    let kind : Int = i % game.kind_count + 1
    vals.push(kind)
    vals.push(kind)
  }

  shuffle_ints(vals)

  clear_board(game)
  let mut p : Int = 0
  for y = 1; y <= game.board_h; y = y + 1 {
    for x = 1; x <= game.board_w; x = x + 1 {
      set_cell(game, x, y, vals[p])
      p = p + 1
    }
  }

  game.remaining = total
}

///|
fn push_point(xs : Array[Int], ys : Array[Int], x : Int, y : Int) -> Unit {
  if xs.length() > 0 {
    let last : Int = xs.length() - 1
    if xs[last] == x && ys[last] == y {
      return
    }
  }

  xs.push(x)
  ys.push(y)
}

///|
fn path_point(path : LinkPath, idx : Int) -> (Int, Int) {
  if idx == 0 {
    (path.x0, path.y0)
  } else if idx == 1 {
    (path.x1, path.y1)
  } else if idx == 2 {
    (path.x2, path.y2)
  } else {
    (path.x3, path.y3)
  }
}

///|
fn make_path(xs : Array[Int], ys : Array[Int]) -> LinkPath {
  let n : Int = xs.length()
  if n < 2 {
    return empty_path()
  }

  {
    found: true,
    points: n,
    x0: xs[0],
    y0: ys[0],
    x1: if n > 1 {
      xs[1]
    } else {
      xs[0]
    },
    y1: if n > 1 {
      ys[1]
    } else {
      ys[0]
    },
    x2: if n > 2 {
      xs[2]
    } else {
      xs[0]
    },
    y2: if n > 2 {
      ys[2]
    } else {
      ys[0]
    },
    x3: if n > 3 {
      xs[3]
    } else {
      xs[0]
    },
    y3: if n > 3 {
      ys[3]
    } else {
      ys[0]
    },
  }
}

///|
fn line_clear(game : Game, x1 : Int, y1 : Int, x2 : Int, y2 : Int) -> Bool {
  if x1 == x2 && y1 == y2 {
    return true
  }

  if x1 != x2 && y1 != y2 {
    return false
  }

  if x1 == x2 {
    let step : Int = if y2 > y1 { 1 } else { -1 }
    let mut y : Int = y1 + step
    while y != y2 {
      if cell_at(game, x1, y) != 0 {
        return false
      }
      y = y + step
    }
    return true
  }

  let step : Int = if x2 > x1 { 1 } else { -1 }
  let mut x : Int = x1 + step
  while x != x2 {
    if cell_at(game, x, y1) != 0 {
      return false
    }
    x = x + step
  }

  true
}

///|
fn empty_or_target(game : Game, x : Int, y : Int, tx : Int, ty : Int) -> Bool {
  (x == tx && y == ty) || cell_at(game, x, y) == 0
}

///|
fn direct_or_one_turn_from_anchor(
  game : Game,
  ax : Int,
  ay : Int,
  bx : Int,
  by : Int,
) -> LinkPath {
  if line_clear(game, ax, ay, bx, by) {
    let xs : Array[Int] = []
    let ys : Array[Int] = []
    push_point(xs, ys, ax, ay)
    push_point(xs, ys, bx, by)
    return make_path(xs, ys)
  }

  let c1x : Int = ax
  let c1y : Int = by
  if empty_or_target(game, c1x, c1y, bx, by) &&
    line_clear(game, ax, ay, c1x, c1y) &&
    line_clear(game, c1x, c1y, bx, by) {
    let xs : Array[Int] = []
    let ys : Array[Int] = []
    push_point(xs, ys, ax, ay)
    push_point(xs, ys, c1x, c1y)
    push_point(xs, ys, bx, by)
    return make_path(xs, ys)
  }

  let c2x : Int = bx
  let c2y : Int = ay
  if empty_or_target(game, c2x, c2y, bx, by) &&
    line_clear(game, ax, ay, c2x, c2y) &&
    line_clear(game, c2x, c2y, bx, by) {
    let xs : Array[Int] = []
    let ys : Array[Int] = []
    push_point(xs, ys, ax, ay)
    push_point(xs, ys, c2x, c2y)
    push_point(xs, ys, bx, by)
    return make_path(xs, ys)
  }

  empty_path()
}

///|
fn compose_with_start(ax : Int, ay : Int, tail : LinkPath) -> LinkPath {
  if not(tail.found) {
    return empty_path()
  }

  let xs : Array[Int] = []
  let ys : Array[Int] = []
  push_point(xs, ys, ax, ay)

  for i = 0; i < tail.points; i = i + 1 {
    let (x, y) = path_point(tail, i)
    push_point(xs, ys, x, y)
  }

  make_path(xs, ys)
}

///|
fn find_link_path(
  game : Game,
  ax : Int,
  ay : Int,
  bx : Int,
  by : Int,
) -> LinkPath {
  if ax == bx && ay == by {
    return empty_path()
  }

  let a : Int = cell_at(game, ax, ay)
  let b : Int = cell_at(game, bx, by)
  if a <= 0 || a != b {
    return empty_path()
  }

  let direct_or_corner : LinkPath = direct_or_one_turn_from_anchor(
    game, ax, ay, bx, by,
  )
  if direct_or_corner.found {
    return direct_or_corner
  }

  for x = 0; x <= game.board_w + 1; x = x + 1 {
    if x == bx && ay == by {
      continue
    }

    if x != ax && not(empty_or_target(game, x, ay, bx, by)) {
      continue
    }

    if not(line_clear(game, ax, ay, x, ay)) {
      continue
    }

    let tail : LinkPath = direct_or_one_turn_from_anchor(game, x, ay, bx, by)
    if tail.found {
      return compose_with_start(ax, ay, tail)
    }
  }

  for y = 0; y <= game.board_h + 1; y = y + 1 {
    if ax == bx && y == by {
      continue
    }

    if y != ay && not(empty_or_target(game, ax, y, bx, by)) {
      continue
    }

    if not(line_clear(game, ax, ay, ax, y)) {
      continue
    }

    let tail : LinkPath = direct_or_one_turn_from_anchor(game, ax, y, bx, by)
    if tail.found {
      return compose_with_start(ax, ay, tail)
    }
  }

  empty_path()
}

///|
fn set_path_flash(game : Game, path : LinkPath) -> Unit {
  if not(path.found) {
    clear_path_flash(game)
    return
  }

  game.path_active = true
  game.path_ttl = 0.23
  game.path_points = path.points
  game.path_x0 = path.x0
  game.path_y0 = path.y0
  game.path_x1 = path.x1
  game.path_y1 = path.y1
  game.path_x2 = path.x2
  game.path_y2 = path.y2
  game.path_x3 = path.x3
  game.path_y3 = path.y3
}

///|
fn path_point_flash(game : Game, idx : Int) -> (Int, Int) {
  if idx == 0 {
    (game.path_x0, game.path_y0)
  } else if idx == 1 {
    (game.path_x1, game.path_y1)
  } else if idx == 2 {
    (game.path_x2, game.path_y2)
  } else {
    (game.path_x3, game.path_y3)
  }
}

///|
fn set_hint_pair(game : Game, x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Unit {
  game.hint_active = true
  game.hint_ttl = 2.8
  game.hint_x0 = x0
  game.hint_y0 = y0
  game.hint_x1 = x1
  game.hint_y1 = y1
}

///|
fn clear_selection(game : Game) -> Unit {
  game.select_active = false
  game.select_x = 1
  game.select_y = 1
}

///|
fn find_any_move(game : Game) -> (Bool, Int, Int, Int, Int, LinkPath) {
  for y1 = 1; y1 <= game.board_h; y1 = y1 + 1 {
    for x1 = 1; x1 <= game.board_w; x1 = x1 + 1 {
      let k1 : Int = cell_at(game, x1, y1)
      if k1 == 0 {
        continue
      }

      let mut y2 : Int = y1
      while y2 <= game.board_h {
        let start_x : Int = if y2 == y1 { x1 + 1 } else { 1 }
        let mut x2 : Int = start_x
        while x2 <= game.board_w {
          if cell_at(game, x2, y2) == k1 {
            let p : LinkPath = find_link_path(game, x1, y1, x2, y2)
            if p.found {
              return (true, x1, y1, x2, y2, p)
            }
          }
          x2 = x2 + 1
        }
        y2 = y2 + 1
      }
    }
  }

  (false, 0, 0, 0, 0, empty_path())
}

///|
fn reshuffle_board(game : Game, consume_ticket : Bool) -> Bool {
  if game.state != state_play {
    return false
  }

  if consume_ticket && game.shuffles_left <= 0 {
    game.message = "No shuffle tickets"
    game.message_t = 0.9
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

  let mut made : Bool = false
  for _t = 0; _t < 28; _t = _t + 1 {
    shuffle_ints(vals)

    let mut p : Int = 0
    for y = 1; y <= game.board_h; y = y + 1 {
      for x = 1; x <= game.board_w; x = x + 1 {
        if cell_at(game, x, y) > 0 {
          set_cell(game, x, y, vals[p])
          p = p + 1
        }
      }
    }

    let probe = find_any_move(game)
    if probe.0 {
      made = true
      break
    }
  }

  if not(made) {
    game.message = "No valid shuffle"
    game.message_t = 0.9
    return false
  }

  if consume_ticket {
    game.shuffles_left = game.shuffles_left - 1
  }

  clear_selection(game)
  clear_path_flash(game)
  clear_hint_flash(game)
  game.combo = 0
  game.message = "Board shuffled"
  game.message_t = 0.8
  game.shake_t = 0.14

  true
}

///|
fn finalize_level_clear(game : Game) -> Unit {
  game.total_levels = game.total_levels + 1
  game.total_time = game.total_time + (game.time_limit - game.timer)
}

///|
fn complete_level(game : Game) -> Unit {
  if game.state != state_play {
    return
  }

  finalize_level_clear(game)
  game.state = if game.level_index + 1 >= game.level_count {
    state_campaign_clear
  } else {
    state_level_clear
  }

  game.message = "Board cleared"
  game.message_t = 1.4
  game.shake_t = 0.2
}

///|
fn fail_level(game : Game) -> Unit {
  if game.state != state_play {
    return
  }

  game.state = state_fail
  game.combo = 0
  game.message = "Time up"
  game.message_t = 1.2
  game.shake_t = 0.28
}

///|
fn ensure_move_exists(game : Game) -> Unit {
  if game.state != state_play || game.remaining <= 0 {
    return
  }

  let probe = find_any_move(game)
  if probe.0 {
    return
  }

  if reshuffle_board(game, true) {
    game.message = "No moves, auto-shuffled"
    game.message_t = 1.0
    return
  }

  if reshuffle_board(game, false) {
    game.message = "No moves, forced shuffle"
    game.message_t = 1.0
    return
  }

  fail_level(game)
}

///|
fn on_pair_matched(
  game : Game,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
  kind : Int,
  path : LinkPath,
) -> Unit {
  set_cell(game, x0, y0, 0)
  set_cell(game, x1, y1, 0)

  game.remaining = game.remaining - 2
  game.combo = game.combo + 1

  let gain : Int = 90 + game.combo * 20 + kind * 4
  game.score = game.score + gain

  game.timer = game.timer + 2.2 + Float::from_int(game.combo) * 0.18
  if game.timer > game.time_limit {
    game.timer = game.time_limit
  }

  set_path_flash(game, path)
  clear_hint_flash(game)
  clear_selection(game)

  game.message = "Combo x\{game.combo} +\{gain}"
  game.message_t = 0.95

  burst_cell(game, x0, y0, 14, 0)
  burst_cell(game, x1, y1, 14, 1)

  if game.remaining <= 0 {
    complete_level(game)
    return
  }

  ensure_move_exists(game)
}

///|
fn on_pair_failed(game : Game, x : Int, y : Int) -> Unit {
  game.combo = 0
  game.message = "Path blocked"
  game.message_t = 0.62
  game.shake_t = 0.08
  burst_cell(game, x, y, 8, 2)
}

///|
fn pick_cell(game : Game, x : Int, y : Int) -> Unit {
  if game.state != state_play {
    return
  }

  let k : Int = cell_at(game, x, y)
  if k <= 0 {
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

  if sk <= 0 || sk != k {
    game.select_x = x
    game.select_y = y
    game.message = "Switched selection"
    game.message_t = 0.32
    return
  }

  let path : LinkPath = find_link_path(game, sx, sy, x, y)
  if path.found {
    on_pair_matched(game, sx, sy, x, y, k, path)
  } else {
    game.select_x = x
    game.select_y = y
    on_pair_failed(game, x, y)
  }
}

///|
fn pick_cursor_cell(game : Game) -> Unit {
  pick_cell(game, game.cursor_x, game.cursor_y)
}

///|
fn use_hint(game : Game) -> Bool {
  if game.state != state_play || game.hints_left <= 0 {
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
  set_hint_pair(game, m.1, m.2, m.3, m.4)
  game.cursor_x = m.1
  game.cursor_y = m.2
  game.message = "Hint highlighted"
  game.message_t = 0.9
  burst_cell(game, m.1, m.2, 10, 3)
  burst_cell(game, m.3, m.4, 10, 3)

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

  if game.path_active {
    game.path_ttl = game.path_ttl - dt
    if game.path_ttl <= 0.0 {
      clear_path_flash(game)
    }
  }

  if game.hint_active {
    game.hint_ttl = game.hint_ttl - dt
    if game.hint_ttl <= 0.0 {
      clear_hint_flash(game)
    }
  }

  if game.touch_action_cd > 0.0 {
    game.touch_action_cd = game.touch_action_cd - dt
    if game.touch_action_cd < 0.0 {
      game.touch_action_cd = 0.0
    }
  }

  if game.state == state_play {
    game.timer = game.timer - dt
    if game.timer <= 0.0 {
      game.timer = 0.0
      fail_level(game)
    }
  }

  update_sparks(game, dt)
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

  let (w, h, kinds, limit, hints, shuffles, name) = configure_level(id)

  game.level_index = id
  game.level_name = name
  game.board_w = w
  game.board_h = h
  game.kind_count = mini(kinds, maxi(2, w * h / 2))

  game.time_limit = limit
  game.timer = limit
  game.hints_left = hints
  game.shuffles_left = shuffles

  game.combo = 0
  game.cursor_x = maxi(1, w / 2)
  game.cursor_y = maxi(1, h / 2)
  clear_selection(game)
  clear_path_flash(game)
  clear_hint_flash(game)
  clear_sparks(game)

  build_level_board(game)

  let mut ok : Bool = false
  for _k = 0; _k < 28; _k = _k + 1 {
    let m = find_any_move(game)
    if m.0 {
      ok = true
      break
    }
    ignore(reshuffle_board(game, false))
  }

  if not(ok) {
    game.message = "Generating board..."
    game.message_t = 0.8
  }

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
