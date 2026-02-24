///|
fn clear_hostages(game : Game) -> Unit {
  for i = 0; i < game.hostages.length(); i = i + 1 {
    game.hostages[i] = Hostage::inactive()
  }
  game.hostages_rescued = 0
  game.rescue_stage_bonus_awarded = false
}

///|
fn alloc_hostage_slot(game : Game) -> Int {
  for i = 0; i < game.hostages.length(); i = i + 1 {
    if not(game.hostages[i].active) {
      return i
    }
  }
  -1
}

///|
fn hostage_goal_for_stage(stage : Int) -> Int {
  let wave = stage + 1
  clampi(rescue_goal_base + wave / 3, rescue_goal_base, 12)
}

///|
fn tile_is_hostage_spawnable(tile : Int) -> Bool {
  tile == tile_empty || tile == tile_bush || tile == tile_ice
}

///|
fn try_spawn_hostage_at_tile(game : Game, tx : Int, ty : Int) -> Bool {
  if not(in_tile_bounds(tx, ty)) {
    return false
  }
  if absf(Float::from_int(tx - base_tile_x)) <= 2.0 &&
    absf(Float::from_int(ty - base_tile_y)) <= 2.0 {
    return false
  }
  let tile = get_tile(game, tx, ty)
  if not(tile_is_hostage_spawnable(tile)) {
    return false
  }

  let slot = alloc_hostage_slot(game)
  if slot < 0 {
    return false
  }

  let hostage = game.hostages[slot]
  hostage.active = true
  hostage.rescued = false
  hostage.x = tile_center_x(tx)
  hostage.y = tile_center_y(ty)
  hostage.bob = rand_rangef(game, 0.0, 6.28)
  hostage.blink = rand_rangef(game, 0.0, 2.0)

  if tile == tile_empty {
    set_tile(game, tx, ty, tile_camp, 1)
  }
  true
}

///|
fn seed_stage_hostages(game : Game, stage : Int) -> Unit {
  clear_hostages(game)
  game.hostages_goal = hostage_goal_for_stage(stage)

  let mut placed = 0
  let mut attempts = 0
  while placed < game.hostages_goal && attempts < 900 {
    attempts += 1
    let tx = rand_range(game, 1, map_tiles_w - 2)
    let ty = rand_range(game, 2, map_tiles_h - 4)
    if try_spawn_hostage_at_tile(game, tx, ty) {
      placed += 1
    }
  }

  if placed < game.hostages_goal {
    for ty = 3; ty < map_tiles_h - 3 && placed < game.hostages_goal; ty = ty + 1 {
      for tx = 2
          tx < map_tiles_w - 2 && placed < game.hostages_goal
          tx = tx + 1 {
        if try_spawn_hostage_at_tile(game, tx, ty) {
          placed += 1
        }
      }
    }
  }

  game.hostages_goal = placed
}

///|
fn rescue_objective_done(game : Game) -> Bool {
  if game.hostages_goal <= 0 {
    true
  } else {
    game.hostages_rescued >= game.hostages_goal
  }
}

///|
fn update_hostages(game : Game, dt : Float) -> Unit {
  let pickup_r2 = rescue_pickup_radius * rescue_pickup_radius

  for i = 0; i < game.hostages.length(); i = i + 1 {
    let hostage = game.hostages[i]
    if not(hostage.active) {
      continue i + 1
    }

    hostage.bob += dt * 3.4
    hostage.blink += dt

    for p = 0; p < max_players; p = p + 1 {
      let player = game.players[p]
      if not(player.active) {
        continue p + 1
      }

      if distance_sq(hostage.x, hostage.y, player.x, player.y) <= pickup_r2 {
        hostage.active = false
        hostage.rescued = true
        game.hostages_rescued += 1

        let team = team_of_player(p)
        grant_score(game, team, rescue_score_each)
        spawn_spark_burst(game, hostage.x, hostage.y - 8.0, 12)
        spawn_respawn_burst(game, hostage.x, hostage.y)

        if rescue_objective_done(game) && not(game.rescue_stage_bonus_awarded) {
          game.rescue_stage_bonus_awarded = true
          grant_score(game, team, rescue_stage_bonus)
          spawn_spark_burst(
            game,
            Float::from_int(map_pixel_w / 2),
            Float::from_int(map_pixel_h / 2),
            32,
          )
          push_camera_shake(game, 1.9)
        }
        break
      }
    }
  }
}
