///|
let screen_w : Int = 1820

///|
let screen_h : Int = 1000

///|
let target_fps : Int = 120

///|
let board_x0 : Int = 28

///|
let board_y0 : Int = 86

///|
let cell : Int = 58

///|
let grid_w : Int = 27

///|
let grid_h : Int = 13

///|
let board_w : Int = grid_w * cell

///|
let board_h : Int = grid_h * cell

///|
let panel_x0 : Int = board_x0 + board_w + 20

///|
let panel_w : Int = screen_w - panel_x0 - 20

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_result : Int = 2

///|
let tile_wall : Int = 0

///|
let tile_floor : Int = 1

///|
let tile_door : Int = 2

///|
let tile_exit : Int = 3

///|
let guard_patrol : Int = 0

///|
let guard_hunt : Int = 1

///|
let guard_stunned : Int = 2

///|
let loot_blueprint : Int = 0

///|
let loot_keycard : Int = 1

///|
let loot_gold : Int = 2

///|
let max_guards : Int = 6

///|
let max_loot : Int = 8

///|
let max_smokes : Int = 5

///|
let max_particles : Int = 420

///|
let loot_need : Int = 6

///|
let start_x : Int = 2

///|
let start_y : Int = 6

///|
let exit_x : Int = grid_w - 2

///|
let exit_y : Int = 6

///|
let player_move_t : Float = 0.11

///|
let guard_move_t : Float = 0.15

///|
let smoke_ttl : Float = 4.8

///|
let run_time_limit : Float = 210.0

///|
let smoke_cost : Float = 34.0

///|
let score_blueprint : Int = 280

///|
let score_keycard : Int = 360

///|
let score_gold : Int = 180

///|
let score_escape : Int = 1200

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
  (panel_x0 + 30, screen_h - 192, panel_w - 60, 72)
}

///|
fn retry_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 30, screen_h - 192, panel_w - 60, 72)
}

///|
fn btn_left() -> (Int, Int, Int, Int) {
  let x0 : Int = 40
  let y0 : Int = screen_h - 244
  (x0, y0 + 72, 76, 76)
}

///|
fn btn_right() -> (Int, Int, Int, Int) {
  let x0 : Int = 40
  let y0 : Int = screen_h - 244
  (x0 + 152, y0 + 72, 76, 76)
}

///|
fn btn_up() -> (Int, Int, Int, Int) {
  let x0 : Int = 40
  let y0 : Int = screen_h - 244
  (x0 + 76, y0, 76, 76)
}

///|
fn btn_down() -> (Int, Int, Int, Int) {
  let x0 : Int = 40
  let y0 : Int = screen_h - 244
  (x0 + 76, y0 + 144, 76, 76)
}

///|
fn btn_action() -> (Int, Int, Int, Int) {
  (screen_w - 190, screen_h - 224, 126, 126)
}

///|
fn btn_hint() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 182, 116, 70)
}

///|
fn btn_restart() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 266, 116, 70)
}

///|
fn btn_menu() -> (Int, Int, Int, Int) {
  (screen_w - 334, screen_h - 350, 116, 70)
}

///|
fn hint_text(i : Int) -> String {
  if i == 0 {
    "Collect 6 loot pieces across train cars to unlock the escape cable."
  } else if i == 1 {
    "Guards see down clear corridors. Break sight using walls or smoke."
  } else if i == 2 {
    "Smoke pulse (Space/E/A) stuns nearby guards and blocks vision."
  } else {
    "Keycards are deep in the center cars. Plan the route before sprinting."
  }
}
