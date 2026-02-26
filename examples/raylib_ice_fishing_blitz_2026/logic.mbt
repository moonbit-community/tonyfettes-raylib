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
fn topf() -> Float {
  Float::from_int(water_top)
}

///|
fn bottomf() -> Float {
  Float::from_int(water_bottom)
}

///|
fn hole_xf() -> Float {
  Float::from_int(hole_x)
}

///|
fn hole_yf() -> Float {
  Float::from_int(hole_y)
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
fn in_catch_zone(x : Float, y : Float) -> Bool {
  x >= Float::from_int(catch_zone_x()) &&
  x <= Float::from_int(catch_zone_x() + catch_zone_w()) &&
  y >= Float::from_int(catch_zone_y()) &&
  y <= Float::from_int(catch_zone_y() + catch_zone_h())
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
  for i = 0; i < game.fish.length(); i = i + 1 {
    game.fish[i].active = false
    game.fish[i].x = 0.0
    game.fish[i].y = 0.0
    game.fish[i].vx = 0.0
    game.fish[i].vy = 0.0
    game.fish[i].r = 0.0
    game.fish[i].value = 0
    game.fish[i].kind = fish_trout
    game.fish[i].phase = 0.0
    game.fish[i].hooked = false
  }

  for i = 0; i < game.hazards.length(); i = i + 1 {
    game.hazards[i].active = false
    game.hazards[i].x = 0.0
    game.hazards[i].y = 0.0
    game.hazards[i].vx = 0.0
    game.hazards[i].vy = 0.0
    game.hazards[i].r = 0.0
    game.hazards[i].dmg = 0.0
    game.hazards[i].kind = hazard_jelly
    game.hazards[i].phase = 0.0
  }

  for i = 0; i < game.pickups.length(); i = i + 1 {
    game.pickups[i].active = false
    game.pickups[i].x = 0.0
    game.pickups[i].y = 0.0
    game.pickups[i].vx = 0.0
    game.pickups[i].vy = 0.0
    game.pickups[i].kind = pickup_bait
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
      randf(-220.0, 220.0),
      randf(-220.0, 140.0),
      randf(0.2, 1.0),
      randf(1.2, 5.6),
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

    let drag : Float = if game.particles[i].kind == 2 { 2.6 } else { 1.9 }
    game.particles[i].vx = game.particles[i].vx * (1.0 - dt * drag)
    game.particles[i].vy = game.particles[i].vy * (1.0 - dt * (drag - 0.4)) +
      dt * (if game.particles[i].kind == 1 { 160.0 } else { 90.0 })
  }
}

///|
fn reset_rig(game : Game) -> Unit {
  game.hook_x = hole_xf()
  game.hook_y = topf() + 70.0
  game.hook_vx = 0.0
  game.hook_vy = 0.0
  game.line_len = 70.0
  game.move_x = 0.0
  game.move_y = 0.0
  game.grab_on = false
  game.carrying_idx = -1
}

///|
fn start_run(game : Game) -> Unit {
  clear_world(game)
  clear_particles(game)

  game.state = state_play

  reset_rig(game)

  game.boost_on = false
  game.lives = 3
  game.line_hp = 100.0
  game.bait = 100.0
  game.turbo_t = 0.0
  game.repair_cd = 0.0

  game.score = 0
  game.caught = 0
  game.escaped = 0
  game.wave = 1
  game.combo = 0
  game.combo_t = 0.0

  game.fish_spawn_t = 0.6
  game.hazard_spawn_t = 0.25
  game.pickup_spawn_t = 1.4

  game.game_t = 0.0
  game.ui_t = 0.0

  game.hint_left = 3
  game.hint_t = 0.0
  game.hint_x = hole_xf()
  game.hint_y = topf() + 160.0

  game.msg = ""
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.touch_cd = 0.0
  game.win = false

  set_msg(game, "Catch fish and reel to top zone.", 2.6)
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
  game.grab_on = false

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if win {
    set_msg(game, "Festival haul complete!", 3.0)
    burst(game, hole_xf(), topf() + 18.0, 64, 2)
  } else {
    set_msg(game, "Ice line snapped. Mission over.", 3.0)
    burst(game, game.hook_x, game.hook_y, 50, 1)
  }
}

///|
fn spawn_fish(game : Game) -> Bool {
  for i = 0; i < game.fish.length(); i = i + 1 {
    if game.fish[i].active {
      continue
    }

    let roll : Int = @raylib.get_random_value(0, 99)
    let kind : Int = if roll < 58 {
      fish_trout
    } else if roll < 90 {
      fish_salmon
    } else {
      fish_gold
    }

    let side : Int = @raylib.get_random_value(0, 1)
    if side == 0 {
      game.fish[i].x = world_left() + 20.0
      game.fish[i].vx = randf(60.0, 130.0)
    } else {
      game.fish[i].x = world_right() - 20.0
      game.fish[i].vx = randf(-130.0, -60.0)
    }

    game.fish[i].y = randf(topf() + 90.0, bottomf() - 40.0)
    game.fish[i].vy = randf(-36.0, 36.0)

    game.fish[i].active = true
    game.fish[i].kind = kind
    game.fish[i].hooked = false
    game.fish[i].phase = randf(0.0, 6.28)

    if kind == fish_trout {
      game.fish[i].r = randf(16.0, 22.0)
      game.fish[i].value = @raylib.get_random_value(22, 35)
    } else if kind == fish_salmon {
      game.fish[i].r = randf(22.0, 28.0)
      game.fish[i].value = @raylib.get_random_value(38, 56)
    } else {
      game.fish[i].r = randf(14.0, 20.0)
      game.fish[i].value = @raylib.get_random_value(70, 110)
    }

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
    let kind : Int = if roll < 46 {
      hazard_jelly
    } else if roll < 78 {
      hazard_eel
    } else {
      hazard_ice
    }

    game.hazards[i].active = true
    game.hazards[i].kind = kind
    game.hazards[i].phase = randf(0.0, 6.28)

    if kind == hazard_jelly {
      game.hazards[i].x = randf(world_left() + 24.0, world_right() - 24.0)
      game.hazards[i].y = topf() + randf(80.0, 180.0)
      game.hazards[i].vx = randf(-44.0, 44.0)
      game.hazards[i].vy = randf(22.0, 80.0)
      game.hazards[i].r = randf(26.0, 36.0)
      game.hazards[i].dmg = randf(7.0, 12.0)
    } else if kind == hazard_eel {
      game.hazards[i].x = randf(world_left() + 30.0, world_right() - 30.0)
      game.hazards[i].y = bottomf() - randf(50.0, 180.0)
      game.hazards[i].vx = randf(-26.0, 26.0)
      game.hazards[i].vy = randf(-22.0, 22.0)
      game.hazards[i].r = randf(18.0, 24.0)
      game.hazards[i].dmg = randf(10.0, 16.0)
    } else {
      game.hazards[i].x = randf(world_left() + 20.0, world_right() - 20.0)
      game.hazards[i].y = topf() + 10.0
      game.hazards[i].vx = randf(-18.0, 18.0)
      game.hazards[i].vy = randf(180.0, 280.0) +
        Float::from_int(game.wave) * 12.0
      game.hazards[i].r = randf(12.0, 18.0)
      game.hazards[i].dmg = randf(14.0, 24.0)
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
    game.pickups[i].x = randf(world_left() + 24.0, world_right() - 24.0)
    game.pickups[i].y = topf() + randf(60.0, 240.0)
    game.pickups[i].vx = randf(-42.0, 42.0)
    game.pickups[i].vy = randf(-16.0, 40.0)
    game.pickups[i].phase = randf(0.0, 6.28)

    let roll : Int = @raylib.get_random_value(0, 99)
    game.pickups[i].kind = if roll < 46 {
      pickup_bait
    } else if roll < 80 {
      pickup_repair
    } else {
      pickup_thermos
    }

    return true
  }

  false
}

///|
fn try_toggle_grab(game : Game) -> Bool {
  if game.state != state_play {
    return false
  }

  game.grab_on = not(game.grab_on)

  if game.grab_on {
    set_msg(game, "Hook clamp ON.", 0.8)
  } else {
    set_msg(game, "Hook clamp OFF.", 0.8)
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

  if game.hook_y > topf() + 86.0 {
    set_msg(game, "Reel up near the ice hole to repair.", 1.0)
    game.repair_cd = 0.22
    return false
  }

  if game.bait < 8.0 {
    set_msg(game, "Not enough bait energy.", 1.0)
    game.repair_cd = 0.22
    return false
  }

  game.bait = maxf(0.0, game.bait - 8.0)
  game.line_hp = minf(100.0, game.line_hp + 30.0)
  game.repair_cd = 1.1

  game.score = game.score + 12
  set_msg(game, "Line repaired.", 1.0)
  burst(game, game.hook_x, game.hook_y, 20, 2)

  true
}

///|
fn drop_carrying_fish(game : Game) -> Unit {
  if game.carrying_idx < 0 || game.carrying_idx >= game.fish.length() {
    game.carrying_idx = -1
    return
  }

  let idx : Int = game.carrying_idx
  if game.fish[idx].active {
    game.fish[idx].hooked = false
    game.fish[idx].vx = randf(-140.0, 140.0)
    game.fish[idx].vy = randf(30.0, 120.0)

    game.escaped = game.escaped + 1
    game.score = maxi(0, game.score - 14)
    set_msg(game, "Fish slipped from hook.", 1.0)
  }

  game.carrying_idx = -1
}

///|
fn land_carrying_fish(game : Game) -> Unit {
  if game.carrying_idx < 0 || game.carrying_idx >= game.fish.length() {
    game.carrying_idx = -1
    return
  }

  let idx : Int = game.carrying_idx
  if not(game.fish[idx].active) {
    game.carrying_idx = -1
    return
  }

  game.fish[idx].active = false
  game.fish[idx].hooked = false

  game.caught = game.caught + 1
  game.combo = mini(20, game.combo + 1)
  game.combo_t = 2.2

  let bonus : Int = game.fish[idx].value + game.combo * 2 + game.wave
  game.score = game.score + bonus
  if game.score > game.best_score {
    game.best_score = game.score
  }

  set_msg(game, "Fish landed +" + bonus.to_string(), 1.1)
  burst(game, hole_xf(), hole_yf() + 20.0, 26, 2)

  game.carrying_idx = -1
}

///|
fn collect_pickup(game : Game, kind : Int, x : Float, y : Float) -> Unit {
  if kind == pickup_bait {
    game.bait = minf(100.0, game.bait + 34.0)
    game.score = game.score + 10
    set_msg(game, "Bait crate collected.", 1.0)
    burst(game, x, y, 16, 0)
  } else if kind == pickup_repair {
    game.line_hp = minf(100.0, game.line_hp + 26.0)
    game.score = game.score + 10
    set_msg(game, "Line reinforced.", 1.0)
    burst(game, x, y, 16, 2)
  } else {
    game.turbo_t = maxf(game.turbo_t, 7.0)
    game.score = game.score + 16
    set_msg(game, "Thermos boost activated.", 1.0)
    burst(game, x, y, 20, 2)
  }
}

///|
fn fish_speed_mul(kind : Int) -> Float {
  if kind == fish_trout {
    1.0
  } else if kind == fish_salmon {
    0.84
  } else {
    1.16
  }
}

///|
fn update_hook(game : Game, dt : Float) -> Unit {
  let boost_mul : Float = if game.boost_on || game.turbo_t > 0.0 {
    1.55
  } else {
    1.0
  }

  let sway_x : Float = sinf(game.ui_t * 1.2 + game.hook_y * 0.008) *
    (22.0 + Float::from_int(game.wave) * 2.4)
  let sway_y : Float = cosf(game.ui_t * 0.86 + game.hook_x * 0.006) * 16.0

  game.hook_vx = game.hook_vx + (game.move_x * 640.0 * boost_mul + sway_x) * dt
  game.hook_vy = game.hook_vy + (game.move_y * 620.0 * boost_mul + sway_y) * dt

  game.hook_vx = game.hook_vx * (1.0 - dt * 3.0)
  game.hook_vy = game.hook_vy * (1.0 - dt * 3.0)

  game.hook_x = game.hook_x + game.hook_vx * dt
  game.hook_y = game.hook_y + game.hook_vy * dt

  game.hook_x = clampf(game.hook_x, world_left() + 18.0, world_right() - 18.0)
  game.hook_y = clampf(game.hook_y, topf() + 20.0, bottomf() - 12.0)

  let line_raw : Float = absf(game.hook_y - hole_yf()) +
    absf(game.hook_x - hole_xf()) * 0.22
  game.line_len = clampf(line_raw, min_line_len, max_line_len)

  if line_raw > max_line_len + 6.0 {
    let bias_x : Float = (hole_xf() - game.hook_x) * dt * 8.0
    let bias_y : Float = (hole_yf() + max_line_len - game.hook_y) * dt * 8.0
    game.hook_x = game.hook_x + bias_x
    game.hook_y = game.hook_y + bias_y
  }

  if game.boost_on || game.turbo_t > 0.0 {
    emit_particle(
      game,
      game.hook_x + randf(-6.0, 6.0),
      game.hook_y + randf(-6.0, 6.0),
      randf(-40.0, 40.0),
      randf(30.0, 100.0),
      randf(0.18, 0.44),
      randf(1.1, 3.0),
      0,
    )
  }
}

///|
fn update_fish(game : Game, dt : Float) -> Unit {
  let mut active_count : Int = 0

  for i = 0; i < game.fish.length(); i = i + 1 {
    if not(game.fish[i].active) {
      continue
    }

    active_count = active_count + 1

    if game.fish[i].hooked {
      game.fish[i].x = game.fish[i].x +
        (game.hook_x - game.fish[i].x) * minf(1.0, dt * 12.0)
      game.fish[i].y = game.fish[i].y +
        (game.hook_y + 16.0 - game.fish[i].y) * minf(1.0, dt * 12.0)
      game.fish[i].phase = game.fish[i].phase + dt * 8.0

      if in_catch_zone(game.fish[i].x, game.fish[i].y) &&
        game.hook_y <= topf() + 72.0 {
        land_carrying_fish(game)
      }

      continue
    }

    game.fish[i].phase = game.fish[i].phase +
      dt * (1.6 + Float::from_int(game.fish[i].kind) * 0.7)

    let sw_x : Float = sinf(game.fish[i].phase * 1.8) *
      40.0 *
      fish_speed_mul(game.fish[i].kind)
    let sw_y : Float = cosf(game.fish[i].phase * 1.4) *
      22.0 *
      fish_speed_mul(game.fish[i].kind)

    game.fish[i].vx = game.fish[i].vx * (1.0 - dt * 1.8) + sw_x * dt
    game.fish[i].vy = game.fish[i].vy * (1.0 - dt * 1.8) + sw_y * dt

    game.fish[i].x = game.fish[i].x + game.fish[i].vx * dt
    game.fish[i].y = game.fish[i].y + game.fish[i].vy * dt

    if game.fish[i].x < world_left() + game.fish[i].r {
      game.fish[i].x = world_left() + game.fish[i].r
      game.fish[i].vx = absf(game.fish[i].vx) * 0.8
    }
    if game.fish[i].x > world_right() - game.fish[i].r {
      game.fish[i].x = world_right() - game.fish[i].r
      game.fish[i].vx = -absf(game.fish[i].vx) * 0.8
    }

    if game.fish[i].y < topf() + game.fish[i].r + 20.0 {
      game.fish[i].y = topf() + game.fish[i].r + 20.0
      game.fish[i].vy = absf(game.fish[i].vy) * 0.8
    }
    if game.fish[i].y > bottomf() - game.fish[i].r - 8.0 {
      game.fish[i].y = bottomf() - game.fish[i].r - 8.0
      game.fish[i].vy = -absf(game.fish[i].vy) * 0.8
    }

    let rr : Float = game.fish[i].r + hook_r + 8.0
    if game.grab_on &&
      game.carrying_idx < 0 &&
      dist2(game.fish[i].x, game.fish[i].y, game.hook_x, game.hook_y) <= rr * rr {
      game.fish[i].hooked = true
      game.carrying_idx = i
      game.grab_on = false
      set_msg(game, "Fish hooked. Reel it up!", 1.1)
      burst(game, game.hook_x, game.hook_y, 14, 2)
      continue
    }

    if game.fish[i].kind == fish_gold && @raylib.get_random_value(0, 999) < 2 {
      game.fish[i].active = false
      game.escaped = game.escaped + 1
    }
  }

  ignore(active_count)
}

///|
fn update_hazards(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    if not(game.hazards[i].active) {
      continue
    }

    game.hazards[i].phase = game.hazards[i].phase +
      dt * (1.1 + Float::from_int(game.hazards[i].kind) * 0.9)

    if game.hazards[i].kind == hazard_jelly {
      game.hazards[i].vx = game.hazards[i].vx +
        sinf(game.hazards[i].phase * 1.7) * dt * 72.0
      game.hazards[i].vy = game.hazards[i].vy +
        cosf(game.hazards[i].phase * 1.3) * dt * 24.0
    } else if game.hazards[i].kind == hazard_eel {
      let dx : Float = game.hook_x - game.hazards[i].x
      let dy : Float = game.hook_y - game.hazards[i].y
      let d : Float = absf(dx) + absf(dy)
      let nx : Float = if d <= 0.001 { 0.0 } else { dx / d }
      let ny : Float = if d <= 0.001 { 0.0 } else { dy / d }

      game.hazards[i].vx = game.hazards[i].vx * (1.0 - dt * 2.2) +
        nx * dt * 300.0
      game.hazards[i].vy = game.hazards[i].vy * (1.0 - dt * 2.2) +
        ny * dt * 300.0
    } else {
      game.hazards[i].vx = game.hazards[i].vx +
        sinf(game.hazards[i].phase * 2.5) * dt * 66.0
      game.hazards[i].vy = game.hazards[i].vy + dt * 44.0
    }

    game.hazards[i].vx = clampf(game.hazards[i].vx, -220.0, 220.0)
    game.hazards[i].vy = clampf(game.hazards[i].vy, -220.0, 280.0)

    game.hazards[i].x = game.hazards[i].x + game.hazards[i].vx * dt
    game.hazards[i].y = game.hazards[i].y + game.hazards[i].vy * dt

    if game.hazards[i].kind == hazard_ice &&
      game.hazards[i].y > bottomf() + 30.0 {
      game.hazards[i].active = false
      continue
    }

    if game.hazards[i].x < world_left() - 60.0 ||
      game.hazards[i].x > world_right() + 60.0 ||
      game.hazards[i].y < topf() - 60.0 ||
      game.hazards[i].y > bottomf() + 80.0 {
      game.hazards[i].active = false
      continue
    }

    let rr : Float = game.hazards[i].r + hook_r
    if dist2(game.hazards[i].x, game.hazards[i].y, game.hook_x, game.hook_y) <=
      rr * rr {
      game.line_hp = maxf(0.0, game.line_hp - game.hazards[i].dmg)
      game.shake_t = maxf(game.shake_t, 0.22)

      burst(game, game.hook_x, game.hook_y, 12, 1)

      if game.hazards[i].kind == hazard_ice {
        game.hazards[i].active = false
      } else {
        game.hazards[i].vx = -game.hazards[i].vx * 0.6
        game.hazards[i].vy = -game.hazards[i].vy * 0.6
      }

      if game.carrying_idx >= 0 && @raylib.get_random_value(0, 99) < 34 {
        drop_carrying_fish(game)
      }

      if game.line_hp <= 0.0 {
        return
      }
    }

    if game.hazards[i].kind == hazard_eel &&
      game.carrying_idx >= 0 &&
      game.carrying_idx < game.fish.length() {
      let idx : Int = game.carrying_idx
      if game.fish[idx].active {
        let r2 : Float = game.hazards[i].r + game.fish[idx].r
        if dist2(
            game.hazards[i].x,
            game.hazards[i].y,
            game.fish[idx].x,
            game.fish[idx].y,
          ) <=
          r2 * r2 {
          game.hazards[i].active = false
          drop_carrying_fish(game)
        }
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

    game.pickups[i].phase = game.pickups[i].phase + dt * 2.3

    game.pickups[i].x = game.pickups[i].x +
      (game.pickups[i].vx + sinf(game.pickups[i].phase * 2.0) * 20.0) * dt
    game.pickups[i].y = game.pickups[i].y +
      (game.pickups[i].vy + cosf(game.pickups[i].phase * 1.3) * 18.0) * dt

    if game.pickups[i].x < world_left() + 16.0 {
      game.pickups[i].x = world_left() + 16.0
      game.pickups[i].vx = absf(game.pickups[i].vx) * 0.6
    }
    if game.pickups[i].x > world_right() - 16.0 {
      game.pickups[i].x = world_right() - 16.0
      game.pickups[i].vx = -absf(game.pickups[i].vx) * 0.6
    }

    if game.pickups[i].y < topf() + 20.0 {
      game.pickups[i].y = topf() + 20.0
      game.pickups[i].vy = absf(game.pickups[i].vy) * 0.6
    }
    if game.pickups[i].y > bottomf() - 16.0 {
      game.pickups[i].y = bottomf() - 16.0
      game.pickups[i].vy = -absf(game.pickups[i].vy) * 0.6
    }

    let rr : Float = hook_r + 16.0
    if dist2(game.hook_x, game.hook_y, game.pickups[i].x, game.pickups[i].y) <=
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

  let mut hx : Float = hole_xf()
  let mut hy : Float = topf() + 120.0
  let mut text : String = "Hint: reel to catch zone."

  if game.carrying_idx >= 0 {
    hx = hole_xf()
    hy = topf() + 40.0
    text = "Hint: bring hooked fish up."
  } else if game.bait < 40.0 {
    let mut best_d2 : Float = 1000000000.0
    for i = 0; i < game.pickups.length(); i = i + 1 {
      if not(game.pickups[i].active) || game.pickups[i].kind != pickup_bait {
        continue
      }

      let d2 : Float = dist2(
        game.hook_x,
        game.hook_y,
        game.pickups[i].x,
        game.pickups[i].y,
      )

      if d2 < best_d2 {
        best_d2 = d2
        hx = game.pickups[i].x
        hy = game.pickups[i].y
        text = "Hint: bait crate marked."
      }
    }
  } else {
    let mut best_score : Int = -1
    let mut best_d2 : Float = 1000000000.0

    for i = 0; i < game.fish.length(); i = i + 1 {
      if not(game.fish[i].active) || game.fish[i].hooked {
        continue
      }

      let d2 : Float = dist2(
        game.hook_x,
        game.hook_y,
        game.fish[i].x,
        game.fish[i].y,
      )

      if game.fish[i].value > best_score ||
        (game.fish[i].value == best_score && d2 < best_d2) {
        best_score = game.fish[i].value
        best_d2 = d2
        hx = game.fish[i].x
        hy = game.fish[i].y
        text = "Hint: high-value fish marked."
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
  game.repair_cd = maxf(0.0, game.repair_cd - step)

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

  game.wave = clampi(1 + (game.game_t / 22.0).to_int(), 1, 10)

  game.fish_spawn_t = game.fish_spawn_t + step
  let fish_interval : Float = maxf(
    0.24,
    0.90 - Float::from_int(game.wave) * 0.05,
  )
  while game.fish_spawn_t >= fish_interval {
    game.fish_spawn_t = game.fish_spawn_t - fish_interval
    ignore(spawn_fish(game))
  }

  game.hazard_spawn_t = game.hazard_spawn_t + step
  let hazard_interval : Float = maxf(
    0.34,
    0.98 - Float::from_int(game.wave) * 0.06,
  )
  while game.hazard_spawn_t >= hazard_interval {
    game.hazard_spawn_t = game.hazard_spawn_t - hazard_interval
    ignore(spawn_hazard(game))
  }

  game.pickup_spawn_t = game.pickup_spawn_t + step
  if game.pickup_spawn_t >= 3.1 {
    game.pickup_spawn_t = 0.0
    ignore(spawn_pickup(game))
  }

  update_hook(game, step)
  update_fish(game, step)
  update_hazards(game, step)
  if game.line_hp <= 0.0 {
    game.lives = game.lives - 1
    game.line_hp = 100.0
    game.bait = maxf(0.0, game.bait - 14.0)

    drop_carrying_fish(game)
    reset_rig(game)

    set_msg(game, "Line snapped. Life lost.", 1.4)
    burst(game, hole_xf(), topf() + 30.0, 30, 1)

    if game.lives <= 0 {
      finish_run(game, false)
      return
    }
  }

  update_pickups(game, step)

  let drain : Float = if game.boost_on || game.turbo_t > 0.0 {
    2.5 + Float::from_int(game.wave) * 0.10
  } else {
    1.0 + Float::from_int(game.wave) * 0.07
  }

  game.bait = maxf(0.0, game.bait - drain * step)

  if game.bait <= 0.0 {
    game.line_hp = maxf(0.0, game.line_hp - step * 6.0)
  }

  if game.score > game.best_score {
    game.best_score = game.score
  }
}
