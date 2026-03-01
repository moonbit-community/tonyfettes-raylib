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
pub let traffic_sedan : Int = 0

///|
pub let traffic_bus : Int = 1

///|
pub let traffic_van : Int = 2

///|
pub let pickup_fuel : Int = 0

///|
pub let pickup_repair : Int = 1

///|
pub let pickup_speed : Int = 2

///|
pub let max_traffic : Int = 220

///|
pub let max_orders : Int = 90

///|
pub let max_pickups : Int = 80

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
pub let road_step : Int = 112

///|
pub let rider_r : Float = 20.0

///|
pub let run_time_goal : Float = 210.0

///|
pub let score_goal : Int = 2200

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
pub fn btn_boost() -> (Int, Int, Int, Int) {
  (1582, 704, 110, 124)
}

///|
pub fn btn_action() -> (Int, Int, Int, Int) {
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
pub fn restaurant_x(i : Int) -> Float {
  if i == 0 {
    Float::from_int(world_x0 + 120)
  } else if i == 1 {
    Float::from_int(world_x0 + world_w / 2)
  } else {
    Float::from_int(world_x0 + world_w - 140)
  }
}

///|
pub fn restaurant_y(i : Int) -> Float {
  if i == 0 {
    Float::from_int(world_y0 + 136)
  } else if i == 1 {
    Float::from_int(world_y0 + world_h - 180)
  } else {
    Float::from_int(world_y0 + 300)
  }
}

///|
pub fn depot_x() -> Float {
  Float::from_int(world_x0 + world_w - 120)
}

///|
pub fn depot_y() -> Float {
  Float::from_int(world_y0 + 100)
}

///|
pub fn depot_w() -> Int {
  160
}

///|
pub fn depot_h() -> Int {
  120
}
