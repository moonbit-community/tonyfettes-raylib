///|
pub fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn signf(v : Float) -> Int {
  if v < 0.0 {
    -1
  } else if v > 0.0 {
    1
  } else {
    0
  }
}

///|
pub fn tile_index(tx : Int, ty : Int) -> Int {
  ty * world_tiles_w + tx
}

///|
pub fn tile_left(tx : Int) -> Float {
  Float::from_int(tx * tile_size)
}

///|
pub fn tile_top(ty : Int) -> Float {
  Float::from_int(ty * tile_size)
}

///|
pub fn tile_center_x(tx : Int) -> Float {
  tile_left(tx) + tile_size_f * 0.5
}

///|
pub fn tile_center_y(ty : Int) -> Float {
  tile_top(ty) + tile_size_f * 0.5
}

///|
pub fn world_to_tile_x(x : Float) -> Int {
  if x <= 0.0 {
    0
  } else {
    clampi((x / tile_size_f).to_int(), 0, world_tiles_w - 1)
  }
}

///|
pub fn world_to_tile_y(y : Float) -> Int {
  if y <= 0.0 {
    0
  } else {
    clampi((y / tile_size_f).to_int(), 0, world_tiles_h - 1)
  }
}

///|
pub fn set_tile(game : Game, tx : Int, ty : Int, tile : Int) -> Unit {
  if tx < 0 || tx >= world_tiles_w || ty < 0 || ty >= world_tiles_h {
    return
  }
  game.tiles[tile_index(tx, ty)] = tile
}

///|
pub fn get_tile(game : Game, tx : Int, ty : Int) -> Int {
  if tx < 0 || tx >= world_tiles_w {
    return tile_ground
  }
  if ty < 0 {
    return tile_empty
  }
  if ty >= world_tiles_h {
    return tile_ground
  }
  game.tiles[tile_index(tx, ty)]
}

///|
pub fn fill_rect_tile(
  game : Game,
  tx0 : Int,
  ty0 : Int,
  tw : Int,
  th : Int,
  tile : Int,
) -> Unit {
  for y = ty0; y < ty0 + th; y = y + 1 {
    for x = tx0; x < tx0 + tw; x = x + 1 {
      set_tile(game, x, y, tile)
    }
  }
}

///|
pub fn clear_tiles(game : Game) -> Unit {
  for i = 0; i < game.tiles.length(); i = i + 1 {
    game.tiles[i] = tile_empty
  }
}

///|
pub fn tile_is_solid(tile : Int) -> Bool {
  tile == tile_ground ||
  tile == tile_brick ||
  tile == tile_question ||
  tile == tile_used ||
  tile == tile_pipe ||
  tile == tile_castle
}

///|
pub fn rects_overlap(
  ax0 : Float,
  ay0 : Float,
  ax1 : Float,
  ay1 : Float,
  bx0 : Float,
  by0 : Float,
  bx1 : Float,
  by1 : Float,
) -> Bool {
  ax0 < bx1 && ax1 > bx0 && ay0 < by1 && ay1 > by0
}

///|
pub fn world_to_screen_x(world_x : Float, camera_x : Float) -> Float {
  world_x - camera_x
}

///|
pub fn player_half_w() -> Float {
  player_w * 0.5
}

///|
pub fn player_half_h() -> Float {
  player_h * 0.5
}

///|
pub fn enemy_half_w() -> Float {
  enemy_w * 0.5
}

///|
pub fn enemy_half_h() -> Float {
  enemy_h * 0.5
}

///|
pub fn randf(minv : Float, maxv : Float) -> Float {
  let r = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  minv + (maxv - minv) * r
}

///|
pub fn remaining_coins(game : Game) -> Int {
  let mut count = 0
  for i = 0; i < game.coins.length(); i = i + 1 {
    if game.coins[i].active {
      count += 1
    }
  }
  count
}

///|
pub fn active_enemy_count(game : Game) -> Int {
  let mut count = 0
  for i = 0; i < game.enemies.length(); i = i + 1 {
    if game.enemies[i].active {
      count += 1
    }
  }
  count
}
