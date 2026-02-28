// Cannonball physics and hit detection

///|
fn update_cannonballs(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.cannonballs.length() {
    let cb = game.cannonballs[i]
    if not(cb.active) {
      continue
    }
    // Update lifetime
    cb.life -= dt
    if cb.life <= 0.0 {
      cb.active = false
      continue
    }
    // Apply gravity
    cb.vy -= @types.gravity * dt
    // Apply wind drift to cannonball
    let wind_dx = @math.sinf(game.wind_angle) * game.wind_speed * 0.05
    let wind_dz = @math.cosf(game.wind_angle) * game.wind_speed * 0.05
    cb.vx += wind_dx * dt
    cb.vz += wind_dz * dt
    // Move
    cb.x += cb.vx * dt
    cb.y += cb.vy * dt
    cb.z += cb.vz * dt
    // Trail timer for visual
    cb.trail_timer += dt
    // Check if hit water (y <= 0)
    if cb.y <= 0.0 {
      // Water splash - bigger for heavier shots
      let splash_count : Int = if cb.cannon_type == @types.cannon_heavy {
        10
      } else if cb.cannon_type == @types.cannon_mortar {
        12
      } else {
        6
      }
      @types.spawn_water_splash(game, cb.x, cb.z, splash_count)
      cb.active = false
      continue
    }
    // Check hit against targets
    if cb.from_player {
      // Check against enemy ships
      check_cannonball_vs_enemies(game, i)
      // Check against convoy (friendly fire check is implicit - these are from_player)
    } else {
      // Check against player
      check_cannonball_vs_player(game, i)
      // Check against fleet ships
      check_cannonball_vs_fleet(game, i)
      // Check against convoy ships
      check_cannonball_vs_convoy(game, i)
    }
    // Check against fortress islands
    if cb.from_player {
      check_cannonball_vs_fortress(game, i)
    }
    // Check against islands (solid)
    if cb.active &&
      @types.check_island_collision(game, cb.x, cb.z, 0.3) &&
      cb.y < 5.0 {
      @types.spawn_particles(game, cb.x, cb.y, cb.z, 5, 150, 130, 100)
      cb.active = false
    }
  }
}

///|
fn check_cannonball_vs_enemies(game : @types.Game, cb_idx : Int) -> Unit {
  let cb = game.cannonballs[cb_idx]
  if not(cb.active) {
    return
  }
  for enemy in game.enemies {
    if not(enemy.active) {
      continue
    }
    let dist = @types.distance3d(cb.x, cb.y, cb.z, enemy.x, 1.0, enemy.z)
    let hit_radius : Float = enemy.ship_width * 0.8 + 0.5
    if dist < hit_radius {
      // Hit! Apply damage based on ammo type
      let base_dmg = cb.damage
      let hull_mult = @types.get_ammo_hull_mult(cb.ammo_type)
      let mast_mult = @types.get_ammo_mast_mult(cb.ammo_type)
      let crew_mult = @types.get_ammo_crew_mult(cb.ammo_type)
      // Hull damage
      let hull_dmg = base_dmg * hull_mult
      enemy.hull_hp -= hull_dmg
      // Mast damage
      let mast_dmg = base_dmg * mast_mult
      enemy.mast_hp -= mast_dmg
      if enemy.mast_hp < 0.0 {
        enemy.mast_hp = 0.0
      }
      // Rudder damage (occasional)
      let to_cb = @math.atan2f(cb.x - enemy.x, cb.z - enemy.z)
      let rel_angle = @types.absf(@types.angle_diff(enemy.heading, to_cb))
      if rel_angle < @types.pi * 0.25 || rel_angle > @types.pi * 0.75 {
        let rudder_dmg = base_dmg * 0.3
        enemy.rudder_hp -= rudder_dmg
        if enemy.rudder_hp < 0.0 {
          enemy.rudder_hp = 0.0
        }
      }
      // Crew casualties
      let crew_dmg = (base_dmg * crew_mult * 0.5).to_int()
      enemy.crew -= @types.maxi(crew_dmg, 0)
      if enemy.crew < 0 {
        enemy.crew = 0
      }
      // Track stats
      game.battle_stats.damage_dealt += hull_dmg
      game.battle_stats.accuracy_hits += 1
      game.player.damage_dealt += hull_dmg
      // Particles
      @types.spawn_particles(game, cb.x, cb.y, cb.z, 8, 255, 150, 50)
      @types.spawn_smoke(game, cb.x, cb.y + 0.5, cb.z, 3)
      // Chain shot can cause fire
      if cb.ammo_type == @types.ammo_chain_shot &&
        @types.rand_range(game, 0, 100) < 15 {
        enemy.on_fire = true
        enemy.fire_timer_decay = 5.0
        @types.add_battle_message(game, "Enemy ship on fire!", 255, 200, 50)
      }
      cb.active = false
      if enemy.hull_hp <= 0.0 {
        enemy.active = false
        game.score += enemy.score_value
        game.battle_stats.ships_sunk += 1
        game.player.kills += 1
        // Big explosion
        @types.spawn_particles(game, enemy.x, 1.0, enemy.z, 25, 255, 100, 30)
        @types.spawn_particles(game, enemy.x, 2.0, enemy.z, 15, 80, 80, 80)
        @types.spawn_fire(game, enemy.x, 1.5, enemy.z, 10)
        @types.spawn_smoke(game, enemy.x, 2.5, enemy.z, 8)
        @types.spawn_debris_cluster(game, enemy.x, enemy.z, 10)
        let class_name = @types.get_class_name(enemy.ship_class)
        @types.add_battle_message(
          game,
          "\{class_name} destroyed!",
          255,
          200,
          50,
        )
        @types.add_battle_log(game, "Sank enemy \{class_name}")
        // Reputation bonus for flagships
        if enemy.is_flagship {
          game.reputation += 200
          @types.add_battle_message(
            game, "FLAGSHIP SUNK! +200 Rep", 255, 220, 100,
          )
        }
      }
      return
    }
  }
}

///|
fn check_cannonball_vs_player(game : @types.Game, cb_idx : Int) -> Unit {
  let cb = game.cannonballs[cb_idx]
  if not(cb.active) {
    return
  }
  let ship = game.player
  let dist = @types.distance3d(cb.x, cb.y, cb.z, ship.x, 1.0, ship.z)
  let hit_radius : Float = ship.ship_width * 0.8 + 0.5
  if dist < hit_radius {
    let base_dmg = cb.damage
    // Determine which zone was hit based on cannonball position relative to ship
    let to_cb = @math.atan2f(cb.x - ship.x, cb.z - ship.z)
    let rel_angle = @types.absf(@types.angle_diff(ship.heading, to_cb))
    if rel_angle < @types.pi * 0.25 {
      // Hit from front - bow damage
      ship.bow_hp -= base_dmg
      if ship.bow_hp < 0.0 {
        ship.bow_hp = 0.0
      }
      ship.hull_hp -= base_dmg * 0.7
    } else if rel_angle > @types.pi * 0.75 {
      // Hit from stern - rudder/stern damage
      ship.stern_hp -= base_dmg
      if ship.stern_hp < 0.0 {
        ship.stern_hp = 0.0
      }
      ship.rudder_hp -= base_dmg * 0.5
      if ship.rudder_hp < 0.0 {
        ship.rudder_hp = 0.0
      }
      ship.hull_hp -= base_dmg * 0.5
    } else if cb.y > 2.5 {
      // High hit - mast/sail damage
      ship.mast_hp -= base_dmg * 0.8
      if ship.mast_hp < 0.0 {
        ship.mast_hp = 0.0
      }
      ship.sail_hp -= base_dmg
      if ship.sail_hp < 0.0 {
        ship.sail_hp = 0.0
      }
    } else {
      // Broadside - hull + cannon deck
      ship.mid_hp -= base_dmg
      if ship.mid_hp < 0.0 {
        ship.mid_hp = 0.0
      }
      ship.hull_hp -= base_dmg
      ship.cannon_deck_hp -= base_dmg * 0.3
      if ship.cannon_deck_hp < 0.0 {
        ship.cannon_deck_hp = 0.0
      }
    }
    if ship.hull_hp < 0.0 {
      ship.hull_hp = 0.0
    }
    // Crew casualties
    let crew_loss = (base_dmg * 0.15).to_int()
    ship.crew -= @types.maxi(crew_loss, 0)
    if ship.crew < 0 {
      ship.crew = 0
    }
    // Track stats
    game.battle_stats.damage_taken += base_dmg
    game.player.damage_taken += base_dmg
    let crew_before = ship.crew + crew_loss
    game.battle_stats.crew_lost += crew_before - ship.crew
    // Effects
    @types.spawn_particles(game, cb.x, cb.y, cb.z, 8, 200, 150, 50)
    @types.spawn_smoke(game, cb.x, cb.y + 0.3, cb.z, 2)
    // Possible fire from heavy hits
    if base_dmg > 15.0 && @types.rand_range(game, 0, 100) < 10 {
      ship.on_fire = true
      ship.fire_timer = 4.0
      @types.add_battle_message(
        game, "Ship on fire! Hull taking damage!", 255, 80, 30,
      )
    }
    cb.active = false
  }
}

///|
fn check_cannonball_vs_fleet(game : @types.Game, cb_idx : Int) -> Unit {
  let cb = game.cannonballs[cb_idx]
  if not(cb.active) {
    return
  }
  for fs in game.fleet_ships {
    if not(fs.active) {
      continue
    }
    let dist = @types.distance3d(cb.x, cb.y, cb.z, fs.x, 1.0, fs.z)
    if dist < fs.ship_width + 0.5 {
      fs.hull_hp -= cb.damage
      @types.spawn_particles(game, cb.x, cb.y, cb.z, 6, 200, 150, 50)
      cb.active = false
      if fs.hull_hp <= 0.0 {
        fs.active = false
        @types.spawn_particles(game, fs.x, 1.0, fs.z, 20, 255, 100, 30)
        @types.spawn_smoke(game, fs.x, 2.0, fs.z, 10)
        @types.spawn_debris_cluster(game, fs.x, fs.z, 6)
        let cn = @types.get_class_name(fs.ship_class)
        @types.add_battle_message(game, "Allied \{cn} sunk!", 255, 100, 100)
        @types.add_battle_log(game, "Lost allied \{cn}")
      }
      return
    }
  }
}

///|
fn check_cannonball_vs_convoy(game : @types.Game, cb_idx : Int) -> Unit {
  let cb = game.cannonballs[cb_idx]
  if not(cb.active) {
    return
  }
  for cs in game.convoy_ships {
    if not(cs.active) {
      continue
    }
    if cs.arrived {
      continue
    }
    let dist = @types.distance3d(cb.x, cb.y, cb.z, cs.x, 1.0, cs.z)
    if dist < 2.0 {
      cs.hull_hp -= cb.damage
      @types.spawn_particles(game, cb.x, cb.y, cb.z, 6, 200, 150, 50)
      cb.active = false
      if cs.hull_hp <= 0.0 {
        cs.active = false
        @types.spawn_particles(game, cs.x, 1.0, cs.z, 15, 255, 100, 30)
        @types.spawn_debris_cluster(game, cs.x, cs.z, 5)
        @types.add_battle_message(game, "Convoy ship destroyed!", 255, 80, 60)
      }
      return
    }
  }
}

///|
fn check_cannonball_vs_fortress(game : @types.Game, cb_idx : Int) -> Unit {
  let cb = game.cannonballs[cb_idx]
  if not(cb.active) {
    return
  }
  for i in 0..<game.island_count {
    let island = game.islands[i]
    if not(island.active) {
      continue
    }
    if not(island.has_fortress) {
      continue
    }
    if island.fortress_hp <= 0.0 {
      continue
    }
    let dist = @types.distance2d(cb.x, cb.z, island.x, island.z)
    if dist < island.radius + 2.0 && cb.y > island.height * 0.3 {
      island.fortress_hp -= cb.damage * 0.8
      @types.spawn_particles(game, cb.x, cb.y, cb.z, 8, 180, 160, 130)
      @types.spawn_smoke(game, cb.x, cb.y + 1.0, cb.z, 4)
      cb.active = false
      game.battle_stats.damage_dealt += cb.damage * 0.8
      if island.fortress_hp <= 0.0 {
        island.fortress_hp = 0.0
        island.fortress_cannons_active = 0
        game.battle_stats.fortresses_destroyed += 1
        game.score += @types.score_fortress_kill
        game.reputation += @types.score_fortress_kill
        @types.spawn_particles(
          game,
          island.x,
          island.height + 2.0,
          island.z,
          30,
          255,
          120,
          30,
        )
        @types.spawn_smoke(game, island.x, island.height + 3.0, island.z, 15)
        @types.add_battle_message(game, "FORTRESS DESTROYED!", 255, 220, 100)
        @types.add_battle_log(game, "Fortress destroyed!")
      } else {
        // Reduce active cannons as fortress takes damage
        let hp_ratio = island.fortress_hp / island.fortress_max_hp
        let active_f : Float = Float::from_int(@types.fortress_cannon_count) *
          hp_ratio
        island.fortress_cannons_active = @types.maxi(active_f.to_int(), 1)
      }
      return
    }
  }
}

// Boarding combat system

///|
pub fn update_boarding(game : @types.Game, dt : Float) -> Unit {
  let ship = game.player
  if ship.boarding_target < 0 {
    return
  }
  if ship.boarding_target >= game.enemies.length() {
    ship.boarding_target = -1
    return
  }
  let enemy = game.enemies[ship.boarding_target]
  if not(enemy.active) {
    ship.boarding_target = -1
    return
  }
  // Check still in range
  let dist = @types.distance2d(ship.x, ship.z, enemy.x, enemy.z)
  if dist > @types.boarding_range * 1.5 {
    ship.boarding_target = -1
    @types.add_battle_message(game, "Boarding failed - too far!", 255, 150, 100)
    return
  }
  ship.boarding_timer -= dt
  if ship.boarding_timer <= 0.0 {
    // Resolve boarding
    let success = @types.resolve_boarding(ship.crew, enemy.crew, game)
    if success {
      // Capture the enemy
      enemy.active = false
      game.score += enemy.score_value * 2
      game.reputation += enemy.score_value
      game.battle_stats.boarding_wins += 1
      // Take some crew losses
      let losses = enemy.crew / 3
      ship.crew -= losses
      if ship.crew < 1 {
        ship.crew = 1
      }
      game.battle_stats.crew_lost += losses
      game.battle_stats.ships_sunk += 1
      game.player.kills += 1
      let cn = @types.get_class_name(enemy.ship_class)
      @types.add_battle_message(
        game,
        "Boarded and captured \{cn}!",
        100,
        255,
        100,
      )
      @types.add_battle_log(game, "Captured enemy \{cn}")
    } else {
      // Failed boarding - take heavy crew losses
      let losses = ship.crew / 4
      ship.crew -= losses
      if ship.crew < 1 {
        ship.crew = 1
      }
      game.battle_stats.crew_lost += losses
      // Enemy also loses some
      enemy.crew -= enemy.crew / 5
      if enemy.crew < 1 {
        enemy.crew = 1
      }
      @types.add_battle_message(
        game, "Boarding repelled! Crew losses!", 255, 100, 100,
      )
    }
    ship.boarding_target = -1
  }
}
