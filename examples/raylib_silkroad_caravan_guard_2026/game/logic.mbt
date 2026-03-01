///|
fn set_message(game : @types.Game, msg : String, ttl : Float) -> Unit {
  game.message = msg
  game.message_t = ttl
}

///|
fn clear_raiders(game : @types.Game) -> Unit {
  for raider in game.raiders {
    raider.active = false
    raider.kind = @types.raider_skirmisher
    raider.x = 0.0
    raider.y = 0.0
    raider.vx = 0.0
    raider.vy = 0.0
    raider.speed = 0.0
    raider.hp = 0.0
    raider.target_wagon = 0
    raider.lane = 0
    raider.attack_cd = 0.0
    raider.flash_t = 0.0
    raider.radius = 16.0
  }
}

///|
fn clear_bullets(game : @types.Game) -> Unit {
  for bullet in game.bullets {
    bullet.active = false
    bullet.x = 0.0
    bullet.y = 0.0
    bullet.vx = 0.0
    bullet.vy = 0.0
    bullet.life = 0.0
    bullet.dmg = 0.0
  }
}

///|
fn clear_dust(game : @types.Game) -> Unit {
  for dust in game.dusts {
    dust.active = false
    dust.x = 0.0
    dust.y = 0.0
    dust.vx = 0.0
    dust.vy = 0.0
    dust.life = 0.0
    dust.size = 0.0
    dust.kind = 0
  }
}

///|
fn reset_wagons(game : @types.Game) -> Unit {
  for i in 0..<game.wagons.length() {
    game.wagons[i].x = @types.wagon_slot_x(i)
    game.wagons[i].y = @types.wagon_slot_y(i)
    game.wagons[i].hp = game.wagons[i].max_hp
    game.wagons[i].repair_cd = 0.0
  }
}

///|
fn reset_hero(hero : @types.Player) -> Unit {
  hero.x = @types.caravan_center_x - @types.perimeter_outer_rx * 0.9
  hero.y = @types.caravan_center_y
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
fn start_run(game : @types.Game) -> Unit {
  clear_raiders(game)
  clear_bullets(game)
  clear_dust(game)
  reset_wagons(game)
  reset_hero(game.hero)

  game.state = @types.state_play
  game.score = 0
  game.kills = 0
  game.checkpoint = 0
  game.distance = 0.0
  game.checkpoint_start = 0.0
  game.next_checkpoint = @types.checkpoint_span(0)
  game.morale = 76.0
  game.ammo = 26
  game.ammo_regen_t = @types.ammo_regen_base
  game.repair_kits = 3
  game.spawn_t = 0.4
  game.time_s = 0.0
  game.flash_t = 0.0
  game.shake_t = 0.0
  set_message(game, "Escort in motion", 1.2)
}

///|
fn alloc_raider(game : @types.Game) -> Int {
  for i in 0..<game.raiders.length() {
    if not(game.raiders[i].active) {
      return i
    }
  }

  let mut oldest = 0
  let mut best_x = game.raiders[0].x
  for i in 1..<game.raiders.length() {
    if game.raiders[i].x < best_x {
      best_x = game.raiders[i].x
      oldest = i
    }
  }
  oldest
}

///|
fn alloc_bullet(game : @types.Game) -> Int {
  for i in 0..<game.bullets.length() {
    if not(game.bullets[i].active) {
      return i
    }
  }

  let mut oldest = 0
  let mut best_life = game.bullets[0].life
  for i in 1..<game.bullets.length() {
    if game.bullets[i].life < best_life {
      best_life = game.bullets[i].life
      oldest = i
    }
  }
  oldest
}

///|
fn alloc_dust(game : @types.Game) -> Int {
  for i in 0..<game.dusts.length() {
    if not(game.dusts[i].active) {
      return i
    }
  }
  @types.randi(0, game.dusts.length() - 1)
}

///|
fn emit_dust(
  game : @types.Game,
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
  game : @types.Game,
  x : Float,
  y : Float,
  count : Int,
  kind : Int,
) -> Unit {
  for _i in 0..<count {
    emit_dust(
      game,
      x + @types.randf(-16.0, 16.0),
      y + @types.randf(-16.0, 16.0),
      @types.randf(-240.0, 240.0),
      @types.randf(-220.0, 220.0),
      @types.randf(0.2, 0.9),
      @types.randf(1.5, 4.8),
      kind,
    )
  }
}

///|
fn lane_y(game : @types.Game, index : Int) -> Float {
  let i = @types.clampi(index, 0, @types.lane_count - 1)
  let fi = Float::from_int(i)
  let base = @types.lane_base_y(i)
  let wave = @types.sinf(
    game.time_s * (0.92 + fi * 0.12) + fi * 1.3 + game.distance * 0.008,
  )
  let sway = @types.cosf(
    game.time_s * (0.46 + fi * 0.06) + fi * 0.8 + game.distance * 0.003,
  )
  base + wave * 26.0 + sway * 12.0
}

///|
fn active_raider_count(game : @types.Game) -> Int {
  let mut c = 0
  for raider in game.raiders {
    if raider.active {
      c = c + 1
    }
  }
  c
}

///|
fn nearest_raider_index(
  game : @types.Game,
  x : Float,
  y : Float,
  max_dist2 : Float,
) -> Int {
  let mut best = -1
  let mut best_d2 = max_dist2
  for i in 0..<game.raiders.length() {
    if not(game.raiders[i].active) {
      continue
    }
    let d2 = @types.dist2(x, y, game.raiders[i].x, game.raiders[i].y)
    if d2 < best_d2 {
      best_d2 = d2
      best = i
    }
  }
  best
}

///|
fn nearest_wagon_index(
  game : @types.Game,
  x : Float,
  y : Float,
  only_alive : Bool,
) -> Int {
  let mut best = -1
  let mut best_d2 : Float = 99999999.0
  for i in 0..<game.wagons.length() {
    if only_alive && game.wagons[i].hp <= 0.0 {
      continue
    }

    let d2 = @types.dist2(x, y, game.wagons[i].x, game.wagons[i].y)
    if d2 < best_d2 {
      best_d2 = d2
      best = i
    }
  }
  best
}

///|
fn all_wagons_broken(game : @types.Game) -> Bool {
  for wagon in game.wagons {
    if wagon.hp > 0.0 {
      return false
    }
  }
  true
}

///|
fn update_wagons(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.wagons.length() {
    if game.wagons[i].repair_cd > 0.0 {
      game.wagons[i].repair_cd = @types.maxf(0.0, game.wagons[i].repair_cd - dt)
    }

    let fi = Float::from_int(i)
    game.wagons[i].x = @types.wagon_slot_x(i) +
      @types.sinf(game.time_s * 1.1 + fi * 0.9 + game.distance * 0.005) * 8.0
    game.wagons[i].y = @types.wagon_slot_y(i) +
      @types.cosf(game.time_s * 1.4 + fi * 0.6) * 6.0
  }
}

///|
fn heal_wagon(game : @types.Game, index : Int, value : Float) -> Unit {
  if index < 0 || index >= game.wagons.length() {
    return
  }

  game.wagons[index].hp = @types.minf(
    game.wagons[index].max_hp,
    game.wagons[index].hp + @types.maxf(value, 0.0),
  )
}

///|
fn damage_wagon(game : @types.Game, index : Int, value : Float) -> Unit {
  if index < 0 || index >= game.wagons.length() {
    return
  }

  if game.wagons[index].hp <= 0.0 {
    return
  }

  game.wagons[index].hp = @types.maxf(0.0, game.wagons[index].hp - value)
  game.morale = @types.clampf(
    game.morale - value * 0.24,
    0.0,
    @types.morale_max,
  )
  game.flash_t = @types.maxf(game.flash_t, 0.2)
  game.shake_t = @types.maxf(game.shake_t, 0.14)

  if game.wagons[index].hp <= 0.0 {
    game.score = @types.maxi(0, game.score - 40)
    game.morale = @types.clampf(game.morale - 10.0, 0.0, @types.morale_max)
    set_message(game, "A wagon is broken!", 1.1)
  }
}

///|
fn kill_raider(game : @types.Game, index : Int, score_gain : Int) -> Unit {
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
  game.morale = @types.clampf(
    game.morale + @types.morale_kill_gain,
    0.0,
    @types.morale_max,
  )

  if @types.chance(22) {
    game.ammo = @types.clampi(game.ammo + 1, 0, @types.ammo_max)
  }

  if @types.chance(9) {
    game.repair_kits = @types.clampi(game.repair_kits + 1, 0, @types.kit_max)
    set_message(game, "Raider dropped a repair kit", 0.9)
  }
}

///|
fn choose_raider_kind(game : @types.Game) -> Int {
  let roll = @types.randi(0, 99)

  if game.checkpoint >= 3 {
    if roll < 34 {
      @types.raider_brute
    } else if roll < 72 {
      @types.raider_rider
    } else {
      @types.raider_skirmisher
    }
  } else if game.checkpoint >= 2 {
    if roll < 28 {
      @types.raider_brute
    } else if roll < 56 {
      @types.raider_rider
    } else {
      @types.raider_skirmisher
    }
  } else if game.checkpoint >= 1 {
    if roll < 20 {
      @types.raider_brute
    } else if roll < 42 {
      @types.raider_rider
    } else {
      @types.raider_skirmisher
    }
  } else if roll < 15 {
    @types.raider_brute
  } else {
    @types.raider_skirmisher
  }
}

///|
fn choose_target_wagon(game : @types.Game, x : Float, y : Float) -> Int {
  let target = nearest_wagon_index(game, x, y, true)
  if target >= 0 {
    target
  } else {
    @types.randi(0, @types.wagon_count - 1)
  }
}

///|
fn spawn_raider(
  game : @types.Game,
  lane : Int,
  kind : Int,
) -> Unit {
  let i = alloc_raider(game)
  let x = Float::from_int(@types.screen_w) + @types.randf(60.0, 160.0)
  let y = lane_y(game, lane) + @types.randf(-20.0, 20.0)

  game.raiders[i].active = true
  game.raiders[i].kind = kind
  game.raiders[i].x = x
  game.raiders[i].y = y
  game.raiders[i].vx = @types.randf(-30.0, 20.0)
  game.raiders[i].vy = @types.randf(-20.0, 20.0)
  game.raiders[i].target_wagon = choose_target_wagon(game, x, y)
  game.raiders[i].lane = @types.clampi(lane, 0, @types.lane_count - 1)
  game.raiders[i].attack_cd = @types.randf(0.24, 0.68)
  game.raiders[i].flash_t = 0.0

  if kind == @types.raider_brute {
    game.raiders[i].speed = @types.randf(76.0, 96.0) +
      Float::from_int(game.checkpoint) * 6.0
    game.raiders[i].hp = @types.randf(84.0, 108.0)
    game.raiders[i].radius = 22.0
  } else if kind == @types.raider_rider {
    game.raiders[i].speed = @types.randf(132.0, 162.0) +
      Float::from_int(game.checkpoint) * 8.0
    game.raiders[i].hp = @types.randf(52.0, 72.0)
    game.raiders[i].radius = 14.0
  } else {
    game.raiders[i].speed = @types.randf(102.0, 128.0) +
      Float::from_int(game.checkpoint) * 7.0
    game.raiders[i].hp = @types.randf(46.0, 62.0)
    game.raiders[i].radius = 16.0
  }
}

///|
fn spawn_wave(game : @types.Game) -> Unit {
  let mut count = 1
  if game.checkpoint >= 2 {
    count = 2
  }
  if @types.chance(14 + game.checkpoint * 11) {
    count = count + 1
  }

  for _i in 0..<count {
    let lane = @types.randi(0, @types.lane_count - 1)
    spawn_raider(game, lane, choose_raider_kind(game))
  }
}

///|
fn update_spawner(game : @types.Game, dt : Float) -> Unit {
  game.spawn_t = game.spawn_t - dt
  if game.spawn_t > 0.0 {
    return
  }

  spawn_wave(game)

  let pressure = Float::from_int(game.checkpoint) * 0.25 +
    game.distance * 0.00013
  let mut next = @types.spawn_interval_base - pressure
  next = @types.clampf(
    next, @types.spawn_interval_min, @types.spawn_interval_base,
  )
  game.spawn_t = next + @types.randf(-0.08, 0.2)
}

///|
fn spawn_bullet(
  game : @types.Game,
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
  game.bullets[i].life = @types.bullet_life
  game.bullets[i].dmg = dmg
}

///|
fn try_shoot(game : @types.Game) -> Unit {
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

  let len = @types.sqrtf(dx * dx + dy * dy)
  if len < 0.001 {
    dx = 1.0
    dy = 0.0
  } else {
    dx = dx / len
    dy = dy / len
  }

  spawn_bullet(
    game,
    game.hero.x + dx * (@types.player_radius + 7.0),
    game.hero.y + dy * (@types.player_radius + 7.0),
    dx * @types.bullet_speed,
    dy * @types.bullet_speed,
    @types.bullet_dmg,
  )

  game.hero.shoot_cd = @types.shoot_cd
  game.ammo = game.ammo - 1
  emit_dust(
    game,
    game.hero.x + dx * 10.0,
    game.hero.y + dy * 10.0,
    dx * 120.0 + @types.randf(-70.0, 70.0),
    dy * 120.0 + @types.randf(-70.0, 70.0),
    0.25,
    3.2,
    2,
  )
}

///|
fn try_repair(game : @types.Game) -> Unit {
  if not(game.input_repair_press) {
    return
  }

  let mut target = -1
  let mut best_d2 = @types.repair_range * @types.repair_range

  for i in 0..<game.wagons.length() {
    if game.wagons[i].hp >= game.wagons[i].max_hp {
      continue
    }

    let d2 = @types.dist2(
      game.hero.x,
      game.hero.y,
      game.wagons[i].x,
      game.wagons[i].y,
    )
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
  heal_wagon(game, target, @types.repair_heal)
  game.wagons[target].repair_cd = @types.repair_cd
  game.hero.repair_t = 0.26
  game.morale = @types.clampf(game.morale + 7.5, 0.0, @types.morale_max)
  game.score = game.score + 22
  set_message(game, "Wagon repaired", 0.8)
  burst_dust(
    game,
    game.wagons[target].x,
    game.wagons[target].y,
    16,
    3,
  )
}

///|
fn clamp_hero_ring(hero : @types.Player) -> Unit {
  let mut dx = hero.x - @types.caravan_center_x
  let mut dy = hero.y - @types.caravan_center_y

  if @types.absf(dx) < 0.001 && @types.absf(dy) < 0.001 {
    dx = @types.perimeter_outer_rx
  }

  let outer = @types.ellipse_norm(
    dx, dy, @types.perimeter_outer_rx, @types.perimeter_outer_ry,
  )
  if outer > 1.0 {
    dx = dx / outer
    dy = dy / outer
  }

  let inner = @types.ellipse_norm(
    dx, dy, @types.perimeter_inner_rx, @types.perimeter_inner_ry,
  )
  if inner < 1.0 {
    let scale : Float = 1.0 / @types.maxf(inner, 0.0001)
    dx = dx * scale
    dy = dy * scale
  }

  hero.x = @types.caravan_center_x + dx
  hero.y = @types.caravan_center_y + dy
}

///|
fn update_hero(game : @types.Game, dt : Float) -> Unit {
  game.hero.shoot_cd = @types.maxf(0.0, game.hero.shoot_cd - dt)
  game.hero.roll_cd = @types.maxf(0.0, game.hero.roll_cd - dt)
  game.hero.invuln_t = @types.maxf(0.0, game.hero.invuln_t - dt)
  game.hero.repair_t = @types.maxf(0.0, game.hero.repair_t - dt)

  if game.input_roll_press && game.hero.roll_cd <= 0.0 {
    let mut dx = game.input_x
    let mut dy = game.input_y

    if @types.absf(dx) + @types.absf(dy) < 0.01 {
      dx = game.hero.facing_x
      dy = game.hero.facing_y
    }

    let len = @types.sqrtf(dx * dx + dy * dy)
    if len < 0.001 {
      dx = 1.0
      dy = 0.0
    } else {
      dx = dx / len
      dy = dy / len
    }

    game.hero.roll_dx = dx
    game.hero.roll_dy = dy
    game.hero.roll_t = @types.player_roll_time
    game.hero.roll_cd = @types.player_roll_cd
    game.hero.invuln_t = @types.maxf(
      game.hero.invuln_t,
      @types.player_roll_time + 0.18,
    )
    game.shake_t = @types.maxf(game.shake_t, 0.08)

    burst_dust(game, game.hero.x, game.hero.y, 8, 0)
  }

  if game.hero.roll_t > 0.0 {
    game.hero.roll_t = @types.maxf(0.0, game.hero.roll_t - dt)
    game.hero.vx = game.hero.roll_dx * @types.player_roll_speed
    game.hero.vy = game.hero.roll_dy * @types.player_roll_speed
  } else {
    let target_vx = game.input_x * @types.player_speed
    let target_vy = game.input_y * @types.player_speed
    let blend = @types.clampf(dt * @types.player_drag, 0.0, 1.0)

    game.hero.vx = @types.lerpf(game.hero.vx, target_vx, blend)
    game.hero.vy = @types.lerpf(game.hero.vy, target_vy, blend)
  }

  game.hero.x = game.hero.x + game.hero.vx * dt
  game.hero.y = game.hero.y + game.hero.vy * dt

  let vel_len = @types.sqrtf(
    game.hero.vx * game.hero.vx + game.hero.vy * game.hero.vy,
  )
  if vel_len > 8.0 {
    game.hero.facing_x = game.hero.vx / vel_len
    game.hero.facing_y = game.hero.vy / vel_len
  }

  clamp_hero_ring(game.hero)

  try_shoot(game)
  try_repair(game)
}

///|
fn update_bullets(game : @types.Game, dt : Float) -> Unit {
  for bullet in game.bullets {
    if not(bullet.active) {
      continue
    }

    bullet.life = bullet.life - dt
    if bullet.life <= 0.0 {
      bullet.active = false
      continue
    }

    bullet.x = bullet.x + bullet.vx * dt
    bullet.y = bullet.y + bullet.vy * dt

    if bullet.x < -80.0 ||
      bullet.x > Float::from_int(@types.screen_w) + 80.0 ||
      bullet.y < -80.0 ||
      bullet.y > Float::from_int(@types.screen_h) + 80.0 {
      bullet.active = false
      continue
    }

    for j in 0..<game.raiders.length() {
      if not(bullet.active) {
        break
      }

      if not(game.raiders[j].active) {
        continue
      }

      let rr = game.raiders[j].radius + 5.0
      if @types.dist2(bullet.x, bullet.y, game.raiders[j].x, game.raiders[j].y) <=
        rr * rr {
        game.raiders[j].hp = game.raiders[j].hp - bullet.dmg
        game.raiders[j].flash_t = 0.12
        bullet.active = false

        emit_dust(
          game,
          bullet.x,
          bullet.y,
          @types.randf(-90.0, 90.0),
          @types.randf(-90.0, 90.0),
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
fn update_raiders(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.raiders.length() {
    if not(game.raiders[i].active) {
      continue
    }

    game.raiders[i].flash_t = @types.maxf(0.0, game.raiders[i].flash_t - dt)

    if game.raiders[i].target_wagon < 0 ||
      game.raiders[i].target_wagon >= @types.wagon_count ||
      game.wagons[game.raiders[i].target_wagon].hp <= 0.0 {
      game.raiders[i].target_wagon = choose_target_wagon(
        game,
        game.raiders[i].x,
        game.raiders[i].y,
      )
    }

    let target_wagon = game.raiders[i].target_wagon
    let mut tx = @types.caravan_center_x
    let mut ty = @types.caravan_center_y

    if target_wagon >= 0 && target_wagon < @types.wagon_count {
      tx = game.wagons[target_wagon].x
      ty = game.wagons[target_wagon].y
    }

    let lane_track = lane_y(game, game.raiders[i].lane)
    ty = @types.lerpf(ty, lane_track, 0.28)

    let dx = tx - game.raiders[i].x
    let dy = ty - game.raiders[i].y
    let len = @types.sqrtf(dx * dx + dy * dy)

    if len > 0.01 {
      let ax = dx / len
      let ay = dy / len
      let blend = @types.clampf(dt * 3.5, 0.0, 1.0)
      game.raiders[i].vx = @types.lerpf(
        game.raiders[i].vx,
        ax * game.raiders[i].speed,
        blend,
      )
      game.raiders[i].vy = @types.lerpf(
        game.raiders[i].vy,
        ay * game.raiders[i].speed,
        blend,
      )
    }

    game.raiders[i].x = game.raiders[i].x + game.raiders[i].vx * dt
    game.raiders[i].y = game.raiders[i].y + game.raiders[i].vy * dt
    game.raiders[i].x = game.raiders[i].x -
      @types.caravan_speed(game.checkpoint) * dt * 0.16

    if target_wagon >= 0 &&
      target_wagon < @types.wagon_count &&
      game.wagons[target_wagon].hp > 0.0 {
      let attack_r = game.raiders[i].radius + 16.0
      let in_attack = @types.dist2(
          game.raiders[i].x,
          game.raiders[i].y,
          game.wagons[target_wagon].x,
          game.wagons[target_wagon].y,
        ) <=
        attack_r * attack_r

      game.raiders[i].attack_cd = game.raiders[i].attack_cd - dt

      if in_attack && game.raiders[i].attack_cd <= 0.0 {
        let dmg = if game.raiders[i].kind == @types.raider_brute {
          @types.randf(14.0, 19.0)
        } else if game.raiders[i].kind == @types.raider_rider {
          @types.randf(9.0, 13.0)
        } else {
          @types.randf(8.0, 12.0)
        }

        damage_wagon(game, target_wagon, dmg)
        game.raiders[i].attack_cd = if game.raiders[i].kind == @types.raider_brute {
          @types.randf(0.72, 1.0)
        } else {
          @types.randf(0.92, 1.24)
        }
        game.morale = @types.clampf(game.morale - 1.8, 0.0, @types.morale_max)
        emit_dust(
          game,
          game.wagons[target_wagon].x,
          game.wagons[target_wagon].y,
          @types.randf(-150.0, 150.0),
          @types.randf(-120.0, 80.0),
          0.3,
          3.4,
          1,
        )
      }
    }

    let hero_hit_r = game.raiders[i].radius + @types.player_radius + 4.0
    if @types.dist2(
        game.raiders[i].x,
        game.raiders[i].y,
        game.hero.x,
        game.hero.y,
      ) <=
      hero_hit_r * hero_hit_r {
      if game.hero.roll_t > 0.0 {
        kill_raider(game, i, 18)
        continue
      }

      if game.hero.invuln_t <= 0.0 {
        game.hero.invuln_t = @types.player_invuln_time
        game.morale = @types.clampf(game.morale - 6.4, 0.0, @types.morale_max)
        game.shake_t = @types.maxf(game.shake_t, 0.2)
        set_message(game, "Raiders breached your guard", 0.6)
      }

      let push_dx = game.raiders[i].x - game.hero.x
      let push_dy = game.raiders[i].y - game.hero.y
      let push_len = @types.sqrtf(push_dx * push_dx + push_dy * push_dy)
      if push_len > 0.001 {
        game.raiders[i].vx = game.raiders[i].vx + push_dx / push_len * 120.0
        game.raiders[i].vy = game.raiders[i].vy + push_dy / push_len * 120.0
      }
    }

    if game.raiders[i].x < -140.0 {
      game.raiders[i].active = false
      game.morale = @types.clampf(game.morale - 3.8, 0.0, @types.morale_max)
      game.score = @types.maxi(0, game.score - 12)
      continue
    }

    if game.raiders[i].hp <= 0.0 {
      kill_raider(game, i, 10)
    }
  }
}

///|
fn update_dust(game : @types.Game, dt : Float) -> Unit {
  for dust in game.dusts {
    if not(dust.active) {
      continue
    }

    dust.life = dust.life - dt
    if dust.life <= 0.0 {
      dust.active = false
      continue
    }

    dust.x = dust.x + dust.vx * dt
    dust.y = dust.y + dust.vy * dt
    dust.vx = dust.vx * (1.0 - dt * 2.2)
    dust.vy = dust.vy * (1.0 - dt * 2.2) + dt * 26.0
  }
}

///|
fn update_resources(game : @types.Game, dt : Float) -> Unit {
  game.ammo_regen_t = game.ammo_regen_t - dt
  if game.ammo < @types.ammo_max && game.ammo_regen_t <= 0.0 {
    game.ammo = game.ammo + 1
    game.ammo_regen_t = @types.maxf(
      0.32,
      @types.ammo_regen_base - Float::from_int(game.checkpoint) * 0.04,
    )
  }

  let pressure = Float::from_int(active_raider_count(game))
  let mut drain = @types.morale_decay + pressure * 0.012
  if all_wagons_broken(game) {
    drain = drain + 8.0
  }

  game.morale = @types.clampf(game.morale - drain * dt, 0.0, @types.morale_max)
}

///|
fn award_checkpoint(game : @types.Game) -> Unit {
  game.checkpoint = game.checkpoint + 1
  game.score = game.score + 160 + game.checkpoint * 28

  game.checkpoint_start = game.next_checkpoint
  game.next_checkpoint = game.next_checkpoint +
    @types.checkpoint_span(game.checkpoint)

  game.morale = @types.clampf(game.morale + 18.0, 0.0, @types.morale_max)
  game.ammo = @types.clampi(game.ammo + 10, 0, @types.ammo_max)
  game.repair_kits = @types.clampi(game.repair_kits + 1, 0, @types.kit_max)

  for i in 0..<game.wagons.length() {
    heal_wagon(game, i, 20.0)
  }

  game.flash_t = @types.maxf(game.flash_t, 0.48)
  game.shake_t = @types.maxf(game.shake_t, 0.2)
  set_message(
    game,
    "Checkpoint \{game.checkpoint}/\{@types.checkpoint_total} secured",
    1.4,
  )

  for wagon in game.wagons {
    burst_dust(game, wagon.x, wagon.y, 9, 3)
  }

  if game.checkpoint >= @types.checkpoint_total {
    if game.score > game.best_score {
      game.best_score = game.score
    }
    game.state = @types.state_victory
    set_message(game, "Caravan reached the final oasis", 2.0)
  }
}

///|
fn update_progress(game : @types.Game, dt : Float) -> Unit {
  game.distance = game.distance + @types.caravan_speed(game.checkpoint) * dt

  while game.checkpoint < @types.checkpoint_total &&
        game.distance >= game.next_checkpoint {
    award_checkpoint(game)
    if game.state == @types.state_victory {
      return
    }
  }
}

///|
fn end_run(game : @types.Game, victory : Bool) -> Unit {
  if game.score > game.best_score {
    game.best_score = game.score
  }

  if victory {
    game.state = @types.state_victory
    set_message(game, "Caravan secured all checkpoints", 1.8)
  } else {
    game.state = @types.state_game_over
    set_message(game, "Escort failed", 1.8)
  }
}

///|
fn update_play(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt
  game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  game.shake_t = @types.maxf(0.0, game.shake_t - dt)

  if game.message_t > 0.0 {
    game.message_t = @types.maxf(0.0, game.message_t - dt)
    if game.message_t <= 0.0 {
      game.message = ""
    }
  }

  update_wagons(game, dt)
  update_hero(game, dt)
  update_progress(game, dt)
  if game.state != @types.state_play {
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
fn update_title(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt * 0.55
  game.flash_t = 0.0
  game.shake_t = 0.0

  if game.message_t > 0.0 {
    game.message_t = @types.maxf(0.0, game.message_t - dt)
  }

  update_wagons(game, dt * 0.55)

  if game.input_confirm_press {
    start_run(game)
  }
}

///|
fn update_pause(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt * 0.18
  update_wagons(game, dt * 0.18)
  update_dust(game, dt)

  if game.input_pause_press || game.input_confirm_press {
    game.state = @types.state_play
    set_message(game, "Escort resumed", 0.8)
  }
}

///|
fn update_end(game : @types.Game, dt : Float) -> Unit {
  game.time_s = game.time_s + dt * 0.35
  game.flash_t = @types.maxf(0.0, game.flash_t - dt)
  game.shake_t = @types.maxf(0.0, game.shake_t - dt)

  if game.message_t > 0.0 {
    game.message_t = @types.maxf(0.0, game.message_t - dt)
  }

  update_wagons(game, dt * 0.35)
  update_dust(game, dt)

  if game.input_confirm_press {
    start_run(game)
  }
}

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  update_input(game)

  if game.input_restart_press {
    start_run(game)
    return
  }

  if game.state == @types.state_title {
    update_title(game, dt)
  } else if game.state == @types.state_play {
    if game.input_pause_press {
      game.state = @types.state_pause
      set_message(game, "Paused", 0.8)
      return
    }
    update_play(game, dt)
  } else if game.state == @types.state_pause {
    update_pause(game, dt)
  } else {
    update_end(game, dt)
  }
}
