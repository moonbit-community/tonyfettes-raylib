///|
fn clear_objs(game : Game) -> Unit {
  for i = 0; i < game.objs.length(); i = i + 1 {
    game.objs[i].active = false
    game.objs[i].kind = obj_rock
    game.objs[i].x = 0.0
    game.objs[i].y = 0.0
    game.objs[i].vx = 0.0
    game.objs[i].vy = 0.0
    game.objs[i].r = 0.0
    game.objs[i].cloak = false
    game.objs[i].spin = 0.0
    game.objs[i].life = 0.0
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
fn clear_ripples(game : Game) -> Unit {
  for i = 0; i < game.ripples.length(); i = i + 1 {
    game.ripples[i].active = false
    game.ripples[i].x = 0.0
    game.ripples[i].y = 0.0
    game.ripples[i].r = 0.0
    game.ripples[i].life = 0.0
    game.ripples[i].kind = 0
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
    game.trails[i].kind = 0
  }
}

///|
fn reset_hero(hero : Player) -> Unit {
  hero.x = Float::from_int(screen_w / 2)
  hero.y = Float::from_int(screen_h) * 0.72
  hero.vx = 0.0
  hero.vy = 0.0
  hero.r = player_r
  hero.invuln = 0.0
  hero.hurt_t = 0.0
  hero.anim_t = 0.0
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
fn alloc_ripple(game : Game) -> Int {
  for i = 0; i < game.ripples.length(); i = i + 1 {
    if not(game.ripples[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.ripples[0].life
  for i = 1; i < game.ripples.length(); i = i + 1 {
    if game.ripples[i].life < best_life {
      best_life = game.ripples[i].life
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
      x + randf(-14.0, 14.0),
      y + randf(-14.0, 14.0),
      randf(-220.0, 220.0),
      randf(-220.0, 220.0),
      randf(0.24, 1.02),
      randf(1.8, 6.8),
      kind,
    )
  }
}

///|
fn spawn_ripple(
  game : Game,
  x : Float,
  y : Float,
  r : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = alloc_ripple(game)
  game.ripples[i].active = true
  game.ripples[i].x = x
  game.ripples[i].y = y
  game.ripples[i].r = r
  game.ripples[i].life = life
  game.ripples[i].kind = kind
}

///|
fn emit_trail(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  life : Float,
  kind : Int,
) -> Unit {
  let i = alloc_trail(game)
  game.trails[i].active = true
  game.trails[i].x = x
  game.trails[i].y = y
  game.trails[i].w = w
  game.trails[i].h = h
  game.trails[i].life = life
  game.trails[i].kind = kind
}

///|
fn spawn_obj(
  game : Game,
  kind : Int,
  x : Float,
  y : Float,
  r : Float,
  vx : Float,
  vy : Float,
  cloak : Bool,
  life : Float,
) -> Unit {
  let i = alloc_obj(game)
  game.objs[i].active = true
  game.objs[i].kind = kind
  game.objs[i].x = x
  game.objs[i].y = y
  game.objs[i].r = r
  game.objs[i].vx = vx
  game.objs[i].vy = vy
  game.objs[i].cloak = cloak
  game.objs[i].spin = randf(0.0, 6.283)
  game.objs[i].life = life
}

///|
fn depth_at_screen(game : Game, y : Float) -> Float {
  game.distance + (Float::from_int(screen_h) - y)
}

///|
fn cave_edges(game : Game, y : Float) -> (Float, Float) {
  let d = depth_at_screen(game, y)
  let c = cave_center(d, game.time_s)
  let hw = cave_half_width(d, game.time_s, game.stage)
  (c - hw, c + hw)
}

///|
fn object_spawn_x(game : Game, y : Float, r : Float) -> Float {
  let d = depth_at_screen(game, y)
  let c = cave_center(d, game.time_s)
  let hw = cave_half_width(d, game.time_s, game.stage)
  let mut lo = c - hw + cave_x_margin + r
  let mut hi = c + hw - cave_x_margin - r
  if hi < lo {
    let mid = c
    lo = mid - 10.0
    hi = mid + 10.0
  }
  clampf(randf(lo, hi), lo, hi)
}

///|
fn score_gain(game : Game, base : Int) -> Int {
  let bonus = base * game.combo / 4
  base + bonus
}

///|
fn add_score(game : Game, base : Int) -> Unit {
  let gained = score_gain(game, base)
  game.score = game.score + gained
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn push_combo(game : Game) -> Unit {
  game.combo = clampi(game.combo + 1, 0, 18)
  game.combo_t = 3.4
}

///|
fn hurt_hero(game : Game, dmg : Float) -> Unit {
  if game.hero.invuln > 0.0 {
    return
  }

  game.hull = maxf(0.0, game.hull - dmg)
  game.hero.invuln = invuln_time
  game.hero.hurt_t = 0.56
  game.flash_t = maxf(game.flash_t, 0.34)
  game.shake_t = maxf(game.shake_t, 0.55)
  game.combo = 0
  game.combo_t = 0.0

  burst(game, game.hero.x, game.hero.y, 22, 1)

  if game.hull <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }
}

///|
fn start_new_stage(game : Game, stage : Int) -> Unit {
  clear_objs(game)
  clear_particles(game)
  clear_ripples(game)
  clear_trails(game)

  reset_hero(game.hero)

  game.state = state_play
  game.stage = stage
  game.distance = 0.0
  game.stage_goal = stage_base_goal +
    Float::from_int(stage - 1) * stage_goal_gain
  game.scroll_speed = base_scroll +
    Float::from_int(stage - 1) * stage_scroll_gain
  game.next_spawn_y = spawn_start_y

  game.sonar_cd = 0.0
  game.sonar_t = 0.0
  game.dash_cd = 0.0
  game.dash_t = 0.0
  game.combo = 0
  game.combo_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0

  if stage <= 1 {
    game.hull = 100.0
    game.oxygen = 100.0
    game.score = 0
    game.data_collected = 0
  } else {
    game.hull = minf(100.0, game.hull + 25.0)
    game.oxygen = minf(100.0, game.oxygen + 36.0)
  }

  spawn_ripple(game, game.hero.x, game.hero.y, 18.0, 0.62, 0)
}

///|
fn init_title_scene(game : Game) -> Unit {
  clear_objs(game)
  clear_particles(game)
  clear_ripples(game)
  clear_trails(game)
  reset_hero(game.hero)

  game.state = state_title
  game.stage = 1
  game.distance = 0.0
  game.stage_goal = stage_base_goal
  game.score = 0
  game.data_collected = 0
  game.combo = 0
  game.combo_t = 0.0
  game.hull = 100.0
  game.oxygen = 100.0
  game.sonar_cd = 0.0
  game.sonar_t = 0.0
  game.dash_cd = 0.0
  game.dash_t = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.result_t = 0.0
  game.hint_t = 0.0
  game.scroll_speed = base_scroll
  game.next_spawn_y = spawn_start_y
}

///|
fn start_run(game : Game) -> Unit {
  start_new_stage(game, 1)
}

///|
fn spawn_wave(game : Game, y : Float) -> Unit {
  let mut count = 1 + randi(0, 2)
  if game.stage >= 3 {
    count = count + randi(0, 1)
  }

  for _i = 0; _i < count; _i = _i + 1 {
    let mut roll = randi(0, 99)

    if game.oxygen < 36.0 && chance(40) {
      roll = 96
    }

    if roll < 34 {
      let r = randf(18.0, 36.0)
      spawn_obj(
        game,
        obj_rock,
        object_spawn_x(game, y, r),
        y + randf(-24.0, 24.0),
        r,
        randf(-44.0, 44.0),
        randf(-18.0, 38.0),
        false,
        randf(8.0, 16.0),
      )
    } else if roll < 56 {
      let r = randf(15.0, 24.0)
      spawn_obj(
        game,
        obj_mine,
        object_spawn_x(game, y, r),
        y + randf(-30.0, 22.0),
        r,
        randf(-72.0, 72.0),
        randf(-16.0, 22.0),
        game.stage >= 2 && chance(42),
        randf(9.0, 18.0),
      )
    } else if roll < 75 {
      let r = randf(12.0, 16.0)
      spawn_obj(
        game,
        obj_data,
        object_spawn_x(game, y, r),
        y + randf(-20.0, 20.0),
        r,
        randf(-38.0, 38.0),
        randf(-14.0, 16.0),
        game.stage >= 4 && chance(28),
        randf(8.0, 15.0),
      )
    } else if roll < 86 {
      let r = randf(44.0, 62.0)
      let a = randf(0.0, 6.283)
      let p = randf(110.0, 190.0)
      spawn_obj(
        game,
        obj_current,
        object_spawn_x(game, y, r),
        y + randf(-28.0, 28.0),
        r,
        cosf(a) * p,
        sinf(a) * p,
        false,
        randf(4.6, 9.4),
      )
    } else if roll < 95 {
      let r = randf(12.0, 18.0)
      spawn_obj(
        game,
        obj_scrap,
        object_spawn_x(game, y, r),
        y + randf(-18.0, 18.0),
        r,
        randf(-42.0, 42.0),
        randf(-22.0, 14.0),
        false,
        randf(9.0, 17.0),
      )
    } else {
      let r = randf(16.0, 22.0)
      spawn_obj(
        game,
        obj_oxygen,
        object_spawn_x(game, y, r),
        y + randf(-14.0, 14.0),
        r,
        randf(-34.0, 34.0),
        randf(-8.0, 18.0),
        false,
        randf(8.0, 15.0),
      )
    }
  }
}

///|
fn spawn_step(game : Game, dt : Float) -> Unit {
  game.next_spawn_y = game.next_spawn_y + game.scroll_speed * dt

  let mut spawn_guard = 0
  while game.next_spawn_y >= 0.0 && spawn_guard < 16 {
    game.next_spawn_y = game.next_spawn_y -
      randf(spawn_spacing_min, spawn_spacing_max)
    spawn_wave(game, game.next_spawn_y)
    spawn_guard = spawn_guard + 1
  }
}

///|
fn trigger_sonar(game : Game) -> Unit {
  game.sonar_cd = sonar_cd_time
  game.sonar_t = sonar_time
  spawn_ripple(game, game.hero.x, game.hero.y, 12.0, 0.92, 1)
  burst(game, game.hero.x, game.hero.y, 18, 2)

  let reveal2 = sonar_reveal_r * sonar_reveal_r
  let destroy2 = sonar_destroy_r * sonar_destroy_r

  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      continue
    }

    let d2 = dist2(game.hero.x, game.hero.y, game.objs[i].x, game.objs[i].y)

    if d2 <= reveal2 {
      game.objs[i].cloak = false
    }

    if game.objs[i].kind == obj_mine && d2 <= destroy2 {
      let ox = game.objs[i].x
      let oy = game.objs[i].y
      game.objs[i].active = false
      add_score(game, 120)
      push_combo(game)
      burst(game, ox, oy, 16, 1)
      spawn_ripple(game, ox, oy, 10.0, 0.52, 0)
    }
  }
}

///|
fn dash_dir(game : Game) -> (Float, Float) {
  let mut dx = game.input_x
  let mut dy = game.input_y
  let len2 = dx * dx + dy * dy

  if len2 <= 0.001 {
    dx = 0.0
    dy = -1.0
  } else {
    let inv : Float = Float::from_int(1) / sqrtf(len2)
    dx = dx * inv
    dy = dy * inv
  }
  (dx, dy)
}

///|
fn apply_player_input(game : Game, dt : Float) -> Unit {
  if game.input_sonar_press && game.sonar_cd <= 0.0 {
    trigger_sonar(game)
  }

  if game.input_dash_press && game.dash_cd <= 0.0 {
    let d = dash_dir(game)
    game.hero.vx = d.0 * dash_speed
    game.hero.vy = d.1 * dash_speed
    game.dash_t = dash_time
    game.dash_cd = dash_cd_time
    game.hero.invuln = maxf(game.hero.invuln, 0.18)

    emit_trail(game, game.hero.x, game.hero.y, 30.0, 14.0, 0.28, 1)
    burst(game, game.hero.x, game.hero.y, 14, 2)
  }

  if game.dash_t <= 0.0 {
    game.hero.vx = game.hero.vx + game.input_x * player_accel * dt
    game.hero.vy = game.hero.vy + game.input_y * player_accel * dt

    let drag_mul = clampf(1.0 - player_drag * dt, 0.0, 1.0)
    game.hero.vx = game.hero.vx * drag_mul
    game.hero.vy = game.hero.vy * drag_mul

    let speed2 = game.hero.vx * game.hero.vx + game.hero.vy * game.hero.vy
    if speed2 > player_max_speed * player_max_speed {
      let inv = player_max_speed / sqrtf(speed2)
      game.hero.vx = game.hero.vx * inv
      game.hero.vy = game.hero.vy * inv
    }
  } else {
    let dash_mul = clampf(1.0 - 1.15 * dt, 0.0, 1.0)
    game.hero.vx = game.hero.vx * dash_mul
    game.hero.vy = game.hero.vy * dash_mul

    emit_trail(
      game,
      game.hero.x - game.hero.vx * 0.02,
      game.hero.y - game.hero.vy * 0.02,
      randf(16.0, 30.0),
      randf(9.0, 15.0),
      randf(0.18, 0.36),
      1,
    )
  }

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  game.hero.y = clampf(
    game.hero.y,
    Float::from_int(74),
    Float::from_int(screen_h) - Float::from_int(86),
  )
}

///|
fn resolve_cave_hit(game : Game) -> Unit {
  let edges = cave_edges(game, game.hero.y)
  let left = edges.0
  let right = edges.1

  if game.hero.x - game.hero.r < left {
    game.hero.x = left + game.hero.r
    game.hero.vx = absf(game.hero.vx) * 0.2
    hurt_hero(game, 12.0)
  }

  if game.hero.x + game.hero.r > right {
    game.hero.x = right - game.hero.r
    game.hero.vx = -absf(game.hero.vx) * 0.2
    hurt_hero(game, 12.0)
  }
}

///|
fn hit_obj(game : Game, i : Int, base_score : Int, burst_kind : Int) -> Unit {
  let x = game.objs[i].x
  let y = game.objs[i].y

  game.objs[i].active = false
  add_score(game, base_score)
  push_combo(game)
  burst(game, x, y, 14 + randi(0, 9), burst_kind)
  spawn_ripple(game, x, y, 10.0, 0.52, 0)
}

///|
fn update_objects(game : Game, dt : Float) -> Unit {
  let hero_dash_hit = game.dash_t > 0.0

  for i = 0; i < game.objs.length(); i = i + 1 {
    if not(game.objs[i].active) {
      continue
    }

    game.objs[i].x = game.objs[i].x + game.objs[i].vx * dt
    game.objs[i].y = game.objs[i].y + (game.scroll_speed + game.objs[i].vy) * dt
    game.objs[i].spin = game.objs[i].spin + dt * 1.6
    game.objs[i].life = game.objs[i].life - dt

    if game.objs[i].kind == obj_mine {
      game.objs[i].x = game.objs[i].x +
        sinf(game.objs[i].spin * 2.3) * 18.0 * dt
    }

    if game.objs[i].kind == obj_data {
      game.objs[i].x = game.objs[i].x +
        sinf(game.objs[i].spin * 3.2) * 12.0 * dt
      game.objs[i].y = game.objs[i].y + cosf(game.objs[i].spin * 2.4) * 9.0 * dt
    }

    if game.objs[i].kind == obj_current {
      game.objs[i].spin = game.objs[i].spin + dt * 1.3
      game.objs[i].r = game.objs[i].r + sinf(game.objs[i].spin * 1.8) * 9.0 * dt
      game.objs[i].r = clampf(game.objs[i].r, 40.0, 72.0)
    }

    let offscreen = game.objs[i].y > Float::from_int(screen_h) + 180.0 ||
      game.objs[i].x < -220.0 ||
      game.objs[i].x > Float::from_int(screen_w) + 220.0 ||
      game.objs[i].life <= 0.0

    if offscreen {
      game.objs[i].active = false
      continue
    }

    let hidden = game.objs[i].cloak && game.sonar_t <= 0.0
    if hidden {
      continue
    }

    let d2 = dist2(game.hero.x, game.hero.y, game.objs[i].x, game.objs[i].y)
    let rr = (game.hero.r + game.objs[i].r) * (game.hero.r + game.objs[i].r)

    if game.objs[i].kind == obj_current {
      let area = (game.objs[i].r + 80.0) * (game.objs[i].r + 80.0)
      if d2 <= area {
        let push_scale = clampf(1.0 - d2 / area, 0.0, 1.0)
        let mut px = game.objs[i].vx
        let mut py = game.objs[i].vy
        let p2 = px * px + py * py
        if p2 > 0.001 {
          let inv : Float = Float::from_int(1) / sqrtf(p2)
          px = px * inv
          py = py * inv
          game.hero.vx = game.hero.vx + px * (220.0 + 120.0 * push_scale) * dt
          game.hero.vy = game.hero.vy + py * (220.0 + 120.0 * push_scale) * dt

          if chance(20) {
            emit_particle(
              game,
              game.hero.x,
              game.hero.y,
              px * randf(30.0, 90.0),
              py * randf(30.0, 90.0),
              randf(0.2, 0.44),
              randf(1.2, 3.6),
              2,
            )
          }
        }
      }
    }

    if d2 > rr {
      continue
    }

    if game.objs[i].kind == obj_rock {
      if hero_dash_hit {
        hit_obj(game, i, 60, 2)
      } else {
        hurt_hero(game, 16.0)
        let dx = game.hero.x - game.objs[i].x
        let dy = game.hero.y - game.objs[i].y
        let n2 = maxf(dx * dx + dy * dy, 1.0)
        let inv : Float = Float::from_int(1) / sqrtf(n2)
        game.hero.vx = dx * inv * 120.0
        game.hero.vy = dy * inv * 120.0
      }
    } else if game.objs[i].kind == obj_mine {
      if hero_dash_hit || game.sonar_t > 0.0 {
        hit_obj(game, i, 110, 1)
      } else {
        hurt_hero(game, 26.0)
        game.objs[i].active = false
        burst(game, game.hero.x, game.hero.y, 12, 1)
      }
    } else if game.objs[i].kind == obj_data {
      game.objs[i].active = false
      game.data_collected = game.data_collected + 1
      add_score(game, 100)
      push_combo(game)
      game.oxygen = minf(100.0, game.oxygen + oxygen_data_bonus)
      burst(game, game.hero.x, game.hero.y, 9, 0)
    } else if game.objs[i].kind == obj_oxygen {
      game.objs[i].active = false
      game.oxygen = minf(100.0, game.oxygen + oxygen_pickup)
      add_score(game, 40)
      burst(game, game.hero.x, game.hero.y, 10, 2)
    } else if game.objs[i].kind == obj_scrap {
      game.objs[i].active = false
      add_score(game, 80)
      push_combo(game)
      burst(game, game.hero.x, game.hero.y, 10, 0)
    }
  }
}

///|
fn update_particles(game : Game, dt : Float) -> Unit {
  let flow = game.scroll_speed * 0.22

  for i = 0; i < game.particles.length(); i = i + 1 {
    if not(game.particles[i].active) {
      continue
    }

    game.particles[i].x = game.particles[i].x + game.particles[i].vx * dt
    game.particles[i].y = game.particles[i].y +
      (game.particles[i].vy + flow) * dt
    game.particles[i].life = game.particles[i].life - dt

    let expired = game.particles[i].life <= 0.0 ||
      game.particles[i].y > Float::from_int(screen_h) + 48.0
    if expired {
      game.particles[i].active = false
    }
  }

  for i = 0; i < game.ripples.length(); i = i + 1 {
    if not(game.ripples[i].active) {
      continue
    }

    game.ripples[i].life = game.ripples[i].life - dt
    game.ripples[i].r = game.ripples[i].r +
      (110.0 + Float::from_int(game.ripples[i].kind) * 46.0) * dt

    if game.ripples[i].life <= 0.0 {
      game.ripples[i].active = false
    }
  }

  for i = 0; i < game.trails.length(); i = i + 1 {
    if not(game.trails[i].active) {
      continue
    }

    game.trails[i].y = game.trails[i].y + game.scroll_speed * 0.18 * dt
    game.trails[i].life = game.trails[i].life - dt

    if game.trails[i].life <= 0.0 {
      game.trails[i].active = false
    }
  }
}

///|
fn update_timers(game : Game, dt : Float) -> Unit {
  game.hero.invuln = maxf(0.0, game.hero.invuln - dt)
  game.hero.hurt_t = maxf(0.0, game.hero.hurt_t - dt)
  game.hero.anim_t = game.hero.anim_t + dt

  game.sonar_cd = maxf(0.0, game.sonar_cd - dt)
  game.sonar_t = maxf(0.0, game.sonar_t - dt)
  game.dash_cd = maxf(0.0, game.dash_cd - dt)
  game.dash_t = maxf(0.0, game.dash_t - dt)

  game.flash_t = maxf(0.0, game.flash_t - dt)
  game.shake_t = maxf(0.0, game.shake_t - dt)

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      game.combo = 0
    }
  }
}

///|
fn emit_ambience(game : Game, dt : Float) -> Unit {
  let mut n = 0
  let tries = clampi((dt * 210.0).to_int(), 1, 8)
  while n < tries {
    if chance(36) {
      let y = randf(-24.0, Float::from_int(screen_h) + 10.0)
      let edges = cave_edges(game, y)
      let side : Float = if chance(50) {
        Float::from_int(-1)
      } else {
        Float::from_int(1)
      }
      let x = if side < 0.0 {
        edges.0 + randf(8.0, 40.0)
      } else {
        edges.1 - randf(8.0, 40.0)
      }

      emit_particle(
        game,
        x,
        y,
        side * randf(4.0, 26.0),
        randf(-26.0, 34.0),
        randf(0.6, 1.4),
        randf(1.0, 2.8),
        if chance(35) {
          2
        } else {
          0
        },
      )
    }
    n = n + 1
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.scroll_speed = base_scroll +
    Float::from_int(game.stage - 1) * stage_scroll_gain +
    minf(52.0, game.distance * 0.008)
  game.distance = game.distance + game.scroll_speed * dt

  apply_player_input(game, dt)
  resolve_cave_hit(game)

  spawn_step(game, dt)
  update_objects(game, dt)
  update_particles(game, dt)

  game.oxygen = maxf(
    0.0,
    game.oxygen -
    oxygen_drain * dt -
    absf(game.hero.vx) / player_max_speed * 1.1 * dt,
  )

  if game.dash_t > 0.0 {
    game.oxygen = maxf(0.0, game.oxygen - 1.6 * dt)
  }

  emit_ambience(game, dt)

  if game.oxygen <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
  }

  if game.state == state_play && game.distance >= game.stage_goal {
    game.state = state_stage_clear
    game.result_t = 0.0
    add_score(game, 300 + game.stage * 120)
    game.hull = minf(100.0, game.hull + 12.0)
    spawn_ripple(game, game.hero.x, game.hero.y, 14.0, 0.84, 1)
    burst(game, game.hero.x, game.hero.y, 24, 2)
  }
}

///|
fn update_title(game : Game, dt : Float) -> Unit {
  game.scroll_speed = 86.0
  game.distance = game.distance + game.scroll_speed * dt * 0.6

  emit_ambience(game, dt)
  update_particles(game, dt)

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll_speed = maxf(80.0, game.scroll_speed - 160.0 * dt)

  if chance(18) {
    emit_particle(
      game,
      game.hero.x + randf(-26.0, 26.0),
      game.hero.y + randf(-26.0, 26.0),
      randf(-32.0, 32.0),
      randf(-42.0, -8.0),
      randf(0.24, 0.68),
      randf(2.0, 4.4),
      2,
    )
  }

  update_particles(game, dt)

  if game.input_restart_press || game.result_t >= stage_clear_delay {
    start_new_stage(game, game.stage + 1)
  }
}

///|
fn update_game_over(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll_speed = maxf(46.0, game.scroll_speed - 120.0 * dt)

  emit_ambience(game, dt)
  update_particles(game, dt)

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
