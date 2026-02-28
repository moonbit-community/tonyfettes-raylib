// 3D world rendering

///|
pub fn draw_world(game : @types.Game) -> Unit {
  let camera = build_camera(game)
  @raylib.begin_mode_3d(camera)
  draw_dungeon(game)
  draw_enemies_3d(game)
  draw_loot_3d(game)
  draw_projectiles_3d(game)
  draw_particles_3d(game)
  draw_sword_swing(game)
  @raylib.end_mode_3d()
}

///|
fn build_camera(game : @types.Game) -> @raylib.Camera3D {
  let eye_x = game.player_x
  let eye_y = @types.player_eye_height
  let eye_z = game.player_z
  // Target is in front of player based on yaw and pitch
  let forward_x = @math.sinf(game.camera_yaw) * @math.cosf(game.camera_pitch)
  let forward_y = @math.sinf(game.camera_pitch)
  let forward_z = @math.cosf(game.camera_yaw) * @math.cosf(game.camera_pitch)
  let target_x = eye_x + forward_x * 10.0
  let target_y = eye_y + forward_y * 10.0
  let target_z = eye_z + forward_z * 10.0
  @raylib.Camera3D::new(
    @raylib.Vector3::new(eye_x, eye_y, eye_z),
    @raylib.Vector3::new(target_x, target_y, target_z),
    @raylib.Vector3::new(0.0, 1.0, 0.0),
    @types.camera_fovy,
    @raylib.CameraPerspective,
  )
}

///|
fn draw_dungeon(game : @types.Game) -> Unit {
  // Only draw tiles near the player for performance
  let pgx = @types.world_to_grid_x(game.player_x)
  let pgz = @types.world_to_grid_z(game.player_z)
  let draw_radius = 16
  let min_gx = @types.maxi(0, pgx - draw_radius)
  let max_gx = @types.mini(@types.grid_w - 1, pgx + draw_radius)
  let min_gz = @types.maxi(0, pgz - draw_radius)
  let max_gz = @types.mini(@types.grid_h - 1, pgz + draw_radius)
  for gz in min_gz..<=max_gz {
    for gx in min_gx..<=max_gx {
      let tile = @types.get_tile(game, gx, gz)
      let wx = @types.grid_to_world_x(gx)
      let wz = @types.grid_to_world_z(gz)
      if tile == @types.tile_wall {
        draw_wall(wx, wz, game, gx, gz)
      } else if tile == @types.tile_floor {
        draw_floor_tile(wx, wz)
      } else if tile == @types.tile_door {
        draw_floor_tile(wx, wz)
        draw_door(wx, wz)
      } else if tile == @types.tile_stairs {
        draw_floor_tile(wx, wz)
        draw_stairs(wx, wz, game)
      } else if tile == @types.tile_chest {
        draw_floor_tile(wx, wz)
        draw_chest(wx, wz, game)
      }
    }
  }
}

///|
fn draw_wall(
  wx : Float,
  wz : Float,
  game : @types.Game,
  gx : Int,
  gz : Int,
) -> Unit {
  // Only draw wall faces that are adjacent to walkable tiles for performance
  let has_floor_neighbor = @types.is_walkable(@types.get_tile(game, gx - 1, gz)) ||
    @types.is_walkable(@types.get_tile(game, gx + 1, gz)) ||
    @types.is_walkable(@types.get_tile(game, gx, gz - 1)) ||
    @types.is_walkable(@types.get_tile(game, gx, gz + 1))
  if not(has_floor_neighbor) {
    return // Interior wall - don't draw
  }
  let cs = @types.cell_size
  let wh = @types.wall_height
  // Dark stone wall
  let base_r = 40 + (gx * 7 + gz * 13) % 15
  let base_g = 35 + (gx * 11 + gz * 3) % 10
  let base_b = 50 + (gx * 5 + gz * 7) % 12
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, wh / 2.0, wz),
    cs,
    wh,
    cs,
    @raylib.Color::new(base_r, base_g, base_b, 255),
  )
  @raylib.draw_cube_wires(
    @raylib.Vector3::new(wx, wh / 2.0, wz),
    cs,
    wh,
    cs,
    @raylib.Color::new(25, 25, 35, 255),
  )
}

///|
fn draw_floor_tile(wx : Float, wz : Float) -> Unit {
  let cs = @types.cell_size
  // Floor
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, -0.05, wz),
    cs,
    0.1,
    cs,
    @raylib.Color::new(55, 50, 65, 255),
  )
  // Ceiling
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, @types.wall_height + 0.05, wz),
    cs,
    0.1,
    cs,
    @raylib.Color::new(30, 28, 38, 255),
  )
}

///|
fn draw_door(wx : Float, wz : Float) -> Unit {
  // Door frame
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, @types.wall_height / 2.0, wz),
    0.3,
    @types.wall_height,
    @types.cell_size,
    @raylib.Color::new(90, 60, 30, 255),
  )
  // Door arch
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, @types.wall_height - 0.3, wz),
    @types.cell_size,
    0.3,
    0.3,
    @raylib.Color::new(90, 60, 30, 255),
  )
}

///|
fn draw_stairs(wx : Float, wz : Float, game : @types.Game) -> Unit {
  // Glowing stairs indicator
  let pulse = @math.sinf(Float::from_int(game.frame_counter) * 0.06) * 0.2 + 0.8
  let g_float : Float = 200.0 * pulse
  let g_val = g_float.to_int()
  let b_float : Float = 255.0 * pulse
  let b_val = b_float.to_int()
  // Step blocks
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.4, 0.15, wz),
    0.4,
    0.3,
    1.2,
    @raylib.Color::new(80, 80, 100, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.35, wz),
    0.4,
    0.3,
    1.2,
    @raylib.Color::new(80, 80, 100, 255),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.4, 0.55, wz),
    0.4,
    0.3,
    1.2,
    @raylib.Color::new(80, 80, 100, 255),
  )
  // Glow orb above stairs
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 1.8, wz),
    0.25,
    @raylib.Color::new(50, g_val, b_val, 200),
  )
}

///|
fn draw_chest(wx : Float, wz : Float, game : @types.Game) -> Unit {
  ignore(game)
  // Chest body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.3, wz),
    0.8,
    0.5,
    0.6,
    @raylib.Color::new(120, 80, 30, 255),
  )
  // Chest lid
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.6, wz),
    0.85,
    0.15,
    0.65,
    @raylib.Color::new(140, 90, 35, 255),
  )
  // Lock
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.4, wz + 0.31),
    0.15,
    0.15,
    0.05,
    @raylib.Color::new(220, 200, 50, 255),
  )
}

///|
fn draw_enemies_3d(game : @types.Game) -> Unit {
  for e in game.enemies {
    if not(e.active) {
      continue
    }
    // Distance check - don't draw far enemies
    let dist = @types.dist2d(game.player_x, game.player_z, e.x, e.z)
    if dist > 30.0 {
      continue
    }
    let flash = e.hit_flash > 0.0
    if e.kind == @types.enemy_skeleton {
      draw_skeleton(e.x, e.z, flash, game)
    } else if e.kind == @types.enemy_archer {
      draw_archer(e.x, e.z, flash, game)
    } else if e.kind == @types.enemy_golem {
      draw_golem(e.x, e.z, flash, game)
    } else if e.kind == @types.enemy_wraith {
      draw_wraith(e.x, e.z, flash, game)
    } else if e.kind == @types.enemy_dragon_boss {
      draw_dragon(e.x, e.z, flash, game)
    }
    // Health bar above enemy
    if e.hp < e.max_hp {
      draw_enemy_health_bar(e, game)
    }
  }
}

///|
fn draw_skeleton(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(200, 190, 170, 255)
  }
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.7, wz),
    0.4,
    0.8,
    0.3,
    body_color,
  )
  // Head (skull)
  @raylib.draw_sphere(@raylib.Vector3::new(wx, 1.3, wz), 0.2, body_color)
  // Arms
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.35, 0.7, wz),
    0.1,
    0.6,
    0.1,
    body_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.35, 0.7, wz),
    0.1,
    0.6,
    0.1,
    body_color,
  )
}

///|
fn draw_archer(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(80, 120, 60, 255)
  }
  // Body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.7, wz),
    0.4,
    0.8,
    0.3,
    body_color,
  )
  // Head with hood
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx, 1.3, wz),
    0.22,
    @raylib.Color::new(60, 90, 40, 255),
  )
  // Bow
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.4, 0.8, wz),
    0.05,
    0.7,
    0.05,
    @raylib.Color::new(140, 100, 40, 255),
  )
}

///|
fn draw_golem(wx : Float, wz : Float, flash : Bool, game : @types.Game) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(100, 90, 80, 255)
  }
  // Large body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.9, wz),
    0.9,
    1.4,
    0.7,
    body_color,
  )
  // Head
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 1.8, wz),
    0.5,
    0.4,
    0.4,
    body_color,
  )
  // Eyes (glowing)
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.12, 1.85, wz + 0.2),
    0.06,
    @raylib.Color::new(255, 150, 0, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.12, 1.85, wz + 0.2),
    0.06,
    @raylib.Color::new(255, 150, 0, 255),
  )
  // Arms
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 0.6, 0.8, wz),
    0.3,
    1.0,
    0.3,
    body_color,
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 0.6, 0.8, wz),
    0.3,
    1.0,
    0.3,
    body_color,
  )
}

///|
fn draw_wraith(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  let bob = @math.sinf(Float::from_int(game.frame_counter) * 0.08) * 0.15
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 200)
  } else {
    @raylib.Color::new(80, 50, 120, 180)
  }
  // Ghostly body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.8 + bob, wz),
    0.5,
    1.0,
    0.4,
    body_color,
  )
  // Head
  @raylib.draw_sphere(@raylib.Vector3::new(wx, 1.5 + bob, wz), 0.25, body_color)
  // Eyes
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.08, 1.55 + bob, wz + 0.2),
    0.05,
    @raylib.Color::new(200, 50, 255, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.08, 1.55 + bob, wz + 0.2),
    0.05,
    @raylib.Color::new(200, 50, 255, 255),
  )
}

///|
fn draw_dragon(
  wx : Float,
  wz : Float,
  flash : Bool,
  game : @types.Game,
) -> Unit {
  ignore(game)
  let body_color = if flash {
    @raylib.Color::new(255, 255, 255, 255)
  } else {
    @raylib.Color::new(150, 30, 30, 255)
  }
  // Large body
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 1.2, wz),
    1.4,
    1.8,
    1.0,
    body_color,
  )
  // Head
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 2.3, wz + 0.6),
    0.6,
    0.5,
    0.8,
    body_color,
  )
  // Eyes
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx - 0.2, 2.4, wz + 1.0),
    0.1,
    @raylib.Color::new(255, 200, 0, 255),
  )
  @raylib.draw_sphere(
    @raylib.Vector3::new(wx + 0.2, 2.4, wz + 1.0),
    0.1,
    @raylib.Color::new(255, 200, 0, 255),
  )
  // Wings
  @raylib.draw_cube(
    @raylib.Vector3::new(wx - 1.2, 1.8, wz),
    1.0,
    0.1,
    0.8,
    @raylib.Color::new(120, 20, 20, 200),
  )
  @raylib.draw_cube(
    @raylib.Vector3::new(wx + 1.2, 1.8, wz),
    1.0,
    0.1,
    0.8,
    @raylib.Color::new(120, 20, 20, 200),
  )
  // Tail
  @raylib.draw_cube(
    @raylib.Vector3::new(wx, 0.8, wz - 1.0),
    0.3,
    0.3,
    1.2,
    body_color,
  )
}

///|
fn draw_enemy_health_bar(e : @types.Enemy, game : @types.Game) -> Unit {
  ignore(game)
  // Draw a simple health bar as cubes above the enemy
  let bar_y : Float = if e.kind == @types.enemy_dragon_boss {
    3.0
  } else if e.kind == @types.enemy_golem {
    2.3
  } else {
    1.8
  }
  let bar_width : Float = 0.8
  let hp_frac = Float::from_int(e.hp) / Float::from_int(e.max_hp)
  // Background (red)
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x, bar_y, e.z),
    bar_width,
    0.08,
    0.08,
    @raylib.Color::new(180, 30, 30, 200),
  )
  // Foreground (green)
  let filled = bar_width * hp_frac
  let offset = (bar_width - filled) / 2.0
  @raylib.draw_cube(
    @raylib.Vector3::new(e.x - offset, bar_y, e.z),
    filled,
    0.08,
    0.08,
    @raylib.Color::new(30, 200, 30, 220),
  )
}

///|
fn draw_loot_3d(game : @types.Game) -> Unit {
  for l in game.loot {
    if not(l.active) {
      continue
    }
    let bob = @math.sinf(l.bob_phase) * 0.1
    let pos = @raylib.Vector3::new(l.x, 0.4 + bob, l.z)
    if l.kind == @types.loot_health_potion {
      // Green potion
      @raylib.draw_sphere(pos, 0.2, @raylib.Color::new(50, 220, 80, 220))
      @raylib.draw_cube(
        @raylib.Vector3::new(l.x, 0.6 + bob, l.z),
        0.1,
        0.1,
        0.1,
        @raylib.Color::new(80, 80, 80, 255),
      )
    } else if l.kind == @types.loot_damage_boost {
      // Red sword boost
      @raylib.draw_cube(
        pos,
        0.15,
        0.4,
        0.08,
        @raylib.Color::new(255, 80, 50, 240),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(l.x, 0.22 + bob, l.z),
        0.3,
        0.08,
        0.08,
        @raylib.Color::new(200, 60, 40, 255),
      )
    } else if l.kind == @types.loot_armor {
      // Blue shield
      @raylib.draw_cube(
        pos,
        0.3,
        0.35,
        0.08,
        @raylib.Color::new(60, 100, 220, 240),
      )
      @raylib.draw_cube(
        @raylib.Vector3::new(l.x, 0.4 + bob, l.z + 0.05),
        0.15,
        0.15,
        0.05,
        @raylib.Color::new(200, 200, 50, 255),
      )
    }
  }
}

///|
fn draw_projectiles_3d(game : @types.Game) -> Unit {
  for p in game.projectiles {
    if not(p.active) {
      continue
    }
    @raylib.draw_sphere(
      @raylib.Vector3::new(p.x, 1.0, p.z),
      0.15,
      @raylib.Color::new(255, 200, 50, 255),
    )
    // Trail
    @raylib.draw_sphere(
      @raylib.Vector3::new(p.x - p.vx * 0.02, 1.0, p.z - p.vz * 0.02),
      0.08,
      @raylib.Color::new(255, 150, 30, 180),
    )
  }
}

///|
fn draw_particles_3d(game : @types.Game) -> Unit {
  for p in game.particles {
    if not(p.active) {
      continue
    }
    let alpha_f = p.life / p.max_life
    let alpha = (alpha_f * 255.0).to_int()
    let a = @types.clampi(alpha, 0, 255)
    @raylib.draw_cube(
      @raylib.Vector3::new(p.x, p.y, p.z),
      p.size,
      p.size,
      p.size,
      @raylib.Color::new(p.r, p.g, p.b, a),
    )
  }
}

///|
fn draw_sword_swing(game : @types.Game) -> Unit {
  if not(game.swing_active) {
    return
  }
  // Draw a sword slash effect in front of the player
  let t : Float = 1.0 - game.swing_timer / @types.swing_duration
  let t_offset : Float = t - 0.5
  let swing_angle : Float = game.camera_yaw + t_offset * 1.5
  let dist : Float = 1.2
  let sx = game.player_x + @math.sinf(swing_angle) * dist
  let sz = game.player_z + @math.cosf(swing_angle) * dist
  let fade : Float = 1.0 - t
  let alpha = (fade * 255.0).to_int()
  let a = @types.clampi(alpha, 0, 255)
  // Blade
  @raylib.draw_cube(
    @raylib.Vector3::new(sx, 1.2, sz),
    0.06,
    0.6,
    0.06,
    @raylib.Color::new(200, 200, 220, a),
  )
  // Slash trail
  @raylib.draw_cube(
    @raylib.Vector3::new(sx, 1.2, sz),
    0.02,
    0.8,
    0.02,
    @raylib.Color::new(255, 255, 150, a / 2),
  )
}
