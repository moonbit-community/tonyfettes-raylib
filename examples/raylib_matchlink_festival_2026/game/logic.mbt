///|
fn build_level_board(game : @types.Game) -> Unit {
  let total : Int = game.board_w * game.board_h
  let pair_count : Int = total / 2

  let vals : Array[Int] = []
  for i in 0..<pair_count {
    let kind : Int = i % game.kind_count + 1
    vals.push(kind)
    vals.push(kind)
  }

  @types.shuffle_ints(vals)

  @types.clear_board(game)
  let mut p : Int = 0
  for y in 1..<=game.board_h {
    for x in 1..<=game.board_w {
      @types.set_cell(game, x, y, vals[p])
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
fn make_path(xs : Array[Int], ys : Array[Int]) -> @types.LinkPath {
  let n : Int = xs.length()
  if n < 2 {
    return @types.empty_path()
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
fn line_clear(
  game : @types.Game,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
) -> Bool {
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
      if @types.cell_at(game, x1, y) != 0 {
        return false
      }
      y = y + step
    }
    return true
  }

  let step : Int = if x2 > x1 { 1 } else { -1 }
  let mut x : Int = x1 + step
  while x != x2 {
    if @types.cell_at(game, x, y1) != 0 {
      return false
    }
    x = x + step
  }

  true
}

///|
fn empty_or_target(
  game : @types.Game,
  x : Int,
  y : Int,
  tx : Int,
  ty : Int,
) -> Bool {
  (x == tx && y == ty) || @types.cell_at(game, x, y) == 0
}

///|
fn direct_or_one_turn_from_anchor(
  game : @types.Game,
  ax : Int,
  ay : Int,
  bx : Int,
  by : Int,
) -> @types.LinkPath {
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

  @types.empty_path()
}

///|
fn compose_with_start(
  ax : Int,
  ay : Int,
  tail : @types.LinkPath,
) -> @types.LinkPath {
  if not(tail.found) {
    return @types.empty_path()
  }

  let xs : Array[Int] = []
  let ys : Array[Int] = []
  push_point(xs, ys, ax, ay)

  for i in 0..<tail.points {
    let (x, y) = @types.path_point(tail, i)
    push_point(xs, ys, x, y)
  }

  make_path(xs, ys)
}

///|
fn find_link_path(
  game : @types.Game,
  ax : Int,
  ay : Int,
  bx : Int,
  by : Int,
) -> @types.LinkPath {
  if ax == bx && ay == by {
    return @types.empty_path()
  }

  let a : Int = @types.cell_at(game, ax, ay)
  let b : Int = @types.cell_at(game, bx, by)
  if a <= 0 || a != b {
    return @types.empty_path()
  }

  let direct_or_corner : @types.LinkPath = direct_or_one_turn_from_anchor(
    game, ax, ay, bx, by,
  )
  if direct_or_corner.found {
    return direct_or_corner
  }

  for x in 0..<=(game.board_w + 1) {
    if x == bx && ay == by {
      continue
    }

    if x != ax && not(empty_or_target(game, x, ay, bx, by)) {
      continue
    }

    if not(line_clear(game, ax, ay, x, ay)) {
      continue
    }

    let tail : @types.LinkPath = direct_or_one_turn_from_anchor(
      game, x, ay, bx, by,
    )
    if tail.found {
      return compose_with_start(ax, ay, tail)
    }
  }

  for y in 0..<=(game.board_h + 1) {
    if ax == bx && y == by {
      continue
    }

    if y != ay && not(empty_or_target(game, ax, y, bx, by)) {
      continue
    }

    if not(line_clear(game, ax, ay, ax, y)) {
      continue
    }

    let tail : @types.LinkPath = direct_or_one_turn_from_anchor(
      game, ax, y, bx, by,
    )
    if tail.found {
      return compose_with_start(ax, ay, tail)
    }
  }

  @types.empty_path()
}

///|
fn set_path_flash(game : @types.Game, path : @types.LinkPath) -> Unit {
  if not(path.found) {
    @types.clear_path_flash(game)
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
fn set_hint_pair(
  game : @types.Game,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Unit {
  game.hint_active = true
  game.hint_ttl = 2.8
  game.hint_x0 = x0
  game.hint_y0 = y0
  game.hint_x1 = x1
  game.hint_y1 = y1
}

///|
fn find_any_move(
  game : @types.Game,
) -> (Bool, Int, Int, Int, Int, @types.LinkPath) {
  for y1 in 1..<=game.board_h {
    for x1 in 1..<=game.board_w {
      let k1 : Int = @types.cell_at(game, x1, y1)
      if k1 == 0 {
        continue
      }

      let mut y2 : Int = y1
      while y2 <= game.board_h {
        let start_x : Int = if y2 == y1 { x1 + 1 } else { 1 }
        let mut x2 : Int = start_x
        while x2 <= game.board_w {
          if @types.cell_at(game, x2, y2) == k1 {
            let p : @types.LinkPath = find_link_path(game, x1, y1, x2, y2)
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

  (false, 0, 0, 0, 0, @types.empty_path())
}

///|
fn reshuffle_board(game : @types.Game, consume_ticket : Bool) -> Bool {
  if game.state != Play {
    return false
  }

  if consume_ticket && game.shuffles_left <= 0 {
    game.message = "No shuffle tickets"
    game.message_t = 0.9
    return false
  }

  let vals : Array[Int] = []
  for y in 1..<=game.board_h {
    for x in 1..<=game.board_w {
      let k : Int = @types.cell_at(game, x, y)
      if k > 0 {
        vals.push(k)
      }
    }
  }

  if vals.length() <= 1 {
    return false
  }

  let mut made : Bool = false
  for _t in 0..<28 {
    @types.shuffle_ints(vals)

    let mut p : Int = 0
    for y in 1..<=game.board_h {
      for x in 1..<=game.board_w {
        if @types.cell_at(game, x, y) > 0 {
          @types.set_cell(game, x, y, vals[p])
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

  @types.clear_selection(game)
  @types.clear_path_flash(game)
  @types.clear_hint_flash(game)
  game.combo = 0
  game.message = "Board shuffled"
  game.message_t = 0.8
  game.shake_t = 0.14

  true
}

///|
fn finalize_level_clear(game : @types.Game) -> Unit {
  game.total_levels = game.total_levels + 1
  game.total_time = game.total_time + (game.time_limit - game.timer)
}

///|
fn complete_level(game : @types.Game) -> Unit {
  if game.state != Play {
    return
  }

  finalize_level_clear(game)
  game.state = if game.level_index + 1 >= game.level_count {
    CampaignClear
  } else {
    LevelClear
  }

  game.message = "Board cleared"
  game.message_t = 1.4
  game.shake_t = 0.2
}

///|
fn fail_level(game : @types.Game) -> Unit {
  if game.state != Play {
    return
  }

  game.state = Fail
  game.combo = 0
  game.message = "Time up"
  game.message_t = 1.2
  game.shake_t = 0.28
}

///|
fn ensure_move_exists(game : @types.Game) -> Unit {
  if game.state != Play || game.remaining <= 0 {
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
  game : @types.Game,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
  kind : Int,
  path : @types.LinkPath,
) -> Unit {
  @types.set_cell(game, x0, y0, 0)
  @types.set_cell(game, x1, y1, 0)

  game.remaining = game.remaining - 2
  game.combo = game.combo + 1

  let gain : Int = 90 + game.combo * 20 + kind * 4
  game.score = game.score + gain

  game.timer = game.timer + 2.2 + Float::from_int(game.combo) * 0.18
  if game.timer > game.time_limit {
    game.timer = game.time_limit
  }

  set_path_flash(game, path)
  @types.clear_hint_flash(game)
  @types.clear_selection(game)

  game.message = "Combo x\{game.combo} +\{gain}"
  game.message_t = 0.95

  @types.burst_cell(game, x0, y0, 14, 0)
  @types.burst_cell(game, x1, y1, 14, 1)

  if game.remaining <= 0 {
    complete_level(game)
    return
  }

  ensure_move_exists(game)
}

///|
fn on_pair_failed(game : @types.Game, x : Int, y : Int) -> Unit {
  game.combo = 0
  game.message = "Path blocked"
  game.message_t = 0.62
  game.shake_t = 0.08
  @types.burst_cell(game, x, y, 8, 2)
}

///|
fn pick_cell(game : @types.Game, x : Int, y : Int) -> Unit {
  if game.state != Play {
    return
  }

  let k : Int = @types.cell_at(game, x, y)
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
    @types.clear_selection(game)
    game.message = "Selection cleared"
    game.message_t = 0.3
    return
  }

  let sx : Int = game.select_x
  let sy : Int = game.select_y
  let sk : Int = @types.cell_at(game, sx, sy)

  if sk <= 0 || sk != k {
    game.select_x = x
    game.select_y = y
    game.message = "Switched selection"
    game.message_t = 0.32
    return
  }

  let path : @types.LinkPath = find_link_path(game, sx, sy, x, y)
  if path.found {
    on_pair_matched(game, sx, sy, x, y, k, path)
  } else {
    game.select_x = x
    game.select_y = y
    on_pair_failed(game, x, y)
  }
}

///|
fn pick_cursor_cell(game : @types.Game) -> Unit {
  pick_cell(game, game.cursor_x, game.cursor_y)
}

///|
fn use_hint(game : @types.Game) -> Bool {
  if game.state != Play || game.hints_left <= 0 {
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
  @types.burst_cell(game, m.1, m.2, 10, 3)
  @types.burst_cell(game, m.3, m.4, 10, 3)

  true
}

///|
fn move_cursor_once(game : @types.Game, dir : @types.Direction) -> Unit {
  if game.state != Play {
    return
  }

  match dir {
    Left => game.cursor_x = @types.clampi(game.cursor_x - 1, 1, game.board_w)
    Right => game.cursor_x = @types.clampi(game.cursor_x + 1, 1, game.board_w)
    Up => game.cursor_y = @types.clampi(game.cursor_y - 1, 1, game.board_h)
    Down => game.cursor_y = @types.clampi(game.cursor_y + 1, 1, game.board_h)
    DirNone => ()
  }
}

///|
fn update_cursor_hold(
  game : @types.Game,
  dt : Float,
  held_dir : @types.Direction,
) -> Unit {
  if game.state != Play {
    game.hold_dir = DirNone
    game.repeat_t = 0.0
    return
  }

  if held_dir == DirNone {
    game.hold_dir = DirNone
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
fn update_timers(game : @types.Game, dt : Float) -> Unit {
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
      @types.clear_path_flash(game)
    }
  }

  if game.hint_active {
    game.hint_ttl = game.hint_ttl - dt
    if game.hint_ttl <= 0.0 {
      @types.clear_hint_flash(game)
    }
  }

  if game.touch_action_cd > 0.0 {
    game.touch_action_cd = game.touch_action_cd - dt
    if game.touch_action_cd < 0.0 {
      game.touch_action_cd = 0.0
    }
  }

  if game.state == Play {
    game.timer = game.timer - dt
    if game.timer <= 0.0 {
      game.timer = 0.0
      fail_level(game)
    }
  }

  @types.update_sparks(game, dt)
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

  let (w, h, kinds, limit, hints, shuffles, name) = configure_level(id)

  game.level_index = id
  game.level_name = name
  game.board_w = w
  game.board_h = h
  game.kind_count = @types.mini(kinds, @types.maxi(2, w * h / 2))

  game.time_limit = limit
  game.timer = limit
  game.hints_left = hints
  game.shuffles_left = shuffles

  game.combo = 0
  game.cursor_x = @types.maxi(1, w / 2)
  game.cursor_y = @types.maxi(1, h / 2)
  @types.clear_selection(game)
  @types.clear_path_flash(game)
  @types.clear_hint_flash(game)
  @types.clear_sparks(game)

  build_level_board(game)

  let mut ok : Bool = false
  for _k in 0..<28 {
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

  game.state = Play
  game.message = "Level \{id + 1}: \{name}"
  game.message_t = 1.2
}

///|
fn reload_level(game : @types.Game) -> Unit {
  load_level(game, game.level_index)
}

///|
fn restart_campaign(game : @types.Game) -> Unit {
  game.score = 0
  game.total_levels = 0
  game.total_time = 0.0
  load_level(game, 0)
}

///|
fn next_level(game : @types.Game) -> Unit {
  if game.level_index + 1 >= game.level_count {
    game.state = CampaignClear
    return
  }
  load_level(game, game.level_index + 1)
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

  update_timers(game, dt)

  let start_press : Bool = detect_start_press(game)
  let next_press : Bool = detect_next_press(game)
  let reset_press : Bool = detect_reset_press(game)

  match game.state {
    Title => if start_press { restart_campaign(game) }
    Play => {
      let held_dir : @types.Direction = detect_held_dir(game)
      update_cursor_hold(game, dt, held_dir)

      let select_press : Bool = detect_select_press(game)
      let hint_press : Bool = detect_hint_press(game)
      let shuffle_press : Bool = detect_shuffle_press(game)
      let clear_press : Bool = detect_clear_press(game)
      let board_tap = detect_board_tap(game)

      if reset_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.2
        reload_level(game)
      } else if clear_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.12
        @types.clear_selection(game)
        game.message = "Selection cleared"
        game.message_t = 0.5
      } else if hint_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.18
        ignore(use_hint(game))
      } else if shuffle_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.2
        ignore(reshuffle_board(game, true))
      } else if board_tap.0 && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.1
        pick_cell(game, board_tap.1, board_tap.2)
      } else if select_press && game.touch_action_cd <= 0.0 {
        game.touch_action_cd = 0.1
        pick_cursor_cell(game)
      }
    }
    LevelClear => if next_press { next_level(game) }
    CampaignClear => if next_press { restart_campaign(game) }
    Fail => if reset_press || next_press { reload_level(game) }
  }
}
