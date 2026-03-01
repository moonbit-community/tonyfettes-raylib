///|
pub let screen_w : Int = 1280

///|
pub let screen_h : Int = 720

///|
pub let target_fps : Int = 120

///|
pub let arena_x0 : Int = 78

///|
pub let arena_y0 : Int = 84

///|
pub let arena_w : Int = 1124

///|
pub let arena_h : Int = 574

///|
pub let arena_x1 : Int = arena_x0 + arena_w

///|
pub let arena_y1 : Int = arena_y0 + arena_h

///|
pub let surface_band_h : Int = 86

///|
pub let surface_band_y : Float = Float::from_int(arena_y0 + surface_band_h)

///|
pub let hot_zone_x : Float = Float::from_int(arena_x0) +
  Float::from_int(arena_w) * 0.72

///|
pub let hot_zone_y : Float = Float::from_int(arena_y0) +
  Float::from_int(arena_h) * 0.46

///|
pub let hot_zone_r : Float = 148.0

///|
pub let mission_min : Int = 1

///|
pub let mission_max : Int = 9

///|
pub let max_mines : Int = 54

///|
pub let max_targets : Int = 16

///|
pub let base_target_goal : Int = 4

///|
pub let target_goal_cap : Int = 12

///|
pub let base_mine_count : Int = 16

///|
pub let sub_start_x : Float = Float::from_int(arena_x0) + 126.0

///|
pub let sub_start_y : Float = Float::from_int(arena_y0) +
  Float::from_int(arena_h) * 0.62

///|
pub let sub_r : Float = 18.0

///|
pub let sub_accel : Float = 420.0

///|
pub let sub_boost_accel : Float = 760.0

///|
pub let sub_drag : Float = 4.8

///|
pub let sub_max_speed : Float = 220.0

///|
pub let sub_boost_max_speed : Float = 340.0

///|
pub let oxygen_max : Float = 100.0

///|
pub let fuel_max : Float = 100.0

///|
pub let hull_max : Float = 100.0

///|
pub let oxygen_base_drain : Float = 3.2

///|
pub let oxygen_hot_drain : Float = 4.4

///|
pub let oxygen_boost_drain : Float = 1.8

///|
pub let oxygen_surface_recover : Float = 10.2

///|
pub let fuel_idle_drain : Float = 0.5

///|
pub let fuel_move_drain : Float = 3.1

///|
pub let fuel_boost_drain : Float = 7.6

///|
pub let sonar_cd_time : Float = 1.28

///|
pub let sonar_pulse_time : Float = 0.82

///|
pub let sonar_base_range : Float = 192.0

///|
pub let sonar_hot_bonus : Float = 110.0

///|
pub let sonar_fuel_cost : Float = 5.6

///|
pub let sonar_oxygen_cost : Float = 4.8

///|
pub let mine_reveal_time : Float = 3.0

///|
pub let mine_damage_hull : Float = 36.0

///|
pub let mine_damage_oxygen : Float = 18.0

///|
pub let mine_damage_fuel : Float = 11.0

///|
pub let detect_oxygen_reward : Float = 4.8

///|
pub let detect_fuel_reward : Float = 3.2
