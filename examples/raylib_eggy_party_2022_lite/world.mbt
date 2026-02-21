///|
fn point_in_world(x : Float, y : Float) -> Bool {
  x >= 0.0 &&
  y >= 0.0 &&
  x < Float::from_int(map_pixel_w) &&
  y < Float::from_int(map_pixel_h)
}

///|
fn tank_hits_world(game : Game, x : Float, y : Float) -> Bool {
  let half = tank_half - 1.0
  if x - half < 0.0 ||
    y - half < 0.0 ||
    x + half >= Float::from_int(map_pixel_w) ||
    y + half >= Float::from_int(map_pixel_h) {
    return true
  }

  let min_tx = world_x_to_tile(x - half)
  let max_tx = world_x_to_tile(x + half)
  let min_ty = world_y_to_tile(y - half)
  let max_ty = world_y_to_tile(y + half)

  for ty = min_ty; ty <= max_ty; ty = ty + 1 {
    for tx = min_tx; tx <= max_tx; tx = tx + 1 {
      let tile = get_tile(game, tx, ty)
      if is_tile_solid_for_tank(tile) {
        return true
      }
    }
  }
  false
}

///|
fn tank_hits_players(
  game : Game,
  x : Float,
  y : Float,
  ignore_player : Int,
) -> Bool {
  let hitbox = tank_rect_at(x, y)
  for i = 0; i < game.players.length(); i = i + 1 {
    if i == ignore_player {
      continue i + 1
    }
    if game.players[i].active {
      if rects_overlap(hitbox, tank_rect(game.players[i])) {
        return true
      }
    }
  }
  false
}

///|
fn tank_hits_enemies(
  game : Game,
  x : Float,
  y : Float,
  ignore_enemy_index : Int,
) -> Bool {
  let hitbox = tank_rect_at(x, y)
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if i == ignore_enemy_index {
      continue i + 1
    }
    if game.enemies[i].active {
      if rects_overlap(hitbox, tank_rect(game.enemies[i])) {
        return true
      }
    }
  }
  false
}

///|
fn damage_tile_at_point(
  game : Game,
  world_x : Float,
  world_y : Float,
  power : Int,
) -> Bool {
  if not(point_in_world(world_x, world_y)) {
    return true
  }

  let tx = world_x_to_tile(world_x)
  let ty = world_y_to_tile(world_y)
  let tile = get_tile(game, tx, ty)
  if not(is_tile_solid_for_bullet(tile)) {
    return false
  }

  let idx = tile_index(tx, ty)
  if tile == tile_brick {
    game.map_hp[idx] -= power
    if game.map_hp[idx] <= 0 {
      set_tile(game, tx, ty, tile_empty, 0)
      spawn_explosion(game, tile_center_x(tx), tile_center_y(ty), 0.45)
    } else {
      spawn_spark_burst(game, world_x, world_y, 6)
    }
  } else if tile == tile_steel {
    if power >= 3 {
      set_tile(game, tx, ty, tile_empty, 0)
      spawn_explosion(game, tile_center_x(tx), tile_center_y(ty), 0.7)
    } else {
      spawn_spark_burst(game, world_x, world_y, 9)
    }
  } else if tile == tile_base {
    game.base_alive = false
    game.base_flash = 1.0
    spawn_explosion(game, tile_center_x(tx), tile_center_y(ty), 2.1)
    push_camera_shake(game, 3.6)
  }
  true
}

///|
fn sight_blocked(
  game : Game,
  ax : Float,
  ay : Float,
  bx : Float,
  by : Float,
) -> Bool {
  let dx = bx - ax
  let dy = by - ay
  let distance = (dx * dx + dy * dy).sqrt()
  if distance <= 1.0 {
    return false
  }
  let step = Float::from_int(tile_size / 2)
  let n = clampi((distance / step).to_int(), 1, 80)
  for i = 1; i < n; i = i + 1 {
    let t = Float::from_int(i) / Float::from_int(n)
    let px = ax + dx * t
    let py = ay + dy * t
    let tile = get_tile(game, world_x_to_tile(px), world_y_to_tile(py))
    if tile == tile_brick || tile == tile_steel || tile == tile_base {
      return true
    }
  }
  false
}
