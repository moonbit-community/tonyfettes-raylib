// Weapon firing, projectile updates, and collision

///|
fn update_weapon_cooldowns(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.weapons.length() {
    if game.weapons[i].reload_timer > 0.0 {
      game.weapons[i].reload_timer -= dt
    }
    // Handle reloading
    if game.weapons[i].reloading {
      game.weapons[i].reload_time -= dt
      if game.weapons[i].reload_time <= 0.0 {
        game.weapons[i].reloading = false
        // Refill magazine from reserve
        let mag_max = @types.effective_mag_size(game.player, i)
        let current_mag = game.player.magazine[i]
        let needed = mag_max - current_mag
        if i == @types.weapon_pistol {
          // Pistol has infinite ammo
          game.player.magazine[i] = mag_max
        } else {
          let available = @types.clampi(game.player.ammo[i], 0, needed)
          game.player.magazine[i] += available
          game.player.ammo[i] -= available
        }
        game.player.mag_size[i] = mag_max
      }
    }
  }
}

///|
fn try_reload(game : @types.Game, weapon : Int) -> Unit {
  let ws = game.weapons[weapon]
  if ws.reloading {
    return
  }
  let mag_max = @types.effective_mag_size(game.player, weapon)
  if game.player.magazine[weapon] >= mag_max {
    return
  }
  if weapon != @types.weapon_pistol && game.player.ammo[weapon] <= 0 {
    return
  }
  ws.reloading = true
  ws.reload_time = @types.weapon_reload_time(weapon)
}

///|
fn handle_shooting(game : @types.Game) -> Unit {
  let weapon = game.player.current_weapon
  let ws = game.weapons[weapon]
  // Don't shoot while reloading
  if ws.reloading {
    return
  }
  // Manual reload with R
  if @raylib.is_key_pressed(@raylib.KeyR) {
    try_reload(game, weapon)
    return
  }
  // Minigun spin-up handling
  if weapon == @types.weapon_minigun {
    if @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) {
      game.player.minigun_spinning = true
      game.player.minigun_spin = @types.minf(
        game.player.minigun_spin + @raylib.get_frame_time() * 2.0,
        1.0,
      )
    } else {
      game.player.minigun_spinning = false
    }
  }
  // Check fire button (left mouse)
  let can_fire = if weapon == @types.weapon_rifle {
    @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
  } else if weapon == @types.weapon_minigun {
    @raylib.is_mouse_button_down(@raylib.MouseButtonLeft) &&
    game.player.minigun_spin >= @types.minigun_spinup_time
  } else {
    @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
  }
  // Check magazine
  if game.player.magazine[weapon] <= 0 {
    if can_fire {
      // Auto-reload on empty
      try_reload(game, weapon)
    }
    return
  }
  let eff_rate = @types.effective_fire_rate(game.player, weapon)
  if can_fire && ws.reload_timer <= 0.0 {
    fire_weapon(game, weapon)
    ws.reload_timer = eff_rate
    game.player.magazine[weapon] -= 1
    game.total_shots_fired += 1
    game.player.flash_timer = 0.08
    // Recoil
    let recoil_amount : Float = if weapon == @types.weapon_sniper {
      1.5
    } else if weapon == @types.weapon_shotgun {
      1.0
    } else if weapon == @types.weapon_rocket {
      0.8
    } else if weapon == @types.weapon_minigun {
      0.15
    } else if weapon == @types.weapon_rifle {
      0.25
    } else {
      0.4
    }
    game.player.recoil_offset += recoil_amount
    game.player.recoil_offset = @types.minf(game.player.recoil_offset, 3.0)
    // Auto-reload when magazine empty
    if game.player.magazine[weapon] <= 0 {
      try_reload(game, weapon)
    }
  }
}

///|
fn fire_weapon(game : @types.Game, weapon : Int) -> Unit {
  let player = game.player
  // Calculate look direction
  let cos_yaw = @math.cosf(player.yaw)
  let sin_yaw = @math.sinf(player.yaw)
  let cos_pitch = @math.cosf(player.pitch)
  let sin_pitch = @math.sinf(player.pitch)
  let look_x = sin_yaw * cos_pitch
  let look_y = sin_pitch
  let look_z = cos_yaw * cos_pitch
  // Right vector for shell casing
  let right_x = cos_yaw
  let right_z = -sin_yaw
  if weapon == @types.weapon_shotgun {
    // Fire multiple pellets with spread
    for i in 0..<@types.shotgun_pellets {
      let spread_h = @types.rand_rangef(
        game,
        -@types.shotgun_spread,
        @types.shotgun_spread,
      )
      let spread_v = @types.rand_rangef(
        game,
        -@types.shotgun_spread,
        @types.shotgun_spread,
      )
      let dx = look_x + spread_h
      let dy = look_y + spread_v
      let dz = look_z + spread_h * 0.5
      let norm = @types.normalize3d(dx, dy, dz)
      fire_projectile(game, norm.0, norm.1, norm.2, weapon)
      ignore(i)
    }
    // Muzzle flash particles
    @types.spawn_particles_dir(
      game,
      player.x + look_x * 0.5,
      @types.player_height + look_y * 0.5,
      player.z + look_z * 0.5,
      look_x,
      look_y,
      look_z,
      6,
      255,
      200,
      50,
    )
    // Shell casing
    @types.spawn_shell_casing(
      game,
      player.x,
      @types.player_height - 0.2,
      player.z,
      right_x,
      right_z,
    )
  } else if weapon == @types.weapon_sniper {
    // Sniper: high accuracy, penetrating
    fire_projectile(game, look_x, look_y, look_z, weapon)
    // Big muzzle flash
    @types.spawn_particles_dir(
      game,
      player.x + look_x * 0.6,
      @types.player_height + look_y * 0.6,
      player.z + look_z * 0.6,
      look_x,
      look_y,
      look_z,
      8,
      255,
      255,
      200,
    )
    @types.spawn_shell_casing(
      game,
      player.x,
      @types.player_height - 0.2,
      player.z,
      right_x,
      right_z,
    )
  } else if weapon == @types.weapon_minigun {
    // Minigun: spread increases when sustained firing
    let spin_ratio = game.player.minigun_spin
    let spread = @types.lerpf(
      @types.minigun_min_spread, @types.minigun_max_spread, spin_ratio,
    )
    let dx = look_x + @types.rand_rangef(game, -spread, spread)
    let dy = look_y + @types.rand_rangef(game, -spread, spread)
    let dz = look_z + @types.rand_rangef(game, -spread, spread)
    let norm = @types.normalize3d(dx, dy, dz)
    fire_projectile(game, norm.0, norm.1, norm.2, weapon)
    // Small muzzle flash
    if game.frame_counter % 3 == 0 {
      @types.spawn_particles_dir(
        game,
        player.x + look_x * 0.5,
        @types.player_height + look_y * 0.5,
        player.z + look_z * 0.5,
        look_x,
        look_y,
        look_z,
        2,
        255,
        220,
        80,
      )
      @types.spawn_shell_casing(
        game,
        player.x,
        @types.player_height - 0.2,
        player.z,
        right_x,
        right_z,
      )
    }
  } else {
    // Single projectile with minor spread for rifle
    let mut dx = look_x
    let mut dy = look_y
    let mut dz = look_z
    if weapon == @types.weapon_rifle {
      dx += @types.rand_rangef(game, -0.02, 0.02)
      dy += @types.rand_rangef(game, -0.02, 0.02)
      dz += @types.rand_rangef(game, -0.02, 0.02)
      let norm = @types.normalize3d(dx, dy, dz)
      dx = norm.0
      dy = norm.1
      dz = norm.2
    }
    fire_projectile(game, dx, dy, dz, weapon)
    // Muzzle flash particles
    @types.spawn_particles_dir(
      game,
      player.x + look_x * 0.5,
      @types.player_height + look_y * 0.5,
      player.z + look_z * 0.5,
      look_x,
      look_y,
      look_z,
      3,
      255,
      220,
      80,
    )
    // Shell casing
    @types.spawn_shell_casing(
      game,
      player.x,
      @types.player_height - 0.2,
      player.z,
      right_x,
      right_z,
    )
  }
}

///|
fn fire_projectile(
  game : @types.Game,
  dx : Float,
  dy : Float,
  dz : Float,
  weapon : Int,
) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let player = game.player
  let proj = game.projectiles[idx]
  // Calculate look direction for spawn offset
  let cos_yaw = @math.cosf(player.yaw)
  let sin_yaw = @math.sinf(player.yaw)
  proj.active = true
  proj.kind = weapon
  // Spawn slightly in front and to the right of player
  proj.x = player.x + sin_yaw * 0.3 + cos_yaw * 0.2
  proj.y = @types.player_height - 0.15
  proj.z = player.z + cos_yaw * 0.3 - sin_yaw * 0.2
  proj.dx = dx
  proj.dy = dy
  proj.dz = dz
  proj.speed = @types.weapon_proj_speed(weapon)
  proj.damage = @types.effective_damage(player, weapon)
  proj.life = if weapon == @types.weapon_rocket {
    4.0
  } else if weapon == @types.weapon_sniper {
    3.0
  } else {
    2.0
  }
  proj.is_enemy = false
  proj.splash_radius = if weapon == @types.weapon_rocket {
    @types.rocket_splash_radius
  } else {
    0.0
  }
  proj.penetration = if weapon == @types.weapon_sniper {
    @types.sniper_penetration
  } else {
    0
  }
  proj.is_headshot_capable = weapon == @types.weapon_sniper ||
    weapon == @types.weapon_pistol ||
    weapon == @types.weapon_rifle
}

///|
fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  for proj in game.projectiles {
    if not(proj.active) {
      continue
    }
    // Move projectile
    proj.x += proj.dx * proj.speed * dt
    proj.y += proj.dy * proj.speed * dt
    proj.z += proj.dz * proj.speed * dt
    // Rocket has slight gravity
    if proj.kind == @types.weapon_rocket && not(proj.is_enemy) {
      proj.dy -= 1.5 * dt
    }
    // Lifetime
    proj.life -= dt
    if proj.life <= 0.0 {
      proj.active = false
      continue
    }
    // Floor/ceiling collision
    if proj.y < 0.0 || proj.y > 10.0 {
      if proj.splash_radius > 0.0 {
        apply_explosion(
          game,
          proj.x,
          proj.y,
          proj.z,
          proj.splash_radius,
          proj.damage,
        )
      }
      proj.active = false
      continue
    }
    // Arena wall collision
    if not(@types.in_arena(proj.x, proj.z)) {
      if proj.splash_radius > 0.0 {
        apply_explosion(
          game,
          proj.x,
          proj.y,
          proj.z,
          proj.splash_radius,
          proj.damage,
        )
      }
      proj.active = false
      continue
    }
    // Pillar collision
    let mut hit_pillar = false
    for pillar in game.pillars {
      let pdist = @types.distance2d(proj.x, proj.z, pillar.x, pillar.z)
      if pdist < pillar.radius + 0.2 && proj.y < pillar.height {
        hit_pillar = true
        break
      }
    }
    if hit_pillar {
      if proj.splash_radius > 0.0 {
        apply_explosion(
          game,
          proj.x,
          proj.y,
          proj.z,
          proj.splash_radius,
          proj.damage,
        )
      }
      @types.spawn_particles_typed(
        game,
        proj.x,
        proj.y,
        proj.z,
        3,
        200,
        200,
        200,
        @types.particle_spark,
      )
      proj.active = false
      continue
    }
    // Barricade collision (enemy projectiles can hit barricades)
    if proj.is_enemy {
      let mut hit_barricade = false
      for barr in game.barricades {
        if not(barr.active) {
          continue
        }
        let bdist = @types.distance2d(proj.x, proj.z, barr.x, barr.z)
        if bdist < @types.barricade_size * 0.5 + 0.3 && proj.y < 2.0 {
          barr.hp -= proj.damage
          if barr.hp <= 0.0 {
            barr.active = false
            @types.spawn_particles(game, barr.x, 1.0, barr.z, 10, 120, 100, 60)
          }
          hit_barricade = true
          break
        }
      }
      if hit_barricade {
        proj.active = false
        continue
      }
    }
    if proj.is_enemy {
      // Enemy projectile: check against player
      let pdist = @types.distance3d(
        proj.x,
        proj.y,
        proj.z,
        game.player.x,
        @types.player_height * 0.5,
        game.player.z,
      )
      if pdist < @types.player_radius + 0.3 {
        damage_player_from(game, proj.damage, proj.x, proj.z)
        proj.active = false
        continue
      }
    } else {
      // Player projectile: check against enemies
      let mut hit = false
      for j in 0..<game.enemies.length() {
        let enemy = game.enemies[j]
        if not(enemy.active) {
          continue
        }
        let edist = @types.distance3d(
          proj.x,
          proj.y,
          proj.z,
          enemy.x,
          enemy.y,
          enemy.z,
        )
        let hit_radius = enemy.size * 0.6
        if edist < hit_radius {
          game.total_shots_hit += 1
          if proj.splash_radius > 0.0 {
            // Rocket: splash damage
            apply_explosion(
              game,
              proj.x,
              proj.y,
              proj.z,
              proj.splash_radius,
              proj.damage,
            )
            hit = true
            proj.active = false
            break
          } else {
            // Check headshot
            let is_headshot = proj.is_headshot_capable &&
              @types.is_headshot_hit(proj.y, enemy.y, enemy.size)
            // Check if shielded
            if enemy.kind == @types.enemy_shielded {
              damage_shielded_enemy(game, j, proj.damage, proj.dx, proj.dz)
            } else if is_headshot {
              damage_enemy_headshot(game, j, proj.damage)
            } else {
              damage_enemy(game, j, proj.damage)
            }
            // Penetration
            if proj.penetration > 0 {
              proj.penetration -= 1
              proj.damage = proj.damage * 0.7
              // Don't deactivate, continue through
            } else {
              hit = true
              proj.active = false
              break
            }
          }
        }
      }
      if hit {
        continue
      }
    }
  }
}

///|
fn apply_explosion(
  game : @types.Game,
  x : Float,
  y : Float,
  z : Float,
  radius : Float,
  damage : Float,
) -> Unit {
  // Damage all enemies in radius
  for i in 0..<game.enemies.length() {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue
    }
    let dist = @types.distance3d(x, y, z, enemy.x, enemy.y, enemy.z)
    if dist < radius {
      let dmg_factor : Float = 1.0 - dist / radius
      let dmg = damage * dmg_factor
      damage_enemy(game, i, dmg)
      // Knockback
      let dx = enemy.x - x
      let dz = enemy.z - z
      let knockback_dist = (dx * dx + dz * dz).sqrt()
      if knockback_dist > 0.01 {
        let knockback_strength : Float = 5.0 * dmg_factor
        enemy.x += dx / knockback_dist * knockback_strength
        enemy.z += dz / knockback_dist * knockback_strength
      }
      // Stun brutes and below
      if enemy.kind != @types.enemy_boss {
        enemy.stun_timer = 0.3 * dmg_factor
      }
    }
  }
  // Damage player if close
  let player_dist = @types.distance3d(
    x,
    y,
    z,
    game.player.x,
    @types.player_height * 0.5,
    game.player.z,
  )
  if player_dist < radius * 0.5 {
    let self_dmg = damage * 0.3 * (1.0 - player_dist / (radius * 0.5))
    damage_player(game, self_dmg)
  }
  // Damage barricades
  for barr in game.barricades {
    if not(barr.active) {
      continue
    }
    let bdist = @types.distance2d(x, z, barr.x, barr.z)
    if bdist < radius {
      let bfactor : Float = 1.0 - bdist / radius
      barr.hp -= damage * bfactor * 0.5
      if barr.hp <= 0.0 {
        barr.active = false
        @types.spawn_particles(game, barr.x, 1.0, barr.z, 10, 120, 100, 60)
      }
    }
  }
  // Explosion particles
  @types.spawn_particles_typed(
    game, x, y, z, 20, 255, 150, 30, @types.particle_explosion,
  )
  @types.spawn_particles_typed(
    game, x, y, z, 10, 255, 80, 20, @types.particle_explosion,
  )
}
