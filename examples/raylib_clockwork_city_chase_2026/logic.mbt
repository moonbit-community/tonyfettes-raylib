///|
fn clear_objs(game : Game) -> Unit {
  for i = 0; i < game.objs.length(); i = i + 1 {
    game.objs[i].active = false
    game.objs[i].kind = obj_scout
    game.objs[i].x = 0.0
    game.objs[i].y = 0.0
    game.objs[i].vx = 0.0
    game.objs[i].vy = 0.0
    game.objs[i].w = 0.0
    game.objs[i].h = 0.0
    game.objs[i].hp = 0.0
    game.objs[i].shot_cd = 0.0
    game.objs[i].spin = 0.0
    game.objs[i].cloak = false
    game.objs[i].reward = 0
  }
}

///|
fn clear_shots(game : Game) -> Unit {
  for i = 0; i < game.shots.length(); i = i + 1 {
    game.shots[i].active = false
    game.shots[i].from_player = true
    game.shots[i].x = 0.0
    game.shots[i].y = 0.0
    game.shots[i].vx = 0.0
    game.shots[i].vy = 0.0
    game.shots[i].life = 0.0
    game.shots[i].dmg = 0.0
    game.shots[i].kind = 0
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
fn clear_rings(game : Game) -> Unit {
  for i = 0; i < game.rings.length(); i = i + 1 {
    game.rings[i].active = false
    game.rings[i].x = 0.0
    game.rings[i].y = 0.0
    game.rings[i].r = 0.0
    game.rings[i].life = 0.0
    game.rings[i].kind = 0
  }
}

///|
fn clear_ghosts(game : Game) -> Unit {
  for i = 0; i < game.ghosts.length(); i = i + 1 {
    game.ghosts[i].active = false
    game.ghosts[i].x = 0.0
    game.ghosts[i].y = 0.0
    game.ghosts[i].w = 0.0
    game.ghosts[i].h = 0.0
    game.ghosts[i].rot = 0.0
    game.ghosts[i].life = 0.0
    game.ghosts[i].kind = 0
  }
}

///|
fn reset_player(hero : Player) -> Unit {
  hero.x = Float::from_int(screen_w / 2)
  hero.y = Float::from_int(screen_h) * 0.76
  hero.vx = 0.0
  hero.vy = 0.0
  hero.w = car_w
  hero.h = car_h
  hero.heading = 0.0
  hero.invuln = 0.0
  hero.hurt_t = 0.0
  hero.muzzle_t = 0.0
  hero.engine_t = 0.0
}

///|
fn alloc_obj(game : Game) -> Int {
  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_y = game.objs[0].y
  for i = 1; i < game.objs.length(); i = i + 1 {
    if game.objs[i].y > best_y {
      best_y = game.objs[i].y
      best = i
    }
  }
  best
}

///|
fn alloc_shot(game : Game) -> Int {
  for i = 0; i < game.shots.length(); i = i + 1 {
    if not(game.shots[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.shots[0].life
  for i = 1; i < game.shots.length(); i = i + 1 {
    if game.shots[i].life < best_life {
      best_life = game.shots[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_spark(game : Game) -> Int {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.sparks[0].life
  for i = 1; i < game.sparks.length(); i = i + 1 {
    if game.sparks[i].life < best_life {
      best_life = game.sparks[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_ring(game : Game) -> Int {
  for i = 0; i < game.rings.length(); i = i + 1 {
    if not(game.rings[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.rings[0].life
  for i = 1; i < game.rings.length(); i = i + 1 {
    if game.rings[i].life < best_life {
      best_life = game.rings[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_ghost(game : Game) -> Int {
  for i = 0; i < game.ghosts.length(); i = i + 1 {
    if not(game.ghosts[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.ghosts[0].life
  for i = 1; i < game.ghosts.length(); i = i + 1 {
    if game.ghosts[i].life < best_life {
      best_life = game.ghosts[i].life
      best = i
    }
  }
  best
}

///|
fn emit_spark(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  let i = alloc_spark(game)
  game.sparks[i].active = true
  game.sparks[i].x = x
  game.sparks[i].y = y
  game.sparks[i].vx = vx
  game.sparks[i].vy = vy
  game.sparks[i].life = life
  game.sparks[i].size = size
  game.sparks[i].kind = kind
}

///|
fn burst(game : Game, x : Float, y : Float, count : Int, kind : Int) -> Unit {
  for _i = 0; _i < count; _i = _i + 1 {
    emit_spark(
      game,
      x + randf(-20.0, 20.0),
      y + randf(-20.0, 20.0),
      randf(-270.0, 270.0),
      randf(-270.0, 270.0),
      randf(0.24, 1.02),
      randf(1.2, 6.6),
      kind,
    )
  }
}

///|
fn spawn_ring(
  game : Game,
  x : Float,
  y : Float,
  r : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = alloc_ring(game)
  game.rings[i].active = true
  game.rings[i].x = x
  game.rings[i].y = y
  game.rings[i].r = r
  game.rings[i].life = life
  game.rings[i].kind = kind
}

///|
fn emit_ghost(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  rot : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = alloc_ghost(game)
  game.ghosts[i].active = true
  game.ghosts[i].x = x
  game.ghosts[i].y = y
  game.ghosts[i].w = w
  game.ghosts[i].h = h
  game.ghosts[i].rot = rot
  game.ghosts[i].life = life
  game.ghosts[i].kind = kind
}

///|
fn spawn_shot(
  game : Game,
  from_player : Bool,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  dmg : Float,
  kind : Int,
) -> Unit {
  let i = alloc_shot(game)
  game.shots[i].active = true
  game.shots[i].from_player = from_player
  game.shots[i].x = x
  game.shots[i].y = y
  game.shots[i].vx = vx
  game.shots[i].vy = vy
  game.shots[i].life = life
  game.shots[i].dmg = dmg
  game.shots[i].kind = kind
}

///|
fn spawn_obj(
  game : Game,
  kind : Int,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  w : Float,
  h : Float,
  hp : Float,
  shot_cd : Float,
  cloak : Bool,
  reward : Int,
) -> Unit {
  let i = alloc_obj(game)
  game.objs[i].active = true
  game.objs[i].kind = kind
  game.objs[i].x = x
  game.objs[i].y = y
  game.objs[i].vx = vx
  game.objs[i].vy = vy
  game.objs[i].w = w
  game.objs[i].h = h
  game.objs[i].hp = hp
  game.objs[i].shot_cd = shot_cd
  game.objs[i].spin = randf(0.0, 6.283)
  game.objs[i].cloak = cloak
  game.objs[i].reward = reward
}

///|
fn score_gain(game : Game, base : Int) -> Int {
  let bonus = base * game.combo / 5
  base + bonus
}

///|
fn add_score(game : Game, base : Int) -> Unit {
  let g = score_gain(game, base)
  game.score = game.score + g
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn push_combo(game : Game) -> Unit {
  game.combo = clampi(game.combo + 1, 0, 24)
  game.combo_t = 3.6
}

///|
fn clear_combo(game : Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
fn is_hostile(kind : Int) -> Bool {
  kind == obj_scout ||
  kind == obj_spinner ||
  kind == obj_tank ||
  kind == obj_gear_wall
}

///|
fn is_pickup(kind : Int) -> Bool {
  kind == obj_coin || kind == obj_coolant || kind == obj_emp_cell
}

///|
fn obj_hit_r(o : Obj) -> Float {
  maxf(o.w, o.h) * 0.38
}

///|
fn player_hit_r(p : Player) -> Float {
  maxf(p.w, p.h) * 0.34
}

///|
fn hurt_player(game : Game, dmg : Float) -> Unit {
  if game.hero.invuln > 0.0 {
    return
  }

  game.armor = maxf(0.0, game.armor - dmg)
  game.hero.invuln = invuln_time
  game.hero.hurt_t = 0.58
  game.flash_t = maxf(game.flash_t, 0.34)
  game.shake_t = maxf(game.shake_t, 0.58)

  burst(game, game.hero.x, game.hero.y, 22, 1)
  clear_combo(game)

  if game.armor <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }
}

///|
fn start_stage(game : Game, stage : Int) -> Unit {
  clear_objs(game)
  clear_shots(game)
  clear_sparks(game)
  clear_rings(game)
  clear_ghosts(game)
  reset_player(game.hero)

  game.state = state_play
  game.stage = stage
  game.distance = 0.0
  game.stage_goal = stage_goal_base +
    Float::from_int(stage - 1) * stage_goal_bonus
  game.scroll = base_scroll + Float::from_int(stage - 1) * stage_scroll_bonus
  game.next_spawn_y = spawn_start_y

  game.fire_cd = 0.0
  game.dash_cd = 0.0
  game.dash_t = 0.0
  game.emp_cd = 0.0
  game.emp_t = 0.0
  game.result_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.hint_t = 0.0
  clear_combo(game)

  if stage <= 1 {
    game.score = 0
    game.coins = 0
    game.kills = 0
    game.armor = armor_max
    game.heat = heat_max
  } else {
    game.armor = minf(armor_max, game.armor + 20.0)
    game.heat = minf(heat_max, game.heat + 34.0)
  }

  spawn_ring(game, game.hero.x, game.hero.y, 16.0, 0.72, 0)
}

///|
fn init_title_scene(game : Game) -> Unit {
  clear_objs(game)
  clear_shots(game)
  clear_sparks(game)
  clear_rings(game)
  clear_ghosts(game)
  reset_player(game.hero)

  game.state = state_title
  game.stage = 1
  game.distance = 0.0
  game.stage_goal = stage_goal_base
  game.score = 0
  game.coins = 0
  game.kills = 0
  game.combo = 0
  game.combo_t = 0.0
  game.armor = armor_max
  game.heat = heat_max

  game.fire_cd = 0.0
  game.dash_cd = 0.0
  game.dash_t = 0.0
  game.emp_cd = 0.0
  game.emp_t = 0.0

  game.time_s = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  game.scroll = base_scroll
  game.next_spawn_y = spawn_start_y
}

///|
fn start_run(game : Game) -> Unit {
  start_stage(game, 1)
}

///|
fn spawn_wave(game : Game, y : Float) -> Unit {
  let depth = game.distance + (Float::from_int(screen_h) - y)
  let center = track_center(depth, game.time_s)

  let c = 1 + randi(0, 2)
  for _i = 0; _i < c; _i = _i + 1 {
    let roll = randi(0, 99)

    if roll < 34 {
      let lane = randi(0, lane_count - 1)
      let x = lane_pos(lane, center) + randf(-12.0, 12.0)
      spawn_obj(
        game,
        obj_scout,
        x,
        y + randf(-28.0, 22.0),
        randf(-42.0, 42.0),
        randf(-18.0, 38.0),
        44.0,
        76.0,
        18.0 + Float::from_int(game.stage - 1) * 3.0,
        randf(0.42, 1.28),
        false,
        120,
      )
    } else if roll < 56 {
      let lane = randi(0, lane_count - 1)
      let x = lane_pos(lane, center) + randf(-14.0, 14.0)
      spawn_obj(
        game,
        obj_spinner,
        x,
        y + randf(-26.0, 22.0),
        randf(-62.0, 62.0),
        randf(-10.0, 30.0),
        40.0,
        40.0,
        12.0 + Float::from_int(game.stage - 1) * 2.0,
        randf(0.26, 0.94),
        game.stage >= 3 && chance(24),
        108,
      )
    } else if roll < 70 {
      let lane = randi(0, lane_count - 1)
      let x = lane_pos(lane, center)
      spawn_obj(
        game,
        obj_tank,
        x,
        y + randf(-32.0, 24.0),
        randf(-18.0, 18.0),
        randf(-16.0, 18.0),
        82.0,
        122.0,
        46.0 + Float::from_int(game.stage - 1) * 7.0,
        randf(0.7, 1.9),
        false,
        188,
      )
    } else if roll < 80 {
      let lane = randi(0, lane_count - 1)
      let x = lane_pos(lane, center)
      spawn_obj(
        game,
        obj_gear_wall,
        x,
        y + randf(-16.0, 12.0),
        0.0,
        randf(-6.0, 12.0),
        126.0,
        18.0,
        16.0,
        randf(0.9, 2.02),
        false,
        94,
      )
    } else if roll < 90 {
      let x = spawn_x(game.distance, game.time_s, game.stage, y)
      spawn_obj(
        game,
        obj_coin,
        x,
        y + randf(-18.0, 18.0),
        randf(-34.0, 34.0),
        randf(-14.0, 16.0),
        34.0,
        34.0,
        1.0,
        0.0,
        false,
        0,
      )
    } else if roll < 96 {
      let x = spawn_x(game.distance, game.time_s, game.stage, y)
      spawn_obj(
        game,
        obj_coolant,
        x,
        y + randf(-18.0, 18.0),
        randf(-28.0, 28.0),
        randf(-12.0, 18.0),
        38.0,
        38.0,
        1.0,
        0.0,
        false,
        0,
      )
    } else {
      let x = spawn_x(game.distance, game.time_s, game.stage, y)
      spawn_obj(
        game,
        obj_emp_cell,
        x,
        y + randf(-14.0, 14.0),
        randf(-20.0, 20.0),
        randf(-10.0, 14.0),
        34.0,
        34.0,
        1.0,
        0.0,
        false,
        0,
      )
    }
  }
}

///|
fn spawn_step(game : Game, dt : Float) -> Unit {
  game.next_spawn_y = game.next_spawn_y + game.scroll * dt

  let mut n = 0
  while game.next_spawn_y >= 0.0 && n < 18 {
    game.next_spawn_y = game.next_spawn_y - randf(spawn_gap_min, spawn_gap_max)
    spawn_wave(game, game.next_spawn_y)
    n = n + 1
  }
}

///|
fn apply_emp(game : Game) -> Unit {
  game.emp_cd = emp_cd_time
  game.emp_t = emp_time

  spawn_ring(game, game.hero.x, game.hero.y, 14.0, 0.9, 2)
  burst(game, game.hero.x, game.hero.y, 24, 2)

  let rr2 = emp_radius * emp_radius
  let kill2 = emp_kill_radius * emp_kill_radius

  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      continue
    }

    let d2 = dist2(game.hero.x, game.hero.y, game.objs[i].x, game.objs[i].y)
    if d2 > rr2 {
      continue
    }

    game.objs[i].cloak = false

    if is_hostile(game.objs[i].kind) && d2 <= kill2 {
      let kind = game.objs[i].kind
      let x = game.objs[i].x
      let y = game.objs[i].y
      game.objs[i].active = false
      add_score(game, if kind == obj_tank { 140 } else { 88 })
      push_combo(game)
      burst(game, x, y, 18, 1)
      spawn_ring(game, x, y, 10.0, 0.5, 1)
      game.kills = game.kills + 1
    }
  }

  for i = 0; i < game.shots.length(); i = i + 1 {
    if not(game.shots[i].active) || game.shots[i].from_player {
      continue
    }

    let d2 = dist2(game.hero.x, game.hero.y, game.shots[i].x, game.shots[i].y)
    if d2 <= rr2 {
      game.shots[i].active = false
      emit_spark(
        game,
        game.shots[i].x,
        game.shots[i].y,
        randf(-86.0, 86.0),
        randf(-86.0, 86.0),
        randf(0.2, 0.45),
        randf(1.2, 3.4),
        2,
      )
    }
  }
}

///|
fn shoot_player(game : Game) -> Unit {
  let spread : Float = if game.dash_t > 0.0 { 15.0 } else { 8.0 }

  spawn_shot(
    game,
    true,
    game.hero.x - 10.0,
    game.hero.y - game.hero.h * 0.44,
    randf(-spread, spread),
    -shot_speed,
    shot_life,
    8.0,
    0,
  )
  spawn_shot(
    game,
    true,
    game.hero.x + 10.0,
    game.hero.y - game.hero.h * 0.44,
    randf(-spread, spread),
    -shot_speed,
    shot_life,
    8.0,
    0,
  )

  if game.stage >= 4 && chance(26) {
    spawn_shot(
      game,
      true,
      game.hero.x,
      game.hero.y - game.hero.h * 0.54,
      randf(-6.0, 6.0),
      -shot_speed * 1.08,
      shot_life,
      6.0,
      1,
    )
  }

  game.hero.muzzle_t = 0.12
}

///|
fn apply_player_input(game : Game, dt : Float) -> Unit {
  if game.input_dash_press && game.dash_cd <= 0.0 && game.heat >= 14.0 {
    game.dash_t = dash_time
    game.dash_cd = dash_cd_time
    game.heat = maxf(0.0, game.heat - 12.0)
    game.hero.invuln = maxf(game.hero.invuln, 0.22)

    let mut dx = game.input_x
    let mut dy = game.input_y
    let n2 = dx * dx + dy * dy
    if n2 <= 0.001 {
      dx = 0.0
      dy = -1.0
    } else {
      let inv : Float = Float::from_int(1) / sqrtf(n2)
      dx = dx * inv
      dy = dy * inv
    }

    game.hero.vx = game.hero.vx + dx * dash_boost
    game.hero.vy = game.hero.vy + dy * dash_boost * 0.72

    spawn_ring(game, game.hero.x, game.hero.y, 18.0, 0.58, 0)
    burst(game, game.hero.x, game.hero.y, 16, 0)
  }

  if game.input_emp_press && game.emp_cd <= 0.0 && game.heat >= 18.0 {
    game.heat = maxf(0.0, game.heat - 18.0)
    apply_emp(game)
  }

  if game.input_fire_hold && game.fire_cd <= 0.0 {
    shoot_player(game)
    game.fire_cd = if game.dash_t > 0.0 {
      shot_cd_base * 0.62
    } else {
      shot_cd_base
    }
  }

  game.hero.vx = game.hero.vx + game.input_x * accel_x * dt
  game.hero.vy = game.hero.vy + game.input_y * accel_y * dt

  if game.dash_t > 0.0 {
    game.hero.vy = game.hero.vy - 150.0 * dt
    emit_ghost(
      game,
      game.hero.x,
      game.hero.y + 16.0,
      game.hero.w,
      game.hero.h,
      game.hero.heading,
      randf(0.14, 0.26),
      1,
    )
  }

  let drag = clampf(1.0 - car_drag * dt, 0.0, 1.0)
  game.hero.vx = game.hero.vx * drag
  game.hero.vy = game.hero.vy * drag

  game.hero.vx = clampf(game.hero.vx, -max_speed_x, max_speed_x)
  game.hero.vy = clampf(game.hero.vy, -max_speed_y, max_speed_y)

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  game.hero.y = clampf(
    game.hero.y,
    Float::from_int(hud_h + 56),
    Float::from_int(screen_h) - 80.0,
  )
}

///|
fn constrain_to_track(game : Game) -> Unit {
  let depth = game.distance + (Float::from_int(screen_h) - game.hero.y)
  let e = track_edges(game.stage, depth, game.time_s)
  let left = e.0
  let right = e.1

  let rr = player_hit_r(game.hero)

  if game.hero.x - rr < left {
    game.hero.x = left + rr
    game.hero.vx = absf(game.hero.vx) * 0.2
    hurt_player(game, 10.0)
  }

  if game.hero.x + rr > right {
    game.hero.x = right - rr
    game.hero.vx = -absf(game.hero.vx) * 0.2
    hurt_player(game, 10.0)
  }
}

///|
fn enemy_fire(game : Game, o : Obj) -> Unit {
  if o.kind == obj_scout {
    spawn_shot(
      game,
      false,
      o.x,
      o.y + o.h * 0.4,
      randf(-120.0, 120.0),
      enemy_shot_speed,
      2.2,
      9.0,
      0,
    )
  } else if o.kind == obj_spinner {
    let dx = game.hero.x - o.x
    let dy = game.hero.y - o.y
    let n2 = maxf(dx * dx + dy * dy, 1.0)
    let inv : Float = Float::from_int(1) / sqrtf(n2)
    spawn_shot(
      game,
      false,
      o.x,
      o.y,
      dx * inv * enemy_shot_speed,
      dy * inv * enemy_shot_speed,
      2.5,
      11.0,
      1,
    )
  } else if o.kind == obj_tank {
    spawn_shot(
      game,
      false,
      o.x - 18.0,
      o.y + o.h * 0.32,
      -60.0,
      enemy_shot_speed * 0.86,
      2.6,
      12.0,
      2,
    )
    spawn_shot(
      game,
      false,
      o.x + 18.0,
      o.y + o.h * 0.32,
      60.0,
      enemy_shot_speed * 0.86,
      2.6,
      12.0,
      2,
    )
  }
}

///|
fn kill_obj(game : Game, i : Int, base : Int, burst_kind : Int) -> Unit {
  let x = game.objs[i].x
  let y = game.objs[i].y
  game.objs[i].active = false
  add_score(game, base)
  push_combo(game)
  game.kills = game.kills + 1
  burst(game, x, y, 16 + randi(0, 8), burst_kind)
  spawn_ring(game, x, y, 10.0, 0.56, burst_kind)
}

///|
fn collect_item(game : Game, kind : Int) -> Unit {
  if kind == obj_coin {
    game.coins = game.coins + 1
    add_score(game, 60)
    push_combo(game)
  } else if kind == obj_coolant {
    game.heat = minf(heat_max, game.heat + heat_pickup)
    add_score(game, 40)
  } else {
    game.emp_cd = maxf(0.0, game.emp_cd - 1.1)
    game.heat = minf(heat_max, game.heat + 12.0)
    add_score(game, 78)
    push_combo(game)
  }
}

///|
fn update_objs(game : Game, dt : Float) -> Unit {
  let ram = game.dash_t > 0.0

  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      continue
    }

    game.objs[i].x = game.objs[i].x + game.objs[i].vx * dt
    game.objs[i].y = game.objs[i].y + (game.scroll + game.objs[i].vy) * dt
    game.objs[i].spin = game.objs[i].spin + dt * 1.9
    game.objs[i].shot_cd = game.objs[i].shot_cd - dt

    if game.objs[i].kind == obj_scout {
      game.objs[i].x = game.objs[i].x +
        sinf(game.objs[i].spin * 2.2) * 34.0 * dt
    } else if game.objs[i].kind == obj_spinner {
      game.objs[i].y = game.objs[i].y +
        cosf(game.objs[i].spin * 2.8) * 26.0 * dt
    } else if game.objs[i].kind == obj_tank {
      game.objs[i].x = game.objs[i].x +
        sinf(game.objs[i].spin * 1.4) * 18.0 * dt
    } else if game.objs[i].kind == obj_gear_wall {
      game.objs[i].w = 118.0 + sinf(game.objs[i].spin * 3.4) * 26.0
      game.objs[i].h = 18.0 + sinf(game.objs[i].spin * 4.2) * 4.0
    } else {
      game.objs[i].x = game.objs[i].x +
        sinf(game.objs[i].spin * 2.6) * 16.0 * dt
    }

    let out = game.objs[i].y > Float::from_int(screen_h) + 220.0 ||
      game.objs[i].x < -260.0 ||
      game.objs[i].x > Float::from_int(screen_w) + 260.0
    if out {
      game.objs[i].active = false
      continue
    }

    if is_hostile(game.objs[i].kind) && game.objs[i].shot_cd <= 0.0 {
      enemy_fire(game, game.objs[i])
      game.objs[i].shot_cd = if game.objs[i].kind == obj_scout {
        randf(0.74, 1.44)
      } else if game.objs[i].kind == obj_spinner {
        randf(0.48, 1.02)
      } else if game.objs[i].kind == obj_tank {
        randf(1.18, 2.1)
      } else {
        randf(1.0, 1.8)
      }
    }

    let d2 = dist2(game.hero.x, game.hero.y, game.objs[i].x, game.objs[i].y)
    let rr = player_hit_r(game.hero) + obj_hit_r(game.objs[i])

    if d2 <= rr * rr {
      let kind = game.objs[i].kind
      if is_pickup(kind) {
        game.objs[i].active = false
        collect_item(game, kind)
        burst(game, game.hero.x, game.hero.y, 10, 2)
      } else if ram {
        kill_obj(game, i, game.objs[i].reward, 0)
      } else {
        let dmg : Float = if kind == obj_tank {
          24.0
        } else if kind == obj_gear_wall {
          16.0
        } else {
          14.0
        }
        hurt_player(game, dmg)
        if kind != obj_gear_wall {
          game.objs[i].active = false
        }
      }
    }
  }
}

///|
fn update_shots(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.shots.length(); i = i + 1 {
    if not(game.shots[i].active) {
      continue
    }

    game.shots[i].x = game.shots[i].x + game.shots[i].vx * dt
    game.shots[i].y = game.shots[i].y +
      (game.shots[i].vy + game.scroll * 0.1) * dt
    game.shots[i].life = game.shots[i].life - dt

    let dead = game.shots[i].life <= 0.0 ||
      game.shots[i].y < -120.0 ||
      game.shots[i].y > Float::from_int(screen_h) + 120.0 ||
      game.shots[i].x < -120.0 ||
      game.shots[i].x > Float::from_int(screen_w) + 120.0
    if dead {
      game.shots[i].active = false
      continue
    }

    if game.shots[i].from_player {
      let mut hit = false
      for j = 0; j < game.objs.length(); j = j + 1 {
        if not(game.objs[j].active) || is_pickup(game.objs[j].kind) {
          continue
        }

        let d2 = dist2(
          game.shots[i].x,
          game.shots[i].y,
          game.objs[j].x,
          game.objs[j].y,
        )
        let rr = obj_hit_r(game.objs[j]) + 8.0
        if d2 <= rr * rr {
          game.objs[j].hp = game.objs[j].hp - game.shots[i].dmg
          game.shots[i].active = false
          hit = true

          emit_spark(
            game,
            game.objs[j].x,
            game.objs[j].y,
            randf(-90.0, 90.0),
            randf(-90.0, 90.0),
            randf(0.18, 0.42),
            randf(1.0, 3.2),
            0,
          )

          if game.objs[j].hp <= 0.0 {
            kill_obj(game, j, game.objs[j].reward, 0)
          }
          break
        }
      }

      if hit {
        continue
      }
    } else {
      let d2 = dist2(game.shots[i].x, game.shots[i].y, game.hero.x, game.hero.y)
      let rr = player_hit_r(game.hero) + 8.0
      if d2 <= rr * rr {
        game.shots[i].active = false
        hurt_player(game, game.shots[i].dmg)
        continue
      }
    }
  }
}

///|
fn update_fx(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    game.sparks[i].x = game.sparks[i].x + game.sparks[i].vx * dt
    game.sparks[i].y = game.sparks[i].y +
      (game.sparks[i].vy + game.scroll * 0.16) * dt
    game.sparks[i].life = game.sparks[i].life - dt

    if game.sparks[i].life <= 0.0 {
      game.sparks[i].active = false
    }
  }

  for i = 0; i < game.rings.length(); i = i + 1 {
    if not(game.rings[i].active) {
      continue
    }

    game.rings[i].life = game.rings[i].life - dt
    game.rings[i].r = game.rings[i].r +
      (130.0 + Float::from_int(game.rings[i].kind) * 52.0) * dt
    if game.rings[i].life <= 0.0 {
      game.rings[i].active = false
    }
  }

  for i = 0; i < game.ghosts.length(); i = i + 1 {
    if not(game.ghosts[i].active) {
      continue
    }

    game.ghosts[i].y = game.ghosts[i].y + game.scroll * 0.26 * dt
    game.ghosts[i].life = game.ghosts[i].life - dt
    if game.ghosts[i].life <= 0.0 {
      game.ghosts[i].active = false
    }
  }
}

///|
fn emit_ambient(game : Game, dt : Float) -> Unit {
  let tries = clampi((dt * 230.0).to_int(), 1, 10)
  let mut i = 0
  while i < tries {
    if chance(32) {
      let y = randf(Float::from_int(hud_h), Float::from_int(screen_h) + 12.0)
      let depth = game.distance + (Float::from_int(screen_h) - y)
      let e = track_edges(game.stage, depth, game.time_s)
      let side : Float = if chance(50) {
        Float::from_int(-1)
      } else {
        Float::from_int(1)
      }
      let x = if side < 0.0 {
        e.0 + randf(8.0, 30.0)
      } else {
        e.1 - randf(8.0, 30.0)
      }

      emit_spark(
        game,
        x,
        y,
        side * randf(4.0, 20.0),
        randf(-20.0, 34.0),
        randf(0.5, 1.4),
        randf(1.0, 2.8),
        if chance(40) {
          2
        } else {
          0
        },
      )
    }
    i = i + 1
  }
}

///|
fn update_timers(game : Game, dt : Float) -> Unit {
  game.hero.invuln = maxf(0.0, game.hero.invuln - dt)
  game.hero.hurt_t = maxf(0.0, game.hero.hurt_t - dt)
  game.hero.muzzle_t = maxf(0.0, game.hero.muzzle_t - dt)
  game.hero.engine_t = game.hero.engine_t + dt

  game.fire_cd = maxf(0.0, game.fire_cd - dt)
  game.dash_cd = maxf(0.0, game.dash_cd - dt)
  game.dash_t = maxf(0.0, game.dash_t - dt)
  game.emp_cd = maxf(0.0, game.emp_cd - dt)
  game.emp_t = maxf(0.0, game.emp_t - dt)

  game.flash_t = maxf(0.0, game.flash_t - dt)
  game.shake_t = maxf(0.0, game.shake_t - dt)

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      clear_combo(game)
    }
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.scroll = base_scroll +
    Float::from_int(game.stage - 1) * stage_scroll_bonus +
    minf(70.0, game.distance * 0.006)
  game.distance = game.distance + game.scroll * dt

  apply_player_input(game, dt)
  constrain_to_track(game)

  spawn_step(game, dt)
  update_objs(game, dt)
  update_shots(game, dt)
  update_fx(game, dt)

  game.heat = maxf(
    0.0,
    game.heat -
    heat_drain_base * dt -
    absf(game.hero.vx) / max_speed_x * 1.2 * dt,
  )

  if game.dash_t > 0.0 {
    game.heat = maxf(0.0, game.heat - heat_drain_dash * dt)
  }

  game.armor = maxf(0.0, game.armor - armor_drain_passive * dt)

  emit_ambient(game, dt)

  if game.heat <= 0.0 {
    hurt_player(game, 100.0)
  }

  if game.state == state_play && game.distance >= game.stage_goal {
    game.state = state_stage_clear
    game.result_t = 0.0
    add_score(game, 320 + game.stage * 120)
    game.armor = minf(armor_max, game.armor + 14.0)
    game.heat = minf(heat_max, game.heat + 20.0)
    spawn_ring(game, game.hero.x, game.hero.y, 18.0, 0.9, 2)
    burst(game, game.hero.x, game.hero.y, 28, 2)
  }
}

///|
fn update_title(game : Game, dt : Float) -> Unit {
  game.scroll = 96.0
  game.distance = game.distance + game.scroll * dt * 0.7

  emit_ambient(game, dt)
  update_fx(game, dt)

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll = maxf(90.0, game.scroll - 140.0 * dt)

  update_fx(game, dt)
  emit_ambient(game, dt)

  if chance(24) {
    emit_spark(
      game,
      game.hero.x + randf(-30.0, 30.0),
      game.hero.y + randf(-30.0, 30.0),
      randf(-44.0, 44.0),
      randf(-80.0, -16.0),
      randf(0.26, 0.62),
      randf(2.0, 4.2),
      2,
    )
  }

  if game.input_restart_press || game.result_t >= stage_clear_wait {
    start_stage(game, game.stage + 1)
  }
}

///|
fn update_game_over(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll = maxf(52.0, game.scroll - 120.0 * dt)

  update_fx(game, dt)
  emit_ambient(game, dt)

  if game.input_restart_press {
    init_title_scene(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt

  update_timers(game, dt)

  if game.state == state_title {
    update_title(game, dt)
  } else if game.state == state_play {
    update_play(game, dt)
  } else if game.state == state_stage_clear {
    update_stage_clear(game, dt)
  } else {
    update_game_over(game, dt)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}
