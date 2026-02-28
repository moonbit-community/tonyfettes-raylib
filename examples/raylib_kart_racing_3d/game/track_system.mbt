// Track loading and race management

///|
pub fn load_track(game : @types.Game, cup : Int, race : Int) -> Unit {
  let wp_data = @levels.get_track_waypoints(cup, race)
  game.waypoint_count = @types.clampi(wp_data.length(), 0, @types.max_waypoints)
  for i in 0..<game.waypoint_count {
    let d = wp_data[i]
    game.waypoints[i] = { x: d.0, y: d.1, z: d.2 }
  }
  // Clear entity pools
  for i in 0..<game.karts.length() {
    game.karts[i] = @types.Kart::inactive()
  }
  for i in 0..<game.powerups.length() {
    game.powerups[i] = @types.Powerup::inactive()
  }
  for i in 0..<game.projectiles.length() {
    game.projectiles[i] = @types.Projectile::inactive()
  }
  for i in 0..<game.particles.length() {
    game.particles[i] = @types.Particle::inactive()
  }
  // Spawn karts at start positions
  spawn_karts(game)
  // Spawn powerup pickups along track
  spawn_track_powerups(game)
  // Reset race state
  game.race_time = 0.0
  game.countdown_timer = @types.countdown_total
  game.best_lap_time = 999.0
  game.current_lap_time = 0.0
  game.lap_start_time = 0.0
}

///|
fn spawn_karts(game : @types.Game) -> Unit {
  if game.waypoint_count < 2 {
    return
  }
  let wp0 = @types.get_waypoint(game, 0)
  let wp1 = @types.get_waypoint(game, 1)
  // Direction from wp0 to wp1
  let dx = wp1.x - wp0.x
  let dz = wp1.z - wp0.z
  let dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
  let dir_x : Float = if dist > 0.01 { dx / dist } else { 0.0 }
  let dir_z : Float = if dist > 0.01 { dz / dist } else { 1.0 }
  let start_angle = @math.atan2f(dir_x, dir_z)
  // Perpendicular direction for side-by-side placement
  let perp_x = -dir_z
  let perp_z = dir_x
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    kart.active = true
    kart.is_player = i == @types.player_kart
    // Grid start: 2 columns, 4 rows behind start line
    let row = i / 2
    let col = i % 2
    let lateral : Float = (Float::from_int(col) - 0.5) * 2.5
    let back : Float = Float::from_int(row) * -3.0
    kart.x = wp0.x + dir_x * back + perp_x * lateral
    kart.y = wp0.y
    kart.z = wp0.z + dir_z * back + perp_z * lateral
    kart.angle = start_angle
    kart.speed = 0.0
    kart.steer = 0.0
    kart.vy = 0.0
    kart.on_ground = true
    kart.lap = 0
    kart.waypoint_idx = 0
    kart.waypoint_progress = 0.0
    kart.total_progress = 0.0
    kart.place = i + 1
    kart.held_powerup = @types.powerup_none
    kart.boost_timer = 0.0
    kart.shield_timer = 0.0
    kart.drift_left = false
    kart.drift_right = false
    kart.drift_timer = 0.0
    kart.spin_timer = 0.0
    kart.finish_time = 0.0
    kart.finished = false
    kart.ai_steer_target = 0.0
    kart.ai_accel = 0.8
    kart.ai_use_item_timer = @types.rand_rangef(game, 2.0, 5.0)
  }
}

///|
fn spawn_track_powerups(game : @types.Game) -> Unit {
  if game.waypoint_count < 3 {
    return
  }
  // Place powerups at intervals around the track
  let spacing = 3 // Every 3rd waypoint segment gets a powerup cluster
  let mut pu_idx = 0
  for i in 0..<game.waypoint_count {
    if i % spacing != 1 {
      continue
    }
    if pu_idx >= @types.max_powerups - 1 {
      break
    }
    let wp0 = @types.get_waypoint(game, i)
    let wp1 = @types.get_waypoint(game, i + 1)
    let mx = (wp0.x + wp1.x) / 2.0
    let mz = (wp0.z + wp1.z) / 2.0
    let my = (wp0.y + wp1.y) / 2.0 + 0.8
    // Place 2 powerups side by side
    let dx = wp1.x - wp0.x
    let dz = wp1.z - wp0.z
    let d = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
    let px : Float = if d > 0.01 { -dz / d } else { 1.0 }
    let pz : Float = if d > 0.01 { dx / d } else { 0.0 }
    let p1 = game.powerups[pu_idx]
    p1.active = true
    p1.x = mx + px * 1.5
    p1.y = my
    p1.z = mz + pz * 1.5
    p1.kind = @types.rand_range(game, 1, 3)
    p1.respawn_timer = 0.0
    p1.collected = false
    pu_idx = pu_idx + 1
    if pu_idx < @types.max_powerups {
      let p2 = game.powerups[pu_idx]
      p2.active = true
      p2.x = mx - px * 1.5
      p2.y = my
      p2.z = mz - pz * 1.5
      p2.kind = @types.rand_range(game, 1, 3)
      p2.respawn_timer = 0.0
      p2.collected = false
      pu_idx = pu_idx + 1
    }
  }
}

// Update waypoint tracking for a kart

///|
pub fn update_kart_waypoint(game : @types.Game, kart_idx : Int) -> Unit {
  let kart = game.karts[kart_idx]
  if not(kart.active) || kart.finished {
    return
  }
  let wc = game.waypoint_count
  if wc < 2 {
    return
  }
  // Check distance to next waypoint
  let next_wp_idx = (kart.waypoint_idx + 1) % wc
  let next_wp = @types.get_waypoint(game, next_wp_idx)
  let dist_next = @types.distance2d(kart.x, kart.z, next_wp.x, next_wp.z)
  // Advance if close enough to next waypoint
  if dist_next < @types.road_width * 1.2 {
    let old_idx = kart.waypoint_idx
    kart.waypoint_idx = next_wp_idx
    // Check for lap completion (crossed start line)
    if next_wp_idx == 0 && old_idx == wc - 1 {
      kart.lap = kart.lap + 1
      if kart.is_player {
        let lap_time = game.race_time - game.lap_start_time
        if lap_time < game.best_lap_time && game.lap_start_time > 0.0 {
          game.best_lap_time = lap_time
        }
        game.lap_start_time = game.race_time
      }
      // Check race finish
      if kart.lap >= @types.total_laps {
        kart.finished = true
        kart.finish_time = game.race_time
      }
    }
  }
  // Calculate progress along current segment
  let cur_wp = @types.get_waypoint(game, kart.waypoint_idx)
  let nxt_wp = @types.get_waypoint(game, (kart.waypoint_idx + 1) % wc)
  let seg_len = @types.distance2d(cur_wp.x, cur_wp.z, nxt_wp.x, nxt_wp.z)
  let dist_from_cur = @types.distance2d(kart.x, kart.z, cur_wp.x, cur_wp.z)
  kart.waypoint_progress = if seg_len > 0.01 {
    @types.clampf(dist_from_cur / seg_len, 0.0, 1.0)
  } else {
    0.0
  }
  kart.total_progress = @types.calc_total_progress(kart, wc)
}

// Update race positions

///|
pub fn update_positions(game : @types.Game) -> Unit {
  // Simple bubble sort by total_progress (descending = better position)
  let positions : Array[Int] = []
  for i in 0..<@types.max_karts {
    positions.push(i)
  }
  // Sort: finished karts first (by finish_time), then by total_progress descending
  for i in 0..<(@types.max_karts - 1) {
    for j in 0..<(@types.max_karts - 1 - i) {
      let a = positions[j]
      let b = positions[j + 1]
      let ka = game.karts[a]
      let kb = game.karts[b]
      let mut swap = false
      if ka.finished && kb.finished {
        if ka.finish_time > kb.finish_time {
          swap = true
        }
      } else if ka.finished {
        swap = false
      } else if kb.finished {
        swap = true
      } else if ka.total_progress < kb.total_progress {
        swap = true
      }
      if swap {
        let tmp = positions[j]
        positions[j] = positions[j + 1]
        positions[j + 1] = tmp
      }
    }
  }
  // Assign places
  for i in 0..<@types.max_karts {
    game.karts[positions[i]].place = i + 1
  }
}

// Check if all karts finished

///|
pub fn all_karts_finished(game : @types.Game) -> Bool {
  for i in 0..<@types.max_karts {
    if game.karts[i].active && not(game.karts[i].finished) {
      return false
    }
  }
  true
}

// Check if player finished

///|
pub fn player_finished(game : @types.Game) -> Bool {
  game.karts[@types.player_kart].finished
}

// Get ground height at position (interpolate from nearby waypoints)

///|
pub fn get_ground_height(game : @types.Game, x : Float, z : Float) -> Float {
  let wc = game.waypoint_count
  if wc < 2 {
    return 0.0
  }
  let mut best_dist : Float = 99999.0
  let mut best_idx = 0
  for i in 0..<wc {
    let wp = game.waypoints[i]
    let d = @types.distance2d(x, z, wp.x, wp.z)
    if d < best_dist {
      best_dist = d
      best_idx = i
    }
  }
  let wp0 = game.waypoints[best_idx]
  let next_idx = (best_idx + 1) % wc
  let wp1 = game.waypoints[next_idx]
  let seg_len = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
  if seg_len < 0.01 {
    return wp0.y
  }
  // Project point onto segment
  let dx = wp1.x - wp0.x
  let dz = wp1.z - wp0.z
  let px = x - wp0.x
  let pz = z - wp0.z
  let t = @types.clampf((px * dx + pz * dz) / (seg_len * seg_len), 0.0, 1.0)
  @types.lerpf(wp0.y, wp1.y, t)
}

// Apply finish-race scoring

///|
pub fn apply_race_results(game : @types.Game) -> Unit {
  for i in 0..<@types.max_karts {
    let kart = game.karts[i]
    game.cup_points[i] = game.cup_points[i] + @types.position_points(kart.place)
  }
}

// Reset cup points

///|
pub fn reset_cup_points(game : @types.Game) -> Unit {
  for i in 0..<@types.max_karts {
    game.cup_points[i] = 0
  }
}

// Update powerup respawns

///|
pub fn update_powerup_respawns(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.powerups.length() {
    let pu = game.powerups[i]
    if not(pu.active) {
      continue
    }
    if pu.collected {
      pu.respawn_timer -= dt
      if pu.respawn_timer <= 0.0 {
        pu.collected = false
        pu.kind = @types.rand_range(game, 1, 3)
      }
    }
  }
}

// Check kart-powerup collisions

///|
pub fn check_powerup_collisions(game : @types.Game) -> Unit {
  for ki in 0..<@types.max_karts {
    let kart = game.karts[ki]
    if not(kart.active) || kart.finished {
      continue
    }
    if kart.held_powerup != @types.powerup_none {
      continue
    }
    for pi in 0..<game.powerups.length() {
      let pu = game.powerups[pi]
      if not(pu.active) || pu.collected {
        continue
      }
      let d = @types.distance2d(kart.x, kart.z, pu.x, pu.z)
      if d < 2.0 {
        kart.held_powerup = pu.kind
        pu.collected = true
        pu.respawn_timer = 8.0
        @types.spawn_particles(game, pu.x, pu.y, pu.z, 8, 255, 255, 100)
        break
      }
    }
  }
}

// Update projectiles

///|
pub fn update_projectiles(game : @types.Game, dt : Float) -> Unit {
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
    // Move forward
    let dx = @math.sinf(proj.angle) * proj.speed * dt
    let dz = @math.cosf(proj.angle) * proj.speed * dt
    proj.x = proj.x + dx
    proj.z = proj.z + dz
    // Check collision with karts
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
      let d = @types.distance2d(proj.x, proj.z, kart.x, kart.z)
      if d < 1.5 {
        if kart.shield_timer > 0.0 {
          kart.shield_timer = 0.0
          @types.spawn_particles(
            game,
            kart.x,
            kart.y + 0.5,
            kart.z,
            12,
            100,
            200,
            255,
          )
        } else {
          kart.spin_timer = 1.5
          kart.speed = kart.speed * 0.3
          @types.spawn_particles(
            game,
            kart.x,
            kart.y + 0.5,
            kart.z,
            15,
            255,
            100,
            50,
          )
        }
        proj.active = false
        break
      }
    }
  }
}

// Update particles

///|
pub fn update_particles(game : @types.Game, dt : Float) -> Unit {
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
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    p.z = p.z + p.vz * dt
    p.vy = p.vy - 8.0 * dt
    p.vx = p.vx * 0.97
    p.vz = p.vz * 0.97
  }
}
