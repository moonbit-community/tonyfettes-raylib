// Enemy AI and projectile updates

pub fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let e = game.enemies[i]
    if not(e.active) {
      continue i + 1
    }
    // Hit flash timer
    if e.hit_flash > 0.0 {
      e.hit_flash -= dt
      if e.hit_flash < 0.0 {
        e.hit_flash = 0.0
      }
    }
    // Stun timer
    if e.stun_timer > 0.0 {
      e.stun_timer -= dt
      if e.stun_timer < 0.0 {
        e.stun_timer = 0.0
      }
      continue i + 1
    }
    // Slow timer
    if e.slow_timer > 0.0 {
      e.slow_timer -= dt
      if e.slow_timer < 0.0 {
        e.slow_timer = 0.0
        e.speed_mult = 1.0
      }
    }
    // Ability cooldown
    if e.ability_cooldown > 0.0 {
      e.ability_cooldown -= dt
      if e.ability_cooldown < 0.0 {
        e.ability_cooldown = 0.0
      }
    }
    // Mimic special: don't move until alerted
    if e.kind == @types.enemy_mimic && not(e.alerted) {
      continue i + 1
    }
    // Check if player is in sight range
    let dist = @types.dist2d(e.x, e.z, game.player_x, game.player_z)
    if dist < @types.enemy_sight_range {
      e.alerted = true
    }
    if not(e.alerted) {
      // Patrol behavior for non-alerted enemies
      update_patrol(game, e, dt)
      continue i + 1
    }
    // Attack cooldown
    if e.attack_timer > 0.0 {
      e.attack_timer -= dt
      if e.attack_timer < 0.0 {
        e.attack_timer = 0.0
      }
    }
    // Update facing angle toward player
    let dx = game.player_x - e.x
    let dz = game.player_z - e.z
    e.facing_angle = @math.atan2f(dx, dz)
    // Movement and AI based on type
    if e.kind == @types.enemy_skeleton {
      update_melee_enemy(game, e, dt, dist)
    } else if e.kind == @types.enemy_golem {
      update_melee_enemy(game, e, dt, dist)
    } else if e.kind == @types.enemy_wraith {
      update_melee_enemy(game, e, dt, dist)
    } else if e.kind == @types.enemy_dragon_boss {
      update_boss_enemy(game, e, dt, dist)
    } else if e.kind == @types.enemy_archer {
      update_archer_enemy(game, e, dt, dist)
    } else if e.kind == @types.enemy_slime {
      update_slime_enemy(game, e, dt, dist)
    } else if e.kind == @types.enemy_bat {
      update_bat_enemy(game, e, dt, dist)
    } else if e.kind == @types.enemy_spider {
      update_spider_enemy(game, e, dt, dist)
    } else if e.kind == @types.enemy_minotaur {
      update_minotaur_enemy(game, e, dt, dist)
    } else if e.kind == @types.enemy_lich {
      update_lich_enemy(game, e, dt, dist)
    } else if e.kind == @types.enemy_mimic {
      update_melee_enemy(game, e, dt, dist)
    }
  }
}

fn update_patrol(game : @types.Game, e : @types.Enemy, dt : Float) -> Unit {
  e.move_timer += dt
  if e.move_timer > 2.0 {
    e.move_timer = 0.0
    // Pick a new random patrol direction
    e.patrol_x = e.x + @types.rand_rangef(game, -3.0, 3.0)
    e.patrol_z = e.z + @types.rand_rangef(game, -3.0, 3.0)
  }
  // Move toward patrol point slowly
  let ddx = e.patrol_x - e.x
  let ddz = e.patrol_z - e.z
  let dd = (ddx * ddx + ddz * ddz).sqrt()
  if dd > 0.5 {
    let nx = ddx / dd
    let nz = ddz / dd
    let speed : Float = 0.8
    let new_x = e.x + nx * speed * dt
    let new_z = e.z + nz * speed * dt
    let radius : Float = 0.4
    if not(@types.is_blocked(game, new_x, e.z, radius)) {
      e.x = new_x
    }
    if not(@types.is_blocked(game, e.x, new_z, radius)) {
      e.z = new_z
    }
  }
}

fn update_melee_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float
) -> Unit {
  // Choose move speed based on type
  let base_speed : Float = if e.kind == @types.enemy_wraith {
    @types.wraith_move_speed
  } else if e.kind == @types.enemy_golem {
    @types.golem_move_speed
  } else if e.kind == @types.enemy_dragon_boss {
    @types.golem_move_speed
  } else {
    @types.enemy_move_speed
  }
  let move_speed = base_speed * e.speed_mult
  // Move towards player if not in melee range
  let melee_range : Float = if e.kind == @types.enemy_dragon_boss {
    @types.enemy_melee_range + 1.0
  } else {
    @types.enemy_melee_range
  }
  if dist > melee_range {
    // Move toward player
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let nx = dir.0
    let nz = dir.1
    let new_x = e.x + nx * move_speed * dt
    let new_z = e.z + nz * move_speed * dt
    let radius : Float = 0.4
    if not(@types.is_blocked(game, new_x, e.z, radius)) {
      e.x = new_x
    }
    if not(@types.is_blocked(game, e.x, new_z, radius)) {
      e.z = new_z
    }
  } else {
    // In melee range - attack
    if e.attack_timer <= 0.0 {
      damage_player(game, e.atk)
      e.attack_timer = @types.enemy_attack_cooldown
      @types.spawn_particles(
        game, game.player_x, 1.0, game.player_z, 6, 255, 80, 80,
      )
      @types.add_message(
        game,
        "\{@types.get_enemy_name(e.kind)} attacks for \{@types.maxi(1, e.atk - @types.calc_player_defense(game))} damage!",
        255, 100, 80,
      )
    }
  }
}

fn update_archer_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float
) -> Unit {
  // Archers try to maintain distance
  let preferred_dist : Float = 8.0
  let move_speed = @types.enemy_move_speed * e.speed_mult
  if dist < 4.0 {
    // Back away
    let dx = e.x - game.player_x
    let dz = e.z - game.player_z
    let d = (dx * dx + dz * dz).sqrt()
    if d > 0.1 {
      let nx = dx / d
      let nz = dz / d
      let new_x = e.x + nx * move_speed * dt
      let new_z = e.z + nz * move_speed * dt
      let radius : Float = 0.4
      if not(@types.is_blocked(game, new_x, e.z, radius)) {
        e.x = new_x
      }
      if not(@types.is_blocked(game, e.x, new_z, radius)) {
        e.z = new_z
      }
    }
  } else if dist > preferred_dist + 2.0 {
    // Move closer
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let new_x = e.x + dir.0 * move_speed * dt
    let new_z = e.z + dir.1 * move_speed * dt
    let radius : Float = 0.4
    if not(@types.is_blocked(game, new_x, e.z, radius)) {
      e.x = new_x
    }
    if not(@types.is_blocked(game, e.x, new_z, radius)) {
      e.z = new_z
    }
  }
  // Shoot at player
  if dist < @types.archer_range && e.attack_timer <= 0.0 {
    shoot_projectile(game, e)
    e.attack_timer = @types.archer_shoot_cooldown
  }
  ignore(dt)
}

fn update_slime_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float
) -> Unit {
  // Slimes are slow but bounce toward player
  let move_speed = @types.slime_move_speed * e.speed_mult
  let melee_range = @types.enemy_melee_range
  if dist > melee_range {
    // Bounce movement - hop every second
    e.move_timer += dt
    if e.move_timer > 0.8 {
      e.move_timer = 0.0
      let dir = @types.pathfind_step(
        game, e.x, e.z, game.player_x, game.player_z,
      )
      let hop_dist = move_speed * 0.5
      let new_x = e.x + dir.0 * hop_dist
      let new_z = e.z + dir.1 * hop_dist
      let radius : Float = 0.4
      if not(@types.is_blocked(game, new_x, e.z, radius)) {
        e.x = new_x
      }
      if not(@types.is_blocked(game, e.x, new_z, radius)) {
        e.z = new_z
      }
      // Spawn slime trail particles
      @types.spawn_particles(game, e.x, 0.2, e.z, 2, 50, 200, 50)
    }
  } else {
    // Attack
    if e.attack_timer <= 0.0 {
      damage_player(game, e.atk)
      e.attack_timer = @types.enemy_attack_cooldown
      @types.spawn_particles(
        game, game.player_x, 0.5, game.player_z, 4, 50, 200, 50,
      )
    }
  }
}

fn update_bat_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float
) -> Unit {
  // Bats have fast erratic movement
  let move_speed = @types.bat_move_speed * e.speed_mult
  let melee_range : Float = 1.8
  // Add erratic movement offset
  e.move_timer += dt * 5.0
  let erratic_x = @math.sinf(e.move_timer * 3.0) * 1.5
  let erratic_z = @math.cosf(e.move_timer * 2.5) * 1.5
  if dist > melee_range {
    let dx = game.player_x + erratic_x - e.x
    let dz = game.player_z + erratic_z - e.z
    let d = (dx * dx + dz * dz).sqrt()
    if d > 0.1 {
      let nx = dx / d
      let nz = dz / d
      let new_x = e.x + nx * move_speed * dt
      let new_z = e.z + nz * move_speed * dt
      let radius : Float = 0.3
      if not(@types.is_blocked(game, new_x, e.z, radius)) {
        e.x = new_x
      }
      if not(@types.is_blocked(game, e.x, new_z, radius)) {
        e.z = new_z
      }
    }
  } else {
    // Swooping attack
    if e.attack_timer <= 0.0 {
      damage_player(game, e.atk)
      e.attack_timer = 0.8
      @types.spawn_particles(
        game, game.player_x, 1.5, game.player_z, 3, 80, 60, 40,
      )
    }
  }
}

fn update_spider_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float
) -> Unit {
  // Spiders are medium speed, can slow player with web
  let move_speed = @types.spider_move_speed * e.speed_mult
  let melee_range = @types.enemy_melee_range
  if dist > melee_range {
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let new_x = e.x + dir.0 * move_speed * dt
    let new_z = e.z + dir.1 * move_speed * dt
    let radius : Float = 0.4
    if not(@types.is_blocked(game, new_x, e.z, radius)) {
      e.x = new_x
    }
    if not(@types.is_blocked(game, e.x, new_z, radius)) {
      e.z = new_z
    }
    // Web attack at range
    if dist < 6.0 && e.ability_cooldown <= 0.0 {
      // Shoot web projectile
      shoot_web(game, e)
      e.ability_cooldown = 4.0
    }
  } else {
    // Melee attack
    if e.attack_timer <= 0.0 {
      damage_player(game, e.atk)
      e.attack_timer = @types.enemy_attack_cooldown
      @types.spawn_particles(
        game, game.player_x, 1.0, game.player_z, 5, 120, 100, 80,
      )
    }
  }
}

fn update_minotaur_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float
) -> Unit {
  // Minotaur: charges in straight line
  let melee_range : Float = 2.5
  if e.ai_state == @types.ai_special {
    // Charging!
    let charge_speed = @types.minotaur_charge_speed * e.speed_mult
    let dx = @math.sinf(e.facing_angle)
    let dz = @math.cosf(e.facing_angle)
    let new_x = e.x + dx * charge_speed * dt
    let new_z = e.z + dz * charge_speed * dt
    let radius : Float = 0.5
    if @types.is_blocked(game, new_x, new_z, radius) {
      // Hit wall, stop charge
      e.ai_state = @types.ai_chase
      e.stun_timer = 1.0
      @types.spawn_particles(game, e.x, 1.0, e.z, 12, 150, 100, 50)
    } else {
      e.x = new_x
      e.z = new_z
      // Check if hit player during charge
      let charge_dist = @types.dist2d(e.x, e.z, game.player_x, game.player_z)
      if charge_dist < 1.5 {
        damage_player(game, e.atk * 2)
        e.ai_state = @types.ai_chase
        @types.spawn_particles(
          game, game.player_x, 1.0, game.player_z, 10, 255, 80, 40,
        )
        @types.add_message(game, "Minotaur charge hits!", 255, 80, 40)
      }
    }
    // Charge has a max duration
    e.move_timer -= dt
    if e.move_timer <= 0.0 {
      e.ai_state = @types.ai_chase
    }
  } else if dist > melee_range && dist < 10.0 && e.ability_cooldown <= 0.0 {
    // Start charge if player is in line of sight
    e.ai_state = @types.ai_special
    e.move_timer = 1.5
    e.ability_cooldown = 5.0
    e.facing_angle = @math.atan2f(game.player_x - e.x, game.player_z - e.z)
    @types.spawn_particles(game, e.x, 0.5, e.z, 8, 200, 100, 50)
    @types.add_message(game, "Minotaur charges!", 200, 100, 50)
  } else {
    // Normal chase
    let move_speed : Float = 2.5 * e.speed_mult
    if dist > melee_range {
      let dir = @types.pathfind_step(
        game, e.x, e.z, game.player_x, game.player_z,
      )
      let new_x = e.x + dir.0 * move_speed * dt
      let new_z = e.z + dir.1 * move_speed * dt
      let radius : Float = 0.5
      if not(@types.is_blocked(game, new_x, e.z, radius)) {
        e.x = new_x
      }
      if not(@types.is_blocked(game, e.x, new_z, radius)) {
        e.z = new_z
      }
    } else {
      if e.attack_timer <= 0.0 {
        damage_player(game, e.atk)
        e.attack_timer = 1.5
        @types.spawn_particles(
          game, game.player_x, 1.0, game.player_z, 8, 200, 100, 50,
        )
      }
    }
  }
}

fn update_lich_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float
) -> Unit {
  // Lich: ranged spell attacks, summons skeletons
  let move_speed : Float = 1.8 * e.speed_mult
  // Keep distance
  if dist < 5.0 {
    // Back away
    let dx = e.x - game.player_x
    let dz = e.z - game.player_z
    let d = (dx * dx + dz * dz).sqrt()
    if d > 0.1 {
      let nx = dx / d
      let nz = dz / d
      let new_x = e.x + nx * move_speed * dt
      let new_z = e.z + nz * move_speed * dt
      let radius : Float = 0.4
      if not(@types.is_blocked(game, new_x, e.z, radius)) {
        e.x = new_x
      }
      if not(@types.is_blocked(game, e.x, new_z, radius)) {
        e.z = new_z
      }
    }
  } else if dist > 10.0 {
    // Move closer
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let new_x = e.x + dir.0 * move_speed * dt
    let new_z = e.z + dir.1 * move_speed * dt
    let radius : Float = 0.4
    if not(@types.is_blocked(game, new_x, e.z, radius)) {
      e.x = new_x
    }
    if not(@types.is_blocked(game, e.x, new_z, radius)) {
      e.z = new_z
    }
  }
  // Spell attacks
  if dist < @types.archer_range && e.attack_timer <= 0.0 {
    shoot_lich_bolt(game, e)
    e.attack_timer = 1.5
  }
  // Summon skeleton ability
  if e.ability_cooldown <= 0.0 && dist < 12.0 {
    summon_skeleton(game, e)
    e.ability_cooldown = 8.0
    @types.add_message(game, "Lich summons a skeleton!", 180, 50, 200)
  }
  ignore(dt)
}

fn update_boss_enemy(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
  dist : Float
) -> Unit {
  // Dragon boss: melee + fire breath + summon
  let base_speed = @types.golem_move_speed * e.speed_mult
  let melee_range : Float = 3.0
  if dist > melee_range {
    let dir = @types.pathfind_step(game, e.x, e.z, game.player_x, game.player_z)
    let new_x = e.x + dir.0 * base_speed * dt
    let new_z = e.z + dir.1 * base_speed * dt
    let radius : Float = 0.6
    if not(@types.is_blocked(game, new_x, e.z, radius)) {
      e.x = new_x
    }
    if not(@types.is_blocked(game, e.x, new_z, radius)) {
      e.z = new_z
    }
  } else {
    // Melee attack
    if e.attack_timer <= 0.0 {
      damage_player(game, e.atk)
      e.attack_timer = @types.enemy_attack_cooldown
      @types.spawn_particles(
        game, game.player_x, 1.0, game.player_z, 8, 255, 80, 80,
      )
    }
  }
  // Fire breath special attack
  if e.ability_cooldown <= 0.0 && dist < 8.0 {
    // Fire breath: multiple projectiles in a cone
    let base_angle = @math.atan2f(
      game.player_x - e.x,
      game.player_z - e.z,
    )
    for j = -2; j <= 2; j = j + 1 {
      let angle = base_angle + Float::from_int(j) * 0.2
      let pidx = @types.alloc_projectile(game)
      if pidx >= 0 {
        let p = game.projectiles[pidx]
        p.active = true
        p.kind = @types.spell_fireball
        p.x = e.x
        p.z = e.z
        p.vx = @math.sinf(angle) * 6.0
        p.vz = @math.cosf(angle) * 6.0
        p.damage = e.atk / 2
        p.lifetime = 2.0
        p.from_enemy = true
        p.aoe_radius = 0.0
        p.slow_on_hit = false
      }
    }
    e.ability_cooldown = 4.0
    @types.spawn_particles(game, e.x, 1.5, e.z, 12, 255, 100, 30)
    @types.add_message(game, "Dragon breathes fire!", 255, 100, 30)
  }
}

fn shoot_projectile(game : @types.Game, e : @types.Enemy) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = 0
  p.x = e.x
  p.z = e.z
  // Direction toward player
  let dx = game.player_x - e.x
  let dz = game.player_z - e.z
  let d = (dx * dx + dz * dz).sqrt()
  if d > 0.1 {
    p.vx = dx / d * @types.projectile_speed
    p.vz = dz / d * @types.projectile_speed
  } else {
    p.vx = 0.0
    p.vz = @types.projectile_speed
  }
  p.damage = e.atk
  p.lifetime = @types.projectile_lifetime
  p.from_enemy = true
  p.aoe_radius = 0.0
  p.slow_on_hit = false
}

fn shoot_web(game : @types.Game, e : @types.Enemy) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = @types.spell_ice_bolt // Reuse ice_bolt visual
  p.x = e.x
  p.z = e.z
  let dx = game.player_x - e.x
  let dz = game.player_z - e.z
  let d = (dx * dx + dz * dz).sqrt()
  if d > 0.1 {
    p.vx = dx / d * 5.0
    p.vz = dz / d * 5.0
  } else {
    p.vx = 0.0
    p.vz = 5.0
  }
  p.damage = 2
  p.lifetime = 2.0
  p.from_enemy = true
  p.aoe_radius = 0.0
  p.slow_on_hit = true
}

fn shoot_lich_bolt(game : @types.Game, e : @types.Enemy) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = @types.spell_lightning
  p.x = e.x
  p.z = e.z
  let dx = game.player_x - e.x
  let dz = game.player_z - e.z
  let d = (dx * dx + dz * dz).sqrt()
  if d > 0.1 {
    p.vx = dx / d * 7.0
    p.vz = dz / d * 7.0
  } else {
    p.vx = 0.0
    p.vz = 7.0
  }
  p.damage = e.atk
  p.lifetime = 2.5
  p.from_enemy = true
  p.aoe_radius = 0.0
  p.slow_on_hit = false
  @types.spawn_particles(game, e.x, 1.5, e.z, 6, 180, 50, 255)
}

fn summon_skeleton(game : @types.Game, e : @types.Enemy) -> Unit {
  let idx = @types.alloc_enemy(game)
  if idx < 0 {
    return
  }
  let se = game.enemies[idx]
  se.active = true
  se.kind = @types.enemy_skeleton
  // Spawn near the lich
  se.x = e.x + @types.rand_rangef(game, -2.0, 2.0)
  se.z = e.z + @types.rand_rangef(game, -2.0, 2.0)
  let hp_s = @levels.get_enemy_hp_scale(game.current_floor)
  let atk_s = @levels.get_enemy_atk_scale(game.current_floor)
  let def_s = @levels.get_enemy_def_scale(game.current_floor)
  se.hp = 15 + hp_s / 2
  se.max_hp = se.hp
  se.atk = 4 + atk_s / 2
  se.def = 1 + def_s / 2
  se.attack_timer = 0.0
  se.move_timer = 0.0
  se.alerted = true
  se.hit_flash = 0.0
  se.ai_state = @types.ai_chase
  se.xp_value = @types.xp_per_skeleton / 2
  se.speed_mult = 1.0
  se.stun_timer = 0.0
  se.slow_timer = 0.0
  se.ability_cooldown = 0.0
  se.facing_angle = 0.0
  se.patrol_x = se.x
  se.patrol_z = se.z
  @types.spawn_particles(game, se.x, 1.0, se.z, 10, 180, 50, 200)
  game.floor_info[game.current_floor].enemies_total += 1
}

pub fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    let p = game.projectiles[i]
    if not(p.active) {
      continue i + 1
    }
    p.lifetime -= dt
    if p.lifetime <= 0.0 {
      p.active = false
      continue i + 1
    }
    // Move
    let new_x = p.x + p.vx * dt
    let new_z = p.z + p.vz * dt
    // Check wall collision
    let gx = @types.world_to_grid_x(new_x)
    let gz = @types.world_to_grid_z(new_z)
    if not(@types.is_walkable(@types.get_tile(game, gx, gz))) {
      p.active = false
      // Hit wall particles
      @types.spawn_particles(game, new_x, 1.0, new_z, 4, 200, 200, 50)
      continue i + 1
    }
    p.x = new_x
    p.z = new_z
    // Check hit player (enemy projectiles)
    if p.from_enemy {
      let dist = @types.dist2d(p.x, p.z, game.player_x, game.player_z)
      if dist < 0.8 {
        damage_player(game, p.damage)
        if p.slow_on_hit {
          @types.add_buff(game, @types.buff_speed, 2.0, -3)
          @types.add_message(game, "Slowed by web!", 200, 200, 200)
        }
        p.active = false
        @types.spawn_particles(
          game, game.player_x, 1.0, game.player_z, 6, 255, 100, 50,
        )
      }
    } else {
      // Player projectile: check hit enemies
      for j = 0; j < game.enemies.length(); j = j + 1 {
        let enemy = game.enemies[j]
        if not(enemy.active) {
          continue j + 1
        }
        let edist = @types.dist2d(p.x, p.z, enemy.x, enemy.z)
        if edist < 0.8 {
          let raw_atk = @types.calc_player_attack(game)
          let damage = @types.maxi(1, raw_atk - enemy.def)
          enemy.hp -= damage
          enemy.hit_flash = 0.2
          enemy.alerted = true
          // Apply slow from ice bolt
          if p.slow_on_hit {
            enemy.slow_timer = @types.ice_bolt_slow_duration
            enemy.speed_mult = 0.4
          }
          p.active = false
          @types.spawn_particles(game, enemy.x, 1.0, enemy.z, 8, 255, 50, 50)
          @types.add_message(
            game,
            "Hit \{@types.get_enemy_name(enemy.kind)} for \{damage}!",
            255, 200, 80,
          )
          if enemy.hp <= 0 {
            kill_enemy(game, j)
          }
          break
        }
      }
    }
  }
}

pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) {
      continue i + 1
    }
    p.life -= dt
    if p.life <= 0.0 {
      p.active = false
      continue i + 1
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.z += p.vz * dt
    // Gravity
    p.vy -= 6.0 * dt
    // Drag
    p.vx *= 0.98
    p.vz *= 0.98
  }
}

pub fn update_loot_bob(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.loot.length(); i = i + 1 {
    let l = game.loot[i]
    if not(l.active) {
      continue i + 1
    }
    l.bob_phase += dt * 3.0
  }
}
