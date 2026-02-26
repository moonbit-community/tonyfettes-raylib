///|
let screen_w : Int = 1600

///|
let screen_h : Int = 960

///|
let target_fps : Int = 120

///|
let state_title : Int = 0

///|
let state_play : Int = 1

///|
let state_paused : Int = 2

///|
let state_result : Int = 3

///|
let pose_axis_min : Int = -2

///|
let pose_axis_max : Int = 2

///|
let max_sequence_len : Int = 8

///|
let spotlight_max : Float = 100.0

///|
let spotlight_start : Float = 78.0

///|
let excitement_max : Float = 100.0

///|
let cue_base_time : Float = 3.25

///|
let cue_drop_per_stage : Float = 0.11

///|
let cue_min_time : Float = 1.05

///|
let combo_hold_time : Float = 2.4

///|
let burst_duration : Float = 1.8

///|
let burst_cooldown : Float = 9.0

///|
let burst_slow_factor : Float = 0.46

///|
let spotlight_drain : Float = 2.55

///|
let excitement_drain : Float = 3.15

///|
let mistake_spotlight_loss : Float = 18.0

///|
let timeout_spotlight_loss : Float = 24.0

///|
let mistake_excitement_loss : Float = 15.0

///|
let correct_spotlight_gain : Float = 3.6

///|
let correct_excitement_gain : Float = 8.0

///|
fn cue_time_for_stage(stage : Int) -> Float {
  let raw = cue_base_time - Float::from_int(stage - 1) * cue_drop_per_stage
  if raw < cue_min_time {
    cue_min_time
  } else {
    raw
  }
}

///|
fn sequence_len_for_stage(stage : Int) -> Int {
  let raw = 3 + (stage - 1) / 2
  if raw > max_sequence_len {
    max_sequence_len
  } else {
    raw
  }
}
