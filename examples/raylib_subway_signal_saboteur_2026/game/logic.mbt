///|
fn clear_particles(game : @types.Game) -> Unit {
  for particle in game.particles {
    particle.active = false
    particle.x = 0.0
    particle.y = 0.0
    particle.vx = 0.0
    particle.vy = 0.0
    particle.life = 0.0
    particle.size = 0.0
    particle.kind = @types.Spark
  }
}

///|
fn emit_particle(
  game : @types.Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : @types.ParticleKind,
) -> Unit {
  for particle in game.particles {
    if particle.active {
      continue
    }

    particle.active = true
    particle.x = x
    particle.y = y
    particle.vx = vx
    particle.vy = vy
    particle.life = life
    particle.size = size
    particle.kind = kind
    break
  }
}

///|
fn burst(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : @types.ParticleKind,
) -> Unit {
  for _i in 0..<n {
    emit_particle(
      game,
      x + @types.randf(-10.0, 10.0),
      y + @types.randf(-10.0, 10.0),
      @types.randf(-180.0, 180.0),
      @types.randf(-160.0, 120.0),
      @types.randf(0.20, 0.95),
      @types.randf(1.5, 5.0),
      kind,
    )
  }
}

///|
fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for particle in game.particles {
    if not(particle.active) {
      continue
    }

    particle.life = particle.life - dt
    if particle.life <= 0.0 {
      particle.active = false
      continue
    }

    particle.x = particle.x + particle.vx * dt
    particle.y = particle.y + particle.vy * dt

    let drag : Float = match particle.kind {
      @types.Smoke => 2.8
      _ => 2.1
    }
    particle.vx = particle.vx * (1.0 - drag * dt)
    let gravity : Float = match particle.kind {
      @types.Gold => 84.0
      _ => 118.0
    }
    particle.vy = particle.vy * (1.0 - (drag - 0.4) * dt) + dt * gravity
  }
}

///|
fn build_map(game : @types.Game) -> Unit {
  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
      if x == 0 || x == @types.grid_w - 1 || y == 0 || y == @types.grid_h - 1 {
        @types.set_tile(game, x, y, @types.Wall)
      } else {
        @types.set_tile(game, x, y, @types.Floor)
      }
    }
  }

  for lane in 0..<@types.train_lane_n {
    let ry : Int = @types.lane_to_y(lane)
    for x in 1..<(@types.grid_w - 1) {
      @types.set_tile(game, x, ry, @types.Track)
    }
  }

  for x in 1..<(@types.grid_w - 1) {
    if x == 5 || x == 9 || x == 13 || x == 17 || x == 21 {
      continue
    }

    @types.set_tile(game, x, 3, @types.Wall)
    @types.set_tile(game, x, 9, @types.Wall)
  }

  for i in 0..<@types.junction_n {
    let jx : Int = @types.junction_x(i)
    @types.set_tile(game, jx, @types.signal_panel_top_y(), @types.Floor)
    @types.set_tile(game, jx, @types.signal_panel_bottom_y(), @types.Floor)

    @types.set_tile(game, jx, 3, @types.Floor)
    @types.set_tile(game, jx, 9, @types.Floor)
  }

  @types.set_tile(game, @types.start_x, @types.start_y, @types.Floor)
}

///|
fn init_inspectors(game : @types.Game) -> Unit {
  let plan : Array[(Int, Int, Int, Int, Int)] = [
    (4, @types.signal_panel_top_y(), 2, 22, 1),
    (12, @types.signal_panel_bottom_y(), 2, 22, -1),
    (20, @types.signal_panel_top_y(), 2, 22, -1),
  ]

  for i in 0..<game.inspectors.length() {
    game.inspectors[i].active = i < plan.length()
    game.inspectors[i].mode = @types.Patrol
    game.inspectors[i].move_cd = @types.randf(0.05, 0.30)
    game.inspectors[i].stun_t = 0.0
    game.inspectors[i].alert_t = 0.0
    game.inspectors[i].seed = 123 + i * 211

    if game.inspectors[i].active {
      @types.actor_place(game.inspectors[i].body, plan[i].0, plan[i].1)
      game.inspectors[i].path_y = plan[i].1
      game.inspectors[i].path_min_x = plan[i].2
      game.inspectors[i].path_max_x = plan[i].3
      game.inspectors[i].dir_x = plan[i].4
    } else {
      @types.actor_place(game.inspectors[i].body, 0, 0)
      game.inspectors[i].path_y = 0
      game.inspectors[i].path_min_x = 0
      game.inspectors[i].path_max_x = 0
      game.inspectors[i].dir_x = 1
    }
  }
}

///|
fn clear_trains(game : @types.Game) -> Unit {
  for train in game.trains {
    train.active = false
    train.x = 0.0
    train.prev_x = 0.0
    train.lane = 0
    train.target_lane = 0
    train.speed = 0.0
    train.passed_junction = -1
    train.color_id = @types.Red
  }
}

///|
fn start_run(game : @types.Game) -> Unit {
  build_map(game)
  clear_trains(game)
  init_inspectors(game)
  clear_particles(game)

  @types.actor_place(game.player, @types.start_x, @types.start_y)

  for i in 0..<game.switch_state.length() {
    game.switch_state[i] = 0
  }

  game.state = @types.Play
  game.win = false
  game.loss_reason = ""

  game.lives = @types.max_lives
  game.score = 0
  game.routed_ok = 0
  game.routed_bad = 0
  game.collisions = 0
  game.spawn_t = 1.0
  game.slow_t = 0.0
  game.time_left = @types.round_time_limit

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

  @types.set_msg(game, "Route 20 trains correctly before time runs out.", 2.6)
}

///|
fn go_title(game : @types.Game) -> Unit {
  game.state = @types.Title
  game.req_dx = 0
  game.req_dy = 0
  game.action_down = false
  game.action_pressed = false
  game.touch_cd = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
}

///|
fn finish_run(game : @types.Game, win : Bool, reason : String) -> Unit {
  if game.state != @types.Play {
    return
  }

  game.state = @types.Result
  game.win = win
  game.loss_reason = reason
  game.req_dx = 0
  game.req_dy = 0
  game.action_pressed = false

  if win {
    game.score = game.score + @types.score_win_bonus + game.lives * 150
    @types.set_msg(game, "Control room cracked. Operation complete.", 3.0)
    burst(
      game,
      Float::from_int(@types.cell_center_x(@types.train_exit_x)),
      Float::from_int(
        @types.cell_center_y(Float::from_int(@types.lane_to_y(1))),
      ),
      72,
      @types.Gold,
    )
  } else {
    @types.set_msg(game, "Signal operation failed.", 2.6)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn cycle_hint(game : @types.Game) -> Unit {
  game.hint_i = (game.hint_i + 1) % 4
  @types.set_msg(game, @types.hint_text(game.hint_i), 2.8)
}

///|
fn train_color_from_target(target_lane : Int) -> @types.TrainColor {
  if target_lane == 0 {
    @types.Red
  } else if target_lane == 1 {
    @types.Blue
  } else {
    @types.Green
  }
}

///|
fn active_train_count(game : @types.Game) -> Int {
  let mut n : Int = 0
  for train in game.trains {
    if train.active {
      n = n + 1
    }
  }
  n
}

///|
fn spawn_train(game : @types.Game) -> Bool {
  let active_n : Int = active_train_count(game)
  if active_n >= 8 {
    return false
  }

  let mut slot : Int = -1
  for i in 0..<game.trains.length() {
    if not(game.trains[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    return false
  }

  let lane : Int = @raylib.get_random_value(0, @types.train_lane_n - 1)
  let target : Int = @raylib.get_random_value(0, @types.train_lane_n - 1)

  game.trains[slot].active = true
  game.trains[slot].x = @types.train_spawn_x
  game.trains[slot].prev_x = @types.train_spawn_x
  game.trains[slot].lane = lane
  game.trains[slot].target_lane = target
  game.trains[slot].speed = @types.randf(2.0, 2.8) +
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
fn try_toggle_switch(game : @types.Game) -> Bool {
  if game.player.y != @types.signal_panel_top_y() &&
    game.player.y != @types.signal_panel_bottom_y() {
    return false
  }

  let px : Int = game.player.x
  let mut best_i : Int = -1
  let mut best_d : Int = 999

  for i in 0..<@types.junction_n {
    let d : Int = @types.absi(px - @types.junction_x(i))
    if d <= 1 && d < best_d {
      best_i = i
      best_d = d
    }
  }

  if best_i < 0 {
    return false
  }

  game.switch_state[best_i] = signal_cycle(game.switch_state[best_i])
  game.score = game.score + @types.score_toggle
  game.action_cd = 0.18
  game.flash_t = 0.12

  let mode_txt : String = if game.switch_state[best_i] < 0 {
    "UP"
  } else if game.switch_state[best_i] > 0 {
    "DOWN"
  } else {
    "STRAIGHT"
  }

  @types.set_msg(game, "J" + (best_i + 1).to_string() + " -> " + mode_txt, 1.0)

  burst(
    game,
    Float::from_int(
      @types.cell_center_x(Float::from_int(@types.junction_x(best_i))),
    ),
    Float::from_int(@types.cell_center_y(Float::from_int(game.player.y))),
    14,
    @types.Spark,
  )

  true
}

///|
fn deploy_emp(game : @types.Game) -> Bool {
  if game.action_cd > 0.0 || game.emp_energy < @types.emp_cost {
    return false
  }

  game.emp_energy = @types.clampf(game.emp_energy - @types.emp_cost, 0.0, 100.0)
  game.action_cd = 0.36
  game.slow_t = 1.7

  let mut hits : Int = 0
  for inspector in game.inspectors {
    if not(inspector.active) || inspector.mode == @types.Stunned {
      continue
    }

    let d : Int = @types.manhattan(
      game.player.x,
      game.player.y,
      inspector.body.x,
      inspector.body.y,
    )

    if d <= 2 {
      inspector.mode = @types.Stunned
      inspector.stun_t = 2.2
      inspector.move_cd = 0.12
      hits = hits + 1
    }
  }

  if hits > 0 {
    game.score = game.score + hits * @types.score_emp_hit
    @types.set_msg(
      game,
      "EMP stunned " + hits.to_string() + " inspector(s).",
      1.5,
    )
  } else {
    @types.set_msg(game, "EMP pulse deployed.", 1.2)
  }

  game.shake_t = 0.16

  burst(
    game,
    Float::from_int(@types.cell_center_x(game.player.fx)),
    Float::from_int(@types.cell_center_y(game.player.fy)),
    36,
    @types.Smoke,
  )

  true
}

///|
fn blocked_for_actor(game : @types.Game, x : Int, y : Int) -> Bool {
  if not(@types.in_bounds(x, y)) {
    return true
  }

  match @types.tile_at(game, x, y) {
    @types.Wall | @types.Void | @types.Track => true
    @types.Floor => false
  }
}

///|
fn try_move_player(game : @types.Game, dx : Int, dy : Int) -> Bool {
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

  @types.actor_start_move(game.player, tx, ty)
  game.move_cd = 0.02

  true
}

///|
fn line_of_sight(
  game : @types.Game,
  x0 : Int,
  y0 : Int,
  x1 : Int,
  y1 : Int,
) -> Bool {
  if x0 == x1 {
    let y_min : Int = @types.mini(y0, y1)
    let y_max : Int = @types.maxi(y0, y1)
    for y in (y_min + 1)..<y_max {
      match @types.tile_at(game, x0, y) {
        @types.Wall | @types.Track => return false
        _ => ()
      }
    }
    return true
  }

  if y0 == y1 {
    let x_min : Int = @types.mini(x0, x1)
    let x_max : Int = @types.maxi(x0, x1)
    for x in (x_min + 1)..<x_max {
      match @types.tile_at(game, x, y0) {
        @types.Wall | @types.Track => return false
        _ => ()
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
fn blocked_for_inspector(game : @types.Game, x : Int, y : Int) -> Bool {
  if blocked_for_actor(game, x, y) {
    return true
  }

  for inspector in game.inspectors {
    if not(inspector.active) {
      continue
    }

    if inspector.body.x == x && inspector.body.y == y {
      return true
    }
  }

  false
}

///|
fn choose_inspector_step(game : @types.Game, i : Int) -> (Int, Int) {
  let g = game.inspectors[i]
  let gx : Int = g.body.x
  let gy : Int = g.body.y
  let px : Int = game.player.x
  let py : Int = game.player.y

  let d : Int = @types.manhattan(gx, gy, px, py)
  let sees : Bool = line_of_sight(game, gx, gy, px, py)

  if d <= 4 || (sees && d <= 8) {
    g.mode = @types.Hunt
    g.alert_t = 1.2
  } else {
    g.alert_t = g.alert_t - 0.16
    if g.alert_t <= 0.0 {
      g.mode = @types.Patrol
    }
  }

  if g.mode == @types.Hunt {
    let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    let mut best_i : Int = -1
    let mut best_d : Int = 999999

    for k in 0..<4 {
      let nx : Int = gx + dirs[k].0
      let ny : Int = gy + dirs[k].1
      if blocked_for_inspector(game, nx, ny) {
        continue
      }

      let dd : Int = @types.manhattan(nx, ny, px, py)
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

  for t in 0..<4 {
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
fn update_inspectors(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.inspectors.length() {
    if not(game.inspectors[i].active) {
      continue
    }

    @types.actor_tick(game.inspectors[i].body, dt, @types.inspector_move_t)

    if game.inspectors[i].mode == @types.Stunned {
      game.inspectors[i].stun_t = game.inspectors[i].stun_t - dt
      if game.inspectors[i].stun_t <= 0.0 {
        game.inspectors[i].mode = @types.Patrol
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

    if game.inspectors[i].mode == @types.Stunned {
      game.inspectors[i].move_cd = 0.14
      continue
    }

    let step = choose_inspector_step(game, i)
    if step.0 != 0 || step.1 != 0 {
      @types.actor_start_move(
        game.inspectors[i].body,
        game.inspectors[i].body.x + step.0,
        game.inspectors[i].body.y + step.1,
      )
    }

    game.inspectors[i].move_cd = @types.inspector_move_t *
      @types.randf(0.80, 1.22)
  }
}

///|
fn update_trains(game : @types.Game, dt : Float) -> Unit {
  for train in game.trains {
    if not(train.active) {
      continue
    }

    train.prev_x = train.x

    let slow_mul : Float = if game.slow_t > 0.0 { 0.52 } else { 1.0 }
    train.x = train.x + train.speed * slow_mul * dt

    while train.passed_junction + 1 < @types.junction_n {
      let j : Int = train.passed_junction + 1
      let jx : Float = Float::from_int(@types.junction_x(j))

      if train.prev_x < jx && train.x >= jx {
        let dir : Int = game.switch_state[j]
        train.lane = @types.clampi(train.lane + dir, 0, @types.train_lane_n - 1)
        train.passed_junction = j
      } else {
        break
      }
    }

    if train.x >= @types.train_exit_x {
      if train.lane == train.target_lane {
        game.routed_ok = game.routed_ok + 1
        game.score = game.score + @types.score_route_ok

        burst(
          game,
          Float::from_int(@types.cell_center_x(@types.train_exit_x)),
          Float::from_int(
            @types.cell_center_y(Float::from_int(@types.lane_to_y(train.lane))),
          ),
          14,
          @types.Gold,
        )
      } else {
        game.routed_bad = game.routed_bad + 1
        game.score = game.score + @types.score_route_bad
        game.lives = game.lives - 1
        game.flash_t = 0.28
        game.shake_t = 0.22

        @types.set_msg(game, "Wrong route! Keep target colors aligned.", 1.4)

        burst(
          game,
          Float::from_int(@types.cell_center_x(@types.train_exit_x)),
          Float::from_int(
            @types.cell_center_y(Float::from_int(@types.lane_to_y(train.lane))),
          ),
          24,
          @types.Smoke,
        )
      }

      train.active = false
    }
  }
}

///|
fn resolve_train_collisions(game : @types.Game) -> Unit {
  for i in 0..<game.trains.length() {
    if not(game.trains[i].active) {
      continue
    }

    for j in (i + 1)..<game.trains.length() {
      if not(game.trains[j].active) {
        continue
      }

      if game.trains[i].lane != game.trains[j].lane {
        continue
      }

      if @types.absf(game.trains[i].x - game.trains[j].x) > 0.38 {
        continue
      }

      let crash_x : Float = (game.trains[i].x + game.trains[j].x) * 0.5
      let crash_y : Float = Float::from_int(
        @types.lane_to_y(game.trains[i].lane),
      )

      game.trains[i].active = false
      game.trains[j].active = false

      game.collisions = game.collisions + 1
      game.lives = game.lives - 1
      game.score = game.score - 120
      game.flash_t = 0.36
      game.shake_t = 0.34

      @types.set_msg(game, "Crash! Junction timing was wrong.", 1.8)

      burst(
        game,
        Float::from_int(@types.cell_center_x(crash_x)),
        Float::from_int(@types.cell_center_y(crash_y)),
        42,
        @types.Smoke,
      )

      break
    }
  }
}

///|
fn handle_player_spotted(game : @types.Game) -> Unit {
  if game.flash_t > 0.0 {
    return
  }

  for inspector in game.inspectors {
    if not(inspector.active) || inspector.mode == @types.Stunned {
      continue
    }

    if inspector.body.x == game.player.x && inspector.body.y == game.player.y {
      game.lives = game.lives - 1
      game.flash_t = 1.0
      game.shake_t = 0.26

      burst(
        game,
        Float::from_int(@types.cell_center_x(game.player.fx)),
        Float::from_int(@types.cell_center_y(game.player.fy)),
        30,
        @types.Smoke,
      )

      if game.lives <= 0 {
        finish_run(game, false, "Caught by transit inspectors")
      } else {
        @types.actor_place(game.player, @types.start_x, @types.start_y)
        game.move_cd = 0.20
        @types.set_msg(game, "Inspector caught you. Keep distance.", 1.8)
      }

      break
    }
  }
}

///|
fn update_timers(game : @types.Game, dt : Float) -> Unit {
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
fn update_play(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.time_left = game.time_left - dt

  update_timers(game, dt)

  game.emp_energy = @types.clampf(game.emp_energy + dt * 16.0, 0.0, 100.0)

  @types.actor_tick(game.player, dt, @types.player_move_t)

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
    game.spawn_t = @types.clampf(@types.randf(1.55, 2.35) - diff, 0.56, 2.2)
  }

  update_trains(game, dt)
  resolve_train_collisions(game)
  update_inspectors(game, dt)
  handle_player_spotted(game)
  update_particles(game, dt)

  if game.state == @types.Play && game.routed_ok >= @types.goal_routed {
    finish_run(game, true, "")
  }

  if game.state == @types.Play && (game.lives <= 0 || game.time_left <= 0.0) {
    let why : String = if game.lives <= 0 {
      "No lives remaining"
    } else {
      "Shift ended before reaching route quota"
    }
    finish_run(game, false, why)
  }
}

///|
fn update_title(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  update_timers(game, dt)
  update_particles(game, dt)
}

///|
fn update_result(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  update_timers(game, dt)
  update_particles(game, dt)
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  match game.state {
    @types.Title => update_title_input(game)
    @types.Play => update_play_input(game)
    @types.Result => update_result_input(game)
  }

  match game.state {
    @types.Title => update_title(game, dt)
    @types.Play => update_play(game, dt)
    @types.Result => update_result(game, dt)
  }

  game.action_pressed = false
}
