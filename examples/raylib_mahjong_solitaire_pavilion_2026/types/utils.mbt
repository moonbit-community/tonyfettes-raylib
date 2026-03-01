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
pub fn idx(x : Int, y : Int) -> Int {
  (y - 1) * max_cols + (x - 1)
}

///|
pub fn in_board(game : Game, x : Int, y : Int) -> Bool {
  x >= 1 && x <= game.board_w && y >= 1 && y <= game.board_h
}

///|
pub fn active_at(game : Game, x : Int, y : Int) -> Bool {
  if in_board(game, x, y) {
    game.active[idx(x, y)]
  } else {
    false
  }
}

///|
pub fn cell_at(game : Game, x : Int, y : Int) -> Int {
  if in_board(game, x, y) && game.active[idx(x, y)] {
    game.cells[idx(x, y)]
  } else {
    0
  }
}

///|
pub fn set_cell(game : Game, x : Int, y : Int, value : Int) -> Unit {
  if in_board(game, x, y) && game.active[idx(x, y)] {
    game.cells[idx(x, y)] = value
  }
}

///|
pub fn clear_board(game : Game) -> Unit {
  for i in 0..<game.active.length() {
    game.active[i] = false
    game.cells[i] = 0
  }
}

///|
pub fn clear_undo(game : Game) -> Unit {
  game.undo_len = 0
  for i in 0..<game.undo.length() {
    game.undo[i] = {
      valid: false,
      x1: 0,
      y1: 0,
      kind1: 0,
      x2: 0,
      y2: 0,
      kind2: 0,
      prev_score: 0,
      prev_combo: 0,
      prev_timer: 0.0,
      prev_remaining: 0,
    }
  }
}

///|
pub fn clear_sparks(game : Game) -> Unit {
  for spark in game.sparks {
    spark.active = false
    spark.x = 0.0
    spark.y = 0.0
    spark.vx = 0.0
    spark.vy = 0.0
    spark.life = 0.0
    spark.size = 0.0
    spark.kind = 0
  }
}

///|
pub fn clear_selection(game : Game) -> Unit {
  game.select_active = false
  game.select_x = 1
  game.select_y = 1
}

///|
pub fn clear_hint(game : Game) -> Unit {
  game.hint_active = false
  game.hint_ttl = 0.0
}

///|
pub fn board_metrics(game : Game) -> (Int, Int, Int) {
  let area_x : Int = 24
  let area_y : Int = 22
  let area_w : Int = screen_w - 460
  let area_h : Int = screen_h - 44

  let safe_w : Int = maxi(1, game.board_w)
  let safe_h : Int = maxi(1, game.board_h)

  let tile_x : Int = (area_w - 24) / safe_w
  let tile_y : Int = (area_h - 24) / safe_h
  let mut tile : Int = mini(tile_x, tile_y)
  tile = clampi(tile, 36, 86)

  let mut board_x : Int = area_x + (area_w - safe_w * tile) / 2
  let mut board_y : Int = area_y + (area_h - safe_h * tile) / 2

  if game.shake_t > 0.0 {
    board_x = board_x + @raylib.get_random_value(-3, 3)
    board_y = board_y + @raylib.get_random_value(-3, 3)
  }

  (board_x, board_y, tile)
}

///|
pub fn world_center(game : Game, x : Int, y : Int) -> (Float, Float, Float) {
  let (board_x, board_y, tile) = board_metrics(game)
  let cx : Float = Float::from_int(board_x + (x - 1) * tile + tile / 2)
  let cy : Float = Float::from_int(board_y + (y - 1) * tile + tile / 2)
  (cx, cy, Float::from_int(tile))
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
  kind : Int,
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
pub fn burst_tile(game : Game, x : Int, y : Int, amount : Int, kind : Int) -> Unit {
  let (cx, cy, tilef) = world_center(game, x, y)
  let spread : Float = maxf(8.0, tilef * 0.22)

  for _i in 0..<amount {
    spawn_spark(
      game,
      cx + randf(-spread, spread),
      cy + randf(-spread, spread),
      randf(-160.0, 160.0),
      randf(-170.0, 156.0),
      randf(0.20, 0.92),
      randf(1.6, 5.6),
      kind,
    )
  }
}

///|
pub fn update_sparks(game : Game, dt : Float) -> Unit {
  for spark in game.sparks {
    if not(spark.active) {
      continue
    }

    spark.life = spark.life - dt
    if spark.life <= 0.0 {
      spark.active = false
      continue
    }

    spark.x = spark.x + spark.vx * dt
    spark.y = spark.y + spark.vy * dt
    spark.vx = spark.vx * (1.0 - dt * 1.9)
    spark.vy = spark.vy * (1.0 - dt * 1.9) + dt * 36.0
  }
}

///|
pub fn shuffle_ints(arr : Array[Int]) -> Unit {
  let mut i : Int = arr.length() - 1
  while i > 0 {
    let j : Int = @raylib.get_random_value(0, i)
    let t : Int = arr[i]
    arr[i] = arr[j]
    arr[j] = t
    i = i - 1
  }
}

///|
pub fn active_count(game : Game) -> Int {
  let mut n : Int = 0
  for y in 1..<=game.board_h {
    for x in 1..<=game.board_w {
      if active_at(game, x, y) {
        n = n + 1
      }
    }
  }
  n
}

///|
pub fn free_tile(game : Game, x : Int, y : Int) -> Bool {
  let k : Int = cell_at(game, x, y)
  if k <= 0 {
    return false
  }

  let left_block : Bool = x > 1 &&
    active_at(game, x - 1, y) &&
    cell_at(game, x - 1, y) > 0
  let right_block : Bool = x < game.board_w &&
    active_at(game, x + 1, y) &&
    cell_at(game, x + 1, y) > 0

  not(left_block && right_block)
}

///|
pub fn configure_level(
  id : Int,
) -> (Int, Int, Int, Float, Int, Int, Int, Int, String) {
  if id == 0 {
    (10, 6, 12, 120.0, 4, 4, 3, 0, "Courtyard Warmup")
  } else if id == 1 {
    (12, 6, 14, 126.0, 4, 4, 3, 1, "Bamboo Gate")
  } else if id == 2 {
    (12, 8, 16, 138.0, 4, 3, 3, 2, "Lantern Bridge")
  } else if id == 3 {
    (14, 8, 18, 146.0, 3, 3, 3, 3, "River Walk")
  } else if id == 4 {
    (14, 9, 20, 154.0, 3, 3, 3, 4, "Pavilion Hall")
  } else if id == 5 {
    (16, 8, 22, 164.0, 3, 3, 2, 5, "Moon Stage")
  } else if id == 6 {
    (16, 9, 24, 172.0, 2, 3, 2, 6, "Dragon Corridor")
  } else if id == 7 {
    (16, 10, 26, 182.0, 2, 2, 2, 7, "Opera Plaza")
  } else if id == 8 {
    (18, 10, 28, 196.0, 2, 2, 2, 8, "Imperial Garden")
  } else {
    (18, 12, 30, 220.0, 2, 2, 1, 9, "Master Solitaire")
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
pub fn select_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 256, 170, 72)
}

///|
pub fn hint_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 256, 170, 72)
}

///|
pub fn shuffle_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 172, 170, 72)
}

///|
pub fn undo_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 172, 170, 72)
}

///|
pub fn reset_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 88, 170, 72)
}

///|
pub fn clear_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 214, screen_h - 88, 170, 72)
}

///|
pub fn next_button_rect() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 88, 360, 72)
}

///|
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, screen_h - 158, 460, 96)
}
