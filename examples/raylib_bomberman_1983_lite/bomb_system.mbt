///|
fn alloc_bomb(game : Game) -> Int {
  for i = 0; i < game.bombs.length(); i = i + 1 {
    if not(game.bombs[i].active) {
      return i
    }
  }
  -1
}

///|
fn count_team_bombs(game : Game, team : Int) -> Int {
  let mut n = 0
  for i = 0; i < game.bombs.length(); i = i + 1 {
    if game.bombs[i].active && game.bombs[i].owner_team == team {
      n += 1
    }
  }
  n
}

///|
fn can_player_place_bomb(game : Game, player_index : Int) -> Bool {
  let player = game.players[player_index]
  if not(player.active) {
    return false
  }
  if player.reload_timer > 0.0 {
    return false
  }

  let team = team_of_player(player_index)
  let bomb_cap = clampi(1 + player.weapon_level / 2, 1, 4)
  if count_team_bombs(game, team) >= bomb_cap {
    return false
  }

  let tx = world_x_to_tile(player.x)
  let ty = world_y_to_tile(player.y)
  let tile = get_tile(game, tx, ty)
  if tile == tile_steel || tile == tile_water || tile == tile_base {
    return false
  }

  for i = 0; i < game.bombs.length(); i = i + 1 {
    if game.bombs[i].active &&
      game.bombs[i].tile_x == tx &&
      game.bombs[i].tile_y == ty {
      return false
    }
  }

  true
}

///|
fn place_player_bomb(game : Game, player_index : Int) -> Unit {
  if not(can_player_place_bomb(game, player_index)) {
    return
  }
  let idx = alloc_bomb(game)
  if idx < 0 {
    return
  }

  let player = game.players[player_index]
  let tx = world_x_to_tile(player.x)
  let ty = world_y_to_tile(player.y)
  let bomb = game.bombs[idx]
  bomb.active = true
  bomb.owner_team = team_of_player(player_index)
  bomb.tile_x = tx
  bomb.tile_y = ty
  bomb.x = tile_center_x(tx)
  bomb.y = tile_center_y(ty)
  bomb.fuse = bomb_fuse_time
  bomb.blast_timer = 0.0
  bomb.exploding = false
  bomb.blast_range = clampi(bomb_range_base + player.weapon_level / 2, 2, 5)

  player.reload_timer = 0.18
  spawn_spark_burst(game, bomb.x, bomb.y, 6)
}

///|
fn is_blast_blocking_tile(tile : Int) -> Bool {
  tile == tile_brick ||
  tile == tile_steel ||
  tile == tile_water ||
  tile == tile_base
}

///|
fn mark_chain_bombs(game : Game, tx : Int, ty : Int) -> Unit {
  for i = 0; i < game.bombs.length(); i = i + 1 {
    let b = game.bombs[i]
    if not(b.active) || b.exploding {
      continue i + 1
    }
    if b.tile_x == tx && b.tile_y == ty && b.fuse > bomb_chain_trigger_window {
      b.fuse = bomb_chain_trigger_window
    }
  }
}

///|
fn hit_entities_on_tile(game : Game, team : Int, tx : Int, ty : Int) -> Unit {
  for i = 0; i < game.enemies.length(); i = i + 1 {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue i + 1
    }
    if world_x_to_tile(enemy.x) == tx && world_y_to_tile(enemy.y) == ty {
      destroy_enemy(game, i, team)
    }
  }

  for i = 0; i < max_players; i = i + 1 {
    let player = game.players[i]
    if not(player.active) {
      continue i + 1
    }
    if world_x_to_tile(player.x) == tx && world_y_to_tile(player.y) == ty {
      on_player_destroyed(game, i)
    }
  }
}

///|
fn detonate_tile(game : Game, team : Int, tx : Int, ty : Int) -> Bool {
  if not(in_tile_bounds(tx, ty)) {
    return false
  }

  let cx = tile_center_x(tx)
  let cy = tile_center_y(ty)
  spawn_spark_burst(game, cx, cy, 7)

  hit_entities_on_tile(game, team, tx, ty)
  mark_chain_bombs(game, tx, ty)

  let tile = get_tile(game, tx, ty)
  if tile == tile_brick {
    set_tile(game, tx, ty, tile_empty, 0)
    spawn_explosion(game, cx, cy, 0.72)
    return false
  }
  if tile == tile_steel || tile == tile_water {
    return false
  }
  if tile == tile_base {
    game.base_alive = false
    game.base_flash = 1.0
    spawn_explosion(game, cx, cy, 1.65)
    push_camera_shake(game, 2.2)
    return false
  }

  not(is_blast_blocking_tile(tile))
}

///|
fn trigger_bomb(game : Game, bomb_index : Int) -> Unit {
  if bomb_index < 0 || bomb_index >= game.bombs.length() {
    return
  }
  let bomb = game.bombs[bomb_index]
  if not(bomb.active) || bomb.exploding {
    return
  }

  bomb.exploding = true
  bomb.fuse = 0.0
  bomb.blast_timer = bomb_blast_time

  let tx = bomb.tile_x
  let ty = bomb.tile_y
  let team = bomb.owner_team
  let range = bomb.blast_range

  ignore(detonate_tile(game, team, tx, ty))
  for dir = 0; dir < 4; dir = dir + 1 {
    let dx = if dir == 0 {
      0
    } else if dir == 1 {
      1
    } else if dir == 2 {
      0
    } else {
      -1
    }
    let dy = if dir == 0 {
      -1
    } else if dir == 1 {
      0
    } else if dir == 2 {
      1
    } else {
      0
    }
    for step = 1; step <= range; step = step + 1 {
      let nx = tx + dx * step
      let ny = ty + dy * step
      if not(in_tile_bounds(nx, ny)) {
        break
      }
      if not(detonate_tile(game, team, nx, ny)) {
        break
      }
    }
  }

  spawn_explosion(game, bomb.x, bomb.y, 1.0)
  push_camera_shake(game, 1.7)
}

///|
fn update_bombs(game : Game, dt : Float) -> Unit {
  for i = 0; i < game.bombs.length(); i = i + 1 {
    let bomb = game.bombs[i]
    if not(bomb.active) {
      continue i + 1
    }

    if bomb.exploding {
      bomb.blast_timer -= dt
      if bomb.blast_timer <= 0.0 {
        bomb.active = false
      }
      continue i + 1
    }

    bomb.fuse -= dt
    if bomb.fuse <= 0.0 {
      trigger_bomb(game, i)
    }
  }
}
