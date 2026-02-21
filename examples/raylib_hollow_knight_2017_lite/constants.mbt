///|
let screen_width : Int = 980

///|
let screen_height : Int = 760

///|
let map_tiles_w : Int = 26

///|
let map_tiles_h : Int = 26

///|
let tile_size : Int = 24

///|
let map_pixel_w : Int = map_tiles_w * tile_size

///|
let map_pixel_h : Int = map_tiles_h * tile_size

///|
let map_offset_x : Int = 36

///|
let map_offset_y : Int = 50

///|
let panel_x : Int = map_offset_x + map_pixel_w + 20

///|
let panel_w : Int = screen_width - panel_x - 24

///|
let tank_size : Float = 20.0

///|
let tank_half : Float = tank_size / 2.0

///|
let bullet_radius : Float = 3.0

///|
let max_players : Int = 2

///|
let max_enemies : Int = 42

///|
let max_bullets : Int = 320

///|
let max_grenades : Int = 96

///|
let max_particles : Int = 960

///|
let max_powerups : Int = 32

///|
let max_cores : Int = 20

///|
let max_contracts : Int = 3

///|
let max_hazards : Int = 36

///|
let max_tiles : Int = map_tiles_w * map_tiles_h

///|
let enemy_on_field_limit : Int = 10

///|
let stage_intro_time : Float = 1.6

///|
let stage_clear_time : Float = 2.4

///|
let game_over_delay : Float = 2.8

///|
let campaign_clear_delay : Float = 3.6

///|
let enemy_spawn_period : Float = 0.78

///|
let powerup_life : Float = 10.0

///|
let freeze_duration : Float = 4.4

///|
let shovel_duration : Float = 8.4

///|
let player_respawn_delay : Float = 1.2

///|
let player_invuln_spawn : Float = 2.0

///|
let player_reload_base : Float = 0.22

///|
let enemy_reload_base : Float = 0.57

///|
let bullet_speed_player : Float = 395.0

///|
let bullet_speed_enemy : Float = 318.0

///|
let grenade_speed_player : Float = 210.0

///|
let grenade_fuse_time : Float = 0.74

///|
let grenade_cooldown_base : Float = 0.30

///|
let grenade_blast_radius : Float = 58.0

///|
let grenade_contact_radius : Float = 7.0

///|
let player_grenade_stock_base : Int = 4

///|
let grenade_pickup_bonus : Int = 3

///|
let melee_reach : Float = 34.0

///|
let melee_width : Float = 18.0

///|
let melee_cooldown : Float = 0.38

///|
let melee_anim_time : Float = 0.14

///|
let melee_stun_time : Float = 0.9

///|
let melee_chain_bonus : Int = 50

///|
let dash_strike_distance : Float = 98.0

///|
let dash_hit_radius : Float = 22.0

///|
let dash_cooldown : Float = 1.55

///|
let dash_chain_bonus : Int = 66

///|
let guard_duration : Float = 0.56

///|
let guard_cooldown : Float = 1.36

///|
let guard_parry_bonus : Int = 30

///|
let guard_counter_range : Float = 38.0

///|
let guard_counter_width : Float = 22.0

///|
let guard_counter_stun : Float = 0.65

///|
let spin_attack_radius : Float = 86.0

///|
let spin_attack_duration : Float = 0.330

///|
let spin_attack_cooldown : Float = 2.04

///|
let spin_attack_bonus : Int = 236

///|
let speed_player : Float = 140.0

///|
let speed_enemy_basic : Float = 88.0

///|
let speed_enemy_fast : Float = 124.0

///|
let speed_enemy_heavy : Float = 70.0

///|
let speed_enemy_sniper : Float = 94.0

///|
let base_tile_x : Int = 12

///|
let base_tile_y : Int = 24

///|
let menu_select_blink_speed : Float = 3.0

///|
let camera_shake_decay : Float = 3.3

///|
let camera_shake_power : Float = 8.5

///|
let level_count : Int = 96

///|
let map_pattern_count : Int = 48

///|
let core_radius : Float = 14.0

///|
let core_hp_base : Int = 18

///|
let core_score_base : Int = 260

///|
let elite_bonus_hp : Int = 2

///|
let elite_spawn_base_chance : Int = 16

///|
let elite_spawn_stage_bonus : Int = 2

///|
let hazard_spawn_base : Float = 6.6

///|
let hazard_warn_time : Float = 1.08

///|
let hazard_radius_base : Float = 34.0

///|
let hazard_damage_base : Int = 1

///|
let contract_score_base : Int = 160

///|
let contract_time_goal_base : Int = 95

///|
let contract_elite_goal_base : Int = 3

///|
let contract_core_goal_base : Int = 2

///|
let team_none : Int = 0

///|
let team_player1 : Int = 1

///|
let team_player2 : Int = 2

///|
let team_enemy : Int = 3

///|
let dir_up : Int = 0

///|
let dir_right : Int = 1

///|
let dir_down : Int = 2

///|
let dir_left : Int = 3

///|
let tile_empty : Int = 0

///|
let tile_brick : Int = 1

///|
let tile_steel : Int = 2

///|
let tile_water : Int = 3

///|
let tile_bush : Int = 4

///|
let tile_ice : Int = 5

///|
let tile_base : Int = 6

///|
let state_menu : Int = 0

///|
let state_stage_intro : Int = 1

///|
let state_playing : Int = 2

///|
let state_paused : Int = 3

///|
let state_stage_clear : Int = 4

///|
let state_game_over : Int = 5

///|
let state_campaign_clear : Int = 6

///|
let enemy_basic : Int = 0

///|
let enemy_fast : Int = 1

///|
let enemy_heavy : Int = 2

///|
let enemy_sniper : Int = 3

///|
let powerup_shield : Int = 0

///|
let powerup_star : Int = 1

///|
let powerup_grenade : Int = 2

///|
let powerup_clock : Int = 3

///|
let powerup_shovel : Int = 4

///|
let powerup_tank : Int = 5

///|
let contract_none : Int = 0

///|
let contract_fast_clear : Int = 1

///|
let contract_no_death : Int = 2

///|
let contract_no_base_break : Int = 3

///|
let contract_elite_hunt : Int = 4

///|
let contract_core_breaker : Int = 5

///|
let contract_combo_chain : Int = 6

///|
let enemy_spawn_x0 : Float = 2.0 * Float::from_int(tile_size) + tank_half

///|
let enemy_spawn_x1 : Float = 12.0 * Float::from_int(tile_size) + tank_half

///|
let enemy_spawn_x2 : Float = 22.0 * Float::from_int(tile_size) + tank_half

///|
let enemy_spawn_y : Float = 1.5 * Float::from_int(tile_size)

///|
let player1_spawn_x : Float = 8.0 * Float::from_int(tile_size) + tank_half

///|
let player1_spawn_y : Float = 24.0 * Float::from_int(tile_size) + tank_half

///|
let player2_spawn_x : Float = 16.0 * Float::from_int(tile_size) + tank_half

///|
let player2_spawn_y : Float = 24.0 * Float::from_int(tile_size) + tank_half

///|
let enemy_icon_rows : Int = 10

///|
let enemy_icon_cols : Int = 2

///|
let base_ring_count : Int = 14

///|
let base_ring_x : Array[Int] = [
  11, 12, 13, 14, 11, 14, 11, 14, 11, 12, 13, 14, 12, 13,
]

///|
let base_ring_y : Array[Int] = [
  22, 22, 22, 22, 23, 23, 24, 24, 25, 25, 25, 25, 24, 24,
]
