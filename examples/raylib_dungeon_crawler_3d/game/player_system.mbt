// Player movement and combat

///|
pub fn update_player(game : @types.Game, dt : Float) -> Unit {
  // Mouse look
  let mouse_delta = @raylib.get_mouse_delta()
  let mouse_dx = mouse_delta.x
  let mouse_dy = mouse_delta.y
  game.camera_yaw -= mouse_dx * 0.003
  game.camera_pitch -= mouse_dy * 0.003
  // Clamp pitch
  game.camera_pitch = @types.clampf(game.camera_pitch, -1.2, 1.2)
  // Movement direction
  let forward_x = @math.sinf(game.camera_yaw)
  let forward_z = @math.cosf(game.camera_yaw)
  let right_x = @math.cosf(game.camera_yaw)
  let right_z = -@math.sinf(game.camera_yaw)
  let mut move_x : Float = 0.0
  let mut move_z : Float = 0.0
  if @raylib.is_key_down(@raylib.KeyW) {
    move_x += forward_x
    move_z += forward_z
  }
  if @raylib.is_key_down(@raylib.KeyS) {
    move_x -= forward_x
    move_z -= forward_z
  }
  if @raylib.is_key_down(@raylib.KeyA) {
    move_x -= right_x
    move_z -= right_z
  }
  if @raylib.is_key_down(@raylib.KeyD) {
    move_x += right_x
    move_z += right_z
  }
  // Sprint
  game.sprinting = @raylib.is_key_down(@raylib.KeyLeftShift)
  // Normalize movement
  let move_len = (move_x * move_x + move_z * move_z).sqrt()
  if move_len > 0.01 {
    move_x = move_x / move_len
    move_z = move_z / move_len
  }
  // Calculate speed with sprint and buffs
  let mut speed_mult : Float = 1.0
  if game.sprinting {
    speed_mult = @types.player_sprint_mult
  }
  // Check for speed buff
  if @types.has_buff(game, @types.buff_speed) {
    speed_mult *= 1.3
  }
  let speed = @types.player_speed * speed_mult * dt
  let new_x = game.player_x + move_x * speed
  let new_z = game.player_z + move_z * speed
  // Collision detection - try X then Z separately for sliding
  let radius : Float = 0.3
  if not(@types.is_blocked(game, new_x, game.player_z, radius)) {
    game.player_x = new_x
  }
  if not(@types.is_blocked(game, game.player_x, new_z, radius)) {
    game.player_z = new_z
  }
  // Attack cooldown timer
  if game.attack_cooldown_timer > 0.0 {
    game.attack_cooldown_timer -= dt
    if game.attack_cooldown_timer < 0.0 {
      game.attack_cooldown_timer = 0.0
    }
  }
  // Sword swing animation
  if game.swing_timer > 0.0 {
    game.swing_timer -= dt
    if game.swing_timer <= 0.0 {
      game.swing_timer = 0.0
      game.swing_active = false
    }
  }
  // Weapon attack (LMB / Space)
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.attack_cooldown_timer <= 0.0 {
      if game.player_weapon == @types.weapon_bow {
        perform_bow_attack(game)
      } else {
        perform_melee_attack(game)
      }
      game.attack_cooldown_timer = @types.get_weapon_cooldown(
        game.player_weapon,
      )
      game.swing_active = true
      game.swing_timer = @types.swing_duration
    }
  }
  // Spell casting (RMB or Q)
  if @raylib.is_mouse_button_pressed(@raylib.MouseButtonRight) ||
    @raylib.is_key_pressed(@raylib.KeyQ) {
    cast_selected_spell(game)
  }
  // Spell cooldown
  if game.spell_cooldown > 0.0 {
    game.spell_cooldown -= dt
    if game.spell_cooldown < 0.0 {
      game.spell_cooldown = 0.0
    }
  }
  // Cycle weapon with Tab
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    game.player_weapon = (game.player_weapon + 1) % 6
    @types.add_message(
      game,
      "Weapon: \{@types.get_weapon_name(game.player_weapon)}",
      200,
      200,
      255,
    )
  }
  // Cycle spells with 1-6 keys
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    game.selected_spell = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    game.selected_spell = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    game.selected_spell = 2
  }
  if @raylib.is_key_pressed(@raylib.KeyFour) {
    game.selected_spell = 3
  }
  if @raylib.is_key_pressed(@raylib.KeyFive) {
    game.selected_spell = 4
  }
  if @raylib.is_key_pressed(@raylib.KeySix) {
    game.selected_spell = 5
  }
  // Mana regeneration
  let mana_regen : Float = @types.mana_regen_rate * dt
  let new_mana_f : Float = Float::from_int(game.player_mana) + mana_regen
  let new_mana = new_mana_f.to_int()
  game.player_mana = @types.mini(new_mana, game.player_max_mana)
  // Pickup loot
  check_loot_pickup(game)
  // Check stairs
  check_stairs(game)
  // Check chest interaction
  if @raylib.is_key_pressed(@raylib.KeyE) {
    check_chest_open(game)
    check_door_interact(game)
    check_shop_interact(game)
    check_shrine_interact(game)
  }
  // Check traps
  check_traps(game, dt)
  // Update buffs
  @types.update_buffs(game, dt)
  // Update messages
  @types.update_messages(game, dt)
  // Update explored tiles
  @types.update_explored(game)
  // Update poison
  if game.poison_remaining > 0.0 {
    game.poison_remaining -= dt
    game.poison_timer += dt
    if game.poison_timer >= 1.0 {
      game.poison_timer -= 1.0
      game.player_hp -= @types.poison_damage_per_sec
      @types.spawn_particles(
        game,
        game.player_x,
        1.0,
        game.player_z,
        3,
        100,
        200,
        50,
      )
    }
    if game.poison_remaining <= 0.0 {
      game.poison_remaining = 0.0
      game.poison_timer = 0.0
    }
  }
  // Update hit flash
  if game.player_hit_flash > 0.0 {
    game.player_hit_flash -= dt
    if game.player_hit_flash < 0.0 {
      game.player_hit_flash = 0.0
    }
  }
  // Update damage flash
  if game.damage_flash > 0.0 {
    game.damage_flash -= dt
    if game.damage_flash < 0.0 {
      game.damage_flash = 0.0
    }
  }
  // Check death
  if game.player_hp <= 0 {
    game.state = @types.state_game_over
    @raylib.enable_cursor()
  }
  // Check level up
  if game.player_xp >= game.player_xp_next {
    level_up(game)
  }
}

///|
fn perform_melee_attack(game : @types.Game) -> Unit {
  let attack_dir_x = @math.sinf(game.camera_yaw)
  let attack_dir_z = @math.cosf(game.camera_yaw)
  let weapon_range = @types.get_weapon_range(game.player_weapon)
  let mut hit_any = false
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    // Check distance
    let dist = @types.dist2d(game.player_x, game.player_z, e.x, e.z)
    if dist > weapon_range {
      continue
    }
    // Check angle (within ~90 degree cone in front)
    let dx = e.x - game.player_x
    let dz = e.z - game.player_z
    let dot = dx * attack_dir_x + dz * attack_dir_z
    if dot < 0.0 {
      continue
    }
    // Hit!
    let raw_atk = @types.calc_player_attack(game)
    let damage = @types.maxi(1, raw_atk - e.def)
    // Critical hit chance based on dex
    let crit_chance = game.player_dex / 2
    let is_crit = @types.rand_range(game, 0, 99) < crit_chance
    let final_damage = if is_crit { damage * 2 } else { damage }
    e.hp -= final_damage
    e.hit_flash = 0.2
    e.alerted = true
    hit_any = true
    // Spawn hit particles
    @types.spawn_particles(game, e.x, 1.0, e.z, 8, 255, 50, 50)
    if is_crit {
      @types.add_message(
        game,
        "CRITICAL HIT! \{final_damage} damage to \{@types.get_enemy_name(e.kind)}!",
        255,
        215,
        0,
      )
      @types.spawn_particles(game, e.x, 1.5, e.z, 6, 255, 215, 0)
    } else {
      @types.add_message(
        game,
        "Hit \{@types.get_enemy_name(e.kind)} for \{final_damage}!",
        255,
        200,
        80,
      )
    }
    if e.hp <= 0 {
      kill_enemy(game, i)
    }
  }
  if hit_any {
    let px = game.player_x + attack_dir_x * 1.5
    let pz = game.player_z + attack_dir_z * 1.5
    @types.spawn_particles(game, px, 1.2, pz, 4, 255, 255, 100)
  }
}

///|
fn perform_bow_attack(game : @types.Game) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = 0
  p.x = game.player_x
  p.z = game.player_z
  let dir_x = @math.sinf(game.camera_yaw)
  let dir_z = @math.cosf(game.camera_yaw)
  p.vx = dir_x * @types.projectile_speed * 1.5
  p.vz = dir_z * @types.projectile_speed * 1.5
  let raw_atk = @types.calc_player_attack(game)
  p.damage = raw_atk
  p.lifetime = @types.projectile_lifetime
  p.from_enemy = false
  p.aoe_radius = 0.0
  p.slow_on_hit = false
  @types.spawn_directional_particles(
    game,
    game.player_x,
    1.2,
    game.player_z,
    dir_x,
    dir_z,
    4,
    200,
    180,
    100,
    3.0,
  )
}

///|
fn cast_selected_spell(game : @types.Game) -> Unit {
  if game.selected_spell < 0 || game.selected_spell >= game.spells.length() {
    return
  }
  let slot = game.spells[game.selected_spell]
  if not(slot.active) {
    @types.add_message(game, "No spell in this slot!", 200, 100, 100)
    return
  }
  if game.spell_cooldown > 0.0 {
    return
  }
  let spell_type = slot.spell_type
  let cost = @types.get_spell_mana_cost(spell_type)
  if game.player_mana < cost {
    @types.add_message(game, "Not enough mana!", 100, 100, 255)
    return
  }
  game.player_mana -= cost
  game.spell_cooldown = 0.5
  if spell_type == @types.spell_fireball {
    cast_fireball(game)
  } else if spell_type == @types.spell_ice_bolt {
    cast_ice_bolt(game)
  } else if spell_type == @types.spell_heal {
    cast_heal(game)
  } else if spell_type == @types.spell_shield {
    cast_shield(game)
  } else if spell_type == @types.spell_lightning {
    cast_lightning(game)
  } else if spell_type == @types.spell_teleport {
    cast_teleport(game)
  }
}

///|
fn cast_fireball(game : @types.Game) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = @types.spell_fireball
  p.x = game.player_x
  p.z = game.player_z
  let dir_x = @math.sinf(game.camera_yaw)
  let dir_z = @math.cosf(game.camera_yaw)
  p.vx = dir_x * 10.0
  p.vz = dir_z * 10.0
  let int_bonus = game.player_int_stat / 2
  p.damage = @types.fireball_damage + int_bonus
  p.lifetime = 2.0
  p.from_enemy = false
  p.aoe_radius = @types.fireball_radius
  p.slow_on_hit = false
  @types.spawn_directional_particles(
    game,
    game.player_x,
    1.2,
    game.player_z,
    dir_x,
    dir_z,
    8,
    255,
    100,
    30,
    5.0,
  )
  @types.add_message(game, "Fireball!", 255, 100, 30)
}

///|
fn cast_ice_bolt(game : @types.Game) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let p = game.projectiles[idx]
  p.active = true
  p.kind = @types.spell_ice_bolt
  p.x = game.player_x
  p.z = game.player_z
  let dir_x = @math.sinf(game.camera_yaw)
  let dir_z = @math.cosf(game.camera_yaw)
  p.vx = dir_x * 12.0
  p.vz = dir_z * 12.0
  let int_bonus = game.player_int_stat / 3
  p.damage = @types.ice_bolt_damage + int_bonus
  p.lifetime = 2.5
  p.from_enemy = false
  p.aoe_radius = 0.0
  p.slow_on_hit = true
  @types.spawn_directional_particles(
    game,
    game.player_x,
    1.2,
    game.player_z,
    dir_x,
    dir_z,
    6,
    100,
    180,
    255,
    4.0,
  )
  @types.add_message(game, "Ice Bolt!", 100, 180, 255)
}

///|
fn cast_heal(game : @types.Game) -> Unit {
  let int_bonus = game.player_int_stat / 2
  let heal = @types.heal_amount + int_bonus
  game.player_hp = @types.mini(game.player_hp + heal, game.player_max_hp)
  @types.spawn_particles(
    game,
    game.player_x,
    1.0,
    game.player_z,
    16,
    50,
    255,
    80,
  )
  @types.add_message(game, "Healed for \{heal} HP!", 50, 255, 80)
}

///|
fn cast_shield(game : @types.Game) -> Unit {
  let int_bonus = game.player_int_stat / 4
  @types.add_buff(
    game,
    @types.buff_shield,
    @types.shield_duration,
    @types.shield_defense_bonus + int_bonus,
  )
  @types.spawn_particles(
    game,
    game.player_x,
    1.0,
    game.player_z,
    12,
    100,
    150,
    255,
  )
  @types.add_message(game, "Shield activated!", 100, 150, 255)
}

///|
fn cast_lightning(game : @types.Game) -> Unit {
  // Hit nearest enemy in front of player
  let attack_dir_x = @math.sinf(game.camera_yaw)
  let attack_dir_z = @math.cosf(game.camera_yaw)
  let int_bonus = game.player_int_stat / 2
  let damage = @types.lightning_damage + int_bonus
  let mut hit_idx = -1
  let mut best_dist : Float = 15.0
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    let dist = @types.dist2d(game.player_x, game.player_z, e.x, e.z)
    if dist > 12.0 {
      continue
    }
    let dx = e.x - game.player_x
    let dz = e.z - game.player_z
    let dot = dx * attack_dir_x + dz * attack_dir_z
    if dot > 0.0 && dist < best_dist {
      best_dist = dist
      hit_idx = i
    }
  }
  if hit_idx >= 0 {
    let e = game.enemies[hit_idx]
    let dmg = @types.maxi(1, damage - e.def)
    e.hp -= dmg
    e.hit_flash = 0.3
    e.alerted = true
    e.stun_timer = 0.5
    @types.spawn_particles(game, e.x, 1.5, e.z, 12, 255, 255, 100)
    @types.add_message(
      game,
      "Lightning hits \{@types.get_enemy_name(e.kind)} for \{dmg}!",
      255,
      255,
      100,
    )
    if e.hp <= 0 {
      kill_enemy(game, hit_idx)
    }
    // Chain to nearby enemies
    let chain_x = e.x
    let chain_z = e.z
    for j in 0..<game.enemies.length() {
      if j == hit_idx {
        continue
      }
      let e2 = game.enemies[j]
      if not(e2.active) {
        continue
      }
      let chain_dist = @types.dist2d(chain_x, chain_z, e2.x, e2.z)
      if chain_dist < @types.lightning_chain_range {
        let chain_dmg = @types.maxi(1, damage / 2 - e2.def)
        e2.hp -= chain_dmg
        e2.hit_flash = 0.3
        e2.alerted = true
        @types.spawn_particles(game, e2.x, 1.5, e2.z, 6, 255, 255, 100)
        if e2.hp <= 0 {
          kill_enemy(game, j)
        }
      }
    }
  } else {
    @types.add_message(game, "Lightning finds no target!", 200, 200, 100)
  }
}

///|
fn cast_teleport(game : @types.Game) -> Unit {
  // Teleport forward in facing direction
  let dir_x = @math.sinf(game.camera_yaw)
  let dir_z = @math.cosf(game.camera_yaw)
  let tp_dist : Float = 8.0
  let mut dest_x = game.player_x + dir_x * tp_dist
  let mut dest_z = game.player_z + dir_z * tp_dist
  let radius : Float = 0.3
  // Find furthest walkable position
  let mut found = false
  for step = 8; step >= 1; step = step - 1 {
    let test_x = game.player_x + dir_x * Float::from_int(step)
    let test_z = game.player_z + dir_z * Float::from_int(step)
    if not(@types.is_blocked(game, test_x, test_z, radius)) {
      dest_x = test_x
      dest_z = test_z
      found = true
      break
    }
    ignore(step)
  }
  if found {
    @types.spawn_particles(
      game,
      game.player_x,
      1.0,
      game.player_z,
      12,
      150,
      100,
      255,
    )
    game.player_x = dest_x
    game.player_z = dest_z
    @types.spawn_particles(
      game,
      game.player_x,
      1.0,
      game.player_z,
      12,
      150,
      100,
      255,
    )
    @types.add_message(game, "Teleported!", 150, 100, 255)
  } else {
    @types.add_message(game, "Cannot teleport there!", 200, 100, 100)
    // Refund mana
    game.player_mana = @types.mini(
      game.player_mana + @types.teleport_mana_cost,
      game.player_max_mana,
    )
  }
}

///|
pub fn kill_enemy(game : @types.Game, idx : Int) -> Unit {
  let e = game.enemies[idx]
  // Award XP
  game.player_xp += e.xp_value
  game.player_kills += 1
  game.total_enemies_killed += 1
  // Death particles
  @types.spawn_particles(game, e.x, 1.0, e.z, 16, 180, 80, 40)
  @types.add_message(
    game,
    "\{@types.get_enemy_name(e.kind)} defeated! +\{e.xp_value} XP",
    80,
    255,
    80,
  )
  // Drop loot (40% base + bonus for rarer enemies)
  let drop_chance = if e.kind == @types.enemy_dragon_boss {
    100
  } else if e.kind == @types.enemy_lich || e.kind == @types.enemy_minotaur {
    60
  } else if e.kind == @types.enemy_golem {
    50
  } else {
    40
  }
  if @types.rand_range(game, 0, 99) < drop_chance {
    let loot_idx = @types.alloc_loot(game)
    if loot_idx >= 0 {
      let l = game.loot[loot_idx]
      l.active = true
      // Better enemies drop better loot
      let roll = @types.rand_range(game, 0, 7)
      if roll == 0 {
        l.kind = @types.loot_health_potion
      } else if roll == 1 {
        l.kind = @types.loot_damage_boost
      } else if roll == 2 {
        l.kind = @types.loot_armor
      } else if roll == 3 {
        l.kind = @types.loot_mana_potion
      } else if roll == 4 {
        l.kind = @types.loot_gold_pile
        l.value = @types.rand_range(game, 5, 30)
      } else if roll == 5 {
        l.kind = @types.loot_speed_potion
      } else if roll == 6 {
        l.kind = @types.loot_strength_potion
      } else {
        l.kind = @types.loot_gold_pile
        l.value = @types.rand_range(game, 10, 40)
      }
      // Boss drops boss key
      if e.kind == @types.enemy_dragon_boss {
        l.kind = @types.loot_boss_key
      }
      l.x = e.x
      l.z = e.z
      l.bob_phase = @types.rand_rangef(game, 0.0, 6.28)
      // Higher rarity from stronger enemies
      let rarity_weights : Array[Int] = [
        @levels.get_rarity_weight_common(game.current_floor),
        @levels.get_rarity_weight_uncommon(game.current_floor),
        @levels.get_rarity_weight_rare(game.current_floor),
        @levels.get_rarity_weight_epic(game.current_floor),
        @levels.get_rarity_weight_legendary(game.current_floor),
      ]
      l.rarity = @types.rand_weighted(game, rarity_weights)
    }
  }
  // Gold always drops
  let gold_amount = @types.rand_range(game, 3, 15 + game.current_floor * 3)
  game.player_gold += gold_amount
  game.player_total_gold += gold_amount
  e.active = false
  game.floor_info[game.current_floor].enemies_killed += 1
}

///|
fn check_loot_pickup(game : @types.Game) -> Unit {
  for l in game.loot {
    if not(l.active) {
      continue
    }
    let dist = @types.dist2d(game.player_x, game.player_z, l.x, l.z)
    if dist < 1.2 {
      // Pick up
      if l.kind == @types.loot_health_potion {
        game.player_hp = @types.mini(
          game.player_hp + @types.health_potion_heal,
          game.player_max_hp,
        )
        @types.add_message(
          game,
          "+\{@types.health_potion_heal} HP",
          50,
          255,
          50,
        )
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 50, 255, 50)
      } else if l.kind == @types.loot_mana_potion {
        game.player_mana = @types.mini(
          game.player_mana + @types.mana_potion_restore,
          game.player_max_mana,
        )
        @types.add_message(
          game,
          "+\{@types.mana_potion_restore} Mana",
          80,
          100,
          255,
        )
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 80, 100, 255)
      } else if l.kind == @types.loot_damage_boost {
        game.player_atk += @types.damage_boost_amount
        @types.add_message(
          game,
          "+\{@types.damage_boost_amount} ATK",
          255,
          100,
          50,
        )
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 255, 100, 50)
      } else if l.kind == @types.loot_armor {
        game.player_def += @types.armor_boost_amount
        @types.add_message(
          game,
          "+\{@types.armor_boost_amount} DEF",
          100,
          100,
          255,
        )
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 100, 100, 255)
      } else if l.kind == @types.loot_speed_potion {
        @types.add_buff(
          game, @types.buff_speed, @types.speed_potion_duration, 1,
        )
        @types.add_message(game, "Speed boost!", 255, 255, 80)
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 255, 255, 80)
      } else if l.kind == @types.loot_strength_potion {
        @types.add_buff(
          game, @types.buff_strength, @types.strength_potion_duration, @types.strength_potion_bonus,
        )
        @types.add_message(game, "Strength boost!", 255, 80, 80)
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 255, 80, 80)
      } else if l.kind == @types.loot_gold_pile {
        let amount = if l.value > 0 {
          l.value
        } else {
          @types.rand_range(game, 10, 30)
        }
        game.player_gold += amount
        game.player_total_gold += amount
        @types.add_message(game, "+\{amount} Gold", 255, 215, 0)
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 255, 215, 0)
      } else if l.kind == @types.loot_key {
        game.player_keys += 1
        @types.add_message(game, "Got a Key!", 200, 200, 50)
        @types.spawn_particles(game, l.x, 0.5, l.z, 8, 200, 200, 50)
      } else if l.kind == @types.loot_boss_key {
        game.player_boss_keys += 1
        @types.add_message(game, "Got a Boss Key!", 255, 100, 100)
        @types.spawn_particles(game, l.x, 0.5, l.z, 10, 255, 100, 100)
      }
      l.active = false
      game.message_text = @types.get_loot_name(l.kind)
      game.message_timer = 2.0
    }
  }
}

///|
fn check_stairs(game : @types.Game) -> Unit {
  let stairs_wx = @types.grid_to_world_x(game.stairs_x)
  let stairs_wz = @types.grid_to_world_z(game.stairs_z)
  let dist = @types.dist2d(game.player_x, game.player_z, stairs_wx, stairs_wz)
  if dist < 1.5 {
    let alive = @types.count_active_enemies(game)
    if alive == 0 {
      game.floor_info[game.current_floor].cleared = true
      game.floors_cleared += 1
      if game.current_floor < @types.max_floors - 1 {
        game.state = @types.state_floor_complete
        @raylib.enable_cursor()
      } else {
        game.state = @types.state_floor_complete
        @raylib.enable_cursor()
      }
    } else {
      game.message_text = "Defeat all enemies to descend"
      game.message_timer = 1.0
    }
  }
}

///|
fn check_chest_open(game : @types.Game) -> Unit {
  let check_x = game.player_x + @math.sinf(game.camera_yaw) * 1.5
  let check_z = game.player_z + @math.cosf(game.camera_yaw) * 1.5
  let gx = @types.world_to_grid_x(check_x)
  let gz = @types.world_to_grid_z(check_z)
  if @types.get_tile(game, gx, gz) == @types.tile_chest {
    // Check for mimic
    for e in game.enemies {
      if e.active && e.kind == @types.enemy_mimic {
        let egx = @types.world_to_grid_x(e.x)
        let egz = @types.world_to_grid_z(e.z)
        if egx == gx && egz == gz {
          // It's a mimic!
          e.alerted = true
          e.ai_state = @types.ai_chase
          @types.set_tile(game, gx, gz, @types.tile_floor)
          @types.add_message(game, "MIMIC! It's alive!", 255, 50, 50)
          @types.spawn_particles(
            game,
            @types.grid_to_world_x(gx),
            0.5,
            @types.grid_to_world_z(gz),
            12,
            255,
            50,
            50,
          )
          return
        }
      }
    }
    @types.set_tile(game, gx, gz, @types.tile_floor)
    // Give random reward
    let roll = @types.rand_range(game, 0, 4)
    if roll == 0 {
      let heal = @types.health_potion_heal + 20
      game.player_hp = @types.mini(game.player_hp + heal, game.player_max_hp)
      game.message_text = "Chest: +\{heal} HP!"
      @types.add_message(game, "Chest: +\{heal} HP!", 50, 255, 50)
    } else if roll == 1 {
      let dmg = @types.damage_boost_amount + 2
      game.player_atk += dmg
      game.message_text = "Chest: +\{dmg} ATK!"
      @types.add_message(game, "Chest: +\{dmg} ATK!", 255, 100, 50)
    } else if roll == 2 {
      let armor = @types.armor_boost_amount + 2
      game.player_def += armor
      game.message_text = "Chest: +\{armor} DEF!"
      @types.add_message(game, "Chest: +\{armor} DEF!", 100, 100, 255)
    } else if roll == 3 {
      let gold = @types.rand_range(game, 20, 60)
      game.player_gold += gold
      game.player_total_gold += gold
      game.message_text = "Chest: +\{gold} Gold!"
      @types.add_message(game, "Chest: +\{gold} Gold!", 255, 215, 0)
    } else {
      // Spell scroll
      let spell_roll = @types.rand_range(game, 1, 6)
      let added = add_spell_to_player(game, spell_roll)
      if added {
        game.message_text = "Chest: \{@types.get_spell_name(spell_roll)} spell!"
        @types.add_message(
          game,
          "Learned \{@types.get_spell_name(spell_roll)}!",
          200,
          100,
          255,
        )
      } else {
        let gold = @types.rand_range(game, 30, 50)
        game.player_gold += gold
        game.player_total_gold += gold
        game.message_text = "Chest: +\{gold} Gold!"
        @types.add_message(game, "+\{gold} Gold!", 255, 215, 0)
      }
    }
    game.message_timer = 2.5
    let wx = @types.grid_to_world_x(gx)
    let wz = @types.grid_to_world_z(gz)
    @types.spawn_particles(game, wx, 0.5, wz, 16, 255, 215, 0)
  }
}

///|
fn check_door_interact(game : @types.Game) -> Unit {
  let check_x = game.player_x + @math.sinf(game.camera_yaw) * 1.5
  let check_z = game.player_z + @math.cosf(game.camera_yaw) * 1.5
  let gx = @types.world_to_grid_x(check_x)
  let gz = @types.world_to_grid_z(check_z)
  let tile = @types.get_tile(game, gx, gz)
  if tile == @types.tile_locked_door {
    if game.player_keys > 0 {
      game.player_keys -= 1
      @types.set_tile(game, gx, gz, @types.tile_floor)
      @types.add_message(game, "Door unlocked!", 200, 200, 50)
      @types.spawn_particles(
        game,
        @types.grid_to_world_x(gx),
        1.5,
        @types.grid_to_world_z(gz),
        8,
        200,
        200,
        50,
      )
    } else {
      @types.add_message(game, "Need a key!", 200, 100, 100)
    }
  } else if tile == @types.tile_boss_door {
    if game.player_boss_keys > 0 {
      game.player_boss_keys -= 1
      @types.set_tile(game, gx, gz, @types.tile_floor)
      @types.add_message(game, "Boss door unlocked!", 255, 100, 100)
    } else {
      @types.add_message(game, "Need a Boss Key!", 255, 80, 80)
    }
  }
}

///|
fn check_shop_interact(game : @types.Game) -> Unit {
  let check_x = game.player_x + @math.sinf(game.camera_yaw) * 1.5
  let check_z = game.player_z + @math.cosf(game.camera_yaw) * 1.5
  let gx = @types.world_to_grid_x(check_x)
  let gz = @types.world_to_grid_z(check_z)
  if @types.get_tile(game, gx, gz) == @types.tile_shop {
    game.prev_state = game.state
    game.state = @types.state_shop
    game.shop_cursor = 0
    @raylib.enable_cursor()
  }
}

///|
fn check_shrine_interact(game : @types.Game) -> Unit {
  let check_x = game.player_x + @math.sinf(game.camera_yaw) * 1.5
  let check_z = game.player_z + @math.cosf(game.camera_yaw) * 1.5
  let gx = @types.world_to_grid_x(check_x)
  let gz = @types.world_to_grid_z(check_z)
  if @types.get_tile(game, gx, gz) == @types.tile_shrine {
    if game.shrine_used {
      @types.add_message(game, "Shrine already used.", 150, 150, 150)
    } else {
      game.prev_state = game.state
      game.state = @types.state_shrine
      game.shrine_cursor = 0
      @raylib.enable_cursor()
    }
  }
}

///|
fn check_traps(game : @types.Game, dt : Float) -> Unit {
  let pgx = @types.world_to_grid_x(game.player_x)
  let pgz = @types.world_to_grid_z(game.player_z)
  for trap in game.traps {
    if not(trap.active) {
      continue
    }
    // Update cooldown
    if trap.cooldown > 0.0 {
      trap.cooldown -= dt
      if trap.cooldown < 0.0 {
        trap.cooldown = 0.0
        trap.armed = true
      }
    }
    // Check if player is on trap
    if pgx == trap.gx && pgz == trap.gz && trap.armed {
      trap.armed = false
      trap.cooldown = @types.trap_cooldown
      trap.triggered = true
      trap.visible = true
      let wx = @types.grid_to_world_x(trap.gx)
      let wz = @types.grid_to_world_z(trap.gz)
      if trap.kind == @types.trap_spike {
        damage_player(game, @types.spike_damage)
        @types.add_message(game, "Stepped on spikes!", 255, 80, 80)
        @types.spawn_particles(game, wx, 0.3, wz, 8, 200, 50, 50)
      } else if trap.kind == @types.trap_arrow {
        damage_player(game, @types.arrow_trap_damage)
        @types.add_message(game, "Arrow trap!", 255, 100, 50)
        @types.spawn_particles(game, wx, 1.0, wz, 6, 200, 150, 50)
      } else if trap.kind == @types.trap_flame {
        damage_player(game, @types.flame_damage)
        @types.add_message(game, "Flame trap!", 255, 100, 30)
        @types.spawn_particles(game, wx, 1.0, wz, 12, 255, 100, 30)
      } else if trap.kind == @types.trap_poison {
        game.poison_remaining = @types.poison_duration
        game.poison_timer = 0.0
        @types.add_message(game, "Poison gas!", 100, 200, 50)
        @types.spawn_particles(game, wx, 0.5, wz, 10, 100, 200, 50)
      } else if trap.kind == @types.trap_pitfall {
        damage_player(game, @types.pitfall_damage)
        @types.add_message(game, "Pitfall trap!", 200, 100, 50)
        @types.spawn_particles(game, wx, 0.1, wz, 8, 150, 100, 50)
      }
    }
    // Nearby traps become visible (perception)
    if not(trap.visible) {
      let trap_dist_sq = @types.dist2d_sq(
        game.player_x,
        game.player_z,
        @types.grid_to_world_x(trap.gx),
        @types.grid_to_world_z(trap.gz),
      )
      let perception : Float = Float::from_int(game.player_dex) * 0.5
      if trap_dist_sq < perception * perception {
        trap.visible = true
        @types.add_message(game, "Trap spotted!", 255, 200, 80)
      }
    }
  }
}

///|
fn add_spell_to_player(game : @types.Game, spell_type : Int) -> Bool {
  // Check if already have this spell
  for spell in game.spells {
    if spell.active && spell.spell_type == spell_type {
      return false
    }
  }
  // Find empty slot
  for spell in game.spells {
    if not(spell.active) {
      spell.active = true
      spell.spell_type = spell_type
      return true
    }
  }
  false
}

///|
fn level_up(game : @types.Game) -> Unit {
  game.player_xp -= game.player_xp_next
  game.player_level += 1
  game.player_xp_next = @levels.get_xp_for_level(game.player_level)
  game.player_max_hp += @types.hp_per_level
  game.player_max_mana += @types.mana_per_level
  game.player_hp = game.player_max_hp // Full heal on level up
  game.player_mana = game.player_max_mana // Full mana restore
  game.player_atk += @types.atk_per_level
  game.player_def += @types.def_per_level
  // Stat bonuses based on class
  if game.player_class == @types.class_warrior {
    game.player_str += 2
    game.player_max_hp += 5
    game.player_hp += 5
  } else if game.player_class == @types.class_rogue {
    game.player_dex += 2
    game.player_atk += 1
  } else if game.player_class == @types.class_mage {
    game.player_int_stat += 2
    game.player_max_mana += 5
    game.player_mana += 5
  }
  game.level_up_timer = 3.0
  game.message_text = "LEVEL UP! Lv.\{game.player_level}"
  game.message_timer = 3.0
  @types.add_message(
    game,
    "Level Up! Lv.\{game.player_level} | HP:\{game.player_max_hp} ATK:\{game.player_atk} DEF:\{game.player_def}",
    255,
    215,
    0,
  )
  @types.spawn_particles(
    game,
    game.player_x,
    1.0,
    game.player_z,
    24,
    255,
    255,
    50,
  )
}

///|
pub fn damage_player(game : @types.Game, raw_damage : Int) -> Unit {
  let total_def = @types.calc_player_defense(game)
  let damage = @types.maxi(1, raw_damage - total_def)
  game.player_hp -= damage
  game.player_hit_flash = 0.3
  game.damage_flash = 0.2
  if game.player_hp < 0 {
    game.player_hp = 0
  }
}
