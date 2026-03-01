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
  for enemy in game.enemies {
    enemy.active = false
    enemy.x = 0.0
    enemy.y = 0.0
    enemy.vx = 0.0
    enemy.vy = 0.0
    enemy.r = 0.0
    enemy.hp = 0.0
    enemy.kind = @types.enemy_wolf
    enemy.phase = 0.0
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

  for bullet in game.bullets {
    bullet.active = false
    bullet.x = 0.0
    bullet.y = 0.0
    bullet.vx = 0.0
    bullet.vy = 0.0
    bullet.life = 0.0
    bullet.power = 0.0
    bullet.kind = @types.bullet_normal
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
      @types.randf(-260.0, 140.0),
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

    let damp : Float = if particle.kind == 2 { 2.7 } else { 1.9 }
    particle.vx = particle.vx * (1.0 - dt * damp)
    particle.vy = particle.vy * (1.0 - dt * (damp - 0.4)) +
      dt * (if particle.kind == 1 { 180.0 } else { 120.0 })
  }
}

///|
fn reset_player(game : @types.Game) -> Unit {
  game.player_x = Float::from_int(@types.world_x0 + @types.world_w / 2)
  game.player_y = Float::from_int(@types.world_y0 + @types.world_h - 180)
  game.player_vx = 0.0
  game.player_vy = 0.0
  game.move_x = 0.0
  game.move_y = 0.0
  game.aim_x = @types.core_x()
  game.aim_y = @types.core_y()
}

///|
fn start_run(game : @types.Game) -> Unit {
  clear_world(game)
  clear_particles(game)

  game.state = @types.Play
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
  game.hint_x = @types.core_x()
  game.hint_y = @types.core_y()

  game.msg = ""
  game.msg_t = 0.0
  game.shake_t = 0.0
  game.win = false

  @types.set_msg(game, "Defend core heat for 200s. Repair near generator.", 2.8)
}

///|
fn finish_run(game : @types.Game, win : Bool) -> Unit {
  if game.state != @types.Play {
    return
  }

  game.state = @types.Result
  game.win = win
  game.move_x = 0.0
  game.move_y = 0.0

  if game.score > game.best_score {
    game.best_score = game.score
  }

  if win {
    @types.set_msg(game, "Outpost survived the polar night.", 3.0)
    burst(game, @types.core_x(), @types.core_y(), 70, 2)
  } else {
    @types.set_msg(game, "Outpost collapsed in the storm.", 3.0)
    burst(game, @types.core_x(), @types.core_y(), 56, 1)
  }
}

///|
fn spawn_enemy(game : @types.Game) -> Bool {
  for enemy in game.enemies {
    if enemy.active {
      continue
    }

    let roll : Int = @raylib.get_random_value(0, 99)
    let kind : Int = if roll < 56 {
      @types.enemy_wolf
    } else if roll < 84 {
      @types.enemy_brute
    } else {
      @types.enemy_shard
    }

    let side : Int = @raylib.get_random_value(0, 3)
    if side == 0 {
      enemy.x = @types.randf(
        @types.world_left() + 20.0,
        @types.world_right() - 20.0,
      )
      enemy.y = @types.world_top() - 40.0
    } else if side == 1 {
      enemy.x = @types.randf(
        @types.world_left() + 20.0,
        @types.world_right() - 20.0,
      )
      enemy.y = @types.world_bottom() + 40.0
    } else if side == 2 {
      enemy.x = @types.world_left() - 40.0
      enemy.y = @types.randf(
        @types.world_top() + 20.0,
        @types.world_bottom() - 20.0,
      )
    } else {
      enemy.x = @types.world_right() + 40.0
      enemy.y = @types.randf(
        @types.world_top() + 20.0,
        @types.world_bottom() - 20.0,
      )
    }

    enemy.active = true
    enemy.kind = kind

    if kind == @types.enemy_wolf {
      enemy.r = @types.randf(17.0, 22.0)
      enemy.hp = @types.randf(24.0, 36.0) + Float::from_int(game.wave) * 2.4
    } else if kind == @types.enemy_brute {
      enemy.r = @types.randf(26.0, 34.0)
      enemy.hp = @types.randf(60.0, 82.0) + Float::from_int(game.wave) * 4.0
    } else {
      enemy.r = @types.randf(13.0, 18.0)
      enemy.hp = @types.randf(16.0, 24.0) + Float::from_int(game.wave) * 1.8
    }

    enemy.vx = 0.0
    enemy.vy = 0.0
    enemy.phase = @types.randf(0.0, 6.28)

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
    pickup.y = @types.world_top() - @types.randf(60.0, 260.0)
    pickup.vx = @types.randf(-36.0, 36.0)
    pickup.vy = @types.randf(112.0, 170.0)
    pickup.phase = @types.randf(0.0, 6.28)

    let roll : Int = @raylib.get_random_value(0, 99)
    pickup.kind = if roll < 38 {
      @types.pickup_fuel
    } else if roll < 62 {
      @types.pickup_medkit
    } else if roll < 86 {
      @types.pickup_ammo
    } else {
      @types.pickup_overdrive
    }

    return true
  }

  false
}

///|
fn spawn_bullet(
  game : @types.Game,
  x : Float,
  y : Float,
  tx : Float,
  ty : Float,
  power : Float,
  kind : Int,
) -> Bool {
  for bullet in game.bullets {
    if bullet.active {
      continue
    }

    let dir = @types.normalize(tx - x, ty - y)
    let speed : Float = if kind == @types.bullet_pierce { 920.0 } else { 760.0 }

    bullet.active = true
    bullet.x = x
    bullet.y = y
    bullet.vx = dir.0 * speed
    bullet.vy = dir.1 * speed
    bullet.life = if kind == @types.bullet_pierce { 1.8 } else { 1.4 }
    bullet.power = power
    bullet.kind = kind

    return true
  }

  false
}

///|
fn try_fire(game : @types.Game, tx : Float, ty : Float) -> Bool {
  if game.state != @types.Play {
    return false
  }
  if game.fire_cd > 0.0 {
    return false
  }
  if game.ammo <= 0 {
    @types.set_msg(game, "No ammo. Gather crates.", 1.1)
    game.fire_cd = 0.14
    return false
  }

  let overdrive : Bool = game.overdrive_t > 0.0
  let kind : Int = if overdrive {
    @types.bullet_pierce
  } else {
    @types.bullet_normal
  }
  let power : Float = if overdrive { 38.0 } else { 24.0 }

  if not(spawn_bullet(game, game.player_x, game.player_y, tx, ty, power, kind)) {
    return false
  }

  game.ammo = @types.maxi(0, game.ammo - 1)
  game.fire_cd = if overdrive { 0.055 } else { 0.11 }

  let dir = @types.normalize(tx - game.player_x, ty - game.player_y)
  game.player_vx = game.player_vx - dir.0 * 28.0
  game.player_vy = game.player_vy - dir.1 * 28.0

  burst(game, game.player_x, game.player_y, if overdrive { 8 } else { 5 }, 0)

  true
}

///|
fn try_repair(game : @types.Game) -> Bool {
  if game.state != @types.Play {
    return false
  }
  if game.repair_cd > 0.0 {
    return false
  }

  let near_core : Bool = @types.dist2(
      game.player_x,
      game.player_y,
      @types.core_x(),
      @types.core_y(),
    ) <=
    (@types.core_r + 130.0) * (@types.core_r + 130.0)

  if not(near_core) {
    @types.set_msg(game, "Move closer to generator to repair.", 1.1)
    game.repair_cd = 0.22
    return false
  }

  if game.fuel < 7.0 {
    @types.set_msg(game, "Not enough fuel for repair.", 1.1)
    game.repair_cd = 0.22
    return false
  }

  game.fuel = @types.maxf(0.0, game.fuel - 7.0)
  game.core_heat = @types.minf(100.0, game.core_heat + 20.0)
  game.suit_hp = @types.minf(100.0, game.suit_hp + 16.0)
  game.ammo = @types.mini(400, game.ammo + 10)
  game.score = game.score + 24
  game.repair_cd = 1.10

  @types.set_msg(game, "Generator repaired: heat stabilized.", 1.4)
  burst(game, @types.core_x(), @types.core_y(), 28, 2)

  true
}

///|
fn enemy_touch_damage(kind : Int) -> Float {
  if kind == @types.enemy_brute {
    34.0
  } else if kind == @types.enemy_wolf {
    20.0
  } else {
    14.0
  }
}

///|
fn enemy_core_damage(kind : Int) -> Float {
  if kind == @types.enemy_brute {
    14.0
  } else if kind == @types.enemy_wolf {
    8.0
  } else {
    6.0
  }
}

///|
fn hurt_player(game : @types.Game, dmg : Float) -> Unit {
  if game.overdrive_t > 0.0 {
    game.suit_hp = game.suit_hp - dmg * 0.72
  } else {
    game.suit_hp = game.suit_hp - dmg
  }

  game.combo = 0
  game.combo_t = 0.0
  game.shake_t = @types.maxf(game.shake_t, 0.24)

  if game.suit_hp <= 0.0 {
    game.lives = game.lives - 1
    game.suit_hp = 100.0
    game.fuel = @types.maxf(0.0, game.fuel - 18.0)
    reset_player(game)
    @types.set_msg(game, "Suit breached. Life lost.", 1.6)
    burst(game, game.player_x, game.player_y, 34, 1)

    if game.lives <= 0 {
      finish_run(game, false)
      return
    }
  } else {
    @types.set_msg(game, "Hostile contact.", 0.9)
    burst(game, game.player_x, game.player_y, 16, 1)
  }
}

///|
fn collect_pickup(game : @types.Game, kind : Int, x : Float, y : Float) -> Unit {
  if kind == @types.pickup_fuel {
    game.fuel = @types.minf(100.0, game.fuel + 26.0)
    game.core_heat = @types.minf(100.0, game.core_heat + 6.0)
    game.score = game.score + 16
    @types.set_msg(game, "Fuel cache secured.", 1.2)
    burst(game, x, y, 20, 0)
  } else if kind == @types.pickup_medkit {
    game.suit_hp = @types.minf(100.0, game.suit_hp + 34.0)
    game.score = game.score + 16
    @types.set_msg(game, "Medkit applied.", 1.2)
    burst(game, x, y, 18, 2)
  } else if kind == @types.pickup_ammo {
    game.ammo = @types.mini(460, game.ammo + 48)
    game.score = game.score + 14
    @types.set_msg(game, "Ammo crate recovered.", 1.2)
    burst(game, x, y, 18, 0)
  } else {
    game.overdrive_t = @types.maxf(game.overdrive_t, 7.0)
    game.score = game.score + 26
    @types.set_msg(game, "Overdrive engaged.", 1.2)
    burst(game, x, y, 24, 2)
  }

  game.combo = @types.mini(12, game.combo + 1)
  game.combo_t = 2.1
}

///|
fn update_player(game : @types.Game, dt : Float) -> Unit {
  let accel : Float = if game.overdrive_t > 0.0 { 940.0 } else { 720.0 }

  game.player_vx = game.player_vx + game.move_x * accel * dt
  game.player_vy = game.player_vy + game.move_y * accel * dt

  game.player_vx = game.player_vx * (1.0 - dt * 3.4)
  game.player_vy = game.player_vy * (1.0 - dt * 3.4)

  game.player_x = game.player_x + game.player_vx * dt
  game.player_y = game.player_y + game.player_vy * dt

  let left : Float = @types.world_left() + @types.player_r + 6.0
  let right : Float = @types.world_right() - @types.player_r - 6.0
  let top : Float = @types.world_top() + @types.player_r + 6.0
  let bottom : Float = @types.world_bottom() - @types.player_r - 6.0

  if game.player_x < left {
    game.player_x = left
    game.player_vx = @types.absf(game.player_vx) * 0.22
  } else if game.player_x > right {
    game.player_x = right
    game.player_vx = -@types.absf(game.player_vx) * 0.22
  }

  if game.player_y < top {
    game.player_y = top
    game.player_vy = @types.absf(game.player_vy) * 0.22
  } else if game.player_y > bottom {
    game.player_y = bottom
    game.player_vy = -@types.absf(game.player_vy) * 0.22
  }

  if game.overdrive_t > 0.0 {
    emit_particle(
      game,
      game.player_x + @types.randf(-6.0, 6.0),
      game.player_y + @types.randf(-6.0, 6.0),
      @types.randf(-80.0, 80.0),
      @types.randf(-40.0, 40.0),
      @types.randf(0.2, 0.5),
      @types.randf(1.1, 2.8),
      2,
    )
  }
}

///|
fn bullet_hit_enemy(game : @types.Game, bi : Int, ei : Int) -> Unit {
  game.enemies[ei].hp = game.enemies[ei].hp - game.bullets[bi].power

  if game.bullets[bi].kind == @types.bullet_normal {
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

    let base_score : Int = if kind == @types.enemy_brute {
      26
    } else if kind == @types.enemy_wolf {
      15
    } else {
      12
    }

    game.combo = @types.mini(18, game.combo + 1)
    game.combo_t = 2.4

    game.score = game.score + base_score + game.combo * 2

    if @raylib.get_random_value(0, 99) < 12 {
      ignore(spawn_pickup(game))
    }

    burst(game, game.enemies[ei].x, game.enemies[ei].y, 20, 1)
  }
}

///|
fn update_bullets(game : @types.Game, dt : Float) -> Unit {
  for bi in 0..<game.bullets.length() {
    if not(game.bullets[bi].active) {
      continue
    }

    game.bullets[bi].x = game.bullets[bi].x + game.bullets[bi].vx * dt
    game.bullets[bi].y = game.bullets[bi].y + game.bullets[bi].vy * dt
    game.bullets[bi].life = game.bullets[bi].life - dt

    if game.bullets[bi].life <= 0.0 ||
      game.bullets[bi].x < @types.world_left() - 40.0 ||
      game.bullets[bi].x > @types.world_right() + 40.0 ||
      game.bullets[bi].y < @types.world_top() - 40.0 ||
      game.bullets[bi].y > @types.world_bottom() + 40.0 {
      game.bullets[bi].active = false
      continue
    }

    for ei in 0..<game.enemies.length() {
      if not(game.enemies[ei].active) {
        continue
      }

      let rr : Float = game.enemies[ei].r +
        (if game.bullets[bi].kind == @types.bullet_pierce { 4.0 } else { 2.0 })

      if @types.dist2(
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
fn enemy_speed(game : @types.Game, kind : Int) -> Float {
  if kind == @types.enemy_wolf {
    130.0 + Float::from_int(game.wave) * 10.0
  } else if kind == @types.enemy_brute {
    84.0 + Float::from_int(game.wave) * 6.0
  } else {
    162.0 + Float::from_int(game.wave) * 12.0
  }
}

///|
fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  for enemy in game.enemies {
    if not(enemy.active) {
      continue
    }

    enemy.phase = enemy.phase + dt * (1.2 + Float::from_int(enemy.kind))

    let target_x : Float = if enemy.kind == @types.enemy_wolf {
      if @types.dist2(enemy.x, enemy.y, game.player_x, game.player_y) <
        280.0 * 280.0 {
        game.player_x
      } else {
        @types.core_x()
      }
    } else {
      @types.core_x()
    }

    let target_y : Float = if enemy.kind == @types.enemy_wolf {
      if @types.dist2(enemy.x, enemy.y, game.player_x, game.player_y) <
        280.0 * 280.0 {
        game.player_y
      } else {
        @types.core_y()
      }
    } else {
      @types.core_y()
    }

    let dir = @types.normalize(target_x - enemy.x, target_y - enemy.y)
    let speed : Float = enemy_speed(game, enemy.kind)

    let swirl_x : Float = if enemy.kind == @types.enemy_shard {
      @types.sinf(enemy.phase * 5.0) * 120.0
    } else if enemy.kind == @types.enemy_wolf {
      @types.sinf(enemy.phase * 3.0) * 64.0
    } else {
      @types.sinf(enemy.phase * 1.3) * 24.0
    }

    let swirl_y : Float = if enemy.kind == @types.enemy_shard {
      @types.cosf(enemy.phase * 4.0) * 96.0
    } else {
      @types.cosf(enemy.phase * 1.8) * 22.0
    }

    enemy.vx = enemy.vx * (1.0 - dt * 2.2) +
      (dir.0 * speed + swirl_x) * dt * 2.2
    enemy.vy = enemy.vy * (1.0 - dt * 2.2) +
      (dir.1 * speed + swirl_y) * dt * 2.2

    enemy.x = enemy.x + enemy.vx * dt
    enemy.y = enemy.y + enemy.vy * dt

    if enemy.x < @types.world_left() - 90.0 ||
      enemy.x > @types.world_right() + 90.0 ||
      enemy.y < @types.world_top() - 90.0 ||
      enemy.y > @types.world_bottom() + 90.0 {
      enemy.active = false
      continue
    }

    let player_rr : Float = enemy.r + @types.player_r - 3.0
    if @types.dist2(enemy.x, enemy.y, game.player_x, game.player_y) <=
      player_rr * player_rr {
      hurt_player(game, enemy_touch_damage(enemy.kind))

      enemy.active = if enemy.kind == @types.enemy_brute { true } else { false }

      enemy.vx = -enemy.vx * 0.5
      enemy.vy = -enemy.vy * 0.5

      if game.state != @types.Play {
        return
      }
    }

    let core_rr : Float = enemy.r + @types.core_r - 6.0
    if @types.dist2(enemy.x, enemy.y, @types.core_x(), @types.core_y()) <=
      core_rr * core_rr {
      game.core_heat = @types.maxf(
        0.0,
        game.core_heat - enemy_core_damage(enemy.kind),
      )
      game.shake_t = @types.maxf(game.shake_t, 0.30)

      @types.set_msg(game, "Core under attack!", 0.8)
      burst(game, @types.core_x(), @types.core_y(), 14, 1)

      if enemy.kind == @types.enemy_brute {
        enemy.hp = enemy.hp - 34.0
        enemy.vx = -enemy.vx * 0.8
        enemy.vy = -enemy.vy * 0.8
        if enemy.hp <= 0.0 {
          enemy.active = false
          game.score = game.score + 18
        }
      } else {
        enemy.active = false
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
      (pickup.vx + @types.sinf(pickup.phase * 2.0) * 24.0) * dt
    pickup.y = pickup.y + (pickup.vy + Float::from_int(game.wave) * 3.0) * dt

    if pickup.x < @types.world_left() + 16.0 {
      pickup.x = @types.world_left() + 16.0
      pickup.vx = @types.absf(pickup.vx) * 0.6
    }
    if pickup.x > @types.world_right() - 16.0 {
      pickup.x = @types.world_right() - 16.0
      pickup.vx = -@types.absf(pickup.vx) * 0.6
    }

    if pickup.y > @types.world_bottom() + 70.0 {
      pickup.active = false
      continue
    }

    let rr : Float = @types.player_r + @types.pickup_radius(pickup.kind)
    if @types.dist2(game.player_x, game.player_y, pickup.x, pickup.y) <= rr * rr {
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
  if game.state != @types.Play || game.hint_left <= 0 {
    return false
  }

  let mut best_x : Float = @types.core_x()
  let mut best_y : Float = @types.core_y()
  let mut found_pickup : Bool = false

  if game.fuel < 42.0 || game.ammo < 40 {
    let mut best_d2 : Float = 1_000_000_000.0
    for pickup in game.pickups {
      if not(pickup.active) {
        continue
      }

      let want : Bool = if game.fuel < 42.0 {
        pickup.kind == @types.pickup_fuel
      } else {
        pickup.kind == @types.pickup_ammo
      }

      if not(want) {
        continue
      }

      let d2 : Float = @types.dist2(
        game.player_x,
        game.player_y,
        pickup.x,
        pickup.y,
      )

      if d2 < best_d2 {
        best_d2 = d2
        best_x = pickup.x
        best_y = pickup.y
        found_pickup = true
      }
    }
  }

  if not(found_pickup) {
    let mut safest_score : Float = 1_000_000_000.0

    for lane in 0..<5 {
      let lx : Float = @types.world_left() +
        120.0 +
        Float::from_int(lane) * (Float::from_int(@types.world_w) - 240.0) / 4.0
      let ly : Float = @types.core_y() + 180.0

      let mut threat : Float = 0.0
      for enemy in game.enemies {
        if not(enemy.active) {
          continue
        }

        let d2 : Float = @types.dist2(lx, ly, enemy.x, enemy.y)
        let w : Float = if enemy.kind == @types.enemy_brute { 1.4 } else { 1.0 }
        threat = threat + w * 42000.0 / @types.maxf(120.0, d2)
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
  game.score = @types.maxi(0, game.score - 6)

  if found_pickup {
    @types.set_msg(game, "Hint: supply route marked.", 1.3)
  } else {
    @types.set_msg(game, "Hint: safest lane marked.", 1.3)
  }

  true
}

///|
fn passive_heat_decay(game : @types.Game, dt : Float) -> Unit {
  let storm : Float = 0.5 +
    @types.sinf(game.storm_t * 1.2) * 0.3 +
    @types.cosf(game.storm_t * 0.7) * 0.2

  let enemy_pressure : Float = Float::from_int(game.wave) * 0.16
  let decay : Float = (1.35 + enemy_pressure + storm) * dt
  game.core_heat = @types.maxf(0.0, game.core_heat - decay)
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

  game.fire_cd = @types.maxf(0.0, game.fire_cd - step)
  game.repair_cd = @types.maxf(0.0, game.repair_cd - step)
  game.overdrive_t = @types.maxf(0.0, game.overdrive_t - step)

  update_particles(game, step)

  if game.state != @types.Play {
    return
  }

  game.game_t = game.game_t + step
  game.storm_t = game.storm_t + step

  if game.game_t >= @types.survival_time_goal {
    finish_run(game, true)
    return
  }

  game.wave = @types.clampi(1 + (game.game_t / 22.0).to_int(), 1, 12)

  passive_heat_decay(game, step)

  game.fuel = @types.maxf(
    0.0,
    game.fuel - (0.95 + Float::from_int(game.wave) * 0.03) * step,
  )
  if game.fuel <= 0.0 {
    game.suit_hp = @types.maxf(0.0, game.suit_hp - 4.0 * step)
  }

  if game.suit_hp <= 0.0 {
    hurt_player(game, 100.0)
    if game.state != @types.Play {
      return
    }
  }

  game.spawn_t = game.spawn_t + step
  let spawn_interval : Float = @types.maxf(
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
  if game.state != @types.Play {
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

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  match game.state {
    Title => {
      update_title_input(game)
      update_play(game, dt)
    }
    Play => {
      update_play_input(game, dt)
      update_play(game, dt)
    }
    Result => {
      update_result_input(game)
      update_play(game, dt)
    }
  }
}
