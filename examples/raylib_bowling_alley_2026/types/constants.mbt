///|
pub let screen_w : Int = 1720

///|
pub let screen_h : Int = 980

///|
pub let target_fps : Int = 120

///|
pub let lane_x : Int = 90

///|
pub let lane_y : Int = 40

///|
pub let lane_w : Int = 970

///|
pub let lane_h : Int = 900

///|
pub let lane_left : Float = Float::from_int(lane_x)

///|
pub let lane_top : Float = Float::from_int(lane_y)

///|
pub let lane_right : Float = Float::from_int(lane_x + lane_w)

///|
pub let lane_bottom : Float = Float::from_int(lane_y + lane_h)

///|
pub let foul_line_y : Float = lane_bottom - 146.0

///|
pub let pin_deck_y : Float = lane_top + 148.0

///|
pub let pin_row_gap : Float = 44.0

///|
pub let pin_col_gap : Float = 41.0

///|
pub let pin_radius : Float = 13.0

///|
pub let ball_radius : Float = 18.0

///|
pub let ball_start_x : Float = Float::from_int(lane_x + lane_w / 2)

///|
pub let ball_start_y : Float = lane_bottom - 58.0

///|
pub let aim_min : Float = -36.0

///|
pub let aim_max : Float = 36.0

///|
pub let spin_min : Float = -1.0

///|
pub let spin_max : Float = 1.0

///|
pub let max_rolls : Int = 24

///|
pub let max_sparks : Int = 1200

///|
pub let panel_x0 : Int = lane_x + lane_w + 24

///|
pub let panel_w : Int = screen_w - panel_x0 - 28

///|
pub fn panel_rect() -> (Int, Int, Int, Int) {
  (panel_x0, 20, panel_w, screen_h - 40)
}

///|
pub fn title_start_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, 600, 480, 116)
}

///|
pub fn retry_button() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, 650, 440, 104)
}

///|
pub fn touch_aim_left_rect() -> (Int, Int, Int, Int) {
  (72, screen_h - 170, 128, 96)
}

///|
pub fn touch_aim_right_rect() -> (Int, Int, Int, Int) {
  (216, screen_h - 170, 128, 96)
}

///|
pub fn touch_spin_left_rect() -> (Int, Int, Int, Int) {
  (370, screen_h - 170, 128, 96)
}

///|
pub fn touch_spin_right_rect() -> (Int, Int, Int, Int) {
  (514, screen_h - 170, 128, 96)
}

///|
pub fn touch_power_rect() -> (Int, Int, Int, Int) {
  (screen_w - 316, screen_h - 212, 252, 150)
}
