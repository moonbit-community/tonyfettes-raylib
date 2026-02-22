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
    tile_wall
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
      randf(-170.0, 170.0),
      randf(-150.0, 110.0),
      randf(0.20, 1.0),
      randf(1.4, 5.2),
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

    let drag : Float = if game.particles[i].kind == 2 { 2.6 } else { 2.1 }
    game.particles[i].vx = game.particles[i].vx * (1.0 - drag * dt)
    game.particles[i].vy = game.particles[i].vy * (1.0 - (drag - 0.5) * dt) +
      dt * (if game.particles[i].kind == 1 { 84.0 } else { 122.0 })
  }
}

///|
fn smoke_cover_at(game : Game, x : Int, y : Int) -> Bool {
  for i = 0; i < game.smokes.length(); i = i + 1 {
    if not(game.smokes[i].active) {
      continue
    }

    let d : Int = manhattan(x, y, game.smokes[i].x, game.smokes[i].y)
    if d <= 1 {
      return true
    }
  }

  false
}

///|
fn guard_index_at(game : Game, x : Int, y : Int, skip : Int) -> Int {
  for i = 0; i < game.guards.length(); i = i + 1 {
    if i == skip || not(game.guards[i].active) {
      continue
    }

    if game.guards[i].body.x == x && game.guards[i].body.y == y {
      return i
    }
  }

  -1
}

///|
fn loot_index_at(game : Game, x : Int, y : Int) -> Int {
  for i = 0; i < game.loots.length(); i = i + 1 {
    if not(game.loots[i].active) {
      continue
    }

    if game.loots[i].x == x && game.loots[i].y == y {
      return i
    }
  }

  -1
}

///|
fn blocked_by_map(game : Game, x : Int, y : Int) -> Bool {
  if not(in_bounds(x, y)) {
    return true
  }

  let t : Int = tile_at(game, x, y)
  if t == tile_wall {
    return true
  }

  t == tile_exit && not(game.vault_open)
}

///|
fn blocked_for_guard(game : Game, gid : Int, x : Int, y : Int) -> Bool {
  if blocked_by_map(game, x, y) {
    return true
  }

  let g2 : Int = guard_index_at(game, x, y, gid)
  g2 >= 0
}

///|
fn clear_map(game : Game) -> Unit {
  for y = 0; y < grid_h; y = y + 1 {
    for x = 0; x < grid_w; x = x + 1 {
      set_tile(game, x, y, tile_wall)
    }
  }

  for car = 0; car < 5; car = car + 1 {
    let x0 : Int = 1 + car * 5
    let x1 : Int = x0 + 3

    for y = 2; y <= 10; y = y + 1 {
      for x = x0; x <= x1; x = x + 1 {
        set_tile(game, x, y, tile_floor)
      }
    }
  }

  for car = 0; car < 4; car = car + 1 {
    let door_x : Int = 5 + car * 5
    set_tile(game, door_x, 6, tile_door)
    set_tile(game, door_x, 5, tile_floor)
    set_tile(game, door_x, 7, tile_floor)
  }

  let crate_cells : Array[(Int, Int)] = [
    (2, 4),
    (3, 8),
    (7, 3),
    (8, 9),
    (12, 4),
    (13, 8),
    (17, 3),
    (18, 9),
    (22, 4),
    (23, 8),
    (11, 6),
    (16, 6),
  ]

  for i = 0; i < crate_cells.length(); i = i + 1 {
    set_tile(game, crate_cells[i].0, crate_cells[i].1, tile_wall)
  }

  set_tile(game, start_x, start_y, tile_floor)
  set_tile(game, exit_x, exit_y, tile_exit)
}

///|
fn loot_score(kind : Int) -> Int {
  if kind == loot_blueprint {
    score_blueprint
  } else if kind == loot_keycard {
    score_keycard
  } else {
    score_gold
  }
}

///|
fn load_loot(game : Game) -> Unit {
  let loot_plan : Array[(Int, Int, Int)] = [
    (3, 3, loot_blueprint),
    (8, 8, loot_gold),
    (12, 6, loot_keycard),
    (13, 3, loot_gold),
    (17, 7, loot_keycard),
    (22, 6, loot_blueprint),
    (23, 9, loot_gold),
    (7, 6, loot_gold),
  ]

  for i = 0; i < game.loots.length(); i = i + 1 {
    if i < loot_plan.length() {
      game.loots[i].active = true
      game.loots[i].x = loot_plan[i].0
      game.loots[i].y = loot_plan[i].1
      game.loots[i].kind = loot_plan[i].2
      game.loots[i].value = loot_score(loot_plan[i].2)
    } else {
      game.loots[i].active = false
      game.loots[i].x = 0
      game.loots[i].y = 0
      game.loots[i].kind = loot_gold
      game.loots[i].value = 0
    }
  }
}

///|
fn load_guards(game : Game) -> Unit {
  let plan : Array[(Int, Int, Int, Int, Int, Int, Int)] = [
    (6, 6, 1, 0, 6, 9, 0),
    (12, 4, 1, 0, 11, 14, 1),
    (17, 8, 1, 0, 16, 19, 2),
    (20, 4, 0, 1, 4, 9, 3),
    (22, 6, 1, 0, 21, 24, 0),
    (3, 8, 1, 0, 1, 4, 1),
  ]

  for i = 0; i < game.guards.length(); i = i + 1 {
    game.guards[i].active = i < plan.length()
    game.guards[i].mode = guard_patrol
    game.guards[i].move_cd = randf(0.02, 0.25)
    game.guards[i].stun_t = 0.0
    game.guards[i].seed = 101 + i * 269
    game.guards[i].alert_t = 0.0

    if game.guards[i].active {
      let px : Int = plan[i].0
      let py : Int = plan[i].1
      actor_place(game.guards[i].body, px, py)

      game.guards[i].dir_x = plan[i].2
      game.guards[i].dir_y = plan[i].3
      game.guards[i].patrol_min = plan[i].4
      game.guards[i].patrol_max = plan[i].5
      game.guards[i].color_id = plan[i].6
    } else {
      actor_place(game.guards[i].body, 0, 0)
      game.guards[i].dir_x = 1
      game.guards[i].dir_y = 0
      game.guards[i].patrol_min = 0
      game.guards[i].patrol_max = 0
      game.guards[i].color_id = 0
    }
  }
}

///|
fn start_run(game : Game) -> Unit {
  clear_map(game)
  load_loot(game)
  load_guards(game)
  clear_particles(game)

  for i = 0; i < game.smokes.length(); i = i + 1 {
    game.smokes[i].active = false
    game.smokes[i].x = 0
    game.smokes[i].y = 0
    game.smokes[i].t = 0.0
  }

  actor_place(game.player, start_x, start_y)

  game.state = state_play
  game.win = false
  game.loss_reason = ""

  game.lives = 3
  game.score = 0
  game.loot_taken = 0
  game.vault_open = false
  game.time_left = run_time_limit

  game.req_dx = 0
  game.req_dy = 0
  game.action_down = false
  game.action_pressed = false

  game.move_cd = 0.0
  game.action_cd = 0.0
  game.smoke_energy = 100.0
  game.touch_cd = 0.0

  game.msg = ""
  game.msg_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0

  game.time_s = 0.0
  game.hint_i = 0

  set_msg(game, "Steal 6 loot pieces, unlock cable, escape right.", 2.6)
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
    game.score = game.score + score_escape + game.lives * 120
    set_msg(game, "Heist complete. The clockwork train is yours.", 3.0)
    burst(
      game,
      Float::from_int(cell_center_x(Float::from_int(exit_x))),
      Float::from_int(cell_center_y(Float::from_int(exit_y))),
      72,
      1,
    )
  } else {
    set_msg(game, "Heist failed. Railway security locked down.", 2.8)
    burst(
      game,
      Float::from_int(cell_center_x(game.player.fx)),
      Float::from_int(cell_center_y(game.player.fy)),
      44,
      2,
    )
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
fn deploy_smoke(game : Game) -> Bool {
  if game.action_cd > 0.0 || game.smoke_energy < smoke_cost {
    return false
  }

  let mut slot : Int = -1
  for i = 0; i < game.smokes.length(); i = i + 1 {
    if not(game.smokes[i].active) {
      slot = i
      break
    }
  }

  if slot < 0 {
    return false
  }

  game.smokes[slot].active = true
  game.smokes[slot].x = game.player.x
  game.smokes[slot].y = game.player.y
  game.smokes[slot].t = smoke_ttl

  game.smoke_energy = clampf(game.smoke_energy - smoke_cost, 0.0, 100.0)
  game.action_cd = 0.35

  let mut stunned : Int = 0
  for i = 0; i < game.guards.length(); i = i + 1 {
    if not(game.guards[i].active) || game.guards[i].mode == guard_stunned {
      continue
    }

    let d : Int = manhattan(
      game.guards[i].body.x,
      game.guards[i].body.y,
      game.player.x,
      game.player.y,
    )

    if d <= 2 {
      game.guards[i].mode = guard_stunned
      game.guards[i].stun_t = 2.3
      game.guards[i].move_cd = 0.18
      stunned = stunned + 1
    }
  }

  if stunned > 0 {
    game.score = game.score + stunned * 80
    set_msg(
      game,
      "Smoke pulse stunned " + stunned.to_string() + " guard(s).",
      1.7,
    )
  } else {
    set_msg(game, "Smoke deployed.", 1.2)
  }

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
fn update_smokes(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.smokes.length(); i = i + 1 {
    if not(game.smokes[i].active) {
      continue
    }

    game.smokes[i].t = game.smokes[i].t - dt
    if game.smokes[i].t <= 0.0 {
      game.smokes[i].active = false
      continue
    }

    if @raylib.get_random_value(0, 4) == 0 {
      emit_particle(
        game,
        Float::from_int(cell_center_x(Float::from_int(game.smokes[i].x))) +
        randf(-14.0, 14.0),
        Float::from_int(cell_center_y(Float::from_int(game.smokes[i].y))) +
        randf(-14.0, 14.0),
        randf(-18.0, 18.0),
        randf(-26.0, -8.0),
        randf(0.35, 0.9),
        randf(4.0, 9.0),
        2,
      )
    }
  }
}

///|
fn line_of_sight(game : Game, x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Bool {
  if x0 == x1 {
    let y_min : Int = mini(y0, y1)
    let y_max : Int = maxi(y0, y1)

    for y = y_min + 1; y < y_max; y = y + 1 {
      let t : Int = tile_at(game, x0, y)
      if t == tile_wall || smoke_cover_at(game, x0, y) {
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
      if t == tile_wall || smoke_cover_at(game, x, y0) {
        return false
      }
    }

    return true
  }

  false
}

///|
fn guard_seed_next(seed : Int) -> Int {
  let n : Int = (seed * 48271 + 131) % 2147483647
  if n <= 0 {
    1
  } else {
    n
  }
}

///|
fn guard_choose_chase_step(game : Game, gid : Int) -> (Int, Int) {
  let gx : Int = game.guards[gid].body.x
  let gy : Int = game.guards[gid].body.y

  let px : Int = game.player.x
  let py : Int = game.player.y

  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]

  let mut best_i : Int = -1
  let mut best_d : Int = 999999

  for i = 0; i < 4; i = i + 1 {
    let nx : Int = gx + dirs[i].0
    let ny : Int = gy + dirs[i].1

    if blocked_for_guard(game, gid, nx, ny) {
      continue
    }

    let d : Int = manhattan(nx, ny, px, py)
    if d < best_d {
      best_d = d
      best_i = i
    }
  }

  if best_i < 0 {
    (0, 0)
  } else {
    dirs[best_i]
  }
}

///|
fn guard_choose_patrol_step(game : Game, gid : Int) -> (Int, Int) {
  let g = game.guards[gid]
  let gx : Int = g.body.x
  let gy : Int = g.body.y

  if g.dir_x != 0 {
    let mut nx : Int = gx + g.dir_x
    if nx < g.patrol_min ||
      nx > g.patrol_max ||
      blocked_for_guard(game, gid, nx, gy) {
      g.dir_x = -g.dir_x
      nx = gx + g.dir_x
    }

    if nx >= g.patrol_min &&
      nx <= g.patrol_max &&
      not(blocked_for_guard(game, gid, nx, gy)) {
      return (g.dir_x, 0)
    }
  }

  if g.dir_y != 0 {
    let mut ny : Int = gy + g.dir_y
    if ny < g.patrol_min ||
      ny > g.patrol_max ||
      blocked_for_guard(game, gid, gx, ny) {
      g.dir_y = -g.dir_y
      ny = gy + g.dir_y
    }

    if ny >= g.patrol_min &&
      ny <= g.patrol_max &&
      not(blocked_for_guard(game, gid, gx, ny)) {
      return (0, g.dir_y)
    }
  }

  g.seed = guard_seed_next(g.seed)
  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]
  let start : Int = g.seed % 4

  for t = 0; t < 4; t = t + 1 {
    let k : Int = (start + t) % 4
    let nx : Int = gx + dirs[k].0
    let ny : Int = gy + dirs[k].1
    if blocked_for_guard(game, gid, nx, ny) {
      continue
    }

    return dirs[k]
  }

  (0, 0)
}

///|
fn update_guards(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.guards.length(); i = i + 1 {
    if not(game.guards[i].active) {
      continue
    }

    actor_tick(game.guards[i].body, dt, guard_move_t)

    if game.guards[i].mode == guard_stunned {
      game.guards[i].stun_t = game.guards[i].stun_t - dt
      if game.guards[i].stun_t <= 0.0 {
        game.guards[i].mode = guard_patrol
        game.guards[i].stun_t = 0.0
      }
    }

    if game.guards[i].alert_t > 0.0 {
      game.guards[i].alert_t = game.guards[i].alert_t - dt
    }

    if game.guards[i].body.moving {
      continue
    }

    game.guards[i].move_cd = game.guards[i].move_cd - dt
    if game.guards[i].move_cd > 0.0 {
      continue
    }

    if game.guards[i].mode == guard_stunned {
      game.guards[i].move_cd = 0.10
      continue
    }

    let d : Int = manhattan(
      game.guards[i].body.x,
      game.guards[i].body.y,
      game.player.x,
      game.player.y,
    )
    let sees : Bool = line_of_sight(
      game,
      game.guards[i].body.x,
      game.guards[i].body.y,
      game.player.x,
      game.player.y,
    )

    if not(smoke_cover_at(game, game.player.x, game.player.y)) &&
      (d <= 3 || (sees && d <= 8)) {
      game.guards[i].mode = guard_hunt
      game.guards[i].alert_t = 1.1
    } else if game.guards[i].alert_t <= 0.0 {
      game.guards[i].mode = guard_patrol
    }

    let step = if game.guards[i].mode == guard_hunt {
      guard_choose_chase_step(game, i)
    } else {
      guard_choose_patrol_step(game, i)
    }

    if step.0 != 0 || step.1 != 0 {
      actor_start_move(
        game.guards[i].body,
        game.guards[i].body.x + step.0,
        game.guards[i].body.y + step.1,
      )
    }

    game.guards[i].move_cd = guard_move_t * randf(0.80, 1.22)
  }
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

  if blocked_by_map(game, tx, ty) {
    return false
  }

  actor_start_move(game.player, tx, ty)
  game.move_cd = 0.02

  burst(
    game,
    Float::from_int(cell_center_x(Float::from_int(tx))),
    Float::from_int(cell_center_y(Float::from_int(ty))),
    8,
    0,
  )

  true
}

///|
fn collect_loot(game : Game) -> Unit {
  if game.player.moving {
    return
  }

  let i : Int = loot_index_at(game, game.player.x, game.player.y)
  if i < 0 {
    return
  }

  game.loots[i].active = false
  game.loot_taken = game.loot_taken + 1
  game.score = game.score + game.loots[i].value
  game.flash_t = 0.22

  let loot_label : String = if game.loots[i].kind == loot_blueprint {
    "Blueprint"
  } else if game.loots[i].kind == loot_keycard {
    "Keycard"
  } else {
    "Gold"
  }

  set_msg(
    game,
    "Stole " +
    loot_label +
    " (" +
    game.loot_taken.to_string() +
    "/" +
    loot_need.to_string() +
    ")",
    1.8,
  )

  burst(
    game,
    Float::from_int(cell_center_x(game.player.fx)),
    Float::from_int(cell_center_y(game.player.fy)),
    24,
    1,
  )

  if game.loot_taken >= loot_need && not(game.vault_open) {
    game.vault_open = true
    game.score = game.score + 260
    game.shake_t = 0.30
    set_msg(game, "Escape cable unlocked. Reach the rightmost car door.", 2.8)

    burst(
      game,
      Float::from_int(cell_center_x(Float::from_int(exit_x))),
      Float::from_int(cell_center_y(Float::from_int(exit_y))),
      42,
      2,
    )
  }
}

///|
fn handle_player_caught(game : Game) -> Unit {
  if game.flash_t > 0.0 {
    return
  }

  if smoke_cover_at(game, game.player.x, game.player.y) {
    return
  }

  for i = 0; i < game.guards.length(); i = i + 1 {
    if not(game.guards[i].active) || game.guards[i].mode == guard_stunned {
      continue
    }

    if game.guards[i].body.x != game.player.x ||
      game.guards[i].body.y != game.player.y {
      continue
    }

    game.lives = game.lives - 1
    game.flash_t = 1.2
    game.shake_t = 0.36

    burst(
      game,
      Float::from_int(cell_center_x(game.player.fx)),
      Float::from_int(cell_center_y(game.player.fy)),
      34,
      2,
    )

    if game.lives <= 0 {
      finish_run(game, false, "Caught by railway guards")
      return
    }

    actor_place(game.player, start_x, start_y)
    game.move_cd = 0.24

    for g = 0; g < game.guards.length(); g = g + 1 {
      if not(game.guards[g].active) {
        continue
      }
      game.guards[g].mode = guard_stunned
      game.guards[g].stun_t = 1.1
      game.guards[g].move_cd = 0.18
    }

    set_msg(game, "Spotted. You lost a life.", 1.8)
    break
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
fn update_play(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.time_left = game.time_left - dt

  update_timers(game, dt)

  game.smoke_energy = clampf(game.smoke_energy + dt * 17.0, 0.0, 100.0)

  actor_tick(game.player, dt, player_move_t)

  if not(game.player.moving) && game.move_cd <= 0.0 {
    ignore(try_move_player(game, game.req_dx, game.req_dy))
  }

  if game.action_pressed {
    ignore(deploy_smoke(game))
  }

  update_smokes(game, dt)
  update_guards(game, dt)
  collect_loot(game)
  handle_player_caught(game)

  if game.state == state_play &&
    not(game.player.moving) &&
    game.vault_open &&
    game.player.x == exit_x &&
    game.player.y == exit_y {
    finish_run(game, true, "")
  }

  if game.state == state_play && game.time_left <= 0.0 {
    finish_run(game, false, "Clockwork engine reached lockdown")
  }

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
