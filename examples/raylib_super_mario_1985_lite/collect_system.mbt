///|
fn clear_collectibles(game : Game) -> Unit {
  for i = 0; i < game.coins.length(); i = i + 1 {
    game.coins[i] = Coin::inactive()
  }
  game.coins_collected = 0
  game.coins_goal = coins_goal_base
  game.goal_open = false
  game.goal_reached = false
  game.goal_x = Float::from_int(map_pixel_w - tile_size * 2)
  game.goal_y = Float::from_int(tile_size * 2)
}

///|
fn alloc_coin_slot(game : Game) -> Int {
  for i = 0; i < game.coins.length(); i = i + 1 {
    if not(game.coins[i].active) {
      return i
    }
  }
  -1
}

///|
fn coin_goal_for_stage(stage : Int) -> Int {
  let wave = stage + 1
  clampi(coins_goal_base + wave / 2 * coins_goal_step, coins_goal_base, 58)
}

///|
fn tile_is_coin_spawnable(tile : Int) -> Bool {
  tile == tile_empty || tile == tile_bush || tile == tile_ice
}

///|
fn try_spawn_coin_at_tile(game : Game, tx : Int, ty : Int) -> Bool {
  if not(in_tile_bounds(tx, ty)) {
    return false
  }
  if absf(Float::from_int(tx - base_tile_x)) <= 2.0 &&
    absf(Float::from_int(ty - base_tile_y)) <= 2.0 {
    return false
  }

  let tile = get_tile(game, tx, ty)
  if not(tile_is_coin_spawnable(tile)) {
    return false
  }

  let slot = alloc_coin_slot(game)
  if slot < 0 {
    return false
  }

  let coin = game.coins[slot]
  coin.active = true
  coin.x = tile_center_x(tx)
  coin.y = tile_center_y(ty)
  coin.bob = rand_rangef(game, 0.0, 6.2)
  coin.spin = rand_rangef(game, 0.0, 6.2)
  true
}

///|
fn seed_stage_collectibles(game : Game, stage : Int) -> Unit {
  clear_collectibles(game)

  game.coins_goal = coin_goal_for_stage(stage)
  game.goal_x = Float::from_int(map_pixel_w - tile_size * 2)
  game.goal_y = Float::from_int(tile_size * 2 + stage % 3 * tile_size * 2)

  let mut placed = 0
  let mut tries = 0
  while placed < game.coins_goal && tries < 1800 {
    tries += 1
    let tx = rand_range(game, 1, map_tiles_w - 2)
    let ty = rand_range(game, 1, map_tiles_h - 2)
    if try_spawn_coin_at_tile(game, tx, ty) {
      placed += 1
    }
  }

  if placed < game.coins_goal {
    for ty = 1; ty < map_tiles_h - 1 && placed < game.coins_goal; ty = ty + 1 {
      for tx = 1; tx < map_tiles_w - 1 && placed < game.coins_goal; tx = tx + 1 {
        if try_spawn_coin_at_tile(game, tx, ty) {
          placed += 1
        }
      }
    }
  }
  game.coins_goal = placed
}

///|
fn collect_objective_done(game : Game) -> Bool {
  game.goal_reached
}

///|
fn update_collectibles(game : Game, dt : Float) -> Unit {
  let pickup_r2 = coin_pickup_radius * coin_pickup_radius

  for i = 0; i < game.coins.length(); i = i + 1 {
    if not(game.coins[i].active) {
      continue i + 1
    }
    let coin = game.coins[i]
    coin.bob += dt * 3.2
    coin.spin += dt * 6.8

    for p = 0; p < max_players; p = p + 1 {
      let player = game.players[p]
      if not(player.active) {
        continue p + 1
      }
      if distance_sq(coin.x, coin.y, player.x, player.y) <= pickup_r2 {
        coin.active = false
        game.coins_collected += 1
        grant_score(game, team_of_player(p), coin_score)
        spawn_spark_burst(game, coin.x, coin.y - 4.0, 9)
        break
      }
    }
  }

  if not(game.goal_open) &&
    game.coins_goal > 0 &&
    game.coins_collected >= game.coins_goal {
    game.goal_open = true
    spawn_spark_burst(game, game.goal_x, game.goal_y, 26)
    push_camera_shake(game, 1.5)
  }

  if game.goal_open && not(game.goal_reached) {
    let goal_r2 = goal_pole_radius * goal_pole_radius
    for p = 0; p < max_players; p = p + 1 {
      let player = game.players[p]
      if not(player.active) {
        continue p + 1
      }
      if distance_sq(game.goal_x, game.goal_y, player.x, player.y) <= goal_r2 {
        game.goal_reached = true
        grant_score(game, team_of_player(p), goal_reach_bonus)
        spawn_spark_burst(game, game.goal_x, game.goal_y, 44)
        spawn_respawn_burst(game, game.goal_x, game.goal_y)
        push_camera_shake(game, 2.0)
        break
      }
    }
  }
}
