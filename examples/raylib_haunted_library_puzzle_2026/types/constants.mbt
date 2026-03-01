///|
pub let screen_w : Int = 1760

///|
pub let screen_h : Int = 980

///|
pub let target_fps : Int = 120

///|
pub let board_x0 : Int = 30

///|
pub let board_y0 : Int = 84

///|
pub let cell : Int = 60

///|
pub let grid_w : Int = 21

///|
pub let grid_h : Int = 13

///|
pub let board_w : Int = grid_w * cell

///|
pub let board_h : Int = grid_h * cell

///|
pub let panel_x0 : Int = board_x0 + board_w + 24

///|
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_result : Int = 2

///|
pub let tile_floor : Int = 0

///|
pub let tile_wall : Int = 1

///|
pub let tile_exit : Int = 2

///|
pub let ghost_patrol : Int = 0

///|
pub let ghost_hunt : Int = 1

///|
pub let ghost_stunned : Int = 2

///|
pub let max_shelves : Int = 32

///|
pub let max_pages : Int = 5

///|
pub let max_ghosts : Int = 5

///|
pub let seal_need : Int = 3

///|
pub let max_particles : Int = 360

///|
pub let player_move_time : Float = 0.115

///|
pub let ghost_move_time : Float = 0.165

///|
pub let page_score : Int = 350

///|
pub let seal_score : Int = 220

///|
pub let escape_score : Int = 1000

///|
pub let start_x : Int = 1

///|
pub let start_y : Int = 1

///|
pub let exit_x : Int = grid_w - 2

///|
pub let exit_y : Int = grid_h - 2

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
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 36, screen_h - 196, panel_w - 72, 70)
}

///|
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 36, screen_h - 188, panel_w - 72, 70)
}

///|
pub fn btn_left() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0, y0 + 70, 74, 74)
}

///|
pub fn btn_right() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0 + 148, y0 + 70, 74, 74)
}

///|
pub fn btn_up() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0 + 74, y0, 74, 74)
}

///|
pub fn btn_down() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0 + 74, y0 + 140, 74, 74)
}

///|
pub fn btn_action() -> (Int, Int, Int, Int) {
  (screen_w - 190, screen_h - 224, 128, 128)
}

///|
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 182, 120, 70)
}

///|
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 266, 120, 70)
}

///|
pub fn btn_menu() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 350, 120, 70)
}

///|
pub fn seal_pos(i : Int) -> (Int, Int) {
  if i == 0 {
    (6, 9)
  } else if i == 1 {
    (11, 5)
  } else {
    (16, 9)
  }
}

///|
pub fn seal_hint(i : Int) -> String {
  if i == 0 {
    "Press shelves onto glowing circles to break arcane locks."
  } else if i == 1 {
    "Stun pulse: Space/E or touch A. It burns lantern energy."
  } else if i == 2 {
    "Collect all lost pages, then escape through the south gate."
  } else {
    "Ghosts hunt in straight lines. Break line-of-sight around stacks."
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
pub fn title_hover(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  let b = start_button_rect()
  pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)
}

///|
pub fn retry_hover(
  mx : Float,
  my : Float,
  hold : Bool,
  touch_count : Int,
) -> Bool {
  let b = retry_button_rect()
  pointer_on_rect(mx, my, hold, touch_count, b.0, b.1, b.2, b.3)
}
