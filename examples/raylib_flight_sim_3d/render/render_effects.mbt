// Visual effects rendering: clouds, weather, explosions, trails, sun/moon

// Draw cloud layer
pub fn draw_clouds(game : @types.Game) -> Unit {
  for i = 0; i < game.clouds.length(); i = i + 1 {
    let c = game.clouds[i]
    if not(c.active) { continue i + 1 }
    // Distance culling
    let dist = @types.distance2d(
      game.player.x, game.player.z, c.x, c.z,
    )
    if dist > game.draw_distance * 0.8 { continue i + 1 }
    // Determine cloud color based on weather and time of day
    let tod = game.weather_state.time_of_day
    let base_gray : Int = if game.weather_state.kind == @types.weather_storm {
      80
    } else if game.weather_state.kind == @types.weather_rain {
      120
    } else if game.weather_state.kind == @types.weather_night {
      40
    } else {
      220
    }
    // Time of day tint
    let r_tint : Int = if tod < 0.2 { 30 } else if tod > 0.8 { 255 } else { base_gray }
    let g_tint : Int = if tod < 0.2 { 20 } else if tod > 0.8 { 180 } else { base_gray }
    let b_tint : Int = if tod < 0.2 { 50 } else { base_gray }
    let cloud_r = @types.clampi(r_tint, 0, 255)
    let cloud_g = @types.clampi(g_tint, 0, 255)
    let cloud_b = @types.clampi(b_tint, 0, 255)
    // Fade alpha with distance
    let fade_raw = dist / (game.draw_distance * 0.8)
    let fade_ratio : Float = 1.0 - fade_raw
    let alpha_f = Float::from_int(c.alpha) * fade_ratio
    let alpha = @types.clampi(alpha_f.to_int(), 10, 200)
    // Draw cloud as cluster of overlapping cubes for volume
    let num_puffs = 5
    for p = 0; p < num_puffs; p = p + 1 {
      let pf = Float::from_int(p)
      let offset_x = @math.sinf(pf * 1.7 + Float::from_int(i) * 0.3) * c.size_x * 0.4
      let offset_y = @math.cosf(pf * 2.3 + Float::from_int(i) * 0.5) * c.size_y * 0.2
      let offset_z = @math.sinf(pf * 1.1 + Float::from_int(i) * 0.7) * c.size_z * 0.4
      let puff_sx = c.size_x * 0.6 + @math.cosf(pf * 0.8) * c.size_x * 0.2
      let puff_sy = c.size_y * 0.5 + @math.sinf(pf * 1.2) * c.size_y * 0.15
      let puff_sz = c.size_z * 0.5 + @math.cosf(pf * 1.5) * c.size_z * 0.2
      @raylib.draw_cube(
        @raylib.Vector3::new(c.x + offset_x, c.y + offset_y, c.z + offset_z),
        puff_sx, puff_sy, puff_sz,
        @raylib.Color::new(cloud_r, cloud_g, cloud_b, alpha),
      )
      ignore(p)
    }
  }
}

// Draw rain effect lines in 3D
pub fn draw_rain_effect(game : @types.Game) -> Unit {
  let ws = game.weather_state
  if ws.rain_intensity <= 0.0 { return }
  let player = game.player
  let rain_count_f = ws.rain_intensity * 30.0
  let rain_count = rain_count_f.to_int()
  for i = 0; i < rain_count; i = i + 1 {
    // Pseudo-random positions around player using frame and index
    let seed_val = Float::from_int(i * 7 + game.frame_counter * 3)
    let rx = player.x + @math.sinf(seed_val * 0.17) * 30.0
    let ry = player.y + @math.cosf(seed_val * 0.23) * 15.0 + 10.0
    let rz = player.z + @math.sinf(seed_val * 0.31 + 2.0) * 30.0
    let line_len : Float = 1.5 * ws.rain_intensity
    let wind_offset_x = ws.wind_dir_x * ws.wind_speed * 0.1
    let wind_offset_z = ws.wind_dir_z * ws.wind_speed * 0.1
    // Rain line: from (rx,ry,rz) downward with wind
    let rain_alpha : Int = (ws.rain_intensity * 150.0).to_int()
    let ra = @types.clampi(rain_alpha, 30, 180)
    @raylib.draw_line_3d(
      @raylib.Vector3::new(rx, ry, rz),
      @raylib.Vector3::new(rx + wind_offset_x, ry - line_len, rz + wind_offset_z),
      @raylib.Color::new(180, 200, 230, ra),
    )
    ignore(i)
  }
}

// Draw fog gradient overlay
pub fn draw_fog_overlay(game : @types.Game) -> Unit {
  let ws = game.weather_state
  let visibility = ws.visibility
  // Draw ground-level fog cubes near player
  if ws.kind == @types.weather_fog || ws.kind == @types.weather_storm {
    let player = game.player
    let fog_count = 8
    for i = 0; i < fog_count; i = i + 1 {
      let seed_f = Float::from_int(i)
      let fog_x = player.x + @math.sinf(seed_f * 2.1) * 40.0
      let fog_z = player.z + @math.cosf(seed_f * 1.7) * 40.0
      let fog_y = @types.terrain_height_at(fog_x, fog_z) + 3.0
      let fog_alpha : Int = if ws.kind == @types.weather_fog { 60 } else { 40 }
      let fog_size_x : Float = 20.0 + @math.sinf(seed_f * 0.9) * 8.0
      let fog_size_y : Float = 4.0 + @math.cosf(seed_f * 1.3) * 2.0
      let fog_size_z : Float = 18.0 + @math.cosf(seed_f * 0.7) * 6.0
      @raylib.draw_cube(
        @raylib.Vector3::new(fog_x, fog_y, fog_z),
        fog_size_x, fog_size_y, fog_size_z,
        @raylib.Color::new(200, 200, 210, fog_alpha),
      )
      ignore(i)
    }
  }
  ignore(visibility)
}

// Draw engine exhaust trail behind player
pub fn draw_engine_trail(game : @types.Game) -> Unit {
  let player = game.player
  if not(player.alive) { return }
  if player.throttle < 0.2 { return }
  let (fx, fy, fz) = @types.get_forward(player.pitch, player.yaw)
  // Draw multiple trail segments behind aircraft
  let trail_segments = 6
  let intensity = player.throttle
  for i = 0; i < trail_segments; i = i + 1 {
    let t_val = Float::from_int(i + 1) * 0.5
    let trail_x = player.x - fx * (2.0 + t_val)
    let trail_y = player.y - fy * (2.0 + t_val)
    let trail_z = player.z - fz * (2.0 + t_val)
    let i_ratio = Float::from_int(i) / Float::from_int(trail_segments)
    let alpha_ratio : Float = 1.0 - i_ratio
    let alpha = (alpha_ratio * intensity * 120.0).to_int()
    let a = @types.clampi(alpha, 0, 200)
    let seg_size : Float = 0.15 + Float::from_int(i) * 0.05 * intensity
    // Color transitions from yellow to gray
    let r_val = 255 - (Float::from_int(i) * 25.0).to_int()
    let g_val = 200 - (Float::from_int(i) * 30.0).to_int()
    let b_val = 100 + (Float::from_int(i) * 15.0).to_int()
    @raylib.draw_cube(
      @raylib.Vector3::new(trail_x, trail_y, trail_z),
      seg_size, seg_size, seg_size,
      @raylib.Color::new(
        @types.clampi(r_val, 100, 255),
        @types.clampi(g_val, 80, 255),
        @types.clampi(b_val, 50, 200),
        a,
      ),
    )
    ignore(i)
  }
}

// Draw smoke trail from damaged aircraft
pub fn draw_damage_smoke(game : @types.Game) -> Unit {
  let player = game.player
  if not(player.alive) { return }
  let hp_ratio = player.hp / player.max_hp
  if hp_ratio > 0.5 { return }
  let (fx, fy, fz) = @types.get_forward(player.pitch, player.yaw)
  let trail_segments = 8
  let hp_x2 = hp_ratio * 2.0
  let smoke_intensity : Float = 1.0 - hp_x2
  for i = 0; i < trail_segments; i = i + 1 {
    let t_val = Float::from_int(i + 1) * 0.8
    let jitter_x = @math.sinf(Float::from_int(game.frame_counter + i * 7) * 0.3) * 0.3
    let jitter_y = @math.cosf(Float::from_int(game.frame_counter + i * 11) * 0.2) * 0.2
    let trail_x = player.x - fx * (1.5 + t_val) + jitter_x
    let trail_y = player.y - fy * (1.5 + t_val) + jitter_y + Float::from_int(i) * 0.3
    let trail_z = player.z - fz * (1.5 + t_val)
    let i_rat = Float::from_int(i) / Float::from_int(trail_segments)
    let alpha_ratio : Float = 1.0 - i_rat
    let alpha = (alpha_ratio * smoke_intensity * 150.0).to_int()
    let a = @types.clampi(alpha, 0, 200)
    let seg_size : Float = 0.2 + Float::from_int(i) * 0.15
    // Dark smoke color, getting lighter with distance
    let gray = 40 + (Float::from_int(i) * 10.0).to_int()
    let gray_c = @types.clampi(gray, 30, 120)
    @raylib.draw_cube(
      @raylib.Vector3::new(trail_x, trail_y, trail_z),
      seg_size, seg_size, seg_size,
      @raylib.Color::new(gray_c, gray_c, gray_c, a),
    )
    // If very damaged, add fire particles
    if hp_ratio < 0.25 && i < 3 {
      let fire_size = seg_size * 0.6
      let fire_alpha = (alpha_ratio * 200.0).to_int()
      let fa = @types.clampi(fire_alpha, 0, 200)
      @raylib.draw_cube(
        @raylib.Vector3::new(trail_x, trail_y - 0.1, trail_z),
        fire_size, fire_size, fire_size,
        @raylib.Color::new(255, 150, 30, fa),
      )
    }
    ignore(i)
  }
}

// Draw tracer bullet trails
pub fn draw_tracer_trails(game : @types.Game) -> Unit {
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    let proj = game.projectiles[i]
    if not(proj.active) { continue i + 1 }
    // Draw extended trail behind projectile
    let trail_len : Float = 1.5
    let start_x = proj.x
    let start_y = proj.y
    let start_z = proj.z
    let end_x = proj.x - proj.dx * trail_len
    let end_y = proj.y - proj.dy * trail_len
    let end_z = proj.z - proj.dz * trail_len
    let color = if proj.is_enemy {
      @raylib.Color::new(255, 80, 30, 150)
    } else if proj.kind == @types.proj_rocket {
      @raylib.Color::new(255, 200, 100, 200)
    } else {
      @raylib.Color::new(255, 255, 100, 150)
    }
    @raylib.draw_line_3d(
      @raylib.Vector3::new(start_x, start_y, start_z),
      @raylib.Vector3::new(end_x, end_y, end_z),
      color,
    )
    // Bright tip
    @raylib.draw_sphere(
      @raylib.Vector3::new(start_x, start_y, start_z),
      0.15,
      @raylib.Color::new(255, 255, 200, 255),
    )
  }
}

// Draw sun or moon based on time of day
pub fn draw_celestial_body(game : @types.Game) -> Unit {
  let tod = game.weather_state.time_of_day
  let player = game.player
  // Sun position: arc across sky based on time of day
  let sun_angle = tod * @types.pi
  let sun_dist : Float = 150.0
  let sun_x = player.x + @math.cosf(sun_angle) * sun_dist
  let sun_y = @math.sinf(sun_angle) * sun_dist + 10.0
  let sun_z = player.z + sun_dist * 0.3
  if tod > 0.15 && tod < 0.85 {
    // Daytime: draw sun
    let sun_size : Float = 8.0
    let sun_r : Int = if tod < 0.3 { 255 } else if tod > 0.7 { 255 } else { 255 }
    let sun_g : Int = if tod < 0.3 { 150 } else if tod > 0.7 { 160 } else { 220 }
    let sun_b : Int = if tod < 0.3 { 50 } else if tod > 0.7 { 60 } else { 100 }
    // Sun glow (larger, dimmer)
    @raylib.draw_sphere(
      @raylib.Vector3::new(sun_x, sun_y, sun_z),
      sun_size * 2.0,
      @raylib.Color::new(sun_r, sun_g, sun_b, 30),
    )
    // Sun core
    @raylib.draw_sphere(
      @raylib.Vector3::new(sun_x, sun_y, sun_z),
      sun_size,
      @raylib.Color::new(sun_r, sun_g, sun_b, 180),
    )
  } else {
    // Nighttime: draw moon
    let moon_x = player.x - @math.cosf(sun_angle) * sun_dist * 0.8
    let moon_wobble = @math.sinf(Float::from_int(game.frame_counter) * 0.001) * 5.0
    let moon_y : Float = 80.0 + moon_wobble
    let moon_z = player.z - sun_dist * 0.2
    // Moon glow
    @raylib.draw_sphere(
      @raylib.Vector3::new(moon_x, moon_y, moon_z),
      10.0,
      @raylib.Color::new(180, 200, 255, 20),
    )
    // Moon surface
    @raylib.draw_sphere(
      @raylib.Vector3::new(moon_x, moon_y, moon_z),
      5.0,
      @raylib.Color::new(220, 230, 245, 200),
    )
  }
}

// Draw enemy smoke trails when damaged
pub fn draw_enemy_damage_trails(game : @types.Game) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let e = game.enemies[i]
    if not(e.active) { continue i + 1 }
    if e.kind != @types.enemy_type_air { continue i + 1 }
    let hp_ratio = e.hp / e.max_hp
    if hp_ratio > 0.6 { continue i + 1 }
    // Distance culling
    let dist = @types.distance3d(
      game.player.x, game.player.y, game.player.z, e.x, e.y, e.z,
    )
    if dist > game.draw_distance { continue i + 1 }
    let smoke_segments = 4
    let vel_len = (e.vx * e.vx + e.vz * e.vz).sqrt()
    let dir_x : Float = if vel_len > 0.5 { e.vx / vel_len } else { 0.0 }
    let dir_z : Float = if vel_len > 0.5 { e.vz / vel_len } else { 0.0 }
    for s = 0; s < smoke_segments; s = s + 1 {
      let t_val = Float::from_int(s + 1) * 0.6
      let smoke_x = e.x - dir_x * t_val
      let smoke_y = e.y + Float::from_int(s) * 0.2
      let smoke_z = e.z - dir_z * t_val
      let seg_alpha = 120 - s * 25
      let sa = @types.clampi(seg_alpha, 10, 200)
      let seg_size : Float = 0.3 + Float::from_int(s) * 0.1
      @raylib.draw_cube(
        @raylib.Vector3::new(smoke_x, smoke_y, smoke_z),
        seg_size, seg_size, seg_size,
        @raylib.Color::new(60, 60, 60, sa),
      )
      // Fire if critical
      if hp_ratio < 0.3 && s < 2 {
        let fire_seg = seg_size * 0.5
        @raylib.draw_cube(
          @raylib.Vector3::new(smoke_x, smoke_y - 0.15, smoke_z),
          fire_seg, fire_seg, fire_seg,
          @raylib.Color::new(255, 120, 20, sa),
        )
      }
      ignore(s)
    }
  }
}
