///|
fn clear_objs(game : Game) -> Unit {
  for i = 0; i < game.objs.length(); i = i + 1 {
    game.objs[i].active = false
    game.objs[i].kind = obj_lantern
    game.objs[i].x = 0.0
    game.objs[i].y = 0.0
    game.objs[i].vx = 0.0
    game.objs[i].vy = 0.0
    game.objs[i].w = 0.0
    game.objs[i].h = 0.0
    game.objs[i].hp = 0.0
    game.objs[i].life = 0.0
    game.objs[i].phase = 0.0
    game.objs[i].value = 0
    game.objs[i].flagged = false
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
fn clear_halos(game : Game) -> Unit {
  for i = 0; i < game.halos.length(); i = i + 1 {
    game.halos[i].active = false
    game.halos[i].x = 0.0
    game.halos[i].y = 0.0
    game.halos[i].r = 0.0
    game.halos[i].life = 0.0
    game.halos[i].kind = 0
  }
}

///|
fn clear_trails(game : Game) -> Unit {
  for i = 0; i < game.trails.length(); i = i + 1 {
    game.trails[i].active = false
    game.trails[i].x = 0.0
    game.trails[i].y = 0.0
    game.trails[i].life = 0.0
    game.trails[i].w = 0.0
    game.trails[i].h = 0.0
    game.trails[i].rot = 0.0
  }
}

///|
fn reset_kite(game : Game) -> Unit {
  game.kite.x = Float::from_int(screen_w) * 0.5
  game.kite.y = Float::from_int(screen_h) * 0.54
  game.kite.vx = 0.0
  game.kite.vy = 0.0
  game.kite.w = kite_w
  game.kite.h = kite_h
  game.kite.angle = 0.0
  game.kite.invuln = 0.0
  game.kite.hurt_t = 0.0
  game.kite.burst_glow = 0.0
  game.kite.reel_glow = 0.0
  game.kite.anim_t = 0.0

  game.rope_len = kite_rope_len_max
}

///|
fn alloc_obj(game : Game) -> Int {
  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.objs[0].life
  for i = 1; i < game.objs.length(); i = i + 1 {
    if game.objs[i].life < best_life {
      best_life = game.objs[i].life
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
fn alloc_halo(game : Game) -> Int {
  for i = 0; i < game.halos.length(); i = i + 1 {
    if not(game.halos[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.halos[0].life
  for i = 1; i < game.halos.length(); i = i + 1 {
    if game.halos[i].life < best_life {
      best_life = game.halos[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_trail(game : Game) -> Int {
  for i = 0; i < game.trails.length(); i = i + 1 {
    if not(game.trails[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.trails[0].life
  for i = 1; i < game.trails.length(); i = i + 1 {
    if game.trails[i].life < best_life {
      best_life = game.trails[i].life
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
fn burst_sparks(game : Game, x : Float, y : Float, n : Int, kind : Int) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    emit_spark(
      game,
      x + randf(-16.0, 16.0),
      y + randf(-16.0, 16.0),
      randf(-240.0, 240.0),
      randf(-240.0, 240.0),
      randf(0.26, 1.1),
      randf(1.2, 5.0),
      kind,
    )
  }
}

///|
fn spawn_halo(
  game : Game,
  x : Float,
  y : Float,
  r : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = alloc_halo(game)
  game.halos[i].active = true
  game.halos[i].x = x
  game.halos[i].y = y
  game.halos[i].r = r
  game.halos[i].life = life
  game.halos[i].kind = kind
}

///|
fn spawn_trail(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  rot : Float,
) -> Unit {
  let i = alloc_trail(game)
  game.trails[i].active = true
  game.trails[i].x = x
  game.trails[i].y = y
  game.trails[i].life = randf(0.12, 0.36)
  game.trails[i].w = w
  game.trails[i].h = h
  game.trails[i].rot = rot
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
  life : Float,
  value : Int,
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
  game.objs[i].life = life
  game.objs[i].phase = randf(0.0, 6.283)
  game.objs[i].value = value
  game.objs[i].flagged = false
}

///|
fn is_hostile(kind : Int) -> Bool {
  kind == obj_bird || kind == obj_storm
}

///|
fn is_collectible(kind : Int) -> Bool {
  kind == obj_lantern || kind == obj_orb || kind == obj_koi
}

///|
fn obj_hit_r(o : SkyObj) -> Float {
  maxf(o.w, o.h) * 0.34
}

///|
fn kite_hit_r(k : Kite) -> Float {
  maxf(k.w, k.h) * 0.32
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
  game.combo = clampi(game.combo + 1, 0, 30)
  game.combo_t = 4.0
}

///|
fn clear_combo(game : Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
fn kite_anchor_x(game : Game) -> Float {
  Float::from_int(screen_w) * 0.5 + sinf(game.time_s * 0.42) * 120.0
}

///|
fn kite_anchor_y() -> Float {
  Float::from_int(screen_h) - 10.0
}

///|
fn hurt_kite(game : Game, dmg : Float) -> Unit {
  if game.kite.invuln > 0.0 {
    return
  }

  game.calm = maxf(0.0, game.calm - dmg)
  game.kite.invuln = 0.66
  game.kite.hurt_t = 0.62
  game.flash_t = maxf(game.flash_t, 0.36)
  game.shake_t = maxf(game.shake_t, 0.66)
  game.hits = game.hits + 1
  clear_combo(game)

  burst_sparks(game, game.kite.x, game.kite.y, 24, 1)
  spawn_halo(game, game.kite.x, game.kite.y, 12.0, 0.52, 1)

  if game.calm <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }
}

///|
fn init_title_scene(game : Game) -> Unit {
  clear_objs(game)
  clear_sparks(game)
  clear_halos(game)
  clear_trails(game)
  reset_kite(game)

  game.state = state_title
  game.stage = 1
  game.stage_goal = stage_goal_base
  game.score = 0
  game.rescued = 0
  game.hits = 0

  game.time_left = stage_time_base
  game.calm = calm_max
  game.energy = energy_max

  game.wind_power = wind_base
  game.wind_x = wind_base
  game.wind_y = -12.0
  game.gust_t = 1.2
  game.gust_phase = 0.0

  game.burst_cd = 0.0
  game.burst_t = 0.0
  game.spawn_t = 0.6
  game.wave_t = 0.0
  game.combo = 0
  game.combo_t = 0.0

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0
  game.time_s = 0.0
}

///|
fn start_stage(game : Game, stage : Int) -> Unit {
  clear_objs(game)
  clear_sparks(game)
  clear_halos(game)
  clear_trails(game)
  reset_kite(game)

  game.state = state_play
  game.stage = stage
  game.stage_goal = stage_goal_base + (stage - 1) * stage_goal_bonus

  game.time_left = stage_time_base +
    Float::from_int(stage - 1) * stage_time_bonus
  game.calm = minf(calm_max, game.calm + 24.0)
  game.energy = minf(energy_max, game.energy + 30.0)

  game.wind_power = wind_base + Float::from_int(stage - 1) * wind_stage_bonus
  game.wind_x = game.wind_power * 0.65
  game.wind_y = -8.0
  game.gust_t = 0.9
  game.gust_phase = randf(0.0, 6.283)

  game.burst_cd = 0.0
  game.burst_t = 0.0
  game.spawn_t = 0.45
  game.wave_t = 0.0
  clear_combo(game)

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  spawn_halo(game, game.kite.x, game.kite.y, 18.0, 0.66, 0)
  burst_sparks(game, game.kite.x, game.kite.y, 30, 0)
}

///|
fn start_run(game : Game) -> Unit {
  game.score = 0
  game.rescued = 0
  game.hits = 0
  game.calm = calm_max
  game.energy = energy_max
  start_stage(game, 1)
}

///|
fn spawn_lantern(game : Game) -> Unit {
  spawn_obj(
    game,
    obj_lantern,
    randf(play_left + 40.0, play_right - 40.0),
    play_top - randf(20.0, 120.0),
    randf(-20.0, 20.0),
    randf(40.0, 90.0),
    randf(26.0, 42.0),
    randf(30.0, 44.0),
    1.0,
    randf(8.0, 14.0),
    120 + game.stage * 12,
  )
}

///|
fn spawn_bird(game : Game) -> Unit {
  let side = if chance(50) { 0 } else { 1 }
  let sx = if side == 0 { play_left - 80.0 } else { play_right + 80.0 }
  let tx = if side == 0 { randf(120.0, 340.0) } else { randf(-340.0, -120.0) }

  spawn_obj(
    game,
    obj_bird,
    sx,
    randf(play_top + 36.0, play_bottom - 120.0),
    tx,
    randf(-30.0, 30.0),
    randf(44.0, 58.0),
    randf(34.0, 46.0),
    16.0 + Float::from_int(game.stage - 1) * 4.0,
    randf(7.0, 11.0),
    180,
  )
}

///|
fn spawn_storm(game : Game) -> Unit {
  spawn_obj(
    game,
    obj_storm,
    randf(play_left + 80.0, play_right - 80.0),
    play_top - randf(60.0, 140.0),
    randf(-40.0, 40.0),
    randf(28.0, 56.0),
    randf(70.0, 120.0),
    randf(46.0, 72.0),
    28.0 + Float::from_int(game.stage - 1) * 6.0,
    randf(8.0, 14.0),
    240,
  )
}

///|
fn spawn_orb(game : Game) -> Unit {
  spawn_obj(
    game,
    obj_orb,
    randf(play_left + 30.0, play_right - 30.0),
    play_top - randf(20.0, 100.0),
    randf(-30.0, 30.0),
    randf(36.0, 74.0),
    randf(30.0, 42.0),
    randf(30.0, 42.0),
    1.0,
    randf(8.0, 12.0),
    100,
  )
}

///|
fn spawn_koi(game : Game) -> Unit {
  let side = if chance(50) { 0 } else { 1 }
  let sx = if side == 0 { play_left - 120.0 } else { play_right + 120.0 }
  let vx = if side == 0 { randf(180.0, 320.0) } else { randf(-320.0, -180.0) }

  spawn_obj(
    game,
    obj_koi,
    sx,
    randf(play_top + 50.0, play_bottom - 90.0),
    vx,
    randf(-40.0, 40.0),
    randf(52.0, 70.0),
    randf(30.0, 40.0),
    1.0,
    randf(4.0, 8.0),
    340,
  )
}

///|
fn spawn_wave(game : Game) -> Unit {
  let count = 1 + randi(0, 2)

  for _i = 0; _i < count; _i = _i + 1 {
    let roll = randi(0, 99)
    if roll < 42 {
      spawn_lantern(game)
    } else if roll < 66 {
      spawn_bird(game)
    } else if roll < 82 {
      spawn_storm(game)
    } else if roll < 94 {
      spawn_orb(game)
    } else {
      spawn_koi(game)
    }
  }

  if chance(20 + game.stage * 4) {
    spawn_lantern(game)
  }
}

///|
fn spawn_step(game : Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt

  if game.spawn_t <= 0.0 {
    spawn_wave(game)
    let base = maxf(0.26, 1.06 - Float::from_int(game.stage - 1) * 0.08)
    game.spawn_t = base + randf(0.0, 0.52)
  }
}

///|
fn update_wind(game : Game, dt : Float) -> Unit {
  game.gust_t = game.gust_t - dt
  game.gust_phase = game.gust_phase + dt

  if game.gust_t <= 0.0 {
    game.gust_t = randf(0.7, 2.2)
    let angle = randf(-2.2, 2.2)
    game.wind_power = wind_base +
      Float::from_int(game.stage - 1) * wind_stage_bonus +
      randf(-20.0, 26.0)
    game.wind_x = cosf(angle) * game.wind_power
    game.wind_y = sinf(angle) * game.wind_power * 0.56 - 6.0
  }

  let wave = sinf(game.gust_phase * 3.2)
  game.wind_x = game.wind_x + wave * 8.0 * dt
  game.wind_y = game.wind_y + cosf(game.gust_phase * 2.6) * 6.0 * dt
}

///|
fn apply_burst(game : Game) -> Unit {
  game.burst_cd = burst_cd_time
  game.burst_t = 0.28
  game.energy = maxf(0.0, game.energy - burst_cost)
  game.kite.burst_glow = 0.46

  spawn_halo(game, game.kite.x, game.kite.y, 16.0, 0.8, 2)
  burst_sparks(game, game.kite.x, game.kite.y, 40, 2)

  let rr2 = burst_radius * burst_radius
  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      continue
    }

    let d2 = dist2(game.kite.x, game.kite.y, game.objs[i].x, game.objs[i].y)
    if d2 > rr2 {
      continue
    }

    if game.objs[i].kind == obj_bird {
      game.objs[i].hp = game.objs[i].hp - 30.0
      if game.objs[i].hp <= 0.0 {
        let x = game.objs[i].x
        let y = game.objs[i].y
        game.objs[i].active = false
        add_score(game, 150)
        push_combo(game)
        burst_sparks(game, x, y, 18, 0)
      }
    } else if game.objs[i].kind == obj_storm {
      game.objs[i].hp = game.objs[i].hp - 26.0
      if game.objs[i].hp <= 0.0 {
        let x = game.objs[i].x
        let y = game.objs[i].y
        game.objs[i].active = false
        add_score(game, 220)
        push_combo(game)
        burst_sparks(game, x, y, 28, 2)
      }
    }
  }
}

///|
fn update_kite(game : Game, dt : Float) -> Unit {
  if game.input_burst_press && game.burst_cd <= 0.0 && game.energy >= burst_cost {
    apply_burst(game)
  }

  let ax = game.input_x * kite_accel + game.wind_x * 0.85
  let ay = game.input_y * kite_accel + game.wind_y * 0.85

  game.kite.vx = game.kite.vx + ax * dt
  game.kite.vy = game.kite.vy + ay * dt

  let drag = clampf(1.0 - kite_drag * dt, 0.0, 1.0)
  game.kite.vx = game.kite.vx * drag
  game.kite.vy = game.kite.vy * drag

  game.kite.vx = clampf(game.kite.vx, -kite_max_speed, kite_max_speed)
  game.kite.vy = clampf(game.kite.vy, -kite_max_speed, kite_max_speed)

  game.kite.x = game.kite.x + game.kite.vx * dt
  game.kite.y = game.kite.y + game.kite.vy * dt

  let anchor_x = kite_anchor_x(game)
  let anchor_y = kite_anchor_y()

  if game.input_reel_hold && game.energy > 0.0 {
    game.rope_len = maxf(kite_rope_len_min, game.rope_len - reel_rate * dt)
    game.energy = maxf(0.0, game.energy - reel_energy_cost * dt)
    game.kite.reel_glow = maxf(game.kite.reel_glow, 0.24)
  } else {
    game.rope_len = minf(
      kite_rope_len_max,
      game.rope_len + rope_recover_rate * dt,
    )
  }

  let dx = game.kite.x - anchor_x
  let dy = game.kite.y - anchor_y
  let d2 = maxf(1.0, dx * dx + dy * dy)
  let d = sqrtf(d2)

  if d > game.rope_len {
    let nx = dx / d
    let ny = dy / d
    let over = d - game.rope_len

    game.kite.vx = game.kite.vx - nx * over * kite_rope_spring * dt
    game.kite.vy = game.kite.vy - ny * over * kite_rope_spring * dt

    game.kite.x = anchor_x + nx * game.rope_len
    game.kite.y = anchor_y + ny * game.rope_len

    game.kite.vx = game.kite.vx * kite_rope_damp
    game.kite.vy = game.kite.vy * kite_rope_damp
  }

  game.kite.x = clampf(game.kite.x, play_left, play_right)
  game.kite.y = clampf(game.kite.y, play_top, play_bottom)

  game.kite.angle = clampf(game.kite.vx / kite_max_speed * 38.0, -38.0, 38.0)
  game.kite.anim_t = game.kite.anim_t + dt

  spawn_trail(
    game,
    game.kite.x,
    game.kite.y,
    game.kite.w * randf(0.3, 0.7),
    game.kite.h * randf(0.2, 0.5),
    game.kite.angle,
  )
}

///|
fn collect_obj(game : Game, kind : Int, value : Int) -> Unit {
  if kind == obj_lantern {
    add_score(game, value)
    game.time_left = minf(
      stage_time_base + Float::from_int(game.stage) * stage_time_bonus,
      game.time_left + 1.8,
    )
    game.rescued = game.rescued + 1
    push_combo(game)
  } else if kind == obj_orb {
    add_score(game, value)
    game.energy = minf(energy_max, game.energy + 28.0)
    game.calm = minf(calm_max, game.calm + 10.0)
    burst_sparks(game, game.kite.x, game.kite.y, 10, 2)
  } else {
    add_score(game, value)
    game.energy = minf(energy_max, game.energy + 18.0)
    game.calm = minf(calm_max, game.calm + 18.0)
    game.time_left = game.time_left + 3.0
    game.rescued = game.rescued + 2
    push_combo(game)
  }
}

///|
fn update_objs(game : Game, dt : Float) -> Unit {
  let kite_rr = kite_hit_r(game.kite)

  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      continue
    }

    game.objs[i].life = game.objs[i].life - dt
    game.objs[i].phase = game.objs[i].phase + dt
    game.objs[i].flagged = game.objs[i].life < 1.2

    if game.objs[i].kind == obj_lantern {
      game.objs[i].x = game.objs[i].x +
        (game.objs[i].vx + game.wind_x * 0.4) * dt
      game.objs[i].y = game.objs[i].y +
        (game.objs[i].vy + game.wind_y * 0.5) * dt
      game.objs[i].y = game.objs[i].y +
        sinf(game.objs[i].phase * 4.2) * 10.0 * dt
    } else if game.objs[i].kind == obj_bird {
      let tx = game.kite.x - game.objs[i].x
      let ty = game.kite.y - game.objs[i].y
      let d2 = maxf(20.0, tx * tx + ty * ty)
      let inv = Float::from_int(1) / sqrtf(d2)
      game.objs[i].vx = game.objs[i].vx + tx * inv * 90.0 * dt
      game.objs[i].vy = game.objs[i].vy + ty * inv * 90.0 * dt
      game.objs[i].vx = clampf(game.objs[i].vx, -320.0, 320.0)
      game.objs[i].vy = clampf(game.objs[i].vy, -280.0, 280.0)
      game.objs[i].x = game.objs[i].x +
        (game.objs[i].vx + game.wind_x * 0.2) * dt
      game.objs[i].y = game.objs[i].y +
        (game.objs[i].vy + game.wind_y * 0.2) * dt
    } else if game.objs[i].kind == obj_storm {
      game.objs[i].x = game.objs[i].x +
        (game.objs[i].vx + game.wind_x * 0.6) * dt
      game.objs[i].y = game.objs[i].y +
        (game.objs[i].vy + game.wind_y * 0.4) * dt
      game.objs[i].w = maxf(
        52.0,
        game.objs[i].w + sinf(game.objs[i].phase * 3.0) * 12.0 * dt,
      )
      game.objs[i].h = maxf(
        36.0,
        game.objs[i].h + cosf(game.objs[i].phase * 2.4) * 9.0 * dt,
      )

      if chance(14) {
        emit_spark(
          game,
          game.objs[i].x + randf(-game.objs[i].w * 0.4, game.objs[i].w * 0.4),
          game.objs[i].y + randf(-game.objs[i].h * 0.3, game.objs[i].h * 0.3),
          randf(-60.0, 60.0),
          randf(30.0, 180.0),
          randf(0.12, 0.3),
          randf(1.0, 2.6),
          2,
        )
      }
    } else if game.objs[i].kind == obj_orb {
      game.objs[i].x = game.objs[i].x +
        (game.objs[i].vx + game.wind_x * 0.48) * dt
      game.objs[i].y = game.objs[i].y +
        (game.objs[i].vy + game.wind_y * 0.48) * dt
      game.objs[i].x = game.objs[i].x +
        sinf(game.objs[i].phase * 6.0) * 26.0 * dt
    } else {
      game.objs[i].x = game.objs[i].x +
        (game.objs[i].vx + game.wind_x * 0.3) * dt
      game.objs[i].y = game.objs[i].y +
        (game.objs[i].vy + game.wind_y * 0.2) * dt
      game.objs[i].y = game.objs[i].y +
        sinf(game.objs[i].phase * 8.0) * 18.0 * dt
    }

    if game.objs[i].life <= 0.0 ||
      game.objs[i].x < play_left - 260.0 ||
      game.objs[i].x > play_right + 260.0 ||
      game.objs[i].y < play_top - 260.0 ||
      game.objs[i].y > play_bottom + 260.0 {
      game.objs[i].active = false
      continue
    }

    let d2 = dist2(game.kite.x, game.kite.y, game.objs[i].x, game.objs[i].y)
    let rr = kite_rr + obj_hit_r(game.objs[i])

    if d2 <= rr * rr {
      if is_collectible(game.objs[i].kind) {
        let kind = game.objs[i].kind
        let value = game.objs[i].value
        game.objs[i].active = false
        collect_obj(game, kind, value)
        spawn_halo(game, game.kite.x, game.kite.y, 10.0, 0.36, 0)
        burst_sparks(game, game.kite.x, game.kite.y, 12, 0)
      } else {
        let dmg : Float = if game.objs[i].kind == obj_storm {
          18.0
        } else {
          12.0
        }
        hurt_kite(game, dmg)
        game.objs[i].hp = game.objs[i].hp - 18.0
        if game.objs[i].hp <= 0.0 {
          let x = game.objs[i].x
          let y = game.objs[i].y
          game.objs[i].active = false
          add_score(game, game.objs[i].value)
          burst_sparks(game, x, y, 16, 1)
        }
      }
    }
  }
}

///|
fn update_sparks(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    game.sparks[i].x = game.sparks[i].x +
      (game.sparks[i].vx + game.wind_x * 0.14) * dt
    game.sparks[i].y = game.sparks[i].y +
      (game.sparks[i].vy + game.wind_y * 0.14) * dt
    game.sparks[i].life = game.sparks[i].life - dt

    if game.sparks[i].kind == 3 {
      game.sparks[i].vy = game.sparks[i].vy + 14.0 * dt
    }

    if game.sparks[i].life <= 0.0 {
      game.sparks[i].active = false
    }
  }

  for i = 0; i < game.halos.length(); i = i + 1 {
    if not(game.halos[i].active) {
      continue
    }

    game.halos[i].life = game.halos[i].life - dt
    game.halos[i].r = game.halos[i].r +
      (120.0 + Float::from_int(game.halos[i].kind) * 44.0) * dt
    if game.halos[i].life <= 0.0 {
      game.halos[i].active = false
    }
  }

  for i = 0; i < game.trails.length(); i = i + 1 {
    if not(game.trails[i].active) {
      continue
    }

    game.trails[i].life = game.trails[i].life - dt
    if game.trails[i].life <= 0.0 {
      game.trails[i].active = false
    }
  }
}

///|
fn emit_snow(game : Game, dt : Float) -> Unit {
  let tries = clampi((dt * 260.0).to_int(), 1, 16)
  for _i = 0; _i < tries; _i = _i + 1 {
    if chance(34) {
      emit_spark(
        game,
        randf(play_left - 20.0, play_right + 20.0),
        play_top - randf(20.0, 120.0),
        game.wind_x * 0.4 + randf(-40.0, 20.0),
        randf(24.0, 90.0) + game.wind_y * 0.2,
        randf(0.8, 1.6),
        randf(0.8, 2.2),
        3,
      )
    }
  }
}

///|
fn update_timers(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt

  game.kite.invuln = maxf(0.0, game.kite.invuln - dt)
  game.kite.hurt_t = maxf(0.0, game.kite.hurt_t - dt)
  game.kite.burst_glow = maxf(0.0, game.kite.burst_glow - dt)
  game.kite.reel_glow = maxf(0.0, game.kite.reel_glow - dt)

  game.burst_cd = maxf(0.0, game.burst_cd - dt)
  game.burst_t = maxf(0.0, game.burst_t - dt)

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
  game.time_left = maxf(0.0, game.time_left - dt)

  game.calm = maxf(0.0, game.calm - calm_decay * dt)
  game.energy = minf(energy_max, game.energy + energy_regen * dt)

  update_wind(game, dt)
  update_kite(game, dt)
  spawn_step(game, dt)
  update_objs(game, dt)
  emit_snow(game, dt)
  update_sparks(game, dt)

  if absf(game.wind_x) > 220.0 {
    game.calm = maxf(0.0, game.calm - dt * 1.2)
  }

  if game.calm <= 0.0 || game.time_left <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }

  if game.state == state_play && game.score >= game.stage_goal {
    game.state = state_stage_clear
    game.result_t = 0.0
    add_score(game, 220 + game.stage * 90)
    game.energy = minf(energy_max, game.energy + 22.0)
    game.calm = minf(calm_max, game.calm + 16.0)
    spawn_halo(game, game.kite.x, game.kite.y, 18.0, 0.8, 2)
    burst_sparks(game, game.kite.x, game.kite.y, 30, 2)
  }
}

///|
fn update_title(game : Game, dt : Float) -> Unit {
  game.wave_t = game.wave_t + dt
  update_wind(game, dt)
  emit_snow(game, dt)
  update_sparks(game, dt)

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  emit_snow(game, dt)
  update_sparks(game, dt)

  if chance(32) {
    emit_spark(
      game,
      game.kite.x + randf(-30.0, 30.0),
      game.kite.y + randf(-30.0, 30.0),
      randf(-40.0, 40.0),
      randf(-80.0, -10.0),
      randf(0.3, 0.66),
      randf(1.4, 4.4),
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
  emit_snow(game, dt)
  update_sparks(game, dt)

  if game.input_restart_press {
    init_title_scene(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
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
