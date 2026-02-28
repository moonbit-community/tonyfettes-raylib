// Mission logic update

pub fn update_mission_logic(game : @types.Game, dt : Float) -> Unit {
  let mission = game.missions[game.current_mission]
  game.mission_timer += dt
  // Time limit check
  if mission.time_limit > 0.0 && game.mission_timer >= mission.time_limit {
    if mission.kind != @types.mission_survive {
      @types.show_message(game, "TIME'S UP!", 3.0)
      game.state = @types.state_game_over
      return
    }
  }
  if mission.kind == @types.mission_checkpoint || mission.kind == @types.mission_canyon_run {
    // Check all checkpoints collected
    if mission.targets_done >= mission.target_count {
      complete_mission(game)
    }
  } else if mission.kind == @types.mission_destroy || mission.kind == @types.mission_dogfight || mission.kind == @types.mission_intercept || mission.kind == @types.mission_boss {
    // Check all enemies destroyed
    if mission.targets_done >= mission.target_count {
      complete_mission(game)
    }
  } else if mission.kind == @types.mission_landing {
    // Landing checked in player_system
    if mission.targets_done >= mission.target_count {
      complete_mission(game)
    }
  } else if mission.kind == @types.mission_survive {
    // Survive for target_count seconds
    let survive_time = Float::from_int(mission.target_count)
    if game.mission_timer >= survive_time {
      mission.targets_done = mission.target_count
      complete_mission(game)
    } else {
      mission.targets_done = game.mission_timer.to_int()
    }
  } else if mission.kind == @types.mission_escort {
    if mission.targets_done >= mission.target_count {
      complete_mission(game)
    }
  } else if mission.kind == @types.mission_bombing_run || mission.kind == @types.mission_attack_base {
    // Destroy buildings/installations
    if mission.targets_done >= mission.target_count {
      complete_mission(game)
    }
  } else if mission.kind == @types.mission_recon {
    // Fly near recon targets (use checkpoints as recon waypoints)
    if mission.targets_done >= mission.target_count {
      complete_mission(game)
    }
  } else if mission.kind == @types.mission_defense {
    // Destroy attacking enemies before time runs out
    if mission.targets_done >= mission.target_count {
      complete_mission(game)
    }
    // Check if any friendly buildings are still standing
    let buildings_alive = @types.count_active_buildings(game)
    if buildings_alive <= 0 && mission.building_count > 0 {
      @types.show_message(game, "Base destroyed - mission failed!", 3.0)
      game.state = @types.state_game_over
    }
  } else if mission.kind == @types.mission_patrol {
    if mission.targets_done >= mission.target_count {
      complete_mission(game)
    }
  } else if mission.kind == @types.mission_night_mission {
    if mission.targets_done >= mission.target_count {
      complete_mission(game)
    }
  }
  // Periodic mission status messages
  if mission.kind == @types.mission_survive {
    let remaining = mission.target_count - mission.targets_done
    if remaining == 30 && game.mission_timer > 0.5 {
      let timer_check = (game.mission_timer * 10.0).to_int()
      if timer_check % 10 == 0 {
        @types.push_message(game, "30 seconds remaining!", 2.0, 1)
      }
    }
    if remaining == 10 {
      let timer_check2 = (game.mission_timer * 10.0).to_int()
      if timer_check2 % 10 == 0 {
        @types.push_message(game, "10 seconds - hold on!", 2.0, 2)
      }
    }
  }
}

fn complete_mission(game : @types.Game) -> Unit {
  let mission = game.missions[game.current_mission]
  game.missions_completed += 1
  let time_bonus = @types.maxf(0.0, 120.0 - game.mission_timer).to_int() * 10
  let kill_bonus = game.kills * 25
  game.mission_score += @types.score_mission_complete + time_bonus + kill_bonus
  game.score += game.mission_score
  // Calculate accuracy
  game.accuracy_pct = @types.calculate_accuracy(
    game.player.shots_fired, game.player.shots_hit,
  )
  // Calculate rating
  game.mission_rating = @types.calculate_rating(game.mission_score)
  // Update best score
  if game.mission_score > game.best_scores[game.current_mission] {
    game.best_scores[game.current_mission] = game.mission_score
  }
  @types.show_message(
    game,
    "Mission Complete: " + mission.name + "!",
    4.0,
  )
  game.state = @types.state_mission_complete
}

pub fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let e = game.enemies[i]
    if not(e.active) { continue i + 1 }
    // Flash timer
    if e.flash_timer > 0.0 {
      e.flash_timer -= dt
    }
    if e.kind == @types.enemy_type_air {
      update_air_enemy_ai(game, e, player, dt)
    } else {
      update_ground_enemy(game, e, player, dt)
    }
  }
}

fn update_air_enemy_ai(
  game : @types.Game,
  e : @types.Enemy,
  player : @types.Player,
  dt : Float
) -> Unit {
  let dist_to_player = @types.distance3d(
    e.x, e.y, e.z, player.x, player.y, player.z,
  )
  // Maneuver timer
  if e.maneuver_timer > 0.0 {
    e.maneuver_timer -= dt
  }
  if e.evade_timer > 0.0 {
    e.evade_timer -= dt
  }
  // AI state transitions
  let hp_ratio = e.hp / e.max_hp
  if hp_ratio < @types.ai_flee_hp_ratio && e.ai_state != @types.ai_flee {
    e.ai_state = @types.ai_flee
    e.maneuver_timer = 0.0
  } else if e.evade_timer > 0.0 && e.ai_state != @types.ai_flee {
    e.ai_state = @types.ai_evade
  } else if dist_to_player < @types.ai_engage_range && e.ai_state == @types.ai_patrol {
    e.ai_state = @types.ai_engage
  } else if dist_to_player > @types.ai_disengage_range && e.ai_state == @types.ai_engage {
    e.ai_state = @types.ai_patrol
  }
  // Execute AI behavior
  if e.ai_state == @types.ai_patrol {
    ai_patrol(game, e, dt)
  } else if e.ai_state == @types.ai_engage {
    ai_engage(game, e, player, dt)
  } else if e.ai_state == @types.ai_evade {
    ai_evade(game, e, player, dt)
  } else if e.ai_state == @types.ai_flee {
    ai_flee(game, e, player, dt)
  } else {
    ai_patrol(game, e, dt)
  }
  // Apply velocity
  e.x += e.vx * dt
  e.y += e.vy * dt
  e.z += e.vz * dt
  // Keep above terrain
  let ground = @types.terrain_height_at(e.x, e.z) + 5.0
  if e.y < ground { e.y = ground }
  // Fire at player if engaging
  if e.ai_state == @types.ai_engage {
    e.fire_timer -= dt
    if e.fire_timer <= 0.0 {
      if dist_to_player < @types.enemy_fire_range {
        enemy_fire(game, e, player)
        e.fire_timer = @types.enemy_fire_rate * (1.0 - e.aggression * 0.5)
      }
    }
  }
}

fn ai_patrol(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float
) -> Unit {
  // Orbit around patrol center
  e.orbit_angle += e.speed * 0.02 * dt
  if e.orbit_angle > @types.two_pi {
    e.orbit_angle -= @types.two_pi
  }
  let target_x = e.patrol_cx + @math.cosf(e.orbit_angle) * e.orbit_radius
  let target_z = e.patrol_cz + @math.sinf(e.orbit_angle) * e.orbit_radius
  let dx = target_x - e.x
  let dz = target_z - e.z
  let dy = e.target_y - e.y
  let dist_h = (dx * dx + dz * dz).sqrt()
  if dist_h > 1.0 {
    e.vx = dx / dist_h * e.speed
    e.vz = dz / dist_h * e.speed
  }
  e.vy = @types.clampf(dy * 2.0, -5.0, 5.0)
  e.heading = @math.atan2f(e.vx, e.vz)
  ignore(game)
}

fn ai_engage(
  game : @types.Game,
  e : @types.Enemy,
  player : @types.Player,
  dt : Float
) -> Unit {
  // Turn toward player and close distance
  let dx = player.x - e.x
  let dy = player.y - e.y
  let dz = player.z - e.z
  let dist_h = (dx * dx + dz * dz).sqrt()
  let engage_speed = e.speed * (1.0 + e.aggression * 0.5)
  if dist_h > 1.0 {
    // Pursuit with lead
    let lead_factor : Float = 0.5
    let pred_x = player.x + player.speed * @math.sinf(player.yaw) * lead_factor
    let pred_z = player.z + player.speed * @math.cosf(player.yaw) * lead_factor
    let ldx = pred_x - e.x
    let ldz = pred_z - e.z
    let ldist = (ldx * ldx + ldz * ldz).sqrt()
    if ldist > 1.0 {
      e.vx = @types.lerpf(e.vx, ldx / ldist * engage_speed, 2.0 * dt)
      e.vz = @types.lerpf(e.vz, ldz / ldist * engage_speed, 2.0 * dt)
    }
  }
  // Match altitude with some offset
  let target_alt = player.y + @types.rand_rangef(game, -3.0, 5.0) * e.aggression
  e.vy = @types.clampf((target_alt - e.y) * 2.0, -8.0, 8.0)
  e.heading = @math.atan2f(e.vx, e.vz)
  ignore(dy)
  ignore(dt)
}

fn ai_evade(
  game : @types.Game,
  e : @types.Enemy,
  player : @types.Player,
  dt : Float
) -> Unit {
  // Break turn - turn perpendicular to player direction and climb
  let dx = player.x - e.x
  let dz = player.z - e.z
  let dist_h = (dx * dx + dz * dz).sqrt()
  if dist_h > 1.0 {
    // Turn perpendicular (cross product with up)
    let perp_x = -dz / dist_h
    let perp_z = dx / dist_h
    e.vx = @types.lerpf(e.vx, perp_x * e.speed * 1.2, 3.0 * dt)
    e.vz = @types.lerpf(e.vz, perp_z * e.speed * 1.2, 3.0 * dt)
  }
  // Climb during evasion
  e.vy = @types.clampf(e.vy + 5.0 * dt, -3.0, 8.0)
  e.heading = @math.atan2f(e.vx, e.vz)
  // Transition back to engage when evade timer expires
  if e.evade_timer <= 0.0 {
    e.ai_state = @types.ai_engage
  }
  ignore(game)
}

fn ai_flee(
  game : @types.Game,
  e : @types.Enemy,
  player : @types.Player,
  dt : Float
) -> Unit {
  // Fly directly away from player
  let dx = e.x - player.x
  let dz = e.z - player.z
  let dist_h = (dx * dx + dz * dz).sqrt()
  if dist_h > 1.0 {
    e.vx = @types.lerpf(e.vx, dx / dist_h * e.speed * 1.3, 2.0 * dt)
    e.vz = @types.lerpf(e.vz, dz / dist_h * e.speed * 1.3, 2.0 * dt)
  }
  // Climb to escape
  e.vy = @types.clampf(e.vy + 3.0 * dt, -2.0, 6.0)
  e.heading = @math.atan2f(e.vx, e.vz)
  ignore(game)
}

fn update_ground_enemy(
  game : @types.Game,
  e : @types.Enemy,
  player : @types.Player,
  dt : Float
) -> Unit {
  // Ground enemies stay stationary but fire at player
  e.fire_timer -= dt
  if e.fire_timer <= 0.0 {
    let dist = @types.distance3d(e.x, e.y, e.z, player.x, player.y, player.z)
    if dist < @types.enemy_fire_range {
      enemy_fire(game, e, player)
      e.fire_timer = @types.enemy_fire_rate + @types.rand_rangef(
        game, 0.0, 1.0,
      )
    }
  }
  // Update heading to face player
  e.heading = @types.bearing_to(e.x, e.z, player.x, player.z)
}

fn enemy_fire(
  game : @types.Game,
  e : @types.Enemy,
  player : @types.Player
) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 { return }
  let dx = player.x - e.x
  let dy = player.y - e.y
  let dz = player.z - e.z
  let (nx, ny, nz) = @types.normalize3d(dx, dy, dz)
  let proj = game.projectiles[idx]
  proj.active = true
  proj.kind = @types.proj_bullet
  proj.x = e.x + nx * 2.0
  proj.y = e.y + ny * 2.0
  proj.z = e.z + nz * 2.0
  proj.dx = nx
  proj.dy = ny
  proj.dz = nz
  proj.speed = 60.0
  proj.damage = 10.0
  proj.life = 3.0
  proj.is_enemy = true
  proj.gravity_affected = false
  proj.blast_radius = 0.0
}

pub fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    let proj = game.projectiles[i]
    if not(proj.active) { continue i + 1 }
    proj.x += proj.dx * proj.speed * dt
    proj.y += proj.dy * proj.speed * dt
    proj.z += proj.dz * proj.speed * dt
    // Apply gravity for gravity-affected projectiles
    if proj.gravity_affected {
      proj.dy -= @types.bomb_gravity * dt / proj.speed
    }
    // Rocket trail particles
    if proj.kind == @types.proj_rocket {
      if game.frame_counter % 2 == 0 {
        @types.spawn_rocket_trail(game, proj.x, proj.y, proj.z)
      }
    }
    proj.life -= dt
    if proj.life <= 0.0 {
      proj.active = false
      continue i + 1
    }
    // Check terrain collision
    let ground = @types.terrain_height_at(proj.x, proj.z)
    if proj.y < ground {
      proj.active = false
      // Bomb explosion effect
      if proj.kind == @types.proj_bomb {
        @types.spawn_large_explosion(game, proj.x, ground, proj.z)
        // Area damage to buildings and enemies
        bomb_area_damage(game, proj.x, ground, proj.z, proj.blast_radius, proj.damage)
      } else {
        @types.spawn_particles(
          game, proj.x, proj.y, proj.z, 3, 200, 180, 100,
        )
      }
      continue i + 1
    }
    if proj.is_enemy {
      // Check hit player
      if player.alive {
        let dist = @types.distance3d(
          proj.x, proj.y, proj.z, player.x, player.y, player.z,
        )
        if dist < @types.aircraft_size + 1.0 {
          proj.active = false
          damage_player(game, proj.damage)
          @types.spawn_particles(
            game, proj.x, proj.y, proj.z, 5, 255, 100, 50,
          )
        }
      }
    } else {
      // Check hit enemies
      for j = 0; j < game.enemies.length(); j = j + 1 {
        let e = game.enemies[j]
        if not(e.active) { continue j + 1 }
        let dist = @types.distance3d(
          proj.x, proj.y, proj.z, e.x, e.y, e.z,
        )
        if dist < e.size + 1.0 {
          proj.active = false
          e.hp -= proj.damage
          e.flash_timer = 0.15
          // Trigger evasion on hit
          if e.kind == @types.enemy_type_air {
            e.evade_timer = @types.ai_evade_duration
          }
          player.shots_hit += 1
          @types.spawn_particles(
            game, e.x, e.y, e.z, 5, 255, 150, 50,
          )
          if e.hp <= 0.0 {
            e.active = false
            game.kills += 1
            let kill_score : Int = if e.kind == @types.enemy_type_air {
              @types.score_air_kill
            } else {
              @types.score_ground_kill
            }
            game.score += kill_score
            game.mission_score += kill_score
            @types.spawn_explosion(game, e.x, e.y, e.z)
            // Update mission target
            let mission = game.missions[game.current_mission]
            if mission.kind == @types.mission_destroy || mission.kind == @types.mission_dogfight || mission.kind == @types.mission_intercept || mission.kind == @types.mission_defense || mission.kind == @types.mission_boss {
              mission.targets_done += 1
              @types.show_message(
                game,
                "Target destroyed! \{mission.targets_done}/\{mission.target_count}",
                2.0,
              )
            }
          }
          break
        }
      }
    }
  }
}

fn bomb_area_damage(
  game : @types.Game,
  x : Float,
  y : Float,
  z : Float,
  radius : Float,
  damage : Float
) -> Unit {
  // Damage enemies in blast radius
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let e = game.enemies[i]
    if not(e.active) { continue i + 1 }
    let dist = @types.distance3d(x, y, z, e.x, e.y, e.z)
    if dist < radius {
      let dmg_ratio : Float = 1.0 - dist / radius
      let final_dmg = damage * dmg_ratio
      e.hp -= final_dmg
      e.flash_timer = 0.2
      if e.hp <= 0.0 {
        e.active = false
        game.kills += 1
        game.score += @types.score_ground_kill
        game.mission_score += @types.score_ground_kill
        @types.spawn_explosion(game, e.x, e.y, e.z)
        let mission = game.missions[game.current_mission]
        if mission.kind == @types.mission_destroy || mission.kind == @types.mission_bombing_run || mission.kind == @types.mission_attack_base || mission.kind == @types.mission_boss {
          mission.targets_done += 1
        }
      }
    }
  }
  // Damage buildings in blast radius
  for i = 0; i < game.buildings.length(); i = i + 1 {
    let b = game.buildings[i]
    if not(b.active) { continue i + 1 }
    if not(b.destructible) { continue i + 1 }
    let dist = @types.distance3d(x, y, z, b.x, b.y + b.height / 2.0, b.z)
    if dist < radius + 3.0 {
      let dmg_ratio : Float = 1.0 - dist / (radius + 3.0)
      let final_dmg = damage * dmg_ratio
      b.hp -= final_dmg
      b.flash_timer = 0.2
      if b.hp <= 0.0 {
        b.active = false
        game.buildings_destroyed += 1
        game.score += @types.score_building_destroy
        game.mission_score += @types.score_building_destroy
        @types.spawn_large_explosion(game, b.x, b.y + b.height / 2.0, b.z)
        let mission = game.missions[game.current_mission]
        if mission.kind == @types.mission_bombing_run || mission.kind == @types.mission_attack_base || mission.kind == @types.mission_boss {
          mission.targets_done += 1
        }
      }
    }
  }
  // Damage turrets in blast radius
  for i = 0; i < game.turrets.length(); i = i + 1 {
    let t = game.turrets[i]
    if not(t.active) { continue i + 1 }
    let dist = @types.distance3d(x, y, z, t.x, t.y, t.z)
    if dist < radius {
      let dmg_ratio : Float = 1.0 - dist / radius
      let final_dmg = damage * dmg_ratio
      t.hp -= final_dmg
      if t.hp <= 0.0 {
        t.active = false
        game.kills += 1
        game.score += @types.score_turret_kill
        game.mission_score += @types.score_turret_kill
        @types.spawn_explosion(game, t.x, t.y, t.z)
      }
    }
  }
}
