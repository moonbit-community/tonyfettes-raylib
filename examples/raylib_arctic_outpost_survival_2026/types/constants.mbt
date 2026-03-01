///|
pub let screen_w : Int = 1720

///|
pub let screen_h : Int = 980

///|
pub let target_fps : Int = 120

///|
pub let enemy_wolf : Int = 0

///|
pub let enemy_brute : Int = 1

///|
pub let enemy_shard : Int = 2

///|
pub let pickup_fuel : Int = 0

///|
pub let pickup_medkit : Int = 1

///|
pub let pickup_ammo : Int = 2

///|
pub let pickup_overdrive : Int = 3

///|
pub let bullet_normal : Int = 0

///|
pub let bullet_pierce : Int = 1

///|
pub let max_enemies : Int = 200

///|
pub let max_pickups : Int = 100

///|
pub let max_bullets : Int = 240

///|
pub let max_particles : Int = 1600

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
pub let player_r : Float = 22.0

///|
pub let core_r : Float = 72.0

///|
pub let survival_time_goal : Float = 200.0

///|
pub fn core_x() -> Float {
  Float::from_int(world_x0 + world_w / 2)
}

///|
pub fn core_y() -> Float {
  Float::from_int(world_y0 + world_h / 2 - 90)
}

///|
pub fn start_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 290, 620, 580, 122)
}

///|
pub fn retry_button_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 250, 648, 500, 110)
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
pub fn btn_fire() -> (Int, Int, Int, Int) {
  (1582, 706, 110, 124)
}

///|
pub fn btn_repair() -> (Int, Int, Int, Int) {
  (1582, 846, 110, 94)
}

///|
pub fn btn_hint() -> (Int, Int, Int, Int) {
  (1582, 606, 110, 92)
}

///|
pub fn btn_restart() -> (Int, Int, Int, Int) {
  (1462, 606, 110, 92)
}
