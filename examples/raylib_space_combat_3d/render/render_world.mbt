// 3D world rendering

///|
pub fn draw_world(game : @types.Game) -> Unit {
  let camera = build_camera(game)
  @raylib.begin_mode_3d(camera)
  draw_stars(game)
  draw_asteroids(game)
  draw_stations(game)
  draw_powerups(game)
  draw_enemies(game)
  draw_player_ship(game)
  draw_projectiles(game)
  draw_particles_3d(game)
  draw_debris_3d(game)
  draw_target_indicator(game)
  draw_lead_indicator(game)
  draw_waypoint_markers(game)
  @raylib.end_mode_3d()
}

///|
fn build_camera(game : @types.Game) -> @raylib.Camera3D {
  let p = game.player
  let fwd = @types.forward_dir(p.yaw, p.pitch)

  // Chase camera: behind and above the player
  let cam_dist = @types.camera_distance
  let cam_h = @types.camera_height
  let cam_x = p.x - fwd.0 * cam_dist
  let cam_y = p.y - fwd.1 * cam_dist + cam_h
  let cam_z = p.z - fwd.2 * cam_dist

  // Camera shake
  let mut shake_x : Float = 0.0
  let mut shake_y : Float = 0.0
  if game.camera_shake > 0.0 {
    let t = Float::from_int(game.frame_counter)
    shake_x = @math.sinf(t * 17.3) * game.camera_shake * 0.5
    shake_y = @math.cosf(t * 23.1) * game.camera_shake * 0.5
  }

  // Look ahead of the player
  let look_x = p.x + fwd.0 * 20.0
  let look_y = p.y + fwd.1 * 20.0
  let look_z = p.z + fwd.2 * 20.0

  @raylib.Camera3D::new(
    @raylib.Vector3::new(cam_x + shake_x, cam_y + shake_y, cam_z),
    @raylib.Vector3::new(look_x, look_y, look_z),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
}

///|
fn draw_stars(game : @types.Game) -> Unit {
  for i = 0; i < game.stars.length(); i = i + 1 {
    let s = game.stars[i]
    @raylib.draw_cube(
      @raylib.Vector3::new(s.x, s.y, s.z),
      0.3,
      0.3,
      0.3,
      @raylib.Color::new(s.r, s.g, s.b, 255),
    )
  }

  // Nebula-like colored cubes scattered around
  let frame_f = Float::from_int(game.frame_counter)
  for i = 0; i < 16; i = i + 1 {
    let fi = Float::from_int(i)
    let nx = @math.sinf(fi * 1.7) * 400.0
    let ny = @math.cosf(fi * 2.3) * 200.0
    let nz = @math.sinf(fi * 0.9 + 1.0) * 400.0
    let pulse = (@math.sinf(frame_f * 0.01 + fi) + 1.0) * 0.5
    let alpha_f : Float = 30.0 + pulse * 25.0
    let alpha = alpha_f.to_int()

    // Different nebula colors
    let color_idx = i % 4
    let r_f : Float = if color_idx == 0 {
      120.0 + fi * 8.0
    } else if color_idx == 1 {
      60.0 + fi * 5.0
    } else if color_idx == 2 {
      150.0 + fi * 6.0
    } else {
      80.0 + fi * 10.0
    }
    let g_f : Float = if color_idx == 0 {
      50.0 + fi * 6.0
    } else if color_idx == 1 {
      100.0 + fi * 8.0
    } else if color_idx == 2 {
      40.0 + fi * 4.0
    } else {
      60.0 + fi * 7.0
    }
    let b_f : Float = if color_idx == 0 {
      150.0 + fi * 7.0
    } else if color_idx == 1 {
      160.0 + fi * 5.0
    } else if color_idx == 2 {
      80.0 + fi * 5.0
    } else {
      180.0 + fi * 4.0
    }
    let r_val = r_f.to_int()
    let g_val = g_f.to_int()
    let b_val = b_f.to_int()
    @raylib.draw_cube(
      @raylib.Vector3::new(nx, ny, nz),
      35.0,
      35.0,
      35.0,
      @raylib.Color::new(
        @types.clampi(r_val, 0, 255),
        @types.clampi(g_val, 0, 255),
        @types.clampi(b_val, 0, 255),
        @types.clampi(alpha, 0, 100),
      ),
    )
    ignore(i)
  }
}

///|
fn draw_player_ship(game : @types.Game) -> Unit {
  let p = game.player
  let fwd = @types.forward_dir(p.yaw, p.pitch)
  let rgt = @types.right_dir(p.yaw)

  // Ship color based on class
  let body_r : Int = if p.ship_class == @types.ship_fighter {
    100
  } else if p.ship_class == @types.ship_interceptor {
    70
  } else if p.ship_class == @types.ship_bomber {
    140
  } else if p.ship_class == @types.ship_cruiser {
    120
  } else {
    150
  }
  let body_g : Int = if p.ship_class == @types.ship_fighter {
    150
  } else if p.ship_class == @types.ship_interceptor {
    200
  } else if p.ship_class == @types.ship_bomber {
    100
  } else if p.ship_class == @types.ship_cruiser {
    130
  } else {
    150
  }
  let body_b : Int = if p.ship_class == @types.ship_fighter {
    220
  } else if p.ship_class == @types.ship_interceptor {
    255
  } else if p.ship_class == @types.ship_bomber {
    80
  } else if p.ship_class == @types.ship_cruiser {
    160
  } else {
    180
  }

  // Damage flash tint
  let flash = p.damage_flash
  let fr : Int = if flash > 0.0 {
    let fv : Float = 255.0 * flash
    let v : Int = body_r + fv.to_int()
    if v > 255 {
      255
    } else {
      v
    }
  } else {
    body_r
  }
  let fg : Int = if flash > 0.0 {
    let fv : Float = 100.0 * flash
    let v : Int = body_g - fv.to_int()
    if v < 0 {
      0
    } else {
      v
    }
  } else {
    body_g
  }
  let fb : Int = if flash > 0.0 {
    let fv : Float = 100.0 * flash
    let v : Int = body_b - fv.to_int()
    if v < 0 {
      0
    } else {
      v
    }
  } else {
    body_b
  }

  // Ship scale based on class
  let scale : Float = if p.ship_class == @types.ship_interceptor {
    0.8
  } else if p.ship_class == @types.ship_bomber {
    1.3
  } else if p.ship_class == @types.ship_cruiser {
    1.6
  } else if p.ship_class == @types.ship_capital_ship {
    2.2
  } else {
    1.0
  }

  // Main fuselage
  @raylib.draw_cube(
    @raylib.Vector3::new(p.x, p.y, p.z),
    1.0 * scale,
    0.4 * scale,
    2.5 * scale,
    @raylib.Color::new(fr, fg, fb, 255),
  )

  // Cockpit (canopy)
  @raylib.draw_cube(
    @raylib.Vector3::new(
      p.x + fwd.0 * 1.0 * scale,
      p.y + fwd.1 * 1.0 * scale + 0.15 * scale,
      p.z + fwd.2 * 1.0 * scale,
    ),
    0.5 * scale,
    0.3 * scale,
    0.8 * scale,
    @raylib.Color::new(60, 180, 255, 200),
  )

  // Wings (different shape per class)
  let wing_span : Float = if p.ship_class == @types.ship_interceptor {
    1.8
  } else if p.ship_class == @types.ship_bomber {
    1.0
  } else if p.ship_class == @types.ship_cruiser {
    1.5
  } else {
    1.5
  }
  let wing_thick : Float = 0.1 * scale
  let wing_depth : Float = if p.ship_class == @types.ship_bomber {
    1.8
  } else {
    1.2
  }

  // Right wing
  @raylib.draw_cube(
    @raylib.Vector3::new(
      p.x + rgt.0 * wing_span * scale,
      p.y + rgt.1 * wing_span * scale,
      p.z + rgt.2 * wing_span * scale,
    ),
    1.5 * scale,
    wing_thick,
    wing_depth * scale,
    @raylib.Color::new(
      @types.clampi(fr - 20, 0, 255),
      @types.clampi(fg - 30, 0, 255),
      @types.clampi(fb - 40, 0, 255),
      255,
    ),
  )
  // Left wing
  @raylib.draw_cube(
    @raylib.Vector3::new(
      p.x - rgt.0 * wing_span * scale,
      p.y - rgt.1 * wing_span * scale,
      p.z - rgt.2 * wing_span * scale,
    ),
    1.5 * scale,
    wing_thick,
    wing_depth * scale,
    @raylib.Color::new(
      @types.clampi(fr - 20, 0, 255),
      @types.clampi(fg - 30, 0, 255),
      @types.clampi(fb - 40, 0, 255),
      255,
    ),
  )

  // Weapon pods (on wing tips for fighter/interceptor)
  if p.ship_class == @types.ship_fighter ||
    p.ship_class == @types.ship_interceptor {
    let pod_off = wing_span * scale * 1.2
    @raylib.draw_cube(
      @raylib.Vector3::new(
        p.x + rgt.0 * pod_off,
        p.y + rgt.1 * pod_off - 0.1,
        p.z + rgt.2 * pod_off,
      ),
      0.3 * scale,
      0.2 * scale,
      0.6 * scale,
      @raylib.Color::new(160, 160, 180, 255),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(
        p.x - rgt.0 * pod_off,
        p.y - rgt.1 * pod_off - 0.1,
        p.z - rgt.2 * pod_off,
      ),
      0.3 * scale,
      0.2 * scale,
      0.6 * scale,
      @raylib.Color::new(160, 160, 180, 255),
    )
  }

  // Tail fin
  @raylib.draw_cube(
    @raylib.Vector3::new(
      p.x - fwd.0 * 1.0 * scale,
      p.y - fwd.1 * 1.0 * scale + 0.4 * scale,
      p.z - fwd.2 * 1.0 * scale,
    ),
    0.1 * scale,
    0.6 * scale,
    0.5 * scale,
    @raylib.Color::new(
      @types.clampi(fr - 10, 0, 255),
      @types.clampi(fg - 20, 0, 255),
      fb,
      255,
    ),
  )

  // Engine glow (two engines)
  let eng_off : Float = 0.3 * scale
  for eng = 0; eng < 2; eng = eng + 1 {
    let side : Float = if eng == 0 { 1.0 } else { -1.0 }
    let eng_x = p.x - fwd.0 * 1.3 * scale + rgt.0 * eng_off * side
    let eng_y = p.y - fwd.1 * 1.3 * scale
    let eng_z = p.z - fwd.2 * 1.3 * scale + rgt.2 * eng_off * side
    let glow_size : Float = if p.boosting { 0.5 * scale } else { 0.25 * scale }
    let pulse = @math.sinf(
        Float::from_int(game.frame_counter) * 0.3 + Float::from_int(eng),
      ) *
      0.08
    @raylib.draw_sphere(
      @raylib.Vector3::new(eng_x, eng_y, eng_z),
      glow_size + pulse,
      @raylib.Color::new(100, 180, 255, 200),
    )
    // Inner bright core
    @raylib.draw_sphere(
      @raylib.Vector3::new(eng_x, eng_y, eng_z),
      (glow_size + pulse) * 0.5,
      @raylib.Color::new(200, 230, 255, 255),
    )
    ignore(eng)
  }

  // Shield bubble (if shield > 0)
  if p.shield > 0.0 {
    let shield_alpha_f : Float = p.shield / p.max_shield * 50.0
    let shield_alpha = shield_alpha_f.to_int()
    let shield_r : Int = if p.damage_flash > 0.0 { 200 } else { 50 }
    let shield_g : Int = if p.damage_flash > 0.0 { 100 } else { 100 }
    @raylib.draw_sphere(
      @raylib.Vector3::new(p.x, p.y, p.z),
      2.5 * scale,
      @raylib.Color::new(
        shield_r,
        shield_g,
        255,
        @types.clampi(shield_alpha, 8, 50),
      ),
    )
  }

  // Weapon boost visual
  if p.weapon_boost_timer > 0.0 {
    let wb_pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.5) * 0.3
    @raylib.draw_sphere(
      @raylib.Vector3::new(p.x, p.y, p.z),
      1.8 * scale + wb_pulse,
      @raylib.Color::new(255, 220, 50, 20),
    )
  }
}

///|
fn draw_enemies(game : @types.Game) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let e = game.enemies[i]
    if not(e.active) {
      continue i + 1
    }

    // Damage flash tint
    let flash = e.damage_flash
    let flash_add : Int = (flash * 150.0).to_int()

    if e.kind == @types.enemy_fighter {
      draw_fighter_ship(e, flash_add, game)
    } else if e.kind == @types.enemy_interceptor {
      draw_interceptor_ship(e, flash_add, game)
    } else if e.kind == @types.enemy_bomber {
      draw_bomber_ship(e, flash_add, game)
    } else if e.kind == @types.enemy_cruiser {
      draw_cruiser_ship(e, flash_add, game)
    } else if e.kind == @types.enemy_capital {
      draw_capital_ship(e, flash_add, game)
    }

    // Health bar above all enemies
    let hp_pct = e.hp / e.max_hp
    let bar_w = e.size * 1.5
    let bar_y = e.y + e.size * 0.8
    @raylib.draw_cube(
      @raylib.Vector3::new(e.x, bar_y, e.z),
      bar_w,
      0.08,
      0.15,
      @raylib.Color::new(80, 0, 0, 200),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(
        e.x - bar_w * (1.0 - hp_pct) / 2.0,
        bar_y + 0.02,
        e.z,
      ),
      bar_w * hp_pct,
      0.1,
      0.15,
      @raylib.Color::new(0, 220, 0, 220),
    )

    // Shield bar (if has shields)
    if e.max_shield_hp > 0.0 {
      let shield_pct = e.shield_hp / e.max_shield_hp
      let shield_bar_y = bar_y + 0.15
      @raylib.draw_cube(
        @raylib.Vector3::new(e.x, shield_bar_y, e.z),
        bar_w,
        0.06,
        0.12,
        @raylib.Color::new(0, 0, 60, 180),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(
          e.x - bar_w * (1.0 - shield_pct) / 2.0,
          shield_bar_y + 0.02,
          e.z,
        ),
        bar_w * shield_pct,
        0.08,
        0.12,
        @raylib.Color::new(80, 140, 255, 200),
      )
    }

    // Smoke effect on damaged enemies
    if e.hp < e.max_hp * 0.3 && game.frame_counter % 6 == 0 {
      @types.spawn_particles(game, e.x, e.y, e.z, 1, 60, 60, 60)
    }
  }
}

///|
fn draw_fighter_ship(
  e : @types.Enemy,
  flash_add : Int,
  game : @types.Game,
) -> Unit {
  ignore(game)
  let br : Int = @types.clampi(220 + flash_add, 0, 255)
  let bg : Int = @types.clampi(60, 0, 255)
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    0.8,
    0.4,
    1.8,
    @raylib.Color::new(br, bg, 60, 255),
  )
  // Wings
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    2.2,
    0.1,
    0.8,
    @raylib.Color::new(@types.clampi(180 + flash_add, 0, 255), 40, 40, 255),
  )
  // Engine glow
  let fwd = @types.forward_dir(e.yaw, e.pitch)
  @raylib.draw_sphere(
    @raylib.Vector3::new(
      e.x - fwd.0 * 1.0,
      e.y - fwd.1 * 1.0,
      e.z - fwd.2 * 1.0,
    ),
    0.2,
    @raylib.Color::new(255, 100, 50, 180),
  )
}

///|
fn draw_interceptor_ship(
  e : @types.Enemy,
  flash_add : Int,
  game : @types.Game,
) -> Unit {
  ignore(game)
  // Interceptor: sleek, narrow, fast-looking
  let br : Int = @types.clampi(200 + flash_add, 0, 255)
  // Narrow body
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    0.5,
    0.3,
    2.0,
    @raylib.Color::new(br, 100, 200, 255),
  )
  // Swept-back wings
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    2.5,
    0.06,
    0.5,
    @raylib.Color::new(@types.clampi(160 + flash_add, 0, 255), 80, 160, 255),
  )
  // Engine trail
  let fwd = @types.forward_dir(e.yaw, e.pitch)
  @raylib.draw_sphere(
    @raylib.Vector3::new(
      e.x - fwd.0 * 1.1,
      e.y - fwd.1 * 1.1,
      e.z - fwd.2 * 1.1,
    ),
    0.25,
    @raylib.Color::new(200, 100, 255, 200),
  )
}

///|
fn draw_bomber_ship(
  e : @types.Enemy,
  flash_add : Int,
  game : @types.Game,
) -> Unit {
  ignore(game)
  // Bomber: bulky, heavy-looking
  let br : Int = @types.clampi(180 + flash_add, 0, 255)
  // Wide body
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    1.8,
    0.8,
    2.5,
    @raylib.Color::new(br, 120, 50, 255),
  )
  // Bomb bay (darker underbelly)
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y - 0.5, e.z),
    1.2,
    0.3,
    1.8,
    @raylib.Color::new(@types.clampi(120 + flash_add, 0, 255), 80, 30, 255),
  )
  // Small wings
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    3.0,
    0.1,
    1.0,
    @raylib.Color::new(@types.clampi(150 + flash_add, 0, 255), 100, 40, 255),
  )
  // Twin engines
  let fwd = @types.forward_dir(e.yaw, e.pitch)
  @raylib.draw_sphere(
    @raylib.Vector3::new(
      e.x - fwd.0 * 1.3 + 0.5,
      e.y - fwd.1 * 1.3,
      e.z - fwd.2 * 1.3,
    ),
    0.3,
    @raylib.Color::new(255, 200, 50, 180),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(
      e.x - fwd.0 * 1.3 - 0.5,
      e.y - fwd.1 * 1.3,
      e.z - fwd.2 * 1.3,
    ),
    0.3,
    @raylib.Color::new(255, 200, 50, 180),
  )
}

///|
fn draw_cruiser_ship(
  e : @types.Enemy,
  flash_add : Int,
  game : @types.Game,
) -> Unit {
  ignore(game)
  // Cruiser: large blocky ship
  let br : Int = @types.clampi(150 + flash_add, 0, 255)
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    2.0,
    1.5,
    5.0,
    @raylib.Color::new(br, 80, 80, 255),
  )
  // Bridge
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y + 1.0, e.z),
    1.0,
    0.8,
    1.5,
    @raylib.Color::new(@types.clampi(180 + flash_add, 0, 255), 100, 100, 255),
  )
  // Hull armor plates
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y - 0.5, e.z + 1.0),
    2.2,
    0.3,
    2.0,
    @raylib.Color::new(@types.clampi(130 + flash_add, 0, 255), 70, 70, 255),
  )
  // Engines
  @raylib.draw_sphere(
    @raylib.Vector3::new(e.x - 0.8, e.y - 0.5, e.z - 2.5),
    0.4,
    @raylib.Color::new(255, 150, 50, 200),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(e.x + 0.8, e.y - 0.5, e.z - 2.5),
    0.4,
    @raylib.Color::new(255, 150, 50, 200),
  )
}

///|
fn draw_capital_ship(
  e : @types.Enemy,
  flash_add : Int,
  game : @types.Game,
) -> Unit {
  // Capital ship: massive, multi-section
  let br : Int = @types.clampi(120 + flash_add, 0, 255)
  // Main hull
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z),
    4.0,
    2.5,
    10.0,
    @raylib.Color::new(br, 60, 60, 255),
  )
  // Bridge tower
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y + 2.0, e.z + 1.0),
    2.0,
    1.5,
    3.0,
    @raylib.Color::new(@types.clampi(140 + flash_add, 0, 255), 80, 80, 255),
  )
  // Bow
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z + 5.5),
    2.5,
    1.5,
    2.0,
    @raylib.Color::new(@types.clampi(100 + flash_add, 0, 255), 50, 60, 255),
  )
  // Engine block
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, e.y, e.z - 5.5),
    3.5,
    2.0,
    1.5,
    @raylib.Color::new(@types.clampi(90 + flash_add, 0, 255), 45, 50, 255),
  )
  // Turret mounts (visual indicators)
  let frame_f = Float::from_int(game.frame_counter)
  for t = 0; t < 4; t = t + 1 {
    let ft = Float::from_int(t)
    let turret_x = e.x + @math.sinf(ft * 1.57) * 2.0
    let turret_y = e.y + 1.5
    let turret_z = e.z + (ft - 1.5) * 2.5
    let turret_pulse = @math.sinf(frame_f * 0.1 + ft) * 0.1
    @raylib.draw_sphere(
      @raylib.Vector3::new(turret_x, turret_y, turret_z),
      0.4 + turret_pulse,
      @raylib.Color::new(255, 80, 80, 200),
    )
    ignore(t)
  }
  // Engine glow (4 engines)
  for eng = 0; eng < 4; eng = eng + 1 {
    let fe = Float::from_int(eng)
    let eng_x = e.x + (fe - 1.5) * 1.2
    let eng_y = e.y - 0.5
    let eng_z = e.z - 6.5
    @raylib.draw_sphere(
      @raylib.Vector3::new(eng_x, eng_y, eng_z),
      0.5,
      @raylib.Color::new(255, 180, 80, 220),
    )
    ignore(eng)
  }
  // Shield bubble if has shields
  if e.shield_hp > 0.0 && e.max_shield_hp > 0.0 {
    let sa_f : Float = e.shield_hp / e.max_shield_hp * 30.0
    let sa = sa_f.to_int()
    @raylib.draw_sphere(
      @raylib.Vector3::new(e.x, e.y, e.z),
      e.size * 1.2,
      @raylib.Color::new(255, 50, 50, @types.clampi(sa, 5, 30)),
    )
  }
}

///|
fn draw_asteroids(game : @types.Game) -> Unit {
  for i = 0; i < game.asteroids.length(); i = i + 1 {
    let a = game.asteroids[i]
    if not(a.active) {
      continue i + 1
    }

    // Color varies by size tier
    let base_r : Int = if a.size_tier == @types.asteroid_large {
      130
    } else if a.size_tier == @types.asteroid_medium {
      120
    } else {
      100
    }
    let base_g : Int = if a.size_tier == @types.asteroid_large {
      120
    } else if a.size_tier == @types.asteroid_medium {
      105
    } else {
      90
    }
    let base_b : Int = if a.size_tier == @types.asteroid_large {
      100
    } else if a.size_tier == @types.asteroid_medium {
      85
    } else {
      75
    }

    // Main body (irregular shape via offset cubes)
    let half = a.size * 0.5
    @raylib.draw_cube(
      @raylib.Vector3::new(a.x, a.y, a.z),
      a.size,
      a.size * 0.8,
      a.size * 0.9,
      @raylib.Color::new(base_r, base_g, base_b, 255),
    )
    // Detail offset cube
    @raylib.draw_cube(
      @raylib.Vector3::new(
        a.x + @math.sinf(a.rot_x) * half * 0.2,
        a.y + @math.cosf(a.rot_y) * half * 0.2,
        a.z + @math.sinf(a.rot_z) * half * 0.15,
      ),
      a.size * 0.85,
      a.size * 0.7,
      a.size * 0.95,
      @raylib.Color::new(
        @types.clampi(base_r - 20, 0, 255),
        @types.clampi(base_g - 20, 0, 255),
        @types.clampi(base_b - 15, 0, 255),
        255,
      ),
    )
    // Protrusion for large asteroids
    if a.size_tier == @types.asteroid_large {
      @raylib.draw_cube(
        @raylib.Vector3::new(
          a.x + @math.cosf(a.rot_y) * half * 0.4,
          a.y + @math.sinf(a.rot_x) * half * 0.3,
          a.z,
        ),
        a.size * 0.4,
        a.size * 0.5,
        a.size * 0.3,
        @raylib.Color::new(
          @types.clampi(base_r - 10, 0, 255),
          @types.clampi(base_g - 10, 0, 255),
          @types.clampi(base_b - 8, 0, 255),
          255,
        ),
      )
    }
    // Wireframe outline
    @raylib.draw_cube_wires(
      @raylib.Vector3::new(a.x, a.y, a.z),
      a.size * 1.01,
      a.size * 0.81,
      a.size * 0.91,
      @raylib.Color::new(80, 70, 60, 255),
    )
  }
}

///|
fn draw_stations(game : @types.Game) -> Unit {
  for i = 0; i < game.stations.length(); i = i + 1 {
    let s = game.stations[i]
    if not(s.active) {
      continue i + 1
    }

    let is_friendly = s.kind == @types.station_friendly

    // Station colors
    let hub_r : Int = if is_friendly { 80 } else { 180 }
    let hub_g : Int = if is_friendly { 140 } else { 60 }
    let hub_b : Int = if is_friendly { 200 } else { 60 }

    // Central hub
    @raylib.draw_cube(
      @raylib.Vector3::new(s.x, s.y, s.z),
      4.0,
      4.0,
      4.0,
      @raylib.Color::new(hub_r, hub_g, hub_b, 255),
    )

    // Rotating ring (simulated with cubes at offsets)
    let ring_r : Float = 6.0
    for seg = 0; seg < 8; seg = seg + 1 {
      let angle = Float::from_int(seg) * (@types.two_pi / 8.0) + s.ring_angle
      let rx = s.x + @math.cosf(angle) * ring_r
      let ry = s.y
      let rz = s.z + @math.sinf(angle) * ring_r
      @raylib.draw_cube(
        @raylib.Vector3::new(rx, ry, rz),
        1.0,
        0.5,
        1.0,
        @raylib.Color::new(
          @types.clampi(hub_r + 20, 0, 255),
          @types.clampi(hub_g + 20, 0, 255),
          @types.clampi(hub_b + 20, 0, 255),
          255,
        ),
      )
      ignore(seg)
    }

    // Docking arms (4 extending outward)
    for arm = 0; arm < 4; arm = arm + 1 {
      let arm_angle = Float::from_int(arm) * (@types.two_pi / 4.0) + s.rot_angle
      let ax = s.x + @math.cosf(arm_angle) * 3.0
      let az = s.z + @math.sinf(arm_angle) * 3.0
      @raylib.draw_cube(
        @raylib.Vector3::new(ax, s.y, az),
        0.5,
        0.5,
        3.0,
        @raylib.Color::new(
          @types.clampi(hub_r - 20, 0, 255),
          @types.clampi(hub_g - 20, 0, 255),
          @types.clampi(hub_b - 20, 0, 255),
          255,
        ),
      )
      ignore(arm)
    }

    // Lights
    let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.1) * 0.3
    let light_alpha : Int = if is_friendly { 200 } else { 180 }
    @raylib.draw_sphere(
      @raylib.Vector3::new(s.x, s.y + 2.5, s.z),
      0.4 + pulse,
      @raylib.Color::new(
        if is_friendly {
          50
        } else {
          255
        },
        if is_friendly {
          255
        } else {
          50
        },
        50,
        light_alpha,
      ),
    )

    // Health bar for stations
    let hp_pct = s.hp / s.max_hp
    let sbar_y = s.y + 5.0
    @raylib.draw_cube(
      @raylib.Vector3::new(s.x, sbar_y, s.z),
      6.0,
      0.12,
      0.2,
      @raylib.Color::new(60, 0, 0, 180),
    )
    @raylib.draw_cube(
      @raylib.Vector3::new(s.x - 6.0 * (1.0 - hp_pct) / 2.0, sbar_y + 0.03, s.z),
      6.0 * hp_pct,
      0.15,
      0.2,
      @raylib.Color::new(
        if is_friendly {
          0
        } else {
          200
        },
        if is_friendly {
          200
        } else {
          80
        },
        0,
        220,
      ),
    )
  }
}

///|
fn draw_powerups(game : @types.Game) -> Unit {
  for i = 0; i < game.powerups.length(); i = i + 1 {
    let pu = game.powerups[i]
    if not(pu.active) {
      continue i + 1
    }

    // Bob animation
    let bob = @math.sinf(pu.bob_timer) * @types.powerup_bob_amplitude
    let draw_y = pu.y + bob

    // Spin
    let spin_off = @math.sinf(pu.spin_angle) * 0.5

    // Color and shape by type
    if pu.kind == @types.powerup_health {
      // Green cross
      @raylib.draw_cube(
        @raylib.Vector3::new(pu.x + spin_off, draw_y, pu.z),
        0.8,
        0.3,
        0.3,
        @raylib.Color::new(50, 255, 50, 220),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(pu.x + spin_off, draw_y, pu.z),
        0.3,
        0.8,
        0.3,
        @raylib.Color::new(50, 255, 50, 220),
      )
      @raylib.draw_sphere(
        @raylib.Vector3::new(pu.x + spin_off, draw_y, pu.z),
        0.8,
        @raylib.Color::new(50, 255, 50, 40),
      )
    } else if pu.kind == @types.powerup_shield {
      // Blue sphere
      @raylib.draw_sphere(
        @raylib.Vector3::new(pu.x + spin_off, draw_y, pu.z),
        0.5,
        @raylib.Color::new(80, 150, 255, 220),
      )
      @raylib.draw_sphere(
        @raylib.Vector3::new(pu.x + spin_off, draw_y, pu.z),
        0.8,
        @raylib.Color::new(80, 150, 255, 40),
      )
    } else if pu.kind == @types.powerup_weapon_boost {
      // Orange cube
      @raylib.draw_cube(
        @raylib.Vector3::new(pu.x + spin_off, draw_y, pu.z),
        0.6,
        0.6,
        0.6,
        @raylib.Color::new(255, 180, 50, 220),
      )
      @raylib.draw_cube_wires(
        @raylib.Vector3::new(pu.x + spin_off, draw_y, pu.z),
        0.7,
        0.7,
        0.7,
        @raylib.Color::new(255, 200, 100, 180),
      )
    } else {
      // Yellow speed bolt
      @raylib.draw_cube(
        @raylib.Vector3::new(pu.x + spin_off, draw_y, pu.z),
        0.2,
        0.8,
        0.2,
        @raylib.Color::new(255, 255, 100, 220),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(pu.x + spin_off + 0.2, draw_y - 0.2, pu.z),
        0.2,
        0.5,
        0.2,
        @raylib.Color::new(255, 255, 100, 220),
      )
      @raylib.draw_sphere(
        @raylib.Vector3::new(pu.x + spin_off, draw_y, pu.z),
        0.7,
        @raylib.Color::new(255, 255, 100, 30),
      )
    }
  }
}

///|
fn draw_projectiles(game : @types.Game) -> Unit {
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    let proj = game.projectiles[i]
    if not(proj.active) {
      continue i + 1
    }

    if proj.from_player {
      if proj.kind == @types.weapon_laser {
        // Laser: bright line-like cube
        @raylib.draw_cube(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.06,
          0.06,
          0.8,
          @raylib.Color::new(255, 255, 100, 255),
        )
        // Inner glow
        @raylib.draw_cube(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.03,
          0.03,
          0.6,
          @raylib.Color::new(255, 255, 255, 255),
        )
      } else if proj.kind == @types.weapon_missile {
        // Missile: small solid with glow
        @raylib.draw_cube(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.15,
          0.15,
          0.5,
          @raylib.Color::new(255, 200, 100, 255),
        )
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.25,
          @raylib.Color::new(255, 150, 50, 150),
        )
      } else if proj.kind == @types.weapon_plasma {
        // Plasma: glowing sphere
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.3,
          @raylib.Color::new(100, 255, 150, 220),
        )
        @raylib.draw_sphere(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.5,
          @raylib.Color::new(50, 200, 100, 80),
        )
      } else if proj.kind == @types.weapon_railgun {
        // Railgun: thin bright beam-like
        @raylib.draw_cube(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.03,
          0.03,
          1.5,
          @raylib.Color::new(150, 200, 255, 255),
        )
        @raylib.draw_cube(
          @raylib.Vector3::new(proj.x, proj.y, proj.z),
          0.08,
          0.08,
          1.0,
          @raylib.Color::new(100, 150, 255, 120),
        )
      }
      // Enemy projectiles
    } else if proj.kind == @types.weapon_plasma {
      // Enemy plasma (from bombers)
      @raylib.draw_sphere(
        @raylib.Vector3::new(proj.x, proj.y, proj.z),
        0.25,
        @raylib.Color::new(255, 100, 100, 220),
      )
      @raylib.draw_sphere(
        @raylib.Vector3::new(proj.x, proj.y, proj.z),
        0.4,
        @raylib.Color::new(255, 50, 50, 60),
      )
    } else {
      // Enemy laser
      @raylib.draw_cube(
        @raylib.Vector3::new(proj.x, proj.y, proj.z),
        0.06,
        0.06,
        0.6,
        @raylib.Color::new(255, 80, 80, 255),
      )
    }
  }
}

///|
fn draw_particles_3d(game : @types.Game) -> Unit {
  for i = 0; i < game.particles.length(); i = i + 1 {
    let p = game.particles[i]
    if not(p.active) {
      continue i + 1
    }
    let alpha_f : Float = p.life / p.max_life * 255.0
    let a = @types.clampi(alpha_f.to_int(), 0, 255)

    if p.kind == 1 {
      // Explosion particles: sphere
      @raylib.draw_sphere(
        @raylib.Vector3::new(p.x, p.y, p.z),
        p.size,
        @raylib.Color::new(p.r, p.g, p.b, a),
      )
    } else if p.kind == 2 {
      // Shield hit particles: small sphere
      @raylib.draw_sphere(
        @raylib.Vector3::new(p.x, p.y, p.z),
        p.size,
        @raylib.Color::new(p.r, p.g, p.b, a),
      )
    } else {
      // Standard: cube
      @raylib.draw_cube(
        @raylib.Vector3::new(p.x, p.y, p.z),
        p.size,
        p.size,
        p.size,
        @raylib.Color::new(p.r, p.g, p.b, a),
      )
    }
  }
}

///|
fn draw_debris_3d(game : @types.Game) -> Unit {
  for i = 0; i < game.debris.length(); i = i + 1 {
    let d = game.debris[i]
    if not(d.active) {
      continue i + 1
    }
    let alpha_f : Float = @types.minf(d.life / 2.0, 1.0) * 255.0
    let a = @types.clampi(alpha_f.to_int(), 0, 255)
    @raylib.draw_cube(
      @raylib.Vector3::new(d.x, d.y, d.z),
      d.size,
      d.size * 0.5,
      d.size * 0.8,
      @raylib.Color::new(d.r, d.g, d.b, a),
    )
  }
}

///|
fn draw_target_indicator(game : @types.Game) -> Unit {
  if game.target_idx < 0 {
    return
  }
  if game.target_idx >= game.enemies.length() {
    return
  }
  let e = game.enemies[game.target_idx]
  if not(e.active) {
    return
  }

  // Draw targeting brackets around selected enemy
  let s = e.size * 1.5
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.15) * 0.3

  @raylib.draw_cube_wires(
    @raylib.Vector3::new(e.x, e.y, e.z),
    s + pulse,
    s + pulse,
    s + pulse,
    @raylib.Color::new(255, 255, 0, 200),
  )

  // Corner brackets (additional detail)
  let cs = s * 0.3
  let corner_pos = s * 0.5 + pulse * 0.5
  // Top-right-front corner bracket
  @raylib.draw_line_3d(
    @raylib.Vector3::new(e.x + corner_pos, e.y + corner_pos, e.z + corner_pos),
    @raylib.Vector3::new(
      e.x + corner_pos - cs,
      e.y + corner_pos,
      e.z + corner_pos,
    ),
    @raylib.Color::new(255, 255, 0, 255),
  )
  @raylib.draw_line_3d(
    @raylib.Vector3::new(e.x + corner_pos, e.y + corner_pos, e.z + corner_pos),
    @raylib.Vector3::new(
      e.x + corner_pos,
      e.y + corner_pos - cs,
      e.z + corner_pos,
    ),
    @raylib.Color::new(255, 255, 0, 255),
  )

  // Bottom-left-back corner bracket
  @raylib.draw_line_3d(
    @raylib.Vector3::new(e.x - corner_pos, e.y - corner_pos, e.z - corner_pos),
    @raylib.Vector3::new(
      e.x - corner_pos + cs,
      e.y - corner_pos,
      e.z - corner_pos,
    ),
    @raylib.Color::new(255, 255, 0, 255),
  )
  @raylib.draw_line_3d(
    @raylib.Vector3::new(e.x - corner_pos, e.y - corner_pos, e.z - corner_pos),
    @raylib.Vector3::new(
      e.x - corner_pos,
      e.y - corner_pos + cs,
      e.z - corner_pos,
    ),
    @raylib.Color::new(255, 255, 0, 255),
  )

  // Line from player to target (subtle)
  @raylib.draw_line_3d(
    @raylib.Vector3::new(game.player.x, game.player.y, game.player.z),
    @raylib.Vector3::new(e.x, e.y, e.z),
    @raylib.Color::new(255, 255, 0, 40),
  )
}

///|
fn draw_lead_indicator(game : @types.Game) -> Unit {
  if game.target_idx < 0 {
    return
  }
  if game.target_idx >= game.enemies.length() {
    return
  }
  let e = game.enemies[game.target_idx]
  if not(e.active) {
    return
  }

  let p = game.player
  let proj_speed = @types.weapon_proj_speed(p.weapon)

  // Calculate lead point
  let lead = @types.lead_target(
    p.x,
    p.y,
    p.z,
    e.x,
    e.y,
    e.z,
    e.vx,
    e.vy,
    e.vz,
    proj_speed,
  )

  // Show lead indicator at predicted interception point
  let dist = @types.distance3d(p.x, p.y, p.z, e.x, e.y, e.z)
  let lead_x = p.x + lead.0 * dist
  let lead_y = p.y + lead.1 * dist
  let lead_z = p.z + lead.2 * dist

  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.2) * 0.15
  @raylib.draw_sphere(
    @raylib.Vector3::new(lead_x, lead_y, lead_z),
    0.3 + pulse,
    @raylib.Color::new(255, 200, 0, 120),
  )
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(lead_x, lead_y, lead_z),
    0.8 + pulse,
    0.8 + pulse,
    0.8 + pulse,
    @raylib.Color::new(255, 200, 0, 80),
  )
}

///|
fn draw_waypoint_markers(game : @types.Game) -> Unit {
  // Draw markers for stations
  for i = 0; i < game.stations.length(); i = i + 1 {
    let s = game.stations[i]
    if not(s.active) {
      continue i + 1
    }
    let marker_y = s.y + 8.0
    let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.08) * 0.5
    let marker_color = if s.kind == @types.station_friendly {
      @raylib.Color::new(50, 255, 50, 100)
    } else {
      @raylib.Color::new(255, 50, 50, 100)
    }
    @raylib.draw_cube(
      @raylib.Vector3::new(s.x, marker_y + pulse, s.z),
      0.5,
      1.5,
      0.5,
      marker_color,
    )
  }
}
