///|
pub let screen_w : Int = 1720

///|
pub let screen_h : Int = 980

///|
pub let target_fps : Int = 120

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_result : Int = 2

///|
pub let obstacle_rock : Int = 0

///|
pub let obstacle_log : Int = 1

///|
pub let obstacle_mine : Int = 2

///|
pub let pickup_coin : Int = 0

///|
pub let pickup_fuel : Int = 1

///|
pub let pickup_shield : Int = 2

///|
pub let pickup_repair : Int = 3

///|
pub let max_obstacles : Int = 120

///|
pub let max_pickups : Int = 80

///|
pub let max_particles : Int = 1400

///|
pub let world_x0 : Int = 24

///|
pub let world_y0 : Int = 20

///|
pub let world_w : Int = 1120

///|
pub let world_h : Int = 940

///|
pub let panel_x0 : Int = world_x0 + world_w + 24

///|
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
pub let raft_r : Float = 26.0

///|
pub let run_time_goal : Float = 180.0

///|
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 260, 620, 520, 118)
}

///|
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, 652, 460, 108)
}

///|
pub fn btn_left() -> (Int, Int, Int, Int) {
  (1230, 730, 104, 96)
}

///|
pub fn btn_right() -> (Int, Int, Int, Int) {
  (1460, 730, 104, 96)
}

///|
pub fn btn_up() -> (Int, Int, Int, Int) {
  (1345, 622, 104, 96)
}

///|
pub fn btn_down() -> (Int, Int, Int, Int) {
  (1345, 838, 104, 96)
}

///|
pub fn btn_boost() -> (Int, Int, Int, Int) {
  (1582, 708, 110, 124)
}

///|
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (1582, 848, 110, 92)
}

///|
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 92)
}
