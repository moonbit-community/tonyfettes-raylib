// Main game update dispatcher

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_particles(game, dt)
  update_messages(game, dt)
  if game.state == @types.state_menu {
    update_menu(game, dt)
  } else if game.state == @types.state_aircraft_select {
    update_aircraft_select(game, dt)
  } else if game.state == @types.state_mission_briefing {
    update_briefing(game)
  } else if game.state == @types.state_playing {
    update_playing(game, dt)
  } else if game.state == @types.state_paused {
    update_paused(game)
  } else if game.state == @types.state_mission_complete {
    update_mission_complete(game)
  } else if game.state == @types.state_game_over {
    update_game_over(game)
  }
}

///|
fn update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = @types.total_missions - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor >= @types.total_missions {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_mission = game.menu_cursor
    game.state = @types.state_aircraft_select
  }
}

///|
fn update_aircraft_select(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.0
  if @raylib.is_key_pressed(@raylib.KeyLeft) {
    game.selected_aircraft -= 1
    if game.selected_aircraft < 0 {
      game.selected_aircraft = 3
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) {
    game.selected_aircraft += 1
    if game.selected_aircraft > 3 {
      game.selected_aircraft = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = @types.state_mission_briefing
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_menu
  }
}

///|
fn update_briefing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_mission(game, game.current_mission)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_aircraft_select
  }
}

///|
fn update_playing(game : @types.Game, dt : Float) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.state_paused
    return
  }
  // Camera mode switch
  if @raylib.is_key_pressed(@raylib.KeyC) {
    game.camera_mode += 1
    if game.camera_mode > @types.camera_mode_free {
      game.camera_mode = @types.camera_mode_chase
    }
  }
  update_player(game, dt)
  update_camera(game, dt)
  update_terrain(game)
  update_clouds(game)
  update_enemies(game, dt)
  update_turrets(game, dt)
  update_projectiles(game, dt)
  update_buildings_projectile_check(game)
  update_checkpoints(game)
  update_mission_logic(game, dt)
  update_warnings(game, dt)
  update_weather_effects(game, dt)
}

///|
fn update_paused(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.state_playing
  }
  if @raylib.is_key_pressed(@raylib.KeyQ) {
    game.state = @types.state_menu
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_mission(game, game.current_mission)
  }
}

///|
fn update_mission_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = @types.state_menu
  }
}

///|
fn update_game_over(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.state = @types.state_menu
  }
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_mission(game, game.current_mission)
  }
}

///|
fn update_particles(game : @types.Game, dt : Float) -> Unit {
  for p in game.particles {
    if not(p.active) {
      continue
    }
    p.x += p.vx * dt
    p.y += p.vy * dt
    p.z += p.vz * dt
    // Different gravity for different particle types
    if p.kind == @types.particle_debris {
      p.vy -= 9.8 * dt
    } else if p.kind == @types.particle_fire {
      p.vy += 2.0 * dt
    } else if p.kind == @types.particle_smoke {
      p.vy += 0.5 * dt
      // Smoke expands
      p.size += 0.1 * dt
    } else if p.kind == @types.particle_rain {
      p.vy -= 15.0 * dt
    } else {
      p.vy -= 3.0 * dt
    }
    p.life -= dt
    if p.life <= 0.0 {
      p.active = false
    }
    // Terrain collision for debris
    if p.kind == @types.particle_debris {
      let ground = @types.terrain_height_at(p.x, p.z)
      if p.y < ground {
        p.active = false
      }
    }
  }
}

///|
fn update_messages(game : @types.Game, dt : Float) -> Unit {
  for message in game.messages {
    if message.timer > 0.0 {
      message.timer -= dt
    }
  }
}

///|
fn update_camera(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  let (fx, fy, fz) = @types.get_forward(player.pitch, player.yaw)
  if game.camera_mode == @types.camera_mode_chase {
    // Chase camera: behind and above the aircraft
    let (tcx, tcy, tcz) = @types.chase_camera_pos(
      player.x,
      player.y,
      player.z,
      fx,
      fy,
      fz,
      @types.camera_distance,
      @types.camera_height,
    )
    let sm = @types.camera_smooth * dt
    let sm_clamped : Float = if sm > 1.0 { 1.0 } else { sm }
    game.cam_x = @types.lerpf(game.cam_x, tcx, sm_clamped)
    game.cam_y = @types.lerpf(game.cam_y, tcy, sm_clamped)
    game.cam_z = @types.lerpf(game.cam_z, tcz, sm_clamped)
    // Look at point slightly ahead of aircraft
    game.cam_target_x = player.x + fx * 5.0
    game.cam_target_y = player.y + fy * 5.0
    game.cam_target_z = player.z + fz * 5.0
  } else if game.camera_mode == @types.camera_mode_cockpit {
    // Cockpit camera: at aircraft position, looking forward
    game.cam_x = player.x + fx * 0.5
    game.cam_y = player.y + 0.3
    game.cam_z = player.z + fz * 0.5
    game.cam_target_x = player.x + fx * 20.0
    game.cam_target_y = player.y + fy * 20.0
    game.cam_target_z = player.z + fz * 20.0
  } else {
    // Free camera: orbiting around aircraft
    let angle = Float::from_int(game.frame_counter) * 0.005
    let free_dist : Float = 18.0
    game.cam_x = player.x + @math.cosf(angle) * free_dist
    game.cam_y = player.y + 6.0
    game.cam_z = player.z + @math.sinf(angle) * free_dist
    game.cam_target_x = player.x
    game.cam_target_y = player.y
    game.cam_target_z = player.z
  }
  // Keep camera above terrain
  let cam_terrain = @types.terrain_height_at(game.cam_x, game.cam_z) + 2.0
  if game.cam_y < cam_terrain {
    game.cam_y = cam_terrain
  }
}

///|
fn update_terrain(game : @types.Game) -> Unit {
  let scale = @types.terrain_chunk_scale
  let cx = (game.player.x / scale).to_int()
  let cz = (game.player.z / scale).to_int()
  // Only rebuild if player moved to a new chunk region
  if cx == game.last_terrain_cx && cz == game.last_terrain_cz {
    return
  }
  game.last_terrain_cx = cx
  game.last_terrain_cz = cz
  // Deactivate all terrain
  for terrain_elem in game.terrain {
    terrain_elem.active = false
  }
  // Generate terrain around player
  let view = @types.terrain_view_range
  let mut tidx = 0
  for gx in (cx - view)..<=(cx + view) {
    for gz in (cz - view)..<=(cz + view) {
      if tidx >= game.terrain.length() {
        break
      }
      let world_x = Float::from_int(gx) * scale
      let world_z = Float::from_int(gz) * scale
      let h = @types.terrain_height_at(world_x, world_z)
      let t = game.terrain[tidx]
      t.active = true
      t.grid_x = gx
      t.grid_z = gz
      t.height = h
      // Color based on height with biome variation
      if h < @types.terrain_water_level {
        // Water level
        t.color_r = 30
        t.color_g = 80
        t.color_b = 160
      } else if h < 3.0 {
        // Beach / sand
        t.color_r = 180
        t.color_g = 170
        t.color_b = 120
      } else if h < @types.terrain_forest_level {
        // Low grass
        t.color_r = 50
        t.color_g = 130
        t.color_b = 50
      } else if h < 8.0 {
        // Dense forest
        t.color_r = 30
        t.color_g = 100
        t.color_b = 30
      } else if h < 10.0 {
        // Hills
        t.color_r = 80
        t.color_g = 110
        t.color_b = 50
      } else if h < @types.terrain_snow_level {
        // Rock
        t.color_r = 120
        t.color_g = 110
        t.color_b = 100
      } else {
        // Snow caps
        t.color_r = 220
        t.color_g = 225
        t.color_b = 230
      }
      tidx += 1
    }
  }
}

///|
fn update_clouds(game : @types.Game) -> Unit {
  // Generate clouds around player if needed
  let player = game.player
  let mut active_count = 0
  for cloud in game.clouds {
    if cloud.active {
      active_count += 1
      // Remove clouds that are too far away
      let d = @types.distance2d(player.x, player.z, cloud.x, cloud.z)
      if d > 200.0 {
        cloud.active = false
        active_count -= 1
      }
    }
  }
  // Spawn new clouds if below target count
  let target_clouds : Int = if game.weather_state.kind == @types.weather_clear {
    8
  } else if game.weather_state.kind == @types.weather_cloudy ||
    game.weather_state.kind == @types.weather_rain {
    25
  } else if game.weather_state.kind == @types.weather_storm {
    30
  } else {
    12
  }
  if active_count < target_clouds {
    let count_to_spawn = target_clouds - active_count
    for j in 0..<count_to_spawn {
      let idx = @types.alloc_cloud(game)
      if idx >= 0 {
        let c = game.clouds[idx]
        c.active = true
        c.x = player.x + @types.rand_rangef(game, -150.0, 150.0)
        c.y = game.weather_state.cloud_height +
          @types.rand_rangef(game, -5.0, 10.0)
        c.z = player.z + @types.rand_rangef(game, -150.0, 150.0)
        c.size_x = @types.rand_rangef(game, 6.0, 15.0)
        c.size_y = @types.rand_rangef(game, 2.0, 5.0)
        c.size_z = @types.rand_rangef(game, 5.0, 12.0)
        let base_alpha : Int = if game.weather_state.kind ==
          @types.weather_storm {
          160
        } else {
          100
        }
        c.alpha = base_alpha + @types.rand_range(game, 0, 40)
      }
      ignore(j)
    }
  }
}

///|
fn update_checkpoints(game : @types.Game) -> Unit {
  let player = game.player
  for cp in game.checkpoints {
    if not(cp.active) {
      continue
    }
    if cp.collected {
      continue
    }
    let dist = @types.distance3d(player.x, player.y, player.z, cp.x, cp.y, cp.z)
    if dist < cp.radius {
      cp.collected = true
      game.score += @types.score_checkpoint
      game.mission_score += @types.score_checkpoint
      let mission = game.missions[game.current_mission]
      mission.targets_done += 1
      @types.spawn_particles(game, cp.x, cp.y, cp.z, 15, 50, 255, 50)
      @types.show_message(
        game,
        "Checkpoint! \{mission.targets_done}/\{mission.target_count}",
        2.0,
      )
    }
  }
}

///|
fn update_turrets(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  for t in game.turrets {
    if not(t.active) {
      continue
    }
    // Flash timer
    if t.flash_timer > 0.0 {
      t.flash_timer -= dt
    }
    let dist = @types.distance3d(t.x, t.y, t.z, player.x, player.y, player.z)
    if dist > t.range {
      continue
    }
    // Rotate towards player
    let target_rot = @types.bearing_to(t.x, t.z, player.x, player.z)
    let rot_diff = @types.angle_diff(t.rotation, target_rot)
    let rot_step = @types.turret_rotation_speed * dt
    if @types.absf(rot_diff) < rot_step {
      t.rotation = target_rot
    } else if rot_diff > 0.0 {
      t.rotation += rot_step
    } else {
      t.rotation -= rot_step
    }
    // Calculate elevation
    let dy = player.y - t.y
    let dh = @types.distance2d(t.x, t.z, player.x, player.z)
    t.elevation = @math.atan2f(dy, dh)
    // Fire at player
    t.fire_timer -= dt
    if t.fire_timer <= 0.0 && @types.absf(rot_diff) < 0.3 {
      turret_fire(game, t, player)
      t.fire_timer = @types.turret_fire_rate
    }
  }
}

///|
fn turret_fire(
  game : @types.Game,
  t : @types.Turret,
  player : @types.Player,
) -> Unit {
  let idx = @types.alloc_projectile(game)
  if idx < 0 {
    return
  }
  let dx = player.x - t.x
  let dy = player.y - t.y
  let dz = player.z - t.z
  let (nx, ny, nz) = @types.normalize3d(dx, dy, dz)
  let proj = game.projectiles[idx]
  proj.active = true
  proj.kind = @types.proj_aa_shell
  proj.x = t.x + nx * 2.0
  proj.y = t.y + 1.5 + ny * 2.0
  proj.z = t.z + nz * 2.0
  proj.dx = nx
  proj.dy = ny
  proj.dz = nz
  proj.speed = @types.turret_shell_speed
  proj.damage = 15.0
  proj.life = 3.0
  proj.is_enemy = true
  proj.gravity_affected = false
  proj.blast_radius = 0.0
  t.flash_timer = 0.15
}

///|
fn update_buildings_projectile_check(game : @types.Game) -> Unit {
  // Check if any player projectiles hit buildings
  for proj in game.projectiles {
    if not(proj.active) {
      continue
    }
    if proj.is_enemy {
      continue
    }
    for b in game.buildings {
      if not(b.active) {
        continue
      }
      if not(b.destructible) {
        continue
      }
      let hit = @types.point_in_aabb(
        proj.x,
        proj.y,
        proj.z,
        b.x,
        b.y + b.height / 2.0,
        b.z,
        b.width / 2.0 + 1.0,
        b.height / 2.0 + 1.0,
        b.depth / 2.0 + 1.0,
      )
      if hit {
        proj.active = false
        b.hp -= proj.damage
        b.flash_timer = 0.2
        @types.spawn_particles(game, proj.x, proj.y, proj.z, 5, 200, 150, 80)
        if b.hp <= 0.0 {
          b.active = false
          game.buildings_destroyed += 1
          game.score += @types.score_building_destroy
          game.mission_score += @types.score_building_destroy
          @types.spawn_large_explosion(game, b.x, b.y + b.height / 2.0, b.z)
          // Check if it counts as mission target
          let mission = game.missions[game.current_mission]
          if mission.kind == @types.mission_bombing_run ||
            mission.kind == @types.mission_attack_base {
            mission.targets_done += 1
            @types.show_message(
              game,
              "Building destroyed! \{mission.targets_done}/\{mission.target_count}",
              2.0,
            )
          }
        }
        break
      }
    }
  }
  // Also check projectiles vs turrets
  for proj in game.projectiles {
    if not(proj.active) {
      continue
    }
    if proj.is_enemy {
      continue
    }
    for t in game.turrets {
      if not(t.active) {
        continue
      }
      let dist = @types.distance3d(proj.x, proj.y, proj.z, t.x, t.y + 1.0, t.z)
      if dist < 2.5 {
        proj.active = false
        t.hp -= proj.damage
        t.flash_timer = 0.15
        @types.spawn_particles(game, t.x, t.y + 1.0, t.z, 4, 255, 150, 50)
        if t.hp <= 0.0 {
          t.active = false
          game.kills += 1
          game.score += @types.score_turret_kill
          game.mission_score += @types.score_turret_kill
          @types.spawn_explosion(game, t.x, t.y + 1.0, t.z)
          let mission = game.missions[game.current_mission]
          if mission.kind == @types.mission_destroy ||
            mission.kind == @types.mission_bombing_run ||
            mission.kind == @types.mission_attack_base ||
            mission.kind == @types.mission_boss {
            mission.targets_done += 1
            @types.show_message(
              game,
              "Turret destroyed! \{mission.targets_done}/\{mission.target_count}",
              2.0,
            )
          }
        }
        break
      }
    }
  }
}

///|
fn update_warnings(game : @types.Game, dt : Float) -> Unit {
  let player = game.player
  game.warning_flash_timer += dt * 4.0
  // Fuel warning
  let fuel_ratio = player.fuel / player.max_fuel
  game.fuel_warning = fuel_ratio < @types.fuel_warning_threshold
  // Stall warning
  let stats = @types.get_aircraft_stats(player.aircraft_type)
  game.stall_warning = player.speed <
    stats.min_speed * @types.stall_warning_speed_ratio
  // Altitude warning
  let alt_agl = @types.altitude_above_terrain(player.x, player.y, player.z)
  game.altitude_warning = alt_agl < 5.0
  // Damage warning
  game.damage_warning = player.hp < player.max_hp * 0.3
  // Incoming fire warning
  let mut incoming = false
  for p in game.projectiles {
    if not(p.active) {
      continue
    }
    if not(p.is_enemy) {
      continue
    }
    let d = @types.distance3d(p.x, p.y, p.z, player.x, player.y, player.z)
    if d < 30.0 {
      incoming = true
      break
    }
  }
  game.incoming_warning = incoming
}

///|
fn update_weather_effects(game : @types.Game, dt : Float) -> Unit {
  let ws = game.weather_state
  // Spawn rain particles in storm/rain weather
  if ws.rain_intensity > 0.0 {
    let rain_count : Float = ws.rain_intensity * 3.0
    let spawn_count = rain_count.to_int()
    for i in 0..<spawn_count {
      let idx = @types.alloc_particle(game)
      if idx >= 0 {
        let p = game.particles[idx]
        p.active = true
        p.kind = @types.particle_rain
        p.x = game.player.x + @types.rand_rangef(game, -40.0, 40.0)
        p.y = game.player.y + @types.rand_rangef(game, 10.0, 30.0)
        p.z = game.player.z + @types.rand_rangef(game, -40.0, 40.0)
        p.vx = ws.wind_dir_x * ws.wind_speed
        p.vy = -20.0
        p.vz = ws.wind_dir_z * ws.wind_speed
        p.life = 1.5
        p.max_life = 1.5
        p.r = 150
        p.g = 170
        p.b = 200
        p.size = 0.03
      }
      ignore(i)
    }
  }
  ignore(dt)
}

///|
pub fn start_mission(game : @types.Game, mission_idx : Int) -> Unit {
  game.current_mission = mission_idx
  let mission = game.missions[mission_idx]
  mission.targets_done = 0
  game.mission_timer = 0.0
  game.mission_score = 0
  game.landing_approach = false
  game.landing_timer = 0.0
  // Reset player
  let player = game.player
  let stats = @types.get_aircraft_stats(game.selected_aircraft)
  player.apply_stats(stats)
  player.x = 0.0
  player.y = 30.0
  player.z = 0.0
  player.pitch = 0.0
  player.yaw = 0.0
  player.roll = 0.0
  player.speed = (stats.max_speed + stats.min_speed) / 2.0
  player.throttle = 0.5
  player.fire_timer = 0.0
  player.damage_flash = 0.0
  player.alive = true
  player.current_weapon = @types.weapon_machine_gun
  player.stalling = false
  player.stall_timer = 0.0
  player.damage_smoke = false
  player.engine_on = true
  player.landing_gear = false
  player.flaps = 0.0
  player.trim = 0.0
  player.gforce = 1.0
  player.prev_vy = 0.0
  player.shots_fired = 0
  player.shots_hit = 0
  player.weapon_switch_timer = 0.0
  // Set weather
  game.weather = mission.weather
  game.weather_state.set_weather(mission.weather)
  game.draw_distance = game.weather_state.visibility
  // Camera
  game.camera_mode = @types.camera_mode_chase
  // Reset warnings
  game.fuel_warning = false
  game.stall_warning = false
  game.altitude_warning = false
  game.damage_warning = false
  game.incoming_warning = false
  // Clear entities
  for enemy in game.enemies {
    enemy.active = false
  }
  for turret in game.turrets {
    turret.active = false
  }
  for projectile in game.projectiles {
    projectile.active = false
  }
  for particle in game.particles {
    particle.active = false
  }
  for checkpoint in game.checkpoints {
    checkpoint.active = false
    checkpoint.collected = false
  }
  for building in game.buildings {
    building.active = false
  }
  for cloud in game.clouds {
    cloud.active = false
  }
  for terrain_elem in game.terrain {
    terrain_elem.active = false
  }
  for message in game.messages {
    message.timer = 0.0
  }
  game.last_terrain_cx = -9999
  game.last_terrain_cz = -9999
  // Spawn checkpoints if checkpoint/canyon mission
  if mission.kind == @types.mission_checkpoint ||
    mission.kind == @types.mission_canyon_run ||
    mission.kind == @types.mission_recon {
    let cp_count : Int = if mission.kind == @types.mission_recon {
      mission.target_count
    } else {
      mission.target_count
    }
    for i in 0..<cp_count {
      let idx = @types.alloc_checkpoint(game)
      if idx >= 0 {
        let (cx, cy, cz) = @levels.get_checkpoint_pos(mission_idx, i)
        let cp = game.checkpoints[idx]
        cp.active = true
        cp.x = cx
        cp.y = cy
        cp.z = cz
        cp.radius = @types.checkpoint_radius
        cp.collected = false
        cp.order = i
      }
    }
  }
  // Spawn ground enemies
  for i in 0..<mission.enemy_count {
    let idx = @types.alloc_enemy(game)
    if idx >= 0 {
      let (ex, _ey, ez) = @levels.get_ground_enemy_pos(mission_idx, i)
      let e = game.enemies[idx]
      e.active = true
      e.kind = @types.enemy_type_ground
      e.x = ex
      e.y = @types.terrain_height_at(ex, ez) + 1.0
      e.z = ez
      e.vx = 0.0
      e.vy = 0.0
      e.vz = 0.0
      e.hp = @types.enemy_hp_ground
      e.max_hp = @types.enemy_hp_ground
      e.speed = 0.0
      e.size = @types.enemy_ground_size
      e.fire_timer = @types.rand_rangef(game, 0.0, @types.enemy_fire_rate)
      e.flash_timer = 0.0
      e.orbit_angle = 0.0
      e.orbit_radius = 0.0
      e.target_y = e.y
      e.ai_state = @types.ai_patrol
      e.patrol_cx = ex
      e.patrol_cz = ez
      e.patrol_index = 0
      e.aggression = 0.5
      e.maneuver_timer = 0.0
      e.evade_timer = 0.0
      e.heading = 0.0
    }
  }
  // Spawn air enemies
  for i in 0..<mission.enemy_air_count {
    let idx = @types.alloc_enemy(game)
    if idx >= 0 {
      let (ex, ey, ez) = @levels.get_air_enemy_pos(mission_idx, i)
      let e = game.enemies[idx]
      e.active = true
      e.kind = @types.enemy_type_air
      e.x = ex
      e.y = ey
      e.z = ez
      e.vx = 0.0
      e.vy = 0.0
      e.vz = 0.0
      e.hp = @types.enemy_hp_air
      e.max_hp = @types.enemy_hp_air
      e.speed = @types.enemy_air_speed
      e.size = @types.enemy_air_size
      e.fire_timer = @types.rand_rangef(game, 0.0, @types.enemy_fire_rate)
      e.flash_timer = 0.0
      e.orbit_angle = @types.rand_rangef(game, 0.0, @types.pi * 2.0)
      e.orbit_radius = @types.rand_rangef(game, 25.0, 50.0)
      e.target_y = ey
      e.ai_state = @types.ai_patrol
      e.patrol_cx = ex
      e.patrol_cz = ez
      e.patrol_index = 0
      e.aggression = @types.rand_rangef(game, 0.3, 0.8)
      e.maneuver_timer = 0.0
      e.evade_timer = 0.0
      e.heading = @types.rand_rangef(game, 0.0, @types.two_pi)
    }
  }
  // Spawn turrets
  for i in 0..<mission.turret_count {
    let idx = @types.alloc_turret(game)
    if idx >= 0 {
      let (tx, _ty, tz) = @levels.get_turret_pos(mission_idx, i)
      let t = game.turrets[idx]
      t.active = true
      t.x = tx
      t.y = @types.terrain_height_at(tx, tz) + 0.5
      t.z = tz
      t.rotation = 0.0
      t.elevation = 0.0
      t.fire_timer = @types.rand_rangef(game, 0.0, @types.turret_fire_rate)
      t.range = @types.turret_range
      t.hp = @types.turret_hp
      t.max_hp = @types.turret_hp
      t.flash_timer = 0.0
    }
  }
  // Spawn buildings
  for i in 0..<mission.building_count {
    let idx = @types.alloc_building(game)
    if idx >= 0 {
      let (bx, _by, bz, bkind) = @levels.get_building_info(mission_idx, i)
      let b = game.buildings[idx]
      b.active = true
      b.kind = bkind
      b.x = bx
      b.y = @types.terrain_height_at(bx, bz)
      b.z = bz
      b.flash_timer = 0.0
      // Set size based on building type
      if bkind == @types.building_hangar {
        b.width = 8.0
        b.height = 4.0
        b.depth = 12.0
        b.hp = 200.0
        b.max_hp = 200.0
        b.destructible = true
      } else if bkind == @types.building_tower {
        b.width = 2.0
        b.height = 10.0
        b.depth = 2.0
        b.hp = 80.0
        b.max_hp = 80.0
        b.destructible = true
      } else if bkind == @types.building_runway {
        b.width = 5.0
        b.height = 0.2
        b.depth = 20.0
        b.hp = 500.0
        b.max_hp = 500.0
        b.destructible = false
      } else if bkind == @types.building_house {
        b.width = 4.0
        b.height = 3.0
        b.depth = 4.0
        b.hp = 60.0
        b.max_hp = 60.0
        b.destructible = true
      } else if bkind == @types.building_factory {
        b.width = 10.0
        b.height = 6.0
        b.depth = 8.0
        b.hp = 250.0
        b.max_hp = 250.0
        b.destructible = true
      } else {
        // Bunker
        b.width = 5.0
        b.height = 2.0
        b.depth = 5.0
        b.hp = 300.0
        b.max_hp = 300.0
        b.destructible = true
      }
    }
  }
  game.state = @types.state_playing
  @types.show_message(game, mission.name + ": " + mission.description, 4.0)
}
