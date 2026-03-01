///|
pub let screen_w : Int = 1720

///|
pub let screen_h : Int = 980

///|
pub let target_fps : Int = 120

///|
pub let board_w : Int = 24

///|
pub let board_h : Int = 14

///|
pub let max_cells : Int = board_w * board_h

///|
pub let mine_count_default : Int = 58

///|
pub let lives_default : Int = 3

///|
pub let hints_default : Int = 3

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_result : Int = 2

///|
pub let mode_reveal : Int = 0

///|
pub let mode_flag : Int = 1

///|
pub let grade_s : Int = 0

///|
pub let grade_a : Int = 1

///|
pub let grade_b : Int = 2

///|
pub let grade_c : Int = 3

///|
pub let grade_d : Int = 4

///|
pub fn panel_x() -> Int {
  1168
}

///|
pub fn board_area_x() -> Int {
  44
}

///|
pub fn board_area_y() -> Int {
  32
}

///|
pub fn board_area_w() -> Int {
  panel_x() - board_area_x() - 24
}

///|
pub fn board_area_h() -> Int {
  screen_h - 64
}

///|
pub fn title_start_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 250, 600, 500, 120)
}

///|
pub fn result_retry_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, 650, 460, 108)
}

///|
pub fn touch_mode_button() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 252, 190, 90)
}

///|
pub fn touch_hint_button() -> (Int, Int, Int, Int) {
  (panel_x() + 228, screen_h - 252, 170, 90)
}

///|
pub fn touch_reset_button() -> (Int, Int, Int, Int) {
  (panel_x() + 410, screen_h - 252, 190, 90)
}

///|
pub fn touch_reveal_button() -> (Int, Int, Int, Int) {
  (panel_x() + 24, screen_h - 148, 576, 96)
}
