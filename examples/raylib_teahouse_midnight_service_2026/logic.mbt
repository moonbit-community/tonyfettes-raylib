///|
fn clear_customers(game : Game) -> Unit {
  for i = 0; i < game.customers.length(); i = i + 1 {
    game.customers[i].active = false
    game.customers[i].tea_type = tea_jasmine
    game.customers[i].slot = 0
    game.customers[i].x = 0.0
    game.customers[i].y = 0.0
    game.customers[i].patience = 0.0
    game.customers[i].patience_max = 0.0
    game.customers[i].life = 0.0
    game.customers[i].reward = 0
    game.customers[i].mood = 0.0
    game.customers[i].served_t = 0.0
    game.customers[i].angry = false
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
fn clear_shadows(game : Game) -> Unit {
  for i = 0; i < game.shadows.length(); i = i + 1 {
    game.shadows[i].active = false
    game.shadows[i].x = 0.0
    game.shadows[i].y = 0.0
    game.shadows[i].w = 0.0
    game.shadows[i].h = 0.0
    game.shadows[i].life = 0.0
    game.shadows[i].rot = 0.0
  }
}

///|
fn reset_player(game : Game) -> Unit {
  game.player.x = 628.0
  game.player.y = 468.0
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.w = player_w
  game.player.h = player_h
  game.player.angle = 0.0
  game.player.dash_cd = 0.0
  game.player.dash_t = 0.0
  game.player.interact_t = 0.0
  game.player.anim_t = 0.0
  game.player.carry_water = false
  game.player.carry_leaf = -1
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
      x + randf(-14.0, 14.0),
      y + randf(-14.0, 14.0),
      randf(-230.0, 230.0),
      randf(-230.0, 230.0),
      randf(0.24, 1.02),
      randf(1.0, 4.4),
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
fn spawn_shadow(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  life : Float,
  rot : Float,
) -> Unit {
  let i = alloc_shadow(game)
  game.shadows[i].active = true
  game.shadows[i].x = x
  game.shadows[i].y = y
  game.shadows[i].w = w
  game.shadows[i].h = h
  game.shadows[i].life = life
  game.shadows[i].rot = rot
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
  game.combo_t = 3.8
}

///|
fn clear_combo(game : Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
fn slot_used(game : Game, slot : Int) -> Bool {
  for i = 0; i < game.customers.length(); i = i + 1 {
    if game.customers[i].active && game.customers[i].slot == slot {
      return true
    }
  }
  false
}

///|
fn find_open_slot(game : Game) -> Int {
  for s = 0; s < customer_slots; s = s + 1 {
    if not(slot_used(game, s)) {
      return s
    }
  }
  -1
}

///|
fn alloc_customer(game : Game) -> Int {
  for i = 0; i < game.customers.length(); i = i + 1 {
    if not(game.customers[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_patience = game.customers[0].patience
  for i = 1; i < game.customers.length(); i = i + 1 {
    if game.customers[i].patience < best_patience {
      best_patience = game.customers[i].patience
      best = i
    }
  }
  best
}

///|
fn customer_base_patience(stage : Int) -> Float {
  maxf(8.0, 20.0 - Float::from_int(stage - 1) * 1.1)
}

///|
fn pick_tea_type(stage : Int) -> Int {
  let r = randi(0, 99)

  if stage <= 1 {
    if r < 40 {
      tea_jasmine
    } else if r < 72 {
      tea_oolong
    } else if r < 86 {
      tea_matcha
    } else {
      tea_berry
    }
  } else if stage <= 3 {
    if r < 24 {
      tea_jasmine
    } else if r < 46 {
      tea_oolong
    } else if r < 66 {
      tea_puer
    } else if r < 84 {
      tea_matcha
    } else {
      tea_berry
    }
  } else {
    randi(0, tea_count - 1)
  }
}

///|
fn spawn_customer(game : Game) -> Unit {
  let slot = find_open_slot(game)
  if slot < 0 {
    return
  }

  let i = alloc_customer(game)
  let tea = pick_tea_type(game.stage)
  let p = customer_slot_pos(slot)

  let base_pat = customer_base_patience(game.stage)
  let patience_max = base_pat + randf(-2.0, 4.0)

  game.customers[i].active = true
  game.customers[i].tea_type = tea
  game.customers[i].slot = slot
  game.customers[i].x = p.0 + randf(-5.0, 5.0)
  game.customers[i].y = p.1 + randf(-5.0, 5.0)
  game.customers[i].patience_max = maxf(6.0, patience_max)
  game.customers[i].patience = game.customers[i].patience_max
  game.customers[i].life = 0.0
  game.customers[i].reward = 96 + tea * 24 + game.stage * 12
  game.customers[i].mood = 1.0
  game.customers[i].served_t = 0.0
  game.customers[i].angry = false

  burst_sparks(game, game.customers[i].x, game.customers[i].y, 10, 0)
}

///|
fn near_station(
  px : Float,
  py : Float,
  sx : Float,
  sy : Float,
  reach : Float,
) -> Bool {
  dist2(px, py, sx, sy) <= reach * reach
}

///|
fn nearest_leaf_station(px : Float, py : Float, reach : Float) -> Int {
  let mut best = -1
  let mut best_d2 = reach * reach

  for tea = 0; tea < tea_count; tea = tea + 1 {
    let d2 = dist2(px, py, leaf_x(), leaf_y(tea))
    if d2 <= best_d2 {
      best_d2 = d2
      best = tea
    }
  }

  best
}

///|
fn nearest_customer(game : Game, x : Float, y : Float, reach : Float) -> Int {
  let mut best = -1
  let mut best_d2 = reach * reach

  for i = 0; i < game.customers.length(); i = i + 1 {
    if not(game.customers[i].active) {
      continue
    }

    let d2 = dist2(x, y, game.customers[i].x, game.customers[i].y)
    if d2 <= best_d2 {
      best_d2 = d2
      best = i
    }
  }

  best
}

///|
fn start_brew(game : Game) -> Unit {
  game.brew_active = true
  game.brew_t = maxf(
    brew_time_min,
    brew_time_base - Float::from_int(game.stage - 1) * 0.12,
  )
  game.brew_type = game.player.carry_leaf
  game.player.carry_water = false
  game.player.carry_leaf = -1

  spawn_ring(game, brew_x, brew_y, 12.0, 0.42, 0)
  burst_sparks(game, brew_x, brew_y, 12, 0)
}

///|
fn finish_brew(game : Game) -> Unit {
  game.brew_active = false
  game.ready_cup = game.brew_type

  spawn_ring(game, brew_x, brew_y, 16.0, 0.7, 2)
  burst_sparks(game, brew_x, brew_y, 22, 2)
}

///|
fn serve_customer(game : Game, ci : Int) -> Unit {
  if ci < 0 || ci >= game.customers.length() {
    return
  }

  let c = game.customers[ci]
  if not(c.active) {
    return
  }

  if game.ready_cup == c.tea_type {
    game.customers[ci].active = false
    game.served = game.served + 1
    add_score(game, game.customers[ci].reward)
    game.reputation = minf(reputation_max, game.reputation + 6.0)
    game.focus = minf(focus_max, game.focus + 10.0)
    push_combo(game)

    spawn_ring(game, c.x, c.y, 10.0, 0.5, 2)
    burst_sparks(game, c.x, c.y, 18, 2)
  } else {
    game.customers[ci].angry = true
    game.customers[ci].mood = maxf(0.0, game.customers[ci].mood - 0.4)
    game.reputation = maxf(0.0, game.reputation - wrong_serve_penalty)
    game.focus = maxf(0.0, game.focus - 6.0)
    clear_combo(game)

    game.flash_t = maxf(game.flash_t, 0.22)
    game.shake_t = maxf(game.shake_t, 0.2)

    burst_sparks(game, c.x, c.y, 16, 1)
  }

  game.ready_cup = -1
  game.player.interact_t = 0.2
}

///|
fn apply_interact(game : Game) -> Unit {
  let px = game.player.x
  let py = game.player.y

  if near_station(px, py, kettle_x, kettle_y, interact_reach) {
    game.player.carry_water = true
    game.player.interact_t = 0.22
    spawn_ring(game, kettle_x, kettle_y, 10.0, 0.4, 0)
    burst_sparks(game, kettle_x, kettle_y, 10, 0)
    return
  }

  let leaf = nearest_leaf_station(px, py, interact_reach)
  if leaf >= 0 {
    game.player.carry_leaf = leaf
    game.player.interact_t = 0.22
    spawn_ring(game, leaf_x(), leaf_y(leaf), 8.0, 0.36, 0)
    burst_sparks(game, leaf_x(), leaf_y(leaf), 8, 0)
    return
  }

  if near_station(px, py, brew_x, brew_y, interact_reach) {
    if not(game.brew_active) &&
      game.ready_cup < 0 &&
      game.player.carry_water &&
      game.player.carry_leaf >= 0 {
      start_brew(game)
      game.player.interact_t = 0.26
    }
    return
  }

  if game.ready_cup >= 0 &&
    near_station(px, py, counter_x, counter_y, interact_reach + 10.0) {
    let ci = nearest_customer(game, px, py, serve_reach)
    if ci >= 0 {
      serve_customer(game, ci)
    }
    return
  }
}

///|
fn apply_dash(game : Game) -> Unit {
  if game.player.dash_cd > 0.0 || game.focus < dash_focus_cost {
    return
  }

  let mut dx = game.input_x
  let mut dy = game.input_y

  if absf(dx) < 0.01 && absf(dy) < 0.01 {
    dx = sinf(game.player.angle * 0.017)
    dy = -cosf(game.player.angle * 0.017)
  }

  let n2 = maxf(0.01, dx * dx + dy * dy)
  let inv = Float::from_int(1) / sqrtf(n2)

  game.player.vx = dx * inv * dash_speed
  game.player.vy = dy * inv * dash_speed

  game.player.dash_t = dash_time
  game.player.dash_cd = dash_cd_time
  game.focus = maxf(0.0, game.focus - dash_focus_cost)

  spawn_ring(game, game.player.x, game.player.y, 14.0, 0.46, 2)
  burst_sparks(game, game.player.x, game.player.y, 16, 2)
}

///|
fn update_player(game : Game, dt : Float) -> Unit {
  if game.input_dash_press {
    apply_dash(game)
  }

  if game.input_interact_press {
    apply_interact(game)
  }

  let speed_mul : Float = if game.focus_mode { 1.15 } else { 1.0 }

  game.player.vx = game.player.vx + game.input_x * player_accel * speed_mul * dt
  game.player.vy = game.player.vy + game.input_y * player_accel * speed_mul * dt

  let drag = clampf(1.0 - player_drag * dt, 0.0, 1.0)
  game.player.vx = game.player.vx * drag
  game.player.vy = game.player.vy * drag

  let cap = player_max_speed * speed_mul
  game.player.vx = clampf(game.player.vx, -cap, cap)
  game.player.vy = clampf(game.player.vy, -cap, cap)

  game.player.x = game.player.x + game.player.vx * dt
  game.player.y = game.player.y + game.player.vy * dt

  game.player.x = clampf(game.player.x, play_left, play_right)
  game.player.y = clampf(game.player.y, play_top, play_bottom)

  if game.player.dash_t > 0.0 {
    spawn_shadow(
      game,
      game.player.x,
      game.player.y,
      game.player.w,
      game.player.h,
      randf(0.1, 0.22),
      game.player.angle,
    )
  }

  game.player.angle = clampf(
    game.player.vx / maxf(1.0, cap) * 24.0,
    -24.0,
    24.0,
  )
}

///|
fn customer_drain_rate(game : Game) -> Float {
  let base : Float = 1.0 + Float::from_int(game.stage - 1) * 0.1
  if game.focus_mode {
    base * 0.58
  } else {
    base
  }
}

///|
fn update_customers(game : Game, dt : Float) -> Unit {
  let drain = customer_drain_rate(game)

  for i = 0; i < game.customers.length(); i = i + 1 {
    if not(game.customers[i].active) {
      continue
    }

    game.customers[i].life = game.customers[i].life + dt
    game.customers[i].patience = game.customers[i].patience - drain * dt
    game.customers[i].served_t = maxf(0.0, game.customers[i].served_t - dt)

    if game.customers[i].patience <= game.customers[i].patience_max * 0.25 {
      game.customers[i].angry = true
    }

    game.customers[i].mood = clampf(
      game.customers[i].patience / maxf(1.0, game.customers[i].patience_max),
      0.0,
      1.0,
    )

    if game.customers[i].patience <= 0.0 {
      let x = game.customers[i].x
      let y = game.customers[i].y

      game.customers[i].active = false
      game.missed = game.missed + 1
      game.reputation = maxf(0.0, game.reputation - miss_penalty)
      game.focus = maxf(0.0, game.focus - 10.0)
      clear_combo(game)

      game.flash_t = maxf(game.flash_t, 0.22)
      game.shake_t = maxf(game.shake_t, 0.28)

      burst_sparks(game, x, y, 18, 1)
      spawn_ring(game, x, y, 10.0, 0.45, 1)
    }
  }
}

///|
fn update_brew(game : Game, dt : Float) -> Unit {
  if not(game.brew_active) {
    return
  }

  let speed : Float = if game.focus_mode { 1.36 } else { 1.0 }
  game.brew_t = game.brew_t - dt * speed

  if chance(16) {
    emit_spark(
      game,
      brew_x + randf(-14.0, 14.0),
      brew_y + randf(-14.0, 14.0),
      randf(-30.0, 30.0),
      randf(-90.0, -20.0),
      randf(0.2, 0.5),
      randf(1.2, 3.0),
      0,
    )
  }

  if game.brew_t <= 0.0 {
    finish_brew(game)
  }
}

///|
fn update_focus(game : Game, dt : Float) -> Unit {
  game.focus_mode = false

  if game.input_focus_hold && game.focus > 0.0 {
    game.focus_mode = true
    game.focus = maxf(0.0, game.focus - focus_drain * dt)
  } else {
    game.focus = minf(focus_max, game.focus + focus_regen * dt)
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
      game.sparks[i].vy = game.sparks[i].vy + 14.0 * dt
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
      (120.0 + Float::from_int(game.rings[i].kind) * 38.0) * dt

    if game.rings[i].life <= 0.0 {
      game.rings[i].active = false
    }
  }

  for i = 0; i < game.shadows.length(); i = i + 1 {
    if not(game.shadows[i].active) {
      continue
    }

    game.shadows[i].life = game.shadows[i].life - dt
    if game.shadows[i].life <= 0.0 {
      game.shadows[i].active = false
    }
  }
}

///|
fn emit_ambient(game : Game, dt : Float) -> Unit {
  let tries = clampi((dt * 220.0).to_int(), 1, 10)

  for _i = 0; _i < tries; _i = _i + 1 {
    if chance(24) {
      emit_spark(
        game,
        randf(play_left, play_right),
        play_top - randf(20.0, 110.0),
        randf(-30.0, 30.0),
        randf(24.0, 84.0),
        randf(0.8, 1.6),
        randf(0.8, 2.2),
        3,
      )
    }
  }
}

///|
fn spawn_step(game : Game, dt : Float) -> Unit {
  game.spawn_cd = game.spawn_cd - dt

  if game.spawn_cd <= 0.0 {
    spawn_customer(game)

    if game.stage >= 3 && chance(32) {
      spawn_customer(game)
    }

    let pressure = Float::from_int(game.stage - 1) * 0.08
    let lo = maxf(spawn_cd_min, spawn_cd_max - pressure - 0.6)
    let hi = maxf(lo + 0.1, spawn_cd_max - pressure)
    game.spawn_cd = randf(lo, hi)
  }
}

///|
fn update_timers(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt

  game.player.dash_cd = maxf(0.0, game.player.dash_cd - dt)
  game.player.dash_t = maxf(0.0, game.player.dash_t - dt)
  game.player.interact_t = maxf(0.0, game.player.interact_t - dt)
  game.player.anim_t = game.player.anim_t + dt

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
  clear_customers(game)
  clear_sparks(game)
  clear_rings(game)
  clear_shadows(game)
  reset_player(game)

  game.state = state_title
  game.stage = 1
  game.stage_goal = stage_goal_base
  game.score = 0
  game.served = 0
  game.missed = 0
  game.combo = 0
  game.combo_t = 0.0

  game.reputation = reputation_max
  game.focus = focus_max
  game.time_left = stage_time_base

  game.spawn_cd = 0.8
  game.brew_active = false
  game.brew_t = 0.0
  game.brew_type = tea_jasmine
  game.ready_cup = -1
  game.focus_mode = false

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0
  game.time_s = 0.0
}

///|
fn start_stage(game : Game, stage : Int) -> Unit {
  clear_customers(game)
  clear_sparks(game)
  clear_rings(game)
  clear_shadows(game)
  reset_player(game)

  game.state = state_play
  game.stage = stage
  game.stage_goal = stage_goal_base + (stage - 1) * stage_goal_bonus

  game.time_left = stage_time_base +
    Float::from_int(stage - 1) * stage_time_bonus
  game.reputation = minf(reputation_max, game.reputation + 18.0)
  game.focus = minf(focus_max, game.focus + 26.0)

  game.spawn_cd = 0.6
  game.brew_active = false
  game.brew_t = 0.0
  game.brew_type = tea_jasmine
  game.ready_cup = -1
  game.focus_mode = false
  clear_combo(game)

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  spawn_ring(game, brew_x, brew_y, 16.0, 0.68, 2)
  burst_sparks(game, brew_x, brew_y, 22, 2)
}

///|
fn start_run(game : Game) -> Unit {
  game.score = 0
  game.served = 0
  game.missed = 0
  game.reputation = reputation_max
  game.focus = focus_max
  start_stage(game, 1)
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.time_left = maxf(0.0, game.time_left - dt)

  update_focus(game, dt)
  update_player(game, dt)
  update_brew(game, dt)
  spawn_step(game, dt)
  update_customers(game, dt)

  emit_ambient(game, dt)
  update_effects(game, dt)

  if game.reputation <= 0.0 || game.time_left <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }

  if game.state == state_play && game.score >= game.stage_goal {
    game.state = state_stage_clear
    game.result_t = 0.0
    add_score(game, stage_clear_bonus + game.stage * 120)
    game.reputation = minf(reputation_max, game.reputation + 12.0)
    game.focus = minf(focus_max, game.focus + 18.0)

    spawn_ring(game, counter_x, counter_y, 20.0, 0.84, 2)
    burst_sparks(game, counter_x, counter_y, 30, 2)
  }
}

///|
fn update_title(game : Game, dt : Float) -> Unit {
  emit_ambient(game, dt)
  update_effects(game, dt)

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt

  emit_ambient(game, dt)
  update_effects(game, dt)

  if chance(28) {
    emit_spark(
      game,
      counter_x + randf(-24.0, 24.0),
      counter_y + randf(-20.0, 20.0),
      randf(-44.0, 44.0),
      randf(-90.0, -14.0),
      randf(0.3, 0.64),
      randf(1.8, 4.0),
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
