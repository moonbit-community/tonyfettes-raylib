///|
let game_title : String = "raylib [game] fighter 97 lite"

///|
let screen_width : Int = 1360

///|
let screen_height : Int = 768

///|
let floor_y : Float = 572.0

///|
let stage_left_x : Float = 120.0

///|
let stage_right_x : Float = 1240.0

///|
let center_line_x : Float = (stage_left_x + stage_right_x) * 0.5

///|
let fight_fps : Float = 60.0

///|
let frame_dt : Float = 1.0 / fight_fps

///|
let max_frame_dt : Float = 0.05

///|
let max_players : Int = 2

///|
let roster_count : Int = 6

///|
let max_particles : Int = 860

///|
let max_hit_sparks : Int = 360

///|
let direction_buffer_size : Int = 42

///|
let button_buffer_size : Int = 22

///|
let state_title : Int = 0

///|
let state_select : Int = 1

///|
let state_intro : Int = 2

///|
let state_fight : Int = 3

///|
let state_round_over : Int = 4

///|
let state_match_over : Int = 5

///|
let state_pause : Int = 6

///|
let winner_none : Int = -1

///|
let winner_draw : Int = -2

///|
let action_idle : Int = 0

///|
let action_walk_forward : Int = 1

///|
let action_walk_back : Int = 2

///|
let action_crouch : Int = 3

///|
let action_jump : Int = 4

///|
let action_dash_forward : Int = 5

///|
let action_dash_back : Int = 6

///|
let action_attack : Int = 7

///|
let action_hitstun : Int = 8

///|
let action_blockstun : Int = 9

///|
let action_knockdown : Int = 10

///|
let action_wakeup : Int = 11

///|
let action_victory : Int = 12

///|
let action_intro : Int = 13

///|
let action_throw : Int = 14

///|
let attack_none : Int = 0

///|
let attack_lp : Int = 1

///|
let attack_hp : Int = 2

///|
let attack_lk : Int = 3

///|
let attack_hk : Int = 4

///|
let attack_special_qcf : Int = 5

///|
let attack_special_dp : Int = 6

///|
let attack_super : Int = 7

///|
let move_kind_normal : Int = 0

///|
let move_kind_special : Int = 1

///|
let move_kind_super : Int = 2

///|
let ai_mode_idle : Int = 0

///|
let ai_mode_rush : Int = 1

///|
let ai_mode_zone : Int = 2

///|
let ai_mode_evade : Int = 3

///|
let facing_left : Int = -1

///|
let facing_right : Int = 1

///|
let motion_none : Int = 0

///|
let motion_qcf : Int = 1

///|
let motion_dp : Int = 2

///|
let motion_qcb : Int = 3

///|
let max_round_wins : Int = 2

///|
let round_time_start : Float = 99.0

///|
let intro_duration : Float = 2.6

///|
let round_over_duration : Float = 2.8

///|
let match_over_duration : Float = 6.0

///|
let title_blink_speed : Float = 2.5

///|
let select_blink_speed : Float = 4.8

///|
let move_speed_forward : Float = 220.0

///|
let move_speed_back : Float = 170.0

///|
let crouch_slide_speed : Float = 80.0

///|
let jump_initial_velocity : Float = -700.0

///|
let gravity_force : Float = 1800.0

///|
let dash_forward_speed : Float = 520.0

///|
let dash_back_speed : Float = -430.0

///|
let dash_duration_frames : Int = 14

///|
let fighter_body_width : Float = 72.0

///|
let fighter_body_height : Float = 134.0

///|
let fighter_stand_hurtbox_w : Float = 56.0

///|
let fighter_stand_hurtbox_h : Float = 124.0

///|
let fighter_crouch_hurtbox_w : Float = 60.0

///|
let fighter_crouch_hurtbox_h : Float = 84.0

///|
let fighter_push_radius : Float = 46.0

///|
let health_max : Int = 1000

///|
let guard_max : Int = 100

///|
let super_max : Int = 100

///|
let super_cost : Int = 100

///|
let guard_recover_per_sec : Float = 9.0

///|
let meter_gain_blocked : Int = 4

///|
let meter_gain_hit_taken : Int = 7

///|
let hitstop_default : Int = 8

///|
let hitstop_super : Int = 14

///|
let combo_decay_step : Float = 0.075

///|
let combo_timeout_frames : Int = 34

///|
let counter_hit_bonus : Float = 1.16

///|
let throw_distance : Float = 68.0

///|
let throw_vertical_tolerance : Float = 44.0

///|
let throw_damage : Int = 118

///|
let throw_knockdown_frames : Int = 42

///|
let throw_push_x : Float = 190.0

///|
let throw_launch_y : Float = -200.0

///|
let throw_tech_window_frames : Int = 8

///|
let throw_tech_push_x : Float = 136.0

///|
let throw_tech_invuln_frames : Int = 6

///|
let throw_corner_space_min : Float = 74.0

///|
let throw_corner_escape_ratio : Float = 0.58

///|
let wakeup_invuln_frames : Int = 10

///|
let training_health_regen_per_sec : Float = 140.0

///|
let training_info_duration : Float = 1.8

///|
let tap_window : Float = 0.24

///|
let input_deadzone : Int = 0

///|
let cpu_think_period : Float = 0.1

///|
let cpu_reaction_base : Float = 0.12

///|
let cpu_jump_chance : Float = 0.08

///|
let cpu_special_chance : Float = 0.22

///|
let cpu_super_chance : Float = 0.18

///|
let cpu_block_chance : Float = 0.64

///|
let particle_gravity : Float = 1200.0

///|
let particle_friction : Float = 0.87

///|
let camera_shake_decay : Float = 7.2

///|
let camera_shake_max : Float = 18.0

///|
let camera_zoom_base : Float = 1.0

///|
let camera_zoom_close : Float = 1.06

///|
let camera_zoom_far : Float = 0.95

///|
let stage_bg_layer_count : Int = 5

///|
let select_grid_columns : Int = 3

///|
let select_grid_rows : Int = 2

///|
let palette_cycle_speed : Float = 1.8

///|
let quote_box_w : Int = 520

///|
let quote_box_h : Int = 76

///|
let font_title : Int = 62

///|
let font_subtitle : Int = 28

///|
let font_hud : Int = 24

///|
let font_small : Int = 18

///|
let dir_neutral : Int = 0

///|
let dir_up : Int = 1

///|
let dir_down : Int = 2

///|
let dir_back : Int = 3

///|
let dir_forward : Int = 4

///|
let dir_down_back : Int = 5

///|
let dir_down_forward : Int = 6

///|
let spark_kind_hit : Int = 0

///|
let spark_kind_block : Int = 1

///|
let spark_kind_super : Int = 2
