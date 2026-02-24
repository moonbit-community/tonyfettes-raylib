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
fn safe_cx() -> Float {
  Float::from_int(safe_zone_x() + safe_zone_w() / 2)
}

///|
fn safe_cy() -> Float {
  Float::from_int(safe_zone_y() + safe_zone_h() / 2)
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
fn inside_safe_zone(x : Float, y : Float) -> Bool {
  point_in_rectf(
    x,
    y,
    Float::from_int(safe_zone_x()),
    Float::from_int(safe_zone_y()),
    Float::from_int(safe_zone_w()),
    Float::from_int(safe_zone_h()),
  )
}

///|
fn hook_tip_x(game : Game) -> Float {
  game.heli_x
}

///|
fn hook_tip_y(game : Game) -> Float {
  game.heli_y + game.hook_len
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
  for i = 0; i < game.survivors.length(); i = i + 1 {
    game.survivors[i].active = false
    game.survivors[i].x = 0.0
    game.survivors[i].y = 0.0
    game.survivors[i].vx = 0.0
    game.survivors[i].vy = 0.0
    game.survivors[i].carried = false
    game.survivors[i].panic = 0.0
    game.survivors[i].phase = 0.0
  }

  for i = 0; i < game.hazards.length(); i = i + 1 {
    game.hazards[i].active = false
    game.hazards[i].x = 0.0
    game.hazards[i].y = 0.0
    game.hazards[i].vx = 0.0
    game.hazards[i].vy = 0.0
    game.hazards[i].r = 0.0
    game.hazards[i].hp = 0.0
    game.hazards[i].kind = hazard_cloud
    game.hazards[i].phase = 0.0
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
      x + randf(-14.0, 14.0),
      y + randf(-14.0, 14.0),
      randf(-260.0, 260.0),
      randf(-220.0, 160.0),
      randf(0.22, 1.1),
      randf(1.2, 5.8),
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

    let damp : Float = if game.particles[i].kind == 2 { 2.8 } else { 1.9 }
    game.particles[i].vx = game.particles[i].vx * (1.0 - dt * damp)
    game.particles[i].vy = game.particles[i].vy * (1.0 - dt * (damp - 0.4)) +
      dt * (if game.particles[i].kind == 1 { 180.0 } else { 110.0 })
  }
}

///|
fn reset_heli(game : Game) -> Unit {
  game.heli_x = Float::from_int(world_x0 + world_w / 2)
  game.heli_y = Float::from_int(world_y0 + world_h - 220)
  game.heli_vx = 0.0
  game.heli_vy = 0.0
  game.move_x = 0.0
  game.move_y = 0.0

  game.hook_len = 46.0
  game.hook_target = 46.0
  game.hook_extending = false
  game.carrying_idx = -1
}

///|
fn start_run(game : Game) -> Unit {
  clear_world(game)
  clear_particles(game)

  game.state = state_play

  reset_heli(game)

  game.boost_on = false
  game.lives = 3
  game.hull = 100.0
  game.fuel = 100.0
  game.turbo_t = 0.0
  game.repair_cd = 0.0

  game.score = 0
  game.rescued = 0
  game.lost = 0
  game.wave = 1
  game.combo = 0
  game.combo_t = 0.0

  game.survivor_spawn_t = 0.55
  game.hazard_spawn_t = 0.35
  game.pickup_spawn_t = 1.2
  game.storm_t = 0.0

  game.game_t = 0.0
  game.ui_t = 0.0
  game.touch_cd = 0.0

  game.hint_left = 3
  game.hint_t = 0.0
  game.hint_x = safe_cx()
  game.hint_y = safe_cy()

  game.msg = ""
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.win = false

  set_msg(game, "Rescue 18 survivors with the skyhook.", 2.8)
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

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if win {
    set_msg(game, "All priority civilians extracted.", 3.0)
    burst(game, safe_cx(), safe_cy(), 70, 2)
  } else {
    set_msg(game, "Rescue mission failed in storm zone.", 3.0)
    burst(game, game.heli_x, game.heli_y, 56, 1)
  }
}

///|
fn spawn_survivor(game : Game) -> Bool {
  for i = 0; i < game.survivors.length(); i = i + 1 {
    if game.survivors[i].active {
      continue
    }

    game.survivors[i].active = true
    game.survivors[i].carried = false

    let lane : Int = @raylib.get_random_value(0, 4)
    game.survivors[i].x = world_left() +
      110.0 +
      Float::from_int(lane) * (Float::from_int(world_w) - 220.0) / 4.0 +
      randf(-40.0, 40.0)
    game.survivors[i].y = world_bottom() - randf(70.0, 130.0)

    game.survivors[i].vx = randf(-18.0, 18.0)
    game.survivors[i].vy = randf(-8.0, 8.0)
    game.survivors[i].panic = randf(0.0, 1.0)
    game.survivors[i].phase = randf(0.0, 6.28)

    return true
  }

  false
}

///|
fn spawn_hazard(game : Game) -> Bool {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    if game.hazards[i].active {
      continue
    }

    let roll : Int = @raylib.get_random_value(0, 99)
    let kind : Int = if roll < 52 {
      hazard_cloud
    } else if roll < 82 {
      hazard_drone
    } else {
      hazard_ice
    }

    let side : Int = @raylib.get_random_value(0, 2)
    if side == 0 {
      game.hazards[i].x = randf(world_left() + 30.0, world_right() - 30.0)
      game.hazards[i].y = world_top() - 60.0
    } else if side == 1 {
      game.hazards[i].x = world_left() - 60.0
      game.hazards[i].y = randf(world_top() + 30.0, world_bottom() - 30.0)
    } else {
      game.hazards[i].x = world_right() + 60.0
      game.hazards[i].y = randf(world_top() + 30.0, world_bottom() - 30.0)
    }

    game.hazards[i].active = true
    game.hazards[i].kind = kind
    game.hazards[i].phase = randf(0.0, 6.28)

    if kind == hazard_cloud {
      game.hazards[i].r = randf(32.0, 46.0)
      game.hazards[i].hp = randf(20.0, 28.0)
      game.hazards[i].vx = randf(-58.0, 58.0)
      game.hazards[i].vy = randf(48.0, 96.0) + Float::from_int(game.wave) * 6.0
    } else if kind == hazard_drone {
      game.hazards[i].r = randf(20.0, 28.0)
      game.hazards[i].hp = randf(34.0, 44.0)
      game.hazards[i].vx = randf(-24.0, 24.0)
      game.hazards[i].vy = randf(-24.0, 24.0)
    } else {
      game.hazards[i].r = randf(16.0, 22.0)
      game.hazards[i].hp = randf(12.0, 18.0)
      game.hazards[i].vx = randf(-34.0, 34.0)
      game.hazards[i].vy = randf(160.0, 240.0) +
        Float::from_int(game.wave) * 14.0
    }

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
    game.pickups[i].x = randf(world_left() + 26.0, world_right() - 26.0)
    game.pickups[i].y = world_top() - randf(40.0, 240.0)
    game.pickups[i].vx = randf(-40.0, 40.0)
    game.pickups[i].vy = randf(100.0, 160.0)
    game.pickups[i].phase = randf(0.0, 6.28)

    let roll : Int = @raylib.get_random_value(0, 99)
    game.pickups[i].kind = if roll < 52 {
      pickup_fuel
    } else if roll < 82 {
      pickup_medkit
    } else {
      pickup_turbo
    }

    return true
  }

  false
}

///|
fn count_active_survivors(game : Game) -> Int {
  let mut n : Int = 0
  for i = 0; i < game.survivors.length(); i = i + 1 {
    if game.survivors[i].active {
      n = n + 1
    }
  }
  n
}

///|
fn try_toggle_hook(game : Game) -> Bool {
  if game.state != state_play {
    return false
  }

  game.hook_extending = not(game.hook_extending)
  game.hook_target = if game.hook_extending { 240.0 } else { 46.0 }

  if game.hook_extending {
    set_msg(game, "Hook extending.", 0.8)
  } else {
    set_msg(game, "Hook retracting.", 0.8)
  }

  true
}

///|
fn try_repair(game : Game) -> Bool {
  if game.state != state_play {
    return false
  }
  if game.repair_cd > 0.0 {
    return false
  }

  let near_pad : Bool = dist2(game.heli_x, game.heli_y, safe_cx(), safe_cy()) <=
    180.0 * 180.0

  if not(near_pad) {
    set_msg(game, "Return to rescue pad for repair.", 1.0)
    game.repair_cd = 0.22
    return false
  }

  if game.fuel < 8.0 {
    set_msg(game, "Not enough fuel for field repair.", 1.0)
    game.repair_cd = 0.22
    return false
  }

  game.fuel = maxf(0.0, game.fuel - 8.0)
  game.hull = minf(100.0, game.hull + 32.0)
  game.repair_cd = 1.1

  game.score = game.score + 14
  set_msg(game, "Repair complete.", 1.1)
  burst(game, game.heli_x, game.heli_y, 24, 2)

  true
}

///|
fn hurt_heli(game : Game, dmg : Float) -> Unit {
  game.hull = game.hull - dmg
  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = maxf(game.shake_t, 0.26)

  if game.hull <= 0.0 {
    game.lives = game.lives - 1
    game.hull = 100.0
    game.fuel = maxf(0.0, game.fuel - 16.0)

    reset_heli(game)
    set_msg(game, "Helicopter downed. Life lost.", 1.6)
    burst(game, game.heli_x, game.heli_y, 34, 1)

    if game.lives <= 0 {
      finish_run(game, false)
    }
  } else {
    burst(game, game.heli_x, game.heli_y, 14, 1)
  }
}

///|
fn drop_carried_survivor(game : Game) -> Unit {
  if game.carrying_idx < 0 || game.carrying_idx >= game.survivors.length() {
    game.carrying_idx = -1
    return
  }

  let idx : Int = game.carrying_idx
  if game.survivors[idx].active {
    game.survivors[idx].active = false
    game.survivors[idx].carried = false
    game.lost = game.lost + 1
    game.score = maxi(0, game.score - 18)
    set_msg(game, "Passenger lost in storm.", 1.3)
    burst(game, game.survivors[idx].x, game.survivors[idx].y, 22, 1)
  }

  game.carrying_idx = -1
  game.hook_extending = false
  game.hook_target = 46.0
}

///|
fn rescue_carried_survivor(game : Game) -> Unit {
  if game.carrying_idx < 0 || game.carrying_idx >= game.survivors.length() {
    game.carrying_idx = -1
    return
  }

  let idx : Int = game.carrying_idx
  if game.survivors[idx].active {
    game.survivors[idx].active = false
    game.survivors[idx].carried = false

    game.rescued = game.rescued + 1
    game.combo = mini(15, game.combo + 1)
    game.combo_t = 2.3

    let bonus : Int = 24 + game.wave + game.combo * 2
    game.score = game.score + bonus

    if game.score > game.best_score {
      game.best_score = game.score
    }

    set_msg(game, "Civilian delivered +" + bonus.to_string(), 1.1)
    burst(game, safe_cx(), safe_cy(), 28, 2)
  }

  game.carrying_idx = -1
  game.hook_extending = false
  game.hook_target = 46.0
}

///|
fn collect_pickup(game : Game, kind : Int, x : Float, y : Float) -> Unit {
  if kind == pickup_fuel {
    game.fuel = minf(100.0, game.fuel + 30.0)
    game.score = game.score + 10
    set_msg(game, "Fuel pod collected.", 1.0)
    burst(game, x, y, 18, 0)
  } else if kind == pickup_medkit {
    game.hull = minf(100.0, game.hull + 28.0)
    game.score = game.score + 10
    set_msg(game, "Hull repairs online.", 1.0)
    burst(game, x, y, 18, 2)
  } else {
    game.turbo_t = maxf(game.turbo_t, 7.0)
    game.score = game.score + 16
    set_msg(game, "Turbo rotor boost ready.", 1.0)
    burst(game, x, y, 20, 2)
  }
}

///|
fn update_heli(game : Game, dt : Float) -> Unit {
  let wind_x : Float = sinf(game.storm_t * 0.82 + game.heli_y * 0.010) *
    (52.0 + Float::from_int(game.wave) * 6.0)
  let wind_y : Float = cosf(game.storm_t * 0.64 + game.heli_x * 0.008) * 26.0

  let boost_mul : Float = if game.boost_on || game.turbo_t > 0.0 {
    1.45
  } else {
    1.0
  }

  game.heli_vx = game.heli_vx + (game.move_x * 720.0 * boost_mul + wind_x) * dt
  game.heli_vy = game.heli_vy + (game.move_y * 680.0 * boost_mul + wind_y) * dt

  game.heli_vx = game.heli_vx * (1.0 - dt * 3.0)
  game.heli_vy = game.heli_vy * (1.0 - dt * 3.0)

  game.heli_x = game.heli_x + game.heli_vx * dt
  game.heli_y = game.heli_y + game.heli_vy * dt

  let left : Float = world_left() + heli_r + 8.0
  let right : Float = world_right() - heli_r - 8.0
  let top : Float = world_top() + heli_r + 8.0
  let bottom : Float = world_bottom() - heli_r - 8.0

  if game.heli_x < left {
    game.heli_x = left
    game.heli_vx = absf(game.heli_vx) * 0.24
  } else if game.heli_x > right {
    game.heli_x = right
    game.heli_vx = -absf(game.heli_vx) * 0.24
  }

  if game.heli_y < top {
    game.heli_y = top
    game.heli_vy = absf(game.heli_vy) * 0.24
  } else if game.heli_y > bottom {
    game.heli_y = bottom
    game.heli_vy = -absf(game.heli_vy) * 0.24
  }

  if game.boost_on || game.turbo_t > 0.0 {
    emit_particle(
      game,
      game.heli_x + randf(-8.0, 8.0),
      game.heli_y + randf(14.0, 22.0),
      randf(-40.0, 40.0),
      randf(30.0, 110.0),
      randf(0.18, 0.44),
      randf(1.2, 3.6),
      0,
    )
  }
}

///|
fn update_hook(game : Game, dt : Float) -> Float {
  let old_len : Float = game.hook_len

  if game.hook_extending {
    game.hook_target = 240.0
  } else {
    game.hook_target = 46.0
  }

  if game.hook_len < game.hook_target {
    game.hook_len = minf(game.hook_target, game.hook_len + dt * 520.0)
  } else {
    game.hook_len = maxf(game.hook_target, game.hook_len - dt * 580.0)
  }

  let tip_x : Float = hook_tip_x(game)
  let tip_y : Float = hook_tip_y(game)

  if game.carrying_idx < 0 && game.hook_len > 82.0 {
    for i = 0; i < game.survivors.length(); i = i + 1 {
      if not(game.survivors[i].active) || game.survivors[i].carried {
        continue
      }

      let rr : Float = survivor_r + 16.0
      if dist2(tip_x, tip_y, game.survivors[i].x, game.survivors[i].y) <=
        rr * rr {
        game.carrying_idx = i
        game.survivors[i].carried = true
        game.survivors[i].panic = 0.0
        set_msg(game, "Passenger latched.", 0.9)
        burst(game, tip_x, tip_y, 16, 2)
        break
      }
    }
  }

  if game.carrying_idx >= 0 && game.carrying_idx < game.survivors.length() {
    let idx : Int = game.carrying_idx

    if game.survivors[idx].active {
      game.survivors[idx].x = game.survivors[idx].x +
        (tip_x - game.survivors[idx].x) * minf(1.0, dt * 12.0)
      game.survivors[idx].y = game.survivors[idx].y +
        (tip_y - game.survivors[idx].y) * minf(1.0, dt * 12.0)

      game.survivors[idx].vx = 0.0
      game.survivors[idx].vy = 0.0
      game.survivors[idx].phase = game.survivors[idx].phase + dt * 6.0

      if game.hook_len <= 64.0 &&
        inside_safe_zone(game.survivors[idx].x, game.survivors[idx].y) {
        rescue_carried_survivor(game)
      }
    } else {
      game.carrying_idx = -1
    }
  }

  absf(game.hook_len - old_len) / maxf(0.0001, dt)
}

///|
fn update_survivors(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.survivors.length(); i = i + 1 {
    if not(game.survivors[i].active) {
      continue
    }

    if game.survivors[i].carried {
      continue
    }

    game.survivors[i].phase = game.survivors[i].phase + dt * 1.7
    game.survivors[i].panic = minf(4.0, game.survivors[i].panic + dt * 0.18)

    let drift_x : Float = sinf(game.survivors[i].phase * 2.2) *
      (10.0 + game.survivors[i].panic * 3.0)
    let drift_y : Float = cosf(game.survivors[i].phase * 1.9) *
      (6.0 + game.survivors[i].panic * 2.0)

    game.survivors[i].vx = game.survivors[i].vx * (1.0 - dt * 2.0) +
      drift_x * dt
    game.survivors[i].vy = game.survivors[i].vy * (1.0 - dt * 2.0) +
      drift_y * dt

    game.survivors[i].x = game.survivors[i].x + game.survivors[i].vx * dt
    game.survivors[i].y = game.survivors[i].y + game.survivors[i].vy * dt

    game.survivors[i].x = clampf(
      game.survivors[i].x,
      world_left() + survivor_r + 10.0,
      world_right() - survivor_r - 10.0,
    )
    game.survivors[i].y = clampf(
      game.survivors[i].y,
      world_top() + survivor_r + 14.0,
      world_bottom() - survivor_r - 12.0,
    )

    let near_hazard : Bool = false
    ignore(near_hazard)

    if dist2(game.survivors[i].x, game.survivors[i].y, safe_cx(), safe_cy()) <
      86.0 * 86.0 {
      game.survivors[i].panic = maxf(0.0, game.survivors[i].panic - dt * 0.5)
    }
  }
}

///|
fn hazard_damage(kind : Int) -> Float {
  if kind == hazard_drone {
    24.0
  } else if kind == hazard_cloud {
    16.0
  } else {
    20.0
  }
}

///|
fn update_hazards(game : Game, dt : Float, hook_speed : Float) -> Unit {
  let tip_x : Float = hook_tip_x(game)
  let tip_y : Float = hook_tip_y(game)

  for i = 0; i < game.hazards.length(); i = i + 1 {
    if not(game.hazards[i].active) {
      continue
    }

    game.hazards[i].phase = game.hazards[i].phase +
      dt * (1.0 + Float::from_int(game.hazards[i].kind) * 0.8)

    if game.hazards[i].kind == hazard_cloud {
      game.hazards[i].vx = game.hazards[i].vx +
        sinf(game.hazards[i].phase * 1.4) * dt * 80.0
      game.hazards[i].vy = game.hazards[i].vy + dt * 24.0
    } else if game.hazards[i].kind == hazard_drone {
      let tx : Float = if game.carrying_idx >= 0 { tip_x } else { game.heli_x }
      let ty : Float = if game.carrying_idx >= 0 { tip_y } else { game.heli_y }

      let dx : Float = tx - game.hazards[i].x
      let dy : Float = ty - game.hazards[i].y

      let w : Float = absf(dx) + absf(dy)
      let nx : Float = if w <= 0.001 { 0.0 } else { dx / w }
      let ny : Float = if w <= 0.001 { 0.0 } else { dy / w }

      game.hazards[i].vx = game.hazards[i].vx * (1.0 - dt * 2.4) +
        nx * dt * 420.0
      game.hazards[i].vy = game.hazards[i].vy * (1.0 - dt * 2.4) +
        ny * dt * 420.0
    } else {
      game.hazards[i].vx = game.hazards[i].vx +
        sinf(game.hazards[i].phase * 3.0) * dt * 96.0
      game.hazards[i].vy = game.hazards[i].vy + dt * 54.0
    }

    game.hazards[i].vx = clampf(game.hazards[i].vx, -260.0, 260.0)
    game.hazards[i].vy = clampf(game.hazards[i].vy, -220.0, 300.0)

    game.hazards[i].x = game.hazards[i].x + game.hazards[i].vx * dt
    game.hazards[i].y = game.hazards[i].y + game.hazards[i].vy * dt

    if game.hazards[i].x < world_left() - 120.0 ||
      game.hazards[i].x > world_right() + 120.0 ||
      game.hazards[i].y < world_top() - 120.0 ||
      game.hazards[i].y > world_bottom() + 120.0 {
      game.hazards[i].active = false
      continue
    }

    let rr_heli : Float = game.hazards[i].r + heli_r - 4.0
    if dist2(game.hazards[i].x, game.hazards[i].y, game.heli_x, game.heli_y) <=
      rr_heli * rr_heli {
      hurt_heli(game, hazard_damage(game.hazards[i].kind))
      game.hazards[i].active = false
      if game.state != state_play {
        return
      }
      continue
    }

    if game.carrying_idx >= 0 && game.carrying_idx < game.survivors.length() {
      let idx : Int = game.carrying_idx
      if game.survivors[idx].active {
        let rr_car : Float = game.hazards[i].r + survivor_r
        if dist2(
            game.hazards[i].x,
            game.hazards[i].y,
            game.survivors[idx].x,
            game.survivors[idx].y,
          ) <=
          rr_car * rr_car {
          game.hazards[i].active = false
          drop_carried_survivor(game)
          continue
        }
      }
    }

    let rr_hook : Float = game.hazards[i].r + 12.0
    if hook_speed > 260.0 &&
      dist2(game.hazards[i].x, game.hazards[i].y, tip_x, tip_y) <=
      rr_hook * rr_hook {
      let dmg : Float = if hook_speed > 460.0 { 34.0 } else { 18.0 }
      game.hazards[i].hp = game.hazards[i].hp - dmg

      burst(game, game.hazards[i].x, game.hazards[i].y, 14, 0)

      if game.hazards[i].hp <= 0.0 {
        game.hazards[i].active = false
        game.score = game.score + 8 + game.wave
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

    game.pickups[i].phase = game.pickups[i].phase + dt * 2.2

    game.pickups[i].x = game.pickups[i].x +
      (game.pickups[i].vx + sinf(game.pickups[i].phase * 2.3) * 20.0) * dt
    game.pickups[i].y = game.pickups[i].y +
      (game.pickups[i].vy + Float::from_int(game.wave) * 4.0) * dt

    if game.pickups[i].x < world_left() + 16.0 {
      game.pickups[i].x = world_left() + 16.0
      game.pickups[i].vx = absf(game.pickups[i].vx) * 0.6
    }
    if game.pickups[i].x > world_right() - 16.0 {
      game.pickups[i].x = world_right() - 16.0
      game.pickups[i].vx = -absf(game.pickups[i].vx) * 0.6
    }

    if game.pickups[i].y > world_bottom() + 80.0 {
      game.pickups[i].active = false
      continue
    }

    let rr : Float = heli_r + 16.0
    if dist2(game.heli_x, game.heli_y, game.pickups[i].x, game.pickups[i].y) <=
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
fn use_hint(game : Game) -> Bool {
  if game.state != state_play || game.hint_left <= 0 {
    return false
  }

  let mut hx : Float = safe_cx()
  let mut hy : Float = safe_cy()
  let mut msg : String = "Hint: deliver to safe zone."

  if game.carrying_idx >= 0 && game.carrying_idx < game.survivors.length() {
    hx = safe_cx()
    hy = safe_cy()
    msg = "Hint: retract hook inside safe zone."
  } else {
    let mut best_d2 : Float = 1000000000.0

    if game.fuel < 40.0 {
      for i = 0; i < game.pickups.length(); i = i + 1 {
        if not(game.pickups[i].active) || game.pickups[i].kind != pickup_fuel {
          continue
        }

        let d2 : Float = dist2(
          game.heli_x,
          game.heli_y,
          game.pickups[i].x,
          game.pickups[i].y,
        )

        if d2 < best_d2 {
          best_d2 = d2
          hx = game.pickups[i].x
          hy = game.pickups[i].y
          msg = "Hint: fuel canister marked."
        }
      }
    }

    if best_d2 >= 900000000.0 {
      for i = 0; i < game.survivors.length(); i = i + 1 {
        if not(game.survivors[i].active) || game.survivors[i].carried {
          continue
        }

        let d2 : Float = dist2(
          game.heli_x,
          game.heli_y,
          game.survivors[i].x,
          game.survivors[i].y,
        )

        if d2 < best_d2 {
          best_d2 = d2
          hx = game.survivors[i].x
          hy = game.survivors[i].y
          msg = "Hint: nearest civilian marked."
        }
      }
    }
  }

  game.hint_x = hx
  game.hint_y = hy
  game.hint_t = 2.8
  game.hint_left = game.hint_left - 1
  game.score = maxi(0, game.score - 5)

  set_msg(game, msg, 1.3)

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
  game.repair_cd = maxf(0.0, game.repair_cd - step)

  update_particles(game, step)

  if game.state != state_play {
    return
  }

  game.game_t = game.game_t + step
  game.storm_t = game.storm_t + step

  if game.rescued >= rescue_target {
    finish_run(game, true)
    return
  }

  if game.game_t >= run_time_goal {
    finish_run(game, false)
    return
  }

  game.wave = clampi(1 + (game.game_t / 24.0).to_int(), 1, 10)

  game.survivor_spawn_t = game.survivor_spawn_t + step
  let spawn_survivor_every : Float = maxf(
    1.1,
    2.5 - Float::from_int(game.wave) * 0.12,
  )
  if game.survivor_spawn_t >= spawn_survivor_every {
    game.survivor_spawn_t = game.survivor_spawn_t - spawn_survivor_every
    if count_active_survivors(game) < 9 {
      ignore(spawn_survivor(game))
    }
  }

  game.hazard_spawn_t = game.hazard_spawn_t + step
  let spawn_hazard_every : Float = maxf(
    0.26,
    0.74 - Float::from_int(game.wave) * 0.04,
  )
  while game.hazard_spawn_t >= spawn_hazard_every {
    game.hazard_spawn_t = game.hazard_spawn_t - spawn_hazard_every
    ignore(spawn_hazard(game))
  }

  game.pickup_spawn_t = game.pickup_spawn_t + step
  if game.pickup_spawn_t >= 3.0 {
    game.pickup_spawn_t = 0.0
    ignore(spawn_pickup(game))
  }

  update_heli(game, step)
  let hook_speed : Float = update_hook(game, step)
  update_survivors(game, step)
  update_hazards(game, step, hook_speed)
  if game.state != state_play {
    return
  }
  update_pickups(game, step)

  let fuel_drain : Float = if game.boost_on || game.turbo_t > 0.0 {
    2.7 + Float::from_int(game.wave) * 0.12
  } else {
    1.2 + Float::from_int(game.wave) * 0.08
  }

  game.fuel = maxf(0.0, game.fuel - fuel_drain * step)

  if game.fuel <= 0.0 {
    game.hull = maxf(0.0, game.hull - step * 7.0)
  }

  if game.hull <= 0.0 {
    hurt_heli(game, 100.0)
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
