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
pub fn absi(v : Int) -> Int {
  if v < 0 {
    -v
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
pub fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
pub fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
pub fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
pub fn manhattan(x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Int {
  absi(x1 - x0) + absi(y1 - y0)
}

///|
pub fn board_px(x : Int) -> Int {
  board_x0 + x * cell
}

///|
pub fn board_py(y : Int) -> Int {
  board_y0 + y * cell
}

///|
pub fn cell_center_x(x : Float) -> Int {
  board_x0 + (x * Float::from_int(cell)).to_int() + cell / 2
}

///|
pub fn cell_center_y(y : Float) -> Int {
  board_y0 + (y * Float::from_int(cell)).to_int() + cell / 2
}

///|
pub fn lane_to_y(lane : Int) -> Int {
  4 + lane * 2
}

///|
pub fn junction_x(i : Int) -> Int {
  6 + i * 4
}

///|
pub fn signal_panel_top_y() -> Int {
  2
}

///|
pub fn signal_panel_bottom_y() -> Int {
  10
}

///|
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 26, screen_h - 194, panel_w - 52, 72)
}

///|
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 26, screen_h - 194, panel_w - 52, 72)
}

///|
pub fn btn_left() -> (Int, Int, Int, Int) {
  let x0 : Int = 36
  let y0 : Int = screen_h - 244
  (x0, y0 + 72, 78, 78)
}

///|
pub fn btn_right() -> (Int, Int, Int, Int) {
  let x0 : Int = 36
  let y0 : Int = screen_h - 244
  (x0 + 156, y0 + 72, 78, 78)
}

///|
pub fn btn_up() -> (Int, Int, Int, Int) {
  let x0 : Int = 36
  let y0 : Int = screen_h - 244
  (x0 + 78, y0, 78, 78)
}

///|
pub fn btn_down() -> (Int, Int, Int, Int) {
  let x0 : Int = 36
  let y0 : Int = screen_h - 244
  (x0 + 78, y0 + 144, 78, 78)
}

///|
pub fn btn_action() -> (Int, Int, Int, Int) {
  (screen_w - 192, screen_h - 226, 128, 128)
}

///|
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (screen_w - 338, screen_h - 182, 118, 70)
}

///|
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (screen_w - 338, screen_h - 266, 118, 70)
}

///|
pub fn btn_menu() -> (Int, Int, Int, Int) {
  (screen_w - 338, screen_h - 350, 118, 70)
}

///|
pub fn hint_text(i : Int) -> String {
  if i == 0 {
    "Route trains to their target lane colors before they exit right."
  } else if i == 1 {
    "Switches affect trains only when crossing a junction column."
  } else if i == 2 {
    "Action on panel toggles signal: UP -> STRAIGHT -> DOWN."
  } else {
    "Action off-panel triggers EMP smoke to stun inspectors briefly."
  }
}

///|
pub fn point_in_rect(
  x : Float,
  y : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  let x0 : Float = Float::from_int(rx)
  let y0 : Float = Float::from_int(ry)
  let x1 : Float = Float::from_int(rx + rw)
  let y1 : Float = Float::from_int(ry + rh)
  x >= x0 && x <= x1 && y >= y0 && y <= y1
}

///|
pub fn pointer_on_rect(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  if hold && point_in_rect(mx, my, rx, ry, rw, rh) {
    return true
  }

  for i in 0..<touch_count {
    let p = @raylib.get_touch_position(i)
    if point_in_rect(p.x, p.y, rx, ry, rw, rh) {
      return true
    }
  }

  false
}

///|
pub fn idx(x : Int, y : Int) -> Int {
  y * grid_w + x
}

///|
pub fn in_bounds(x : Int, y : Int) -> Bool {
  x >= 0 && x < grid_w && y >= 0 && y < grid_h
}

///|
pub fn tile_at(game : Game, x : Int, y : Int) -> Tile {
  if not(in_bounds(x, y)) {
    Void
  } else {
    game.map[idx(x, y)]
  }
}

///|
pub fn set_tile(game : Game, x : Int, y : Int, t : Tile) -> Unit {
  if not(in_bounds(x, y)) {
    return
  }
  game.map[idx(x, y)] = t
}

///|
pub fn set_msg(game : Game, msg : String, ttl : Float) -> Unit {
  game.msg = msg
  game.msg_t = ttl
}

///|
pub fn actor_place(a : Actor, x : Int, y : Int) -> Unit {
  a.x = x
  a.y = y
  a.from_x = x
  a.from_y = y
  a.to_x = x
  a.to_y = y
  a.fx = Float::from_int(x)
  a.fy = Float::from_int(y)
  a.t = 1.0
  a.moving = false
}

///|
pub fn actor_start_move(a : Actor, tx : Int, ty : Int) -> Unit {
  if a.x == tx && a.y == ty {
    return
  }

  a.from_x = a.x
  a.from_y = a.y
  a.to_x = tx
  a.to_y = ty
  a.t = 0.0
  a.moving = true
}

///|
pub fn actor_tick(a : Actor, dt : Float, move_t : Float) -> Unit {
  if not(a.moving) {
    a.fx = Float::from_int(a.x)
    a.fy = Float::from_int(a.y)
    return
  }

  a.t = a.t + dt / move_t
  if a.t >= 1.0 {
    a.t = 1.0
    a.x = a.to_x
    a.y = a.to_y
    a.fx = Float::from_int(a.x)
    a.fy = Float::from_int(a.y)
    a.moving = false
    return
  }

  a.fx = lerpf(Float::from_int(a.from_x), Float::from_int(a.to_x), a.t)
  a.fy = lerpf(Float::from_int(a.from_y), Float::from_int(a.to_y), a.t)
}
