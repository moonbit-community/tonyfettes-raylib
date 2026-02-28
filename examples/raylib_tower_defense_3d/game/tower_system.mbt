// Tower targeting, firing, upgrading, selling, and special abilities

///|
fn update_towers(game : @types.Game, dt : Float) -> Unit {
  // First, reset buff bonuses on all towers
  for i = 0; i < game.towers.length(); i = i + 1 {
    let tower = game.towers[i]
    if not(tower.active) {
      continue i + 1
    }
    tower.buff_damage = 0.0
    tower.buff_range = 0.0
    tower.buff_rate = 0.0
  }
  // Apply buff tower bonuses
  for i = 0; i < game.towers.length(); i = i + 1 {
    let tower = game.towers[i]
    if not(tower.active) {
      continue i + 1
    }
    if tower.kind == @types.tower_buff {
      apply_buff_tower(game, i)
    }
  }
  // Update all towers
  for i = 0; i < game.towers.length(); i = i + 1 {
    let tower = game.towers[i]
    if not(tower.active) {
      continue i + 1
    }
    // Update reload timer
    tower.reload_timer -= dt
    if tower.reload_timer <= 0.0 {
      tower.reload_timer = 0.0
    }
    // Update special ability timer
    if tower.special_timer > 0.0 {
      tower.special_timer -= dt
      if tower.special_timer <= 0.0 {
        tower.special_timer = 0.0
        tower.special_active = false
      }
    }
    // Buff towers don't attack
    if tower.kind == @types.tower_buff {
      // Level 3 buff towers have a pulse ability
      if tower.level >= 3 {
        update_buff_pulse(game, i, dt)
      }
      continue i + 1
    }
    // Find target
    let tx = @types.grid_to_world_x(tower.gx)
    let tz = @types.grid_to_world_z(tower.gy)
    let range = @types.tower_effective_range(tower)
    let can_see_camo = @types.tower_can_detect_camo(tower.kind)
    let best_idx = @types.find_target(
      game,
      tx,
      tz,
      range,
      tower.targeting_mode,
      can_see_camo,
    )
    tower.target_idx = best_idx
    // Rotate towards target
    if best_idx >= 0 {
      let enemy = game.enemies[best_idx]
      let dx = enemy.x - tx
      let dz = enemy.z - tz
      tower.angle = @math.atan2f(dx, dz) * 180.0 / @types.pi
    }
    // Fire if ready
    if tower.reload_timer <= 0.0 && best_idx >= 0 {
      fire_tower(game, i)
      let fire_rate = @types.tower_effective_rate(tower)
      tower.reload_timer = fire_rate
      // Level 3 arrow tower: double shot
      if tower.kind == @types.tower_arrow && tower.level >= 3 {
        // Fire a second projectile after a small delay (simulated by immediate fire)
        fire_tower_secondary(game, i)
      }
    }
    // Level 3 flame tower: fire aura (damages nearby enemies passively)
    if tower.kind == @types.tower_flame && tower.level >= 3 {
      update_flame_aura(game, i, dt)
    }
  }
}

///|
fn apply_buff_tower(game : @types.Game, buff_idx : Int) -> Unit {
  let buff = game.towers[buff_idx]
  let bx = @types.grid_to_world_x(buff.gx)
  let bz = @types.grid_to_world_z(buff.gy)
  let range = @types.tower_effective_range(buff)
  let dmg_bonus : Float = @types.buff_damage_bonus *
    (1.0 + Float::from_int(buff.level - 1) * 0.3)
  let rng_bonus : Float = @types.buff_range_bonus *
    (1.0 + Float::from_int(buff.level - 1) * 0.2)
  let rate_bonus : Float = @types.buff_rate_bonus *
    (1.0 + Float::from_int(buff.level - 1) * 0.15)
  for i = 0; i < game.towers.length(); i = i + 1 {
    if i == buff_idx {
      continue i + 1
    }
    let other = game.towers[i]
    if not(other.active) {
      continue i + 1
    }
    if other.kind == @types.tower_buff {
      continue i + 1
    }
    let ox = @types.grid_to_world_x(other.gx)
    let oz = @types.grid_to_world_z(other.gy)
    let dist = @types.distance2d(bx, bz, ox, oz)
    if dist <= range {
      // Apply buff (don't stack, take max)
      other.buff_damage = @types.maxf(other.buff_damage, dmg_bonus)
      other.buff_range = @types.maxf(other.buff_range, rng_bonus)
      other.buff_rate = @types.maxf(other.buff_rate, rate_bonus)
    }
  }
}

///|
fn update_buff_pulse(game : @types.Game, buff_idx : Int, dt : Float) -> Unit {
  let buff = game.towers[buff_idx]
  buff.special_timer -= dt
  if buff.special_timer <= 0.0 {
    buff.special_timer = @types.ability_buff_pulse_cd
    // Damage all enemies in range
    let bx = @types.grid_to_world_x(buff.gx)
    let bz = @types.grid_to_world_z(buff.gy)
    let range = @types.tower_effective_range(buff)
    for i = 0; i < game.enemies.length(); i = i + 1 {
      let enemy = game.enemies[i]
      if not(enemy.active) {
        continue i + 1
      }
      let dist = @types.distance2d(bx, bz, enemy.x, enemy.z)
      if dist <= range {
        let dmg : Float = 10.0 * Float::from_int(buff.level)
        damage_enemy(game, i, dmg, buff_idx)
      }
    }
    @types.spawn_particles(game, bx, 1.0, bz, 15, 200, 150, 255)
    buff.special_active = true
  }
}

///|
fn update_flame_aura(game : @types.Game, tower_idx : Int, dt : Float) -> Unit {
  let tower = game.towers[tower_idx]
  tower.special_timer -= dt
  if tower.special_timer <= 0.0 {
    tower.special_timer = @types.ability_flame_aura_cd
    let tx = @types.grid_to_world_x(tower.gx)
    let tz = @types.grid_to_world_z(tower.gy)
    let aura_range : Float = @types.tower_effective_range(tower) * 0.6
    for i = 0; i < game.enemies.length(); i = i + 1 {
      let enemy = game.enemies[i]
      if not(enemy.active) {
        continue i + 1
      }
      let dist = @types.distance2d(tx, tz, enemy.x, enemy.z)
      if dist <= aura_range {
        // Apply burn
        enemy.burn_dps = @types.burn_dps * 1.5
        enemy.burn_timer = @types.burn_duration
      }
    }
    @types.spawn_fire_particles(game, tx, 1.5, tz)
    tower.special_active = true
  }
}

///|
fn fire_tower(game : @types.Game, tower_idx : Int) -> Unit {
  let tower = game.towers[tower_idx]
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let tx = @types.grid_to_world_x(tower.gx)
  let tz = @types.grid_to_world_z(tower.gy)
  let proj = game.projectiles[idx]
  proj.active = true
  proj.kind = tower.kind
  proj.x = tx
  proj.y = 1.5
  proj.z = tz
  proj.target_idx = tower.target_idx
  proj.tower_idx = tower_idx
  proj.damage = @types.tower_effective_damage(tower)
  proj.speed = @types.projectile_speed_for(tower.kind)
  proj.splash_radius = @types.splash_radius_for(tower.kind)
  // Level 3 cannon: bigger splash
  if tower.kind == @types.tower_cannon && tower.level >= 3 {
    proj.splash_radius = @types.splash_radius_cannon * 1.5
  }
  // Frost tower: slow effect
  proj.slow_amount = if tower.kind == @types.tower_frost {
    @types.slow_strength
  } else {
    0.0
  }
  proj.slow_duration = if tower.kind == @types.tower_frost {
    @types.slow_duration
  } else {
    0.0
  }
  // Level 3 frost: stun chance
  if tower.kind == @types.tower_frost && tower.level >= 3 {
    proj.stun_chance = 0.2
    proj.stun_duration = @types.stun_duration
  } else {
    proj.stun_chance = 0.0
    proj.stun_duration = 0.0
  }
  // Flame tower: burn effect
  proj.burn_damage = if tower.kind == @types.tower_flame {
    @types.burn_dps
  } else {
    0.0
  }
  proj.burn_duration = if tower.kind == @types.tower_flame {
    @types.burn_duration
  } else {
    0.0
  }
  // Lightning tower: chain
  if tower.kind == @types.tower_lightning {
    let chains : Int = if tower.level >= 3 {
      @types.chain_count + 2
    } else {
      @types.chain_count
    }
    proj.chain_count = chains
    proj.chain_range = @types.chain_range
  } else {
    proj.chain_count = 0
    proj.chain_range = 0.0
  }
  // Sniper tower: crit
  proj.is_crit = if tower.kind == @types.tower_sniper {
    @types.rand_bool(game, @types.sniper_crit_chance)
  } else {
    false
  }
  // Level 3 sniper: armor break on hit
  // (Applied in apply_projectile_effects via a check)
  // Splash tower: stun chance at level 3
  if tower.kind == @types.tower_splash && tower.level >= 3 {
    proj.stun_chance = 0.15
    proj.stun_duration = @types.stun_duration * 0.5
  }
}

// Secondary shot for level 3 arrow tower

///|
fn fire_tower_secondary(game : @types.Game, tower_idx : Int) -> Unit {
  let tower = game.towers[tower_idx]
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let tx = @types.grid_to_world_x(tower.gx)
  let tz = @types.grid_to_world_z(tower.gy)
  let proj = game.projectiles[idx]
  proj.active = true
  proj.kind = tower.kind
  proj.x = tx + @types.rand_rangef(game, -0.2, 0.2)
  proj.y = 1.5
  proj.z = tz + @types.rand_rangef(game, -0.2, 0.2)
  proj.target_idx = tower.target_idx
  proj.tower_idx = tower_idx
  proj.damage = @types.tower_effective_damage(tower) * 0.6
  proj.speed = @types.projectile_speed_for(tower.kind) * 1.1
  proj.splash_radius = 0.0
  proj.slow_amount = 0.0
  proj.slow_duration = 0.0
  proj.burn_damage = 0.0
  proj.burn_duration = 0.0
  proj.stun_chance = 0.0
  proj.stun_duration = 0.0
  proj.chain_count = 0
  proj.chain_range = 0.0
  proj.is_crit = false
}

///|
fn try_place_tower(game : @types.Game) -> Unit {
  if not(game.hover_valid) {
    return
  }
  let cost = @types.tower_cost(game.selected_tower_type)
  if game.gold < cost {
    @types.set_notification(game, "Not enough gold!", 1.5)
    return
  }
  let idx = @types.alloc_tower(game)
  if idx < 0 {
    @types.set_notification(game, "Max towers reached!", 1.5)
    return
  }
  game.towers[idx] = @types.Tower::new(
    game.selected_tower_type,
    game.hover_gx,
    game.hover_gy,
  )
  game.gold -= cost
  game.total_gold_spent += cost
  game.towers_built += 1
  @types.spawn_build_particles(
    game,
    @types.grid_to_world_x(game.hover_gx),
    0.5,
    @types.grid_to_world_z(game.hover_gy),
  )
  @types.set_notification(
    game,
    @types.tower_name(game.selected_tower_type) + " tower built!",
    1.5,
  )
}

///|
fn try_upgrade_tower(game : @types.Game) -> Unit {
  if game.selected_tower_idx < 0 {
    return
  }
  let tower = game.towers[game.selected_tower_idx]
  if not(tower.active) {
    return
  }
  if tower.level >= 3 {
    @types.set_notification(game, "Already max level!", 1.5)
    return
  }
  let cost = @types.tower_upgrade_cost(tower.kind, tower.level)
  if game.gold < cost {
    @types.set_notification(game, "Not enough gold!", 1.5)
    return
  }
  game.gold -= cost
  game.total_gold_spent += cost
  tower.level += 1
  tower.sell_value = @types.tower_sell_value(tower.kind, tower.level)
  let wx = @types.grid_to_world_x(tower.gx)
  let wz = @types.grid_to_world_z(tower.gy)
  @types.spawn_particles(game, wx, 1.0, wz, 12, 100, 200, 255)
  @types.set_notification(
    game,
    @types.tower_name(tower.kind) + " upgraded to level \{tower.level}!",
    2.0,
  )
}

///|
fn try_sell_tower(game : @types.Game) -> Unit {
  if game.selected_tower_idx < 0 {
    return
  }
  let tower = game.towers[game.selected_tower_idx]
  if not(tower.active) {
    return
  }
  let sell_val = @types.tower_sell_value(tower.kind, tower.level)
  game.gold += sell_val
  game.total_gold_earned += sell_val
  game.towers_sold += 1
  let wx = @types.grid_to_world_x(tower.gx)
  let wz = @types.grid_to_world_z(tower.gy)
  @types.spawn_particles(game, wx, 1.0, wz, 8, 255, 215, 0)
  @types.set_notification(game, "Tower sold for \{sell_val}g", 1.5)
  tower.active = false
  game.selected_tower_idx = -1
}

///|
fn cycle_targeting_mode(game : @types.Game) -> Unit {
  if game.selected_tower_idx < 0 {
    return
  }
  let tower = game.towers[game.selected_tower_idx]
  if not(tower.active) {
    return
  }
  tower.targeting_mode = (tower.targeting_mode + 1) % @types.target_mode_count
  @types.set_notification(
    game,
    "Target: " + @types.targeting_mode_name(tower.targeting_mode),
    1.0,
  )
}
