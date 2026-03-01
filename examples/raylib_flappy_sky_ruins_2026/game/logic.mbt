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
  for particle in game.particles {
    if particle.active {
      continue
    }

    particle.active = true
    particle.x = x
    particle.y = y
    particle.vx = vx
    particle.vy = vy
    particle.life = life
    particle.size = size
    particle.kind = kind
    break
  }
}

///|
fn burst(game : @types.Game, x : Float, y : Float, n : Int, kind : Int) -> Unit {
  for _i in 0..<n {
    spawn_particle(
      game,
      x + @types.randf(-10.0, 10.0),
      y + @types.randf(-10.0, 10.0),
      @types.randf(-240.0, 240.0),
      @types.randf(-260.0, 120.0),
      @types.randf(0.2, 1.0),
      @types.randf(1.3, 5.2),
      kind,
    )
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
    particle.vx = particle.vx * (1.0 - dt * 2.4)
    particle.vy = particle.vy * (1.0 - dt * 2.2) + dt * 180.0
  }
}

///|
fn clear_world(game : @types.Game) -> Unit {
  for obstacle in game.obstacles {
    obstacle.active = false
    obstacle.x = 0.0
    obstacle.gap_y = 0.0
    obstacle.gap_h = 0.0
    obstacle.w = 0.0
    obstacle.speed = 0.0
    obstacle.kind = @types.obstacle_kind_gate
    obstacle.phase = 0.0
    obstacle.scored = false
  }

  for pickup in game.pickups {
    pickup.active = false
    pickup.x = 0.0
    pickup.y = 0.0
    pickup.kind = @types.pickup_score
    pickup.phase = 0.0
  }
}

///|
fn init_player(game : @types.Game) -> Unit {
  game.px = Float::from_int(@types.world_x0 + @types.world_w / 4)
  game.py = Float::from_int(@types.world_y0 + @types.world_h / 2)
  game.vy = 0.0
}

///|
fn start_match(game : @types.Game) -> Unit {
  clear_world(game)
  clear_particles(game)

  game.state = Play

  init_player(game)

  game.lives = 3
  game.shield_t = 0.0
  game.boost_meter = 1.0
  game.boost_on = false
  game.boost_t = 0.0

  game.score = 0
  game.distance = 0
  game.combo = 0
  game.combo_t = 0.0
  game.level = 1

  game.spawn_t = 0.8
  game.pickup_t = 1.8

  game.game_t = 0.0
  game.ui_t = 0.0
  game.msg_t = 0.0

  game.hint_left = 3
  game.hint_t = 0.0
  game.hint_y = game.py

  game.shake_t = 0.0
  game.win = false
  game.touch_cd = 0.0

  @types.set_msg(game, "Tap/Space to flap. Survive the ruins.", 2.2)
}

///|
fn flap(game : @types.Game) -> Unit {
  if game.state != Play {
    return
  }

  game.vy = @types.flap_impulse
  game.boost_on = false

  burst(game, game.px - 8.0, game.py + 6.0, 10, 0)
}

///|
fn spawn_obstacle(game : @types.Game) -> Bool {
  for obstacle in game.obstacles {
    if obstacle.active {
      continue
    }

    obstacle.active = true
    obstacle.x = @types.world_right() + @types.randf(30.0, 120.0)
    obstacle.w = @types.randf(82.0, 124.0)
    obstacle.speed = @types.randf(220.0, 320.0) +
      Float::from_int(game.level) * 10.0

    let min_y : Float = @types.world_top() + 140.0
    let max_y : Float = @types.world_bottom() - 140.0
    obstacle.gap_y = @types.randf(min_y, max_y)

    obstacle.gap_h = @types.randf(220.0, 340.0) -
      Float::from_int(game.level) * 4.0
    obstacle.gap_h = @types.clampf(obstacle.gap_h, 170.0, 340.0)

    let roll : Int = @raylib.get_random_value(0, 99)
    obstacle.kind = if roll < 62 {
      @types.obstacle_kind_gate
    } else if roll < 86 {
      @types.obstacle_kind_beam
    } else {
      @types.obstacle_kind_spinner
    }

    obstacle.phase = @types.randf(0.0, 6.28)
    obstacle.scored = false

    return true
  }

  false
}

///|
fn spawn_pickup(game : @types.Game) -> Bool {
  for pickup in game.pickups {
    if pickup.active {
      continue
    }

    pickup.active = true
    pickup.x = @types.world_right() + @types.randf(120.0, 300.0)
    pickup.y = @types.randf(
      @types.world_top() + 120.0,
      @types.world_bottom() - 120.0,
    )

    let roll : Int = @raylib.get_random_value(0, 99)
    pickup.kind = if roll < 56 {
      @types.pickup_score
    } else if roll < 78 {
      @types.pickup_boost
    } else if roll < 93 {
      @types.pickup_shield
    } else {
      @types.pickup_heart
    }

    pickup.phase = @types.randf(0.0, 6.28)

    return true
  }

  false
}

///|
fn score_obstacle(game : @types.Game, i : Int) -> Unit {
  if game.obstacles[i].scored {
    return
  }

  if game.obstacles[i].x + game.obstacles[i].w < game.px {
    game.obstacles[i].scored = true

    game.score = game.score + 12 + game.level
    game.combo = game.combo + 1
    game.combo_t = 1.2

    if game.combo > 1 {
      game.score = game.score + game.combo * 3
    }

    if game.score > game.best_score {
      game.best_score = game.score
    }

    if game.combo % 5 == 0 {
      @types.set_msg(game, "Combo x\{game.combo}", 0.8)
    }
  }
}

///|
fn point_hits_obstacle(
  ob : @types.Obstacle,
  px : Float,
  py : Float,
  pr : Float,
) -> Bool {
  if not(ob.active) {
    return false
  }

  let x0 : Float = ob.x
  let x1 : Float = ob.x + ob.w

  if px + pr < x0 || px - pr > x1 {
    return false
  }

  let gy : Float = @types.obstacle_gap_mid(ob)
  let gh : Float = ob.gap_h

  let top_h : Float = gy - gh / 2.0 - @types.world_top()
  let bot_y : Float = gy + gh / 2.0

  let hit_top : Bool = py - pr < @types.world_top() + top_h
  let hit_bottom : Bool = py + pr > bot_y

  hit_top || hit_bottom
}

///|
fn point_hits_pickup(
  pk : @types.Pickup,
  px : Float,
  py : Float,
  pr : Float,
) -> Bool {
  if not(pk.active) {
    return false
  }

  let r : Float = if pk.kind == @types.pickup_score { 16.0 } else { 20.0 }
  let dx : Float = px - pk.x
  let dy : Float = py - pk.y
  dx * dx + dy * dy <= (pr + r) * (pr + r)
}

///|
fn damage_player(game : @types.Game, msg : String) -> Unit {
  if game.shield_t > 0.0 {
    game.shield_t = 0.0
    @types.set_msg(game, "Shield broke", 0.7)
    return
  }

  game.lives = game.lives - 1
  game.combo = 0
  game.combo_t = 0.0

  burst(game, game.px, game.py, 24, 2)
  game.shake_t = @types.maxf(game.shake_t, 0.18)

  if game.lives <= 0 {
    game.state = Result
    game.win = false
    if game.score > game.best_score {
      game.best_score = game.score
    }
    @types.set_msg(game, "Ruins defeated you", 1.6)
    return
  }

  game.py = Float::from_int(@types.world_y0 + @types.world_h / 2)
  game.vy = @types.flap_impulse * 0.35
  @types.set_msg(game, msg + "  Lives \{game.lives}", 0.9)
}

///|
fn collect_pickup(game : @types.Game, i : Int) -> Unit {
  if not(game.pickups[i].active) {
    return
  }

  let kind : Int = game.pickups[i].kind
  game.pickups[i].active = false

  burst(game, game.px, game.py, 14, 1)

  if kind == @types.pickup_score {
    game.score = game.score + 90 + game.level * 4
    @types.set_msg(game, "+Score", 0.6)
  } else if kind == @types.pickup_boost {
    game.boost_meter = @types.clampf(game.boost_meter + 0.44, 0.0, 1.0)
    @types.set_msg(game, "Boost refilled", 0.7)
  } else if kind == @types.pickup_shield {
    game.shield_t = 6.0
    @types.set_msg(game, "Shield online", 0.8)
  } else {
    game.lives = @types.mini(5, game.lives + 1)
    @types.set_msg(game, "+1 life", 0.8)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn use_hint(game : @types.Game) -> Bool {
  if game.state != Play {
    return false
  }

  if game.hint_left <= 0 {
    @types.set_msg(game, "No hints", 0.6)
    return false
  }

  let mut best_y : Float = game.py
  let mut best_dist : Float = 1000000000.0

  for obstacle in game.obstacles {
    if not(obstacle.active) {
      continue
    }

    if obstacle.x + obstacle.w < game.px {
      continue
    }

    let d : Float = obstacle.x - game.px
    if d < best_dist {
      best_dist = d
      best_y = @types.obstacle_gap_mid(obstacle)
    }
  }

  game.hint_left = game.hint_left - 1
  game.hint_t = 1.6
  game.hint_y = best_y
  @types.set_msg(game, "Hint: follow ring", 0.8)

  true
}

///|
fn update_obstacles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.obstacles.length() {
    if not(game.obstacles[i].active) {
      continue
    }

    game.obstacles[i].x = game.obstacles[i].x - game.obstacles[i].speed * dt
    game.obstacles[i].phase = game.obstacles[i].phase + dt * 2.0

    score_obstacle(game, i)

    if game.obstacles[i].x + game.obstacles[i].w < @types.world_left() - 80.0 {
      game.obstacles[i].active = false
    }
  }
}

///|
fn update_pickups(game : @types.Game, dt : Float) -> Unit {
  for pickup in game.pickups {
    if not(pickup.active) {
      continue
    }

    let speed : Float = 220.0 + Float::from_int(game.level) * 8.0
    pickup.x = pickup.x - speed * dt
    pickup.phase = pickup.phase + dt * 3.8

    pickup.y = pickup.y +
      Float::from_double(@math.sin(pickup.phase.to_double())) * dt * 40.0

    if pickup.x < @types.world_left() - 70.0 {
      pickup.active = false
    }
  }
}

///|
fn update_physics(game : @types.Game, dt : Float) -> Unit {
  let speed_scale : Float = if game.boost_on { 1.22 } else { 1.0 }

  game.vy = game.vy + @types.gravity * dt
  game.vy = @types.clampf(game.vy, -620.0, 760.0)

  game.py = game.py + game.vy * dt * speed_scale

  if game.py - @types.player_r < @types.world_top() {
    game.py = @types.world_top() + @types.player_r
    game.vy = 40.0
    damage_player(game, "Roof hit")
  }

  if game.py + @types.player_r > @types.world_bottom() {
    game.py = @types.world_bottom() - @types.player_r
    game.vy = -120.0
    damage_player(game, "Ground hit")
  }
}

///|
fn update_collisions(game : @types.Game) -> Unit {
  for obstacle in game.obstacles {
    if not(obstacle.active) {
      continue
    }

    if point_hits_obstacle(obstacle, game.px, game.py, @types.player_r) {
      damage_player(game, "Obstacle hit")
      return
    }
  }

  for i in 0..<game.pickups.length() {
    if point_hits_pickup(game.pickups[i], game.px, game.py, @types.player_r) {
      collect_pickup(game, i)
    }
  }
}

///|
fn update_spawns(game : @types.Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  if game.spawn_t <= 0.0 {
    ignore(spawn_obstacle(game))

    let base : Float = 1.12 - Float::from_int(game.level) * 0.04
    game.spawn_t = @types.clampf(base + @types.randf(-0.08, 0.16), 0.6, 1.25)
  }

  game.pickup_t = game.pickup_t - dt
  if game.pickup_t <= 0.0 {
    ignore(spawn_pickup(game))
    game.pickup_t = @types.randf(2.1, 4.2)
  }
}

///|
fn check_level_up(game : @types.Game) -> Unit {
  let lv : Int = @types.clampi(1 + game.score / 520, 1, 10)
  if lv != game.level {
    game.level = lv
    @types.set_msg(game, "Level \{game.level}", 0.8)
  }
}

///|
fn check_win(game : @types.Game) -> Unit {
  if game.game_t < 180.0 {
    return
  }

  game.state = Result
  game.win = true
  if game.score > game.best_score {
    game.best_score = game.score
  }
  @types.set_msg(game, "Sky ruins conquered", 1.6)
}

///|
pub fn update_play(game : @types.Game, dt : Float) -> Unit {
  game.ui_t = game.ui_t + dt

  if game.msg_t > 0.0 {
    game.msg_t = game.msg_t - dt
  }
  if game.combo_t > 0.0 {
    game.combo_t = game.combo_t - dt
  } else if game.combo > 0 {
    game.combo = game.combo - 1
    game.combo_t = if game.combo > 0 { 0.4 } else { 0.0 }
  }

  if game.shield_t > 0.0 {
    game.shield_t = game.shield_t - dt
  }
  if game.hint_t > 0.0 {
    game.hint_t = game.hint_t - dt
  }
  if game.shake_t > 0.0 {
    game.shake_t = game.shake_t - dt
  }
  if game.touch_cd > 0.0 {
    game.touch_cd = game.touch_cd - dt
  }

  if game.boost_on {
    game.boost_meter = @types.clampf(game.boost_meter - dt * 0.48, 0.0, 1.0)
    game.boost_t = game.boost_t + dt
    if game.boost_meter <= 0.0 {
      game.boost_on = false
    }
  } else {
    game.boost_meter = @types.clampf(game.boost_meter + dt * 0.18, 0.0, 1.0)
  }

  update_particles(game, dt)

  if game.state != Play {
    return
  }

  game.game_t = game.game_t + dt
  game.distance = game.distance + (dt * 100.0).to_int()

  update_physics(game, dt)
  update_spawns(game, dt)
  update_obstacles(game, dt)
  update_pickups(game, dt)
  update_collisions(game)

  check_level_up(game)
  check_win(game)
}
