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
let obstacle_rock : Int = 0

///|
let obstacle_log : Int = 1

///|
let obstacle_mine : Int = 2

///|
let pickup_coin : Int = 0

///|
let pickup_fuel : Int = 1

///|
let pickup_shield : Int = 2

///|
let pickup_repair : Int = 3

///|
let max_obstacles : Int = 120

///|
let max_pickups : Int = 80

///|
let max_particles : Int = 1400

///|
let world_x0 : Int = 24

///|
let world_y0 : Int = 20

///|
let world_w : Int = 1120

///|
let world_h : Int = 940

///|
let panel_x0 : Int = world_x0 + world_w + 24

///|
let panel_w : Int = screen_w - panel_x0 - 24

///|
let raft_r : Float = 26.0

///|
let run_time_goal : Float = 180.0

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
  (1230, 730, 104, 96)
}

///|
fn btn_right() -> (Int, Int, Int, Int) {
  (1460, 730, 104, 96)
}

///|
fn btn_up() -> (Int, Int, Int, Int) {
  (1345, 622, 104, 96)
}

///|
fn btn_down() -> (Int, Int, Int, Int) {
  (1345, 838, 104, 96)
}

///|
fn btn_boost() -> (Int, Int, Int, Int) {
  (1582, 708, 110, 124)
}

///|
fn btn_restart() -> (Int, Int, Int, Int) {
  (1582, 848, 110, 92)
}

///|
fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 92)
}
