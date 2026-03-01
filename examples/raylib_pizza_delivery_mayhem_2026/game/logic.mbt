///|
fn set_msg(game : @types.Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
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
fn clear_world(game : @types.Game) -> Unit {
  for traffic_elem in game.traffic {
    traffic_elem.active = false
    traffic_elem.x = 0.0
    traffic_elem.y = 0.0
    traffic_elem.vx = 0.0
    traffic_elem.vy = 0.0
    traffic_elem.w = 0.0
    traffic_elem.h = 0.0
    traffic_elem.kind = @types.traffic_sedan
    traffic_elem.phase = 0.0
  }
  for order in game.orders {
    order.active = false
    order.picked = false
    order.x_from = 0.0
    order.y_from = 0.0
    order.x_to = 0.0
    order.y_to = 0.0
    order.timer = 0.0
    order.value = 0
  }
  for pickup in game.pickups {
    pickup.active = false
    pickup.x = 0.0
    pickup.y = 0.0
    pickup.vx = 0.0
    pickup.vy = 0.0
    pickup.kind = @types.pickup_fuel
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
fn burst(game : @types.Game, x : Float, y : Float, n : Int, kind : Int) -> Unit {
  for _i in 0..<n {
    emit_particle(
      game,
      x + @types.randf(-12.0, 12.0),
      y + @types.randf(-12.0, 12.0),
      @types.randf(-240.0, 240.0),
      @types.randf(-220.0, 140.0),
      @types.randf(0.22, 1.0),
      @types.randf(1.2, 5.2),
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
    let drag : Float = if particle.kind == 2 { 2.7 } else { 1.9 }
    particle.vx = particle.vx * (1.0 - dt * drag)
    particle.vy = particle.vy * (1.0 - dt * (drag - 0.4)) +
      dt * (if particle.kind == 1 { 180.0 } else { 120.0 })
  }
}

///|
fn reset_rider(game : @types.Game) -> Unit {
  game.rider_x = Float::from_int(@types.world_x0 + @types.world_w / 2)
  game.rider_y = Float::from_int(@types.world_y0 + @types.world_h / 2)
  game.rider_vx = 0.0
  game.rider_vy = 0.0
  game.move_x = 0.0
  game.move_y = 0.0
  game.boost_on = false
  game.action_on = false
  game.cargo_idx = -1
}

///|
fn start_run(game : @types.Game) -> Unit {
  clear_world(game)
  clear_particles(game)
  game.state = @types.state_play
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
  game.hint_x = @types.restaurant_x(0)
  game.hint_y = @types.restaurant_y(0)
  game.msg = ""
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.win = false
  set_msg(game, "Pick up pizza, deliver fast, avoid traffic.", 2.6)
}

///|
fn finish_run(game : @types.Game, win : Bool) -> Unit {
  if game.state != @types.state_play {
    return
  }
  game.state = @types.state_result
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
    burst(game, @types.depot_x(), @types.depot_y(), 66, 2)
  } else {
    set_msg(game, "Rush ended. Try another shift.", 3.0)
    burst(game, game.rider_x, game.rider_y, 52, 1)
  }
}

///|
fn active_orders(game : @types.Game) -> Int {
  let mut n : Int = 0
  for order in game.orders {
    if order.active {
      n = n + 1
    }
  }
  n
}

///|
fn spawn_order(game : @types.Game) -> Bool {
  for order in game.orders {
    if order.active {
      continue
    }
    let src : Int = @raylib.get_random_value(0, 2)
    let mut tx : Float = @types.randf(
      @types.world_left() + 70.0,
      @types.world_right() - 70.0,
    )
    let mut ty : Float = @types.randf(
      @types.world_top() + 70.0,
      @types.world_bottom() - 70.0,
    )
    tx = @types.world_left() +
      Float::from_int(
        (tx - @types.world_left()).to_int() /
        @types.road_step *
        @types.road_step +
        @types.road_step / 2,
      )
    ty = @types.world_top() +
      Float::from_int(
        (ty - @types.world_top()).to_int() / @types.road_step * @types.road_step +
        @types.road_step / 2,
      )
    order.active = true
    order.picked = false
    order.x_from = @types.restaurant_x(src)
    order.y_from = @types.restaurant_y(src)
    order.x_to = tx
    order.y_to = ty
    order.timer = @types.randf(24.0, 42.0) - Float::from_int(game.wave) * 0.6
    order.timer = @types.maxf(16.0, order.timer)
    order.value = @raylib.get_random_value(70, 130)
    return true
  }
  false
}

///|
fn spawn_traffic(game : @types.Game) -> Bool {
  for traffic_elem in game.traffic {
    if traffic_elem.active {
      continue
    }
    let kind_roll : Int = @raylib.get_random_value(0, 99)
    let kind : Int = if kind_roll < 58 {
      @types.traffic_sedan
    } else if kind_roll < 84 {
      @types.traffic_van
    } else {
      @types.traffic_bus
    }
    let lane : Int = @raylib.get_random_value(0, 1)
    if lane == 0 {
      let y_lane : Float = @types.world_top() +
        Float::from_int(
          @raylib.get_random_value(1, @types.world_h / @types.road_step - 2) *
          @types.road_step +
          @types.road_step / 2,
        )
      let from_left : Bool = @raylib.get_random_value(0, 1) == 0
      traffic_elem.x = if from_left {
        @types.world_left() - 80.0
      } else {
        @types.world_right() + 80.0
      }
      traffic_elem.y = y_lane
      traffic_elem.vx = if from_left {
        @types.randf(180.0, 280.0)
      } else {
        @types.randf(-280.0, -180.0)
      }
      traffic_elem.vy = @types.randf(-16.0, 16.0)
      if kind == @types.traffic_sedan {
        traffic_elem.w = 48.0
        traffic_elem.h = 30.0
      } else if kind == @types.traffic_van {
        traffic_elem.w = 60.0
        traffic_elem.h = 34.0
      } else {
        traffic_elem.w = 88.0
        traffic_elem.h = 40.0
      }
    } else {
      let x_lane : Float = @types.world_left() +
        Float::from_int(
          @raylib.get_random_value(1, @types.world_w / @types.road_step - 2) *
          @types.road_step +
          @types.road_step / 2,
        )
      let from_top : Bool = @raylib.get_random_value(0, 1) == 0
      traffic_elem.x = x_lane
      traffic_elem.y = if from_top {
        @types.world_top() - 80.0
      } else {
        @types.world_bottom() + 80.0
      }
      traffic_elem.vx = @types.randf(-16.0, 16.0)
      traffic_elem.vy = if from_top {
        @types.randf(180.0, 280.0)
      } else {
        @types.randf(-280.0, -180.0)
      }
      if kind == @types.traffic_sedan {
        traffic_elem.w = 30.0
        traffic_elem.h = 48.0
      } else if kind == @types.traffic_van {
        traffic_elem.w = 34.0
        traffic_elem.h = 60.0
      } else {
        traffic_elem.w = 40.0
        traffic_elem.h = 88.0
      }
    }
    traffic_elem.active = true
    traffic_elem.kind = kind
    traffic_elem.phase = @types.randf(0.0, 6.28)
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
      @types.world_left() + 40.0,
      @types.world_right() - 40.0,
    )
    pickup.y = @types.randf(
      @types.world_top() + 40.0,
      @types.world_bottom() - 40.0,
    )
    pickup.vx = @types.randf(-32.0, 32.0)
    pickup.vy = @types.randf(-32.0, 32.0)
    pickup.phase = @types.randf(0.0, 6.28)
    let roll : Int = @raylib.get_random_value(0, 99)
    pickup.kind = if roll < 46 {
      @types.pickup_fuel
    } else if roll < 78 {
      @types.pickup_repair
    } else {
      @types.pickup_speed
    }
    return true
  }
  false
}

///|
fn try_repair(game : @types.Game) -> Bool {
  if game.state != @types.state_play {
    return false
  }
  if game.action_cd > 0.0 {
    return false
  }
  let near_depot : Bool = @types.point_in_rectf(
    game.rider_x,
    game.rider_y,
    @types.depot_x() - 20.0,
    @types.depot_y() - 20.0,
    Float::from_int(@types.depot_w() + 40),
    Float::from_int(@types.depot_h() + 40),
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
  game.fuel = @types.maxf(0.0, game.fuel - 8.0)
  game.scooter_hp = @types.minf(100.0, game.scooter_hp + 30.0)
  game.action_cd = 1.2
  game.score = game.score + 12
  set_msg(game, "Scooter serviced.", 1.0)
  burst(game, @types.depot_x(), @types.depot_y(), 22, 2)
  true
}

///|
fn pickup_distance(kind : Int) -> Float {
  if kind == @types.pickup_speed {
    28.0
  } else {
    24.0
  }
}

///|
fn collect_pickup(game : @types.Game, kind : Int, x : Float, y : Float) -> Unit {
  if kind == @types.pickup_fuel {
    game.fuel = @types.minf(100.0, game.fuel + 30.0)
    game.score = game.score + 10
    set_msg(game, "Fuel canister collected.", 1.0)
    burst(game, x, y, 16, 0)
  } else if kind == @types.pickup_repair {
    game.scooter_hp = @types.minf(100.0, game.scooter_hp + 24.0)
    game.score = game.score + 10
    set_msg(game, "Quick repair kit used.", 1.0)
    burst(game, x, y, 16, 2)
  } else {
    game.turbo_t = @types.maxf(game.turbo_t, 7.0)
    game.score = game.score + 16
    set_msg(game, "Nitro drink activated.", 1.0)
    burst(game, x, y, 20, 2)
  }
}

///|
fn hurt_rider(game : @types.Game, dmg : Float) -> Unit {
  game.scooter_hp = game.scooter_hp - dmg
  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = @types.maxf(game.shake_t, 0.24)
  if game.scooter_hp <= 0.0 {
    game.lives = game.lives - 1
    game.scooter_hp = 100.0
    game.fuel = @types.maxf(0.0, game.fuel - 16.0)
    game.rider_x = Float::from_int(@types.world_x0 + @types.world_w / 2)
    game.rider_y = Float::from_int(@types.world_y0 + @types.world_h / 2)
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
fn update_rider(game : @types.Game, dt : Float) -> Unit {
  let boost_mul : Float = if game.boost_on || game.turbo_t > 0.0 {
    1.55
  } else {
    1.0
  }
  let traffic_drift_x : Float = @types.sinf(
      game.ui_t * 0.92 + game.rider_y * 0.006,
    ) *
    (14.0 + Float::from_int(game.wave) * 2.2)
  let traffic_drift_y : Float = @types.cosf(
      game.ui_t * 0.81 + game.rider_x * 0.007,
    ) *
    12.0
  game.rider_vx = game.rider_vx +
    (game.move_x * 780.0 * boost_mul + traffic_drift_x) * dt
  game.rider_vy = game.rider_vy +
    (game.move_y * 760.0 * boost_mul + traffic_drift_y) * dt
  game.rider_vx = game.rider_vx * (1.0 - dt * 3.0)
  game.rider_vy = game.rider_vy * (1.0 - dt * 3.0)
  game.rider_x = game.rider_x + game.rider_vx * dt
  game.rider_y = game.rider_y + game.rider_vy * dt
  game.rider_x = @types.clampf(
    game.rider_x,
    @types.world_left() + @types.rider_r + 8.0,
    @types.world_right() - @types.rider_r - 8.0,
  )
  game.rider_y = @types.clampf(
    game.rider_y,
    @types.world_top() + @types.rider_r + 8.0,
    @types.world_bottom() - @types.rider_r - 8.0,
  )
  if game.boost_on || game.turbo_t > 0.0 {
    emit_particle(
      game,
      game.rider_x + @types.randf(-6.0, 6.0),
      game.rider_y + @types.randf(-6.0, 6.0),
      @types.randf(-40.0, 40.0),
      @types.randf(24.0, 86.0),
      @types.randf(0.2, 0.5),
      @types.randf(1.1, 3.0),
      0,
    )
  }
}

///|
fn update_traffic(game : @types.Game, dt : Float) -> Unit {
  for traffic_elem in game.traffic {
    if not(traffic_elem.active) {
      continue
    }
    traffic_elem.phase = traffic_elem.phase +
      dt * (1.4 + Float::from_int(traffic_elem.kind) * 0.6)
    let sway_x : Float = @types.sinf(traffic_elem.phase * 2.0) * 10.0
    let sway_y : Float = @types.cosf(traffic_elem.phase * 1.7) * 10.0
    traffic_elem.x = traffic_elem.x + (traffic_elem.vx + sway_x) * dt
    traffic_elem.y = traffic_elem.y + (traffic_elem.vy + sway_y) * dt
    if traffic_elem.x < @types.world_left() - 130.0 ||
      traffic_elem.x > @types.world_right() + 130.0 ||
      traffic_elem.y < @types.world_top() - 130.0 ||
      traffic_elem.y > @types.world_bottom() + 130.0 {
      traffic_elem.active = false
      continue
    }
    let hit : Bool = @types.circle_rect_hit(
      game.rider_x,
      game.rider_y,
      @types.rider_r,
      traffic_elem.x - traffic_elem.w * 0.5,
      traffic_elem.y - traffic_elem.h * 0.5,
      traffic_elem.w,
      traffic_elem.h,
    )
    if hit {
      let dmg : Float = if traffic_elem.kind == @types.traffic_bus {
        32.0
      } else if traffic_elem.kind == @types.traffic_van {
        22.0
      } else {
        16.0
      }
      hurt_rider(game, dmg)
      traffic_elem.active = false
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
      (pickup.vx + @types.sinf(pickup.phase * 2.0) * 22.0) * dt
    pickup.y = pickup.y +
      (pickup.vy + @types.cosf(pickup.phase * 2.1) * 22.0) * dt
    if pickup.x < @types.world_left() + 16.0 {
      pickup.x = @types.world_left() + 16.0
      pickup.vx = @types.absf(pickup.vx) * 0.6
    }
    if pickup.x > @types.world_right() - 16.0 {
      pickup.x = @types.world_right() - 16.0
      pickup.vx = -@types.absf(pickup.vx) * 0.6
    }
    if pickup.y < @types.world_top() + 16.0 {
      pickup.y = @types.world_top() + 16.0
      pickup.vy = @types.absf(pickup.vy) * 0.6
    }
    if pickup.y > @types.world_bottom() - 16.0 {
      pickup.y = @types.world_bottom() - 16.0
      pickup.vy = -@types.absf(pickup.vy) * 0.6
    }
    let rr : Float = @types.rider_r + pickup_distance(pickup.kind)
    if @types.dist2(game.rider_x, game.rider_y, pickup.x, pickup.y) <= rr * rr {
      let kind : Int = pickup.kind
      let px : Float = pickup.x
      let py : Float = pickup.y
      pickup.active = false
      collect_pickup(game, kind, px, py)
    }
  }
}

///|
fn near_order_pick(game : @types.Game, i : Int) -> Bool {
  @types.dist2(
    game.rider_x,
    game.rider_y,
    game.orders[i].x_from,
    game.orders[i].y_from,
  ) <=
  44.0 * 44.0
}

///|
fn near_order_drop(game : @types.Game, i : Int) -> Bool {
  @types.dist2(
    game.rider_x,
    game.rider_y,
    game.orders[i].x_to,
    game.orders[i].y_to,
  ) <=
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
fn update_orders(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.orders.length() {
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
      game.score = @types.maxi(0, game.score - 22)
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
      game.combo = @types.mini(18, game.combo + 1)
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
fn use_hint(game : @types.Game) -> Bool {
  if game.state != @types.state_play || game.hint_left <= 0 {
    return false
  }
  let mut hx : Float = @types.depot_x()
  let mut hy : Float = @types.depot_y()
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
      for i in 0..<game.pickups.length() {
        if not(game.pickups[i].active) ||
          game.pickups[i].kind != @types.pickup_fuel {
          continue
        }
        let d2 : Float = @types.dist2(
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
      for order in game.orders {
        if not(order.active) || order.picked {
          continue
        }
        let d2 : Float = @types.dist2(
          game.rider_x,
          game.rider_y,
          order.x_from,
          order.y_from,
        )
        if d2 < best_d2 {
          best_d2 = d2
          hx = order.x_from
          hy = order.y_from
          text = "Hint: nearest pickup restaurant marked."
        }
      }
    }
  }
  game.hint_x = hx
  game.hint_y = hy
  game.hint_t = 2.8
  game.hint_left = game.hint_left - 1
  game.score = @types.maxi(0, game.score - 5)
  set_msg(game, text, 1.3)
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
  game.turbo_t = @types.maxf(0.0, game.turbo_t - step)
  game.action_cd = @types.maxf(0.0, game.action_cd - step)
  update_particles(game, step)
  if game.state != @types.state_play {
    return
  }
  game.game_t = game.game_t + step
  if game.score >= @types.score_goal {
    finish_run(game, true)
    return
  }
  if game.game_t >= @types.run_time_goal {
    finish_run(game, game.score >= @types.score_goal * 8 / 10)
    return
  }
  game.wave = @types.clampi(1 + (game.game_t / 22.0).to_int(), 1, 12)
  game.order_spawn_t = game.order_spawn_t + step
  let order_interval : Float = @types.maxf(
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
  let traffic_interval : Float = @types.maxf(
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
  if game.state != @types.state_play {
    return
  }
  update_pickups(game, step)
  let drain : Float = if game.boost_on || game.turbo_t > 0.0 {
    2.5 + Float::from_int(game.wave) * 0.10
  } else {
    1.1 + Float::from_int(game.wave) * 0.06
  }
  game.fuel = @types.maxf(0.0, game.fuel - drain * step)
  if game.fuel <= 0.0 {
    game.scooter_hp = @types.maxf(0.0, game.scooter_hp - step * 6.0)
  }
  if game.scooter_hp <= 0.0 {
    hurt_rider(game, 100.0)
    if game.state != @types.state_play {
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

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
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
