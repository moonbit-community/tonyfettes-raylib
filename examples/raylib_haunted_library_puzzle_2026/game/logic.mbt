///|
fn idx(x : Int, y : Int) -> Int {
  y * @types.grid_w + x
}

///|
fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < @types.grid_w && y >= 0 && y < @types.grid_h
}

///|
fn tile_at(game : @types.Game, x : Int, y : Int) -> @types.Tile {
  if not(in_bounds(x, y)) {
    @types.Wall
  } else {
    game.map[idx(x, y)]
  }
}

///|
fn set_tile(game : @types.Game, x : Int, y : Int, t : @types.Tile) -> Unit {
  if not(in_bounds(x, y)) {
    return
  }
  game.map[idx(x, y)] = t
}

///|
fn set_msg(game : @types.Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
fn actor_place(a : @types.Actor, x : Int, y : Int) -> Unit {
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
fn actor_start_move(a : @types.Actor, tx : Int, ty : Int) -> Unit {
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
fn actor_tick(a : @types.Actor, dt : Float, move_t : Float) -> Unit {
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

  a.fx = @types.lerpf(Float::from_int(a.from_x), Float::from_int(a.to_x), a.t)
  a.fy = @types.lerpf(Float::from_int(a.from_y), Float::from_int(a.to_y), a.t)
}

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
    particle.kind = @types.Dust
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
      @types.randf(1.6, 4.8),
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
      @types.Gold => 2.1
      @types.Dust | @types.Purple => 2.8
    }
    let gravity : Float = match particle.kind {
      @types.Gold => 85.0
      @types.Dust | @types.Purple => 120.0
    }
    particle.vx = particle.vx * (1.0 - drag * dt)
    particle.vy = particle.vy * (1.0 - (drag - 0.4) * dt) + dt * gravity
  }
}

///|
fn shelf_index_at(game : @types.Game, x : Int, y : Int) -> Int {
  for i in 0..<game.shelf_n {
    if game.shelf_x[i] == x && game.shelf_y[i] == y {
      return i
    }
  }
  -1
}

///|
fn page_index_at(game : @types.Game, x : Int, y : Int) -> Int {
  for i in 0..<@types.max_pages {
    if not(game.page_taken[i]) && game.page_x[i] == x && game.page_y[i] == y {
      return i
    }
  }
  -1
}

///|
fn ghost_index_at(game : @types.Game, x : Int, y : Int, skip : Int) -> Int {
  for i in 0..<game.ghosts.length() {
    if i == skip || not(game.ghosts[i].active) {
      continue
    }

    if game.ghosts[i].body.x == x && game.ghosts[i].body.y == y {
      return i
    }
  }

  -1
}

///|
fn blocked_by_map(game : @types.Game, x : Int, y : Int) -> Bool {
  if not(in_bounds(x, y)) {
    return true
  }

  let t : @types.Tile = tile_at(game, x, y)
  if t == @types.Wall {
    return true
  }

  t == @types.Exit && not(game.gate_open)
}

///|
fn blocked_for_actor(game : @types.Game, gid : Int, x : Int, y : Int) -> Bool {
  if blocked_by_map(game, x, y) {
    return true
  }
  if shelf_index_at(game, x, y) >= 0 {
    return true
  }

  let g2 : Int = ghost_index_at(game, x, y, gid)
  g2 >= 0
}

///|
fn clear_map(game : @types.Game) -> Unit {
  for y in 0..<@types.grid_h {
    for x in 0..<@types.grid_w {
      if x == 0 || y == 0 || x == @types.grid_w - 1 || y == @types.grid_h - 1 {
        set_tile(game, x, y, @types.Wall)
      } else {
        set_tile(game, x, y, @types.Floor)
      }
    }
  }

  for x = 3; x < @types.grid_w - 2; x = x + 4 {
    for y in 1..<(@types.grid_h - 1) {
      let keep_gap : Bool = y == 2 || y == @types.grid_h - 3 || (x + y) % 5 == 0
      if not(keep_gap) {
        set_tile(game, x, y, @types.Wall)
      }
    }
  }

  for y = 3; y < @types.grid_h - 2; y = y + 4 {
    for x in 2..<(@types.grid_w - 2) {
      let keep_gap : Bool = x == 5 || x == 10 || x == 15
      if not(keep_gap) {
        set_tile(game, x, y, @types.Wall)
      }
    }
  }

  set_tile(game, @types.exit_x, @types.exit_y, @types.Exit)
  set_tile(game, @types.start_x, @types.start_y, @types.Floor)
}

///|
fn load_layout(game : @types.Game) -> Unit {
  let shelf_list : Array[(Int, Int)] = [
    (5, 9),
    (7, 9),
    (10, 5),
    (12, 5),
    (15, 9),
    (17, 9),
    (4, 2),
    (9, 2),
    (14, 2),
    (6, 6),
    (11, 8),
    (16, 6),
  ]

  game.shelf_n = @types.mini(shelf_list.length(), @types.max_shelves)
  for i in 0..<game.shelf_n {
    game.shelf_x[i] = shelf_list[i].0
    game.shelf_y[i] = shelf_list[i].1
  }

  let page_list : Array[(Int, Int)] = [
    (2, 10),
    (9, 1),
    (18, 4),
    (4, 6),
    (15, 11),
  ]
  for i in 0..<@types.max_pages {
    game.page_x[i] = page_list[i].0
    game.page_y[i] = page_list[i].1
    game.page_taken[i] = false
  }

  let ghost_spawn : Array[(Int, Int)] = [
    (18, 1),
    (18, 10),
    (10, 10),
    (12, 2),
    (6, 4),
  ]

  for i in 0..<game.ghosts.length() {
    game.ghosts[i].active = i < ghost_spawn.length()
    game.ghosts[i].mode = @types.Patrol
    game.ghosts[i].stun_t = 0.0
    game.ghosts[i].move_cd = @types.randf(0.12, 0.45)
    game.ghosts[i].seed = 99 + i * 211
    game.ghosts[i].alert_t = 0.0

    if game.ghosts[i].active {
      let gx : Int = ghost_spawn[i].0
      let gy : Int = ghost_spawn[i].1
      actor_place(game.ghosts[i].body, gx, gy)
    }
  }
}

///|
fn count_seals_on(game : @types.Game) -> Int {
  let mut n : Int = 0
  for i in 0..<@types.seal_need {
    let p = @types.seal_pos(i)
    if shelf_index_at(game, p.0, p.1) >= 0 {
      n = n + 1
    }
  }
  n
}

///|
fn update_gate(game : @types.Game) -> Unit {
  let old_open : Bool = game.gate_open
  game.seals_on = count_seals_on(game)
  game.gate_open = game.seals_on == @types.seal_need &&
    game.pages == @types.max_pages

  if game.gate_open && not(old_open) {
    game.score = game.score + @types.seal_score * @types.seal_need
    game.flash_t = 0.35
    game.shake_t = 0.35
    set_msg(game, "Gate unlocked. Escape through the south archive door.", 2.4)
    burst(
      game,
      Float::from_int(@types.cell_center_x(Float::from_int(@types.exit_x))),
      Float::from_int(@types.cell_center_y(Float::from_int(@types.exit_y))),
      44,
      @types.Purple,
    )
  }
}

///|
pub fn start_run(game : @types.Game) -> Unit {
  clear_map(game)
  load_layout(game)
  clear_particles(game)

  actor_place(game.player, @types.start_x, @types.start_y)

  game.state = @types.Play
  game.win = false
  game.loss_reason = ""

  game.lives = 3
  game.pages = 0
  game.seals_on = 0
  game.gate_open = false
  game.score = 0
  game.steps = 0
  game.time_s = 0.0

  game.req_dx = 0
  game.req_dy = 0
  game.action_down = false
  game.action_pressed = false

  game.move_cd = 0.0
  game.action_cd = 0.0
  game.stun_energy = 100.0
  game.touch_cd = 0.0

  game.msg = ""
  game.msg_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0

  game.hint_i = 0

  set_msg(game, "Find 5 pages. Seal 3 runes. Reach exit.", 2.6)
}

///|
pub fn go_title(game : @types.Game) -> Unit {
  game.state = @types.Title
  game.req_dx = 0
  game.req_dy = 0
  game.action_down = false
  game.action_pressed = false
  game.touch_cd = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  clear_particles(game)
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
    game.score = game.score + @types.escape_score + game.lives * 120
    set_msg(game, "Archive saved. The spirits quiet down.", 3.2)
    burst(
      game,
      Float::from_int(@types.cell_center_x(Float::from_int(@types.exit_x))),
      Float::from_int(@types.cell_center_y(Float::from_int(@types.exit_y))),
      72,
      @types.Gold,
    )
  } else {
    set_msg(game, "You were lost in the stacks.", 2.8)
    burst(
      game,
      Float::from_int(@types.cell_center_x(game.player.fx)),
      Float::from_int(@types.cell_center_y(game.player.fy)),
      40,
      @types.Purple,
    )
  }
}

///|
pub fn cycle_hint(game : @types.Game) -> Unit {
  game.hint_i = (game.hint_i + 1) % 4
  set_msg(game, @types.seal_hint(game.hint_i), 2.8)
}

///|
fn push_shelf(game : @types.Game, sidx : Int, dx : Int, dy : Int) -> Bool {
  let nx : Int = game.shelf_x[sidx] + dx
  let ny : Int = game.shelf_y[sidx] + dy

  if blocked_by_map(game, nx, ny) {
    return false
  }

  if shelf_index_at(game, nx, ny) >= 0 {
    return false
  }

  if ghost_index_at(game, nx, ny, -1) >= 0 {
    return false
  }

  game.shelf_x[sidx] = nx
  game.shelf_y[sidx] = ny
  true
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

  if blocked_by_map(game, tx, ty) {
    return false
  }

  if ghost_index_at(game, tx, ty, -1) >= 0 {
    return false
  }

  let sidx : Int = shelf_index_at(game, tx, ty)
  if sidx >= 0 && not(push_shelf(game, sidx, dx, dy)) {
    return false
  }

  actor_start_move(game.player, tx, ty)
  game.steps = game.steps + 1
  game.move_cd = 0.03

  burst(
    game,
    Float::from_int(@types.cell_center_x(Float::from_int(tx))),
    Float::from_int(@types.cell_center_y(Float::from_int(ty))),
    8,
    @types.Dust,
  )

  true
}

///|
fn collect_page_if_needed(game : @types.Game) -> Unit {
  if game.player.moving {
    return
  }

  let i : Int = page_index_at(game, game.player.x, game.player.y)
  if i < 0 {
    return
  }

  game.page_taken[i] = true
  game.pages = game.pages + 1
  game.score = game.score + @types.page_score
  game.flash_t = 0.22

  set_msg(game, "Recovered page " + game.pages.to_string() + "/5", 1.8)

  burst(
    game,
    Float::from_int(@types.cell_center_x(Float::from_int(game.player.x))),
    Float::from_int(@types.cell_center_y(Float::from_int(game.player.y))),
    26,
    @types.Gold,
  )
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
      if tile_at(game, x0, y) == @types.Wall || shelf_index_at(game, x0, y) >= 0 {
        return false
      }
    }
    return true
  }

  if y0 == y1 {
    let x_min : Int = @types.mini(x0, x1)
    let x_max : Int = @types.maxi(x0, x1)
    for x in (x_min + 1)..<x_max {
      if tile_at(game, x, y0) == @types.Wall || shelf_index_at(game, x, y0) >= 0 {
        return false
      }
    }
    return true
  }

  false
}

///|
fn ghost_seed_next(seed : Int) -> Int {
  let n : Int = (seed * 48271 + 97) % 2147483647
  if n <= 0 {
    1
  } else {
    n
  }
}

///|
fn ghost_choose_step(game : @types.Game, gid : Int) -> (Int, Int) {
  let g = game.ghosts[gid]
  let gx : Int = g.body.x
  let gy : Int = g.body.y
  let px : Int = game.player.x
  let py : Int = game.player.y

  let dist : Int = @types.manhattan(gx, gy, px, py)
  let sees : Bool = line_of_sight(game, gx, gy, px, py)
  let hunt_now : Bool = dist <= 4 || (sees && dist <= 8)

  if hunt_now {
    g.mode = @types.Hunt
    g.alert_t = 0.8
  } else {
    g.alert_t = g.alert_t - 0.16
    if g.alert_t <= 0.0 {
      g.mode = @types.Patrol
    }
  }

  let dirs : Array[(Int, Int)] = [(-1, 0), (1, 0), (0, -1), (0, 1)]

  if g.mode == @types.Hunt {
    let mut best_i : Int = -1
    let mut best_d : Int = 999999

    for i in 0..<4 {
      let nx : Int = gx + dirs[i].0
      let ny : Int = gy + dirs[i].1
      if blocked_for_actor(game, gid, nx, ny) {
        continue
      }

      let d : Int = @types.manhattan(nx, ny, px, py)
      if d < best_d {
        best_d = d
        best_i = i
      }
    }

    if best_i >= 0 {
      return dirs[best_i]
    }
  }

  g.seed = ghost_seed_next(g.seed)
  let start : Int = g.seed % 4

  for t in 0..<4 {
    let k : Int = (start + t) % 4
    let nx : Int = gx + dirs[k].0
    let ny : Int = gy + dirs[k].1

    if blocked_for_actor(game, gid, nx, ny) {
      continue
    }

    return dirs[k]
  }

  (0, 0)
}

///|
fn update_ghosts(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.ghosts.length() {
    if not(game.ghosts[i].active) {
      continue
    }

    actor_tick(game.ghosts[i].body, dt, @types.ghost_move_time)

    if game.ghosts[i].mode == @types.Stunned {
      game.ghosts[i].stun_t = game.ghosts[i].stun_t - dt
      if game.ghosts[i].stun_t <= 0.0 {
        game.ghosts[i].mode = @types.Patrol
        game.ghosts[i].stun_t = 0.0
      }
    }

    if game.ghosts[i].alert_t > 0.0 {
      game.ghosts[i].alert_t = game.ghosts[i].alert_t - dt
    }

    if game.ghosts[i].body.moving {
      continue
    }

    game.ghosts[i].move_cd = game.ghosts[i].move_cd - dt
    if game.ghosts[i].move_cd > 0.0 {
      continue
    }

    if game.ghosts[i].mode == @types.Stunned {
      game.ghosts[i].move_cd = 0.12
      continue
    }

    let step = ghost_choose_step(game, i)
    if step.0 != 0 || step.1 != 0 {
      actor_start_move(
        game.ghosts[i].body,
        game.ghosts[i].body.x + step.0,
        game.ghosts[i].body.y + step.1,
      )
    }

    game.ghosts[i].move_cd = @types.ghost_move_time * @types.randf(0.78, 1.20)
  }
}

///|
fn try_stun_pulse(game : @types.Game) -> Bool {
  if game.action_cd > 0.0 || game.stun_energy < 30.0 {
    return false
  }

  let mut hits : Int = 0
  for ghost in game.ghosts {
    if not(ghost.active) || ghost.mode == @types.Stunned {
      continue
    }

    let d : Int = @types.manhattan(
      game.player.x,
      game.player.y,
      ghost.body.x,
      ghost.body.y,
    )

    if d <= 2 {
      ghost.mode = @types.Stunned
      ghost.stun_t = 2.6
      ghost.move_cd = 0.22
      hits = hits + 1
    }
  }

  game.action_cd = 0.46
  game.stun_energy = @types.clampf(game.stun_energy - 30.0, 0.0, 100.0)

  if hits > 0 {
    game.score = game.score + hits * 60
    game.flash_t = 0.20
    set_msg(game, "Pulse hit " + hits.to_string() + " spirit(s).", 1.5)
    burst(
      game,
      Float::from_int(@types.cell_center_x(game.player.fx)),
      Float::from_int(@types.cell_center_y(game.player.fy)),
      24,
      @types.Purple,
    )
    true
  } else {
    set_msg(game, "Pulse missed. Close in before casting.", 1.2)
    false
  }
}

///|
fn handle_player_hit(game : @types.Game) -> Unit {
  if game.flash_t > 0.0 {
    return
  }

  for i in 0..<game.ghosts.length() {
    if not(game.ghosts[i].active) || game.ghosts[i].mode == @types.Stunned {
      continue
    }

    if game.ghosts[i].body.x == game.player.x &&
      game.ghosts[i].body.y == game.player.y {
      game.lives = game.lives - 1
      game.flash_t = 1.25
      game.shake_t = 0.35

      burst(
        game,
        Float::from_int(@types.cell_center_x(game.player.fx)),
        Float::from_int(@types.cell_center_y(game.player.fy)),
        34,
        @types.Purple,
      )

      if game.lives <= 0 {
        finish_run(game, false, "Caught by spectral librarians")
      } else {
        actor_place(game.player, @types.start_x, @types.start_y)
        game.player.moving = false
        game.move_cd = 0.20
        set_msg(game, "A ghost touched you. Retreat and reroute.", 1.8)
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
}

///|
fn update_play(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt

  update_timers(game, dt)
  actor_tick(game.player, dt, @types.player_move_time)

  game.stun_energy = @types.clampf(game.stun_energy + dt * 16.0, 0.0, 100.0)

  if not(game.player.moving) && game.move_cd <= 0.0 {
    ignore(try_move_player(game, game.req_dx, game.req_dy))
  }

  if game.action_pressed {
    ignore(try_stun_pulse(game))
  }

  update_ghosts(game, dt)
  collect_page_if_needed(game)
  update_gate(game)
  handle_player_hit(game)

  if not(game.player.moving) &&
    game.gate_open &&
    game.player.x == @types.exit_x &&
    game.player.y == @types.exit_y {
    finish_run(game, true, "")
  }

  if game.time_s >= 240.0 {
    finish_run(game, false, "Midnight consumed the archive")
  }

  update_particles(game, dt)
}

///|
fn update_title(game : @types.Game, dt : Float) -> Unit {
  update_timers(game, dt)
  game.time_s = game.time_s + dt
  update_particles(game, dt)
}

///|
fn update_result(game : @types.Game, dt : Float) -> Unit {
  update_timers(game, dt)
  game.time_s = game.time_s + dt
  update_particles(game, dt)
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  match game.state {
    @types.Title => update_title(game, dt)
    @types.Play => update_play(game, dt)
    @types.Result => update_result(game, dt)
  }
  game.action_pressed = false
}
