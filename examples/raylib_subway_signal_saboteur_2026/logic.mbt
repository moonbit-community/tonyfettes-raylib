///|
fn idx(x : Int, y : Int) -> Int {
  y * grid_w + x
}

///|
fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < grid_w && y >= 0 && y < grid_h
}

///|
fn tile_at(game : Game, x : Int, y : Int) -> Int {
  if not(in_bounds(x, y)) {
    tile_void
  } else {
    game.map[idx(x, y)]
  }
}

///|
fn set_tile(game : Game, x : Int, y : Int, t : Int) -> Unit {
  if not(in_bounds(x, y)) {
    return
  }
  game.map[idx(x, y)] = t
}

///|
fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
fn actor_place(a : Actor, x : Int, y : Int) -> Unit {
  a.x = x
  a.y = y
  a.from_x = x
  a.from_y = y
  a.to_x = x
  a.to_y = y
  a.fx = Float::from_int(x)
  a.fy = Float::from_int(y)
  a.t = 1.0
  a.moving = false
}

///|
fn actor_start_move(a : Actor, tx : Int, ty : Int) -> Unit {
  if a.x == tx && a.y == ty {
    return
  }

  a.from_x = a.x
  a.from_y = a.y
  a.to_x = tx
  a.to_y = ty
  a.t = 0.0
  a.moving = true
}

///|
fn actor_tick(a : Actor, dt : Float, move_t : Float) -> Unit {
  if not(a.moving) {
    a.fx = Float::from_int(a.x)
    a.fy = Float::from_int(a.y)
    return
  }

  a.t = a.t + dt / move_t
  if a.t >= 1.0 {
    a.t = 1.0
    a.x = a.to_x
    a.y = a.to_y
    a.fx = Float::from_int(a.x)
    a.fy = Float::from_int(a.y)
    a.moving = false
    return
  }

  a.fx = lerpf(Float::from_int(a.from_x), Float::from_int(a.to_x), a.t)
  a.fy = lerpf(Float::from_int(a.from_y), Float::from_int(a.to_y), a.t)
}

///|
fn clear_particles(game : Game) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    game.particles[i].active = false
    game.particles[i].x = 0.0
    game.particles[i].y = 0.0
    game.particles[i].vx = 0.0
    game.particles[i].vy = 0.0
    game.particles[i].life = 0.0
    game.particles[i].size = 0.0
    game.particles[i].kind = 0
  }
}

///|
fn emit_particle(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if game.particles[i].active {
      continue
    }

    game.particles[i].active = true
    game.particles[i].x = x
    game.particles[i].y = y
    game.particles[i].vx = vx
    game.particles[i].vy = vy
    game.particles[i].life = life
    game.particles[i].size = size
    game.particles[i].kind = kind
    break
  }
}

///|
fn burst(game : Game, x : Float, y : Float, n : Int, kind : Int) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    emit_particle(
      game,
      x + randf(-10.0, 10.0),
      y + randf(-10.0, 10.0),
      randf(-180.0, 180.0),
      randf(-160.0, 120.0),
      randf(0.20, 0.95),
      randf(1.5, 5.0),
      kind,
    )
  }
}

///|
fn update_particles(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue
    }

    game.particles[i].life = game.particles[i].life - dt
    if game.particles[i].life <= 0.0 {
      game.particles[i].active = false
      continue
    }

    game.particles[i].x = game.particles[i].x + game.particles[i].vx * dt
    game.particles[i].y = game.particles[i].y + game.particles[i].vy * dt

    let drag : Float = if game.particles[i].kind == 2 { 2.8 } else { 2.1 }
    game.particles[i].vx = game.particles[i].vx * (1.0 - drag * dt)
    game.particles[i].vy = game.particles[i].vy * (1.0 - (drag - 0.4) * dt) +
      dt * (if game.particles[i].kind == 1 { 84.0 } else { 118.0 })
  }
}

///|
fn build_map(game : Game) -> Unit {
  for y = 0; y < grid_h; y = y + 1 {
    for x = 0; x < grid_w; x = x + 1 {
      if x == 0 || x == grid_w - 1 || y == 0 || y == grid_h - 1 {
        set_tile(game, x, y, tile_wall)
      } else {
        set_tile(game, x, y, tile_floor)
      }
    }
  }

  for lane = 0; lane < train_lane_n; lane = lane + 1 {
    let ry : Int = lane_to_y(lane)
    for x = 1; x < grid_w - 1; x = x + 1 {
      set_tile(game, x, ry, tile_track)
    }
  }

  for x = 1; x < grid_w - 1; x = x + 1 {
    if x == 5 || x == 9 || x == 13 || x == 17 || x == 21 {
      continue
    }

    set_tile(game, x, 3, tile_wall)
    set_tile(game, x, 9, tile_wall)
  }

  for i = 0; i < junction_n; i = i + 1 {
    let jx : Int = junction_x(i)
    set_tile(game, jx, signal_panel_top_y(), tile_floor)
    set_tile(game, jx, signal_panel_bottom_y(), tile_floor)

    set_tile(game, jx, 3, tile_floor)
    set_tile(game, jx, 9, tile_floor)
  }

  set_tile(game, start_x, start_y, tile_floor)
}

///|
fn init_inspectors(game : Game) -> Unit {
  let plan : Array[(Int, Int, Int, Int, Int)] = [
    (4, signal_panel_top_y(), 2, 22, 1),
    (12, signal_panel_bottom_y(), 2, 22, -1),
    (20, signal_panel_top_y(), 2, 22, -1),
  ]

  for i = 0; i < game.inspectors.length(); i = i + 1 {
    game.inspectors[i].active = i < plan.length()
    game.inspectors[i].mode = inspector_patrol
    game.inspectors[i].move_cd = randf(0.05, 0.30)
    game.inspectors[i].stun_t = 0.0
    game.inspectors[i].alert_t = 0.0
    game.inspectors[i].seed = 123 + i * 211

    if game.inspectors[i].active {
      actor_place(game.inspectors[i].body, plan[i].0, plan[i].1)
      game.inspectors[i].path_y = plan[i].1
      game.inspectors[i].path_min_x = plan[i].2
      game.inspectors[i].path_max_x = plan[i].3
      game.inspectors[i].dir_x = plan[i].4
    } else {
      actor_place(game.inspectors[i].body, 0, 0)
      game.inspectors[i].path_y = 0
      game.inspectors[i].path_min_x = 0
      game.inspectors[i].path_max_x = 0
      game.inspectors[i].dir_x = 1
    }
  }
}

///|
fn clear_trains(game : Game) -> Unit {
  for i = 0; i < game.trains.length(); i = i + 1 {
    game.trains[i].active = false
    game.trains[i].x = 0.0
    game.trains[i].prev_x = 0.0
    game.trains[i].lane = 0
    game.trains[i].target_lane = 0
    game.trains[i].speed = 0.0
    game.trains[i].passed_junction = -1
    game.trains[i].color_id = 0
  }
}

///|
fn start_run(game : Game) -> Unit {
  build_map(game)
  clear_trains(game)
  init_inspectors(game)
  clear_particles(game)

  actor_place(game.player, start_x, start_y)

  for i = 0; i < game.switch_state.length(); i = i + 1 {
    game.switch_state[i] = 0
  }

  game.state = state_play
  game.win = false
  game.loss_reason = ""

  game.lives = max_lives
  game.score = 0
  game.routed_ok = 0
  game.routed_bad = 0
  game.collisions = 0
  game.spawn_t = 1.0
  game.slow_t = 0.0
  game.time_left = round_time_limit

  game.req_dx = 0
  game.req_dy = 0
  game.action_down = false
  game.action_pressed = false

  game.move_cd = 0.0
  game.action_cd = 0.0
  game.emp_energy = 100.0
  game.touch_cd = 0.0

  game.msg = ""
  game.msg_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0

  game.time_s = 0.0
  game.hint_i = 0

  set_msg(game, "Route 20 trains correctly before time runs out.", 2.6)
}

///|
fn go_title(game : Game) -> Unit {
  game.state = state_title
  game.req_dx = 0
  game.req_dy = 0
  game.action_down = false
  game.action_pressed = false
  game.touch_cd = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
}

///|
fn finish_run(game : Game, win : Bool, reason : String) -> Unit {
  if game.state != state_play {
    return
  }

  game.state = state_result
  game.win = win
  game.loss_reason = reason
  game.req_dx = 0
  game.req_dy = 0
  game.action_pressed = false

  if win {
    game.score = game.score + score_win_bonus + game.lives * 150
    set_msg(game, "Control room cracked. Operation complete.", 3.0)
    burst(
      game,
      Float::from_int(cell_center_x(train_exit_x)),
      Float::from_int(cell_center_y(Float::from_int(lane_to_y(1)))),
      72,
      1,
    )
  } else {
    set_msg(game, "Signal operation failed.", 2.6)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn cycle_hint(game : Game) -> Unit {
  game.hint_i = (game.hint_i + 1) % 4
  set_msg(game, hint_text(game.hint_i), 2.8)
}

///|
fn train_color_from_target(target_lane : Int) -> Int {
  if target_lane == 0 {
    0
  } else if target_lane == 1 {
    1
  } else {
    2
  }
}

///|
fn active_train_count(game : Game) -> Int {
  let mut n : Int = 0
  for i = 0; i < game.trains.length(); i = i + 1 {
    if game.trains[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn spawn_train(game : Game) -> Bool {
  let active_n : Int = active_train_count(game)
  if active_n >= 8 {
    return false
  }

  let mut slot : Int = -1
  for i = 0; i < game.trains.length(); i = i + 1 {
    if not(game.trains[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    return false
  }

  let lane : Int = @raylib.get_random_value(0, train_lane_n - 1)
  let target : Int = @raylib.get_random_value(0, train_lane_n - 1)

  game.trains[slot].active = true
  game.trains[slot].x = train_spawn_x
  game.trains[slot].prev_x = train_spawn_x
  game.trains[slot].lane = lane
  game.trains[slot].target_lane = target
  game.trains[slot].speed = randf(2.0, 2.8) +
    Float::from_int(game.routed_ok / 8) * 0.15
  game.trains[slot].passed_junction = -1
  game.trains[slot].color_id = train_color_from_target(target)

  true
}

///|
fn signal_cycle(v : Int) -> Int {
  if v == -1 {
    0
  } else if v == 0 {
    1
  } else {
    -1
  }
}

///|
fn try_toggle_switch(game : Game) -> Bool {
  if game.player.y != signal_panel_top_y() &&
    game.player.y != signal_panel_bottom_y() {
    return false
  }

  let px : Int = game.player.x
  let mut best_i : Int = -1
  let mut best_d : Int = 999

  for i = 0; i < junction_n; i = i + 1 {
    let d : Int = absi(px - junction_x(i))
    if d <= 1 && d < best_d {
      best_i = i
      best_d = d
    }
  }

  if best_i < 0 {
    return false
  }

  game.switch_state[best_i] = signal_cycle(game.switch_state[best_i])
  game.score = game.score + score_toggle
  game.action_cd = 0.18
  game.flash_t = 0.12

  let mode_txt : String = if game.switch_state[best_i] < 0 {
    "UP"
  } else if game.switch_state[best_i] > 0 {
    "DOWN"
  } else {
    "STRAIGHT"
  }

  set_msg(game, "J" + (best_i + 1).to_string() + " -> " + mode_txt, 1.0)

  burst(
    game,
    Float::from_int(cell_center_x(Float::from_int(junction_x(best_i)))),
    Float::from_int(cell_center_y(Float::from_int(game.player.y))),
    14,
    0,
  )

  true
}

///|
fn deploy_emp(game : Game) -> Bool {
  if game.action_cd > 0.0 || game.emp_energy < emp_cost {
    return false
  }

  game.emp_energy = clampf(game.emp_energy - emp_cost, 0.0, 100.0)
  game.action_cd = 0.36
  game.slow_t = 1.7

  let mut hits : Int = 0
  for i = 0; i < game.inspectors.length(); i = i + 1 {
    if not(game.inspectors[i].active) ||
      game.inspectors[i].mode == inspector_stunned {
      continue
    }

    let d : Int = manhattan(
      game.player.x,
      game.player.y,
      game.inspectors[i].body.x,
      game.inspectors[i].body.y,
    )

    if d <= 2 {
      game.inspectors[i].mode = inspector_stunned
      game.inspectors[i].stun_t = 2.2
      game.inspectors[i].move_cd = 0.12
      hits = hits + 1
    }
  }

  if hits > 0 {
    game.score = game.score + hits * score_emp_hit
    set_msg(game, "EMP stunned " + hits.to_string() + " inspector(s).", 1.5)
  } else {
    set_msg(game, "EMP pulse deployed.", 1.2)
  }

  game.shake_t = 0.16

  burst(
    game,
    Float::from_int(cell_center_x(game.player.fx)),
    Float::from_int(cell_center_y(game.player.fy)),
    36,
    2,
  )

  true
}

///|
fn blocked_for_actor(game : Game, x : Int, y : Int) -> Bool {
  if not(in_bounds(x, y)) {
    return true
  }

  let t : Int = tile_at(game, x, y)
  if t == tile_wall || t == tile_void || t == tile_track {
    return true
  }

  false
}

///|
fn try_move_player(game : Game, dx : Int, dy : Int) -> Bool {
  if dx == 0 && dy == 0 {
    return false
  }
  if game.player.moving {
    return false
  }

  let tx : Int = game.player.x + dx
  let ty : Int = game.player.y + dy

  if blocked_for_actor(game, tx, ty) {
    return false
  }

  actor_start_move(game.player, tx, ty)
  game.move_cd = 0.02

  true
}

///|
fn line_of_sight(game : Game, x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Bool {
  if x0 == x1 {
    let y_min : Int = mini(y0, y1)
    let y_max : Int = maxi(y0, y1)
    for y = y_min + 1; y < y_max; y = y + 1 {
      let t : Int = tile_at(game, x0, y)
      if t == tile_wall || t == tile_track {
        return false
      }
    }
    return true
  }

  if y0 == y1 {
    let x_min : Int = mini(x0, x1)
    let x_max : Int = maxi(x0, x1)
    for x = x_min + 1; x < x_max; x = x + 1 {
      let t : Int = tile_at(game, x, y0)
      if t == tile_wall || t == tile_track {
        return false
      }
    }
    return true
  }

  false
}

///|
fn inspector_seed_next(seed : Int) -> Int {
  let n : Int = (seed * 48271 + 97) % 2147483647
  if n <= 0 {
    1
  } else {
    n
  }
}

///|
fn blocked_for_inspector(game : Game, x : Int, y : Int) -> Bool {
  if blocked_for_actor(game, x, y) {
    return true
  }

  for i = 0; i < game.inspectors.length(); i = i + 1 {
    if not(game.inspectors[i].active) {
      continue
    }

    if game.inspectors[i].body.x == x && game.inspectors[i].body.y == y {
      return true
    }
  }

  false
}

///|
fn choose_inspector_step(game : Game, i : Int) -> (Int, Int) {
  let g = game.inspectors[i]
  let gx : Int = g.body.x
  let gy : Int = g.body.y
  let px : Int = game.player.x
  let py : Int = game.player.y

  let d : Int = manhattan(gx, gy, px, py)
  let sees : Bool = line_of_sight(game, gx, gy, px, py)

  if d <= 4 || (sees && d <= 8) {
    g.mode = inspector_hunt
    g.alert_t = 1.2
  } else {
    g.alert_t = g.alert_t - 0.16
    if g.alert_t <= 0.0 {
      g.mode = inspector_patrol
    }
  }

  if g.mode == inspector_hunt {
    let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    let mut best_i : Int = -1
    let mut best_d : Int = 999999

    for k = 0; k < 4; k = k + 1 {
      let nx : Int = gx + dirs[k].0
      let ny : Int = gy + dirs[k].1
      if blocked_for_inspector(game, nx, ny) {
        continue
      }

      let dd : Int = manhattan(nx, ny, px, py)
      if dd < best_d {
        best_d = dd
        best_i = k
      }
    }

    if best_i >= 0 {
      return dirs[best_i]
    }
  }

  let mut nx : Int = gx + g.dir_x
  if nx < g.path_min_x ||
    nx > g.path_max_x ||
    blocked_for_actor(game, nx, g.path_y) {
    g.dir_x = -g.dir_x
    nx = gx + g.dir_x
  }

  if nx >= g.path_min_x &&
    nx <= g.path_max_x &&
    not(blocked_for_inspector(game, nx, g.path_y)) {
    return (g.dir_x, 0)
  }

  g.seed = inspector_seed_next(g.seed)
  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  let start : Int = g.seed % 4

  for t = 0; t < 4; t = t + 1 {
    let k : Int = (start + t) % 4
    let xx : Int = gx + dirs[k].0
    let yy : Int = gy + dirs[k].1
    if blocked_for_inspector(game, xx, yy) {
      continue
    }

    return dirs[k]
  }

  (0, 0)
}

///|
fn update_inspectors(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.inspectors.length(); i = i + 1 {
    if not(game.inspectors[i].active) {
      continue
    }

    actor_tick(game.inspectors[i].body, dt, inspector_move_t)

    if game.inspectors[i].mode == inspector_stunned {
      game.inspectors[i].stun_t = game.inspectors[i].stun_t - dt
      if game.inspectors[i].stun_t <= 0.0 {
        game.inspectors[i].mode = inspector_patrol
        game.inspectors[i].stun_t = 0.0
      }
    }

    if game.inspectors[i].alert_t > 0.0 {
      game.inspectors[i].alert_t = game.inspectors[i].alert_t - dt
    }

    if game.inspectors[i].body.moving {
      continue
    }

    game.inspectors[i].move_cd = game.inspectors[i].move_cd - dt
    if game.inspectors[i].move_cd > 0.0 {
      continue
    }

    if game.inspectors[i].mode == inspector_stunned {
      game.inspectors[i].move_cd = 0.14
      continue
    }

    let step = choose_inspector_step(game, i)
    if step.0 != 0 || step.1 != 0 {
      actor_start_move(
        game.inspectors[i].body,
        game.inspectors[i].body.x + step.0,
        game.inspectors[i].body.y + step.1,
      )
    }

    game.inspectors[i].move_cd = inspector_move_t * randf(0.80, 1.22)
  }
}

///|
fn update_trains(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.trains.length(); i = i + 1 {
    if not(game.trains[i].active) {
      continue
    }

    game.trains[i].prev_x = game.trains[i].x

    let slow_mul : Float = if game.slow_t > 0.0 { 0.52 } else { 1.0 }
    game.trains[i].x = game.trains[i].x + game.trains[i].speed * slow_mul * dt

    while game.trains[i].passed_junction + 1 < junction_n {
      let j : Int = game.trains[i].passed_junction + 1
      let jx : Float = Float::from_int(junction_x(j))

      if game.trains[i].prev_x < jx && game.trains[i].x >= jx {
        let dir : Int = game.switch_state[j]
        game.trains[i].lane = clampi(
          game.trains[i].lane + dir,
          0,
          train_lane_n - 1,
        )
        game.trains[i].passed_junction = j
      } else {
        break
      }
    }

    if game.trains[i].x >= train_exit_x {
      if game.trains[i].lane == game.trains[i].target_lane {
        game.routed_ok = game.routed_ok + 1
        game.score = game.score + score_route_ok

        burst(
          game,
          Float::from_int(cell_center_x(train_exit_x)),
          Float::from_int(
            cell_center_y(Float::from_int(lane_to_y(game.trains[i].lane))),
          ),
          14,
          1,
        )
      } else {
        game.routed_bad = game.routed_bad + 1
        game.score = game.score + score_route_bad
        game.lives = game.lives - 1
        game.flash_t = 0.28
        game.shake_t = 0.22

        set_msg(game, "Wrong route! Keep target colors aligned.", 1.4)

        burst(
          game,
          Float::from_int(cell_center_x(train_exit_x)),
          Float::from_int(
            cell_center_y(Float::from_int(lane_to_y(game.trains[i].lane))),
          ),
          24,
          2,
        )
      }

      game.trains[i].active = false
    }
  }
}

///|
fn resolve_train_collisions(game : Game) -> Unit {
  for i = 0; i < game.trains.length(); i = i + 1 {
    if not(game.trains[i].active) {
      continue
    }

    for j = i + 1; j < game.trains.length(); j = j + 1 {
      if not(game.trains[j].active) {
        continue
      }

      if game.trains[i].lane != game.trains[j].lane {
        continue
      }

      if absf(game.trains[i].x - game.trains[j].x) > 0.38 {
        continue
      }

      let crash_x : Float = (game.trains[i].x + game.trains[j].x) * 0.5
      let crash_y : Float = Float::from_int(lane_to_y(game.trains[i].lane))

      game.trains[i].active = false
      game.trains[j].active = false

      game.collisions = game.collisions + 1
      game.lives = game.lives - 1
      game.score = game.score - 120
      game.flash_t = 0.36
      game.shake_t = 0.34

      set_msg(game, "Crash! Junction timing was wrong.", 1.8)

      burst(
        game,
        Float::from_int(cell_center_x(crash_x)),
        Float::from_int(cell_center_y(crash_y)),
        42,
        2,
      )

      break
    }
  }
}

///|
fn handle_player_spotted(game : Game) -> Unit {
  if game.flash_t > 0.0 {
    return
  }

  for i = 0; i < game.inspectors.length(); i = i + 1 {
    if not(game.inspectors[i].active) ||
      game.inspectors[i].mode == inspector_stunned {
      continue
    }

    if game.inspectors[i].body.x == game.player.x &&
      game.inspectors[i].body.y == game.player.y {
      game.lives = game.lives - 1
      game.flash_t = 1.0
      game.shake_t = 0.26

      burst(
        game,
        Float::from_int(cell_center_x(game.player.fx)),
        Float::from_int(cell_center_y(game.player.fy)),
        30,
        2,
      )

      if game.lives <= 0 {
        finish_run(game, false, "Caught by transit inspectors")
      } else {
        actor_place(game.player, start_x, start_y)
        game.move_cd = 0.20
        set_msg(game, "Inspector caught you. Keep distance.", 1.8)
      }

      break
    }
  }
}

///|
fn update_timers(game : Game, dt : Float) -> Unit {
  if game.msg_t > 0.0 {
    game.msg_t = game.msg_t - dt
  }

  if game.flash_t > 0.0 {
    game.flash_t = game.flash_t - dt
  }

  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
  }

  if game.move_cd > 0.0 {
    game.move_cd = game.move_cd - dt
  }

  if game.action_cd > 0.0 {
    game.action_cd = game.action_cd - dt
  }

  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }

  if game.slow_t > 0.0 {
    game.slow_t = game.slow_t - dt
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.time_left = game.time_left - dt

  update_timers(game, dt)

  game.emp_energy = clampf(game.emp_energy + dt * 16.0, 0.0, 100.0)

  actor_tick(game.player, dt, player_move_t)

  if not(game.player.moving) && game.move_cd <= 0.0 {
    ignore(try_move_player(game, game.req_dx, game.req_dy))
  }

  if game.action_pressed {
    if not(try_toggle_switch(game)) {
      ignore(deploy_emp(game))
    }
  }

  game.spawn_t = game.spawn_t - dt
  if game.spawn_t <= 0.0 {
    ignore(spawn_train(game))

    let diff : Float = Float::from_int(game.routed_ok) * 0.03 +
      Float::from_int(game.collisions) * 0.04
    game.spawn_t = clampf(randf(1.55, 2.35) - diff, 0.56, 2.2)
  }

  update_trains(game, dt)
  resolve_train_collisions(game)
  update_inspectors(game, dt)
  handle_player_spotted(game)
  update_particles(game, dt)

  if game.state == state_play && game.routed_ok >= goal_routed {
    finish_run(game, true, "")
  }

  if game.state == state_play && (game.lives <= 0 || game.time_left <= 0.0) {
    let why : String = if game.lives <= 0 {
      "No lives remaining"
    } else {
      "Shift ended before reaching route quota"
    }
    finish_run(game, false, why)
  }
}

///|
fn update_title(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  update_timers(game, dt)
  update_particles(game, dt)
}

///|
fn update_result(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  update_timers(game, dt)
  update_particles(game, dt)
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  if game.state == state_title {
    update_title(game, dt)
  } else if game.state == state_play {
    update_play(game, dt)
  } else {
    update_result(game, dt)
  }

  game.action_pressed = false
}
