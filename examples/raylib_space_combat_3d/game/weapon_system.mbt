// Projectile update and collision

///|
pub fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    let proj = game.projectiles[i]
    if not(proj.active) {
      continue i + 1
    }

    // Lifetime
    proj.life -= dt
    if proj.life <= 0.0 {
      proj.active = false
      continue i + 1
    }

    // Missile homing logic
    if proj.kind == @types.weapon_missile &&
      proj.from_player &&
      proj.target_idx >= 0 {
      if proj.fuel > 0.0 {
        proj.fuel -= dt
        if proj.target_idx < game.enemies.length() &&
          game.enemies[proj.target_idx].active {
          let target = game.enemies[proj.target_idx]
          let dx = target.x - proj.x
          let dy = target.y - proj.y
          let dz = target.z - proj.z
          let dist_to_target = @types.length3d(dx, dy, dz)

          // Proximity detonation
          if dist_to_target < @types.missile_prox_radius {
            missile_detonate(game, i)
            continue i + 1
          }

          let norm = @types.normalize3d(dx, dy, dz)
          let spd = @types.length3d(proj.vx, proj.vy, proj.vz)
          let cur_norm = @types.normalize3d(proj.vx, proj.vy, proj.vz)
          let turn = @types.missile_turn_rate * dt
          let nx = @types.lerpf(cur_norm.0, norm.0, turn)
          let ny = @types.lerpf(cur_norm.1, norm.1, turn)
          let nz = @types.lerpf(cur_norm.2, norm.2, turn)
          let new_norm = @types.normalize3d(nx, ny, nz)
          // Accelerate missile slightly over time
          let accel_spd = @types.minf(
            spd + 10.0 * dt,
            @types.missile_speed * 1.5,
          )
          proj.vx = new_norm.0 * accel_spd
          proj.vy = new_norm.1 * accel_spd
          proj.vz = new_norm.2 * accel_spd
        }
      }
    }

    // Move
    proj.x += proj.vx * dt
    proj.y += proj.vy * dt
    proj.z += proj.vz * dt

    // Trail particles
    if proj.kind == @types.weapon_missile && game.frame_counter % 2 == 0 {
      @types.spawn_particles(game, proj.x, proj.y, proj.z, 1, 255, 200, 100)
    }
    if proj.kind == @types.weapon_plasma && game.frame_counter % 2 == 0 {
      @types.spawn_particles(game, proj.x, proj.y, proj.z, 1, 100, 255, 100)
    }
    if proj.kind == @types.weapon_railgun && game.frame_counter % 1 == 0 {
      // Railgun leaves a fading trail
      let idx2 = @types.alloc_particle(game)
      if idx2 >= 0 {
        let p = game.particles[idx2]
        p.active = true
        p.x = proj.x
        p.y = proj.y
        p.z = proj.z
        p.vx = 0.0
        p.vy = 0.0
        p.vz = 0.0
        p.life = 0.2
        p.max_life = 0.2
        p.r = 150
        p.g = 200
        p.b = 255
        p.size = 0.03
        p.kind = 3
      }
    }

    // Collision detection
    if proj.from_player {
      let mut hit_something = false

      // Check against enemies
      for j = 0; j < game.enemies.length(); j = j + 1 {
        let e = game.enemies[j]
        if not(e.active) {
          continue j + 1
        }
        let dist = @types.distance3d(proj.x, proj.y, proj.z, e.x, e.y, e.z)
        let hit_radius : Float = e.size * 0.8
        if dist < hit_radius {
          // Apply damage
          damage_enemy(game, j, proj.damage)
          game.player.shots_hit += 1

          // Hit sparks by weapon type
          let spark_r : Int = if proj.kind == @types.weapon_laser {
            255
          } else if proj.kind == @types.weapon_missile {
            255
          } else if proj.kind == @types.weapon_plasma {
            100
          } else {
            150
          }
          let spark_g : Int = if proj.kind == @types.weapon_laser {
            50
          } else if proj.kind == @types.weapon_missile {
            180
          } else if proj.kind == @types.weapon_plasma {
            255
          } else {
            200
          }
          let spark_b : Int = if proj.kind == @types.weapon_laser {
            50
          } else if proj.kind == @types.weapon_missile {
            50
          } else if proj.kind == @types.weapon_plasma {
            100
          } else {
            255
          }
          @types.spawn_particles(
            game,
            proj.x,
            proj.y,
            proj.z,
            5,
            spark_r,
            spark_g,
            spark_b,
          )

          if not(proj.piercing) {
            proj.active = false
            hit_something = true
            break
          }
          // Piercing rounds continue but lose damage
          proj.damage = proj.damage * 0.7
        }
      }

      // Check against asteroids
      if proj.active && not(hit_something) {
        for j = 0; j < game.asteroids.length(); j = j + 1 {
          let a = game.asteroids[j]
          if not(a.active) {
            continue j + 1
          }
          let dist = @types.distance3d(proj.x, proj.y, proj.z, a.x, a.y, a.z)
          if dist < a.size {
            damage_asteroid(game, j, proj.damage)
            @types.spawn_particles(
              game,
              proj.x,
              proj.y,
              proj.z,
              4,
              150,
              130,
              100,
            )
            if not(proj.piercing) {
              proj.active = false
              break
            }
            proj.damage = proj.damage * 0.5
          }
        }
      }

      // Check against enemy stations
      if proj.active {
        for j = 0; j < game.stations.length(); j = j + 1 {
          let s = game.stations[j]
          if not(s.active) {
            continue j + 1
          }
          if s.kind != @types.station_enemy {
            continue j + 1
          }
          let dist = @types.distance3d(proj.x, proj.y, proj.z, s.x, s.y, s.z)
          if dist < 8.0 {
            s.hp -= proj.damage
            @types.spawn_particles(
              game,
              proj.x,
              proj.y,
              proj.z,
              5,
              200,
              100,
              50,
            )
            if not(proj.piercing) {
              proj.active = false
              break
            }
          }
        }
      }
    } else {
      // Enemy projectile: check against player
      let dist = @types.distance3d(
        proj.x,
        proj.y,
        proj.z,
        game.player.x,
        game.player.y,
        game.player.z,
      )
      if dist < 2.0 {
        damage_player(game, proj.damage)
        proj.active = false
        @types.spawn_particles(game, proj.x, proj.y, proj.z, 4, 255, 100, 100)
      }

      // Enemy projectiles also hit friendly stations
      if proj.active {
        for j = 0; j < game.stations.length(); j = j + 1 {
          let s = game.stations[j]
          if not(s.active) {
            continue j + 1
          }
          if s.kind != @types.station_friendly {
            continue j + 1
          }
          let sdist = @types.distance3d(proj.x, proj.y, proj.z, s.x, s.y, s.z)
          if sdist < 8.0 {
            s.hp -= proj.damage
            @types.spawn_particles(
              game,
              proj.x,
              proj.y,
              proj.z,
              3,
              200,
              150,
              50,
            )
            proj.active = false
            break
          }
        }
      }
    }
  }
}

///|
fn missile_detonate(game : @types.Game, proj_idx : Int) -> Unit {
  let proj = game.projectiles[proj_idx]
  proj.active = false

  // Explosion at detonation point
  @types.spawn_explosion(game, proj.x, proj.y, proj.z, 15, 255, 180, 50)
  game.camera_shake = @types.maxf(game.camera_shake, 0.4)

  // Area damage to nearby enemies
  for j = 0; j < game.enemies.length(); j = j + 1 {
    let e = game.enemies[j]
    if not(e.active) {
      continue j + 1
    }
    let dist = @types.distance3d(proj.x, proj.y, proj.z, e.x, e.y, e.z)
    if dist < @types.missile_prox_radius * 2.0 {
      // Damage falls off with distance
      let falloff : Float = 1.0 - dist / (@types.missile_prox_radius * 2.0)
      let aoe_damage : Float = proj.damage * falloff
      damage_enemy(game, j, aoe_damage)
      game.player.shots_hit += 1
    }
  }

  // Also damage nearby asteroids
  for j = 0; j < game.asteroids.length(); j = j + 1 {
    let a = game.asteroids[j]
    if not(a.active) {
      continue j + 1
    }
    let dist = @types.distance3d(proj.x, proj.y, proj.z, a.x, a.y, a.z)
    if dist < @types.missile_prox_radius * 2.0 {
      let falloff : Float = 1.0 - dist / (@types.missile_prox_radius * 2.0)
      let aoe_damage : Float = proj.damage * falloff
      damage_asteroid(game, j, aoe_damage)
    }
  }
}

///|
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

    // Different behavior by particle kind
    if p.kind == 0 {
      // Standard particles: dampen and shrink
      p.vx *= 0.96
      p.vy *= 0.96
      p.vz *= 0.96
      p.size *= 0.98
    } else if p.kind == 1 {
      // Explosion particles: grow slightly then shrink
      let life_pct = p.life / p.max_life
      if life_pct > 0.7 {
        p.size *= 1.02
      } else {
        p.size *= 0.97
      }
      p.vx *= 0.94
      p.vy *= 0.94
      p.vz *= 0.94
    } else if p.kind == 2 {
      // Shield hit: expand quickly
      p.size *= 1.05
      p.vx *= 0.9
      p.vy *= 0.9
      p.vz *= 0.9
    } else {
      // Trail: static, just fade
      p.size *= 0.95
    }
  }
}
