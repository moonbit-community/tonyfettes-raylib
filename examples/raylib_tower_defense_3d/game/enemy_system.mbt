// Enemy spawning, movement, and special abilities

fn start_wave(game : @types.Game, wave : Int) -> Unit {
  let def = @levels.get_wave_def(wave)
  game.wave_enemy_kind = def.0
  game.enemies_to_spawn = def.1
  game.wave_hp_mult = def.2
  game.wave_speed_mult = def.3
  game.enemies_spawned = 0
  game.spawn_timer = 0.0
  game.enemies_killed_this_wave = 0
  game.wave_active = true
  // Show wave message
  let info = @levels.get_wave_info(wave)
  @types.set_notification(game, info.wave_message, 3.0)
  game.wave_message = info.wave_message
  game.wave_message_timer = 3.0
}

fn update_spawning(game : @types.Game, dt : Float) -> Unit {
  if game.enemies_spawned >= game.enemies_to_spawn {
    return
  }
  game.spawn_timer -= dt
  if game.spawn_timer <= 0.0 {
    spawn_enemy(game)
    // Swarm enemies spawn faster
    let interval : Float = if game.wave_enemy_kind == @types.enemy_swarm {
      @types.fast_spawn_interval
    } else {
      @types.spawn_interval
    }
    game.spawn_timer = interval
  }
}

fn spawn_enemy(game : @types.Game) -> Unit {
  let idx = @types.alloc_enemy(game)
  if idx < 0 {
    return
  }
  let kind = game.wave_enemy_kind
  let base_hp = @levels.enemy_base_hp(kind)
  let base_speed = @levels.enemy_base_speed(kind)
  let diff_hp = @types.difficulty_hp_mult(game.difficulty)
  let diff_speed = @types.difficulty_speed_mult(game.difficulty)
  let enemy = game.enemies[idx]
  enemy.active = true
  enemy.kind = kind
  enemy.hp = base_hp * game.wave_hp_mult * diff_hp
  enemy.max_hp = enemy.hp
  enemy.speed = base_speed * game.wave_speed_mult * diff_speed
  enemy.base_speed = enemy.speed
  enemy.armor = @types.enemy_armor_value(kind)
  enemy.path_index = 0
  enemy.path_progress = 0.0
  enemy.slow_timer = 0.0
  enemy.slow_factor = 1.0
  enemy.burn_timer = 0.0
  enemy.burn_dps = 0.0
  enemy.stun_timer = 0.0
  enemy.armor_break_timer = 0.0
  enemy.armor_break_factor = 1.0
  enemy.gold_value = @levels.enemy_gold_value(kind)
  enemy.score_value = @levels.enemy_score_value(kind)
  enemy.flying = @levels.enemy_is_flying(kind)
  enemy.is_boss = @levels.enemy_is_boss(kind)
  enemy.is_camo = @levels.enemy_is_camo(kind)
  enemy.spawn_children = @levels.enemy_spawns_children(kind)
  enemy.heal_timer = 0.0
  // Shield setup
  if @levels.enemy_has_shield(kind) {
    let shield_hp = @levels.enemy_shield_hp(kind, game.wave_hp_mult * diff_hp)
    enemy.shield_hp = shield_hp
    enemy.shield_max = shield_hp
    enemy.shield_regen_timer = 0.0
  } else {
    enemy.shield_hp = 0.0
    enemy.shield_max = 0.0
    enemy.shield_regen_timer = 0.0
  }
  // Start at first path node
  if game.path_count > 0 {
    enemy.x = game.path_nodes[0].x
    enemy.z = game.path_nodes[0].z
  }
  let fly_height : Float = 3.0
  let ground_height : Float = 0.5
  enemy.y = if enemy.flying { fly_height } else { ground_height }
  game.enemies_spawned += 1
}

// Spawn child enemies from splitters
fn spawn_splitter_children(game : @types.Game, parent : @types.Enemy) -> Unit {
  let child_count = @types.splitter_children
  for i = 0; i < child_count; i = i + 1 {
    let idx = @types.alloc_enemy(game)
    if idx < 0 {
      return
    }
    let child = game.enemies[idx]
    child.active = true
    child.kind = @types.enemy_swarm
    child.hp = parent.max_hp * @types.splitter_child_hp_pct
    child.max_hp = child.hp
    child.speed = parent.base_speed * 1.3
    child.base_speed = child.speed
    child.armor = 0.0
    child.path_index = parent.path_index
    child.path_progress = parent.path_progress
    child.slow_timer = 0.0
    child.slow_factor = 1.0
    child.burn_timer = 0.0
    child.burn_dps = 0.0
    child.stun_timer = 0.0
    child.armor_break_timer = 0.0
    child.armor_break_factor = 1.0
    child.gold_value = 3
    child.score_value = 5
    child.flying = false
    child.is_boss = false
    child.is_camo = false
    child.spawn_children = false
    child.heal_timer = 0.0
    child.shield_hp = 0.0
    child.shield_max = 0.0
    child.shield_regen_timer = 0.0
    // Offset position slightly
    let offset_x = @types.rand_rangef(game, -0.5, 0.5)
    let offset_z = @types.rand_rangef(game, -0.5, 0.5)
    child.x = parent.x + offset_x
    child.y = 0.5
    child.z = parent.z + offset_z
    ignore(i)
  }
}

fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  // Update all enemies
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue i + 1
    }
    // Update status effects
    update_enemy_status_effects(game, enemy, dt)
    // Update healer ability
    if enemy.kind == @types.enemy_healer {
      update_healer(game, i, dt)
    }
    // Update shield regeneration
    if enemy.shield_max > 0.0 {
      update_enemy_shield(enemy, dt)
    }
    // Stun check - stunned enemies don't move
    if enemy.stun_timer > 0.0 {
      continue i + 1
    }
    // Move along path
    let effective_speed : Float = enemy.speed * enemy.slow_factor
    let speed = effective_speed * dt
    move_enemy_along_path(game, i, speed)
    // Check if reached end
    if enemy.path_index >= game.path_count - 1 && enemy.path_progress >= 1.0 {
      enemy.active = false
      let lives_lost : Int = if enemy.is_boss { 5 } else { 1 }
      game.lives -= lives_lost
    }
  }
}

fn update_enemy_status_effects(
  game : @types.Game,
  enemy : @types.Enemy,
  dt : Float
) -> Unit {
  // Update slow
  if enemy.slow_timer > 0.0 {
    enemy.slow_timer -= dt
    if enemy.slow_timer <= 0.0 {
      enemy.slow_factor = 1.0
    }
  }
  // Update burn (DOT damage)
  if enemy.burn_timer > 0.0 {
    enemy.burn_timer -= dt
    let burn_dmg = enemy.burn_dps * dt
    enemy.hp -= burn_dmg
    // Spawn fire particles occasionally
    if @types.rand_range(game, 0, 10) < 2 {
      @types.spawn_fire_particles(game, enemy.x, enemy.y, enemy.z)
    }
    if enemy.burn_timer <= 0.0 {
      enemy.burn_dps = 0.0
    }
  }
  // Update stun
  if enemy.stun_timer > 0.0 {
    enemy.stun_timer -= dt
  }
  // Update armor break
  if enemy.armor_break_timer > 0.0 {
    enemy.armor_break_timer -= dt
    if enemy.armor_break_timer <= 0.0 {
      enemy.armor_break_factor = 1.0
    }
  }
  // Check death from burn
  if enemy.hp <= 0.0 && enemy.active {
    kill_enemy(game, enemy)
  }
}

fn update_enemy_shield(enemy : @types.Enemy, dt : Float) -> Unit {
  if enemy.shield_hp < enemy.shield_max {
    enemy.shield_regen_timer += dt
    if enemy.shield_regen_timer >= @types.shield_regen_delay {
      enemy.shield_hp += @types.shield_regen_rate * dt
      if enemy.shield_hp > enemy.shield_max {
        enemy.shield_hp = enemy.shield_max
      }
    }
  }
}

fn update_healer(game : @types.Game, healer_idx : Int, dt : Float) -> Unit {
  let healer = game.enemies[healer_idx]
  healer.heal_timer += dt
  if healer.heal_timer < @types.healer_heal_interval {
    return
  }
  healer.heal_timer = 0.0
  // Heal nearby allies
  for j = 0; j < game.enemies.length(); j = j + 1 {
    if j == healer_idx {
      continue j + 1
    }
    let other = game.enemies[j]
    if not(other.active) {
      continue j + 1
    }
    let dist = @types.distance2d(healer.x, healer.z, other.x, other.z)
    if dist <= @types.healer_range {
      let heal_amount = @types.healer_heal_rate
      other.hp += heal_amount
      if other.hp > other.max_hp {
        other.hp = other.max_hp
      }
      // Visual feedback
      @types.spawn_particles_typed(
        game, other.x, other.y + 0.5, other.z, 2, 50, 255, 50, @types.particle_normal,
      )
    }
  }
}

fn kill_enemy(game : @types.Game, enemy : @types.Enemy) -> Unit {
  enemy.active = false
  game.gold += enemy.gold_value
  game.score += enemy.score_value
  game.total_gold_earned += enemy.gold_value
  game.total_kills += 1
  game.enemies_killed_this_wave += 1
  // Spawn death particles
  @types.spawn_particles(game, enemy.x, enemy.y, enemy.z, 10, 255, 100, 50)
  @types.spawn_gold_particles(game, enemy.x, enemy.y + 0.5, enemy.z)
  // Splitter: spawn children
  if enemy.spawn_children {
    spawn_splitter_children(game, enemy)
  }
}

fn move_enemy_along_path(game : @types.Game, idx : Int, speed : Float) -> Unit {
  let enemy = game.enemies[idx]
  if enemy.path_index >= game.path_count - 1 {
    enemy.path_progress = 1.0
    return
  }
  let p0 = game.path_nodes[enemy.path_index]
  let next_idx = enemy.path_index + 1
  if next_idx >= game.path_count {
    return
  }
  let p1 = game.path_nodes[next_idx]
  let seg_dx = p1.x - p0.x
  let seg_dz = p1.z - p0.z
  let seg_len = @types.distance2d(p0.x, p0.z, p1.x, p1.z)
  if seg_len < 0.01 {
    enemy.path_index += 1
    enemy.path_progress = 0.0
    return
  }
  let progress_add = speed / seg_len
  enemy.path_progress += progress_add
  if enemy.path_progress >= 1.0 {
    enemy.path_index += 1
    enemy.path_progress = 0.0
    if enemy.path_index < game.path_count {
      enemy.x = game.path_nodes[enemy.path_index].x
      enemy.z = game.path_nodes[enemy.path_index].z
    }
  } else {
    enemy.x = p0.x + seg_dx * enemy.path_progress
    enemy.z = p0.z + seg_dz * enemy.path_progress
  }
  ignore(seg_len)
}

fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    let proj = game.projectiles[i]
    if not(proj.active) {
      continue i + 1
    }
    // Check if target still valid
    if proj.target_idx < 0 || not(game.enemies[proj.target_idx].active) {
      // Find nearest enemy as fallback
      let mut best = -1
      let mut best_dist : Float = 999.0
      for j = 0; j < game.enemies.length(); j = j + 1 {
        if not(game.enemies[j].active) {
          continue j + 1
        }
        let d = @types.distance3d(
          proj.x, proj.y, proj.z, game.enemies[j].x, game.enemies[j].y,
          game.enemies[j].z,
        )
        if d < best_dist {
          best_dist = d
          best = j
        }
      }
      if best < 0 {
        proj.active = false
        continue i + 1
      }
      proj.target_idx = best
    }
    let target = game.enemies[proj.target_idx]
    let dx = target.x - proj.x
    let dy = target.y - proj.y
    let dz = target.z - proj.z
    let dist = @types.distance3d(
      proj.x, proj.y, proj.z, target.x, target.y, target.z,
    )
    if dist < 0.5 {
      // Hit!
      apply_projectile_hit(game, i)
      proj.active = false
      continue i + 1
    }
    // Move towards target
    let move_dist = proj.speed * dt
    if dist > 0.01 {
      proj.x += dx / dist * move_dist
      proj.y += dy / dist * move_dist
      proj.z += dz / dist * move_dist
    }
    ignore(dy)
  }
}

fn apply_projectile_hit(game : @types.Game, proj_idx : Int) -> Unit {
  let proj = game.projectiles[proj_idx]
  // Determine tower kind for resistance calculation
  let tower_kind = proj.kind
  if proj.splash_radius > 0.0 {
    // Splash damage
    for i = 0; i < game.enemies.length(); i = i + 1 {
      let enemy = game.enemies[i]
      if not(enemy.active) {
        continue i + 1
      }
      let dist = @types.distance2d(proj.x, proj.z, enemy.x, enemy.z)
      if dist <= proj.splash_radius {
        let dmg_factor : Float = 1.0 - dist / proj.splash_radius
        let raw_damage = proj.damage * dmg_factor
        let actual_damage = @types.calc_damage(raw_damage, tower_kind, enemy)
        damage_enemy(game, i, actual_damage, proj.tower_idx)
        // Apply splash status effects
        apply_projectile_effects(game, proj, i)
      }
    }
    @types.spawn_explosion_particles(game, proj.x, proj.y, proj.z, 12)
  } else if proj.chain_count > 0 {
    // Chain lightning
    apply_chain_lightning(game, proj)
  } else {
    // Single target
    if proj.target_idx >= 0 && game.enemies[proj.target_idx].active {
      let enemy = game.enemies[proj.target_idx]
      let raw_damage : Float = if proj.is_crit {
        proj.damage * @types.sniper_crit_mult
      } else {
        proj.damage
      }
      let actual_damage = @types.calc_damage(raw_damage, tower_kind, enemy)
      damage_enemy(game, proj.target_idx, actual_damage, proj.tower_idx)
      // Apply status effects
      apply_projectile_effects(game, proj, proj.target_idx)
      // Crit visual
      if proj.is_crit {
        @types.spawn_particles(
          game, enemy.x, enemy.y + 1.0, enemy.z, 8, 255, 50, 50,
        )
      }
    }
  }
}

fn apply_projectile_effects(
  game : @types.Game,
  proj : @types.Projectile,
  enemy_idx : Int
) -> Unit {
  let enemy = game.enemies[enemy_idx]
  // Slow effect
  if proj.slow_amount > 0.0 {
    // Boss enemies are more resistant to slow
    let slow_effectiveness : Float = if enemy.is_boss { 0.5 } else { 1.0 }
    let slow_amt = proj.slow_amount * slow_effectiveness
    enemy.slow_factor = 1.0 - slow_amt
    enemy.slow_timer = proj.slow_duration
    @types.spawn_ice_particles(game, enemy.x, enemy.y, enemy.z)
  }
  // Burn effect
  if proj.burn_damage > 0.0 {
    enemy.burn_dps = proj.burn_damage
    enemy.burn_timer = proj.burn_duration
    @types.spawn_fire_particles(game, enemy.x, enemy.y, enemy.z)
  }
  // Stun effect
  if proj.stun_chance > 0.0 {
    if @types.rand_bool(game, proj.stun_chance) {
      // Bosses can't be stunned
      if not(enemy.is_boss) {
        enemy.stun_timer = proj.stun_duration
        @types.spawn_particles(
          game, enemy.x, enemy.y + 1.0, enemy.z, 5, 255, 255, 0,
        )
      }
    }
  }
  ignore(game)
}

fn apply_chain_lightning(game : @types.Game, proj : @types.Projectile) -> Unit {
  let mut current_target = proj.target_idx
  let mut current_damage = proj.damage
  let chains = proj.chain_count
  let mut prev_x = proj.x
  let mut prev_y = proj.y
  let mut prev_z = proj.z
  // Hit initial target
  if current_target >= 0 && game.enemies[current_target].active {
    let enemy = game.enemies[current_target]
    let actual_damage = @types.calc_damage(
      current_damage, @types.tower_lightning, enemy,
    )
    damage_enemy(game, current_target, actual_damage, proj.tower_idx)
    @types.spawn_lightning_particles(game, enemy.x, enemy.y, enemy.z)
    // Add chain line visual
    @types.add_chain_line(game, prev_x, prev_y, prev_z, enemy.x, enemy.y, enemy.z)
    prev_x = enemy.x
    prev_y = enemy.y
    prev_z = enemy.z
  }
  // Chain to nearby enemies
  let visited = Array::make(game.enemies.length(), false)
  if current_target >= 0 {
    visited[current_target] = true
  }
  for c = 0; c < chains; c = c + 1 {
    current_damage = current_damage * @types.chain_damage_decay
    // Find nearest unvisited enemy within chain range
    let mut best = -1
    let mut best_dist : Float = @types.chain_range + 1.0
    for j = 0; j < game.enemies.length(); j = j + 1 {
      if not(game.enemies[j].active) {
        continue j + 1
      }
      if visited[j] {
        continue j + 1
      }
      let dist = @types.distance2d(
        prev_x, prev_z, game.enemies[j].x, game.enemies[j].z,
      )
      if dist <= @types.chain_range && dist < best_dist {
        best_dist = dist
        best = j
      }
    }
    if best < 0 {
      // No more targets to chain to
      ignore(c)
      return
    }
    visited[best] = true
    let enemy = game.enemies[best]
    let actual_damage = @types.calc_damage(
      current_damage, @types.tower_lightning, enemy,
    )
    damage_enemy(game, best, actual_damage, proj.tower_idx)
    @types.spawn_lightning_particles(game, enemy.x, enemy.y, enemy.z)
    @types.add_chain_line(game, prev_x, prev_y, prev_z, enemy.x, enemy.y, enemy.z)
    prev_x = enemy.x
    prev_y = enemy.y
    prev_z = enemy.z
    current_target = best
    ignore(c)
  }
}

fn damage_enemy(
  game : @types.Game,
  idx : Int,
  damage : Float,
  tower_idx : Int
) -> Unit {
  let enemy = game.enemies[idx]
  // Apply damage to shield first
  let mut remaining_damage = damage
  if enemy.shield_hp > 0.0 {
    if remaining_damage <= enemy.shield_hp {
      enemy.shield_hp -= remaining_damage
      enemy.shield_regen_timer = 0.0
      // Shield absorbed all damage
      @types.spawn_particles(
        game, enemy.x, enemy.y + 0.3, enemy.z, 3, 100, 150, 255,
      )
      // Track damage on tower
      if tower_idx >= 0 && tower_idx < game.towers.length() && game.towers[tower_idx].active {
        game.towers[tower_idx].total_damage += damage
        game.damage_dealt += damage
      }
      return
    }
    remaining_damage -= enemy.shield_hp
    enemy.shield_hp = 0.0
    enemy.shield_regen_timer = 0.0
  }
  enemy.hp -= remaining_damage
  // Track damage on tower
  if tower_idx >= 0 && tower_idx < game.towers.length() && game.towers[tower_idx].active {
    game.towers[tower_idx].total_damage += damage
    game.damage_dealt += damage
  }
  if enemy.hp <= 0.0 {
    // Track kill on tower
    if tower_idx >= 0 && tower_idx < game.towers.length() && game.towers[tower_idx].active {
      game.towers[tower_idx].kills += 1
    }
    kill_enemy(game, enemy)
  }
}
