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
  y * max_board + x
}

///|
pub fn in_grid(game : Game, x : Int, y : Int) -> Bool {
  x >= 0 && x < game.grid_w && y >= 0 && y < game.grid_h
}

///|
pub fn solution_at(game : Game, x : Int, y : Int) -> Bool {
  if not(in_grid(game, x, y)) {
    false
  } else {
    game.solution[board_index(x, y)]
  }
}

///|
pub fn cell_at(game : Game, x : Int, y : Int) -> Int {
  if not(in_grid(game, x, y)) {
    cell_unknown
  } else {
    game.cells[board_index(x, y)]
  }
}

///|
pub fn set_solution(game : Game, x : Int, y : Int, v : Bool) -> Unit {
  if in_grid(game, x, y) {
    game.solution[board_index(x, y)] = v
  }
}

///|
pub fn set_cell(game : Game, x : Int, y : Int, state : Int) -> Unit {
  if in_grid(game, x, y) {
    game.cells[board_index(x, y)] = state
  }
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
  164
}

///|
pub fn dpad_center_y() -> Int {
  screen_h - 186
}

///|
pub fn dpad_size() -> Int {
  78
}

///|
pub fn right_panel_x() -> Int {
  screen_w - 420
}

///|
pub fn action_w() -> Int {
  170
}

///|
pub fn action_h() -> Int {
  72
}

///|
pub fn fill_button_rect() -> (Int, Int, Int, Int) {
  (right_panel_x() + 24, screen_h - 256, action_w(), action_h())
}

///|
pub fn cross_button_rect() -> (Int, Int, Int, Int) {
  (right_panel_x() + 214, screen_h - 256, action_w(), action_h())
}

///|
pub fn undo_button_rect() -> (Int, Int, Int, Int) {
  (right_panel_x() + 24, screen_h - 172, action_w(), action_h())
}

///|
pub fn hint_button_rect() -> (Int, Int, Int, Int) {
  (right_panel_x() + 214, screen_h - 172, action_w(), action_h())
}

///|
pub fn reset_button_rect() -> (Int, Int, Int, Int) {
  (right_panel_x() + 24, screen_h - 88, action_w(), action_h())
}

///|
pub fn next_button_rect() -> (Int, Int, Int, Int) {
  (right_panel_x() + 24, screen_h - 88, 360, 72)
}

///|
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, screen_h - 160, 480, 96)
}

///|
pub fn row_solved(game : Game, y : Int) -> Bool {
  for x in 0..<game.grid_w {
    let sol : Bool = solution_at(game, x, y)
    let state : Int = cell_at(game, x, y)

    if sol && state != cell_fill {
      return false
    }

    if not(sol) && state == cell_fill {
      return false
    }
  }

  true
}

///|
pub fn col_solved(game : Game, x : Int) -> Bool {
  for y in 0..<game.grid_h {
    let sol : Bool = solution_at(game, x, y)
    let state : Int = cell_at(game, x, y)

    if sol && state != cell_fill {
      return false
    }

    if not(sol) && state == cell_fill {
      return false
    }
  }

  true
}

///|
pub fn puzzle_solved(game : Game) -> Bool {
  game.filled_correct >= game.solution_total && game.filled_wrong == 0
}

///|
pub fn max_row_clues(game : Game) -> Int {
  let mut out : Int = 1
  for y in 0..<game.grid_h {
    if game.row_clue_counts[y] > out {
      out = game.row_clue_counts[y]
    }
  }
  out
}

///|
pub fn max_col_clues(game : Game) -> Int {
  let mut out : Int = 1
  for x in 0..<game.grid_w {
    if game.col_clue_counts[x] > out {
      out = game.col_clue_counts[x]
    }
  }
  out
}

///|
pub fn board_metrics(game : Game) -> (Int, Int, Int, Int, Int, Int, Int) {
  let area_x : Int = 26
  let area_y : Int = 24
  let area_w : Int = screen_w - 472
  let area_h : Int = screen_h - 38

  let clue_l : Int = max_row_clues(game)
  let clue_t : Int = max_col_clues(game)

  let den_w : Int = maxi(1, game.grid_w + clue_l)
  let den_h : Int = maxi(1, game.grid_h + clue_t)

  let tile_x : Int = (area_w - 30) / den_w
  let tile_y : Int = (area_h - 30) / den_h

  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 24, 68)

  let total_w : Int = den_w * tile
  let total_h : Int = den_h * tile

  let mut origin_x : Int = area_x + (area_w - total_w) / 2
  let mut origin_y : Int = area_y + (area_h - total_h) / 2

  if game.shake_t > 0.0 {
    origin_x = origin_x + @raylib.get_random_value(-2, 2)
    origin_y = origin_y + @raylib.get_random_value(-2, 2)
  }

  let board_x : Int = origin_x + clue_l * tile
  let board_y : Int = origin_y + clue_t * tile

  (board_x, board_y, tile, clue_l, clue_t, origin_x, origin_y)
}

///|
pub fn world_for_cell(game : Game, x : Int, y : Int) -> (Float, Float, Float) {
  let (board_x, board_y, tile, _, _, _, _) = board_metrics(game)
  let cx : Float = Float::from_int(board_x + x * tile + tile / 2)
  let cy : Float = Float::from_int(board_y + y * tile + tile / 2)
  (cx, cy, Float::from_int(tile))
}
