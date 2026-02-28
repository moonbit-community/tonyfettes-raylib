// Screen
pub let screen_width : Int = 1280
pub let screen_height : Int = 720

// Game states
pub let state_menu : Int = 0
pub let state_playing : Int = 1
pub let state_paused : Int = 2
pub let state_mission_complete : Int = 3
pub let state_game_over : Int = 4
pub let state_aircraft_select : Int = 5
pub let state_mission_briefing : Int = 6

// PI constant
pub let pi : Float = 3.14159265
pub let two_pi : Float = 6.2831853
pub let half_pi : Float = 1.57079632
pub let deg_to_rad : Float = 0.01745329

// Aircraft types
pub let aircraft_trainer : Int = 0
pub let aircraft_fighter : Int = 1
pub let aircraft_bomber : Int = 2
pub let aircraft_interceptor : Int = 3

// Trainer stats
pub let trainer_speed_max : Float = 60.0
pub let trainer_speed_min : Float = 12.0
pub let trainer_turn_rate : Float = 2.0
pub let trainer_roll_rate : Float = 2.8
pub let trainer_climb_rate : Float = 1.5
pub let trainer_fuel_capacity : Float = 120.0
pub let trainer_hp : Float = 80.0
pub let trainer_ammo_mg : Int = 300
pub let trainer_ammo_rockets : Int = 4
pub let trainer_ammo_bombs : Int = 2

// Fighter stats
pub let fighter_speed_max : Float = 90.0
pub let fighter_speed_min : Float = 18.0
pub let fighter_turn_rate : Float = 2.4
pub let fighter_roll_rate : Float = 3.2
pub let fighter_climb_rate : Float = 2.0
pub let fighter_fuel_capacity : Float = 100.0
pub let fighter_hp : Float = 100.0
pub let fighter_ammo_mg : Int = 500
pub let fighter_ammo_rockets : Int = 8
pub let fighter_ammo_bombs : Int = 4

// Bomber stats
pub let bomber_speed_max : Float = 55.0
pub let bomber_speed_min : Float = 15.0
pub let bomber_turn_rate : Float = 1.2
pub let bomber_roll_rate : Float = 1.5
pub let bomber_climb_rate : Float = 0.8
pub let bomber_fuel_capacity : Float = 150.0
pub let bomber_hp : Float = 160.0
pub let bomber_ammo_mg : Int = 200
pub let bomber_ammo_rockets : Int = 6
pub let bomber_ammo_bombs : Int = 12

// Interceptor stats
pub let interceptor_speed_max : Float = 110.0
pub let interceptor_speed_min : Float = 22.0
pub let interceptor_turn_rate : Float = 1.8
pub let interceptor_roll_rate : Float = 2.6
pub let interceptor_climb_rate : Float = 2.8
pub let interceptor_fuel_capacity : Float = 80.0
pub let interceptor_hp : Float = 70.0
pub let interceptor_ammo_mg : Int = 400
pub let interceptor_ammo_rockets : Int = 12
pub let interceptor_ammo_bombs : Int = 0

// Player aircraft (legacy / defaults)
pub let aircraft_speed_min : Float = 15.0
pub let aircraft_speed_max : Float = 80.0
pub let aircraft_speed_start : Float = 40.0
pub let aircraft_throttle_accel : Float = 20.0
pub let aircraft_pitch_rate : Float = 1.8
pub let aircraft_yaw_rate : Float = 1.2
pub let aircraft_roll_rate : Float = 2.5
pub let aircraft_gravity : Float = 9.8
pub let aircraft_lift_factor : Float = 0.15
pub let aircraft_drag : Float = 0.02
pub let aircraft_size : Float = 1.5
pub let aircraft_max_fuel : Float = 100.0
pub let aircraft_fuel_rate : Float = 1.5
pub let aircraft_min_altitude : Float = 0.5

// Stall parameters
pub let stall_speed_threshold : Float = 0.7
pub let stall_recovery_pitch : Float = 0.3
pub let stall_nose_drop_rate : Float = 1.5
pub let stall_control_reduction : Float = 0.3
pub let stall_warning_speed_ratio : Float = 0.8

// Altitude effects
pub let altitude_thin_air_start : Float = 60.0
pub let altitude_thin_air_max : Float = 120.0
pub let altitude_control_min : Float = 0.4
pub let altitude_engine_min : Float = 0.5

// Fuel consumption rates
pub let fuel_idle_rate : Float = 0.3
pub let fuel_cruise_rate : Float = 1.0
pub let fuel_afterburner_rate : Float = 3.0
pub let fuel_warning_threshold : Float = 0.2
pub let fuel_critical_threshold : Float = 0.1

// Camera
pub let camera_fovy : Float = 65.0
pub let camera_distance : Float = 12.0
pub let camera_height : Float = 4.0
pub let camera_smooth : Float = 5.0
pub let camera_mode_chase : Int = 0
pub let camera_mode_cockpit : Int = 1
pub let camera_mode_free : Int = 2
pub let camera_cockpit_fov : Float = 80.0

// Terrain
pub let terrain_grid_size : Int = 16
pub let terrain_chunk_scale : Float = 8.0
pub let terrain_max_height : Float = 15.0
pub let terrain_view_range : Int = 8
pub let max_terrain_chunks : Int = 256
pub let terrain_water_level : Float = 1.0
pub let terrain_snow_level : Float = 12.0
pub let terrain_forest_level : Float = 5.0

// Weapon types
pub let weapon_machine_gun : Int = 0
pub let weapon_rockets : Int = 1
pub let weapon_bombs : Int = 2

// Machine gun parameters
pub let mg_fire_rate : Float = 0.08
pub let mg_damage : Float = 12.0
pub let mg_speed : Float = 150.0
pub let mg_range : Float = 80.0
pub let mg_spread : Float = 0.02

// Rocket parameters
pub let rocket_fire_rate : Float = 0.5
pub let rocket_damage : Float = 60.0
pub let rocket_speed : Float = 100.0
pub let rocket_range : Float = 120.0
pub let rocket_thrust : Float = 40.0
pub let rocket_gravity : Float = 2.0

// Bomb parameters
pub let bomb_fire_rate : Float = 0.8
pub let bomb_damage : Float = 120.0
pub let bomb_blast_radius : Float = 8.0
pub let bomb_gravity : Float = 9.8

// Projectiles
pub let max_projectiles : Int = 128
pub let projectile_speed : Float = 120.0
pub let projectile_life : Float = 2.0
pub let projectile_damage : Float = 25.0
pub let fire_cooldown : Float = 0.15

// Projectile types
pub let proj_bullet : Int = 0
pub let proj_rocket : Int = 1
pub let proj_bomb : Int = 2
pub let proj_aa_shell : Int = 3

// Enemies
pub let max_enemies : Int = 32
pub let enemy_air_speed : Float = 20.0
pub let enemy_ground_size : Float = 2.0
pub let enemy_air_size : Float = 1.8
pub let enemy_hp_air : Float = 50.0
pub let enemy_hp_ground : Float = 80.0
pub let enemy_fire_rate : Float = 2.0
pub let enemy_fire_range : Float = 60.0
pub let enemy_type_air : Int = 0
pub let enemy_type_ground : Int = 1

// Enemy AI states
pub let ai_patrol : Int = 0
pub let ai_engage : Int = 1
pub let ai_evade : Int = 2
pub let ai_flee : Int = 3
pub let ai_formation : Int = 4

// Enemy AI parameters
pub let ai_engage_range : Float = 80.0
pub let ai_disengage_range : Float = 150.0
pub let ai_flee_hp_ratio : Float = 0.2
pub let ai_evade_duration : Float = 3.0
pub let ai_formation_spacing : Float = 8.0

// Turrets
pub let max_turrets : Int = 16
pub let turret_fire_rate : Float = 1.5
pub let turret_range : Float = 70.0
pub let turret_hp : Float = 100.0
pub let turret_rotation_speed : Float = 1.0
pub let turret_shell_speed : Float = 80.0

// Buildings
pub let max_buildings : Int = 32
pub let building_hangar : Int = 0
pub let building_tower : Int = 1
pub let building_runway : Int = 2
pub let building_house : Int = 3
pub let building_factory : Int = 4
pub let building_bunker : Int = 5

// Particles
pub let max_particles : Int = 512
pub let particle_exhaust : Int = 0
pub let particle_smoke : Int = 1
pub let particle_fire : Int = 2
pub let particle_tracer : Int = 3
pub let particle_explosion : Int = 4
pub let particle_debris : Int = 5
pub let particle_rain : Int = 6
pub let particle_spark : Int = 7

// Checkpoints
pub let max_checkpoints : Int = 16
pub let checkpoint_radius : Float = 8.0

// Mission types
pub let mission_checkpoint : Int = 0
pub let mission_destroy : Int = 1
pub let mission_landing : Int = 2
pub let mission_survive : Int = 3
pub let mission_escort : Int = 4
pub let mission_patrol : Int = 5
pub let mission_intercept : Int = 6
pub let mission_bombing_run : Int = 7
pub let mission_dogfight : Int = 8
pub let mission_recon : Int = 9
pub let mission_defense : Int = 10
pub let mission_attack_base : Int = 11
pub let mission_canyon_run : Int = 12
pub let mission_night_mission : Int = 13
pub let mission_boss : Int = 14
pub let total_missions : Int = 15

// Weather
pub let weather_clear : Int = 0
pub let weather_cloudy : Int = 1
pub let weather_fog : Int = 2
pub let weather_rain : Int = 3
pub let weather_storm : Int = 4
pub let weather_night : Int = 5

// Weather parameters
pub let fog_clear_dist : Float = 200.0
pub let fog_cloudy_dist : Float = 150.0
pub let fog_fog_dist : Float = 80.0
pub let fog_rain_dist : Float = 100.0
pub let fog_storm_dist : Float = 50.0
pub let fog_night_dist : Float = 120.0

// Turbulence strength by weather
pub let turb_clear : Float = 0.0
pub let turb_cloudy : Float = 0.1
pub let turb_fog : Float = 0.05
pub let turb_rain : Float = 0.3
pub let turb_storm : Float = 0.6
pub let turb_night : Float = 0.05

// Wind parameters
pub let wind_clear : Float = 0.0
pub let wind_cloudy : Float = 2.0
pub let wind_fog : Float = 1.0
pub let wind_rain : Float = 5.0
pub let wind_storm : Float = 10.0
pub let wind_night : Float = 1.5

// Cloud parameters
pub let cloud_base_height : Float = 50.0
pub let cloud_layer_thickness : Float = 10.0
pub let max_clouds : Int = 40

// Landing parameters
pub let landing_glide_slope : Float = 0.05
pub let landing_max_speed : Float = 25.0
pub let landing_max_pitch : Float = 0.2
pub let landing_max_roll : Float = 0.3
pub let landing_zone_radius : Float = 15.0
pub let landing_hold_time : Float = 1.5

// G-force parameters
pub let gforce_normal : Float = 1.0
pub let gforce_max : Float = 6.0
pub let gforce_blackout : Float = 7.0
pub let gforce_damage_threshold : Float = 8.0

// Scoring
pub let score_checkpoint : Int = 100
pub let score_air_kill : Int = 150
pub let score_ground_kill : Int = 75
pub let score_turret_kill : Int = 50
pub let score_building_destroy : Int = 100
pub let score_mission_complete : Int = 500
pub let score_landing_bonus : Int = 200

// Mission rating thresholds
pub let rating_s_threshold : Int = 2000
pub let rating_a_threshold : Int = 1500
pub let rating_b_threshold : Int = 1000
pub let rating_c_threshold : Int = 500

// Building types (extended)
pub let building_barracks : Int = 6
pub let building_fuel_depot : Int = 7
pub let building_radar : Int = 8
pub let building_command : Int = 9

// Building HP values
pub let hp_hangar : Float = 200.0
pub let hp_tower : Float = 80.0
pub let hp_house : Float = 60.0
pub let hp_factory : Float = 250.0
pub let hp_bunker : Float = 300.0
pub let hp_barracks : Float = 120.0
pub let hp_fuel_depot : Float = 90.0
pub let hp_radar : Float = 70.0
pub let hp_command : Float = 180.0

// Weapon damage multipliers by aircraft type
pub let trainer_damage_mult : Float = 0.8
pub let fighter_damage_mult : Float = 1.0
pub let bomber_damage_mult : Float = 1.3
pub let interceptor_damage_mult : Float = 1.1

// Weapon fire rate multipliers by aircraft type
pub let trainer_firerate_mult : Float = 1.2
pub let fighter_firerate_mult : Float = 1.0
pub let bomber_firerate_mult : Float = 0.7
pub let interceptor_firerate_mult : Float = 0.9

// Scoring constants (extended)
pub let score_accuracy_bonus_90 : Int = 500
pub let score_accuracy_bonus_70 : Int = 300
pub let score_accuracy_bonus_50 : Int = 150
pub let score_no_damage_bonus : Int = 400
pub let score_time_bonus_fast : Int = 500
pub let score_time_bonus_good : Int = 300
pub let score_time_bonus_ok : Int = 150
pub let score_kill_streak_3 : Int = 100
pub let score_kill_streak_5 : Int = 250
pub let score_kill_streak_10 : Int = 500

// Kill values per enemy type
pub let kill_value_fighter : Int = 150
pub let kill_value_ground : Int = 75
pub let kill_value_turret : Int = 50
pub let kill_value_building : Int = 100
pub let kill_value_boss : Int = 500

// Weather effect parameters (extended)
pub let rain_particle_count : Int = 30
pub let rain_line_length : Float = 1.5
pub let fog_ground_alpha : Int = 60
pub let storm_flash_interval : Float = 5.0
pub let storm_flash_duration : Float = 0.15

// Cloud count by weather
pub let cloud_count_clear : Int = 8
pub let cloud_count_cloudy : Int = 25
pub let cloud_count_storm : Int = 30
pub let cloud_count_default : Int = 12

// Terrain detail constants
pub let tree_spawn_chance : Float = 0.3
pub let rock_spawn_chance : Float = 0.2
pub let tree_min_height : Float = 3.0
pub let tree_max_height : Float = 8.0
pub let rock_min_size : Float = 0.5
pub let rock_max_size : Float = 2.0

// Radar constants
pub let radar_range : Float = 120.0
pub let radar_size : Int = 100
pub let radar_blip_size : Int = 3
pub let radar_sweep_speed : Float = 2.0

// Warning flash rates
pub let warning_flash_rate : Float = 4.0
pub let warning_fuel_rate : Float = 3.0
pub let warning_stall_rate : Float = 6.0
pub let warning_altitude_rate : Float = 5.0

// Mission par times (for time bonus calculation)
pub let par_time_training : Float = 60.0
pub let par_time_ground_strike : Float = 90.0
pub let par_time_dogfight : Float = 120.0
pub let par_time_fog_nav : Float = 90.0
pub let par_time_landing : Float = 60.0
pub let par_time_valley : Float = 150.0
pub let par_time_storm : Float = 120.0
pub let par_time_air_sup : Float = 120.0
pub let par_time_base_raid : Float = 180.0
pub let par_time_survival : Float = 60.0
pub let par_time_night : Float = 120.0
pub let par_time_canyon : Float = 90.0
pub let par_time_defense : Float = 90.0
pub let par_time_storm_surv : Float = 90.0
pub let par_time_final : Float = 240.0
