///|
let screen_w : Int = 1720

///|
let screen_h : Int = 980

///|
let target_fps : Int = 120

///|
let grid_w : Int = 34

///|
let grid_h : Int = 20

///|
let max_cells : Int = grid_w * grid_h

///|
let max_segments : Int = max_cells

///|
let max_rivals : Int = 2

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_result : Int = 2

///|
let dir_left : Int = 0

///|
let dir_right : Int = 1

///|
let dir_up : Int = 2

///|
let dir_down : Int = 3

///|
let food_normal : Int = 0

///|
let food_gold : Int = 1

///|
let lives_default : Int = 3

///|
let match_time_limit : Float = 180.0

///|
let panel_x0 : Int = 1146

///|
let panel_w : Int = screen_w - panel_x0 - 24

///|
let board_area_x : Int = 40

///|
let board_area_y : Int = 30

///|
let board_area_w : Int = panel_x0 - board_area_x - 24

///|
let board_area_h : Int = screen_h - 60

///|
fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 260, 620, 520, 118)
}

///|
fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, 652, 460, 108)
}

///|
fn btn_left() -> (Int, Int, Int, Int) {
  (1180, 710, 104, 94)
}

///|
fn btn_right() -> (Int, Int, Int, Int) {
  (1408, 710, 104, 94)
}

///|
fn btn_up() -> (Int, Int, Int, Int) {
  (1294, 604, 104, 94)
}

///|
fn btn_down() -> (Int, Int, Int, Int) {
  (1294, 816, 104, 94)
}

///|
fn btn_boost() -> (Int, Int, Int, Int) {
  (1530, 690, 154, 112)
}

///|
fn btn_restart() -> (Int, Int, Int, Int) {
  (1530, 816, 154, 92)
}

///|
fn btn_hint() -> (Int, Int, Int, Int) {
  (1530, 590, 154, 82)
}
