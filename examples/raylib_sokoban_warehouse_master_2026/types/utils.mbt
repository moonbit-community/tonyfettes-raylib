///|
pub fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
pub fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

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
pub fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn board_index(x : Int, y : Int) -> Int {
  y * board_cols + x
}

///|
pub fn tile_at(game : Game, x : Int, y : Int) -> Tile {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    Void
  } else {
    game.tiles[board_index(x, y)]
  }
}

///|
pub fn set_tile(game : Game, x : Int, y : Int, tile : Tile) -> Unit {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    return
  }
  game.tiles[board_index(x, y)] = tile
}

///|
pub fn box_at(game : Game, x : Int, y : Int) -> Bool {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    false
  } else {
    game.boxes[board_index(x, y)]
  }
}

///|
pub fn set_box(game : Game, x : Int, y : Int, has_box : Bool) -> Unit {
  if x < 0 || x >= board_cols || y < 0 || y >= board_rows {
    return
  }
  game.boxes[board_index(x, y)] = has_box
}

///|
pub fn walkable_tile(tile : Tile) -> Bool {
  tile == Floor || tile == Goal
}

///|
pub fn goal_filled_count(game : Game) -> Int {
  let mut n : Int = 0
  for y in 0..<game.grid_h {
    for x in 0..<game.grid_w {
      if tile_at(game, x, y) == Goal && box_at(game, x, y) {
        n = n + 1
      }
    }
  }
  n
}

///|
pub fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
pub fn pointer_on_rect(
  mouse_x : Float,
  mouse_y : Float,
  mouse_flag : Bool,
  touch_count : Int,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  let mut hit : Bool = false

  if mouse_flag && inside_rect(mouse_x, mouse_y, x, y, w, h) {
    hit = true
  }

  if not(hit) {
    for i in 0..<touch_count {
      let p = @raylib.get_touch_position(i)
      if inside_rect(p.x, p.y, x, y, w, h) {
        hit = true
      }
    }
  }

  hit
}

///|
pub fn dpad_center_x() -> Int {
  160
}

///|
pub fn dpad_center_y() -> Int {
  screen_h - 180
}

///|
pub fn dpad_size() -> Int {
  76
}

///|
pub fn action_panel_x() -> Int {
  screen_w - 300
}

///|
pub fn action_panel_y() -> Int {
  screen_h - 252
}

///|
pub fn action_panel_w() -> Int {
  118
}

///|
pub fn action_panel_h() -> Int {
  74
}

///|
pub fn next_button_rect() -> (Int, Int, Int, Int) {
  (screen_w - 348, screen_h - 130, 310, 84)
}

///|
pub fn title_start_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, screen_h - 170, 440, 92)
}
