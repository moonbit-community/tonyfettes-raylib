///|
let screen_w : Int = 1720

///|
let screen_h : Int = 980

///|
let target_fps : Int = 120

///|
let board_w : Int = 24

///|
let board_h : Int = 14

///|
let max_cells : Int = board_w * board_h

///|
let mine_count_default : Int = 58

///|
let lives_default : Int = 3

///|
let hints_default : Int = 3

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_result : Int = 2

///|
let mode_reveal : Int = 0

///|
let mode_flag : Int = 1

///|
let grade_s : Int = 0

///|
let grade_a : Int = 1

///|
let grade_b : Int = 2

///|
let grade_c : Int = 3

///|
let grade_d : Int = 4

///|
fn panel_x() -> Int {
  1168
}

///|
fn board_area_x() -> Int {
  44
}

///|
fn board_area_y() -> Int {
  32
}

///|
fn board_area_w() -> Int {
  panel_x() - board_area_x() - 24
}

///|
fn board_area_h() -> Int {
  screen_h - 64
}

///|
fn title_start_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 250, 600, 500, 120)
}

///|
fn result_retry_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, 650, 460, 108)
}

///|
fn touch_mode_button() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 252, 190, 90)
}

///|
fn touch_hint_button() -> (Int, Int, Int, Int) {
  (panel_x() + 228, screen_h - 252, 170, 90)
}

///|
fn touch_reset_button() -> (Int, Int, Int, Int) {
  (panel_x() + 410, screen_h - 252, 190, 90)
}

///|
fn touch_reveal_button() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 148, 576, 96)
}
