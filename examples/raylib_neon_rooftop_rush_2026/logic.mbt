///|
fn clear_segments(game : Game) -> Unit {
  for i = 0; i < game.segments.length(); i = i + 1 {
    game.segments[i].active = false
    game.segments[i].x = -2000.0
    game.segments[i].y = Float::from_int(screen_h) + 200.0
    game.segments[i].w = 0.0
    game.segments[i].h = 0.0
    game.segments[i].skin = 0
    game.segments[i].neon = 0
    game.segments[i].window_seed = 0
  }
}

///|
fn clear_obstacles(game : Game) -> Unit {
  for i = 0; i < game.obstacles.length(); i = i + 1 {
    game.obstacles[i].active = false
    game.obstacles[i].kind = obstacle_vent
    game.obstacles[i].x = -2000.0
    game.obstacles[i].y = 0.0
    game.obstacles[i].w = 0.0
    game.obstacles[i].h = 0.0
    game.obstacles[i].vx = 0.0
    game.obstacles[i].phase = 0.0
    game.obstacles[i].hit_lock = 0.0
  }
}

///|
fn clear_chips(game : Game) -> Unit {
  for i = 0; i < game.chips.length(); i = i + 1 {
    game.chips[i].active = false
    game.chips[i].x = -2000.0
    game.chips[i].y = 0.0
    game.chips[i].bob_t = 0.0
    game.chips[i].spin_t = 0.0
  }
}

///|
fn clear_anchors(game : Game) -> Unit {
  for i = 0; i < game.anchors.length(); i = i + 1 {
    game.anchors[i].active = false
    game.anchors[i].x = -2000.0
    game.anchors[i].y = 0.0
    game.anchors[i].glow_t = 0.0
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
fn clear_ghosts(game : Game) -> Unit {
  for i = 0; i < game.ghosts.length(); i = i + 1 {
    game.ghosts[i].active = false
    game.ghosts[i].x = 0.0
    game.ghosts[i].y = 0.0
    game.ghosts[i].w = 0.0
    game.ghosts[i].h = 0.0
    game.ghosts[i].life = 0.0
    game.ghosts[i].hue = 0.0
  }
}

///|
fn reset_player(hero : Player) -> Unit {
  hero.x = player_spawn_x
  hero.y = player_spawn_y
  hero.w = 64.0
  hero.h = 88.0
  hero.vy = 0.0
  hero.grounded = false
  hero.coyote_t = 0.0
  hero.jump_buf_t = 0.0
  hero.air_jumps = 1
  hero.slide_t = 0.0
  hero.grapple_t = 0.0
  hero.grapple_target_y = 0.0
  hero.invuln_t = 0.0
  hero.hurt_t = 0.0
  hero.anim_t = 0.0
  hero.floor_y = 460.0
}

///|
fn alloc_segment_slot(game : Game) -> Int {
  for i = 0; i < game.segments.length(); i = i + 1 {
    if not(game.segments[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_x = game.segments[0].x
  for i = 1; i < game.segments.length(); i = i + 1 {
    if game.segments[i].x < best_x {
      best_x = game.segments[i].x
      best_i = i
    }
  }

  best_i
}

///|
fn alloc_obstacle_slot(game : Game) -> Int {
  for i = 0; i < game.obstacles.length(); i = i + 1 {
    if not(game.obstacles[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_x = game.obstacles[0].x
  for i = 1; i < game.obstacles.length(); i = i + 1 {
    if game.obstacles[i].x < best_x {
      best_x = game.obstacles[i].x
      best_i = i
    }
  }

  best_i
}

///|
fn alloc_chip_slot(game : Game) -> Int {
  for i = 0; i < game.chips.length(); i = i + 1 {
    if not(game.chips[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_x = game.chips[0].x
  for i = 1; i < game.chips.length(); i = i + 1 {
    if game.chips[i].x < best_x {
      best_x = game.chips[i].x
      best_i = i
    }
  }

  best_i
}

///|
fn alloc_anchor_slot(game : Game) -> Int {
  for i = 0; i < game.anchors.length(); i = i + 1 {
    if not(game.anchors[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_x = game.anchors[0].x
  for i = 1; i < game.anchors.length(); i = i + 1 {
    if game.anchors[i].x < best_x {
      best_x = game.anchors[i].x
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
fn alloc_ghost_slot(game : Game) -> Int {
  for i = 0; i < game.ghosts.length(); i = i + 1 {
    if not(game.ghosts[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_life = game.ghosts[0].life
  for i = 1; i < game.ghosts.length(); i = i + 1 {
    if game.ghosts[i].life < best_life {
      best_life = game.ghosts[i].life
      best_i = i
    }
  }

  best_i
}

///|
fn spawn_segment(
  game : Game,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  skin : Int,
  neon : Int,
  window_seed : Int,
) -> Unit {
  let i = alloc_segment_slot(game)
  game.segments[i].active = true
  game.segments[i].x = x
  game.segments[i].y = y
  game.segments[i].w = w
  game.segments[i].h = h
  game.segments[i].skin = skin
  game.segments[i].neon = neon
  game.segments[i].window_seed = window_seed
}

///|
fn spawn_obstacle(
  game : Game,
  kind : Int,
  x : Float,
  y : Float,
  w : Float,
  h : Float,
  vx : Float,
) -> Unit {
  let i = alloc_obstacle_slot(game)
  game.obstacles[i].active = true
  game.obstacles[i].kind = kind
  game.obstacles[i].x = x
  game.obstacles[i].y = y
  game.obstacles[i].w = w
  game.obstacles[i].h = h
  game.obstacles[i].vx = vx
  game.obstacles[i].phase = randf(0.0, 6.28)
  game.obstacles[i].hit_lock = 0.0
}

///|
fn spawn_chip(game : Game, x : Float, y : Float) -> Unit {
  let i = alloc_chip_slot(game)
  game.chips[i].active = true
  game.chips[i].x = x
  game.chips[i].y = y
  game.chips[i].bob_t = randf(0.0, 6.28)
  game.chips[i].spin_t = randf(0.0, 6.28)
}

///|
fn spawn_anchor(game : Game, x : Float, y : Float) -> Unit {
  let i = alloc_anchor_slot(game)
  game.anchors[i].active = true
  game.anchors[i].x = x
  game.anchors[i].y = y
  game.anchors[i].glow_t = randf(0.0, 6.28)
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
fn burst_particles(
  game : Game,
  x : Float,
  y : Float,
  amount : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < amount; _i = _i + 1 {
    spawn_particle(
      game,
      x + randf(-18.0, 18.0),
      y + randf(-18.0, 18.0),
      randf(-280.0, 280.0),
      randf(-360.0, -20.0),
      randf(0.30, 0.95),
      randf(2.0, 6.2),
      kind,
    )
  }
}

///|
fn spawn_ghost(game : Game, hero : Player, hue : Float) -> Unit {
  let i = alloc_ghost_slot(game)
  game.ghosts[i].active = true
  game.ghosts[i].x = hero.x + randf(-2.0, 2.0)
  game.ghosts[i].y = hero.y + randf(-2.0, 2.0)
  game.ghosts[i].w = hero.w
  game.ghosts[i].h = hero.h
  game.ghosts[i].life = 0.18
  game.ghosts[i].hue = hue
}

///|
fn best_right_edge(game : Game) -> (Float, Float) {
  let mut right_x : Float = -10000.0
  let mut right_y : Float = 460.0
  for i = 0; i < game.segments.length(); i = i + 1 {
    if not(game.segments[i].active) {
      continue
    }

    let edge = game.segments[i].x + game.segments[i].w
    if edge > right_x {
      right_x = edge
      right_y = game.segments[i].y
    }
  }

  (right_x, right_y)
}

///|
fn spawn_chip_arc(game : Game, x0 : Float, x1 : Float, roof_y : Float) -> Unit {
  let steps = clampi((absf(x1 - x0) / 62.0).to_int(), 3, 9)
  if steps <= 0 {
    return
  }

  for i = 0; i < steps; i = i + 1 {
    let t = Float::from_int(i) / Float::from_int(steps - 1)
    let px = lerpf(x0, x1, t)
    let py = roof_y - 54.0 - sinf(t * 3.14159) * 80.0
    spawn_chip(game, px, py)
  }
}

///|
fn spawn_stage_chunk(game : Game) -> Unit {
  let right = best_right_edge(game)
  let prev_end = maxf(right.0, game.last_segment_end)
  let prev_y = right.1

  let stage_factor = Float::from_int(game.stage - 1)
  let gap = randf(92.0, 246.0) + stage_factor * 4.5
  let w = randf(220.0, 540.0)
  let y = clampf(prev_y + randf(-92.0, 92.0), 270.0, 540.0)
  let x = prev_end + gap

  let skin = randi(0, 3)
  let neon = randi(0, 3)
  let seed = randi(0, 9999)
  spawn_segment(
    game,
    x,
    y,
    w,
    Float::from_int(screen_h) - y + 140.0,
    skin,
    neon,
    seed,
  )

  if chance(72) {
    let mut obstacles = randi(1, 2)
    if w > 420.0 {
      obstacles = obstacles + 1
    }

    for _i = 0; _i < obstacles; _i = _i + 1 {
      let px = randf(x + 40.0, x + w - 60.0)
      let choice = randi(0, 99)
      if choice < 36 {
        spawn_obstacle(game, obstacle_vent, px, y - 26.0, 46.0, 26.0, 0.0)
      } else if choice < 62 {
        spawn_obstacle(game, obstacle_sign, px, y - 112.0, 62.0, 28.0, 0.0)
      } else if choice < 86 {
        spawn_obstacle(
          game,
          obstacle_drone,
          px,
          y - 84.0,
          56.0,
          28.0,
          randf(-22.0, 28.0),
        )
      } else {
        spawn_obstacle(game, obstacle_laser, px, y - 140.0, 24.0, 140.0, 0.0)
      }
    }
  }

  if chance(84) {
    let arc_from = x + randf(30.0, 72.0)
    let arc_to = minf(x + w - 28.0, arc_from + randf(120.0, w * 0.72))
    spawn_chip_arc(game, arc_from, arc_to, y)
  }

  if gap > 150.0 || chance(26) {
    let anchor_y = minf(prev_y, y) - randf(126.0, 182.0)
    let anchor_x = prev_end + gap * 0.52
    spawn_anchor(game, anchor_x, anchor_y)
    if chance(58) {
      spawn_chip_arc(game, prev_end + 36.0, x - 20.0, minf(prev_y, y))
    }
  }

  game.last_segment_end = x + w
}

///|
fn ensure_world(game : Game) -> Unit {
  let mut right : Float = -10000.0
  for i = 0; i < game.segments.length(); i = i + 1 {
    if not(game.segments[i].active) {
      continue
    }

    right = maxf(right, game.segments[i].x + game.segments[i].w)
  }

  if right < -9000.0 {
    let y0 : Float = 460.0
    spawn_segment(
      game,
      -120.0,
      y0,
      430.0,
      Float::from_int(screen_h) - y0 + 140.0,
      0,
      0,
      randi(0, 9999),
    )
    spawn_segment(
      game,
      420.0,
      y0 - 24.0,
      390.0,
      Float::from_int(screen_h) - (y0 - 24.0) + 140.0,
      1,
      1,
      randi(0, 9999),
    )
    spawn_segment(
      game,
      900.0,
      y0 + 20.0,
      420.0,
      Float::from_int(screen_h) - (y0 + 20.0) + 140.0,
      2,
      2,
      randi(0, 9999),
    )
    spawn_chip_arc(game, 120.0, 270.0, y0)
    spawn_chip_arc(game, 500.0, 740.0, y0 - 24.0)
    spawn_anchor(game, 350.0, y0 - 164.0)
    spawn_anchor(game, 840.0, y0 - 170.0)
    right = Float::from_int(1320)
    game.last_segment_end = right
  }

  while right < Float::from_int(screen_w) + 1200.0 {
    spawn_stage_chunk(game)
    let r = best_right_edge(game)
    right = r.0
    game.last_segment_end = right
  }
}

///|
fn shift_world(game : Game, dx : Float) -> Unit {
  for i = 0; i < game.segments.length(); i = i + 1 {
    if game.segments[i].active {
      game.segments[i].x = game.segments[i].x - dx
      if game.segments[i].x + game.segments[i].w < -280.0 {
        game.segments[i].active = false
      }
    }
  }

  for i = 0; i < game.obstacles.length(); i = i + 1 {
    if not(game.obstacles[i].active) {
      continue
    }

    game.obstacles[i].x = game.obstacles[i].x - dx
    if game.obstacles[i].x + game.obstacles[i].w < -220.0 {
      game.obstacles[i].active = false
      continue
    }

    game.obstacles[i].phase = game.obstacles[i].phase + 1.7 * dx * 0.01
    if game.obstacles[i].kind == obstacle_drone {
      game.obstacles[i].x = game.obstacles[i].x + game.obstacles[i].vx * 0.04
      game.obstacles[i].y = game.obstacles[i].y +
        sinf(game.obstacles[i].phase) * 0.9
    }

    if game.obstacles[i].hit_lock > 0.0 {
      game.obstacles[i].hit_lock = maxf(
        0.0,
        game.obstacles[i].hit_lock - 0.008 * dx,
      )
    }
  }

  for i = 0; i < game.chips.length(); i = i + 1 {
    if not(game.chips[i].active) {
      continue
    }

    game.chips[i].x = game.chips[i].x - dx
    game.chips[i].bob_t = game.chips[i].bob_t + 0.07
    game.chips[i].spin_t = game.chips[i].spin_t + 0.21
    if game.chips[i].x < -220.0 {
      game.chips[i].active = false
    }
  }

  for i = 0; i < game.anchors.length(); i = i + 1 {
    if not(game.anchors[i].active) {
      continue
    }

    game.anchors[i].x = game.anchors[i].x - dx
    game.anchors[i].glow_t = game.anchors[i].glow_t + 0.09
    if game.anchors[i].x < -260.0 {
      game.anchors[i].active = false
    }
  }
}

///|
fn find_floor(game : Game, center_x : Float) -> (Bool, Float) {
  let mut found = false
  let mut best_y = Float::from_int(screen_h) + 400.0

  for i = 0; i < game.segments.length(); i = i + 1 {
    if not(game.segments[i].active) {
      continue
    }

    let s0 = game.segments[i].x + 4.0
    let s1 = game.segments[i].x + game.segments[i].w - 4.0
    if center_x >= s0 && center_x <= s1 {
      if game.segments[i].y < best_y {
        best_y = game.segments[i].y
        found = true
      }
    }
  }

  (found, best_y)
}

///|
fn apply_damage(game : Game, amount : Float) -> Unit {
  if game.hero.invuln_t > 0.0 {
    return
  }

  game.health = game.health - amount
  if game.health < 0.0 {
    game.health = 0.0
  }

  game.combo = 0
  game.combo_t = 0.0
  game.hero.invuln_t = invuln_time
  game.hero.hurt_t = hurt_flash_time
  game.shake_t = 0.34
  game.flash_t = 0.22

  burst_particles(
    game,
    game.hero.x + game.hero.w * 0.5,
    game.hero.y + game.hero.h * 0.45,
    18,
    2,
  )

  if game.health <= 0.0 {
    game.state = state_game_over
    game.result_t = 0.0
    if game.score > game.best_score {
      game.best_score = game.score
    }
  }
}

///|
fn try_grapple(game : Game) -> Bool {
  if game.stamina < 26.0 || game.hero.grapple_t > 0.0 {
    return false
  }

  let hero_cx = game.hero.x + game.hero.w * 0.5
  let hero_cy = game.hero.y + game.hero.h * 0.32

  let mut found = false
  let mut best_dist : Float = 1000000000.0
  let mut best_y = hero_cy

  for i = 0; i < game.anchors.length(); i = i + 1 {
    if not(game.anchors[i].active) {
      continue
    }

    let dx = game.anchors[i].x - hero_cx
    let dy = game.anchors[i].y - hero_cy
    if dx < 30.0 || dx > 320.0 {
      continue
    }

    if dy > 30.0 {
      continue
    }

    let d2 = dx * dx + dy * dy
    if d2 < best_dist {
      best_dist = d2
      best_y = game.anchors[i].y
      found = true
    }
  }

  if not(found) {
    return false
  }

  game.hero.grapple_t = grapple_duration
  game.hero.grapple_target_y = best_y + 42.0
  game.hero.vy = minf(game.hero.vy, -240.0)
  game.hero.grounded = false
  game.hero.coyote_t = 0.0
  game.stamina = maxf(0.0, game.stamina - 26.0)
  game.flash_t = maxf(game.flash_t, 0.1)

  burst_particles(game, hero_cx, hero_cy, 10, 1)
  true
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

  if game.input_jump_press {
    hero.jump_buf_t = jump_buffer_time
  } else {
    hero.jump_buf_t = maxf(0.0, hero.jump_buf_t - dt)
  }

  if game.input_slide_hold && hero.grounded && hero.slide_t <= 0.0 {
    hero.slide_t = slide_duration
  }

  if hero.slide_t > 0.0 {
    hero.slide_t = maxf(0.0, hero.slide_t - dt)
  }

  let prev_h = hero.h
  hero.h = if hero.slide_t > 0.0 { 54.0 } else { 88.0 }
  if hero.grounded {
    hero.y = hero.floor_y - hero.h
  } else if prev_h != hero.h {
    hero.y = hero.y + (prev_h - hero.h)
  }

  if game.input_grapple_press {
    ignore(try_grapple(game))
  }

  if hero.grapple_t > 0.0 {
    hero.grapple_t = maxf(0.0, hero.grapple_t - dt)
    let pull_t : Float = 1.0 - hero.grapple_t / grapple_duration
    let eased = ease_out_quad(pull_t)
    let target = hero.grapple_target_y - hero.h * 0.5
    hero.y = lerpf(hero.y, target, clampf(7.2 * dt + eased * 0.20, 0.0, 1.0))
    hero.vy = approachf(hero.vy, -110.0, 1200.0 * dt)
  } else {
    hero.vy = hero.vy + world_gravity * dt
    if hero.vy < 0.0 && not(game.input_jump_hold) {
      hero.vy = hero.vy + world_gravity * dt * 0.75
    }
  }

  if hero.jump_buf_t > 0.0 {
    let can_ground_jump = hero.grounded || hero.coyote_t > 0.0
    if can_ground_jump {
      hero.vy = jump_speed
      hero.jump_buf_t = 0.0
      hero.grounded = false
      hero.coyote_t = 0.0
      hero.air_jumps = 1
      burst_particles(game, hero.x + hero.w * 0.38, hero.y + hero.h, 8, 0)
    } else if hero.air_jumps > 0 {
      hero.air_jumps = hero.air_jumps - 1
      hero.vy = double_jump_speed
      hero.jump_buf_t = 0.0
      burst_particles(
        game,
        hero.x + hero.w * 0.45,
        hero.y + hero.h * 0.55,
        10,
        1,
      )
    }
  }

  let prev_y = hero.y
  hero.y = hero.y + hero.vy * dt

  let floor = find_floor(game, hero.x + hero.w * 0.52)
  if floor.0 {
    hero.floor_y = floor.1
  } else {
    hero.floor_y = Float::from_int(screen_h) + 220.0
  }

  let prev_bottom = prev_y + hero.h
  let new_bottom = hero.y + hero.h
  if floor.0 &&
    hero.vy >= 0.0 &&
    prev_bottom <= floor.1 + 12.0 &&
    new_bottom >= floor.1 {
    hero.y = floor.1 - hero.h
    hero.vy = 0.0
    hero.grounded = true
    hero.coyote_t = coyote_time
    hero.air_jumps = 1
  } else {
    if hero.grounded {
      hero.coyote_t = coyote_time
    } else {
      hero.coyote_t = maxf(0.0, hero.coyote_t - dt)
    }
    hero.grounded = false
  }

  if not(hero.grounded) && hero.grapple_t <= 0.0 {
    if hero.slide_t > 0.0 {
      hero.slide_t = 0.0
    }
  }

  if hero.y > Float::from_int(screen_h) + 200.0 {
    apply_damage(game, 28.0)
    hero.y = player_spawn_y
    hero.vy = -220.0
    hero.grounded = false
    hero.coyote_t = 0.0
    hero.air_jumps = 1
  }

  game.stamina = clampf(
    game.stamina + dt * (if hero.grapple_t > 0.0 { 10.0 } else { 19.0 }),
    0.0,
    100.0,
  )

  if hero.grounded && game.speed > 120.0 {
    let gate : Float = if hero.slide_t > 0.0 { 0.06 } else { 0.045 }
    let tick_now = (hero.anim_t / gate).to_int()
    let tick_prev = ((hero.anim_t - dt) / gate).to_int()
    if tick_now != tick_prev {
      spawn_ghost(game, hero, if hero.slide_t > 0.0 { 1.0 } else { 0.0 })
    }
  }
}

///|
fn hero_hitbox(hero : Player) -> (Float, Float, Float, Float) {
  let inset_x : Float = if hero.slide_t > 0.0 { 10.0 } else { 12.0 }
  let inset_top : Float = if hero.slide_t > 0.0 { 10.0 } else { 6.0 }
  let inset_bottom : Float = if hero.slide_t > 0.0 { 6.0 } else { 8.0 }
  (
    hero.x + inset_x,
    hero.y + inset_top,
    hero.w - inset_x * 2.0,
    hero.h - inset_top - inset_bottom,
  )
}

///|
fn score_multiplier(game : Game) -> Float {
  1.0 + Float::from_int(game.combo) * 0.06
}

///|
fn gain_combo(game : Game, amount : Int) -> Unit {
  game.combo = clampi(game.combo + amount, 0, 999)
  game.combo_t = 4.0
}

///|
fn update_obstacles(game : Game, dt : Float) -> Unit {
  let hb = hero_hitbox(game.hero)
  for i = 0; i < game.obstacles.length(); i = i + 1 {
    if not(game.obstacles[i].active) {
      continue
    }

    if game.obstacles[i].kind == obstacle_drone {
      game.obstacles[i].phase = game.obstacles[i].phase + dt * 3.8
      game.obstacles[i].y = game.obstacles[i].y +
        sinf(game.obstacles[i].phase) * 26.0 * dt
    }

    if game.obstacles[i].kind == obstacle_laser {
      game.obstacles[i].phase = game.obstacles[i].phase + dt * 5.4
    }

    if game.obstacles[i].hit_lock > 0.0 {
      game.obstacles[i].hit_lock = maxf(0.0, game.obstacles[i].hit_lock - dt)
    }

    if not(
        rect_overlap(
          hb.0,
          hb.1,
          hb.2,
          hb.3,
          game.obstacles[i].x,
          game.obstacles[i].y,
          game.obstacles[i].w,
          game.obstacles[i].h,
        ),
      ) {
      continue
    }

    let mut ignored_hit = false
    if game.obstacles[i].kind == obstacle_sign {
      if game.hero.slide_t > 0.0 {
        ignored_hit = true
      }
    }

    if game.obstacles[i].kind == obstacle_vent {
      if game.hero.vy < -10.0 {
        ignored_hit = true
      }
    }

    if game.obstacles[i].kind == obstacle_laser {
      let pulse : Float = 0.5 + 0.5 * sinf(game.obstacles[i].phase)
      if pulse < 0.35 {
        ignored_hit = true
      }
    }

    if game.hero.grapple_t > 0.0 && game.obstacles[i].kind == obstacle_drone {
      ignored_hit = true
      game.obstacles[i].active = false
      game.score = game.score +
        (Float::from_int(260) * score_multiplier(game)).to_int()
      gain_combo(game, 2)
      burst_particles(
        game,
        game.obstacles[i].x + game.obstacles[i].w * 0.5,
        game.obstacles[i].y + game.obstacles[i].h * 0.5,
        20,
        1,
      )
    }

    if ignored_hit {
      continue
    }

    if game.obstacles[i].hit_lock <= 0.0 {
      let dmg : Float = if game.obstacles[i].kind == obstacle_laser {
        18.0
      } else {
        13.0
      }
      apply_damage(game, dmg)
      game.obstacles[i].hit_lock = 0.2
    }
  }
}

///|
fn update_chips(game : Game, _dt : Float) -> Unit {
  let hero = game.hero
  let cx = hero.x + hero.w * 0.5
  let cy = hero.y + hero.h * 0.45

  for i = 0; i < game.chips.length(); i = i + 1 {
    if not(game.chips[i].active) {
      continue
    }

    let bob_y = game.chips[i].y + sinf(game.chips[i].bob_t) * 9.0
    let d2 = dist_sq(cx, cy, game.chips[i].x, bob_y)
    if d2 <= 34.0 * 34.0 {
      game.chips[i].active = false
      game.chips_collected = game.chips_collected + 1
      gain_combo(game, 1)
      let base = 100 + game.combo * 5
      game.score = game.score +
        (Float::from_int(base) * score_multiplier(game)).to_int()
      burst_particles(game, game.chips[i].x, bob_y, 8, 0)
    }
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
    game.particles[i].vx = game.particles[i].vx * (1.0 - dt * 2.8)
    game.particles[i].vy = game.particles[i].vy * (1.0 - dt * 2.0) +
      dt * (if game.particles[i].kind == 1 { 130.0 } else { 220.0 })
  }

  for i = 0; i < game.ghosts.length(); i = i + 1 {
    if not(game.ghosts[i].active) {
      continue
    }

    game.ghosts[i].life = game.ghosts[i].life - dt
    if game.ghosts[i].life <= 0.0 {
      game.ghosts[i].active = false
    }
  }
}

///|
fn update_combo_and_score(game : Game, dt : Float, dx : Float) -> Unit {
  if game.combo_t > 0.0 {
    game.combo_t = maxf(0.0, game.combo_t - dt)
    if game.combo_t <= 0.0 {
      game.combo = 0
    }
  }

  game.distance = game.distance + dx
  game.stage_progress = game.stage_progress + dx

  let run_points = (dx * 0.16 * score_multiplier(game)).to_int()
  game.score = game.score + run_points

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn start_stage(game : Game, stage : Int) -> Unit {
  game.stage = stage
  game.stage_goal = stage_base_goal +
    Float::from_int(stage - 1) * stage_goal_growth
  game.stage_progress = 0.0
  game.stage_intro_t = stage_intro_time
  game.speed = base_scroll_speed + Float::from_int(stage - 1) * speed_per_stage
  game.health = clampf(game.health + 14.0, 0.0, 100.0)
}

///|
fn start_run(game : Game) -> Unit {
  clear_segments(game)
  clear_obstacles(game)
  clear_chips(game)
  clear_anchors(game)
  clear_particles(game)
  clear_ghosts(game)
  reset_player(game.hero)

  game.state = state_play
  game.title_t = 0.0
  game.time_s = 0.0
  game.distance = 0.0
  game.score = 0
  game.chips_collected = 0
  game.combo = 0
  game.combo_t = 0.0
  game.health = 100.0
  game.stamina = 100.0
  game.shake_t = 0.0
  game.flash_t = 0.0
  game.last_segment_end = 0.0
  game.hint_t = 8.0
  game.result_t = 0.0
  game.stage_clear_bonus = 0
  game.touch_jump_prev = false
  game.touch_grapple_prev = false
  game.touch_restart_prev = false

  start_stage(game, 1)
  ensure_world(game)
}

///|
fn init_title_scene(game : Game) -> Unit {
  clear_segments(game)
  clear_obstacles(game)
  clear_chips(game)
  clear_anchors(game)
  clear_particles(game)
  clear_ghosts(game)
  reset_player(game.hero)

  game.state = state_title
  game.title_t = 0.0
  game.time_s = 0.0
  game.speed = 160.0
  game.distance = 0.0
  game.chips_collected = 0
  game.combo = 0
  game.combo_t = 0.0
  game.health = 100.0
  game.stamina = 100.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  game.last_segment_end = 0.0
  game.hint_t = 0.0
  game.stage = 1
  game.stage_goal = stage_base_goal
  game.stage_progress = 0.0
  game.touch_jump_prev = false
  game.touch_grapple_prev = false
  game.touch_restart_prev = false

  ensure_world(game)
}

///|
fn update_title_scene(game : Game, dt : Float) -> Unit {
  game.title_t = game.title_t + dt
  let demo_speed : Float = 160.0 + sinf(game.title_t * 0.6) * 30.0
  shift_world(game, demo_speed * dt)
  ensure_world(game)

  let floor = find_floor(game, game.hero.x + game.hero.w * 0.5)
  if floor.0 {
    game.hero.y = floor.1 - game.hero.h
  }

  if chance(4) {
    spawn_particle(
      game,
      randf(80.0, Float::from_int(screen_w) - 120.0),
      randf(120.0, Float::from_int(screen_h) - 200.0),
      randf(-22.0, 22.0),
      randf(-36.0, -10.0),
      randf(0.5, 1.1),
      randf(1.0, 2.4),
      randi(0, 1),
    )
  }

  update_particles(game, dt)

  if game.input_jump_press ||
    game.input_grapple_press ||
    game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_stage_clear(game : Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.hero.vy = approachf(game.hero.vy, 0.0, 1600.0 * dt)
  game.hero.y = game.hero.y + game.hero.vy * dt

  if game.result_t > 0.08 {
    game.result_t = 0.0
    spawn_particle(
      game,
      game.hero.x + randf(0.0, game.hero.w),
      game.hero.y + randf(0.0, game.hero.h),
      randf(-120.0, 120.0),
      randf(-220.0, -40.0),
      randf(0.5, 1.2),
      randf(2.0, 4.6),
      1,
    )
  }

  game.stage_intro_t = maxf(0.0, game.stage_intro_t - dt)
  if game.stage_intro_t <= 0.0 {
    start_stage(game, game.stage + 1)
    game.state = state_play
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  if game.hint_t > 0.0 {
    game.hint_t = maxf(0.0, game.hint_t - dt)
  }

  if game.stage_intro_t > 0.0 {
    game.stage_intro_t = maxf(0.0, game.stage_intro_t - dt)
  }

  let ramp = game.time_s * speed_ramp_per_second
  let stage_speed = base_scroll_speed +
    Float::from_int(game.stage - 1) * speed_per_stage
  let target_speed = stage_speed + ramp
  game.speed = approachf(game.speed, target_speed, dt * 60.0)
  let speed_mul : Float = if game.stage_intro_t > 0.0 { 0.64 } else { 1.0 }
  let dx = game.speed * speed_mul * dt

  shift_world(game, dx)
  ensure_world(game)

  update_player(game, dt)
  update_obstacles(game, dt)
  update_chips(game, dt)
  update_particles(game, dt)
  update_combo_and_score(game, dt, dx)

  if game.stage_progress >= game.stage_goal {
    game.state = state_stage_clear
    game.stage_intro_t = 1.5
    let bonus = 380 + game.combo * 14 + (game.health * 4.0).to_int()
    game.stage_clear_bonus = bonus
    game.score = game.score + bonus
    if game.score > game.best_score {
      game.best_score = game.score
    }
    game.flash_t = 0.4
    burst_particles(
      game,
      game.hero.x + game.hero.w * 0.5,
      game.hero.y + 20.0,
      24,
      1,
    )
  }

  if game.flash_t > 0.0 {
    game.flash_t = maxf(0.0, game.flash_t - dt)
  }

  if game.shake_t > 0.0 {
    game.shake_t = maxf(0.0, game.shake_t - dt)
  }

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_game_over(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  update_particles(game, dt)

  game.result_t = game.result_t + dt
  if game.flash_t > 0.0 {
    game.flash_t = maxf(0.0, game.flash_t - dt)
  }

  if game.input_restart_press || (game.result_t > 0.45 && game.input_jump_press) {
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
    update_particles(game, dt)
    if game.input_restart_press {
      start_run(game)
    }
    return
  }

  update_game_over(game, dt)
}
