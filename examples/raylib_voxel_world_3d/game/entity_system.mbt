// Entity system: advanced AI, pathfinding, mob spawning, mob interactions

// ========== Animal AI: random wandering ==========

// Get a random wander target near the entity's current position

///|
pub fn pick_wander_target(game : @types.Game, ent : @types.Entity) -> Unit {
  let range : Float = 12.0
  let half_range = range * 0.5
  let offset_x = @types.rand_float(game) * range - half_range
  let offset_z = @types.rand_float(game) * range - half_range
  ent.target_x = ent.x + offset_x
  ent.target_z = ent.z + offset_z
  // Clamp to world bounds
  let world_max_x = Float::from_int(@types.world_chunks_x * @types.chunk_x) -
    1.0
  let world_max_z = Float::from_int(@types.world_chunks_z * @types.chunk_z) -
    1.0
  ent.target_x = @types.clampf(ent.target_x, 1.0, world_max_x)
  ent.target_z = @types.clampf(ent.target_z, 1.0, world_max_z)
}

// ========== Flee behavior ==========

// Calculate flee direction away from player

///|
pub fn calculate_flee_target(game : @types.Game, ent : @types.Entity) -> Unit {
  let player = game.player
  let dx = ent.x - player.x
  let dz = ent.z - player.z
  let dist = (dx * dx + dz * dz).sqrt()
  if dist > 0.1 {
    let flee_dist : Float = 15.0
    ent.target_x = ent.x + dx / dist * flee_dist
    ent.target_z = ent.z + dz / dist * flee_dist
  } else {
    // Random direction if exactly on player
    let angle = @types.rand_float(game) * @types.two_pi
    let flee_dist : Float = 15.0
    ent.target_x = ent.x + @math.cosf(angle) * flee_dist
    ent.target_z = ent.z + @math.sinf(angle) * flee_dist
  }
  // Clamp to world bounds
  let world_max_x = Float::from_int(@types.world_chunks_x * @types.chunk_x) -
    1.0
  let world_max_z = Float::from_int(@types.world_chunks_z * @types.chunk_z) -
    1.0
  ent.target_x = @types.clampf(ent.target_x, 1.0, world_max_x)
  ent.target_z = @types.clampf(ent.target_z, 1.0, world_max_z)
}

// ========== Hostile mob chase with simple pathfinding ==========

// Simple pathfinding: try to move toward target, avoiding walls

///|
pub fn pathfind_toward_target(
  game : @types.Game,
  ent : @types.Entity,
  target_x : Float,
  target_z : Float,
) -> Unit {
  let dx = target_x - ent.x
  let dz = target_z - ent.z
  let dist = (dx * dx + dz * dz).sqrt()
  if dist < 0.5 {
    ent.vx = 0.0
    ent.vz = 0.0
    return
  }
  let speed : Float = if @types.is_hostile(ent.kind) {
    @types.entity_speed_hostile
  } else {
    @types.entity_speed_passive
  }
  // Desired direction
  let dir_x = dx / dist
  let dir_z = dz / dist
  // Check if direct path is blocked
  let check_x = ent.x + dir_x * 1.0
  let check_z = ent.z + dir_z * 1.0
  let block_ahead = @types.get_world_block(
    game,
    check_x.to_int(),
    ent.y.to_int(),
    check_z.to_int(),
  )
  if @types.is_solid(block_ahead) {
    // Try going around: check left and right
    let left_x = ent.x + dir_z * 1.0
    let left_z = ent.z - dir_x * 1.0
    let right_x = ent.x - dir_z * 1.0
    let right_z = ent.z + dir_x * 1.0
    let block_left = @types.get_world_block(
      game,
      left_x.to_int(),
      ent.y.to_int(),
      left_z.to_int(),
    )
    let block_right = @types.get_world_block(
      game,
      right_x.to_int(),
      ent.y.to_int(),
      right_z.to_int(),
    )
    if not(@types.is_solid(block_left)) {
      ent.vx = dir_z * speed
      ent.vz = -dir_x * speed
    } else if not(@types.is_solid(block_right)) {
      ent.vx = -dir_z * speed
      ent.vz = dir_x * speed
    } else {
      // Blocked on all sides, try jumping
      if ent.on_ground {
        ent.vy = 6.0
        ent.on_ground = false
      }
      ent.vx = dir_x * speed * 0.3
      ent.vz = dir_z * speed * 0.3
    }
  } else {
    // Direct path is clear
    ent.vx = dir_x * speed
    ent.vz = dir_z * speed
  }
  // Update yaw to face movement direction
  let move_dist = (ent.vx * ent.vx + ent.vz * ent.vz).sqrt()
  if move_dist > 0.1 {
    ent.yaw = @math.atan2f(ent.vx, ent.vz)
  }
}

// ========== Mob damage and death drops ==========

// Get item drops when a mob dies

///|
pub fn get_mob_drop_id(kind : Int) -> Int {
  if kind == @types.entity_pig {
    // Pigs drop food (represented as special healing)
    @types.block_brick // cooked porkchop placeholder
  } else if kind == @types.entity_cow {
    // Cows drop leather (represented as block)
    @types.block_dirt // leather placeholder
  } else if kind == @types.entity_chicken {
    // Chickens drop feathers
    @types.block_snow // feather placeholder
  } else if kind == @types.entity_zombie {
    // Zombies drop rotten flesh (not useful, but collectible)
    @types.block_clay
  } else if kind == @types.entity_skeleton {
    // Skeletons drop bones
    @types.block_gravel
  } else if kind == @types.entity_spider {
    // Spiders drop string
    @types.block_cobblestone
  } else {
    0
  }
}

// Get number of items dropped

///|
pub fn get_mob_drop_count(kind : Int) -> Int {
  if kind == @types.entity_pig {
    2
  } else if kind == @types.entity_cow {
    2
  } else if kind == @types.entity_chicken {
    1
  } else if kind == @types.entity_zombie {
    1
  } else if kind == @types.entity_skeleton {
    1
  } else if kind == @types.entity_spider {
    1
  } else {
    0
  }
}

// Process mob death: spawn particles, drop items, restore hunger

///|
pub fn handle_mob_death(game : @types.Game, ent : @types.Entity) -> Unit {
  // Spawn death particles
  let body_r : Int = if ent.kind == @types.entity_pig {
    230
  } else if ent.kind == @types.entity_cow {
    120
  } else if ent.kind == @types.entity_chicken {
    240
  } else if ent.kind == @types.entity_zombie {
    80
  } else if ent.kind == @types.entity_skeleton {
    220
  } else if ent.kind == @types.entity_spider {
    50
  } else {
    200
  }
  let body_g : Int = if ent.kind == @types.entity_pig {
    170
  } else if ent.kind == @types.entity_cow {
    80
  } else if ent.kind == @types.entity_chicken {
    240
  } else if ent.kind == @types.entity_zombie {
    120
  } else if ent.kind == @types.entity_skeleton {
    220
  } else if ent.kind == @types.entity_spider {
    40
  } else {
    200
  }
  let body_b : Int = if ent.kind == @types.entity_pig {
    160
  } else if ent.kind == @types.entity_cow {
    50
  } else if ent.kind == @types.entity_chicken {
    235
  } else if ent.kind == @types.entity_zombie {
    70
  } else if ent.kind == @types.entity_skeleton {
    210
  } else if ent.kind == @types.entity_spider {
    40
  } else {
    200
  }
  // Spawn particles at entity position
  for p = 0; p < 6; p = p + 1 {
    let angle = Float::from_int(p) * 1.047
    let speed : Float = 2.0 + Float::from_int(p % 3)
    let pvx = @math.cosf(angle) * speed
    let pvy : Float = 3.0 + Float::from_int(p % 2) * 2.0
    let pvz = @math.sinf(angle) * speed
    @types.spawn_particle(
      game,
      ent.x,
      ent.y + 0.5,
      ent.z,
      pvx,
      pvy,
      pvz,
      body_r,
      body_g,
      body_b,
      0.15,
      1.0,
    )
  }
  // Drop items into inventory
  let drop_id = get_mob_drop_id(ent.kind)
  let drop_count = get_mob_drop_count(ent.kind)
  if drop_id > 0 && drop_count > 0 {
    let leftover = game.player.inventory.add_item(drop_id, drop_count)
    ignore(leftover)
  }
  // Passive mobs restore hunger
  if not(@types.is_hostile(ent.kind)) {
    let hunger_restore : Int = if ent.kind == @types.entity_pig {
      4
    } else if ent.kind == @types.entity_cow {
      5
    } else if ent.kind == @types.entity_chicken {
      2
    } else {
      1
    }
    game.player.hunger += hunger_restore
    if game.player.hunger > @types.player_max_hunger {
      game.player.hunger = @types.player_max_hunger
    }
  }
}

// ========== Mob-player collision ==========

// Check if an entity is colliding with the player

///|
pub fn check_entity_player_collision(
  game : @types.Game,
  ent : @types.Entity,
) -> Bool {
  let player = game.player
  let dx = @types.absf(ent.x - player.x)
  let dz = @types.absf(ent.z - player.z)
  let dy = @types.absf(ent.y - player.y)
  let collision_radius : Float = 0.8
  let collision_height : Float = 1.8
  dx < collision_radius && dz < collision_radius && dy < collision_height
}

// Push entity away from player when colliding

///|
pub fn resolve_entity_player_collision(
  game : @types.Game,
  ent : @types.Entity,
) -> Unit {
  let player = game.player
  let dx = ent.x - player.x
  let dz = ent.z - player.z
  let dist = (dx * dx + dz * dz).sqrt()
  if dist > 0.01 {
    let push_force : Float = 3.0
    ent.vx += dx / dist * push_force
    ent.vz += dz / dist * push_force
  } else {
    // Random push if exactly overlapping
    let angle = @types.rand_float(game) * @types.two_pi
    ent.vx += @math.cosf(angle) * 3.0
    ent.vz += @math.sinf(angle) * 3.0
  }
}

// ========== Mob spawning logic ==========

// Get the maximum number of mobs that should be active based on time of day

///|
pub fn get_max_entity_count(is_night : Bool) -> Int {
  if is_night {
    24
  } else {
    16
  }
}

// Get spawn weight for a mob type in a given biome

///|
pub fn get_spawn_weight(kind : Int, biome : Int) -> Int {
  if kind == @types.entity_pig {
    if biome == @types.biome_plains {
      40
    } else if biome == @types.biome_forest {
      30
    } else if biome == @types.biome_swamp {
      20
    } else if biome == @types.biome_tundra {
      15
    } else if biome == @types.biome_desert {
      5
    } else if biome == @types.biome_mountains {
      10
    } else {
      20
    }
  } else if kind == @types.entity_cow {
    if biome == @types.biome_plains {
      35
    } else if biome == @types.biome_forest {
      20
    } else if biome == @types.biome_mountains {
      25
    } else if biome == @types.biome_tundra {
      20
    } else if biome == @types.biome_desert {
      0
    } else if biome == @types.biome_swamp {
      10
    } else {
      15
    }
  } else if kind == @types.entity_chicken {
    if biome == @types.biome_plains {
      30
    } else if biome == @types.biome_forest {
      25
    } else if biome == @types.biome_swamp {
      30
    } else if biome == @types.biome_desert {
      10
    } else if biome == @types.biome_tundra {
      5
    } else if biome == @types.biome_mountains {
      5
    } else {
      15
    }
  } else if kind == @types.entity_zombie {
    if biome == @types.biome_swamp {
      50
    } else if biome == @types.biome_forest {
      40
    } else if biome == @types.biome_plains {
      35
    } else {
      30
    }
  } else if kind == @types.entity_skeleton {
    if biome == @types.biome_tundra {
      45
    } else if biome == @types.biome_mountains {
      40
    } else if biome == @types.biome_desert {
      50
    } else {
      30
    }
  } else if kind == @types.entity_spider {
    if biome == @types.biome_swamp {
      45
    } else if biome == @types.biome_forest {
      40
    } else {
      25
    }
  } else {
    0
  }
}

// ========== Entity-entity collision avoidance ==========

// Check if two entities are colliding and push them apart

///|
pub fn resolve_entity_entity_collisions(game : @types.Game) -> Unit {
  for i = 0; i < @types.entity_max; i = i + 1 {
    let ent_a = game.entities[i]
    if not(ent_a.active) {
      continue i + 1
    }
    for j = i + 1; j < @types.entity_max; j = j + 1 {
      let ent_b = game.entities[j]
      if not(ent_b.active) {
        continue j + 1
      }
      let dx = ent_b.x - ent_a.x
      let dz = ent_b.z - ent_a.z
      let dist = (dx * dx + dz * dz).sqrt()
      let min_dist : Float = 0.7
      if dist < min_dist && dist > 0.01 {
        let push = (min_dist - dist) * 2.0
        let nx = dx / dist
        let nz = dz / dist
        ent_a.vx -= nx * push
        ent_a.vz -= nz * push
        ent_b.vx += nx * push
        ent_b.vz += nz * push
      }
    }
  }
}

// ========== Night aggression update ==========

// Update hostile mob aggression based on time of day

///|
pub fn update_hostile_aggression(
  game : @types.Game,
  ent : @types.Entity,
) -> Unit {
  if not(@types.is_hostile(ent.kind)) {
    return
  }
  let player = game.player
  let dist = @types.distance_xz(ent.x, ent.z, player.x, player.z)
  // Hostile mobs are more aggressive at night
  let aggro_range : Float = if game.is_night { 24.0 } else { 12.0 }
  if dist < aggro_range {
    if ent.ai_state != @types.ai_chase && ent.ai_state != @types.ai_attack {
      ent.ai_state = @types.ai_chase
      ent.target_x = player.x
      ent.target_z = player.z
    }
  }
  // Hostile mobs despawn during day if far from player
  if not(game.is_night) && dist > 40.0 {
    ent.active = false
  }
}

// ========== Entity awareness system ==========

// Check if entity can "see" the player (simple line of sight)

///|
pub fn entity_can_see_player(game : @types.Game, ent : @types.Entity) -> Bool {
  let player = game.player
  let dx = player.x - ent.x
  let dy = player.y + 0.5 - (ent.y + 0.5)
  let dz = player.z - ent.z
  let dist = (dx * dx + dy * dy + dz * dz).sqrt()
  if dist > 20.0 || dist < 0.1 {
    return false
  }
  // Simple raycast check - sample a few points along the line
  let steps = 8
  let step_x = dx / Float::from_int(steps)
  let step_y = dy / Float::from_int(steps)
  let step_z = dz / Float::from_int(steps)
  for s = 1; s < steps; s = s + 1 {
    let cx = ent.x + step_x * Float::from_int(s)
    let cy = ent.y + 0.5 + step_y * Float::from_int(s)
    let cz = ent.z + step_z * Float::from_int(s)
    let block = @types.get_world_block(
      game,
      cx.to_int(),
      cy.to_int(),
      cz.to_int(),
    )
    if @types.is_solid(block) {
      return false
    }
  }
  true
}

// ========== Entity group behavior ==========

// Passive mobs stay near each other (simple herding)

///|
pub fn update_herd_behavior(game : @types.Game, ent : @types.Entity) -> Unit {
  if @types.is_hostile(ent.kind) {
    return
  }
  if ent.ai_state != @types.ai_idle {
    return
  }
  // Find nearest entity of the same kind
  let mut nearest_dist : Float = 999.0
  let mut nearest_x : Float = ent.x
  let mut nearest_z : Float = ent.z
  let mut found = false
  for i = 0; i < @types.entity_max; i = i + 1 {
    let other = game.entities[i]
    if not(other.active) || other.kind != ent.kind {
      continue i + 1
    }
    // Check if it's the same entity by position
    let same_x = @types.absf(other.x - ent.x) < 0.01
    let same_z = @types.absf(other.z - ent.z) < 0.01
    if same_x && same_z {
      continue i + 1
    }
    let d = @types.distance_xz(ent.x, ent.z, other.x, other.z)
    if d < nearest_dist && d > 1.0 {
      nearest_dist = d
      nearest_x = other.x
      nearest_z = other.z
      found = true
    }
  }
  // If nearest same-kind mob is not too far, wander toward it
  if found && nearest_dist > 5.0 && nearest_dist < 20.0 {
    ent.ai_state = @types.ai_wander
    ent.ai_timer = 3.0
    ent.target_x = nearest_x + (@types.rand_float(game) - 0.5) * 3.0
    ent.target_z = nearest_z + (@types.rand_float(game) - 0.5) * 3.0
  }
}

// ========== Spider special abilities ==========

// Spiders can climb walls (simplified: extra high jump near walls)

///|
pub fn update_spider_climb(game : @types.Game, ent : @types.Entity) -> Unit {
  if ent.kind != @types.entity_spider {
    return
  }
  if not(ent.on_ground) {
    return
  }
  // Check if there is a wall adjacent
  let ahead_x = ent.x + @math.sinf(ent.yaw) * 0.8
  let ahead_z = ent.z + @math.cosf(ent.yaw) * 0.8
  let block_at = @types.get_world_block(
    game,
    ahead_x.to_int(),
    ent.y.to_int(),
    ahead_z.to_int(),
  )
  let block_above = @types.get_world_block(
    game,
    ahead_x.to_int(),
    ent.y.to_int() + 1,
    ahead_z.to_int(),
  )
  // If wall ahead and space above, climb
  if @types.is_solid(block_at) && not(@types.is_solid(block_above)) {
    ent.vy = 8.0
    ent.on_ground = false
  }
}

// ========== Skeleton ranged behavior ==========

// Skeletons try to maintain distance from the player

///|
pub fn update_skeleton_behavior(
  game : @types.Game,
  ent : @types.Entity,
) -> Unit {
  if ent.kind != @types.entity_skeleton {
    return
  }
  let player = game.player
  let dist = @types.distance_xz(ent.x, ent.z, player.x, player.z)
  // Skeletons prefer to stay at medium range
  let preferred_dist : Float = 5.0
  if dist < preferred_dist && ent.ai_state == @types.ai_chase {
    // Back away
    let dx = ent.x - player.x
    let dz = ent.z - player.z
    let d = (dx * dx + dz * dz).sqrt()
    if d > 0.01 {
      ent.target_x = ent.x + dx / d * 4.0
      ent.target_z = ent.z + dz / d * 4.0
    }
  }
}
