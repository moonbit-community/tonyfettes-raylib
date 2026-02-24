///|
let screen_w : Int = 1600

///|
let screen_h : Int = 960

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_playing : Int = 1

///|
let state_paused : Int = 2

///|
let state_game_over : Int = 3

///|
let threat_firecracker : Int = 0

///|
let threat_incident : Int = 1

///|
let action_strike : Int = 0

///|
let action_guard : Int = 1

///|
let action_burst : Int = 2

///|
let lane_count : Int = 6

///|
let lane_top : Int = 170

///|
let lane_gap : Int = 108

///|
let lane_height : Int = 70

///|
let street_left : Int = 120

///|
let street_right : Int = 1480

///|
let troupe_w : Float = 96.0

///|
let troupe_move_speed : Float = 620.0

///|
let troupe_start_lane : Int = 2

///|
let max_threats : Int = 96

///|
let spawn_time_start : Float = 1.00

///|
let spawn_time_floor : Float = 0.24

///|
let spawn_difficulty_ramp : Float = 0.010

///|
let firecracker_speed_base : Float = 350.0

///|
let incident_speed_base : Float = 260.0

///|
let speed_scale_max_bonus : Float = 240.0

///|
let strike_radius : Float = 132.0

///|
let strike_cd_time : Float = 0.24

///|
let strike_fx_time : Float = 0.15

///|
let guard_radius : Float = 150.0

///|
let guard_cd_time : Float = 0.72

///|
let guard_hold_time : Float = 0.40

///|
let guard_stun_time : Float = 1.80

///|
let burst_cost : Float = 62.0

///|
let burst_duration : Float = 0.92

///|
let burst_radius : Float = 320.0

///|
let burst_cd_time : Float = 6.2

///|
let hype_max : Float = 100.0

///|
let morale_max : Float = 100.0

///|
let order_max : Float = 100.0

///|
let morale_start : Float = 82.0

///|
let order_start : Float = 84.0

///|
let combo_keep_time : Float = 2.6

///|
let order_gain_on_clear : Float = 2.0

///|
let order_recover_rate : Float = 2.2

///|
let order_pressure_threshold : Float = 42.0

///|
let order_pressure_drain_rate : Float = 0.29

///|
let breach_order_loss_firecracker : Float = 11.0

///|
let breach_order_loss_incident : Float = 16.0

///|
let breach_morale_loss_firecracker : Float = 7.0

///|
let breach_morale_loss_incident : Float = 10.0

///|
let collision_morale_loss_firecracker : Float = 8.0

///|
let collision_morale_loss_incident : Float = 11.0

///|
let score_firecracker : Int = 120

///|
let score_incident : Int = 170

///|
let score_guard_stun : Int = 24

///|
let hype_gain_firecracker : Float = 8.0

///|
let hype_gain_incident : Float = 12.0

///|
let hype_gain_guard_stun : Float = 4.0

///|
let hype_gain_combo_step : Float = 1.6

///|
let msg_ttl : Float = 1.6

///|
fn street_w() -> Int {
  street_right - street_left
}

///|
fn street_h() -> Int {
  (lane_count - 1) * lane_gap + lane_height
}

///|
fn lane_y(lane : Int) -> Float {
  Float::from_int(lane_top + lane * lane_gap + lane_height / 2)
}

///|
fn lane_from_y(y : Float) -> Int {
  let raw = ((y - Float::from_int(lane_top)) / Float::from_int(lane_gap)).to_int()
  clampi(raw, 0, lane_count - 1)
}

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
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn squaref(v : Float) -> Float {
  v * v
}
