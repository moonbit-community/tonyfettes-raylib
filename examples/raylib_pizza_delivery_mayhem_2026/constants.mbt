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
let traffic_sedan : Int = 0

///|
let traffic_bus : Int = 1

///|
let traffic_van : Int = 2

///|
let pickup_fuel : Int = 0

///|
let pickup_repair : Int = 1

///|
let pickup_speed : Int = 2

///|
let max_traffic : Int = 220

///|
let max_orders : Int = 90

///|
let max_pickups : Int = 80

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
let road_step : Int = 112

///|
let rider_r : Float = 20.0

///|
let run_time_goal : Float = 210.0

///|
let score_goal : Int = 2200

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
fn btn_boost() -> (Int, Int, Int, Int) {
  (1582, 704, 110, 124)
}

///|
fn btn_action() -> (Int, Int, Int, Int) {
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
fn restaurant_x(i : Int) -> Float {
  if i == 0 {
    Float::from_int(world_x0 + 120)
  } else if i == 1 {
    Float::from_int(world_x0 + world_w / 2)
  } else {
    Float::from_int(world_x0 + world_w - 140)
  }
}

///|
fn restaurant_y(i : Int) -> Float {
  if i == 0 {
    Float::from_int(world_y0 + 136)
  } else if i == 1 {
    Float::from_int(world_y0 + world_h - 180)
  } else {
    Float::from_int(world_y0 + 300)
  }
}

///|
fn depot_x() -> Float {
  Float::from_int(world_x0 + world_w - 120)
}

///|
fn depot_y() -> Float {
  Float::from_int(world_y0 + 100)
}

///|
fn depot_w() -> Int {
  160
}

///|
fn depot_h() -> Int {
  120
}
