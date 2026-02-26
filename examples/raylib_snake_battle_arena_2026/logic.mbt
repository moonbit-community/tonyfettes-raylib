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
fn dir_dx(dir : Int) -> Int {
  if dir == dir_left {
    -1
  } else if dir == dir_right {
    1
  } else {
    0
  }
}

///|
fn dir_dy(dir : Int) -> Int {
  if dir == dir_up {
    -1
  } else if dir == dir_down {
    1
  } else {
    0
  }
}

///|
fn opposite_dir(a : Int, b : Int) -> Bool {
  (a == dir_left && b == dir_right) ||
  (a == dir_right && b == dir_left) ||
  (a == dir_up && b == dir_down) ||
  (a == dir_down && b == dir_up)
}

///|
fn wrap_x(x : Int) -> Int {
  if x < 0 {
    grid_w - 1
  } else if x >= grid_w {
    0
  } else {
    x
  }
}

///|
fn wrap_y(y : Int) -> Int {
  if y < 0 {
    grid_h - 1
  } else if y >= grid_h {
    0
  } else {
    y
  }
}

///|
fn board_metrics(game : Game) -> (Int, Int, Int) {
  let tile_x : Int = board_area_w / grid_w
  let tile_y : Int = board_area_h / grid_h

  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 30, 45)

  let mut bx : Int = board_area_x + (board_area_w - grid_w * tile) / 2
  let mut by : Int = board_area_y + (board_area_h - grid_h * tile) / 2

  if game.shake_t > 0.0 {
    bx = bx + @raylib.get_random_value(-3, 3)
    by = by + @raylib.get_random_value(-3, 3)
  }

  (bx, by, tile)
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
      randf(-240.0, 240.0),
      randf(-260.0, 140.0),
      randf(0.2, 1.0),
      randf(1.2, 5.0),
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
    game.sparks[i].vy = game.sparks[i].vy * (1.0 - dt * 2.1) + dt * 160.0
  }
}

///|
fn player_segment_at(game : Game, x : Int, y : Int, ignore_tail : Bool) -> Bool {
  let mut end : Int = game.p_len
  if ignore_tail && game.p_grow <= 0 {
    end = maxi(0, end - 1)
  }

  for i = 0; i < end; i = i + 1 {
    if game.p_seg_x[i] == x && game.p_seg_y[i] == y {
      return true
    }
  }

  false
}

///|
fn rival_segment_at(
  game : Game,
  x : Int,
  y : Int,
  ignore_rid : Int,
  ignore_tail : Bool,
) -> Bool {
  for rid = 0; rid < game.rivals.length(); rid = rid + 1 {
    if not(game.rivals[rid].alive) {
      continue
    }

    if ignore_rid >= 0 && rid == ignore_rid {
      if ignore_tail {
        let end : Int = if game.rivals[rid].grow <= 0 {
          maxi(0, game.rivals[rid].len - 1)
        } else {
          game.rivals[rid].len
        }

        for i = 0; i < end; i = i + 1 {
          if game.rivals[rid].seg_x[i] == x && game.rivals[rid].seg_y[i] == y {
            return true
          }
        }
      }
      continue
    }

    for i = 0; i < game.rivals[rid].len; i = i + 1 {
      if game.rivals[rid].seg_x[i] == x && game.rivals[rid].seg_y[i] == y {
        return true
      }
    }
  }

  false
}

///|
fn trap_at(game : Game, x : Int, y : Int) -> Bool {
  game.trap_active && game.trap_x == x && game.trap_y == y
}

///|
fn is_cell_empty(game : Game, x : Int, y : Int) -> Bool {
  if player_segment_at(game, x, y, false) {
    return false
  }

  if rival_segment_at(game, x, y, -1, false) {
    return false
  }

  if trap_at(game, x, y) {
    return false
  }

  true
}

///|
fn random_empty_cell(game : Game) -> (Bool, Int, Int) {
  let mut empty_count : Int = 0

  for y = 0; y < grid_h; y = y + 1 {
    for x = 0; x < grid_w; x = x + 1 {
      if is_cell_empty(game, x, y) {
        empty_count = empty_count + 1
      }
    }
  }

  if empty_count <= 0 {
    return (false, 0, 0)
  }

  let pick : Int = @raylib.get_random_value(0, empty_count - 1)
  let mut seen : Int = 0

  for y = 0; y < grid_h; y = y + 1 {
    for x = 0; x < grid_w; x = x + 1 {
      if not(is_cell_empty(game, x, y)) {
        continue
      }

      if seen == pick {
        return (true, x, y)
      }

      seen = seen + 1
    }
  }

  (false, 0, 0)
}

///|
fn spawn_food(game : Game) -> Bool {
  let cell = random_empty_cell(game)
  if not(cell.0) {
    return false
  }

  game.food_x = cell.1
  game.food_y = cell.2
  game.food_kind = if @raylib.get_random_value(0, 99) < 22 {
    food_gold
  } else {
    food_normal
  }

  true
}

///|
fn spawn_trap(game : Game) -> Bool {
  if game.trap_active {
    return false
  }

  let cell = random_empty_cell(game)
  if not(cell.0) {
    return false
  }

  game.trap_x = cell.1
  game.trap_y = cell.2
  game.trap_active = true
  game.trap_ttl = randf(8.0, 14.0)
  game.trap_flash = 0.0

  let (wx, wy) = cell_world_center(game, game.trap_x, game.trap_y)
  burst(game, wx, wy, 12, 2)
  true
}

///|
fn reset_player(game : Game, cx : Int, cy : Int) -> Unit {
  game.p_alive = true
  game.p_len = 5
  game.p_dir = dir_right
  game.p_next_dir = dir_right
  game.p_grow = 0

  for i = 0; i < game.p_seg_x.length(); i = i + 1 {
    game.p_seg_x[i] = -100
    game.p_seg_y[i] = -100
  }

  for i = 0; i < game.p_len; i = i + 1 {
    game.p_seg_x[i] = wrap_x(cx - i)
    game.p_seg_y[i] = cy
  }
}

///|
fn reset_rival(game : Game, rid : Int, cx : Int, cy : Int, dir : Int) -> Unit {
  let rival = game.rivals[rid]
  rival.alive = true
  rival.len = 4
  rival.dir = dir
  rival.next_dir = dir
  rival.grow = 0

  for i = 0; i < rival.seg_x.length(); i = i + 1 {
    rival.seg_x[i] = -100
    rival.seg_y[i] = -100
  }

  for i = 0; i < rival.len; i = i + 1 {
    let offset : Int = if dir == dir_left { i } else { -i }
    rival.seg_x[i] = wrap_x(cx + offset)
    rival.seg_y[i] = cy
  }
}

///|
fn start_match(game : Game) -> Unit {
  clear_effects(game)

  game.state = state_play
  game.score = 0
  game.lives = lives_default
  game.total_kills = 0
  game.combo = 0
  game.combo_t = 0.0

  game.step_acc = 0.0
  game.game_t = 0.0
  game.ui_t = 0.0

  game.boost_meter = 1.0
  game.boost_on = false
  game.hint_left = 3
  game.hint_t = 0.0

  game.trap_active = false
  game.trap_ttl = 0.0
  game.trap_flash = 0.0

  game.msg_t = 0.0
  game.shake_t = 0.0
  game.touch_cd = 0.0
  game.win = false

  reset_player(game, grid_w / 2, grid_h / 2)

  reset_rival(game, 0, 6, 4, dir_right)
  if game.rivals.length() > 1 {
    reset_rival(game, 1, grid_w - 7, grid_h - 5, dir_left)
  }

  ignore(spawn_food(game))

  set_msg(game, "Collect food and outlast rivals", 1.8)
}

///|
fn cell_hits_player(game : Game, x : Int, y : Int) -> Bool {
  player_segment_at(game, x, y, false)
}

///|
fn damage_player(game : Game, msg : String) -> Unit {
  game.lives = game.lives - 1
  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = maxf(game.shake_t, 0.2)

  let (wx, wy) = cell_world_center(game, game.p_seg_x[0], game.p_seg_y[0])
  burst(game, wx, wy, 22, 2)

  if game.lives <= 0 {
    game.state = state_result
    game.win = false
    if game.score > game.best_score {
      game.best_score = game.score
    }
    set_msg(game, "Snake down", 1.6)
    return
  }

  reset_player(game, grid_w / 2, grid_h / 2)
  set_msg(game, msg + "  Lives \{game.lives}", 1.0)
}

///|
fn rival_respawn(game : Game, rid : Int) -> Unit {
  if rid < 0 || rid >= game.rivals.length() {
    return
  }

  game.rivals[rid].deaths = game.rivals[rid].deaths + 1

  let sx : Int = if rid % 2 == 0 { 3 } else { grid_w - 4 }
  let sy : Int = if rid % 2 == 0 { 3 } else { grid_h - 4 }
  let dir : Int = if rid % 2 == 0 { dir_right } else { dir_left }
  reset_rival(game, rid, sx, sy, dir)
}

///|
fn grow_player_after_food(game : Game) -> Unit {
  if game.food_kind == food_gold {
    game.p_grow = game.p_grow + 3
    game.score = game.score + 210
    game.combo = game.combo + 2
    set_msg(game, "Gold food!", 0.9)
  } else {
    game.p_grow = game.p_grow + 1
    game.score = game.score + 80
    game.combo = game.combo + 1
  }

  game.combo_t = 1.1

  if game.combo > 1 {
    game.score = game.score + game.combo * 12
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }

  ignore(spawn_food(game))

  if @raylib.get_random_value(0, 99) < 16 {
    ignore(spawn_trap(game))
  }
}

///|
fn shift_player_forward(game : Game, nx : Int, ny : Int) -> Unit {
  let cap : Int = mini(game.p_len, max_segments - 1)

  for i = cap; i > 0; i = i - 1 {
    game.p_seg_x[i] = game.p_seg_x[i - 1]
    game.p_seg_y[i] = game.p_seg_y[i - 1]
  }

  game.p_seg_x[0] = nx
  game.p_seg_y[0] = ny

  if game.p_grow > 0 {
    game.p_grow = game.p_grow - 1
    game.p_len = mini(max_segments, game.p_len + 1)
  }
}

///|
fn player_step(game : Game) -> Unit {
  if not(game.p_alive) {
    return
  }

  if not(opposite_dir(game.p_dir, game.p_next_dir)) {
    game.p_dir = game.p_next_dir
  }

  let nx : Int = wrap_x(game.p_seg_x[0] + dir_dx(game.p_dir))
  let ny : Int = wrap_y(game.p_seg_y[0] + dir_dy(game.p_dir))

  let self_hit : Bool = player_segment_at(game, nx, ny, true)
  let rival_hit : Bool = rival_segment_at(game, nx, ny, -1, false)
  let trap_hit : Bool = trap_at(game, nx, ny)

  if self_hit || rival_hit || trap_hit {
    damage_player(game, if trap_hit { "Trap hit" } else { "Crash" })
    return
  }

  shift_player_forward(game, nx, ny)

  if nx == game.food_x && ny == game.food_y {
    let (wx, wy) = cell_world_center(game, nx, ny)
    burst(game, wx, wy, if game.food_kind == food_gold { 16 } else { 10 }, 1)
    grow_player_after_food(game)
  }
}

///|
fn shift_rival_forward(game : Game, rid : Int, nx : Int, ny : Int) -> Unit {
  let rival = game.rivals[rid]
  let cap : Int = mini(rival.len, max_segments - 1)

  for i = cap; i > 0; i = i - 1 {
    rival.seg_x[i] = rival.seg_x[i - 1]
    rival.seg_y[i] = rival.seg_y[i - 1]
  }

  rival.seg_x[0] = nx
  rival.seg_y[0] = ny

  if rival.grow > 0 {
    rival.grow = rival.grow - 1
    rival.len = mini(max_segments, rival.len + 1)
  }
}

///|
fn rival_would_collide(game : Game, rid : Int, nx : Int, ny : Int) -> Bool {
  if player_segment_at(game, nx, ny, false) {
    return true
  }

  if rival_segment_at(game, nx, ny, rid, true) {
    return true
  }

  trap_at(game, nx, ny)
}

///|
fn rival_step(game : Game, rid : Int) -> Unit {
  if rid < 0 || rid >= game.rivals.length() {
    return
  }

  let rival = game.rivals[rid]
  if not(rival.alive) {
    return
  }

  rival.next_dir = ai_choose_dir(game, rid)
  if not(opposite_dir(rival.dir, rival.next_dir)) {
    rival.dir = rival.next_dir
  }

  let nx : Int = wrap_x(rival.seg_x[0] + dir_dx(rival.dir))
  let ny : Int = wrap_y(rival.seg_y[0] + dir_dy(rival.dir))

  let hits_player : Bool = cell_hits_player(game, nx, ny)
  let hits_rival : Bool = rival_segment_at(game, nx, ny, rid, true)
  let hits_trap : Bool = trap_at(game, nx, ny)

  if hits_player {
    if nx == game.p_seg_x[0] && ny == game.p_seg_y[0] {
      damage_player(game, "Head clash")
    } else {
      // Rival ran into player body: reward player.
      game.total_kills = game.total_kills + 1
      game.score = game.score + 120
      if game.score > game.best_score {
        game.best_score = game.score
      }
      let (wx, wy) = cell_world_center(game, nx, ny)
      burst(game, wx, wy, 14, 0)
      set_msg(game, "Rival crashed", 0.7)
    }

    rival_respawn(game, rid)
    return
  }

  if hits_rival || hits_trap {
    rival_respawn(game, rid)
    return
  }

  shift_rival_forward(game, rid, nx, ny)

  if nx == game.food_x && ny == game.food_y {
    let grow_gain : Int = if game.food_kind == food_gold { 2 } else { 1 }
    let score_gain : Int = if game.food_kind == food_gold { 140 } else { 64 }
    let burst_count : Int = if game.food_kind == food_gold { 14 } else { 8 }

    rival.grow = rival.grow + grow_gain
    rival.score = rival.score + score_gain

    let (wx, wy) = cell_world_center(game, nx, ny)
    burst(game, wx, wy, burst_count, 1)
    ignore(spawn_food(game))

    if @raylib.get_random_value(0, 99) < 14 {
      ignore(spawn_trap(game))
    }
  }
}

///|
fn rival_total_score(game : Game) -> Int {
  let mut s : Int = 0
  for i = 0; i < game.rivals.length(); i = i + 1 {
    s = s + game.rivals[i].score
  }
  s
}

///|
fn update_hint(game : Game) -> Unit {
  if game.hint_t > 0.0 {
    return
  }

  game.hint_x = game.p_seg_x[0]
  game.hint_y = game.p_seg_y[0]
}

///|
fn use_hint(game : Game) -> Bool {
  if game.state != state_play {
    return false
  }
  if game.hint_left <= 0 {
    set_msg(game, "No hints", 0.6)
    return false
  }

  let best = suggest_player_dir(game)
  if best < 0 {
    set_msg(game, "No safe hint", 0.7)
    return false
  }

  game.hint_left = game.hint_left - 1
  game.p_next_dir = best

  let nx : Int = wrap_x(game.p_seg_x[0] + dir_dx(best))
  let ny : Int = wrap_y(game.p_seg_y[0] + dir_dy(best))
  game.hint_x = nx
  game.hint_y = ny
  game.hint_t = 1.4

  set_msg(game, "Hint: move now", 0.8)
  true
}

///|
fn check_timeout(game : Game) -> Unit {
  if game.game_t < match_time_limit {
    return
  }

  game.state = state_result
  game.win = game.score >= rival_total_score(game)

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if game.win {
    set_msg(game, "Arena secured", 1.5)
  } else {
    set_msg(game, "Rivals won", 1.5)
  }
}

///|
fn step_once(game : Game) -> Unit {
  if game.state != state_play {
    return
  }

  player_step(game)
  if game.state != state_play {
    return
  }

  for rid = 0; rid < game.rivals.length(); rid = rid + 1 {
    rival_step(game, rid)
    if game.state != state_play {
      return
    }
  }

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - 0.08
  } else if game.combo > 0 {
    game.combo = game.combo - 1
    game.combo_t = 0.26
  }

  if @raylib.get_random_value(0, 999) < 8 {
    ignore(spawn_trap(game))
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.state == state_play {
    game.game_t = game.game_t + dt
  }

  if game.msg_t > 0.0 {
    game.msg_t = game.msg_t - dt
  }
  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
  }
  if game.hint_t > 0.0 {
    game.hint_t = game.hint_t - dt
  }
  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }

  if game.trap_active {
    game.trap_ttl = game.trap_ttl - dt
    game.trap_flash = game.trap_flash + dt
    if game.trap_ttl <= 0.0 {
      game.trap_active = false
      game.trap_ttl = 0.0
      game.trap_flash = 0.0
    }
  }

  update_sparks(game, dt)

  if game.state != state_play {
    return
  }

  let base_step : Float = if game.boost_on { 0.078 } else { 0.118 }

  if game.boost_on {
    game.boost_meter = clampf(game.boost_meter - dt * 0.52, 0.0, 1.0)
    if game.boost_meter <= 0.0 {
      game.boost_on = false
    }
  } else {
    game.boost_meter = clampf(game.boost_meter + dt * 0.22, 0.0, 1.0)
  }

  game.step_acc = game.step_acc + dt

  while game.step_acc >= base_step {
    game.step_acc = game.step_acc - base_step
    step_once(game)

    if game.state != state_play {
      break
    }
  }

  update_hint(game)
  check_timeout(game)
}
