// Main game update dispatcher

///|
pub fn update_game(game : @types.Game, dt : Float) -> Unit {
  game.frame_counter += 1
  update_particles(game, dt)
  update_debris(game, dt)

  // Camera shake decay
  if game.camera_shake > 0.0 {
    game.camera_shake -= dt * 2.0
    if game.camera_shake < 0.0 {
      game.camera_shake = 0.0
    }
  }

  // Message timer
  if game.message_timer > 0.0 {
    game.message_timer -= dt
  }

  // Screen flash decay
  if game.screen_flash > 0.0 {
    game.screen_flash -= dt * 3.0
    if game.screen_flash < 0.0 {
      game.screen_flash = 0.0
    }
  }

  // Kill feed timer
  for i in 0..<@types.max_kill_feed {
    if game.kill_feed[i].active {
      game.kill_feed[i].timer -= dt
      if game.kill_feed[i].timer <= 0.0 {
        game.kill_feed[i].active = false
      }
    }
  }

  if game.state == @types.state_menu {
    update_menu(game, dt)
  } else if game.state == @types.state_playing {
    update_playing(game, dt)
  } else if game.state == @types.state_paused {
    update_paused(game)
  } else if game.state == @types.state_mission_complete {
    update_mission_complete(game)
  } else if game.state == @types.state_game_over {
    update_game_over(game)
  } else if game.state == @types.state_mission_briefing {
    update_mission_briefing(game)
  } else if game.state == @types.state_mission_select {
    update_mission_select(game)
  } else if game.state == @types.state_loadout {
    update_loadout(game)
  }
}

///|
fn update_menu(game : @types.Game, dt : Float) -> Unit {
  game.menu_blink += dt * 3.5
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.menu_cursor -= 1
    if game.menu_cursor < 0 {
      game.menu_cursor = 3
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.menu_cursor += 1
    if game.menu_cursor > 3 {
      game.menu_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if game.menu_cursor == 0 {
      // New game - go to loadout
      game.current_mission = 0
      game.score = 0
      game.total_kills = 0
      game.state = @types.state_loadout
      game.loadout_cursor = 0
    } else if game.menu_cursor == 1 {
      // Mission select
      game.state = @types.state_mission_select
      game.select_cursor = game.current_mission
    } else if game.menu_cursor == 2 {
      // Continue from current mission
      game.state = @types.state_mission_briefing
      game.briefing_scroll = 0
    } else {
      // Quick start
      start_mission(game, 0)
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

  update_player(game, dt)
  update_enemies(game, dt)
  update_asteroids(game, dt)
  update_projectiles(game, dt)
  update_powerups(game, dt)
  update_stations(game, dt)
  @types.update_combo(game, dt)

  // Player damage flash decay
  if game.player.damage_flash > 0.0 {
    game.player.damage_flash -= dt * 4.0
    if game.player.damage_flash < 0.0 {
      game.player.damage_flash = 0.0
    }
  }

  // Enemy damage flash decay
  for enemy in game.enemies {
    if enemy.active && enemy.damage_flash > 0.0 {
      enemy.damage_flash -= dt * 4.0
      if enemy.damage_flash < 0.0 {
        enemy.damage_flash = 0.0
      }
    }
  }

  // Player boost timer decay
  if game.player.weapon_boost_timer > 0.0 {
    game.player.weapon_boost_timer -= dt
    if game.player.weapon_boost_timer < 0.0 {
      game.player.weapon_boost_timer = 0.0
    }
  }
  if game.player.speed_boost_timer > 0.0 {
    game.player.speed_boost_timer -= dt
    if game.player.speed_boost_timer < 0.0 {
      game.player.speed_boost_timer = 0.0
    }
  }

  // Weapon energy regeneration
  if game.player.weapon_energy < @types.max_weapon_energy {
    game.player.weapon_energy += @types.weapon_energy_regen * dt
    if game.player.weapon_energy > @types.max_weapon_energy {
      game.player.weapon_energy = @types.max_weapon_energy
    }
  }

  // Boost fuel regeneration (when not boosting)
  if not(game.player.boosting) && game.player.boost_fuel < @types.max_boost_fuel {
    game.player.boost_fuel += @types.boost_fuel_regen * dt
    if game.player.boost_fuel > @types.max_boost_fuel {
      game.player.boost_fuel = @types.max_boost_fuel
    }
  }

  // Wave spawning
  if game.wave_number < game.waves_total {
    game.wave_timer -= dt
    if game.wave_timer <= 0.0 {
      spawn_wave(game, game.current_mission, game.wave_number)
      game.wave_number += 1
      if game.wave_number < game.waves_total {
        game.wave_timer = @levels.wave_spawn_delay(
          game.current_mission,
          game.wave_number,
        )
      }
      if game.wave_number > 1 {
        game.message_text = "WAVE \{game.wave_number}"
        game.message_timer = 2.0
      }
    }
  }

  // Validate target
  if game.target_idx >= 0 {
    if game.target_idx >= game.enemies.length() ||
      not(game.enemies[game.target_idx].active) {
      game.target_idx = -1
    }
  }

  // Update target lock timer
  if game.target_idx >= 0 {
    game.target_lock_timer += dt
  }

  // Check mission objectives
  game.mission_timer += dt
  game.mission_time += dt

  // Check mission complete conditions
  let obj_type = @levels.mission_objective_type(game.current_mission)
  if obj_type == @types.objective_destroy_all {
    if @types.count_active_enemies(game) == 0 &&
      game.wave_number >= game.waves_total {
      complete_mission(game)
    }
  } else if obj_type == @types.objective_destroy_count {
    let target_count = @levels.mission_objective_target(game.current_mission)
    if game.mission_kills >= target_count {
      complete_mission(game)
    }
  } else if obj_type == @types.objective_boss_fight {
    // Check if all capital ships are destroyed
    if @types.count_enemies_of_type(game, @types.enemy_capital) == 0 &&
      game.wave_number >= game.waves_total {
      complete_mission(game)
    }
  } else if obj_type == @types.objective_defend_station {
    // Check if all enemies eliminated while station survives
    let station_alive = check_station_alive(game, @types.station_friendly)
    if not(station_alive) {
      game.state = @types.state_game_over
      game.message_text = "STATION DESTROYED"
      game.message_timer = 3.0
    } else if @types.count_active_enemies(game) == 0 &&
      game.wave_number >= game.waves_total {
      complete_mission(game)
    }
    // Default: destroy all
  } else if @types.count_active_enemies(game) == 0 &&
    game.wave_number >= game.waves_total {
    complete_mission(game)
  }
}

///|
fn complete_mission(game : @types.Game) -> Unit {
  game.state = @types.state_mission_complete
  game.message_text = "MISSION COMPLETE"
  game.message_timer = 3.0
  // Award mission reward
  let reward = @levels.mission_reward(game.current_mission)
  game.score += reward
}

///|
fn check_station_alive(game : @types.Game, kind : Int) -> Bool {
  for station in game.stations {
    if station.active && station.kind == kind {
      return true
    }
  }
  false
}

///|
fn update_paused(game : @types.Game) -> Unit {
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
  if @raylib.is_key_pressed(@raylib.KeyEscape) ||
    @raylib.is_key_pressed(@raylib.KeyP) {
    game.state = @types.state_playing
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) {
    if game.pause_cursor == 0 {
      // Resume
      game.state = @types.state_playing
    } else if game.pause_cursor == 1 {
      // Restart mission
      start_mission(game, game.current_mission)
    } else {
      // Quit to menu
      game.state = @types.state_menu
      game.menu_cursor = 0
    }
  }
}

///|
fn update_mission_complete(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    let next = game.current_mission + 1
    if next >= @types.total_missions {
      // Completed all missions
      game.state = @types.state_menu
    } else {
      game.current_mission = next
      game.state = @types.state_mission_briefing
      game.briefing_scroll = 0
    }
  }
}

///|
fn update_game_over(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    if @raylib.is_key_down(@raylib.KeyLeftShift) {
      // Hold shift+enter to restart the same mission
      start_mission(game, game.current_mission)
    } else {
      game.state = @types.state_menu
    }
  }
  // R to restart
  if @raylib.is_key_pressed(@raylib.KeyR) {
    start_mission(game, game.current_mission)
  }
}

///|
fn update_mission_briefing(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    start_mission(game, game.current_mission)
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_menu
    game.menu_cursor = 0
  }
}

///|
fn update_mission_select(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.select_cursor -= 1
    if game.select_cursor < 0 {
      game.select_cursor = @types.total_missions - 1
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.select_cursor += 1
    if game.select_cursor >= @types.total_missions {
      game.select_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.current_mission = game.select_cursor
    game.state = @types.state_loadout
    game.loadout_cursor = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_menu
    game.menu_cursor = 0
  }
}

///|
fn update_loadout(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) {
    game.loadout_cursor -= 1
    if game.loadout_cursor < 0 {
      game.loadout_cursor = 4
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) {
    game.loadout_cursor += 1
    if game.loadout_cursor > 4 {
      game.loadout_cursor = 0
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyRight) {
    // Cycle selected ship class
    if game.loadout_cursor < 5 {
      game.selected_ship_class = game.loadout_cursor
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyEnter) ||
    @raylib.is_key_pressed(@raylib.KeySpace) {
    game.selected_ship_class = game.loadout_cursor
    game.state = @types.state_mission_briefing
    game.briefing_scroll = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyEscape) {
    game.state = @types.state_menu
    game.menu_cursor = 0
  }
}

///|
fn start_mission(game : @types.Game, mission : Int) -> Unit {
  game.current_mission = mission
  game.state = @types.state_playing
  game.mission_timer = 0.0
  game.mission_time = 0.0
  game.mission_kills = 0
  game.target_idx = -1
  game.target_lock_timer = 0.0
  game.combo_count = 0
  game.combo_timer = 0.0
  game.combo_multiplier = 1.0

  // Reset player based on selected ship class
  let p = game.player
  let sc = game.selected_ship_class
  p.x = 0.0
  p.y = 0.0
  p.z = 0.0
  p.yaw = 0.0
  p.pitch = 0.0
  p.roll = 0.0
  p.vx = 0.0
  p.vy = 0.0
  p.vz = 0.0
  p.ship_class = sc
  p.max_hull = @types.ship_class_hull(sc)
  p.hull = p.max_hull
  p.max_shield = @types.ship_class_shield(sc)
  p.shield = p.max_shield
  p.shield_timer = 0.0
  p.weapon = @types.weapon_laser
  p.fire_timer = 0.0
  p.boosting = false
  p.speed = @types.ship_class_speed(sc)
  p.turn_rate = @types.ship_class_turn(sc)
  p.weapon_level = 1
  p.missile_ammo = @types.missile_max_ammo
  p.weapon_energy = @types.max_weapon_energy
  p.boost_fuel = @types.max_boost_fuel
  p.weapon_boost_timer = 0.0
  p.speed_boost_timer = 0.0
  p.damage_flash = 0.0
  p.strafe_x = 0.0
  p.strafe_y = 0.0
  p.kills = 0
  p.shots_fired = 0
  p.shots_hit = 0

  // Clear pools
  for enemy in game.enemies {
    enemy.active = false
  }
  for projectile in game.projectiles {
    projectile.active = false
  }
  for particle in game.particles {
    particle.active = false
  }
  for asteroid in game.asteroids {
    asteroid.active = false
  }
  for powerup in game.powerups {
    powerup.active = false
  }
  for station in game.stations {
    station.active = false
  }
  for debri in game.debris {
    debri.active = false
  }
  for i in 0..<@types.max_kill_feed {
    game.kill_feed[i].active = false
  }

  // Load mission basic data
  let def = @levels.get_mission_def(mission)
  let num_asteroids = def.2
  let ext = @levels.get_mission_extended(mission)

  // Setup waves
  game.waves_total = ext.6
  game.wave_number = 0
  game.wave_timer = 0.0

  // Calculate total enemies for remaining counter
  let mut total_enemies = 0
  for w in 0..<game.waves_total {
    let wave_comp = @levels.wave_composition(mission, w)
    total_enemies = total_enemies +
      wave_comp.0 +
      wave_comp.1 +
      wave_comp.2 +
      wave_comp.3
  }
  game.enemies_remaining = total_enemies

  // Spawn asteroids
  for i in 0..<num_asteroids {
    let idx = @types.alloc_asteroid(game)
    if idx < 0 {
      break
    }
    let a = game.asteroids[idx]
    a.active = true
    a.x = @types.rand_rangef(game, -250.0, 250.0)
    a.y = @types.rand_rangef(game, -100.0, 100.0)
    a.z = @types.rand_rangef(game, -250.0, 250.0)
    a.vx = @types.rand_rangef(game, -3.0, 3.0)
    a.vy = @types.rand_rangef(game, -1.0, 1.0)
    a.vz = @types.rand_rangef(game, -3.0, 3.0)
    a.rot_x = @types.rand_rangef(game, 0.0, 6.28)
    a.rot_y = @types.rand_rangef(game, 0.0, 6.28)
    a.rot_z = @types.rand_rangef(game, 0.0, 6.28)
    a.rot_speed = @types.rand_rangef(game, 0.2, 1.5)
    // Size tier
    let tier_roll = @types.rand_range(game, 0, 2)
    if tier_roll == 0 {
      a.size_tier = @types.asteroid_large
      a.size = @types.asteroid_large_size
      a.hp = @types.asteroid_large_hp
    } else if tier_roll == 1 {
      a.size_tier = @types.asteroid_medium
      a.size = @types.asteroid_medium_size
      a.hp = @types.asteroid_medium_hp
    } else {
      a.size_tier = @types.asteroid_small
      a.size = @types.asteroid_small_size
      a.hp = @types.asteroid_small_hp
    }
    a.breakable = a.size_tier != @types.asteroid_small
    ignore(i)
  }

  // Spawn stations
  let num_friendly_stations = ext.3
  let num_enemy_stations = ext.4
  for i in 0..<num_friendly_stations {
    let idx = @types.alloc_station(game)
    if idx < 0 {
      break
    }
    let s = game.stations[idx]
    s.active = true
    s.kind = @types.station_friendly
    let pos = @levels.mission_station_pos(mission, i)
    s.x = pos.0
    s.y = pos.1
    s.z = pos.2
    s.hp = @types.station_hp
    s.max_hp = @types.station_hp
    s.rot_angle = 0.0
    s.ring_angle = 0.0
    ignore(i)
  }
  for i in 0..<num_enemy_stations {
    let idx = @types.alloc_station(game)
    if idx < 0 {
      break
    }
    let s = game.stations[idx]
    s.active = true
    s.kind = @types.station_enemy
    let pos = @levels.mission_station_pos(mission, num_friendly_stations + i)
    s.x = pos.0
    s.y = pos.1
    s.z = pos.2
    s.hp = @types.station_hp
    s.max_hp = @types.station_hp
    s.rot_angle = 0.0
    s.ring_angle = 0.0
    ignore(i)
  }

  // Spawn initial power-ups
  let num_powerups = ext.5
  for i in 0..<num_powerups {
    let idx = @types.alloc_powerup(game)
    if idx < 0 {
      break
    }
    let pu = game.powerups[idx]
    let pos = @levels.powerup_spawn_pos(mission, i)
    pu.active = true
    pu.kind = pos.3
    pu.x = pos.0
    pu.y = pos.1
    pu.z = pos.2
    pu.bob_timer = @types.rand_rangef(game, 0.0, 6.28)
    pu.spin_angle = 0.0
    pu.life = 60.0
    ignore(i)
  }

  // Setup objectives
  let obj_type = @levels.mission_objective_type(mission)
  game.objectives_count = 1
  game.objectives[0].obj_type = obj_type
  game.objectives[0].current_count = 0
  game.objectives[0].complete = false
  if obj_type == @types.objective_destroy_all {
    game.objectives[0].target_count = total_enemies
    game.objectives[0].description = "Destroy all enemies"
  } else if obj_type == @types.objective_destroy_count {
    let target = @levels.mission_objective_target(mission)
    game.objectives[0].target_count = target
    game.objectives[0].description = "Destroy \{target} enemies"
  } else if obj_type == @types.objective_boss_fight {
    game.objectives[0].target_count = 1
    game.objectives[0].description = "Destroy the capital ship"
  } else if obj_type == @types.objective_defend_station {
    game.objectives[0].target_count = total_enemies
    game.objectives[0].description = "Defend the station"
  } else {
    game.objectives[0].target_count = total_enemies
    game.objectives[0].description = "Complete objectives"
  }

  game.message_text = @levels.mission_name(mission)
  game.message_timer = 3.0
  game.camera_shake = 0.0
}

///|
fn spawn_wave(game : @types.Game, mission : Int, wave : Int) -> Unit {
  let comp = @levels.wave_composition(mission, wave)
  let hp_mult = @types.mission_difficulty_hp_mult(mission)
  let spd_mult = @types.mission_difficulty_speed_mult(mission)
  let formation = @levels.mission_formation(mission)

  // Spawn fighters
  for i in 0..<comp.0 {
    spawn_enemy_of_type(
      game, @types.enemy_fighter, hp_mult, spd_mult, formation, i, wave,
    )
    ignore(i)
  }

  // Spawn interceptors
  for i in 0..<comp.1 {
    spawn_enemy_of_type(
      game,
      @types.enemy_interceptor,
      hp_mult,
      spd_mult,
      formation,
      comp.0 + i,
      wave,
    )
    ignore(i)
  }

  // Spawn bombers
  for i in 0..<comp.2 {
    spawn_enemy_of_type(
      game,
      @types.enemy_bomber,
      hp_mult,
      spd_mult,
      formation,
      comp.0 + comp.1 + i,
      wave,
    )
    ignore(i)
  }

  // Spawn cruisers
  for i in 0..<comp.3 {
    spawn_enemy_of_type(
      game,
      @types.enemy_cruiser,
      hp_mult,
      spd_mult,
      formation,
      comp.0 + comp.1 + comp.2 + i,
      wave,
    )
    ignore(i)
  }

  // Spawn capital ships (from extended def, only for wave 0)
  if wave == 0 {
    let ext = @levels.get_mission_extended(mission)
    let num_capitals = ext.2
    for i in 0..<num_capitals {
      let idx = @types.alloc_enemy(game)
      if idx < 0 {
        break
      }
      let e = game.enemies[idx]
      let boss_cfg = @levels.mission_boss_config(mission)
      e.active = true
      e.kind = @types.enemy_capital
      e.hp = @types.capital_hp * hp_mult * boss_cfg.3
      e.max_hp = e.hp
      e.shield_hp = 100.0
      e.max_shield_hp = 100.0
      e.x = boss_cfg.0 + @types.rand_rangef(game, -30.0, 30.0)
      e.y = boss_cfg.1
      e.z = boss_cfg.2 + @types.rand_rangef(game, -20.0, 20.0)
      e.vx = 0.0
      e.vy = 0.0
      e.vz = 0.0
      e.yaw = 0.0
      e.pitch = 0.0
      e.fire_timer = 2.0
      e.ai_timer = 0.0
      e.ai_state = @types.ai_idle
      e.score_value = @types.capital_score
      e.size = 8.0
      e.squad_id = -1
      e.formation_index = 0
      e.aggression = 0.8
      e.flee_threshold = 0.0
      e.detect_range = 200.0
      e.damage_flash = 0.0
      e.turret_timer_1 = 1.0
      e.turret_timer_2 = 2.0
      e.weak_point_hp = @types.capital_weak_point_hp
      ignore(i)
    }
  }
}

///|
fn spawn_enemy_of_type(
  game : @types.Game,
  kind : Int,
  hp_mult : Float,
  spd_mult : Float,
  formation : Int,
  form_index : Int,
  wave : Int,
) -> Unit {
  let idx = @types.alloc_enemy(game)
  if idx < 0 {
    return
  }
  let e = game.enemies[idx]
  e.active = true
  e.kind = kind
  e.ai_state = @types.ai_patrol
  e.squad_id = wave
  e.formation_index = form_index
  e.damage_flash = 0.0

  // Spawn position: offset from center, further back in later waves
  let wave_offset = Float::from_int(wave) * 80.0
  let form_off = @types.formation_offset(formation, form_index, 8.0)
  e.x = form_off.0 + @types.rand_rangef(game, -30.0, 30.0)
  e.y = form_off.1 + @types.rand_rangef(game, -20.0, 20.0)
  e.z = 100.0 + wave_offset + form_off.2 + @types.rand_rangef(game, 0.0, 50.0)

  e.patrol_x = e.x
  e.patrol_y = e.y
  e.patrol_z = e.z

  if kind == @types.enemy_fighter {
    e.hp = @types.fighter_hp * hp_mult
    e.max_hp = e.hp
    e.shield_hp = 0.0
    e.max_shield_hp = 0.0
    e.vx = @types.rand_rangef(game, -5.0, 5.0)
    e.vy = @types.rand_rangef(game, -3.0, 3.0)
    e.vz = @types.rand_rangef(game, -5.0, 5.0)
    e.fire_timer = @types.rand_rangef(game, 1.0, 3.0)
    e.ai_timer = @types.rand_rangef(game, 0.0, 2.0)
    e.score_value = @types.fighter_score
    e.size = 1.5
    e.aggression = @types.rand_rangef(game, 0.4, 0.8)
    e.flee_threshold = @types.fighter_flee_hp_pct
    e.detect_range = @types.fighter_detect_range
  } else if kind == @types.enemy_interceptor {
    e.hp = @types.interceptor_hp * hp_mult
    e.max_hp = e.hp
    e.shield_hp = 0.0
    e.max_shield_hp = 0.0
    e.vx = @types.rand_rangef(game, -8.0, 8.0)
    e.vy = @types.rand_rangef(game, -4.0, 4.0)
    e.vz = @types.rand_rangef(game, -8.0, 8.0)
    e.fire_timer = @types.rand_rangef(game, 0.5, 1.5)
    e.ai_timer = @types.rand_rangef(game, 0.0, 1.0)
    e.score_value = @types.interceptor_score
    e.size = 1.2
    e.aggression = @types.rand_rangef(game, 0.6, 1.0)
    e.flee_threshold = 0.1
    e.detect_range = @types.interceptor_detect_range
  } else if kind == @types.enemy_bomber {
    e.hp = @types.bomber_hp * hp_mult
    e.max_hp = e.hp
    e.shield_hp = 20.0
    e.max_shield_hp = 20.0
    e.vx = @types.rand_rangef(game, -2.0, 2.0)
    e.vy = @types.rand_rangef(game, -1.0, 1.0)
    e.vz = @types.rand_rangef(game, -2.0, 2.0)
    e.fire_timer = @types.rand_rangef(game, 2.0, 4.0)
    e.ai_timer = @types.rand_rangef(game, 0.0, 2.0)
    e.score_value = @types.bomber_score
    e.size = 2.5
    e.aggression = @types.rand_rangef(game, 0.3, 0.6)
    e.flee_threshold = 0.2
    e.detect_range = 100.0
  } else if kind == @types.enemy_cruiser {
    e.hp = @types.cruiser_hp * hp_mult
    e.max_hp = e.hp
    e.shield_hp = 40.0
    e.max_shield_hp = 40.0
    e.vx = @types.rand_rangef(game, -2.0, 2.0)
    e.vy = @types.rand_rangef(game, -1.0, 1.0)
    e.vz = @types.rand_rangef(game, -2.0, 2.0)
    e.fire_timer = @types.rand_rangef(game, 1.0, 4.0)
    e.ai_timer = @types.rand_rangef(game, 0.0, 2.0)
    e.score_value = @types.cruiser_score
    e.size = 3.0
    e.aggression = @types.rand_rangef(game, 0.3, 0.5)
    e.flee_threshold = 0.1
    e.detect_range = 100.0
  }
  e.yaw = 0.0
  e.pitch = 0.0
  e.turret_timer_1 = 0.0
  e.turret_timer_2 = 0.0
  e.weak_point_hp = 0.0
  ignore(spd_mult)
}

///|
fn update_powerups(game : @types.Game, dt : Float) -> Unit {
  let p = game.player
  for i in 0..<game.powerups.length() {
    let pu = game.powerups[i]
    if not(pu.active) {
      continue
    }

    // Animation
    pu.bob_timer += @types.powerup_float_speed * dt
    pu.spin_angle += @types.powerup_spin_speed * dt
    pu.life -= dt
    if pu.life <= 0.0 {
      pu.active = false
      continue
    }

    // Check collection by player
    let dist = @types.distance3d(pu.x, pu.y, pu.z, p.x, p.y, p.z)
    if dist < @types.powerup_collect_radius {
      collect_powerup(game, i)
    }
  }
}

///|
fn collect_powerup(game : @types.Game, idx : Int) -> Unit {
  let pu = game.powerups[idx]
  let p = game.player
  pu.active = false

  if pu.kind == @types.powerup_health {
    p.hull += @types.powerup_health_amount
    if p.hull > p.max_hull {
      p.hull = p.max_hull
    }
    game.message_text = "HULL REPAIRED"
    game.message_timer = 1.5
    @types.add_kill_feed(game, "+HULL", 0, 255, 0)
  } else if pu.kind == @types.powerup_shield {
    p.shield += @types.powerup_shield_amount
    if p.shield > p.max_shield {
      p.shield = p.max_shield
    }
    game.message_text = "SHIELD BOOST"
    game.message_timer = 1.5
    @types.add_kill_feed(game, "+SHIELD", 80, 160, 255)
  } else if pu.kind == @types.powerup_weapon_boost {
    p.weapon_boost_timer = @types.powerup_weapon_duration
    game.message_text = "WEAPON POWER UP"
    game.message_timer = 1.5
    @types.add_kill_feed(game, "+WEAPON", 255, 200, 50)
  } else if pu.kind == @types.powerup_speed_boost {
    p.speed_boost_timer = @types.powerup_speed_duration
    game.message_text = "SPEED BOOST"
    game.message_timer = 1.5
    @types.add_kill_feed(game, "+SPEED", 255, 255, 100)
  }
  @types.spawn_particles(game, pu.x, pu.y, pu.z, 10, 255, 255, 200)

  // Screen flash for positive feedback
  game.screen_flash = 0.2
  game.flash_r = 100
  game.flash_g = 255
  game.flash_b = 100
}

///|
fn update_stations(game : @types.Game, dt : Float) -> Unit {
  for s in game.stations {
    if not(s.active) {
      continue
    }
    // Rotate the station
    s.rot_angle += 0.1 * dt
    s.ring_angle += 0.3 * dt

    // Check if station is destroyed
    if s.hp <= 0.0 {
      s.active = false
      @types.spawn_explosion(game, s.x, s.y, s.z, 40, 255, 200, 100)
      @types.spawn_debris(game, s.x, s.y, s.z, 8, 150, 150, 160)
      if s.kind == @types.station_enemy {
        game.score += 1000
        @types.add_kill_feed(game, "Station Destroyed!", 255, 200, 50)
      }
    }
  }
}

///|
fn update_debris(game : @types.Game, dt : Float) -> Unit {
  for d in game.debris {
    if not(d.active) {
      continue
    }
    d.life -= dt
    if d.life <= 0.0 {
      d.active = false
      continue
    }
    d.x += d.vx * dt
    d.y += d.vy * dt
    d.z += d.vz * dt
    d.rot_x += d.rot_speed * dt
    d.rot_y += d.rot_speed * 0.7 * dt
    // Slow down
    d.vx *= 0.99
    d.vy *= 0.99
    d.vz *= 0.99
  }
}
