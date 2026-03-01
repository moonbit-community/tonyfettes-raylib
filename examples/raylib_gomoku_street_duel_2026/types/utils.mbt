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
pub fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn board_index(x : Int, y : Int) -> Int {
  y * board_n + x
}

///|
pub fn in_board(x : Int, y : Int) -> Bool {
  x >= 0 && x < board_n && y >= 0 && y < board_n
}

///|
pub fn cell_at(game : Game, x : Int, y : Int) -> Player {
  if in_board(x, y) {
    game.board[board_index(x, y)]
  } else {
    Empty
  }
}

///|
pub fn set_cell(game : Game, x : Int, y : Int, p : Player) -> Unit {
  if in_board(x, y) {
    game.board[board_index(x, y)] = p
  }
}

///|
pub fn set_message(game : Game, msg : String, ttl : Float) -> Unit {
  game.message = msg
  game.message_t = ttl
}

///|
pub fn clear_hint(game : Game) -> Unit {
  game.hint_active = false
  game.hint_ttl = 0.0
  game.hint_x = 0
  game.hint_y = 0
}

///|
pub fn spawn_spark(
  game : Game,
  x : Float,
  y : Float,
  vx : Float,
  vy : Float,
  life : Float,
  size : Float,
  kind : SparkKind,
) -> Unit {
  for spark in game.sparks {
    if spark.active {
      continue
    }

    spark.active = true
    spark.x = x
    spark.y = y
    spark.vx = vx
    spark.vy = vy
    spark.life = life
    spark.size = size
    spark.kind = kind
    break
  }
}

///|
pub fn board_metrics(game : Game) -> (Int, Int, Int) {
  let area_x : Int = 24
  let area_y : Int = 22
  let area_w : Int = screen_w - 460
  let area_h : Int = screen_h - 44

  let tile_x : Int = (area_w - 24) / board_n
  let tile_y : Int = (area_h - 24) / board_n

  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 42, 72)

  let mut board_x : Int = area_x + (area_w - board_n * tile) / 2
  let mut board_y : Int = area_y + (area_h - board_n * tile) / 2

  if game.shake_t > 0.0 {
    board_x = board_x + @raylib.get_random_value(-3, 3)
    board_y = board_y + @raylib.get_random_value(-3, 3)
  }

  (board_x, board_y, tile)
}

///|
pub fn world_center(game : Game, x : Int, y : Int) -> (Float, Float, Float) {
  let (bx, by, tile) = board_metrics(game)
  let cx : Float = Float::from_int(bx + x * tile + tile / 2)
  let cy : Float = Float::from_int(by + y * tile + tile / 2)
  (cx, cy, Float::from_int(tile))
}

///|
pub fn burst_move(
  game : Game,
  x : Int,
  y : Int,
  amount : Int,
  kind : SparkKind,
) -> Unit {
  let (cx, cy, tilef) = world_center(game, x, y)
  let spread : Float = maxf(8.0, tilef * 0.22)

  for _i in 0..<amount {
    spawn_spark(
      game,
      cx + randf(-spread, spread),
      cy + randf(-spread, spread),
      randf(-150.0, 150.0),
      randf(-160.0, 150.0),
      randf(0.2, 0.9),
      randf(1.6, 5.4),
      kind,
    )
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
pub fn panel_x() -> Int {
  screen_w - 420
}

///|
pub fn dpad_center_x() -> Int {
  162
}

///|
pub fn dpad_center_y() -> Int {
  screen_h - 184
}

///|
pub fn dpad_size() -> Int {
  78
}

///|
pub fn place_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 256, 170, 72)
}

///|
pub fn hint_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 256, 170, 72)
}

///|
pub fn undo_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 172, 170, 72)
}

///|
pub fn clear_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 172, 170, 72)
}

///|
pub fn reset_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 88, 170, 72)
}

///|
pub fn next_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 88, 360, 72)
}

///|
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, screen_h - 158, 460, 96)
}
