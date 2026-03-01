///|
pub let screen_w : Int = 1720

///|
pub let screen_h : Int = 980

///|
pub let target_fps : Int = 120

///|
pub let hazard_debris : Int = 0

///|
pub let hazard_wave : Int = 1

///|
pub let max_hazards : Int = 96

///|
pub let max_rivals : Int = 4

///|
pub let river_x : Int = 56

///|
pub let river_y : Int = 56

///|
pub let river_w : Int = 1188

///|
pub let river_h : Int = 868

///|
pub let hud_x : Int = river_x + river_w + 24

///|
pub let hud_w : Int = screen_w - hud_x - 24

///|
pub let boat_y : Int = river_y + river_h - 138

///|
pub let lane_span_px : Float = 430.0

///|
pub let distance_to_px : Float = 0.34

///|
pub let visible_distance : Float = 2320.0

///|
pub let finish_distance : Float = 5200.0

///|
pub let checkpoint_gap : Float = 1040.0

///|
pub let checkpoint_count : Int = 4

///|
pub let beat_period : Float = 0.62

///|
pub let beat_perfect_window : Float = 0.08

///|
pub let beat_good_window : Float = 0.16

///|
pub let base_speed : Float = 132.0

///|
pub fn checkpoint_distance(index : Int) -> Float {
  checkpoint_gap * Float::from_int(index + 1)
}
