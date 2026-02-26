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
let fish_trout : Int = 0

///|
let fish_salmon : Int = 1

///|
let fish_gold : Int = 2

///|
let hazard_jelly : Int = 0

///|
let hazard_eel : Int = 1

///|
let hazard_ice : Int = 2

///|
let pickup_bait : Int = 0

///|
let pickup_repair : Int = 1

///|
let pickup_thermos : Int = 2

///|
let max_fish : Int = 180

///|
let max_hazards : Int = 120

///|
let max_pickups : Int = 80

///|
let max_particles : Int = 1500

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
let water_top : Int = world_y0 + 170

///|
let water_bottom : Int = world_y0 + world_h - 14

///|
let hole_x : Int = world_x0 + world_w / 2

///|
let hole_y : Int = water_top - 24

///|
let hook_r : Float = 13.0

///|
let run_time_goal : Float = 200.0

///|
let score_goal : Int = 1600

///|
let max_line_len : Float = 760.0

///|
let min_line_len : Float = 60.0

///|
fn catch_zone_x() -> Int {
  hole_x - 120
}

///|
fn catch_zone_y() -> Int {
  water_top - 54
}

///|
fn catch_zone_w() -> Int {
  240
}

///|
fn catch_zone_h() -> Int {
  76
}

///|
fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 280, 620, 560, 122)
}

///|
fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 240, 648, 480, 110)
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
  (1345, 624, 104, 96)
}

///|
fn btn_down() -> (Int, Int, Int, Int) {
  (1345, 836, 104, 96)
}

///|
fn btn_hook() -> (Int, Int, Int, Int) {
  (1582, 704, 110, 124)
}

///|
fn btn_boost() -> (Int, Int, Int, Int) {
  (1582, 842, 110, 98)
}

///|
fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 90)
}

///|
fn btn_restart() -> (Int, Int, Int, Int) {
  (1462, 606, 110, 90)
}

///|
fn btn_repair() -> (Int, Int, Int, Int) {
  (1462, 704, 110, 124)
}
