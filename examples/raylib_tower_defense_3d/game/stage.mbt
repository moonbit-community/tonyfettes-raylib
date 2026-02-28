// Map loading, game reset, and stage management

pub fn load_map(game : @types.Game, map_idx : Int) -> Unit {
  // Reset state
  let map_info = @levels.get_map_info(map_idx)
  game.gold = @types.starting_gold + map_info.starting_gold_bonus
  game.total_gold_earned = game.gold
  game.total_gold_spent = 0
  game.lives = @types.starting_lives
  game.score = 0
  game.current_wave = 0
  game.enemies_to_spawn = 0
  game.enemies_spawned = 0
  game.path_count = 0
  game.selected_tower_type = @types.tower_arrow
  game.hover_gx = @types.map_w / 2
  game.hover_gy = @types.map_h / 2
  game.hover_valid = false
  game.interest_timer = 0.0
  game.speed_multiplier = 1.0
  game.speed_setting = 0
  game.selected_tower_idx = -1
  game.wave_active = false
  game.enemies_killed_this_wave = 0
  game.towers_built = 0
  game.towers_sold = 0
  game.total_kills = 0
  game.damage_dealt = 0.0
  game.longest_wave = 0
  game.notification_timer = 0.0
  game.notification_text = ""
  game.wave_message = ""
  game.wave_message_timer = 0.0
  game.show_ranges = false
  game.show_minimap = true
  game.upgrade_preview = false
  game.prev_state = @types.state_wave_prep
  // Clear pools
  for i = 0; i < game.towers.length(); i = i + 1 {
    game.towers[i] = @types.Tower::inactive()
  }
  for i = 0; i < game.enemies.length(); i = i + 1 {
    game.enemies[i] = @types.Enemy::inactive()
  }
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    game.projectiles[i] = @types.Projectile::inactive()
  }
  for i = 0; i < game.particles.length(); i = i + 1 {
    game.particles[i] = @types.Particle::inactive()
  }
  for i = 0; i < game.chain_lines.length(); i = i + 1 {
    game.chain_lines[i] = @types.ChainLine::inactive()
  }
  // Load map data
  let data = @levels.get_map_data(map_idx)
  // Build tiles from map data
  let path_points : Array[@types.PathNode] = []
  let mut start_gx = 0
  let mut start_gy = 0
  for gy = 0; gy < @types.map_h; gy = gy + 1 {
    if gy >= data.length() {
      continue gy + 1
    }
    let row = data[gy]
    for gx = 0; gx < @types.map_w; gx = gx + 1 {
      let ch = if gx < row.length() { row[gx] } else { '.' }
      if ch == '#' || ch == 'S' || ch == 'E' {
        @types.set_tile(game, gx, gy, @types.tile_path)
      } else if ch == '~' {
        @types.set_tile(game, gx, gy, @types.tile_water)
      } else if ch == 'R' {
        @types.set_tile(game, gx, gy, @types.tile_rock)
      } else {
        @types.set_tile(game, gx, gy, @types.tile_grass)
      }
      if ch == 'S' {
        @types.set_tile(game, gx, gy, @types.tile_start)
        start_gx = gx
        start_gy = gy
      }
      if ch == 'E' {
        @types.set_tile(game, gx, gy, @types.tile_end)
      }
    }
  }
  // Trace path from start using BFS-like walk
  trace_path(game, data, start_gx, start_gy, path_points)
  game.path_count = @types.clampi(
    path_points.length(), 0, @types.max_path_nodes,
  )
  for i = 0; i < game.path_count; i = i + 1 {
    game.path_nodes[i] = path_points[i]
  }
  // Camera centered on map
  game.camera_target_x = Float::from_int(@types.map_w) * @types.cell_size / 2.0
  game.camera_target_z = Float::from_int(@types.map_h) * @types.cell_size / 2.0
  game.camera_angle = 45.0
  game.camera_pitch = 55.0
  game.camera_dist = 25.0
  // Notify player
  @types.set_notification(
    game,
    "Map: " + map_info.name + " | " + map_info.description,
    3.0,
  )
}

fn trace_path(
  game : @types.Game,
  data : Array[String],
  start_gx : Int,
  start_gy : Int,
  path : Array[@types.PathNode]
) -> Unit {
  let visited = Array::make(@types.map_total, false)
  let mut cx = start_gx
  let mut cy = start_gy
  let max_steps = @types.map_total
  for _step = 0; _step < max_steps; _step = _step + 1 {
    path.push(
      {
        x: @types.grid_to_world_x(cx),
        z: @types.grid_to_world_z(cy),
      },
    )
    visited[@types.tile_index(cx, cy)] = true
    // Check if reached end
    let tile = @types.get_tile(game, cx, cy)
    if tile == @types.tile_end {
      return
    }
    // Find unvisited path neighbor
    let dirs : Array[(Int, Int)] = [(1, 0), (0, 1), (-1, 0), (0, -1)]
    let mut found = false
    for d = 0; d < 4; d = d + 1 {
      let nx = cx + dirs[d].0
      let ny = cy + dirs[d].1
      if @types.in_bounds(nx, ny) {
        let idx = @types.tile_index(nx, ny)
        if not(visited[idx]) {
          let ntile = @types.get_tile(game, nx, ny)
          if ntile == @types.tile_path || ntile == @types.tile_end {
            cx = nx
            cy = ny
            found = true
            break
          }
        }
      }
    }
    if not(found) {
      return
    }
  }
  ignore(data)
}

fn reset_game(game : @types.Game) -> Unit {
  game.gold = @types.starting_gold
  game.lives = @types.starting_lives
  game.score = 0
  game.current_wave = 0
  game.enemies_to_spawn = 0
  game.enemies_spawned = 0
  game.interest_timer = 0.0
  game.speed_multiplier = 1.0
  game.speed_setting = 0
  game.selected_tower_idx = -1
  game.wave_active = false
  game.enemies_killed_this_wave = 0
  game.total_gold_earned = @types.starting_gold
  game.total_gold_spent = 0
  game.towers_built = 0
  game.towers_sold = 0
  game.total_kills = 0
  game.damage_dealt = 0.0
  game.longest_wave = 0
  game.menu_cursor = 0
  game.notification_timer = 0.0
  game.notification_text = ""
  game.wave_message = ""
  game.wave_message_timer = 0.0
  game.show_ranges = false
  game.show_minimap = true
  game.prev_state = @types.state_menu
  for i = 0; i < game.towers.length(); i = i + 1 {
    game.towers[i] = @types.Tower::inactive()
  }
  for i = 0; i < game.enemies.length(); i = i + 1 {
    game.enemies[i] = @types.Enemy::inactive()
  }
  for i = 0; i < game.projectiles.length(); i = i + 1 {
    game.projectiles[i] = @types.Projectile::inactive()
  }
  for i = 0; i < game.particles.length(); i = i + 1 {
    game.particles[i] = @types.Particle::inactive()
  }
  for i = 0; i < game.chain_lines.length(); i = i + 1 {
    game.chain_lines[i] = @types.ChainLine::inactive()
  }
}
