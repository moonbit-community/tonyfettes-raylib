///|
pub let screen_w : Int = 1280

///|
pub let screen_h : Int = 720

///|
pub let target_fps : Int = 120

///|
pub let state_title : Int = 0

///|
pub let state_play : Int = 1

///|
pub let state_stage_clear : Int = 2

///|
pub let state_game_over : Int = 3

///|
pub let foe_bike : Int = 0

///|
pub let foe_drone : Int = 1

///|
pub let foe_truck : Int = 2

///|
pub let foe_laser : Int = 3

///|
pub let item_credit : Int = 4

///|
pub let item_battery : Int = 5

///|
pub let item_hackcell : Int = 6

///|
pub let max_entities : Int = 380

///|
pub let max_bullets : Int = 440

///|
pub let max_sparks : Int = 760

///|
pub let max_glow_rings : Int = 80

///|
pub let max_afterimages : Int = 220

///|
pub let lanes_count : Int = 5

///|
pub let lane_gap : Float = Float::from_int(92)

///|
pub let player_w : Float = Float::from_int(42)

///|
pub let player_h : Float = Float::from_int(74)

///|
pub let player_accel_x : Float = Float::from_int(1700)

///|
pub let player_accel_y : Float = Float::from_int(1260)

///|
pub let player_drag : Float = Float::from_int(3)

///|
pub let player_max_speed_x : Float = Float::from_int(520)

///|
pub let player_max_speed_y : Float = Float::from_int(360)

///|
pub let base_scroll_speed : Float = Float::from_int(280)

///|
pub let stage_scroll_gain : Float = Float::from_int(34)

///|
pub let stage_distance_base : Float = Float::from_int(2600)

///|
pub let stage_distance_gain : Float = Float::from_int(760)

///|
pub let spawn_start_y : Float = -110.0

///|
pub let spawn_spacing_min : Float = 68.0

///|
pub let spawn_spacing_max : Float = 164.0

///|
pub let energy_drain_base : Float = Float::from_int(3)

///|
pub let energy_drain_boost : Float = Float::from_int(6)

///|
pub let energy_pickup : Float = Float::from_int(22)

///|
pub let shield_damage_decay : Float = Float::from_int(14)

///|
pub let player_shield_max : Float = Float::from_int(100)

///|
pub let player_energy_max : Float = Float::from_int(100)

///|
pub let fire_cooldown_base : Float = 0.145

///|
pub let bullet_speed : Float = Float::from_int(780)

///|
pub let enemy_bullet_speed : Float = Float::from_int(390)

///|
pub let bullet_life : Float = 1.2

///|
pub let boost_cd_time : Float = 1.55

///|
pub let boost_time : Float = 0.26

///|
pub let boost_speed_bonus : Float = Float::from_int(560)

///|
pub let hack_cd_time : Float = 2.4

///|
pub let hack_time : Float = 0.82

///|
pub let hack_radius : Float = Float::from_int(220)

///|
pub let hack_pulse_kill : Float = Float::from_int(110)

///|
pub let stage_clear_delay : Float = 1.85

///|
pub let invuln_after_hit : Float = 0.62

///|
pub let ui_panel_h : Int = 112
