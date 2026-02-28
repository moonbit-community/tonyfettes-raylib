// Item system: dropped items, projectile homing, item box respawns, powerup effects

// Update dropped items (bananas, oil slicks) on the track

///|
pub fn update_dropped_items(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.dropped_items.length() {
    let item = game.dropped_items[i]
    if not(item.active) {
      continue
    }
    // Decrease lifetime
    item.lifetime -= dt
    if item.lifetime <= 0.0 {
      item.active = false
      // Fade-out particles
      @types.spawn_typed_particles(
        game,
        @types.particle_dust,
        item.x,
        item.y + 0.2,
        item.z,
        3,
        180,
        180,
        120,
        0.04,
        0.3,
      )
      continue
    }
    // Banana rotation animation
    if item.item_type == @types.powerup_banana {
      item.rotation += dt * 2.0
      if item.rotation > @types.two_pi {
        item.rotation -= @types.two_pi
      }
    }
    // Oil slick subtle pulsing handled in render
    // Gravity settling: if item is above ground, settle it down
    let ground_y = get_ground_height(game, item.x, item.z)
    if item.y > ground_y + 0.15 {
      item.y -= dt * 3.0
      if item.y < ground_y + 0.1 {
        item.y = ground_y + 0.1
      }
    }
  }
}

// Check collisions between karts and dropped items

///|
pub fn check_dropped_item_collisions(game : @types.Game) -> Unit {
  for ki in 0..<@types.max_karts {
    let kart = game.karts[ki]
    if not(kart.active) || kart.finished {
      continue
    }
    // Skip if already spinning or stunned
    if kart.spin_timer > 0.0 || kart.stunned_timer > 0.0 {
      continue
    }
    for di in 0..<game.dropped_items.length() {
      let item = game.dropped_items[di]
      if not(item.active) {
        continue
      }
      // Don't hit your own item for a brief grace period (first 0.5s)
      let grace_time : Float = item.lifetime
      let max_life : Float = if item.item_type == @types.powerup_banana {
        @types.banana_lifetime
      } else {
        @types.oil_slick_lifetime
      }
      let elapsed = max_life - grace_time
      if item.owner == ki && elapsed < 0.5 {
        continue
      }
      let dist = @types.distance2d(kart.x, kart.z, item.x, item.z)
      let hit_radius : Float = 1.3
      if dist < hit_radius {
        // Check for shield protection
        if kart.shield_timer > 0.0 {
          kart.shield_timer = 0.0
          @types.spawn_particles(
            game,
            kart.x,
            kart.y + 0.5,
            kart.z,
            10,
            100,
            200,
            255,
          )
          item.active = false
          continue
        }
        // Check for star invincibility
        if kart.star_timer > 0.0 || kart.invincible_timer > 0.0 {
          item.active = false
          @types.spawn_particles(
            game,
            item.x,
            item.y + 0.3,
            item.z,
            6,
            255,
            255,
            100,
          )
          continue
        }
        // Apply item effect
        if item.item_type == @types.powerup_banana {
          apply_banana_hit(game, ki)
        } else if item.item_type == @types.powerup_oil_slick {
          apply_oil_slick_hit(game, ki)
        }
        item.active = false
      }
    }
  }
}

// Apply banana peel hit effect - causes spin

///|
fn apply_banana_hit(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  kart.spin_timer = @types.spin_duration
  kart.speed = kart.speed * 0.4
  // Spawn banana peel explosion particles
  @types.spawn_particles(game, kart.x, kart.y + 0.3, kart.z, 12, 255, 230, 50)
  @types.spawn_typed_particles(
    game,
    @types.particle_explosion,
    kart.x,
    kart.y + 0.5,
    kart.z,
    6,
    255,
    200,
    0,
    0.08,
    0.5,
  )
}

// Apply oil slick hit effect - causes sliding and speed loss

///|
fn apply_oil_slick_hit(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  kart.stunned_timer = 1.2
  kart.speed = kart.speed * 0.5
  // Add a sideways drift effect
  let slide_angle = @types.rand_rangef(game, -0.5, 0.5)
  kart.angle = kart.angle + slide_angle
  // Spawn oil splash particles
  @types.spawn_typed_particles(
    game,
    @types.particle_splash,
    kart.x,
    kart.y + 0.1,
    kart.z,
    8,
    40,
    40,
    50,
    0.06,
    0.4,
  )
  @types.spawn_particles(game, kart.x, kart.y + 0.2, kart.z, 6, 80, 80, 90)
}

// Update projectile homing behavior

///|
pub fn update_projectile_homing(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.projectiles.length() {
    let proj = game.projectiles[i]
    if not(proj.active) {
      continue
    }
    // Only home if we have a valid target
    if proj.target_kart < 0 || proj.target_kart >= @types.max_karts {
      continue
    }
    let target = game.karts[proj.target_kart]
    if not(target.active) || target.finished {
      // Lost target, find a new one
      proj.target_kart = @types.find_target_ahead(game, proj.owner)
      continue
    }
    // Calculate angle to target
    let dx = target.x - proj.x
    let dz = target.z - proj.z
    let target_angle = @math.atan2f(dx, dz)
    let angle_delta = @types.angle_diff(proj.angle, target_angle)
    // Gradually turn towards target
    let max_turn = proj.homing_strength * dt
    let turn = @types.clampf(angle_delta, -max_turn, max_turn)
    proj.angle = proj.angle + turn
    proj.angle = @types.normalize_angle(proj.angle)
    // Spawn trail particles for homing missiles
    if game.frame_counter % 3 == 0 {
      let trail_x = proj.x - @math.sinf(proj.angle) * 0.3
      let trail_z = proj.z - @math.cosf(proj.angle) * 0.3
      @types.spawn_typed_particles(
        game,
        @types.particle_boost_flame,
        trail_x,
        proj.y,
        trail_z,
        1,
        255,
        120,
        30,
        0.04,
        0.2,
      )
    }
  }
}

// Enhanced powerup usage effects with more detailed behavior

///|
pub fn apply_speed_boost(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  kart.boost_timer = @types.boost_duration
  kart.boost_power = @types.boost_speed_add
  // Boost activation particles
  let sin_a = @math.sinf(kart.angle)
  let cos_a = @math.cosf(kart.angle)
  let tail_x = kart.x - sin_a * @types.kart_length * 0.6
  let tail_z = kart.z - cos_a * @types.kart_length * 0.6
  @types.spawn_typed_particles(
    game,
    @types.particle_boost_flame,
    tail_x,
    kart.y + 0.2,
    tail_z,
    8,
    255,
    180,
    30,
    0.08,
    0.4,
  )
  @types.spawn_particles(game, kart.x, kart.y + 0.3, kart.z, 6, 255, 200, 0)
}

// Apply shield activation with visual feedback

///|
pub fn apply_shield_activation(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  kart.shield_timer = @types.shield_duration
  // Shield activation ring particles
  for a in 0..<12 {
    let angle_f = Float::from_int(a) * @types.two_pi / 12.0
    let px = kart.x + @math.sinf(angle_f) * 1.2
    let pz = kart.z + @math.cosf(angle_f) * 1.2
    @types.spawn_typed_particles(
      game,
      @types.particle_star_sparkle,
      px,
      kart.y + 0.5,
      pz,
      1,
      80,
      180,
      255,
      0.06,
      0.4,
    )
  }
}

// Launch missile with enhanced targeting

///|
pub fn launch_missile(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let proj = game.projectiles[idx]
  proj.active = true
  let sin_a = @math.sinf(kart.angle)
  let cos_a = @math.cosf(kart.angle)
  proj.x = kart.x + sin_a * 1.8
  proj.y = kart.y + 0.5
  proj.z = kart.z + cos_a * 1.8
  proj.angle = kart.angle
  proj.speed = @types.missile_speed
  proj.owner = kart_idx
  proj.life = 6.0
  // Find homing target
  proj.target_kart = @types.find_target_ahead(game, kart_idx)
  proj.homing_strength = 2.8
  // Launch effect
  @types.spawn_typed_particles(
    game,
    @types.particle_boost_flame,
    proj.x,
    proj.y,
    proj.z,
    6,
    255,
    100,
    30,
    0.07,
    0.3,
  )
  @types.spawn_particles(game, kart.x, kart.y + 0.3, kart.z, 4, 200, 200, 200)
}

// Drop banana behind kart with arc trajectory

///|
pub fn drop_banana(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  let idx = @types.alloc_dropped_item(game)
  if idx < 0 {
    return
  }
  let item = game.dropped_items[idx]
  item.active = true
  item.item_type = @types.powerup_banana
  let sin_a = @math.sinf(kart.angle)
  let cos_a = @math.cosf(kart.angle)
  item.x = kart.x - sin_a * 2.5
  item.y = kart.y + 0.5
  item.z = kart.z - cos_a * 2.5
  item.owner = kart_idx
  item.rotation = 0.0
  item.lifetime = @types.banana_lifetime
  // Drop particles
  @types.spawn_typed_particles(
    game,
    @types.particle_dust,
    item.x,
    item.y,
    item.z,
    3,
    255,
    230,
    50,
    0.05,
    0.3,
  )
}

// Drop oil slick behind kart

///|
pub fn drop_oil_slick(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  let idx = @types.alloc_dropped_item(game)
  if idx < 0 {
    return
  }
  let item = game.dropped_items[idx]
  item.active = true
  item.item_type = @types.powerup_oil_slick
  let sin_a = @math.sinf(kart.angle)
  let cos_a = @math.cosf(kart.angle)
  item.x = kart.x - sin_a * 2.0
  item.y = kart.y + 0.1
  item.z = kart.z - cos_a * 2.0
  item.owner = kart_idx
  item.rotation = 0.0
  item.lifetime = @types.oil_slick_lifetime
  // Drop particles
  @types.spawn_typed_particles(
    game,
    @types.particle_splash,
    item.x,
    item.y,
    item.z,
    4,
    40,
    40,
    50,
    0.06,
    0.3,
  )
}

// Activate star power with full effect

///|
pub fn activate_star_power(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  kart.star_timer = @types.star_duration
  kart.invincible_timer = @types.star_duration
  // Star activation burst
  for a in 0..<16 {
    let angle_f = Float::from_int(a) * @types.two_pi / 16.0
    let radius : Float = 1.5
    let px = kart.x + @math.sinf(angle_f) * radius
    let pz = kart.z + @math.cosf(angle_f) * radius
    let r = 200 + @types.rand_range(game, 0, 55)
    let g = 150 + @types.rand_range(game, 0, 105)
    let b = 50 + @types.rand_range(game, 0, 205)
    @types.spawn_typed_particles(
      game,
      @types.particle_star_sparkle,
      px,
      kart.y + 0.5,
      pz,
      1,
      r,
      g,
      b,
      0.07,
      0.5,
    )
  }
  @types.spawn_particles(game, kart.x, kart.y + 0.5, kart.z, 15, 255, 255, 100)
}

// Activate lightning bolt affecting all opponents

///|
pub fn activate_lightning_bolt(game : @types.Game, source_kart : Int) -> Unit {
  game.lightning_active = true
  game.lightning_timer = @types.lightning_duration
  game.lightning_source = source_kart
  // Strike all other karts
  for i in 0..<@types.max_karts {
    if i == source_kart {
      continue
    }
    let kart = game.karts[i]
    if not(kart.active) || kart.finished {
      continue
    }
    // Star and invincibility protect against lightning
    if kart.star_timer > 0.0 || kart.invincible_timer > 0.0 {
      continue
    }
    kart.lightning_timer = @types.lightning_duration
    kart.spin_timer = @types.lightning_spin_duration
    kart.speed = kart.speed * 0.5
    // Lightning strike visual per kart
    @types.spawn_typed_particles(
      game,
      @types.particle_lightning,
      kart.x,
      kart.y + 1.5,
      kart.z,
      8,
      255,
      255,
      100,
      0.08,
      0.6,
    )
    @types.spawn_typed_particles(
      game,
      @types.particle_lightning,
      kart.x,
      kart.y + 0.5,
      kart.z,
      4,
      200,
      200,
      255,
      0.06,
      0.4,
    )
  }
  // Big lightning bolt from source
  let src = game.karts[source_kart]
  @types.spawn_typed_particles(
    game,
    @types.particle_lightning,
    src.x,
    src.y + 3.0,
    src.z,
    12,
    255,
    255,
    200,
    0.12,
    0.8,
  )
}

// Apply triple mushroom boost (one of three uses)

///|
pub fn apply_triple_mushroom(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  kart.boost_timer = @types.triple_mushroom_boost
  kart.boost_power = @types.boost_speed_add
  // Mushroom boost particles - pink tinted
  @types.spawn_typed_particles(
    game,
    @types.particle_boost_flame,
    kart.x,
    kart.y + 0.2,
    kart.z,
    6,
    255,
    150,
    200,
    0.07,
    0.3,
  )
  @types.spawn_particles(game, kart.x, kart.y + 0.3, kart.z, 5, 255, 180, 220)
}

// Item box respawn with enhanced variety

///|
pub fn update_item_box_respawns(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.powerups.length() {
    let pu = game.powerups[i]
    if not(pu.active) {
      continue
    }
    if pu.collected {
      pu.respawn_timer -= dt
      if pu.respawn_timer <= 0.0 {
        pu.collected = false
        // Respawn with position-aware item type
        // Items near the start/finish are more likely to be basic
        let variety = @types.rand_range(game, 1, @types.powerup_type_count - 1)
        pu.kind = variety
        // Respawn sparkle
        @types.spawn_typed_particles(
          game,
          @types.particle_star_sparkle,
          pu.x,
          pu.y,
          pu.z,
          4,
          255,
          255,
          200,
          0.05,
          0.3,
        )
      }
    }
    // Bob animation offset update
    pu.bob_offset += dt * 2.5
    if pu.bob_offset > @types.two_pi {
      pu.bob_offset -= @types.two_pi
    }
  }
}

// Projectile-kart collision check with enhanced effects

///|
pub fn check_projectile_impacts(game : @types.Game) -> Unit {
  for i in 0..<game.projectiles.length() {
    let proj = game.projectiles[i]
    if not(proj.active) {
      continue
    }
    for ki in 0..<@types.max_karts {
      if ki == proj.owner {
        continue
      }
      let kart = game.karts[ki]
      if not(kart.active) || kart.finished {
        continue
      }
      if kart.spin_timer > 0.0 {
        continue
      }
      let dist = @types.distance2d(proj.x, proj.z, kart.x, kart.z)
      let hit_dist : Float = 1.6
      if dist < hit_dist {
        // Shield absorbs the hit
        if kart.shield_timer > 0.0 {
          kart.shield_timer = 0.0
          @types.spawn_particles(
            game,
            kart.x,
            kart.y + 0.5,
            kart.z,
            14,
            100,
            200,
            255,
          )
          @types.spawn_typed_particles(
            game,
            @types.particle_explosion,
            kart.x,
            kart.y + 0.5,
            kart.z,
            6,
            80,
            160,
            255,
            0.08,
            0.4,
          )
          proj.active = false
          break
        }
        // Star makes kart immune
        if kart.star_timer > 0.0 || kart.invincible_timer > 0.0 {
          proj.active = false
          @types.spawn_particles(
            game,
            kart.x,
            kart.y + 0.5,
            kart.z,
            8,
            255,
            255,
            100,
          )
          break
        }
        // Direct hit
        kart.spin_timer = @types.spin_duration
        kart.speed = kart.speed * 0.25
        // Explosion particles
        @types.spawn_particles(
          game,
          kart.x,
          kart.y + 0.5,
          kart.z,
          18,
          255,
          100,
          50,
        )
        @types.spawn_typed_particles(
          game,
          @types.particle_explosion,
          kart.x,
          kart.y + 0.8,
          kart.z,
          8,
          255,
          150,
          30,
          0.1,
          0.6,
        )
        @types.spawn_typed_particles(
          game,
          @types.particle_explosion,
          kart.x,
          kart.y + 0.3,
          kart.z,
          6,
          80,
          80,
          80,
          0.08,
          0.5,
        )
        proj.active = false
        break
      }
    }
  }
}

// Check if a kart has a defensive item ready

///|
pub fn has_defensive_item(kart : @types.Kart) -> Bool {
  kart.held_powerup == @types.powerup_shield ||
  kart.held_powerup == @types.powerup_banana ||
  kart.held_powerup == @types.powerup_star
}

// Check if a kart has an offensive item ready

///|
pub fn has_offensive_item(kart : @types.Kart) -> Bool {
  kart.held_powerup == @types.powerup_missile ||
  kart.held_powerup == @types.powerup_lightning ||
  kart.held_powerup == @types.powerup_oil_slick
}

// Get item name for display purposes

///|
pub fn get_item_name(item_type : Int) -> String {
  if item_type == @types.powerup_none {
    "NONE"
  } else if item_type == @types.powerup_boost {
    "BOOST"
  } else if item_type == @types.powerup_shield {
    "SHIELD"
  } else if item_type == @types.powerup_missile {
    "MISSILE"
  } else if item_type == @types.powerup_oil_slick {
    "OIL SLICK"
  } else if item_type == @types.powerup_lightning {
    "LIGHTNING"
  } else if item_type == @types.powerup_star {
    "STAR"
  } else if item_type == @types.powerup_banana {
    "BANANA"
  } else if item_type == @types.powerup_triple_mushroom {
    "TRIPLE MUSH"
  } else {
    "UNKNOWN"
  }
}

// Get item color for UI display (r, g, b)

///|
pub fn get_item_color(item_type : Int) -> (Int, Int, Int) {
  if item_type == @types.powerup_boost {
    (255, 200, 0)
  } else if item_type == @types.powerup_shield {
    (80, 180, 255)
  } else if item_type == @types.powerup_missile {
    (255, 80, 30)
  } else if item_type == @types.powerup_oil_slick {
    (60, 60, 70)
  } else if item_type == @types.powerup_lightning {
    (255, 255, 100)
  } else if item_type == @types.powerup_star {
    (255, 255, 50)
  } else if item_type == @types.powerup_banana {
    (255, 230, 50)
  } else if item_type == @types.powerup_triple_mushroom {
    (255, 150, 200)
  } else {
    (200, 200, 200)
  }
}

// Calculate item effectiveness based on kart position

///|
pub fn calc_item_effectiveness(place : Int, item_type : Int) -> Float {
  if item_type == @types.powerup_boost ||
    item_type == @types.powerup_triple_mushroom {
    // Boosts more effective when behind
    if place >= 5 {
      1.5
    } else if place >= 3 {
      1.2
    } else {
      1.0
    }
  } else if item_type == @types.powerup_missile {
    // Missiles most useful in mid-pack
    if place >= 3 && place <= 6 {
      1.3
    } else {
      1.0
    }
  } else if item_type == @types.powerup_lightning {
    // Lightning best from back of pack
    if place >= 6 {
      1.5
    } else if place >= 4 {
      1.2
    } else {
      0.8
    }
  } else if item_type == @types.powerup_banana ||
    item_type == @types.powerup_oil_slick {
    // Traps best when in the lead
    if place <= 2 {
      1.4
    } else {
      1.0
    }
  } else if item_type == @types.powerup_shield {
    // Shield equally useful everywhere
    1.0
  } else if item_type == @types.powerup_star {
    // Star best in middle of pack for ramming
    if place >= 3 && place <= 5 {
      1.4
    } else {
      1.1
    }
  } else {
    1.0
  }
}
