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
let room_rest : Int = 0

///|
let room_train : Int = 1

///|
let room_sparring : Int = 2

///|
let room_defense : Int = 3

///|
let room_count : Int = 4

///|
let student_count : Int = 6

///|
let start_funds : Float = 1650.0

///|
let start_reputation : Float = 62.0

///|
let week_duration_base : Float = 36.0

///|
let week_duration_drop : Float = 1.35

///|
let week_duration_min : Float = 18.0

///|
let week_upkeep_base : Float = 220.0

///|
let week_upkeep_growth : Float = 38.0

///|
let student_salary_weekly : Float = 52.0

///|
let operation_cost_per_sec : Float = 5.2

///|
let operation_cost_week_scale : Float = 1.6

///|
let reputation_passive_drain_per_sec : Float = 0.05

///|
let train_cost_per_sec : Float = 8.0

///|
let train_skill_gain_per_sec : Float = 2.9

///|
let train_fatigue_gain_per_sec : Float = 6.8

///|
let spar_income_per_sec : Float = 13.0

///|
let spar_rep_gain_per_sec : Float = 0.46

///|
let spar_fatigue_gain_per_sec : Float = 4.2

///|
let defense_stipend_per_sec : Float = 2.6

///|
let defense_stipend_week_scale : Float = 0.24

///|
let defense_fatigue_gain_per_sec : Float = 3.0

///|
let rest_fatigue_recover_per_sec : Float = 9.5

///|
let fatigue_max : Float = 100.0

///|
let fatigue_penalty_start : Float = 74.0

///|
let fatigue_rep_penalty_per_sec : Float = 0.12

///|
let burnout_threshold : Float = 99.0

///|
let weekly_recovery_bonus : Float = 11.0

///|
let incident_gap_base : Float = 12.5

///|
let incident_gap_drop : Float = 0.52

///|
let incident_gap_min : Float = 4.8

///|
let incident_gap_jitter : Float = 2.2

///|
let incident_severity_base : Float = 1.0

///|
let incident_severity_growth : Float = 0.23

///|
let burst_duration : Float = 2.2

///|
let burst_cooldown : Float = 9.0

///|
let burst_time_multiplier : Float = 3.5

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
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
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
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn week_duration_for(week : Int) -> Float {
  let raw = week_duration_base - Float::from_int(week - 1) * week_duration_drop
  maxf(week_duration_min, raw)
}

///|
fn upkeep_for(week : Int) -> Float {
  week_upkeep_base + Float::from_int(week - 1) * week_upkeep_growth
}

///|
fn incident_gap_for(week : Int) -> Float {
  let raw = incident_gap_base - Float::from_int(week - 1) * incident_gap_drop
  maxf(incident_gap_min, raw)
}

///|
fn incident_severity_for(week : Int) -> Float {
  incident_severity_base + Float::from_int(week - 1) * incident_severity_growth
}

///|
fn room_name(room : Int) -> String {
  if room == room_rest {
    "Rest"
  } else if room == room_train {
    "Train"
  } else if room == room_sparring {
    "Spar"
  } else {
    "Defense"
  }
}
