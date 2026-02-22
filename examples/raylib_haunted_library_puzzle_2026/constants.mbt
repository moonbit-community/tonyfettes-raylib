///|
let screen_w : Int = 1760

///|
let screen_h : Int = 980

///|
let target_fps : Int = 120

///|
let board_x0 : Int = 30

///|
let board_y0 : Int = 84

///|
let cell : Int = 60

///|
let grid_w : Int = 21

///|
let grid_h : Int = 13

///|
let board_w : Int = grid_w * cell

///|
let board_h : Int = grid_h * cell

///|
let panel_x0 : Int = board_x0 + board_w + 24

///|
let panel_w : Int = screen_w - panel_x0 - 24

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_result : Int = 2

///|
let tile_floor : Int = 0

///|
let tile_wall : Int = 1

///|
let tile_exit : Int = 2

///|
let ghost_patrol : Int = 0

///|
let ghost_hunt : Int = 1

///|
let ghost_stunned : Int = 2

///|
let max_shelves : Int = 32

///|
let max_pages : Int = 5

///|
let max_ghosts : Int = 5

///|
let seal_need : Int = 3

///|
let max_particles : Int = 360

///|
let player_move_time : Float = 0.115

///|
let ghost_move_time : Float = 0.165

///|
let page_score : Int = 350

///|
let seal_score : Int = 220

///|
let escape_score : Int = 1000

///|
let start_x : Int = 1

///|
let start_y : Int = 1

///|
let exit_x : Int = grid_w - 2

///|
let exit_y : Int = grid_h - 2

///|
fn mini(a : Int, b : Int) -> Int {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn absi(v : Int) -> Int {
  if v < 0 {
    -v
  } else {
    v
  }
}

///|
fn lerpf(a : Float, b : Float, t : Float) -> Float {
  a + (b - a) * t
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn manhattan(x0 : Int, y0 : Int, x1 : Int, y1 : Int) -> Int {
  absi(x1 - x0) + absi(y1 - y0)
}

///|
fn board_px(x : Int) -> Int {
  board_x0 + x * cell
}

///|
fn board_py(y : Int) -> Int {
  board_y0 + y * cell
}

///|
fn cell_center_x(x : Float) -> Int {
  board_x0 + (x * Float::from_int(cell)).to_int() + cell / 2
}

///|
fn cell_center_y(y : Float) -> Int {
  board_y0 + (y * Float::from_int(cell)).to_int() + cell / 2
}

///|
fn start_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 36, screen_h - 196, panel_w - 72, 70)
}

///|
fn retry_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 36, screen_h - 188, panel_w - 72, 70)
}

///|
fn btn_left() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0, y0 + 70, 74, 74)
}

///|
fn btn_right() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0 + 148, y0 + 70, 74, 74)
}

///|
fn btn_up() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0 + 74, y0, 74, 74)
}

///|
fn btn_down() -> (Int, Int, Int, Int) {
  let x0 : Int = 44
  let y0 : Int = screen_h - 238
  (x0 + 74, y0 + 140, 74, 74)
}

///|
fn btn_action() -> (Int, Int, Int, Int) {
  (screen_w - 190, screen_h - 224, 128, 128)
}

///|
fn btn_hint() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 182, 120, 70)
}

///|
fn btn_restart() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 266, 120, 70)
}

///|
fn btn_menu() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 350, 120, 70)
}

///|
fn seal_pos(i : Int) -> (Int, Int) {
  if i == 0 {
    (6, 9)
  } else if i == 1 {
    (11, 5)
  } else {
    (16, 9)
  }
}

///|
fn seal_hint(i : Int) -> String {
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
