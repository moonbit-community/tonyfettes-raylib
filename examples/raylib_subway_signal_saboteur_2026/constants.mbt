///|
let screen_w : Int = 1840

///|
let screen_h : Int = 1010

///|
let target_fps : Int = 120

///|
let board_x0 : Int = 26

///|
let board_y0 : Int = 84

///|
let cell : Int = 56

///|
let grid_w : Int = 25

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
let tile_void : Int = 0

///|
let tile_floor : Int = 1

///|
let tile_track : Int = 2

///|
let tile_wall : Int = 3

///|
let train_lane_n : Int = 3

///|
let junction_n : Int = 4

///|
let max_trains : Int = 24

///|
let max_inspectors : Int = 3

///|
let max_particles : Int = 420

///|
let inspector_patrol : Int = 0

///|
let inspector_hunt : Int = 1

///|
let inspector_stunned : Int = 2

///|
let max_lives : Int = 3

///|
let goal_routed : Int = 20

///|
let round_time_limit : Float = 210.0

///|
let train_exit_x : Float = 23.4

///|
let train_spawn_x : Float = 1.0

///|
let player_move_t : Float = 0.105

///|
let inspector_move_t : Float = 0.145

///|
let emp_cost : Float = 35.0

///|
let score_route_ok : Int = 120

///|
let score_route_bad : Int = -70

///|
let score_toggle : Int = 20

///|
let score_emp_hit : Int = 50

///|
let score_win_bonus : Int = 1000

///|
let start_x : Int = 2

///|
let start_y : Int = 10

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
fn absf(v : Float) -> Float {
  if v < 0.0 {
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
fn lane_to_y(lane : Int) -> Int {
  4 + lane * 2
}

///|
fn junction_x(i : Int) -> Int {
  6 + i * 4
}

///|
fn signal_panel_top_y() -> Int {
  2
}

///|
fn signal_panel_bottom_y() -> Int {
  10
}

///|
fn start_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 26, screen_h - 194, panel_w - 52, 72)
}

///|
fn retry_button_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 26, screen_h - 194, panel_w - 52, 72)
}

///|
fn btn_left() -> (Int, Int, Int, Int) {
  let x0 : Int = 36
  let y0 : Int = screen_h - 244
  (x0, y0 + 72, 78, 78)
}

///|
fn btn_right() -> (Int, Int, Int, Int) {
  let x0 : Int = 36
  let y0 : Int = screen_h - 244
  (x0 + 156, y0 + 72, 78, 78)
}

///|
fn btn_up() -> (Int, Int, Int, Int) {
  let x0 : Int = 36
  let y0 : Int = screen_h - 244
  (x0 + 78, y0, 78, 78)
}

///|
fn btn_down() -> (Int, Int, Int, Int) {
  let x0 : Int = 36
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
    "Route trains to their target lane colors before they exit right."
  } else if i == 1 {
    "Switches affect trains only when crossing a junction column."
  } else if i == 2 {
    "Action on panel toggles signal: UP -> STRAIGHT -> DOWN."
  } else {
    "Action off-panel triggers EMP smoke to stun inspectors briefly."
  }
}
