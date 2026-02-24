///|
let screen_w : Int = 1440

///|
let screen_h : Int = 900

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
let city_cols : Int = 10

///|
let city_rows : Int = 6

///|
let district_count : Int = city_cols * city_rows

///|
let city_origin_x_i : Int = 120

///|
let city_origin_y_i : Int = 148

///|
let cell_w_i : Int = 116

///|
let cell_h_i : Int = 102

///|
let suspect_count : Int = 4

///|
let chains_per_suspect : Int = 3

///|
let clue_steps_per_chain : Int = 2

///|
let clue_count : Int = suspect_count * chains_per_suspect * clue_steps_per_chain

///|
let max_incidents : Int = 8

///|
let trust_max : Float = 100.0

///|
let trust_decay_base : Float = 0.95

///|
let time_limit_s : Float = 210.0

///|
let incident_spawn_base : Float = 4.9

///|
let incident_spawn_floor : Float = 2.2

///|
let incident_timer_base : Float = 19.0

///|
let incident_timer_drop : Float = 2.9

///|
let focus_duration : Float = 1.7

///|
let focus_cooldown : Float = 7.0

///|
let score_clue : Int = 45

///|
let score_chain_complete : Int = 80

///|
let score_deduction_unlock : Int = 130

///|
let score_incident_resolve : Int = 180

///|
let score_wrong_accuse_penalty : Int = 95

///|
let evidence_per_clue : Int = 5

///|
let evidence_focus_bonus : Int = 3

///|
let deduction_chains_to_unlock : Int = 2

///|
let trust_gain_clue : Float = 0.9

///|
let trust_gain_chain : Float = 1.8

///|
let trust_gain_deduction : Float = 4.2

///|
let trust_gain_resolve : Float = 5.4

///|
let trust_penalty_missed_incident : Float = 7.8

///|
let trust_penalty_wrong_accuse : Float = 12.0

///|
let tau : Float = 6.28318530718

///|
fn city_w_i() -> Int {
  city_cols * cell_w_i
}

///|
fn city_h_i() -> Int {
  city_rows * cell_h_i
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
fn maxi(a : Int, b : Int) -> Int {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn clamp01(v : Float) -> Float {
  clampf(v, 0.0, 1.0)
}

///|
fn sinf(v : Float) -> Float {
  Float::from_double(@math.sin(v.to_double()))
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let n = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * n
}

///|
fn randi(lo : Int, hi : Int) -> Int {
  @raylib.get_random_value(lo, hi)
}

///|
fn cell_index(cell_x : Int, cell_y : Int) -> Int {
  cell_y * city_cols + cell_x
}

///|
fn cell_left_i(cell_x : Int) -> Int {
  city_origin_x_i + cell_x * cell_w_i
}

///|
fn cell_top_i(cell_y : Int) -> Int {
  city_origin_y_i + cell_y * cell_h_i
}

///|
fn cell_center_x(cell_x : Int) -> Float {
  Float::from_int(cell_left_i(cell_x) + cell_w_i / 2)
}

///|
fn cell_center_y(cell_y : Int) -> Float {
  Float::from_int(cell_top_i(cell_y) + cell_h_i / 2)
}

///|
fn chain_slot(suspect : Int, chain : Int) -> Int {
  suspect * chains_per_suspect + chain
}

///|
fn incident_need_score(severity : Int) -> Int {
  10 + severity * 8
}

///|
fn incident_timer_for_severity(severity : Int) -> Float {
  incident_timer_base - Float::from_int(severity - 1) * incident_timer_drop
}
