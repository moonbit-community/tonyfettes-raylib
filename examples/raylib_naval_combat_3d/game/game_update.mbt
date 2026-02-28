// Main game update dispatcher

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_particles(game, dt)
  if game.state == @types.state_menu {
    update_menu(game, dt)
  } else if game.state == @types.state_battle_select {
    update_battle_select(game, dt)
  } else if game.state == @types.state_playing {
    update_playing(game, dt)
  } else if game.state == @types.state_paused {
    update_paused(game)
  } else if game.state == @types.state_battle_complete {
    update_battle_complete(game)
  } else if game.state == @types.state_game_over {
    update_game_over(game)
  }
}

///|
fn update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  // Up/Down to navigate menu
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor > 1 {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      // Quick battle - start battle 0
      start_battle(game, 0)
      game.state = @types.state_playing
    } else {
      // Battle select
      game.state = @types.state_battle_select
      game.battle_select_cursor = 0
    }
  }
}

///|
fn update_battle_select(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  // Navigate battle list
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.battle_select_cursor -= 1
    if game.battle_select_cursor < 0 {
      game.battle_select_cursor = game.total_battles - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.battle_select_cursor += 1
    if game.battle_select_cursor >= game.total_battles {
      game.battle_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_battle(game, game.battle_select_cursor)
    game.current_battle = game.battle_select_cursor
    game.state = @types.state_playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_menu
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.state_paused
    return
  }
  // Update timers
  game.battle_timer += dt
  game.wave_time += dt
  game.battle_stats.time_elapsed += dt
  // Update wind system
  update_wind(game, dt)
  // Update systems
  update_player(game, dt)
  update_enemies(game, dt)
  update_cannonballs(game, dt)
  update_fleet_ships(game, dt)
  update_convoy(game, dt)
  update_fortress_combat(game, dt)
  update_wakes(game, dt)
  update_debris(game, dt)
  update_messages(game, dt)
  update_message(game, dt)
  update_ship_effects(game, dt)
  // Wake spawning
  game.wake_spawn_timer -= dt
  if game.wake_spawn_timer <= 0.0 {
    game.wake_spawn_timer = 0.15
    // Player wake
    if game.player.speed > @types.wake_min_speed {
      let sin_h = @math.sinf(game.player.heading)
      let cos_h = @math.cosf(game.player.heading)
      let wake_x = game.player.x - sin_h * game.player.ship_length * 0.4
      let wake_z = game.player.z - cos_h * game.player.ship_length * 0.4
      @types.spawn_wake(
        game,
        wake_x,
        wake_z,
        game.player.heading,
        game.player.speed,
      )
    }
    // Enemy wakes
    for e in game.enemies {
      if not(e.active) {
        continue
      }
      if e.speed > @types.wake_min_speed {
        let sin_h = @math.sinf(e.heading)
        let cos_h = @math.cosf(e.heading)
        let wx = e.x - sin_h * e.ship_length * 0.4
        let wz = e.z - cos_h * e.ship_length * 0.4
        @types.spawn_wake(game, wx, wz, e.heading, e.speed)
      }
    }
  }
  // Check battle objectives
  check_objectives(game)
  // Check game over
  if game.player.hull_hp <= 0.0 {
    game.player.hull_hp = 0.0
    game.state = @types.state_game_over
  }
}

///|
fn update_wind(game : @types.Game, dt : Float) -> Unit {
  let wind = game.wind
  // Shift timer - periodically change wind direction
  wind.shift_timer -= dt
  if wind.shift_timer <= 0.0 {
    wind.shift_timer = wind.shift_interval
    // New target direction (slight shift)
    wind.target_direction = @types.normalize_angle(
      wind.direction + @types.rand_rangef(game, -0.8, 0.8),
    )
    // Possibly change speed
    let speed_change = @types.rand_rangef(game, -0.3, 0.3)
    wind.target_speed = @types.clampf(
      wind.speed + speed_change,
      @types.wind_speed_calm,
      @types.wind_speed_gale,
    )
  }
  // Lerp towards target direction/speed
  let dir_diff = @types.angle_diff(wind.direction, wind.target_direction)
  wind.direction = @types.normalize_angle(
    wind.direction + dir_diff * @types.wind_shift_speed,
  )
  wind.speed = @types.lerpf(wind.speed, wind.target_speed, dt * 0.5)
  // Gust system
  wind.gust_timer -= dt
  if wind.gust_timer <= 0.0 {
    if wind.gust_active {
      wind.gust_active = false
      wind.gust_timer = @types.wind_gust_frequency +
        @types.rand_rangef(game, -2.0, 2.0)
    } else {
      wind.gust_active = true
      wind.gust_strength = @types.rand_rangef(
        game,
        @types.wind_gust_strength * 0.5,
        @types.wind_gust_strength * 1.5,
      )
      wind.gust_timer = @types.wind_gust_duration
    }
  }
  // Turbulence noise
  let turb = @math.sinf(Float::from_int(game.frame_counter) * 0.07) * 0.05
  wind.turbulence = turb
  // Sync to game-level wind vars
  let effective_speed : Float = if wind.gust_active {
    wind.speed + wind.gust_strength
  } else {
    wind.speed
  }
  game.wind_angle = wind.direction + wind.turbulence
  game.wind_speed = effective_speed
}

///|
fn update_paused(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.state_playing
  }
}

///|
fn update_battle_complete(game : @types.Game) -> Unit {
  if game.current_battle >= game.total_battles - 1 {
    // All battles done - victory
    if @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeySpace) {
      reset_game(game)
      game.state = @types.state_menu
    }
  } else if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    // Repair player ship partially between battles
    game.player.hull_hp = @types.minf(
      game.player.hull_hp + 30.0,
      game.player.max_hp,
    )
    game.player.sail_hp = @types.minf(
      game.player.sail_hp + 20.0,
      game.player.max_hp,
    )
    game.player.rudder_hp = @types.minf(
      game.player.rudder_hp + 20.0,
      game.player.max_hp,
    )
    game.player.mast_hp = @types.minf(
      game.player.mast_hp + 25.0,
      @types.get_class_max_mast(game.player.ship_class),
    )
    game.player.cannon_deck_hp = @types.minf(
      game.player.cannon_deck_hp + 15.0,
      game.player.max_hp,
    )
    // Replenish some ammo
    game.player.ammo_round = @types.mini(
      game.player.ammo_round + 15,
      @types.player_start_ammo,
    )
    game.player.ammo_chain = @types.mini(game.player.ammo_chain + 8, 20)
    game.player.ammo_grape = @types.mini(game.player.ammo_grape + 5, 15)
    // Recover some crew
    let crew_recover = @types.maxi(
      (game.player.max_crew - game.player.crew) / 4,
      2,
    )
    game.player.crew = @types.mini(
      game.player.crew + crew_recover,
      game.player.max_crew,
    )
    game.current_battle += 1
    start_battle(game, game.current_battle)
    game.state = @types.state_playing
  }
}

///|
fn update_game_over(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    reset_game(game)
    game.state = @types.state_menu
  }
}

///|
fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for p in game.particles {
    if not(p.active) {
      continue
    }
    p.life -= dt
    if p.life <= 0.0 {
      p.active = false
      continue
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.z += p.vz * dt
    // Particle type behaviors
    if p.particle_type == @types.particle_smoke {
      p.vy -= 1.0 * dt
      p.vx *= 0.95
      p.vz *= 0.95
      p.size += dt * 0.1
    } else if p.particle_type == @types.particle_fire {
      p.vy -= 2.0 * dt
      p.vx *= 0.93
      p.vz *= 0.93
      // Color shift to darker as it fades
      let ratio = p.life / p.max_life
      let g_f : Float = Float::from_int(p.g) * ratio
      p.g = g_f.to_int()
    } else if p.particle_type == @types.particle_splash {
      p.vy -= 10.0 * dt
      if p.y < 0.0 {
        p.active = false
      }
    } else {
      p.vy -= 8.0 * dt
      p.vx *= 0.97
      p.vz *= 0.97
    }
  }
}

///|
fn update_wakes(game : @types.Game, dt : Float) -> Unit {
  for w in game.wakes {
    if not(w.active) {
      continue
    }
    w.age += dt
    if w.age >= w.max_age {
      w.active = false
      continue
    }
    // Width expands as it ages
    let age_ratio = w.age / w.max_age
    w.width = (0.3 + w.speed_at_spawn * 0.15) * (1.0 + age_ratio * 2.0)
  }
}

///|
fn update_debris(game : @types.Game, dt : Float) -> Unit {
  for d in game.debris_pool {
    if not(d.active) {
      continue
    }
    d.life -= dt
    if d.life <= 0.0 {
      d.active = false
      continue
    }
    // Move with current/wind
    d.x += (d.vx + @math.sinf(game.wind_angle) * game.wind_speed * 0.1) * dt
    d.z += (d.vz + @math.cosf(game.wind_angle) * game.wind_speed * 0.1) * dt
    d.vx *= 0.99
    d.vz *= 0.99
    d.rotation += d.rot_speed * dt
    // Slowly sink
    if d.life < 3.0 {
      d.y -= @types.debris_sink_speed * dt
    }
    // Bob on water
    let bob = @types.water_height(d.x, d.z, game.wave_time) * 0.5
    if d.y > bob + 0.1 {
      d.y = bob + 0.1
    }
  }
}

///|
fn update_messages(game : @types.Game, dt : Float) -> Unit {
  for msg in game.messages {
    if not(msg.active) {
      continue
    }
    msg.timer -= dt
    if msg.timer <= 0.0 {
      msg.active = false
    }
  }
}

///|
fn update_message(game : @types.Game, dt : Float) -> Unit {
  if game.message_timer > 0.0 {
    game.message_timer -= dt
  }
}

///|
fn update_ship_effects(game : @types.Game, dt : Float) -> Unit {
  // Player ship bobbing
  game.player.bob_phase += dt * 2.0
  // Player roll from turning
  let turning : Float = if @raylib.is_key_down(@raylib.KeyA) {
    -1.0
  } else if @raylib.is_key_down(@raylib.KeyD) {
    1.0
  } else {
    0.0
  }
  let target_roll = turning * 0.15 * game.player.speed / @types.player_max_sail
  game.player.roll_angle = @types.lerpf(
    game.player.roll_angle,
    target_roll,
    dt * 3.0,
  )
  // Player taking water if hull damaged
  if game.player.hull_hp < game.player.max_hp * 0.3 {
    let leak_rate : Float = (
        1.0 - game.player.hull_hp / (game.player.max_hp * 0.3)
      ) *
      2.0
    game.player.taking_water += leak_rate * dt
    // Water damage
    if game.player.taking_water > 5.0 {
      game.player.hull_hp -= dt * 1.0
      game.player.taking_water = 5.0
    }
  }
  // Fire on player ship
  if game.player.on_fire {
    game.player.fire_timer -= dt
    if game.player.fire_timer <= 0.0 {
      game.player.on_fire = false
    } else {
      // Fire damages hull
      game.player.hull_hp -= dt * 2.0
      // Spawn fire particles
      if game.frame_counter % 5 == 0 {
        @types.spawn_fire(game, game.player.x, 1.5, game.player.z, 2)
      }
    }
  }
  // Enemy ship effects
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    e.bob_phase += dt * (1.8 + Float::from_int(i) * 0.1)
    // Enemy taking water
    if e.hull_hp < e.max_hp * 0.3 {
      let leak : Float = (1.0 - e.hull_hp / (e.max_hp * 0.3)) * 1.5
      e.taking_water += leak * dt
      if e.taking_water > 5.0 {
        e.hull_hp -= dt * 0.8
        e.taking_water = 5.0
      }
    }
    // Enemy fire
    if e.on_fire {
      e.fire_timer_decay -= dt
      if e.fire_timer_decay <= 0.0 {
        e.on_fire = false
      } else {
        e.hull_hp -= dt * 1.5
        if game.frame_counter % 8 == 0 {
          @types.spawn_fire(game, e.x, 1.0, e.z, 1)
        }
      }
    }
    // Check death from fire/water
    if e.hull_hp <= 0.0 {
      e.active = false
      game.score += e.score_value
      game.battle_stats.ships_sunk += 1
      game.player.kills += 1
      @types.spawn_particles(game, e.x, 1.0, e.z, 25, 255, 100, 30)
      @types.spawn_particles(game, e.x, 2.0, e.z, 15, 80, 80, 80)
      @types.spawn_debris_cluster(game, e.x, e.z, 8)
      let class_name = @types.get_class_name(e.ship_class)
      @types.add_battle_message(game, "Enemy \{class_name} sunk!", 255, 150, 50)
      @types.add_battle_log(game, "Enemy \{class_name} destroyed")
    }
  }
}

///|
fn update_fleet_ships(game : @types.Game, dt : Float) -> Unit {
  let px = game.player.x
  let pz = game.player.z
  for i in 0..<game.fleet_ships.length() {
    let fs = game.fleet_ships[i]
    if not(fs.active) {
      continue
    }
    fs.bob_phase += dt * 2.0
    // Fleet AI based on order
    if fs.order == @types.fleet_order_follow {
      // Follow player at an offset
      let follow_angle = game.player.heading +
        @types.pi +
        Float::from_int(i + 1) * 0.5
      let fx = px - @math.sinf(follow_angle) * @types.fleet_follow_dist
      let fz = pz - @math.cosf(follow_angle) * @types.fleet_follow_dist
      let desired = @types.bearing(fs.x, fs.z, fx, fz)
      let diff = @types.angle_diff(fs.heading, desired)
      let turn = fs.turn_rate_base * dt
      if diff > turn {
        fs.heading += turn
      } else if diff < -turn {
        fs.heading -= turn
      }
      fs.heading = @types.normalize_angle(fs.heading)
      let dist = @types.distance2d(fs.x, fs.z, fx, fz)
      let target_speed : Float = if dist > 5.0 {
        @types.get_class_base_speed(fs.ship_class) * fs.sail_amount
      } else {
        game.player.speed * 0.8
      }
      fs.speed = @types.lerpf(fs.speed, target_speed, dt * 2.0)
    } else if fs.order == @types.fleet_order_attack {
      // Find nearest enemy and engage
      let mut nearest_dist : Float = 999.0
      let mut nearest_idx = -1
      for j in 0..<game.enemies.length() {
        let e = game.enemies[j]
        if not(e.active) {
          continue
        }
        let d = @types.distance2d(fs.x, fs.z, e.x, e.z)
        if d < nearest_dist {
          nearest_dist = d
          nearest_idx = j
        }
      }
      if nearest_idx >= 0 {
        let target = game.enemies[nearest_idx]
        let to_target = @types.bearing(fs.x, fs.z, target.x, target.z)
        // Approach at broadside angle
        let approach = to_target + @types.pi * 0.4
        let diff = @types.angle_diff(fs.heading, approach)
        let turn = fs.turn_rate_base * dt
        if diff > turn {
          fs.heading += turn
        } else if diff < -turn {
          fs.heading -= turn
        }
        fs.heading = @types.normalize_angle(fs.heading)
        fs.speed = @types.get_class_base_speed(fs.ship_class) * fs.sail_amount
        // Fire when in range
        fs.fire_timer -= dt
        if fs.fire_timer <= 0.0 && nearest_dist < 30.0 {
          fire_fleet_broadside(game, i, nearest_idx)
          fs.fire_timer = fs.fire_rate
        }
      } else {
        // No enemies, return to follow
        fs.order = @types.fleet_order_follow
      }
    } else if fs.order == @types.fleet_order_defend {
      // Stay near target position
      let desired = @types.bearing(fs.x, fs.z, fs.target_x, fs.target_z)
      let diff = @types.angle_diff(fs.heading, desired)
      let turn = fs.turn_rate_base * dt
      if diff > turn {
        fs.heading += turn
      } else if diff < -turn {
        fs.heading -= turn
      }
      fs.heading = @types.normalize_angle(fs.heading)
      let dist = @types.distance2d(fs.x, fs.z, fs.target_x, fs.target_z)
      let target_speed : Float = if dist > 8.0 {
        @types.get_class_base_speed(fs.ship_class) * fs.sail_amount
      } else {
        1.0
      }
      fs.speed = @types.lerpf(fs.speed, target_speed, dt * 2.0)
      // Fire at nearby enemies
      fs.fire_timer -= dt
      if fs.fire_timer <= 0.0 {
        let mut near_enemy = -1
        let mut near_dist : Float = 25.0
        for j in 0..<game.enemies.length() {
          let e = game.enemies[j]
          if not(e.active) {
            continue
          }
          let d = @types.distance2d(fs.x, fs.z, e.x, e.z)
          if d < near_dist {
            near_dist = d
            near_enemy = j
          }
        }
        if near_enemy >= 0 {
          fire_fleet_broadside(game, i, near_enemy)
          fs.fire_timer = fs.fire_rate
        }
      }
    } else {
      // Hold position
      fs.speed = @types.lerpf(fs.speed, 0.0, dt * 2.0)
    }
    // Move
    let move_speed = fs.speed * dt
    let new_x = fs.x + @math.sinf(fs.heading) * move_speed
    let new_z = fs.z + @math.cosf(fs.heading) * move_speed
    if not(@types.check_island_collision(game, new_x, new_z, 1.5)) {
      let half : Float = @types.ocean_size / 2.0 - 5.0
      fs.x = @types.clampf(new_x, -half, half)
      fs.z = @types.clampf(new_z, -half, half)
    } else {
      fs.heading = @types.normalize_angle(fs.heading + @types.pi * 0.5)
    }
    // Take hits from enemy cannonballs
    // (handled in combat_system)
  }
}

///|
fn fire_fleet_broadside(
  game : @types.Game,
  fleet_idx : Int,
  enemy_idx : Int,
) -> Unit {
  let fs = game.fleet_ships[fleet_idx]
  let target = game.enemies[enemy_idx]
  let to_target = @types.bearing(fs.x, fs.z, target.x, target.z)
  let rel = @types.angle_diff(fs.heading, to_target)
  let side_angle : Float = if rel > 0.0 {
    fs.heading + @types.pi / 2.0
  } else {
    fs.heading - @types.pi / 2.0
  }
  let shots : Int = @types.mini(fs.cannon_count / 2, 3)
  for i in 0..<shots {
    let idx = @types.alloc_cannonball(game)
    if idx < 0 {
      break
    }
    let cb = game.cannonballs[idx]
    let spread = (Float::from_int(i) - Float::from_int(shots) / 2.0) * 0.15
    let fire_angle = side_angle + spread
    cb.active = true
    cb.x = fs.x + @math.sinf(fire_angle) * 1.2
    cb.y = 1.2
    cb.z = fs.z + @math.cosf(fire_angle) * 1.2
    let aim_dx = target.x - cb.x
    let aim_dz = target.z - cb.z
    let aim_dist = @types.distance2d(cb.x, cb.z, target.x, target.z)
    let speed : Float = @types.cannonball_speed * 0.75
    if aim_dist > 0.1 {
      cb.vx = aim_dx / aim_dist * speed + @types.rand_rangef(game, -2.5, 2.5)
      cb.vz = aim_dz / aim_dist * speed + @types.rand_rangef(game, -2.5, 2.5)
    } else {
      cb.vx = @math.sinf(fire_angle) * speed
      cb.vz = @math.cosf(fire_angle) * speed
    }
    cb.vy = 4.5 + @types.rand_rangef(game, 0.0, 1.5)
    cb.life = @types.cannonball_life
    cb.damage = fs.cannon_damage
    cb.from_player = true
    cb.ammo_type = @types.ammo_round_shot
    cb.cannon_type = @types.cannon_medium
  }
  let flash_x = fs.x + @math.sinf(side_angle) * 1.5
  let flash_z = fs.z + @math.cosf(side_angle) * 1.5
  @types.spawn_particles(game, flash_x, 1.2, flash_z, 4, 255, 180, 80)
  @types.spawn_smoke(game, flash_x, 1.5, flash_z, 3)
}

///|
fn update_convoy(game : @types.Game, dt : Float) -> Unit {
  for cs in game.convoy_ships {
    if not(cs.active) {
      continue
    }
    if cs.arrived {
      continue
    }
    // Move toward target
    let desired = @types.bearing(
      cs.x,
      cs.z,
      game.convoy_target_x,
      game.convoy_target_z,
    )
    let diff = @types.angle_diff(cs.heading, desired)
    let turn : Float = 0.8 * dt
    if diff > turn {
      cs.heading += turn
    } else if diff < -turn {
      cs.heading -= turn
    }
    cs.heading = @types.normalize_angle(cs.heading)
    cs.x += @math.sinf(cs.heading) * cs.speed * dt
    cs.z += @math.cosf(cs.heading) * cs.speed * dt
    // Check arrival
    let dist = @types.distance2d(
      cs.x,
      cs.z,
      game.convoy_target_x,
      game.convoy_target_z,
    )
    if dist < 10.0 {
      cs.arrived = true
      game.convoy_arrived_count += 1
      @types.add_battle_message(
        game, "Convoy ship arrived safely!", 100, 255, 100,
      )
    }
    // Check hull
    if cs.hull_hp <= 0.0 {
      cs.active = false
      @types.spawn_particles(game, cs.x, 1.0, cs.z, 20, 255, 100, 30)
      @types.spawn_debris_cluster(game, cs.x, cs.z, 6)
      @types.add_battle_message(game, "Convoy ship destroyed!", 255, 80, 60)
      @types.add_battle_log(game, "Convoy ship lost!")
    }
  }
}

///|
fn update_fortress_combat(game : @types.Game, dt : Float) -> Unit {
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
    // Fire at player if in range
    let dist_to_player = @types.distance2d(
      island.x,
      island.z,
      game.player.x,
      game.player.z,
    )
    island.fortress_fire_timer -= dt
    if island.fortress_fire_timer <= 0.0 &&
      dist_to_player < @types.fortress_range {
      island.fortress_fire_timer = @types.fortress_fire_rate
      // Fire from fortress
      let cannon_count = island.fortress_cannons_active
      let shots : Int = @types.mini(cannon_count, 3)
      for j in 0..<shots {
        let idx = @types.alloc_cannonball(game)
        if idx < 0 {
          break
        }
        let cb = game.cannonballs[idx]
        cb.active = true
        let angle_to_player = @types.bearing(
          island.x,
          island.z,
          game.player.x,
          game.player.z,
        )
        let spread = (Float::from_int(j) - Float::from_int(shots) / 2.0) * 0.2
        let fire_angle = angle_to_player + spread
        cb.x = island.x + @math.sinf(fire_angle) * (island.radius + 1.0)
        cb.y = island.height + 2.0
        cb.z = island.z + @math.cosf(fire_angle) * (island.radius + 1.0)
        let aim_dx = game.player.x - cb.x
        let aim_dz = game.player.z - cb.z
        let aim_dist = @types.distance2d(
          cb.x,
          cb.z,
          game.player.x,
          game.player.z,
        )
        let speed : Float = @types.cannonball_speed * 0.7
        if aim_dist > 0.1 {
          cb.vx = aim_dx / aim_dist * speed +
            @types.rand_rangef(game, -3.0, 3.0)
          cb.vz = aim_dz / aim_dist * speed +
            @types.rand_rangef(game, -3.0, 3.0)
        } else {
          cb.vx = @math.sinf(fire_angle) * speed
          cb.vz = @math.cosf(fire_angle) * speed
        }
        cb.vy = 6.0 + @types.rand_rangef(game, 0.0, 3.0)
        cb.life = @types.cannonball_life
        cb.damage = @types.fortress_cannon_damage
        cb.from_player = false
        cb.ammo_type = @types.ammo_round_shot
      }
      // Muzzle flash
      let flash_angle = @types.bearing(
        island.x,
        island.z,
        game.player.x,
        game.player.z,
      )
      let fx = island.x + @math.sinf(flash_angle) * (island.radius + 1.5)
      let fz = island.z + @math.cosf(flash_angle) * (island.radius + 1.5)
      @types.spawn_particles(game, fx, island.height + 2.0, fz, 6, 255, 200, 80)
      @types.spawn_smoke(game, fx, island.height + 2.5, fz, 4)
    }
  }
}

///|
fn check_objectives(game : @types.Game) -> Unit {
  let obj = game.objective
  if obj.completed || obj.failed {
    return
  }
  // Count enemies alive
  let mut alive = 0
  for enemy in game.enemies {
    if enemy.active {
      alive += 1
    }
  }
  game.enemies_alive = alive
  if obj.objective_type == @types.objective_destroy_all {
    // Also check fortress
    let mut fortress_alive = false
    for i in 0..<game.island_count {
      let island = game.islands[i]
      if island.has_fortress && island.fortress_hp > 0.0 {
        fortress_alive = true
      }
    }
    if alive == 0 && not(fortress_alive) {
      obj.completed = true
      complete_battle(game)
    }
  } else if obj.objective_type == @types.objective_escort_convoy {
    // Check if any convoy ships are still active and haven't arrived
    let convoy_alive = @types.count_convoy_alive(game)
    let mut all_arrived = true
    for cs in game.convoy_ships {
      if cs.active && not(cs.arrived) {
        all_arrived = false
      }
    }
    if convoy_alive == 0 && game.convoy_arrived_count == 0 {
      obj.failed = true
      game.state = @types.state_game_over
      game.message_text = "All convoy ships destroyed!"
      game.message_timer = 5.0
    } else if all_arrived && convoy_alive > 0 {
      obj.completed = true
      complete_battle(game)
    } else if alive == 0 && convoy_alive > 0 {
      // All enemies dead but convoy still moving - wait for arrival
      ignore(all_arrived)
    }
  } else if obj.objective_type == @types.objective_blockade_run {
    // Player must reach the far side
    if game.player.z > 80.0 {
      obj.completed = true
      complete_battle(game)
    }
    // Time limit
    obj.time_elapsed += @raylib.get_frame_time()
    if obj.time_limit > 0.0 && obj.time_elapsed > obj.time_limit {
      obj.failed = true
      game.state = @types.state_game_over
      game.message_text = "Time's up! Blockade held."
      game.message_timer = 5.0
    }
  }
}

///|
fn complete_battle(game : @types.Game) -> Unit {
  // Award score bonus
  let bonus = @levels.get_battle_reward_mult(game.current_battle) * 100
  game.score += bonus
  game.reputation += bonus
  game.state = @types.state_battle_complete
  if game.current_battle >= game.total_battles - 1 {
    game.message_text = "ALL BATTLES WON!"
    game.message_timer = 999.0
  } else {
    game.message_text = "Battle Complete!"
    game.message_timer = 3.0
  }
  @types.add_battle_log(
    game,
    "Battle \{game.current_battle + 1} complete! Score: \{game.score}",
  )
}

///|
fn start_battle(game : @types.Game, battle : Int) -> Unit {
  // Clear pools
  for i in 0..<game.enemies.length() {
    game.enemies[i] = @types.EnemyShip::inactive()
  }
  for i in 0..<game.cannonballs.length() {
    game.cannonballs[i] = @types.Cannonball::inactive()
  }
  for i in 0..<game.particles.length() {
    game.particles[i] = @types.Particle::inactive()
  }
  for i in 0..<game.islands.length() {
    game.islands[i] = @types.Island::inactive()
  }
  for i in 0..<game.wakes.length() {
    game.wakes[i] = @types.WaterWake::inactive()
  }
  for i in 0..<game.debris_pool.length() {
    game.debris_pool[i] = @types.Debris::inactive()
  }
  for i in 0..<game.fleet_ships.length() {
    game.fleet_ships[i] = @types.FleetShip::inactive()
  }
  for i in 0..<game.convoy_ships.length() {
    game.convoy_ships[i] = @types.ConvoyShip::inactive()
  }
  for i in 0..<game.messages.length() {
    game.messages[i] = @types.BattleMessage::inactive()
  }
  // Reset timers
  game.battle_timer = 0.0
  game.wave_time = 0.0
  game.wake_spawn_timer = 0.0
  game.battle_log_count = 0
  game.convoy_arrived_count = 0
  // Reset battle stats
  let stats = game.battle_stats
  stats.ships_sunk = 0
  stats.damage_dealt = 0.0
  stats.damage_taken = 0.0
  stats.crew_lost = 0
  stats.ammo_used = 0
  stats.time_elapsed = 0.0
  stats.accuracy_hits = 0
  stats.accuracy_shots = 0
  stats.boarding_wins = 0
  stats.fortresses_destroyed = 0
  // Reset player position
  game.player.x = 0.0
  game.player.z = -40.0
  game.player.heading = 0.0
  game.player.speed = 0.0
  game.player.sail_amount = 0.5
  game.player.reload_left = 0.0
  game.player.reload_right = 0.0
  game.player.drift_x = 0.0
  game.player.drift_z = 0.0
  game.player.on_fire = false
  game.player.boarding_target = -1
  game.player.boarding_timer = 0.0
  // Set up wind
  let wind_cond = @levels.get_wind_conditions(battle)
  game.wind.direction = wind_cond.0
  game.wind.speed = wind_cond.1
  game.wind.shift_interval = wind_cond.2
  game.wind.shift_timer = wind_cond.2
  game.wind.target_direction = wind_cond.0
  game.wind.target_speed = wind_cond.1
  game.wind.gust_active = false
  game.wind.gust_timer = @types.wind_gust_frequency
  @types.sync_wind(game)
  // Set up objective
  let obj = game.objective
  obj.objective_type = @levels.get_battle_objective_type(battle)
  obj.completed = false
  obj.failed = false
  obj.time_elapsed = 0.0
  obj.description = @levels.get_battle_objective_desc(battle)
  if obj.objective_type == @types.objective_blockade_run {
    obj.time_limit = @types.survive_time_default
  } else {
    obj.time_limit = 0.0
  }
  // Load battle definition
  let def = @levels.get_battle_def(battle)
  let enemy_count = def.0
  let enemy_hp = def.1
  let enemy_speed = def.2
  let enemy_fire_rate = def.3
  let enemy_damage = def.4
  let detect_range = def.5
  let score_value = def.6
  // Get enemy classes and personalities
  let classes = @levels.get_enemy_classes(battle)
  let personalities = @levels.get_enemy_personalities(battle)
  let flagship_idx = @levels.get_flagship_index(battle)
  // Spawn enemies
  for i in 0..<enemy_count {
    let idx = @types.alloc_enemy(game)
    if idx < 0 {
      break
    }
    let spawn = @levels.get_enemy_spawn_angle(i, enemy_count)
    let angle = spawn.0
    let dist = spawn.1
    let ex = @math.sinf(angle) * dist
    let ez = @math.cosf(angle) * dist
    let enemy = game.enemies[idx]
    enemy.active = true
    enemy.x = ex
    enemy.z = ez
    enemy.heading = angle + @types.pi
    // Set class-based stats
    let eclass : Int = if i < classes.length() {
      classes[i]
    } else {
      @types.class_sloop
    }
    enemy.ship_class = eclass
    enemy.ship_length = @types.get_class_length(eclass)
    enemy.ship_width = @types.get_class_width(eclass)
    enemy.turn_rate_base = @types.get_class_turn_rate(eclass)
    enemy.max_crew = @types.get_class_max_crew(eclass)
    enemy.crew = enemy.max_crew
    enemy.cannon_count = @types.get_class_cannon_count(eclass)
    enemy.cannon_type = @levels.get_enemy_cannon_type(eclass, battle)
    enemy.sail_amount = 0.7 + @types.rand_rangef(game, 0.0, 0.3)
    // Scale HP with class
    let class_hull = @types.get_class_max_hull(eclass)
    let hp_scale = enemy_hp / 50.0
    enemy.hull_hp = class_hull * hp_scale
    enemy.max_hp = class_hull * hp_scale
    enemy.mast_hp = @types.get_class_max_mast(eclass) * hp_scale
    enemy.max_mast_hp = enemy.mast_hp
    enemy.rudder_hp = @types.get_class_max_rudder(eclass) * hp_scale
    enemy.max_rudder_hp = enemy.rudder_hp
    enemy.speed = enemy_speed
    enemy.ai_state = @types.ai_patrol
    // Set personality
    let personality : Int = if i < personalities.length() {
      personalities[i]
    } else {
      @types.ai_personality_aggressive
    }
    enemy.ai_personality = personality
    // Set retreat threshold based on personality
    if personality == @types.ai_personality_defensive {
      enemy.retreat_hp_pct = 0.4
    } else if personality == @types.ai_personality_retreater {
      enemy.retreat_hp_pct = 0.5
    } else if personality == @types.ai_personality_berserker {
      enemy.retreat_hp_pct = 0.05
    } else {
      enemy.retreat_hp_pct = 0.2
    }
    enemy.patrol_angle = angle
    enemy.patrol_cx = ex
    enemy.patrol_cz = ez
    enemy.patrol_radius = 12.0 + @types.rand_rangef(game, 0.0, 5.0)
    enemy.fire_timer = @types.rand_rangef(game, 0.0, enemy_fire_rate)
    enemy.fire_rate = enemy_fire_rate
    enemy.cannon_damage = enemy_damage
    enemy.detect_range = detect_range
    enemy.attack_range = detect_range * 0.6
    enemy.score_value = score_value
    enemy.is_flagship = i == flagship_idx
    enemy.bob_phase = @types.rand_rangef(game, 0.0, @types.two_pi)
    ignore(i)
  }
  // Load islands
  let island_data = @levels.get_island_layout(battle)
  let island_types = @levels.get_island_types(battle)
  let fortress_idx = @levels.get_fortress_island(battle)
  game.island_count = 0
  for i in 0..<island_data.length() {
    if game.island_count >= @types.max_islands {
      break
    }
    let d = island_data[i]
    let island = game.islands[game.island_count]
    island.active = true
    island.x = d.0
    island.z = d.1
    island.radius = d.2
    island.height = d.3
    island.blocks = d.4
    if i < island_types.length() {
      island.island_type = island_types[i]
    }
    // Fortress setup
    if i == fortress_idx {
      island.has_fortress = true
      island.fortress_hp = @types.fortress_base_hp
      island.fortress_max_hp = @types.fortress_base_hp
      island.fortress_cannons_active = @types.fortress_cannon_count
      island.fortress_fire_timer = @types.fortress_fire_rate
      island.island_type = @types.island_fortress
    }
    // Vegetation density based on size
    if island.island_type == @types.island_small {
      island.vegetation_density = 2
    } else if island.island_type == @types.island_medium {
      island.vegetation_density = 4
    } else if island.island_type == @types.island_large {
      island.vegetation_density = 6
    } else {
      island.vegetation_density = 3
    }
    game.island_count += 1
  }
  // Spawn fleet ships
  let fleet_classes = @levels.get_fleet_classes(battle)
  for i in 0..<fleet_classes.length() {
    if i >= @types.max_fleet_ships {
      break
    }
    let fs = game.fleet_ships[i]
    let fc = fleet_classes[i]
    fs.active = true
    fs.x = game.player.x - 10.0 - Float::from_int(i) * 8.0
    fs.z = game.player.z - 5.0
    fs.heading = 0.0
    fs.ship_class = fc
    fs.hull_hp = @types.get_class_max_hull(fc) * 0.9
    fs.max_hp = @types.get_class_max_hull(fc) * 0.9
    fs.mast_hp = @types.get_class_max_mast(fc) * 0.9
    fs.max_mast_hp = @types.get_class_max_mast(fc) * 0.9
    fs.cannon_count = @types.get_class_cannon_count(fc)
    fs.cannon_damage = @types.get_cannon_damage(@types.cannon_medium)
    fs.fire_rate = 2.5
    fs.fire_timer = 0.0
    fs.crew = @types.get_class_max_crew(fc)
    fs.max_crew = @types.get_class_max_crew(fc)
    fs.sail_amount = 0.7
    fs.turn_rate_base = @types.get_class_turn_rate(fc)
    fs.ship_length = @types.get_class_length(fc)
    fs.ship_width = @types.get_class_width(fc)
    fs.order = @types.fleet_order_follow
  }
  // Spawn convoy ships
  let convoy_count = @levels.get_convoy_count(battle)
  for i in 0..<convoy_count {
    if i >= @types.max_convoy_ships {
      break
    }
    let cs = game.convoy_ships[i]
    cs.active = true
    cs.x = -15.0 + Float::from_int(i) * @types.convoy_spacing
    cs.z = -50.0
    cs.heading = 0.0
    cs.speed = @types.convoy_speed
    cs.hull_hp = 50.0
    cs.max_hp = 50.0
    cs.arrived = false
  }
  game.convoy_target_x = 0.0
  game.convoy_target_z = 80.0
  let battle_name = @levels.get_battle_name(battle)
  game.message_text = "\{battle_name} - \{game.objective.description}"
  game.message_timer = 4.0
  @types.add_battle_log(game, "Battle \{battle + 1}: \{battle_name}")
}

///|
fn reset_game(game : @types.Game) -> Unit {
  game.score = 0
  game.reputation = 0
  game.current_battle = 0
  game.player.hull_hp = @types.player_max_hp
  game.player.sail_hp = @types.player_max_hp
  game.player.rudder_hp = @types.player_max_hp * 0.8
  game.player.mast_hp = @types.frigate_max_mast
  game.player.bow_hp = @types.player_max_hp * 0.8
  game.player.mid_hp = @types.player_max_hp
  game.player.stern_hp = @types.player_max_hp * 0.8
  game.player.cannon_deck_hp = @types.player_max_hp * 0.9
  game.player.x = 0.0
  game.player.z = 0.0
  game.player.heading = 0.0
  game.player.speed = 0.0
  game.player.crew = @types.player_start_crew
  game.player.ammo_round = @types.player_start_ammo
  game.player.ammo_chain = 20
  game.player.ammo_grape = 15
  game.player.kills = 0
  game.player.damage_dealt = 0.0
  game.player.damage_taken = 0.0
  game.player.on_fire = false
  game.player.taking_water = 0.0
  game.enemies_alive = 0
  for i in 0..<game.enemies.length() {
    game.enemies[i] = @types.EnemyShip::inactive()
  }
  for i in 0..<game.cannonballs.length() {
    game.cannonballs[i] = @types.Cannonball::inactive()
  }
  for i in 0..<game.particles.length() {
    game.particles[i] = @types.Particle::inactive()
  }
  for i in 0..<game.islands.length() {
    game.islands[i] = @types.Island::inactive()
  }
  for i in 0..<game.wakes.length() {
    game.wakes[i] = @types.WaterWake::inactive()
  }
  for i in 0..<game.debris_pool.length() {
    game.debris_pool[i] = @types.Debris::inactive()
  }
  for i in 0..<game.fleet_ships.length() {
    game.fleet_ships[i] = @types.FleetShip::inactive()
  }
  for i in 0..<game.convoy_ships.length() {
    game.convoy_ships[i] = @types.ConvoyShip::inactive()
  }
  game.battle_log_count = 0
}
