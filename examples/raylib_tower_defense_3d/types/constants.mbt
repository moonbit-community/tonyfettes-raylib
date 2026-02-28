// Screen
///|
pub let screen_width : Int = 1024

///|
pub let screen_height : Int = 768

// Map grid

///|
pub let map_w : Int = 20

///|
pub let map_h : Int = 15

///|
pub let cell_size : Float = 2.0

///|
pub let map_total : Int = 300 // map_w * map_h

// Tile types

///|
pub let tile_grass : Int = 0

///|
pub let tile_path : Int = 1

///|
pub let tile_start : Int = 2

///|
pub let tile_end : Int = 3

///|
pub let tile_water : Int = 4

///|
pub let tile_rock : Int = 5

// Tower types (8 tower types)

///|
pub let tower_arrow : Int = 0

///|
pub let tower_cannon : Int = 1

///|
pub let tower_frost : Int = 2

///|
pub let tower_lightning : Int = 3

///|
pub let tower_flame : Int = 4

///|
pub let tower_sniper : Int = 5

///|
pub let tower_splash : Int = 6

///|
pub let tower_buff : Int = 7

///|
pub let tower_type_count : Int = 8

// Tower costs (base cost for level 1)

///|
pub let cost_arrow : Int = 50

///|
pub let cost_cannon : Int = 100

///|
pub let cost_frost : Int = 75

///|
pub let cost_lightning : Int = 150

///|
pub let cost_flame : Int = 120

///|
pub let cost_sniper : Int = 200

///|
pub let cost_splash : Int = 130

///|
pub let cost_buff : Int = 175

// Tower ranges (base range)

///|
pub let range_arrow : Float = 5.0

///|
pub let range_cannon : Float = 4.5

///|
pub let range_frost : Float = 4.0

///|
pub let range_lightning : Float = 6.0

///|
pub let range_flame : Float = 3.5

///|
pub let range_sniper : Float = 9.0

///|
pub let range_splash : Float = 4.0

///|
pub let range_buff : Float = 5.0

// Tower damage (base damage)

///|
pub let dmg_arrow : Float = 10.0

///|
pub let dmg_cannon : Float = 30.0

///|
pub let dmg_frost : Float = 5.0

///|
pub let dmg_lightning : Float = 20.0

///|
pub let dmg_flame : Float = 15.0

///|
pub let dmg_sniper : Float = 60.0

///|
pub let dmg_splash : Float = 18.0

///|
pub let dmg_buff : Float = 0.0

// Tower fire rates (seconds between shots)

///|
pub let rate_arrow : Float = 0.8

///|
pub let rate_cannon : Float = 2.0

///|
pub let rate_frost : Float = 1.0

///|
pub let rate_lightning : Float = 1.5

///|
pub let rate_flame : Float = 0.3

///|
pub let rate_sniper : Float = 3.0

///|
pub let rate_splash : Float = 1.8

///|
pub let rate_buff : Float = 4.0

// Tower upgrade costs (level 2 and level 3)

///|
pub let upgrade_cost_mult_2 : Float = 0.6

///|
pub let upgrade_cost_mult_3 : Float = 1.0

// Tower upgrade stat multipliers per level

///|
pub let upgrade_range_mult : Float = 0.12

///|
pub let upgrade_damage_mult : Float = 0.25

///|
pub let upgrade_rate_mult : Float = 0.10

// Tower sell value (percentage of total investment)

///|
pub let sell_value_pct : Float = 0.6

// Targeting modes

///|
pub let target_first : Int = 0

///|
pub let target_last : Int = 1

///|
pub let target_strongest : Int = 2

///|
pub let target_closest : Int = 3

///|
pub let target_mode_count : Int = 4

// Projectile types

///|
pub let proj_bullet : Int = 0

///|
pub let proj_cannonball : Int = 1

///|
pub let proj_ice_shard : Int = 2

///|
pub let proj_lightning_bolt : Int = 3

///|
pub let proj_fireball : Int = 4

///|
pub let proj_sniper_round : Int = 5

///|
pub let proj_splash_bomb : Int = 6

// Projectile speeds

///|
pub let proj_speed_bullet : Float = 14.0

///|
pub let proj_speed_cannonball : Float = 10.0

///|
pub let proj_speed_ice_shard : Float = 12.0

///|
pub let proj_speed_lightning : Float = 20.0

///|
pub let proj_speed_fireball : Float = 8.0

///|
pub let proj_speed_sniper : Float = 25.0

///|
pub let proj_speed_splash : Float = 9.0

// Splash radii

///|
pub let splash_radius_cannon : Float = 2.0

///|
pub let splash_radius_splash : Float = 3.0

///|
pub let splash_radius_flame : Float = 1.5

// Status effect types

///|
pub let effect_none : Int = 0

///|
pub let effect_slow : Int = 1

///|
pub let effect_burn : Int = 2

///|
pub let effect_stun : Int = 3

///|
pub let effect_chain : Int = 4

///|
pub let effect_armor_break : Int = 5

// Status effect durations

///|
pub let slow_duration : Float = 2.5

///|
pub let burn_duration : Float = 3.0

///|
pub let stun_duration : Float = 1.0

///|
pub let armor_break_duration : Float = 4.0

// Status effect strengths

///|
pub let slow_strength : Float = 0.4

///|
pub let burn_dps : Float = 5.0

///|
pub let armor_break_amount : Float = 0.5

// Lightning chain parameters

///|
pub let chain_count : Int = 3

///|
pub let chain_range : Float = 4.0

///|
pub let chain_damage_decay : Float = 0.7

// Sniper crit parameters

///|
pub let sniper_crit_chance : Float = 0.25

///|
pub let sniper_crit_mult : Float = 2.5

// Buff tower parameters

///|
pub let buff_damage_bonus : Float = 0.25

///|
pub let buff_range_bonus : Float = 0.15

///|
pub let buff_rate_bonus : Float = 0.10

// Enemy types (10+ enemy types)

///|
pub let enemy_basic : Int = 0

///|
pub let enemy_fast : Int = 1

///|
pub let enemy_tank : Int = 2

///|
pub let enemy_flying : Int = 3

///|
pub let enemy_boss : Int = 4

///|
pub let enemy_healer : Int = 5

///|
pub let enemy_swarm : Int = 6

///|
pub let enemy_shield : Int = 7

///|
pub let enemy_camo : Int = 8

///|
pub let enemy_splitter : Int = 9

///|
pub let enemy_type_count : Int = 10

// Enemy armor values (damage reduction flat amount)

///|
pub let armor_basic : Float = 0.0

///|
pub let armor_fast : Float = 0.0

///|
pub let armor_tank : Float = 5.0

///|
pub let armor_flying : Float = 0.0

///|
pub let armor_boss : Float = 8.0

///|
pub let armor_healer : Float = 1.0

///|
pub let armor_swarm : Float = 0.0

///|
pub let armor_shield : Float = 10.0

///|
pub let armor_camo : Float = 0.0

///|
pub let armor_splitter : Float = 2.0

// Enemy resistance system: 0.0 = immune, 0.5 = resistant, 1.0 = normal, 1.5 = weak, 2.0 = very weak
// Indexed by [enemy_type][damage_source] where damage_source maps to tower types
// We'll use functions to look up resistance

// Healer parameters

///|
pub let healer_range : Float = 4.0

///|
pub let healer_heal_rate : Float = 8.0

///|
pub let healer_heal_interval : Float = 1.5

// Splitter parameters

///|
pub let splitter_children : Int = 3

///|
pub let splitter_child_hp_pct : Float = 0.3

// Shield enemy parameters

///|
pub let shield_regen_delay : Float = 3.0

///|
pub let shield_regen_rate : Float = 5.0

///|
pub let shield_max_pct : Float = 0.4

// Game states

///|
pub let state_menu : Int = 0

///|
pub let state_playing : Int = 1

///|
pub let state_paused : Int = 2

///|
pub let state_wave_prep : Int = 3

///|
pub let state_game_over : Int = 4

///|
pub let state_victory : Int = 5

///|
pub let state_building : Int = 6

///|
pub let state_map_select : Int = 7

///|
pub let state_tower_info : Int = 8

// Pools

///|
pub let max_towers : Int = 64

///|
pub let max_enemies : Int = 200

///|
pub let max_projectiles : Int = 300

///|
pub let max_particles : Int = 600

///|
pub let max_path_nodes : Int = 64

///|
pub let max_waves : Int = 30

///|
pub let max_status_effects : Int = 4

// Camera

///|
pub let camera_fovy : Float = 45.0

///|
pub let camera_min_dist : Float = 10.0

///|
pub let camera_max_dist : Float = 40.0

// Economy

///|
pub let starting_gold : Int = 250

///|
pub let starting_lives : Int = 25

///|
pub let kill_gold_base : Int = 10

///|
pub let interest_rate : Float = 0.05

///|
pub let interest_interval : Float = 10.0

///|
pub let interest_cap : Int = 50

///|
pub let wave_completion_bonus : Int = 25

// Wave timing

///|
pub let wave_prep_time : Float = 8.0

///|
pub let spawn_interval : Float = 0.8

///|
pub let fast_spawn_interval : Float = 0.3

// Speed multiplier options

///|
pub let speed_1x : Float = 1.0

///|
pub let speed_2x : Float = 2.0

///|
pub let speed_3x : Float = 3.0

// Difficulty multipliers

///|
pub let difficulty_easy_hp : Float = 0.7

///|
pub let difficulty_easy_speed : Float = 0.9

///|
pub let difficulty_normal_hp : Float = 1.0

///|
pub let difficulty_normal_speed : Float = 1.0

///|
pub let difficulty_hard_hp : Float = 1.4

///|
pub let difficulty_hard_speed : Float = 1.15

// Map count

///|
pub let map_count : Int = 5

// Special ability cooldowns

///|
pub let ability_lightning_chain_cd : Float = 5.0

///|
pub let ability_sniper_crit_cd : Float = 0.0

///|
pub let ability_flame_aura_cd : Float = 3.0

///|
pub let ability_frost_freeze_cd : Float = 8.0

///|
pub let ability_buff_pulse_cd : Float = 12.0

// Visual constants

///|
pub let pi : Float = 3.14159

///|
pub let health_bar_width : Float = 1.2

///|
pub let health_bar_height : Float = 0.08

///|
pub let tower_base_height : Float = 0.6

///|
pub let tower_body_height : Float = 1.4

///|
pub let minimap_size : Int = 150

///|
pub let minimap_x : Int = 10

///|
pub let minimap_y : Int = 60
