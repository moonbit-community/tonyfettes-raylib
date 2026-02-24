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
let stance_spear : Int = 0

///|
let stance_fan : Int = 1

///|
let stance_guard : Int = 2

///|
let stance_sleeve : Int = 3

///|
let stance_count : Int = 4

///|
let lane_axis_min : Int = -1

///|
let lane_axis_max : Int = 1

///|
let duel_duration : Float = 90.0

///|
let prompt_lead_time : Float = 1.18

///|
let beat_start_interval : Float = 1.02

///|
let beat_min_interval : Float = 0.54

///|
let beat_accel_per_sec : Float = 0.0042

///|
let timing_perfect : Float = 0.07

///|
let timing_good : Float = 0.15

///|
let timing_deflect : Float = 0.20

///|
let timing_miss : Float = 0.28

///|
let health_max : Float = 100.0

///|
let harmony_max : Float = 100.0

///|
let health_drain_per_sec : Float = 0.34

///|
let harmony_drain_per_sec : Float = 0.48

///|
let offbeat_harmony_penalty : Float = 4.5

///|
let miss_health_penalty : Float = 8.5

///|
let miss_harmony_penalty : Float = 12.0

///|
let mismatch_harmony_extra : Float = 3.0

///|
let deflect_harmony_penalty : Float = 4.2

///|
let deflect_acclaim_gain : Int = 8

///|
let good_acclaim_gain : Int = 22

///|
let perfect_acclaim_gain : Int = 32

///|
let combo_acclaim_step : Int = 3

///|
let hit_health_recover : Float = 1.6

///|
let hit_harmony_recover : Float = 2.2

///|
let burst_duration : Float = 1.7

///|
let burst_cooldown : Float = 8.0

///|
let burst_slow_factor : Float = 0.46

///|
fn stance_name(stance : Int) -> String {
  if stance == stance_spear {
    "Spear Lift"
  } else if stance == stance_fan {
    "Fan Sweep"
  } else if stance == stance_guard {
    "Guard Frame"
  } else {
    "Sleeve Arc"
  }
}
