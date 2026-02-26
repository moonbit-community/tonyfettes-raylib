///|
let screen_w : Int = 1720

///|
let screen_h : Int = 980

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_result : Int = 2

///|
let lane_x : Int = 90

///|
let lane_y : Int = 40

///|
let lane_w : Int = 970

///|
let lane_h : Int = 900

///|
let lane_left : Float = Float::from_int(lane_x)

///|
let lane_top : Float = Float::from_int(lane_y)

///|
let lane_right : Float = Float::from_int(lane_x + lane_w)

///|
let lane_bottom : Float = Float::from_int(lane_y + lane_h)

///|
let foul_line_y : Float = lane_bottom - 146.0

///|
let pin_deck_y : Float = lane_top + 148.0

///|
let pin_row_gap : Float = 44.0

///|
let pin_col_gap : Float = 41.0

///|
let pin_radius : Float = 13.0

///|
let ball_radius : Float = 18.0

///|
let ball_start_x : Float = Float::from_int(lane_x + lane_w / 2)

///|
let ball_start_y : Float = lane_bottom - 58.0

///|
let aim_min : Float = -36.0

///|
let aim_max : Float = 36.0

///|
let spin_min : Float = -1.0

///|
let spin_max : Float = 1.0

///|
let max_rolls : Int = 24

///|
let max_sparks : Int = 1200

///|
let panel_x0 : Int = lane_x + lane_w + 24

///|
let panel_w : Int = screen_w - panel_x0 - 28

///|
fn panel_rect() -> (Int, Int, Int, Int) {
  (panel_x0, 20, panel_w, screen_h - 40)
}

///|
fn title_start_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, 600, 480, 116)
}

///|
fn retry_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, 650, 440, 104)
}

///|
fn touch_aim_left_rect() -> (Int, Int, Int, Int) {
  (72, screen_h - 170, 128, 96)
}

///|
fn touch_aim_right_rect() -> (Int, Int, Int, Int) {
  (216, screen_h - 170, 128, 96)
}

///|
fn touch_spin_left_rect() -> (Int, Int, Int, Int) {
  (370, screen_h - 170, 128, 96)
}

///|
fn touch_spin_right_rect() -> (Int, Int, Int, Int) {
  (514, screen_h - 170, 128, 96)
}

///|
fn touch_power_rect() -> (Int, Int, Int, Int) {
  (screen_w - 316, screen_h - 212, 252, 150)
}
