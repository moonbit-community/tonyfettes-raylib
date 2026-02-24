///|
fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
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
fn cell_index(x : Int, y : Int) -> Int {
  y * board_cols + x
}

///|
fn cell_x(idx : Int) -> Int {
  idx % board_cols
}

///|
fn cell_y(idx : Int) -> Int {
  idx / board_cols
}

///|
fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_cols && y >= 0 && y < board_rows
}

///|
fn tile_at(game : Game, x : Int, y : Int) -> Int {
  if in_bounds(x, y) {
    game.tiles[cell_index(x, y)]
  } else {
    tile_wall
  }
}

///|
fn set_tile(game : Game, x : Int, y : Int, tile : Int) -> Unit {
  if in_bounds(x, y) {
    game.tiles[cell_index(x, y)] = tile
  }
}

///|
fn fill_board_floor(game : Game) -> Unit {
  for i = 0; i < game.tiles.length(); i = i + 1 {
    game.tiles[i] = tile_floor
  }
}

///|
fn add_wall_rect(game : Game, x : Int, y : Int, w : Int, h : Int) -> Unit {
  for yy = y; yy < y + h; yy = yy + 1 {
    for xx = x; xx < x + w; xx = xx + 1 {
      set_tile(game, xx, yy, tile_wall)
    }
  }
}

///|
fn carve_floor_rect(game : Game, x : Int, y : Int, w : Int, h : Int) -> Unit {
  for yy = y; yy < y + h; yy = yy + 1 {
    for xx = x; xx < x + w; xx = xx + 1 {
      set_tile(game, xx, yy, tile_floor)
    }
  }
}

///|
fn add_border_walls(game : Game) -> Unit {
  add_wall_rect(game, 0, 0, board_cols, 1)
  add_wall_rect(game, 0, board_rows - 1, board_cols, 1)
  add_wall_rect(game, 0, 0, 1, board_rows)
  add_wall_rect(game, board_cols - 1, 0, 1, board_rows)
}

///|
fn clear_entities(game : Game) -> Unit {
  game.artifacts = []
  game.guards = []
  game.artifacts_total = 0
  game.artifacts_collected = 0
}

///|
fn spawn_artifact(game : Game, x : Int, y : Int) -> Unit {
  if tile_at(game, x, y) != tile_floor {
    return
  }

  game.artifacts.push({ x, y, taken: false })
  game.artifacts_total = game.artifacts_total + 1
}

///|
fn spawn_guard(
  game : Game,
  path : Array[Int],
  view_range : Int,
  phase : Float,
) -> Unit {
  if path.length() == 0 {
    return
  }

  let first = path[0]
  let gx = cell_x(first)
  let gy = cell_y(first)

  let mut dir_x : Int = 1
  let mut dir_y : Int = 0
  let mut next_idx : Int = 0

  if path.length() > 1 {
    next_idx = 1
    let nx = cell_x(path[1])
    let ny = cell_y(path[1])
    if nx > gx {
      dir_x = 1
      dir_y = 0
    } else if nx < gx {
      dir_x = -1
      dir_y = 0
    } else if ny > gy {
      dir_x = 0
      dir_y = 1
    } else if ny < gy {
      dir_x = 0
      dir_y = -1
    }
  }

  game.guards.push({
    x: gx,
    y: gy,
    dir_x,
    dir_y,
    view_range,
    path,
    path_index: next_idx,
    step_timer: phase,
  })
}

///|
fn pc(x : Int, y : Int) -> Int {
  cell_index(x, y)
}

///|
fn setup_level_1(game : Game) -> Unit {
  game.level_name = "East Wing Silent Sweep"
  game.player_x = 2
  game.player_y = 11
  game.exit_x = 17
  game.exit_y = 2

  add_wall_rect(game, 6, 1, 1, 11)
  carve_floor_rect(game, 6, 5, 1, 2)
  add_wall_rect(game, 6, 7, 12, 1)
  carve_floor_rect(game, 10, 7, 2, 1)
  add_wall_rect(game, 13, 3, 1, 10)
  carve_floor_rect(game, 13, 9, 1, 2)
  add_wall_rect(game, 2, 10, 5, 1)
  carve_floor_rect(game, 4, 10, 2, 1)
  add_wall_rect(game, 15, 2, 1, 4)
  carve_floor_rect(game, 15, 4, 1, 1)

  spawn_artifact(game, 4, 3)
  spawn_artifact(game, 11, 10)
  spawn_artifact(game, 16, 11)

  spawn_guard(game, [pc(3, 2), pc(10, 2), pc(10, 6), pc(3, 6)], 6, 0.00)
  spawn_guard(game, [pc(16, 3), pc(18, 3), pc(18, 10), pc(16, 10)], 6, 0.12)
}

///|
fn setup_level_2(game : Game) -> Unit {
  game.level_name = "Laser Hall Maze"
  game.player_x = 2
  game.player_y = 2
  game.exit_x = 18
  game.exit_y = 11

  add_wall_rect(game, 4, 1, 1, 12)
  carve_floor_rect(game, 4, 4, 1, 1)
  carve_floor_rect(game, 4, 9, 1, 1)

  add_wall_rect(game, 9, 1, 1, 12)
  carve_floor_rect(game, 9, 6, 1, 1)

  add_wall_rect(game, 14, 1, 1, 12)
  carve_floor_rect(game, 14, 8, 1, 1)

  add_wall_rect(game, 4, 5, 11, 1)
  carve_floor_rect(game, 7, 5, 1, 1)
  carve_floor_rect(game, 12, 5, 1, 1)

  add_wall_rect(game, 1, 9, 18, 1)
  carve_floor_rect(game, 5, 9, 1, 1)
  carve_floor_rect(game, 15, 9, 1, 1)

  spawn_artifact(game, 6, 11)
  spawn_artifact(game, 10, 3)
  spawn_artifact(game, 13, 7)
  spawn_artifact(game, 17, 2)

  spawn_guard(game, [pc(6, 2), pc(7, 2), pc(7, 7), pc(6, 7)], 5, 0.00)
  spawn_guard(game, [pc(16, 2), pc(18, 2), pc(18, 7), pc(16, 7)], 6, 0.16)
  spawn_guard(game, [pc(2, 10), pc(3, 10), pc(3, 12), pc(2, 12)], 5, 0.28)
}

///|
fn setup_level_3(game : Game) -> Unit {
  game.level_name = "Grand Vault Orbit"
  game.player_x = 1
  game.player_y = 12
  game.exit_x = 18
  game.exit_y = 1

  add_wall_rect(game, 5, 1, 1, 12)
  carve_floor_rect(game, 5, 3, 1, 1)
  carve_floor_rect(game, 5, 10, 1, 1)

  add_wall_rect(game, 10, 1, 1, 12)
  carve_floor_rect(game, 10, 7, 1, 1)

  add_wall_rect(game, 15, 1, 1, 12)
  carve_floor_rect(game, 15, 4, 1, 1)
  carve_floor_rect(game, 15, 9, 1, 1)

  add_wall_rect(game, 5, 4, 11, 1)
  carve_floor_rect(game, 8, 4, 1, 1)
  carve_floor_rect(game, 13, 4, 1, 1)

  add_wall_rect(game, 1, 8, 18, 1)
  carve_floor_rect(game, 4, 8, 1, 1)
  carve_floor_rect(game, 11, 8, 1, 1)
  carve_floor_rect(game, 17, 8, 1, 1)

  spawn_artifact(game, 3, 3)
  spawn_artifact(game, 8, 6)
  spawn_artifact(game, 11, 10)
  spawn_artifact(game, 16, 5)
  spawn_artifact(game, 17, 11)

  spawn_guard(game, [pc(2, 2), pc(4, 2), pc(4, 6), pc(2, 6)], 6, 0.00)
  spawn_guard(game, [pc(11, 2), pc(13, 2), pc(13, 6), pc(11, 6)], 5, 0.13)
  spawn_guard(game, [pc(2, 9), pc(4, 9), pc(4, 12), pc(2, 12)], 5, 0.26)
  spawn_guard(game, [pc(16, 9), pc(18, 9), pc(18, 12), pc(16, 12)], 6, 0.34)
}

///|
fn load_level(game : Game, level_idx : Int) -> Unit {
  let safe_idx = clampi(level_idx, 0, game.level_count - 1)
  game.level_index = safe_idx

  clear_entities(game)
  fill_board_floor(game)
  add_border_walls(game)

  if safe_idx == 0 {
    setup_level_1(game)
  } else if safe_idx == 1 {
    setup_level_2(game)
  } else {
    setup_level_3(game)
  }

  game.player_step_t = 0.0
  game.state_t = 0.0
  game.alarm_t = 0.0
}

///|
fn reset_to_title(game : Game) -> Unit {
  load_level(game, 0)
  game.state = state_title
  game.state_t = 0.0
}

///|
fn start_campaign(game : Game) -> Unit {
  load_level(game, 0)
  game.state = state_play
  game.state_t = 0.0
}

///|
fn retry_level(game : Game) -> Unit {
  load_level(game, game.level_index)
  game.state = state_play
  game.state_t = 0.0
}

///|
fn go_to_next_level(game : Game) -> Unit {
  let next_level = game.level_index + 1
  if next_level < game.level_count {
    load_level(game, next_level)
    game.state = state_play
    game.state_t = 0.0
  } else {
    game.state = state_campaign_clear
    game.state_t = 0.0
  }
}

///|
fn preview_next_title_level(game : Game) -> Unit {
  let next_level = (game.level_index + 1) % game.level_count
  load_level(game, next_level)
  game.state = state_title
}

///|
fn walkable(game : Game, x : Int, y : Int) -> Bool {
  tile_at(game, x, y) == tile_floor
}

///|
fn dir_delta(dir : Int) -> (Int, Int) {
  if dir == dir_left {
    (-1, 0)
  } else if dir == dir_right {
    (1, 0)
  } else if dir == dir_up {
    (0, -1)
  } else if dir == dir_down {
    (0, 1)
  } else {
    (0, 0)
  }
}

///|
fn try_move_player(game : Game, dir : Int) -> Unit {
  if dir == dir_none {
    return
  }
  if game.player_step_t > 0.0 {
    return
  }

  let (dx, dy) = dir_delta(dir)
  let nx = game.player_x + dx
  let ny = game.player_y + dy
  if walkable(game, nx, ny) {
    game.player_x = nx
    game.player_y = ny
  }
  game.player_step_t = player_step_interval
}

///|
fn collect_artifacts(game : Game) -> Unit {
  for i = 0; i < game.artifacts.length(); i = i + 1 {
    if game.artifacts[i].taken {
      continue
    }
    if game.artifacts[i].x == game.player_x &&
      game.artifacts[i].y == game.player_y {
      game.artifacts[i].taken = true
      game.artifacts_collected = game.artifacts_collected + 1
    }
  }
}

///|
fn has_line_of_sight(
  game : Game,
  from_x : Int,
  from_y : Int,
  to_x : Int,
  to_y : Int,
) -> Bool {
  let mut x = from_x
  let mut y = from_y
  let dx = absi(to_x - from_x)
  let sx = if from_x < to_x { 1 } else if from_x > to_x { -1 } else { 0 }
  let dy = -absi(to_y - from_y)
  let sy = if from_y < to_y { 1 } else if from_y > to_y { -1 } else { 0 }
  let mut err = dx + dy

  while true {
    if x == to_x && y == to_y {
      break
    }

    let e2 = 2 * err
    if e2 >= dy {
      err = err + dy
      x = x + sx
    }
    if e2 <= dx {
      err = err + dx
      y = y + sy
    }

    if x == to_x && y == to_y {
      break
    }
    if tile_at(game, x, y) == tile_wall {
      return false
    }
  }

  true
}

///|
fn in_guard_front(g : Guard, dx : Int, dy : Int) -> Bool {
  let adx = absi(dx)
  let ady = absi(dy)

  if g.dir_x > 0 {
    dx >= 0 && ady <= dx
  } else if g.dir_x < 0 {
    dx <= 0 && ady <= -dx
  } else if g.dir_y > 0 {
    dy >= 0 && adx <= dy
  } else if g.dir_y < 0 {
    dy <= 0 && adx <= -dy
  } else {
    true
  }
}

///|
fn guard_sees_cell(game : Game, g : Guard, cx : Int, cy : Int) -> Bool {
  if not(in_bounds(cx, cy)) {
    return false
  }
  if tile_at(game, cx, cy) == tile_wall {
    return false
  }
  if cx == g.x && cy == g.y {
    return true
  }

  let dx = cx - g.x
  let dy = cy - g.y
  let dist = maxi(absi(dx), absi(dy))
  if dist > g.view_range {
    return false
  }
  if not(in_guard_front(g, dx, dy)) {
    return false
  }

  has_line_of_sight(game, g.x, g.y, cx, cy)
}

///|
fn any_guard_on_cell(game : Game, cx : Int, cy : Int) -> Bool {
  for i = 0; i < game.guards.length(); i = i + 1 {
    if game.guards[i].x == cx && game.guards[i].y == cy {
      return true
    }
  }
  false
}

///|
fn player_spotted(game : Game) -> Bool {
  if any_guard_on_cell(game, game.player_x, game.player_y) {
    return true
  }

  for i = 0; i < game.guards.length(); i = i + 1 {
    if guard_sees_cell(game, game.guards[i], game.player_x, game.player_y) {
      return true
    }
  }
  false
}

///|
fn advance_guard_once(game : Game, guard_idx : Int) -> Unit {
  let path_len = game.guards[guard_idx].path.length()
  if path_len == 0 {
    return
  }

  if game.guards[guard_idx].path_index < 0 ||
    game.guards[guard_idx].path_index >= path_len {
    game.guards[guard_idx].path_index = 0
  }

  let mut target_idx = game.guards[guard_idx].path_index
  let mut target = game.guards[guard_idx].path[target_idx]
  let mut tx = cell_x(target)
  let mut ty = cell_y(target)

  if game.guards[guard_idx].x == tx && game.guards[guard_idx].y == ty {
    target_idx = (target_idx + 1) % path_len
    game.guards[guard_idx].path_index = target_idx
    target = game.guards[guard_idx].path[target_idx]
    tx = cell_x(target)
    ty = cell_y(target)
  }

  let mut dx : Int = 0
  let mut dy : Int = 0
  if game.guards[guard_idx].x < tx {
    dx = 1
  } else if game.guards[guard_idx].x > tx {
    dx = -1
  } else if game.guards[guard_idx].y < ty {
    dy = 1
  } else if game.guards[guard_idx].y > ty {
    dy = -1
  }

  if dx == 0 && dy == 0 {
    return
  }

  let nx = game.guards[guard_idx].x + dx
  let ny = game.guards[guard_idx].y + dy
  if walkable(game, nx, ny) {
    game.guards[guard_idx].x = nx
    game.guards[guard_idx].y = ny
    game.guards[guard_idx].dir_x = dx
    game.guards[guard_idx].dir_y = dy
  } else {
    game.guards[guard_idx].path_index = (game.guards[guard_idx].path_index + 1) %
      path_len
  }
}

///|
fn update_guards(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.guards.length(); i = i + 1 {
    game.guards[i].step_timer = game.guards[i].step_timer - dt
    while game.guards[i].step_timer <= 0.0 {
      game.guards[i].step_timer = game.guards[i].step_timer +
        guard_step_interval
      advance_guard_once(game, i)
    }
  }
}

///|
fn exit_unlocked(game : Game) -> Bool {
  game.artifacts_total > 0 && game.artifacts_collected >= game.artifacts_total
}

///|
fn current_level_is_last(game : Game) -> Bool {
  game.level_index + 1 >= game.level_count
}

///|
fn complete_level(game : Game) -> Unit {
  if current_level_is_last(game) {
    game.state = state_campaign_clear
  } else {
    game.state = state_win
  }
  game.state_t = 0.0
}

///|
fn trigger_loss(game : Game) -> Unit {
  game.state = state_lose
  game.state_t = 0.0
  game.alarm_t = alarm_flash_time
}

///|
fn update_play(game : Game, dt : Float, input : FrameInput) -> Unit {
  if input.restart_pressed {
    retry_level(game)
    return
  }

  if game.player_step_t > 0.0 {
    game.player_step_t = game.player_step_t - dt
    if game.player_step_t < 0.0 {
      game.player_step_t = 0.0
    }
  }

  update_guards(game, dt)
  try_move_player(game, input.move_dir)
  collect_artifacts(game)

  if exit_unlocked(game) &&
    game.player_x == game.exit_x &&
    game.player_y == game.exit_y {
    complete_level(game)
    return
  }

  if player_spotted(game) {
    trigger_loss(game)
  }
}

///|
fn actions_ready(game : Game) -> Bool {
  game.state_t >= menu_action_delay
}

///|
fn update_title(game : Game, input : FrameInput) -> Unit {
  if not(actions_ready(game)) {
    return
  }

  if input.start_pressed {
    start_campaign(game)
  } else if input.next_pressed {
    preview_next_title_level(game)
  }
}

///|
fn update_win(game : Game, input : FrameInput) -> Unit {
  if not(actions_ready(game)) {
    return
  }

  if input.next_pressed {
    go_to_next_level(game)
  } else if input.retry_pressed || input.restart_pressed {
    retry_level(game)
  }
}

///|
fn update_lose(game : Game, input : FrameInput) -> Unit {
  if not(actions_ready(game)) {
    return
  }

  if input.retry_pressed || input.next_pressed || input.start_pressed {
    retry_level(game)
  }
}

///|
fn update_campaign_clear(game : Game, input : FrameInput) -> Unit {
  if not(actions_ready(game)) {
    return
  }

  if input.start_pressed || input.next_pressed || input.retry_pressed {
    reset_to_title(game)
  }
}

///|
fn update_game(game : Game, dt : Float, input : FrameInput) -> Unit {
  let mut capped_dt = dt
  if capped_dt < 0.0 {
    capped_dt = 0.0
  }
  if capped_dt > 0.05 {
    capped_dt = 0.05
  }

  game.state_t = game.state_t + capped_dt
  game.pulse_t = game.pulse_t + capped_dt

  if game.alarm_t > 0.0 {
    game.alarm_t = game.alarm_t - capped_dt
    if game.alarm_t < 0.0 {
      game.alarm_t = 0.0
    }
  }

  if game.state == state_title {
    update_title(game, input)
  } else if game.state == state_play {
    update_play(game, capped_dt, input)
  } else if game.state == state_win {
    update_win(game, input)
  } else if game.state == state_lose {
    update_lose(game, input)
  } else {
    update_campaign_clear(game, input)
  }
}
