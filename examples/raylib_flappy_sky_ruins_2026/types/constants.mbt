///|
pub let screen_w : Int = 1720

///|
pub let screen_h : Int = 980

///|
pub let target_fps : Int = 120

///|
pub let player_r : Float = 24.0

///|
pub let gravity : Float = 1220.0

///|
pub let flap_impulse : Float = -420.0

///|
pub let max_obs : Int = 72

///|
pub let max_pickups : Int = 64

///|
pub let max_particles : Int = 1300

///|
pub let obstacle_kind_gate : Int = 0

///|
pub let obstacle_kind_beam : Int = 1

///|
pub let obstacle_kind_spinner : Int = 2

///|
pub let pickup_score : Int = 0

///|
pub let pickup_boost : Int = 1

///|
pub let pickup_shield : Int = 2

///|
pub let pickup_heart : Int = 3

///|
pub let panel_x0 : Int = 1180

///|
pub let panel_w : Int = screen_w - panel_x0 - 24

///|
pub let world_x0 : Int = 24

///|
pub let world_y0 : Int = 20

///|
pub let world_w : Int = panel_x0 - world_x0 - 24

///|
pub let world_h : Int = screen_h - 40

///|
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 260, 620, 520, 118)
}

///|
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, 652, 460, 108)
}

///|
pub fn btn_flap_rect() -> (Int, Int, Int, Int) {
  (1250, 730, 188, 126)
}

///|
pub fn btn_boost_rect() -> (Int, Int, Int, Int) {
  (1454, 730, 188, 126)
}

///|
pub fn btn_restart_rect() -> (Int, Int, Int, Int) {
  (1454, 876, 188, 74)
}

///|
pub fn btn_hint_rect() -> (Int, Int, Int, Int) {
  (1250, 876, 188, 74)
}
