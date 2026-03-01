///|
pub let screen_w : Int = 1420

///|
pub let screen_h : Int = 900

///|
pub let target_fps : Int = 120

///|
pub let state_title : Int = 0

///|
pub let state_playing : Int = 1

///|
pub let state_paused : Int = 2

///|
pub let state_game_over : Int = 3

///|
pub let dir_up : Int = 0

///|
pub let dir_right : Int = 1

///|
pub let dir_down : Int = 2

///|
pub let dir_left : Int = 3

///|
pub let grid_cols : Int = 11

///|
pub let grid_rows : Int = 7

///|
pub let cell_size : Int = 82

///|
pub let board_w : Int = grid_cols * cell_size

///|
pub let board_h : Int = grid_rows * cell_size

///|
pub let board_x : Int = (screen_w - board_w) / 2

///|
pub let board_y : Int = 168

///|
pub let gate_gx : Int = grid_cols / 2

///|
pub let gate_gy : Int = grid_rows / 2

///|
pub let gate_radius : Float = 44.0

///|
pub let gate_hit_radius : Float = 30.0

///|
pub let gate_hp_max : Float = 260.0

///|
pub let max_nodes : Int = grid_cols * grid_rows

///|
pub let max_enemies : Int = 200

///|
pub let max_bolts : Int = 300

///|
pub let max_pulses : Int = 320

///|
pub let node_max_level : Int = 3

///|
pub let node_build_cost : Float = 36.0

///|
pub let node_upgrade_cost_l2 : Float = 52.0

///|
pub let node_upgrade_cost_l3 : Float = 76.0

///|
pub let node_sell_ratio : Float = 0.65

///|
pub let node_range_l1 : Float = 168.0

///|
pub let node_range_l2 : Float = 218.0

///|
pub let node_range_l3 : Float = 270.0

///|
pub let node_damage_l1 : Float = 17.0

///|
pub let node_damage_l2 : Float = 28.0

///|
pub let node_damage_l3 : Float = 42.0

///|
pub let node_fire_cd_l1 : Float = 0.58

///|
pub let node_fire_cd_l2 : Float = 0.40

///|
pub let node_fire_cd_l3 : Float = 0.27

///|
pub let node_projectile_speed : Float = 620.0

///|
pub let node_cone_dot_sq : Float = 0.22

///|
pub let bolt_life : Float = 1.2

///|
pub let bolt_hit_radius : Float = 8.0

///|
pub let energy_start : Float = 120.0

///|
pub let energy_max : Float = 320.0

///|
pub let energy_regen : Float = 13.5

///|
pub let wave_energy_bonus : Float = 12.0

///|
pub let wave_intro_delay : Float = 0.8

///|
pub let wave_spawn_count_base : Int = 7

///|
pub let wave_spawn_count_step : Int = 3

///|
pub let spawn_cd_base : Float = 0.95

///|
pub let spawn_cd_min : Float = 0.20

///|
pub let enemy_kind_skitter : Int = 0

///|
pub let enemy_kind_carapace : Int = 1

///|
pub let enemy_kind_wraith : Int = 2

///|
pub let enemy_base_hp : Float = 28.0

///|
pub let enemy_hp_per_wave : Float = 5.2

///|
pub let enemy_base_speed : Float = 62.0

///|
pub let enemy_speed_per_wave : Float = 5.0

///|
pub let enemy_contact_damage_base : Float = 12.0

///|
pub let enemy_contact_damage_wave : Float = 1.5

///|
pub let combo_window : Float = 2.5

///|
pub let combo_score_step : Int = 4

///|
pub let barrier_charge_goal : Float = 100.0

///|
pub let barrier_charge_kill : Float = 11.0

///|
pub let barrier_charge_combo : Float = 1.8

///|
pub let barrier_charge_combo_cap : Int = 12

///|
pub let barrier_radius : Float = 235.0

///|
pub let barrier_damage : Float = 95.0

///|
pub let barrier_push : Float = 72.0

///|
pub let barrier_flash_time : Float = 0.56

///|
pub let shake_time_hit : Float = 0.22
