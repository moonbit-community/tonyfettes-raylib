// Player aircraft controls and physics

pub fn update_player(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  if not(player.alive) { return }
  // Throttle
  if @raylib.is_key_down(@raylib.KeyLeftShift) {
    player.throttle += 0.8 * dt
    if player.throttle > 1.0 { player.throttle = 1.0 }
  }
  if @raylib.is_key_down(@raylib.KeyLeftControl) {
    player.throttle -= 0.8 * dt
    if player.throttle < 0.0 { player.throttle = 0.0 }
  }
  // Pitch (W/S)
  if @raylib.is_key_down(@raylib.KeyW) {
    player.pitch -= @types.aircraft_pitch_rate * dt
  }
  if @raylib.is_key_down(@raylib.KeyS) {
    player.pitch += @types.aircraft_pitch_rate * dt
  }
  // Clamp pitch
  let max_pitch : Float = @types.pi * 0.45
  player.pitch = @types.clampf(player.pitch, -max_pitch, max_pitch)
  // Yaw (A/D)
  if @raylib.is_key_down(@raylib.KeyA) {
    player.yaw -= @types.aircraft_yaw_rate * dt
  }
  if @raylib.is_key_down(@raylib.KeyD) {
    player.yaw += @types.aircraft_yaw_rate * dt
  }
  // Roll (Q/E)
  if @raylib.is_key_down(@raylib.KeyQ) {
    player.roll -= @types.aircraft_roll_rate * dt
  }
  if @raylib.is_key_down(@raylib.KeyE) {
    player.roll += @types.aircraft_roll_rate * dt
  }
  // Clamp roll
  let max_roll : Float = @types.pi * 0.8
  player.roll = @types.clampf(player.roll, -max_roll, max_roll)
  // Roll auto-center when no input
  if not(@raylib.is_key_down(@raylib.KeyQ)) && not(
    @raylib.is_key_down(@raylib.KeyE),
  ) {
    if player.roll > 0.01 {
      player.roll -= 0.8 * dt
      if player.roll < 0.0 { player.roll = 0.0 }
    } else if player.roll < -0.01 {
      player.roll += 0.8 * dt
      if player.roll > 0.0 { player.roll = 0.0 }
    }
  }
  // Roll affects yaw (banking turn)
  player.yaw += @math.sinf(player.roll) * 0.8 * dt
  // Speed based on throttle
  let target_speed = @types.aircraft_speed_min +
    (@types.aircraft_speed_max - @types.aircraft_speed_min) * player.throttle
  let speed_diff = target_speed - player.speed
  player.speed += speed_diff * @types.aircraft_drag * 10.0 * dt
  // Fuel consumption
  player.fuel -= @types.aircraft_fuel_rate * player.throttle * dt
  if player.fuel < 0.0 {
    player.fuel = 0.0
    player.throttle = 0.0
  }
  // Calculate forward direction
  let (fx, fy, fz) = @types.get_forward(player.pitch, player.yaw)
  // Apply movement
  player.x += fx * player.speed * dt
  player.y += fy * player.speed * dt
  player.z += fz * player.speed * dt
  // Gravity effect when slow or no fuel
  let lift = player.speed * @types.aircraft_lift_factor
  if lift < @types.aircraft_gravity {
    player.y -= (@types.aircraft_gravity - lift) * dt
  }
  // Terrain collision
  let ground = @types.terrain_height_at(player.x, player.z) +
    @types.aircraft_min_altitude
  if player.y < ground {
    // Crash if going too fast or too steep
    if player.speed > 25.0 || @types.absf(player.pitch) > 0.3 {
      crash_player(game)
      return
    }
    player.y = ground
    player.pitch = 0.0
    if player.speed > 5.0 {
      player.speed -= 10.0 * dt
    }
  }
  // Damage flash timer
  if player.damage_flash > 0.0 {
    player.damage_flash -= dt
  }
  // Fire timer
  if player.fire_timer > 0.0 {
    player.fire_timer -= dt
  }
  // Fire weapon
  if @raylib.is_key_down(@raylib.KeySpace) && player.fire_timer <= 0.0 {
    fire_player_weapon(game)
    player.fire_timer = @types.fire_cooldown
  }
  // Landing check
  check_landing(game, dt)
  // Engine particles (exhaust trail)
  if game.frame_counter % 3 == 0 {
    let idx = @types.alloc_particle(game)
    if idx >= 0 {
      let p = game.particles[idx]
      p.active = true
      p.x = player.x - fx * 2.0
      p.y = player.y - fy * 2.0
      p.z = player.z - fz * 2.0
      p.vx = -fx * 3.0 + @types.rand_rangef(game, -0.5, 0.5)
      p.vy = -fy * 3.0 + @types.rand_rangef(game, -0.5, 0.5)
      p.vz = -fz * 3.0 + @types.rand_rangef(game, -0.5, 0.5)
      p.life = 0.5
      p.max_life = 0.5
      p.r = 200
      p.g = 200
      p.b = 200
      p.size = 0.15
    }
  }
}

fn fire_player_weapon(game : @types.Game) -> Unit {
  let player = game.player
  let idx = @types.alloc_projectile(game)
  if idx < 0 { return }
  let (fx, fy, fz) = @types.get_forward(player.pitch, player.yaw)
  let proj = game.projectiles[idx]
  proj.active = true
  proj.x = player.x + fx * 2.5
  proj.y = player.y + fy * 2.5
  proj.z = player.z + fz * 2.5
  proj.dx = fx
  proj.dy = fy
  proj.dz = fz
  proj.speed = @types.projectile_speed
  proj.damage = @types.projectile_damage
  proj.life = @types.projectile_life
  proj.is_enemy = false
}

fn crash_player(game : @types.Game) -> Unit {
  let player = game.player
  player.alive = false
  @types.spawn_explosion(game, player.x, player.y, player.z)
  @types.show_message(game, "CRASHED!", 3.0)
  game.state = @types.state_game_over
}

pub fn damage_player(game : @types.Game, amount : Float) -> Unit {
  let player = game.player
  if not(player.alive) { return }
  if player.damage_flash > 0.0 { return }
  player.hp -= amount
  player.damage_flash = 0.3
  if player.hp <= 0.0 {
    player.hp = 0.0
    player.alive = false
    @types.spawn_explosion(game, player.x, player.y, player.z)
    @types.show_message(game, "SHOT DOWN!", 3.0)
    game.state = @types.state_game_over
  }
}

fn check_landing(game : @types.Game, dt : Float) -> Unit {
  let mission = game.missions[game.current_mission]
  if not(mission.has_landing) { return }
  let player = game.player
  let land_x = mission.landing_x
  let land_z = mission.landing_z
  let dist_h = @types.distance2d(player.x, player.z, land_x, land_z)
  let ground = @types.terrain_height_at(land_x, land_z) +
    @types.aircraft_min_altitude
  let altitude_above_ground = player.y - ground
  // Check if near landing zone
  if dist_h < 15.0 && altitude_above_ground < 3.0 {
    if not(game.landing_approach) {
      game.landing_approach = true
      @types.show_message(game, "Landing approach - slow down!", 2.0)
    }
    // Check successful landing conditions
    if altitude_above_ground < 1.0 && player.speed < 25.0 && @types.absf(
      player.pitch,
    ) < 0.2 && @types.absf(player.roll) < 0.3 {
      game.landing_timer += dt
      if game.landing_timer > 1.5 {
        mission.targets_done = mission.target_count
        @types.show_message(game, "Landing successful!", 3.0)
      }
    } else {
      game.landing_timer = 0.0
    }
  } else {
    game.landing_approach = false
    game.landing_timer = 0.0
  }
}
