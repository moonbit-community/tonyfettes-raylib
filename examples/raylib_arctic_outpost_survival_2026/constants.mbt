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
let enemy_wolf : Int = 0

///|
let enemy_brute : Int = 1

///|
let enemy_shard : Int = 2

///|
let pickup_fuel : Int = 0

///|
let pickup_medkit : Int = 1

///|
let pickup_ammo : Int = 2

///|
let pickup_overdrive : Int = 3

///|
let bullet_normal : Int = 0

///|
let bullet_pierce : Int = 1

///|
let max_enemies : Int = 200

///|
let max_pickups : Int = 100

///|
let max_bullets : Int = 240

///|
let max_particles : Int = 1600

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
let player_r : Float = 22.0

///|
let core_r : Float = 72.0

///|
let survival_time_goal : Float = 200.0

///|
fn core_x() -> Float {
  Float::from_int(world_x0 + world_w / 2)
}

///|
fn core_y() -> Float {
  Float::from_int(world_y0 + world_h / 2 - 90)
}

///|
fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 290, 620, 580, 122)
}

///|
fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 250, 648, 500, 110)
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
fn btn_fire() -> (Int, Int, Int, Int) {
  (1582, 706, 110, 124)
}

///|
fn btn_repair() -> (Int, Int, Int, Int) {
  (1582, 846, 110, 94)
}

///|
fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 92)
}

///|
fn btn_restart() -> (Int, Int, Int, Int) {
  (1462, 606, 110, 92)
}
