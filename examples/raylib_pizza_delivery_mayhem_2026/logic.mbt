///|
fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxi(a : Int, b : Int) -> Int {
  if a > b {
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
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
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
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
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
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
fn point_in_rectf(
  x : Float,
  y : Float,
  rx : Float,
  ry : Float,
  rw : Float,
  rh : Float,
) -> Bool {
  x >= rx && x <= rx + rw && y >= ry && y <= ry + rh
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
  let nx : Float = clampf(cx, rx, rx + rw)
  let ny : Float = clampf(cy, ry, ry + rh)
  let dx : Float = cx - nx
  let dy : Float = cy - ny
  dx * dx + dy * dy <= cr * cr
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
fn clear_world(game : Game) -> Unit {
  for i = 0; i < game.traffic.length(); i = i + 1 {
    game.traffic[i].active = false
    game.traffic[i].x = 0.0
    game.traffic[i].y = 0.0
    game.traffic[i].vx = 0.0
    game.traffic[i].vy = 0.0
    game.traffic[i].w = 0.0
    game.traffic[i].h = 0.0
    game.traffic[i].kind = traffic_sedan
    game.traffic[i].phase = 0.0
  }

  for i = 0; i < game.orders.length(); i = i + 1 {
    game.orders[i].active = false
    game.orders[i].picked = false
    game.orders[i].x_from = 0.0
    game.orders[i].y_from = 0.0
    game.orders[i].x_to = 0.0
    game.orders[i].y_to = 0.0
    game.orders[i].timer = 0.0
    game.orders[i].value = 0
    game.orders[i].id = 0
  }

  for i = 0; i < game.pickups.length(); i = i + 1 {
    game.pickups[i].active = false
    game.pickups[i].x = 0.0
    game.pickups[i].y = 0.0
    game.pickups[i].vx = 0.0
    game.pickups[i].vy = 0.0
    game.pickups[i].kind = pickup_fuel
    game.pickups[i].phase = 0.0
  }
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
    emit_particle(
      game,
      x + randf(-12.0, 12.0),
      y + randf(-12.0, 12.0),
      randf(-240.0, 240.0),
      randf(-220.0, 140.0),
      randf(0.22, 1.0),
      randf(1.2, 5.2),
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

    let drag : Float = if game.particles[i].kind == 2 { 2.7 } else { 1.9 }
    game.particles[i].vx = game.particles[i].vx * (1.0 - dt * drag)
    game.particles[i].vy = game.particles[i].vy * (1.0 - dt * (drag - 0.4)) +
      dt * (if game.particles[i].kind == 1 { 180.0 } else { 120.0 })
  }
}

///|
fn reset_rider(game : Game) -> Unit {
  game.rider_x = Float::from_int(world_x0 + world_w / 2)
  game.rider_y = Float::from_int(world_y0 + world_h / 2)
  game.rider_vx = 0.0
  game.rider_vy = 0.0
  game.move_x = 0.0
  game.move_y = 0.0
  game.boost_on = false
  game.action_on = false
  game.cargo_idx = -1
}

///|
fn start_run(game : Game) -> Unit {
  clear_world(game)
  clear_particles(game)

  game.state = state_play

  reset_rider(game)

  game.lives = 3
  game.scooter_hp = 100.0
  game.fuel = 100.0
  game.turbo_t = 0.0
  game.action_cd = 0.0

  game.score = 0
  game.delivered = 0
  game.missed = 0
  game.wave = 1
  game.combo = 0
  game.combo_t = 0.0

  game.order_spawn_t = 0.4
  game.traffic_spawn_t = 0.0
  game.pickup_spawn_t = 1.1

  game.game_t = 0.0
  game.ui_t = 0.0
  game.touch_cd = 0.0

  game.hint_left = 3
  game.hint_t = 0.0
  game.hint_x = restaurant_x(0)
  game.hint_y = restaurant_y(0)

  game.msg = ""
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.win = false

  set_msg(game, "Pick up pizza, deliver fast, avoid traffic.", 2.6)
}

///|
fn finish_run(game : Game, win : Bool) -> Unit {
  if game.state != state_play {
    return
  }

  game.state = state_result
  game.win = win

  game.move_x = 0.0
  game.move_y = 0.0
  game.boost_on = false
  game.action_on = false

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if win {
    set_msg(game, "City fed. Delivery legend.", 3.0)
    burst(game, depot_x(), depot_y(), 66, 2)
  } else {
    set_msg(game, "Rush ended. Try another shift.", 3.0)
    burst(game, game.rider_x, game.rider_y, 52, 1)
  }
}

///|
fn active_orders(game : Game) -> Int {
  let mut n : Int = 0
  for i = 0; i < game.orders.length(); i = i + 1 {
    if game.orders[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn spawn_order(game : Game) -> Bool {
  for i = 0; i < game.orders.length(); i = i + 1 {
    if game.orders[i].active {
      continue
    }

    let src : Int = @raylib.get_random_value(0, 2)

    let mut tx : Float = randf(world_left() + 70.0, world_right() - 70.0)
    let mut ty : Float = randf(world_top() + 70.0, world_bottom() - 70.0)

    // Snap customer destination to city road grid for readable routes.
    tx = world_left() +
      Float::from_int(
        (tx - world_left()).to_int() / road_step * road_step + road_step / 2,
      )
    ty = world_top() +
      Float::from_int(
        (ty - world_top()).to_int() / road_step * road_step + road_step / 2,
      )

    game.orders[i].active = true
    game.orders[i].picked = false
    game.orders[i].x_from = restaurant_x(src)
    game.orders[i].y_from = restaurant_y(src)
    game.orders[i].x_to = tx
    game.orders[i].y_to = ty
    game.orders[i].timer = randf(24.0, 42.0) - Float::from_int(game.wave) * 0.6
    game.orders[i].timer = maxf(16.0, game.orders[i].timer)
    game.orders[i].value = @raylib.get_random_value(70, 130)
    game.orders[i].id = @raylib.get_random_value(1000, 9999)

    return true
  }

  false
}

///|
fn spawn_traffic(game : Game) -> Bool {
  for i = 0; i < game.traffic.length(); i = i + 1 {
    if game.traffic[i].active {
      continue
    }

    let kind_roll : Int = @raylib.get_random_value(0, 99)
    let kind : Int = if kind_roll < 58 {
      traffic_sedan
    } else if kind_roll < 84 {
      traffic_van
    } else {
      traffic_bus
    }

    let lane : Int = @raylib.get_random_value(0, 1)

    if lane == 0 {
      let y_lane : Float = world_top() +
        Float::from_int(
          @raylib.get_random_value(1, world_h / road_step - 2) * road_step +
          road_step / 2,
        )

      let from_left : Bool = @raylib.get_random_value(0, 1) == 0
      game.traffic[i].x = if from_left {
        world_left() - 80.0
      } else {
        world_right() + 80.0
      }
      game.traffic[i].y = y_lane
      game.traffic[i].vx = if from_left {
        randf(180.0, 280.0)
      } else {
        randf(-280.0, -180.0)
      }
      game.traffic[i].vy = randf(-16.0, 16.0)

      if kind == traffic_sedan {
        game.traffic[i].w = 48.0
        game.traffic[i].h = 30.0
      } else if kind == traffic_van {
        game.traffic[i].w = 60.0
        game.traffic[i].h = 34.0
      } else {
        game.traffic[i].w = 88.0
        game.traffic[i].h = 40.0
      }
    } else {
      let x_lane : Float = world_left() +
        Float::from_int(
          @raylib.get_random_value(1, world_w / road_step - 2) * road_step +
          road_step / 2,
        )

      let from_top : Bool = @raylib.get_random_value(0, 1) == 0
      game.traffic[i].x = x_lane
      game.traffic[i].y = if from_top {
        world_top() - 80.0
      } else {
        world_bottom() + 80.0
      }
      game.traffic[i].vx = randf(-16.0, 16.0)
      game.traffic[i].vy = if from_top {
        randf(180.0, 280.0)
      } else {
        randf(-280.0, -180.0)
      }

      if kind == traffic_sedan {
        game.traffic[i].w = 30.0
        game.traffic[i].h = 48.0
      } else if kind == traffic_van {
        game.traffic[i].w = 34.0
        game.traffic[i].h = 60.0
      } else {
        game.traffic[i].w = 40.0
        game.traffic[i].h = 88.0
      }
    }

    game.traffic[i].active = true
    game.traffic[i].kind = kind
    game.traffic[i].phase = randf(0.0, 6.28)

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
    game.pickups[i].x = randf(world_left() + 40.0, world_right() - 40.0)
    game.pickups[i].y = randf(world_top() + 40.0, world_bottom() - 40.0)
    game.pickups[i].vx = randf(-32.0, 32.0)
    game.pickups[i].vy = randf(-32.0, 32.0)
    game.pickups[i].phase = randf(0.0, 6.28)

    let roll : Int = @raylib.get_random_value(0, 99)
    game.pickups[i].kind = if roll < 46 {
      pickup_fuel
    } else if roll < 78 {
      pickup_repair
    } else {
      pickup_speed
    }

    return true
  }

  false
}

///|
fn try_repair(game : Game) -> Bool {
  if game.state != state_play {
    return false
  }
  if game.action_cd > 0.0 {
    return false
  }

  let near_depot : Bool = point_in_rectf(
    game.rider_x,
    game.rider_y,
    depot_x() - 20.0,
    depot_y() - 20.0,
    Float::from_int(depot_w() + 40),
    Float::from_int(depot_h() + 40),
  )

  if not(near_depot) {
    set_msg(game, "Return to depot for repairs.", 1.0)
    game.action_cd = 0.22
    return false
  }

  if game.fuel < 8.0 {
    set_msg(game, "Not enough fuel to repair.", 1.0)
    game.action_cd = 0.22
    return false
  }

  game.fuel = maxf(0.0, game.fuel - 8.0)
  game.scooter_hp = minf(100.0, game.scooter_hp + 30.0)
  game.action_cd = 1.2

  game.score = game.score + 12
  set_msg(game, "Scooter serviced.", 1.0)
  burst(game, depot_x(), depot_y(), 22, 2)

  true
}

///|
fn pickup_distance(kind : Int) -> Float {
  if kind == pickup_speed {
    28.0
  } else {
    24.0
  }
}

///|
fn collect_pickup(game : Game, kind : Int, x : Float, y : Float) -> Unit {
  if kind == pickup_fuel {
    game.fuel = minf(100.0, game.fuel + 30.0)
    game.score = game.score + 10
    set_msg(game, "Fuel canister collected.", 1.0)
    burst(game, x, y, 16, 0)
  } else if kind == pickup_repair {
    game.scooter_hp = minf(100.0, game.scooter_hp + 24.0)
    game.score = game.score + 10
    set_msg(game, "Quick repair kit used.", 1.0)
    burst(game, x, y, 16, 2)
  } else {
    game.turbo_t = maxf(game.turbo_t, 7.0)
    game.score = game.score + 16
    set_msg(game, "Nitro drink activated.", 1.0)
    burst(game, x, y, 20, 2)
  }
}

///|
fn hurt_rider(game : Game, dmg : Float) -> Unit {
  game.scooter_hp = game.scooter_hp - dmg
  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = maxf(game.shake_t, 0.24)

  if game.scooter_hp <= 0.0 {
    game.lives = game.lives - 1
    game.scooter_hp = 100.0
    game.fuel = maxf(0.0, game.fuel - 16.0)

    game.rider_x = Float::from_int(world_x0 + world_w / 2)
    game.rider_y = Float::from_int(world_y0 + world_h / 2)
    game.rider_vx = 0.0
    game.rider_vy = 0.0

    set_msg(game, "Scooter wrecked. Life lost.", 1.4)
    burst(game, game.rider_x, game.rider_y, 30, 1)

    if game.cargo_idx >= 0 {
      let idx : Int = game.cargo_idx
      if idx < game.orders.length() && game.orders[idx].active {
        game.orders[idx].picked = false
        game.orders[idx].x_from = game.rider_x
        game.orders[idx].y_from = game.rider_y
      }
      game.cargo_idx = -1
    }

    if game.lives <= 0 {
      finish_run(game, false)
    }
  } else {
    burst(game, game.rider_x, game.rider_y, 12, 1)
  }
}

///|
fn update_rider(game : Game, dt : Float) -> Unit {
  let boost_mul : Float = if game.boost_on || game.turbo_t > 0.0 {
    1.55
  } else {
    1.0
  }

  let traffic_drift_x : Float = sinf(game.ui_t * 0.92 + game.rider_y * 0.006) *
    (14.0 + Float::from_int(game.wave) * 2.2)
  let traffic_drift_y : Float = cosf(game.ui_t * 0.81 + game.rider_x * 0.007) *
    12.0

  game.rider_vx = game.rider_vx +
    (game.move_x * 780.0 * boost_mul + traffic_drift_x) * dt
  game.rider_vy = game.rider_vy +
    (game.move_y * 760.0 * boost_mul + traffic_drift_y) * dt

  game.rider_vx = game.rider_vx * (1.0 - dt * 3.0)
  game.rider_vy = game.rider_vy * (1.0 - dt * 3.0)

  game.rider_x = game.rider_x + game.rider_vx * dt
  game.rider_y = game.rider_y + game.rider_vy * dt

  game.rider_x = clampf(
    game.rider_x,
    world_left() + rider_r + 8.0,
    world_right() - rider_r - 8.0,
  )
  game.rider_y = clampf(
    game.rider_y,
    world_top() + rider_r + 8.0,
    world_bottom() - rider_r - 8.0,
  )

  if game.boost_on || game.turbo_t > 0.0 {
    emit_particle(
      game,
      game.rider_x + randf(-6.0, 6.0),
      game.rider_y + randf(-6.0, 6.0),
      randf(-40.0, 40.0),
      randf(24.0, 86.0),
      randf(0.2, 0.5),
      randf(1.1, 3.0),
      0,
    )
  }
}

///|
fn update_traffic(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.traffic.length(); i = i + 1 {
    if not(game.traffic[i].active) {
      continue
    }

    game.traffic[i].phase = game.traffic[i].phase +
      dt * (1.4 + Float::from_int(game.traffic[i].kind) * 0.6)

    let sway_x : Float = sinf(game.traffic[i].phase * 2.0) * 10.0
    let sway_y : Float = cosf(game.traffic[i].phase * 1.7) * 10.0

    game.traffic[i].x = game.traffic[i].x + (game.traffic[i].vx + sway_x) * dt
    game.traffic[i].y = game.traffic[i].y + (game.traffic[i].vy + sway_y) * dt

    if game.traffic[i].x < world_left() - 130.0 ||
      game.traffic[i].x > world_right() + 130.0 ||
      game.traffic[i].y < world_top() - 130.0 ||
      game.traffic[i].y > world_bottom() + 130.0 {
      game.traffic[i].active = false
      continue
    }

    let hit : Bool = circle_rect_hit(
      game.rider_x,
      game.rider_y,
      rider_r,
      game.traffic[i].x - game.traffic[i].w * 0.5,
      game.traffic[i].y - game.traffic[i].h * 0.5,
      game.traffic[i].w,
      game.traffic[i].h,
    )

    if hit {
      let dmg : Float = if game.traffic[i].kind == traffic_bus {
        32.0
      } else if game.traffic[i].kind == traffic_van {
        22.0
      } else {
        16.0
      }

      hurt_rider(game, dmg)
      game.traffic[i].active = false

      if game.state != state_play {
        return
      }
    }
  }
}

///|
fn update_pickups(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.pickups.length(); i = i + 1 {
    if not(game.pickups[i].active) {
      continue
    }

    game.pickups[i].phase = game.pickups[i].phase + dt * 2.4

    game.pickups[i].x = game.pickups[i].x +
      (game.pickups[i].vx + sinf(game.pickups[i].phase * 2.0) * 22.0) * dt
    game.pickups[i].y = game.pickups[i].y +
      (game.pickups[i].vy + cosf(game.pickups[i].phase * 2.1) * 22.0) * dt

    if game.pickups[i].x < world_left() + 16.0 {
      game.pickups[i].x = world_left() + 16.0
      game.pickups[i].vx = absf(game.pickups[i].vx) * 0.6
    }
    if game.pickups[i].x > world_right() - 16.0 {
      game.pickups[i].x = world_right() - 16.0
      game.pickups[i].vx = -absf(game.pickups[i].vx) * 0.6
    }

    if game.pickups[i].y < world_top() + 16.0 {
      game.pickups[i].y = world_top() + 16.0
      game.pickups[i].vy = absf(game.pickups[i].vy) * 0.6
    }
    if game.pickups[i].y > world_bottom() - 16.0 {
      game.pickups[i].y = world_bottom() - 16.0
      game.pickups[i].vy = -absf(game.pickups[i].vy) * 0.6
    }

    let rr : Float = rider_r + pickup_distance(game.pickups[i].kind)
    if dist2(game.rider_x, game.rider_y, game.pickups[i].x, game.pickups[i].y) <=
      rr * rr {
      let kind : Int = game.pickups[i].kind
      let px : Float = game.pickups[i].x
      let py : Float = game.pickups[i].y
      game.pickups[i].active = false
      collect_pickup(game, kind, px, py)
    }
  }
}

///|
fn near_order_pick(game : Game, i : Int) -> Bool {
  dist2(
    game.rider_x,
    game.rider_y,
    game.orders[i].x_from,
    game.orders[i].y_from,
  ) <=
  44.0 * 44.0
}

///|
fn near_order_drop(game : Game, i : Int) -> Bool {
  dist2(game.rider_x, game.rider_y, game.orders[i].x_to, game.orders[i].y_to) <=
  52.0 * 52.0
}

///|
fn order_time_bonus(timer_left : Float) -> Int {
  if timer_left > 24.0 {
    36
  } else if timer_left > 16.0 {
    24
  } else if timer_left > 10.0 {
    14
  } else {
    4
  }
}

///|
fn update_orders(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.orders.length(); i = i + 1 {
    if not(game.orders[i].active) {
      continue
    }

    game.orders[i].timer = game.orders[i].timer - dt
    if game.orders[i].timer <= 0.0 {
      game.orders[i].active = false

      if game.cargo_idx == i {
        game.cargo_idx = -1
      }

      game.missed = game.missed + 1
      game.score = maxi(0, game.score - 22)
      game.combo = 0
      game.combo_t = 0.0

      if game.missed % 2 == 0 {
        set_msg(game, "Late order lost.", 1.0)
      }

      continue
    }

    if not(game.orders[i].picked) {
      if game.cargo_idx < 0 && game.action_on && near_order_pick(game, i) {
        game.orders[i].picked = true
        game.cargo_idx = i
        set_msg(game, "Order picked. Deliver now.", 1.0)
        burst(game, game.orders[i].x_from, game.orders[i].y_from, 14, 0)
      }
    } else if game.cargo_idx == i && game.action_on && near_order_drop(game, i) {
      let bonus : Int = order_time_bonus(game.orders[i].timer)
      let gain : Int = game.orders[i].value + bonus + game.combo * 3

      game.orders[i].active = false
      game.cargo_idx = -1

      game.delivered = game.delivered + 1
      game.combo = mini(18, game.combo + 1)
      game.combo_t = 2.2

      game.score = game.score + gain
      if game.score > game.best_score {
        game.best_score = game.score
      }

      set_msg(game, "Delivery +" + gain.to_string(), 1.0)
      burst(game, game.orders[i].x_to, game.orders[i].y_to, 20, 2)
    }
  }
}

///|
fn use_hint(game : Game) -> Bool {
  if game.state != state_play || game.hint_left <= 0 {
    return false
  }

  let mut hx : Float = depot_x()
  let mut hy : Float = depot_y()
  let mut text : String = "Hint: depot is marked."

  if game.cargo_idx >= 0 &&
    game.cargo_idx < game.orders.length() &&
    game.orders[game.cargo_idx].active {
    hx = game.orders[game.cargo_idx].x_to
    hy = game.orders[game.cargo_idx].y_to
    text = "Hint: customer destination marked."
  } else {
    let mut best_d2 : Float = 1000000000.0

    if game.fuel < 40.0 {
      for i = 0; i < game.pickups.length(); i = i + 1 {
        if not(game.pickups[i].active) || game.pickups[i].kind != pickup_fuel {
          continue
        }

        let d2 : Float = dist2(
          game.rider_x,
          game.rider_y,
          game.pickups[i].x,
          game.pickups[i].y,
        )
        if d2 < best_d2 {
          best_d2 = d2
          hx = game.pickups[i].x
          hy = game.pickups[i].y
          text = "Hint: fuel pickup marked."
        }
      }
    }

    if best_d2 >= 900000000.0 {
      for i = 0; i < game.orders.length(); i = i + 1 {
        if not(game.orders[i].active) || game.orders[i].picked {
          continue
        }

        let d2 : Float = dist2(
          game.rider_x,
          game.rider_y,
          game.orders[i].x_from,
          game.orders[i].y_from,
        )
        if d2 < best_d2 {
          best_d2 = d2
          hx = game.orders[i].x_from
          hy = game.orders[i].y_from
          text = "Hint: nearest pickup restaurant marked."
        }
      }
    }
  }

  game.hint_x = hx
  game.hint_y = hy
  game.hint_t = 2.8
  game.hint_left = game.hint_left - 1
  game.score = maxi(0, game.score - 5)

  set_msg(game, text, 1.3)

  true
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  let step : Float = clampf(dt, 0.0, 0.04)

  game.ui_t = game.ui_t + step
  game.touch_cd = maxf(0.0, game.touch_cd - step)
  game.msg_t = maxf(0.0, game.msg_t - step)
  game.shake_t = maxf(0.0, game.shake_t - step)
  game.hint_t = maxf(0.0, game.hint_t - step)

  game.combo_t = maxf(0.0, game.combo_t - step)
  if game.combo_t <= 0.0 {
    game.combo = 0
  }

  game.turbo_t = maxf(0.0, game.turbo_t - step)
  game.action_cd = maxf(0.0, game.action_cd - step)

  update_particles(game, step)

  if game.state != state_play {
    return
  }

  game.game_t = game.game_t + step

  if game.score >= score_goal {
    finish_run(game, true)
    return
  }

  if game.game_t >= run_time_goal {
    finish_run(game, game.score >= score_goal * 8 / 10)
    return
  }

  game.wave = clampi(1 + (game.game_t / 22.0).to_int(), 1, 12)

  game.order_spawn_t = game.order_spawn_t + step
  let order_interval : Float = maxf(
    1.0,
    2.8 - Float::from_int(game.wave) * 0.12,
  )
  if game.order_spawn_t >= order_interval {
    game.order_spawn_t = game.order_spawn_t - order_interval
    if active_orders(game) < 4 {
      ignore(spawn_order(game))
    }
  }

  game.traffic_spawn_t = game.traffic_spawn_t + step
  let traffic_interval : Float = maxf(
    0.14,
    0.62 - Float::from_int(game.wave) * 0.028,
  )
  while game.traffic_spawn_t >= traffic_interval {
    game.traffic_spawn_t = game.traffic_spawn_t - traffic_interval
    ignore(spawn_traffic(game))
  }

  game.pickup_spawn_t = game.pickup_spawn_t + step
  if game.pickup_spawn_t >= 3.3 {
    game.pickup_spawn_t = 0.0
    ignore(spawn_pickup(game))
  }

  update_rider(game, step)
  update_orders(game, step)
  update_traffic(game, step)
  if game.state != state_play {
    return
  }
  update_pickups(game, step)

  let drain : Float = if game.boost_on || game.turbo_t > 0.0 {
    2.5 + Float::from_int(game.wave) * 0.10
  } else {
    1.1 + Float::from_int(game.wave) * 0.06
  }

  game.fuel = maxf(0.0, game.fuel - drain * step)

  if game.fuel <= 0.0 {
    game.scooter_hp = maxf(0.0, game.scooter_hp - step * 6.0)
  }

  if game.scooter_hp <= 0.0 {
    hurt_rider(game, 100.0)
    if game.state != state_play {
      return
    }
  }

  if game.lives <= 0 {
    finish_run(game, false)
    return
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}
