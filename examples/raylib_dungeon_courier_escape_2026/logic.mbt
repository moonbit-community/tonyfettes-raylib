///|
fn set_hint(game : Game, text : String, ttl : Float) -> Unit {
  game.hint = text
  game.info_t = ttl
}

///|
fn clear_smokes(game : Game) -> Unit {
  for i = 0; i < game.smokes.length(); i = i + 1 {
    game.smokes[i].active = false
    game.smokes[i].x = 0.0
    game.smokes[i].y = 0.0
    game.smokes[i].radius = smoke_radius_base
    game.smokes[i].life = 0.0
  }
}

///|
fn clear_guards(game : Game) -> Unit {
  for i = 0; i < game.guards.length(); i = i + 1 {
    game.guards[i].active = false
    game.guards[i].x = 0.0
    game.guards[i].y = 0.0
    game.guards[i].vx = 0.0
    game.guards[i].vy = 0.0
    game.guards[i].dir_deg = 0.0
    game.guards[i].patrol_a_x = 0.0
    game.guards[i].patrol_a_y = 0.0
    game.guards[i].patrol_b_x = 0.0
    game.guards[i].patrol_b_y = 0.0
    game.guards[i].to_b = true
    game.guards[i].speed = guard_speed_base
    game.guards[i].cone_range = guard_cone_range_base
    game.guards[i].cone_half_angle = guard_cone_half_angle_base
    game.guards[i].alert_t = 0.0
    game.guards[i].investigate_t = 0.0
    game.guards[i].target_x = 0.0
    game.guards[i].target_y = 0.0
  }
}

///|
fn clear_traps(game : Game) -> Unit {
  for i = 0; i < game.traps.length(); i = i + 1 {
    game.traps[i].active = false
    game.traps[i].x = 0.0
    game.traps[i].y = 0.0
    game.traps[i].radius = 0.0
    game.traps[i].blink_t = 0.0
    game.traps[i].cooldown = 0.0
  }
}

///|
fn clear_parcels(game : Game) -> Unit {
  for i = 0; i < game.parcels.length(); i = i + 1 {
    game.parcels[i].active = false
    game.parcels[i].delivered = false
    game.parcels[i].x = 0.0
    game.parcels[i].y = 0.0
    game.parcels[i].pulse = 0.0
  }
}

///|
fn random_world_point(margin : Float) -> (Float, Float) {
  (
    randf(world_left + margin, world_right - margin),
    randf(world_top + margin, world_bottom - margin),
  )
}

///|
fn far_from_exits(game : Game, x : Float, y : Float, min_dist : Float) -> Bool {
  let min_d2 = min_dist * min_dist
  for i = 0; i < game.exits.length(); i = i + 1 {
    if not(game.exits[i].active) {
      continue
    }
    if dist2(x, y, game.exits[i].x, game.exits[i].y) < min_d2 {
      return false
    }
  }
  true
}

///|
fn far_from_spawn(x : Float, y : Float, min_dist : Float) -> Bool {
  dist2(x, y, player_spawn_x(), player_spawn_y()) >= min_dist * min_dist
}

///|
fn far_from_active_parcels(
  game : Game,
  x : Float,
  y : Float,
  min_dist : Float,
  upto : Int,
) -> Bool {
  let min_d2 = min_dist * min_dist
  for i = 0; i < upto; i = i + 1 {
    if not(game.parcels[i].active) {
      continue
    }
    if dist2(x, y, game.parcels[i].x, game.parcels[i].y) < min_d2 {
      return false
    }
  }
  true
}

///|
fn setup_parcels(game : Game, count : Int) -> Unit {
  clear_parcels(game)

  for i = 0; i < count; i = i + 1 {
    let mut placed = false

    for _attempt = 0; _attempt < 64; _attempt = _attempt + 1 {
      let p = random_world_point(parcel_spawn_margin)
      if not(far_from_exits(game, p.0, p.1, 116.0)) {
        continue
      }
      if not(far_from_spawn(p.0, p.1, 150.0)) {
        continue
      }
      if not(far_from_active_parcels(game, p.0, p.1, 82.0, i)) {
        continue
      }

      game.parcels[i].active = true
      game.parcels[i].delivered = false
      game.parcels[i].x = p.0
      game.parcels[i].y = p.1
      game.parcels[i].pulse = randf(0.0, 6.0)
      placed = true
      break
    }

    if not(placed) {
      let fx = world_left + 130.0 + Float::from_int(i % 4) * 270.0
      let fy = world_top + 140.0 + Float::from_int(i / 4) * 190.0
      game.parcels[i].active = true
      game.parcels[i].delivered = false
      game.parcels[i].x = clampf(fx, world_left + 100.0, world_right - 100.0)
      game.parcels[i].y = clampf(fy, world_top + 100.0, world_bottom - 100.0)
      game.parcels[i].pulse = randf(0.0, 6.0)
    }
  }
}

///|
fn setup_guards(game : Game, wave : Int, count : Int) -> Unit {
  clear_guards(game)

  let wavef = Float::from_int(wave - 1)
  let cone_add = Float::from_int(clampi(wave - 1, 0, 8)) * 1.6

  for i = 0; i < count; i = i + 1 {
    let p0 = random_world_point(guard_spawn_margin)
    let mut p1 = random_world_point(guard_spawn_margin)

    if dist2(p0.0, p0.1, p1.0, p1.1) < 140.0 * 140.0 {
      p1 = (
        clampf(
          p0.0 + randf(-240.0, 240.0),
          world_left + guard_spawn_margin,
          world_right - guard_spawn_margin,
        ),
        clampf(
          p0.1 + randf(-220.0, 220.0),
          world_top + guard_spawn_margin,
          world_bottom - guard_spawn_margin,
        ),
      )
    }

    game.guards[i].active = true
    game.guards[i].x = p0.0
    game.guards[i].y = p0.1
    game.guards[i].vx = 0.0
    game.guards[i].vy = 0.0
    game.guards[i].dir_deg = heading_deg(p1.0 - p0.0, p1.1 - p0.1)
    game.guards[i].patrol_a_x = p0.0
    game.guards[i].patrol_a_y = p0.1
    game.guards[i].patrol_b_x = p1.0
    game.guards[i].patrol_b_y = p1.1
    game.guards[i].to_b = true
    game.guards[i].speed = guard_speed_base +
      wavef * guard_speed_wave_gain +
      randf(-8.0, 8.0)
    game.guards[i].cone_range = guard_cone_range_base +
      wavef * guard_cone_range_wave_gain +
      randf(-18.0, 22.0)
    game.guards[i].cone_half_angle = guard_cone_half_angle_base + cone_add
    game.guards[i].alert_t = 0.0
    game.guards[i].investigate_t = 0.0
    game.guards[i].target_x = p1.0
    game.guards[i].target_y = p1.1
  }
}

///|
fn setup_traps(game : Game, wave : Int, count : Int) -> Unit {
  clear_traps(game)

  for i = 0; i < count; i = i + 1 {
    let mut placed = false

    for _attempt = 0; _attempt < 48; _attempt = _attempt + 1 {
      let p = random_world_point(trap_spawn_margin)
      if not(far_from_exits(game, p.0, p.1, 88.0)) {
        continue
      }
      if not(far_from_spawn(p.0, p.1, 112.0)) {
        continue
      }

      game.traps[i].active = true
      game.traps[i].x = p.0
      game.traps[i].y = p.1
      game.traps[i].radius = trap_radius_base + randf(-3.0, 5.0)
      game.traps[i].blink_t = randf(0.0, 8.0)
      game.traps[i].cooldown = randf(0.0, 0.6)
      placed = true
      break
    }

    if not(placed) {
      game.traps[i].active = true
      game.traps[i].x = world_left + 120.0 + Float::from_int(i % 6) * 200.0
      game.traps[i].y = world_top + 120.0 + Float::from_int(i / 6) * 120.0
      game.traps[i].radius = trap_radius_base
      game.traps[i].blink_t = randf(0.0, 6.0)
      game.traps[i].cooldown = randf(0.0, 0.5)
    }
  }
}

///|
fn setup_wave(game : Game, wave : Int) -> Unit {
  game.state = state_play
  game.wave = wave
  game.delivered_wave = 0
  game.wave_clock = 0.0
  game.alarm_flash = 0.0

  game.player.x = player_spawn_x()
  game.player.y = player_spawn_y()
  game.player.vx = 0.0
  game.player.vy = 0.0
  game.player.facing_deg = -90.0
  game.player.stealth = player_stealth_max
  game.player.carrying_parcel = -1

  game.target_deliveries = clampi(
    wave_target_base + (wave - 1) / 2,
    wave_target_base,
    max_delivery_target,
  )

  let parcel_count = clampi(
    game.target_deliveries + 2,
    game.target_deliveries,
    max_parcels,
  )
  let guard_count = clampi(2 + wave, 2, max_guards)
  let trap_count = clampi(4 + wave * 2, 4, max_traps)

  game.smoke_stock = clampi(
    smoke_stock_base + (wave - 1) / 2,
    smoke_stock_base,
    max_smokes,
  )

  game.time_left = maxf(
    wave_min_time,
    wave_time_base -
    Float::from_int(wave - 1) * wave_time_decay +
    Float::from_int(game.target_deliveries) * 3.2,
  )

  setup_parcels(game, parcel_count)
  setup_guards(game, wave, guard_count)
  setup_traps(game, wave, trap_count)
  clear_smokes(game)

  if wave == 1 {
    set_hint(game, "Collect parcels, then deliver them at glowing exits.", 4.0)
  } else {
    set_hint(game, "Wave \{wave}: more guards and traps are active.", 2.6)
  }
}

///|
fn start_new_run(game : Game) -> Unit {
  game.score = 0
  game.delivered_total = 0
  game.fail_reason = ""
  game.player.health = player_health_max
  setup_wave(game, 1)
}

///|
fn advance_wave(game : Game) -> Unit {
  let time_bonus = (maxf(0.0, game.time_left) * wave_clear_time_score_mult).to_int()
  game.score = game.score +
    wave_clear_score_base +
    game.wave * wave_clear_score_wave_bonus +
    time_bonus

  game.player.health = minf(
    player_health_max,
    game.player.health + wave_clear_health_recover,
  )

  let next_wave = game.wave + 1
  if next_wave > game.best_wave {
    game.best_wave = next_wave
  }

  setup_wave(game, next_wave)
}

///|
fn fail_mission(game : Game, reason : String) -> Unit {
  if game.wave > game.best_wave {
    game.best_wave = game.wave
  }
  game.state = state_retry
  game.fail_reason = reason
  game.player.carrying_parcel = -1
  game.alarm_flash = 0.0
}

///|
fn alloc_smoke_slot(game : Game) -> Int {
  for i = 0; i < game.smokes.length(); i = i + 1 {
    if not(game.smokes[i].active) {
      return i
    }
  }

  let mut oldest = 0
  let mut life = game.smokes[0].life
  for i = 1; i < game.smokes.length(); i = i + 1 {
    if game.smokes[i].life < life {
      life = game.smokes[i].life
      oldest = i
    }
  }

  oldest
}

///|
fn deploy_smoke(game : Game) -> Unit {
  if game.smoke_stock <= 0 {
    set_hint(game, "No smoke decoys left this wave.", 1.2)
    return
  }

  let idx = alloc_smoke_slot(game)
  game.smokes[idx].active = true
  game.smokes[idx].x = game.player.x
  game.smokes[idx].y = game.player.y
  game.smokes[idx].radius = smoke_radius_base +
    Float::from_int(game.wave - 1) * 2.0
  game.smokes[idx].life = smoke_life_secs
  game.smoke_stock = game.smoke_stock - 1

  game.alarm_flash = maxf(game.alarm_flash, 0.25)
  set_hint(game, "Smoke decoy deployed.", 0.9)
}

///|
fn nearest_parcel(game : Game, max_d2 : Float) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i = 0; i < game.parcels.length(); i = i + 1 {
    if not(game.parcels[i].active) || game.parcels[i].delivered {
      continue
    }

    let d2 = dist2(
      game.player.x,
      game.player.y,
      game.parcels[i].x,
      game.parcels[i].y,
    )
    if d2 <= best_d2 {
      best_d2 = d2
      best = i
    }
  }

  best
}

///|
fn nearest_exit(game : Game, max_d2 : Float) -> Int {
  let mut best = -1
  let mut best_d2 = max_d2

  for i = 0; i < game.exits.length(); i = i + 1 {
    if not(game.exits[i].active) {
      continue
    }

    let d2 = dist2(
      game.player.x,
      game.player.y,
      game.exits[i].x,
      game.exits[i].y,
    )
    if d2 <= best_d2 {
      best_d2 = d2
      best = i
    }
  }

  best
}

///|
fn try_interact(game : Game) -> Unit {
  if game.player.carrying_parcel >= 0 {
    let exit_idx = nearest_exit(
      game,
      (interaction_range + exit_radius) * (interaction_range + exit_radius),
    )

    if exit_idx >= 0 {
      let pidx = game.player.carrying_parcel
      if pidx >= 0 &&
        game.parcels[pidx].active &&
        not(game.parcels[pidx].delivered) {
        game.parcels[pidx].active = false
        game.parcels[pidx].delivered = true
        game.player.carrying_parcel = -1
        game.delivered_wave = game.delivered_wave + 1
        game.delivered_total = game.delivered_total + 1
        game.score = game.score + 110 + game.wave * 24
        game.player.stealth = minf(
          player_stealth_max,
          game.player.stealth + 10.0,
        )
        set_hint(
          game,
          "Parcel delivered (\{game.delivered_wave}/\{game.target_deliveries}).",
          1.2,
        )
      }
      return
    }

    let pidx = game.player.carrying_parcel
    if pidx >= 0 {
      let drop_x = clampf(
        game.player.x + cosf(game.player.facing_deg * deg_to_rad) * 24.0,
        world_left + 60.0,
        world_right - 60.0,
      )
      let drop_y = clampf(
        game.player.y + sinf(game.player.facing_deg * deg_to_rad) * 24.0,
        world_top + 60.0,
        world_bottom - 60.0,
      )

      game.parcels[pidx].x = drop_x
      game.parcels[pidx].y = drop_y
      game.player.carrying_parcel = -1
      set_hint(game, "Parcel dropped.", 0.8)
    }
    return
  }

  let parcel_idx = nearest_parcel(game, interaction_range * interaction_range)
  if parcel_idx >= 0 {
    game.player.carrying_parcel = parcel_idx
    set_hint(game, "Parcel picked up. Reach any marked exit.", 1.2)
  } else {
    set_hint(game, "No parcel in reach.", 0.5)
  }
}

///|
fn update_player_motion(game : Game, dt : Float) -> Float {
  let ix = game.input.move_x
  let iy = game.input.move_y
  let moving = ix * ix + iy * iy > 0.0001

  let mut speed = player_base_speed
  if game.player.carrying_parcel >= 0 {
    speed = speed * player_carry_speed_mult
  }

  let mut pressure : Float = 0.0

  if moving && game.input.sprint_hold {
    speed = speed * player_sprint_mult
    pressure = pressure + sprint_noise_pressure
    game.player.stealth = clampf(
      game.player.stealth - sprint_stealth_burn * dt,
      0.0,
      player_stealth_max,
    )
  }

  game.player.vx = ix * speed
  game.player.vy = iy * speed

  game.player.x = game.player.x + game.player.vx * dt
  game.player.y = game.player.y + game.player.vy * dt

  game.player.x = clampf(
    game.player.x,
    world_left + player_radius,
    world_right - player_radius,
  )
  game.player.y = clampf(
    game.player.y,
    world_top + player_radius,
    world_bottom - player_radius,
  )

  if moving {
    game.player.facing_deg = heading_deg(ix, iy)
  }

  if game.player.carrying_parcel >= 0 {
    let pidx = game.player.carrying_parcel
    if pidx >= 0 && game.parcels[pidx].active {
      let follow_x = game.player.x -
        cosf(game.player.facing_deg * deg_to_rad) * 8.0
      let follow_y = game.player.y -
        sinf(game.player.facing_deg * deg_to_rad) * 8.0
      game.parcels[pidx].x = follow_x
      game.parcels[pidx].y = follow_y
    }
  }

  pressure
}

///|
fn update_smokes(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.smokes.length(); i = i + 1 {
    if not(game.smokes[i].active) {
      continue
    }

    game.smokes[i].life = game.smokes[i].life - dt
    if game.smokes[i].life <= 0.0 {
      game.smokes[i].active = false
      game.smokes[i].life = 0.0
    }
  }
}

///|
fn player_smoke_cover(game : Game) -> Float {
  let mut factor : Float = 1.0

  for i = 0; i < game.smokes.length(); i = i + 1 {
    if not(game.smokes[i].active) {
      continue
    }

    if dist2(game.player.x, game.player.y, game.smokes[i].x, game.smokes[i].y) <=
      game.smokes[i].radius * game.smokes[i].radius {
      factor = minf(factor, smoke_cover_factor)
    }
  }

  factor
}

///|
fn nearest_smoke_target(
  game : Game,
  x : Float,
  y : Float,
) -> (Bool, Float, Float, Float) {
  let mut found = false
  let mut best_x : Float = 0.0
  let mut best_y : Float = 0.0
  let mut best_d2 : Float = 0.0

  for i = 0; i < game.smokes.length(); i = i + 1 {
    if not(game.smokes[i].active) {
      continue
    }

    let d2 = dist2(x, y, game.smokes[i].x, game.smokes[i].y)
    if not(found) || d2 < best_d2 {
      found = true
      best_x = game.smokes[i].x
      best_y = game.smokes[i].y
      best_d2 = d2
    }
  }

  (found, best_x, best_y, best_d2)
}

///|
fn alert_all_guards(game : Game, alert_time : Float) -> Unit {
  for i = 0; i < game.guards.length(); i = i + 1 {
    if game.guards[i].active {
      game.guards[i].alert_t = maxf(game.guards[i].alert_t, alert_time)
      game.guards[i].target_x = game.player.x
      game.guards[i].target_y = game.player.y
    }
  }
}

///|
fn update_guards(game : Game, dt : Float) -> Float {
  let mut pressure : Float = 0.0
  let wave_scale : Float = (1.0 : Float) +
    Float::from_int(game.wave - 1) * (0.08 : Float)

  for i = 0; i < game.guards.length(); i = i + 1 {
    if not(game.guards[i].active) {
      continue
    }

    game.guards[i].alert_t = maxf(0.0, game.guards[i].alert_t - dt)
    game.guards[i].investigate_t = maxf(0.0, game.guards[i].investigate_t - dt)

    let smoke = nearest_smoke_target(game, game.guards[i].x, game.guards[i].y)

    let mut tx = if game.guards[i].to_b {
      game.guards[i].patrol_b_x
    } else {
      game.guards[i].patrol_a_x
    }
    let mut ty = if game.guards[i].to_b {
      game.guards[i].patrol_b_y
    } else {
      game.guards[i].patrol_a_y
    }
    let mut move_speed = game.guards[i].speed

    if smoke.0 && smoke.3 <= guard_smoke_lure_range * guard_smoke_lure_range {
      tx = smoke.1
      ty = smoke.2
      move_speed = game.guards[i].speed * 1.2
      game.guards[i].investigate_t = guard_investigate_hold
      game.guards[i].target_x = smoke.1
      game.guards[i].target_y = smoke.2
    } else if game.guards[i].alert_t > 0.0 {
      tx = game.player.x
      ty = game.player.y
      move_speed = game.guards[i].speed * guard_alert_speed_mult
      game.guards[i].target_x = game.player.x
      game.guards[i].target_y = game.player.y
    } else if game.guards[i].investigate_t > 0.0 {
      tx = game.guards[i].target_x
      ty = game.guards[i].target_y
      move_speed = game.guards[i].speed * 1.12
    } else if dist2(game.guards[i].x, game.guards[i].y, tx, ty) <= 18.0 * 18.0 {
      game.guards[i].to_b = not(game.guards[i].to_b)
      tx = if game.guards[i].to_b {
        game.guards[i].patrol_b_x
      } else {
        game.guards[i].patrol_a_x
      }
      ty = if game.guards[i].to_b {
        game.guards[i].patrol_b_y
      } else {
        game.guards[i].patrol_a_y
      }
    }

    let dx = tx - game.guards[i].x
    let dy = ty - game.guards[i].y
    let len2 = dx * dx + dy * dy

    if len2 > 1.0 {
      let inv : Float = (1.0 : Float) / sqrtf(len2)
      game.guards[i].vx = dx * inv * move_speed
      game.guards[i].vy = dy * inv * move_speed
    } else {
      game.guards[i].vx = 0.0
      game.guards[i].vy = 0.0
    }

    game.guards[i].x = game.guards[i].x + game.guards[i].vx * dt
    game.guards[i].y = game.guards[i].y + game.guards[i].vy * dt

    game.guards[i].x = clampf(
      game.guards[i].x,
      world_left + guard_spawn_margin * 0.4,
      world_right - guard_spawn_margin * 0.4,
    )
    game.guards[i].y = clampf(
      game.guards[i].y,
      world_top + guard_spawn_margin * 0.4,
      world_bottom - guard_spawn_margin * 0.4,
    )

    if absf(game.guards[i].vx) + absf(game.guards[i].vy) > 0.1 {
      game.guards[i].dir_deg = heading_deg(game.guards[i].vx, game.guards[i].vy)
    }

    let pdx = game.player.x - game.guards[i].x
    let pdy = game.player.y - game.guards[i].y
    let p_d2 = pdx * pdx + pdy * pdy

    if p_d2 <= game.guards[i].cone_range * game.guards[i].cone_range {
      let p_dist = sqrtf(maxf(p_d2, 0.0001))
      let ang_to_player = heading_deg(pdx, pdy)
      let delta = angle_delta_deg(ang_to_player, game.guards[i].dir_deg)

      if delta <= game.guards[i].cone_half_angle {
        let dist_factor : Float = (1.0 : Float) -
          p_dist / game.guards[i].cone_range
        let ang_factor : Float = (1.0 : Float) -
          delta / game.guards[i].cone_half_angle
        let intensity = clampf(dist_factor * ang_factor, 0.0, 1.0)

        pressure = pressure +
          (guard_detection_base + guard_detection_peak * intensity) * wave_scale

        game.guards[i].alert_t = maxf(
          game.guards[i].alert_t,
          guard_alert_hold + intensity * 0.6,
        )
        game.guards[i].target_x = game.player.x
        game.guards[i].target_y = game.player.y
      }
    }
  }

  pressure
}

///|
fn update_traps(game : Game, dt : Float) -> Float {
  let mut pressure : Float = 0.0

  for i = 0; i < game.traps.length(); i = i + 1 {
    if not(game.traps[i].active) {
      continue
    }

    game.traps[i].blink_t = game.traps[i].blink_t +
      dt * (2.0 + Float::from_int(game.wave) * 0.18)
    game.traps[i].cooldown = maxf(0.0, game.traps[i].cooldown - dt)

    let rr = game.traps[i].radius + player_radius
    if dist2(game.player.x, game.player.y, game.traps[i].x, game.traps[i].y) <=
      rr * rr {
      pressure = pressure + trap_pressure

      if game.traps[i].cooldown <= 0.0 {
        game.traps[i].cooldown = trap_trigger_cooldown

        let damage = trap_damage_base +
          Float::from_int(game.wave - 1) * trap_damage_wave_gain
        game.player.health = game.player.health - damage
        game.player.stealth = maxf(0.0, game.player.stealth - 24.0)

        game.alarm_flash = 1.0
        set_hint(game, "Trap triggered. Guards heard that.", 1.3)
        alert_all_guards(game, 1.0)
      }
    }
  }

  pressure
}

///|
fn update_parcel_pulses(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.parcels.length(); i = i + 1 {
    if not(game.parcels[i].active) {
      continue
    }
    game.parcels[i].pulse = game.parcels[i].pulse + dt * 3.2
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.wave_clock = game.wave_clock + dt
  game.time_left = game.time_left - dt
  game.alarm_flash = maxf(0.0, game.alarm_flash - dt * 1.8)
  game.info_t = maxf(0.0, game.info_t - dt)

  if game.input.smoke_press {
    deploy_smoke(game)
  }

  if game.input.interact_press {
    try_interact(game)
  }

  let mut pressure = update_player_motion(game, dt)
  update_smokes(game, dt)

  pressure = pressure + update_guards(game, dt)
  pressure = pressure + update_traps(game, dt)
  pressure = pressure * player_smoke_cover(game)

  if pressure > 0.1 {
    game.player.stealth = clampf(
      game.player.stealth - pressure * dt,
      0.0,
      player_stealth_max,
    )
    if pressure > 14.0 {
      game.alarm_flash = maxf(game.alarm_flash, 0.45)
    }
  } else {
    game.player.stealth = clampf(
      game.player.stealth + stealth_recovery_per_sec * dt,
      0.0,
      player_stealth_max,
    )
  }

  if game.player.stealth <= 0.0 && pressure > 0.2 {
    game.player.health = game.player.health - stealth_break_damage_per_sec * dt
    game.alarm_flash = maxf(game.alarm_flash, 0.6)
  }

  game.player.health = clampf(game.player.health, 0.0, player_health_max)

  update_parcel_pulses(game, dt)

  if game.player.health <= 0.0 {
    fail_mission(game, "You were overwhelmed by guard pressure.")
    return
  }

  if game.time_left <= 0.0 {
    fail_mission(game, "Courier timer expired.")
    return
  }

  if game.delivered_wave >= game.target_deliveries {
    advance_wave(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  if game.state == state_title {
    if game.input.start_press {
      start_new_run(game)
    }
    return
  }

  if game.state == state_play {
    update_play(game, dt)
    return
  }

  if game.state == state_retry && game.input.retry_press {
    start_new_run(game)
  }
}
