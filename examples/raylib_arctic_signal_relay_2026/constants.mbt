///|
let screen_w : Int = 1440

///|
let screen_h : Int = 900

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_result : Int = 2

///|
let world_x0 : Int = 24

///|
let world_y0 : Int = 24

///|
let world_w : Int = 980

///|
let world_h : Int = 852

///|
let panel_x0 : Int = world_x0 + world_w + 20

///|
let panel_w : Int = screen_w - panel_x0 - 24

///|
let max_towers : Int = 6

///|
let max_storms : Int = 5

///|
let rover_r : Float = 22.0

///|
let rover_accel : Float = 760.0

///|
let rover_drag : Float = 5.0

///|
let rover_max_speed : Float = 280.0

///|
let rover_wind_force : Float = 180.0

///|
let storm_control_penalty : Float = 0.45

///|
let cargo_capacity : Int = 3

///|
let energy_max : Float = 100.0

///|
let heat_max : Float = 100.0

///|
let energy_idle_drain : Float = 1.6

///|
let energy_move_drain : Float = 0.008

///|
let energy_storm_drain : Float = 7.4

///|
let energy_recharge_rate : Float = 29.0

///|
let heat_idle_drain : Float = 2.0

///|
let heat_storm_drain : Float = 10.8

///|
let heat_recharge_rate : Float = 34.0

///|
let timer_base : Float = 92.0

///|
let timer_floor : Float = 48.0

///|
let timer_step : Float = 5.0

///|
let tower_online_bonus_base : Float = 3.0

///|
let tower_online_bonus_step : Float = 0.9

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn cosf(v : Float) -> Float {
  Float::from_double(@math.cos(v.to_double()))
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
}

///|
fn world_left() -> Float {
  Float::from_int(world_x0)
}

///|
fn world_right() -> Float {
  Float::from_int(world_x0 + world_w)
}

///|
fn world_top() -> Float {
  Float::from_int(world_y0)
}

///|
fn world_bottom() -> Float {
  Float::from_int(world_y0 + world_h)
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx = x1 - x0
  let dy = y1 - y0
  dx * dx + dy * dy
}

///|
fn depot_x() -> Float {
  Float::from_int(world_x0 + 132)
}

///|
fn depot_y() -> Float {
  Float::from_int(world_y0 + world_h - 126)
}

///|
fn depot_r() -> Float {
  70.0
}

///|
fn tower_hit_r() -> Float {
  30.0
}

///|
fn tower_interact_r() -> Float {
  66.0
}

///|
fn title_start_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 220, screen_h / 2 + 128, 440, 92)
}

///|
fn result_primary_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 236, screen_h / 2 + 116, 472, 88)
}

///|
fn result_secondary_rect() -> (Int, Int, Int, Int) {
  (screen_w / 2 - 236, screen_h / 2 + 224, 472, 74)
}

///|
fn touch_left_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 24, screen_h - 190, 76, 76)
}

///|
fn touch_right_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 184, screen_h - 190, 76, 76)
}

///|
fn touch_up_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 104, screen_h - 270, 76, 76)
}

///|
fn touch_down_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + 104, screen_h - 110, 76, 76)
}

///|
fn touch_action_rect() -> (Int, Int, Int, Int) {
  (panel_x0 + panel_w - 128, screen_h - 228, 104, 104)
}

///|
fn point_in_rect(
  x : Float,
  y : Float,
  rx : Int,
  ry : Int,
  rw : Int,
  rh : Int,
) -> Bool {
  let fx0 = Float::from_int(rx)
  let fy0 = Float::from_int(ry)
  let fx1 = Float::from_int(rx + rw)
  let fy1 = Float::from_int(ry + rh)
  x >= fx0 && x <= fx1 && y >= fy0 && y <= fy1
}
