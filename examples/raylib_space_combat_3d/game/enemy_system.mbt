// Enemy AI and behavior

///|
pub fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  let px = game.player.x
  let py = game.player.y
  let pz = game.player.z

  for i = 0; i < game.enemies.length(); i = i + 1 {
    let e = game.enemies[i]
    if not(e.active) {
      continue i + 1
    }

    // Shield regen for enemies that have shields
    if e.shield_hp < e.max_shield_hp && e.max_shield_hp > 0.0 {
      e.shield_hp += 1.0 * dt
      if e.shield_hp > e.max_shield_hp {
        e.shield_hp = e.max_shield_hp
      }
    }

    // Direction to player
    let dx = px - e.x
    let dy = py - e.y
    let dz = pz - e.z
    let dist = @types.distance3d(e.x, e.y, e.z, px, py, pz)

    // AI state machine
    update_ai_state(game, i, dist, dt)

    if e.kind == @types.enemy_fighter {
      update_fighter_ai(game, i, dx, dy, dz, dist, dt)
    } else if e.kind == @types.enemy_interceptor {
      update_interceptor_ai(game, i, dx, dy, dz, dist, dt)
    } else if e.kind == @types.enemy_bomber {
      update_bomber_ai(game, i, dx, dy, dz, dist, dt)
    } else if e.kind == @types.enemy_cruiser {
      update_cruiser_ai(game, i, dx, dy, dz, dist, dt)
    } else if e.kind == @types.enemy_capital {
      update_capital_ai(game, i, dx, dy, dz, dist, dt)
    }

    // Move
    e.x += e.vx * dt
    e.y += e.vy * dt
    e.z += e.vz * dt

    // Wrap
    e.x = @types.wrap_coord(e.x)
    e.y = @types.wrap_coord(e.y)
    e.z = @types.wrap_coord(e.z)

    // Fire timer
    e.fire_timer -= dt
    if e.fire_timer <= 0.0 && dist < 150.0 {
      // Only fire in attack or chase state
      if e.ai_state == @types.ai_attack || e.ai_state == @types.ai_chase {
        enemy_fire(game, i, dx, dy, dz, dist)
        let rate : Float = if e.kind == @types.enemy_fighter {
          @types.fighter_fire_rate
        } else if e.kind == @types.enemy_interceptor {
          @types.interceptor_fire_rate
        } else if e.kind == @types.enemy_bomber {
          @types.bomber_fire_rate
        } else if e.kind == @types.enemy_cruiser {
          @types.cruiser_fire_rate
        } else {
          @types.capital_fire_rate
        }
        e.fire_timer = rate + @types.rand_rangef(game, -0.3, 0.5)
      } else {
        e.fire_timer = 0.5
      }
    }

    // Capital ship turrets
    if e.kind == @types.enemy_capital && dist < 200.0 {
      e.turret_timer_1 -= dt
      e.turret_timer_2 -= dt
      if e.turret_timer_1 <= 0.0 {
        capital_turret_fire(game, i, dx, dy, dz, dist, 1)
        e.turret_timer_1 = 1.5 + @types.rand_rangef(game, 0.0, 1.0)
      }
      if e.turret_timer_2 <= 0.0 {
        capital_turret_fire(game, i, dx, dy, dz, dist, 2)
        e.turret_timer_2 = 2.0 + @types.rand_rangef(game, 0.0, 1.0)
      }
    }
  }
}

///|
fn update_ai_state(
  game : @types.Game,
  idx : Int,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  e.ai_timer -= dt

  if e.ai_timer > 0.0 {
    return
  }

  let hp_pct = e.hp / e.max_hp

  // State transitions
  if e.ai_state == @types.ai_idle {
    if dist < e.detect_range {
      e.ai_state = @types.ai_chase
      e.ai_timer = 1.0
    } else {
      e.ai_state = @types.ai_patrol
      e.ai_timer = 2.0
    }
  } else if e.ai_state == @types.ai_patrol {
    if dist < e.detect_range {
      e.ai_state = @types.ai_chase
      e.ai_timer = 0.5
    } else {
      e.ai_timer = @types.rand_rangef(game, 1.0, 3.0)
    }
  } else if e.ai_state == @types.ai_chase {
    if hp_pct < e.flee_threshold {
      e.ai_state = @types.ai_flee
      e.ai_timer = 2.0
    } else if dist < @types.fighter_attack_range {
      e.ai_state = @types.ai_attack
      e.ai_timer = @types.rand_rangef(game, 1.0, 3.0)
    } else if dist > e.detect_range * 1.5 {
      e.ai_state = @types.ai_patrol
      e.ai_timer = 1.0
    } else {
      e.ai_timer = 0.5
    }
  } else if e.ai_state == @types.ai_attack {
    if hp_pct < e.flee_threshold {
      e.ai_state = @types.ai_flee
      e.ai_timer = 2.0
    } else if hp_pct < @types.fighter_evade_hp_pct &&
      @types.rand_bool(game, 0.4) {
      e.ai_state = @types.ai_evade
      e.ai_timer = @types.rand_rangef(game, 1.5, 3.0)
    } else if dist > @types.fighter_attack_range * 1.5 {
      e.ai_state = @types.ai_chase
      e.ai_timer = 0.5
    } else {
      e.ai_timer = @types.rand_rangef(game, 0.8, 2.0)
    }
  } else if e.ai_state == @types.ai_evade {
    if hp_pct < e.flee_threshold {
      e.ai_state = @types.ai_flee
      e.ai_timer = 2.0
    } else if dist > 60.0 {
      e.ai_state = @types.ai_chase
      e.ai_timer = 1.0
    } else {
      e.ai_timer = @types.rand_rangef(game, 1.0, 2.0)
    }
  } else if e.ai_state == @types.ai_flee {
    if dist > 200.0 {
      // Fled far enough, regroup
      e.ai_state = @types.ai_patrol
      e.ai_timer = 3.0
    } else {
      e.ai_timer = 1.0
    }
  } else if e.ai_state == @types.ai_formation {
    if dist < e.detect_range * 0.8 {
      e.ai_state = @types.ai_chase
      e.ai_timer = 0.5
    } else {
      e.ai_timer = 1.0
    }
  }
}

///|
fn update_fighter_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = @types.fighter_speed

  if e.ai_state == @types.ai_patrol {
    // Patrol: move toward patrol point
    let pdx = e.patrol_x - e.x
    let pdy = e.patrol_y - e.y
    let pdz = e.patrol_z - e.z
    let pdist = @types.length3d(pdx, pdy, pdz)
    if pdist > 5.0 {
      let norm = @types.normalize3d(pdx, pdy, pdz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 0.5, 1.5 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 0.5, 1.5 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 0.5, 1.5 * dt)
    } else {
      // Drift near patrol point
      e.vx = @types.lerpf(e.vx, 0.0, 1.0 * dt)
      e.vy = @types.lerpf(e.vy, 0.0, 1.0 * dt)
      e.vz = @types.lerpf(e.vz, 0.0, 1.0 * dt)
    }
  } else if e.ai_state == @types.ai_chase {
    // Chase: approach player
    let norm = @types.normalize3d(dx, dy, dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd, 2.0 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd, 2.0 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd, 2.0 * dt)
  } else if e.ai_state == @types.ai_attack {
    if dist > 60.0 {
      // Approach
      let norm = @types.normalize3d(dx, dy, dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd, 2.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd, 2.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd, 2.0 * dt)
    } else if dist < 15.0 {
      // Too close, pull away
      let norm = @types.normalize3d(-dx, -dy, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.3, 3.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.3, 3.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.3, 3.0 * dt)
    } else {
      // Strafe around player
      let norm = @types.normalize3d(dx, dy, dz)
      let cross = @types.cross3d(norm.0, norm.1, norm.2, 0.0, 1.0, 0.0)
      let orbit = @types.normalize3d(
        cross.0 + norm.0 * 0.3,
        cross.1 + norm.1 * 0.3,
        cross.2 + norm.2 * 0.3,
      )
      e.vx = @types.lerpf(e.vx, orbit.0 * spd, 2.0 * dt)
      e.vy = @types.lerpf(e.vy, orbit.1 * spd, 2.0 * dt)
      e.vz = @types.lerpf(e.vz, orbit.2 * spd, 2.0 * dt)
    }
  } else if e.ai_state == @types.ai_evade {
    // Evade: jink perpendicular to player direction
    let norm = @types.normalize3d(dx, dy, dz)
    let cross = @types.cross3d(norm.0, norm.1, norm.2, 0.0, 1.0, 0.0)
    let jink_dir = Float::from_int(game.frame_counter % 60)
    let jx = cross.0 * @math.sinf(jink_dir * 0.2) + norm.0 * -0.3
    let jy = @math.cosf(jink_dir * 0.15) * 0.5
    let jz = cross.2 * @math.sinf(jink_dir * 0.2) + norm.2 * -0.3
    let jnorm = @types.normalize3d(jx, jy, jz)
    e.vx = @types.lerpf(e.vx, jnorm.0 * spd * 1.2, 3.0 * dt)
    e.vy = @types.lerpf(e.vy, jnorm.1 * spd * 1.2, 3.0 * dt)
    e.vz = @types.lerpf(e.vz, jnorm.2 * spd * 1.2, 3.0 * dt)
  } else if e.ai_state == @types.ai_flee {
    // Run away from player
    let norm = @types.normalize3d(-dx, -dy, -dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.5, 2.0 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.5, 2.0 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.5, 2.0 * dt)
  } else {
    // Idle/formation: drift
    e.vx = @types.lerpf(e.vx, 0.0, 0.5 * dt)
    e.vy = @types.lerpf(e.vy, 0.0, 0.5 * dt)
    e.vz = @types.lerpf(e.vz, 0.0, 0.5 * dt)
  }

  // Update facing
  let vel_len = @types.length3d(e.vx, e.vy, e.vz)
  if vel_len > 1.0 {
    e.yaw = @math.atan2f(e.vx, e.vz)
    e.pitch = @math.atan2f(e.vy, (e.vx * e.vx + e.vz * e.vz).sqrt())
  }
  ignore(game)
  ignore(dist)
}

///|
fn update_interceptor_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = @types.interceptor_speed

  // Interceptors are aggressive and fast - they do hit-and-run attacks
  if e.ai_state == @types.ai_patrol || e.ai_state == @types.ai_idle {
    let pdx = e.patrol_x - e.x
    let pdy = e.patrol_y - e.y
    let pdz = e.patrol_z - e.z
    let pdist = @types.length3d(pdx, pdy, pdz)
    if pdist > 5.0 {
      let norm = @types.normalize3d(pdx, pdy, pdz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 0.4, 2.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 0.4, 2.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 0.4, 2.0 * dt)
    }
  } else if e.ai_state == @types.ai_chase || e.ai_state == @types.ai_attack {
    // Full speed toward player
    let norm = @types.normalize3d(dx, dy, dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd, 3.0 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd, 3.0 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd, 3.0 * dt)

    // If very close, zip past and evade
    if dist < 10.0 {
      e.ai_state = @types.ai_evade
      e.ai_timer = 2.0
    }
  } else if e.ai_state == @types.ai_evade {
    // Sharp turn away
    let norm = @types.normalize3d(-dx, -dy + 5.0, -dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.3, 4.0 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.3, 4.0 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.3, 4.0 * dt)
  } else if e.ai_state == @types.ai_flee {
    let norm = @types.normalize3d(-dx, -dy, -dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.5, 3.0 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.5, 3.0 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.5, 3.0 * dt)
  }

  let vel_len = @types.length3d(e.vx, e.vy, e.vz)
  if vel_len > 1.0 {
    e.yaw = @math.atan2f(e.vx, e.vz)
    e.pitch = @math.atan2f(e.vy, (e.vx * e.vx + e.vz * e.vz).sqrt())
  }
  ignore(game)
  ignore(dist)
}

///|
fn update_bomber_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = @types.bomber_speed

  // Bombers are slow but try to get firing angles. They stay at medium range.
  if e.ai_state == @types.ai_patrol || e.ai_state == @types.ai_idle {
    let pdx = e.patrol_x - e.x
    let pdy = e.patrol_y - e.y
    let pdz = e.patrol_z - e.z
    let pdist = @types.length3d(pdx, pdy, pdz)
    if pdist > 5.0 {
      let norm = @types.normalize3d(pdx, pdy, pdz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 0.3, 1.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 0.3, 1.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 0.3, 1.0 * dt)
    }
  } else if e.ai_state == @types.ai_chase {
    // Slow approach
    let norm = @types.normalize3d(dx, dy, dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd, 1.5 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd, 1.5 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd, 1.5 * dt)
  } else if e.ai_state == @types.ai_attack {
    // Hold distance at ~60 units
    if dist > 80.0 {
      let norm = @types.normalize3d(dx, dy, dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd, 1.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd, 1.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd, 1.0 * dt)
    } else if dist < 40.0 {
      let norm = @types.normalize3d(-dx, -dy, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd, 1.5 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd, 1.5 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd, 1.5 * dt)
    } else {
      // Drift and fire
      e.vx = @types.lerpf(e.vx, 0.0, 0.5 * dt)
      e.vy = @types.lerpf(e.vy, 0.0, 0.5 * dt)
      e.vz = @types.lerpf(e.vz, 0.0, 0.5 * dt)
    }
  } else if e.ai_state == @types.ai_evade || e.ai_state == @types.ai_flee {
    let norm = @types.normalize3d(-dx, -dy, -dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd * 1.2, 1.5 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd * 1.2, 1.5 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd * 1.2, 1.5 * dt)
  }

  // Face player
  e.yaw = @math.atan2f(dx, dz)
  e.pitch = @math.atan2f(dy, (dx * dx + dz * dz).sqrt())
  ignore(game)
  ignore(dist)
}

///|
fn update_cruiser_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = @types.cruiser_speed

  // Cruisers slowly approach and hold distance
  if e.ai_state == @types.ai_patrol || e.ai_state == @types.ai_idle {
    // Drift slowly
    e.vx = @types.lerpf(e.vx, 0.0, 0.3 * dt)
    e.vy = @types.lerpf(e.vy, 0.0, 0.3 * dt)
    e.vz = @types.lerpf(e.vz, 0.0, 0.3 * dt)
  } else if e.ai_state == @types.ai_chase || e.ai_state == @types.ai_attack {
    if dist > 60.0 {
      let norm = @types.normalize3d(dx, dy, dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd, 1.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd, 1.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd, 1.0 * dt)
    } else if dist < 30.0 {
      let norm = @types.normalize3d(-dx, -dy, -dz)
      e.vx = @types.lerpf(e.vx, norm.0 * spd * 0.5, 1.0 * dt)
      e.vy = @types.lerpf(e.vy, norm.1 * spd * 0.5, 1.0 * dt)
      e.vz = @types.lerpf(e.vz, norm.2 * spd * 0.5, 1.0 * dt)
    } else {
      // Hold position
      e.vx = @types.lerpf(e.vx, 0.0, 0.5 * dt)
      e.vy = @types.lerpf(e.vy, 0.0, 0.5 * dt)
      e.vz = @types.lerpf(e.vz, 0.0, 0.5 * dt)
    }
  } else if e.ai_state == @types.ai_evade || e.ai_state == @types.ai_flee {
    let norm = @types.normalize3d(-dx, -dy, -dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd, 1.0 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd, 1.0 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd, 1.0 * dt)
  }

  // Face player
  e.yaw = @math.atan2f(dx, dz)
  e.pitch = @math.atan2f(dy, (dx * dx + dz * dz).sqrt())
  ignore(game)
  ignore(dist)
}

///|
fn update_capital_ai(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  dt : Float,
) -> Unit {
  let e = game.enemies[idx]
  let spd = @types.capital_speed

  // Capital ships are slow and mostly stationary. They rely on turrets.
  if dist > 100.0 {
    // Very slowly approach
    let norm = @types.normalize3d(dx, dy, dz)
    e.vx = @types.lerpf(e.vx, norm.0 * spd * 0.5, 0.5 * dt)
    e.vy = @types.lerpf(e.vy, norm.1 * spd * 0.3, 0.5 * dt)
    e.vz = @types.lerpf(e.vz, norm.2 * spd * 0.5, 0.5 * dt)
  } else {
    // Hold position, slight drift
    e.vx = @types.lerpf(e.vx, 0.0, 0.3 * dt)
    e.vy = @types.lerpf(e.vy, 0.0, 0.3 * dt)
    e.vz = @types.lerpf(e.vz, 0.0, 0.3 * dt)
  }

  // Slowly rotate to face player
  let target_yaw = @math.atan2f(dx, dz)
  e.yaw = @types.lerpf(e.yaw, target_yaw, 0.5 * dt)
  e.pitch = @types.lerpf(
    e.pitch,
    @math.atan2f(dy, (dx * dx + dz * dz).sqrt()),
    0.3 * dt,
  )
  ignore(game)
  ignore(dist)
}

///|
fn enemy_fire(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
) -> Unit {
  let e = game.enemies[idx]
  let pidx = @types.alloc_projectile(game)
  if pidx < 0 {
    return
  }
  let proj = game.projectiles[pidx]

  // Lead targeting for smarter aim
  let lead = @types.lead_target(
    e.x,
    e.y,
    e.z,
    game.player.x,
    game.player.y,
    game.player.z,
    game.player.vx,
    game.player.vy,
    game.player.vz,
    80.0,
  )

  let spd : Float = 80.0
  proj.active = true
  proj.from_player = false
  proj.x = e.x + lead.0 * e.size
  proj.y = e.y + lead.1 * e.size
  proj.z = e.z + lead.2 * e.size
  proj.vx = lead.0 * spd
  proj.vy = lead.1 * spd
  proj.vz = lead.2 * spd
  proj.piercing = false

  if e.kind == @types.enemy_bomber {
    // Bombers fire plasma-like shots
    proj.kind = @types.weapon_plasma
    proj.damage = @types.bomber_damage
    proj.life = 4.0
    proj.target_idx = -1
    proj.size = 0.2
    proj.fuel = 0.0
  } else if e.kind == @types.enemy_capital {
    proj.kind = @types.weapon_laser
    proj.damage = @types.capital_damage
    proj.life = 4.0
    proj.target_idx = -1
    proj.size = 0.12
    proj.fuel = 0.0
  } else {
    proj.kind = @types.weapon_laser
    let dmg : Float = if e.kind == @types.enemy_fighter {
      @types.fighter_damage
    } else if e.kind == @types.enemy_interceptor {
      @types.interceptor_damage
    } else {
      @types.cruiser_damage
    }
    proj.damage = dmg
    proj.life = 3.0
    proj.target_idx = -1
    proj.size = 0.08
    proj.fuel = 0.0
  }
  ignore(idx)
  ignore(dist)
  ignore(dx)
  ignore(dy)
  ignore(dz)
}

///|
fn capital_turret_fire(
  game : @types.Game,
  idx : Int,
  dx : Float,
  dy : Float,
  dz : Float,
  dist : Float,
  turret : Int,
) -> Unit {
  let e = game.enemies[idx]
  let pidx = @types.alloc_projectile(game)
  if pidx < 0 {
    return
  }
  let proj = game.projectiles[pidx]
  let norm = @types.normalize3d(dx, dy, dz)

  // Turret offset based on turret number
  let turret_off_x : Float = if turret == 1 { 3.0 } else { -3.0 }
  let turret_off_y : Float = if turret == 1 { 1.0 } else { -1.0 }

  let spd : Float = 90.0
  proj.active = true
  proj.kind = @types.weapon_laser
  proj.from_player = false
  proj.x = e.x + turret_off_x
  proj.y = e.y + turret_off_y
  proj.z = e.z
  proj.vx = norm.0 * spd
  proj.vy = norm.1 * spd
  proj.vz = norm.2 * spd
  proj.damage = @types.capital_damage * 0.6
  proj.life = 3.5
  proj.target_idx = -1
  proj.size = 0.1
  proj.fuel = 0.0
  proj.piercing = false
  ignore(dist)
}

///|
pub fn damage_enemy(game : @types.Game, idx : Int, damage : Float) -> Unit {
  let e = game.enemies[idx]

  // Apply damage to shield first
  let mut remaining_damage = damage
  if e.shield_hp > 0.0 {
    let absorbed = @types.minf(e.shield_hp, remaining_damage)
    e.shield_hp -= absorbed
    remaining_damage = remaining_damage - absorbed
    @types.spawn_shield_hit(game, e.x, e.y, e.z, 3)
  }

  e.hp -= remaining_damage
  e.damage_flash = @types.damage_flash_duration

  if e.hp <= 0.0 {
    e.active = false

    // Score with combo multiplier
    let base_score = e.score_value
    let combo_score = (Float::from_int(base_score) * game.combo_multiplier).to_int()
    game.score += combo_score
    game.total_kills += 1
    game.mission_kills += 1
    game.enemies_remaining -= 1
    game.player.kills += 1
    if game.enemies_remaining < 0 {
      game.enemies_remaining = 0
    }

    // Register combo
    @types.register_kill_combo(game)

    // Kill feed
    let type_name = @types.enemy_type_name(e.kind)
    let feed_text = "\{type_name} +\{combo_score}"
    let fr : Int = if e.kind == @types.enemy_capital { 255 } else { 200 }
    let fg : Int = if e.kind == @types.enemy_capital { 255 } else { 200 }
    @types.add_kill_feed(game, feed_text, fr, fg, 100)

    // Explosion
    let exp_count : Int = if e.kind == @types.enemy_capital {
      50
    } else if e.kind == @types.enemy_cruiser {
      30
    } else if e.kind == @types.enemy_bomber {
      20
    } else {
      15
    }
    let r : Int = if e.kind == @types.enemy_fighter { 255 } else { 200 }
    let g : Int = if e.kind == @types.enemy_fighter { 150 } else { 100 }
    @types.spawn_explosion(game, e.x, e.y, e.z, exp_count, r, g, 50)

    // Spawn debris
    let debris_count : Int = if e.kind == @types.enemy_capital {
      12
    } else if e.kind == @types.enemy_cruiser {
      8
    } else {
      4
    }
    let dr : Int = if e.kind == @types.enemy_fighter { 220 } else { 150 }
    let dg : Int = if e.kind == @types.enemy_fighter { 60 } else { 80 }
    @types.spawn_debris(game, e.x, e.y, e.z, debris_count, dr, dg, 60)

    // Chance to drop power-up
    if @types.rand_bool(game, 0.25) {
      let pu_idx = @types.alloc_powerup(game)
      if pu_idx >= 0 {
        let pu = game.powerups[pu_idx]
        pu.active = true
        pu.kind = @types.rand_range(game, 0, 3)
        pu.x = e.x
        pu.y = e.y
        pu.z = e.z
        pu.bob_timer = 0.0
        pu.spin_angle = 0.0
        pu.life = 30.0
      }
    }

    // Camera shake for large kills
    if e.kind == @types.enemy_capital {
      game.camera_shake = @types.maxf(game.camera_shake, 1.5)
      game.screen_flash = 0.5
      game.flash_r = 255
      game.flash_g = 200
      game.flash_b = 100
    } else if e.kind == @types.enemy_cruiser {
      game.camera_shake = @types.maxf(game.camera_shake, 0.8)
    }

    // Check if target was destroyed
    if game.target_idx == idx {
      game.target_idx = -1
    }

    // Update objectives
    @types.check_objective_progress(game, @types.objective_destroy_all, 1)
    @types.check_objective_progress(game, @types.objective_destroy_count, 1)
  }
}

///|
pub fn update_asteroids(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.asteroids.length(); i = i + 1 {
    let a = game.asteroids[i]
    if not(a.active) {
      continue i + 1
    }
    // Move
    a.x += a.vx * dt
    a.y += a.vy * dt
    a.z += a.vz * dt
    // Rotate
    a.rot_x += a.rot_speed * dt
    a.rot_y += a.rot_speed * 0.7 * dt
    a.rot_z += a.rot_speed * 0.4 * dt
    // Wrap
    a.x = @types.wrap_coord(a.x)
    a.y = @types.wrap_coord(a.y)
    a.z = @types.wrap_coord(a.z)
    // Check collision with player
    let dist = @types.distance3d(
      a.x,
      a.y,
      a.z,
      game.player.x,
      game.player.y,
      game.player.z,
    )
    if dist < a.size + 1.5 {
      damage_player(game, 20.0)
      a.hp -= 30.0
      if a.hp <= 0.0 {
        destroy_asteroid(game, i)
      }
    }

    // Check collision with enemies
    for j = 0; j < game.enemies.length(); j = j + 1 {
      let e = game.enemies[j]
      if not(e.active) {
        continue j + 1
      }
      let edist = @types.distance3d(a.x, a.y, a.z, e.x, e.y, e.z)
      if edist < a.size + e.size * 0.5 {
        e.hp -= 10.0
        a.hp -= 10.0
        if e.hp <= 0.0 {
          damage_enemy(game, j, 0.0)
        }
        if a.hp <= 0.0 {
          destroy_asteroid(game, i)
          break
        }
      }
    }
  }
}

///|
fn destroy_asteroid(game : @types.Game, idx : Int) -> Unit {
  let a = game.asteroids[idx]
  a.active = false
  game.score += @types.asteroid_score
  @types.spawn_explosion(game, a.x, a.y, a.z, 10, 150, 130, 100)

  // Break into smaller asteroids if breakable
  if a.breakable && a.size_tier != @types.asteroid_small {
    let new_tier : Int = if a.size_tier == @types.asteroid_large {
      @types.asteroid_medium
    } else {
      @types.asteroid_small
    }
    let new_size : Float = if new_tier == @types.asteroid_medium {
      @types.asteroid_medium_size
    } else {
      @types.asteroid_small_size
    }
    let new_hp : Float = if new_tier == @types.asteroid_medium {
      @types.asteroid_medium_hp
    } else {
      @types.asteroid_small_hp
    }

    for c = 0; c < @types.asteroid_break_count; c = c + 1 {
      let cidx = @types.alloc_asteroid(game)
      if cidx < 0 {
        break
      }
      let child = game.asteroids[cidx]
      child.active = true
      child.x = a.x + @types.rand_rangef(game, -1.0, 1.0)
      child.y = a.y + @types.rand_rangef(game, -1.0, 1.0)
      child.z = a.z + @types.rand_rangef(game, -1.0, 1.0)
      child.vx = a.vx + @types.rand_rangef(game, -5.0, 5.0)
      child.vy = a.vy + @types.rand_rangef(game, -3.0, 3.0)
      child.vz = a.vz + @types.rand_rangef(game, -5.0, 5.0)
      child.rot_x = @types.rand_rangef(game, 0.0, 6.28)
      child.rot_y = @types.rand_rangef(game, 0.0, 6.28)
      child.rot_z = @types.rand_rangef(game, 0.0, 6.28)
      child.rot_speed = @types.rand_rangef(game, 0.5, 2.0)
      child.hp = new_hp
      child.size = new_size
      child.size_tier = new_tier
      child.breakable = new_tier != @types.asteroid_small
      ignore(c)
    }
  }
}

///|
pub fn damage_asteroid(game : @types.Game, idx : Int, damage : Float) -> Unit {
  let a = game.asteroids[idx]
  a.hp -= damage
  if a.hp <= 0.0 {
    destroy_asteroid(game, idx)
  }
}
