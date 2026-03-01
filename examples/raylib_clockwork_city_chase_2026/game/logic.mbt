///|
fn clear_objs(game : @types.Game) -> Unit {
  for obj in game.objs {
    obj.active = false
    obj.kind = @types.Scout
    obj.x = 0.0
    obj.y = 0.0
    obj.vx = 0.0
    obj.vy = 0.0
    obj.w = 0.0
    obj.h = 0.0
    obj.hp = 0.0
    obj.shot_cd = 0.0
    obj.spin = 0.0
    obj.cloak = false
    obj.reward = 0
  }
}

///|
fn clear_shots(game : @types.Game) -> Unit {
  for shot in game.shots {
    shot.active = false
    shot.from_player = true
    shot.x = 0.0
    shot.y = 0.0
    shot.vx = 0.0
    shot.vy = 0.0
    shot.life = 0.0
    shot.dmg = 0.0
    shot.kind = 0
  }
}

///|
fn clear_sparks(game : @types.Game) -> Unit {
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
fn clear_rings(game : @types.Game) -> Unit {
  for ring in game.rings {
    ring.active = false
    ring.x = 0.0
    ring.y = 0.0
    ring.r = 0.0
    ring.life = 0.0
    ring.kind = 0
  }
}

///|
fn clear_ghosts(game : @types.Game) -> Unit {
  for ghost in game.ghosts {
    ghost.active = false
    ghost.x = 0.0
    ghost.y = 0.0
    ghost.w = 0.0
    ghost.h = 0.0
    ghost.rot = 0.0
    ghost.life = 0.0
    ghost.kind = 0
  }
}

///|
fn reset_player(hero : @types.Player) -> Unit {
  hero.x = Float::from_int(@types.screen_w / 2)
  hero.y = Float::from_int(@types.screen_h) * 0.76
  hero.vx = 0.0
  hero.vy = 0.0
  hero.w = @types.car_w
  hero.h = @types.car_h
  hero.heading = 0.0
  hero.invuln = 0.0
  hero.hurt_t = 0.0
  hero.muzzle_t = 0.0
  hero.engine_t = 0.0
}

///|
fn alloc_obj(game : @types.Game) -> Int {
  for i in 0..<game.objs.length() {
    if not(game.objs[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_y = game.objs[0].y
  for i in 1..<game.objs.length() {
    if game.objs[i].y > best_y {
      best_y = game.objs[i].y
      best = i
    }
  }
  best
}

///|
fn alloc_shot(game : @types.Game) -> Int {
  for i in 0..<game.shots.length() {
    if not(game.shots[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.shots[0].life
  for i in 1..<game.shots.length() {
    if game.shots[i].life < best_life {
      best_life = game.shots[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_spark(game : @types.Game) -> Int {
  for i in 0..<game.sparks.length() {
    if not(game.sparks[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.sparks[0].life
  for i in 1..<game.sparks.length() {
    if game.sparks[i].life < best_life {
      best_life = game.sparks[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_ring(game : @types.Game) -> Int {
  for i in 0..<game.rings.length() {
    if not(game.rings[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.rings[0].life
  for i in 1..<game.rings.length() {
    if game.rings[i].life < best_life {
      best_life = game.rings[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_ghost(game : @types.Game) -> Int {
  for i in 0..<game.ghosts.length() {
    if not(game.ghosts[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.ghosts[0].life
  for i in 1..<game.ghosts.length() {
    if game.ghosts[i].life < best_life {
      best_life = game.ghosts[i].life
      best = i
    }
  }
  best
}

///|
fn emit_spark(
  game : @types.Game,
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
fn burst(
  game : @types.Game,
  x : Float,
  y : Float,
  count : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<count {
    emit_spark(
      game,
      x + @types.randf(-20.0, 20.0),
      y + @types.randf(-20.0, 20.0),
      @types.randf(-270.0, 270.0),
      @types.randf(-270.0, 270.0),
      @types.randf(0.24, 1.02),
      @types.randf(1.2, 6.6),
      kind,
    )
  }
}

///|
fn spawn_ring(
  game : @types.Game,
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
  game : @types.Game,
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
  game : @types.Game,
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
  game : @types.Game,
  kind : @types.ObjKind,
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
  game.objs[i].spin = @types.randf(0.0, 6.283)
  game.objs[i].cloak = cloak
  game.objs[i].reward = reward
}

///|
fn score_gain(game : @types.Game, base : Int) -> Int {
  let bonus = base * game.combo / 5
  base + bonus
}

///|
fn add_score(game : @types.Game, base : Int) -> Unit {
  let g = score_gain(game, base)
  game.score = game.score + g
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn push_combo(game : @types.Game) -> Unit {
  game.combo = @types.clampi(game.combo + 1, 0, 24)
  game.combo_t = 3.6
}

///|
fn clear_combo(game : @types.Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
fn hurt_player(game : @types.Game, dmg : Float) -> Unit {
  if game.hero.invuln > 0.0 {
    return
  }

  game.armor = @types.maxf(0.0, game.armor - dmg)
  game.hero.invuln = @types.invuln_time
  game.hero.hurt_t = 0.58
  game.flash_t = @types.maxf(game.flash_t, 0.34)
  game.shake_t = @types.maxf(game.shake_t, 0.58)

  burst(game, game.hero.x, game.hero.y, 22, 1)
  clear_combo(game)

  if game.armor <= 0.0 {
    game.state = @types.GameOver
    game.result_t = 0.0
  }
}

///|
fn start_stage(game : @types.Game, stage : Int) -> Unit {
  clear_objs(game)
  clear_shots(game)
  clear_sparks(game)
  clear_rings(game)
  clear_ghosts(game)
  reset_player(game.hero)

  game.state = @types.Play
  game.stage = stage
  game.distance = 0.0
  game.stage_goal = @types.stage_goal_base +
    Float::from_int(stage - 1) * @types.stage_goal_bonus
  game.scroll = @types.base_scroll +
    Float::from_int(stage - 1) * @types.stage_scroll_bonus
  game.next_spawn_y = @types.spawn_start_y

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
    game.armor = @types.armor_max
    game.heat = @types.heat_max
  } else {
    game.armor = @types.minf(@types.armor_max, game.armor + 20.0)
    game.heat = @types.minf(@types.heat_max, game.heat + 34.0)
  }

  spawn_ring(game, game.hero.x, game.hero.y, 16.0, 0.72, 0)
}

///|
fn init_title_scene(game : @types.Game) -> Unit {
  clear_objs(game)
  clear_shots(game)
  clear_sparks(game)
  clear_rings(game)
  clear_ghosts(game)
  reset_player(game.hero)

  game.state = @types.Title
  game.stage = 1
  game.distance = 0.0
  game.stage_goal = @types.stage_goal_base
  game.score = 0
  game.coins = 0
  game.kills = 0
  game.combo = 0
  game.combo_t = 0.0
  game.armor = @types.armor_max
  game.heat = @types.heat_max

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

  game.scroll = @types.base_scroll
  game.next_spawn_y = @types.spawn_start_y
}

///|
fn start_run(game : @types.Game) -> Unit {
  start_stage(game, 1)
}

///|
fn spawn_wave(game : @types.Game, y : Float) -> Unit {
  let depth = game.distance + (Float::from_int(@types.screen_h) - y)
  let center = @types.track_center(depth, game.time_s)

  let c = 1 + @types.randi(0, 2)
  for _i in 0..<c {
    let roll = @types.randi(0, 99)

    if roll < 34 {
      let lane = @types.randi(0, @types.lane_count - 1)
      let x = @types.lane_pos(lane, center) + @types.randf(-12.0, 12.0)
      spawn_obj(
        game,
        @types.Scout,
        x,
        y + @types.randf(-28.0, 22.0),
        @types.randf(-42.0, 42.0),
        @types.randf(-18.0, 38.0),
        44.0,
        76.0,
        18.0 + Float::from_int(game.stage - 1) * 3.0,
        @types.randf(0.42, 1.28),
        false,
        120,
      )
    } else if roll < 56 {
      let lane = @types.randi(0, @types.lane_count - 1)
      let x = @types.lane_pos(lane, center) + @types.randf(-14.0, 14.0)
      spawn_obj(
        game,
        @types.Spinner,
        x,
        y + @types.randf(-26.0, 22.0),
        @types.randf(-62.0, 62.0),
        @types.randf(-10.0, 30.0),
        40.0,
        40.0,
        12.0 + Float::from_int(game.stage - 1) * 2.0,
        @types.randf(0.26, 0.94),
        game.stage >= 3 && @types.chance(24),
        108,
      )
    } else if roll < 70 {
      let lane = @types.randi(0, @types.lane_count - 1)
      let x = @types.lane_pos(lane, center)
      spawn_obj(
        game,
        @types.Tank,
        x,
        y + @types.randf(-32.0, 24.0),
        @types.randf(-18.0, 18.0),
        @types.randf(-16.0, 18.0),
        82.0,
        122.0,
        46.0 + Float::from_int(game.stage - 1) * 7.0,
        @types.randf(0.7, 1.9),
        false,
        188,
      )
    } else if roll < 80 {
      let lane = @types.randi(0, @types.lane_count - 1)
      let x = @types.lane_pos(lane, center)
      spawn_obj(
        game,
        @types.GearWall,
        x,
        y + @types.randf(-16.0, 12.0),
        0.0,
        @types.randf(-6.0, 12.0),
        126.0,
        18.0,
        16.0,
        @types.randf(0.9, 2.02),
        false,
        94,
      )
    } else if roll < 90 {
      let x = @types.spawn_x(game.distance, game.time_s, game.stage, y)
      spawn_obj(
        game,
        @types.Coin,
        x,
        y + @types.randf(-18.0, 18.0),
        @types.randf(-34.0, 34.0),
        @types.randf(-14.0, 16.0),
        34.0,
        34.0,
        1.0,
        0.0,
        false,
        0,
      )
    } else if roll < 96 {
      let x = @types.spawn_x(game.distance, game.time_s, game.stage, y)
      spawn_obj(
        game,
        @types.Coolant,
        x,
        y + @types.randf(-18.0, 18.0),
        @types.randf(-28.0, 28.0),
        @types.randf(-12.0, 18.0),
        38.0,
        38.0,
        1.0,
        0.0,
        false,
        0,
      )
    } else {
      let x = @types.spawn_x(game.distance, game.time_s, game.stage, y)
      spawn_obj(
        game,
        @types.EmpCell,
        x,
        y + @types.randf(-14.0, 14.0),
        @types.randf(-20.0, 20.0),
        @types.randf(-10.0, 14.0),
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
fn spawn_step(game : @types.Game, dt : Float) -> Unit {
  game.next_spawn_y = game.next_spawn_y + game.scroll * dt

  let mut n = 0
  while game.next_spawn_y >= 0.0 && n < 18 {
    game.next_spawn_y = game.next_spawn_y -
      @types.randf(@types.spawn_gap_min, @types.spawn_gap_max)
    spawn_wave(game, game.next_spawn_y)
    n = n + 1
  }
}

///|
fn apply_emp(game : @types.Game) -> Unit {
  game.emp_cd = @types.emp_cd_time
  game.emp_t = @types.emp_time

  spawn_ring(game, game.hero.x, game.hero.y, 14.0, 0.9, 2)
  burst(game, game.hero.x, game.hero.y, 24, 2)

  let rr2 = @types.emp_radius * @types.emp_radius
  let kill2 = @types.emp_kill_radius * @types.emp_kill_radius

  for obj in game.objs {
    if not(obj.active) {
      continue
    }

    let d2 = @types.dist2(game.hero.x, game.hero.y, obj.x, obj.y)
    if d2 > rr2 {
      continue
    }

    obj.cloak = false

    if @types.is_hostile(obj.kind) && d2 <= kill2 {
      let kind = obj.kind
      let x = obj.x
      let y = obj.y
      obj.active = false
      add_score(game, if kind == @types.Tank { 140 } else { 88 })
      push_combo(game)
      burst(game, x, y, 18, 1)
      spawn_ring(game, x, y, 10.0, 0.5, 1)
      game.kills = game.kills + 1
    }
  }

  for shot in game.shots {
    if not(shot.active) || shot.from_player {
      continue
    }

    let d2 = @types.dist2(game.hero.x, game.hero.y, shot.x, shot.y)
    if d2 <= rr2 {
      shot.active = false
      emit_spark(
        game,
        shot.x,
        shot.y,
        @types.randf(-86.0, 86.0),
        @types.randf(-86.0, 86.0),
        @types.randf(0.2, 0.45),
        @types.randf(1.2, 3.4),
        2,
      )
    }
  }
}

///|
fn shoot_player(game : @types.Game) -> Unit {
  let spread : Float = if game.dash_t > 0.0 { 15.0 } else { 8.0 }

  spawn_shot(
    game,
    true,
    game.hero.x - 10.0,
    game.hero.y - game.hero.h * 0.44,
    @types.randf(-spread, spread),
    -@types.shot_speed,
    @types.shot_life,
    8.0,
    0,
  )
  spawn_shot(
    game,
    true,
    game.hero.x + 10.0,
    game.hero.y - game.hero.h * 0.44,
    @types.randf(-spread, spread),
    -@types.shot_speed,
    @types.shot_life,
    8.0,
    0,
  )

  if game.stage >= 4 && @types.chance(26) {
    spawn_shot(
      game,
      true,
      game.hero.x,
      game.hero.y - game.hero.h * 0.54,
      @types.randf(-6.0, 6.0),
      -@types.shot_speed * 1.08,
      @types.shot_life,
      6.0,
      1,
    )
  }

  game.hero.muzzle_t = 0.12
}

///|
fn apply_player_input(game : @types.Game, dt : Float) -> Unit {
  if game.input_dash_press && game.dash_cd <= 0.0 && game.heat >= 14.0 {
    game.dash_t = @types.dash_time
    game.dash_cd = @types.dash_cd_time
    game.heat = @types.maxf(0.0, game.heat - 12.0)
    game.hero.invuln = @types.maxf(game.hero.invuln, 0.22)

    let mut dx = game.input_x
    let mut dy = game.input_y
    let n2 = dx * dx + dy * dy
    if n2 <= 0.001 {
      dx = 0.0
      dy = -1.0
    } else {
      let inv : Float = Float::from_int(1) / @types.sqrtf(n2)
      dx = dx * inv
      dy = dy * inv
    }

    game.hero.vx = game.hero.vx + dx * @types.dash_boost
    game.hero.vy = game.hero.vy + dy * @types.dash_boost * 0.72

    spawn_ring(game, game.hero.x, game.hero.y, 18.0, 0.58, 0)
    burst(game, game.hero.x, game.hero.y, 16, 0)
  }

  if game.input_emp_press && game.emp_cd <= 0.0 && game.heat >= 18.0 {
    game.heat = @types.maxf(0.0, game.heat - 18.0)
    apply_emp(game)
  }

  if game.input_fire_hold && game.fire_cd <= 0.0 {
    shoot_player(game)
    game.fire_cd = if game.dash_t > 0.0 {
      @types.shot_cd_base * 0.62
    } else {
      @types.shot_cd_base
    }
  }

  game.hero.vx = game.hero.vx + game.input_x * @types.accel_x * dt
  game.hero.vy = game.hero.vy + game.input_y * @types.accel_y * dt

  if game.dash_t > 0.0 {
    game.hero.vy = game.hero.vy - 150.0 * dt
    emit_ghost(
      game,
      game.hero.x,
      game.hero.y + 16.0,
      game.hero.w,
      game.hero.h,
      game.hero.heading,
      @types.randf(0.14, 0.26),
      1,
    )
  }

  let drag = @types.clampf(1.0 - @types.car_drag * dt, 0.0, 1.0)
  game.hero.vx = game.hero.vx * drag
  game.hero.vy = game.hero.vy * drag

  game.hero.vx = @types.clampf(
    game.hero.vx,
    -@types.max_speed_x,
    @types.max_speed_x,
  )
  game.hero.vy = @types.clampf(
    game.hero.vy,
    -@types.max_speed_y,
    @types.max_speed_y,
  )

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  game.hero.y = @types.clampf(
    game.hero.y,
    Float::from_int(@types.hud_h + 56),
    Float::from_int(@types.screen_h) - 80.0,
  )
}

///|
fn constrain_to_track(game : @types.Game) -> Unit {
  let depth = game.distance + (Float::from_int(@types.screen_h) - game.hero.y)
  let e = @types.track_edges(game.stage, depth, game.time_s)
  let left = e.0
  let right = e.1

  let rr = @types.player_hit_r(game.hero)

  if game.hero.x - rr < left {
    game.hero.x = left + rr
    game.hero.vx = @types.absf(game.hero.vx) * 0.2
    hurt_player(game, 10.0)
  }

  if game.hero.x + rr > right {
    game.hero.x = right - rr
    game.hero.vx = -@types.absf(game.hero.vx) * 0.2
    hurt_player(game, 10.0)
  }
}

///|
fn enemy_fire(game : @types.Game, o : @types.Obj) -> Unit {
  match o.kind {
    @types.Scout =>
      spawn_shot(
        game,
        false,
        o.x,
        o.y + o.h * 0.4,
        @types.randf(-120.0, 120.0),
        @types.enemy_shot_speed,
        2.2,
        9.0,
        0,
      )
    @types.Spinner => {
      let dx = game.hero.x - o.x
      let dy = game.hero.y - o.y
      let n2 = @types.maxf(dx * dx + dy * dy, 1.0)
      let inv : Float = Float::from_int(1) / @types.sqrtf(n2)
      spawn_shot(
        game,
        false,
        o.x,
        o.y,
        dx * inv * @types.enemy_shot_speed,
        dy * inv * @types.enemy_shot_speed,
        2.5,
        11.0,
        1,
      )
    }
    @types.Tank => {
      spawn_shot(
        game,
        false,
        o.x - 18.0,
        o.y + o.h * 0.32,
        -60.0,
        @types.enemy_shot_speed * 0.86,
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
        @types.enemy_shot_speed * 0.86,
        2.6,
        12.0,
        2,
      )
    }
    _ => ()
  }
}

///|
fn kill_obj(game : @types.Game, i : Int, base : Int, burst_kind : Int) -> Unit {
  let x = game.objs[i].x
  let y = game.objs[i].y
  game.objs[i].active = false
  add_score(game, base)
  push_combo(game)
  game.kills = game.kills + 1
  burst(game, x, y, 16 + @types.randi(0, 8), burst_kind)
  spawn_ring(game, x, y, 10.0, 0.56, burst_kind)
}

///|
fn collect_item(game : @types.Game, kind : @types.ObjKind) -> Unit {
  match kind {
    @types.Coin => {
      game.coins = game.coins + 1
      add_score(game, 60)
      push_combo(game)
    }
    @types.Coolant => {
      game.heat = @types.minf(@types.heat_max, game.heat + @types.heat_pickup)
      add_score(game, 40)
    }
    _ => {
      game.emp_cd = @types.maxf(0.0, game.emp_cd - 1.1)
      game.heat = @types.minf(@types.heat_max, game.heat + 12.0)
      add_score(game, 78)
      push_combo(game)
    }
  }
}

///|
fn update_objs(game : @types.Game, dt : Float) -> Unit {
  let ram = game.dash_t > 0.0

  for i in 0..<game.objs.length() {
    if not(game.objs[i].active) {
      continue
    }

    game.objs[i].x = game.objs[i].x + game.objs[i].vx * dt
    game.objs[i].y = game.objs[i].y + (game.scroll + game.objs[i].vy) * dt
    game.objs[i].spin = game.objs[i].spin + dt * 1.9
    game.objs[i].shot_cd = game.objs[i].shot_cd - dt

    match game.objs[i].kind {
      @types.Scout =>
        game.objs[i].x = game.objs[i].x +
          @types.sinf(game.objs[i].spin * 2.2) * 34.0 * dt
      @types.Spinner =>
        game.objs[i].y = game.objs[i].y +
          @types.cosf(game.objs[i].spin * 2.8) * 26.0 * dt
      @types.Tank =>
        game.objs[i].x = game.objs[i].x +
          @types.sinf(game.objs[i].spin * 1.4) * 18.0 * dt
      @types.GearWall => {
        game.objs[i].w = 118.0 + @types.sinf(game.objs[i].spin * 3.4) * 26.0
        game.objs[i].h = 18.0 + @types.sinf(game.objs[i].spin * 4.2) * 4.0
      }
      _ =>
        game.objs[i].x = game.objs[i].x +
          @types.sinf(game.objs[i].spin * 2.6) * 16.0 * dt
    }

    let out = game.objs[i].y > Float::from_int(@types.screen_h) + 220.0 ||
      game.objs[i].x < -260.0 ||
      game.objs[i].x > Float::from_int(@types.screen_w) + 260.0
    if out {
      game.objs[i].active = false
      continue
    }

    if @types.is_hostile(game.objs[i].kind) && game.objs[i].shot_cd <= 0.0 {
      enemy_fire(game, game.objs[i])
      game.objs[i].shot_cd = match game.objs[i].kind {
        @types.Scout => @types.randf(0.74, 1.44)
        @types.Spinner => @types.randf(0.48, 1.02)
        @types.Tank => @types.randf(1.18, 2.1)
        _ => @types.randf(1.0, 1.8)
      }
    }

    let d2 = @types.dist2(
      game.hero.x,
      game.hero.y,
      game.objs[i].x,
      game.objs[i].y,
    )
    let rr = @types.player_hit_r(game.hero) + @types.obj_hit_r(game.objs[i])

    if d2 <= rr * rr {
      let kind = game.objs[i].kind
      if @types.is_pickup(kind) {
        game.objs[i].active = false
        collect_item(game, kind)
        burst(game, game.hero.x, game.hero.y, 10, 2)
      } else if ram {
        kill_obj(game, i, game.objs[i].reward, 0)
      } else {
        let dmg : Float = match kind {
          @types.Tank => 24.0
          @types.GearWall => 16.0
          _ => 14.0
        }
        hurt_player(game, dmg)
        if kind != @types.GearWall {
          game.objs[i].active = false
        }
      }
    }
  }
}

///|
fn update_shots(game : @types.Game, dt : Float) -> Unit {
  for shot in game.shots {
    if not(shot.active) {
      continue
    }

    shot.x = shot.x + shot.vx * dt
    shot.y = shot.y + (shot.vy + game.scroll * 0.1) * dt
    shot.life = shot.life - dt

    let dead = shot.life <= 0.0 ||
      shot.y < -120.0 ||
      shot.y > Float::from_int(@types.screen_h) + 120.0 ||
      shot.x < -120.0 ||
      shot.x > Float::from_int(@types.screen_w) + 120.0
    if dead {
      shot.active = false
      continue
    }

    if shot.from_player {
      let mut hit = false
      for j in 0..<game.objs.length() {
        if not(game.objs[j].active) || @types.is_pickup(game.objs[j].kind) {
          continue
        }

        let d2 = @types.dist2(shot.x, shot.y, game.objs[j].x, game.objs[j].y)
        let rr = @types.obj_hit_r(game.objs[j]) + 8.0
        if d2 <= rr * rr {
          game.objs[j].hp = game.objs[j].hp - shot.dmg
          shot.active = false
          hit = true

          emit_spark(
            game,
            game.objs[j].x,
            game.objs[j].y,
            @types.randf(-90.0, 90.0),
            @types.randf(-90.0, 90.0),
            @types.randf(0.18, 0.42),
            @types.randf(1.0, 3.2),
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
      let d2 = @types.dist2(shot.x, shot.y, game.hero.x, game.hero.y)
      let rr = @types.player_hit_r(game.hero) + 8.0
      if d2 <= rr * rr {
        shot.active = false
        hurt_player(game, shot.dmg)
        continue
      }
    }
  }
}

///|
fn update_fx(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + (spark.vy + game.scroll * 0.16) * dt
    spark.life = spark.life - dt

    if spark.life <= 0.0 {
      spark.active = false
    }
  }

  for ring in game.rings {
    if not(ring.active) {
      continue
    }

    ring.life = ring.life - dt
    ring.r = ring.r + (130.0 + Float::from_int(ring.kind) * 52.0) * dt
    if ring.life <= 0.0 {
      ring.active = false
    }
  }

  for ghost in game.ghosts {
    if not(ghost.active) {
      continue
    }

    ghost.y = ghost.y + game.scroll * 0.26 * dt
    ghost.life = ghost.life - dt
    if ghost.life <= 0.0 {
      ghost.active = false
    }
  }
}

///|
fn emit_ambient(game : @types.Game, dt : Float) -> Unit {
  let tries = @types.clampi((dt * 230.0).to_int(), 1, 10)
  let mut i = 0
  while i < tries {
    if @types.chance(32) {
      let y = @types.randf(
        Float::from_int(@types.hud_h),
        Float::from_int(@types.screen_h) + 12.0,
      )
      let depth = game.distance + (Float::from_int(@types.screen_h) - y)
      let e = @types.track_edges(game.stage, depth, game.time_s)
      let side : Float = if @types.chance(50) {
        Float::from_int(-1)
      } else {
        Float::from_int(1)
      }
      let x = if side < 0.0 {
        e.0 + @types.randf(8.0, 30.0)
      } else {
        e.1 - @types.randf(8.0, 30.0)
      }

      emit_spark(
        game,
        x,
        y,
        side * @types.randf(4.0, 20.0),
        @types.randf(-20.0, 34.0),
        @types.randf(0.5, 1.4),
        @types.randf(1.0, 2.8),
        if @types.chance(40) {
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
fn update_timers(game : @types.Game, dt : Float) -> Unit {
  game.hero.invuln = @types.maxf(0.0, game.hero.invuln - dt)
  game.hero.hurt_t = @types.maxf(0.0, game.hero.hurt_t - dt)
  game.hero.muzzle_t = @types.maxf(0.0, game.hero.muzzle_t - dt)
  game.hero.engine_t = game.hero.engine_t + dt

  game.fire_cd = @types.maxf(0.0, game.fire_cd - dt)
  game.dash_cd = @types.maxf(0.0, game.dash_cd - dt)
  game.dash_t = @types.maxf(0.0, game.dash_t - dt)
  game.emp_cd = @types.maxf(0.0, game.emp_cd - dt)
  game.emp_t = @types.maxf(0.0, game.emp_t - dt)

  game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  game.shake_t = @types.maxf(0.0, game.shake_t - dt)

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      clear_combo(game)
    }
  }
}

///|
fn update_play(game : @types.Game, dt : Float) -> Unit {
  game.scroll = @types.base_scroll +
    Float::from_int(game.stage - 1) * @types.stage_scroll_bonus +
    @types.minf(70.0, game.distance * 0.006)
  game.distance = game.distance + game.scroll * dt

  apply_player_input(game, dt)
  constrain_to_track(game)

  spawn_step(game, dt)
  update_objs(game, dt)
  update_shots(game, dt)
  update_fx(game, dt)

  game.heat = @types.maxf(
    0.0,
    game.heat -
    @types.heat_drain_base * dt -
    @types.absf(game.hero.vx) / @types.max_speed_x * 1.2 * dt,
  )

  if game.dash_t > 0.0 {
    game.heat = @types.maxf(0.0, game.heat - @types.heat_drain_dash * dt)
  }

  game.armor = @types.maxf(0.0, game.armor - @types.armor_drain_passive * dt)

  emit_ambient(game, dt)

  if game.heat <= 0.0 {
    hurt_player(game, 100.0)
  }

  if game.state == @types.Play && game.distance >= game.stage_goal {
    game.state = @types.StageClear
    game.result_t = 0.0
    add_score(game, 320 + game.stage * 120)
    game.armor = @types.minf(@types.armor_max, game.armor + 14.0)
    game.heat = @types.minf(@types.heat_max, game.heat + 20.0)
    spawn_ring(game, game.hero.x, game.hero.y, 18.0, 0.9, 2)
    burst(game, game.hero.x, game.hero.y, 28, 2)
  }
}

///|
fn update_title(game : @types.Game, dt : Float) -> Unit {
  game.scroll = 96.0
  game.distance = game.distance + game.scroll * dt * 0.7

  emit_ambient(game, dt)
  update_fx(game, dt)

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll = @types.maxf(90.0, game.scroll - 140.0 * dt)

  update_fx(game, dt)
  emit_ambient(game, dt)

  if @types.chance(24) {
    emit_spark(
      game,
      game.hero.x + @types.randf(-30.0, 30.0),
      game.hero.y + @types.randf(-30.0, 30.0),
      @types.randf(-44.0, 44.0),
      @types.randf(-80.0, -16.0),
      @types.randf(0.26, 0.62),
      @types.randf(2.0, 4.2),
      2,
    )
  }

  if game.input_restart_press || game.result_t >= @types.stage_clear_wait {
    start_stage(game, game.stage + 1)
  }
}

///|
fn update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll = @types.maxf(52.0, game.scroll - 120.0 * dt)

  update_fx(game, dt)
  emit_ambient(game, dt)

  if game.input_restart_press {
    init_title_scene(game)
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Read input first
  match game.state {
    @types.Title => update_title_input(game)
    @types.Play => update_play_input(game)
    @types.StageClear | @types.GameOver => update_result_input(game)
  }

  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt

  update_timers(game, dt)

  match game.state {
    @types.Title => update_title(game, dt)
    @types.Play => update_play(game, dt)
    @types.StageClear => update_stage_clear(game, dt)
    @types.GameOver => update_game_over(game, dt)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
pub fn init_title(game : @types.Game) -> Unit {
  init_title_scene(game)
}
