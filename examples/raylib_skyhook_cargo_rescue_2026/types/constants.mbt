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
pub let hazard_cloud : Int = 0

///|
pub let hazard_drone : Int = 1

///|
pub let hazard_ice : Int = 2

///|
pub let pickup_fuel : Int = 0

///|
pub let pickup_medkit : Int = 1

///|
pub let pickup_turbo : Int = 2

///|
pub let max_survivors : Int = 90

///|
pub let max_hazards : Int = 160

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
pub let heli_r : Float = 24.0

///|
pub let survivor_r : Float = 15.0

///|
pub let rescue_target : Int = 18

///|
pub let run_time_goal : Float = 210.0

///|
pub fn safe_zone_x() -> Int {
  world_x0 + world_w - 224
}

///|
pub fn safe_zone_y() -> Int {
  world_y0 + 42
}

///|
pub fn safe_zone_w() -> Int {
  184
}

///|
pub fn safe_zone_h() -> Int {
  142
}

///|
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 280, 620, 560, 122)
}

///|
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, 648, 480, 110)
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
  (1345, 624, 104, 96)
}

///|
pub fn btn_down() -> (Int, Int, Int, Int) {
  (1345, 836, 104, 96)
}

///|
pub fn btn_hook() -> (Int, Int, Int, Int) {
  (1582, 704, 110, 124)
}

///|
pub fn btn_boost() -> (Int, Int, Int, Int) {
  (1582, 842, 110, 98)
}

///|
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 90)
}

///|
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (1462, 606, 110, 90)
}

///|
pub fn btn_repair() -> (Int, Int, Int, Int) {
  (1462, 704, 110, 124)
}
