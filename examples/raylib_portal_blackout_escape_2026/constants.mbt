///|
let screen_w : Int = 1780

///|
let screen_h : Int = 1000

///|
let target_fps : Int = 120

///|
let board_x0 : Int = 28

///|
let board_y0 : Int = 86

///|
let cell : Int = 60

///|
let grid_w : Int = 23

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
let tile_wall : Int = 0

///|
let tile_floor : Int = 1

///|
let tile_exit : Int = 2

///|
let drone_patrol : Int = 0

///|
let drone_hunt : Int = 1

///|
let drone_stunned : Int = 2

///|
let max_drones : Int = 5

///|
let max_cores : Int = 8

///|
let max_flares : Int = 6

///|
let max_particles : Int = 420

///|
let core_need : Int = 6

///|
let max_lives : Int = 3

///|
let round_time_limit : Float = 210.0

///|
let start_x : Int = 2

///|
let start_y : Int = 11

///|
let exit_x : Int = 21

///|
let exit_y : Int = 1

///|
let portal_ax : Int = 4

///|
let portal_ay : Int = 10

///|
let portal_bx : Int = 18

///|
let portal_by : Int = 3

///|
let player_move_t : Float = 0.105

///|
let drone_move_t : Float = 0.150

///|
let flare_ttl : Float = 4.2

///|
let flare_cost : Float = 34.0

///|
let flare_stun_t : Float = 2.3

///|
let score_core : Int = 180

///|
let score_teleport : Int = 90

///|
let score_stun : Int = 60

///|
let score_win : Int = 1100

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
  (panel_x0 + 26, screen_h - 192, panel_w - 52, 72)
}

///|
fn retry_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 26, screen_h - 192, panel_w - 52, 72)
}

///|
fn btn_left() -> (Int, Int, Int, Int) {
  let x0 : Int = 38
  let y0 : Int = screen_h - 244
  (x0, y0 + 72, 78, 78)
}

///|
fn btn_right() -> (Int, Int, Int, Int) {
  let x0 : Int = 38
  let y0 : Int = screen_h - 244
  (x0 + 156, y0 + 72, 78, 78)
}

///|
fn btn_up() -> (Int, Int, Int, Int) {
  let x0 : Int = 38
  let y0 : Int = screen_h - 244
  (x0 + 78, y0, 78, 78)
}

///|
fn btn_down() -> (Int, Int, Int, Int) {
  let x0 : Int = 38
  let y0 : Int = screen_h - 244
  (x0 + 78, y0 + 144, 78, 78)
}

///|
fn btn_action() -> (Int, Int, Int, Int) {
  (screen_w - 192, screen_h - 226, 128, 128)
}

///|
fn btn_hint() -> (Int, Int, Int, Int) {
  (screen_w - 338, screen_h - 182, 118, 70)
}

///|
fn btn_restart() -> (Int, Int, Int, Int) {
  (screen_w - 338, screen_h - 266, 118, 70)
}

///|
fn btn_menu() -> (Int, Int, Int, Int) {
  (screen_w - 338, screen_h - 350, 118, 70)
}

///|
fn hint_text(i : Int) -> String {
  if i == 0 {
    "Recover 6 energy cores to power the portal network."
  } else if i == 1 {
    "Action near portal teleports; action elsewhere drops flare EMP."
  } else if i == 2 {
    "Flares reveal darkness and stun nearby drones briefly."
  } else {
    "Exit gate unlocks only after portal power reaches 100%."
  }
}
