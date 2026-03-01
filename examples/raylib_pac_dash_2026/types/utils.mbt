///|
pub fn map_index(x : Int, y : Int) -> Int {
  y * maze_cols + x
}

///|
pub fn in_map(x : Int, y : Int) -> Bool {
  x >= 0 && x < maze_cols && y >= 0 && y < maze_rows
}

///|
pub fn tunnel_wrap_x(x : Int) -> Int {
  if x < 0 {
    maze_cols - 1
  } else if x >= maze_cols {
    0
  } else {
    x
  }
}

///|
pub fn is_walkable(game : Game, x : Int, y : Int) -> Bool {
  let wrapped_x = tunnel_wrap_x(x)
  if not(in_map(wrapped_x, y)) {
    return false
  }
  game.walls[map_index(wrapped_x, y)] == 0
}

///|
pub fn manhattan_distance(ax : Int, ay : Int, bx : Int, by : Int) -> Int {
  let dx = (ax - bx).abs()
  let dy = (ay - by).abs()
  dx + dy
}

///|
pub fn tile_center_x(x : Int) -> Int {
  maze_x + x * tile_size + tile_size / 2
}

///|
pub fn tile_center_y(y : Int) -> Int {
  maze_y + y * tile_size + tile_size / 2
}
