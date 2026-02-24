///|
fn clear_foes(game : Game) -> Unit {
  for i = 0; i < game.foes.length(); i = i + 1 {
    game.foes[i].active = false
    game.foes[i].kind = foe_wisp
    game.foes[i].x = 0.0
    game.foes[i].y = 0.0
    game.foes[i].vx = 0.0
    game.foes[i].vy = 0.0
    game.foes[i].w = 0.0
    game.foes[i].h = 0.0
    game.foes[i].hp = 0.0
    game.foes[i].life = 0.0
    game.foes[i].phase = 0.0
    game.foes[i].shot_cd = 0.0
    game.foes[i].reward = 0
    game.foes[i].marked = false
  }
}

///|
fn clear_bolts(game : Game) -> Unit {
  for i = 0; i < game.bolts.length(); i = i + 1 {
    game.bolts[i].active = false
    game.bolts[i].x = 0.0
    game.bolts[i].y = 0.0
    game.bolts[i].vx = 0.0
    game.bolts[i].vy = 0.0
    game.bolts[i].life = 0.0
    game.bolts[i].dmg = 0.0
    game.bolts[i].kind = 0
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
fn clear_echoes(game : Game) -> Unit {
  for i = 0; i < game.echoes.length(); i = i + 1 {
    game.echoes[i].active = false
    game.echoes[i].x = 0.0
    game.echoes[i].y = 0.0
    game.echoes[i].w = 0.0
    game.echoes[i].h = 0.0
    game.echoes[i].life = 0.0
    game.echoes[i].rot = 0.0
  }
}

///|
fn reset_bells(game : Game) -> Unit {
  for i = 0; i < bell_count; i = i + 1 {
    let p = bell_pos(i)
    game.bells[i].x = p.0
    game.bells[i].y = p.1
    game.bells[i].cooldown = 0.0
    game.bells[i].glow = 0.0
    game.bells[i].charge = 1.0
  }
}

///|
fn reset_hero(game : Game) -> Unit {
  game.hero.x = shrine_x()
  game.hero.y = shrine_y() + 130.0
  game.hero.vx = 0.0
  game.hero.vy = 0.0
  game.hero.w = hero_w
  game.hero.h = hero_h
  game.hero.angle = 0.0
  game.hero.dash_cd = 0.0
  game.hero.dash_t = 0.0
  game.hero.invuln = 0.0
  game.hero.hurt_t = 0.0
  game.hero.aura_t = 0.0
  game.hero.anim_t = 0.0
}

///|
fn alloc_foe(game : Game) -> Int {
  for i = 0; i < game.foes.length(); i = i + 1 {
    if not(game.foes[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.foes[0].life
  for i = 1; i < game.foes.length(); i = i + 1 {
    if game.foes[i].life < best_life {
      best_life = game.foes[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_bolt(game : Game) -> Int {
  for i = 0; i < game.bolts.length(); i = i + 1 {
    if not(game.bolts[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.bolts[0].life
  for i = 1; i < game.bolts.length(); i = i + 1 {
    if game.bolts[i].life < best_life {
      best_life = game.bolts[i].life
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
fn alloc_echo(game : Game) -> Int {
  for i = 0; i < game.echoes.length(); i = i + 1 {
    if not(game.echoes[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.echoes[0].life
  for i = 1; i < game.echoes.length(); i = i + 1 {
    if game.echoes[i].life < best_life {
      best_life = game.echoes[i].life
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
      randf(0.24, 1.06),
      randf(1.0, 4.6),
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
fn spawn_echo(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  life : Float,
  rot : Float,
) -> Unit {
  let i = alloc_echo(game)
  game.echoes[i].active = true
  game.echoes[i].x = x
  game.echoes[i].y = y
  game.echoes[i].w = w
  game.echoes[i].h = h
  game.echoes[i].life = life
  game.echoes[i].rot = rot
}

///|
fn spawn_bolt(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  dmg : Float,
  kind : Int,
) -> Unit {
  let i = alloc_bolt(game)
  game.bolts[i].active = true
  game.bolts[i].x = x
  game.bolts[i].y = y
  game.bolts[i].vx = vx
  game.bolts[i].vy = vy
  game.bolts[i].life = life
  game.bolts[i].dmg = dmg
  game.bolts[i].kind = kind
}

///|
fn spawn_foe(
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
  shot_cd : Float,
  reward : Int,
) -> Unit {
  let i = alloc_foe(game)
  game.foes[i].active = true
  game.foes[i].kind = kind
  game.foes[i].x = x
  game.foes[i].y = y
  game.foes[i].vx = vx
  game.foes[i].vy = vy
  game.foes[i].w = w
  game.foes[i].h = h
  game.foes[i].hp = hp
  game.foes[i].life = life
  game.foes[i].phase = randf(0.0, 6.283)
  game.foes[i].shot_cd = shot_cd
  game.foes[i].reward = reward
  game.foes[i].marked = false
}

///|
fn is_hostile(kind : Int) -> Bool {
  kind == foe_wisp || kind == foe_brute || kind == foe_shaman
}

///|
fn is_relic(kind : Int) -> Bool {
  kind == foe_relic
}

///|
fn foe_hit_r(f : Foe) -> Float {
  maxf(f.w, f.h) * 0.34
}

///|
fn hero_hit_r(h : Hero) -> Float {
  maxf(h.w, h.h) * 0.32
}

///|
fn score_gain(game : Game, base : Int) -> Int {
  let bonus = base * game.combo / 6
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
  game.combo = clampi(game.combo + 1, 0, 28)
  game.combo_t = 3.6
}

///|
fn clear_combo(game : Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
fn hurt_hero(game : Game, dmg : Float) -> Unit {
  if game.hero.invuln > 0.0 {
    return
  }

  game.shrine_hp = maxf(0.0, game.shrine_hp - dmg)
  game.spirit = maxf(0.0, game.spirit - 10.0)

  game.hero.invuln = hero_invuln_time
  game.hero.hurt_t = hero_hurt_time
  game.flash_t = maxf(game.flash_t, 0.32)
  game.shake_t = maxf(game.shake_t, 0.52)

  burst_sparks(game, game.hero.x, game.hero.y, 18, 1)
  clear_combo(game)

  if game.shrine_hp <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }
}

///|
fn ring_bell(game : Game, bell_i : Int) -> Unit {
  if bell_i < 0 || bell_i >= bell_count {
    return
  }

  if game.bells[bell_i].cooldown > 0.0 || game.spirit < bell_cost {
    return
  }

  game.bells[bell_i].cooldown = bell_cd_time
  game.bells[bell_i].glow = 0.9
  game.bells[bell_i].charge = 0.0

  game.spirit = maxf(0.0, game.spirit - bell_cost)
  game.hero.aura_t = 0.42

  spawn_ring(game, game.bells[bell_i].x, game.bells[bell_i].y, 16.0, 0.9, 0)
  burst_sparks(game, game.bells[bell_i].x, game.bells[bell_i].y, 28, 0)

  let rr2 = bell_shock_radius * bell_shock_radius

  for i = 0; i < game.foes.length(); i = i + 1 {
    if not(game.foes[i].active) {
      continue
    }

    let d2 = dist2(
      game.bells[bell_i].x,
      game.bells[bell_i].y,
      game.foes[i].x,
      game.foes[i].y,
    )
    if d2 > rr2 {
      continue
    }

    if is_relic(game.foes[i].kind) {
      game.foes[i].active = false
      game.rescued = game.rescued + 1
      add_score(game, 180)
      game.spirit = minf(spirit_max, game.spirit + 20.0)
      game.shrine_hp = minf(shrine_max_hp, game.shrine_hp + 12.0)
      spawn_ring(game, game.foes[i].x, game.foes[i].y, 10.0, 0.5, 2)
      burst_sparks(game, game.foes[i].x, game.foes[i].y, 12, 2)
      continue
    }

    let dmg = if game.foes[i].kind == foe_brute {
      bell_shock_damage * 0.7
    } else {
      bell_shock_damage
    }

    game.foes[i].hp = game.foes[i].hp - dmg
    game.foes[i].marked = true

    let dx = game.foes[i].x - game.bells[bell_i].x
    let dy = game.foes[i].y - game.bells[bell_i].y
    let n2 = maxf(1.0, dx * dx + dy * dy)
    let inv = Float::from_int(1) / sqrtf(n2)
    game.foes[i].vx = game.foes[i].vx + dx * inv * 220.0
    game.foes[i].vy = game.foes[i].vy + dy * inv * 220.0

    if game.foes[i].hp <= 0.0 {
      let x = game.foes[i].x
      let y = game.foes[i].y
      let reward = game.foes[i].reward
      game.foes[i].active = false
      add_score(game, reward)
      push_combo(game)
      game.defeats = game.defeats + 1
      spawn_ring(game, x, y, 9.0, 0.44, 1)
      burst_sparks(game, x, y, 14, 1)
    }
  }

  for i = 0; i < game.bolts.length(); i = i + 1 {
    if not(game.bolts[i].active) {
      continue
    }

    let d2 = dist2(
      game.bells[bell_i].x,
      game.bells[bell_i].y,
      game.bolts[i].x,
      game.bolts[i].y,
    )
    if d2 <= rr2 {
      game.bolts[i].active = false
      emit_spark(
        game,
        game.bolts[i].x,
        game.bolts[i].y,
        randf(-80.0, 80.0),
        randf(-80.0, 80.0),
        randf(0.2, 0.42),
        randf(1.2, 3.0),
        2,
      )
    }
  }
}

///|
fn find_nearest_bell(game : Game) -> Int {
  let mut best = -1
  let mut best_d2 = bell_ring_reach * bell_ring_reach

  for i = 0; i < bell_count; i = i + 1 {
    let d2 = dist2(game.hero.x, game.hero.y, game.bells[i].x, game.bells[i].y)
    if d2 <= best_d2 {
      best_d2 = d2
      best = i
    }
  }

  best
}

///|
fn edge_spawn() -> (Float, Float) {
  let side = randi(0, 3)

  if side == 0 {
    (play_left - 120.0, randf(play_top - 20.0, play_bottom + 20.0))
  } else if side == 1 {
    (play_right + 120.0, randf(play_top - 20.0, play_bottom + 20.0))
  } else if side == 2 {
    (randf(play_left - 20.0, play_right + 20.0), play_top - 120.0)
  } else {
    (randf(play_left - 20.0, play_right + 20.0), play_bottom + 120.0)
  }
}

///|
fn spawn_wisp(game : Game) -> Unit {
  let p = edge_spawn()

  spawn_foe(
    game,
    foe_wisp,
    p.0,
    p.1,
    randf(-20.0, 20.0),
    randf(-20.0, 20.0),
    randf(36.0, 44.0),
    randf(36.0, 44.0),
    16.0 + Float::from_int(game.stage - 1) * 3.0,
    randf(7.0, 13.0),
    randf(1.2, 2.4),
    120,
  )
}

///|
fn spawn_brute(game : Game) -> Unit {
  let p = edge_spawn()

  spawn_foe(
    game,
    foe_brute,
    p.0,
    p.1,
    randf(-12.0, 12.0),
    randf(-12.0, 12.0),
    randf(58.0, 74.0),
    randf(58.0, 74.0),
    38.0 + Float::from_int(game.stage - 1) * 7.0,
    randf(9.0, 15.0),
    randf(2.0, 3.0),
    180,
  )
}

///|
fn spawn_shaman(game : Game) -> Unit {
  let p = edge_spawn()

  spawn_foe(
    game,
    foe_shaman,
    p.0,
    p.1,
    randf(-16.0, 16.0),
    randf(-16.0, 16.0),
    randf(50.0, 62.0),
    randf(50.0, 62.0),
    22.0 + Float::from_int(game.stage - 1) * 4.0,
    randf(8.0, 14.0),
    randf(0.6, 1.5),
    160,
  )
}

///|
fn spawn_relic(game : Game) -> Unit {
  let p = edge_spawn()

  spawn_foe(
    game,
    foe_relic,
    p.0,
    p.1,
    randf(-18.0, 18.0),
    randf(-18.0, 18.0),
    randf(34.0, 42.0),
    randf(34.0, 42.0),
    1.0,
    randf(8.0, 12.0),
    99.0,
    0,
  )
}

///|
fn spawn_wave(game : Game) -> Unit {
  let n = 1 + randi(0, 1 + game.stage / 2)

  for _i = 0; _i < n; _i = _i + 1 {
    let roll = randi(0, 99)
    if roll < 40 {
      spawn_wisp(game)
    } else if roll < 66 {
      spawn_brute(game)
    } else if roll < 88 {
      spawn_shaman(game)
    } else {
      spawn_relic(game)
    }
  }

  if chance(14 + game.stage * 3) {
    spawn_relic(game)
  }
}

///|
fn spawn_step(game : Game, dt : Float) -> Unit {
  game.spawn_cd = game.spawn_cd - dt

  if game.spawn_cd <= 0.0 {
    spawn_wave(game)

    let pressure = Float::from_int(game.stage - 1) * 0.06
    game.spawn_cd = randf(
      maxf(spawn_cd_min, spawn_cd_max - pressure - 0.4),
      spawn_cd_max - pressure,
    )
  }
}

///|
fn apply_dash(game : Game) -> Unit {
  game.hero.dash_cd = dash_cd_time
  game.hero.dash_t = dash_time
  game.hero.invuln = maxf(game.hero.invuln, 0.24)
  game.spirit = maxf(0.0, game.spirit - spirit_dash_cost)

  let mut dx = game.input_x
  let mut dy = game.input_y

  if absf(dx) < 0.01 && absf(dy) < 0.01 {
    dx = sinf(game.hero.angle * 0.017)
    dy = -cosf(game.hero.angle * 0.017)
  }

  let n2 = maxf(0.01, dx * dx + dy * dy)
  let inv = Float::from_int(1) / sqrtf(n2)
  game.hero.vx = dx * inv * dash_speed
  game.hero.vy = dy * inv * dash_speed

  game.hero.aura_t = 0.3
  spawn_ring(game, game.hero.x, game.hero.y, 14.0, 0.52, 2)
  burst_sparks(game, game.hero.x, game.hero.y, 18, 2)
}

///|
fn update_hero(game : Game, dt : Float) -> Unit {
  if game.input_dash_press &&
    game.hero.dash_cd <= 0.0 &&
    game.spirit >= spirit_dash_cost {
    apply_dash(game)
  }

  if game.input_ring_press {
    let bi = find_nearest_bell(game)
    if bi >= 0 {
      ring_bell(game, bi)
    }
  }

  game.hero.vx = game.hero.vx + game.input_x * hero_accel * dt
  game.hero.vy = game.hero.vy + game.input_y * hero_accel * dt

  let cx = shrine_x() - game.hero.x
  let cy = shrine_y() - game.hero.y
  game.hero.vx = game.hero.vx + cx * 0.6 * dt
  game.hero.vy = game.hero.vy + cy * 0.6 * dt

  let drag = clampf(1.0 - hero_drag * dt, 0.0, 1.0)
  game.hero.vx = game.hero.vx * drag
  game.hero.vy = game.hero.vy * drag

  let speed2 = game.hero.vx * game.hero.vx + game.hero.vy * game.hero.vy
  if speed2 > hero_max_speed * hero_max_speed {
    let inv = Float::from_int(1) / sqrtf(speed2)
    game.hero.vx = game.hero.vx * inv * hero_max_speed
    game.hero.vy = game.hero.vy * inv * hero_max_speed
  }

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  game.hero.x = clampf(game.hero.x, play_left, play_right)
  game.hero.y = clampf(game.hero.y, play_top, play_bottom)

  if game.hero.dash_t > 0.0 {
    spawn_echo(
      game,
      game.hero.x,
      game.hero.y,
      game.hero.w,
      game.hero.h,
      randf(0.1, 0.24),
      game.hero.angle,
    )
  }

  game.hero.angle = clampf(game.hero.vx / hero_max_speed * 30.0, -30.0, 30.0)
}

///|
fn fire_shaman_bolt(game : Game, f : Foe) -> Unit {
  let dx = game.hero.x - f.x
  let dy = game.hero.y - f.y
  let n2 = maxf(1.0, dx * dx + dy * dy)
  let inv = Float::from_int(1) / sqrtf(n2)

  spawn_bolt(
    game,
    f.x,
    f.y,
    dx * inv * bolt_speed,
    dy * inv * bolt_speed,
    bolt_life,
    10.0,
    0,
  )
}

///|
fn kill_foe(game : Game, i : Int, reward : Int, kind : Int) -> Unit {
  let x = game.foes[i].x
  let y = game.foes[i].y
  game.foes[i].active = false
  game.defeats = game.defeats + 1
  add_score(game, reward)
  push_combo(game)
  spawn_ring(game, x, y, 10.0, 0.44, kind)
  burst_sparks(game, x, y, 14 + randi(0, 8), kind)
}

///|
fn update_foes(game : Game, dt : Float) -> Unit {
  let dash_hit = game.hero.dash_t > 0.0

  for i = 0; i < game.foes.length(); i = i + 1 {
    if not(game.foes[i].active) {
      continue
    }

    game.foes[i].life = game.foes[i].life - dt
    game.foes[i].phase = game.foes[i].phase + dt
    game.foes[i].marked = false

    let mut tx = shrine_x()
    let mut ty = shrine_y()

    if game.foes[i].kind == foe_wisp {
      tx = game.hero.x
      ty = game.hero.y
    } else if game.foes[i].kind == foe_shaman {
      let away_x = game.foes[i].x - shrine_x()
      let away_y = game.foes[i].y - shrine_y()
      let n2 = maxf(1.0, away_x * away_x + away_y * away_y)
      let inv = Float::from_int(1) / sqrtf(n2)
      tx = shrine_x() + away_x * inv * 180.0
      ty = shrine_y() + away_y * inv * 180.0
    }

    let dx = tx - game.foes[i].x
    let dy = ty - game.foes[i].y
    let n2 = maxf(1.0, dx * dx + dy * dy)
    let inv = Float::from_int(1) / sqrtf(n2)

    let accel : Float = if game.foes[i].kind == foe_wisp {
      180.0
    } else if game.foes[i].kind == foe_brute {
      100.0
    } else if game.foes[i].kind == foe_shaman {
      120.0
    } else {
      74.0
    }

    game.foes[i].vx = game.foes[i].vx + dx * inv * accel * dt
    game.foes[i].vy = game.foes[i].vy + dy * inv * accel * dt

    if game.foes[i].kind == foe_wisp {
      game.foes[i].vx = game.foes[i].vx +
        sinf(game.foes[i].phase * 11.0) * 30.0 * dt
      game.foes[i].vy = game.foes[i].vy +
        cosf(game.foes[i].phase * 9.0) * 26.0 * dt
    } else if game.foes[i].kind == foe_shaman {
      game.foes[i].vx = game.foes[i].vx +
        cosf(game.foes[i].phase * 4.2) * 40.0 * dt
      game.foes[i].vy = game.foes[i].vy +
        sinf(game.foes[i].phase * 4.8) * 40.0 * dt
      game.foes[i].shot_cd = game.foes[i].shot_cd - dt
      if game.foes[i].shot_cd <= 0.0 {
        fire_shaman_bolt(game, game.foes[i])
        game.foes[i].shot_cd = randf(0.9, 1.7)
      }
    } else if game.foes[i].kind == foe_relic {
      game.foes[i].vx = game.foes[i].vx +
        sinf(game.foes[i].phase * 6.0) * 34.0 * dt
      game.foes[i].vy = game.foes[i].vy +
        cosf(game.foes[i].phase * 7.0) * 34.0 * dt
    }

    let speed_cap : Float = if game.foes[i].kind == foe_wisp {
      260.0
    } else if game.foes[i].kind == foe_brute {
      180.0
    } else if game.foes[i].kind == foe_shaman {
      220.0
    } else {
      170.0
    }

    let v2 = game.foes[i].vx * game.foes[i].vx +
      game.foes[i].vy * game.foes[i].vy
    if v2 > speed_cap * speed_cap {
      let invv = Float::from_int(1) / sqrtf(v2)
      game.foes[i].vx = game.foes[i].vx * invv * speed_cap
      game.foes[i].vy = game.foes[i].vy * invv * speed_cap
    }

    game.foes[i].x = game.foes[i].x + game.foes[i].vx * dt
    game.foes[i].y = game.foes[i].y + game.foes[i].vy * dt

    let outside = game.foes[i].life <= 0.0 ||
      game.foes[i].x < play_left - 240.0 ||
      game.foes[i].x > play_right + 240.0 ||
      game.foes[i].y < play_top - 240.0 ||
      game.foes[i].y > play_bottom + 240.0

    if outside {
      game.foes[i].active = false
      continue
    }

    if is_relic(game.foes[i].kind) {
      let d2h = dist2(game.hero.x, game.hero.y, game.foes[i].x, game.foes[i].y)
      let rrh = hero_hit_r(game.hero) + foe_hit_r(game.foes[i])
      if d2h <= rrh * rrh {
        game.foes[i].active = false
        game.rescued = game.rescued + 1
        add_score(game, 160)
        game.spirit = minf(spirit_max, game.spirit + 22.0)
        game.shrine_hp = minf(shrine_max_hp, game.shrine_hp + 14.0)
        spawn_ring(game, game.hero.x, game.hero.y, 10.0, 0.44, 2)
        burst_sparks(game, game.hero.x, game.hero.y, 14, 2)
      }
      continue
    }

    let d2_shrine = dist2(
      shrine_x(),
      shrine_y(),
      game.foes[i].x,
      game.foes[i].y,
    )
    let shrine_rr = shrine_radius + foe_hit_r(game.foes[i])
    if d2_shrine <= shrine_rr * shrine_rr {
      let dmg = if game.foes[i].kind == foe_wisp {
        shrine_drain_wisp
      } else if game.foes[i].kind == foe_brute {
        shrine_drain_brute
      } else {
        shrine_drain_shaman
      }
      game.shrine_hp = maxf(0.0, game.shrine_hp - dmg)
      game.foes[i].active = false
      game.shake_t = maxf(game.shake_t, 0.44)
      game.flash_t = maxf(game.flash_t, 0.2)
      burst_sparks(game, shrine_x(), shrine_y(), 18, 1)
      clear_combo(game)

      if game.shrine_hp <= 0.0 {
        game.state = state_game_over
        game.result_t = 0.0
      }
      continue
    }

    let d2h = dist2(game.hero.x, game.hero.y, game.foes[i].x, game.foes[i].y)
    let rrh = hero_hit_r(game.hero) + foe_hit_r(game.foes[i])
    if d2h <= rrh * rrh {
      if dash_hit {
        kill_foe(game, i, game.foes[i].reward, 0)
      } else {
        let dmg : Float = if game.foes[i].kind == foe_brute {
          14.0
        } else {
          10.0
        }
        hurt_hero(game, dmg)
        game.foes[i].hp = game.foes[i].hp - 10.0
        if game.foes[i].hp <= 0.0 {
          kill_foe(game, i, game.foes[i].reward, 1)
        }
      }
    }
  }
}

///|
fn update_bolts(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.bolts.length(); i = i + 1 {
    if not(game.bolts[i].active) {
      continue
    }

    game.bolts[i].x = game.bolts[i].x + game.bolts[i].vx * dt
    game.bolts[i].y = game.bolts[i].y + game.bolts[i].vy * dt
    game.bolts[i].life = game.bolts[i].life - dt

    let dead = game.bolts[i].life <= 0.0 ||
      game.bolts[i].x < play_left - 120.0 ||
      game.bolts[i].x > play_right + 120.0 ||
      game.bolts[i].y < play_top - 120.0 ||
      game.bolts[i].y > play_bottom + 120.0

    if dead {
      game.bolts[i].active = false
      continue
    }

    let d2 = dist2(game.hero.x, game.hero.y, game.bolts[i].x, game.bolts[i].y)
    let rr = hero_hit_r(game.hero) + 8.0
    if d2 <= rr * rr {
      game.bolts[i].active = false
      hurt_hero(game, game.bolts[i].dmg)
      emit_spark(
        game,
        game.hero.x,
        game.hero.y,
        randf(-90.0, 90.0),
        randf(-90.0, 90.0),
        randf(0.2, 0.46),
        randf(1.2, 3.0),
        1,
      )
    }
  }
}

///|
fn update_effects(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.sparks.length(); i = i + 1 {
    if not(game.sparks[i].active) {
      continue
    }

    game.sparks[i].x = game.sparks[i].x + game.sparks[i].vx * dt
    game.sparks[i].y = game.sparks[i].y + game.sparks[i].vy * dt
    game.sparks[i].life = game.sparks[i].life - dt

    if game.sparks[i].kind == 3 {
      game.sparks[i].vy = game.sparks[i].vy + 12.0 * dt
    }

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
      (130.0 + Float::from_int(game.rings[i].kind) * 44.0) * dt

    if game.rings[i].life <= 0.0 {
      game.rings[i].active = false
    }
  }

  for i = 0; i < game.echoes.length(); i = i + 1 {
    if not(game.echoes[i].active) {
      continue
    }

    game.echoes[i].life = game.echoes[i].life - dt
    if game.echoes[i].life <= 0.0 {
      game.echoes[i].active = false
    }
  }
}

///|
fn update_bells(game : Game, dt : Float) -> Unit {
  for i = 0; i < bell_count; i = i + 1 {
    game.bells[i].cooldown = maxf(0.0, game.bells[i].cooldown - dt)
    game.bells[i].glow = maxf(0.0, game.bells[i].glow - dt)

    if game.bells[i].cooldown <= 0.0 {
      game.bells[i].charge = 1.0
    } else {
      game.bells[i].charge = clampf(
        1.0 - game.bells[i].cooldown / bell_cd_time,
        0.0,
        1.0,
      )
    }
  }
}

///|
fn emit_ambient(game : Game, dt : Float) -> Unit {
  let tries = clampi((dt * 200.0).to_int(), 1, 12)

  for _i = 0; _i < tries; _i = _i + 1 {
    if chance(28) {
      emit_spark(
        game,
        randf(play_left, play_right),
        randf(play_top - 20.0, play_top + 60.0),
        randf(-40.0, 40.0),
        randf(22.0, 90.0),
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
  game.wave_t = game.wave_t + dt

  game.hero.dash_cd = maxf(0.0, game.hero.dash_cd - dt)
  game.hero.dash_t = maxf(0.0, game.hero.dash_t - dt)
  game.hero.invuln = maxf(0.0, game.hero.invuln - dt)
  game.hero.hurt_t = maxf(0.0, game.hero.hurt_t - dt)
  game.hero.aura_t = maxf(0.0, game.hero.aura_t - dt)
  game.hero.anim_t = game.hero.anim_t + dt

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
fn init_title_scene(game : Game) -> Unit {
  clear_foes(game)
  clear_bolts(game)
  clear_sparks(game)
  clear_rings(game)
  clear_echoes(game)
  reset_bells(game)
  reset_hero(game)

  game.state = state_title
  game.stage = 1
  game.stage_goal = stage_goal_base
  game.score = 0
  game.defeats = 0
  game.rescued = 0
  game.combo = 0
  game.combo_t = 0.0

  game.shrine_hp = shrine_max_hp
  game.spirit = spirit_max
  game.time_left = stage_time_base

  game.spawn_cd = 0.62
  game.wave_t = 0.0

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0
  game.time_s = 0.0
}

///|
fn start_stage(game : Game, stage : Int) -> Unit {
  clear_foes(game)
  clear_bolts(game)
  clear_sparks(game)
  clear_rings(game)
  clear_echoes(game)
  reset_bells(game)
  reset_hero(game)

  game.state = state_play
  game.stage = stage
  game.stage_goal = stage_goal_base + (stage - 1) * stage_goal_bonus

  game.time_left = stage_time_base +
    Float::from_int(stage - 1) * stage_time_bonus
  game.shrine_hp = minf(shrine_max_hp, game.shrine_hp + 24.0)
  game.spirit = minf(spirit_max, game.spirit + 30.0)

  game.spawn_cd = 0.5
  game.wave_t = 0.0
  clear_combo(game)

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  spawn_ring(game, shrine_x(), shrine_y(), 18.0, 0.72, 2)
  burst_sparks(game, shrine_x(), shrine_y(), 28, 2)
}

///|
fn start_run(game : Game) -> Unit {
  game.score = 0
  game.defeats = 0
  game.rescued = 0
  game.shrine_hp = shrine_max_hp
  game.spirit = spirit_max
  start_stage(game, 1)
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.time_left = maxf(0.0, game.time_left - dt)

  update_hero(game, dt)
  update_bells(game, dt)

  spawn_step(game, dt)
  update_foes(game, dt)
  update_bolts(game, dt)

  emit_ambient(game, dt)
  update_effects(game, dt)

  game.spirit = minf(spirit_max, game.spirit + spirit_regen * dt)

  if game.time_left <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }

  if game.shrine_hp <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }

  if game.state == state_play && game.score >= game.stage_goal {
    game.state = state_stage_clear
    game.result_t = 0.0
    add_score(game, 280 + game.stage * 120)
    game.shrine_hp = minf(shrine_max_hp, game.shrine_hp + 14.0)
    game.spirit = minf(spirit_max, game.spirit + 24.0)
    spawn_ring(game, shrine_x(), shrine_y(), 20.0, 0.84, 2)
    burst_sparks(game, shrine_x(), shrine_y(), 32, 2)
  }
}

///|
fn update_title(game : Game, dt : Float) -> Unit {
  emit_ambient(game, dt)
  update_effects(game, dt)
  update_bells(game, dt)

  if chance(6) {
    let bi = randi(0, bell_count - 1)
    game.bells[bi].glow = maxf(game.bells[bi].glow, 0.24)
  }

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  emit_ambient(game, dt)
  update_effects(game, dt)
  update_bells(game, dt)

  if chance(34) {
    emit_spark(
      game,
      shrine_x() + randf(-40.0, 40.0),
      shrine_y() + randf(-40.0, 40.0),
      randf(-50.0, 50.0),
      randf(-90.0, -20.0),
      randf(0.3, 0.7),
      randf(1.5, 4.0),
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
  emit_ambient(game, dt)
  update_effects(game, dt)
  update_bells(game, dt)

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
