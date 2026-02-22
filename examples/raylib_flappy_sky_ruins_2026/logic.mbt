///|
fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn world_left() -> Float {
  Float::from_int(world_x0)
}

///|
fn world_right() -> Float {
  Float::from_int(world_x0 + world_w)
}

///|
fn world_top() -> Float {
  Float::from_int(world_y0)
}

///|
fn world_bottom() -> Float {
  Float::from_int(world_y0 + world_h)
}

///|
fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
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
  for i = 0; i < game.particles.length(); i = i + 1 {
    if game.particles[i].active {
      continue
    }

    game.particles[i].active = true
    game.particles[i].x = x
    game.particles[i].y = y
    game.particles[i].vx = vx
    game.particles[i].vy = vy
    game.particles[i].life = life
    game.particles[i].size = size
    game.particles[i].kind = kind
    break
  }
}

///|
fn burst(game : Game, x : Float, y : Float, n : Int, kind : Int) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    spawn_particle(
      game,
      x + randf(-10.0, 10.0),
      y + randf(-10.0, 10.0),
      randf(-240.0, 240.0),
      randf(-260.0, 120.0),
      randf(0.2, 1.0),
      randf(1.3, 5.2),
      kind,
    )
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
    game.particles[i].vx = game.particles[i].vx * (1.0 - dt * 2.4)
    game.particles[i].vy = game.particles[i].vy * (1.0 - dt * 2.2) + dt * 180.0
  }
}

///|
fn clear_world(game : Game) -> Unit {
  for i = 0; i < game.obstacles.length(); i = i + 1 {
    game.obstacles[i].active = false
    game.obstacles[i].x = 0.0
    game.obstacles[i].gap_y = 0.0
    game.obstacles[i].gap_h = 0.0
    game.obstacles[i].w = 0.0
    game.obstacles[i].speed = 0.0
    game.obstacles[i].kind = obstacle_kind_gate
    game.obstacles[i].phase = 0.0
    game.obstacles[i].scored = false
  }

  for i = 0; i < game.pickups.length(); i = i + 1 {
    game.pickups[i].active = false
    game.pickups[i].x = 0.0
    game.pickups[i].y = 0.0
    game.pickups[i].kind = pickup_score
    game.pickups[i].phase = 0.0
  }
}

///|
fn init_player(game : Game) -> Unit {
  game.px = Float::from_int(world_x0 + world_w / 4)
  game.py = Float::from_int(world_y0 + world_h / 2)
  game.vy = 0.0
}

///|
fn start_match(game : Game) -> Unit {
  clear_world(game)
  clear_particles(game)

  game.state = state_play

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

  set_msg(game, "Tap/Space to flap. Survive the ruins.", 2.2)
}

///|
fn flap(game : Game) -> Unit {
  if game.state != state_play {
    return
  }

  game.vy = flap_impulse
  game.boost_on = false

  burst(game, game.px - 8.0, game.py + 6.0, 10, 0)
}

///|
fn spawn_obstacle(game : Game) -> Bool {
  for i = 0; i < game.obstacles.length(); i = i + 1 {
    if game.obstacles[i].active {
      continue
    }

    game.obstacles[i].active = true
    game.obstacles[i].x = world_right() + randf(30.0, 120.0)
    game.obstacles[i].w = randf(82.0, 124.0)
    game.obstacles[i].speed = randf(220.0, 320.0) +
      Float::from_int(game.level) * 10.0

    let min_y : Float = world_top() + 140.0
    let max_y : Float = world_bottom() - 140.0
    game.obstacles[i].gap_y = randf(min_y, max_y)

    game.obstacles[i].gap_h = randf(220.0, 340.0) -
      Float::from_int(game.level) * 4.0
    game.obstacles[i].gap_h = clampf(game.obstacles[i].gap_h, 170.0, 340.0)

    let roll : Int = @raylib.get_random_value(0, 99)
    game.obstacles[i].kind = if roll < 62 {
      obstacle_kind_gate
    } else if roll < 86 {
      obstacle_kind_beam
    } else {
      obstacle_kind_spinner
    }

    game.obstacles[i].phase = randf(0.0, 6.28)
    game.obstacles[i].scored = false

    return true
  }

  false
}

///|
fn spawn_pickup(game : Game) -> Bool {
  for i = 0; i < game.pickups.length(); i = i + 1 {
    if game.pickups[i].active {
      continue
    }

    game.pickups[i].active = true
    game.pickups[i].x = world_right() + randf(120.0, 300.0)
    game.pickups[i].y = randf(world_top() + 120.0, world_bottom() - 120.0)

    let roll : Int = @raylib.get_random_value(0, 99)
    game.pickups[i].kind = if roll < 56 {
      pickup_score
    } else if roll < 78 {
      pickup_boost
    } else if roll < 93 {
      pickup_shield
    } else {
      pickup_heart
    }

    game.pickups[i].phase = randf(0.0, 6.28)

    return true
  }

  false
}

///|
fn score_obstacle(game : Game, i : Int) -> Unit {
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
      set_msg(game, "Combo x\{game.combo}", 0.8)
    }
  }
}

///|
fn obstacle_gap_mid(ob : Obstacle) -> Float {
  if ob.kind == obstacle_kind_spinner {
    ob.gap_y + Float::from_double(@math.sin(ob.phase.to_double())) * 120.0
  } else {
    ob.gap_y
  }
}

///|
fn point_hits_obstacle(
  ob : Obstacle,
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

  let gy : Float = obstacle_gap_mid(ob)
  let gh : Float = ob.gap_h

  let top_h : Float = gy - gh / 2.0 - world_top()
  let bot_y : Float = gy + gh / 2.0

  let hit_top : Bool = py - pr < world_top() + top_h
  let hit_bottom : Bool = py + pr > bot_y

  hit_top || hit_bottom
}

///|
fn point_hits_pickup(pk : Pickup, px : Float, py : Float, pr : Float) -> Bool {
  if not(pk.active) {
    return false
  }

  let r : Float = if pk.kind == pickup_score { 16.0 } else { 20.0 }
  let dx : Float = px - pk.x
  let dy : Float = py - pk.y
  dx * dx + dy * dy <= (pr + r) * (pr + r)
}

///|
fn damage_player(game : Game, msg : String) -> Unit {
  if game.shield_t > 0.0 {
    game.shield_t = 0.0
    set_msg(game, "Shield broke", 0.7)
    return
  }

  game.lives = game.lives - 1
  game.combo = 0
  game.combo_t = 0.0

  burst(game, game.px, game.py, 24, 2)
  game.shake_t = maxf(game.shake_t, 0.18)

  if game.lives <= 0 {
    game.state = state_result
    game.win = false
    if game.score > game.best_score {
      game.best_score = game.score
    }
    set_msg(game, "Ruins defeated you", 1.6)
    return
  }

  game.py = Float::from_int(world_y0 + world_h / 2)
  game.vy = flap_impulse * 0.35
  set_msg(game, msg + "  Lives \{game.lives}", 0.9)
}

///|
fn collect_pickup(game : Game, i : Int) -> Unit {
  if not(game.pickups[i].active) {
    return
  }

  let kind : Int = game.pickups[i].kind
  game.pickups[i].active = false

  burst(game, game.px, game.py, 14, 1)

  if kind == pickup_score {
    game.score = game.score + 90 + game.level * 4
    set_msg(game, "+Score", 0.6)
  } else if kind == pickup_boost {
    game.boost_meter = clampf(game.boost_meter + 0.44, 0.0, 1.0)
    set_msg(game, "Boost refilled", 0.7)
  } else if kind == pickup_shield {
    game.shield_t = 6.0
    set_msg(game, "Shield online", 0.8)
  } else {
    game.lives = mini(5, game.lives + 1)
    set_msg(game, "+1 life", 0.8)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn use_hint(game : Game) -> Bool {
  if game.state != state_play {
    return false
  }

  if game.hint_left <= 0 {
    set_msg(game, "No hints", 0.6)
    return false
  }

  let mut best_y : Float = game.py
  let mut best_dist : Float = 1000000000.0

  for i = 0; i < game.obstacles.length(); i = i + 1 {
    if not(game.obstacles[i].active) {
      continue
    }

    if game.obstacles[i].x + game.obstacles[i].w < game.px {
      continue
    }

    let d : Float = game.obstacles[i].x - game.px
    if d < best_dist {
      best_dist = d
      best_y = obstacle_gap_mid(game.obstacles[i])
    }
  }

  game.hint_left = game.hint_left - 1
  game.hint_t = 1.6
  game.hint_y = best_y
  set_msg(game, "Hint: follow ring", 0.8)

  true
}

///|
fn update_obstacles(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.obstacles.length(); i = i + 1 {
    if not(game.obstacles[i].active) {
      continue
    }

    game.obstacles[i].x = game.obstacles[i].x - game.obstacles[i].speed * dt
    game.obstacles[i].phase = game.obstacles[i].phase + dt * 2.0

    score_obstacle(game, i)

    if game.obstacles[i].x + game.obstacles[i].w < world_left() - 80.0 {
      game.obstacles[i].active = false
    }
  }
}

///|
fn update_pickups(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.pickups.length(); i = i + 1 {
    if not(game.pickups[i].active) {
      continue
    }

    let speed : Float = 220.0 + Float::from_int(game.level) * 8.0
    game.pickups[i].x = game.pickups[i].x - speed * dt
    game.pickups[i].phase = game.pickups[i].phase + dt * 3.8

    game.pickups[i].y = game.pickups[i].y +
      Float::from_double(@math.sin(game.pickups[i].phase.to_double())) *
      dt *
      40.0

    if game.pickups[i].x < world_left() - 70.0 {
      game.pickups[i].active = false
    }
  }
}

///|
fn update_physics(game : Game, dt : Float) -> Unit {
  let speed_scale : Float = if game.boost_on { 1.22 } else { 1.0 }

  game.vy = game.vy + gravity * dt
  game.vy = clampf(game.vy, -620.0, 760.0)

  game.py = game.py + game.vy * dt * speed_scale

  if game.py - player_r < world_top() {
    game.py = world_top() + player_r
    game.vy = 40.0
    damage_player(game, "Roof hit")
  }

  if game.py + player_r > world_bottom() {
    game.py = world_bottom() - player_r
    game.vy = -120.0
    damage_player(game, "Ground hit")
  }
}

///|
fn update_collisions(game : Game) -> Unit {
  for i = 0; i < game.obstacles.length(); i = i + 1 {
    if not(game.obstacles[i].active) {
      continue
    }

    if point_hits_obstacle(game.obstacles[i], game.px, game.py, player_r) {
      damage_player(game, "Obstacle hit")
      return
    }
  }

  for i = 0; i < game.pickups.length(); i = i + 1 {
    if point_hits_pickup(game.pickups[i], game.px, game.py, player_r) {
      collect_pickup(game, i)
    }
  }
}

///|
fn update_spawns(game : Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  if game.spawn_t <= 0.0 {
    ignore(spawn_obstacle(game))

    let base : Float = 1.12 - Float::from_int(game.level) * 0.04
    game.spawn_t = clampf(base + randf(-0.08, 0.16), 0.6, 1.25)
  }

  game.pickup_t = game.pickup_t - dt
  if game.pickup_t <= 0.0 {
    ignore(spawn_pickup(game))
    game.pickup_t = randf(2.1, 4.2)
  }
}

///|
fn check_level_up(game : Game) -> Unit {
  let lv : Int = clampi(1 + game.score / 520, 1, 10)
  if lv != game.level {
    game.level = lv
    set_msg(game, "Level \{game.level}", 0.8)
  }
}

///|
fn check_win(game : Game) -> Unit {
  if game.game_t < 180.0 {
    return
  }

  game.state = state_result
  game.win = true
  if game.score > game.best_score {
    game.best_score = game.score
  }
  set_msg(game, "Sky ruins conquered", 1.6)
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
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
    game.boost_meter = clampf(game.boost_meter - dt * 0.48, 0.0, 1.0)
    game.boost_t = game.boost_t + dt
    if game.boost_meter <= 0.0 {
      game.boost_on = false
    }
  } else {
    game.boost_meter = clampf(game.boost_meter + dt * 0.18, 0.0, 1.0)
  }

  update_particles(game, dt)

  if game.state != state_play {
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
