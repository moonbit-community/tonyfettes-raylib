///|
fn set_message(game : Game, msg : String, ttl : Float) -> Unit {
  game.message = msg
  game.message_t = ttl
}

///|
fn clear_raiders(game : Game) -> Unit {
  for i = 0; i < game.raiders.length(); i = i + 1 {
    game.raiders[i].active = false
    game.raiders[i].kind = raider_skirmisher
    game.raiders[i].x = 0.0
    game.raiders[i].y = 0.0
    game.raiders[i].vx = 0.0
    game.raiders[i].vy = 0.0
    game.raiders[i].speed = 0.0
    game.raiders[i].hp = 0.0
    game.raiders[i].target_wagon = 0
    game.raiders[i].lane = 0
    game.raiders[i].attack_cd = 0.0
    game.raiders[i].flash_t = 0.0
    game.raiders[i].radius = 16.0
  }
}

///|
fn clear_bullets(game : Game) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    game.bullets[i].active = false
    game.bullets[i].x = 0.0
    game.bullets[i].y = 0.0
    game.bullets[i].vx = 0.0
    game.bullets[i].vy = 0.0
    game.bullets[i].life = 0.0
    game.bullets[i].dmg = 0.0
  }
}

///|
fn clear_dust(game : Game) -> Unit {
  for i = 0; i < game.dusts.length(); i = i + 1 {
    game.dusts[i].active = false
    game.dusts[i].x = 0.0
    game.dusts[i].y = 0.0
    game.dusts[i].vx = 0.0
    game.dusts[i].vy = 0.0
    game.dusts[i].life = 0.0
    game.dusts[i].size = 0.0
    game.dusts[i].kind = 0
  }
}

///|
fn reset_wagons(game : Game) -> Unit {
  for i = 0; i < game.wagons.length(); i = i + 1 {
    game.wagons[i].x = wagon_slot_x(i)
    game.wagons[i].y = wagon_slot_y(i)
    game.wagons[i].hp = game.wagons[i].max_hp
    game.wagons[i].repair_cd = 0.0
  }
}

///|
fn reset_hero(hero : Player) -> Unit {
  hero.x = caravan_center_x - perimeter_outer_rx * 0.9
  hero.y = caravan_center_y
  hero.vx = 0.0
  hero.vy = 0.0
  hero.facing_x = 1.0
  hero.facing_y = 0.0
  hero.roll_t = 0.0
  hero.roll_cd = 0.0
  hero.roll_dx = 1.0
  hero.roll_dy = 0.0
  hero.shoot_cd = 0.0
  hero.invuln_t = 0.0
  hero.repair_t = 0.0
}

///|
fn start_run(game : Game) -> Unit {
  clear_raiders(game)
  clear_bullets(game)
  clear_dust(game)
  reset_wagons(game)
  reset_hero(game.hero)

  game.state = state_play
  game.score = 0
  game.kills = 0
  game.checkpoint = 0
  game.distance = 0.0
  game.checkpoint_start = 0.0
  game.next_checkpoint = checkpoint_span(0)
  game.morale = 76.0
  game.ammo = 26
  game.ammo_regen_t = ammo_regen_base
  game.repair_kits = 3
  game.spawn_t = 0.4
  game.time_s = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  set_message(game, "Escort in motion", 1.2)
}

///|
fn alloc_raider(game : Game) -> Int {
  for i = 0; i < game.raiders.length(); i = i + 1 {
    if not(game.raiders[i].active) {
      return i
    }
  }

  let mut oldest = 0
  let mut best_x = game.raiders[0].x
  for i = 1; i < game.raiders.length(); i = i + 1 {
    if game.raiders[i].x < best_x {
      best_x = game.raiders[i].x
      oldest = i
    }
  }
  oldest
}

///|
fn alloc_bullet(game : Game) -> Int {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      return i
    }
  }

  let mut oldest = 0
  let mut best_life = game.bullets[0].life
  for i = 1; i < game.bullets.length(); i = i + 1 {
    if game.bullets[i].life < best_life {
      best_life = game.bullets[i].life
      oldest = i
    }
  }
  oldest
}

///|
fn alloc_dust(game : Game) -> Int {
  for i = 0; i < game.dusts.length(); i = i + 1 {
    if not(game.dusts[i].active) {
      return i
    }
  }
  randi(0, game.dusts.length() - 1)
}

///|
fn emit_dust(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : Int,
) -> Unit {
  let i = alloc_dust(game)
  game.dusts[i].active = true
  game.dusts[i].x = x
  game.dusts[i].y = y
  game.dusts[i].vx = vx
  game.dusts[i].vy = vy
  game.dusts[i].life = life
  game.dusts[i].size = size
  game.dusts[i].kind = kind
}

///|
fn burst_dust(
  game : Game,
  x : Float,
  y : Float,
  count : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < count; _i = _i + 1 {
    emit_dust(
      game,
      x + randf(-16.0, 16.0),
      y + randf(-16.0, 16.0),
      randf(-240.0, 240.0),
      randf(-220.0, 220.0),
      randf(0.2, 0.9),
      randf(1.5, 4.8),
      kind,
    )
  }
}

///|
fn lane_y(game : Game, index : Int) -> Float {
  let i = clampi(index, 0, lane_count - 1)
  let fi = Float::from_int(i)
  let base = lane_base_y(i)
  let wave = sinf(
    game.time_s * (0.92 + fi * 0.12) + fi * 1.3 + game.distance * 0.008,
  )
  let sway = cosf(
    game.time_s * (0.46 + fi * 0.06) + fi * 0.8 + game.distance * 0.003,
  )
  base + wave * 26.0 + sway * 12.0
}

///|
fn active_raider_count(game : Game) -> Int {
  let mut c = 0
  for i = 0; i < game.raiders.length(); i = i + 1 {
    if game.raiders[i].active {
      c = c + 1
    }
  }
  c
}

///|
fn checkpoint_progress(game : Game) -> Float {
  if game.state == state_victory {
    1.0
  } else {
    let span = maxf(1.0, game.next_checkpoint - game.checkpoint_start)
    clamp01((game.distance - game.checkpoint_start) / span)
  }
}

///|
fn nearest_raider_index(
  game : Game,
  x : Float,
  y : Float,
  max_dist2 : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = max_dist2
  for i = 0; i < game.raiders.length(); i = i + 1 {
    if not(game.raiders[i].active) {
      continue
    }
    let d2 = dist2(x, y, game.raiders[i].x, game.raiders[i].y)
    if d2 < best_d2 {
      best_d2 = d2
      best = i
    }
  }
  best
}

///|
fn nearest_wagon_index(
  game : Game,
  x : Float,
  y : Float,
  only_alive : Bool,
) -> Int {
  let mut best = -1
  let mut best_d2 : Float = 99999999.0
  for i = 0; i < game.wagons.length(); i = i + 1 {
    if only_alive && game.wagons[i].hp <= 0.0 {
      continue
    }

    let d2 = dist2(x, y, game.wagons[i].x, game.wagons[i].y)
    if d2 < best_d2 {
      best_d2 = d2
      best = i
    }
  }
  best
}

///|
fn all_wagons_broken(game : Game) -> Bool {
  for i = 0; i < game.wagons.length(); i = i + 1 {
    if game.wagons[i].hp > 0.0 {
      return false
    }
  }
  true
}

///|
fn update_wagons(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.wagons.length(); i = i + 1 {
    if game.wagons[i].repair_cd > 0.0 {
      game.wagons[i].repair_cd = maxf(0.0, game.wagons[i].repair_cd - dt)
    }

    let fi = Float::from_int(i)
    game.wagons[i].x = wagon_slot_x(i) +
      sinf(game.time_s * 1.1 + fi * 0.9 + game.distance * 0.005) * 8.0
    game.wagons[i].y = wagon_slot_y(i) +
      cosf(game.time_s * 1.4 + fi * 0.6) * 6.0
  }
}

///|
fn heal_wagon(game : Game, index : Int, value : Float) -> Unit {
  if index < 0 || index >= game.wagons.length() {
    return
  }

  game.wagons[index].hp = minf(
    game.wagons[index].max_hp,
    game.wagons[index].hp + maxf(value, 0.0),
  )
}

///|
fn damage_wagon(game : Game, index : Int, value : Float) -> Unit {
  if index < 0 || index >= game.wagons.length() {
    return
  }

  if game.wagons[index].hp <= 0.0 {
    return
  }

  game.wagons[index].hp = maxf(0.0, game.wagons[index].hp - value)
  game.morale = clampf(game.morale - value * 0.24, 0.0, morale_max)
  game.flash_t = maxf(game.flash_t, 0.2)
  game.shake_t = maxf(game.shake_t, 0.14)

  if game.wagons[index].hp <= 0.0 {
    game.score = maxi(0, game.score - 40)
    game.morale = clampf(game.morale - 10.0, 0.0, morale_max)
    set_message(game, "A wagon is broken!", 1.1)
  }
}

///|
fn kill_raider(game : Game, index : Int, score_gain : Int) -> Unit {
  if index < 0 || index >= game.raiders.length() {
    return
  }

  if not(game.raiders[index].active) {
    return
  }

  let x = game.raiders[index].x
  let y = game.raiders[index].y
  burst_dust(game, x, y, 12, 1)

  game.raiders[index].active = false
  game.kills = game.kills + 1
  game.score = game.score + score_gain + game.checkpoint * 3
  game.morale = clampf(game.morale + morale_kill_gain, 0.0, morale_max)

  if chance(22) {
    game.ammo = clampi(game.ammo + 1, 0, ammo_max)
  }

  if chance(9) {
    game.repair_kits = clampi(game.repair_kits + 1, 0, kit_max)
    set_message(game, "Raider dropped a repair kit", 0.9)
  }
}

///|
fn choose_raider_kind(game : Game) -> Int {
  let roll = randi(0, 99)

  if game.checkpoint >= 3 {
    if roll < 34 {
      raider_brute
    } else if roll < 72 {
      raider_rider
    } else {
      raider_skirmisher
    }
  } else if game.checkpoint >= 2 {
    if roll < 28 {
      raider_brute
    } else if roll < 56 {
      raider_rider
    } else {
      raider_skirmisher
    }
  } else if game.checkpoint >= 1 {
    if roll < 20 {
      raider_brute
    } else if roll < 42 {
      raider_rider
    } else {
      raider_skirmisher
    }
  } else if roll < 15 {
    raider_brute
  } else {
    raider_skirmisher
  }
}

///|
fn choose_target_wagon(game : Game, x : Float, y : Float) -> Int {
  let target = nearest_wagon_index(game, x, y, true)
  if target >= 0 {
    target
  } else {
    randi(0, wagon_count - 1)
  }
}

///|
fn spawn_raider(game : Game, lane : Int, kind : Int) -> Unit {
  let i = alloc_raider(game)
  let x = Float::from_int(screen_w) + randf(60.0, 160.0)
  let y = lane_y(game, lane) + randf(-20.0, 20.0)

  game.raiders[i].active = true
  game.raiders[i].kind = kind
  game.raiders[i].x = x
  game.raiders[i].y = y
  game.raiders[i].vx = randf(-30.0, 20.0)
  game.raiders[i].vy = randf(-20.0, 20.0)
  game.raiders[i].target_wagon = choose_target_wagon(game, x, y)
  game.raiders[i].lane = clampi(lane, 0, lane_count - 1)
  game.raiders[i].attack_cd = randf(0.24, 0.68)
  game.raiders[i].flash_t = 0.0

  if kind == raider_brute {
    game.raiders[i].speed = randf(76.0, 96.0) +
      Float::from_int(game.checkpoint) * 6.0
    game.raiders[i].hp = randf(84.0, 108.0)
    game.raiders[i].radius = 22.0
  } else if kind == raider_rider {
    game.raiders[i].speed = randf(132.0, 162.0) +
      Float::from_int(game.checkpoint) * 8.0
    game.raiders[i].hp = randf(52.0, 72.0)
    game.raiders[i].radius = 14.0
  } else {
    game.raiders[i].speed = randf(102.0, 128.0) +
      Float::from_int(game.checkpoint) * 7.0
    game.raiders[i].hp = randf(46.0, 62.0)
    game.raiders[i].radius = 16.0
  }
}

///|
fn spawn_wave(game : Game) -> Unit {
  let mut count = 1
  if game.checkpoint >= 2 {
    count = 2
  }
  if chance(14 + game.checkpoint * 11) {
    count = count + 1
  }

  for _i = 0; _i < count; _i = _i + 1 {
    let lane = randi(0, lane_count - 1)
    spawn_raider(game, lane, choose_raider_kind(game))
  }
}

///|
fn update_spawner(game : Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  if game.spawn_t > 0.0 {
    return
  }

  spawn_wave(game)

  let pressure = Float::from_int(game.checkpoint) * 0.25 +
    game.distance * 0.00013
  let mut next = spawn_interval_base - pressure
  next = clampf(next, spawn_interval_min, spawn_interval_base)
  game.spawn_t = next + randf(-0.08, 0.2)
}

///|
fn spawn_bullet(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  dmg : Float,
) -> Unit {
  let i = alloc_bullet(game)
  game.bullets[i].active = true
  game.bullets[i].x = x
  game.bullets[i].y = y
  game.bullets[i].vx = vx
  game.bullets[i].vy = vy
  game.bullets[i].life = bullet_life
  game.bullets[i].dmg = dmg
}

///|
fn try_shoot(game : Game) -> Unit {
  if not(game.input_shoot_hold) {
    return
  }

  if game.hero.shoot_cd > 0.0 {
    return
  }

  if game.ammo <= 0 {
    game.hero.shoot_cd = 0.15
    if game.message_t <= 0.0 {
      set_message(game, "Out of ammo", 0.55)
    }
    return
  }

  let mut dx = game.hero.facing_x
  let mut dy = game.hero.facing_y

  let target = nearest_raider_index(
    game,
    game.hero.x,
    game.hero.y,
    950.0 * 950.0,
  )
  if target >= 0 {
    dx = game.raiders[target].x - game.hero.x
    dy = game.raiders[target].y - game.hero.y
  }

  let len = sqrtf(dx * dx + dy * dy)
  if len < 0.001 {
    dx = 1.0
    dy = 0.0
  } else {
    dx = dx / len
    dy = dy / len
  }

  spawn_bullet(
    game,
    game.hero.x + dx * (player_radius + 7.0),
    game.hero.y + dy * (player_radius + 7.0),
    dx * bullet_speed,
    dy * bullet_speed,
    bullet_dmg,
  )

  game.hero.shoot_cd = shoot_cd
  game.ammo = game.ammo - 1
  emit_dust(
    game,
    game.hero.x + dx * 10.0,
    game.hero.y + dy * 10.0,
    dx * 120.0 + randf(-70.0, 70.0),
    dy * 120.0 + randf(-70.0, 70.0),
    0.25,
    3.2,
    2,
  )
}

///|
fn try_repair(game : Game) -> Unit {
  if not(game.input_repair_press) {
    return
  }

  let mut target = -1
  let mut best_d2 = repair_range * repair_range

  for i = 0; i < game.wagons.length(); i = i + 1 {
    if game.wagons[i].hp >= game.wagons[i].max_hp {
      continue
    }

    let d2 = dist2(game.hero.x, game.hero.y, game.wagons[i].x, game.wagons[i].y)
    if d2 < best_d2 {
      best_d2 = d2
      target = i
    }
  }

  if target < 0 {
    set_message(game, "No damaged wagon nearby", 0.6)
    return
  }

  if game.repair_kits <= 0 {
    set_message(game, "No repair kits", 0.7)
    return
  }

  if game.wagons[target].repair_cd > 0.0 {
    set_message(game, "Repair cooling down", 0.55)
    return
  }

  game.repair_kits = game.repair_kits - 1
  heal_wagon(game, target, repair_heal)
  game.wagons[target].repair_cd = repair_cd
  game.hero.repair_t = 0.26
  game.morale = clampf(game.morale + 7.5, 0.0, morale_max)
  game.score = game.score + 22
  set_message(game, "Wagon repaired", 0.8)
  burst_dust(game, game.wagons[target].x, game.wagons[target].y, 16, 3)
}

///|
fn clamp_hero_ring(hero : Player) -> Unit {
  let mut dx = hero.x - caravan_center_x
  let mut dy = hero.y - caravan_center_y

  if absf(dx) < 0.001 && absf(dy) < 0.001 {
    dx = perimeter_outer_rx
  }

  let outer = ellipse_norm(dx, dy, perimeter_outer_rx, perimeter_outer_ry)
  if outer > 1.0 {
    dx = dx / outer
    dy = dy / outer
  }

  let inner = ellipse_norm(dx, dy, perimeter_inner_rx, perimeter_inner_ry)
  if inner < 1.0 {
    let scale : Float = 1.0 / maxf(inner, 0.0001)
    dx = dx * scale
    dy = dy * scale
  }

  hero.x = caravan_center_x + dx
  hero.y = caravan_center_y + dy
}

///|
fn update_hero(game : Game, dt : Float) -> Unit {
  game.hero.shoot_cd = maxf(0.0, game.hero.shoot_cd - dt)
  game.hero.roll_cd = maxf(0.0, game.hero.roll_cd - dt)
  game.hero.invuln_t = maxf(0.0, game.hero.invuln_t - dt)
  game.hero.repair_t = maxf(0.0, game.hero.repair_t - dt)

  if game.input_roll_press && game.hero.roll_cd <= 0.0 {
    let mut dx = game.input_x
    let mut dy = game.input_y

    if absf(dx) + absf(dy) < 0.01 {
      dx = game.hero.facing_x
      dy = game.hero.facing_y
    }

    let len = sqrtf(dx * dx + dy * dy)
    if len < 0.001 {
      dx = 1.0
      dy = 0.0
    } else {
      dx = dx / len
      dy = dy / len
    }

    game.hero.roll_dx = dx
    game.hero.roll_dy = dy
    game.hero.roll_t = player_roll_time
    game.hero.roll_cd = player_roll_cd
    game.hero.invuln_t = maxf(game.hero.invuln_t, player_roll_time + 0.18)
    game.shake_t = maxf(game.shake_t, 0.08)

    burst_dust(game, game.hero.x, game.hero.y, 8, 0)
  }

  if game.hero.roll_t > 0.0 {
    game.hero.roll_t = maxf(0.0, game.hero.roll_t - dt)
    game.hero.vx = game.hero.roll_dx * player_roll_speed
    game.hero.vy = game.hero.roll_dy * player_roll_speed
  } else {
    let target_vx = game.input_x * player_speed
    let target_vy = game.input_y * player_speed
    let blend = clampf(dt * player_drag, 0.0, 1.0)

    game.hero.vx = lerpf(game.hero.vx, target_vx, blend)
    game.hero.vy = lerpf(game.hero.vy, target_vy, blend)
  }

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  let vel_len = sqrtf(game.hero.vx * game.hero.vx + game.hero.vy * game.hero.vy)
  if vel_len > 8.0 {
    game.hero.facing_x = game.hero.vx / vel_len
    game.hero.facing_y = game.hero.vy / vel_len
  }

  clamp_hero_ring(game.hero)

  try_shoot(game)
  try_repair(game)
}

///|
fn update_bullets(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if not(game.bullets[i].active) {
      continue
    }

    game.bullets[i].life = game.bullets[i].life - dt
    if game.bullets[i].life <= 0.0 {
      game.bullets[i].active = false
      continue
    }

    game.bullets[i].x = game.bullets[i].x + game.bullets[i].vx * dt
    game.bullets[i].y = game.bullets[i].y + game.bullets[i].vy * dt

    if game.bullets[i].x < -80.0 ||
      game.bullets[i].x > Float::from_int(screen_w) + 80.0 ||
      game.bullets[i].y < -80.0 ||
      game.bullets[i].y > Float::from_int(screen_h) + 80.0 {
      game.bullets[i].active = false
      continue
    }

    for j = 0; j < game.raiders.length(); j = j + 1 {
      if not(game.bullets[i].active) {
        break
      }

      if not(game.raiders[j].active) {
        continue
      }

      let rr = game.raiders[j].radius + 5.0
      if dist2(
          game.bullets[i].x,
          game.bullets[i].y,
          game.raiders[j].x,
          game.raiders[j].y,
        ) <=
        rr * rr {
        game.raiders[j].hp = game.raiders[j].hp - game.bullets[i].dmg
        game.raiders[j].flash_t = 0.12
        game.bullets[i].active = false

        emit_dust(
          game,
          game.bullets[i].x,
          game.bullets[i].y,
          randf(-90.0, 90.0),
          randf(-90.0, 90.0),
          0.2,
          2.2,
          2,
        )

        if game.raiders[j].hp <= 0.0 {
          kill_raider(game, j, 14)
        }
      }
    }
  }
}

///|
fn update_raiders(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.raiders.length(); i = i + 1 {
    if not(game.raiders[i].active) {
      continue
    }

    game.raiders[i].flash_t = maxf(0.0, game.raiders[i].flash_t - dt)

    if game.raiders[i].target_wagon < 0 ||
      game.raiders[i].target_wagon >= wagon_count ||
      game.wagons[game.raiders[i].target_wagon].hp <= 0.0 {
      game.raiders[i].target_wagon = choose_target_wagon(
        game,
        game.raiders[i].x,
        game.raiders[i].y,
      )
    }

    let target_wagon = game.raiders[i].target_wagon
    let mut tx = caravan_center_x
    let mut ty = caravan_center_y

    if target_wagon >= 0 && target_wagon < wagon_count {
      tx = game.wagons[target_wagon].x
      ty = game.wagons[target_wagon].y
    }

    let lane_track = lane_y(game, game.raiders[i].lane)
    ty = lerpf(ty, lane_track, 0.28)

    let dx = tx - game.raiders[i].x
    let dy = ty - game.raiders[i].y
    let len = sqrtf(dx * dx + dy * dy)

    if len > 0.01 {
      let ax = dx / len
      let ay = dy / len
      let blend = clampf(dt * 3.5, 0.0, 1.0)
      game.raiders[i].vx = lerpf(
        game.raiders[i].vx,
        ax * game.raiders[i].speed,
        blend,
      )
      game.raiders[i].vy = lerpf(
        game.raiders[i].vy,
        ay * game.raiders[i].speed,
        blend,
      )
    }

    game.raiders[i].x = game.raiders[i].x + game.raiders[i].vx * dt
    game.raiders[i].y = game.raiders[i].y + game.raiders[i].vy * dt
    game.raiders[i].x = game.raiders[i].x -
      caravan_speed(game.checkpoint) * dt * 0.16

    if target_wagon >= 0 &&
      target_wagon < wagon_count &&
      game.wagons[target_wagon].hp > 0.0 {
      let attack_r = game.raiders[i].radius + 16.0
      let in_attack = dist2(
          game.raiders[i].x,
          game.raiders[i].y,
          game.wagons[target_wagon].x,
          game.wagons[target_wagon].y,
        ) <=
        attack_r * attack_r

      game.raiders[i].attack_cd = game.raiders[i].attack_cd - dt

      if in_attack && game.raiders[i].attack_cd <= 0.0 {
        let dmg = if game.raiders[i].kind == raider_brute {
          randf(14.0, 19.0)
        } else if game.raiders[i].kind == raider_rider {
          randf(9.0, 13.0)
        } else {
          randf(8.0, 12.0)
        }

        damage_wagon(game, target_wagon, dmg)
        game.raiders[i].attack_cd = if game.raiders[i].kind == raider_brute {
          randf(0.72, 1.0)
        } else {
          randf(0.92, 1.24)
        }
        game.morale = clampf(game.morale - 1.8, 0.0, morale_max)
        emit_dust(
          game,
          game.wagons[target_wagon].x,
          game.wagons[target_wagon].y,
          randf(-150.0, 150.0),
          randf(-120.0, 80.0),
          0.3,
          3.4,
          1,
        )
      }
    }

    let hero_hit_r = game.raiders[i].radius + player_radius + 4.0
    if dist2(game.raiders[i].x, game.raiders[i].y, game.hero.x, game.hero.y) <=
      hero_hit_r * hero_hit_r {
      if game.hero.roll_t > 0.0 {
        kill_raider(game, i, 18)
        continue
      }

      if game.hero.invuln_t <= 0.0 {
        game.hero.invuln_t = player_invuln_time
        game.morale = clampf(game.morale - 6.4, 0.0, morale_max)
        game.shake_t = maxf(game.shake_t, 0.2)
        set_message(game, "Raiders breached your guard", 0.6)
      }

      let push_dx = game.raiders[i].x - game.hero.x
      let push_dy = game.raiders[i].y - game.hero.y
      let push_len = sqrtf(push_dx * push_dx + push_dy * push_dy)
      if push_len > 0.001 {
        game.raiders[i].vx = game.raiders[i].vx + push_dx / push_len * 120.0
        game.raiders[i].vy = game.raiders[i].vy + push_dy / push_len * 120.0
      }
    }

    if game.raiders[i].x < -140.0 {
      game.raiders[i].active = false
      game.morale = clampf(game.morale - 3.8, 0.0, morale_max)
      game.score = maxi(0, game.score - 12)
      continue
    }

    if game.raiders[i].hp <= 0.0 {
      kill_raider(game, i, 10)
    }
  }
}

///|
fn update_dust(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.dusts.length(); i = i + 1 {
    if not(game.dusts[i].active) {
      continue
    }

    game.dusts[i].life = game.dusts[i].life - dt
    if game.dusts[i].life <= 0.0 {
      game.dusts[i].active = false
      continue
    }

    game.dusts[i].x = game.dusts[i].x + game.dusts[i].vx * dt
    game.dusts[i].y = game.dusts[i].y + game.dusts[i].vy * dt
    game.dusts[i].vx = game.dusts[i].vx * (1.0 - dt * 2.2)
    game.dusts[i].vy = game.dusts[i].vy * (1.0 - dt * 2.2) + dt * 26.0
  }
}

///|
fn update_resources(game : Game, dt : Float) -> Unit {
  game.ammo_regen_t = game.ammo_regen_t - dt
  if game.ammo < ammo_max && game.ammo_regen_t <= 0.0 {
    game.ammo = game.ammo + 1
    game.ammo_regen_t = maxf(
      0.32,
      ammo_regen_base - Float::from_int(game.checkpoint) * 0.04,
    )
  }

  let pressure = Float::from_int(active_raider_count(game))
  let mut drain = morale_decay + pressure * 0.012
  if all_wagons_broken(game) {
    drain = drain + 8.0
  }

  game.morale = clampf(game.morale - drain * dt, 0.0, morale_max)
}

///|
fn award_checkpoint(game : Game) -> Unit {
  game.checkpoint = game.checkpoint + 1
  game.score = game.score + 160 + game.checkpoint * 28

  game.checkpoint_start = game.next_checkpoint
  game.next_checkpoint = game.next_checkpoint + checkpoint_span(game.checkpoint)

  game.morale = clampf(game.morale + 18.0, 0.0, morale_max)
  game.ammo = clampi(game.ammo + 10, 0, ammo_max)
  game.repair_kits = clampi(game.repair_kits + 1, 0, kit_max)

  for i = 0; i < game.wagons.length(); i = i + 1 {
    heal_wagon(game, i, 20.0)
  }

  game.flash_t = maxf(game.flash_t, 0.48)
  game.shake_t = maxf(game.shake_t, 0.2)
  set_message(
    game,
    "Checkpoint \{game.checkpoint}/\{checkpoint_total} secured",
    1.4,
  )

  for i = 0; i < game.wagons.length(); i = i + 1 {
    burst_dust(game, game.wagons[i].x, game.wagons[i].y, 9, 3)
  }

  if game.checkpoint >= checkpoint_total {
    if game.score > game.best_score {
      game.best_score = game.score
    }
    game.state = state_victory
    set_message(game, "Caravan reached the final oasis", 2.0)
  }
}

///|
fn update_progress(game : Game, dt : Float) -> Unit {
  game.distance = game.distance + caravan_speed(game.checkpoint) * dt

  while game.checkpoint < checkpoint_total &&
        game.distance >= game.next_checkpoint {
    award_checkpoint(game)
    if game.state == state_victory {
      return
    }
  }
}

///|
fn end_run(game : Game, victory : Bool) -> Unit {
  if game.score > game.best_score {
    game.best_score = game.score
  }

  if victory {
    game.state = state_victory
    set_message(game, "Caravan secured all checkpoints", 1.8)
  } else {
    game.state = state_game_over
    set_message(game, "Escort failed", 1.8)
  }
}

///|
fn update_play(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.flash_t = maxf(0.0, game.flash_t - dt)
  game.shake_t = maxf(0.0, game.shake_t - dt)

  if game.message_t > 0.0 {
    game.message_t = maxf(0.0, game.message_t - dt)
    if game.message_t <= 0.0 {
      game.message = ""
    }
  }

  update_wagons(game, dt)
  update_hero(game, dt)
  update_progress(game, dt)
  if game.state != state_play {
    update_bullets(game, dt)
    update_dust(game, dt)
    return
  }

  update_spawner(game, dt)
  update_raiders(game, dt)
  update_bullets(game, dt)
  update_dust(game, dt)
  update_resources(game, dt)

  if game.morale <= 0.0 {
    end_run(game, false)
    return
  }

  if all_wagons_broken(game) {
    end_run(game, false)
    return
  }
}

///|
fn update_title(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt * 0.55
  game.flash_t = 0.0
  game.shake_t = 0.0

  if game.message_t > 0.0 {
    game.message_t = maxf(0.0, game.message_t - dt)
  }

  update_wagons(game, dt * 0.55)

  if game.input_confirm_press {
    start_run(game)
  }
}

///|
fn update_pause(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt * 0.18
  update_wagons(game, dt * 0.18)
  update_dust(game, dt)

  if game.input_pause_press || game.input_confirm_press {
    game.state = state_play
    set_message(game, "Escort resumed", 0.8)
  }
}

///|
fn update_end(game : Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt * 0.35
  game.flash_t = maxf(0.0, game.flash_t - dt)
  game.shake_t = maxf(0.0, game.shake_t - dt)

  if game.message_t > 0.0 {
    game.message_t = maxf(0.0, game.message_t - dt)
  }

  update_wagons(game, dt * 0.35)
  update_dust(game, dt)

  if game.input_confirm_press {
    start_run(game)
  }
}

///|
fn update_game(game : Game, dt : Float) -> Unit {
  if game.input_restart_press {
    start_run(game)
    return
  }

  if game.state == state_title {
    update_title(game, dt)
    return
  }

  if game.state == state_play {
    if game.input_pause_press {
      game.state = state_pause
      set_message(game, "Paused", 0.8)
      return
    }

    update_play(game, dt)
    return
  }

  if game.state == state_pause {
    update_pause(game, dt)
    return
  }

  update_end(game, dt)
}
