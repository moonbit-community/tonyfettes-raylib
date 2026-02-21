///|
fn clear_hazards(game : Game) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    game.hazards[i] = HazardMarker::inactive()
  }
  game.hazard_spawn_timer = hazard_spawn_base
}

///|
fn alloc_hazard_slot(game : Game) -> Int {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    if not(game.hazards[i].active) {
      return i
    }
  }
  -1
}

///|
fn hazard_score_team(game : Game) -> Int {
  if game.players[0].active {
    team_player1
  } else if game.coop_enabled && game.players[1].active {
    team_player2
  } else {
    team_none
  }
}

///|
fn hazard_point_is_valid(game : Game, x : Float, y : Float, radius : Float) -> Bool {
  let min_x = Float::from_int(tile_size)
  let min_y = Float::from_int(tile_size)
  let max_x = Float::from_int(map_pixel_w - tile_size)
  let max_y = Float::from_int(map_pixel_h - tile_size)

  if x < min_x || x > max_x || y < min_y || y > max_y {
    return false
  }

  let base_x = tile_center_x(base_tile_x)
  let base_y = tile_center_y(base_tile_y)
  if distance_sq(x, y, base_x, base_y) <= (radius + 26.0) * (radius + 26.0) {
    return false
  }

  // Keep telegraphs out of dense water to preserve readability.
  let tx = world_x_to_tile(x)
  let ty = world_y_to_tile(y)
  let tile = get_tile(game, tx, ty)
  tile != tile_water
}

///|
fn spawn_hazard_marker(game : Game, x : Float, y : Float, radius : Float, damage : Int) -> Bool {
  let slot = alloc_hazard_slot(game)
  if slot < 0 {
    return false
  }

  if not(hazard_point_is_valid(game, x, y, radius)) {
    return false
  }

  let h = game.hazards[slot]
  h.active = true
  h.x = x
  h.y = y
  h.radius = clampf(radius, 18.0, 100.0)
  h.warn_timer = hazard_warn_time
  h.pulse = rand_rangef(game, 0.0, 6.2)
  h.damage = clampi(damage, 1, 8)
  true
}

///|
fn spawn_random_hazard(game : Game) -> Bool {
  let radius = hazard_radius_base + rand_rangef(game, -8.0, 20.0) +
    game.hazard_intensity * 8.0
  let damage = hazard_damage_base + clampi(game.hazard_intensity.to_int(), 0, 3)

  let mut attempts = 0
  while attempts < 18 {
    attempts += 1
    let x = Float::from_int(rand_range(game, tile_size, map_pixel_w - tile_size))
    let y = Float::from_int(rand_range(game, tile_size, map_pixel_h - tile_size))
    if spawn_hazard_marker(game, x, y, radius, damage) {
      return true
    }
  }
  false
}

///|
fn damage_tiles_by_hazard(game : Game, x : Float, y : Float, radius : Float) -> Unit {
  let r = radius.to_int()
  let step = clampi(tile_size / 2, 6, 16)

  let mut ox = -r
  while ox <= r {
    let mut oy = -r
    while oy <= r {
      let fx = x + Float::from_int(ox)
      let fy = y + Float::from_int(oy)
      if distance_sq(x, y, fx, fy) <= radius * radius {
        ignore(damage_tile_at_point(game, fx, fy, 2))
      }
      oy += step
    }
    ox += step
  }
}

///|
fn resolve_hazard_blast(game : Game, hazard : HazardMarker) -> Unit {
  let team = hazard_score_team(game)
  let radius_sq = hazard.radius * hazard.radius

  // Players take heavy punishment from standing in blast circles.
  for i = 0; i < max_players; i = i + 1 {
    if not(is_player_enabled(game, i)) {
      continue i + 1
    }
    let p = game.players[i]
    if not(p.active) {
      continue i + 1
    }
    if distance_sq(p.x, p.y, hazard.x, hazard.y) <= radius_sq {
      game.stage_hazard_hits += 1
      on_player_destroyed(game, i)
    }
  }

  for i = 0; i < game.enemies.length(); i = i + 1 {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue i + 1
    }
    if distance_sq(enemy.x, enemy.y, hazard.x, hazard.y) > radius_sq {
      continue i + 1
    }

    enemy.hp -= hazard.damage + enemy.elite_rank
    if enemy.hp <= 0 {
      destroy_enemy(game, i, team)
    }
  }

  for i = 0; i < game.cores.length(); i = i + 1 {
    let core = game.cores[i]
    if not(core.active) {
      continue i + 1
    }
    if distance_sq(core.x, core.y, hazard.x, hazard.y) <= radius_sq {
      ignore(damage_core(game, i, team, hazard.damage + 1))
    }
  }

  damage_tiles_by_hazard(game, hazard.x, hazard.y, hazard.radius)

  if not(game.base_alive) {
    contract_on_base_broken(game)
  }

  spawn_explosion(game, hazard.x, hazard.y, 1.4)
  spawn_spark_burst(game, hazard.x, hazard.y, 18)
  push_camera_shake(game, 2.0 + game.hazard_intensity)
}

///|
fn update_hazards(game : Game, dt : Float) -> Unit {
  game.hazard_spawn_timer -= dt
  if game.hazard_spawn_timer <= 0.0 {
    let count = if rand_range(game, 0, 99) < clampi((game.hazard_intensity * 25.0).to_int(), 8, 52) {
      2
    } else {
      1
    }
    for i = 0; i < count; i = i + 1 {
      ignore(spawn_random_hazard(game))
    }

    let pace = Float::from_double(0.58) +
      game.hazard_intensity * Float::from_double(0.72)
    game.hazard_spawn_timer = hazard_spawn_base / pace
    if game.hazard_spawn_timer < 2.2 {
      game.hazard_spawn_timer = 2.2
    }
  }

  for i = 0; i < game.hazards.length(); i = i + 1 {
    let h = game.hazards[i]
    if not(h.active) {
      continue i + 1
    }

    h.warn_timer -= dt
    h.pulse += dt * 4.2

    if h.warn_timer <= 0.0 {
      resolve_hazard_blast(game, h)
      h.active = false
    }
  }
}

///|
fn draw_hazards(game : Game, shake_x : Float, shake_y : Float) -> Unit {
  for i = 0; i < game.hazards.length(); i = i + 1 {
    let h = game.hazards[i]
    if not(h.active) {
      continue i + 1
    }

    let sx = world_to_screen_x(h.x, shake_x)
    let sy = world_to_screen_y(h.y, shake_y)
    let phase = Float::from_double(@math.sin(h.pulse.to_double())) * 0.5 + 0.5
    let ring_radius = h.radius * (0.78 + phase * 0.28)
    let fill_alpha = clampf(0.12 + phase * 0.08, 0.1, 0.26)

    @raylib.draw_circle(
      sx,
      sy,
      h.radius,
      @raylib.color_alpha(@raylib.red, fill_alpha),
    )
    @raylib.draw_circle_lines(
      sx,
      sy,
      h.radius,
      @raylib.color_alpha(@raylib.orange, 0.75),
    )
    @raylib.draw_circle_lines(
      sx,
      sy,
      ring_radius,
      @raylib.color_alpha(@raylib.yellow, 0.62),
    )

    let remain = clampi(h.warn_timer.to_int() + 1, 0, 99)
    @raylib.draw_text(
      "\{remain}",
      sx - 6,
      sy - 8,
      16,
      @raylib.white,
    )
  }
}
