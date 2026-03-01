///|
pub let screen_w : Int = 1600

///|
pub let screen_h : Int = 960

///|
pub let target_fps : Int = 120

///|
pub let pose_axis_min : Int = -2

///|
pub let pose_axis_max : Int = 2

///|
pub let max_sequence_len : Int = 8

///|
pub let spotlight_max : Float = 100.0

///|
pub let spotlight_start : Float = 78.0

///|
pub let excitement_max : Float = 100.0

///|
pub let cue_base_time : Float = 3.25

///|
pub let cue_drop_per_stage : Float = 0.11

///|
pub let cue_min_time : Float = 1.05

///|
pub let combo_hold_time : Float = 2.4

///|
pub let burst_duration : Float = 1.8

///|
pub let burst_cooldown : Float = 9.0

///|
pub let burst_slow_factor : Float = 0.46

///|
pub let spotlight_drain : Float = 2.55

///|
pub let excitement_drain : Float = 3.15

///|
pub let mistake_spotlight_loss : Float = 18.0

///|
pub let timeout_spotlight_loss : Float = 24.0

///|
pub let mistake_excitement_loss : Float = 15.0

///|
pub let correct_spotlight_gain : Float = 3.6

///|
pub let correct_excitement_gain : Float = 8.0

///|
pub let stage_screen_x : Int = 248

///|
pub let stage_screen_y : Int = 126

///|
pub let stage_screen_w : Int = 980

///|
pub let stage_screen_h : Int = 682

///|
pub fn cue_time_for_stage(stage : Int) -> Float {
  let raw = cue_base_time - Float::from_int(stage - 1) * cue_drop_per_stage
  if raw < cue_min_time {
    cue_min_time
  } else {
    raw
  }
}

///|
pub fn sequence_len_for_stage(stage : Int) -> Int {
  let raw = 3 + (stage - 1) / 2
  if raw > max_sequence_len {
    max_sequence_len
  } else {
    raw
  }
}
