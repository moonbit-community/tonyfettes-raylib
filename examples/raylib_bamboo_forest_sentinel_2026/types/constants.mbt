///|
pub let screen_w : Int = 1500

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
pub let world_x : Int = 44

///|
pub let world_y : Int = 48

///|
pub let world_w : Int = 1040

///|
pub let world_h : Int = 804

///|
pub let hud_x : Int = world_x + world_w + 24

///|
pub let hud_y : Int = world_y

///|
pub let hud_w : Int = 348

///|
pub let hud_h : Int = world_h

///|
pub let corridor_lanes : Int = 3

///|
pub let lane_top_y : Int = world_y + 176

///|
pub let lane_mid_y : Int = world_y + world_h / 2

///|
pub let lane_bottom_y : Int = world_y + world_h - 176

///|
pub let player_radius : Float = 16.0

///|
pub let player_speed : Float = 312.0

///|
pub let dash_speed : Float = 860.0

///|
pub let dash_time : Float = 0.12

///|
pub let dash_cooldown : Float = 0.92

///|
pub let dash_energy_cost : Float = 18.0

///|
pub let basic_attack_damage : Float = 34.0

///|
pub let basic_attack_range : Float = 90.0

///|
pub let basic_attack_arc_dot : Float = 0.28

///|
pub let basic_attack_energy_cost : Float = 6.0

///|
pub let basic_attack_cooldown : Float = 0.22

///|
pub let attack_flash_time : Float = 0.14

///|
pub let energy_max : Float = 100.0

///|
pub let energy_regen : Float = 14.0

///|
pub let sweep_charge_max : Float = 100.0

///|
pub let sweep_charge_passive : Float = 3.8

///|
pub let sweep_charge_hit : Float = 8.0

///|
pub let sweep_charge_kill : Float = 16.0

///|
pub let sweep_radius : Float = 250.0

///|
pub let sweep_damage : Float = 88.0

///|
pub let sweep_fx_time : Float = 0.34

///|
pub let trap_slot_cols : Int = 6

///|
pub let trap_slot_rows : Int = 3

///|
pub let trap_slot_count : Int = trap_slot_cols * trap_slot_rows

///|
pub let trap_place_range : Float = 46.0

///|
pub let trap_place_energy_cost : Float = 18.0

///|
pub let trap_place_cooldown : Float = 0.46

///|
pub let trap_trigger_radius : Float = 54.0

///|
pub let trap_damage : Float = 44.0

///|
pub let trap_rearm_time : Float = 1.18

///|
pub let trap_flash_time : Float = 0.20

///|
pub let trap_slow_time : Float = 1.10

///|
pub let trap_slow_factor : Float = 0.56

///|
pub let trap_remove_range : Float = 56.0

///|
pub let trap_remove_refund : Float = 8.0

///|
pub let beacon_count : Int = 3

///|
pub let beacon_radius : Float = 26.0

///|
pub let beacon_integrity_max : Float = 140.0

///|
pub let max_enemies : Int = 260

///|
pub let enemy_radius : Float = 14.0

///|
pub let enemy_hp_base : Float = 58.0

///|
pub let enemy_hp_step : Float = 6.4

///|
pub let enemy_speed_base : Float = 92.0

///|
pub let enemy_speed_step : Float = 7.2

///|
pub let enemy_damage_base : Float = 14.0

///|
pub let enemy_damage_step : Float = 1.5

///|
pub let night_spawn_base : Int = 10

///|
pub let night_spawn_step : Int = 4

///|
pub let spawn_interval_start : Float = 1.04

///|
pub let spawn_interval_decay : Float = 0.06

///|
pub let spawn_interval_floor : Float = 0.28

///|
pub let night_banner_time : Float = 1.35

///|
pub let night_clear_energy_bonus : Float = 20.0

///|
pub let night_clear_charge_bonus : Float = 22.0

///|
pub let score_kill_base : Int = 40

///|
pub let score_night_clear_bonus : Int = 220

///|
pub let status_default_t : Float = 1.4

///|
pub let shake_hit_time : Float = 0.18
