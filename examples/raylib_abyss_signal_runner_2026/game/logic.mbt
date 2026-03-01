///|
fn clear_objs(game : @types.Game) -> Unit {
  for obj in game.objs {
    obj.active = false
    obj.kind = @types.Rock
    obj.x = 0.0
    obj.y = 0.0
    obj.vx = 0.0
    obj.vy = 0.0
    obj.r = 0.0
    obj.cloak = false
    obj.spin = 0.0
    obj.life = 0.0
  }
}

///|
fn clear_particles(game : @types.Game) -> Unit {
  for particle in game.particles {
    particle.active = false
    particle.x = 0.0
    particle.y = 0.0
    particle.vx = 0.0
    particle.vy = 0.0
    particle.life = 0.0
    particle.size = 0.0
    particle.kind = 0
  }
}

///|
fn clear_ripples(game : @types.Game) -> Unit {
  for ripple in game.ripples {
    ripple.active = false
    ripple.x = 0.0
    ripple.y = 0.0
    ripple.r = 0.0
    ripple.life = 0.0
    ripple.kind = 0
  }
}

///|
fn clear_trails(game : @types.Game) -> Unit {
  for trail in game.trails {
    trail.active = false
    trail.x = 0.0
    trail.y = 0.0
    trail.w = 0.0
    trail.h = 0.0
    trail.life = 0.0
    trail.kind = 0
  }
}

///|
fn reset_hero(hero : @types.Player) -> Unit {
  hero.x = Float::from_int(@types.screen_w / 2)
  hero.y = Float::from_int(@types.screen_h) * 0.72
  hero.vx = 0.0
  hero.vy = 0.0
  hero.r = @types.player_r
  hero.invuln = 0.0
  hero.hurt_t = 0.0
  hero.anim_t = 0.0
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
fn alloc_particle(game : @types.Game) -> Int {
  for i in 0..<game.particles.length() {
    if not(game.particles[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.particles[0].life
  for i in 1..<game.particles.length() {
    if game.particles[i].life < best_life {
      best_life = game.particles[i].life
      best = i
    }
  }
  best
}

///|
fn alloc_ripple(game : @types.Game) -> Int {
  for i in 0..<game.ripples.length() {
    if not(game.ripples[i].active) {
      return i
    }
  }

  let mut best = 0
  let mut best_life = game.ripples[0].life
  for i in 1..<game.ripples.length() {
    if game.ripples[i].life < best_life {
      best_life = game.ripples[i].life
      best = i
    }
  }
  best
}

///|
fn emit_particle(
  game : @types.Game,
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
fn burst(game : @types.Game, x : Float, y : Float, n : Int, kind : Int) -> Unit {
  for _i in 0..<n {
    emit_particle(
      game,
      x + @types.randf(-14.0, 14.0),
      y + @types.randf(-14.0, 14.0),
      @types.randf(-220.0, 220.0),
      @types.randf(-220.0, 220.0),
      @types.randf(0.24, 1.02),
      @types.randf(1.8, 6.8),
      kind,
    )
  }
}

///|
fn spawn_ripple(
  game : @types.Game,
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
fn spawn_obj(
  game : @types.Game,
  kind : @types.ObjKind,
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
  game.objs[i].spin = @types.randf(0.0, 6.283)
  game.objs[i].life = life
}

///|
fn object_spawn_x(game : @types.Game, y : Float, r : Float) -> Float {
  let d = @types.depth_at_screen(game, y)
  let c = @types.cave_center(d, game.time_s)
  let hw = @types.cave_half_width(d, game.time_s, game.stage)
  let mut lo = c - hw + @types.cave_x_margin + r
  let mut hi = c + hw - @types.cave_x_margin - r
  if hi < lo {
    let mid = c
    lo = mid - 10.0
    hi = mid + 10.0
  }
  @types.clampf(@types.randf(lo, hi), lo, hi)
}

///|
fn score_gain(game : @types.Game, base : Int) -> Int {
  let bonus = base * game.combo / 4
  base + bonus
}

///|
fn add_score(game : @types.Game, base : Int) -> Unit {
  let gained = score_gain(game, base)
  game.score = game.score + gained
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn push_combo(game : @types.Game) -> Unit {
  game.combo = @types.clampi(game.combo + 1, 0, 18)
  game.combo_t = 3.4
}

///|
fn hurt_hero(game : @types.Game, dmg : Float) -> Unit {
  if game.hero.invuln > 0.0 {
    return
  }

  game.hull = @types.maxf(0.0, game.hull - dmg)
  game.hero.invuln = @types.invuln_time
  game.hero.hurt_t = 0.56
  game.flash_t = @types.maxf(game.flash_t, 0.34)
  game.shake_t = @types.maxf(game.shake_t, 0.55)
  game.combo = 0
  game.combo_t = 0.0

  burst(game, game.hero.x, game.hero.y, 22, 1)

  if game.hull <= 0.0 {
    game.state = @types.GameOver
    game.result_t = 0.0
  }
}

///|
fn start_new_stage(game : @types.Game, stage : Int) -> Unit {
  clear_objs(game)
  clear_particles(game)
  clear_ripples(game)
  clear_trails(game)

  reset_hero(game.hero)

  game.state = @types.Play
  game.stage = stage
  game.distance = 0.0
  game.stage_goal = @types.stage_base_goal +
    Float::from_int(stage - 1) * @types.stage_goal_gain
  game.scroll_speed = @types.base_scroll +
    Float::from_int(stage - 1) * @types.stage_scroll_gain
  game.next_spawn_y = @types.spawn_start_y

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
    game.hull = @types.minf(100.0, game.hull + 25.0)
    game.oxygen = @types.minf(100.0, game.oxygen + 36.0)
  }

  spawn_ripple(game, game.hero.x, game.hero.y, 18.0, 0.62, 0)
}

///|
fn init_title_scene(game : @types.Game) -> Unit {
  clear_objs(game)
  clear_particles(game)
  clear_ripples(game)
  clear_trails(game)
  reset_hero(game.hero)

  game.state = @types.Title
  game.stage = 1
  game.distance = 0.0
  game.stage_goal = @types.stage_base_goal
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
  game.scroll_speed = @types.base_scroll
  game.next_spawn_y = @types.spawn_start_y
}

///|
fn start_run(game : @types.Game) -> Unit {
  start_new_stage(game, 1)
}

///|
fn spawn_wave(game : @types.Game, y : Float) -> Unit {
  let mut count = 1 + @types.randi(0, 2)
  if game.stage >= 3 {
    count = count + @types.randi(0, 1)
  }

  for _i in 0..<count {
    let mut roll = @types.randi(0, 99)

    if game.oxygen < 36.0 && @types.chance(40) {
      roll = 96
    }

    if roll < 34 {
      let r = @types.randf(18.0, 36.0)
      spawn_obj(
        game,
        @types.Rock,
        object_spawn_x(game, y, r),
        y + @types.randf(-24.0, 24.0),
        r,
        @types.randf(-44.0, 44.0),
        @types.randf(-18.0, 38.0),
        false,
        @types.randf(8.0, 16.0),
      )
    } else if roll < 56 {
      let r = @types.randf(15.0, 24.0)
      spawn_obj(
        game,
        @types.Mine,
        object_spawn_x(game, y, r),
        y + @types.randf(-30.0, 22.0),
        r,
        @types.randf(-72.0, 72.0),
        @types.randf(-16.0, 22.0),
        game.stage >= 2 && @types.chance(42),
        @types.randf(9.0, 18.0),
      )
    } else if roll < 75 {
      let r = @types.randf(12.0, 16.0)
      spawn_obj(
        game,
        @types.Data,
        object_spawn_x(game, y, r),
        y + @types.randf(-20.0, 20.0),
        r,
        @types.randf(-38.0, 38.0),
        @types.randf(-14.0, 16.0),
        game.stage >= 4 && @types.chance(28),
        @types.randf(8.0, 15.0),
      )
    } else if roll < 86 {
      let r = @types.randf(44.0, 62.0)
      let a = @types.randf(0.0, 6.283)
      let p = @types.randf(110.0, 190.0)
      spawn_obj(
        game,
        @types.Current,
        object_spawn_x(game, y, r),
        y + @types.randf(-28.0, 28.0),
        r,
        @types.cosf(a) * p,
        @types.sinf(a) * p,
        false,
        @types.randf(4.6, 9.4),
      )
    } else if roll < 95 {
      let r = @types.randf(12.0, 18.0)
      spawn_obj(
        game,
        @types.Scrap,
        object_spawn_x(game, y, r),
        y + @types.randf(-18.0, 18.0),
        r,
        @types.randf(-42.0, 42.0),
        @types.randf(-22.0, 14.0),
        false,
        @types.randf(9.0, 17.0),
      )
    } else {
      let r = @types.randf(16.0, 22.0)
      spawn_obj(
        game,
        @types.Oxygen,
        object_spawn_x(game, y, r),
        y + @types.randf(-14.0, 14.0),
        r,
        @types.randf(-34.0, 34.0),
        @types.randf(-8.0, 18.0),
        false,
        @types.randf(8.0, 15.0),
      )
    }
  }
}

///|
fn spawn_step(game : @types.Game, dt : Float) -> Unit {
  game.next_spawn_y = game.next_spawn_y + game.scroll_speed * dt

  let mut spawn_guard = 0
  while game.next_spawn_y >= 0.0 && spawn_guard < 16 {
    game.next_spawn_y = game.next_spawn_y -
      @types.randf(@types.spawn_spacing_min, @types.spawn_spacing_max)
    spawn_wave(game, game.next_spawn_y)
    spawn_guard = spawn_guard + 1
  }
}

///|
fn trigger_sonar(game : @types.Game) -> Unit {
  game.sonar_cd = @types.sonar_cd_time
  game.sonar_t = @types.sonar_time
  spawn_ripple(game, game.hero.x, game.hero.y, 12.0, 0.92, 1)
  burst(game, game.hero.x, game.hero.y, 18, 2)

  let reveal2 = @types.sonar_reveal_r * @types.sonar_reveal_r
  let destroy2 = @types.sonar_destroy_r * @types.sonar_destroy_r

  for obj in game.objs {
    if not(obj.active) {
      continue
    }

    let d2 = @types.dist2(game.hero.x, game.hero.y, obj.x, obj.y)

    if d2 <= reveal2 {
      obj.cloak = false
    }

    if obj.kind is @types.Mine && d2 <= destroy2 {
      let ox = obj.x
      let oy = obj.y
      obj.active = false
      add_score(game, 120)
      push_combo(game)
      burst(game, ox, oy, 16, 1)
      spawn_ripple(game, ox, oy, 10.0, 0.52, 0)
    }
  }
}

///|
fn dash_dir(game : @types.Game) -> (Float, Float) {
  let mut dx = game.input_x
  let mut dy = game.input_y
  let len2 = dx * dx + dy * dy

  if len2 <= 0.001 {
    dx = 0.0
    dy = -1.0
  } else {
    let inv : Float = Float::from_int(1) / @types.sqrtf(len2)
    dx = dx * inv
    dy = dy * inv
  }
  (dx, dy)
}

///|
fn apply_player_input(game : @types.Game, dt : Float) -> Unit {
  if game.input_sonar_press && game.sonar_cd <= 0.0 {
    trigger_sonar(game)
  }

  if game.input_dash_press && game.dash_cd <= 0.0 {
    let d = dash_dir(game)
    game.hero.vx = d.0 * @types.dash_speed
    game.hero.vy = d.1 * @types.dash_speed
    game.dash_t = @types.dash_time
    game.dash_cd = @types.dash_cd_time
    game.hero.invuln = @types.maxf(game.hero.invuln, 0.18)

    @types.emit_trail(game, game.hero.x, game.hero.y, 30.0, 14.0, 0.28, 1)
    burst(game, game.hero.x, game.hero.y, 14, 2)
  }

  if game.dash_t <= 0.0 {
    game.hero.vx = game.hero.vx + game.input_x * @types.player_accel * dt
    game.hero.vy = game.hero.vy + game.input_y * @types.player_accel * dt

    let drag_mul = @types.clampf(1.0 - @types.player_drag * dt, 0.0, 1.0)
    game.hero.vx = game.hero.vx * drag_mul
    game.hero.vy = game.hero.vy * drag_mul

    let speed2 = game.hero.vx * game.hero.vx + game.hero.vy * game.hero.vy
    if speed2 > @types.player_max_speed * @types.player_max_speed {
      let inv = @types.player_max_speed / @types.sqrtf(speed2)
      game.hero.vx = game.hero.vx * inv
      game.hero.vy = game.hero.vy * inv
    }
  } else {
    let dash_mul = @types.clampf(1.0 - 1.15 * dt, 0.0, 1.0)
    game.hero.vx = game.hero.vx * dash_mul
    game.hero.vy = game.hero.vy * dash_mul

    @types.emit_trail(
      game,
      game.hero.x - game.hero.vx * 0.02,
      game.hero.y - game.hero.vy * 0.02,
      @types.randf(16.0, 30.0),
      @types.randf(9.0, 15.0),
      @types.randf(0.18, 0.36),
      1,
    )
  }

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  game.hero.y = @types.clampf(
    game.hero.y,
    Float::from_int(74),
    Float::from_int(@types.screen_h) - Float::from_int(86),
  )
}

///|
fn resolve_cave_hit(game : @types.Game) -> Unit {
  let edges = @types.cave_edges(game, game.hero.y)
  let left = edges.0
  let right = edges.1

  if game.hero.x - game.hero.r < left {
    game.hero.x = left + game.hero.r
    game.hero.vx = @types.absf(game.hero.vx) * 0.2
    hurt_hero(game, 12.0)
  }

  if game.hero.x + game.hero.r > right {
    game.hero.x = right - game.hero.r
    game.hero.vx = -@types.absf(game.hero.vx) * 0.2
    hurt_hero(game, 12.0)
  }
}

///|
fn hit_obj(
  game : @types.Game,
  i : Int,
  base_score : Int,
  burst_kind : Int,
) -> Unit {
  let x = game.objs[i].x
  let y = game.objs[i].y

  game.objs[i].active = false
  add_score(game, base_score)
  push_combo(game)
  burst(game, x, y, 14 + @types.randi(0, 9), burst_kind)
  spawn_ripple(game, x, y, 10.0, 0.52, 0)
}

///|
fn update_objects(game : @types.Game, dt : Float) -> Unit {
  let hero_dash_hit = game.dash_t > 0.0

  for i in 0..<game.objs.length() {
    if not(game.objs[i].active) {
      continue
    }

    game.objs[i].x = game.objs[i].x + game.objs[i].vx * dt
    game.objs[i].y = game.objs[i].y + (game.scroll_speed + game.objs[i].vy) * dt
    game.objs[i].spin = game.objs[i].spin + dt * 1.6
    game.objs[i].life = game.objs[i].life - dt

    match game.objs[i].kind {
      Mine =>
        game.objs[i].x = game.objs[i].x +
          @types.sinf(game.objs[i].spin * 2.3) * 18.0 * dt
      Data => {
        game.objs[i].x = game.objs[i].x +
          @types.sinf(game.objs[i].spin * 3.2) * 12.0 * dt
        game.objs[i].y = game.objs[i].y +
          @types.cosf(game.objs[i].spin * 2.4) * 9.0 * dt
      }
      Current => {
        game.objs[i].spin = game.objs[i].spin + dt * 1.3
        game.objs[i].r = game.objs[i].r +
          @types.sinf(game.objs[i].spin * 1.8) * 9.0 * dt
        game.objs[i].r = @types.clampf(game.objs[i].r, 40.0, 72.0)
      }
      Rock | Oxygen | Scrap => ()
    }

    let offscreen = game.objs[i].y > Float::from_int(@types.screen_h) + 180.0 ||
      game.objs[i].x < -220.0 ||
      game.objs[i].x > Float::from_int(@types.screen_w) + 220.0 ||
      game.objs[i].life <= 0.0

    if offscreen {
      game.objs[i].active = false
      continue
    }

    let hidden = game.objs[i].cloak && game.sonar_t <= 0.0
    if hidden {
      continue
    }

    let d2 = @types.dist2(
      game.hero.x,
      game.hero.y,
      game.objs[i].x,
      game.objs[i].y,
    )
    let rr = (game.hero.r + game.objs[i].r) * (game.hero.r + game.objs[i].r)

    if game.objs[i].kind is @types.Current {
      let area = (game.objs[i].r + 80.0) * (game.objs[i].r + 80.0)
      if d2 <= area {
        let push_scale = @types.clampf(1.0 - d2 / area, 0.0, 1.0)
        let mut px = game.objs[i].vx
        let mut py = game.objs[i].vy
        let p2 = px * px + py * py
        if p2 > 0.001 {
          let inv : Float = Float::from_int(1) / @types.sqrtf(p2)
          px = px * inv
          py = py * inv
          game.hero.vx = game.hero.vx + px * (220.0 + 120.0 * push_scale) * dt
          game.hero.vy = game.hero.vy + py * (220.0 + 120.0 * push_scale) * dt

          if @types.chance(20) {
            emit_particle(
              game,
              game.hero.x,
              game.hero.y,
              px * @types.randf(30.0, 90.0),
              py * @types.randf(30.0, 90.0),
              @types.randf(0.2, 0.44),
              @types.randf(1.2, 3.6),
              2,
            )
          }
        }
      }
    }

    if d2 > rr {
      continue
    }

    match game.objs[i].kind {
      Rock =>
        if hero_dash_hit {
          hit_obj(game, i, 60, 2)
        } else {
          hurt_hero(game, 16.0)
          let dx = game.hero.x - game.objs[i].x
          let dy = game.hero.y - game.objs[i].y
          let n2 = @types.maxf(dx * dx + dy * dy, 1.0)
          let inv : Float = Float::from_int(1) / @types.sqrtf(n2)
          game.hero.vx = dx * inv * 120.0
          game.hero.vy = dy * inv * 120.0
        }
      Mine =>
        if hero_dash_hit || game.sonar_t > 0.0 {
          hit_obj(game, i, 110, 1)
        } else {
          hurt_hero(game, 26.0)
          game.objs[i].active = false
          burst(game, game.hero.x, game.hero.y, 12, 1)
        }
      Data => {
        game.objs[i].active = false
        game.data_collected = game.data_collected + 1
        add_score(game, 100)
        push_combo(game)
        game.oxygen = @types.minf(100.0, game.oxygen + @types.oxygen_data_bonus)
        burst(game, game.hero.x, game.hero.y, 9, 0)
      }
      Oxygen => {
        game.objs[i].active = false
        game.oxygen = @types.minf(100.0, game.oxygen + @types.oxygen_pickup)
        add_score(game, 40)
        burst(game, game.hero.x, game.hero.y, 10, 2)
      }
      Scrap => {
        game.objs[i].active = false
        add_score(game, 80)
        push_combo(game)
        burst(game, game.hero.x, game.hero.y, 10, 0)
      }
      Current => ()
    }
  }
}

///|
fn update_particles(game : @types.Game, dt : Float) -> Unit {
  let flow = game.scroll_speed * 0.22

  for particle in game.particles {
    if not(particle.active) {
      continue
    }

    particle.x = particle.x + particle.vx * dt
    particle.y = particle.y + (particle.vy + flow) * dt
    particle.life = particle.life - dt

    let expired = particle.life <= 0.0 ||
      particle.y > Float::from_int(@types.screen_h) + 48.0
    if expired {
      particle.active = false
    }
  }

  for ripple in game.ripples {
    if not(ripple.active) {
      continue
    }

    ripple.life = ripple.life - dt
    ripple.r = ripple.r + (110.0 + Float::from_int(ripple.kind) * 46.0) * dt

    if ripple.life <= 0.0 {
      ripple.active = false
    }
  }

  for trail in game.trails {
    if not(trail.active) {
      continue
    }

    trail.y = trail.y + game.scroll_speed * 0.18 * dt
    trail.life = trail.life - dt

    if trail.life <= 0.0 {
      trail.active = false
    }
  }
}

///|
fn update_timers(game : @types.Game, dt : Float) -> Unit {
  game.hero.invuln = @types.maxf(0.0, game.hero.invuln - dt)
  game.hero.hurt_t = @types.maxf(0.0, game.hero.hurt_t - dt)
  game.hero.anim_t = game.hero.anim_t + dt

  game.sonar_cd = @types.maxf(0.0, game.sonar_cd - dt)
  game.sonar_t = @types.maxf(0.0, game.sonar_t - dt)
  game.dash_cd = @types.maxf(0.0, game.dash_cd - dt)
  game.dash_t = @types.maxf(0.0, game.dash_t - dt)

  game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  game.shake_t = @types.maxf(0.0, game.shake_t - dt)

  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
    if game.combo_t <= 0.0 {
      game.combo = 0
    }
  }
}

///|
fn emit_ambience(game : @types.Game, dt : Float) -> Unit {
  let mut n = 0
  let tries = @types.clampi((dt * 210.0).to_int(), 1, 8)
  while n < tries {
    if @types.chance(36) {
      let y = @types.randf(-24.0, Float::from_int(@types.screen_h) + 10.0)
      let edges = @types.cave_edges(game, y)
      let side : Float = if @types.chance(50) {
        Float::from_int(-1)
      } else {
        Float::from_int(1)
      }
      let x = if side < 0.0 {
        edges.0 + @types.randf(8.0, 40.0)
      } else {
        edges.1 - @types.randf(8.0, 40.0)
      }

      emit_particle(
        game,
        x,
        y,
        side * @types.randf(4.0, 26.0),
        @types.randf(-26.0, 34.0),
        @types.randf(0.6, 1.4),
        @types.randf(1.0, 2.8),
        if @types.chance(35) {
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
fn update_play(game : @types.Game, dt : Float) -> Unit {
  game.scroll_speed = @types.base_scroll +
    Float::from_int(game.stage - 1) * @types.stage_scroll_gain +
    @types.minf(52.0, game.distance * 0.008)
  game.distance = game.distance + game.scroll_speed * dt

  apply_player_input(game, dt)
  resolve_cave_hit(game)

  spawn_step(game, dt)
  update_objects(game, dt)
  update_particles(game, dt)

  game.oxygen = @types.maxf(
    0.0,
    game.oxygen -
    @types.oxygen_drain * dt -
    @types.absf(game.hero.vx) / @types.player_max_speed * 1.1 * dt,
  )

  if game.dash_t > 0.0 {
    game.oxygen = @types.maxf(0.0, game.oxygen - 1.6 * dt)
  }

  emit_ambience(game, dt)

  if game.oxygen <= 0.0 {
    game.state = @types.GameOver
    game.result_t = 0.0
  }

  if game.state is @types.Play && game.distance >= game.stage_goal {
    game.state = @types.StageClear
    game.result_t = 0.0
    add_score(game, 300 + game.stage * 120)
    game.hull = @types.minf(100.0, game.hull + 12.0)
    spawn_ripple(game, game.hero.x, game.hero.y, 14.0, 0.84, 1)
    burst(game, game.hero.x, game.hero.y, 24, 2)
  }
}

///|
fn update_title(game : @types.Game, dt : Float) -> Unit {
  game.scroll_speed = 86.0
  game.distance = game.distance + game.scroll_speed * dt * 0.6

  emit_ambience(game, dt)
  update_particles(game, dt)

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll_speed = @types.maxf(80.0, game.scroll_speed - 160.0 * dt)

  if @types.chance(18) {
    emit_particle(
      game,
      game.hero.x + @types.randf(-26.0, 26.0),
      game.hero.y + @types.randf(-26.0, 26.0),
      @types.randf(-32.0, 32.0),
      @types.randf(-42.0, -8.0),
      @types.randf(0.24, 0.68),
      @types.randf(2.0, 4.4),
      2,
    )
  }

  update_particles(game, dt)

  if game.input_restart_press || game.result_t >= @types.stage_clear_delay {
    start_new_stage(game, game.stage + 1)
  }
}

///|
fn update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.scroll_speed = @types.maxf(46.0, game.scroll_speed - 120.0 * dt)

  emit_ambience(game, dt)
  update_particles(game, dt)

  if game.input_restart_press {
    init_title_scene(game)
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.hint_t = game.hint_t + dt

  // Handle input based on current state
  match game.state {
    Title => update_title_input(game)
    Play => update_play_input(game)
    StageClear | GameOver => update_result_input(game)
  }

  update_timers(game, dt)

  match game.state {
    Title => update_title(game, dt)
    Play => update_play(game, dt)
    StageClear => update_stage_clear(game, dt)
    GameOver => update_game_over(game, dt)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
pub fn init_game(game : @types.Game) -> Unit {
  init_title_scene(game)
}
