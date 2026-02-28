///|
pub fn point_in_world(x : Float, y : Float) -> Bool {
  x >= 0.0 &&
  y >= 0.0 &&
  x < Float::from_int(@types.map_pixel_w) &&
  y < Float::from_int(@types.map_pixel_h)
}

///|
pub fn tank_hits_world(game : @types.Game, x : Float, y : Float) -> Bool {
  let half = @types.tank_half - 1.0
  if x - half < 0.0 ||
    y - half < 0.0 ||
    x + half >= Float::from_int(@types.map_pixel_w) ||
    y + half >= Float::from_int(@types.map_pixel_h) {
    return true
  }

  let min_tx = @types.world_x_to_tile(x - half)
  let max_tx = @types.world_x_to_tile(x + half)
  let min_ty = @types.world_y_to_tile(y - half)
  let max_ty = @types.world_y_to_tile(y + half)

  for ty in min_ty..<=max_ty {
    for tx in min_tx..<=max_tx {
      let tile = @types.get_tile(game, tx, ty)
      if @types.is_tile_solid_for_tank(tile) {
        return true
      }
    }
  }
  false
}

///|
pub fn tank_hits_players(
  game : @types.Game,
  x : Float,
  y : Float,
  ignore_player : Int,
) -> Bool {
  let hitbox = @types.tank_rect_at(x, y)
  for i in 0..<game.players.length() {
    if i == ignore_player {
      continue
    }
    if game.players[i].active {
      if @types.rects_overlap(hitbox, @types.tank_rect(game.players[i])) {
        return true
      }
    }
  }
  false
}

///|
pub fn tank_hits_enemies(
  game : @types.Game,
  x : Float,
  y : Float,
  ignore_enemy_index : Int,
) -> Bool {
  let hitbox = @types.tank_rect_at(x, y)
  for i in 0..<game.enemies.length() {
    if i == ignore_enemy_index {
      continue
    }
    if game.enemies[i].active {
      if @types.rects_overlap(hitbox, @types.tank_rect(game.enemies[i])) {
        return true
      }
    }
  }
  false
}

///|
pub fn sight_blocked(
  game : @types.Game,
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
  let step = Float::from_int(@types.tile_size / 2)
  let n = @types.clampi((distance / step).to_int(), 1, 80)
  for i in 1..<n {
    let t = Float::from_int(i) / Float::from_int(n)
    let px = ax + dx * t
    let py = ay + dy * t
    let tile = @types.get_tile(
      game,
      @types.world_x_to_tile(px),
      @types.world_y_to_tile(py),
    )
    if tile == @types.tile_brick ||
      tile == @types.tile_steel ||
      tile == @types.tile_base {
      return true
    }
  }
  false
}
