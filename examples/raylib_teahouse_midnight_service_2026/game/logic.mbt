///|
fn clear_customers(game : @types.Game) -> Unit {
  for customer in game.customers {
    customer.active = false
    customer.tea_type = @types.tea_jasmine
    customer.slot = 0
    customer.x = 0.0
    customer.y = 0.0
    customer.patience = 0.0
    customer.patience_max = 0.0
    customer.life = 0.0
    customer.reward = 0
    customer.mood = 0.0
    customer.served_t = 0.0
    customer.angry = false
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
fn clear_shadows(game : @types.Game) -> Unit {
  for shadow in game.shadows {
    shadow.active = false
    shadow.x = 0.0
    shadow.y = 0.0
    shadow.w = 0.0
    shadow.h = 0.0
    shadow.life = 0.0
    shadow.rot = 0.0
  }
}

///|
fn reset_player(game : @types.Game) -> Unit {
  game.player.x = 628.0
  game.player.y = 468.0
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.w = @types.player_w
  game.player.h = @types.player_h
  game.player.angle = 0.0
  game.player.dash_cd = 0.0
  game.player.dash_t = 0.0
  game.player.interact_t = 0.0
  game.player.anim_t = 0.0
  game.player.carry_water = false
  game.player.carry_leaf = -1
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
fn alloc_shadow(game : @types.Game) -> Int {
  for i in 0..<game.shadows.length() {
    if not(game.shadows[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.shadows[0].life
  for i in 1..<game.shadows.length() {
    if game.shadows[i].life < best_life {
      best_life = game.shadows[i].life
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
fn burst_sparks(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<n {
    emit_spark(
      game,
      x + @types.randf(-14.0, 14.0),
      y + @types.randf(-14.0, 14.0),
      @types.randf(-230.0, 230.0),
      @types.randf(-230.0, 230.0),
      @types.randf(0.24, 1.02),
      @types.randf(1.0, 4.4),
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
fn spawn_shadow(
  game : @types.Game,
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
  game.combo = @types.clampi(game.combo + 1, 0, 30)
  game.combo_t = 3.8
}

///|
fn clear_combo(game : @types.Game) -> Unit {
  game.combo = 0
  game.combo_t = 0.0
}

///|
fn slot_used(game : @types.Game, slot : Int) -> Bool {
  for customer in game.customers {
    if customer.active && customer.slot == slot {
      return true
    }
  }
  false
}

///|
fn find_open_slot(game : @types.Game) -> Int {
  for s in 0..<@types.customer_slots {
    if not(slot_used(game, s)) {
      return s
    }
  }
  -1
}

///|
fn alloc_customer(game : @types.Game) -> Int {
  for i in 0..<game.customers.length() {
    if not(game.customers[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_patience = game.customers[0].patience
  for i in 1..<game.customers.length() {
    if game.customers[i].patience < best_patience {
      best_patience = game.customers[i].patience
      best = i
    }
  }
  best
}

///|
fn customer_base_patience(stage : Int) -> Float {
  @types.maxf(8.0, 20.0 - Float::from_int(stage - 1) * 1.1)
}

///|
fn pick_tea_type(stage : Int) -> Int {
  let r = @types.randi(0, 99)

  if stage <= 1 {
    if r < 40 {
      @types.tea_jasmine
    } else if r < 72 {
      @types.tea_oolong
    } else if r < 86 {
      @types.tea_matcha
    } else {
      @types.tea_berry
    }
  } else if stage <= 3 {
    if r < 24 {
      @types.tea_jasmine
    } else if r < 46 {
      @types.tea_oolong
    } else if r < 66 {
      @types.tea_puer
    } else if r < 84 {
      @types.tea_matcha
    } else {
      @types.tea_berry
    }
  } else {
    @types.randi(0, @types.tea_count - 1)
  }
}

///|
fn spawn_customer(game : @types.Game) -> Unit {
  let slot = find_open_slot(game)
  if slot < 0 {
    return
  }

  let i = alloc_customer(game)
  let tea = pick_tea_type(game.stage)
  let p = @types.customer_slot_pos(slot)

  let base_pat = customer_base_patience(game.stage)
  let patience_max = base_pat + @types.randf(-2.0, 4.0)

  game.customers[i].active = true
  game.customers[i].tea_type = tea
  game.customers[i].slot = slot
  game.customers[i].x = p.0 + @types.randf(-5.0, 5.0)
  game.customers[i].y = p.1 + @types.randf(-5.0, 5.0)
  game.customers[i].patience_max = @types.maxf(6.0, patience_max)
  game.customers[i].patience = game.customers[i].patience_max
  game.customers[i].life = 0.0
  game.customers[i].reward = 96 + tea * 24 + game.stage * 12
  game.customers[i].mood = 1.0
  game.customers[i].served_t = 0.0
  game.customers[i].angry = false

  burst_sparks(game, game.customers[i].x, game.customers[i].y, 10, 0)
}

///|
fn nearest_leaf_station(px : Float, py : Float, reach : Float) -> Int {
  let mut best = -1
  let mut best_d2 = reach * reach

  for tea in 0..<@types.tea_count {
    let d2 = @types.dist2(px, py, @types.leaf_x(), @types.leaf_y(tea))
    if d2 <= best_d2 {
      best_d2 = d2
      best = tea
    }
  }

  best
}

///|
fn nearest_customer(
  game : @types.Game,
  x : Float,
  y : Float,
  reach : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = reach * reach

  for i in 0..<game.customers.length() {
    if not(game.customers[i].active) {
      continue
    }

    let d2 = @types.dist2(x, y, game.customers[i].x, game.customers[i].y)
    if d2 <= best_d2 {
      best_d2 = d2
      best = i
    }
  }

  best
}

///|
fn start_brew(game : @types.Game) -> Unit {
  game.brew_active = true
  game.brew_t = @types.maxf(
    @types.brew_time_min,
    @types.brew_time_base - Float::from_int(game.stage - 1) * 0.12,
  )
  game.brew_type = game.player.carry_leaf
  game.player.carry_water = false
  game.player.carry_leaf = -1

  spawn_ring(game, @types.brew_x, @types.brew_y, 12.0, 0.42, 0)
  burst_sparks(game, @types.brew_x, @types.brew_y, 12, 0)
}

///|
fn finish_brew(game : @types.Game) -> Unit {
  game.brew_active = false
  game.ready_cup = game.brew_type

  spawn_ring(game, @types.brew_x, @types.brew_y, 16.0, 0.7, 2)
  burst_sparks(game, @types.brew_x, @types.brew_y, 22, 2)
}

///|
fn serve_customer(game : @types.Game, ci : Int) -> Unit {
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
    game.reputation = @types.minf(
      @types.reputation_max,
      game.reputation + 6.0,
    )
    game.focus = @types.minf(@types.focus_max, game.focus + 10.0)
    push_combo(game)

    spawn_ring(game, c.x, c.y, 10.0, 0.5, 2)
    burst_sparks(game, c.x, c.y, 18, 2)
  } else {
    game.customers[ci].angry = true
    game.customers[ci].mood = @types.maxf(
      0.0,
      game.customers[ci].mood - 0.4,
    )
    game.reputation = @types.maxf(
      0.0,
      game.reputation - @types.wrong_serve_penalty,
    )
    game.focus = @types.maxf(0.0, game.focus - 6.0)
    clear_combo(game)

    game.flash_t = @types.maxf(game.flash_t, 0.22)
    game.shake_t = @types.maxf(game.shake_t, 0.2)

    burst_sparks(game, c.x, c.y, 16, 1)
  }

  game.ready_cup = -1
  game.player.interact_t = 0.2
}

///|
fn apply_interact(game : @types.Game) -> Unit {
  let px = game.player.x
  let py = game.player.y

  if @types.near_station(
    px,
    py,
    @types.kettle_x,
    @types.kettle_y,
    @types.interact_reach,
  ) {
    game.player.carry_water = true
    game.player.interact_t = 0.22
    spawn_ring(game, @types.kettle_x, @types.kettle_y, 10.0, 0.4, 0)
    burst_sparks(game, @types.kettle_x, @types.kettle_y, 10, 0)
    return
  }

  let leaf = nearest_leaf_station(px, py, @types.interact_reach)
  if leaf >= 0 {
    game.player.carry_leaf = leaf
    game.player.interact_t = 0.22
    spawn_ring(
      game, @types.leaf_x(), @types.leaf_y(leaf), 8.0, 0.36, 0,
    )
    burst_sparks(game, @types.leaf_x(), @types.leaf_y(leaf), 8, 0)
    return
  }

  if @types.near_station(
    px,
    py,
    @types.brew_x,
    @types.brew_y,
    @types.interact_reach,
  ) {
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
    @types.near_station(
      px,
      py,
      @types.counter_x,
      @types.counter_y,
      @types.interact_reach + 10.0,
    ) {
    let ci = nearest_customer(game, px, py, @types.serve_reach)
    if ci >= 0 {
      serve_customer(game, ci)
    }
    return
  }
}

///|
fn apply_dash(game : @types.Game) -> Unit {
  if game.player.dash_cd > 0.0 || game.focus < @types.dash_focus_cost {
    return
  }

  let mut dx = game.input_x
  let mut dy = game.input_y

  if @types.absf(dx) < 0.01 && @types.absf(dy) < 0.01 {
    dx = @types.sinf(game.player.angle * 0.017)
    dy = -@types.cosf(game.player.angle * 0.017)
  }

  let n2 = @types.maxf(0.01, dx * dx + dy * dy)
  let inv = Float::from_int(1) / @types.sqrtf(n2)

  game.player.vx = dx * inv * @types.dash_speed
  game.player.vy = dy * inv * @types.dash_speed

  game.player.dash_t = @types.dash_time
  game.player.dash_cd = @types.dash_cd_time
  game.focus = @types.maxf(0.0, game.focus - @types.dash_focus_cost)

  spawn_ring(game, game.player.x, game.player.y, 14.0, 0.46, 2)
  burst_sparks(game, game.player.x, game.player.y, 16, 2)
}

///|
fn update_player(game : @types.Game, dt : Float) -> Unit {
  if game.input_dash_press {
    apply_dash(game)
  }

  if game.input_interact_press {
    apply_interact(game)
  }

  let speed_mul : Float = if game.focus_mode { 1.15 } else { 1.0 }

  game.player.vx = game.player.vx +
    game.input_x * @types.player_accel * speed_mul * dt
  game.player.vy = game.player.vy +
    game.input_y * @types.player_accel * speed_mul * dt

  let drag = @types.clampf(1.0 - @types.player_drag * dt, 0.0, 1.0)
  game.player.vx = game.player.vx * drag
  game.player.vy = game.player.vy * drag

  let cap = @types.player_max_speed * speed_mul
  game.player.vx = @types.clampf(game.player.vx, -cap, cap)
  game.player.vy = @types.clampf(game.player.vy, -cap, cap)

  game.player.x = game.player.x + game.player.vx * dt
  game.player.y = game.player.y + game.player.vy * dt

  game.player.x = @types.clampf(
    game.player.x,
    @types.play_left,
    @types.play_right,
  )
  game.player.y = @types.clampf(
    game.player.y,
    @types.play_top,
    @types.play_bottom,
  )

  if game.player.dash_t > 0.0 {
    spawn_shadow(
      game,
      game.player.x,
      game.player.y,
      game.player.w,
      game.player.h,
      @types.randf(0.1, 0.22),
      game.player.angle,
    )
  }

  game.player.angle = @types.clampf(
    game.player.vx / @types.maxf(1.0, cap) * 24.0,
    -24.0,
    24.0,
  )
}

///|
fn customer_drain_rate(game : @types.Game) -> Float {
  let base : Float = 1.0 + Float::from_int(game.stage - 1) * 0.1
  if game.focus_mode {
    base * 0.58
  } else {
    base
  }
}

///|
fn update_customers(game : @types.Game, dt : Float) -> Unit {
  let drain = customer_drain_rate(game)

  for customer in game.customers {
    if not(customer.active) {
      continue
    }

    customer.life = customer.life + dt
    customer.patience = customer.patience - drain * dt
    customer.served_t = @types.maxf(0.0, customer.served_t - dt)

    if customer.patience <= customer.patience_max * 0.25 {
      customer.angry = true
    }

    customer.mood = @types.clampf(
      customer.patience / @types.maxf(1.0, customer.patience_max),
      0.0,
      1.0,
    )

    if customer.patience <= 0.0 {
      let x = customer.x
      let y = customer.y

      customer.active = false
      game.missed = game.missed + 1
      game.reputation = @types.maxf(
        0.0,
        game.reputation - @types.miss_penalty,
      )
      game.focus = @types.maxf(0.0, game.focus - 10.0)
      clear_combo(game)

      game.flash_t = @types.maxf(game.flash_t, 0.22)
      game.shake_t = @types.maxf(game.shake_t, 0.28)

      burst_sparks(game, x, y, 18, 1)
      spawn_ring(game, x, y, 10.0, 0.45, 1)
    }
  }
}

///|
fn update_brew(game : @types.Game, dt : Float) -> Unit {
  if not(game.brew_active) {
    return
  }

  let speed : Float = if game.focus_mode { 1.36 } else { 1.0 }
  game.brew_t = game.brew_t - dt * speed

  if @types.chance(16) {
    emit_spark(
      game,
      @types.brew_x + @types.randf(-14.0, 14.0),
      @types.brew_y + @types.randf(-14.0, 14.0),
      @types.randf(-30.0, 30.0),
      @types.randf(-90.0, -20.0),
      @types.randf(0.2, 0.5),
      @types.randf(1.2, 3.0),
      0,
    )
  }

  if game.brew_t <= 0.0 {
    finish_brew(game)
  }
}

///|
fn update_focus(game : @types.Game, dt : Float) -> Unit {
  game.focus_mode = false

  if game.input_focus_hold && game.focus > 0.0 {
    game.focus_mode = true
    game.focus = @types.maxf(0.0, game.focus - @types.focus_drain * dt)
  } else {
    game.focus = @types.minf(
      @types.focus_max,
      game.focus + @types.focus_regen * dt,
    )
  }
}

///|
fn update_effects(game : @types.Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.life = spark.life - dt

    if spark.kind == 3 {
      spark.vy = spark.vy + 14.0 * dt
    }

    if spark.life <= 0.0 {
      spark.active = false
    }
  }

  for ring in game.rings {
    if not(ring.active) {
      continue
    }

    ring.life = ring.life - dt
    ring.r = ring.r + (120.0 + Float::from_int(ring.kind) * 38.0) * dt

    if ring.life <= 0.0 {
      ring.active = false
    }
  }

  for shadow in game.shadows {
    if not(shadow.active) {
      continue
    }

    shadow.life = shadow.life - dt
    if shadow.life <= 0.0 {
      shadow.active = false
    }
  }
}

///|
fn emit_ambient(game : @types.Game, dt : Float) -> Unit {
  let tries = @types.clampi((dt * 220.0).to_int(), 1, 10)

  for _i in 0..<tries {
    if @types.chance(24) {
      emit_spark(
        game,
        @types.randf(@types.play_left, @types.play_right),
        @types.play_top - @types.randf(20.0, 110.0),
        @types.randf(-30.0, 30.0),
        @types.randf(24.0, 84.0),
        @types.randf(0.8, 1.6),
        @types.randf(0.8, 2.2),
        3,
      )
    }
  }
}

///|
fn spawn_step(game : @types.Game, dt : Float) -> Unit {
  game.spawn_cd = game.spawn_cd - dt

  if game.spawn_cd <= 0.0 {
    spawn_customer(game)

    if game.stage >= 3 && @types.chance(32) {
      spawn_customer(game)
    }

    let pressure = Float::from_int(game.stage - 1) * 0.08
    let lo = @types.maxf(
      @types.spawn_cd_min,
      @types.spawn_cd_max - pressure - 0.6,
    )
    let hi = @types.maxf(lo + 0.1, @types.spawn_cd_max - pressure)
    game.spawn_cd = @types.randf(lo, hi)
  }
}

///|
fn update_timers(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt

  game.player.dash_cd = @types.maxf(0.0, game.player.dash_cd - dt)
  game.player.dash_t = @types.maxf(0.0, game.player.dash_t - dt)
  game.player.interact_t = @types.maxf(0.0, game.player.interact_t - dt)
  game.player.anim_t = game.player.anim_t + dt

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
fn start_stage(game : @types.Game, stage : Int) -> Unit {
  clear_customers(game)
  clear_sparks(game)
  clear_rings(game)
  clear_shadows(game)
  reset_player(game)

  game.state = @types.state_play
  game.stage = stage
  game.stage_goal = @types.stage_goal_base +
    (stage - 1) * @types.stage_goal_bonus

  game.time_left = @types.stage_time_base +
    Float::from_int(stage - 1) * @types.stage_time_bonus
  game.reputation = @types.minf(
    @types.reputation_max,
    game.reputation + 18.0,
  )
  game.focus = @types.minf(@types.focus_max, game.focus + 26.0)

  game.spawn_cd = 0.6
  game.brew_active = false
  game.brew_t = 0.0
  game.brew_type = @types.tea_jasmine
  game.ready_cup = -1
  game.focus_mode = false
  clear_combo(game)

  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0

  spawn_ring(game, @types.brew_x, @types.brew_y, 16.0, 0.68, 2)
  burst_sparks(game, @types.brew_x, @types.brew_y, 22, 2)
}

///|
fn start_run(game : @types.Game) -> Unit {
  game.score = 0
  game.served = 0
  game.missed = 0
  game.reputation = @types.reputation_max
  game.focus = @types.focus_max
  start_stage(game, 1)
}

///|
fn update_play(game : @types.Game, dt : Float) -> Unit {
  game.time_left = @types.maxf(0.0, game.time_left - dt)

  update_focus(game, dt)
  update_player(game, dt)
  update_brew(game, dt)
  spawn_step(game, dt)
  update_customers(game, dt)

  emit_ambient(game, dt)
  update_effects(game, dt)

  if game.reputation <= 0.0 || game.time_left <= 0.0 {
    game.state = @types.state_game_over
    game.result_t = 0.0
  }

  if game.state == @types.state_play && game.score >= game.stage_goal {
    game.state = @types.state_stage_clear
    game.result_t = 0.0
    add_score(game, @types.stage_clear_bonus + game.stage * 120)
    game.reputation = @types.minf(
      @types.reputation_max,
      game.reputation + 12.0,
    )
    game.focus = @types.minf(@types.focus_max, game.focus + 18.0)

    spawn_ring(game, @types.counter_x, @types.counter_y, 20.0, 0.84, 2)
    burst_sparks(game, @types.counter_x, @types.counter_y, 30, 2)
  }
}

///|
fn update_title(game : @types.Game, dt : Float) -> Unit {
  emit_ambient(game, dt)
  update_effects(game, dt)

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt

  emit_ambient(game, dt)
  update_effects(game, dt)

  if @types.chance(28) {
    emit_spark(
      game,
      @types.counter_x + @types.randf(-24.0, 24.0),
      @types.counter_y + @types.randf(-20.0, 20.0),
      @types.randf(-44.0, 44.0),
      @types.randf(-90.0, -14.0),
      @types.randf(0.3, 0.64),
      @types.randf(1.8, 4.0),
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

  emit_ambient(game, dt)
  update_effects(game, dt)

  if game.input_restart_press {
    @types.init_title_scene(game)
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  // Read mouse/touch state and store in game fields
  game.mouse_x = Float::from_int(@raylib.get_mouse_x())
  game.mouse_y = Float::from_int(@raylib.get_mouse_y())
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  // Dispatch input based on state
  if game.state == @types.state_title {
    update_title_input(game)
  } else if game.state == @types.state_play {
    update_play_input(game)
  } else {
    update_result_input(game)
  }

  update_timers(game, dt)

  if game.state == @types.state_title {
    update_title(game, dt)
  } else if game.state == @types.state_play {
    update_play(game, dt)
  } else if game.state == @types.state_stage_clear {
    update_stage_clear(game, dt)
  } else {
    update_game_over(game, dt)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}
