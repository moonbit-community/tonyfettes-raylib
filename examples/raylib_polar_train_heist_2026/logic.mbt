///|
fn clear_ents(game : Game) -> Unit {
  for i = 0; i < game.ents.length(); i = i + 1 {
    game.ents[i].active = false
    game.ents[i].kind = ent_guard
    game.ents[i].x = 0.0
    game.ents[i].y = 0.0
    game.ents[i].vx = 0.0
    game.ents[i].vy = 0.0
    game.ents[i].w = 0.0
    game.ents[i].h = 0.0
    game.ents[i].hp = 0.0
    game.ents[i].lane = 0
    game.ents[i].shot_cd = 0.0
    game.ents[i].spin = 0.0
    game.ents[i].cloak = false
    game.ents[i].reward = 0
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
fn clear_fx(game : Game) -> Unit {
  for i = 0; i < game.fxs.length(); i = i + 1 {
    game.fxs[i].active = false
    game.fxs[i].x = 0.0
    game.fxs[i].y = 0.0
    game.fxs[i].vx = 0.0
    game.fxs[i].vy = 0.0
    game.fxs[i].life = 0.0
    game.fxs[i].size = 0.0
    game.fxs[i].kind = 0
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
fn clear_shadows(game : Game) -> Unit {
  for i = 0; i < game.shadows.length(); i = i + 1 {
    game.shadows[i].active = false
    game.shadows[i].x = 0.0
    game.shadows[i].y = 0.0
    game.shadows[i].w = 0.0
    game.shadows[i].h = 0.0
    game.shadows[i].rot = 0.0
    game.shadows[i].life = 0.0
    game.shadows[i].kind = 0
  }
}

///|
fn reset_player(hero : Player) -> Unit {
  hero.x = Float::from_int(screen_w / 2) - 220.0
  hero.lane = 1
  hero.ground_y = lane_y(hero.lane)
  hero.y = hero.ground_y
  hero.vx = 0.0
  hero.vy = 0.0
  hero.w = player_w
  hero.h = player_h
  hero.grounded = true
  hero.coyote_t = 0.0
  hero.jump_buf_t = 0.0
  hero.heading = 0.0
  hero.invuln = 0.0
  hero.hurt_t = 0.0
  hero.muzzle_t = 0.0
  hero.anim_t = 0.0
}

///|
fn alloc_ent(game : Game) -> Int {
  for i = 0; i < game.ents.length(); i = i + 1 {
    if not(game.ents[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_x = game.ents[0].x
  for i = 1; i < game.ents.length(); i = i + 1 {
    if game.ents[i].x < best_x {
      best_x = game.ents[i].x
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
fn alloc_fx(game : Game) -> Int {
  for i = 0; i < game.fxs.length(); i = i + 1 {
    if not(game.fxs[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.fxs[0].life
  for i = 1; i < game.fxs.length(); i = i + 1 {
    if game.fxs[i].life < best_life {
      best_life = game.fxs[i].life
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
fn alloc_shadow(game : Game) -> Int {
  for i = 0; i < game.shadows.length(); i = i + 1 {
    if not(game.shadows[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.shadows[0].life
  for i = 1; i < game.shadows.length(); i = i + 1 {
    if game.shadows[i].life < best_life {
      best_life = game.shadows[i].life
      best = i
    }
  }
  best
}

///|
fn emit_fx(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  let i = alloc_fx(game)
  game.fxs[i].active = true
  game.fxs[i].x = x
  game.fxs[i].y = y
  game.fxs[i].vx = vx
  game.fxs[i].vy = vy
  game.fxs[i].life = life
  game.fxs[i].size = size
  game.fxs[i].kind = kind
}

///|
fn burst(game : Game, x : Float, y : Float, count : Int, kind : Int) -> Unit {
  for _i = 0; _i < count; _i = _i + 1 {
    emit_fx(
      game,
      x + randf(-18.0, 18.0),
      y + randf(-18.0, 18.0),
      randf(-260.0, 260.0),
      randf(-260.0, 260.0),
      randf(0.24, 1.02),
      randf(1.2, 6.2),
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
fn emit_shadow(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  rot : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = alloc_shadow(game)
  game.shadows[i].active = true
  game.shadows[i].x = x
  game.shadows[i].y = y
  game.shadows[i].w = w
  game.shadows[i].h = h
  game.shadows[i].rot = rot
  game.shadows[i].life = life
  game.shadows[i].kind = kind
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
fn spawn_ent(
  game : Game,
  kind : Int,
  lane : Int,
  x : Float,
  vx : Float,
  vy : Float,
  w : Float,
  h : Float,
  hp : Float,
  shot_cd : Float,
  cloak : Bool,
  reward : Int,
) -> Unit {
  let i = alloc_ent(game)
  game.ents[i].active = true
  game.ents[i].kind = kind
  game.ents[i].lane = clampi(lane, 0, lane_count - 1)
  game.ents[i].x = x
  game.ents[i].y = lane_y(game.ents[i].lane)
  game.ents[i].vx = vx
  game.ents[i].vy = vy
  game.ents[i].w = w
  game.ents[i].h = h
  game.ents[i].hp = hp
  game.ents[i].shot_cd = shot_cd
  game.ents[i].spin = randf(0.0, 6.283)
  game.ents[i].cloak = cloak
  game.ents[i].reward = reward
}

///|
fn is_hostile(kind : Int) -> Bool {
  kind == ent_guard ||
  kind == ent_drone ||
  kind == ent_turret ||
  kind == ent_crate
}

///|
fn is_pickup(kind : Int) -> Bool {
  kind == ent_medkit || kind == ent_battery || kind == ent_signal
}

///|
fn ent_hit_r(e : Ent) -> Float {
  maxf(e.w, e.h) * 0.36
}

///|
fn player_hit_r(p : Player) -> Float {
  maxf(p.w, p.h) * 0.34
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
  game.combo_t = 3.5
}

///|
fn clear_combo(game : Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
fn hurt_player(game : Game, dmg : Float) -> Unit {
  if game.hero.invuln > 0.0 {
    return
  }

  game.armor = maxf(0.0, game.armor - dmg)
  game.hero.invuln = invuln_time
  game.hero.hurt_t = 0.56
  game.flash_t = maxf(game.flash_t, 0.32)
  game.shake_t = maxf(game.shake_t, 0.58)

  burst(game, game.hero.x, game.hero.y, 20, 1)
  clear_combo(game)

  if game.armor <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }
}

///|
fn start_stage(game : Game, stage : Int) -> Unit {
  clear_ents(game)
  clear_shots(game)
  clear_fx(game)
  clear_rings(game)
  clear_shadows(game)
  reset_player(game.hero)

  game.state = state_play
  game.stage = stage
  game.distance = 0.0
  game.stage_goal = stage_goal_base +
    Float::from_int(stage - 1) * stage_goal_bonus
  game.scroll = base_scroll + Float::from_int(stage - 1) * stage_scroll_bonus
  game.next_spawn_x = spawn_start_x

  game.fire_cd = 0.0
  game.dash_cd = 0.0
  game.dash_t = 0.0
  game.hook_cd = 0.0
  game.hook_t = 0.0

  game.result_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.hint_t = 0.0
  clear_combo(game)

  if stage <= 1 {
    game.score = 0
    game.loot = 0
    game.kills = 0
    game.armor = armor_max
    game.heat = heat_max
  } else {
    game.armor = minf(armor_max, game.armor + 20.0)
    game.heat = minf(heat_max, game.heat + 32.0)
  }

  spawn_ring(game, game.hero.x, game.hero.y, 14.0, 0.68, 0)
}

///|
fn init_title_scene(game : Game) -> Unit {
  clear_ents(game)
  clear_shots(game)
  clear_fx(game)
  clear_rings(game)
  clear_shadows(game)
  reset_player(game.hero)

  game.state = state_title
  game.stage = 1
  game.distance = 0.0
  game.stage_goal = stage_goal_base
  game.score = 0
  game.loot = 0
  game.kills = 0
  game.combo = 0
  game.combo_t = 0.0
  game.armor = armor_max
  game.heat = heat_max

  game.fire_cd = 0.0
  game.dash_cd = 0.0
  game.dash_t = 0.0
  game.hook_cd = 0.0
  game.hook_t = 0.0

  game.time_s = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  game.scroll = base_scroll
  game.next_spawn_x = spawn_start_x
}

///|
fn start_run(game : Game) -> Unit {
  start_stage(game, 1)
}

///|
fn spawn_pack(game : Game, x : Float) -> Unit {
  let c = 1 + randi(0, 2)

  for _i = 0; _i < c; _i = _i + 1 {
    let lane = randi(0, lane_count - 1)
    let roll = randi(0, 99)

    if roll < 30 {
      spawn_ent(
        game,
        ent_guard,
        lane,
        x + randf(-16.0, 18.0),
        randf(-70.0, -30.0),
        0.0,
        42.0,
        70.0,
        16.0 + Float::from_int(game.stage - 1) * 3.0,
        randf(0.42, 1.24),
        false,
        120,
      )
    } else if roll < 52 {
      spawn_ent(
        game,
        ent_drone,
        lane,
        x + randf(-20.0, 20.0),
        randf(-40.0, 20.0),
        randf(-40.0, 40.0),
        40.0,
        34.0,
        12.0 + Float::from_int(game.stage - 1) * 2.0,
        randf(0.28, 0.94),
        game.stage >= 3 && chance(26),
        108,
      )
    } else if roll < 66 {
      spawn_ent(
        game,
        ent_turret,
        lane,
        x + randf(-10.0, 10.0),
        randf(-20.0, 10.0),
        0.0,
        56.0,
        48.0,
        22.0 + Float::from_int(game.stage - 1) * 4.0,
        randf(0.62, 1.6),
        false,
        136,
      )
    } else if roll < 78 {
      spawn_ent(
        game,
        ent_crate,
        lane,
        x + randf(-16.0, 16.0),
        randf(-20.0, 10.0),
        0.0,
        56.0,
        56.0,
        30.0 + Float::from_int(game.stage - 1) * 5.0,
        99.0,
        false,
        150,
      )
    } else if roll < 88 {
      spawn_ent(
        game,
        ent_medkit,
        lane,
        x + randf(-20.0, 20.0),
        randf(-20.0, 20.0),
        0.0,
        34.0,
        34.0,
        1.0,
        99.0,
        false,
        0,
      )
    } else if roll < 96 {
      spawn_ent(
        game,
        ent_battery,
        lane,
        x + randf(-20.0, 20.0),
        randf(-20.0, 20.0),
        0.0,
        34.0,
        34.0,
        1.0,
        99.0,
        false,
        0,
      )
    } else {
      spawn_ent(
        game,
        ent_signal,
        lane,
        x + randf(-20.0, 20.0),
        randf(-20.0, 20.0),
        0.0,
        34.0,
        34.0,
        1.0,
        99.0,
        false,
        0,
      )
    }
  }
}

///|
fn spawn_step(game : Game, dt : Float) -> Unit {
  game.next_spawn_x = game.next_spawn_x - game.scroll * dt

  let mut n = 0
  while game.next_spawn_x < Float::from_int(screen_w) + 140.0 && n < 18 {
    spawn_pack(game, game.next_spawn_x)
    game.next_spawn_x = game.next_spawn_x + randf(spawn_gap_min, spawn_gap_max)
    n = n + 1
  }
}

///|
fn apply_hook(game : Game) -> Unit {
  game.hook_cd = hook_cd_time
  game.hook_t = hook_time

  spawn_ring(game, game.hero.x, game.hero.y, 16.0, 0.9, 2)
  burst(game, game.hero.x, game.hero.y, 24, 2)

  let rr2 = hook_radius * hook_radius
  let kill2 = hook_kill_radius * hook_kill_radius

  for i = 0; i < game.ents.length(); i = i + 1 {
    if not(game.ents[i].active) {
      continue
    }

    let d2 = dist2(game.hero.x, game.hero.y, game.ents[i].x, game.ents[i].y)
    if d2 > rr2 {
      continue
    }

    game.ents[i].cloak = false

    if is_hostile(game.ents[i].kind) && d2 <= kill2 {
      let kind = game.ents[i].kind
      let x = game.ents[i].x
      let y = game.ents[i].y
      game.ents[i].active = false
      add_score(game, if kind == ent_crate { 150 } else { 88 })
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
      emit_fx(
        game,
        game.shots[i].x,
        game.shots[i].y,
        randf(-90.0, 90.0),
        randf(-90.0, 90.0),
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
  let vy0 : Float = if game.hero.grounded { 0.0 } else { game.hero.vy * 0.2 }

  spawn_shot(
    game,
    true,
    game.hero.x + game.hero.w * 0.44,
    game.hero.y - game.hero.h * 0.16,
    shot_speed,
    vy0 + randf(-spread, spread),
    shot_life,
    8.0,
    0,
  )

  if game.stage >= 4 && chance(26) {
    spawn_shot(
      game,
      true,
      game.hero.x + game.hero.w * 0.4,
      game.hero.y - game.hero.h * 0.28,
      shot_speed * 1.06,
      vy0 + randf(-6.0, 6.0),
      shot_life,
      6.0,
      1,
    )
  }

  game.hero.muzzle_t = 0.12
}

///|
fn apply_jump(game : Game) -> Unit {
  game.hero.vy = -jump_speed
  game.hero.grounded = false
  game.hero.coyote_t = 0.0
  game.hero.jump_buf_t = 0.0

  emit_fx(
    game,
    game.hero.x,
    game.hero.y + game.hero.h * 0.44,
    randf(-120.0, 120.0),
    randf(-60.0, -20.0),
    randf(0.2, 0.42),
    randf(1.2, 3.4),
    2,
  )
}

///|
fn update_player(game : Game, dt : Float) -> Unit {
  if game.input_jump_press {
    game.hero.jump_buf_t = 0.16
  }

  if game.input_dash_press && game.dash_cd <= 0.0 && game.heat >= 14.0 {
    game.dash_t = dash_time
    game.dash_cd = dash_cd_time
    game.heat = maxf(0.0, game.heat - 12.0)
    game.hero.invuln = maxf(game.hero.invuln, 0.22)

    let dir : Float = if game.input_x < -0.1 {
      -1.0
    } else if game.input_x > 0.1 {
      1.0
    } else {
      1.0
    }

    game.hero.vx = dir * dash_speed
    game.hero.vy = minf(game.hero.vy, 0.0)

    spawn_ring(game, game.hero.x, game.hero.y, 18.0, 0.58, 0)
    burst(game, game.hero.x, game.hero.y, 16, 0)
  }

  if game.input_hook_press && game.hook_cd <= 0.0 && game.heat >= 18.0 {
    game.heat = maxf(0.0, game.heat - 18.0)
    apply_hook(game)
  }

  if game.input_fire_hold && game.fire_cd <= 0.0 {
    shoot_player(game)
    game.fire_cd = if game.dash_t > 0.0 {
      fire_cd_base * 0.62
    } else {
      fire_cd_base
    }
  }

  game.hero.vx = game.hero.vx + game.input_x * player_accel_x * dt

  let drag = clampf(1.0 - player_drag_x * dt, 0.0, 1.0)
  game.hero.vx = game.hero.vx * drag
  game.hero.vx = clampf(game.hero.vx, -player_max_vx, player_max_vx)

  if game.hero.grounded {
    game.hero.coyote_t = 0.12
  } else {
    game.hero.coyote_t = maxf(0.0, game.hero.coyote_t - dt)
  }

  if game.hero.jump_buf_t > 0.0 {
    game.hero.jump_buf_t = game.hero.jump_buf_t - dt
  }

  if game.hero.jump_buf_t > 0.0 &&
    (game.hero.grounded || game.hero.coyote_t > 0.0) {
    apply_jump(game)
  }

  game.hero.vy = minf(fall_max, game.hero.vy + gravity * dt)

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  let left_bound : Float = 80.0
  let right_bound = Float::from_int(screen_w) - 80.0
  game.hero.x = clampf(game.hero.x, left_bound, right_bound)

  if game.hero.y >= game.hero.ground_y {
    if not(game.hero.grounded) && game.hero.vy > 140.0 {
      burst(game, game.hero.x, game.hero.ground_y + 24.0, 10, 2)
    }

    game.hero.y = game.hero.ground_y
    game.hero.vy = 0.0
    game.hero.grounded = true
  } else {
    game.hero.grounded = false
  }

  if game.dash_t > 0.0 {
    emit_shadow(
      game,
      game.hero.x,
      game.hero.y,
      game.hero.w,
      game.hero.h,
      game.hero.heading,
      randf(0.14, 0.26),
      1,
    )
  }

  game.hero.heading = clampf(game.hero.vx / player_max_vx * 20.0, -20.0, 20.0)
}

///|
fn enemy_fire(game : Game, e : Ent) -> Unit {
  if e.kind == ent_guard {
    spawn_shot(
      game,
      false,
      e.x - e.w * 0.4,
      e.y - e.h * 0.16,
      -enemy_shot_speed,
      randf(-80.0, 80.0),
      2.2,
      9.0,
      0,
    )
  } else if e.kind == ent_drone {
    let dx = game.hero.x - e.x
    let dy = game.hero.y - e.y
    let n2 = maxf(dx * dx + dy * dy, 1.0)
    let inv : Float = Float::from_int(1) / sqrtf(n2)
    spawn_shot(
      game,
      false,
      e.x,
      e.y,
      dx * inv * enemy_shot_speed,
      dy * inv * enemy_shot_speed,
      2.4,
      11.0,
      1,
    )
  } else if e.kind == ent_turret {
    spawn_shot(
      game,
      false,
      e.x - 10.0,
      e.y - e.h * 0.32,
      -enemy_shot_speed * 0.9,
      -40.0,
      2.4,
      12.0,
      2,
    )
    spawn_shot(
      game,
      false,
      e.x - 10.0,
      e.y - e.h * 0.12,
      -enemy_shot_speed * 0.9,
      40.0,
      2.4,
      12.0,
      2,
    )
  }
}

///|
fn kill_ent(game : Game, i : Int, base : Int, burst_kind : Int) -> Unit {
  let x = game.ents[i].x
  let y = game.ents[i].y
  game.ents[i].active = false
  add_score(game, base)
  push_combo(game)
  game.kills = game.kills + 1
  burst(game, x, y, 16 + randi(0, 8), burst_kind)
  spawn_ring(game, x, y, 10.0, 0.56, burst_kind)
}

///|
fn collect_pickup(game : Game, kind : Int) -> Unit {
  if kind == ent_medkit {
    game.armor = minf(armor_max, game.armor + 18.0)
    add_score(game, 44)
  } else if kind == ent_battery {
    game.heat = minf(heat_max, game.heat + heat_pickup)
    add_score(game, 40)
  } else {
    game.hook_cd = maxf(0.0, game.hook_cd - 1.1)
    game.heat = minf(heat_max, game.heat + 12.0)
    game.loot = game.loot + 1
    add_score(game, 84)
    push_combo(game)
  }
}

///|
fn update_ents(game : Game, dt : Float) -> Unit {
  let dash_hit = game.dash_t > 0.0

  for i = 0; i < game.ents.length(); i = i + 1 {
    if not(game.ents[i].active) {
      continue
    }

    game.ents[i].x = game.ents[i].x + (game.ents[i].vx - game.scroll) * dt
    game.ents[i].y = game.ents[i].y + game.ents[i].vy * dt
    game.ents[i].spin = game.ents[i].spin + dt * 1.9
    game.ents[i].shot_cd = game.ents[i].shot_cd - dt

    if game.ents[i].kind == ent_guard {
      game.ents[i].x = game.ents[i].x +
        sinf(game.ents[i].spin * 2.4) * 22.0 * dt
    } else if game.ents[i].kind == ent_drone {
      game.ents[i].y = lane_y(game.ents[i].lane) +
        sinf(game.ents[i].spin * 3.0) * 22.0
    } else if game.ents[i].kind == ent_turret {
      game.ents[i].y = lane_y(game.ents[i].lane) - 6.0
    } else if game.ents[i].kind == ent_crate {
      game.ents[i].w = 52.0 + sinf(game.ents[i].spin * 2.0) * 4.0
      game.ents[i].h = 52.0 + sinf(game.ents[i].spin * 2.6) * 4.0
    }

    if game.ents[i].x < -220.0 {
      game.ents[i].active = false
      continue
    }

    if is_hostile(game.ents[i].kind) &&
      game.ents[i].shot_cd <= 0.0 &&
      game.ents[i].x < Float::from_int(screen_w) - 20.0 {
      enemy_fire(game, game.ents[i])
      game.ents[i].shot_cd = if game.ents[i].kind == ent_guard {
        randf(0.74, 1.42)
      } else if game.ents[i].kind == ent_drone {
        randf(0.44, 1.02)
      } else if game.ents[i].kind == ent_turret {
        randf(0.92, 1.72)
      } else {
        randf(1.1, 1.8)
      }
    }

    let d2 = dist2(game.hero.x, game.hero.y, game.ents[i].x, game.ents[i].y)
    let rr = player_hit_r(game.hero) + ent_hit_r(game.ents[i])

    if d2 <= rr * rr {
      let kind = game.ents[i].kind
      if is_pickup(kind) {
        game.ents[i].active = false
        collect_pickup(game, kind)
        burst(game, game.hero.x, game.hero.y, 9, 2)
      } else if dash_hit {
        kill_ent(game, i, game.ents[i].reward, 0)
      } else {
        let dmg : Float = if kind == ent_crate {
          20.0
        } else if kind == ent_turret {
          16.0
        } else {
          13.0
        }
        hurt_player(game, dmg)
        if kind != ent_crate {
          game.ents[i].active = false
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
    game.shots[i].y = game.shots[i].y + game.shots[i].vy * dt
    game.shots[i].life = game.shots[i].life - dt

    let dead = game.shots[i].life <= 0.0 ||
      game.shots[i].x < -120.0 ||
      game.shots[i].x > Float::from_int(screen_w) + 120.0 ||
      game.shots[i].y < Float::from_int(hud_h) - 120.0 ||
      game.shots[i].y > Float::from_int(screen_h) + 120.0

    if dead {
      game.shots[i].active = false
      continue
    }

    if game.shots[i].from_player {
      let mut hit = false

      for j = 0; j < game.ents.length(); j = j + 1 {
        if not(game.ents[j].active) || is_pickup(game.ents[j].kind) {
          continue
        }

        let d2 = dist2(
          game.shots[i].x,
          game.shots[i].y,
          game.ents[j].x,
          game.ents[j].y,
        )
        let rr = ent_hit_r(game.ents[j]) + 8.0
        if d2 <= rr * rr {
          game.ents[j].hp = game.ents[j].hp - game.shots[i].dmg
          game.shots[i].active = false
          hit = true

          emit_fx(
            game,
            game.ents[j].x,
            game.ents[j].y,
            randf(-90.0, 90.0),
            randf(-90.0, 90.0),
            randf(0.18, 0.42),
            randf(1.0, 3.2),
            0,
          )

          if game.ents[j].hp <= 0.0 {
            kill_ent(game, j, game.ents[j].reward, 0)
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
  for i = 0; i < game.fxs.length(); i = i + 1 {
    if not(game.fxs[i].active) {
      continue
    }

    game.fxs[i].x = game.fxs[i].x + (game.fxs[i].vx - game.scroll * 0.2) * dt
    game.fxs[i].y = game.fxs[i].y + game.fxs[i].vy * dt
    game.fxs[i].life = game.fxs[i].life - dt

    if game.fxs[i].life <= 0.0 {
      game.fxs[i].active = false
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

  for i = 0; i < game.shadows.length(); i = i + 1 {
    if not(game.shadows[i].active) {
      continue
    }

    game.shadows[i].x = game.shadows[i].x - game.scroll * 0.28 * dt
    game.shadows[i].life = game.shadows[i].life - dt
    if game.shadows[i].life <= 0.0 {
      game.shadows[i].active = false
    }
  }
}

///|
fn emit_snow(game : Game, dt : Float) -> Unit {
  let tries = clampi((dt * 230.0).to_int(), 1, 10)
  let mut i = 0
  while i < tries {
    if chance(38) {
      emit_fx(
        game,
        Float::from_int(screen_w) + randf(0.0, 30.0),
        randf(Float::from_int(hud_h), Float::from_int(screen_h) + 16.0),
        randf(-100.0, -40.0),
        randf(-20.0, 20.0),
        randf(0.6, 1.4),
        randf(0.8, 2.2),
        3,
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
  game.hero.anim_t = game.hero.anim_t + dt

  game.fire_cd = maxf(0.0, game.fire_cd - dt)
  game.dash_cd = maxf(0.0, game.dash_cd - dt)
  game.dash_t = maxf(0.0, game.dash_t - dt)
  game.hook_cd = maxf(0.0, game.hook_cd - dt)
  game.hook_t = maxf(0.0, game.hook_t - dt)

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
    minf(68.0, game.distance * 0.006)
  game.distance = game.distance + game.scroll * dt

  update_player(game, dt)

  spawn_step(game, dt)
  update_ents(game, dt)
  update_shots(game, dt)
  update_fx(game, dt)

  game.heat = maxf(
    0.0,
    game.heat -
    heat_drain_base * dt -
    absf(game.hero.vx) / player_max_vx * 1.1 * dt,
  )

  if game.dash_t > 0.0 {
    game.heat = maxf(0.0, game.heat - heat_drain_dash * dt)
  }

  game.armor = maxf(0.0, game.armor - armor_passive * dt)

  emit_snow(game, dt)

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
  game.scroll = 86.0
  game.distance = game.distance + game.scroll * dt * 0.7

  emit_snow(game, dt)
  update_fx(game, dt)

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll = maxf(88.0, game.scroll - 140.0 * dt)

  update_fx(game, dt)
  emit_snow(game, dt)

  if chance(24) {
    emit_fx(
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
  emit_snow(game, dt)

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
