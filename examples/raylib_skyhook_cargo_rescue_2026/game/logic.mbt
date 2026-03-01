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
  for survivor in game.survivors {
    survivor.active = false
    survivor.x = 0.0
    survivor.y = 0.0
    survivor.vx = 0.0
    survivor.vy = 0.0
    survivor.carried = false
    survivor.panic = 0.0
    survivor.phase = 0.0
  }

  for hazard in game.hazards {
    hazard.active = false
    hazard.x = 0.0
    hazard.y = 0.0
    hazard.vx = 0.0
    hazard.vy = 0.0
    hazard.r = 0.0
    hazard.hp = 0.0
    hazard.kind = @types.hazard_cloud
    hazard.phase = 0.0
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
      x + @types.randf(-14.0, 14.0),
      y + @types.randf(-14.0, 14.0),
      @types.randf(-260.0, 260.0),
      @types.randf(-220.0, 160.0),
      @types.randf(0.22, 1.1),
      @types.randf(1.2, 5.8),
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

    let damp : Float = if particle.kind == 2 { 2.8 } else { 1.9 }
    particle.vx = particle.vx * (1.0 - dt * damp)
    particle.vy = particle.vy * (1.0 - dt * (damp - 0.4)) +
      dt * (if particle.kind == 1 { 180.0 } else { 110.0 })
  }
}

///|
fn reset_heli(game : @types.Game) -> Unit {
  game.heli_x = Float::from_int(@types.world_x0 + @types.world_w / 2)
  game.heli_y = Float::from_int(@types.world_y0 + @types.world_h - 220)
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
fn start_run(game : @types.Game) -> Unit {
  clear_world(game)
  clear_particles(game)

  game.state = @types.state_play

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
  game.hint_x = @types.safe_cx()
  game.hint_y = @types.safe_cy()

  game.msg = ""
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.win = false

  set_msg(game, "Rescue 18 survivors with the skyhook.", 2.8)
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

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if win {
    set_msg(game, "All priority civilians extracted.", 3.0)
    burst(game, @types.safe_cx(), @types.safe_cy(), 70, 2)
  } else {
    set_msg(game, "Rescue mission failed in storm zone.", 3.0)
    burst(game, game.heli_x, game.heli_y, 56, 1)
  }
}

///|
fn spawn_survivor(game : @types.Game) -> Bool {
  for survivor in game.survivors {
    if survivor.active {
      continue
    }

    survivor.active = true
    survivor.carried = false

    let lane : Int = @raylib.get_random_value(0, 4)
    survivor.x = @types.world_left() +
      110.0 +
      Float::from_int(lane) * (Float::from_int(@types.world_w) - 220.0) / 4.0 +
      @types.randf(-40.0, 40.0)
    survivor.y = @types.world_bottom() - @types.randf(70.0, 130.0)

    survivor.vx = @types.randf(-18.0, 18.0)
    survivor.vy = @types.randf(-8.0, 8.0)
    survivor.panic = @types.randf(0.0, 1.0)
    survivor.phase = @types.randf(0.0, 6.28)

    return true
  }

  false
}

///|
fn spawn_hazard(game : @types.Game) -> Bool {
  for hazard in game.hazards {
    if hazard.active {
      continue
    }

    let roll : Int = @raylib.get_random_value(0, 99)
    let kind : Int = if roll < 52 {
      @types.hazard_cloud
    } else if roll < 82 {
      @types.hazard_drone
    } else {
      @types.hazard_ice
    }

    let side : Int = @raylib.get_random_value(0, 2)
    if side == 0 {
      hazard.x = @types.randf(
        @types.world_left() + 30.0,
        @types.world_right() - 30.0,
      )
      hazard.y = @types.world_top() - 60.0
    } else if side == 1 {
      hazard.x = @types.world_left() - 60.0
      hazard.y = @types.randf(
        @types.world_top() + 30.0,
        @types.world_bottom() - 30.0,
      )
    } else {
      hazard.x = @types.world_right() + 60.0
      hazard.y = @types.randf(
        @types.world_top() + 30.0,
        @types.world_bottom() - 30.0,
      )
    }

    hazard.active = true
    hazard.kind = kind
    hazard.phase = @types.randf(0.0, 6.28)

    if kind == @types.hazard_cloud {
      hazard.r = @types.randf(32.0, 46.0)
      hazard.hp = @types.randf(20.0, 28.0)
      hazard.vx = @types.randf(-58.0, 58.0)
      hazard.vy = @types.randf(48.0, 96.0) + Float::from_int(game.wave) * 6.0
    } else if kind == @types.hazard_drone {
      hazard.r = @types.randf(20.0, 28.0)
      hazard.hp = @types.randf(34.0, 44.0)
      hazard.vx = @types.randf(-24.0, 24.0)
      hazard.vy = @types.randf(-24.0, 24.0)
    } else {
      hazard.r = @types.randf(16.0, 22.0)
      hazard.hp = @types.randf(12.0, 18.0)
      hazard.vx = @types.randf(-34.0, 34.0)
      hazard.vy = @types.randf(160.0, 240.0) +
        Float::from_int(game.wave) * 14.0
    }

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
      @types.world_left() + 26.0,
      @types.world_right() - 26.0,
    )
    pickup.y = @types.world_top() - @types.randf(40.0, 240.0)
    pickup.vx = @types.randf(-40.0, 40.0)
    pickup.vy = @types.randf(100.0, 160.0)
    pickup.phase = @types.randf(0.0, 6.28)

    let roll : Int = @raylib.get_random_value(0, 99)
    pickup.kind = if roll < 52 {
      @types.pickup_fuel
    } else if roll < 82 {
      @types.pickup_medkit
    } else {
      @types.pickup_turbo
    }

    return true
  }

  false
}

///|
fn count_active_survivors(game : @types.Game) -> Int {
  let mut n : Int = 0
  for survivor in game.survivors {
    if survivor.active {
      n = n + 1
    }
  }
  n
}

///|
fn try_toggle_hook(game : @types.Game) -> Bool {
  if game.state != @types.state_play {
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
fn try_repair(game : @types.Game) -> Bool {
  if game.state != @types.state_play {
    return false
  }
  if game.repair_cd > 0.0 {
    return false
  }

  let near_pad : Bool = @types.dist2(
      game.heli_x,
      game.heli_y,
      @types.safe_cx(),
      @types.safe_cy(),
    ) <=
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

  game.fuel = @types.maxf(0.0, game.fuel - 8.0)
  game.hull = @types.minf(100.0, game.hull + 32.0)
  game.repair_cd = 1.1

  game.score = game.score + 14
  set_msg(game, "Repair complete.", 1.1)
  burst(game, game.heli_x, game.heli_y, 24, 2)

  true
}

///|
fn hurt_heli(game : @types.Game, dmg : Float) -> Unit {
  game.hull = game.hull - dmg
  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = @types.maxf(game.shake_t, 0.26)

  if game.hull <= 0.0 {
    game.lives = game.lives - 1
    game.hull = 100.0
    game.fuel = @types.maxf(0.0, game.fuel - 16.0)

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
fn drop_carried_survivor(game : @types.Game) -> Unit {
  if game.carrying_idx < 0 || game.carrying_idx >= game.survivors.length() {
    game.carrying_idx = -1
    return
  }

  let idx : Int = game.carrying_idx
  if game.survivors[idx].active {
    game.survivors[idx].active = false
    game.survivors[idx].carried = false
    game.lost = game.lost + 1
    game.score = @types.maxi(0, game.score - 18)
    set_msg(game, "Passenger lost in storm.", 1.3)
    burst(game, game.survivors[idx].x, game.survivors[idx].y, 22, 1)
  }

  game.carrying_idx = -1
  game.hook_extending = false
  game.hook_target = 46.0
}

///|
fn rescue_carried_survivor(game : @types.Game) -> Unit {
  if game.carrying_idx < 0 || game.carrying_idx >= game.survivors.length() {
    game.carrying_idx = -1
    return
  }

  let idx : Int = game.carrying_idx
  if game.survivors[idx].active {
    game.survivors[idx].active = false
    game.survivors[idx].carried = false

    game.rescued = game.rescued + 1
    game.combo = @types.mini(15, game.combo + 1)
    game.combo_t = 2.3

    let bonus : Int = 24 + game.wave + game.combo * 2
    game.score = game.score + bonus

    if game.score > game.best_score {
      game.best_score = game.score
    }

    set_msg(game, "Civilian delivered +" + bonus.to_string(), 1.1)
    burst(game, @types.safe_cx(), @types.safe_cy(), 28, 2)
  }

  game.carrying_idx = -1
  game.hook_extending = false
  game.hook_target = 46.0
}

///|
fn collect_pickup(
  game : @types.Game,
  kind : Int,
  x : Float,
  y : Float,
) -> Unit {
  if kind == @types.pickup_fuel {
    game.fuel = @types.minf(100.0, game.fuel + 30.0)
    game.score = game.score + 10
    set_msg(game, "Fuel pod collected.", 1.0)
    burst(game, x, y, 18, 0)
  } else if kind == @types.pickup_medkit {
    game.hull = @types.minf(100.0, game.hull + 28.0)
    game.score = game.score + 10
    set_msg(game, "Hull repairs online.", 1.0)
    burst(game, x, y, 18, 2)
  } else {
    game.turbo_t = @types.maxf(game.turbo_t, 7.0)
    game.score = game.score + 16
    set_msg(game, "Turbo rotor boost ready.", 1.0)
    burst(game, x, y, 20, 2)
  }
}

///|
fn update_heli(game : @types.Game, dt : Float) -> Unit {
  let wind_x : Float = @types.sinf(
      game.storm_t * 0.82 + game.heli_y * 0.010,
    ) *
    (52.0 + Float::from_int(game.wave) * 6.0)
  let wind_y : Float = @types.cosf(
      game.storm_t * 0.64 + game.heli_x * 0.008,
    ) *
    26.0

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

  let left : Float = @types.world_left() + @types.heli_r + 8.0
  let right : Float = @types.world_right() - @types.heli_r - 8.0
  let top : Float = @types.world_top() + @types.heli_r + 8.0
  let bottom : Float = @types.world_bottom() - @types.heli_r - 8.0

  if game.heli_x < left {
    game.heli_x = left
    game.heli_vx = @types.absf(game.heli_vx) * 0.24
  } else if game.heli_x > right {
    game.heli_x = right
    game.heli_vx = -@types.absf(game.heli_vx) * 0.24
  }

  if game.heli_y < top {
    game.heli_y = top
    game.heli_vy = @types.absf(game.heli_vy) * 0.24
  } else if game.heli_y > bottom {
    game.heli_y = bottom
    game.heli_vy = -@types.absf(game.heli_vy) * 0.24
  }

  if game.boost_on || game.turbo_t > 0.0 {
    emit_particle(
      game,
      game.heli_x + @types.randf(-8.0, 8.0),
      game.heli_y + @types.randf(14.0, 22.0),
      @types.randf(-40.0, 40.0),
      @types.randf(30.0, 110.0),
      @types.randf(0.18, 0.44),
      @types.randf(1.2, 3.6),
      0,
    )
  }
}

///|
fn update_hook(game : @types.Game, dt : Float) -> Float {
  let old_len : Float = game.hook_len

  if game.hook_extending {
    game.hook_target = 240.0
  } else {
    game.hook_target = 46.0
  }

  if game.hook_len < game.hook_target {
    game.hook_len = @types.minf(
      game.hook_target,
      game.hook_len + dt * 520.0,
    )
  } else {
    game.hook_len = @types.maxf(
      game.hook_target,
      game.hook_len - dt * 580.0,
    )
  }

  let tip_x : Float = @types.hook_tip_x(game)
  let tip_y : Float = @types.hook_tip_y(game)

  if game.carrying_idx < 0 && game.hook_len > 82.0 {
    for i in 0..<game.survivors.length() {
      if not(game.survivors[i].active) || game.survivors[i].carried {
        continue
      }

      let rr : Float = @types.survivor_r + 16.0
      if @types.dist2(tip_x, tip_y, game.survivors[i].x, game.survivors[i].y) <=
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
        (tip_x - game.survivors[idx].x) * @types.minf(1.0, dt * 12.0)
      game.survivors[idx].y = game.survivors[idx].y +
        (tip_y - game.survivors[idx].y) * @types.minf(1.0, dt * 12.0)

      game.survivors[idx].vx = 0.0
      game.survivors[idx].vy = 0.0
      game.survivors[idx].phase = game.survivors[idx].phase + dt * 6.0

      if game.hook_len <= 64.0 &&
        @types.inside_safe_zone(
          game.survivors[idx].x,
          game.survivors[idx].y,
        ) {
        rescue_carried_survivor(game)
      }
    } else {
      game.carrying_idx = -1
    }
  }

  @types.absf(game.hook_len - old_len) / @types.maxf(0.0001, dt)
}

///|
fn update_survivors(game : @types.Game, dt : Float) -> Unit {
  for survivor in game.survivors {
    if not(survivor.active) {
      continue
    }

    if survivor.carried {
      continue
    }

    survivor.phase = survivor.phase + dt * 1.7
    survivor.panic = @types.minf(4.0, survivor.panic + dt * 0.18)

    let drift_x : Float = @types.sinf(survivor.phase * 2.2) *
      (10.0 + survivor.panic * 3.0)
    let drift_y : Float = @types.cosf(survivor.phase * 1.9) *
      (6.0 + survivor.panic * 2.0)

    survivor.vx = survivor.vx * (1.0 - dt * 2.0) + drift_x * dt
    survivor.vy = survivor.vy * (1.0 - dt * 2.0) + drift_y * dt

    survivor.x = survivor.x + survivor.vx * dt
    survivor.y = survivor.y + survivor.vy * dt

    survivor.x = @types.clampf(
      survivor.x,
      @types.world_left() + @types.survivor_r + 10.0,
      @types.world_right() - @types.survivor_r - 10.0,
    )
    survivor.y = @types.clampf(
      survivor.y,
      @types.world_top() + @types.survivor_r + 14.0,
      @types.world_bottom() - @types.survivor_r - 12.0,
    )

    let near_hazard : Bool = false
    ignore(near_hazard)

    if @types.dist2(survivor.x, survivor.y, @types.safe_cx(), @types.safe_cy()) <
      86.0 * 86.0 {
      survivor.panic = @types.maxf(0.0, survivor.panic - dt * 0.5)
    }
  }
}

///|
fn hazard_damage(kind : Int) -> Float {
  if kind == @types.hazard_drone {
    24.0
  } else if kind == @types.hazard_cloud {
    16.0
  } else {
    20.0
  }
}

///|
fn update_hazards(
  game : @types.Game,
  dt : Float,
  hook_speed : Float,
) -> Unit {
  let tip_x : Float = @types.hook_tip_x(game)
  let tip_y : Float = @types.hook_tip_y(game)

  for hazard in game.hazards {
    if not(hazard.active) {
      continue
    }

    hazard.phase = hazard.phase +
      dt * (1.0 + Float::from_int(hazard.kind) * 0.8)

    if hazard.kind == @types.hazard_cloud {
      hazard.vx = hazard.vx +
        @types.sinf(hazard.phase * 1.4) * dt * 80.0
      hazard.vy = hazard.vy + dt * 24.0
    } else if hazard.kind == @types.hazard_drone {
      let tx : Float = if game.carrying_idx >= 0 { tip_x } else { game.heli_x }
      let ty : Float = if game.carrying_idx >= 0 { tip_y } else { game.heli_y }

      let dx : Float = tx - hazard.x
      let dy : Float = ty - hazard.y

      let w : Float = @types.absf(dx) + @types.absf(dy)
      let nx : Float = if w <= 0.001 { 0.0 } else { dx / w }
      let ny : Float = if w <= 0.001 { 0.0 } else { dy / w }

      hazard.vx = hazard.vx * (1.0 - dt * 2.4) + nx * dt * 420.0
      hazard.vy = hazard.vy * (1.0 - dt * 2.4) + ny * dt * 420.0
    } else {
      hazard.vx = hazard.vx +
        @types.sinf(hazard.phase * 3.0) * dt * 96.0
      hazard.vy = hazard.vy + dt * 54.0
    }

    hazard.vx = @types.clampf(hazard.vx, -260.0, 260.0)
    hazard.vy = @types.clampf(hazard.vy, -220.0, 300.0)

    hazard.x = hazard.x + hazard.vx * dt
    hazard.y = hazard.y + hazard.vy * dt

    if hazard.x < @types.world_left() - 120.0 ||
      hazard.x > @types.world_right() + 120.0 ||
      hazard.y < @types.world_top() - 120.0 ||
      hazard.y > @types.world_bottom() + 120.0 {
      hazard.active = false
      continue
    }

    let rr_heli : Float = hazard.r + @types.heli_r - 4.0
    if @types.dist2(hazard.x, hazard.y, game.heli_x, game.heli_y) <=
      rr_heli * rr_heli {
      hurt_heli(game, hazard_damage(hazard.kind))
      hazard.active = false
      if game.state != @types.state_play {
        return
      }
      continue
    }

    if game.carrying_idx >= 0 && game.carrying_idx < game.survivors.length() {
      let idx : Int = game.carrying_idx
      if game.survivors[idx].active {
        let rr_car : Float = hazard.r + @types.survivor_r
        if @types.dist2(
            hazard.x,
            hazard.y,
            game.survivors[idx].x,
            game.survivors[idx].y,
          ) <=
          rr_car * rr_car {
          hazard.active = false
          drop_carried_survivor(game)
          continue
        }
      }
    }

    let rr_hook : Float = hazard.r + 12.0
    if hook_speed > 260.0 &&
      @types.dist2(hazard.x, hazard.y, tip_x, tip_y) <= rr_hook * rr_hook {
      let dmg : Float = if hook_speed > 460.0 { 34.0 } else { 18.0 }
      hazard.hp = hazard.hp - dmg

      burst(game, hazard.x, hazard.y, 14, 0)

      if hazard.hp <= 0.0 {
        hazard.active = false
        game.score = game.score + 8 + game.wave
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

    pickup.phase = pickup.phase + dt * 2.2

    pickup.x = pickup.x +
      (pickup.vx + @types.sinf(pickup.phase * 2.3) * 20.0) * dt
    pickup.y = pickup.y +
      (pickup.vy + Float::from_int(game.wave) * 4.0) * dt

    if pickup.x < @types.world_left() + 16.0 {
      pickup.x = @types.world_left() + 16.0
      pickup.vx = @types.absf(pickup.vx) * 0.6
    }
    if pickup.x > @types.world_right() - 16.0 {
      pickup.x = @types.world_right() - 16.0
      pickup.vx = -@types.absf(pickup.vx) * 0.6
    }

    if pickup.y > @types.world_bottom() + 80.0 {
      pickup.active = false
      continue
    }

    let rr : Float = @types.heli_r + 16.0
    if @types.dist2(game.heli_x, game.heli_y, pickup.x, pickup.y) <= rr * rr {
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

  let mut hx : Float = @types.safe_cx()
  let mut hy : Float = @types.safe_cy()
  let mut msg : String = "Hint: deliver to safe zone."

  if game.carrying_idx >= 0 && game.carrying_idx < game.survivors.length() {
    hx = @types.safe_cx()
    hy = @types.safe_cy()
    msg = "Hint: retract hook inside safe zone."
  } else {
    let mut best_d2 : Float = 1000000000.0

    if game.fuel < 40.0 {
      for pickup in game.pickups {
        if not(pickup.active) || pickup.kind != @types.pickup_fuel {
          continue
        }

        let d2 : Float = @types.dist2(
          game.heli_x,
          game.heli_y,
          pickup.x,
          pickup.y,
        )

        if d2 < best_d2 {
          best_d2 = d2
          hx = pickup.x
          hy = pickup.y
          msg = "Hint: fuel canister marked."
        }
      }
    }

    if best_d2 >= 900000000.0 {
      for survivor in game.survivors {
        if not(survivor.active) || survivor.carried {
          continue
        }

        let d2 : Float = @types.dist2(
          game.heli_x,
          game.heli_y,
          survivor.x,
          survivor.y,
        )

        if d2 < best_d2 {
          best_d2 = d2
          hx = survivor.x
          hy = survivor.y
          msg = "Hint: nearest civilian marked."
        }
      }
    }
  }

  game.hint_x = hx
  game.hint_y = hy
  game.hint_t = 2.8
  game.hint_left = game.hint_left - 1
  game.score = @types.maxi(0, game.score - 5)

  set_msg(game, msg, 1.3)

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
  game.repair_cd = @types.maxf(0.0, game.repair_cd - step)

  update_particles(game, step)

  if game.state != @types.state_play {
    return
  }

  game.game_t = game.game_t + step
  game.storm_t = game.storm_t + step

  if game.rescued >= @types.rescue_target {
    finish_run(game, true)
    return
  }

  if game.game_t >= @types.run_time_goal {
    finish_run(game, false)
    return
  }

  game.wave = @types.clampi(1 + (game.game_t / 24.0).to_int(), 1, 10)

  game.survivor_spawn_t = game.survivor_spawn_t + step
  let spawn_survivor_every : Float = @types.maxf(
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
  let spawn_hazard_every : Float = @types.maxf(
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
  if game.state != @types.state_play {
    return
  }
  update_pickups(game, step)

  let fuel_drain : Float = if game.boost_on || game.turbo_t > 0.0 {
    2.7 + Float::from_int(game.wave) * 0.12
  } else {
    1.2 + Float::from_int(game.wave) * 0.08
  }

  game.fuel = @types.maxf(0.0, game.fuel - fuel_drain * step)

  if game.fuel <= 0.0 {
    game.hull = @types.maxf(0.0, game.hull - step * 7.0)
  }

  if game.hull <= 0.0 {
    hurt_heli(game, 100.0)
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
  // Update mouse/touch state
  game.mouse_x = @raylib.get_mouse_x() |> Float::from_int
  game.mouse_y = @raylib.get_mouse_y() |> Float::from_int
  game.touch_count = @raylib.get_touch_point_count()
  game.mouse_hold = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) ||
    game.touch_count > 0

  // Handle input based on state
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
