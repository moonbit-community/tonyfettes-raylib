// Combat system: advanced enemy AI, turret tracking, damage calculation, scoring

// Advanced patrol: enemies follow waypoint routes

///|
pub fn ai_patrol_advanced(
  game : @types.Game,
  e : @types.Enemy,
  dt : Float,
) -> Unit {
  // Calculate patrol waypoint based on patrol_index
  let num_waypoints = 4
  let waypoint_spacing : Float = 40.0
  let current_wp = e.patrol_index % num_waypoints
  let angle_offset = @types.two_pi *
    Float::from_int(current_wp) /
    Float::from_int(num_waypoints)
  let wp_x = e.patrol_cx + @math.cosf(angle_offset) * waypoint_spacing
  let wp_z = e.patrol_cz + @math.sinf(angle_offset) * waypoint_spacing
  let wp_y = e.target_y
  // Calculate direction to waypoint
  let dx = wp_x - e.x
  let dy = wp_y - e.y
  let dz = wp_z - e.z
  let dist_h = (dx * dx + dz * dz).sqrt()
  // If close to waypoint, advance to next
  if dist_h < 8.0 {
    e.patrol_index = (e.patrol_index + 1) % num_waypoints
  }
  // Steer towards waypoint
  if dist_h > 1.0 {
    let target_heading = @math.atan2f(dx, dz)
    let heading_diff = @types.angle_diff(e.heading, target_heading)
    let turn_rate : Float = 1.5 * dt
    if @types.absf(heading_diff) < turn_rate {
      e.heading = target_heading
    } else if heading_diff > 0.0 {
      e.heading = e.heading + turn_rate
    } else {
      e.heading = e.heading - turn_rate
    }
    e.vx = @math.sinf(e.heading) * e.speed
    e.vz = @math.cosf(e.heading) * e.speed
  }
  e.vy = @types.clampf(dy * 1.5, -4.0, 4.0)
  ignore(game)
}

// Engage behavior with lead pursuit and firing solutions

///|
pub fn ai_engage_advanced(
  game : @types.Game,
  e : @types.Enemy,
  player : @types.Player,
  dt : Float,
) -> Unit {
  // Calculate lead position for intercept
  let dx = player.x - e.x
  let dy = player.y - e.y
  let dz = player.z - e.z
  let dist = (dx * dx + dy * dy + dz * dz).sqrt()
  // Estimate player velocity from forward direction
  let (pfx, pfy, pfz) = @types.get_forward(player.pitch, player.yaw)
  let pvx = pfx * player.speed
  let pvy = pfy * player.speed
  let pvz = pfz * player.speed
  // Lead prediction
  let bullet_speed : Float = 60.0
  let time_to_intercept : Float = if dist > 1.0 {
    dist / bullet_speed
  } else {
    0.1
  }
  let lead_x = player.x + pvx * time_to_intercept * e.aggression
  let lead_y = player.y + pvy * time_to_intercept * e.aggression
  let lead_z = player.z + pvz * time_to_intercept * e.aggression
  // Steer towards lead position
  let ldx = lead_x - e.x
  let ldy = lead_y - e.y
  let ldz = lead_z - e.z
  let ldist_h = (ldx * ldx + ldz * ldz).sqrt()
  if ldist_h > 1.0 {
    let target_heading = @math.atan2f(ldx, ldz)
    let heading_diff = @types.angle_diff(e.heading, target_heading)
    let turn_rate : Float = 2.5 * e.aggression * dt
    if @types.absf(heading_diff) < turn_rate {
      e.heading = target_heading
    } else if heading_diff > 0.0 {
      e.heading = e.heading + turn_rate
    } else {
      e.heading = e.heading - turn_rate
    }
  }
  // Speed adjustment based on distance
  let engage_speed : Float = if dist < 30.0 {
    e.speed * 0.8
  } else if dist > 80.0 {
    e.speed * 1.4
  } else {
    e.speed * (1.0 + e.aggression * 0.3)
  }
  e.vx = @math.sinf(e.heading) * engage_speed
  e.vz = @math.cosf(e.heading) * engage_speed
  // Match altitude with offset
  let alt_offset = @types.rand_rangef(game, -2.0, 3.0) * e.aggression
  e.vy = @types.clampf((lead_y + alt_offset - e.y) * 2.0, -8.0, 8.0)
  ignore(ldy)
  ignore(dt)
}

// Evasive maneuvers: barrel roll, split-S, break turn

///|
pub fn ai_evasive_maneuver(
  game : @types.Game,
  e : @types.Enemy,
  player : @types.Player,
  dt : Float,
) -> Unit {
  // Choose maneuver based on maneuver_timer phase
  let phase = e.maneuver_timer * 2.0
  let phase_int = phase.to_int() % 3
  if phase_int == 0 {
    // Break turn: sharp turn away from player
    let dx = e.x - player.x
    let dz = e.z - player.z
    let dist_h = (dx * dx + dz * dz).sqrt()
    if dist_h > 1.0 {
      let away_heading = @math.atan2f(dx, dz)
      // Add perpendicular offset for corkscrew evasion
      let perp_offset = @math.sinf(e.maneuver_timer * 5.0) * 1.5
      let turn_heading = away_heading + perp_offset
      let heading_diff = @types.angle_diff(e.heading, turn_heading)
      let turn_rate : Float = 4.0 * dt
      if @types.absf(heading_diff) < turn_rate {
        e.heading = turn_heading
      } else if heading_diff > 0.0 {
        e.heading = e.heading + turn_rate
      } else {
        e.heading = e.heading - turn_rate
      }
    }
    let evade_speed = e.speed * 1.3
    e.vx = @math.sinf(e.heading) * evade_speed
    e.vz = @math.cosf(e.heading) * evade_speed
    e.vy = @types.clampf(e.vy + 6.0 * dt, -5.0, 10.0)
  } else if phase_int == 1 {
    // Dive and turn: drop altitude and reverse direction
    e.vy = @types.clampf(e.vy - 8.0 * dt, -12.0, 4.0)
    e.heading = e.heading + 3.0 * dt
    e.vx = @math.sinf(e.heading) * e.speed * 1.2
    e.vz = @math.cosf(e.heading) * e.speed * 1.2
  } else {
    // Climb and weave: gain altitude with lateral movement
    e.vy = @types.clampf(e.vy + 10.0 * dt, -3.0, 12.0)
    let weave = @math.sinf(e.maneuver_timer * 8.0) * 2.0
    e.heading = e.heading + weave * dt
    e.vx = @math.sinf(e.heading) * e.speed * 1.1
    e.vz = @math.cosf(e.heading) * e.speed * 1.1
  }
  // Update maneuver timer
  e.maneuver_timer -= dt
  if e.maneuver_timer <= 0.0 {
    e.ai_state = @types.ai_engage
  }
  ignore(game)
}

// Formation flying: enemies maintain spacing from leader

///|
pub fn ai_formation_fly(
  game : @types.Game,
  e : @types.Enemy,
  leader_x : Float,
  leader_y : Float,
  leader_z : Float,
  leader_heading : Float,
  formation_slot : Int,
  dt : Float,
) -> Unit {
  // Calculate formation offset based on slot
  let slot_f = Float::from_int(formation_slot)
  let side : Float = if formation_slot % 2 == 0 { 1.0 } else { -1.0 }
  let row = Float::from_int((formation_slot + 1) / 2)
  let spacing = @types.ai_formation_spacing
  // V-formation offset
  let offset_x = side *
    row *
    spacing *
    @math.cosf(leader_heading + @types.half_pi)
  let offset_z = side *
    row *
    spacing *
    @math.sinf(leader_heading + @types.half_pi)
  let offset_behind = row * spacing * 0.5
  // Target position in formation
  let target_x = leader_x -
    @math.sinf(leader_heading) * offset_behind +
    offset_x
  let target_z = leader_z -
    @math.cosf(leader_heading) * offset_behind +
    offset_z
  let target_y = leader_y - row * 2.0
  // Steer towards formation position
  let dx = target_x - e.x
  let dy = target_y - e.y
  let dz = target_z - e.z
  let dist_h = (dx * dx + dz * dz).sqrt()
  if dist_h > 2.0 {
    let target_heading = @math.atan2f(dx, dz)
    let heading_diff = @types.angle_diff(e.heading, target_heading)
    let turn_rate : Float = 2.0 * dt
    if @types.absf(heading_diff) < turn_rate {
      e.heading = target_heading
    } else if heading_diff > 0.0 {
      e.heading = e.heading + turn_rate
    } else {
      e.heading = e.heading - turn_rate
    }
    e.vx = @math.sinf(e.heading) * e.speed
    e.vz = @math.cosf(e.heading) * e.speed
  } else {
    e.vx = e.vx * 0.95
    e.vz = e.vz * 0.95
  }
  e.vy = @types.clampf(dy * 2.0, -5.0, 5.0)
  ignore(game)
  ignore(slot_f)
}

// Turret tracking: smooth tracking of player with prediction

///|
pub fn turret_track_player(
  t : @types.Turret,
  player : @types.Player,
  dt : Float,
) -> Unit {
  let dx = player.x - t.x
  let dy = player.y - (t.y + 1.5)
  let dz = player.z - t.z
  let dist_h = (dx * dx + dz * dz).sqrt()
  // Calculate predicted position based on player velocity
  let (pfx, pfy, pfz) = @types.get_forward(player.pitch, player.yaw)
  let pvx = pfx * player.speed
  let pvz = pfz * player.speed
  let bullet_travel_time : Float = if dist_h > 1.0 {
    dist_h / @types.turret_shell_speed
  } else {
    0.1
  }
  let pred_x = player.x + pvx * bullet_travel_time
  let pred_z = player.z + pvz * bullet_travel_time
  let pred_y = player.y + pfy * player.speed * bullet_travel_time
  // Calculate target rotation towards predicted position
  let pred_dx = pred_x - t.x
  let pred_dy = pred_y - (t.y + 1.5)
  let pred_dz = pred_z - t.z
  let target_rot = @math.atan2f(pred_dx, pred_dz)
  let pred_dist_h = (pred_dx * pred_dx + pred_dz * pred_dz).sqrt()
  let target_elev = @math.atan2f(pred_dy, pred_dist_h)
  // Smooth rotation towards target
  let rot_diff = @types.angle_diff(t.rotation, target_rot)
  let rot_speed = @types.turret_rotation_speed * dt
  if @types.absf(rot_diff) < rot_speed {
    t.rotation = target_rot
  } else if rot_diff > 0.0 {
    t.rotation = t.rotation + rot_speed
  } else {
    t.rotation = t.rotation - rot_speed
  }
  // Smooth elevation
  let elev_diff = target_elev - t.elevation
  let elev_speed = @types.turret_rotation_speed * 0.8 * dt
  if @types.absf(elev_diff) < elev_speed {
    t.elevation = target_elev
  } else if elev_diff > 0.0 {
    t.elevation = t.elevation + elev_speed
  } else {
    t.elevation = t.elevation - elev_speed
  }
  // Clamp elevation
  t.elevation = @types.clampf(t.elevation, -0.1, @types.half_pi * 0.8)
  ignore(dy)
}

// Turret burst fire: fires a short burst of shells

///|
pub fn turret_burst_fire(
  game : @types.Game,
  t : @types.Turret,
  player : @types.Player,
  burst_count : Int,
) -> Unit {
  for b in 0..<burst_count {
    let idx = @types.alloc_projectile(game)
    if idx < 0 {
      return
    }
    // Calculate firing direction from turret rotation and elevation
    let fire_dx = @math.sinf(t.rotation) * @math.cosf(t.elevation)
    let fire_dy = @math.sinf(t.elevation)
    let fire_dz = @math.cosf(t.rotation) * @math.cosf(t.elevation)
    // Add spread
    let spread : Float = 0.03 * Float::from_int(b)
    let spread_x = @types.rand_rangef(game, -spread, spread)
    let spread_y = @types.rand_rangef(game, -spread, spread)
    let spread_z = @types.rand_rangef(game, -spread, spread)
    let proj = game.projectiles[idx]
    proj.active = true
    proj.kind = @types.proj_aa_shell
    proj.x = t.x + fire_dx * 2.0
    proj.y = t.y + 1.5 + fire_dy * 2.0
    proj.z = t.z + fire_dz * 2.0
    proj.dx = fire_dx + spread_x
    proj.dy = fire_dy + spread_y
    proj.dz = fire_dz + spread_z
    proj.speed = @types.turret_shell_speed
    proj.damage = 12.0
    proj.life = 3.0
    proj.is_enemy = true
    proj.gravity_affected = false
    proj.blast_radius = 0.0
    ignore(player)
    ignore(b)
  }
  t.flash_timer = 0.2
}

// Calculate damage falloff based on distance

///|
pub fn calculate_damage_falloff(
  base_damage : Float,
  distance : Float,
  max_range : Float,
) -> Float {
  if distance >= max_range {
    0.0
  } else if distance < max_range * 0.3 {
    base_damage
  } else {
    let falloff_range = max_range - max_range * 0.3
    let falloff_dist = distance - max_range * 0.3
    let ratio_raw = falloff_dist / falloff_range
    let ratio : Float = 1.0 - ratio_raw
    base_damage * ratio * ratio
  }
}

// Check if shooter has line of sight to target (simple terrain check)

///|
pub fn has_line_of_sight(
  sx : Float,
  sy : Float,
  sz : Float,
  tx : Float,
  ty : Float,
  tz : Float,
  steps : Int,
) -> Bool {
  let step_count = if steps < 2 { 2 } else { steps }
  let inv_steps : Float = 1.0 / Float::from_int(step_count)
  for i in 1..<step_count {
    let t_val = Float::from_int(i) * inv_steps
    let check_x = @types.lerpf(sx, tx, t_val)
    let check_y = @types.lerpf(sy, ty, t_val)
    let check_z = @types.lerpf(sz, tz, t_val)
    let terrain_h = @types.terrain_height_at(check_x, check_z)
    if check_y < terrain_h + 1.0 {
      return false
    }
  }
  true
}

// Score calculation for a kill based on difficulty and conditions

///|
pub fn calculate_kill_score(
  base_score : Int,
  distance : Float,
  difficulty : Int,
  weather : Int,
) -> Int {
  let mut multiplier : Float = 1.0
  // Distance bonus: longer shots get more points
  if distance > 60.0 {
    multiplier = multiplier + 0.5
  } else if distance > 40.0 {
    multiplier = multiplier + 0.25
  }
  // Difficulty multiplier
  let diff_bonus = Float::from_int(difficulty) * 0.1
  multiplier = multiplier + diff_bonus
  // Weather bonus
  if weather == @types.weather_storm {
    multiplier = multiplier + 0.5
  } else if weather == @types.weather_fog {
    multiplier = multiplier + 0.3
  } else if weather == @types.weather_night {
    multiplier = multiplier + 0.4
  } else if weather == @types.weather_rain {
    multiplier = multiplier + 0.2
  }
  let final_score = Float::from_int(base_score) * multiplier
  final_score.to_int()
}

// Check if enemy is behind player (for tail warning)

///|
pub fn is_enemy_behind_player(
  player : @types.Player,
  enemy_x : Float,
  enemy_z : Float,
) -> Bool {
  let (fx, _fy, fz) = @types.get_forward(player.pitch, player.yaw)
  let dx = enemy_x - player.x
  let dz = enemy_z - player.z
  let dot = fx * dx + fz * dz
  dot < 0.0
}

// Count enemies in engagement range

///|
pub fn count_engaged_enemies(game : @types.Game) -> Int {
  let mut count = 0
  let player = game.player
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    if e.kind != @types.enemy_type_air {
      continue
    }
    let dist = @types.distance3d(e.x, e.y, e.z, player.x, player.y, player.z)
    if dist < @types.ai_engage_range {
      count = count + 1
    }
  }
  count
}

// Check if any enemy has missile lock on player

///|
pub fn check_enemy_threat_level(game : @types.Game) -> Int {
  let player = game.player
  let mut threat = 0
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    let dist = @types.distance3d(e.x, e.y, e.z, player.x, player.y, player.z)
    if dist < 20.0 && e.ai_state == @types.ai_engage {
      threat = threat + 3
    } else if dist < 40.0 && e.ai_state == @types.ai_engage {
      threat = threat + 2
    } else if dist < @types.ai_engage_range {
      threat = threat + 1
    }
  }
  // Add turret threats
  for i in 0..<game.turrets.length() {
    let t = game.turrets[i]
    if not(t.active) {
      continue
    }
    let dist = @types.distance3d(t.x, t.y, t.z, player.x, player.y, player.z)
    if dist < t.range * 0.5 {
      threat = threat + 2
    } else if dist < t.range {
      threat = threat + 1
    }
  }
  threat
}

// Calculate accuracy bonus score

///|
pub fn accuracy_bonus_score(shots_fired : Int, shots_hit : Int) -> Int {
  if shots_fired <= 0 {
    0
  } else {
    let accuracy = Float::from_int(shots_hit) / Float::from_int(shots_fired)
    if accuracy > 0.8 {
      500
    } else if accuracy > 0.6 {
      300
    } else if accuracy > 0.4 {
      150
    } else if accuracy > 0.2 {
      50
    } else {
      0
    }
  }
}

// Calculate time bonus for mission completion

///|
pub fn time_bonus_score(time_taken : Float, par_time : Float) -> Int {
  if par_time <= 0.0 {
    0
  } else if time_taken < par_time * 0.5 {
    500
  } else if time_taken < par_time * 0.75 {
    300
  } else if time_taken < par_time {
    150
  } else {
    0
  }
}

// Calculate no-damage bonus

///|
pub fn no_damage_bonus(current_hp : Float, max_hp : Float) -> Int {
  let ratio = current_hp / max_hp
  if ratio >= 1.0 {
    400
  } else if ratio > 0.9 {
    200
  } else if ratio > 0.75 {
    100
  } else {
    0
  }
}

// Determine if enemy should attempt evasion based on incoming projectiles

///|
pub fn should_enemy_evade(game : @types.Game, e : @types.Enemy) -> Bool {
  for i in 0..<game.projectiles.length() {
    let proj = game.projectiles[i]
    if not(proj.active) {
      continue
    }
    if proj.is_enemy {
      continue
    }
    // Check if projectile is heading towards this enemy
    let dx = e.x - proj.x
    let dy = e.y - proj.y
    let dz = e.z - proj.z
    let dist = (dx * dx + dy * dy + dz * dz).sqrt()
    if dist > 40.0 {
      continue
    }
    // Check if projectile direction is roughly towards enemy
    let dot = proj.dx * dx + proj.dy * dy + proj.dz * dz
    if dot > 0.0 && dist < 25.0 {
      return true
    }
  }
  false
}

// Calculate lead angle for AI firing

///|
pub fn calculate_lead_angle(
  shooter_x : Float,
  shooter_z : Float,
  target_x : Float,
  target_z : Float,
  target_vx : Float,
  target_vz : Float,
  bullet_speed : Float,
) -> Float {
  let dx = target_x - shooter_x
  let dz = target_z - shooter_z
  let dist = (dx * dx + dz * dz).sqrt()
  let time_to_target : Float = if dist > 1.0 {
    dist / bullet_speed
  } else {
    0.1
  }
  let lead_x = target_x + target_vx * time_to_target
  let lead_z = target_z + target_vz * time_to_target
  @math.atan2f(lead_x - shooter_x, lead_z - shooter_z)
}

// Enemy collision avoidance: steer away from other enemies

///|
pub fn avoid_collision(
  game : @types.Game,
  e : @types.Enemy,
  enemy_index : Int,
  dt : Float,
) -> Unit {
  let min_sep : Float = 6.0
  let mut avoid_x : Float = 0.0
  let mut avoid_z : Float = 0.0
  let mut avoid_y : Float = 0.0
  let mut need_avoid = false
  for i in 0..<game.enemies.length() {
    if i == enemy_index {
      continue
    }
    let other = game.enemies[i]
    if not(other.active) {
      continue
    }
    let dx = e.x - other.x
    let dy = e.y - other.y
    let dz = e.z - other.z
    let dist = (dx * dx + dy * dy + dz * dz).sqrt()
    if dist < min_sep && dist > 0.1 {
      let strength = (min_sep - dist) / min_sep
      avoid_x = avoid_x + dx / dist * strength
      avoid_y = avoid_y + dy / dist * strength
      avoid_z = avoid_z + dz / dist * strength
      need_avoid = true
    }
  }
  if need_avoid {
    let avoid_strength : Float = 5.0
    e.vx = e.vx + avoid_x * avoid_strength * dt
    e.vy = e.vy + avoid_y * avoid_strength * dt
    e.vz = e.vz + avoid_z * avoid_strength * dt
  }
}

// Determine threat direction for HUD indicator

///|
pub fn get_threat_direction(game : @types.Game) -> Int {
  let player = game.player
  let (fx, _fy, fz) = @types.get_forward(player.pitch, player.yaw)
  let mut closest_dist : Float = 99999.0
  let mut closest_dir = -1
  for i in 0..<game.enemies.length() {
    let e = game.enemies[i]
    if not(e.active) {
      continue
    }
    if e.ai_state != @types.ai_engage {
      continue
    }
    let dist = @types.distance3d(e.x, e.y, e.z, player.x, player.y, player.z)
    if dist < closest_dist && dist < @types.ai_engage_range {
      closest_dist = dist
      let dx = e.x - player.x
      let dz = e.z - player.z
      let dot = fx * dx + fz * dz
      let cross = fx * dz - fz * dx
      if dot > 0.0 {
        closest_dir = 0 // front
      } else if cross > 0.0 {
        closest_dir = 1 // right
      } else if cross < 0.0 {
        closest_dir = 3 // left
      } else {
        closest_dir = 2 // behind
      }
    }
  }
  closest_dir
}
