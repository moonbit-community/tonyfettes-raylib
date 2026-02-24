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
let state_paused : Int = 2

///|
let state_result : Int = 3

///|
let hazard_debris : Int = 0

///|
let hazard_wave : Int = 1

///|
let max_hazards : Int = 96

///|
let max_rivals : Int = 4

///|
let river_x : Int = 56

///|
let river_y : Int = 56

///|
let river_w : Int = 1188

///|
let river_h : Int = 868

///|
let hud_x : Int = river_x + river_w + 24

///|
let hud_w : Int = screen_w - hud_x - 24

///|
let boat_y : Int = river_y + river_h - 138

///|
let lane_span_px : Float = 430.0

///|
let distance_to_px : Float = 0.34

///|
let visible_distance : Float = 2320.0

///|
let finish_distance : Float = 5200.0

///|
let checkpoint_gap : Float = 1040.0

///|
let checkpoint_count : Int = 4

///|
let beat_period : Float = 0.62

///|
let beat_perfect_window : Float = 0.08

///|
let beat_good_window : Float = 0.16

///|
let base_speed : Float = 132.0

///|
fn checkpoint_distance(index : Int) -> Float {
  checkpoint_gap * Float::from_int(index + 1)
}
