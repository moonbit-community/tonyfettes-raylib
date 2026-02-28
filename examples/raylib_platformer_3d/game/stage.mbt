// Level loading and stage management

pub fn load_level(game : @types.Game, world : Int, level : Int) -> Unit {
  game.current_world = world
  game.current_level = level
  game.gems_collected = 0
  game.gems_total = 0
  game.stars_collected = 0
  game.coins_collected = 0
  game.keys_collected = 0
  game.total_coins = 0
  game.total_keys = 0
  game.level_deaths = 0
  game.level_time = 0.0
  game.combo_count = 0
  game.combo_timer = 0.0
  game.combo_mult = 1.0
  game.invincible_timer = 0.0
  game.powerup_type = -1
  game.powerup_timer = 0.0
  game.has_shield = false
  game.dashing = false
  game.dash_timer = 0.0
  game.dash_cooldown_timer = 0.0
  game.double_jumped = false
  game.has_double_jump = false
  game.wall_slide = false
  game.can_wall_jump = false
  game.checkpoint_active = false
  // Clear all pools
  clear_pools(game)
  // Load platforms
  load_platforms(game, world, level)
  // Load collectibles
  load_collectibles(game, world, level)
  // Load hazards
  load_hazards(game, world, level)
  // Load enemies
  load_enemies(game, world, level)
  // Load power-ups
  load_powerups(game, world, level)
  // Load decorations
  load_decorations(game, world, level)
  // Set goal
  let goal = @levels.get_goal_position(world, level)
  game.goal_x = goal.0
  game.goal_y = goal.1
  game.goal_z = goal.2
  // Set checkpoints
  load_checkpoints(game, world, level)
  // Player start
  game.px = 0.0
  game.py = @types.respawn_height
  game.pz = 0.0
  game.vx = 0.0
  game.vy = 0.0
  game.vz = 0.0
  game.grounded = false
  game.on_ice = false
  game.facing_x = 0.0
  game.facing_z = -1.0
  game.checkpoint_x = 0.0
  game.checkpoint_y = @types.respawn_height
  game.checkpoint_z = 0.0
  // Camera
  game.cam_x = 0.0
  game.cam_y = @types.camera_height + 2.0
  game.cam_z = @types.camera_dist
  game.cam_angle = 0.0
  game.cam_dist = @types.camera_dist
  game.cam_shake = 0.0
  game.cam_shake_timer = 0.0
  // Animation
  game.anim_walk_timer = 0.0
  game.anim_land_squash = 0.0
  game.anim_jump_stretch = 0.0
}

fn clear_pools(game : @types.Game) -> Unit {
  for i = 0; i < game.platforms.length(); i = i + 1 {
    game.platforms[i] = @types.Platform::inactive()
  }
  for i = 0; i < game.collectibles.length(); i = i + 1 {
    game.collectibles[i] = @types.Collectible::inactive()
  }
  for i = 0; i < game.hazards.length(); i = i + 1 {
    game.hazards[i] = @types.Hazard::inactive()
  }
  for i = 0; i < game.particles.length(); i = i + 1 {
    game.particles[i] = @types.Particle::inactive()
  }
  for i = 0; i < game.checkpoints.length(); i = i + 1 {
    game.checkpoints[i] = @types.Checkpoint::inactive()
  }
  for i = 0; i < game.enemies.length(); i = i + 1 {
    game.enemies[i] = @types.Enemy::inactive()
  }
  for i = 0; i < game.powerups.length(); i = i + 1 {
    game.powerups[i] = @types.PowerUp::inactive()
  }
  for i = 0; i < game.decorations.length(); i = i + 1 {
    game.decorations[i] = @types.Decoration::inactive()
  }
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    game.projectiles[i] = @types.Projectile::inactive()
  }
  for i = 0; i < game.score_flies.length(); i = i + 1 {
    game.score_flies[i] = @types.ScoreFly::inactive()
  }
}

fn load_platforms(game : @types.Game, world : Int, level : Int) -> Unit {
  let plat_data = @levels.get_platform_data(world, level)
  let wc = @levels.world_platform_color(world)
  for i = 0; i < plat_data.length() && i < @types.max_platforms; i = i + 1 {
    let pd = plat_data[i]
    let plat = game.platforms[i]
    plat.active = true
    plat.kind = pd.0
    plat.x = pd.1
    plat.y = pd.2
    plat.z = pd.3
    plat.w = pd.4
    plat.h = 0.3
    plat.d = pd.5
    plat.base_x = pd.1
    plat.base_y = pd.2
    plat.base_z = pd.3
    plat.move_range = pd.6
    plat.move_speed = pd.7
    plat.move_timer = Float::from_int(i) * 0.5
    plat.fall_timer = 0.0
    plat.falling = false
    plat.touched = false
    plat.crumble_timer = 0.0
    plat.crumbling = false
    plat.phase_timer = Float::from_int(i) * 0.3
    plat.phase_visible = true
    plat.rot_angle = 0.0
    // Color based on type
    if plat.kind == @types.plat_bouncy {
      plat.r = 255
      plat.g = 200
      plat.b = 50
    } else if plat.kind == @types.plat_ice {
      plat.r = @types.crystal_ice_r
      plat.g = @types.crystal_ice_g
      plat.b = @types.crystal_ice_b
    } else if plat.kind == @types.plat_falling || plat.kind == @types.plat_crumbling {
      plat.r = 180
      plat.g = 100
      plat.b = 80
    } else if plat.kind >= @types.plat_moving_x && plat.kind <= @types.plat_moving_z {
      plat.r = 120
      plat.g = 150
      plat.b = 200
    } else if plat.kind == @types.plat_conveyor_l || plat.kind == @types.plat_conveyor_r {
      plat.r = 160
      plat.g = 160
      plat.b = 80
    } else if plat.kind == @types.plat_phasing {
      plat.r = 180
      plat.g = 120
      plat.b = 200
    } else {
      plat.r = wc.0
      plat.g = wc.1
      plat.b = wc.2
    }
  }
}

fn load_collectibles(game : @types.Game, world : Int, level : Int) -> Unit {
  let coll_data = @levels.get_collectible_data(world, level)
  for i = 0; i < coll_data.length() && i < @types.max_collectibles; i = i + 1 {
    let cd = coll_data[i]
    let c = game.collectibles[i]
    c.active = true
    c.kind = cd.0
    c.x = cd.1
    c.y = cd.2
    c.z = cd.3
    c.bob_timer = Float::from_int(i)
    c.spin_timer = Float::from_int(i) * 0.7
    c.collected = false
    c.magnet_target = false
    if c.kind == @types.collect_gem { game.gems_total += 1 }
    if c.kind == @types.collect_coin_bronze || c.kind == @types.collect_coin_silver || c.kind == @types.collect_coin_gold {
      game.total_coins += 1
    }
    if c.kind == @types.collect_key { game.total_keys += 1 }
  }
}

fn load_hazards(game : @types.Game, world : Int, level : Int) -> Unit {
  let hazard_data = @levels.get_hazard_data(world, level)
  for i = 0; i < hazard_data.length() && i < @types.max_hazards; i = i + 1 {
    let hd = hazard_data[i]
    let h = game.hazards[i]
    h.active = true
    h.kind = hd.0
    h.x = hd.1
    h.y = hd.2
    h.z = hd.3
    h.w = hd.4
    h.h = hd.5
    h.d = hd.6
    h.timer = Float::from_int(i) * 0.5
    h.phase = Float::from_int(i) * 0.3
    h.on = true
    h.base_x = hd.1
    h.base_y = hd.2
    h.move_range = 0.0
    h.move_speed = 0.0
    // Pendulums and saws get movement
    if h.kind == @types.hazard_pendulum {
      h.move_range = 2.0
      h.move_speed = 2.0
    }
    if h.kind == @types.hazard_saw {
      h.move_range = 1.5
      h.move_speed = 3.0
    }
  }
}

fn load_enemies(game : @types.Game, world : Int, level : Int) -> Unit {
  let enemy_data = @levels.get_enemy_data(world, level)
  for i = 0; i < enemy_data.length() && i < @types.max_enemies; i = i + 1 {
    let ed = enemy_data[i]
    let e = game.enemies[i]
    e.active = true
    e.kind = ed.0
    e.x = ed.1
    e.y = ed.2
    e.z = ed.3
    e.base_x = ed.1
    e.base_y = ed.2
    e.base_z = ed.3
    e.patrol_range = ed.4
    e.patrol_dir = 1.0
    e.timer = Float::from_int(i) * 0.5
    e.health = 1
    e.stunned = false
    e.stun_timer = 0.0
    e.anim_timer = 0.0
    e.size = @types.enemy_size
    e.vx = 0.0
    e.vy = 0.0
    e.vz = 0.0
    // Set colors by kind
    if e.kind == @types.enemy_patrol {
      e.r = @types.enemy_patrol_r
      e.g = @types.enemy_patrol_g
      e.b = @types.enemy_patrol_b
    } else if e.kind == @types.enemy_bounce {
      e.r = @types.enemy_bounce_r
      e.g = @types.enemy_bounce_g
      e.b = @types.enemy_bounce_b
    } else if e.kind == @types.enemy_fly_circle {
      e.r = @types.enemy_fly_r
      e.g = @types.enemy_fly_g
      e.b = @types.enemy_fly_b
    } else if e.kind == @types.enemy_chase {
      e.r = @types.enemy_chase_r
      e.g = @types.enemy_chase_g
      e.b = @types.enemy_chase_b
    } else if e.kind == @types.enemy_turret {
      e.r = @types.enemy_turret_r
      e.g = @types.enemy_turret_g
      e.b = @types.enemy_turret_b
    } else {
      e.r = @types.enemy_ghost_r
      e.g = @types.enemy_ghost_g
      e.b = @types.enemy_ghost_b
    }
  }
}

fn load_powerups(game : @types.Game, world : Int, level : Int) -> Unit {
  let pu_data = @levels.get_powerup_data(world, level)
  for i = 0; i < pu_data.length() && i < @types.max_powerups; i = i + 1 {
    let pd = pu_data[i]
    let pu = game.powerups[i]
    pu.active = true
    pu.kind = pd.0
    pu.x = pd.1
    pu.y = pd.2
    pu.z = pd.3
    pu.bob_timer = Float::from_int(i) * 0.8
    pu.spin_timer = 0.0
    pu.collected = false
  }
}

fn load_decorations(game : @types.Game, world : Int, level : Int) -> Unit {
  let deco_data = @levels.get_decoration_data(world, level)
  for i = 0; i < deco_data.length() && i < @types.max_decorations; i = i + 1 {
    let dd = deco_data[i]
    let d = game.decorations[i]
    d.active = true
    d.kind = dd.0
    d.x = dd.1
    d.y = dd.2
    d.z = dd.3
    d.scale = dd.4
    d.rot_y = Float::from_int(i) * 45.0
    // Decoration colors by world
    let c1 = @levels.world_deco_color_1(world)
    let c2 = @levels.world_deco_color_2(world)
    if i % 2 == 0 {
      d.r = c1.0
      d.g = c1.1
      d.b = c1.2
    } else {
      d.r = c2.0
      d.g = c2.1
      d.b = c2.2
    }
  }
}

fn load_checkpoints(game : @types.Game, world : Int, level : Int) -> Unit {
  let plat_data = @levels.get_platform_data(world, level)
  let mut cp_count = 0
  for i = 0; i < plat_data.length() && cp_count < @types.max_checkpoints; i = i + 1 {
    if i > 0 && i % 5 == 0 {
      let pd = plat_data[i]
      // Only place checkpoints on static platforms
      if pd.0 == 0 {
        let cp = game.checkpoints[cp_count]
        cp.active = true
        cp.x = pd.1
        cp.y = pd.2 + 1.0
        cp.z = pd.3
        cp.activated = false
        cp.anim_timer = 0.0
        cp_count += 1
      }
    }
  }
  ignore(world)
  ignore(level)
}
