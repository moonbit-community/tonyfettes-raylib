// Enemy spawning, AI and combat

///|
fn update_enemies_ai(game : @types.Game, dt : Float) -> Unit {
  // Spawn enemies
  if game.wave_active && game.enemies_spawned < game.enemies_to_spawn {
    game.spawn_timer -= dt
    if game.spawn_timer <= 0.0 {
      spawn_enemy(game)
      game.spawn_timer = @types.spawn_interval
    }
  }
  // Update each enemy
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue i + 1
    }
    // Stun timer
    if enemy.stun_timer > 0.0 {
      enemy.stun_timer -= dt
      continue i + 1
    }
    // Flash timer
    if enemy.flash_timer > 0.0 {
      enemy.flash_timer -= dt
    }
    // State timer
    if enemy.state_timer > 0.0 {
      enemy.state_timer -= dt
    }
    // Calculate distance and direction to player
    let dx = game.player.x - enemy.x
    let dz = game.player.z - enemy.z
    let dist = @types.distance2d(enemy.x, enemy.z, game.player.x, game.player.z)
    // Update facing angle towards player
    enemy.facing_angle = @math.atan2f(dx, dz)
    // AI behavior based on type
    if enemy.kind == @types.enemy_spitter {
      update_spitter_ai(game, i, dx, dz, dist, dt)
    } else if enemy.kind == @types.enemy_exploder {
      update_exploder_ai(game, i, dx, dz, dist, dt)
    } else if enemy.kind == @types.enemy_necromancer {
      update_necromancer_ai(game, i, dx, dz, dist, dt)
    } else if enemy.kind == @types.enemy_shielded {
      update_shielded_ai(game, i, dx, dz, dist, dt)
    } else if enemy.kind == @types.enemy_boss {
      update_boss_ai(game, i, dx, dz, dist, dt)
    } else if enemy.kind == @types.enemy_runner {
      update_runner_ai(game, i, dx, dz, dist, dt)
    } else if enemy.kind == @types.enemy_brute {
      update_brute_ai(game, i, dx, dz, dist, dt)
    } else {
      update_melee_ai(game, i, dx, dz, dist, dt)
    }
    // Apply velocity
    enemy.x += enemy.vx * dt
    enemy.z += enemy.vz * dt
    // Arena collision
    let clamped = @types.clamp_to_arena(enemy.x, enemy.z)
    enemy.x = clamped.0
    enemy.z = clamped.1
    // Pillar collision
    for pi = 0; pi < game.pillars.length(); pi = pi + 1 {
      let pillar = game.pillars[pi]
      let result = @types.push_from_pillar(
        enemy.x,
        enemy.z,
        enemy.size * 0.5,
        pillar.x,
        pillar.z,
        pillar.radius,
      )
      enemy.x = result.0
      enemy.z = result.1
    }
    // Barricade collision + barricade damage
    for bi = 0; bi < game.barricades.length(); bi = bi + 1 {
      let barr = game.barricades[bi]
      if not(barr.active) {
        continue bi + 1
      }
      let bdist = @types.distance2d(enemy.x, enemy.z, barr.x, barr.z)
      if bdist < @types.barricade_size * 0.5 + enemy.size * 0.5 {
        // Push enemy away
        let bdx = enemy.x - barr.x
        let bdz = enemy.z - barr.z
        let blen = (bdx * bdx + bdz * bdz).sqrt()
        if blen > 0.01 {
          let push_dist = @types.barricade_size * 0.5 + enemy.size * 0.5 - bdist
          enemy.x += bdx / blen * push_dist
          enemy.z += bdz / blen * push_dist
        }
        // Enemy attacks barricade
        enemy.attack_timer -= dt
        if enemy.attack_timer <= 0.0 {
          barr.hp -= enemy.damage * 0.5
          enemy.attack_timer = 1.0
          if barr.hp <= 0.0 {
            barr.active = false
            @types.spawn_particles(game, barr.x, 1.0, barr.z, 12, 120, 100, 60)
          }
        }
      }
    }
    // Enemy-enemy collision (simple push apart)
    for j = i + 1; j < game.enemies.length(); j = j + 1 {
      let other = game.enemies[j]
      if not(other.active) {
        continue j + 1
      }
      let edx = other.x - enemy.x
      let edz = other.z - enemy.z
      let edist = (edx * edx + edz * edz).sqrt()
      let min_dist = (enemy.size + other.size) * 0.5
      if edist < min_dist && edist > 0.01 {
        let push = (min_dist - edist) * 0.5
        let enx = edx / edist
        let enz = edz / edist
        enemy.x -= enx * push
        enemy.z -= enz * push
        other.x += enx * push
        other.z += enz * push
      }
    }
    // Trap interaction
    for ti = 0; ti < game.traps.length(); ti = ti + 1 {
      let trap = game.traps[ti]
      if not(trap.active) {
        continue ti + 1
      }
      let tdist = @types.distance2d(enemy.x, enemy.z, trap.x, trap.z)
      if tdist < 2.0 && trap.cooldown_timer <= 0.0 {
        // Trap triggers
        if trap.kind == @types.trap_spike {
          enemy.hp -= trap.damage
          enemy.flash_timer = 0.1
          trap.cooldown_timer = @types.trap_spike_cooldown
          trap.active_timer = 0.3
          @types.spawn_particles(game, enemy.x, 0.3, enemy.z, 5, 200, 50, 50)
        } else if trap.kind == @types.trap_flame {
          enemy.hp -= trap.damage * dt * 3.0
          trap.active_timer = @types.trap_flame_duration
          @types.spawn_particles_typed(
            game,
            enemy.x,
            0.5,
            enemy.z,
            2,
            255,
            150,
            30,
            @types.particle_explosion,
          )
        } else if trap.kind == @types.trap_electric {
          enemy.hp -= trap.damage
          enemy.stun_timer = @types.trap_electric_stun
          trap.cooldown_timer = @types.trap_electric_cooldown
          trap.active_timer = 0.5
          @types.spawn_particles_typed(
            game,
            enemy.x,
            0.5,
            enemy.z,
            4,
            100,
            150,
            255,
            @types.particle_spark,
          )
        }
        if enemy.hp <= 0.0 {
          kill_enemy(game, i)
        }
      }
    }
  }
}

///|
fn update_melee_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Move towards player
  if dist > 0.5 {
    let nx = dx / dist
    let nz = dz / dist
    enemy.vx = nx * enemy.speed
    enemy.vz = nz * enemy.speed
  } else {
    enemy.vx = 0.0
    enemy.vz = 0.0
  }
  // Attack when in range
  enemy.attack_timer -= dt
  if dist < enemy.attack_range && enemy.attack_timer <= 0.0 {
    damage_player_from(game, enemy.damage, enemy.x, enemy.z)
    enemy.attack_timer = 1.0
    // Attack particles
    @types.spawn_particles(
      game,
      game.player.x,
      @types.player_height * 0.5,
      game.player.z,
      3,
      200,
      50,
      50,
    )
  }
}

///|
fn update_runner_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Runners zigzag toward player
  if dist > 0.5 {
    let nx = dx / dist
    let nz = dz / dist
    // Add zigzag perpendicular component
    let zigzag_period : Float = 1.5
    let zigzag_amp : Float = 0.6
    let zigzag = @math.sinf(
        Float::from_int(game.frame_counter) * 0.08 + Float::from_int(idx) * 3.0,
      ) *
      zigzag_amp
    let perp_x = -nz
    let perp_z = nx
    enemy.vx = (nx + perp_x * zigzag) * enemy.speed
    enemy.vz = (nz + perp_z * zigzag) * enemy.speed
    ignore(zigzag_period)
  } else {
    enemy.vx = 0.0
    enemy.vz = 0.0
  }
  // Quick melee attacks
  enemy.attack_timer -= dt
  if dist < enemy.attack_range && enemy.attack_timer <= 0.0 {
    damage_player_from(game, enemy.damage, enemy.x, enemy.z)
    enemy.attack_timer = 0.7
    @types.spawn_particles(
      game,
      game.player.x,
      @types.player_height * 0.5,
      game.player.z,
      2,
      50,
      200,
      50,
    )
  }
}

///|
fn update_brute_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Brutes charge when close
  if enemy.state == 2 {
    // Charging state
    enemy.state_timer -= dt
    if enemy.state_timer <= 0.0 {
      enemy.state = 1
      enemy.speed = enemy.speed / 2.0
    }
    // Damage on contact during charge
    if dist < enemy.attack_range + 0.5 {
      damage_player_from(game, enemy.damage * 1.5, enemy.x, enemy.z)
      enemy.state = 1
      enemy.speed = enemy.speed / 2.0
      enemy.attack_timer = 2.0
      @types.spawn_particles(
        game,
        game.player.x,
        1.0,
        game.player.z,
        6,
        150,
        50,
        150,
      )
    }
  } else {
    // Normal approach
    if dist > 0.5 {
      let nx = dx / dist
      let nz = dz / dist
      enemy.vx = nx * enemy.speed
      enemy.vz = nz * enemy.speed
    } else {
      enemy.vx = 0.0
      enemy.vz = 0.0
    }
    // Initiate charge when in range
    if dist < 8.0 && dist > 3.0 && enemy.attack_timer <= 0.0 {
      enemy.state = 2
      enemy.state_timer = 1.5
      enemy.speed = enemy.speed * 2.0
      let nx = dx / dist
      let nz = dz / dist
      enemy.vx = nx * enemy.speed
      enemy.vz = nz * enemy.speed
      @types.spawn_particles(game, enemy.x, 0.5, enemy.z, 4, 150, 100, 200)
    }
    // Regular melee
    enemy.attack_timer -= dt
    if dist < enemy.attack_range && enemy.attack_timer <= 0.0 {
      damage_player_from(game, enemy.damage, enemy.x, enemy.z)
      enemy.attack_timer = 1.5
    }
  }
}

///|
fn update_spitter_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Spitters try to keep distance
  let preferred_dist : Float = 10.0
  if dist < preferred_dist - 2.0 {
    // Too close, back away
    if dist > 0.5 {
      let nx = dx / dist
      let nz = dz / dist
      enemy.vx = -nx * enemy.speed
      enemy.vz = -nz * enemy.speed
    }
  } else if dist > preferred_dist + 3.0 {
    // Too far, move closer
    if dist > 0.5 {
      let nx = dx / dist
      let nz = dz / dist
      enemy.vx = nx * enemy.speed
      enemy.vz = nz * enemy.speed
    }
    // Good range, strafe
  } else if dist > 0.5 {
    let nx = dx / dist
    let nz = dz / dist
    // Perpendicular movement (strafe)
    let strafe_dir : Float = if game.frame_counter % 200 < 100 {
      1.0
    } else {
      -1.0
    }
    enemy.vx = -nz * enemy.speed * 0.5 * strafe_dir
    enemy.vz = nx * enemy.speed * 0.5 * strafe_dir
  }
  // Spit attack
  enemy.spit_timer -= dt
  if enemy.spit_timer <= 0.0 && dist < enemy.attack_range {
    fire_spit(game, idx)
    enemy.spit_timer = enemy.spit_cooldown
  }
}

///|
fn update_exploder_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  ignore(dt)
  // Exploders rush toward player
  if not(enemy.explode_triggered) {
    if dist > 0.5 {
      let nx = dx / dist
      let nz = dz / dist
      enemy.vx = nx * enemy.speed
      enemy.vz = nz * enemy.speed
    }
    // Trigger explosion when close
    if dist < enemy.attack_range {
      enemy.explode_triggered = true
      enemy.explode_timer = 0.8
      enemy.vx = 0.0
      enemy.vz = 0.0
      // Warning particles
      @types.spawn_particles_typed(
        game,
        enemy.x,
        enemy.y,
        enemy.z,
        6,
        255,
        200,
        50,
        @types.particle_explosion,
      )
    }
  } else {
    // Countdown to explosion
    enemy.explode_timer -= @raylib.get_frame_time()
    if enemy.explode_timer <= 0.0 {
      // EXPLODE
      apply_explosion(
        game,
        enemy.x,
        enemy.y,
        enemy.z,
        @types.exploder_radius,
        @types.exploder_damage,
      )
      enemy.active = false
      game.player.score += enemy.score_value
      game.player.money += enemy.gold_value
    }
  }
}

///|
fn update_necromancer_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Necromancers stay back and try to revive dead enemies
  let preferred_dist : Float = 15.0
  if dist < preferred_dist - 3.0 {
    if dist > 0.5 {
      let nx = dx / dist
      let nz = dz / dist
      enemy.vx = -nx * enemy.speed * 1.2
      enemy.vz = -nz * enemy.speed * 1.2
    }
  } else if dist > preferred_dist + 5.0 {
    if dist > 0.5 {
      let nx = dx / dist
      let nz = dz / dist
      enemy.vx = nx * enemy.speed
      enemy.vz = nz * enemy.speed
    }
    // Strafe at range
  } else if dist > 0.5 {
    let nx = dx / dist
    let nz = dz / dist
    let strafe_dir : Float = if (game.frame_counter + idx * 50) % 300 < 150 {
      1.0
    } else {
      -1.0
    }
    enemy.vx = -nz * enemy.speed * 0.4 * strafe_dir
    enemy.vz = nx * enemy.speed * 0.4 * strafe_dir
  }
  // Revive ability
  enemy.revive_timer -= dt
  if enemy.revive_timer <= 0.0 {
    // Try to find a dead enemy to revive (using can_revive flag)
    let mut revived = false
    for j = 0; j < game.enemies.length(); j = j + 1 {
      let target = game.enemies[j]
      if not(target.active) && target.can_revive {
        let revive_dist = @types.distance2d(
          enemy.x,
          enemy.z,
          target.death_x,
          target.death_z,
        )
        if revive_dist < @types.necro_revive_range {
          // Revive this enemy
          target.active = true
          target.x = target.death_x
          target.z = target.death_z
          target.hp = target.max_hp * 0.5
          target.stun_timer = 0.5
          target.can_revive = false
          target.flash_timer = 0.3
          @types.spawn_particles_typed(
            game,
            target.x,
            target.y,
            target.z,
            8,
            100,
            50,
            200,
            @types.particle_heal,
          )
          revived = true
          break
        }
      }
    }
    enemy.revive_timer = @types.necro_revive_cooldown
    if revived {
      // Visual feedback for necromancer
      @types.spawn_particles_typed(
        game,
        enemy.x,
        enemy.y + 0.5,
        enemy.z,
        5,
        150,
        50,
        255,
        @types.particle_heal,
      )
    }
  }
  // Weak ranged attack
  enemy.spit_timer -= dt
  if enemy.spit_timer <= 0.0 && dist < 18.0 {
    fire_spit(game, idx)
    enemy.spit_timer = 4.0
  }
}

///|
fn update_shielded_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Shielded enemies always face the player (shield in front)
  // Move toward player
  if dist > 0.5 {
    let nx = dx / dist
    let nz = dz / dist
    enemy.vx = nx * enemy.speed
    enemy.vz = nz * enemy.speed
  } else {
    enemy.vx = 0.0
    enemy.vz = 0.0
  }
  // Attack when in range
  enemy.attack_timer -= dt
  if dist < enemy.attack_range && enemy.attack_timer <= 0.0 {
    damage_player_from(game, enemy.damage, enemy.x, enemy.z)
    enemy.attack_timer = 1.2
    @types.spawn_particles(
      game,
      game.player.x,
      @types.player_height * 0.5,
      game.player.z,
      3,
      150,
      150,
      200,
    )
  }
}

///|
fn update_boss_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Update boss phase based on HP
  let hp_pct = enemy.hp / enemy.max_hp
  if hp_pct < 0.25 && enemy.boss_phase < 3 {
    enemy.boss_phase = 3
    enemy.speed = enemy.speed * 1.2
    @types.spawn_particles(
      game,
      enemy.x,
      enemy.y + 1.0,
      enemy.z,
      15,
      255,
      50,
      50,
    )
  } else if hp_pct < 0.50 && enemy.boss_phase < 2 {
    enemy.boss_phase = 2
    enemy.speed = enemy.speed * 1.1
    @types.spawn_particles(
      game,
      enemy.x,
      enemy.y + 1.0,
      enemy.z,
      12,
      255,
      100,
      50,
    )
  } else if hp_pct < 0.75 && enemy.boss_phase < 1 {
    enemy.boss_phase = 1
    @types.spawn_particles(
      game,
      enemy.x,
      enemy.y + 1.0,
      enemy.z,
      10,
      255,
      150,
      50,
    )
  }
  // Boss ability cooldown
  enemy.boss_ability_timer -= dt
  // Movement toward player
  if dist > 0.5 {
    let nx = dx / dist
    let nz = dz / dist
    let charge_mult = @levels.boss_charge_speed_mult(enemy.boss_phase)
    if enemy.state == 2 {
      // Charging
      enemy.vx = nx * enemy.speed * charge_mult
      enemy.vz = nz * enemy.speed * charge_mult
    } else {
      enemy.vx = nx * enemy.speed
      enemy.vz = nz * enemy.speed
    }
  } else {
    enemy.vx = 0.0
    enemy.vz = 0.0
  }
  // Boss abilities
  if enemy.boss_ability_timer <= 0.0 {
    let ability_cd = @levels.boss_ability_cooldown(enemy.boss_phase)
    if enemy.boss_phase >= 2 && dist > 5.0 {
      // Ranged attack: burst of projectiles
      let proj_count = 3 + enemy.boss_phase
      for pi = 0; pi < proj_count; pi = pi + 1 {
        let spread = @types.rand_rangef(game, -0.3, 0.3)
        let shoot_dx = dx / dist + spread
        let shoot_dz = dz / dist + spread * 0.5
        let norm = @types.normalize3d(shoot_dx, 0.0, shoot_dz)
        let pidx = @types.alloc_projectile(game)
        if pidx >= 0 {
          let proj = game.projectiles[pidx]
          proj.active = true
          proj.kind = @types.enemy_boss
          proj.x = enemy.x + norm.0 * enemy.size
          proj.y = enemy.y + enemy.size * 0.3
          proj.z = enemy.z + norm.2 * enemy.size
          proj.dx = norm.0
          proj.dy = 0.0
          proj.dz = norm.2
          proj.speed = 18.0
          proj.damage = enemy.damage * 0.5
          proj.life = 3.0
          proj.is_enemy = true
          proj.splash_radius = 0.0
        }
        ignore(pi)
      }
      @types.spawn_particles(
        game,
        enemy.x,
        enemy.y + 0.5,
        enemy.z,
        8,
        200,
        50,
        200,
      )
      enemy.boss_ability_timer = ability_cd
    } else if dist < 6.0 {
      // Ground slam: AoE damage around boss
      let slam_radius : Float = 6.0
      let slam_damage = enemy.damage * 1.5
      let player_dist = @types.distance2d(
        enemy.x,
        enemy.z,
        game.player.x,
        game.player.z,
      )
      if player_dist < slam_radius {
        let dmg_factor : Float = 1.0 - player_dist / slam_radius
        damage_player_from(game, slam_damage * dmg_factor, enemy.x, enemy.z)
      }
      @types.spawn_particles(game, enemy.x, 0.3, enemy.z, 18, 200, 150, 50)
      enemy.boss_ability_timer = ability_cd * 1.5
    } else {
      // Charge toward player
      enemy.state = 2
      enemy.state_timer = 1.5
      enemy.boss_ability_timer = ability_cd
    }
  }
  // Regular melee
  enemy.attack_timer -= dt
  if dist < enemy.attack_range && enemy.attack_timer <= 0.0 {
    damage_player_from(game, enemy.damage, enemy.x, enemy.z)
    enemy.attack_timer = 1.0
    @types.spawn_particles(
      game,
      game.player.x,
      1.0,
      game.player.z,
      5,
      200,
      50,
      200,
    )
  }
  // State timer for charge
  if enemy.state == 2 && enemy.state_timer <= 0.0 {
    enemy.state = 1
  }
}

///|
fn fire_spit(game : @types.Game, enemy_idx : Int) -> Unit {
  let enemy = game.enemies[enemy_idx]
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let proj = game.projectiles[idx]
  let dx = game.player.x - enemy.x
  let dy = @types.player_height * 0.7 - enemy.y
  let dz = game.player.z - enemy.z
  let norm = @types.normalize3d(dx, dy, dz)
  proj.active = true
  proj.kind = @types.enemy_spitter
  proj.x = enemy.x
  proj.y = enemy.y + enemy.size * 0.5
  proj.z = enemy.z
  proj.dx = norm.0
  proj.dy = norm.1
  proj.dz = norm.2
  proj.speed = 15.0
  proj.damage = enemy.damage * 0.7
  proj.life = 3.0
  proj.is_enemy = true
  proj.splash_radius = 0.0
  proj.penetration = 0
  proj.is_headshot_capable = false
}

///|
fn spawn_enemy(game : @types.Game) -> Unit {
  let idx = @types.alloc_enemy(game)
  if idx < 0 {
    return
  }
  // Determine enemy kind from wave composition
  let kind = @levels.get_wave_enemy_kind(
    game.current_wave,
    game.enemies_spawned,
  )
  let base_hp = @levels.enemy_base_hp(kind)
  let base_speed = @levels.enemy_base_speed(kind)
  let base_damage = @levels.enemy_base_damage(kind)
  let enemy = game.enemies[idx]
  enemy.active = true
  enemy.kind = kind
  enemy.hp = base_hp * game.wave_hp_mult * game.difficulty
  enemy.max_hp = enemy.hp
  enemy.speed = base_speed * game.wave_speed_mult
  enemy.damage = base_damage * game.difficulty
  enemy.attack_timer = 0.5
  enemy.attack_range = @levels.enemy_attack_range(kind)
  enemy.size = @levels.enemy_size(kind)
  enemy.gold_value = @levels.enemy_gold_value(kind)
  enemy.score_value = @levels.enemy_score_value(kind)
  enemy.spit_timer = @levels.enemy_spit_cooldown(kind)
  enemy.spit_cooldown = @levels.enemy_spit_cooldown(kind)
  enemy.stun_timer = 0.0
  enemy.flash_timer = 0.0
  enemy.vx = 0.0
  enemy.vy = 0.0
  enemy.vz = 0.0
  enemy.explode_triggered = false
  enemy.explode_timer = 0.0
  enemy.revive_timer = @levels.enemy_spit_cooldown(kind)
  enemy.facing_angle = 0.0
  enemy.boss_phase = 0
  enemy.boss_ability_timer = 3.0
  enemy.state = 0
  enemy.state_timer = 0.3
  enemy.death_x = 0.0
  enemy.death_z = 0.0
  enemy.can_revive = false
  enemy.drops_pickup = @types.rand_bool(game, @levels.enemy_drop_chance(kind))
  // Spawn at random position on arena edges
  let angle = @types.rand_rangef(game, 0.0, 2.0 * @types.pi)
  let dist = @types.rand_rangef(
    game, @types.spawn_min_dist, @types.spawn_max_dist,
  )
  let sx = @math.cosf(angle) * dist
  let sz = @math.sinf(angle) * dist
  // Clamp to arena
  let clamped = @types.clamp_to_arena(sx, sz)
  enemy.x = clamped.0
  enemy.y = enemy.size * 0.5
  enemy.z = clamped.1
  game.enemies_spawned += 1
}

///|
fn kill_enemy(game : @types.Game, idx : Int) -> Unit {
  let enemy = game.enemies[idx]
  enemy.active = false
  // Save death position for necromancer
  enemy.death_x = enemy.x
  enemy.death_z = enemy.z
  enemy.can_revive = enemy.kind != @types.enemy_boss &&
    enemy.kind != @types.enemy_exploder
  game.player.money += enemy.gold_value
  let combo_mult_score : Float = game.player.combo_mult
  let score_add_f : Float = Float::from_int(enemy.score_value) *
    combo_mult_score
  game.player.score += score_add_f.to_int()
  game.player.kills += 1
  // Combo system
  game.player.combo_count += 1
  game.player.combo_timer = @types.combo_timeout
  let new_mult = @types.combo_base_mult +
    Float::from_int(game.player.combo_count) * @types.combo_increment
  game.player.combo_mult = @types.minf(new_mult, @types.combo_max_mult)
  // Multi-kill tracking
  game.player.recent_kill_count += 1
  game.player.recent_kill_timer = 1.0
  if game.player.recent_kill_count == 2 {
    game.player.score += @types.bonus_double_kill
    @types.add_kill_feed(game, "DOUBLE KILL!", 255, 200, 50)
  } else if game.player.recent_kill_count == 3 {
    game.player.score += @types.bonus_triple_kill
    @types.add_kill_feed(game, "TRIPLE KILL!", 255, 150, 50)
  } else if game.player.recent_kill_count >= 4 {
    game.player.score += @types.bonus_multi_kill
    @types.add_kill_feed(game, "MULTI KILL!", 255, 50, 50)
  }
  // Death particles - color varies by enemy type
  let r = if enemy.kind == @types.enemy_zombie {
    100
  } else if enemy.kind == @types.enemy_runner {
    50
  } else if enemy.kind == @types.enemy_brute {
    80
  } else if enemy.kind == @types.enemy_spitter {
    50
  } else if enemy.kind == @types.enemy_exploder {
    255
  } else if enemy.kind == @types.enemy_necromancer {
    150
  } else if enemy.kind == @types.enemy_shielded {
    100
  } else {
    200
  }
  let g = if enemy.kind == @types.enemy_zombie {
    180
  } else if enemy.kind == @types.enemy_runner {
    200
  } else if enemy.kind == @types.enemy_brute {
    60
  } else if enemy.kind == @types.enemy_spitter {
    200
  } else if enemy.kind == @types.enemy_exploder {
    150
  } else if enemy.kind == @types.enemy_necromancer {
    50
  } else if enemy.kind == @types.enemy_shielded {
    100
  } else {
    50
  }
  let b = if enemy.kind == @types.enemy_zombie {
    50
  } else if enemy.kind == @types.enemy_runner {
    50
  } else if enemy.kind == @types.enemy_brute {
    150
  } else if enemy.kind == @types.enemy_spitter {
    50
  } else if enemy.kind == @types.enemy_exploder {
    30
  } else if enemy.kind == @types.enemy_necromancer {
    255
  } else if enemy.kind == @types.enemy_shielded {
    200
  } else {
    200
  }
  let particle_count = if enemy.kind == @types.enemy_boss { 25 } else { 10 }
  @types.spawn_particles(
    game,
    enemy.x,
    enemy.y,
    enemy.z,
    particle_count,
    r,
    g,
    b,
  )
  // Exploder death explosion
  if enemy.kind == @types.enemy_exploder && not(enemy.explode_triggered) {
    apply_explosion(
      game,
      enemy.x,
      enemy.y,
      enemy.z,
      @types.exploder_radius * 0.7,
      @types.exploder_damage * 0.5,
    )
  }
  // Pickup drop
  if enemy.drops_pickup {
    spawn_pickup_at(game, enemy.x, enemy.z)
  }
}

///|
fn damage_enemy(game : @types.Game, idx : Int, damage : Float) -> Unit {
  let enemy = game.enemies[idx]
  enemy.hp -= damage
  enemy.flash_timer = 0.1
  game.hit_marker_timer = 0.15
  game.total_damage_dealt += damage
  if enemy.hp <= 0.0 {
    kill_enemy(game, idx)
  }
}

///|
fn damage_enemy_headshot(game : @types.Game, idx : Int, damage : Float) -> Unit {
  let final_damage = damage * @types.headshot_mult
  let enemy = game.enemies[idx]
  enemy.hp -= final_damage
  enemy.flash_timer = 0.15
  enemy.stun_timer = 0.2
  game.hit_marker_timer = 0.2
  game.total_damage_dealt += final_damage
  game.player.headshots += 1
  game.player.score += @types.bonus_headshot
  @types.add_kill_feed(game, "HEADSHOT!", 255, 100, 100)
  // Extra blood particles for headshot
  @types.spawn_particles(
    game,
    enemy.x,
    enemy.y + enemy.size * 0.8,
    enemy.z,
    8,
    200,
    30,
    30,
  )
  if enemy.hp <= 0.0 {
    kill_enemy(game, idx)
  }
}

// Damage shielded enemy (checks if hit from front)

///|
fn damage_shielded_enemy(
  game : @types.Game,
  idx : Int,
  damage : Float,
  proj_dx : Float,
  proj_dz : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Check if projectile is hitting the shield (front)
  let attack_angle = @math.atan2f(proj_dx, proj_dz)
  let is_blocked = @types.angle_within(
    attack_angle,
    enemy.facing_angle + @types.pi,
    @types.shield_block_angle,
  )
  if is_blocked {
    // Shield blocks - reduced damage and spark effect
    let blocked_damage = damage * 0.15
    enemy.hp -= blocked_damage
    enemy.flash_timer = 0.05
    game.hit_marker_timer = 0.05
    @types.spawn_particles_typed(
      game,
      enemy.x,
      enemy.y + 0.3,
      enemy.z,
      3,
      200,
      200,
      255,
      @types.particle_spark,
    )
  } else {
    // Hit from behind/side - full damage
    damage_enemy(game, idx, damage)
  }
  if enemy.hp <= 0.0 {
    kill_enemy(game, idx)
  }
}

///|
fn spawn_pickup_at(game : @types.Game, x : Float, z : Float) -> Unit {
  let idx = @types.alloc_pickup(game)
  if idx < 0 {
    return
  }
  let pickup = game.pickups[idx]
  pickup.active = true
  let roll = @types.rand_next(game)
  pickup.kind = @levels.random_pickup_kind(roll)
  pickup.x = x
  pickup.y = 0.5
  pickup.z = z
  pickup.float_timer = 0.0
  pickup.life = 20.0
}
