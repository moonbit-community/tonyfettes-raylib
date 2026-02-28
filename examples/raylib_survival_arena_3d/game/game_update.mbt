// Main game update dispatcher

pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_particles(game, dt)
  @types.update_kill_feed(game, dt)
  @types.update_damage_indicators(game, dt)
  if game.state == @types.state_menu {
    update_menu(game, dt)
  } else if game.state == @types.state_playing {
    update_playing(game, dt)
  } else if game.state == @types.state_wave_complete {
    update_wave_complete(game, dt)
  } else if game.state == @types.state_paused {
    update_paused(game, dt)
  } else if game.state == @types.state_game_over {
    update_game_over(game, dt)
  }
}

fn update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    start_new_game(game)
    game.state = @types.state_wave_complete
    game.wave_timer = @types.wave_shop_time
    @types.show_message(game, "Wave 1 starting soon! Press SPACE to skip.", 3.0)
    @raylib.disable_cursor()
  }
}

fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_paused
    @raylib.enable_cursor()
    return
  }
  // Update game systems
  update_player(game, dt)
  update_camera_fps(game)
  update_weapon_cooldowns(game, dt)
  handle_shooting(game)
  update_enemies_ai(game, dt)
  update_projectiles(game, dt)
  update_crates(game, dt)
  update_pickups(game, dt)
  update_traps(game, dt)
  update_message(game, dt)
  // Weapon selection with number keys
  if @raylib.is_key_pressed(@raylib.KeyOne) && game.player.owns_weapon[0] {
    switch_weapon(game, @types.weapon_pistol)
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) && game.player.owns_weapon[1] {
    switch_weapon(game, @types.weapon_shotgun)
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) && game.player.owns_weapon[2] {
    switch_weapon(game, @types.weapon_rifle)
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) && game.player.owns_weapon[3] {
    switch_weapon(game, @types.weapon_sniper)
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) && game.player.owns_weapon[4] {
    switch_weapon(game, @types.weapon_rocket)
  }
  if @raylib.is_key_pressed(@raylib.KeySix) && game.player.owns_weapon[5] {
    switch_weapon(game, @types.weapon_minigun)
  }
  // Mouse wheel weapon cycling
  let wheel = @raylib.get_mouse_wheel_move()
  if wheel > 0.0 {
    cycle_weapon(game, 1)
  } else if wheel < 0.0 {
    cycle_weapon(game, -1)
  }
  // Check wave completion
  check_wave_status(game)
  // Check player death
  if game.player.hp <= 0.0 {
    game.player.hp = 0.0
    game.state = @types.state_game_over
    @raylib.enable_cursor()
  }
}

fn switch_weapon(game : @types.Game, weapon : Int) -> Unit {
  if game.player.current_weapon != weapon {
    game.player.current_weapon = weapon
    // Cancel reload
    game.weapons[weapon].reloading = false
    // Reset minigun spin
    if weapon != @types.weapon_minigun {
      game.player.minigun_spinning = false
    }
  }
}

fn cycle_weapon(game : @types.Game, direction : Int) -> Unit {
  let mut next = game.player.current_weapon + direction
  // Wrap around and find next owned weapon
  for _attempts = 0; _attempts < @types.weapon_count; _attempts = _attempts + 1 {
    if next >= @types.weapon_count { next = 0 }
    if next < 0 { next = @types.weapon_count - 1 }
    if game.player.owns_weapon[next] {
      switch_weapon(game, next)
      return
    }
    next += direction
  }
}

fn update_wave_complete(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_paused
    @raylib.enable_cursor()
    return
  }
  // Player can still move during shop phase
  update_player(game, dt)
  update_camera_fps(game)
  update_crates(game, dt)
  update_pickups(game, dt)
  update_message(game, dt)
  // Wave summary display
  if game.show_wave_summary {
    game.wave_summary_timer -= dt
    if game.wave_summary_timer <= 0.0 {
      game.show_wave_summary = false
    }
  }
  // Shop navigation
  let max_items = @levels.shop_item_count()
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.shop_cursor -= 1
    if game.shop_cursor < 0 { game.shop_cursor = max_items - 1 }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.shop_cursor += 1
    if game.shop_cursor >= max_items { game.shop_cursor = 0 }
  }
  // Buy item
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeyE,
  ) {
    buy_shop_item(game, game.shop_cursor)
  }
  // Weapon selection still works
  if @raylib.is_key_pressed(@raylib.KeyOne) && game.player.owns_weapon[0] {
    switch_weapon(game, @types.weapon_pistol)
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) && game.player.owns_weapon[1] {
    switch_weapon(game, @types.weapon_shotgun)
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) && game.player.owns_weapon[2] {
    switch_weapon(game, @types.weapon_rifle)
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) && game.player.owns_weapon[3] {
    switch_weapon(game, @types.weapon_sniper)
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) && game.player.owns_weapon[4] {
    switch_weapon(game, @types.weapon_rocket)
  }
  if @raylib.is_key_pressed(@raylib.KeySix) && game.player.owns_weapon[5] {
    switch_weapon(game, @types.weapon_minigun)
  }
  // Timer counts down or skip with space
  game.wave_timer -= dt
  if game.wave_timer <= 0.0 || @raylib.is_key_pressed(@raylib.KeySpace) {
    start_wave(game, game.current_wave)
    game.state = @types.state_playing
    @types.show_message(
      game,
      "Wave \{game.current_wave + 1} incoming!",
      2.5,
    )
  }
}

fn update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) || @raylib.is_key_pressed(
    @raylib.KeyP,
  ) {
    // Return to previous playing state
    if game.wave_active {
      game.state = @types.state_playing
    } else {
      game.state = @types.state_wave_complete
    }
    @raylib.disable_cursor()
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    // Quit to menu
    game.state = @types.state_menu
  }
}

fn update_game_over(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) || @raylib.is_key_pressed(
    @raylib.KeySpace,
  ) {
    game.state = @types.state_menu
  }
}

fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) { continue i + 1 }
    p.life -= dt
    if p.life <= 0.0 {
      p.active = false
      continue i + 1
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.z += p.vz * dt
    // Different physics per particle type
    if p.kind == @types.particle_shell {
      p.vy -= 12.0 * dt
      p.vx *= 0.98
      p.vz *= 0.98
    } else if p.kind == @types.particle_spark {
      p.vy -= 5.0 * dt
      p.vx *= 0.92
      p.vz *= 0.92
    } else {
      p.vy -= 8.0 * dt
      p.vx *= 0.96
      p.vz *= 0.96
    }
    // Floor collision
    if p.y < 0.0 {
      p.y = 0.0
      p.vy = @types.absf(p.vy) * 0.3
      if p.kind == @types.particle_shell {
        p.vy = @types.absf(p.vy) * 0.1
        p.vx *= 0.5
        p.vz *= 0.5
      }
    }
  }
}

fn update_message(game : @types.Game, dt : Float) -> Unit {
  if game.message_timer > 0.0 {
    game.message_timer -= dt
    if game.message_timer < 0.0 { game.message_timer = 0.0 }
  }
}

fn update_pickups(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.pickups.length(); i = i + 1 {
    let pickup = game.pickups[i]
    if not(pickup.active) { continue i + 1 }
    // Update float animation
    pickup.float_timer += dt * 3.0
    pickup.y = 0.5 + @math.sinf(pickup.float_timer) * 0.15
    // Lifetime
    pickup.life -= dt
    if pickup.life <= 0.0 {
      pickup.active = false
      continue i + 1
    }
    // Check player pickup
    let dist = @types.distance2d(game.player.x, game.player.z, pickup.x, pickup.z)
    if dist < 1.5 {
      apply_pickup(game, pickup.kind)
      pickup.active = false
      @types.spawn_particles(game, pickup.x, pickup.y, pickup.z, 6, 255, 255, 100)
    }
  }
}

fn apply_pickup(game : @types.Game, kind : Int) -> Unit {
  if kind == @types.pickup_health {
    let heal : Float = 30.0
    game.player.hp = @types.minf(game.player.hp + heal, @types.player_max_hp)
    @types.show_message(game, "+30 HP!", 1.5)
    @types.add_kill_feed(game, "+30 Health", 50, 255, 50)
  } else if kind == @types.pickup_ammo {
    // Give ammo to current weapon
    let weapon = game.player.current_weapon
    if weapon != @types.weapon_pistol {
      let add = @types.weapon_mag_size(weapon) * 2
      game.player.ammo[weapon] += add
      @types.show_message(game, "+\{add} \{@types.weapon_name(weapon)} ammo", 1.5)
    }
  } else if kind == @types.pickup_speed_boost {
    game.player.speed_boost_timer = @types.pickup_speed_duration
    @types.show_message(game, "Speed Boost!", 1.5)
    @types.add_kill_feed(game, "Speed Boost Active", 50, 200, 255)
  } else if kind == @types.pickup_damage_boost {
    game.player.damage_boost_timer = @types.pickup_damage_duration
    @types.show_message(game, "Damage Boost!", 1.5)
    @types.add_kill_feed(game, "Damage Boost Active", 255, 100, 50)
  } else if kind == @types.pickup_shield {
    game.player.shield_timer = @types.pickup_shield_duration
    @types.show_message(game, "Shield Active!", 1.5)
    @types.add_kill_feed(game, "Shield Active", 50, 150, 255)
  } else if kind == @types.pickup_nuke {
    // Kill all active enemies
    @types.show_message(game, "NUKE!!!", 2.0)
    @types.add_kill_feed(game, "NUKE ACTIVATED!", 255, 50, 50)
    for ei = 0; ei < game.enemies.length(); ei = ei + 1 {
      let enemy = game.enemies[ei]
      if enemy.active {
        @types.spawn_particles(game, enemy.x, enemy.y, enemy.z, 8, 255, 200, 50)
        kill_enemy(game, ei)
      }
    }
  }
}

fn update_traps(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.traps.length(); i = i + 1 {
    let trap = game.traps[i]
    if not(trap.active) { continue i + 1 }
    if trap.cooldown_timer > 0.0 {
      trap.cooldown_timer -= dt
    }
    if trap.active_timer > 0.0 {
      trap.active_timer -= dt
    }
  }
}

fn check_wave_status(game : @types.Game) -> Unit {
  if not(game.wave_active) { return }
  // Check if all enemies spawned and all dead
  if game.enemies_spawned >= game.enemies_to_spawn {
    let alive = @types.count_active_enemies(game)
    if alive == 0 {
      game.wave_active = false
      // Give wave bonus
      let bonus = @levels.wave_bonus(game.current_wave)
      game.player.money += bonus
      game.player.score += bonus
      // Wave summary
      game.show_wave_summary = true
      game.wave_summary_timer = 4.0
      game.wave_summary_kills = game.player.kills
      game.wave_summary_money = bonus
      game.current_wave += 1
      if game.current_wave >= @types.max_waves {
        // Victory! Just go to game over with high score
        game.state = @types.state_game_over
        @raylib.enable_cursor()
        @types.show_message(game, "VICTORY! All waves survived!", 5.0)
      } else {
        game.state = @types.state_wave_complete
        game.wave_timer = @types.wave_shop_time
        game.shop_cursor = 0
        @types.show_message(
          game,
          "Wave cleared! +\{bonus} gold. Shop open!",
          3.0,
        )
      }
    }
  }
}

fn start_new_game(game : @types.Game) -> Unit {
  // Reset player
  game.player.x = 0.0
  game.player.y = @types.player_height
  game.player.z = 0.0
  game.player.yaw = 0.0
  game.player.pitch = 0.0
  game.player.hp = @types.player_max_hp
  game.player.armor = 0.0
  game.player.current_weapon = @types.weapon_pistol
  game.player.ammo[0] = @types.ammo_pistol
  game.player.ammo[1] = @types.ammo_shotgun
  game.player.ammo[2] = @types.ammo_rifle
  game.player.ammo[3] = @types.ammo_sniper
  game.player.ammo[4] = @types.ammo_rocket
  game.player.ammo[5] = @types.ammo_minigun
  // Reset magazines
  for mi = 0; mi < @types.weapon_count; mi = mi + 1 {
    game.player.magazine[mi] = @types.weapon_mag_size(mi)
    game.player.mag_size[mi] = @types.weapon_mag_size(mi)
  }
  game.player.speed_mult = 1.0
  game.player.damage_mult = 1.0
  game.player.damage_timer = 0.0
  game.player.score = 0
  game.player.money = 0
  game.player.kills = 0
  game.player.headshots = 0
  game.player.bob_timer = 0.0
  game.player.flash_timer = 0.0
  game.player.sprint = false
  game.player.crouching = false
  game.player.crouch_lerp = 0.0
  game.player.combo_count = 0
  game.player.combo_timer = 0.0
  game.player.combo_mult = @types.combo_base_mult
  game.player.speed_boost_timer = 0.0
  game.player.damage_boost_timer = 0.0
  game.player.shield_timer = 0.0
  game.player.recent_kill_timer = 0.0
  game.player.recent_kill_count = 0
  game.player.owns_weapon[0] = true
  game.player.owns_weapon[1] = true
  game.player.owns_weapon[2] = true
  game.player.owns_weapon[3] = false
  game.player.owns_weapon[4] = false
  game.player.owns_weapon[5] = false
  game.player.minigun_spin = 0.0
  game.player.minigun_spinning = false
  game.player.recoil_offset = 0.0
  game.player.recoil_recover = 0.0
  for wi = 0; wi < @types.weapon_count; wi = wi + 1 {
    game.player.weapon_damage_level[wi] = 0
    game.player.weapon_rate_level[wi] = 0
    game.player.weapon_mag_level[wi] = 0
  }
  // Reset waves
  game.current_wave = 0
  game.wave_timer = @types.wave_shop_time
  game.spawn_timer = 0.0
  game.enemies_to_spawn = 0
  game.enemies_spawned = 0
  game.wave_active = false
  game.difficulty = 1.0
  game.hit_marker_timer = 0.0
  game.shop_cursor = 0
  game.message_timer = 0.0
  game.message_text = ""
  game.show_wave_summary = false
  game.wave_summary_timer = 0.0
  game.total_shots_fired = 0
  game.total_shots_hit = 0
  game.highest_combo = 0
  game.total_damage_dealt = 0.0
  game.total_damage_taken = 0.0
  // Clear pools
  for i = 0; i < game.enemies.length(); i = i + 1 {
    game.enemies[i] = @types.Enemy::inactive()
  }
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    game.projectiles[i] = @types.Projectile::inactive()
  }
  for i = 0; i < game.particles.length(); i = i + 1 {
    game.particles[i] = @types.Particle::inactive()
  }
  for i = 0; i < game.pickups.length(); i = i + 1 {
    game.pickups[i] = @types.Pickup::inactive()
  }
  for i = 0; i < game.traps.length(); i = i + 1 {
    game.traps[i] = @types.ArenaTrap::inactive()
  }
  for i = 0; i < game.barricades.length(); i = i + 1 {
    game.barricades[i] = @types.Barricade::inactive()
  }
  for i = 0; i < game.kill_feed.length(); i = i + 1 {
    game.kill_feed[i] = @types.KillFeedEntry::inactive()
  }
  for i = 0; i < game.damage_indicators.length(); i = i + 1 {
    game.damage_indicators[i] = @types.DamageIndicator::inactive()
  }
  // Reset weapon cooldowns
  for i = 0; i < game.weapons.length(); i = i + 1 {
    game.weapons[i].reload_timer = 0.0
    game.weapons[i].reloading = false
    game.weapons[i].reload_time = 0.0
  }
  // Reset crates
  for i = 0; i < game.crates.length(); i = i + 1 {
    game.crates[i].active = true
    game.crates[i].respawn_timer = 0.0
  }
}

fn start_wave(game : @types.Game, wave : Int) -> Unit {
  game.enemies_to_spawn = @levels.get_wave_total_enemies(wave)
  game.wave_hp_mult = @levels.get_wave_hp_mult(wave)
  game.wave_speed_mult = @levels.get_wave_speed_mult(wave)
  game.enemies_spawned = 0
  game.spawn_timer = 0.0
  game.wave_active = true
  game.difficulty = 1.0 + Float::from_int(wave) * 0.05
}

fn buy_shop_item(game : @types.Game, item_idx : Int) -> Unit {
  let cost = @levels.shop_item_cost(item_idx)
  if game.player.money < cost { return }
  if item_idx == 0 {
    // Heal
    if game.player.hp < @types.player_max_hp {
      game.player.money -= cost
      game.player.hp = @types.minf(
        game.player.hp + 40.0, @types.player_max_hp,
      )
      @types.show_message(game, "Healed! HP: \{game.player.hp.to_int()}", 1.5)
    }
  } else if item_idx == 1 {
    // Armor
    if game.player.armor < @types.player_max_armor {
      game.player.money -= cost
      game.player.armor = @types.minf(
        game.player.armor + 30.0, @types.player_max_armor,
      )
      @types.show_message(
        game, "Armor up! Armor: \{game.player.armor.to_int()}", 1.5,
      )
    }
  } else if item_idx == 2 {
    // Shotgun ammo
    game.player.money -= cost
    game.player.ammo[@types.weapon_shotgun] += 12
    @types.show_message(
      game,
      "Shotgun ammo +12! Total: \{game.player.ammo[@types.weapon_shotgun]}",
      1.5,
    )
  } else if item_idx == 3 {
    // Rifle ammo
    game.player.money -= cost
    game.player.ammo[@types.weapon_rifle] += 30
    @types.show_message(
      game,
      "Rifle ammo +30! Total: \{game.player.ammo[@types.weapon_rifle]}",
      1.5,
    )
  } else if item_idx == 4 {
    // Sniper ammo
    game.player.money -= cost
    game.player.ammo[@types.weapon_sniper] += 5
    @types.show_message(
      game,
      "Sniper ammo +5! Total: \{game.player.ammo[@types.weapon_sniper]}",
      1.5,
    )
  } else if item_idx == 5 {
    // Rocket ammo
    game.player.money -= cost
    game.player.ammo[@types.weapon_rocket] += 3
    @types.show_message(
      game,
      "Rocket ammo +3! Total: \{game.player.ammo[@types.weapon_rocket]}",
      1.5,
    )
  } else if item_idx == 6 {
    // Minigun ammo
    game.player.money -= cost
    game.player.ammo[@types.weapon_minigun] += 100
    @types.show_message(
      game,
      "Minigun ammo +100! Total: \{game.player.ammo[@types.weapon_minigun]}",
      1.5,
    )
  } else if item_idx == 7 {
    // Damage upgrade
    game.player.money -= cost
    game.player.damage_mult += 0.15
    let pct = (game.player.damage_mult * 100.0).to_int()
    @types.show_message(game, "Damage up! Now \{pct}%", 1.5)
  } else if item_idx == 8 {
    // Speed upgrade
    game.player.money -= cost
    game.player.speed_mult += 0.1
    let pct = (game.player.speed_mult * 100.0).to_int()
    @types.show_message(game, "Speed up! Now \{pct}%", 1.5)
  } else if item_idx == 9 {
    // Buy Sniper
    if not(game.player.owns_weapon[@types.weapon_sniper]) {
      game.player.money -= cost
      game.player.owns_weapon[@types.weapon_sniper] = true
      game.player.ammo[@types.weapon_sniper] = @types.ammo_sniper
      game.player.magazine[@types.weapon_sniper] = @types.mag_sniper
      @types.show_message(game, "Sniper Rifle acquired!", 2.0)
    }
  } else if item_idx == 10 {
    // Buy Rocket Launcher
    if not(game.player.owns_weapon[@types.weapon_rocket]) {
      game.player.money -= cost
      game.player.owns_weapon[@types.weapon_rocket] = true
      game.player.ammo[@types.weapon_rocket] = @types.ammo_rocket
      game.player.magazine[@types.weapon_rocket] = @types.mag_rocket
      @types.show_message(game, "Rocket Launcher acquired!", 2.0)
    }
  } else if item_idx == 11 {
    // Buy Minigun
    if not(game.player.owns_weapon[@types.weapon_minigun]) {
      game.player.money -= cost
      game.player.owns_weapon[@types.weapon_minigun] = true
      game.player.ammo[@types.weapon_minigun] = @types.ammo_minigun
      game.player.magazine[@types.weapon_minigun] = @types.mag_minigun
      @types.show_message(game, "Minigun acquired!", 2.0)
    }
  } else if item_idx == 12 {
    // Place barricade
    let bi = @types.alloc_barricade(game)
    if bi >= 0 {
      game.player.money -= cost
      let barr = game.barricades[bi]
      barr.active = true
      // Place in front of player
      let cos_yaw = @math.cosf(game.player.yaw)
      let sin_yaw = @math.sinf(game.player.yaw)
      barr.x = game.player.x + sin_yaw * 3.0
      barr.z = game.player.z + cos_yaw * 3.0
      barr.hp = @types.barricade_max_hp
      barr.max_hp = @types.barricade_max_hp
      @types.show_message(game, "Barricade placed!", 1.5)
    }
  } else if item_idx == 13 {
    // Place spike trap
    let ti = @types.alloc_trap(game)
    if ti >= 0 {
      game.player.money -= cost
      let trap = game.traps[ti]
      trap.active = true
      trap.kind = @types.trap_spike
      // Place in front of player
      let cos_yaw = @math.cosf(game.player.yaw)
      let sin_yaw = @math.sinf(game.player.yaw)
      trap.x = game.player.x + sin_yaw * 3.0
      trap.z = game.player.z + cos_yaw * 3.0
      trap.cooldown_timer = 0.0
      trap.active_timer = 0.0
      trap.damage = @types.trap_spike_damage
      @types.show_message(game, "Spike trap placed!", 1.5)
    }
  }
}

fn update_crates(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.crates.length(); i = i + 1 {
    let crate = game.crates[i]
    if not(crate.active) {
      crate.respawn_timer -= dt
      if crate.respawn_timer <= 0.0 {
        crate.active = true
      }
      continue i + 1
    }
    // Check if player is close enough to pick up
    let dist = @types.distance2d(
      game.player.x, game.player.z, crate.x, crate.z,
    )
    if dist < 2.0 {
      // Give ammo
      let weapon = crate.kind
      let add_ammo = if weapon == @types.weapon_shotgun {
        6
      } else if weapon == @types.weapon_rifle {
        15
      } else if weapon == @types.weapon_minigun {
        50
      } else {
        2
      }
      game.player.ammo[weapon] += add_ammo
      @types.show_message(
        game,
        "+\{add_ammo} \{@types.weapon_name(weapon)} ammo",
        1.0,
      )
      @types.spawn_particles(game, crate.x, 1.0, crate.z, 8, 255, 255, 100)
      crate.active = false
      crate.respawn_timer = 20.0
    }
  }
}
