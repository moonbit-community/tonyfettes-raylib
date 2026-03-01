///|
fn set_pattern_active(game : @types.Game, pattern : Int) -> Unit {
  @types.clear_board(game)

  let cx : Float = (Float::from_int(game.board_w) + 1.0) * 0.5
  let cy : Float = (Float::from_int(game.board_h) + 1.0) * 0.5

  for y in 1..<=game.board_h {
    for x in 1..<=game.board_w {
      let xf : Float = Float::from_int(x)
      let yf : Float = Float::from_int(y)
      let nx : Float = (xf - cx) /
        (Float::from_int(@types.maxi(1, game.board_w)) * 0.5)
      let ny : Float = (yf - cy) /
        (Float::from_int(@types.maxi(1, game.board_h)) * 0.5)

      let mut on : Bool = true

      if pattern == 0 {
        on = true
      } else if pattern == 1 {
        on = nx * nx + ny * ny <= 1.05
      } else if pattern == 2 {
        on = @types.absf(nx) + @types.absf(ny) <= 1.05
      } else if pattern == 3 {
        on = @types.absf(nx) <= 0.36 ||
          @types.absf(ny) <= 0.32 ||
          @types.absf(nx) + @types.absf(ny) <= 1.0
      } else if pattern == 4 {
        let edge : Bool = x <= 2 ||
          x >= game.board_w - 1 ||
          y <= 2 ||
          y >= game.board_h - 1
        let core : Bool = nx * nx + ny * ny <= 0.5
        on = edge || core
      } else if pattern == 5 {
        let wing_l : Bool = x <= game.board_w / 2 - 1 &&
          @types.absf(ny) <= 0.72
        let wing_r : Bool = x >= game.board_w / 2 + 2 &&
          @types.absf(ny) <= 0.72
        let spine : Bool = @types.absf(nx) <= 0.18
        on = wing_l || wing_r || spine
      } else if pattern == 6 {
        let band : Float = Float::from_double(
            @math.sin((xf * 0.62).to_double()),
          ) *
          0.36
        on = @types.absf(ny - band) <= 0.44 || @types.absf(nx) <= 0.18
      } else if pattern == 7 {
        let stair_a : Bool = y <=
          x * game.board_h / @types.maxi(1, game.board_w) + 2
        let stair_b : Bool = y >=
          game.board_h -
          x * game.board_h / @types.maxi(1, game.board_w) -
          1
        on = stair_a && stair_b
      } else if pattern == 8 {
        let r2 : Float = nx * nx + ny * ny
        on = (r2 >= 0.18 && r2 <= 1.08) ||
          @types.absf(nx) <= 0.12 ||
          @types.absf(ny) <= 0.12
      } else {
        let ring : Bool = nx * nx + ny * ny <= 1.08
        let cut1 : Bool = not(@types.absf(nx) < 0.22 && ny < -0.32)
        let cut2 : Bool = not(@types.absf(nx) < 0.22 && ny > 0.32)
        let cut3 : Bool = not(@types.absf(ny) < 0.2 && nx < -0.42)
        let cut4 : Bool = not(@types.absf(ny) < 0.2 && nx > 0.42)
        on = ring && cut1 && cut2 && cut3 && cut4
      }

      game.active[@types.idx(x, y)] = on
      game.cells[@types.idx(x, y)] = 0
    }
  }

  let mut n : Int = @types.active_count(game)
  if n % 2 == 1 {
    let mut removed : Bool = false
    for y = game.board_h; y >= 1; y = y - 1 {
      for x = game.board_w; x >= 1; x = x - 1 {
        if game.active[@types.idx(x, y)] {
          game.active[@types.idx(x, y)] = false
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
    for y in 1..<=game.board_h {
      for x in 1..<=game.board_w {
        game.active[@types.idx(x, y)] = true
      }
    }

    if @types.active_count(game) % 2 == 1 {
      game.active[@types.idx(game.board_w, game.board_h)] = false
    }
  }
}

///|
fn fill_board_with_pairs(game : @types.Game) -> Unit {
  let active_n : Int = @types.active_count(game)
  let pair_n : Int = active_n / 2

  let vals : Array[Int] = []
  for i in 0..<pair_n {
    let kind : Int = i % @types.maxi(2, game.kind_count) + 1
    vals.push(kind)
    vals.push(kind)
  }

  @types.shuffle_ints(vals)

  let mut p : Int = 0
  for y in 1..<=game.board_h {
    for x in 1..<=game.board_w {
      if @types.active_at(game, x, y) {
        @types.set_cell(game, x, y, vals[p])
        p = p + 1
      }
    }
  }

  game.remaining = active_n
}

///|
fn find_any_move(game : @types.Game) -> (Bool, Int, Int, Int, Int) {
  for y1 in 1..<=game.board_h {
    for x1 in 1..<=game.board_w {
      let k1 : Int = @types.cell_at(game, x1, y1)
      if k1 <= 0 || not(@types.free_tile(game, x1, y1)) {
        continue
      }

      let mut y2 : Int = y1
      while y2 <= game.board_h {
        let mut x2 : Int = if y2 == y1 { x1 + 1 } else { 1 }
        while x2 <= game.board_w {
          if @types.cell_at(game, x2, y2) == k1 &&
            @types.free_tile(game, x2, y2) {
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
fn reshuffle(game : @types.Game, consume_ticket : Bool) -> Bool {
  if game.state != @types.state_play {
    return false
  }

  if consume_ticket && game.shuffles_left <= 0 {
    game.message = "No shuffles left"
    game.message_t = 0.8
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

  let mut good : Bool = false
  for _t in 0..<32 {
    @types.shuffle_ints(vals)

    let mut p : Int = 0
    for y in 1..<=game.board_h {
      for x in 1..<=game.board_w {
        if @types.active_at(game, x, y) && @types.cell_at(game, x, y) > 0 {
          @types.set_cell(game, x, y, vals[p])
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

  @types.clear_selection(game)
  @types.clear_hint(game)
  game.combo = 0
  game.message = "Tiles shuffled"
  game.message_t = 0.9
  game.shake_t = 0.12

  true
}

///|
fn ensure_moves(game : @types.Game) -> Unit {
  if game.state != @types.state_play || game.remaining <= 0 {
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

  game.state = @types.state_fail
  game.message = "No possible pairs"
  game.message_t = 1.2
}

///|
fn push_undo_pair(game : @types.Game, step : @types.UndoPair) -> Unit {
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
fn award_match(game : @types.Game, kind : Int) -> Int {
  let gain : Int = 90 + game.combo * 25 + kind % 8 * 6
  game.score = game.score + gain
  gain
}

///|
fn on_match(
  game : @types.Game,
  x1 : Int,
  y1 : Int,
  x2 : Int,
  y2 : Int,
  kind : Int,
) -> Unit {
  let step : @types.UndoPair = {
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

  @types.set_cell(game, x1, y1, 0)
  @types.set_cell(game, x2, y2, 0)

  game.remaining = game.remaining - 2
  game.combo = game.combo + 1

  let gain : Int = award_match(game, kind)
  game.timer = game.timer + 2.1 + Float::from_int(game.combo) * 0.18
  if game.timer > game.time_limit {
    game.timer = game.time_limit
  }

  @types.clear_selection(game)
  @types.clear_hint(game)

  game.message = "Combo x\{game.combo} +\{gain}"
  game.message_t = 0.95

  @types.burst_tile(game, x1, y1, 12, 0)
  @types.burst_tile(game, x2, y2, 12, 1)

  if game.remaining <= 0 {
    game.total_levels = game.total_levels + 1
    game.total_time = game.total_time + (game.time_limit - game.timer)

    if game.level_index + 1 >= game.level_count {
      game.state = @types.state_campaign_clear
    } else {
      game.state = @types.state_level_clear
    }

    game.message = "Board cleared"
    game.message_t = 1.3
    game.shake_t = 0.2
    return
  }

  ensure_moves(game)
}

///|
fn on_bad_pick(game : @types.Game, x : Int, y : Int) -> Unit {
  game.combo = 0
  game.message = "Tile blocked"
  game.message_t = 0.6
  game.shake_t = 0.08
  @types.burst_tile(game, x, y, 8, 2)
}

///|
fn pick_tile(game : @types.Game, x : Int, y : Int) -> Unit {
  if game.state != @types.state_play {
    return
  }

  let kind : Int = @types.cell_at(game, x, y)
  if kind <= 0 {
    return
  }

  if not(@types.free_tile(game, x, y)) {
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
    @types.clear_selection(game)
    game.message = "Selection cleared"
    game.message_t = 0.3
    return
  }

  let sx : Int = game.select_x
  let sy : Int = game.select_y
  let sk : Int = @types.cell_at(game, sx, sy)

  if sk <= 0 || not(@types.free_tile(game, sx, sy)) {
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
fn pick_cursor(game : @types.Game) -> Unit {
  pick_tile(game, game.cursor_x, game.cursor_y)
}

///|
fn use_hint(game : @types.Game) -> Bool {
  if game.state != @types.state_play {
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

  @types.burst_tile(game, m.1, m.2, 9, 3)
  @types.burst_tile(game, m.3, m.4, 9, 3)

  true
}

///|
fn undo_last(game : @types.Game) -> Bool {
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

  if game.state != @types.state_play {
    game.message = "Undo during play only"
    game.message_t = 0.8
    return false
  }

  game.undo_len = game.undo_len - 1
  let step : @types.UndoPair = game.undo[game.undo_len]
  if not(step.valid) {
    return false
  }

  @types.set_cell(game, step.x1, step.y1, step.kind1)
  @types.set_cell(game, step.x2, step.y2, step.kind2)

  game.score = step.prev_score
  game.combo = step.prev_combo
  game.timer = step.prev_timer
  game.remaining = step.prev_remaining

  game.undos_left = game.undos_left - 1
  @types.clear_selection(game)
  @types.clear_hint(game)

  game.cursor_x = step.x1
  game.cursor_y = step.y1

  game.message = "Undo used"
  game.message_t = 0.75
  game.shake_t = 0.08

  @types.burst_tile(game, step.x1, step.y1, 8, 2)
  @types.burst_tile(game, step.x2, step.y2, 8, 2)

  true
}

///|
fn move_cursor_once(game : @types.Game, dir : Int) -> Unit {
  if game.state != @types.state_play {
    return
  }

  if dir == @types.dir_left {
    game.cursor_x = @types.clampi(game.cursor_x - 1, 1, game.board_w)
  } else if dir == @types.dir_right {
    game.cursor_x = @types.clampi(game.cursor_x + 1, 1, game.board_w)
  } else if dir == @types.dir_up {
    game.cursor_y = @types.clampi(game.cursor_y - 1, 1, game.board_h)
  } else if dir == @types.dir_down {
    game.cursor_y = @types.clampi(game.cursor_y + 1, 1, game.board_h)
  }
}

///|
fn update_cursor_hold(game : @types.Game, dt : Float, held_dir : Int) -> Unit {
  if game.state != @types.state_play {
    game.hold_dir = @types.dir_none
    game.repeat_t = 0.0
    return
  }

  if held_dir == @types.dir_none {
    game.hold_dir = @types.dir_none
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

  if game.touch_action_cd > 0.0 {
    game.touch_action_cd = game.touch_action_cd - dt
    if game.touch_action_cd < 0.0 {
      game.touch_action_cd = 0.0
    }
  }

  if game.hint_active {
    game.hint_ttl = game.hint_ttl - dt
    if game.hint_ttl <= 0.0 {
      @types.clear_hint(game)
    }
  }

  if game.state == @types.state_play {
    game.timer = game.timer - dt
    if game.timer <= 0.0 {
      game.timer = 0.0
      game.state = @types.state_fail
      game.combo = 0
      @types.clear_selection(game)
      @types.clear_hint(game)
      game.message = "Time up"
      game.message_t = 1.2
      game.shake_t = 0.25
    }
  }

  @types.update_sparks(game, dt)
}

///|
fn place_cursor_on_first_tile(game : @types.Game) -> Unit {
  let mut found : Bool = false
  for y in 1..<=game.board_h {
    for x in 1..<=game.board_w {
      if @types.cell_at(game, x, y) > 0 {
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
fn load_level(game : @types.Game, level_id : Int) -> Unit {
  let mut id : Int = level_id
  if id < 0 {
    id = 0
  }
  if id >= game.level_count {
    id = game.level_count - 1
  }

  let (w, h, kinds, limit, hints, shuffles, undos, pattern, name) = @types.configure_level(
    id,
  )

  game.level_index = id
  game.level_name = name

  game.board_w = @types.mini(w, @types.max_cols)
  game.board_h = @types.mini(h, @types.max_rows)
  game.kind_count = @types.maxi(2, kinds)

  game.time_limit = limit
  game.timer = limit

  game.hints_left = hints
  game.shuffles_left = shuffles
  game.undos_left = undos

  game.combo = 0
  game.hold_dir = @types.dir_none
  game.repeat_t = 0.0
  game.touch_action_cd = 0.0

  @types.clear_selection(game)
  @types.clear_hint(game)
  @types.clear_undo(game)
  @types.clear_sparks(game)

  set_pattern_active(game, pattern)
  fill_board_with_pairs(game)

  for _t in 0..<24 {
    if find_any_move(game).0 {
      break
    }
    ignore(reshuffle(game, false))
  }

  place_cursor_on_first_tile(game)

  game.state = @types.state_play
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
    game.state = @types.state_campaign_clear
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

  if @raylib.is_key_pressed(@raylib.KeyF11) {
    @raylib.toggle_borderless_windowed()
  }

  update_timers(game, dt)

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

    let select_press : Bool = detect_select_press(game)
    let hint_press : Bool = detect_hint_press(game)
    let shuffle_press : Bool = detect_shuffle_press(game)
    let undo_press : Bool = detect_undo_press(game)
    let clear_press : Bool = detect_clear_press(game)
    let board_tap = detect_board_tap(game)

    if reset_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.2
      reload_level(game)
    } else if clear_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.12
      @types.clear_selection(game)
      @types.clear_hint(game)
      game.message = "Selection cleared"
      game.message_t = 0.45
    } else if hint_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.2
      ignore(use_hint(game))
    } else if shuffle_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.2
      ignore(reshuffle(game, true))
    } else if undo_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.18
      ignore(undo_last(game))
    } else if board_tap.0 && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.1
      pick_tile(game, board_tap.1, board_tap.2)
    } else if select_press && game.touch_action_cd <= 0.0 {
      game.touch_action_cd = 0.1
      pick_cursor(game)
    }
  } else if game.state == @types.state_level_clear {
    if next_press {
      next_level(game)
    }
  } else if game.state == @types.state_campaign_clear {
    if next_press {
      restart_campaign(game)
    }
  } else if reset_press || next_press {
    reload_level(game)
  }
}
