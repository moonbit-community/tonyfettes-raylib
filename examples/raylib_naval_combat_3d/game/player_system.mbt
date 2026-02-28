// Player ship movement and controls

///|
fn update_player(game : @types.Game, dt : Float) -> Unit {
  let ship = game.player
  // Sail control: W/S to raise/lower sails
  if @raylib.is_key_down(@raylib.KeyW) {
    ship.sail_amount += dt * 0.8
    if ship.sail_amount > 1.0 {
      ship.sail_amount = 1.0
    }
  }
  if @raylib.is_key_down(@raylib.KeyS) {
    ship.sail_amount -= dt * 0.8
    if ship.sail_amount < 0.0 {
      ship.sail_amount = 0.0
    }
  }
  // Sail state management (1/2/3 keys for quick setting)
  if @raylib.is_key_pressed(@raylib.KeyOne) {
    ship.sail_state = @types.sail_furled
    ship.sail_amount = @types.sail_furled_mult
  }
  if @raylib.is_key_pressed(@raylib.KeyTwo) {
    ship.sail_state = @types.sail_half
    ship.sail_amount = @types.sail_half_mult
  }
  if @raylib.is_key_pressed(@raylib.KeyThree) {
    ship.sail_state = @types.sail_full
    ship.sail_amount = @types.sail_full_mult
  }
  // Update sail state based on amount
  if ship.sail_amount < 0.15 {
    ship.sail_state = @types.sail_furled
  } else if ship.sail_amount < 0.7 {
    ship.sail_state = @types.sail_half
  } else {
    ship.sail_state = @types.sail_full
  }
  // Wind-based speed calculation using sailing physics
  let mast_ratio : Float = if @types.get_class_max_mast(ship.ship_class) > 0.0 {
    ship.mast_hp / @types.get_class_max_mast(ship.ship_class)
  } else {
    1.0
  }
  let base_speed = @types.get_class_base_speed(ship.ship_class)
  let target_speed = @types.calc_sailing_speed(
    ship.heading,
    game.wind_angle,
    game.wind_speed,
    ship.sail_amount,
    mast_ratio,
    base_speed,
  )
  // Crew affects speed (need minimum crew to sail effectively)
  let crew_ratio = Float::from_int(ship.crew) / Float::from_int(ship.max_crew)
  let crew_speed_mult : Float = if crew_ratio > 0.5 {
    1.0
  } else if crew_ratio > 0.2 {
    0.5 + crew_ratio
  } else {
    0.3
  }
  let final_target = target_speed * crew_speed_mult
  // Lerp towards target speed
  ship.speed = @types.lerpf(ship.speed, final_target, dt * 2.0)
  // Rudder control: A/D to turn
  let rudder_ratio : Float = if @types.get_class_max_rudder(ship.ship_class) >
    0.0 {
    ship.rudder_hp / @types.get_class_max_rudder(ship.ship_class)
  } else {
    1.0
  }
  let turn = @types.calc_turn_rate(
      ship.turn_rate_base,
      rudder_ratio,
      ship.speed,
      base_speed,
    ) *
    dt
  if @raylib.is_key_down(@raylib.KeyA) {
    ship.heading -= turn
  }
  if @raylib.is_key_down(@raylib.KeyD) {
    ship.heading += turn
  }
  ship.heading = @types.normalize_angle(ship.heading)
  // Move
  let dx = @math.sinf(ship.heading) * ship.speed * dt
  let dz = @math.cosf(ship.heading) * ship.speed * dt
  // Wind drift
  let drift = @types.calc_wind_drift(
    ship.heading,
    game.wind_angle,
    game.wind_speed,
    ship.speed,
  )
  ship.drift_x = @types.lerpf(ship.drift_x, drift.0, dt * 2.0)
  ship.drift_z = @types.lerpf(ship.drift_z, drift.1, dt * 2.0)
  let new_x = ship.x + dx + ship.drift_x * dt * 0.3
  let new_z = ship.z + dz + ship.drift_z * dt * 0.3
  // Island collision
  if not(@types.check_island_collision(game, new_x, new_z, ship.ship_width)) {
    // Boundary check
    let half : Float = @types.ocean_size / 2.0 - 5.0
    ship.x = @types.clampf(new_x, -half, half)
    ship.z = @types.clampf(new_z, -half, half)
  } else {
    ship.speed = ship.speed * 0.3
    // Collision damage
    if ship.speed > 3.0 {
      ship.bow_hp -= ship.speed * 0.5
      if ship.bow_hp < 0.0 {
        ship.bow_hp = 0.0
      }
      ship.hull_hp -= ship.speed * 0.3
    }
  }
  // Ammo type switching (Tab to cycle)
  if @raylib.is_key_pressed(@raylib.KeyTab) {
    if ship.ammo_type == @types.ammo_round_shot {
      if ship.ammo_chain > 0 {
        ship.ammo_type = @types.ammo_chain_shot
      } else if ship.ammo_grape > 0 {
        ship.ammo_type = @types.ammo_grapeshot
      }
    } else if ship.ammo_type == @types.ammo_chain_shot {
      if ship.ammo_grape > 0 {
        ship.ammo_type = @types.ammo_grapeshot
      } else if ship.ammo_round > 0 {
        ship.ammo_type = @types.ammo_round_shot
      }
    } else if ship.ammo_round > 0 {
      ship.ammo_type = @types.ammo_round_shot
    } else if ship.ammo_chain > 0 {
      ship.ammo_type = @types.ammo_chain_shot
    }
    let ammo_name = get_ammo_name(ship.ammo_type)
    @types.add_battle_message(game, "Ammo: \{ammo_name}", 200, 200, 255)
  }
  // Cannon firing - modified for ammo system
  ship.reload_left -= dt
  ship.reload_right -= dt
  if ship.reload_left < 0.0 {
    ship.reload_left = 0.0
  }
  if ship.reload_right < 0.0 {
    ship.reload_right = 0.0
  }
  // Crew affects reload speed
  let cannon_crew_ratio : Float = if ship.crew_action ==
    @types.crew_action_cannons {
    crew_ratio
  } else {
    crew_ratio * 0.5
  }
  let reload_mult : Float = if cannon_crew_ratio > 0.5 {
    1.0
  } else {
    0.5 + cannon_crew_ratio
  }
  let effective_reload = ship.reload_time / reload_mult
  // Cannon deck damage reduces available cannons
  let cannon_eff : Float = if ship.max_hp > 0.0 {
    0.3 + 0.7 * (ship.cannon_deck_hp / (ship.max_hp * 0.9))
  } else {
    0.3
  }
  let active_cannons_f : Float = Float::from_int(ship.cannon_count) * cannon_eff
  let active_cannons = @types.maxi(active_cannons_f.to_int(), 1)
  // Q fires port (left) broadside, E fires starboard (right) broadside
  if @raylib.is_key_pressed(@raylib.KeyQ) || @raylib.is_mouse_button_pressed(0) {
    if ship.reload_left <= 0.0 && has_ammo(ship) {
      fire_player_broadside(game, true, active_cannons)
      ship.reload_left = effective_reload
      consume_ammo(ship)
      game.battle_stats.ammo_used += 1
      game.battle_stats.accuracy_shots += active_cannons / 2
    }
  }
  if @raylib.is_key_pressed(@raylib.KeyE) || @raylib.is_mouse_button_pressed(1) {
    if ship.reload_right <= 0.0 && has_ammo(ship) {
      fire_player_broadside(game, false, active_cannons)
      ship.reload_right = effective_reload
      consume_ammo(ship)
      game.battle_stats.ammo_used += 1
      game.battle_stats.accuracy_shots += active_cannons / 2
    }
  }
  // Space fires both broadsides
  if @raylib.is_key_pressed(@raylib.KeySpace) {
    if ship.reload_left <= 0.0 && has_ammo(ship) {
      fire_player_broadside(game, true, active_cannons)
      ship.reload_left = effective_reload
      consume_ammo(ship)
      game.battle_stats.ammo_used += 1
      game.battle_stats.accuracy_shots += active_cannons / 2
    }
    if ship.reload_right <= 0.0 && has_ammo(ship) {
      fire_player_broadside(game, false, active_cannons)
      ship.reload_right = effective_reload
      consume_ammo(ship)
      game.battle_stats.ammo_used += 1
      game.battle_stats.accuracy_shots += active_cannons / 2
    }
  }
  // Crew action management (R key to cycle repair targets)
  if @raylib.is_key_pressed(@raylib.KeyR) {
    if ship.crew_action == @types.crew_action_cannons {
      ship.crew_action = @types.crew_action_repair_hull
      @types.add_battle_message(game, "Crew: Repairing Hull", 100, 200, 255)
    } else if ship.crew_action == @types.crew_action_repair_hull {
      ship.crew_action = @types.crew_action_repair_mast
      @types.add_battle_message(game, "Crew: Repairing Mast", 100, 200, 255)
    } else if ship.crew_action == @types.crew_action_repair_mast {
      ship.crew_action = @types.crew_action_repair_rudder
      @types.add_battle_message(game, "Crew: Repairing Rudder", 100, 200, 255)
    } else {
      ship.crew_action = @types.crew_action_cannons
      @types.add_battle_message(game, "Crew: Manning Cannons", 255, 200, 100)
    }
  }
  // Repair system
  if ship.crew_action == @types.crew_action_repair_hull {
    let repair_crew = ship.crew / 3
    let repair_amount = Float::from_int(repair_crew) *
      @types.repair_hull_speed *
      dt
    ship.hull_hp = @types.minf(ship.hull_hp + repair_amount, ship.max_hp)
    ship.bow_hp = @types.minf(
      ship.bow_hp + repair_amount * 0.3,
      ship.max_hp * 0.8,
    )
    ship.mid_hp = @types.minf(ship.mid_hp + repair_amount * 0.3, ship.max_hp)
    ship.stern_hp = @types.minf(
      ship.stern_hp + repair_amount * 0.3,
      ship.max_hp * 0.8,
    )
    // Reduce water intake
    if ship.taking_water > 0.0 {
      ship.taking_water -= dt * 0.5
      if ship.taking_water < 0.0 {
        ship.taking_water = 0.0
      }
    }
  } else if ship.crew_action == @types.crew_action_repair_mast {
    let repair_crew = ship.crew / 3
    let repair_amount = Float::from_int(repair_crew) *
      @types.repair_mast_speed *
      dt
    ship.mast_hp = @types.minf(
      ship.mast_hp + repair_amount,
      @types.get_class_max_mast(ship.ship_class),
    )
    ship.sail_hp = @types.minf(ship.sail_hp + repair_amount * 0.5, ship.max_hp)
  } else if ship.crew_action == @types.crew_action_repair_rudder {
    let repair_crew = ship.crew / 3
    let repair_amount = Float::from_int(repair_crew) *
      @types.repair_rudder_speed *
      dt
    ship.rudder_hp = @types.minf(
      ship.rudder_hp + repair_amount,
      @types.get_class_max_rudder(ship.ship_class),
    )
  }
  // Boarding (B key when near enemy)
  if @raylib.is_key_pressed(@raylib.KeyB) && ship.boarding_target < 0 {
    // Find nearest enemy in boarding range
    let mut nearest_idx = -1
    let mut nearest_dist : Float = @types.boarding_range
    for i in 0..<game.enemies.length() {
      let e = game.enemies[i]
      if not(e.active) {
        continue
      }
      let d = @types.distance2d(ship.x, ship.z, e.x, e.z)
      if d < nearest_dist {
        nearest_dist = d
        nearest_idx = i
      }
    }
    if nearest_idx >= 0 {
      ship.boarding_target = nearest_idx
      ship.boarding_timer = @types.boarding_duration
      let cn = @types.get_class_name(game.enemies[nearest_idx].ship_class)
      @types.add_battle_message(game, "Boarding \{cn}!", 255, 255, 100)
      @types.add_battle_log(game, "Attempting to board \{cn}")
    } else {
      @types.add_battle_message(
        game, "No ship in boarding range", 200, 200, 200,
      )
    }
  }
  // Update boarding
  update_boarding(game, dt)
  // Fleet command (F key to toggle, then number keys)
  if @raylib.is_key_pressed(@raylib.KeyF) {
    game.fleet_command_mode = not(game.fleet_command_mode)
    if game.fleet_command_mode {
      @types.add_battle_message(
        game, "Fleet Command: Select order", 150, 200, 255,
      )
    } else {
      @types.add_battle_message(game, "Fleet Command: Off", 150, 150, 150)
    }
  }
  if game.fleet_command_mode {
    // 1-4 for fleet orders
    if @raylib.is_key_pressed(@raylib.KeyOne) {
      set_fleet_order(game, @types.fleet_order_follow)
      game.fleet_command_mode = false
    }
    if @raylib.is_key_pressed(@raylib.KeyTwo) {
      set_fleet_order(game, @types.fleet_order_attack)
      game.fleet_command_mode = false
    }
    if @raylib.is_key_pressed(@raylib.KeyThree) {
      set_fleet_order(game, @types.fleet_order_defend)
      game.fleet_command_mode = false
    }
    if @raylib.is_key_pressed(@raylib.KeyFour) {
      set_fleet_order(game, @types.fleet_order_hold)
      game.fleet_command_mode = false
    }
  }
  // Toggle minimap (M key)
  if @raylib.is_key_pressed(@raylib.KeyM) {
    game.show_minimap = not(game.show_minimap)
  }
  // Camera follow with scroll wheel zoom
  let wheel = @raylib.get_mouse_wheel_move()
  if wheel != 0.0 {
    if @raylib.is_key_down(@raylib.KeyLeftShift) ||
      @raylib.is_key_down(@raylib.KeyRightShift) {
      // Zoom
      game.camera_dist -= wheel * 2.0
      game.camera_dist = @types.clampf(
        game.camera_dist,
        @types.camera_dist_min,
        @types.camera_dist_max,
      )
    } else {
      game.camera_offset_angle += wheel * 0.3
    }
  }
}

///|
fn has_ammo(ship : @types.Ship) -> Bool {
  if ship.ammo_type == @types.ammo_round_shot {
    ship.ammo_round > 0
  } else if ship.ammo_type == @types.ammo_chain_shot {
    ship.ammo_chain > 0
  } else if ship.ammo_type == @types.ammo_grapeshot {
    ship.ammo_grape > 0
  } else {
    false
  }
}

///|
fn consume_ammo(ship : @types.Ship) -> Unit {
  if ship.ammo_type == @types.ammo_round_shot {
    ship.ammo_round -= 1
    if ship.ammo_round < 0 {
      ship.ammo_round = 0
    }
  } else if ship.ammo_type == @types.ammo_chain_shot {
    ship.ammo_chain -= 1
    if ship.ammo_chain < 0 {
      ship.ammo_chain = 0
    }
  } else if ship.ammo_type == @types.ammo_grapeshot {
    ship.ammo_grape -= 1
    if ship.ammo_grape < 0 {
      ship.ammo_grape = 0
    }
  }
}

///|
fn get_ammo_name(ammo_type : Int) -> String {
  if ammo_type == @types.ammo_round_shot {
    "Round Shot"
  } else if ammo_type == @types.ammo_chain_shot {
    "Chain Shot"
  } else if ammo_type == @types.ammo_grapeshot {
    "Grapeshot"
  } else {
    "Unknown"
  }
}

///|
fn set_fleet_order(game : @types.Game, order : Int) -> Unit {
  for i in 0..<game.fleet_ships.length() {
    let fs = game.fleet_ships[i]
    if not(fs.active) {
      continue
    }
    fs.order = order
    if order == @types.fleet_order_defend {
      fs.target_x = game.player.x
      fs.target_z = game.player.z
    }
  }
  let order_name = if order == @types.fleet_order_follow {
    "Follow"
  } else if order == @types.fleet_order_attack {
    "Attack"
  } else if order == @types.fleet_order_defend {
    "Defend"
  } else {
    "Hold"
  }
  @types.add_battle_message(game, "Fleet: \{order_name}", 150, 200, 255)
}

///|
fn fire_player_broadside(
  game : @types.Game,
  port : Bool,
  active_cannons : Int,
) -> Unit {
  let ship = game.player
  // Port is left side (heading - pi/2), starboard is right (heading + pi/2)
  let side_angle : Float = if port {
    ship.heading - @types.pi / 2.0
  } else {
    ship.heading + @types.pi / 2.0
  }
  // Number of balls based on active cannons
  let shots : Int = @types.mini(active_cannons / 2, 4)
  let cannon_spd = @types.get_cannon_speed(ship.cannon_type)
  let cannon_arc = @types.get_cannon_arc(ship.cannon_type)
  for i in 0..<shots {
    let idx = @types.alloc_cannonball(game)
    if idx < 0 {
      break
    }
    let cb = game.cannonballs[idx]
    let spread_f : Float = Float::from_int(i) - Float::from_int(shots) / 2.0
    let spread = spread_f * 0.12
    let fire_angle = side_angle + spread
    cb.active = true
    // Spawn from ship side
    let offset_x = @math.sinf(fire_angle) * (ship.ship_width * 0.6)
    let offset_z = @math.cosf(fire_angle) * (ship.ship_width * 0.6)
    cb.x = ship.x + offset_x
    cb.y = 1.5
    cb.z = ship.z + offset_z
    cb.vx = @math.sinf(fire_angle) * cannon_spd
    cb.vy = cannon_arc + Float::from_int(i) * 0.3
    cb.vz = @math.cosf(fire_angle) * cannon_spd
    cb.life = @types.cannonball_life
    cb.damage = @types.get_cannon_damage(ship.cannon_type)
    cb.from_player = true
    cb.ammo_type = ship.ammo_type
    cb.cannon_type = ship.cannon_type
  }
  // Muzzle flash particles and smoke
  let side_x = ship.x + @math.sinf(side_angle) * (ship.ship_width * 0.8)
  let side_z = ship.z + @math.cosf(side_angle) * (ship.ship_width * 0.8)
  @types.spawn_particles(game, side_x, 1.5, side_z, 8, 255, 200, 100)
  @types.spawn_smoke(game, side_x, 1.8, side_z, 5)
}
