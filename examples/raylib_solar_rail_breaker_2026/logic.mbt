///|
fn clear_enemies(game : Game) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    game.enemies[i].active = false
    game.enemies[i].kind = 0
    game.enemies[i].ring = 0
    game.enemies[i].angle = 0.0
    game.enemies[i].ang_v = 0.0
    game.enemies[i].hp = 0.0
    game.enemies[i].fire_cd = 0.0
    game.enemies[i].phase_mask = 0
    game.enemies[i].size = 0.0
    game.enemies[i].spin = 0.0
  }
}

///|
fn clear_bullets(game : Game) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    game.bullets[i].active = false
    game.bullets[i].ring_f = 0.0
    game.bullets[i].angle = 0.0
    game.bullets[i].vr = 0.0
    game.bullets[i].va = 0.0
    game.bullets[i].life = 0.0
    game.bullets[i].dmg = 0.0
    game.bullets[i].kind = 0
  }
}

///|
fn clear_enemy_bullets(game : Game) -> Unit {
  for i = 0; i < game.enemy_bullets.length(); i = i + 1 {
    game.enemy_bullets[i].active = false
    game.enemy_bullets[i].x = 0.0
    game.enemy_bullets[i].y = 0.0
    game.enemy_bullets[i].vx = 0.0
    game.enemy_bullets[i].vy = 0.0
    game.enemy_bullets[i].life = 0.0
    game.enemy_bullets[i].dmg = 0.0
    game.enemy_bullets[i].kind = 0
  }
}

///|
fn clear_flares(game : Game) -> Unit {
  for i = 0; i < game.flares.length(); i = i + 1 {
    game.flares[i].active = false
    game.flares[i].ring = 0
    game.flares[i].angle = 0.0
    game.flares[i].span = 0.0
    game.flares[i].spin_v = 0.0
    game.flares[i].t = 0.0
    game.flares[i].danger = 0.0
  }
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
fn clear_shocks(game : Game) -> Unit {
  for i = 0; i < game.shocks.length(); i = i + 1 {
    game.shocks[i].active = false
    game.shocks[i].ring = 0
    game.shocks[i].a0 = 0.0
    game.shocks[i].a1 = 0.0
    game.shocks[i].life = 0.0
    game.shocks[i].beta = false
  }
}

///|
fn reset_player(player : Player) -> Unit {
  player.ring = 1
  player.ring_f = 1.0
  player.angle = -1.2
  player.ang_v = 0.0
  player.switch_cd = 0.0
  player.shot_cd = 0.0
  player.beam_cd = 0.0
  player.invuln = 0.0
  player.hurt_t = 0.0
  player.anim_t = 0.0
}

///|
fn alloc_enemy(game : Game) -> Int {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      return i
    }
  }
  let mut best = 0
  let mut best_hp = game.enemies[0].hp
  for i = 1; i < game.enemies.length(); i = i + 1 {
    if game.enemies[i].hp < best_hp {
      best_hp = game.enemies[i].hp
      best = i
    }
  }
  best
}

///|
fn alloc_bullet(game : Game) -> Int {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      return i
    }
  }
  let mut best = 0
  let mut best_life = game.bullets[0].life
  for i = 1; i < game.bullets.length(); i = i + 1 {
    if game.bullets[i].life < best_life {
      best_life = game.bullets[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_enemy_bullet(game : Game) -> Int {
  for i = 0; i < game.enemy_bullets.length(); i = i + 1 {
    if not(game.enemy_bullets[i].active) {
      return i
    }
  }
  let mut best = 0
  let mut best_life = game.enemy_bullets[0].life
  for i = 1; i < game.enemy_bullets.length(); i = i + 1 {
    if game.enemy_bullets[i].life < best_life {
      best_life = game.enemy_bullets[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_flare(game : Game) -> Int {
  for i = 0; i < game.flares.length(); i = i + 1 {
    if not(game.flares[i].active) {
      return i
    }
  }
  let mut best = 0
  let mut best_t = game.flares[0].t
  for i = 1; i < game.flares.length(); i = i + 1 {
    if game.flares[i].t < best_t {
      best_t = game.flares[i].t
      best = i
    }
  }
  best
}

///|
fn alloc_particle(game : Game) -> Int {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      return i
    }
  }
  let mut best = 0
  let mut best_life = game.particles[0].life
  for i = 1; i < game.particles.length(); i = i + 1 {
    if game.particles[i].life < best_life {
      best_life = game.particles[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_shock(game : Game) -> Int {
  for i = 0; i < game.shocks.length(); i = i + 1 {
    if not(game.shocks[i].active) {
      return i
    }
  }
  let mut best = 0
  let mut best_life = game.shocks[0].life
  for i = 1; i < game.shocks.length(); i = i + 1 {
    if game.shocks[i].life < best_life {
      best_life = game.shocks[i].life
      best = i
    }
  }
  best
}

///|
fn spawn_enemy(
  game : Game,
  kind : Int,
  ring : Int,
  angle : Float,
  ang_v : Float,
  hp : Float,
  phase_mask : Int,
) -> Unit {
  let i = alloc_enemy(game)
  game.enemies[i].active = true
  game.enemies[i].kind = kind
  game.enemies[i].ring = ring
  game.enemies[i].angle = wrap_angle(angle)
  game.enemies[i].ang_v = ang_v
  game.enemies[i].hp = hp
  game.enemies[i].fire_cd = randf(0.2, enemy_fire_base)
  game.enemies[i].phase_mask = phase_mask
  game.enemies[i].size = if kind == 0 {
    16.0
  } else if kind == 1 {
    22.0
  } else {
    14.0
  }
  game.enemies[i].spin = randf(0.0, tau)
}

///|
fn spawn_flare(
  game : Game,
  ring : Int,
  angle : Float,
  span : Float,
  spin_v : Float,
  t : Float,
) -> Unit {
  let i = alloc_flare(game)
  game.flares[i].active = true
  game.flares[i].ring = ring
  game.flares[i].angle = wrap_angle(angle)
  game.flares[i].span = span
  game.flares[i].spin_v = spin_v
  game.flares[i].t = t
  game.flares[i].danger = 0.0
}

///|
fn spawn_bullet(
  game : Game,
  ring_f : Float,
  angle : Float,
  vr : Float,
  va : Float,
  life : Float,
  dmg : Float,
  kind : Int,
) -> Unit {
  let i = alloc_bullet(game)
  game.bullets[i].active = true
  game.bullets[i].ring_f = ring_f
  game.bullets[i].angle = wrap_angle(angle)
  game.bullets[i].vr = vr
  game.bullets[i].va = va
  game.bullets[i].life = life
  game.bullets[i].dmg = dmg
  game.bullets[i].kind = kind
}

///|
fn spawn_enemy_bullet(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  dmg : Float,
  kind : Int,
) -> Unit {
  let i = alloc_enemy_bullet(game)
  game.enemy_bullets[i].active = true
  game.enemy_bullets[i].x = x
  game.enemy_bullets[i].y = y
  game.enemy_bullets[i].vx = vx
  game.enemy_bullets[i].vy = vy
  game.enemy_bullets[i].life = life
  game.enemy_bullets[i].dmg = dmg
  game.enemy_bullets[i].kind = kind
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
  let i = alloc_particle(game)
  game.particles[i].active = true
  game.particles[i].x = x
  game.particles[i].y = y
  game.particles[i].vx = vx
  game.particles[i].vy = vy
  game.particles[i].life = life
  game.particles[i].size = size
  game.particles[i].kind = kind
}

///|
fn burst(game : Game, x : Float, y : Float, n : Int, kind : Int) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    emit_particle(
      game,
      x + randf(-16.0, 16.0),
      y + randf(-16.0, 16.0),
      randf(-240.0, 240.0),
      randf(-240.0, 240.0),
      randf(0.24, 0.92),
      randf(1.8, 6.2),
      kind,
    )
  }
}

///|
fn spawn_shock(
  game : Game,
  ring : Int,
  a0 : Float,
  a1 : Float,
  life : Float,
  beta : Bool,
) -> Unit {
  let i = alloc_shock(game)
  game.shocks[i].active = true
  game.shocks[i].ring = ring
  game.shocks[i].a0 = wrap_angle(a0)
  game.shocks[i].a1 = wrap_angle(a1)
  game.shocks[i].life = life
  game.shocks[i].beta = beta
}

///|
fn enemy_world_xy(e : Enemy) -> (Float, Float) {
  let r = ring_radius(e.ring)
  (world_x(r, e.angle), world_y(r, e.angle))
}

///|
fn player_world_xy(player : Player) -> (Float, Float) {
  let r = ring_radius(player.ring)
  (world_x(r, player.angle), world_y(r, player.angle))
}

///|
fn phase_mask_active(mask : Int, beta : Bool) -> Bool {
  if mask == 1 {
    not(beta)
  } else if mask == 2 {
    beta
  } else {
    true
  }
}

///|
fn stage_enemy_hp(game : Game, kind : Int) -> Float {
  if kind == 0 {
    18.0 + Float::from_int(game.stage - 1) * 2.4
  } else if kind == 1 {
    36.0 + Float::from_int(game.stage - 1) * 4.8
  } else {
    12.0 + Float::from_int(game.stage - 1) * 1.8
  }
}

///|
fn begin_stage(game : Game, stage : Int) -> Unit {
  game.stage = stage
  game.stage_time_left = stage_time + Float::from_int(stage - 1) * 2.0
  game.stage_goal = 22 + (stage - 1) * 6
  game.stage_kills = 0
  game.stage_bonus = 0
  game.wave_timer = 0.4
  game.flare_timer = 2.9
}

///|
fn start_run(game : Game) -> Unit {
  clear_enemies(game)
  clear_bullets(game)
  clear_enemy_bullets(game)
  clear_flares(game)
  clear_particles(game)
  clear_shocks(game)
  reset_player(game.player)

  game.state = state_play
  game.score = 0
  game.combo = 0
  game.combo_t = 0.0
  game.hp = 100.0
  game.phase = player_phase_max
  game.phase_beta = false
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.time_s = 0.0
  game.hint_t = 7.0
  game.result_t = 0.0

  game.touch_in_prev = false
  game.touch_out_prev = false
  game.touch_beam_prev = false
  game.touch_restart_prev = false

  begin_stage(game, 1)
}

///|
fn init_title_scene(game : Game) -> Unit {
  clear_enemies(game)
  clear_bullets(game)
  clear_enemy_bullets(game)
  clear_flares(game)
  clear_particles(game)
  clear_shocks(game)
  reset_player(game.player)

  game.state = state_title
  game.stage = 1
  game.stage_time_left = stage_time
  game.stage_goal = 20
  game.stage_kills = 0
  game.stage_bonus = 0
  game.score = 0
  game.combo = 0
  game.combo_t = 0.0
  game.hp = 100.0
  game.phase = player_phase_max
  game.phase_beta = false
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.time_s = 0.0
  game.hint_t = 0.0
  game.result_t = 0.0
  game.wave_timer = 0.3
  game.flare_timer = 2.3

  game.touch_in_prev = false
  game.touch_out_prev = false
  game.touch_beam_prev = false
  game.touch_restart_prev = false
}

///|
fn add_combo_score(game : Game, base : Int) -> Unit {
  game.combo = clampi(game.combo + 1, 0, 999)
  game.combo_t = 3.8
  let mul = f(1) + Float::from_int(game.combo) * 0.08
  game.score = game.score + (Float::from_int(base) * mul).to_int()
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn apply_damage(game : Game, dmg : Float) -> Unit {
  if game.player.invuln > 0.0 {
    return
  }

  game.hp = maxf(0.0, game.hp - dmg)
  game.player.invuln = player_invuln_t
  game.player.hurt_t = 0.3
  game.combo = 0
  game.combo_t = 0.0
  game.flash_t = 0.22
  game.shake_t = 0.22

  let p = player_world_xy(game.player)
  burst(game, p.0, p.1, 20, 2)

  if game.hp <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
    if game.score > game.best_score {
      game.best_score = game.score
    }
  }
}

///|
fn kill_enemy(game : Game, i : Int) -> Unit {
  if not(game.enemies[i].active) {
    return
  }

  let p = enemy_world_xy(game.enemies[i])
  let kind = game.enemies[i].kind
  game.enemies[i].active = false
  game.stage_kills = game.stage_kills + 1

  let base_score = if kind == 0 { 160 } else if kind == 1 { 330 } else { 110 }
  add_combo_score(game, base_score)

  burst(game, p.0, p.1, if kind == 1 { 26 } else { 14 }, 1)
}

///|
fn try_fire(game : Game) -> Unit {
  if game.player.shot_cd > 0.0 {
    return
  }

  let outward = game.input_ring_move >= 0
  let vr : Float = if outward { 3.8 } else { -3.8 }
  spawn_bullet(
    game,
    game.player.ring_f,
    game.player.angle,
    vr,
    game.player.ang_v * 0.18,
    0.92,
    16.0,
    0,
  )

  game.player.shot_cd = player_shot_cd

  let p = player_world_xy(game.player)
  burst(game, p.0, p.1, 5, 0)
}

///|
fn try_beam(game : Game) -> Unit {
  if game.player.beam_cd > 0.0 {
    return
  }

  if game.phase < 24.0 {
    return
  }

  game.player.beam_cd = player_beam_cd
  game.phase = game.phase - 24.0

  let ring = game.player.ring
  let a0 = game.player.angle - 0.36
  let a1 = game.player.angle + 0.36
  spawn_shock(game, ring, a0, a1, 0.34, game.phase_beta)

  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue
    }
    if game.enemies[i].ring != ring {
      continue
    }

    if not(phase_mask_active(game.enemies[i].phase_mask, game.phase_beta)) {
      continue
    }

    let ad = angle_dist(game.player.angle, game.enemies[i].angle)
    if ad <= 0.38 {
      game.enemies[i].hp = game.enemies[i].hp - 36.0
      if game.enemies[i].hp <= 0.0 {
        kill_enemy(game, i)
      }
    }
  }

  let p = player_world_xy(game.player)
  burst(game, p.0, p.1, 18, 1)
}

///|
fn update_player(game : Game, dt : Float) -> Unit {
  let player = game.player
  player.anim_t = player.anim_t + dt

  if player.invuln > 0.0 {
    player.invuln = maxf(0.0, player.invuln - dt)
  }
  if player.hurt_t > 0.0 {
    player.hurt_t = maxf(0.0, player.hurt_t - dt)
  }

  if player.switch_cd > 0.0 {
    player.switch_cd = maxf(0.0, player.switch_cd - dt)
  }
  if player.shot_cd > 0.0 {
    player.shot_cd = maxf(0.0, player.shot_cd - dt)
  }
  if player.beam_cd > 0.0 {
    player.beam_cd = maxf(0.0, player.beam_cd - dt)
  }

  player.ang_v = game.input_turn * player_turn_speed
  player.angle = wrap_angle(player.angle + player.ang_v * dt)

  if game.input_ring_move != 0 && player.switch_cd <= 0.0 {
    player.ring = clampi(player.ring + game.input_ring_move, 0, ring_count - 1)
    player.switch_cd = player_switch_cd
  }

  player.ring_f = lerpf(
    player.ring_f,
    Float::from_int(player.ring),
    clampf(dt * 12.0, 0.0, 1.0),
  )

  if game.input_fire_hold {
    try_fire(game)
  }
  if game.input_beam_press {
    try_beam(game)
  }

  if game.phase_beta {
    game.phase = maxf(0.0, game.phase - phase_drain * dt)
    if game.phase <= 0.0 {
      game.phase_beta = false
    }
  } else {
    game.phase = minf(player_phase_max, game.phase + phase_recover * dt)
  }
}

///|
fn enemy_phase_mask_random() -> Int {
  let pick = randi(0, 99)
  if pick < 52 {
    0
  } else if pick < 76 {
    1
  } else {
    2
  }
}

///|
fn spawn_enemy_wave(game : Game) -> Unit {
  let wave_kind = randi(0, 99)

  if wave_kind < 28 {
    let ring = randi(0, ring_count - 1)
    for i = 0; i < 5; i = i + 1 {
      let a = randf(-pi, pi)
      spawn_enemy(
        game,
        0,
        ring,
        a,
        randf(-2.2, 2.2),
        stage_enemy_hp(game, 0),
        enemy_phase_mask_random(),
      )
    }
  } else if wave_kind < 56 {
    for ring = 0; ring < ring_count; ring = ring + 1 {
      spawn_enemy(
        game,
        0,
        ring,
        randf(-pi, pi),
        randf(-1.9, 1.9),
        stage_enemy_hp(game, 0),
        enemy_phase_mask_random(),
      )
    }
    let ring_big = randi(0, ring_count - 1)
    spawn_enemy(
      game,
      1,
      ring_big,
      randf(-pi, pi),
      randf(-1.2, 1.2),
      stage_enemy_hp(game, 1),
      enemy_phase_mask_random(),
    )
  } else if wave_kind < 78 {
    let center = randf(-pi, pi)
    for i = -2; i <= 2; i = i + 1 {
      let ring = clampi(1 + i % ring_count, 0, ring_count - 1)
      spawn_enemy(
        game,
        2,
        ring,
        wrap_angle(center + Float::from_int(i) * 0.34),
        randf(-2.8, 2.8),
        stage_enemy_hp(game, 2),
        enemy_phase_mask_random(),
      )
    }
  } else {
    for _i = 0; _i < 8; _i = _i + 1 {
      let ring = randi(0, ring_count - 1)
      let kind_pick = randi(0, 99)
      let kind = if kind_pick < 65 { 0 } else if kind_pick < 86 { 2 } else { 1 }
      spawn_enemy(
        game,
        kind,
        ring,
        randf(-pi, pi),
        randf(-2.4, 2.4),
        stage_enemy_hp(game, kind),
        enemy_phase_mask_random(),
      )
    }
  }
}

///|
fn spawn_flare_event(game : Game) -> Unit {
  let flare_n = if game.stage <= 2 {
    1
  } else if game.stage <= 4 {
    2
  } else {
    3
  }
  for _i = 0; _i < flare_n; _i = _i + 1 {
    spawn_flare(
      game,
      randi(0, ring_count - 1),
      randf(-pi, pi),
      randf(0.18, 0.42),
      randf(-1.8, 1.8),
      randf(1.8, 3.2),
    )
  }
}

///|
fn update_enemies(game : Game, dt : Float) -> Unit {
  let player_xy = player_world_xy(game.player)

  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue
    }

    let e = game.enemies[i]
    let speed_mul : Float = enemy_base_speed +
      Float::from_int(game.stage - 1) * enemy_speed_stage
    let chase : Float = if e.kind == 1 {
      0.18
    } else if e.kind == 2 {
      0.07
    } else {
      0.12
    }

    let target_offset : Float = if e.kind == 2 { pi * 0.5 } else { 0.0 }
    let target_a : Float = game.player.angle + target_offset
    let turn = shortest_angle(e.angle, target_a)

    e.ang_v = e.ang_v + turn * chase * dt
    e.ang_v = clampf(e.ang_v, -2.8, 2.8)
    e.angle = wrap_angle(e.angle + e.ang_v * dt * speed_mul)
    e.spin = e.spin + dt * (if e.kind == 2 { 3.8 } else { 2.2 })

    e.fire_cd = e.fire_cd - dt

    if e.fire_cd <= 0.0 {
      if phase_mask_active(e.phase_mask, game.phase_beta) {
        let ep = enemy_world_xy(e)
        let dx = player_xy.0 - ep.0
        let dy = player_xy.1 - ep.1
        let d = maxf(0.01, sqrtf(dx * dx + dy * dy))

        let sp : Float = if e.kind == 1 {
          160.0
        } else if e.kind == 2 {
          220.0
        } else {
          185.0
        }
        spawn_enemy_bullet(
          game,
          ep.0,
          ep.1,
          dx / d * sp,
          dy / d * sp,
          2.8,
          if e.kind == 1 {
            16.0
          } else {
            11.0
          },
          e.kind,
        )
      }

      e.fire_cd = enemy_fire_base -
        Float::from_int(game.stage - 1) * 0.06 +
        randf(0.0, 0.8)
      e.fire_cd = maxf(0.26, e.fire_cd)
    }

    if e.kind == 2 {
      let p = enemy_world_xy(e)
      if dist2(p.0, p.1, player_xy.0, player_xy.1) <= 34.0 * 34.0 {
        apply_damage(game, 16.0)
        e.hp = e.hp - 40.0
        if e.hp <= 0.0 {
          kill_enemy(game, i)
        }
      }
    }
  }
}

///|
fn update_bullets(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      continue
    }

    let b = game.bullets[i]
    b.life = b.life - dt
    if b.life <= 0.0 {
      b.active = false
      continue
    }

    b.ring_f = b.ring_f + b.vr * dt
    b.angle = wrap_angle(b.angle + b.va * dt)

    if b.ring_f < -0.5 || b.ring_f > Float::from_int(ring_count - 1) + 0.8 {
      b.active = false
      continue
    }

    for j = 0; j < game.enemies.length(); j = j + 1 {
      if not(game.enemies[j].active) {
        continue
      }

      if not(phase_mask_active(game.enemies[j].phase_mask, game.phase_beta)) {
        continue
      }

      let ring_d = absf(Float::from_int(game.enemies[j].ring) - b.ring_f)
      if ring_d > 0.34 {
        continue
      }

      let ang_d = angle_dist(game.enemies[j].angle, b.angle)
      if ang_d > 0.24 {
        continue
      }

      game.enemies[j].hp = game.enemies[j].hp - b.dmg
      b.active = false

      let p = enemy_world_xy(game.enemies[j])
      burst(game, p.0, p.1, 8, 0)

      if game.enemies[j].hp <= 0.0 {
        kill_enemy(game, j)
      }

      break
    }
  }
}

///|
fn update_enemy_bullets(game : Game, dt : Float) -> Unit {
  let player_xy = player_world_xy(game.player)

  for i = 0; i < game.enemy_bullets.length(); i = i + 1 {
    if not(game.enemy_bullets[i].active) {
      continue
    }

    let b = game.enemy_bullets[i]
    b.life = b.life - dt
    if b.life <= 0.0 {
      b.active = false
      continue
    }

    b.x = b.x + b.vx * dt
    b.y = b.y + b.vy * dt

    if dist2(b.x, b.y, player_xy.0, player_xy.1) <= player_hit_r * player_hit_r {
      apply_damage(game, b.dmg)
      b.active = false
      continue
    }

    if absf(b.x) > 520.0 || absf(b.y) > 520.0 {
      b.active = false
    }
  }
}

///|
fn update_flares(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.flares.length(); i = i + 1 {
    if not(game.flares[i].active) {
      continue
    }

    let f0 = game.flares[i]
    f0.t = f0.t - dt
    if f0.t <= 0.0 {
      f0.active = false
      continue
    }

    f0.angle = wrap_angle(f0.angle + f0.spin_v * dt)

    let p = clampf(f0.t / 3.0, 0.0, 1.0)
    f0.danger = 1.0 - p

    if p < 0.45 {
      continue
    }

    if f0.ring != game.player.ring {
      continue
    }

    let ad = angle_dist(game.player.angle, f0.angle)
    if ad <= f0.span {
      apply_damage(game, 9.0 * dt * 8.0)
    }
  }
}

///|
fn update_particles(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue
    }

    let p = game.particles[i]
    p.life = p.life - dt
    if p.life <= 0.0 {
      p.active = false
      continue
    }

    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.vx = p.vx * (1.0 - dt * 2.2)
    p.vy = p.vy * (1.0 - dt * 2.2)
  }

  for i = 0; i < game.shocks.length(); i = i + 1 {
    if not(game.shocks[i].active) {
      continue
    }

    game.shocks[i].life = game.shocks[i].life - dt
    if game.shocks[i].life <= 0.0 {
      game.shocks[i].active = false
    }
  }
}

///|
fn update_stage_flow(game : Game, dt : Float) -> Unit {
  game.stage_time_left = game.stage_time_left - dt

  if game.combo_t > 0.0 {
    game.combo_t = maxf(0.0, game.combo_t - dt)
    if game.combo_t <= 0.0 {
      game.combo = 0
    }
  }

  if game.flash_t > 0.0 {
    game.flash_t = maxf(0.0, game.flash_t - dt)
  }
  if game.shake_t > 0.0 {
    game.shake_t = maxf(0.0, game.shake_t - dt)
  }

  if game.stage_time_left > 0.0 {
    let passive = (dt * (20.0 + Float::from_int(game.stage * 2))).to_int()
    game.score = game.score + passive
    if game.score > game.best_score {
      game.best_score = game.score
    }
  }

  if game.wave_timer > 0.0 {
    game.wave_timer = game.wave_timer - dt
  }
  if game.wave_timer <= 0.0 {
    spawn_enemy_wave(game)
    let base : Float = 3.6 - Float::from_int(game.stage - 1) * 0.22
    game.wave_timer = maxf(1.2, base) + randf(0.0, 0.9)
  }

  if game.flare_timer > 0.0 {
    game.flare_timer = game.flare_timer - dt
  }
  if game.flare_timer <= 0.0 {
    spawn_flare_event(game)
    game.flare_timer = maxf(2.2, 6.2 - Float::from_int(game.stage - 1) * 0.3) +
      randf(0.0, 1.4)
  }

  let win_by_kills = game.stage_kills >= game.stage_goal
  let win_by_time = game.stage_time_left <= 0.0

  if win_by_kills || win_by_time {
    game.state = state_stage_clear
    game.result_t = stage_clear_delay
    game.stage_bonus = 520 + game.stage_kills * 12 + (game.hp * 5.0).to_int()
    game.score = game.score + game.stage_bonus
    if game.score > game.best_score {
      game.best_score = game.score
    }
    game.flash_t = 0.4

    let p = player_world_xy(game.player)
    burst(game, p.0, p.1, 28, 1)
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  if game.input_pause_press {
    init_title_scene(game)
    return
  }

  game.time_s = game.time_s + dt
  if game.hint_t > 0.0 {
    game.hint_t = maxf(0.0, game.hint_t - dt)
  }

  update_player(game, dt)
  update_enemies(game, dt)
  update_bullets(game, dt)
  update_enemy_bullets(game, dt)
  update_flares(game, dt)
  update_particles(game, dt)
  update_stage_flow(game, dt)

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  update_particles(game, dt)
  if game.flash_t > 0.0 {
    game.flash_t = maxf(0.0, game.flash_t - dt)
  }

  game.result_t = game.result_t - dt
  if game.result_t <= 0.0 {
    begin_stage(game, game.stage + 1)
    game.state = state_play

    clear_enemies(game)
    clear_enemy_bullets(game)
    clear_flares(game)

    game.phase = minf(player_phase_max, game.phase + 24.0)
    game.hp = minf(100.0, game.hp + 12.0)
    game.hint_t = 1.8
  }

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_game_over(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  update_particles(game, dt)

  if game.input_restart_press || (game.result_t > 0.4 && game.input_fire_hold) {
    start_run(game)
  }
}

///|
fn update_title(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt

  if game.wave_timer > 0.0 {
    game.wave_timer = game.wave_timer - dt
  }
  if game.wave_timer <= 0.0 {
    spawn_enemy_wave(game)
    game.wave_timer = 2.8 + randf(0.0, 1.0)
  }

  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue
    }

    game.enemies[i].angle = wrap_angle(
      game.enemies[i].angle + game.enemies[i].ang_v * dt * 0.42,
    )
    game.enemies[i].spin = game.enemies[i].spin + dt * 1.3
  }

  if game.flare_timer > 0.0 {
    game.flare_timer = game.flare_timer - dt
  }
  if game.flare_timer <= 0.0 {
    spawn_flare_event(game)
    game.flare_timer = 2.4 + randf(0.0, 1.2)
  }

  update_flares(game, dt)
  update_particles(game, dt)

  if game.input_fire_hold || game.input_beam_press || game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  if game.state == state_title {
    update_title(game, dt)
    return
  }

  if game.state == state_play {
    update_play(game, dt)
    return
  }

  if game.state == state_stage_clear {
    update_stage_clear(game, dt)
    return
  }

  update_game_over(game, dt)
}
