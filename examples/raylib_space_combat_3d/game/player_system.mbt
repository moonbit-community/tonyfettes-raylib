// Player movement and controls

///|
pub fn update_player(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  let sc = p.ship_class
  let turn = @types.ship_class_turn(sc)

  // Pitch control (W/S)
  if @raylib.is_key_down(@raylib.KeyW) {
    p.pitch += turn * dt
    if p.pitch > @types.pi * 0.45 {
      p.pitch = @types.pi * 0.45
    }
  }
  if @raylib.is_key_down(@raylib.KeyS) {
    p.pitch -= turn * dt
    if p.pitch < -@types.pi * 0.45 {
      p.pitch = -@types.pi * 0.45
    }
  }

  // Yaw control (A/D)
  if @raylib.is_key_down(@raylib.KeyA) {
    p.yaw -= turn * dt
  }
  if @raylib.is_key_down(@raylib.KeyD) {
    p.yaw += turn * dt
  }

  // Roll control (Q/E)
  if @raylib.is_key_down(@raylib.KeyQ) {
    p.roll -= @types.player_roll_speed * dt
  }
  if @raylib.is_key_down(@raylib.KeyE) {
    p.roll += @types.player_roll_speed * dt
  }
  // Decay roll
  p.roll = p.roll * 0.95

  // Strafe controls (arrow keys for vertical/horizontal strafe)
  let strafe_speed : Float = 15.0
  p.strafe_x = 0.0
  p.strafe_y = 0.0
  if @raylib.is_key_down(@raylib.KeyLeft) {
    p.strafe_x = -strafe_speed
  }
  if @raylib.is_key_down(@raylib.KeyRight) {
    p.strafe_x = strafe_speed
  }
  if @raylib.is_key_down(@raylib.KeyUp) {
    p.strafe_y = strafe_speed
  }
  if @raylib.is_key_down(@raylib.KeyDown) {
    p.strafe_y = -strafe_speed
  }

  // Boost (left shift) - uses fuel
  let can_boost = p.boost_fuel > 0.0
  p.boosting = @raylib.is_key_down(@raylib.KeyLeftShift) && can_boost
  if p.boosting {
    p.boost_fuel -= @types.boost_fuel_drain * dt
    if p.boost_fuel < 0.0 {
      p.boost_fuel = 0.0
    }
  }

  // Calculate target speed
  let base_speed = @types.ship_class_speed(sc)
  let boost_speed = @types.ship_class_boost(sc)
  let speed_boost_mult : Float = if p.speed_boost_timer > 0.0 {
    1.3
  } else {
    1.0
  }

  let cur_speed : Float = if p.boosting {
    boost_speed * speed_boost_mult
  } else {
    base_speed * speed_boost_mult
  }
  p.speed = @types.lerpf(p.speed, cur_speed, 3.0 * dt)

  // Brake (left ctrl)
  if @raylib.is_key_down(@raylib.KeyLeftControl) {
    p.speed = @types.lerpf(p.speed, base_speed * 0.3, 4.0 * dt)
  }

  // Calculate forward direction
  let fwd = @types.forward_dir(p.yaw, p.pitch)
  let rgt = @types.right_dir(p.yaw)
  let up = @types.up_dir(p.yaw, p.pitch)

  // Combine forward movement with strafe
  p.vx = fwd.0 * p.speed + rgt.0 * p.strafe_x + up.0 * p.strafe_y
  p.vy = fwd.1 * p.speed + rgt.1 * p.strafe_x + up.1 * p.strafe_y
  p.vz = fwd.2 * p.speed + rgt.2 * p.strafe_x + up.2 * p.strafe_y

  // Move
  p.x += p.vx * dt
  p.y += p.vy * dt
  p.z += p.vz * dt

  // Wrap around world
  p.x = @types.wrap_coord(p.x)
  p.y = @types.wrap_coord(p.y)
  p.z = @types.wrap_coord(p.z)

  // Shield regeneration
  if p.shield_timer > 0.0 {
    p.shield_timer -= dt
  } else if p.shield < p.max_shield {
    p.shield += @types.shield_regen_rate * dt
    if p.shield > p.max_shield {
      p.shield = p.max_shield
    }
  }

  // Weapon fire timer
  if p.fire_timer > 0.0 {
    p.fire_timer -= dt
  }

  // Weapon selection (1-4)
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    p.weapon = @types.weapon_laser
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    p.weapon = @types.weapon_missile
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    p.weapon = @types.weapon_plasma
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    p.weapon = @types.weapon_railgun
  }

  // Fire weapon (Space or left mouse)
  let can_fire = p.fire_timer <= 0.0
  let has_energy = p.weapon_energy >= @types.weapon_energy_cost(p.weapon)
  let has_ammo = p.weapon != @types.weapon_missile || p.missile_ammo > 0
  if (
      @raylib.is_key_down(@raylib.KeySpace) ||
      @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)
    ) &&
    can_fire &&
    has_energy &&
    has_ammo {
    fire_weapon(game)
    p.fire_timer = @types.weapon_cooldown(p.weapon)
    // Deduct energy
    let cost = @types.weapon_energy_cost(p.weapon)
    p.weapon_energy -= cost
    if p.weapon == @types.weapon_missile {
      p.missile_ammo -= 1
    }
    p.shots_fired += 1
  }

  // Tab to cycle targets
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    cycle_target(game)
  }

  // T to target nearest
  if @raylib.is_key_pressed(@raylib.KeyT) {
    target_nearest(game)
  }

  // Engine particles
  if game.frame_counter % 3 == 0 {
    let fwd2 = @types.forward_dir(p.yaw, p.pitch)
    let ex = p.x - fwd2.0 * 1.5
    let ey = p.y - fwd2.1 * 1.5
    let ez = p.z - fwd2.2 * 1.5
    let r : Int = if p.boosting { 100 } else { 50 }
    let g : Int = if p.boosting { 180 } else { 120 }
    @types.spawn_particles(game, ex, ey, ez, 1, r, g, 255)
  }

  // Extra engine particles for boost
  if p.boosting && game.frame_counter % 2 == 0 {
    let fwd2 = @types.forward_dir(p.yaw, p.pitch)
    let ex = p.x - fwd2.0 * 2.0 + @types.rand_rangef(game, -0.3, 0.3)
    let ey = p.y - fwd2.1 * 2.0 + @types.rand_rangef(game, -0.3, 0.3)
    let ez = p.z - fwd2.2 * 2.0 + @types.rand_rangef(game, -0.3, 0.3)
    @types.spawn_particles(game, ex, ey, ez, 2, 200, 220, 255)
  }

  // Smoke particles when hull is low
  if p.hull < p.max_hull * 0.3 && game.frame_counter % 5 == 0 {
    @types.spawn_particles(game, p.x, p.y, p.z, 1, 80, 80, 80)
  }
}

///|
fn fire_weapon(game : @types.Game) -> Unit {
  let p = game.player
  let fwd = @types.forward_dir(p.yaw, p.pitch)
  let rgt = @types.right_dir(p.yaw)

  let damage_mult : Float = if p.weapon_boost_timer > 0.0 { 1.5 } else { 1.0 }

  if p.weapon == @types.weapon_laser {
    fire_laser(game, fwd, rgt, damage_mult)
  } else if p.weapon == @types.weapon_missile {
    fire_missile(game, fwd, damage_mult)
  } else if p.weapon == @types.weapon_plasma {
    fire_plasma(game, fwd, damage_mult)
  } else if p.weapon == @types.weapon_railgun {
    fire_railgun(game, fwd, damage_mult)
  }
  game.camera_shake = @types.maxf(game.camera_shake, 0.3)
}

///|
fn fire_laser(
  game : @types.Game,
  fwd : (Float, Float, Float),
  rgt : (Float, Float, Float),
  damage_mult : Float,
) -> Unit {
  let p = game.player
  // Fire two bolts (left and right of ship)
  let offsets : Array[Float] = [0.4, -0.4]
  for o = 0; o < offsets.length(); o = o + 1 {
    let off = offsets[o]
    let idx = @types.alloc_projectile(game)
    if idx < 0 {
      break
    }
    let proj = game.projectiles[idx]
    proj.active = true
    proj.kind = @types.weapon_laser
    proj.from_player = true
    proj.x = p.x + fwd.0 * 2.0 + rgt.0 * off
    proj.y = p.y + fwd.1 * 2.0 + rgt.1 * off
    proj.z = p.z + fwd.2 * 2.0 + rgt.2 * off
    proj.vx = fwd.0 * @types.laser_speed
    proj.vy = fwd.1 * @types.laser_speed
    proj.vz = fwd.2 * @types.laser_speed
    proj.damage = @types.laser_damage * damage_mult
    proj.life = @types.laser_range / @types.laser_speed
    proj.target_idx = -1
    proj.size = 0.06
    proj.fuel = 0.0
    proj.piercing = false
  }
}

///|
fn fire_missile(
  game : @types.Game,
  fwd : (Float, Float, Float),
  damage_mult : Float,
) -> Unit {
  let p = game.player
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let proj = game.projectiles[idx]
  proj.active = true
  proj.kind = @types.weapon_missile
  proj.from_player = true
  proj.x = p.x + fwd.0 * 2.0
  proj.y = p.y + fwd.1 * 2.0
  proj.z = p.z + fwd.2 * 2.0
  proj.vx = fwd.0 * @types.missile_speed
  proj.vy = fwd.1 * @types.missile_speed
  proj.vz = fwd.2 * @types.missile_speed
  proj.damage = @types.missile_damage * damage_mult
  proj.life = @types.missile_range / @types.missile_speed
  proj.target_idx = game.target_idx
  proj.size = 0.2
  proj.fuel = @types.missile_fuel
  proj.piercing = false
}

///|
fn fire_plasma(
  game : @types.Game,
  fwd : (Float, Float, Float),
  damage_mult : Float,
) -> Unit {
  let p = game.player
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let proj = game.projectiles[idx]
  proj.active = true
  proj.kind = @types.weapon_plasma
  proj.from_player = true
  proj.x = p.x + fwd.0 * 2.0
  proj.y = p.y + fwd.1 * 2.0
  proj.z = p.z + fwd.2 * 2.0
  proj.vx = fwd.0 * @types.plasma_speed
  proj.vy = fwd.1 * @types.plasma_speed
  proj.vz = fwd.2 * @types.plasma_speed
  proj.damage = @types.plasma_damage * damage_mult
  proj.life = @types.plasma_range / @types.plasma_speed
  proj.target_idx = -1
  proj.size = 0.3
  proj.fuel = 0.0
  proj.piercing = false
}

///|
fn fire_railgun(
  game : @types.Game,
  fwd : (Float, Float, Float),
  damage_mult : Float,
) -> Unit {
  let p = game.player
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let proj = game.projectiles[idx]
  proj.active = true
  proj.kind = @types.weapon_railgun
  proj.from_player = true
  proj.x = p.x + fwd.0 * 2.5
  proj.y = p.y + fwd.1 * 2.5
  proj.z = p.z + fwd.2 * 2.5
  proj.vx = fwd.0 * @types.railgun_speed
  proj.vy = fwd.1 * @types.railgun_speed
  proj.vz = fwd.2 * @types.railgun_speed
  proj.damage = @types.railgun_damage * damage_mult
  proj.life = @types.railgun_range / @types.railgun_speed
  proj.target_idx = -1
  proj.size = 0.04
  proj.fuel = 0.0
  proj.piercing = true
  // Railgun has stronger camera shake
  game.camera_shake = @types.maxf(game.camera_shake, 0.6)
}

///|
fn cycle_target(game : @types.Game) -> Unit {
  let start = game.target_idx + 1
  // Search forward from current
  for i = start; i < game.enemies.length(); i = i + 1 {
    if game.enemies[i].active {
      game.target_idx = i
      game.target_lock_timer = 0.0
      return
    }
  }
  // Wrap around
  for i = 0; i < start; i = i + 1 {
    if i < game.enemies.length() && game.enemies[i].active {
      game.target_idx = i
      game.target_lock_timer = 0.0
      return
    }
  }
  game.target_idx = -1
}

///|
fn target_nearest(game : @types.Game) -> Unit {
  let p = game.player
  let idx = @types.find_nearest_enemy(game, p.x, p.y, p.z)
  if idx >= 0 {
    game.target_idx = idx
    game.target_lock_timer = 0.0
  }
}

///|
pub fn damage_player(game : @types.Game, damage : Float) -> Unit {
  let p = game.player
  p.shield_timer = @types.shield_regen_delay
  p.damage_flash = @types.damage_flash_duration

  // Screen flash for damage
  game.screen_flash = 0.3
  game.flash_r = 255
  game.flash_g = 50
  game.flash_b = 50

  if p.shield > 0.0 {
    let absorbed = @types.minf(p.shield, damage)
    p.shield -= absorbed
    let remaining = damage - absorbed
    if remaining > 0.0 {
      p.hull -= remaining
    }
    // Shield hit particles
    @types.spawn_shield_hit(game, p.x, p.y, p.z, 5)
  } else {
    p.hull -= damage
  }
  game.camera_shake = @types.maxf(game.camera_shake, 0.5)
  if p.hull <= 0.0 {
    p.hull = 0.0
    game.state = @types.state_game_over
    @types.spawn_explosion(game, p.x, p.y, p.z, 40, 255, 150, 50)
    @types.spawn_debris(game, p.x, p.y, p.z, 10, 100, 150, 220)
    game.camera_shake = 2.0
    game.screen_flash = 1.0
  }
}
