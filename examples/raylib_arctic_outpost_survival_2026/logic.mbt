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
fn normalize(dx : Float, dy : Float) -> (Float, Float) {
  let d1 : Float = absf(dx) + absf(dy)
  if d1 <= 0.00001 {
    (0.0, -1.0)
  } else {
    (dx / d1, dy / d1)
  }
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
  for i = 0; i < game.enemies.length(); i = i + 1 {
    game.enemies[i].active = false
    game.enemies[i].x = 0.0
    game.enemies[i].y = 0.0
    game.enemies[i].vx = 0.0
    game.enemies[i].vy = 0.0
    game.enemies[i].r = 0.0
    game.enemies[i].hp = 0.0
    game.enemies[i].kind = enemy_wolf
    game.enemies[i].phase = 0.0
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

  for i = 0; i < game.bullets.length(); i = i + 1 {
    game.bullets[i].active = false
    game.bullets[i].x = 0.0
    game.bullets[i].y = 0.0
    game.bullets[i].vx = 0.0
    game.bullets[i].vy = 0.0
    game.bullets[i].life = 0.0
    game.bullets[i].power = 0.0
    game.bullets[i].kind = bullet_normal
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
      randf(-260.0, 140.0),
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

    let damp : Float = if game.particles[i].kind == 2 { 2.7 } else { 1.9 }
    game.particles[i].vx = game.particles[i].vx * (1.0 - dt * damp)
    game.particles[i].vy = game.particles[i].vy * (1.0 - dt * (damp - 0.4)) +
      dt * (if game.particles[i].kind == 1 { 180.0 } else { 120.0 })
  }
}

///|
fn reset_player(game : Game) -> Unit {
  game.player_x = Float::from_int(world_x0 + world_w / 2)
  game.player_y = Float::from_int(world_y0 + world_h - 180)
  game.player_vx = 0.0
  game.player_vy = 0.0
  game.move_x = 0.0
  game.move_y = 0.0
  game.aim_x = core_x()
  game.aim_y = core_y()
}

///|
fn start_run(game : Game) -> Unit {
  clear_world(game)
  clear_particles(game)

  game.state = state_play
  reset_player(game)

  game.lives = 3
  game.suit_hp = 100.0
  game.core_heat = 100.0
  game.fuel = 100.0
  game.ammo = 180

  game.overdrive_t = 0.0
  game.fire_cd = 0.0
  game.repair_cd = 0.0

  game.score = 0
  game.wave = 1
  game.combo = 0
  game.combo_t = 0.0

  game.spawn_t = 0.48
  game.pickup_t = 1.2
  game.storm_t = 0.0

  game.game_t = 0.0
  game.ui_t = 0.0
  game.touch_cd = 0.0

  game.hint_left = 3
  game.hint_t = 0.0
  game.hint_x = core_x()
  game.hint_y = core_y()

  game.msg = ""
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.win = false

  set_msg(game, "Defend core heat for 200s. Repair near generator.", 2.8)
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

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if win {
    set_msg(game, "Outpost survived the polar night.", 3.0)
    burst(game, core_x(), core_y(), 70, 2)
  } else {
    set_msg(game, "Outpost collapsed in the storm.", 3.0)
    burst(game, core_x(), core_y(), 56, 1)
  }
}

///|
fn spawn_enemy(game : Game) -> Bool {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if game.enemies[i].active {
      continue
    }

    let roll : Int = @raylib.get_random_value(0, 99)
    let kind : Int = if roll < 56 {
      enemy_wolf
    } else if roll < 84 {
      enemy_brute
    } else {
      enemy_shard
    }

    let side : Int = @raylib.get_random_value(0, 3)
    if side == 0 {
      game.enemies[i].x = randf(world_left() + 20.0, world_right() - 20.0)
      game.enemies[i].y = world_top() - 40.0
    } else if side == 1 {
      game.enemies[i].x = randf(world_left() + 20.0, world_right() - 20.0)
      game.enemies[i].y = world_bottom() + 40.0
    } else if side == 2 {
      game.enemies[i].x = world_left() - 40.0
      game.enemies[i].y = randf(world_top() + 20.0, world_bottom() - 20.0)
    } else {
      game.enemies[i].x = world_right() + 40.0
      game.enemies[i].y = randf(world_top() + 20.0, world_bottom() - 20.0)
    }

    game.enemies[i].active = true
    game.enemies[i].kind = kind

    if kind == enemy_wolf {
      game.enemies[i].r = randf(17.0, 22.0)
      game.enemies[i].hp = randf(24.0, 36.0) + Float::from_int(game.wave) * 2.4
    } else if kind == enemy_brute {
      game.enemies[i].r = randf(26.0, 34.0)
      game.enemies[i].hp = randf(60.0, 82.0) + Float::from_int(game.wave) * 4.0
    } else {
      game.enemies[i].r = randf(13.0, 18.0)
      game.enemies[i].hp = randf(16.0, 24.0) + Float::from_int(game.wave) * 1.8
    }

    game.enemies[i].vx = 0.0
    game.enemies[i].vy = 0.0
    game.enemies[i].phase = randf(0.0, 6.28)

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
    game.pickups[i].y = world_top() - randf(60.0, 260.0)
    game.pickups[i].vx = randf(-36.0, 36.0)
    game.pickups[i].vy = randf(112.0, 170.0)
    game.pickups[i].phase = randf(0.0, 6.28)

    let roll : Int = @raylib.get_random_value(0, 99)
    game.pickups[i].kind = if roll < 38 {
      pickup_fuel
    } else if roll < 62 {
      pickup_medkit
    } else if roll < 86 {
      pickup_ammo
    } else {
      pickup_overdrive
    }

    return true
  }

  false
}

///|
fn spawn_bullet(
  game : Game,
  x : Float,
  y : Float,
  tx : Float,
  ty : Float,
  power : Float,
  kind : Int,
) -> Bool {
  for i = 0; i < game.bullets.length(); i = i + 1 {
    if game.bullets[i].active {
      continue
    }

    let dir = normalize(tx - x, ty - y)
    let speed : Float = if kind == bullet_pierce { 920.0 } else { 760.0 }

    game.bullets[i].active = true
    game.bullets[i].x = x
    game.bullets[i].y = y
    game.bullets[i].vx = dir.0 * speed
    game.bullets[i].vy = dir.1 * speed
    game.bullets[i].life = if kind == bullet_pierce { 1.8 } else { 1.4 }
    game.bullets[i].power = power
    game.bullets[i].kind = kind

    return true
  }

  false
}

///|
fn try_fire(game : Game, tx : Float, ty : Float) -> Bool {
  if game.state != state_play {
    return false
  }
  if game.fire_cd > 0.0 {
    return false
  }
  if game.ammo <= 0 {
    set_msg(game, "No ammo. Gather crates.", 1.1)
    game.fire_cd = 0.14
    return false
  }

  let overdrive : Bool = game.overdrive_t > 0.0
  let kind : Int = if overdrive { bullet_pierce } else { bullet_normal }
  let power : Float = if overdrive { 38.0 } else { 24.0 }

  if not(spawn_bullet(game, game.player_x, game.player_y, tx, ty, power, kind)) {
    return false
  }

  game.ammo = maxi(0, game.ammo - 1)
  game.fire_cd = if overdrive { 0.055 } else { 0.11 }

  let dir = normalize(tx - game.player_x, ty - game.player_y)
  game.player_vx = game.player_vx - dir.0 * 28.0
  game.player_vy = game.player_vy - dir.1 * 28.0

  burst(game, game.player_x, game.player_y, if overdrive { 8 } else { 5 }, 0)

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

  let near_core : Bool = dist2(game.player_x, game.player_y, core_x(), core_y()) <=
    (core_r + 130.0) * (core_r + 130.0)

  if not(near_core) {
    set_msg(game, "Move closer to generator to repair.", 1.1)
    game.repair_cd = 0.22
    return false
  }

  if game.fuel < 7.0 {
    set_msg(game, "Not enough fuel for repair.", 1.1)
    game.repair_cd = 0.22
    return false
  }

  game.fuel = maxf(0.0, game.fuel - 7.0)
  game.core_heat = minf(100.0, game.core_heat + 20.0)
  game.suit_hp = minf(100.0, game.suit_hp + 16.0)
  game.ammo = mini(400, game.ammo + 10)
  game.score = game.score + 24
  game.repair_cd = 1.10

  set_msg(game, "Generator repaired: heat stabilized.", 1.4)
  burst(game, core_x(), core_y(), 28, 2)

  true
}

///|
fn enemy_touch_damage(kind : Int) -> Float {
  if kind == enemy_brute {
    34.0
  } else if kind == enemy_wolf {
    20.0
  } else {
    14.0
  }
}

///|
fn enemy_core_damage(kind : Int) -> Float {
  if kind == enemy_brute {
    14.0
  } else if kind == enemy_wolf {
    8.0
  } else {
    6.0
  }
}

///|
fn hurt_player(game : Game, dmg : Float) -> Unit {
  if game.overdrive_t > 0.0 {
    game.suit_hp = game.suit_hp - dmg * 0.72
  } else {
    game.suit_hp = game.suit_hp - dmg
  }

  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = maxf(game.shake_t, 0.24)

  if game.suit_hp <= 0.0 {
    game.lives = game.lives - 1
    game.suit_hp = 100.0
    game.fuel = maxf(0.0, game.fuel - 18.0)
    reset_player(game)
    set_msg(game, "Suit breached. Life lost.", 1.6)
    burst(game, game.player_x, game.player_y, 34, 1)

    if game.lives <= 0 {
      finish_run(game, false)
      return
    }
  } else {
    set_msg(game, "Hostile contact.", 0.9)
    burst(game, game.player_x, game.player_y, 16, 1)
  }
}

///|
fn collect_pickup(game : Game, kind : Int, x : Float, y : Float) -> Unit {
  if kind == pickup_fuel {
    game.fuel = minf(100.0, game.fuel + 26.0)
    game.core_heat = minf(100.0, game.core_heat + 6.0)
    game.score = game.score + 16
    set_msg(game, "Fuel cache secured.", 1.2)
    burst(game, x, y, 20, 0)
  } else if kind == pickup_medkit {
    game.suit_hp = minf(100.0, game.suit_hp + 34.0)
    game.score = game.score + 16
    set_msg(game, "Medkit applied.", 1.2)
    burst(game, x, y, 18, 2)
  } else if kind == pickup_ammo {
    game.ammo = mini(460, game.ammo + 48)
    game.score = game.score + 14
    set_msg(game, "Ammo crate recovered.", 1.2)
    burst(game, x, y, 18, 0)
  } else {
    game.overdrive_t = maxf(game.overdrive_t, 7.0)
    game.score = game.score + 26
    set_msg(game, "Overdrive engaged.", 1.2)
    burst(game, x, y, 24, 2)
  }

  game.combo = mini(12, game.combo + 1)
  game.combo_t = 2.1
}

///|
fn update_player(game : Game, dt : Float) -> Unit {
  let accel : Float = if game.overdrive_t > 0.0 { 940.0 } else { 720.0 }

  game.player_vx = game.player_vx + game.move_x * accel * dt
  game.player_vy = game.player_vy + game.move_y * accel * dt

  game.player_vx = game.player_vx * (1.0 - dt * 3.4)
  game.player_vy = game.player_vy * (1.0 - dt * 3.4)

  game.player_x = game.player_x + game.player_vx * dt
  game.player_y = game.player_y + game.player_vy * dt

  let left : Float = world_left() + player_r + 6.0
  let right : Float = world_right() - player_r - 6.0
  let top : Float = world_top() + player_r + 6.0
  let bottom : Float = world_bottom() - player_r - 6.0

  if game.player_x < left {
    game.player_x = left
    game.player_vx = absf(game.player_vx) * 0.22
  } else if game.player_x > right {
    game.player_x = right
    game.player_vx = -absf(game.player_vx) * 0.22
  }

  if game.player_y < top {
    game.player_y = top
    game.player_vy = absf(game.player_vy) * 0.22
  } else if game.player_y > bottom {
    game.player_y = bottom
    game.player_vy = -absf(game.player_vy) * 0.22
  }

  if game.overdrive_t > 0.0 {
    emit_particle(
      game,
      game.player_x + randf(-6.0, 6.0),
      game.player_y + randf(-6.0, 6.0),
      randf(-80.0, 80.0),
      randf(-40.0, 40.0),
      randf(0.2, 0.5),
      randf(1.1, 2.8),
      2,
    )
  }
}

///|
fn bullet_hit_enemy(game : Game, bi : Int, ei : Int) -> Unit {
  game.enemies[ei].hp = game.enemies[ei].hp - game.bullets[bi].power

  if game.bullets[bi].kind == bullet_normal {
    game.bullets[bi].active = false
  } else {
    game.bullets[bi].power = game.bullets[bi].power * 0.72
    if game.bullets[bi].power < 8.0 {
      game.bullets[bi].active = false
    }
  }

  burst(game, game.enemies[ei].x, game.enemies[ei].y, 9, 0)

  if game.enemies[ei].hp <= 0.0 {
    let kind : Int = game.enemies[ei].kind
    game.enemies[ei].active = false

    let base_score : Int = if kind == enemy_brute {
      26
    } else if kind == enemy_wolf {
      15
    } else {
      12
    }

    game.combo = mini(18, game.combo + 1)
    game.combo_t = 2.4

    game.score = game.score + base_score + game.combo * 2

    if @raylib.get_random_value(0, 99) < 12 {
      ignore(spawn_pickup(game))
    }

    burst(game, game.enemies[ei].x, game.enemies[ei].y, 20, 1)
  }
}

///|
fn update_bullets(game : Game, dt : Float) -> Unit {
  for bi = 0; bi < game.bullets.length(); bi = bi + 1 {
    if not(game.bullets[bi].active) {
      continue
    }

    game.bullets[bi].x = game.bullets[bi].x + game.bullets[bi].vx * dt
    game.bullets[bi].y = game.bullets[bi].y + game.bullets[bi].vy * dt
    game.bullets[bi].life = game.bullets[bi].life - dt

    if game.bullets[bi].life <= 0.0 ||
      game.bullets[bi].x < world_left() - 40.0 ||
      game.bullets[bi].x > world_right() + 40.0 ||
      game.bullets[bi].y < world_top() - 40.0 ||
      game.bullets[bi].y > world_bottom() + 40.0 {
      game.bullets[bi].active = false
      continue
    }

    for ei = 0; ei < game.enemies.length(); ei = ei + 1 {
      if not(game.enemies[ei].active) {
        continue
      }

      let rr : Float = game.enemies[ei].r +
        (if game.bullets[bi].kind == bullet_pierce { 4.0 } else { 2.0 })

      if dist2(
          game.bullets[bi].x,
          game.bullets[bi].y,
          game.enemies[ei].x,
          game.enemies[ei].y,
        ) <=
        rr * rr {
        bullet_hit_enemy(game, bi, ei)

        if not(game.bullets[bi].active) {
          break
        }
      }
    }
  }
}

///|
fn enemy_speed(game : Game, kind : Int) -> Float {
  if kind == enemy_wolf {
    130.0 + Float::from_int(game.wave) * 10.0
  } else if kind == enemy_brute {
    84.0 + Float::from_int(game.wave) * 6.0
  } else {
    162.0 + Float::from_int(game.wave) * 12.0
  }
}

///|
fn update_enemies(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if not(game.enemies[i].active) {
      continue
    }

    game.enemies[i].phase = game.enemies[i].phase +
      dt * (1.2 + Float::from_int(game.enemies[i].kind))

    let target_x : Float = if game.enemies[i].kind == enemy_wolf {
      if dist2(
          game.enemies[i].x,
          game.enemies[i].y,
          game.player_x,
          game.player_y,
        ) <
        280.0 * 280.0 {
        game.player_x
      } else {
        core_x()
      }
    } else {
      core_x()
    }

    let target_y : Float = if game.enemies[i].kind == enemy_wolf {
      if dist2(
          game.enemies[i].x,
          game.enemies[i].y,
          game.player_x,
          game.player_y,
        ) <
        280.0 * 280.0 {
        game.player_y
      } else {
        core_y()
      }
    } else {
      core_y()
    }

    let dir = normalize(
      target_x - game.enemies[i].x,
      target_y - game.enemies[i].y,
    )
    let speed : Float = enemy_speed(game, game.enemies[i].kind)

    let swirl_x : Float = if game.enemies[i].kind == enemy_shard {
      sinf(game.enemies[i].phase * 5.0) * 120.0
    } else if game.enemies[i].kind == enemy_wolf {
      sinf(game.enemies[i].phase * 3.0) * 64.0
    } else {
      sinf(game.enemies[i].phase * 1.3) * 24.0
    }

    let swirl_y : Float = if game.enemies[i].kind == enemy_shard {
      cosf(game.enemies[i].phase * 4.0) * 96.0
    } else {
      cosf(game.enemies[i].phase * 1.8) * 22.0
    }

    game.enemies[i].vx = game.enemies[i].vx * (1.0 - dt * 2.2) +
      (dir.0 * speed + swirl_x) * dt * 2.2
    game.enemies[i].vy = game.enemies[i].vy * (1.0 - dt * 2.2) +
      (dir.1 * speed + swirl_y) * dt * 2.2

    game.enemies[i].x = game.enemies[i].x + game.enemies[i].vx * dt
    game.enemies[i].y = game.enemies[i].y + game.enemies[i].vy * dt

    if game.enemies[i].x < world_left() - 90.0 ||
      game.enemies[i].x > world_right() + 90.0 ||
      game.enemies[i].y < world_top() - 90.0 ||
      game.enemies[i].y > world_bottom() + 90.0 {
      game.enemies[i].active = false
      continue
    }

    let player_rr : Float = game.enemies[i].r + player_r - 3.0
    if dist2(game.enemies[i].x, game.enemies[i].y, game.player_x, game.player_y) <=
      player_rr * player_rr {
      hurt_player(game, enemy_touch_damage(game.enemies[i].kind))

      game.enemies[i].active = if game.enemies[i].kind == enemy_brute {
        true
      } else {
        false
      }

      game.enemies[i].vx = -game.enemies[i].vx * 0.5
      game.enemies[i].vy = -game.enemies[i].vy * 0.5

      if game.state != state_play {
        return
      }
    }

    let core_rr : Float = game.enemies[i].r + core_r - 6.0
    if dist2(game.enemies[i].x, game.enemies[i].y, core_x(), core_y()) <=
      core_rr * core_rr {
      game.core_heat = maxf(
        0.0,
        game.core_heat - enemy_core_damage(game.enemies[i].kind),
      )
      game.shake_t = maxf(game.shake_t, 0.30)

      set_msg(game, "Core under attack!", 0.8)
      burst(game, core_x(), core_y(), 14, 1)

      if game.enemies[i].kind == enemy_brute {
        game.enemies[i].hp = game.enemies[i].hp - 34.0
        game.enemies[i].vx = -game.enemies[i].vx * 0.8
        game.enemies[i].vy = -game.enemies[i].vy * 0.8
        if game.enemies[i].hp <= 0.0 {
          game.enemies[i].active = false
          game.score = game.score + 18
        }
      } else {
        game.enemies[i].active = false
      }
    }
  }
}

///|
fn pickup_radius(kind : Int) -> Float {
  if kind == pickup_overdrive {
    21.0
  } else if kind == pickup_fuel {
    19.0
  } else {
    17.0
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
      (game.pickups[i].vx + sinf(game.pickups[i].phase * 2.0) * 24.0) * dt
    game.pickups[i].y = game.pickups[i].y +
      (game.pickups[i].vy + Float::from_int(game.wave) * 3.0) * dt

    if game.pickups[i].x < world_left() + 16.0 {
      game.pickups[i].x = world_left() + 16.0
      game.pickups[i].vx = absf(game.pickups[i].vx) * 0.6
    }
    if game.pickups[i].x > world_right() - 16.0 {
      game.pickups[i].x = world_right() - 16.0
      game.pickups[i].vx = -absf(game.pickups[i].vx) * 0.6
    }

    if game.pickups[i].y > world_bottom() + 70.0 {
      game.pickups[i].active = false
      continue
    }

    let rr : Float = player_r + pickup_radius(game.pickups[i].kind)
    if dist2(game.player_x, game.player_y, game.pickups[i].x, game.pickups[i].y) <=
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

  let mut best_x : Float = core_x()
  let mut best_y : Float = core_y()
  let mut found_pickup : Bool = false

  if game.fuel < 42.0 || game.ammo < 40 {
    let mut best_d2 : Float = 1_000_000_000.0
    for i = 0; i < game.pickups.length(); i = i + 1 {
      if not(game.pickups[i].active) {
        continue
      }

      let want : Bool = if game.fuel < 42.0 {
        game.pickups[i].kind == pickup_fuel
      } else {
        game.pickups[i].kind == pickup_ammo
      }

      if not(want) {
        continue
      }

      let d2 : Float = dist2(
        game.player_x,
        game.player_y,
        game.pickups[i].x,
        game.pickups[i].y,
      )

      if d2 < best_d2 {
        best_d2 = d2
        best_x = game.pickups[i].x
        best_y = game.pickups[i].y
        found_pickup = true
      }
    }
  }

  if not(found_pickup) {
    let mut safest_score : Float = 1_000_000_000.0

    for lane = 0; lane < 5; lane = lane + 1 {
      let lx : Float = world_left() +
        120.0 +
        Float::from_int(lane) * (Float::from_int(world_w) - 240.0) / 4.0
      let ly : Float = core_y() + 180.0

      let mut threat : Float = 0.0
      for i = 0; i < game.enemies.length(); i = i + 1 {
        if not(game.enemies[i].active) {
          continue
        }

        let d2 : Float = dist2(lx, ly, game.enemies[i].x, game.enemies[i].y)
        let w : Float = if game.enemies[i].kind == enemy_brute {
          1.4
        } else {
          1.0
        }
        threat = threat + w * 42000.0 / maxf(120.0, d2)
      }

      if threat < safest_score {
        safest_score = threat
        best_x = lx
        best_y = ly
      }
    }
  }

  game.hint_x = best_x
  game.hint_y = best_y
  game.hint_t = 2.8
  game.hint_left = game.hint_left - 1
  game.score = maxi(0, game.score - 6)

  if found_pickup {
    set_msg(game, "Hint: supply route marked.", 1.3)
  } else {
    set_msg(game, "Hint: safest lane marked.", 1.3)
  }

  true
}

///|
fn passive_heat_decay(game : Game, dt : Float) -> Unit {
  let storm : Float = 0.5 +
    sinf(game.storm_t * 1.2) * 0.3 +
    cosf(game.storm_t * 0.7) * 0.2

  let enemy_pressure : Float = Float::from_int(game.wave) * 0.16
  let decay : Float = (1.35 + enemy_pressure + storm) * dt
  game.core_heat = maxf(0.0, game.core_heat - decay)
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

  game.fire_cd = maxf(0.0, game.fire_cd - step)
  game.repair_cd = maxf(0.0, game.repair_cd - step)
  game.overdrive_t = maxf(0.0, game.overdrive_t - step)

  update_particles(game, step)

  if game.state != state_play {
    return
  }

  game.game_t = game.game_t + step
  game.storm_t = game.storm_t + step

  if game.game_t >= survival_time_goal {
    finish_run(game, true)
    return
  }

  game.wave = clampi(1 + (game.game_t / 22.0).to_int(), 1, 12)

  passive_heat_decay(game, step)

  game.fuel = maxf(
    0.0,
    game.fuel - (0.95 + Float::from_int(game.wave) * 0.03) * step,
  )
  if game.fuel <= 0.0 {
    game.suit_hp = maxf(0.0, game.suit_hp - 4.0 * step)
  }

  if game.suit_hp <= 0.0 {
    hurt_player(game, 100.0)
    if game.state != state_play {
      return
    }
  }

  game.spawn_t = game.spawn_t + step
  let spawn_interval : Float = maxf(
    0.18,
    0.70 - Float::from_int(game.wave) * 0.038,
  )
  while game.spawn_t >= spawn_interval {
    game.spawn_t = game.spawn_t - spawn_interval
    ignore(spawn_enemy(game))
  }

  game.pickup_t = game.pickup_t + step
  if game.pickup_t >= 1.95 {
    game.pickup_t = 0.0
    ignore(spawn_pickup(game))
  }

  update_player(game, step)
  update_bullets(game, step)
  update_enemies(game, step)
  if game.state != state_play {
    return
  }
  update_pickups(game, step)

  if game.core_heat <= 0.0 {
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
