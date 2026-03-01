///|
pub let screen_w : Int = 1440

///|
pub let screen_h : Int = 900

///|
pub let target_fps : Int = 120

///|
pub let max_parcels : Int = 12

///|
pub let max_exits : Int = 3

///|
pub let max_guards : Int = 16

///|
pub let max_traps : Int = 28

///|
pub let max_smokes : Int = 8

///|
pub let hud_h : Float = 92.0

///|
pub let world_left : Float = 46.0

///|
pub let world_top : Float = 108.0

///|
pub let world_right : Float = Float::from_int(screen_w) - 46.0

///|
pub let world_bottom : Float = Float::from_int(screen_h) - 46.0

///|
pub let player_radius : Float = 14.0

///|
pub let player_base_speed : Float = 210.0

///|
pub let player_sprint_mult : Float = 1.62

///|
pub let player_carry_speed_mult : Float = 0.83

///|
pub let player_health_max : Float = 100.0

///|
pub let player_stealth_max : Float = 100.0

///|
pub let stealth_recovery_per_sec : Float = 16.0

///|
pub let stealth_break_damage_per_sec : Float = 19.0

///|
pub let sprint_noise_pressure : Float = 10.0

///|
pub let sprint_stealth_burn : Float = 8.0

///|
pub let interaction_range : Float = 36.0

///|
pub let parcel_spawn_margin : Float = 84.0

///|
pub let exit_radius : Float = 34.0

///|
pub let guard_speed_base : Float = 96.0

///|
pub let guard_speed_wave_gain : Float = 8.0

///|
pub let guard_alert_speed_mult : Float = 1.35

///|
pub let guard_cone_range_base : Float = 214.0

///|
pub let guard_cone_range_wave_gain : Float = 8.0

///|
pub let guard_cone_half_angle_base : Float = 27.0

///|
pub let guard_detection_base : Float = 14.0

///|
pub let guard_detection_peak : Float = 52.0

///|
pub let guard_alert_hold : Float = 1.5

///|
pub let guard_smoke_lure_range : Float = 250.0

///|
pub let guard_investigate_hold : Float = 1.4

///|
pub let guard_spawn_margin : Float = 90.0

///|
pub let trap_radius_base : Float = 18.0

///|
pub let trap_damage_base : Float = 16.0

///|
pub let trap_damage_wave_gain : Float = 2.5

///|
pub let trap_trigger_cooldown : Float = 1.15

///|
pub let trap_pressure : Float = 12.0

///|
pub let trap_spawn_margin : Float = 72.0

///|
pub let smoke_radius_base : Float = 154.0

///|
pub let smoke_life_secs : Float = 4.8

///|
pub let smoke_cover_factor : Float = 0.38

///|
pub let smoke_stock_base : Int = 2

///|
pub let wave_target_base : Int = 2

///|
pub let max_delivery_target : Int = 7

///|
pub let wave_time_base : Float = 74.0

///|
pub let wave_time_decay : Float = 4.2

///|
pub let wave_min_time : Float = 35.0

///|
pub let wave_clear_health_recover : Float = 12.0

///|
pub let wave_clear_score_base : Int = 160

///|
pub let wave_clear_score_wave_bonus : Int = 38

///|
pub let wave_clear_time_score_mult : Float = 4.0

///|
pub let pi : Float = 3.141592653589793

///|
pub let deg_to_rad : Float = pi / 180.0

///|
pub let rad_to_deg : Float = 180.0 / pi
