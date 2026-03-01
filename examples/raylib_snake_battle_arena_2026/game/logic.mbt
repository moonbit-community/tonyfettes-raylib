///|
fn clear_effects(game : @types.Game) -> Unit {
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
fn burst(game : @types.Game, x : Float, y : Float, n : Int, kind : Int) -> Unit {
  for _i in 0..<n {
    spawn_spark(
      game,
      x + @types.randf(-8.0, 8.0),
      y + @types.randf(-8.0, 8.0),
      @types.randf(-240.0, 240.0),
      @types.randf(-260.0, 140.0),
      @types.randf(0.2, 1.0),
      @types.randf(1.2, 5.0),
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
    spark.vx = spark.vx * (1.0 - dt * 2.3)
    spark.vy = spark.vy * (1.0 - dt * 2.1) + dt * 160.0
  }
}

///|
fn player_segment_at(
  game : @types.Game,
  x : Int,
  y : Int,
  ignore_tail : Bool,
) -> Bool {
  let mut end : Int = game.p_len
  if ignore_tail && game.p_grow <= 0 {
    end = @types.maxi(0, end - 1)
  }

  for i in 0..<end {
    if game.p_seg_x[i] == x && game.p_seg_y[i] == y {
      return true
    }
  }

  false
}

///|
fn rival_segment_at(
  game : @types.Game,
  x : Int,
  y : Int,
  ignore_rid : Int,
  ignore_tail : Bool,
) -> Bool {
  for rid in 0..<game.rivals.length() {
    if not(game.rivals[rid].alive) {
      continue
    }

    if ignore_rid >= 0 && rid == ignore_rid {
      if ignore_tail {
        let end : Int = if game.rivals[rid].grow <= 0 {
          @types.maxi(0, game.rivals[rid].len - 1)
        } else {
          game.rivals[rid].len
        }

        for i in 0..<end {
          if game.rivals[rid].seg_x[i] == x && game.rivals[rid].seg_y[i] == y {
            return true
          }
        }
      }
      continue
    }

    for i in 0..<game.rivals[rid].len {
      if game.rivals[rid].seg_x[i] == x && game.rivals[rid].seg_y[i] == y {
        return true
      }
    }
  }

  false
}

///|
fn trap_at(game : @types.Game, x : Int, y : Int) -> Bool {
  game.trap_active && game.trap_x == x && game.trap_y == y
}

///|
fn is_cell_empty(game : @types.Game, x : Int, y : Int) -> Bool {
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
fn random_empty_cell(game : @types.Game) -> (Bool, Int, Int) {
  let mut empty_count : Int = 0

  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
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

  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
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
fn spawn_food(game : @types.Game) -> Bool {
  let cell = random_empty_cell(game)
  if not(cell.0) {
    return false
  }

  game.food_x = cell.1
  game.food_y = cell.2
  game.food_kind = if @raylib.get_random_value(0, 99) < 22 {
    @types.food_gold
  } else {
    @types.food_normal
  }

  true
}

///|
fn spawn_trap(game : @types.Game) -> Bool {
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
  game.trap_ttl = @types.randf(8.0, 14.0)
  game.trap_flash = 0.0

  let (wx, wy) = @types.cell_world_center(game, game.trap_x, game.trap_y)
  burst(game, wx, wy, 12, 2)
  true
}

///|
fn reset_player(game : @types.Game, cx : Int, cy : Int) -> Unit {
  game.p_alive = true
  game.p_len = 5
  game.p_dir = @types.dir_right
  game.p_next_dir = @types.dir_right
  game.p_grow = 0

  for i in 0..<game.p_seg_x.length() {
    game.p_seg_x[i] = -100
    game.p_seg_y[i] = -100
  }

  for i in 0..<game.p_len {
    game.p_seg_x[i] = @types.wrap_x(cx - i)
    game.p_seg_y[i] = cy
  }
}

///|
fn reset_rival(
  game : @types.Game,
  rid : Int,
  cx : Int,
  cy : Int,
  dir : Int,
) -> Unit {
  let rival = game.rivals[rid]
  rival.alive = true
  rival.len = 4
  rival.dir = dir
  rival.next_dir = dir
  rival.grow = 0

  for i in 0..<rival.seg_x.length() {
    rival.seg_x[i] = -100
    rival.seg_y[i] = -100
  }

  for i in 0..<rival.len {
    let offset : Int = if dir == @types.dir_left { i } else { -i }
    rival.seg_x[i] = @types.wrap_x(cx + offset)
    rival.seg_y[i] = cy
  }
}

///|
fn start_match(game : @types.Game) -> Unit {
  clear_effects(game)

  game.state = @types.state_play
  game.score = 0
  game.lives = @types.lives_default
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

  reset_player(game, @types.grid_w / 2, @types.grid_h / 2)

  reset_rival(game, 0, 6, 4, @types.dir_right)
  if game.rivals.length() > 1 {
    reset_rival(game, 1, @types.grid_w - 7, @types.grid_h - 5, @types.dir_left)
  }

  ignore(spawn_food(game))

  @types.set_msg(game, "Collect food and outlast rivals", 1.8)
}

///|
fn cell_hits_player(game : @types.Game, x : Int, y : Int) -> Bool {
  player_segment_at(game, x, y, false)
}

///|
fn damage_player(game : @types.Game, msg : String) -> Unit {
  game.lives = game.lives - 1
  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = @types.maxf(game.shake_t, 0.2)

  let (wx, wy) = @types.cell_world_center(
    game,
    game.p_seg_x[0],
    game.p_seg_y[0],
  )
  burst(game, wx, wy, 22, 2)

  if game.lives <= 0 {
    game.state = @types.state_result
    game.win = false
    if game.score > game.best_score {
      game.best_score = game.score
    }
    @types.set_msg(game, "Snake down", 1.6)
    return
  }

  reset_player(game, @types.grid_w / 2, @types.grid_h / 2)
  @types.set_msg(game, msg + "  Lives \{game.lives}", 1.0)
}

///|
fn rival_respawn(game : @types.Game, rid : Int) -> Unit {
  if rid < 0 || rid >= game.rivals.length() {
    return
  }

  game.rivals[rid].deaths = game.rivals[rid].deaths + 1

  let sx : Int = if rid % 2 == 0 { 3 } else { @types.grid_w - 4 }
  let sy : Int = if rid % 2 == 0 { 3 } else { @types.grid_h - 4 }
  let dir : Int = if rid % 2 == 0 { @types.dir_right } else { @types.dir_left }
  reset_rival(game, rid, sx, sy, dir)
}

///|
fn grow_player_after_food(game : @types.Game) -> Unit {
  if game.food_kind == @types.food_gold {
    game.p_grow = game.p_grow + 3
    game.score = game.score + 210
    game.combo = game.combo + 2
    @types.set_msg(game, "Gold food!", 0.9)
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
fn shift_player_forward(game : @types.Game, nx : Int, ny : Int) -> Unit {
  let cap : Int = @types.mini(game.p_len, @types.max_segments - 1)

  for i = cap; i > 0; i = i - 1 {
    game.p_seg_x[i] = game.p_seg_x[i - 1]
    game.p_seg_y[i] = game.p_seg_y[i - 1]
  }

  game.p_seg_x[0] = nx
  game.p_seg_y[0] = ny

  if game.p_grow > 0 {
    game.p_grow = game.p_grow - 1
    game.p_len = @types.mini(@types.max_segments, game.p_len + 1)
  }
}

///|
fn player_step(game : @types.Game) -> Unit {
  if not(game.p_alive) {
    return
  }

  if not(@types.opposite_dir(game.p_dir, game.p_next_dir)) {
    game.p_dir = game.p_next_dir
  }

  let nx : Int = @types.wrap_x(game.p_seg_x[0] + @types.dir_dx(game.p_dir))
  let ny : Int = @types.wrap_y(game.p_seg_y[0] + @types.dir_dy(game.p_dir))

  let self_hit : Bool = player_segment_at(game, nx, ny, true)
  let rival_hit : Bool = rival_segment_at(game, nx, ny, -1, false)
  let trap_hit : Bool = trap_at(game, nx, ny)

  if self_hit || rival_hit || trap_hit {
    damage_player(game, if trap_hit { "Trap hit" } else { "Crash" })
    return
  }

  shift_player_forward(game, nx, ny)

  if nx == game.food_x && ny == game.food_y {
    let (wx, wy) = @types.cell_world_center(game, nx, ny)
    burst(
      game,
      wx,
      wy,
      if game.food_kind == @types.food_gold {
        16
      } else {
        10
      },
      1,
    )
    grow_player_after_food(game)
  }
}

///|
fn shift_rival_forward(
  game : @types.Game,
  rid : Int,
  nx : Int,
  ny : Int,
) -> Unit {
  let rival = game.rivals[rid]
  let cap : Int = @types.mini(rival.len, @types.max_segments - 1)

  for i = cap; i > 0; i = i - 1 {
    rival.seg_x[i] = rival.seg_x[i - 1]
    rival.seg_y[i] = rival.seg_y[i - 1]
  }

  rival.seg_x[0] = nx
  rival.seg_y[0] = ny

  if rival.grow > 0 {
    rival.grow = rival.grow - 1
    rival.len = @types.mini(@types.max_segments, rival.len + 1)
  }
}

///|
fn rival_would_collide(
  game : @types.Game,
  rid : Int,
  nx : Int,
  ny : Int,
) -> Bool {
  if player_segment_at(game, nx, ny, false) {
    return true
  }

  if rival_segment_at(game, nx, ny, rid, true) {
    return true
  }

  trap_at(game, nx, ny)
}

///|
fn rival_step(game : @types.Game, rid : Int) -> Unit {
  if rid < 0 || rid >= game.rivals.length() {
    return
  }

  let rival = game.rivals[rid]
  if not(rival.alive) {
    return
  }

  rival.next_dir = ai_choose_dir(game, rid)
  if not(@types.opposite_dir(rival.dir, rival.next_dir)) {
    rival.dir = rival.next_dir
  }

  let nx : Int = @types.wrap_x(rival.seg_x[0] + @types.dir_dx(rival.dir))
  let ny : Int = @types.wrap_y(rival.seg_y[0] + @types.dir_dy(rival.dir))

  let hits_player : Bool = cell_hits_player(game, nx, ny)
  let hits_rival : Bool = rival_segment_at(game, nx, ny, rid, true)
  let hits_trap : Bool = trap_at(game, nx, ny)

  if hits_player {
    if nx == game.p_seg_x[0] && ny == game.p_seg_y[0] {
      damage_player(game, "Head clash")
    } else {
      game.total_kills = game.total_kills + 1
      game.score = game.score + 120
      if game.score > game.best_score {
        game.best_score = game.score
      }
      let (wx, wy) = @types.cell_world_center(game, nx, ny)
      burst(game, wx, wy, 14, 0)
      @types.set_msg(game, "Rival crashed", 0.7)
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
    let grow_gain : Int = if game.food_kind == @types.food_gold { 2 } else { 1 }
    let score_gain : Int = if game.food_kind == @types.food_gold {
      140
    } else {
      64
    }
    let burst_count : Int = if game.food_kind == @types.food_gold {
      14
    } else {
      8
    }

    rival.grow = rival.grow + grow_gain
    rival.score = rival.score + score_gain

    let (wx, wy) = @types.cell_world_center(game, nx, ny)
    burst(game, wx, wy, burst_count, 1)
    ignore(spawn_food(game))

    if @raylib.get_random_value(0, 99) < 14 {
      ignore(spawn_trap(game))
    }
  }
}

///|
fn rival_total_score(game : @types.Game) -> Int {
  let mut s : Int = 0
  for rival in game.rivals {
    s = s + rival.score
  }
  s
}

///|
fn update_hint(game : @types.Game) -> Unit {
  if game.hint_t > 0.0 {
    return
  }

  game.hint_x = game.p_seg_x[0]
  game.hint_y = game.p_seg_y[0]
}

///|
fn use_hint(game : @types.Game) -> Bool {
  if game.state != @types.state_play {
    return false
  }
  if game.hint_left <= 0 {
    @types.set_msg(game, "No hints", 0.6)
    return false
  }

  let best = suggest_player_dir(game)
  if best < 0 {
    @types.set_msg(game, "No safe hint", 0.7)
    return false
  }

  game.hint_left = game.hint_left - 1
  game.p_next_dir = best

  let nx : Int = @types.wrap_x(game.p_seg_x[0] + @types.dir_dx(best))
  let ny : Int = @types.wrap_y(game.p_seg_y[0] + @types.dir_dy(best))
  game.hint_x = nx
  game.hint_y = ny
  game.hint_t = 1.4

  @types.set_msg(game, "Hint: move now", 0.8)
  true
}

///|
fn check_timeout(game : @types.Game) -> Unit {
  if game.game_t < @types.match_time_limit {
    return
  }

  game.state = @types.state_result
  game.win = game.score >= rival_total_score(game)

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if game.win {
    @types.set_msg(game, "Arena secured", 1.5)
  } else {
    @types.set_msg(game, "Rivals won", 1.5)
  }
}

///|
fn step_once(game : @types.Game) -> Unit {
  if game.state != @types.state_play {
    return
  }

  player_step(game)
  if game.state != @types.state_play {
    return
  }

  for rid in 0..<game.rivals.length() {
    rival_step(game, rid)
    if game.state != @types.state_play {
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
fn update_play(game : @types.Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.state == @types.state_play {
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

  if game.state != @types.state_play {
    return
  }

  let base_step : Float = if game.boost_on { 0.078 } else { 0.118 }

  if game.boost_on {
    game.boost_meter = @types.clampf(game.boost_meter - dt * 0.52, 0.0, 1.0)
    if game.boost_meter <= 0.0 {
      game.boost_on = false
    }
  } else {
    game.boost_meter = @types.clampf(game.boost_meter + dt * 0.22, 0.0, 1.0)
  }

  game.step_acc = game.step_acc + dt

  while game.step_acc >= base_step {
    game.step_acc = game.step_acc - base_step
    step_once(game)

    if game.state != @types.state_play {
      break
    }
  }

  update_hint(game)
  check_timeout(game)
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.mouse_x = @raylib.get_mouse_x() |> Float::from_int
  game.mouse_y = @raylib.get_mouse_y() |> Float::from_int
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0
  let clamped_dt : Float = @types.clampf(dt, 0.0, 0.04)
  if game.state == @types.state_title {
    update_title_input(game)
    update_play(game, clamped_dt)
  } else if game.state == @types.state_play {
    update_play_input(game, clamped_dt)
    update_play(game, clamped_dt)
  } else {
    update_result_input(game)
    update_play(game, clamped_dt)
  }
}
