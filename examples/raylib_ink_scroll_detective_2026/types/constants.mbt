///|
pub let screen_w : Int = 1440

///|
pub let screen_h : Int = 900

///|
pub let target_fps : Int = 120

///|
pub let city_cols : Int = 10

///|
pub let city_rows : Int = 6

///|
pub let district_count : Int = city_cols * city_rows

///|
pub let city_origin_x_i : Int = 120

///|
pub let city_origin_y_i : Int = 148

///|
pub let cell_w_i : Int = 116

///|
pub let cell_h_i : Int = 102

///|
pub let suspect_count : Int = 4

///|
pub let chains_per_suspect : Int = 3

///|
pub let clue_steps_per_chain : Int = 2

///|
pub let clue_count : Int = suspect_count *
  chains_per_suspect *
  clue_steps_per_chain

///|
pub let max_incidents : Int = 8

///|
pub let trust_max : Float = 100.0

///|
pub let trust_decay_base : Float = 0.95

///|
pub let time_limit_s : Float = 210.0

///|
pub let incident_spawn_base : Float = 4.9

///|
pub let incident_spawn_floor : Float = 2.2

///|
pub let incident_timer_base : Float = 19.0

///|
pub let incident_timer_drop : Float = 2.9

///|
pub let focus_duration : Float = 1.7

///|
pub let focus_cooldown : Float = 7.0

///|
pub let score_clue : Int = 45

///|
pub let score_chain_complete : Int = 80

///|
pub let score_deduction_unlock : Int = 130

///|
pub let score_incident_resolve : Int = 180

///|
pub let score_wrong_accuse_penalty : Int = 95

///|
pub let evidence_per_clue : Int = 5

///|
pub let evidence_focus_bonus : Int = 3

///|
pub let deduction_chains_to_unlock : Int = 2

///|
pub let trust_gain_clue : Float = 0.9

///|
pub let trust_gain_chain : Float = 1.8

///|
pub let trust_gain_deduction : Float = 4.2

///|
pub let trust_gain_resolve : Float = 5.4

///|
pub let trust_penalty_missed_incident : Float = 7.8

///|
pub let trust_penalty_wrong_accuse : Float = 12.0

///|
pub let tau : Float = 6.28318530718
