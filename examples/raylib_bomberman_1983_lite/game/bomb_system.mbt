///|
fn alloc_bomb(game : @types.Game) -> Int {
  for i in 0..<game.bombs.length() {
    if not(game.bombs[i].active) {
      return i
    }
  }
  -1
}

///|
fn can_player_place_bomb(game : @types.Game, player_index : Int) -> Bool {
  let player = game.players[player_index]
  if not(player.active) {
    return false
  }
  if player.reload_timer > 0.0 {
    return false
  }

  let team = @types.team_of_player(player_index)
  let bomb_cap = @types.clampi(1 + player.weapon_level / 2, 1, 4)
  if @types.count_team_bombs(game, team) >= bomb_cap {
    return false
  }

  let tx = @types.world_x_to_tile(player.x)
  let ty = @types.world_y_to_tile(player.y)
  let tile = @types.get_tile(game, tx, ty)
  match tile {
    @types.Steel | @types.Water | @types.Base => return false
    _ => ()
  }

  for bomb in game.bombs {
    if bomb.active && bomb.tile_x == tx && bomb.tile_y == ty {
      return false
    }
  }

  true
}

///|
fn place_player_bomb(game : @types.Game, player_index : Int) -> Unit {
  if not(can_player_place_bomb(game, player_index)) {
    return
  }
  let idx = alloc_bomb(game)
  if idx < 0 {
    return
  }

  let player = game.players[player_index]
  let tx = @types.world_x_to_tile(player.x)
  let ty = @types.world_y_to_tile(player.y)
  let bomb = game.bombs[idx]
  bomb.active = true
  bomb.owner_team = @types.team_of_player(player_index)
  bomb.tile_x = tx
  bomb.tile_y = ty
  bomb.x = @types.tile_center_x(tx)
  bomb.y = @types.tile_center_y(ty)
  bomb.fuse = @types.bomb_fuse_time
  bomb.blast_timer = 0.0
  bomb.exploding = false
  bomb.blast_range = @types.clampi(
    @types.bomb_range_base + player.weapon_level / 2,
    2,
    5,
  )

  player.reload_timer = 0.18
  @particles.spawn_spark_burst(game, bomb.x, bomb.y, 6)
}

///|
fn is_blast_blocking_tile(tile : @types.TileKind) -> Bool {
  match tile {
    @types.Brick | @types.Steel | @types.Water | @types.Base => true
    @types.Empty | @types.Bush | @types.Ice => false
  }
}

///|
fn mark_chain_bombs(game : @types.Game, tx : Int, ty : Int) -> Unit {
  for b in game.bombs {
    if not(b.active) || b.exploding {
      continue
    }
    if b.tile_x == tx &&
      b.tile_y == ty &&
      b.fuse > @types.bomb_chain_trigger_window {
      b.fuse = @types.bomb_chain_trigger_window
    }
  }
}

///|
fn hit_entities_on_tile(
  game : @types.Game,
  team : @types.Team,
  tx : Int,
  ty : Int,
) -> Unit {
  for i in 0..<game.enemies.length() {
    let enemy = game.enemies[i]
    if not(enemy.active) {
      continue
    }
    if @types.world_x_to_tile(enemy.x) == tx &&
      @types.world_y_to_tile(enemy.y) == ty {
      destroy_enemy(game, i, team)
    }
  }

  for i in 0..<@types.max_players {
    let player = game.players[i]
    if not(player.active) {
      continue
    }
    if @types.world_x_to_tile(player.x) == tx &&
      @types.world_y_to_tile(player.y) == ty {
      on_player_destroyed(game, i)
    }
  }
}

///|
fn detonate_tile(
  game : @types.Game,
  team : @types.Team,
  tx : Int,
  ty : Int,
) -> Bool {
  if not(@types.in_tile_bounds(tx, ty)) {
    return false
  }

  let cx = @types.tile_center_x(tx)
  let cy = @types.tile_center_y(ty)
  @particles.spawn_spark_burst(game, cx, cy, 7)

  hit_entities_on_tile(game, team, tx, ty)
  mark_chain_bombs(game, tx, ty)

  let tile = @types.get_tile(game, tx, ty)
  match tile {
    Brick => {
      @types.set_tile(game, tx, ty, @types.Empty, 0)
      @particles.spawn_explosion(game, cx, cy, 0.72)
      return false
    }
    Steel | Water => return false
    Base => {
      game.base_alive = false
      game.base_flash = 1.0
      @particles.spawn_explosion(game, cx, cy, 1.65)
      @types.push_camera_shake(game, 2.2)
      return false
    }
    _ => not(is_blast_blocking_tile(tile))
  }
}

///|
fn trigger_bomb(game : @types.Game, bomb_index : Int) -> Unit {
  if bomb_index < 0 || bomb_index >= game.bombs.length() {
    return
  }
  let bomb = game.bombs[bomb_index]
  if not(bomb.active) || bomb.exploding {
    return
  }

  bomb.exploding = true
  bomb.fuse = 0.0
  bomb.blast_timer = @types.bomb_blast_time

  let tx = bomb.tile_x
  let ty = bomb.tile_y
  let team = bomb.owner_team
  let range = bomb.blast_range

  ignore(detonate_tile(game, team, tx, ty))
  for dir in 0..<4 {
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
    for step in 1..<=range {
      let nx = tx + dx * step
      let ny = ty + dy * step
      if not(@types.in_tile_bounds(nx, ny)) {
        break
      }
      if not(detonate_tile(game, team, nx, ny)) {
        break
      }
    }
  }

  @particles.spawn_explosion(game, bomb.x, bomb.y, 1.0)
  @types.push_camera_shake(game, 1.7)
}

///|
fn update_bombs(game : @types.Game, dt : Float) -> Unit {
  for i in 0..<game.bombs.length() {
    let bomb = game.bombs[i]
    if not(bomb.active) {
      continue
    }

    if bomb.exploding {
      bomb.blast_timer -= dt
      if bomb.blast_timer <= 0.0 {
        bomb.active = false
      }
      continue
    }

    bomb.fuse -= dt
    if bomb.fuse <= 0.0 {
      trigger_bomb(game, i)
    }
  }
}
