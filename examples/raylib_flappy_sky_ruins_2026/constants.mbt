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
let player_r : Float = 24.0

///|
let gravity : Float = 1220.0

///|
let flap_impulse : Float = -420.0

///|
let max_obs : Int = 72

///|
let max_pickups : Int = 64

///|
let max_particles : Int = 1300

///|
let obstacle_kind_gate : Int = 0

///|
let obstacle_kind_beam : Int = 1

///|
let obstacle_kind_spinner : Int = 2

///|
let pickup_score : Int = 0

///|
let pickup_boost : Int = 1

///|
let pickup_shield : Int = 2

///|
let pickup_heart : Int = 3

///|
let panel_x0 : Int = 1180

///|
let panel_w : Int = screen_w - panel_x0 - 24

///|
let world_x0 : Int = 24

///|
let world_y0 : Int = 20

///|
let world_w : Int = panel_x0 - world_x0 - 24

///|
let world_h : Int = screen_h - 40

///|
fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 260, 620, 520, 118)
}

///|
fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 230, 652, 460, 108)
}

///|
fn btn_flap_rect() -> (Int, Int, Int, Int) {
  (1250, 730, 188, 126)
}

///|
fn btn_boost_rect() -> (Int, Int, Int, Int) {
  (1454, 730, 188, 126)
}

///|
fn btn_restart_rect() -> (Int, Int, Int, Int) {
  (1454, 876, 188, 74)
}

///|
fn btn_hint_rect() -> (Int, Int, Int, Int) {
  (1250, 876, 188, 74)
}
