///|
fn clear_objs(game : Game) -> Unit {
  for i = 0; i < game.objs.length(); i = i + 1 {
    game.objs[i].active = false
    game.objs[i].kind = obj_wall
    game.objs[i].lane = 0
    game.objs[i].z = 0.0
    game.objs[i].y_off = 0.0
    game.objs[i].w = 0.0
    game.objs[i].h = 0.0
    game.objs[i].phase_only = 0
    game.objs[i].spin = 0.0
    game.objs[i].hit_lock = 0.0
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
fn clear_trails(game : Game) -> Unit {
  for i = 0; i < game.trails.length(); i = i + 1 {
    game.trails[i].active = false
    game.trails[i].x = 0.0
    game.trails[i].y = 0.0
    game.trails[i].w = 0.0
    game.trails[i].h = 0.0
    game.trails[i].life = 0.0
    game.trails[i].beta = false
  }
}

///|
fn reset_hero(hero : Player) -> Unit {
  hero.lane = 2
  hero.lane_f = lane_world_x(hero.lane)
  hero.y = 0.0
  hero.vy = 0.0
  hero.jump_buf = 0.0
  hero.grounded = true
  hero.invuln_t = 0.0
  hero.hurt_t = 0.0
  hero.anim_t = 0.0
}

///|
fn alloc_obj_slot(game : Game) -> Int {
  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_z = game.objs[0].z
  for i = 1; i < game.objs.length(); i = i + 1 {
    if game.objs[i].z < best_z {
      best_z = game.objs[i].z
      best_i = i
    }
  }
  best_i
}

///|
fn alloc_particle_slot(game : Game) -> Int {
  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_life = game.particles[0].life
  for i = 1; i < game.particles.length(); i = i + 1 {
    if game.particles[i].life < best_life {
      best_life = game.particles[i].life
      best_i = i
    }
  }
  best_i
}

///|
fn alloc_trail_slot(game : Game) -> Int {
  for i = 0; i < game.trails.length(); i = i + 1 {
    if not(game.trails[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_life = game.trails[0].life
  for i = 1; i < game.trails.length(); i = i + 1 {
    if game.trails[i].life < best_life {
      best_life = game.trails[i].life
      best_i = i
    }
  }
  best_i
}

///|
fn spawn_obj(
  game : Game,
  kind : Int,
  lane : Int,
  z : Float,
  y_off : Float,
  w : Float,
  h : Float,
  phase_only : Int,
) -> Unit {
  let i = alloc_obj_slot(game)
  game.objs[i].active = true
  game.objs[i].kind = kind
  game.objs[i].lane = lane
  game.objs[i].z = z
  game.objs[i].y_off = y_off
  game.objs[i].w = w
  game.objs[i].h = h
  game.objs[i].phase_only = phase_only
  game.objs[i].spin = randf(0.0, 6.28)
  game.objs[i].hit_lock = 0.0
}

///|
fn spawn_particle(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  let i = alloc_particle_slot(game)
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
fn burst(game : Game, x : Float, y : Float, amount : Int, kind : Int) -> Unit {
  for _i = 0; _i < amount; _i = _i + 1 {
    spawn_particle(
      game,
      x + randf(-24.0, 24.0),
      y + randf(-16.0, 16.0),
      randf(-420.0, 420.0),
      randf(-420.0, 160.0),
      randf(0.26, 1.1),
      randf(2.0, 7.2),
      kind,
    )
  }
}

///|
fn spawn_trail(
  game : Game,
  lane_x : Float,
  jump_y : Float,
  beta : Bool,
) -> Unit {
  let i = alloc_trail_slot(game)
  game.trails[i].active = true
  game.trails[i].x = lane_x
  game.trails[i].y = jump_y
  game.trails[i].w = 74.0
  game.trails[i].h = 20.0
  game.trails[i].life = 0.18
  game.trails[i].beta = beta
}

///|
fn set_stage(game : Game, stage : Int) -> Unit {
  game.stage = stage
  game.stage_goal = stage_base_distance +
    Float::from_int(stage - 1) * stage_distance_growth
  game.stage_progress = 0.0
  game.speed = base_speed + Float::from_int(stage - 1) * speed_stage_gain
}

///|
fn spawn_orb_strip(game : Game, z0 : Float, len : Int, lane : Int) -> Unit {
  for i = 0; i < len; i = i + 1 {
    spawn_obj(
      game,
      obj_orb,
      lane,
      z0 + Float::from_int(i) * 72.0,
      48.0 + sinf(Float::from_int(i) * 0.8) * 16.0,
      56.0,
      56.0,
      0,
    )
  }
}

///|
fn spawn_wave(game : Game, z_base : Float) -> Unit {
  let p = randi(0, 99)

  if p < 20 {
    let safe = randi(0, lane_count - 1)
    for lane = 0; lane < lane_count; lane = lane + 1 {
      if lane == safe {
        spawn_orb_strip(game, z_base + 30.0, 4, lane)
      } else {
        spawn_obj(
          game,
          obj_wall,
          lane,
          z_base + randf(0.0, 56.0),
          0.0,
          110.0,
          180.0,
          0,
        )
      }
    }
  } else if p < 36 {
    let mut lane = randi(0, lane_count - 1)
    for i = 0; i < 6; i = i + 1 {
      spawn_obj(
        game,
        obj_wall,
        lane,
        z_base + Float::from_int(i) * 170.0,
        0.0,
        102.0,
        178.0,
        0,
      )
      if chance(70) {
        let step_dir = if chance(50) { 1 } else { -1 }
        lane = clampi(lane + step_dir, 0, lane_count - 1)
      }
    }
  } else if p < 54 {
    for lane = 0; lane < lane_count; lane = lane + 1 {
      spawn_obj(
        game,
        obj_gate_alpha,
        lane,
        z_base + Float::from_int(lane) * 36.0,
        0.0,
        96.0,
        176.0,
        1,
      )
      spawn_obj(
        game,
        obj_gate_beta,
        lane,
        z_base + 260.0 + Float::from_int(lane) * 36.0,
        0.0,
        96.0,
        176.0,
        2,
      )
    }
    spawn_orb_strip(game, z_base + 122.0, 5, randi(0, lane_count - 1))
  } else if p < 72 {
    let lane = randi(0, lane_count - 1)
    spawn_obj(game, obj_boost, lane, z_base + 180.0, 0.0, 112.0, 48.0, 0)
    spawn_orb_strip(game, z_base + 20.0, 3, lane)
    for i = 0; i < 5; i = i + 1 {
      let l = (lane + i + 1) % lane_count
      spawn_obj(
        game,
        obj_wall,
        l,
        z_base + 300.0 + Float::from_int(i) * 60.0,
        0.0,
        108.0,
        180.0,
        0,
      )
    }
  } else if p < 88 {
    let lane = randi(0, lane_count - 1)
    for i = 0; i < 7; i = i + 1 {
      spawn_obj(
        game,
        obj_jump_bar,
        lane,
        z_base + Float::from_int(i) * 130.0,
        0.0,
        108.0,
        72.0,
        0,
      )
      if i % 2 == 0 {
        let side_step = if chance(50) { 1 } else { -1 }
        let side_lane = clampi(lane + side_step, 0, lane_count - 1)
        spawn_obj(
          game,
          obj_orb,
          side_lane,
          z_base + Float::from_int(i) * 130.0 + 32.0,
          62.0,
          56.0,
          56.0,
          0,
        )
      }
    }
  } else {
    for i = 0; i < 10; i = i + 1 {
      let lane = randi(0, lane_count - 1)
      let kind = if chance(70) { obj_orb } else { obj_wall }
      let y_off : Float = if kind == obj_orb {
        Float::from_int(46) + sinf(Float::from_int(i)) * Float::from_int(22)
      } else {
        0.0
      }
      let w : Float = if kind == obj_orb { 56.0 } else { 96.0 }
      let h : Float = if kind == obj_orb { 56.0 } else { 172.0 }
      spawn_obj(
        game,
        kind,
        lane,
        z_base + Float::from_int(i) * 110.0,
        y_off,
        w,
        h,
        0,
      )
    }
  }
}

///|
fn ensure_spawns(game : Game) -> Unit {
  while game.next_spawn_z < 3000.0 {
    spawn_wave(game, game.next_spawn_z)
    let step = randf(240.0, 420.0) - Float::from_int(game.stage - 1) * 4.0
    game.next_spawn_z = game.next_spawn_z + maxf(180.0, step)
  }
}

///|
fn apply_damage(game : Game, amount : Float) -> Unit {
  if game.hero.invuln_t > 0.0 {
    return
  }

  game.health = game.health - amount
  game.health = maxf(0.0, game.health)
  game.combo = 0
  game.combo_t = 0.0
  game.hero.invuln_t = invuln_time
  game.hero.hurt_t = 0.30
  game.flash_t = 0.24
  game.shake_t = 0.28

  burst(game, game.hero.lane_f, game.hero.y + 42.0, 24, 2)

  if game.health <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
    if game.score > game.best_score {
      game.best_score = game.score
    }
  }
}

///|
fn start_run(game : Game) -> Unit {
  clear_objs(game)
  clear_particles(game)
  clear_trails(game)
  reset_hero(game.hero)

  game.state = state_play
  set_stage(game, 1)
  game.speed_mul = 1.0
  game.boost_t = 0.0
  game.score = 0
  game.stage_bonus = 0
  game.combo = 0
  game.combo_t = 0.0
  game.orbs = 0
  game.health = 100.0
  game.phase_energy = 100.0
  game.phase_beta = false
  game.phase_cd = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 9.0
  game.next_spawn_z = 380.0

  game.touch_left_prev = false
  game.touch_right_prev = false
  game.touch_jump_prev = false
  game.touch_phase_prev = false
  game.touch_restart_prev = false

  ensure_spawns(game)
}

///|
fn init_title_scene(game : Game) -> Unit {
  clear_objs(game)
  clear_particles(game)
  clear_trails(game)
  reset_hero(game.hero)

  game.state = state_title
  game.stage = 1
  game.stage_goal = stage_base_distance
  game.stage_progress = 0.0
  game.speed = base_speed * 0.55
  game.speed_mul = 1.0
  game.boost_t = 0.0
  game.score = 0
  game.stage_bonus = 0
  game.combo = 0
  game.combo_t = 0.0
  game.orbs = 0
  game.health = 100.0
  game.phase_energy = 100.0
  game.phase_beta = false
  game.phase_cd = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.title_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0
  game.next_spawn_z = 420.0

  ensure_spawns(game)
}

///|
fn handle_lane_input(game : Game) -> Unit {
  if game.input_move == 0 {
    return
  }

  game.hero.lane = clampi(game.hero.lane + game.input_move, 0, lane_count - 1)
}

///|
fn update_player(game : Game, dt : Float) -> Unit {
  let hero = game.hero
  hero.anim_t = hero.anim_t + dt

  if hero.invuln_t > 0.0 {
    hero.invuln_t = maxf(0.0, hero.invuln_t - dt)
  }
  if hero.hurt_t > 0.0 {
    hero.hurt_t = maxf(0.0, hero.hurt_t - dt)
  }

  handle_lane_input(game)

  let lane_target = lane_world_x(hero.lane)
  hero.lane_f = lerpf(hero.lane_f, lane_target, clampf(dt * 12.0, 0.0, 1.0))

  if game.input_jump_press {
    hero.jump_buf = 0.12
  } else {
    hero.jump_buf = maxf(0.0, hero.jump_buf - dt)
  }

  if hero.grounded && hero.jump_buf > 0.0 {
    hero.vy = player_jump_speed
    hero.grounded = false
    hero.jump_buf = 0.0
    burst(game, hero.lane_f, 10.0, 10, 0)
  }

  if not(hero.grounded) {
    hero.vy = hero.vy - player_gravity * dt
    if hero.vy > 0.0 && not(game.input_jump_hold) {
      hero.vy = hero.vy - player_gravity * dt * 0.75
    }
    hero.y = hero.y + hero.vy * dt
    if hero.y <= 0.0 {
      hero.y = 0.0
      hero.vy = 0.0
      hero.grounded = true
    }
  }

  let gate : Float = if hero.y > 2.0 { 0.032 } else { 0.046 }
  let now_tick = (hero.anim_t / gate).to_int()
  let prev_tick = ((hero.anim_t - dt) / gate).to_int()
  if now_tick != prev_tick {
    spawn_trail(game, hero.lane_f, hero.y, game.phase_beta)
  }
}

///|
fn update_phase(game : Game, dt : Float) -> Unit {
  if game.phase_cd > 0.0 {
    game.phase_cd = maxf(0.0, game.phase_cd - dt)
  }

  if game.input_phase_press && game.phase_cd <= 0.0 {
    if game.phase_beta {
      game.phase_beta = false
      game.phase_cd = phase_switch_cd
      burst(game, game.hero.lane_f, game.hero.y + 34.0, 8, 0)
    } else if game.phase_energy > 8.0 {
      game.phase_beta = true
      game.phase_energy = game.phase_energy - 8.0
      game.phase_cd = phase_switch_cd
      burst(game, game.hero.lane_f, game.hero.y + 34.0, 8, 1)
    }
  }

  if game.phase_beta {
    game.phase_energy = maxf(0.0, game.phase_energy - phase_drain_per_sec * dt)
    if game.phase_energy <= 0.0 {
      game.phase_beta = false
      game.phase_cd = phase_switch_cd
    }
  } else {
    game.phase_energy = minf(
      100.0,
      game.phase_energy + phase_recover_per_sec * dt,
    )
  }
}

///|
fn combo_mul(game : Game) -> Float {
  1.0 + Float::from_int(game.combo) * 0.08
}

///|
fn mark_hit_obj(o : TrackObj) -> Unit {
  o.hit_lock = 0.18
}

///|
fn obj_affects_phase(game : Game, o : TrackObj) -> Bool {
  if o.phase_only == 1 {
    return not(game.phase_beta)
  }
  if o.phase_only == 2 {
    return game.phase_beta
  }
  true
}

///|
fn update_objects(game : Game, dt : Float) -> Unit {
  let dz = game.speed * game.speed_mul * dt
  game.stage_progress = game.stage_progress + dz

  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      continue
    }

    let o = game.objs[i]
    o.z = o.z - dz
    o.spin = o.spin + dt * 2.0

    if o.hit_lock > 0.0 {
      o.hit_lock = maxf(0.0, o.hit_lock - dt)
    }

    if o.z < -180.0 {
      o.active = false
      continue
    }

    if o.z > 130.0 || o.z < -24.0 {
      continue
    }

    let lane_dx = lane_world_x(o.lane) - game.hero.lane_f
    let same_lane = lane_dx * lane_dx < 70.0 * 70.0
    if not(same_lane) {
      continue
    }

    if o.kind == obj_orb {
      let d2 = dist2(
        lane_world_x(o.lane),
        o.y_off + 24.0,
        game.hero.lane_f,
        game.hero.y + 14.0,
      )
      if d2 < 78.0 * 78.0 {
        o.active = false
        game.orbs = game.orbs + 1
        game.combo = clampi(game.combo + 1, 0, 999)
        game.combo_t = combo_decay_time
        game.score = game.score +
          (Float::from_int(96 + game.combo * 6) * combo_mul(game)).to_int()
        burst(game, lane_world_x(o.lane), o.y_off + 22.0, 10, 0)
      }
      continue
    }

    if o.kind == obj_boost {
      if game.hero.y <= 48.0 {
        o.active = false
        game.boost_t = 1.4
        game.speed_mul = 1.78
        game.score = game.score + 280
        burst(game, lane_world_x(o.lane), 22.0, 16, 1)
      }
      continue
    }

    if not(obj_affects_phase(game, o)) {
      continue
    }

    if o.hit_lock > 0.0 {
      continue
    }

    if o.kind == obj_jump_bar {
      if game.hero.y > 84.0 {
        continue
      }
      mark_hit_obj(o)
      apply_damage(game, 14.0)
      continue
    }

    if o.kind == obj_gate_alpha || o.kind == obj_gate_beta {
      if game.hero.y > 106.0 {
        continue
      }
      mark_hit_obj(o)
      apply_damage(game, 17.0)
      continue
    }

    if o.kind == obj_wall {
      if game.hero.y > 120.0 {
        continue
      }
      mark_hit_obj(o)
      apply_damage(game, 20.0)
      continue
    }
  }

  ensure_spawns(game)

  if game.boost_t > 0.0 {
    game.boost_t = maxf(0.0, game.boost_t - dt)
    game.speed_mul = approachf(game.speed_mul, 1.0, dt * 1.4)
  } else {
    game.speed_mul = approachf(game.speed_mul, 1.0, dt * 2.6)
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
    game.particles[i].vx = game.particles[i].vx * (1.0 - dt * 2.3)
    game.particles[i].vy = game.particles[i].vy * (1.0 - dt * 1.8) - dt * 140.0
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
fn update_score(game : Game, dt : Float) -> Unit {
  if game.combo_t > 0.0 {
    game.combo_t = maxf(0.0, game.combo_t - dt)
    if game.combo_t <= 0.0 {
      game.combo = 0
    }
  }

  let points = (game.speed * game.speed_mul * dt * 0.10 * combo_mul(game)).to_int()
  game.score = game.score + points

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  if game.input_pause_press {
    init_title_scene(game)
    return
  }

  if game.hint_t > 0.0 {
    game.hint_t = maxf(0.0, game.hint_t - dt)
  }

  update_player(game, dt)
  update_phase(game, dt)
  update_objects(game, dt)
  update_particles(game, dt)
  update_score(game, dt)

  if game.flash_t > 0.0 {
    game.flash_t = maxf(0.0, game.flash_t - dt)
  }
  if game.shake_t > 0.0 {
    game.shake_t = maxf(0.0, game.shake_t - dt)
  }

  if game.stage_progress >= game.stage_goal {
    game.state = state_stage_clear
    game.result_t = 1.7
    game.stage_bonus = 520 + game.combo * 14 + (game.health * 5.0).to_int()
    game.score = game.score + game.stage_bonus
    if game.score > game.best_score {
      game.best_score = game.score
    }
    game.flash_t = 0.34
    burst(game, game.hero.lane_f, game.hero.y + 26.0, 34, 1)
  }

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  update_particles(game, dt)

  game.result_t = game.result_t - dt
  if game.result_t <= 0.0 {
    set_stage(game, game.stage + 1)
    game.state = state_play
    game.result_t = 0.0
    game.stage_bonus = 0
    game.health = minf(100.0, game.health + 15.0)
    game.hint_t = 2.0
  }

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_game_over(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  update_particles(game, dt)

  if game.input_restart_press || (game.result_t > 0.35 && game.input_jump_press) {
    start_run(game)
  }
}

///|
fn update_title_scene(game : Game, dt : Float) -> Unit {
  game.title_t = game.title_t + dt

  let demo_dz = base_speed * 0.52 * dt
  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      continue
    }

    game.objs[i].z = game.objs[i].z - demo_dz
    game.objs[i].spin = game.objs[i].spin + dt * 2.0
    if game.objs[i].z < -180.0 {
      game.objs[i].active = false
    }
  }

  ensure_spawns(game)
  update_particles(game, dt)

  if game.input_jump_press || game.input_phase_press || game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  if game.state == state_title {
    update_title_scene(game, dt)
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
