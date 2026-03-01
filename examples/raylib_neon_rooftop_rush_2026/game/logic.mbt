///|
fn clear_segments(game : @types.Game) -> Unit {
  for segment in game.segments {
    segment.active = false
    segment.x = -2000.0
    segment.y = Float::from_int(@types.screen_h) + 200.0
    segment.w = 0.0
    segment.h = 0.0
    segment.skin = 0
    segment.neon = 0
    segment.window_seed = 0
  }
}

///|
fn clear_obstacles(game : @types.Game) -> Unit {
  for obstacle in game.obstacles {
    obstacle.active = false
    obstacle.kind = @types.obstacle_vent
    obstacle.x = -2000.0
    obstacle.y = 0.0
    obstacle.w = 0.0
    obstacle.h = 0.0
    obstacle.vx = 0.0
    obstacle.phase = 0.0
    obstacle.hit_lock = 0.0
  }
}

///|
fn clear_chips(game : @types.Game) -> Unit {
  for chip in game.chips {
    chip.active = false
    chip.x = -2000.0
    chip.y = 0.0
    chip.bob_t = 0.0
    chip.spin_t = 0.0
  }
}

///|
fn clear_anchors(game : @types.Game) -> Unit {
  for anchor in game.anchors {
    anchor.active = false
    anchor.x = -2000.0
    anchor.y = 0.0
    anchor.glow_t = 0.0
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
    particle.kind = @types.particle_spark
  }
}

///|
fn clear_ghosts(game : @types.Game) -> Unit {
  for ghost in game.ghosts {
    ghost.active = false
    ghost.x = 0.0
    ghost.y = 0.0
    ghost.w = 0.0
    ghost.h = 0.0
    ghost.life = 0.0
    ghost.hue = 0.0
  }
}

///|
fn reset_player(hero : @types.Player) -> Unit {
  hero.x = @types.player_spawn_x
  hero.y = @types.player_spawn_y
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
fn alloc_segment_slot(game : @types.Game) -> Int {
  for i in 0..<game.segments.length() {
    if not(game.segments[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_x = game.segments[0].x
  for i in 1..<game.segments.length() {
    if game.segments[i].x < best_x {
      best_x = game.segments[i].x
      best_i = i
    }
  }

  best_i
}

///|
fn alloc_obstacle_slot(game : @types.Game) -> Int {
  for i in 0..<game.obstacles.length() {
    if not(game.obstacles[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_x = game.obstacles[0].x
  for i in 1..<game.obstacles.length() {
    if game.obstacles[i].x < best_x {
      best_x = game.obstacles[i].x
      best_i = i
    }
  }

  best_i
}

///|
fn alloc_chip_slot(game : @types.Game) -> Int {
  for i in 0..<game.chips.length() {
    if not(game.chips[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_x = game.chips[0].x
  for i in 1..<game.chips.length() {
    if game.chips[i].x < best_x {
      best_x = game.chips[i].x
      best_i = i
    }
  }

  best_i
}

///|
fn alloc_anchor_slot(game : @types.Game) -> Int {
  for i in 0..<game.anchors.length() {
    if not(game.anchors[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_x = game.anchors[0].x
  for i in 1..<game.anchors.length() {
    if game.anchors[i].x < best_x {
      best_x = game.anchors[i].x
      best_i = i
    }
  }

  best_i
}

///|
fn alloc_particle_slot(game : @types.Game) -> Int {
  for i in 0..<game.particles.length() {
    if not(game.particles[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_life = game.particles[0].life
  for i in 1..<game.particles.length() {
    if game.particles[i].life < best_life {
      best_life = game.particles[i].life
      best_i = i
    }
  }

  best_i
}

///|
fn alloc_ghost_slot(game : @types.Game) -> Int {
  for i in 0..<game.ghosts.length() {
    if not(game.ghosts[i].active) {
      return i
    }
  }

  let mut best_i = 0
  let mut best_life = game.ghosts[0].life
  for i in 1..<game.ghosts.length() {
    if game.ghosts[i].life < best_life {
      best_life = game.ghosts[i].life
      best_i = i
    }
  }

  best_i
}

///|
fn spawn_segment(
  game : @types.Game,
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
  game : @types.Game,
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
  game.obstacles[i].phase = @types.randf(0.0, 6.28)
  game.obstacles[i].hit_lock = 0.0
}

///|
fn spawn_chip(game : @types.Game, x : Float, y : Float) -> Unit {
  let i = alloc_chip_slot(game)
  game.chips[i].active = true
  game.chips[i].x = x
  game.chips[i].y = y
  game.chips[i].bob_t = @types.randf(0.0, 6.28)
  game.chips[i].spin_t = @types.randf(0.0, 6.28)
}

///|
fn spawn_anchor(game : @types.Game, x : Float, y : Float) -> Unit {
  let i = alloc_anchor_slot(game)
  game.anchors[i].active = true
  game.anchors[i].x = x
  game.anchors[i].y = y
  game.anchors[i].glow_t = @types.randf(0.0, 6.28)
}

///|
fn spawn_particle(
  game : @types.Game,
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
  game : @types.Game,
  x : Float,
  y : Float,
  amount : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<amount {
    spawn_particle(
      game,
      x + @types.randf(-18.0, 18.0),
      y + @types.randf(-18.0, 18.0),
      @types.randf(-280.0, 280.0),
      @types.randf(-360.0, -20.0),
      @types.randf(0.30, 0.95),
      @types.randf(2.0, 6.2),
      kind,
    )
  }
}

///|
fn spawn_ghost(game : @types.Game, hero : @types.Player, hue : Float) -> Unit {
  let i = alloc_ghost_slot(game)
  game.ghosts[i].active = true
  game.ghosts[i].x = hero.x + @types.randf(-2.0, 2.0)
  game.ghosts[i].y = hero.y + @types.randf(-2.0, 2.0)
  game.ghosts[i].w = hero.w
  game.ghosts[i].h = hero.h
  game.ghosts[i].life = 0.18
  game.ghosts[i].hue = hue
}

///|
fn best_right_edge(game : @types.Game) -> (Float, Float) {
  let mut right_x : Float = -10000.0
  let mut right_y : Float = 460.0
  for segment in game.segments {
    if not(segment.active) {
      continue
    }

    let edge = segment.x + segment.w
    if edge > right_x {
      right_x = edge
      right_y = segment.y
    }
  }

  (right_x, right_y)
}

///|
fn spawn_chip_arc(
  game : @types.Game,
  x0 : Float,
  x1 : Float,
  roof_y : Float,
) -> Unit {
  let steps = @types.clampi((@types.absf(x1 - x0) / 62.0).to_int(), 3, 9)
  if steps <= 0 {
    return
  }

  for i in 0..<steps {
    let t = Float::from_int(i) / Float::from_int(steps - 1)
    let px = @types.lerpf(x0, x1, t)
    let py = roof_y - 54.0 - @types.sinf(t * 3.14159) * 80.0
    spawn_chip(game, px, py)
  }
}

///|
fn spawn_stage_chunk(game : @types.Game) -> Unit {
  let right = best_right_edge(game)
  let prev_end = @types.maxf(right.0, game.last_segment_end)
  let prev_y = right.1

  let stage_factor = Float::from_int(game.stage - 1)
  let gap = @types.randf(92.0, 246.0) + stage_factor * 4.5
  let w = @types.randf(220.0, 540.0)
  let y = @types.clampf(prev_y + @types.randf(-92.0, 92.0), 270.0, 540.0)
  let x = prev_end + gap

  let skin = @types.randi(0, 3)
  let neon = @types.randi(0, 3)
  let seed = @types.randi(0, 9999)
  spawn_segment(
    game,
    x,
    y,
    w,
    Float::from_int(@types.screen_h) - y + 140.0,
    skin,
    neon,
    seed,
  )

  if @types.chance(72) {
    let mut obstacles = @types.randi(1, 2)
    if w > 420.0 {
      obstacles = obstacles + 1
    }

    for _i in 0..<obstacles {
      let px = @types.randf(x + 40.0, x + w - 60.0)
      let choice = @types.randi(0, 99)
      if choice < 36 {
        spawn_obstacle(
          game,
          @types.obstacle_vent,
          px,
          y - 26.0,
          46.0,
          26.0,
          0.0,
        )
      } else if choice < 62 {
        spawn_obstacle(
          game,
          @types.obstacle_sign,
          px,
          y - 112.0,
          62.0,
          28.0,
          0.0,
        )
      } else if choice < 86 {
        spawn_obstacle(
          game,
          @types.obstacle_drone,
          px,
          y - 84.0,
          56.0,
          28.0,
          @types.randf(-22.0, 28.0),
        )
      } else {
        spawn_obstacle(
          game,
          @types.obstacle_laser,
          px,
          y - 140.0,
          24.0,
          140.0,
          0.0,
        )
      }
    }
  }

  if @types.chance(84) {
    let arc_from = x + @types.randf(30.0, 72.0)
    let arc_to = @types.minf(
      x + w - 28.0,
      arc_from + @types.randf(120.0, w * 0.72),
    )
    spawn_chip_arc(game, arc_from, arc_to, y)
  }

  if gap > 150.0 || @types.chance(26) {
    let anchor_y = @types.minf(prev_y, y) - @types.randf(126.0, 182.0)
    let anchor_x = prev_end + gap * 0.52
    spawn_anchor(game, anchor_x, anchor_y)
    if @types.chance(58) {
      spawn_chip_arc(game, prev_end + 36.0, x - 20.0, @types.minf(prev_y, y))
    }
  }

  game.last_segment_end = x + w
}

///|
fn ensure_world(game : @types.Game) -> Unit {
  let mut right : Float = -10000.0
  for segment in game.segments {
    if not(segment.active) {
      continue
    }

    right = @types.maxf(right, segment.x + segment.w)
  }

  if right < -9000.0 {
    let y0 : Float = 460.0
    spawn_segment(
      game,
      -120.0,
      y0,
      430.0,
      Float::from_int(@types.screen_h) - y0 + 140.0,
      0,
      0,
      @types.randi(0, 9999),
    )
    spawn_segment(
      game,
      420.0,
      y0 - 24.0,
      390.0,
      Float::from_int(@types.screen_h) - (y0 - 24.0) + 140.0,
      1,
      1,
      @types.randi(0, 9999),
    )
    spawn_segment(
      game,
      900.0,
      y0 + 20.0,
      420.0,
      Float::from_int(@types.screen_h) - (y0 + 20.0) + 140.0,
      2,
      2,
      @types.randi(0, 9999),
    )
    spawn_chip_arc(game, 120.0, 270.0, y0)
    spawn_chip_arc(game, 500.0, 740.0, y0 - 24.0)
    spawn_anchor(game, 350.0, y0 - 164.0)
    spawn_anchor(game, 840.0, y0 - 170.0)
    right = Float::from_int(1320)
    game.last_segment_end = right
  }

  while right < Float::from_int(@types.screen_w) + 1200.0 {
    spawn_stage_chunk(game)
    let r = best_right_edge(game)
    right = r.0
    game.last_segment_end = right
  }
}

///|
fn shift_world(game : @types.Game, dx : Float) -> Unit {
  for segment in game.segments {
    if segment.active {
      segment.x = segment.x - dx
      if segment.x + segment.w < -280.0 {
        segment.active = false
      }
    }
  }

  for obstacle in game.obstacles {
    if not(obstacle.active) {
      continue
    }

    obstacle.x = obstacle.x - dx
    if obstacle.x + obstacle.w < -220.0 {
      obstacle.active = false
      continue
    }

    obstacle.phase = obstacle.phase + 1.7 * dx * 0.01
    if obstacle.kind == @types.obstacle_drone {
      obstacle.x = obstacle.x + obstacle.vx * 0.04
      obstacle.y = obstacle.y + @types.sinf(obstacle.phase) * 0.9
    }

    if obstacle.hit_lock > 0.0 {
      obstacle.hit_lock = @types.maxf(0.0, obstacle.hit_lock - 0.008 * dx)
    }
  }

  for chip in game.chips {
    if not(chip.active) {
      continue
    }

    chip.x = chip.x - dx
    chip.bob_t = chip.bob_t + 0.07
    chip.spin_t = chip.spin_t + 0.21
    if chip.x < -220.0 {
      chip.active = false
    }
  }

  for anchor in game.anchors {
    if not(anchor.active) {
      continue
    }

    anchor.x = anchor.x - dx
    anchor.glow_t = anchor.glow_t + 0.09
    if anchor.x < -260.0 {
      anchor.active = false
    }
  }
}

///|
fn find_floor(game : @types.Game, center_x : Float) -> (Bool, Float) {
  let mut found = false
  let mut best_y = Float::from_int(@types.screen_h) + 400.0

  for segment in game.segments {
    if not(segment.active) {
      continue
    }

    let s0 = segment.x + 4.0
    let s1 = segment.x + segment.w - 4.0
    if center_x >= s0 && center_x <= s1 {
      if segment.y < best_y {
        best_y = segment.y
        found = true
      }
    }
  }

  (found, best_y)
}

///|
fn apply_damage(game : @types.Game, amount : Float) -> Unit {
  if game.hero.invuln_t > 0.0 {
    return
  }

  game.health = game.health - amount
  if game.health < 0.0 {
    game.health = 0.0
  }

  game.combo = 0
  game.combo_t = 0.0
  game.hero.invuln_t = @types.invuln_time
  game.hero.hurt_t = @types.hurt_flash_time
  game.shake_t = 0.34
  game.flash_t = 0.22

  burst_particles(
    game,
    game.hero.x + game.hero.w * 0.5,
    game.hero.y + game.hero.h * 0.45,
    18,
    @types.particle_hurt,
  )

  if game.health <= 0.0 {
    game.state = @types.state_game_over
    game.result_t = 0.0
    if game.score > game.best_score {
      game.best_score = game.score
    }
  }
}

///|
fn try_grapple(game : @types.Game) -> Bool {
  if game.stamina < 26.0 || game.hero.grapple_t > 0.0 {
    return false
  }

  let hero_cx = game.hero.x + game.hero.w * 0.5
  let hero_cy = game.hero.y + game.hero.h * 0.32

  let mut found = false
  let mut best_dist : Float = 1000000000.0
  let mut best_y = hero_cy

  for anchor in game.anchors {
    if not(anchor.active) {
      continue
    }

    let dx = anchor.x - hero_cx
    let dy = anchor.y - hero_cy
    if dx < 30.0 || dx > 320.0 {
      continue
    }

    if dy > 30.0 {
      continue
    }

    let d2 = dx * dx + dy * dy
    if d2 < best_dist {
      best_dist = d2
      best_y = anchor.y
      found = true
    }
  }

  if not(found) {
    return false
  }

  game.hero.grapple_t = @types.grapple_duration
  game.hero.grapple_target_y = best_y + 42.0
  game.hero.vy = @types.minf(game.hero.vy, -240.0)
  game.hero.grounded = false
  game.hero.coyote_t = 0.0
  game.stamina = @types.maxf(0.0, game.stamina - 26.0)
  game.flash_t = @types.maxf(game.flash_t, 0.1)

  burst_particles(game, hero_cx, hero_cy, 10, @types.particle_glow)
  true
}

///|
fn update_player(game : @types.Game, dt : Float) -> Unit {
  let hero = game.hero

  hero.anim_t = hero.anim_t + dt

  if hero.invuln_t > 0.0 {
    hero.invuln_t = @types.maxf(0.0, hero.invuln_t - dt)
  }

  if hero.hurt_t > 0.0 {
    hero.hurt_t = @types.maxf(0.0, hero.hurt_t - dt)
  }

  if game.input_jump_press {
    hero.jump_buf_t = @types.jump_buffer_time
  } else {
    hero.jump_buf_t = @types.maxf(0.0, hero.jump_buf_t - dt)
  }

  if game.input_slide_hold && hero.grounded && hero.slide_t <= 0.0 {
    hero.slide_t = @types.slide_duration
  }

  if hero.slide_t > 0.0 {
    hero.slide_t = @types.maxf(0.0, hero.slide_t - dt)
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
    hero.grapple_t = @types.maxf(0.0, hero.grapple_t - dt)
    let pull_t : Float = 1.0 - hero.grapple_t / @types.grapple_duration
    let eased = @types.ease_out_quad(pull_t)
    let target = hero.grapple_target_y - hero.h * 0.5
    hero.y = @types.lerpf(
      hero.y,
      target,
      @types.clampf(7.2 * dt + eased * 0.20, 0.0, 1.0),
    )
    hero.vy = @types.approachf(hero.vy, -110.0, 1200.0 * dt)
  } else {
    hero.vy = hero.vy + @types.world_gravity * dt
    if hero.vy < 0.0 && not(game.input_jump_hold) {
      hero.vy = hero.vy + @types.world_gravity * dt * 0.75
    }
  }

  if hero.jump_buf_t > 0.0 {
    let can_ground_jump = hero.grounded || hero.coyote_t > 0.0
    if can_ground_jump {
      hero.vy = @types.jump_speed
      hero.jump_buf_t = 0.0
      hero.grounded = false
      hero.coyote_t = 0.0
      hero.air_jumps = 1
      burst_particles(
        game,
        hero.x + hero.w * 0.38,
        hero.y + hero.h,
        8,
        @types.particle_spark,
      )
    } else if hero.air_jumps > 0 {
      hero.air_jumps = hero.air_jumps - 1
      hero.vy = @types.double_jump_speed
      hero.jump_buf_t = 0.0
      burst_particles(
        game,
        hero.x + hero.w * 0.45,
        hero.y + hero.h * 0.55,
        10,
        @types.particle_glow,
      )
    }
  }

  let prev_y = hero.y
  hero.y = hero.y + hero.vy * dt

  let floor = find_floor(game, hero.x + hero.w * 0.52)
  if floor.0 {
    hero.floor_y = floor.1
  } else {
    hero.floor_y = Float::from_int(@types.screen_h) + 220.0
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
    hero.coyote_t = @types.coyote_time
    hero.air_jumps = 1
  } else {
    if hero.grounded {
      hero.coyote_t = @types.coyote_time
    } else {
      hero.coyote_t = @types.maxf(0.0, hero.coyote_t - dt)
    }
    hero.grounded = false
  }

  if not(hero.grounded) && hero.grapple_t <= 0.0 {
    if hero.slide_t > 0.0 {
      hero.slide_t = 0.0
    }
  }

  if hero.y > Float::from_int(@types.screen_h) + 200.0 {
    apply_damage(game, 28.0)
    hero.y = @types.player_spawn_y
    hero.vy = -220.0
    hero.grounded = false
    hero.coyote_t = 0.0
    hero.air_jumps = 1
  }

  game.stamina = @types.clampf(
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
fn hero_hitbox(hero : @types.Player) -> (Float, Float, Float, Float) {
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
fn score_multiplier(game : @types.Game) -> Float {
  1.0 + Float::from_int(game.combo) * 0.06
}

///|
fn gain_combo(game : @types.Game, amount : Int) -> Unit {
  game.combo = @types.clampi(game.combo + amount, 0, 999)
  game.combo_t = 4.0
}

///|
fn update_obstacles(game : @types.Game, dt : Float) -> Unit {
  let hb = hero_hitbox(game.hero)
  for obstacle in game.obstacles {
    if not(obstacle.active) {
      continue
    }

    if obstacle.kind == @types.obstacle_drone {
      obstacle.phase = obstacle.phase + dt * 3.8
      obstacle.y = obstacle.y + @types.sinf(obstacle.phase) * 26.0 * dt
    }

    if obstacle.kind == @types.obstacle_laser {
      obstacle.phase = obstacle.phase + dt * 5.4
    }

    if obstacle.hit_lock > 0.0 {
      obstacle.hit_lock = @types.maxf(0.0, obstacle.hit_lock - dt)
    }

    if not(
        @types.rect_overlap(
          hb.0,
          hb.1,
          hb.2,
          hb.3,
          obstacle.x,
          obstacle.y,
          obstacle.w,
          obstacle.h,
        ),
      ) {
      continue
    }

    let mut ignored_hit = false
    if obstacle.kind == @types.obstacle_sign {
      if game.hero.slide_t > 0.0 {
        ignored_hit = true
      }
    }

    if obstacle.kind == @types.obstacle_vent {
      if game.hero.vy < -10.0 {
        ignored_hit = true
      }
    }

    if obstacle.kind == @types.obstacle_laser {
      let pulse : Float = 0.5 + 0.5 * @types.sinf(obstacle.phase)
      if pulse < 0.35 {
        ignored_hit = true
      }
    }

    if game.hero.grapple_t > 0.0 && obstacle.kind == @types.obstacle_drone {
      ignored_hit = true
      obstacle.active = false
      game.score = game.score +
        (Float::from_int(260) * score_multiplier(game)).to_int()
      gain_combo(game, 2)
      burst_particles(
        game,
        obstacle.x + obstacle.w * 0.5,
        obstacle.y + obstacle.h * 0.5,
        20,
        @types.particle_glow,
      )
    }

    if ignored_hit {
      continue
    }

    if obstacle.hit_lock <= 0.0 {
      let dmg : Float = if obstacle.kind == @types.obstacle_laser {
        18.0
      } else {
        13.0
      }
      apply_damage(game, dmg)
      obstacle.hit_lock = 0.2
    }
  }
}

///|
fn update_chips(game : @types.Game, _dt : Float) -> Unit {
  let hero = game.hero
  let cx = hero.x + hero.w * 0.5
  let cy = hero.y + hero.h * 0.45

  for chip in game.chips {
    if not(chip.active) {
      continue
    }

    let bob_y = chip.y + @types.sinf(chip.bob_t) * 9.0
    let d2 = @types.dist_sq(cx, cy, chip.x, bob_y)
    if d2 <= 34.0 * 34.0 {
      chip.active = false
      game.chips_collected = game.chips_collected + 1
      gain_combo(game, 1)
      let base = 100 + game.combo * 5
      game.score = game.score +
        (Float::from_int(base) * score_multiplier(game)).to_int()
      burst_particles(game, chip.x, bob_y, 8, @types.particle_spark)
    }
  }
}

///|
fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for particle in game.particles {
    if not(particle.active) {
      continue
    }

    particle.life = particle.life - dt
    if particle.life <= 0.0 {
      particle.active = false
      continue
    }

    particle.x = particle.x + particle.vx * dt
    particle.y = particle.y + particle.vy * dt
    particle.vx = particle.vx * (1.0 - dt * 2.8)
    particle.vy = particle.vy * (1.0 - dt * 2.0) +
      dt * (if particle.kind == @types.particle_glow { 130.0 } else { 220.0 })
  }

  for ghost in game.ghosts {
    if not(ghost.active) {
      continue
    }

    ghost.life = ghost.life - dt
    if ghost.life <= 0.0 {
      ghost.active = false
    }
  }
}

///|
fn update_combo_and_score(game : @types.Game, dt : Float, dx : Float) -> Unit {
  if game.combo_t > 0.0 {
    game.combo_t = @types.maxf(0.0, game.combo_t - dt)
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
fn start_stage(game : @types.Game, stage : Int) -> Unit {
  game.stage = stage
  game.stage_goal = @types.stage_base_goal +
    Float::from_int(stage - 1) * @types.stage_goal_growth
  game.stage_progress = 0.0
  game.stage_intro_t = @types.stage_intro_time
  game.speed = @types.base_scroll_speed +
    Float::from_int(stage - 1) * @types.speed_per_stage
  game.health = @types.clampf(game.health + 14.0, 0.0, 100.0)
}

///|
fn start_run(game : @types.Game) -> Unit {
  clear_segments(game)
  clear_obstacles(game)
  clear_chips(game)
  clear_anchors(game)
  clear_particles(game)
  clear_ghosts(game)
  reset_player(game.hero)

  game.state = @types.state_play
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
fn init_title_scene(game : @types.Game) -> Unit {
  clear_segments(game)
  clear_obstacles(game)
  clear_chips(game)
  clear_anchors(game)
  clear_particles(game)
  clear_ghosts(game)
  reset_player(game.hero)

  game.state = @types.state_title
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
  game.stage_goal = @types.stage_base_goal
  game.stage_progress = 0.0
  game.touch_jump_prev = false
  game.touch_grapple_prev = false
  game.touch_restart_prev = false

  ensure_world(game)
}

///|
fn update_title_scene(game : @types.Game, dt : Float) -> Unit {
  game.title_t = game.title_t + dt
  let demo_speed : Float = 160.0 + @types.sinf(game.title_t * 0.6) * 30.0
  shift_world(game, demo_speed * dt)
  ensure_world(game)

  let floor = find_floor(game, game.hero.x + game.hero.w * 0.5)
  if floor.0 {
    game.hero.y = floor.1 - game.hero.h
  }

  if @types.chance(4) {
    spawn_particle(
      game,
      @types.randf(80.0, Float::from_int(@types.screen_w) - 120.0),
      @types.randf(120.0, Float::from_int(@types.screen_h) - 200.0),
      @types.randf(-22.0, 22.0),
      @types.randf(-36.0, -10.0),
      @types.randf(0.5, 1.1),
      @types.randf(1.0, 2.4),
      if @types.chance(50) {
        @types.particle_spark
      } else {
        @types.particle_glow
      },
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
fn update_stage_clear(game : @types.Game, dt : Float) -> Unit {
  game.result_t = game.result_t + dt
  game.hero.vy = @types.approachf(game.hero.vy, 0.0, 1600.0 * dt)
  game.hero.y = game.hero.y + game.hero.vy * dt

  if game.result_t > 0.08 {
    game.result_t = 0.0
    spawn_particle(
      game,
      game.hero.x + @types.randf(0.0, game.hero.w),
      game.hero.y + @types.randf(0.0, game.hero.h),
      @types.randf(-120.0, 120.0),
      @types.randf(-220.0, -40.0),
      @types.randf(0.5, 1.2),
      @types.randf(2.0, 4.6),
      @types.particle_glow,
    )
  }

  game.stage_intro_t = @types.maxf(0.0, game.stage_intro_t - dt)
  if game.stage_intro_t <= 0.0 {
    start_stage(game, game.stage + 1)
    game.state = @types.state_play
  }
}

///|
fn update_play(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  if game.hint_t > 0.0 {
    game.hint_t = @types.maxf(0.0, game.hint_t - dt)
  }

  if game.stage_intro_t > 0.0 {
    game.stage_intro_t = @types.maxf(0.0, game.stage_intro_t - dt)
  }

  let ramp = game.time_s * @types.speed_ramp_per_second
  let stage_speed = @types.base_scroll_speed +
    Float::from_int(game.stage - 1) * @types.speed_per_stage
  let target_speed = stage_speed + ramp
  game.speed = @types.approachf(game.speed, target_speed, dt * 60.0)
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
    game.state = @types.state_stage_clear
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
      @types.particle_glow,
    )
  }

  if game.flash_t > 0.0 {
    game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  }

  if game.shake_t > 0.0 {
    game.shake_t = @types.maxf(0.0, game.shake_t - dt)
  }

  if game.input_restart_press {
    start_run(game)
  }
}

///|
fn update_game_over(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  update_particles(game, dt)

  game.result_t = game.result_t + dt
  if game.flash_t > 0.0 {
    game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  }

  if game.input_restart_press || (game.result_t > 0.45 && game.input_jump_press) {
    start_run(game)
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.mouse_x = Float::from_int(@raylib.get_mouse_x())
  game.mouse_y = Float::from_int(@raylib.get_mouse_y())
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    @raylib.get_touch_point_count() > 0

  // Dispatch input based on current state (input may change state)
  let prev_state = game.state
  if game.state == @types.state_title {
    update_title_input(game)
  } else if game.state == @types.state_play {
    update_play_input(game)
  } else if game.state == @types.state_stage_clear {
    update_stage_clear_input(game)
  } else if game.state == @types.state_game_over {
    update_result_input(game)
  }

  // If state changed during input, clear stale input flags
  if game.state != prev_state {
    game.input_jump_press = false
    game.input_grapple_press = false
    game.input_pause_press = false
    game.input_restart_press = false
  }

  // Dispatch update based on (potentially changed) state
  if game.state == @types.state_title {
    update_title_scene(game, dt)
  } else if game.state == @types.state_play {
    update_play(game, dt)
  } else if game.state == @types.state_stage_clear {
    update_stage_clear(game, dt)
    update_particles(game, dt)
    if game.input_restart_press {
      start_run(game)
    }
  } else if game.state == @types.state_game_over {
    update_game_over(game, dt)
  }
}

///|
pub fn init_title(game : @types.Game) -> Unit {
  init_title_scene(game)
}
