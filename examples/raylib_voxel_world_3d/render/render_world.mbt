// 3D world rendering

///|
pub fn draw_world(game : @types.Game) -> Unit {
  let camera = build_camera(game)
  @raylib.begin_mode_3d(camera)
  draw_sky_objects(game)
  draw_chunks(game)
  draw_block_highlight(game)
  draw_face_highlight(game)
  draw_mining_progress(game)
  draw_entities(game)
  draw_particles(game)
  draw_decorations(game)
  draw_torch_glow_effects(game)
  draw_water_surface_effects(game)
  draw_tool_in_hand(game)
  @raylib.end_mode_3d()
}

///|
fn build_camera(game : @types.Game) -> @raylib.Camera3D {
  @raylib.Camera3D::new(
    @raylib.Vector3::new(game.cam_pos_x, game.cam_pos_y, game.cam_pos_z),
    @raylib.Vector3::new(
      game.cam_target_x,
      game.cam_target_y,
      game.cam_target_z,
    ),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
}

// ========== Sky objects (sun, moon, stars) ==========

///|
fn draw_sky_objects(game : @types.Game) -> Unit {
  let t = game.day_timer / @types.day_length
  // Sun
  let sun_y = @math.cosf(game.sun_angle) * 80.0
  let sun_z_offset = @math.sinf(game.sun_angle) * 80.0
  let sun_x = game.cam_pos_x
  let sun_z = game.cam_pos_z + sun_z_offset
  if sun_y > -10.0 {
    // Sun color changes throughout day
    let sun_r : Int = if t < 0.15 || t > 0.5 { 255 } else { 255 }
    let sun_g : Int = if t < 0.15 || t > 0.5 { 180 } else { 230 }
    let sun_b : Int = if t < 0.15 || t > 0.5 { 50 } else { 100 }
    let sun_color = @raylib.Color::new(sun_r, sun_g, sun_b, 255)
    @raylib.draw_sphere(
      @raylib.Vector3::new(sun_x, sun_y + 50.0, sun_z),
      5.0,
      sun_color,
    )
    // Sun glow
    @raylib.draw_sphere(
      @raylib.Vector3::new(sun_x, sun_y + 50.0, sun_z),
      7.0,
      @raylib.Color::new(sun_r, sun_g, sun_b, 60),
    )
  }
  // Moon (opposite side)
  let moon_y = -sun_y
  let moon_z = game.cam_pos_z - sun_z_offset
  if moon_y > -10.0 {
    @raylib.draw_sphere(
      @raylib.Vector3::new(sun_x, moon_y + 50.0, moon_z),
      3.5,
      @raylib.Color::new(220, 220, 240, 255),
    )
  }
  // Stars at night
  if game.is_night {
    draw_stars(game)
  }
}

///|
fn draw_stars(game : @types.Game) -> Unit {
  // Draw some fixed "stars" as small bright spheres
  let star_count = 20
  for i in 0..<star_count {
    let fi = Float::from_int(i)
    let angle = fi * 0.314 + 1.0
    let elevation : Float = 40.0 + @math.sinf(fi * 0.7 + 2.0) * 25.0
    let radius : Float = 60.0 + @math.cosf(fi * 0.5) * 20.0
    let sx = game.cam_pos_x + @math.cosf(angle) * radius
    let sy : Float = elevation + 20.0
    let sz = game.cam_pos_z + @math.sinf(angle) * radius
    // Twinkle effect
    let twinkle = @math.sinf(game.day_timer * 3.0 + fi * 1.5)
    let alpha : Int = if twinkle > 0.0 { 255 } else { 140 }
    @raylib.draw_sphere(
      @raylib.Vector3::new(sx, sy, sz),
      0.3,
      @raylib.Color::new(255, 255, 230, alpha),
    )
  }
}

// ========== Chunk rendering ==========

// Draw all visible blocks in chunks near the player

///|
fn draw_chunks(game : @types.Game) -> Unit {
  let player = game.player
  // Determine which chunk the player is in
  let pcx = player.x.to_int() / @types.chunk_x
  let pcz = player.z.to_int() / @types.chunk_z
  let rd = @types.render_distance
  let min_cx = @types.maxi(0, pcx - rd)
  let max_cx = @types.mini(@types.world_chunks_x - 1, pcx + rd)
  let min_cz = @types.maxi(0, pcz - rd)
  let max_cz = @types.mini(@types.world_chunks_z - 1, pcz + rd)
  for cz in min_cz..=max_cz {
    for cx in min_cx..=max_cx {
      draw_chunk_blocks(game, cx, cz)
    }
  }
}

// Draw visible blocks in a single chunk

///|
fn draw_chunk_blocks(game : @types.Game, cx : Int, cz : Int) -> Unit {
  let chunk = game.chunks[cz * @types.world_chunks_x + cx]
  let base_wx = cx * @types.chunk_x
  let base_wz = cz * @types.chunk_z
  // Only render blocks near player height +/- some range for performance
  let player_y = game.player.y.to_int()
  let min_y = @types.maxi(0, player_y - 20)
  let max_y = @types.mini(@types.chunk_y - 1, player_y + 20)
  // Distance from player to chunk center for fog
  let chunk_center_x = Float::from_int(base_wx + @types.chunk_x / 2)
  let chunk_center_z = Float::from_int(base_wz + @types.chunk_z / 2)
  let chunk_dist = @types.distance_xz(
    game.player.x,
    game.player.z,
    chunk_center_x,
    chunk_center_z,
  )
  // Skip chunk if too far (beyond fog)
  if chunk_dist > @types.fog_end_distance + 16.0 {
    return
  }
  for ly in min_y..=max_y {
    for lz in 0..<@types.chunk_z {
      for lx in 0..<@types.chunk_x {
        let block = chunk.get_block(lx, ly, lz)
        if block == @types.block_air {
          continue
        }
        // Skip decorations (rendered separately)
        if @types.is_decoration(block) {
          continue
        }
        let wx = base_wx + lx
        let wz = base_wz + lz
        // Check if this block has at least one visible face
        let has_visible_face = @types.is_face_visible(game, wx - 1, ly, wz) ||
          @types.is_face_visible(game, wx + 1, ly, wz) ||
          @types.is_face_visible(game, wx, ly - 1, wz) ||
          @types.is_face_visible(game, wx, ly + 1, wz) ||
          @types.is_face_visible(game, wx, ly, wz - 1) ||
          @types.is_face_visible(game, wx, ly, wz + 1)
        if not(has_visible_face) {
          continue
        }
        // Draw the block with distance-based fog
        let block_dist = @types.distance_xz(
          game.player.x,
          game.player.z,
          Float::from_int(wx) + 0.5,
          Float::from_int(wz) + 0.5,
        )
        draw_block_with_lighting(game, block, wx, ly, wz, block_dist)
      }
    }
  }
}

// Draw a single block with lighting and fog

///|
fn draw_block_with_lighting(
  game : @types.Game,
  block : Int,
  wx : Int,
  wy : Int,
  wz : Int,
  dist : Float,
) -> Unit {
  let fx = Float::from_int(wx) + 0.5
  let fy = Float::from_int(wy) + 0.5
  let fz = Float::from_int(wz) + 0.5
  let mut r = @levels.block_color_r(block)
  let mut g = @levels.block_color_g(block)
  let mut b = @levels.block_color_b(block)
  let a = @levels.block_alpha(block)
  // Height-based shading: blocks deep underground are darker
  let height_factor : Float = @types.clampf(
    Float::from_int(wy) / Float::from_int(@types.chunk_y),
    0.3,
    1.0,
  )
  r = (Float::from_int(r) * height_factor).to_int()
  g = (Float::from_int(g) * height_factor).to_int()
  b = (Float::from_int(b) * height_factor).to_int()
  // Day/night lighting
  if game.is_night {
    // Check if near a torch for glow
    let mut near_torch = false
    let check_range = 4
    let neg_range = -check_range
    for dy in neg_range..=check_range {
      for dz in neg_range..=check_range {
        for dx in neg_range..=check_range {
          let check_block = @types.get_world_block(
            game,
            wx + dx,
            wy + dy,
            wz + dz,
          )
          if check_block == @types.block_torch {
            let torch_dist = @types.absf(Float::from_int(dx)) +
              @types.absf(Float::from_int(dy)) +
              @types.absf(Float::from_int(dz))
            if torch_dist < 5.0 {
              near_torch = true
            }
          }
        }
      }
    }
    if near_torch {
      // Warm torch light
      r = @types.mini(255, r + 30)
      g = @types.mini(255, g + 15)
    } else {
      // Night dimming
      r = r * 4 / 10
      g = g * 4 / 10
      b = b * 6 / 10
    }
  }
  // Overhang shadow: if block above is solid, darken slightly
  let above = @types.get_world_block(game, wx, wy + 1, wz)
  if @types.is_solid(above) {
    r = r * 7 / 10
    g = g * 7 / 10
    b = b * 7 / 10
  }
  // Fog blending
  if dist > @types.fog_start_distance {
    let fog_t = @types.clampf(
      (dist - @types.fog_start_distance) /
      (@types.fog_end_distance - @types.fog_start_distance),
      0.0,
      0.7,
    )
    let fr = @levels.fog_color_r(game.is_night)
    let fg = @levels.fog_color_g(game.is_night)
    let fb = @levels.fog_color_b(game.is_night)
    r = @types.lerpi(r, fr, fog_t)
    g = @types.lerpi(g, fg, fog_t)
    b = @types.lerpi(b, fb, fog_t)
  }
  r = @types.clampi(r, 0, 255)
  g = @types.clampi(g, 0, 255)
  b = @types.clampi(b, 0, 255)
  let color = @raylib.Color::new(r, g, b, a)
  @raylib.draw_cube(@raylib.Vector3::new(fx, fy, fz), 1.0, 1.0, 1.0, color)
  // Draw slightly darker wireframe for block edges
  let wr = r * 2 / 3
  let wg = g * 2 / 3
  let wb = b * 2 / 3
  let wire_color = @raylib.Color::new(wr, wg, wb, a)
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(fx, fy, fz),
    1.0,
    1.0,
    1.0,
    wire_color,
  )
}

// ========== Decoration rendering (flowers, grass, torches) ==========

///|
fn draw_decorations(game : @types.Game) -> Unit {
  let player = game.player
  let pcx = player.x.to_int() / @types.chunk_x
  let pcz = player.z.to_int() / @types.chunk_z
  let rd = @types.render_distance
  let min_cx = @types.maxi(0, pcx - rd)
  let max_cx = @types.mini(@types.world_chunks_x - 1, pcx + rd)
  let min_cz = @types.maxi(0, pcz - rd)
  let max_cz = @types.mini(@types.world_chunks_z - 1, pcz + rd)
  for cz in min_cz..=max_cz {
    for cx in min_cx..=max_cx {
      draw_chunk_decorations(game, cx, cz)
    }
  }
}

///|
fn draw_chunk_decorations(game : @types.Game, cx : Int, cz : Int) -> Unit {
  let chunk = game.chunks[cz * @types.world_chunks_x + cx]
  let base_wx = cx * @types.chunk_x
  let base_wz = cz * @types.chunk_z
  let player_y = game.player.y.to_int()
  let min_y = @types.maxi(0, player_y - 15)
  let max_y = @types.mini(@types.chunk_y - 1, player_y + 15)
  for ly in min_y..=max_y {
    for lz in 0..<@types.chunk_z {
      for lx in 0..<@types.chunk_x {
        let block = chunk.get_block(lx, ly, lz)
        if not(@types.is_decoration(block)) {
          continue
        }
        let wx = base_wx + lx
        let wz = base_wz + lz
        let fx = Float::from_int(wx) + 0.5
        let fy = Float::from_int(ly) + 0.5
        let fz = Float::from_int(wz) + 0.5
        if block == @types.block_flower_red {
          // Draw red flower as small cube
          @raylib.draw_cube(
            @raylib.Vector3::new(fx, fy - 0.2, fz),
            0.3,
            0.6,
            0.3,
            @raylib.Color::new(220, 40, 50, 255),
          )
          // Stem
          @raylib.draw_cube(
            @raylib.Vector3::new(fx, fy - 0.4, fz),
            0.08,
            0.4,
            0.08,
            @raylib.Color::new(40, 120, 30, 255),
          )
        } else if block == @types.block_flower_yellow {
          @raylib.draw_cube(
            @raylib.Vector3::new(fx, fy - 0.2, fz),
            0.3,
            0.6,
            0.3,
            @raylib.Color::new(255, 220, 50, 255),
          )
          @raylib.draw_cube(
            @raylib.Vector3::new(fx, fy - 0.4, fz),
            0.08,
            0.4,
            0.08,
            @raylib.Color::new(40, 120, 30, 255),
          )
        } else if block == @types.block_tall_grass {
          // Cross-shaped grass
          let sway = @math.sinf(game.day_timer * 2.0 + fx * 0.5 + fz * 0.3) *
            0.05
          @raylib.draw_cube(
            @raylib.Vector3::new(fx + sway, fy - 0.15, fz),
            0.05,
            0.7,
            0.5,
            @raylib.Color::new(60, 140, 30, 180),
          )
          @raylib.draw_cube(
            @raylib.Vector3::new(fx + sway, fy - 0.15, fz),
            0.5,
            0.7,
            0.05,
            @raylib.Color::new(50, 130, 25, 180),
          )
        } else if block == @types.block_torch {
          // Torch: yellow cube on a stick
          @raylib.draw_cube(
            @raylib.Vector3::new(fx, fy - 0.2, fz),
            0.15,
            0.5,
            0.15,
            @raylib.Color::new(139, 90, 43, 255),
          )
          // Flame
          let flicker = @math.sinf(game.day_timer * 8.0 + fx) * 0.03
          @raylib.draw_cube(
            @raylib.Vector3::new(fx + flicker, fy + 0.15, fz),
            0.2,
            0.2,
            0.2,
            @raylib.Color::new(255, 200, 50, 200),
          )
          // Light glow sphere
          @raylib.draw_sphere(
            @raylib.Vector3::new(fx, fy + 0.2, fz),
            0.4,
            @raylib.Color::new(255, 180, 30, 30),
          )
        }
      }
    }
  }
}

// ========== Block highlight and mining progress ==========

// Draw highlight around targeted block

///|
fn draw_block_highlight(game : @types.Game) -> Unit {
  let target = game.target
  if not(target.hit) {
    return
  }
  let fx = Float::from_int(target.bx) + 0.5
  let fy = Float::from_int(target.by) + 0.5
  let fz = Float::from_int(target.bz) + 0.5
  // Draw wireframe highlight
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(fx, fy, fz),
    1.02,
    1.02,
    1.02,
    @raylib.Color::new(255, 255, 255, 255),
  )
  // Draw a second slightly larger wireframe for visibility
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(fx, fy, fz),
    1.04,
    1.04,
    1.04,
    @raylib.Color::new(0, 0, 0, 180),
  )
}

///|
fn draw_mining_progress(game : @types.Game) -> Unit {
  let player = game.player
  if not(player.mining_active) {
    return
  }
  let fx = Float::from_int(player.mining_block_x) + 0.5
  let fy = Float::from_int(player.mining_block_y) + 0.5
  let fz = Float::from_int(player.mining_block_z) + 0.5
  // Draw crack effect: semi-transparent overlay that grows with progress
  let progress = player.mining_progress
  let crack_alpha = (progress * 180.0).to_int()
  let crack_size : Float = 1.0 + progress * 0.08
  @raylib.draw_cube(
    @raylib.Vector3::new(fx, fy, fz),
    crack_size,
    crack_size,
    crack_size,
    @raylib.Color::new(0, 0, 0, @types.clampi(crack_alpha, 0, 180)),
  )
  // Draw wireframe showing progress
  let wire_r : Int = @types.lerpi(255, 255, progress)
  let wire_g : Int = @types.lerpi(255, 0, progress)
  let wire_b = 0
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(fx, fy, fz),
    crack_size + 0.02,
    crack_size + 0.02,
    crack_size + 0.02,
    @raylib.Color::new(wire_r, wire_g, wire_b, 255),
  )
}

// ========== Entity rendering ==========

///|
fn draw_entities(game : @types.Game) -> Unit {
  for i in 0..<@types.entity_max {
    let ent = game.entities[i]
    if not(ent.active) {
      continue
    }
    // Check distance for culling
    let dist = @types.distance_xz(game.player.x, game.player.z, ent.x, ent.z)
    if dist > @types.fog_end_distance {
      continue
    }
    draw_entity(game, ent)
  }
}

///|
fn draw_entity(game : @types.Game, ent : @types.Entity) -> Unit {
  let x = ent.x
  let y = ent.y
  let z = ent.z
  // Damage flash: make entity white briefly
  let flash = ent.damage_flash > 0.0
  // Walking animation
  let leg_swing = @math.sinf(ent.anim_timer * 6.0) * 0.3
  if ent.kind == @types.entity_pig {
    draw_pig(x, y, z, ent.yaw, leg_swing, flash)
  } else if ent.kind == @types.entity_cow {
    draw_cow(x, y, z, ent.yaw, leg_swing, flash)
  } else if ent.kind == @types.entity_chicken {
    draw_chicken(x, y, z, ent.yaw, leg_swing, flash)
  } else if ent.kind == @types.entity_zombie {
    draw_zombie(x, y, z, ent.yaw, leg_swing, flash)
  } else if ent.kind == @types.entity_skeleton {
    draw_skeleton(x, y, z, ent.yaw, leg_swing, flash)
  } else if ent.kind == @types.entity_spider {
    draw_spider(x, y, z, ent.yaw, leg_swing, flash)
  }
  // Health bar above entity
  if ent.health < ent.max_health {
    let health_pct = Float::from_int(ent.health) /
      Float::from_int(ent.max_health)
    let bar_width : Float = 0.6
    let bar_y = y + 1.5
    // Background
    @raylib.draw_cube(
      @raylib.Vector3::new(x, bar_y, z),
      bar_width,
      0.08,
      0.08,
      @raylib.Color::new(60, 0, 0, 200),
    )
    // Health fill
    let fill_w = bar_width * health_pct
    let offset = (bar_width - fill_w) * 0.5
    let hr : Int = if health_pct > 0.5 { 0 } else { 255 }
    let hg : Int = if health_pct > 0.5 { 200 } else { 0 }
    @raylib.draw_cube(
      @raylib.Vector3::new(x - offset, bar_y, z),
      fill_w,
      0.08,
      0.08,
      @raylib.Color::new(hr, hg, 0, 200),
    )
  }
  ignore(game)
}

///|
fn draw_pig(
  x : Float,
  y : Float,
  z : Float,
  yaw : Float,
  leg_swing : Float,
  flash : Bool,
) -> Unit {
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(230, 170, 160, 255)
  }
  let snout_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(210, 140, 130, 255)
  }
  let cos_y = @math.cosf(yaw)
  let sin_y = @math.sinf(yaw)
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y + 0.4, z),
    0.5,
    0.4,
    0.7,
    body_color,
  )
  // Head
  let head_x = x + sin_y * 0.4
  let head_z = z + cos_y * 0.4
  @raylib.draw_cube(
    @raylib.Vector3::new(head_x, y + 0.5, head_z),
    0.35,
    0.35,
    0.35,
    body_color,
  )
  // Snout
  let snout_x = x + sin_y * 0.6
  let snout_z = z + cos_y * 0.6
  @raylib.draw_cube(
    @raylib.Vector3::new(snout_x, y + 0.45, snout_z),
    0.2,
    0.15,
    0.15,
    snout_color,
  )
  // Legs
  let leg_offset : Float = 0.15
  draw_entity_leg(x - leg_offset, y, z - leg_offset, leg_swing, body_color)
  draw_entity_leg(x + leg_offset, y, z - leg_offset, -leg_swing, body_color)
  draw_entity_leg(x - leg_offset, y, z + leg_offset, -leg_swing, body_color)
  draw_entity_leg(x + leg_offset, y, z + leg_offset, leg_swing, body_color)
}

///|
fn draw_cow(
  x : Float,
  y : Float,
  z : Float,
  yaw : Float,
  leg_swing : Float,
  flash : Bool,
) -> Unit {
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(120, 80, 50, 255)
  }
  let spot_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(240, 230, 220, 255)
  }
  let cos_y = @math.cosf(yaw)
  let sin_y = @math.sinf(yaw)
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y + 0.5, z),
    0.6,
    0.5,
    0.9,
    body_color,
  )
  // Spots on body
  @raylib.draw_cube(
    @raylib.Vector3::new(x + 0.1, y + 0.6, z - 0.1),
    0.25,
    0.2,
    0.3,
    spot_color,
  )
  // Head
  let head_x = x + sin_y * 0.5
  let head_z = z + cos_y * 0.5
  @raylib.draw_cube(
    @raylib.Vector3::new(head_x, y + 0.65, head_z),
    0.4,
    0.4,
    0.35,
    body_color,
  )
  // Horns
  @raylib.draw_cube(
    @raylib.Vector3::new(head_x - 0.2, y + 0.9, head_z),
    0.06,
    0.15,
    0.06,
    @raylib.Color::new(200, 190, 170, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(head_x + 0.2, y + 0.9, head_z),
    0.06,
    0.15,
    0.06,
    @raylib.Color::new(200, 190, 170, 255),
  )
  // Legs
  let lo : Float = 0.2
  draw_entity_leg(x - lo, y, z - lo * 1.5, leg_swing, body_color)
  draw_entity_leg(x + lo, y, z - lo * 1.5, -leg_swing, body_color)
  draw_entity_leg(x - lo, y, z + lo * 1.5, -leg_swing, body_color)
  draw_entity_leg(x + lo, y, z + lo * 1.5, leg_swing, body_color)
}

///|
fn draw_chicken(
  x : Float,
  y : Float,
  z : Float,
  yaw : Float,
  leg_swing : Float,
  flash : Bool,
) -> Unit {
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(240, 240, 235, 255)
  }
  let beak_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(255, 160, 50, 255)
  }
  let cos_y = @math.cosf(yaw)
  let sin_y = @math.sinf(yaw)
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y + 0.25, z),
    0.3,
    0.25,
    0.35,
    body_color,
  )
  // Head
  let head_x = x + sin_y * 0.25
  let head_z = z + cos_y * 0.25
  @raylib.draw_cube(
    @raylib.Vector3::new(head_x, y + 0.45, head_z),
    0.2,
    0.2,
    0.2,
    body_color,
  )
  // Beak
  let beak_x = x + sin_y * 0.38
  let beak_z = z + cos_y * 0.38
  @raylib.draw_cube(
    @raylib.Vector3::new(beak_x, y + 0.42, beak_z),
    0.08,
    0.06,
    0.1,
    beak_color,
  )
  // Comb
  @raylib.draw_cube(
    @raylib.Vector3::new(head_x, y + 0.58, head_z),
    0.1,
    0.08,
    0.06,
    @raylib.Color::new(220, 40, 30, 255),
  )
  // Legs (thin)
  @raylib.draw_cube(
    @raylib.Vector3::new(x - 0.06, y + 0.05 + leg_swing * 0.1, z),
    0.04,
    0.15,
    0.04,
    beak_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(x + 0.06, y + 0.05 - leg_swing * 0.1, z),
    0.04,
    0.15,
    0.04,
    beak_color,
  )
}

///|
fn draw_zombie(
  x : Float,
  y : Float,
  z : Float,
  yaw : Float,
  leg_swing : Float,
  flash : Bool,
) -> Unit {
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(80, 120, 70, 255)
  }
  let shirt_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(70, 70, 140, 255)
  }
  let cos_y = @math.cosf(yaw)
  let sin_y = @math.sinf(yaw)
  // Body (shirt)
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y + 0.8, z),
    0.45,
    0.6,
    0.25,
    shirt_color,
  )
  // Head
  let head_x = x + sin_y * 0.05
  let head_z = z + cos_y * 0.05
  @raylib.draw_cube(
    @raylib.Vector3::new(head_x, y + 1.3, head_z),
    0.35,
    0.35,
    0.35,
    body_color,
  )
  // Eyes (red)
  let eye_x = x + sin_y * 0.18
  let eye_z = z + cos_y * 0.18
  @raylib.draw_cube(
    @raylib.Vector3::new(eye_x - 0.08, y + 1.35, eye_z),
    0.06,
    0.04,
    0.04,
    @raylib.Color::new(200, 30, 30, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(eye_x + 0.08, y + 1.35, eye_z),
    0.06,
    0.04,
    0.04,
    @raylib.Color::new(200, 30, 30, 255),
  )
  // Arms (extended forward)
  let arm_x = x + sin_y * 0.5
  let arm_z = z + cos_y * 0.5
  @raylib.draw_cube(
    @raylib.Vector3::new(arm_x - 0.3, y + 0.9, arm_z),
    0.15,
    0.5,
    0.15,
    body_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(arm_x + 0.3, y + 0.9, arm_z),
    0.15,
    0.5,
    0.15,
    body_color,
  )
  // Legs
  let pants_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(60, 50, 90, 255)
  }
  @raylib.draw_cube(
    @raylib.Vector3::new(x - 0.12, y + 0.25 + leg_swing * 0.15, z),
    0.18,
    0.5,
    0.18,
    pants_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(x + 0.12, y + 0.25 - leg_swing * 0.15, z),
    0.18,
    0.5,
    0.18,
    pants_color,
  )
}

///|
fn draw_skeleton(
  x : Float,
  y : Float,
  z : Float,
  yaw : Float,
  leg_swing : Float,
  flash : Bool,
) -> Unit {
  let bone_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(220, 220, 210, 255)
  }
  let dark_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(40, 40, 40, 255)
  }
  let cos_y = @math.cosf(yaw)
  let sin_y = @math.sinf(yaw)
  // Ribcage
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y + 0.8, z),
    0.35,
    0.5,
    0.2,
    bone_color,
  )
  // Spine detail
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y + 0.8, z),
    0.08,
    0.5,
    0.08,
    dark_color,
  )
  // Skull
  let head_x = x + sin_y * 0.05
  let head_z = z + cos_y * 0.05
  @raylib.draw_cube(
    @raylib.Vector3::new(head_x, y + 1.3, head_z),
    0.3,
    0.3,
    0.3,
    bone_color,
  )
  // Eye sockets (dark)
  let eye_x = x + sin_y * 0.16
  let eye_z = z + cos_y * 0.16
  @raylib.draw_cube(
    @raylib.Vector3::new(eye_x - 0.07, y + 1.33, eye_z),
    0.06,
    0.06,
    0.06,
    dark_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(eye_x + 0.07, y + 1.33, eye_z),
    0.06,
    0.06,
    0.06,
    dark_color,
  )
  // Arms
  @raylib.draw_cube(
    @raylib.Vector3::new(x - 0.25, y + 0.8, z),
    0.08,
    0.5,
    0.08,
    bone_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(x + 0.25, y + 0.8, z),
    0.08,
    0.5,
    0.08,
    bone_color,
  )
  // Legs
  @raylib.draw_cube(
    @raylib.Vector3::new(x - 0.1, y + 0.25 + leg_swing * 0.15, z),
    0.08,
    0.5,
    0.08,
    bone_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(x + 0.1, y + 0.25 - leg_swing * 0.15, z),
    0.08,
    0.5,
    0.08,
    bone_color,
  )
  ignore(cos_y)
}

///|
fn draw_spider(
  x : Float,
  y : Float,
  z : Float,
  yaw : Float,
  leg_swing : Float,
  flash : Bool,
) -> Unit {
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(50, 40, 40, 255)
  }
  let eye_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(200, 20, 20, 255)
  }
  let cos_y = @math.cosf(yaw)
  let sin_y = @math.sinf(yaw)
  // Abdomen
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y + 0.3, z),
    0.5,
    0.3,
    0.6,
    body_color,
  )
  // Head
  let head_x = x + sin_y * 0.35
  let head_z = z + cos_y * 0.35
  @raylib.draw_cube(
    @raylib.Vector3::new(head_x, y + 0.3, head_z),
    0.35,
    0.25,
    0.3,
    body_color,
  )
  // Eyes (red, multiple)
  let eye_x = x + sin_y * 0.5
  let eye_z = z + cos_y * 0.5
  @raylib.draw_cube(
    @raylib.Vector3::new(eye_x - 0.08, y + 0.35, eye_z),
    0.05,
    0.05,
    0.05,
    eye_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(eye_x + 0.08, y + 0.35, eye_z),
    0.05,
    0.05,
    0.05,
    eye_color,
  )
  // Legs (4 pairs)
  let leg_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(60, 50, 50, 255)
  }
  for li in 0..<4 {
    let offset_z = Float::from_int(li) * 0.15 - 0.22
    let swing : Float = if li % 2 == 0 { leg_swing } else { -leg_swing }
    // Left leg
    @raylib.draw_cube(
      @raylib.Vector3::new(x - 0.4 - swing * 0.1, y + 0.15, z + offset_z),
      0.4,
      0.06,
      0.06,
      leg_color,
    )
    // Right leg
    @raylib.draw_cube(
      @raylib.Vector3::new(x + 0.4 + swing * 0.1, y + 0.15, z + offset_z),
      0.4,
      0.06,
      0.06,
      leg_color,
    )
  }
  ignore(cos_y)
}

///|
fn draw_entity_leg(
  x : Float,
  y : Float,
  z : Float,
  swing : Float,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_cube(
    @raylib.Vector3::new(x, y + 0.1 + swing * 0.08, z),
    0.12,
    0.22,
    0.12,
    color,
  )
}

// ========== Face-specific block highlight ==========

///|
fn draw_face_highlight(game : @types.Game) -> Unit {
  let target = game.target
  if not(target.hit) {
    return
  }
  let fx = Float::from_int(target.bx) + 0.5
  let fy = Float::from_int(target.by) + 0.5
  let fz = Float::from_int(target.bz) + 0.5
  // Draw a semi-transparent quad on the face the player is looking at
  let face_alpha = 60
  let face_color = @raylib.Color::new(255, 255, 255, face_alpha)
  let offset : Float = 0.505
  if target.nx == 1 {
    // Positive X face
    @raylib.draw_cube(
      @raylib.Vector3::new(fx + offset, fy, fz),
      0.01,
      1.0,
      1.0,
      face_color,
    )
  } else if target.nx == -1 {
    // Negative X face
    @raylib.draw_cube(
      @raylib.Vector3::new(fx - offset, fy, fz),
      0.01,
      1.0,
      1.0,
      face_color,
    )
  } else if target.ny == 1 {
    // Top face
    @raylib.draw_cube(
      @raylib.Vector3::new(fx, fy + offset, fz),
      1.0,
      0.01,
      1.0,
      face_color,
    )
  } else if target.ny == -1 {
    // Bottom face
    @raylib.draw_cube(
      @raylib.Vector3::new(fx, fy - offset, fz),
      1.0,
      0.01,
      1.0,
      face_color,
    )
  } else if target.nz == 1 {
    // Positive Z face
    @raylib.draw_cube(
      @raylib.Vector3::new(fx, fy, fz + offset),
      1.0,
      1.0,
      0.01,
      face_color,
    )
  } else if target.nz == -1 {
    // Negative Z face
    @raylib.draw_cube(
      @raylib.Vector3::new(fx, fy, fz - offset),
      1.0,
      1.0,
      0.01,
      face_color,
    )
  }
}

// ========== Torch glow effects ==========

///|
fn draw_torch_glow_effects(game : @types.Game) -> Unit {
  let player = game.player
  let pcx = player.x.to_int() / @types.chunk_x
  let pcz = player.z.to_int() / @types.chunk_z
  let rd = @types.render_distance
  let min_cx = @types.maxi(0, pcx - rd)
  let max_cx = @types.mini(@types.world_chunks_x - 1, pcx + rd)
  let min_cz = @types.maxi(0, pcz - rd)
  let max_cz = @types.mini(@types.world_chunks_z - 1, pcz + rd)
  let player_y = player.y.to_int()
  let min_y = @types.maxi(0, player_y - 12)
  let max_y = @types.mini(@types.chunk_y - 1, player_y + 12)
  for cz in min_cz..=max_cz {
    for cx in min_cx..=max_cx {
      let chunk = game.chunks[cz * @types.world_chunks_x + cx]
      let base_wx = cx * @types.chunk_x
      let base_wz = cz * @types.chunk_z
      for ly in min_y..=max_y {
        for lz in 0..<@types.chunk_z {
          for lx in 0..<@types.chunk_x {
            let block = chunk.get_block(lx, ly, lz)
            if block == @types.block_torch {
              let wx = base_wx + lx
              let wz = base_wz + lz
              let gx = Float::from_int(wx) + 0.5
              let gy = Float::from_int(ly) + 0.7
              let gz = Float::from_int(wz) + 0.5
              // Distance check
              let glow_dist = @types.distance_xz(player.x, player.z, gx, gz)
              if glow_dist < 20.0 {
                // Pulsing glow sphere
                let pulse = @math.sinf(game.day_timer * 4.0 + gx * 0.5) * 0.15 +
                  1.0
                let glow_size : Float = 1.2 * pulse
                @raylib.draw_sphere(
                  @raylib.Vector3::new(gx, gy, gz),
                  glow_size,
                  @raylib.Color::new(255, 180, 50, 15),
                )
                // Inner brighter glow
                @raylib.draw_sphere(
                  @raylib.Vector3::new(gx, gy, gz),
                  0.5 * pulse,
                  @raylib.Color::new(255, 200, 80, 25),
                )
              }
            }
          }
        }
      }
    }
  }
}

// ========== Water surface transparency effect ==========

///|
fn draw_water_surface_effects(game : @types.Game) -> Unit {
  let player = game.player
  let pcx = player.x.to_int() / @types.chunk_x
  let pcz = player.z.to_int() / @types.chunk_z
  let rd = @types.render_distance
  let min_cx = @types.maxi(0, pcx - rd)
  let max_cx = @types.mini(@types.world_chunks_x - 1, pcx + rd)
  let min_cz = @types.maxi(0, pcz - rd)
  let max_cz = @types.mini(@types.world_chunks_z - 1, pcz + rd)
  let water_y = @types.water_level
  for cz in min_cz..=max_cz {
    for cx in min_cx..=max_cx {
      let chunk = game.chunks[cz * @types.world_chunks_x + cx]
      let base_wx = cx * @types.chunk_x
      let base_wz = cz * @types.chunk_z
      // Only check at water level for surface animation
      for lz = 0; lz < @types.chunk_z; lz = lz + 4 {
        for lx = 0; lx < @types.chunk_x; lx = lx + 4 {
          let block = chunk.get_block(lx, water_y - 1, lz)
          if block == @types.block_water {
            let above = chunk.get_block(lx, water_y, lz)
            if above == @types.block_air {
              let wx = base_wx + lx
              let wz = base_wz + lz
              let sx = Float::from_int(wx) + 2.0
              let sy = Float::from_int(water_y) - 0.45
              let sz = Float::from_int(wz) + 2.0
              // Animated wave effect
              let wave = @math.sinf(game.day_timer * 2.0 + sx * 0.3 + sz * 0.2) *
                0.05
              // Semi-transparent blue surface shimmer
              @raylib.draw_cube(
                @raylib.Vector3::new(sx, sy + wave, sz),
                4.0,
                0.02,
                4.0,
                @raylib.Color::new(80, 150, 220, 40),
              )
            }
          }
        }
      }
    }
  }
}

// ========== Tool in hand rendering (first-person) ==========

///|
fn draw_tool_in_hand(game : @types.Game) -> Unit {
  if game.state != @types.state_playing {
    return
  }
  let player = game.player
  let tool = player.equipped_tool
  let cos_yaw = @math.cosf(player.yaw)
  let sin_yaw = @math.sinf(player.yaw)
  let cos_pitch = @math.cosf(player.pitch)
  let sin_pitch = @math.sinf(player.pitch)
  // Hand/tool position: offset to the right and below the camera
  let right_x = cos_yaw * 0.3
  let right_z = -sin_yaw * 0.3
  let hand_x = game.cam_pos_x + right_x + sin_yaw * cos_pitch * 0.5
  let hand_y = game.cam_pos_y - 0.3 + sin_pitch * 0.3
  let hand_z = game.cam_pos_z - right_z + cos_yaw * cos_pitch * 0.5
  // Bob animation when mining
  let bob_offset : Float = if player.mining_active {
    @math.sinf(game.day_timer * 12.0) * 0.05
  } else {
    0.0
  }
  let tool_y = hand_y + bob_offset
  if tool == @types.tool_hand {
    // Draw bare hand as a small cube
    @raylib.draw_cube(
      @raylib.Vector3::new(hand_x, tool_y, hand_z),
      0.12,
      0.06,
      0.18,
      @raylib.Color::new(220, 180, 160, 230),
    )
  } else if is_pickaxe_tool(tool) {
    // Draw pickaxe: handle + head
    let head_color = get_tool_head_color(tool)
    // Handle
    @raylib.draw_cube(
      @raylib.Vector3::new(hand_x, tool_y - 0.05, hand_z),
      0.04,
      0.25,
      0.04,
      @raylib.Color::new(139, 90, 43, 255),
    )
    // Head
    @raylib.draw_cube(
      @raylib.Vector3::new(hand_x, tool_y + 0.1, hand_z),
      0.18,
      0.06,
      0.06,
      head_color,
    )
  } else if is_axe_tool(tool) {
    // Draw axe
    let head_color = get_tool_head_color(tool)
    // Handle
    @raylib.draw_cube(
      @raylib.Vector3::new(hand_x, tool_y - 0.05, hand_z),
      0.04,
      0.25,
      0.04,
      @raylib.Color::new(139, 90, 43, 255),
    )
    // Axe head (wider on one side)
    @raylib.draw_cube(
      @raylib.Vector3::new(hand_x + 0.06, tool_y + 0.08, hand_z),
      0.12,
      0.1,
      0.04,
      head_color,
    )
  } else if is_sword_tool(tool) {
    // Draw sword
    let blade_color = get_tool_head_color(tool)
    // Handle/grip
    @raylib.draw_cube(
      @raylib.Vector3::new(hand_x, tool_y - 0.08, hand_z),
      0.06,
      0.08,
      0.04,
      @raylib.Color::new(100, 70, 40, 255),
    )
    // Guard
    @raylib.draw_cube(
      @raylib.Vector3::new(hand_x, tool_y, hand_z),
      0.12,
      0.03,
      0.03,
      @raylib.Color::new(80, 80, 80, 255),
    )
    // Blade
    @raylib.draw_cube(
      @raylib.Vector3::new(hand_x, tool_y + 0.12, hand_z),
      0.04,
      0.2,
      0.02,
      blade_color,
    )
  } else if is_shovel_tool(tool) {
    // Draw shovel
    let head_color = get_tool_head_color(tool)
    // Handle
    @raylib.draw_cube(
      @raylib.Vector3::new(hand_x, tool_y - 0.05, hand_z),
      0.04,
      0.25,
      0.04,
      @raylib.Color::new(139, 90, 43, 255),
    )
    // Shovel head
    @raylib.draw_cube(
      @raylib.Vector3::new(hand_x, tool_y + 0.1, hand_z),
      0.1,
      0.12,
      0.03,
      head_color,
    )
  }
}

///|
fn is_pickaxe_tool(tool : Int) -> Bool {
  tool == @types.tool_wooden_pickaxe ||
  tool == @types.tool_stone_pickaxe ||
  tool == @types.tool_iron_pickaxe
}

///|
fn is_axe_tool(tool : Int) -> Bool {
  tool == @types.tool_wooden_axe ||
  tool == @types.tool_stone_axe ||
  tool == @types.tool_iron_axe
}

///|
fn is_sword_tool(tool : Int) -> Bool {
  tool == @types.tool_wooden_sword ||
  tool == @types.tool_stone_sword ||
  tool == @types.tool_iron_sword
}

///|
fn is_shovel_tool(tool : Int) -> Bool {
  tool == @types.tool_wooden_shovel ||
  tool == @types.tool_stone_shovel ||
  tool == @types.tool_iron_shovel
}

///|
fn get_tool_head_color(tool : Int) -> @raylib.Color {
  if tool == @types.tool_wooden_pickaxe ||
    tool == @types.tool_wooden_axe ||
    tool == @types.tool_wooden_shovel ||
    tool == @types.tool_wooden_sword {
    @raylib.Color::new(160, 120, 60, 255)
  } else if tool == @types.tool_stone_pickaxe ||
    tool == @types.tool_stone_axe ||
    tool == @types.tool_stone_shovel ||
    tool == @types.tool_stone_sword {
    @raylib.Color::new(140, 140, 140, 255)
  } else if tool == @types.tool_iron_pickaxe ||
    tool == @types.tool_iron_axe ||
    tool == @types.tool_iron_shovel ||
    tool == @types.tool_iron_sword {
    @raylib.Color::new(200, 200, 210, 255)
  } else {
    @raylib.Color::new(180, 180, 180, 255)
  }
}

// ========== Particle rendering ==========

///|
fn draw_particles(game : @types.Game) -> Unit {
  for i in 0..<@types.particle_max {
    let p = game.particles[i]
    if p.active {
      let life_pct = p.lifetime / p.max_lifetime
      let alpha = (life_pct * 255.0).to_int()
      let clamped_alpha = @types.clampi(alpha, 0, 255)
      @raylib.draw_cube(
        @raylib.Vector3::new(p.x, p.y, p.z),
        p.size,
        p.size,
        p.size,
        @raylib.Color::new(p.color_r, p.color_g, p.color_b, clamped_alpha),
      )
    }
  }
}
