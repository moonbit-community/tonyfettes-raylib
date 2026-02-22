///|
let screen_w : Int = 1720

///|
let screen_h : Int = 980

///|
let target_fps : Int = 120

///|
let board_n : Int = 5

///|
let max_cells : Int = board_n * board_n

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
let target_tile : Int = 2048

///|
let blocker_value : Int = -1

///|
let panel_x0 : Int = 1060

///|
let panel_w : Int = screen_w - panel_x0 - 24

///|
fn board_area_x() -> Int {
  60
}

///|
fn board_area_y() -> Int {
  44
}

///|
fn board_area_w() -> Int {
  panel_x0 - board_area_x() - 24
}

///|
fn board_area_h() -> Int {
  screen_h - 88
}

///|
fn title_start_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 260, 620, 520, 118)
}

///|
fn retry_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, 658, 460, 108)
}

///|
fn btn_left() -> (Int, Int, Int, Int) {
  (1100, 704, 110, 96)
}

///|
fn btn_right() -> (Int, Int, Int, Int) {
  (1348, 704, 110, 96)
}

///|
fn btn_up() -> (Int, Int, Int, Int) {
  (1224, 590, 110, 96)
}

///|
fn btn_down() -> (Int, Int, Int, Int) {
  (1224, 818, 110, 96)
}

///|
fn btn_zap() -> (Int, Int, Int, Int) {
  (1476, 684, 188, 110)
}

///|
fn btn_undo() -> (Int, Int, Int, Int) {
  (1476, 808, 188, 92)
}

///|
fn btn_restart() -> (Int, Int, Int, Int) {
  (1476, 590, 188, 82)
}
