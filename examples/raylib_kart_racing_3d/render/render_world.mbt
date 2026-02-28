// 3D world rendering

pub fn draw_world(game : @types.Game) -> Unit {
  let camera = build_camera(game)
  @raylib.begin_mode_3d(camera)
  draw_skybox_elements(game)
  draw_ground(game)
  draw_track(game)
  draw_surface_indicators(game)
  draw_powerups(game)
  draw_karts(game)
  draw_kart_details(game)
  draw_projectiles(game)
  draw_particles_3d(game)
  draw_start_finish_line(game)
  draw_trackside_objects(game)
  draw_themed_decorations(game)
  @raylib.end_mode_3d()
  draw_effects(game)
}

fn build_camera(game : @types.Game) -> @raylib.Camera3D {
  @raylib.Camera3D::new(
    @raylib.Vector3::new(game.camera_x, game.camera_y, game.camera_z),
    @raylib.Vector3::new(
      game.camera_look_x, game.camera_look_y, game.camera_look_z,
    ),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
}

fn draw_ground(game : @types.Game) -> Unit {
  let gc = @levels.get_track_ground_color(game.current_cup, game.current_race)
  // Draw a large ground plane
  @raylib.draw_plane(
    @raylib.Vector3::new(15.0, -0.05, 20.0),
    @raylib.Vector2::new(200.0, 200.0),
    @raylib.Color::new(gc.0, gc.1, gc.2, 255),
  )
}

fn draw_track(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 2 { return }
  let rc = @levels.get_track_road_color(game.current_cup, game.current_race)
  let road_color = @raylib.Color::new(rc.0, rc.1, rc.2, 255)
  let edge_color = @raylib.Color::new(
    @types.clampi(rc.0 + 40, 0, 255),
    @types.clampi(rc.1 + 40, 0, 255),
    @types.clampi(rc.2 + 40, 0, 255),
    255,
  )
  let stripe_color = @raylib.Color::new(200, 200, 200, 200)
  for i = 0; i < wc; i = i + 1 {
    let wp0 = game.waypoints[i]
    let wp1 = game.waypoints[(i + 1) % wc]
    // Direction vector
    let dx = wp1.x - wp0.x
    let dz = wp1.z - wp0.z
    let dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
    if dist < 0.01 { continue i + 1 }
    // Perpendicular for road width
    let px = -dz / dist * @types.road_half
    let pz = dx / dist * @types.road_half
    // Draw road surface as series of cubes along the segment
    let steps = (dist / 2.0).to_int() + 1
    for s = 0; s < steps; s = s + 1 {
      let t = Float::from_int(s) / Float::from_int(steps)
      let cx = @types.lerpf(wp0.x, wp1.x, t)
      let cy = @types.lerpf(wp0.y, wp1.y, t)
      let cz = @types.lerpf(wp0.z, wp1.z, t)
      @raylib.draw_cube(
        @raylib.Vector3::new(cx, cy, cz),
        @types.road_width,
        0.1,
        2.5,
        road_color,
      )
    }
    // Road edge markers at waypoints
    @raylib.draw_cube(
      @raylib.Vector3::new(wp0.x + px, wp0.y + 0.1, wp0.z + pz),
      0.4,
      0.2,
      0.4,
      edge_color,
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(wp0.x - px, wp0.y + 0.1, wp0.z - pz),
      0.4,
      0.2,
      0.4,
      edge_color,
    )
    // Center stripe at midpoint
    let mx = (wp0.x + wp1.x) / 2.0
    let mz = (wp0.z + wp1.z) / 2.0
    let my = (wp0.y + wp1.y) / 2.0
    @raylib.draw_cube(
      @raylib.Vector3::new(mx, my + 0.06, mz), 0.2, 0.02, 0.8, stripe_color,
    )
  }
}

fn draw_start_finish_line(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 2 { return }
  let wp0 = game.waypoints[0]
  let wp1 = game.waypoints[1]
  let dx = wp1.x - wp0.x
  let dz = wp1.z - wp0.z
  let dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
  if dist < 0.01 { return }
  let px = -dz / dist * @types.road_half
  let pz = dx / dist * @types.road_half
  // Draw checkered start/finish line
  let num_checks = 8
  for c = 0; c < num_checks; c = c + 1 {
    let t = Float::from_int(c) / Float::from_int(num_checks) * 2.0 - 1.0
    let cx = wp0.x + px * t
    let cz = wp0.z + pz * t
    let color = if c % 2 == 0 {
      @raylib.Color::new(255, 255, 255, 255)
    } else {
      @raylib.Color::new(30, 30, 30, 255)
    }
    @raylib.draw_cube(
      @raylib.Vector3::new(cx, wp0.y + 0.08, cz), 0.8, 0.05, 0.8, color,
    )
  }
  // Finish arch poles
  @raylib.draw_cube(
    @raylib.Vector3::new(wp0.x + px * 1.2, wp0.y + 2.0, wp0.z + pz * 1.2),
    0.3,
    4.0,
    0.3,
    @raylib.Color::new(200, 200, 200, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wp0.x - px * 1.2, wp0.y + 2.0, wp0.z - pz * 1.2),
    0.3,
    4.0,
    0.3,
    @raylib.Color::new(200, 200, 200, 255),
  )
  // Top bar
  @raylib.draw_cube(
    @raylib.Vector3::new(wp0.x, wp0.y + 4.0, wp0.z),
    @types.road_width * 0.7,
    0.3,
    0.3,
    @raylib.Color::new(220, 40, 40, 255),
  )
}

fn draw_trackside_objects(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 3 { return }
  // Place trees/rocks along the track edges
  for i = 0; i < wc; i = i + 1 {
    let wp = game.waypoints[i]
    let next = game.waypoints[(i + 1) % wc]
    let dx = next.x - wp.x
    let dz = next.z - wp.z
    let dist = @types.distance2d(wp.x, wp.z, next.x, next.z)
    if dist < 0.01 { continue i + 1 }
    let px = -dz / dist
    let pz = dx / dist
    // Trees on the right side
    let tree_dist = @types.road_half + 4.0 + Float::from_int(i % 3) * 2.0
    let tx = wp.x + px * tree_dist
    let tz = wp.z + pz * tree_dist
    // Tree trunk
    @raylib.draw_cube(
      @raylib.Vector3::new(tx, wp.y + 1.0, tz),
      0.3,
      2.0,
      0.3,
      @raylib.Color::new(100, 70, 40, 255),
    )
    // Tree canopy
    @raylib.draw_sphere(
      @raylib.Vector3::new(tx, wp.y + 2.5, tz),
      1.0,
      @raylib.Color::new(40, 120 + i % 40, 30, 255),
    )
    // Rocks on the left side (every other waypoint)
    if i % 2 == 0 {
      let rock_dist = @types.road_half + 3.0 + Float::from_int(i % 5)
      let rx = wp.x - px * rock_dist
      let rz = wp.z - pz * rock_dist
      @raylib.draw_cube(
        @raylib.Vector3::new(rx, wp.y + 0.3, rz),
        0.8,
        0.6,
        0.8,
        @raylib.Color::new(110, 105, 95, 255),
      )
    }
  }
}

fn draw_karts(game : @types.Game) -> Unit {
  for i = 0; i < @types.max_karts; i = i + 1 {
    let kart = game.karts[i]
    if not(kart.active) { continue i + 1 }
    let colors = @types.kart_colors
    let ci = @types.clampi(i, 0, colors.length() - 1)
    let kc = colors[ci]
    let body_color = @raylib.Color::new(kc.0, kc.1, kc.2, 255)
    // Kart body (main cube)
    let kw = @types.kart_width
    let kh = @types.kart_height
    let kl = @types.kart_length
    let draw_y = kart.y + kh / 2.0
    // Spin visual rotation
    let visual_angle : Float = if kart.spin_timer > 0.0 {
      kart.angle + kart.spin_timer * 10.0
    } else {
      kart.angle
    }
    // Main body - we draw at kart position with direction indicator
    @raylib.draw_cube(
      @raylib.Vector3::new(kart.x, draw_y, kart.z), kw, kh, kl, body_color,
    )
    // Cockpit (smaller darker cube on top)
    @raylib.draw_cube(
      @raylib.Vector3::new(kart.x, draw_y + kh * 0.5, kart.z),
      kw * 0.6,
      kh * 0.4,
      kl * 0.5,
      @raylib.Color::new(kc.0 / 2, kc.1 / 2, kc.2 / 2, 255),
    )
    // Direction indicator (nose cone)
    let nose_x = kart.x + @math.sinf(visual_angle) * kl * 0.7
    let nose_z = kart.z + @math.cosf(visual_angle) * kl * 0.7
    @raylib.draw_cube(
      @raylib.Vector3::new(nose_x, draw_y, nose_z),
      kw * 0.4,
      kh * 0.6,
      0.3,
      @raylib.Color::new(255, 255, 255, 220),
    )
    // Wheels (4 small dark cubes)
    let wheel_color = @raylib.Color::new(30, 30, 30, 255)
    let wx_off = kw * 0.6
    let wz_off = kl * 0.35
    let sin_a = @math.sinf(visual_angle)
    let cos_a = @math.cosf(visual_angle)
    // Front-left
    let fl_x = kart.x + sin_a * wz_off + cos_a * wx_off
    let fl_z = kart.z + cos_a * wz_off - sin_a * wx_off
    @raylib.draw_cube(
      @raylib.Vector3::new(fl_x, kart.y + 0.1, fl_z),
      0.25,
      0.25,
      0.35,
      wheel_color,
    )
    // Front-right
    let fr_x = kart.x + sin_a * wz_off - cos_a * wx_off
    let fr_z = kart.z + cos_a * wz_off + sin_a * wx_off
    @raylib.draw_cube(
      @raylib.Vector3::new(fr_x, kart.y + 0.1, fr_z),
      0.25,
      0.25,
      0.35,
      wheel_color,
    )
    // Rear-left
    let rl_x = kart.x - sin_a * wz_off + cos_a * wx_off
    let rl_z = kart.z - cos_a * wz_off - sin_a * wx_off
    @raylib.draw_cube(
      @raylib.Vector3::new(rl_x, kart.y + 0.1, rl_z),
      0.25,
      0.25,
      0.35,
      wheel_color,
    )
    // Rear-right
    let rr_x = kart.x - sin_a * wz_off - cos_a * wx_off
    let rr_z = kart.z - cos_a * wz_off + sin_a * wx_off
    @raylib.draw_cube(
      @raylib.Vector3::new(rr_x, kart.y + 0.1, rr_z),
      0.25,
      0.25,
      0.35,
      wheel_color,
    )
    // Shield effect
    if kart.shield_timer > 0.0 {
      let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.2)
      let shield_size : Float = 1.2 + pulse * 0.1
      @raylib.draw_sphere(
        @raylib.Vector3::new(kart.x, draw_y + 0.2, kart.z),
        shield_size,
        @raylib.Color::new(100, 180, 255, 60),
      )
    }
    // Boost flame effect
    if kart.boost_timer > 0.0 {
      let tail_x = kart.x - @math.sinf(visual_angle) * kl * 0.7
      let tail_z = kart.z - @math.cosf(visual_angle) * kl * 0.7
      let flame_size : Float = 0.3 + @math.sinf(
          Float::from_int(game.frame_counter) * 0.5,
        ) * 0.1
      @raylib.draw_sphere(
        @raylib.Vector3::new(tail_x, draw_y, tail_z),
        flame_size,
        @raylib.Color::new(255, 150, 30, 200),
      )
    }
    // Drift sparks
    if kart.drift_left || kart.drift_right {
      if game.frame_counter % 4 == 0 {
        let spark_side : Float = if kart.drift_left { 1.0 } else { -1.0 }
        let sx = kart.x - sin_a * kl * 0.4 + cos_a * spark_side * kw * 0.5
        let sz = kart.z - cos_a * kl * 0.4 - sin_a * spark_side * kw * 0.5
        @raylib.draw_sphere(
          @raylib.Vector3::new(sx, kart.y + 0.1, sz),
          0.15,
          @raylib.Color::new(255, 200, 50, 255),
        )
      }
    }
    // Place number above kart
    ignore(visual_angle)
  }
}

fn draw_powerups(game : @types.Game) -> Unit {
  for i = 0; i < game.powerups.length(); i = i + 1 {
    let pu = game.powerups[i]
    if not(pu.active) || pu.collected { continue i + 1 }
    let bob = @math.sinf(Float::from_int(game.frame_counter) * 0.08 + Float::from_int(
        i,
      )) *
      0.3
    let py = pu.y + bob
    let spin = Float::from_int(game.frame_counter) * 0.05
    let size : Float = 0.5
    let color = if pu.kind == @types.powerup_boost {
      @raylib.Color::new(255, 200, 0, 220)
    } else if pu.kind == @types.powerup_shield {
      @raylib.Color::new(80, 180, 255, 220)
    } else {
      @raylib.Color::new(255, 80, 60, 220)
    }
    // Rotating cube for powerup
    @raylib.draw_cube(
      @raylib.Vector3::new(pu.x, py, pu.z), size, size, size, color,
    )
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(pu.x, py, pu.z), size + 0.05, size + 0.05,
      size + 0.05, @raylib.Color::new(255, 255, 255, 150),
    )
    // Question mark base
    @raylib.draw_cube(
      @raylib.Vector3::new(pu.x, pu.y - 0.5, pu.z),
      0.2,
      0.3,
      0.2,
      @raylib.Color::new(100, 100, 100, 200),
    )
    ignore(spin)
  }
}

fn draw_projectiles(game : @types.Game) -> Unit {
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    let proj = game.projectiles[i]
    if not(proj.active) { continue i + 1 }
    @raylib.draw_sphere(
      @raylib.Vector3::new(proj.x, proj.y, proj.z),
      0.25,
      @raylib.Color::new(255, 80, 30, 255),
    )
    // Trail
    let trail_x = proj.x - @math.sinf(proj.angle) * 0.5
    let trail_z = proj.z - @math.cosf(proj.angle) * 0.5
    @raylib.draw_sphere(
      @raylib.Vector3::new(trail_x, proj.y, trail_z),
      0.15,
      @raylib.Color::new(255, 150, 50, 150),
    )
  }
}

fn draw_particles_3d(game : @types.Game) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) { continue i + 1 }
    let alpha = (p.life / p.max_life * 255.0).to_int()
    let a = @types.clampi(alpha, 0, 255)
    @raylib.draw_cube(
      @raylib.Vector3::new(p.x, p.y, p.z), p.size, p.size, p.size,
      @raylib.Color::new(p.r, p.g, p.b, a),
    )
  }
}

// Draw theme-specific track decorations using decoration data from levels
fn draw_themed_decorations(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 3 { return }
  let deco_data = @levels.get_track_decoration_data(
    game.current_cup, game.current_race,
  )
  for di = 0; di < deco_data.length(); di = di + 1 {
    let deco = deco_data[di]
    let deco_type = deco.0
    let x_offset = deco.1
    let z_progress = deco.2
    let scale = deco.3
    // Place decoration along each segment based on z_progress
    for si = 0; si < wc; si = si + 1 {
      let wp0 = game.waypoints[si]
      let wp1 = game.waypoints[(si + 1) % wc]
      let dx = wp1.x - wp0.x
      let dz = wp1.z - wp0.z
      let dist = @types.distance2d(wp0.x, wp0.z, wp1.x, wp1.z)
      if dist < 0.01 { continue si + 1 }
      // Only place decorations at matching segment progress
      let seg_match_f : Float = Float::from_int(si) / Float::from_int(wc)
      let diff = @types.absf(seg_match_f - z_progress)
      if diff > 0.15 && diff < 0.85 { continue si + 1 }
      let px = -dz / dist
      let pz = dx / dist
      let deco_x = wp0.x + px * x_offset
      let deco_z = wp0.z + pz * x_offset
      let deco_y = wp0.y
      draw_decoration_object(deco_type, deco_x, deco_y, deco_z, scale, game)
    }
  }
}

// Helper to scale a float value
fn sf(v : Float, s : Float) -> Float {
  v * s
}

// Draw a single decoration object based on type
fn draw_decoration_object(
  deco_type : Int,
  x : Float,
  y : Float,
  z : Float,
  scale : Float,
  game : @types.Game
) -> Unit {
  ignore(game)
  if deco_type == @types.deco_tree_green {
    let trunk_h : Float = sf(1.8, scale)
    let canopy_r : Float = sf(1.0, scale)
    let half_trunk : Float = trunk_h * 0.5
    let trunk_w : Float = sf(0.25, scale)
    let canopy_y : Float = y + trunk_h + canopy_r * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + half_trunk, z),
      trunk_w, trunk_h, trunk_w,
      @raylib.Color::new(100, 70, 40, 255),
    )
    @raylib.draw_sphere(
      @raylib.Vector3::new(x, canopy_y, z),
      canopy_r,
      @raylib.Color::new(40, 130, 30, 255),
    )
  } else if deco_type == @types.deco_tree_pine {
    let trunk_h : Float = sf(2.0, scale)
    let trunk_w : Float = sf(0.2, scale)
    let half_trunk : Float = trunk_h * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + half_trunk, z),
      trunk_w, trunk_h, trunk_w,
      @raylib.Color::new(80, 55, 30, 255),
    )
    let c1w : Float = sf(1.2, scale)
    let c1h : Float = sf(0.8, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + half_trunk, z),
      c1w, c1h, c1w,
      @raylib.Color::new(30, 90, 40, 255),
    )
    let c2w : Float = sf(0.9, scale)
    let c2h : Float = sf(0.7, scale)
    let c2y : Float = y + trunk_h * 0.8
    @raylib.draw_cube(
      @raylib.Vector3::new(x, c2y, z),
      c2w, c2h, c2w,
      @raylib.Color::new(35, 100, 45, 255),
    )
    let c3w : Float = sf(0.6, scale)
    let c3y : Float = y + trunk_h * 1.1
    @raylib.draw_cube(
      @raylib.Vector3::new(x, c3y, z),
      c3w, c3w, c3w,
      @raylib.Color::new(40, 110, 50, 255),
    )
  } else if deco_type == @types.deco_tree_palm {
    let trunk_h : Float = sf(2.5, scale)
    let trunk_w : Float = sf(0.2, scale)
    let half_trunk : Float = trunk_h * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + half_trunk, z),
      trunk_w, trunk_h, trunk_w,
      @raylib.Color::new(130, 100, 50, 255),
    )
    let top_y : Float = y + trunk_h
    let frond_l : Float = sf(1.0, scale)
    let frond_h : Float = sf(0.1, scale)
    let frond_w : Float = sf(0.3, scale)
    let frond_off : Float = sf(0.5, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x + frond_off, top_y, z),
      frond_l, frond_h, frond_w,
      @raylib.Color::new(50, 150, 40, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x - frond_off, top_y, z),
      frond_l, frond_h, frond_w,
      @raylib.Color::new(45, 140, 35, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, top_y, z + frond_off),
      frond_w, frond_h, frond_l,
      @raylib.Color::new(55, 145, 42, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, top_y, z - frond_off),
      frond_w, frond_h, frond_l,
      @raylib.Color::new(48, 135, 38, 255),
    )
  } else if deco_type == @types.deco_rock_small {
    let ry : Float = y + sf(0.25, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, ry, z),
      sf(0.6, scale), sf(0.5, scale), sf(0.5, scale),
      @raylib.Color::new(110, 105, 95, 255),
    )
  } else if deco_type == @types.deco_rock_large {
    let ry : Float = y + sf(0.5, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, ry, z),
      sf(1.2, scale), sf(1.0, scale), sf(1.0, scale),
      @raylib.Color::new(90, 85, 75, 255),
    )
    let ry2 : Float = y + sf(0.8, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x + sf(0.3, scale), ry2, z - sf(0.2, scale)),
      sf(0.6, scale), sf(0.4, scale), sf(0.5, scale),
      @raylib.Color::new(100, 95, 85, 255),
    )
  } else if deco_type == @types.deco_barrier_metal {
    let bh_half : Float = @types.barrier_height * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + bh_half, z),
      @types.barrier_width * scale, @types.barrier_height * scale, sf(2.0, scale),
      @raylib.Color::new(160, 160, 170, 255),
    )
  } else if deco_type == @types.deco_barrier_tire {
    let tw : Float = sf(0.4, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + 0.2, z),
      tw, tw, tw,
      @raylib.Color::new(30, 30, 30, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + 0.6, z),
      tw, tw, tw,
      @raylib.Color::new(35, 35, 35, 255),
    )
  } else if deco_type == @types.deco_grandstand {
    let gw : Float = sf(3.0, scale)
    let gh : Float = sf(2.0, scale)
    let gh_half : Float = gh * 0.5
    let gd : Float = sf(1.5, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + gh_half, z),
      gw, gh, gd,
      @raylib.Color::new(180, 170, 150, 255),
    )
    let roof_y : Float = y + gh + sf(0.1, scale)
    let roof_w : Float = gw + sf(0.5, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, roof_y, z),
      roof_w, sf(0.2, scale), sf(2.0, scale),
      @raylib.Color::new(140, 40, 40, 255),
    )
    let seat_w : Float = gw * 0.9
    let seat_z : Float = z + sf(0.4, scale)
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(0.3, scale), seat_z),
      seat_w, sf(0.15, scale), sf(0.3, scale),
      @raylib.Color::new(200, 60, 60, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(0.7, scale), seat_z),
      seat_w, sf(0.15, scale), sf(0.3, scale),
      @raylib.Color::new(60, 60, 200, 255),
    )
  } else if deco_type == @types.deco_building_small {
    let bw : Float = sf(2.0, scale)
    let bh : Float = sf(3.0, scale)
    let bh_half : Float = bh * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + bh_half, z),
      bw, bh, bw,
      @raylib.Color::new(160, 150, 140, 255),
    )
    let win_w : Float = sf(0.3, scale)
    let win_h : Float = sf(0.4, scale)
    let win_d : Float = sf(0.05, scale)
    let bw_off : Float = bw * 0.3
    let bw_front : Float = z + bw * 0.51
    let win_y1 : Float = y + bh * 0.3
    let win_y2 : Float = y + bh * 0.65
    @raylib.draw_cube(
      @raylib.Vector3::new(x - bw_off, win_y1, bw_front),
      win_w, win_h, win_d,
      @raylib.Color::new(100, 150, 200, 200),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x + bw_off, win_y1, bw_front),
      win_w, win_h, win_d,
      @raylib.Color::new(100, 150, 200, 200),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x - bw_off, win_y2, bw_front),
      win_w, win_h, win_d,
      @raylib.Color::new(100, 150, 200, 200),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x + bw_off, win_y2, bw_front),
      win_w, win_h, win_d,
      @raylib.Color::new(100, 150, 200, 200),
    )
  } else if deco_type == @types.deco_building_tall {
    let bw : Float = sf(2.5, scale)
    let bh : Float = sf(6.0, scale)
    let bh_half : Float = bh * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + bh_half, z),
      bw, bh, bw,
      @raylib.Color::new(140, 140, 150, 255),
    )
    let bw_off : Float = bw * 0.25
    let bw_front : Float = z + bw * 0.51
    let win_w : Float = sf(0.25, scale)
    let win_h : Float = sf(0.35, scale)
    let win_d : Float = sf(0.05, scale)
    for wy = 0; wy < 4; wy = wy + 1 {
      let wy_f = Float::from_int(wy)
      let win_y : Float = y + sf(1.0, scale) + wy_f * sf(1.2, scale)
      @raylib.draw_cube(
        @raylib.Vector3::new(x - bw_off, win_y, bw_front),
        win_w, win_h, win_d,
        @raylib.Color::new(150, 200, 240, 200),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(x + bw_off, win_y, bw_front),
        win_w, win_h, win_d,
        @raylib.Color::new(150, 200, 240, 200),
      )
    }
  } else if deco_type == @types.deco_cactus {
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(0.8, scale), z),
      sf(0.3, scale), sf(1.6, scale), sf(0.3, scale),
      @raylib.Color::new(60, 120, 40, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x + sf(0.4, scale), y + sf(1.0, scale), z),
      sf(0.5, scale), sf(0.2, scale), sf(0.2, scale),
      @raylib.Color::new(55, 115, 35, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x + sf(0.6, scale), y + sf(1.3, scale), z),
      sf(0.2, scale), sf(0.5, scale), sf(0.2, scale),
      @raylib.Color::new(55, 115, 35, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x - sf(0.35, scale), y + sf(0.7, scale), z),
      sf(0.4, scale), sf(0.2, scale), sf(0.2, scale),
      @raylib.Color::new(50, 110, 30, 255),
    )
  } else if deco_type == @types.deco_snow_mound {
    @raylib.draw_sphere(
      @raylib.Vector3::new(x, y + sf(0.3, scale), z),
      sf(0.8, scale),
      @raylib.Color::new(230, 235, 240, 255),
    )
    @raylib.draw_sphere(
      @raylib.Vector3::new(x + sf(0.3, scale), y + sf(0.2, scale), z + sf(0.2, scale)),
      sf(0.5, scale),
      @raylib.Color::new(225, 230, 235, 255),
    )
  } else if deco_type == @types.deco_lava_rock {
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(0.4, scale), z),
      sf(0.8, scale), sf(0.8, scale), sf(0.7, scale),
      @raylib.Color::new(100, 40, 20, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + 0.1, z),
      sf(0.9, scale), 0.05, sf(0.8, scale),
      @raylib.Color::new(255, 100, 20, 150),
    )
  } else if deco_type == @types.deco_lamp_post {
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(1.5, scale), z),
      sf(0.1, scale), sf(3.0, scale), sf(0.1, scale),
      @raylib.Color::new(120, 120, 130, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + sf(3.0, scale), z),
      sf(0.4, scale), sf(0.15, scale), sf(0.4, scale),
      @raylib.Color::new(200, 200, 150, 255),
    )
    @raylib.draw_sphere(
      @raylib.Vector3::new(x, y + sf(2.9, scale), z),
      sf(0.2, scale),
      @raylib.Color::new(255, 240, 180, 100),
    )
  } else if deco_type == @types.deco_sign_board {
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + 0.8, z),
      0.1, 1.6, 0.1,
      @raylib.Color::new(100, 100, 110, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(x, y + 1.5, z),
      sf(1.0, scale), sf(0.6, scale), 0.05,
      @raylib.Color::new(180, 180, 40, 255),
    )
  }
}

// Draw track surface visual differences (boost pads, dirt patches, ice patches)
fn draw_surface_indicators(game : @types.Game) -> Unit {
  let wc = game.waypoint_count
  if wc < 2 { return }
  for i = 0; i < wc; i = i + 1 {
    let seg = game.segments[i]
    let wp0 = game.waypoints[i]
    let wp1 = game.waypoints[(i + 1) % wc]
    let mx = (wp0.x + wp1.x) / 2.0
    let my = (wp0.y + wp1.y) / 2.0
    let mz = (wp0.z + wp1.z) / 2.0
    if seg.surface_type == @types.surface_boost_pad {
      // Boost pad arrows
      let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.15)
      let alpha_f : Float = 150.0 + pulse * 50.0
      let alpha = @types.clampi(alpha_f.to_int(), 100, 200)
      @raylib.draw_cube(
        @raylib.Vector3::new(mx, my + 0.08, mz),
        @types.road_width * seg.width_mult * 0.8,
        0.06,
        3.0,
        @raylib.Color::new(255, 200, 0, alpha),
      )
      // Arrow chevrons
      @raylib.draw_cube(
        @raylib.Vector3::new(mx, my + 0.09, mz - 0.8),
        @types.road_width * seg.width_mult * 0.5,
        0.04,
        0.3,
        @raylib.Color::new(255, 255, 100, alpha),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(mx, my + 0.09, mz + 0.8),
        @types.road_width * seg.width_mult * 0.5,
        0.04,
        0.3,
        @raylib.Color::new(255, 255, 100, alpha),
      )
    } else if seg.surface_type == @types.surface_dirt {
      // Dirt patch texture
      @raylib.draw_cube(
        @raylib.Vector3::new(mx - 1.0, my + 0.02, mz + 0.5),
        1.5,
        0.01,
        1.2,
        @raylib.Color::new(140, 110, 70, 80),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(mx + 1.5, my + 0.02, mz - 0.3),
        1.0,
        0.01,
        0.8,
        @raylib.Color::new(150, 120, 75, 60),
      )
    } else if seg.surface_type == @types.surface_ice {
      // Ice shimmer
      let shimmer = @math.sinf(Float::from_int(game.frame_counter) * 0.1 + Float::from_int(
          i,
        ))
      let ice_alpha_f : Float = 50.0 + shimmer * 20.0
      let ice_alpha = @types.clampi(ice_alpha_f.to_int(), 30, 80)
      @raylib.draw_cube(
        @raylib.Vector3::new(mx, my + 0.05, mz),
        @types.road_width * seg.width_mult,
        0.03,
        3.0,
        @raylib.Color::new(200, 220, 255, ice_alpha),
      )
    }
  }
}

// Draw skybox elements based on theme
fn draw_skybox_elements(game : @types.Game) -> Unit {
  let theme = @levels.get_track_theme(game.current_cup, game.current_race)
  let sky_c = @levels.get_track_sky_color(game.current_cup, game.current_race)
  let grad_c = @levels.get_sky_gradient_color(game.current_cup, game.current_race)
  // Horizon gradient band
  let player = game.karts[@types.player_kart]
  let horizon_y : Float = -5.0
  let horizon_dist : Float = 80.0
  // Draw distant horizon cubes around the player
  for h = 0; h < 8; h = h + 1 {
    let angle_f = Float::from_int(h) * @types.two_pi / 8.0
    let hx = player.x + @math.sinf(angle_f) * horizon_dist
    let hz = player.z + @math.cosf(angle_f) * horizon_dist
    @raylib.draw_cube(
      @raylib.Vector3::new(hx, horizon_y, hz),
      30.0,
      10.0,
      30.0,
      @raylib.Color::new(grad_c.0, grad_c.1, grad_c.2, 80),
    )
  }
  // Theme-specific sky objects
  if theme == @types.theme_night {
    // Stars in the sky
    for s = 0; s < 12; s = s + 1 {
      let sa = Float::from_int(s) * @types.two_pi / 12.0 + game.preview_rotation * 0.1
      let sr : Float = 50.0 + Float::from_int(s % 3) * 10.0
      let star_x = player.x + @math.sinf(sa) * sr
      let star_z = player.z + @math.cosf(sa) * sr
      let star_y : Float = 25.0 + Float::from_int(s % 4) * 5.0
      let twinkle = @math.sinf(Float::from_int(game.frame_counter) * 0.1 + Float::from_int(
          s,
        ))
      let star_alpha_f : Float = 150.0 + twinkle * 80.0
      let star_alpha = @types.clampi(star_alpha_f.to_int(), 80, 230)
      @raylib.draw_sphere(
        @raylib.Vector3::new(star_x, star_y, star_z),
        0.15,
        @raylib.Color::new(255, 255, 230, star_alpha),
      )
    }
  } else if theme == @types.theme_volcano {
    // Smoke/ash in the air
    for s = 0; s < 6; s = s + 1 {
      let sa = Float::from_int(s) * @types.two_pi / 6.0
      let sr : Float = 30.0 + Float::from_int(s) * 5.0
      let smoke_x = player.x + @math.sinf(sa) * sr
      let smoke_z = player.z + @math.cosf(sa) * sr
      let smoke_y : Float = 10.0 + Float::from_int(s % 3) * 3.0
      @raylib.draw_sphere(
        @raylib.Vector3::new(smoke_x, smoke_y, smoke_z),
        2.0,
        @raylib.Color::new(80, 60, 50, 40),
      )
    }
  }
  ignore(sky_c)
}

// Draw kart detail: exhaust pipes, spoiler, engine details
fn draw_kart_details(game : @types.Game) -> Unit {
  for i = 0; i < @types.max_karts; i = i + 1 {
    let kart = game.karts[i]
    if not(kart.active) { continue i + 1 }
    let ci = @types.clampi(i, 0, @types.kart_accent_colors.length() - 1)
    let ac = @types.kart_accent_colors[ci]
    let sin_a = @math.sinf(kart.angle)
    let cos_a = @math.cosf(kart.angle)
    let draw_y = kart.y + @types.kart_height * 0.5
    // Exhaust pipe (rear)
    let ex_x = kart.x - sin_a * @types.kart_length * 0.55 +
      cos_a * @types.kart_width * 0.3
    let ex_z = kart.z - cos_a * @types.kart_length * 0.55 -
      sin_a * @types.kart_width * 0.3
    @raylib.draw_cube(
      @raylib.Vector3::new(ex_x, draw_y - 0.1, ex_z),
      0.1,
      0.1,
      0.2,
      @raylib.Color::new(80, 80, 80, 255),
    )
    // Spoiler/wing (rear top)
    let sp_x = kart.x - sin_a * @types.kart_length * 0.45
    let sp_z = kart.z - cos_a * @types.kart_length * 0.45
    @raylib.draw_cube(
      @raylib.Vector3::new(sp_x, draw_y + @types.kart_height * 0.5, sp_z),
      @types.kart_width * 0.8,
      0.05,
      0.15,
      @raylib.Color::new(ac.0, ac.1, ac.2, 255),
    )
    // Spoiler supports
    let sup_left_x = sp_x + cos_a * @types.kart_width * 0.3
    let sup_left_z = sp_z - sin_a * @types.kart_width * 0.3
    @raylib.draw_cube(
      @raylib.Vector3::new(sup_left_x, draw_y + @types.kart_height * 0.25, sup_left_z),
      0.05,
      @types.kart_height * 0.4,
      0.05,
      @raylib.Color::new(ac.0, ac.1, ac.2, 255),
    )
    let sup_right_x = sp_x - cos_a * @types.kart_width * 0.3
    let sup_right_z = sp_z + sin_a * @types.kart_width * 0.3
    @raylib.draw_cube(
      @raylib.Vector3::new(sup_right_x, draw_y + @types.kart_height * 0.25, sup_right_z),
      0.05,
      @types.kart_height * 0.4,
      0.05,
      @raylib.Color::new(ac.0, ac.1, ac.2, 255),
    )
  }
}
