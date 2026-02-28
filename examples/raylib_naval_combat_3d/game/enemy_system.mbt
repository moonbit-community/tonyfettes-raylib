// Enemy AI and movement

///|
fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  let px = game.player.x
  let pz = game.player.z
  for i in 0..<game.enemies.length() {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue
    }
    let dist_to_player = @types.distance2d(enemy.x, enemy.z, px, pz)
    // AI state transitions based on personality
    update_ai_state(game, i, dist_to_player)
    // Execute behavior
    if enemy.ai_state == @types.ai_patrol {
      update_patrol(game, i, dt)
    } else if enemy.ai_state == @types.ai_chase {
      update_chase(game, i, dt, px, pz)
    } else if enemy.ai_state == @types.ai_attack {
      update_attack(game, i, dt, px, pz)
    } else if enemy.ai_state == @types.ai_retreat {
      update_retreat(game, i, dt, px, pz)
    } else if enemy.ai_state == @types.ai_flank {
      update_flank(game, i, dt, px, pz)
    } else if enemy.ai_state == @types.ai_broadside_run {
      update_broadside_run(game, i, dt, px, pz)
    }
    // Calculate speed based on wind and mast damage
    let mast_ratio : Float = if enemy.max_mast_hp > 0.0 {
      enemy.mast_hp / enemy.max_mast_hp
    } else {
      1.0
    }
    let base_speed = @types.get_class_base_speed(enemy.ship_class)
    let wind_speed = @types.calc_sailing_speed(
      enemy.heading,
      game.wind_angle,
      game.wind_speed,
      enemy.sail_amount,
      mast_ratio,
      base_speed,
    )
    // Use the min of AI-controlled speed and wind-calculated speed
    let actual_speed = @types.minf(enemy.speed, @types.maxf(wind_speed, 1.5))
    // Move enemy based on heading
    let move_speed = actual_speed * dt
    let new_x = enemy.x + @math.sinf(enemy.heading) * move_speed
    let new_z = enemy.z + @math.cosf(enemy.heading) * move_speed
    // Wind drift
    let drift = @types.calc_wind_drift(
      enemy.heading,
      game.wind_angle,
      game.wind_speed,
      actual_speed,
    )
    let drift_x = new_x + drift.0 * dt * 0.3
    let drift_z = new_z + drift.1 * dt * 0.3
    // Island collision
    if not(
        @types.check_island_collision(game, drift_x, drift_z, enemy.ship_width),
      ) {
      let half : Float = @types.ocean_size / 2.0 - 5.0
      enemy.x = @types.clampf(drift_x, -half, half)
      enemy.z = @types.clampf(drift_z, -half, half)
    } else {
      // Reverse heading when hitting island
      enemy.heading = @types.normalize_angle(enemy.heading + @types.pi * 0.5)
    }
    // Ship-to-ship collision avoidance with other enemies
    for j in 0..<game.enemies.length() {
      if i == j {
        continue
      }
      let other = game.enemies[j]
      if not(other.active) {
        continue
      }
      let d = @types.distance2d(enemy.x, enemy.z, other.x, other.z)
      let min_dist = enemy.ship_width + other.ship_width
      if d < min_dist && d > 0.1 {
        // Push apart
        let push_x = (enemy.x - other.x) / d * 0.5
        let push_z = (enemy.z - other.z) / d * 0.5
        enemy.x += push_x
        enemy.z += push_z
      }
    }
    // Firing logic
    enemy.fire_timer -= dt
    enemy.broadside_cooldown -= dt
    if enemy.broadside_cooldown < 0.0 {
      enemy.broadside_cooldown = 0.0
    }
    if enemy.fire_timer <= 0.0 &&
      (
        enemy.ai_state == @types.ai_attack ||
        enemy.ai_state == @types.ai_broadside_run
      ) {
      let can_fire = enemy.crew > 0 && enemy.broadside_cooldown <= 0.0
      if can_fire {
        // Check if player is within firing arc (broadside)
        let to_player = @math.atan2f(px - enemy.x, pz - enemy.z)
        let rel = @types.angle_diff(enemy.heading, to_player)
        let in_broadside_arc = @types.absf(rel) > @types.pi * 0.2 &&
          @types.absf(rel) < @types.pi * 0.8
        if in_broadside_arc && dist_to_player < enemy.attack_range * 1.2 {
          fire_enemy_broadside(game, i)
          enemy.fire_timer = enemy.fire_rate
          enemy.broadside_cooldown = enemy.fire_rate * 0.5
        } else {
          enemy.fire_timer = 0.5
        }
      } else {
        enemy.fire_timer = 1.0
      }
    }
    // Crew affects fire rate
    if enemy.crew < enemy.max_crew / 2 {
      let crew_ratio = Float::from_int(enemy.crew) /
        Float::from_int(enemy.max_crew)
      let penalty : Float = 1.0 + (1.0 - crew_ratio) * 2.0
      if enemy.fire_timer > 0.0 {
        enemy.fire_timer += dt * penalty * 0.1
      }
    }
    // Target convoy ships if applicable
    if enemy.ai_state == @types.ai_attack || enemy.ai_state == @types.ai_chase {
      maybe_target_convoy(game, i, dt)
    }
  }
}

///|
fn update_ai_state(
  game : @types.Game,
  idx : Int,
  dist_to_player : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  let hp_ratio : Float = if enemy.max_hp > 0.0 {
    enemy.hull_hp / enemy.max_hp
  } else {
    1.0
  }
  // Retreat check based on personality
  if hp_ratio < enemy.retreat_hp_pct &&
    enemy.ai_personality != @types.ai_personality_berserker {
    enemy.ai_state = @types.ai_retreat
    return
  }
  // State machine
  if enemy.ai_state == @types.ai_patrol {
    if dist_to_player < enemy.detect_range {
      // Transition based on personality
      if enemy.ai_personality == @types.ai_personality_aggressive ||
        enemy.ai_personality == @types.ai_personality_berserker {
        enemy.ai_state = @types.ai_chase
      } else if enemy.ai_personality == @types.ai_personality_flanker {
        enemy.ai_state = @types.ai_flank
      } else if enemy.ai_personality == @types.ai_personality_defensive {
        enemy.ai_state = @types.ai_attack
      } else {
        enemy.ai_state = @types.ai_chase
      }
    }
  } else if enemy.ai_state == @types.ai_chase {
    if dist_to_player < enemy.attack_range {
      if enemy.ai_personality == @types.ai_personality_flanker {
        enemy.ai_state = @types.ai_broadside_run
      } else {
        enemy.ai_state = @types.ai_attack
      }
    } else if dist_to_player > enemy.detect_range * 1.5 {
      enemy.ai_state = @types.ai_patrol
    }
  } else if enemy.ai_state == @types.ai_attack {
    if dist_to_player > enemy.attack_range * 1.3 {
      enemy.ai_state = @types.ai_chase
    }
    // Berserkers try to close distance for boarding
    if enemy.ai_personality == @types.ai_personality_berserker &&
      dist_to_player < @types.boarding_range * 2.0 {
      // Stay attacking, try to board
      ignore(game)
    }
  } else if enemy.ai_state == @types.ai_retreat {
    if hp_ratio > enemy.retreat_hp_pct + 0.1 {
      enemy.ai_state = @types.ai_patrol
    }
  } else if enemy.ai_state == @types.ai_flank {
    if dist_to_player < enemy.attack_range * 0.7 {
      enemy.ai_state = @types.ai_broadside_run
    } else if dist_to_player > enemy.detect_range * 1.5 {
      enemy.ai_state = @types.ai_patrol
    }
  } else if enemy.ai_state == @types.ai_broadside_run {
    if dist_to_player > enemy.attack_range * 1.2 {
      enemy.ai_state = @types.ai_chase
    }
  }
}

///|
fn update_patrol(game : @types.Game, idx : Int, dt : Float) -> Unit {
  let enemy = game.enemies[idx]
  // Circle around patrol center
  enemy.patrol_angle += dt * 0.3
  let target_x = enemy.patrol_cx +
    @math.sinf(enemy.patrol_angle) * enemy.patrol_radius
  let target_z = enemy.patrol_cz +
    @math.cosf(enemy.patrol_angle) * enemy.patrol_radius
  let desired = @math.atan2f(target_x - enemy.x, target_z - enemy.z)
  let diff = @types.angle_diff(enemy.heading, desired)
  let rudder_ratio : Float = if enemy.max_rudder_hp > 0.0 {
    enemy.rudder_hp / enemy.max_rudder_hp
  } else {
    1.0
  }
  let turn_rate = @types.calc_turn_rate(
      enemy.turn_rate_base,
      rudder_ratio,
      enemy.speed,
      @types.get_class_base_speed(enemy.ship_class),
    ) *
    dt
  if diff > turn_rate {
    enemy.heading += turn_rate
  } else if diff < -turn_rate {
    enemy.heading -= turn_rate
  } else {
    enemy.heading = desired
  }
  enemy.heading = @types.normalize_angle(enemy.heading)
  ignore(game)
}

///|
fn update_chase(
  game : @types.Game,
  idx : Int,
  dt : Float,
  px : Float,
  pz : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Head towards player but try to approach broadside
  let to_player = @math.atan2f(px - enemy.x, pz - enemy.z)
  // Approach at an angle to get broadside position
  let approach_offset : Float = if enemy.ai_personality ==
    @types.ai_personality_aggressive {
    @types.pi * 0.2
  } else if enemy.ai_personality == @types.ai_personality_berserker {
    0.0
  } else {
    @types.pi * 0.3
  }
  let approach_angle = to_player + approach_offset
  let diff = @types.angle_diff(enemy.heading, approach_angle)
  let rudder_ratio : Float = if enemy.max_rudder_hp > 0.0 {
    enemy.rudder_hp / enemy.max_rudder_hp
  } else {
    1.0
  }
  let turn_rate = @types.calc_turn_rate(
      enemy.turn_rate_base,
      rudder_ratio,
      enemy.speed,
      @types.get_class_base_speed(enemy.ship_class),
    ) *
    dt *
    1.2
  if diff > turn_rate {
    enemy.heading += turn_rate
  } else if diff < -turn_rate {
    enemy.heading -= turn_rate
  } else {
    enemy.heading = approach_angle
  }
  enemy.heading = @types.normalize_angle(enemy.heading)
  ignore(game)
}

///|
fn update_attack(
  game : @types.Game,
  idx : Int,
  dt : Float,
  px : Float,
  pz : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Circle the player at attack range, keeping broadside
  let to_player = @math.atan2f(px - enemy.x, pz - enemy.z)
  let dist = @types.distance2d(enemy.x, enemy.z, px, pz)
  // Orbit angle depends on personality
  let orbit_angle : Float = if dist < enemy.attack_range * 0.6 {
    // Too close, angle away
    let away_mult : Float = if enemy.ai_personality ==
      @types.ai_personality_defensive {
      0.8
    } else {
      0.7
    }
    to_player + @types.pi * away_mult
  } else if dist > enemy.attack_range {
    // Too far, angle towards
    let toward_mult : Float = if enemy.ai_personality ==
      @types.ai_personality_aggressive {
      0.15
    } else {
      0.2
    }
    to_player + @types.pi * toward_mult
  } else {
    // Good distance, circle
    to_player + @types.pi * 0.5
  }
  let diff = @types.angle_diff(enemy.heading, orbit_angle)
  let rudder_ratio : Float = if enemy.max_rudder_hp > 0.0 {
    enemy.rudder_hp / enemy.max_rudder_hp
  } else {
    1.0
  }
  let turn_rate = @types.calc_turn_rate(
      enemy.turn_rate_base,
      rudder_ratio,
      enemy.speed,
      @types.get_class_base_speed(enemy.ship_class),
    ) *
    dt *
    1.3
  if diff > turn_rate {
    enemy.heading += turn_rate
  } else if diff < -turn_rate {
    enemy.heading -= turn_rate
  } else {
    enemy.heading = orbit_angle
  }
  enemy.heading = @types.normalize_angle(enemy.heading)
  ignore(game)
}

///|
fn update_retreat(
  game : @types.Game,
  idx : Int,
  dt : Float,
  px : Float,
  pz : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Run away from player
  let away_from_player = @math.atan2f(enemy.x - px, enemy.z - pz)
  // Try to use wind advantage
  let wind_bonus = @types.angle_diff(away_from_player, game.wind_angle)
  let retreat_angle : Float = if @types.absf(wind_bonus) < @types.pi * 0.3 {
    away_from_player
  } else {
    // Adjust to get better wind
    away_from_player + wind_bonus * 0.2
  }
  let diff = @types.angle_diff(enemy.heading, retreat_angle)
  let rudder_ratio : Float = if enemy.max_rudder_hp > 0.0 {
    enemy.rudder_hp / enemy.max_rudder_hp
  } else {
    1.0
  }
  let turn_rate = @types.calc_turn_rate(
      enemy.turn_rate_base,
      rudder_ratio,
      enemy.speed,
      @types.get_class_base_speed(enemy.ship_class),
    ) *
    dt *
    1.5
  if diff > turn_rate {
    enemy.heading += turn_rate
  } else if diff < -turn_rate {
    enemy.heading -= turn_rate
  } else {
    enemy.heading = retreat_angle
  }
  enemy.heading = @types.normalize_angle(enemy.heading)
  // Full sail when retreating
  enemy.sail_amount = 1.0
  ignore(game)
}

///|
fn update_flank(
  game : @types.Game,
  idx : Int,
  dt : Float,
  px : Float,
  pz : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Approach from an oblique angle, using wind advantage
  let to_player = @math.atan2f(px - enemy.x, pz - enemy.z)
  // Flankers approach at 60-90 degree offset
  let flank_offset : Float = @types.pi * 0.45
  let dist = @types.distance2d(enemy.x, enemy.z, px, pz)
  let flank_angle : Float = if dist > enemy.attack_range * 0.8 {
    to_player + flank_offset
  } else {
    // Close enough, start circling for broadside
    to_player + @types.pi * 0.5
  }
  let diff = @types.angle_diff(enemy.heading, flank_angle)
  let rudder_ratio : Float = if enemy.max_rudder_hp > 0.0 {
    enemy.rudder_hp / enemy.max_rudder_hp
  } else {
    1.0
  }
  let turn_rate = @types.calc_turn_rate(
      enemy.turn_rate_base,
      rudder_ratio,
      enemy.speed,
      @types.get_class_base_speed(enemy.ship_class),
    ) *
    dt *
    1.2
  if diff > turn_rate {
    enemy.heading += turn_rate
  } else if diff < -turn_rate {
    enemy.heading -= turn_rate
  } else {
    enemy.heading = flank_angle
  }
  enemy.heading = @types.normalize_angle(enemy.heading)
  ignore(game)
}

///|
fn update_broadside_run(
  game : @types.Game,
  idx : Int,
  dt : Float,
  px : Float,
  pz : Float,
) -> Unit {
  let enemy = game.enemies[idx]
  // Sail parallel to the player at attack range, firing broadsides
  let to_player = @math.atan2f(px - enemy.x, pz - enemy.z)
  let dist = @types.distance2d(enemy.x, enemy.z, px, pz)
  // Maintain parallel heading
  let player_heading = game.player.heading
  let parallel_angle : Float = if dist < enemy.attack_range * 0.5 {
    // Too close, angle slightly away
    player_heading + @types.pi * 0.15
  } else if dist > enemy.attack_range * 0.9 {
    // Too far, angle slightly toward
    to_player + @types.pi * 0.3
  } else {
    // Good range, run parallel
    player_heading
  }
  let diff = @types.angle_diff(enemy.heading, parallel_angle)
  let rudder_ratio : Float = if enemy.max_rudder_hp > 0.0 {
    enemy.rudder_hp / enemy.max_rudder_hp
  } else {
    1.0
  }
  let turn_rate = @types.calc_turn_rate(
      enemy.turn_rate_base,
      rudder_ratio,
      enemy.speed,
      @types.get_class_base_speed(enemy.ship_class),
    ) *
    dt
  if diff > turn_rate {
    enemy.heading += turn_rate
  } else if diff < -turn_rate {
    enemy.heading -= turn_rate
  } else {
    enemy.heading = parallel_angle
  }
  enemy.heading = @types.normalize_angle(enemy.heading)
  ignore(game)
}

///|
fn maybe_target_convoy(game : @types.Game, enemy_idx : Int, dt : Float) -> Unit {
  ignore(dt)
  let enemy = game.enemies[enemy_idx]
  // Check if any convoy ships are closer than the player
  let dist_to_player = @types.distance2d(
    enemy.x,
    enemy.z,
    game.player.x,
    game.player.z,
  )
  for cs in game.convoy_ships {
    if not(cs.active) {
      continue
    }
    if cs.arrived {
      continue
    }
    let dist_to_convoy = @types.distance2d(enemy.x, enemy.z, cs.x, cs.z)
    // Prefer attacking convoy if it's significantly closer
    if dist_to_convoy < dist_to_player * 0.6 &&
      dist_to_convoy < enemy.detect_range {
      // Turn towards convoy instead
      enemy.target_heading = @types.bearing(enemy.x, enemy.z, cs.x, cs.z)
      return
    }
  }
}

///|
fn fire_enemy_broadside(game : @types.Game, enemy_idx : Int) -> Unit {
  let enemy = game.enemies[enemy_idx]
  let px = game.player.x
  let pz = game.player.z
  // Determine which side faces the player
  let to_player = @math.atan2f(px - enemy.x, pz - enemy.z)
  let rel = @types.angle_diff(enemy.heading, to_player)
  let side_angle : Float = if rel > 0.0 {
    enemy.heading + @types.pi / 2.0
  } else {
    enemy.heading - @types.pi / 2.0
  }
  // Number of cannonballs based on cannon count
  let shots : Int = @types.mini(enemy.cannon_count / 2, 4)
  for i in 0..<shots {
    let idx = @types.alloc_cannonball(game)
    if idx < 0 {
      break
    }
    let cb = game.cannonballs[idx]
    let spread_f : Float = Float::from_int(i) - Float::from_int(shots) / 2.0
    let spread = spread_f * 0.15
    let fire_angle = side_angle + spread
    cb.active = true
    cb.x = enemy.x + @math.sinf(fire_angle) * (enemy.ship_width * 0.6)
    cb.y = 1.2
    cb.z = enemy.z + @math.cosf(fire_angle) * (enemy.ship_width * 0.6)
    // Aim at player with inaccuracy based on class
    let aim_dx = px - cb.x
    let aim_dz = pz - cb.z
    let aim_dist = @types.distance2d(cb.x, cb.z, px, pz)
    let cannon_spd = @types.get_cannon_speed(enemy.cannon_type)
    let inaccuracy : Float = if enemy.ship_class == @types.class_man_of_war {
      1.5
    } else if enemy.ship_class == @types.class_galleon {
      2.0
    } else if enemy.ship_class == @types.class_frigate {
      2.5
    } else {
      3.0
    }
    if aim_dist > 0.1 {
      cb.vx = aim_dx / aim_dist * cannon_spd +
        @types.rand_rangef(game, -inaccuracy, inaccuracy)
      cb.vz = aim_dz / aim_dist * cannon_spd +
        @types.rand_rangef(game, -inaccuracy, inaccuracy)
    } else {
      cb.vx = @math.sinf(fire_angle) * cannon_spd
      cb.vz = @math.cosf(fire_angle) * cannon_spd
    }
    let arc = @types.get_cannon_arc(enemy.cannon_type)
    cb.vy = arc + @types.rand_rangef(game, 0.0, 2.0)
    cb.life = @types.cannonball_life
    cb.damage = enemy.cannon_damage
    cb.from_player = false
    cb.ammo_type = @types.ammo_round_shot
    cb.cannon_type = enemy.cannon_type
  }
  // Muzzle flash and smoke
  let flash_x = enemy.x + @math.sinf(side_angle) * (enemy.ship_width * 0.8)
  let flash_z = enemy.z + @math.cosf(side_angle) * (enemy.ship_width * 0.8)
  @types.spawn_particles(game, flash_x, 1.2, flash_z, 5, 255, 180, 80)
  @types.spawn_smoke(game, flash_x, 1.5, flash_z, 3)
}
