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
fn clear_world(game : @types.Game) -> Unit {
  for obstacle in game.obstacles {
    obstacle.active = false
    obstacle.x = 0.0
    obstacle.y = 0.0
    obstacle.w = 0.0
    obstacle.h = 0.0
    obstacle.vx = 0.0
    obstacle.vy = 0.0
    obstacle.kind = @types.obstacle_rock
    obstacle.phase = 0.0
  }

  for pickup in game.pickups {
    pickup.active = false
    pickup.x = 0.0
    pickup.y = 0.0
    pickup.kind = @types.pickup_coin
    pickup.phase = 0.0
  }
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
fn splash(
  game : @types.Game,
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<n {
    emit_particle(
      game,
      x + @types.randf(-14.0, 14.0),
      y + @types.randf(-8.0, 8.0),
      @types.randf(-260.0, 260.0),
      @types.randf(-220.0, 120.0),
      @types.randf(0.25, 1.0),
      @types.randf(1.4, 6.2),
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

    let drag : Float = if particle.kind == 2 { 2.8 } else { 1.9 }
    particle.vx = particle.vx * (1.0 - dt * drag)
    particle.vy = particle.vy * (1.0 - dt * (drag - 0.5)) +
      dt * (if particle.kind == 2 { 250.0 } else { 160.0 })
  }
}

///|
fn reset_raft(game : @types.Game) -> Unit {
  game.raft_x = Float::from_int(@types.world_x0 + @types.world_w / 2)
  game.raft_y = Float::from_int(@types.world_y0 + @types.world_h - 160)
  game.raft_vx = 0.0
  game.raft_vy = -40.0
  game.move_x = 0.0
  game.move_y = 0.0
}

///|
fn start_run(game : @types.Game) -> Unit {
  clear_world(game)
  clear_particles(game)

  game.state = @types.state_play
  reset_raft(game)

  game.lives = 3
  game.shield_t = 0.0
  game.fuel = 100.0
  game.boost_on = false

  game.score = 0
  game.distance = 0
  game.level = 1
  game.combo = 0
  game.combo_t = 0.0

  game.spawn_t = 0.72
  game.pickup_t = 1.18
  game.game_t = 0.0
  game.ui_t = 0.0

  game.hint_left = 3
  game.hint_t = 0.0
  game.hint_x = game.raft_x
  game.hint_y = game.raft_y - 160.0

  game.msg = ""
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.touch_cd = 0.0
  game.win = false

  @types.set_msg(game, "WASD move, Shift boost, avoid rapids hazards.", 2.6)
}

///|
fn finish_run(game : @types.Game, win : Bool) -> Unit {
  if game.state != @types.state_play {
    return
  }

  game.state = @types.state_result
  game.win = win
  game.boost_on = false
  game.move_x = 0.0
  game.move_y = 0.0

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if win {
    @types.set_msg(game, "You conquered the rapids!", 3.0)
    splash(game, game.raft_x, game.raft_y, 60, 2)
  } else {
    @types.set_msg(game, "Expedition ended. Repair and run again.", 3.0)
    splash(game, game.raft_x, game.raft_y, 45, 1)
  }
}

///|
fn circle_rect_hit(
  cx : Float,
  cy : Float,
  cr : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  let nearest_x : Float = @types.clampf(cx, rx, rx + rw)
  let nearest_y : Float = @types.clampf(cy, ry, ry + rh)
  let dx : Float = cx - nearest_x
  let dy : Float = cy - nearest_y
  dx * dx + dy * dy <= cr * cr
}

///|
fn obstacle_hit_cost(kind : Int) -> Int {
  if kind == @types.obstacle_mine {
    2
  } else {
    1
  }
}

///|
fn obstacle_hit_fuel(kind : Int) -> Float {
  if kind == @types.obstacle_mine {
    18.0
  } else if kind == @types.obstacle_log {
    11.0
  } else {
    8.0
  }
}

///|
fn hurt_player(game : @types.Game, kind : Int, x : Float, y : Float) -> Unit {
  splash(game, x, y, if kind == @types.obstacle_mine { 40 } else { 26 }, 1)
  game.shake_t = @types.maxf(game.shake_t, 0.34)

  if game.shield_t > 0.0 {
    game.shield_t = @types.maxf(
      0.0,
      game.shield_t - (if kind == @types.obstacle_mine { 1.6 } else { 0.9 }),
    )
    game.score = game.score + 8
    game.combo = 0
    game.combo_t = 0.0
    @types.set_msg(game, "Shield absorbed impact.", 1.2)
    return
  }

  game.lives = game.lives - obstacle_hit_cost(kind)
  game.lives = @types.maxi(0, game.lives)

  game.fuel = game.fuel - obstacle_hit_fuel(kind)
  game.fuel = @types.maxf(0.0, game.fuel)

  game.combo = 0
  game.combo_t = 0.0

  if kind == @types.obstacle_mine {
    @types.set_msg(game, "Mine blast! Heavy damage.", 1.6)
  } else if kind == @types.obstacle_log {
    @types.set_msg(game, "Crushed into a drifting log.", 1.4)
  } else {
    @types.set_msg(game, "Rock impact! Keep control.", 1.2)
  }

  if game.lives <= 0 {
    finish_run(game, false)
  }
}

///|
fn pickup_radius(kind : Int) -> Float {
  if kind == @types.pickup_coin {
    16.0
  } else if kind == @types.pickup_repair {
    20.0
  } else {
    18.0
  }
}

///|
fn collect_pickup(game : @types.Game, kind : Int, x : Float, y : Float) -> Unit {
  if kind == @types.pickup_coin {
    game.combo = @types.mini(15, game.combo + 1)
    game.combo_t = 2.2

    game.score = game.score + 16 + game.combo * 4
    game.fuel = @types.minf(100.0, game.fuel + 1.3)

    if game.combo >= 4 {
      @types.set_msg(game, "Combo coins +" + game.combo.to_string(), 0.9)
    }

    splash(game, x, y, 10 + game.combo, 0)
  } else if kind == @types.pickup_fuel {
    game.fuel = @types.minf(100.0, game.fuel + 30.0)
    game.score = game.score + 20
    @types.set_msg(game, "Fuel canister recovered.", 1.5)
    splash(game, x, y, 24, 0)
  } else if kind == @types.pickup_shield {
    game.shield_t = @types.maxf(game.shield_t, 7.0)
    game.score = game.score + 24
    @types.set_msg(game, "Shield bubble online.", 1.5)
    splash(game, x, y, 28, 2)
  } else {
    if game.lives < 5 {
      game.lives = game.lives + 1
      @types.set_msg(game, "Repair kit: hull restored.", 1.5)
    } else {
      game.score = game.score + 50
      game.fuel = @types.minf(100.0, game.fuel + 10.0)
      @types.set_msg(game, "Repair converted to bonus points.", 1.5)
    }
    splash(game, x, y, 26, 2)
  }

  game.score = @types.maxi(0, game.score)
  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
fn spawn_obstacle(game : @types.Game) -> Bool {
  for obstacle in game.obstacles {
    if obstacle.active {
      continue
    }

    let roll : Int = @raylib.get_random_value(0, 99)
    let kind : Int = if roll < 46 {
      @types.obstacle_rock
    } else if roll < 84 {
      @types.obstacle_log
    } else {
      @types.obstacle_mine
    }

    let w : Float = if kind == @types.obstacle_rock {
      @types.randf(56.0, 90.0)
    } else if kind == @types.obstacle_log {
      @types.randf(120.0, 210.0)
    } else {
      @types.randf(50.0, 74.0)
    }

    let h : Float = if kind == @types.obstacle_rock {
      @types.randf(48.0, 82.0)
    } else if kind == @types.obstacle_log {
      @types.randf(32.0, 52.0)
    } else {
      @types.randf(50.0, 74.0)
    }

    obstacle.active = true
    obstacle.kind = kind
    obstacle.w = w
    obstacle.h = h

    obstacle.x = @types.randf(
      @types.world_left() + 20.0,
      @types.world_right() - w - 20.0,
    )
    obstacle.y = @types.world_top() - h - @types.randf(30.0, 180.0)

    obstacle.vx = @types.randf(-42.0, 42.0)
    obstacle.vy = if kind == @types.obstacle_log {
      @types.randf(220.0, 300.0) + Float::from_int(game.level) * 20.0
    } else if kind == @types.obstacle_mine {
      @types.randf(170.0, 240.0) + Float::from_int(game.level) * 16.0
    } else {
      @types.randf(190.0, 270.0) + Float::from_int(game.level) * 18.0
    }
    obstacle.phase = @types.randf(0.0, 6.28)

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
    pickup.x = @types.randf(
      @types.world_left() + 36.0,
      @types.world_right() - 36.0,
    )
    pickup.y = @types.world_top() - @types.randf(50.0, 260.0)
    pickup.phase = @types.randf(0.0, 6.28)

    let roll : Int = @raylib.get_random_value(0, 99)
    pickup.kind = if roll < 58 {
      @types.pickup_coin
    } else if roll < 80 {
      @types.pickup_fuel
    } else if roll < 92 {
      @types.pickup_shield
    } else {
      @types.pickup_repair
    }

    return true
  }

  false
}

///|
fn update_raft(game : @types.Game, dt : Float) -> Unit {
  let boost_mul : Float = if game.boost_on && game.fuel > 0.6 {
    1.7
  } else {
    1.0
  }

  let cx : Float = @types.water_current_x(game, game.raft_y)
  let cy : Float = @types.water_current_y(game, game.raft_x)

  let ax : Float = game.move_x * 700.0 + cx * 0.42
  let ay : Float = game.move_y * 640.0 + cy * 0.36

  game.raft_vx = game.raft_vx + ax * dt
  game.raft_vy = game.raft_vy + ay * dt

  game.raft_vx = game.raft_vx * (1.0 - dt * 2.5)
  game.raft_vy = game.raft_vy * (1.0 - dt * 2.3)

  if boost_mul > 1.1 {
    game.raft_vx = game.raft_vx * 1.03
    game.raft_vy = game.raft_vy * 1.03
    splash(game, game.raft_x, game.raft_y + @types.raft_r * 0.6, 3, 0)
  }

  game.raft_x = game.raft_x + game.raft_vx * dt * boost_mul
  game.raft_y = game.raft_y + game.raft_vy * dt * boost_mul

  let left : Float = @types.world_left() + @types.raft_r + 8.0
  let right : Float = @types.world_right() - @types.raft_r - 8.0
  let top : Float = @types.world_top() + @types.raft_r + 10.0
  let bottom : Float = @types.world_bottom() - @types.raft_r - 10.0

  let mut wall_hit : Bool = false

  if game.raft_x < left {
    game.raft_x = left
    game.raft_vx = @types.absf(game.raft_vx) * 0.30
    wall_hit = true
  } else if game.raft_x > right {
    game.raft_x = right
    game.raft_vx = -@types.absf(game.raft_vx) * 0.30
    wall_hit = true
  }

  if game.raft_y < top {
    game.raft_y = top
    game.raft_vy = @types.absf(game.raft_vy) * 0.35
    wall_hit = true
  } else if game.raft_y > bottom {
    game.raft_y = bottom
    game.raft_vy = -@types.absf(game.raft_vy) * 0.20
    wall_hit = true
  }

  if wall_hit {
    splash(game, game.raft_x, game.raft_y, 8, 0)
    game.shake_t = @types.maxf(game.shake_t, 0.14)
    game.fuel = @types.maxf(0.0, game.fuel - 1.8)
  }
}

///|
fn update_obstacles(game : @types.Game, dt : Float) -> Unit {
  for obstacle in game.obstacles {
    if not(obstacle.active) {
      continue
    }

    obstacle.phase = obstacle.phase +
      dt * (1.3 + Float::from_int(obstacle.kind))

    let sway : Float = if obstacle.kind == @types.obstacle_log {
      @types.sinf(obstacle.phase * 1.9) * 32.0
    } else if obstacle.kind == @types.obstacle_mine {
      @types.sinf(obstacle.phase * 2.6) * 19.0
    } else {
      @types.sinf(obstacle.phase * 1.3) * 24.0
    }

    obstacle.x = obstacle.x +
      (obstacle.vx + sway + @types.water_current_x(game, obstacle.y) * 0.08) *
      dt
    obstacle.y = obstacle.y +
      (obstacle.vy + @types.water_current_y(game, obstacle.x) * 0.06) * dt

    if obstacle.x < @types.world_left() + 4.0 {
      obstacle.x = @types.world_left() + 4.0
      obstacle.vx = @types.absf(obstacle.vx) * 0.7
    }
    if obstacle.x + obstacle.w > @types.world_right() - 4.0 {
      obstacle.x = @types.world_right() - obstacle.w - 4.0
      obstacle.vx = -@types.absf(obstacle.vx) * 0.7
    }

    if obstacle.y > @types.world_bottom() + 120.0 {
      obstacle.active = false
      game.score = game.score + 3 + game.level
      continue
    }

    let hit : Bool = circle_rect_hit(
      game.raft_x,
      game.raft_y,
      @types.raft_r,
      obstacle.x,
      obstacle.y,
      obstacle.w,
      obstacle.h,
    )

    if hit {
      let kind : Int = obstacle.kind
      let ox : Float = obstacle.x + obstacle.w * 0.5
      let oy : Float = obstacle.y + obstacle.h * 0.5

      obstacle.active = false
      hurt_player(game, kind, ox, oy)

      if game.state != @types.state_play {
        return
      }
    }
  }
}

///|
fn update_pickups(game : @types.Game, dt : Float) -> Unit {
  for pickup in game.pickups {
    if not(pickup.active) {
      continue
    }

    pickup.phase = pickup.phase + dt * 2.4

    pickup.x = pickup.x +
      (
        @types.sinf(pickup.phase * 2.3) * 22.0 +
        @types.water_current_x(game, pickup.y) * 0.10
      ) *
      dt
    pickup.y = pickup.y +
      (
        160.0 +
        Float::from_int(game.level) * 18.0 +
        @types.water_current_y(game, pickup.x) * 0.08
      ) *
      dt

    pickup.x = @types.clampf(
      pickup.x,
      @types.world_left() + 20.0,
      @types.world_right() - 20.0,
    )

    if pickup.y > @types.world_bottom() + 90.0 {
      pickup.active = false
      continue
    }

    let r : Float = @types.raft_r + pickup_radius(pickup.kind)
    let d2 : Float = @types.point_dist2(
      game.raft_x,
      game.raft_y,
      pickup.x,
      pickup.y,
    )

    if d2 <= r * r {
      let kind : Int = pickup.kind
      let px : Float = pickup.x
      let py : Float = pickup.y
      pickup.active = false
      collect_pickup(game, kind, px, py)
    }
  }
}

///|
fn use_hint(game : @types.Game) -> Bool {
  if game.state != @types.state_play || game.hint_left <= 0 {
    return false
  }

  let mut best_x : Float = game.raft_x
  let mut best_y : Float = @types.clampf(
    game.raft_y - 210.0,
    @types.world_top() + 80.0,
    @types.world_bottom() - 80.0,
  )

  let mut best_cost : Float = 1_000_000.0

  for lane in 0..<5 {
    let lane_x : Float = @types.world_left() +
      120.0 +
      Float::from_int(lane) * (Float::from_int(@types.world_w) - 240.0) / 4.0

    let mut cost : Float = 0.0

    for obstacle in game.obstacles {
      if not(obstacle.active) {
        continue
      }

      if @types.absf(obstacle.y - best_y) > 260.0 {
        continue
      }

      let ox : Float = obstacle.x + obstacle.w * 0.5
      let dx : Float = @types.absf(ox - lane_x)
      cost = cost + @types.maxf(0.0, 220.0 - dx)

      if obstacle.kind == @types.obstacle_mine {
        cost = cost + @types.maxf(0.0, 100.0 - dx)
      }
    }

    if cost < best_cost {
      best_cost = cost
      best_x = lane_x
    }
  }

  let mut pickup_found : Bool = false
  let mut pickup_dist : Float = 1_000_000.0

  for pickup in game.pickups {
    if not(pickup.active) {
      continue
    }

    if pickup.kind != @types.pickup_fuel && pickup.kind != @types.pickup_shield {
      continue
    }

    if pickup.y > game.raft_y + 40.0 {
      continue
    }

    let d2 : Float = @types.point_dist2(
      game.raft_x,
      game.raft_y,
      pickup.x,
      pickup.y,
    )

    if d2 < pickup_dist {
      pickup_dist = d2
      best_x = pickup.x
      best_y = pickup.y
      pickup_found = true
    }
  }

  game.hint_x = best_x
  game.hint_y = best_y
  game.hint_t = 2.7
  game.hint_left = game.hint_left - 1
  game.score = @types.maxi(0, game.score - 6)

  if pickup_found {
    @types.set_msg(game, "Hint: rush the supply pickup.", 1.4)
  } else {
    @types.set_msg(game, "Hint: steer toward the beacon lane.", 1.4)
  }

  true
}

///|
fn update_play(game : @types.Game, dt : Float) -> Unit {
  let step : Float = @types.clampf(dt, 0.0, 0.04)

  game.ui_t = game.ui_t + step
  game.touch_cd = @types.maxf(0.0, game.touch_cd - step)
  game.msg_t = @types.maxf(0.0, game.msg_t - step)
  game.shake_t = @types.maxf(0.0, game.shake_t - step)
  game.hint_t = @types.maxf(0.0, game.hint_t - step)
  game.combo_t = @types.maxf(0.0, game.combo_t - step)

  if game.combo_t <= 0.0 {
    game.combo = 0
  }

  game.shield_t = @types.maxf(0.0, game.shield_t - step)

  update_particles(game, step)

  if game.state != @types.state_play {
    return
  }

  game.game_t = game.game_t + step

  if game.game_t >= @types.run_time_goal {
    finish_run(game, true)
    return
  }

  game.level = @types.clampi(1 + (game.game_t / 24.0).to_int(), 1, 10)

  let old_band : Int = game.distance / 120
  let speed_base : Float = 170.0 + Float::from_int(game.level) * 18.0
  let speed_mul : Float = if game.boost_on && game.fuel > 0.6 {
    1.65
  } else {
    1.0
  }
  game.distance = game.distance + (speed_base * speed_mul * step).to_int()

  let new_band : Int = game.distance / 120
  if new_band > old_band {
    game.score = game.score + (new_band - old_band)
  }

  game.spawn_t = game.spawn_t + step
  let spawn_every : Float = @types.maxf(
    0.22,
    0.68 - Float::from_int(game.level) * 0.04,
  )
  if game.spawn_t >= spawn_every {
    game.spawn_t = game.spawn_t - spawn_every
    ignore(spawn_obstacle(game))
  }

  game.pickup_t = game.pickup_t + step
  if game.pickup_t >= 1.55 {
    game.pickup_t = 0.0
    ignore(spawn_pickup(game))
  }

  update_raft(game, step)

  update_obstacles(game, step)
  if game.state != @types.state_play {
    return
  }

  update_pickups(game, step)

  let fuel_loss : Float = if game.boost_on && game.fuel > 0.6 {
    11.5 + Float::from_int(game.level) * 0.42
  } else {
    3.2 + Float::from_int(game.level) * 0.19
  }

  game.fuel = @types.maxf(0.0, game.fuel - fuel_loss * step)

  if game.fuel <= 0.0 {
    @types.set_msg(game, "Out of fuel.", 1.3)
    finish_run(game, false)
    return
  }

  if game.lives <= 0 {
    finish_run(game, false)
    return
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.mouse_x = @raylib.get_mouse_x() |> Float::from_int
  game.mouse_y = @raylib.get_mouse_y() |> Float::from_int
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  if game.state == @types.state_title {
    update_title_input(game)
    update_play(game, dt)
  } else if game.state == @types.state_play {
    update_play_input(game, dt)
    update_play(game, dt)
  } else {
    update_result_input(game)
    update_play(game, dt)
  }
}
