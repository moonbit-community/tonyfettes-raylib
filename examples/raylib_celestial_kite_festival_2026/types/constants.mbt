///|
pub let screen_w : Int = 1280

///|
pub let screen_h : Int = 720

///|
pub let target_fps : Int = 120

///|
pub let hud_h : Int = 110

///|
pub let play_top : Float = Float::from_int(hud_h) + 14.0

///|
pub let play_bottom : Float = Float::from_int(screen_h) - 26.0

///|
pub let play_left : Float = 42.0

///|
pub let play_right : Float = Float::from_int(screen_w) - 42.0

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_stage_clear : Int = 2

///|
pub let state_game_over : Int = 3

///|
pub let obj_lantern : Int = 0

///|
pub let obj_bird : Int = 1

///|
pub let obj_storm : Int = 2

///|
pub let obj_orb : Int = 3

///|
pub let obj_koi : Int = 4

///|
pub let max_objs : Int = 360

///|
pub let max_sparks : Int = 900

///|
pub let max_halos : Int = 90

///|
pub let max_trails : Int = 320

///|
pub let kite_w : Float = 54.0

///|
pub let kite_h : Float = 64.0

///|
pub let kite_accel : Float = 1040.0

///|
pub let kite_drag : Float = 2.8

///|
pub let kite_max_speed : Float = 540.0

///|
pub let kite_rope_len_min : Float = 150.0

///|
pub let kite_rope_len_max : Float = 360.0

///|
pub let kite_rope_spring : Float = 9.0

///|
pub let kite_rope_damp : Float = 0.94

///|
pub let burst_cd_time : Float = 1.8

///|
pub let burst_radius : Float = 150.0

///|
pub let burst_cost : Float = 24.0

///|
pub let reel_energy_cost : Float = 22.0

///|
pub let reel_rate : Float = 120.0

///|
pub let rope_recover_rate : Float = 52.0

///|
pub let stage_time_base : Float = 62.0

///|
pub let stage_time_bonus : Float = 12.0

///|
pub let stage_goal_base : Int = 1300

///|
pub let stage_goal_bonus : Int = 720

///|
pub let calm_max : Float = 100.0

///|
pub let energy_max : Float = 100.0

///|
pub let calm_decay : Float = 3.2

///|
pub let energy_regen : Float = 16.0

///|
pub let wind_base : Float = 48.0

///|
pub let wind_stage_bonus : Float = 22.0

///|
pub let stage_clear_wait : Float = 2.0
