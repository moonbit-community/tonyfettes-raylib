///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_particles(game, dt)
  update_score_flies(game, dt)
  if game.state == @types.state_menu {
    update_menu(game, dt)
  } else if game.state == @types.state_playing {
    update_playing(game, dt)
  } else if game.state == @types.state_paused {
    update_paused(game, dt)
  } else if game.state == @types.state_level_complete {
    update_level_complete(game, dt)
  } else if game.state == @types.state_game_over {
    update_game_over(game, dt)
  } else if game.state == @types.state_world_select {
    update_world_select(game, dt)
  } else if game.state == @types.state_campaign_complete {
    update_campaign_complete(game, dt)
  } else if game.state == @types.state_level_select {
    update_level_select(game, dt)
  } else if game.state == @types.state_death_anim {
    update_death_anim(game, dt)
  } else if game.state == @types.state_world_intro {
    update_world_intro(game, dt)
  }
}

///|
fn update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * @types.ui_blink_speed
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor > 2 {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      // New game
      game.lives = @types.player_max_lives
      game.score = 0
      game.world_intro_timer = @types.world_intro_duration
      game.current_world = 0
      game.current_level = 0
      load_level(game, 0, 0)
      game.state = @types.state_world_intro
    } else if game.menu_cursor == 1 {
      game.state = @types.state_world_select
    } else {
      // Level select
      game.state = @types.state_level_select
    }
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.state_paused
    game.pause_cursor = 0
    return
  }
  // Level timer
  game.level_time += dt
  // Combo decay
  if game.combo_timer > 0.0 {
    game.combo_timer -= dt
    if game.combo_timer <= 0.0 {
      game.combo_count = 0
      game.combo_mult = @types.combo_base_mult
    }
  }
  // Power-up timer
  if game.powerup_type >= 0 {
    game.powerup_timer -= dt
    if game.powerup_timer <= 0.0 {
      expire_powerup(game)
    }
  }
  // Invincibility timer
  if game.invincible_timer > 0.0 {
    game.invincible_timer -= dt
  }
  // Dash cooldown
  if game.dash_cooldown_timer > 0.0 {
    game.dash_cooldown_timer -= dt
  }
  update_player(game, dt)
  update_platforms(game, dt)
  update_collectibles(game, dt)
  update_enemies(game, dt)
  update_powerups(game, dt)
  update_projectiles(game, dt)
  update_hazards(game, dt)
  check_hazard_collision(game)
  check_enemy_collision(game)
  check_checkpoint_collision(game)
  update_camera(game, dt)
  // Camera shake
  if game.cam_shake_timer > 0.0 {
    game.cam_shake_timer -= dt
    game.cam_shake = game.cam_shake * (1.0 - dt * @types.camera_shake_decay)
  } else {
    game.cam_shake = 0.0
  }
  // Check death by falling
  if game.py < @types.death_fall_y {
    player_die(game)
  }
  // Check goal
  let goal_dist = @types.dist3d(
    game.px,
    game.py,
    game.pz,
    game.goal_x,
    game.goal_y,
    game.goal_z,
  )
  if goal_dist < 1.5 {
    game.complete_timer = 0.0
    // Calculate stars
    let stars = @types.calc_stars(
      game.level_time,
      game.gems_collected,
      game.gems_total,
      game.level_deaths,
    )
    let lvl_idx = game.current_world * @types.levels_per_world +
      game.current_level
    if stars > game.level_stars[lvl_idx] {
      game.level_stars[lvl_idx] = stars
    }
    // Bonus score
    if game.level_deaths == 0 {
      game.score += @types.star_no_death_bonus
    }
    if game.gems_collected == game.gems_total {
      game.score += @types.star_all_gems_bonus
    }
    @types.spawn_particle_ring(
      game,
      game.px,
      game.py,
      game.pz,
      20,
      1.5,
      3.0,
      255,
      215,
      0,
    )
    game.state = @types.state_level_complete
  }
}

///|
fn update_paused(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.state_playing
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.pause_cursor -= 1
    if game.pause_cursor < 0 {
      game.pause_cursor = 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.pause_cursor += 1
    if game.pause_cursor > 2 {
      game.pause_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.pause_cursor == 0 {
      // Resume
      game.state = @types.state_playing
    } else if game.pause_cursor == 1 {
      // Restart
      load_level(game, game.current_world, game.current_level)
      game.state = @types.state_playing
    } else {
      // Quit to menu
      game.state = @types.state_menu
    }
  }
}

///|
fn update_level_complete(game : @types.Game, dt : Float) -> Unit {
  game.complete_timer += dt
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let next_level = game.current_level + 1
    if next_level >= @types.levels_per_world {
      let next_world = game.current_world + 1
      if next_world >= @types.num_worlds {
        game.state = @types.state_campaign_complete
      } else {
        game.current_world = next_world
        game.current_level = 0
        game.world_intro_timer = @types.world_intro_duration
        load_level(game, next_world, 0)
        game.state = @types.state_world_intro
      }
    } else {
      load_level(game, game.current_world, next_level)
      game.state = @types.state_playing
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.state = @types.state_menu
  }
}

///|
fn update_game_over(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.lives = @types.player_max_lives
    game.score = 0
    load_level(game, game.current_world, game.current_level)
    game.state = @types.state_playing
  }
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.lives = @types.player_max_lives
    game.score = 0
    game.state = @types.state_menu
  }
}

///|
fn update_world_select(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_menu
    return
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.world_select_cursor -= 1
    if game.world_select_cursor < 0 {
      game.world_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.world_select_cursor += 1
    if game.world_select_cursor >= @types.num_worlds {
      game.world_select_cursor = @types.num_worlds - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_world = game.world_select_cursor
    game.current_level = 0
    game.world_intro_timer = @types.world_intro_duration
    load_level(game, game.world_select_cursor, 0)
    game.state = @types.state_world_intro
  }
}

///|
fn update_campaign_complete(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = @types.state_menu
  }
}

///|
fn update_level_select(game : @types.Game, _dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_menu
    return
  }
  let total = @types.total_levels
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.level_select_cursor -= 1
    if game.level_select_cursor < 0 {
      game.level_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.level_select_cursor += 1
    if game.level_select_cursor >= total {
      game.level_select_cursor = total - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.level_select_cursor -= @types.level_grid_cols
    if game.level_select_cursor < 0 {
      game.level_select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.level_select_cursor += @types.level_grid_cols
    if game.level_select_cursor >= total {
      game.level_select_cursor = total - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let w = game.level_select_cursor / @types.levels_per_world
    let l = game.level_select_cursor % @types.levels_per_world
    load_level(game, w, l)
    game.state = @types.state_playing
  }
}

///|
fn update_death_anim(game : @types.Game, dt : Float) -> Unit {
  game.death_timer += dt
  // Player pops up then falls
  if game.death_timer < 0.3 {
    game.py += @types.death_bounce_height * dt * 3.0
  } else {
    game.py -= @types.gravity * 0.5 * dt
  }
  if game.death_timer >= @types.death_anim_time {
    game.death_timer = 0.0
    if game.lives <= 0 {
      game.state = @types.state_game_over
    } else {
      // Respawn at checkpoint
      game.px = game.checkpoint_x
      game.py = game.checkpoint_y
      game.pz = game.checkpoint_z
      game.vx = 0.0
      game.vy = 0.0
      game.vz = 0.0
      game.grounded = false
      game.invincible_timer = @types.invincible_time
      game.state = @types.state_playing
    }
  }
}

///|
fn update_world_intro(game : @types.Game, dt : Float) -> Unit {
  game.world_intro_timer -= dt
  if game.world_intro_timer <= 0.0 ||
    @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = @types.state_playing
  }
}

///|
fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.particles.length() {
    let p = game.particles[i]
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
    p.vy -= 8.0 * dt
    // Shrink over life
    let life_ratio : Float = p.life / p.max_life
    p.size = p.size * (0.95 + 0.05 * life_ratio)
  }
}

///|
fn update_score_flies(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.score_flies.length() {
    let sf = game.score_flies[i]
    if not(sf.active) {
      continue
    }
    sf.timer += dt
    sf.y -= 40.0 * dt
    if sf.timer >= sf.max_time {
      sf.active = false
    }
  }
}

///|
fn update_camera(game : @types.Game, dt : Float) -> Unit {
  // Rotate camera with Q/E
  if @raylib.is_key_down(@raylib.KeyQ) {
    game.cam_angle += @types.camera_rotate_speed * dt
  }
  if @raylib.is_key_down(@raylib.KeyE) {
    game.cam_angle -= @types.camera_rotate_speed * dt
  }
  // Zoom with mouse wheel or +/-
  if @raylib.is_key_down(@raylib.KeyEqual) {
    game.cam_dist -= @types.camera_zoom_speed * dt
  }
  if @raylib.is_key_down(@raylib.KeyMinus) {
    game.cam_dist += @types.camera_zoom_speed * dt
  }
  game.cam_dist = @types.clampf(
    game.cam_dist,
    @types.camera_min_dist,
    @types.camera_max_dist,
  )
  let angle_rad = game.cam_angle * @types.deg2rad
  let target_x = game.px + @math.sinf(angle_rad) * game.cam_dist
  let target_y = game.py + @types.camera_height
  let target_z = game.pz + @math.cosf(angle_rad) * game.cam_dist
  let smooth = @types.minf(dt * @types.camera_smooth, 1.0)
  game.cam_x = @types.lerpf(game.cam_x, target_x, smooth)
  game.cam_y = @types.lerpf(game.cam_y, target_y, smooth)
  game.cam_z = @types.lerpf(game.cam_z, target_z, smooth)
  // Apply shake
  if game.cam_shake > 0.01 {
    let shake_x = @types.rand_rangef(game, -game.cam_shake, game.cam_shake)
    let shake_y = @types.rand_rangef(game, -game.cam_shake, game.cam_shake)
    game.cam_x += shake_x
    game.cam_y += shake_y
  }
}

///|
fn update_enemies(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    e.anim_timer += dt
    // Handle stun
    if e.stunned {
      e.stun_timer -= dt
      if e.stun_timer <= 0.0 {
        e.stunned = false
      }
      continue
    }
    if e.kind == @types.enemy_patrol {
      update_enemy_patrol(e, dt)
    } else if e.kind == @types.enemy_bounce {
      update_enemy_bounce(e, dt)
    } else if e.kind == @types.enemy_fly_circle {
      update_enemy_fly(e, dt)
    } else if e.kind == @types.enemy_chase {
      update_enemy_chase(game, e, dt)
    } else if e.kind == @types.enemy_turret {
      update_enemy_turret(game, e, dt)
    }
  }
}

///|
fn update_enemy_patrol(e : @types.Enemy, dt : Float) -> Unit {
  e.x += e.patrol_dir * @types.enemy_patrol_speed * dt
  let dist_from_base = e.x - e.base_x
  if @types.absf(dist_from_base) > e.patrol_range {
    e.patrol_dir = -e.patrol_dir
    e.x = e.base_x + e.patrol_dir * e.patrol_range
  }
}

///|
fn update_enemy_bounce(e : @types.Enemy, dt : Float) -> Unit {
  e.timer += dt * @types.enemy_bounce_speed
  let bounce_h = @types.absf(@math.sinf(e.timer)) * @types.enemy_bounce_height
  e.y = e.base_y + bounce_h
  // Small horizontal wobble
  let wobble = @math.sinf(e.timer * 0.7) * 0.5
  e.x = e.base_x + wobble
}

///|
fn update_enemy_fly(e : @types.Enemy, dt : Float) -> Unit {
  e.timer += dt * @types.enemy_fly_speed
  e.x = e.base_x + @math.cosf(e.timer) * e.patrol_range
  e.z = e.base_z + @math.sinf(e.timer) * e.patrol_range
  // Gentle bob up and down
  let bob_amt = @math.sinf(e.timer * 2.0) * 0.3
  e.y = e.base_y + bob_amt
}

///|
fn update_enemy_chase(game : @types.Game, e : @types.Enemy, dt : Float) -> Unit {
  let dist = @types.dist2d(e.x, e.z, game.px, game.pz)
  if dist < @types.enemy_chase_range && dist > 0.5 {
    let dx = game.px - e.x
    let dz = game.pz - e.z
    let inv_dist : Float = 1.0 / dist
    e.x += dx * inv_dist * @types.enemy_chase_speed * dt
    e.z += dz * inv_dist * @types.enemy_chase_speed * dt
  } else {
    // Return to base if player is far
    let base_dist = @types.dist2d(e.x, e.z, e.base_x, e.base_z)
    if base_dist > 0.5 {
      let bx = e.base_x - e.x
      let bz = e.base_z - e.z
      let inv_base : Float = 1.0 / base_dist
      e.x += bx * inv_base * @types.enemy_patrol_speed * dt
      e.z += bz * inv_base * @types.enemy_patrol_speed * dt
    }
  }
}

///|
fn update_enemy_turret(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
) -> Unit {
  e.timer += dt
  let dist = @types.dist3d(e.x, e.y, e.z, game.px, game.py, game.pz)
  if dist < @types.enemy_turret_range &&
    e.timer >= @types.enemy_turret_fire_rate {
    e.timer = 0.0
    // Fire a projectile toward the player
    let idx = @types.alloc_projectile(game)
    if idx >= 0 {
      let proj = game.projectiles[idx]
      proj.active = true
      proj.kind = @types.proj_enemy_shot
      proj.x = e.x
      proj.y = e.y + 0.3
      proj.z = e.z
      let dx = game.px - e.x
      let dy = game.py - e.y
      let dz = game.pz - e.z
      let d = @types.dist3d(e.x, e.y, e.z, game.px, game.py, game.pz)
      if d > 0.1 {
        let inv_d : Float = @types.proj_speed / d
        proj.vx = dx * inv_d
        proj.vy = dy * inv_d
        proj.vz = dz * inv_d
      }
      proj.life = @types.proj_lifetime
      proj.r = 255
      proj.g = 100
      proj.b = 50
    }
  }
}

///|
fn update_powerups(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.powerups.length() {
    let pu = game.powerups[i]
    if not(pu.active) || pu.collected {
      continue
    }
    pu.bob_timer += dt
    pu.spin_timer += dt * @types.powerup_spin_speed
    // Check player collision
    let dist = @types.dist3d(game.px, game.py, game.pz, pu.x, pu.y, pu.z)
    if dist < 1.2 {
      pu.collected = true
      pu.active = false
      activate_powerup(game, pu.kind)
      // Particles
      let pr : Int = if pu.kind == @types.powerup_double_jump {
        @types.pu_double_jump_r
      } else if pu.kind == @types.powerup_speed {
        @types.pu_speed_r
      } else if pu.kind == @types.powerup_shield {
        @types.pu_shield_r
      } else if pu.kind == @types.powerup_magnet {
        @types.pu_magnet_r
      } else {
        @types.pu_slow_fall_r
      }
      let pg : Int = if pu.kind == @types.powerup_double_jump {
        @types.pu_double_jump_g
      } else if pu.kind == @types.powerup_speed {
        @types.pu_speed_g
      } else if pu.kind == @types.powerup_shield {
        @types.pu_shield_g
      } else if pu.kind == @types.powerup_magnet {
        @types.pu_magnet_g
      } else {
        @types.pu_slow_fall_g
      }
      let pb : Int = if pu.kind == @types.powerup_double_jump {
        @types.pu_double_jump_b
      } else if pu.kind == @types.powerup_speed {
        @types.pu_speed_b
      } else if pu.kind == @types.powerup_shield {
        @types.pu_shield_b
      } else if pu.kind == @types.powerup_magnet {
        @types.pu_magnet_b
      } else {
        @types.pu_slow_fall_b
      }
      @types.spawn_particle_ring(
        game,
        pu.x,
        pu.y,
        pu.z,
        @types.particle_powerup_count,
        1.0,
        2.0,
        pr,
        pg,
        pb,
      )
    }
  }
}

///|
fn activate_powerup(game : @types.Game, kind : Int) -> Unit {
  game.powerup_type = kind
  game.powerup_timer = @types.powerup_duration
  if kind == @types.powerup_double_jump {
    game.has_double_jump = true
  } else if kind == @types.powerup_shield {
    game.has_shield = true
  }
}

///|
fn expire_powerup(game : @types.Game) -> Unit {
  if game.powerup_type == @types.powerup_double_jump {
    game.has_double_jump = false
  } else if game.powerup_type == @types.powerup_shield {
    game.has_shield = false
  }
  game.powerup_type = -1
  game.powerup_timer = 0.0
}

///|
fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.projectiles.length() {
    let proj = game.projectiles[i]
    if not(proj.active) {
      continue
    }
    proj.life -= dt
    if proj.life <= 0.0 {
      proj.active = false
      continue
    }
    proj.x += proj.vx * dt
    proj.y += proj.vy * dt
    proj.z += proj.vz * dt
    // Check collision with player
    let dist = @types.dist3d(proj.x, proj.y, proj.z, game.px, game.py, game.pz)
    if dist < @types.player_radius + @types.proj_radius {
      proj.active = false
      if game.invincible_timer <= 0.0 {
        if game.has_shield {
          game.has_shield = false
          game.powerup_type = -1
          game.powerup_timer = 0.0
          @types.spawn_particles(
            game,
            game.px,
            game.py,
            game.pz,
            8,
            @types.player_shield_r,
            @types.player_shield_g,
            @types.player_shield_b,
          )
        } else {
          player_die(game)
          return
        }
      }
    }
  }
}

///|
fn update_hazards(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.hazards.length() {
    let h = game.hazards[i]
    if not(h.active) {
      continue
    }
    h.timer += dt
    // Fire jets toggle on/off
    if h.kind == @types.hazard_fire_jet {
      h.phase += dt
      let cycle : Float = 3.0
      let ratio : Float = h.phase / cycle
      let floored : Float = Float::from_int(ratio.to_int())
      let phase_in_cycle : Float = h.phase - floored * cycle
      h.on = phase_in_cycle < cycle * 0.6
    }
    // Pendulum swing
    if h.kind == @types.hazard_pendulum {
      let swing = @math.sinf(h.timer * h.move_speed) * h.move_range
      h.x = h.base_x + swing
    }
    // Saw movement
    if h.kind == @types.hazard_saw {
      h.x = h.base_x + @math.sinf(h.timer * h.move_speed) * h.move_range
    }
    // Crusher
    if h.kind == @types.hazard_crusher {
      let cycle : Float = 4.0
      let ratio : Float = h.timer / cycle
      let floored : Float = Float::from_int(ratio.to_int())
      let t : Float = h.timer - floored * cycle
      if t < 1.0 {
        // Moving down
        h.y = h.base_y - t * 2.0
      } else if t < 1.5 {
        // Hold
        h.y = h.base_y - 2.0
      } else if t < 2.5 {
        // Moving up
        let up_t : Float = t - 1.5
        h.y = h.base_y - 2.0 + up_t * 2.0
      } else {
        // Wait at top
        h.y = h.base_y
      }
    }
  }
}

///|
fn check_hazard_collision(game : @types.Game) -> Unit {
  if game.invincible_timer > 0.0 {
    return
  }
  for i in 0..<game.hazards.length() {
    let h = game.hazards[i]
    if not(h.active) {
      continue
    }
    // Fire jets only hit when on
    if h.kind == @types.hazard_fire_jet && not(h.on) {
      continue
    }
    if @types.sphere_aabb(
        game.px,
        game.py,
        game.pz,
        @types.player_radius,
        h.x,
        h.y,
        h.z,
        h.w,
        h.h,
        h.d,
      ) {
      if game.has_shield {
        game.has_shield = false
        game.powerup_type = -1
        game.powerup_timer = 0.0
        game.invincible_timer = 0.5
        @types.spawn_particles(
          game,
          game.px,
          game.py,
          game.pz,
          8,
          @types.player_shield_r,
          @types.player_shield_g,
          @types.player_shield_b,
        )
      } else {
        player_die(game)
      }
      return
    }
  }
}

///|
fn check_enemy_collision(game : @types.Game) -> Unit {
  if game.invincible_timer > 0.0 {
    return
  }
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) || e.stunned {
      continue
    }
    let dist = @types.dist3d(game.px, game.py, game.pz, e.x, e.y, e.z)
    if dist < @types.player_radius + e.size {
      // Check if player is above enemy (stomp)
      let player_bottom = game.py - @types.player_height * 0.5
      let enemy_top = e.y + e.size * 0.5
      if player_bottom > enemy_top - 0.3 && game.vy < 0.0 {
        // Stomp the enemy
        e.health -= 1
        if e.health <= 0 {
          e.active = false
          @types.add_score(game, @types.enemy_kill_score)
          @types.spawn_particles(
            game,
            e.x,
            e.y,
            e.z,
            @types.particle_stomp_count,
            e.r,
            e.g,
            e.b,
          )
          @types.trigger_cam_shake(game, 0.15, 0.2)
        } else {
          e.stunned = true
          e.stun_timer = 2.0
        }
        // Bounce player up
        game.vy = @types.enemy_stomp_bounce
        game.double_jumped = false
      } else {
        // Player hit by enemy
        if game.has_shield {
          game.has_shield = false
          game.powerup_type = -1
          game.powerup_timer = 0.0
          game.invincible_timer = 0.5
          @types.spawn_particles(
            game,
            game.px,
            game.py,
            game.pz,
            8,
            @types.player_shield_r,
            @types.player_shield_g,
            @types.player_shield_b,
          )
          // Knock back
          let knock_dir_x = game.px - e.x
          let knock_dir_z = game.pz - e.z
          let knock_len = (knock_dir_x * knock_dir_x + knock_dir_z * knock_dir_z).sqrt()
          if knock_len > 0.01 {
            game.vx = knock_dir_x / knock_len * 5.0
            game.vz = knock_dir_z / knock_len * 5.0
          }
          game.vy = 4.0
        } else {
          player_die(game)
        }
        return
      }
    }
  }
}

///|
fn check_checkpoint_collision(game : @types.Game) -> Unit {
  for i in 0..<game.checkpoints.length() {
    let cp = game.checkpoints[i]
    if not(cp.active) || cp.activated {
      continue
    }
    let dist = @types.dist3d(game.px, game.py, game.pz, cp.x, cp.y, cp.z)
    if dist < @types.checkpoint_activate_range {
      cp.activated = true
      cp.anim_timer = 0.0
      game.checkpoint_x = cp.x
      game.checkpoint_y = cp.y
      game.checkpoint_z = cp.z
      game.checkpoint_active = true
      @types.spawn_particle_ring(
        game,
        cp.x,
        cp.y,
        cp.z,
        @types.particle_checkpoint_count,
        0.8,
        2.0,
        0,
        255,
        100,
      )
    }
  }
}

///|
fn player_die(game : @types.Game) -> Unit {
  game.lives -= 1
  game.level_deaths += 1
  game.combo_count = 0
  game.combo_mult = @types.combo_base_mult
  game.combo_timer = 0.0
  @types.spawn_particles(
    game,
    game.px,
    game.py,
    game.pz,
    @types.particle_death_count,
    255,
    100,
    100,
  )
  @types.trigger_cam_shake(game, 0.3, 0.4)
  game.death_timer = 0.0
  game.state = @types.state_death_anim
}
