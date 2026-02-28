///|
pub let game_title : String = "raylib [game] fighter 97 lite"

///|
pub let screen_width : Int = 1360

///|
pub let screen_height : Int = 768

///|
pub let floor_y : Float = 572.0

///|
pub let stage_left_x : Float = 120.0

///|
pub let stage_right_x : Float = 1240.0

///|
pub let center_line_x : Float = (stage_left_x + stage_right_x) * 0.5

///|
pub let fight_fps : Float = 60.0

///|
pub let frame_dt : Float = 1.0 / fight_fps

///|
pub let max_frame_dt : Float = 0.05

///|
pub let max_players : Int = 2

///|
pub let roster_count : Int = 6

///|
pub let max_particles : Int = 860

///|
pub let max_hit_sparks : Int = 360

///|
pub let direction_buffer_size : Int = 42

///|
pub let state_title : Int = 0

///|
pub let state_select : Int = 1

///|
pub let state_intro : Int = 2

///|
pub let state_fight : Int = 3

///|
pub let state_round_over : Int = 4

///|
pub let state_match_over : Int = 5

///|
pub let state_pause : Int = 6

///|
pub let winner_none : Int = -1

///|
pub let winner_draw : Int = -2

///|
pub let action_idle : Int = 0

///|
pub let action_walk_forward : Int = 1

///|
pub let action_walk_back : Int = 2

///|
pub let action_crouch : Int = 3

///|
pub let action_jump : Int = 4

///|
pub let action_dash_forward : Int = 5

///|
pub let action_dash_back : Int = 6

///|
pub let action_attack : Int = 7

///|
pub let action_hitstun : Int = 8

///|
pub let action_blockstun : Int = 9

///|
pub let action_knockdown : Int = 10

///|
pub let action_wakeup : Int = 11

///|
pub let action_victory : Int = 12

///|
pub let action_intro : Int = 13

///|
pub let action_throw : Int = 14

///|
pub let attack_none : Int = 0

///|
pub let attack_lp : Int = 1

///|
pub let attack_hp : Int = 2

///|
pub let attack_lk : Int = 3

///|
pub let attack_hk : Int = 4

///|
pub let attack_special_qcf : Int = 5

///|
pub let attack_special_dp : Int = 6

///|
pub let attack_super : Int = 7

///|
pub let move_kind_normal : Int = 0

///|
pub let move_kind_special : Int = 1

///|
pub let move_kind_super : Int = 2

///|
pub let ai_mode_idle : Int = 0

///|
pub let ai_mode_rush : Int = 1

///|
pub let ai_mode_zone : Int = 2

///|
pub let ai_mode_evade : Int = 3

///|
pub let facing_left : Int = -1

///|
pub let facing_right : Int = 1

///|
pub let motion_none : Int = 0

///|
pub let motion_qcf : Int = 1

///|
pub let motion_dp : Int = 2

///|
pub let max_round_wins : Int = 2

///|
pub let round_time_start : Float = 99.0

///|
pub let intro_duration : Float = 2.6

///|
pub let round_over_duration : Float = 2.8

///|
pub let match_over_duration : Float = 6.0

///|
pub let title_blink_speed : Float = 2.5

///|
pub let select_blink_speed : Float = 4.8

///|
pub let move_speed_forward : Float = 220.0

///|
pub let move_speed_back : Float = 170.0

///|
pub let crouch_slide_speed : Float = 80.0

///|
pub let jump_initial_velocity : Float = -700.0

///|
pub let gravity_force : Float = 1800.0

///|
pub let dash_forward_speed : Float = 520.0

///|
pub let dash_back_speed : Float = -430.0

///|
pub let dash_duration_frames : Int = 14

///|
pub let fighter_body_width : Float = 72.0

///|
pub let fighter_body_height : Float = 134.0

///|
pub let fighter_stand_hurtbox_w : Float = 56.0

///|
pub let fighter_stand_hurtbox_h : Float = 124.0

///|
pub let fighter_crouch_hurtbox_w : Float = 60.0

///|
pub let fighter_crouch_hurtbox_h : Float = 84.0

///|
pub let fighter_push_radius : Float = 46.0

///|
pub let health_max : Int = 1000

///|
pub let guard_max : Int = 100

///|
pub let super_max : Int = 100

///|
pub let super_cost : Int = 100

///|
pub let guard_recover_per_sec : Float = 9.0

///|
pub let meter_gain_blocked : Int = 4

///|
pub let meter_gain_hit_taken : Int = 7

///|
pub let hitstop_default : Int = 8

///|
pub let hitstop_super : Int = 14

///|
pub let combo_decay_step : Float = 0.075

///|
pub let combo_timeout_frames : Int = 34

///|
pub let counter_hit_bonus : Float = 1.16

///|
pub let throw_distance : Float = 68.0

///|
pub let throw_vertical_tolerance : Float = 44.0

///|
pub let throw_damage : Int = 118

///|
pub let throw_knockdown_frames : Int = 42

///|
pub let throw_push_x : Float = 190.0

///|
pub let throw_launch_y : Float = -200.0

///|
pub let throw_tech_window_frames : Int = 8

///|
pub let throw_tech_push_x : Float = 136.0

///|
pub let throw_tech_invuln_frames : Int = 6

///|
pub let throw_corner_space_min : Float = 74.0

///|
pub let throw_corner_escape_ratio : Float = 0.58

///|
pub let wakeup_invuln_frames : Int = 10

///|
pub let training_health_regen_per_sec : Float = 140.0

///|
pub let training_info_duration : Float = 1.8

///|
pub let tap_window : Float = 0.24

///|
pub let cpu_think_period : Float = 0.1

///|
pub let cpu_reaction_base : Float = 0.12

///|
pub let cpu_jump_chance : Float = 0.08

///|
pub let cpu_special_chance : Float = 0.22

///|
pub let cpu_super_chance : Float = 0.18

///|
pub let cpu_block_chance : Float = 0.64

///|
pub let particle_gravity : Float = 1200.0

///|
pub let particle_friction : Float = 0.87

///|
pub let camera_shake_decay : Float = 7.2

///|
pub let camera_shake_max : Float = 18.0

///|
pub let camera_zoom_base : Float = 1.0

///|
pub let camera_zoom_close : Float = 1.06

///|
pub let camera_zoom_far : Float = 0.95

///|
pub let select_grid_columns : Int = 3

///|
pub let quote_box_w : Int = 520

///|
pub let quote_box_h : Int = 76

///|
pub let font_title : Int = 62

///|
pub let font_subtitle : Int = 28

///|
pub let dir_neutral : Int = 0

///|
pub let dir_up : Int = 1

///|
pub let dir_down : Int = 2

///|
pub let dir_back : Int = 3

///|
pub let dir_forward : Int = 4

///|
pub let dir_down_back : Int = 5

///|
pub let dir_down_forward : Int = 6

///|
pub let spark_kind_hit : Int = 0

///|
pub let spark_kind_block : Int = 1

///|
pub let spark_kind_super : Int = 2
