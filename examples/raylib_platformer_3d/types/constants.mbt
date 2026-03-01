///|
pub let screen_width : Int = 1024

///|
pub let screen_height : Int = 768

// ========== Physics ==========

///|
pub let gravity : Float = 25.0

///|
pub let jump_force : Float = 10.0

///|
pub let move_speed : Float = 6.0

///|
pub let air_control : Float = 0.4

///|
pub let max_fall_speed : Float = 30.0

///|
pub let coyote_time : Float = 0.1

///|
pub let jump_buffer : Float = 0.1

///|
pub let wall_slide_speed : Float = 3.0

///|
pub let wall_jump_h_force : Float = 7.0

///|
pub let wall_jump_v_force : Float = 9.0

///|
pub let double_jump_force : Float = 8.5

///|
pub let ground_friction : Float = 0.85

///|
pub let ice_friction : Float = 0.98

///|
pub let air_friction : Float = 0.92

///|
pub let dash_speed : Float = 14.0

///|
pub let dash_duration : Float = 0.15

///|
pub let dash_cooldown : Float = 0.6

///|
pub let player_accel_mult : Float = 10.0

// ========== Player ==========

///|
pub let player_radius : Float = 0.4

///|
pub let player_height : Float = 0.8

///|
pub let player_max_lives : Int = 5

///|
pub let invincible_time : Float = 1.5

///|
pub let respawn_height : Float = 2.0

///|
pub let death_fall_y : Float = -20.0

// ========== Camera ==========

///|
pub let camera_fovy : Float = 60.0

///|
pub let camera_dist : Float = 8.0

///|
pub let camera_height : Float = 4.0

///|
pub let camera_smooth : Float = 8.0

///|
pub let camera_rotate_speed : Float = 90.0

///|
pub let camera_min_dist : Float = 4.0

///|
pub let camera_max_dist : Float = 14.0

///|
pub let camera_zoom_speed : Float = 3.0

///|
pub let camera_shake_decay : Float = 5.0

// ========== Pool sizes ==========

///|
pub let max_platforms : Int = 128

///|
pub let max_collectibles : Int = 64

///|
pub let max_hazards : Int = 32

///|
pub let max_particles : Int = 512

///|
pub let max_checkpoints : Int = 8

///|
pub let max_enemies : Int = 32

///|
pub let max_powerups : Int = 16

///|
pub let max_decorations : Int = 64

///|
pub let max_projectiles : Int = 32

// ========== Game states ==========

///|
pub let state_menu : Int = 0

///|
pub let state_playing : Int = 1

///|
pub let state_paused : Int = 2

///|
pub let state_level_complete : Int = 3

///|
pub let state_game_over : Int = 4

///|
pub let state_world_select : Int = 5

///|
pub let state_campaign_complete : Int = 6

///|
pub let state_level_select : Int = 7

///|
pub let state_death_anim : Int = 8

///|
pub let state_world_intro : Int = 9

// ========== Platform types ==========

///|
pub let plat_static : Int = 0

///|
pub let plat_moving_x : Int = 1

///|
pub let plat_moving_y : Int = 2

///|
pub let plat_moving_z : Int = 3

///|
pub let plat_falling : Int = 4

///|
pub let plat_bouncy : Int = 5

///|
pub let plat_ice : Int = 6

///|
pub let plat_crumbling : Int = 7

///|
pub let plat_rotating : Int = 8

///|
pub let plat_conveyor_l : Int = 9

///|
pub let plat_conveyor_r : Int = 10

///|
pub let plat_phasing : Int = 11

///|
pub let plat_size_pulse : Int = 12

// ========== Collectible types ==========

///|
pub let collect_gem : Int = 0

///|
pub let collect_star : Int = 1

///|
pub let collect_life : Int = 2

///|
pub let collect_spring : Int = 3

///|
pub let collect_coin_bronze : Int = 4

///|
pub let collect_coin_silver : Int = 5

///|
pub let collect_coin_gold : Int = 6

///|
pub let collect_key : Int = 7

// ========== Hazard types ==========

///|
pub let hazard_spike : Int = 0

///|
pub let hazard_lava : Int = 1

///|
pub let hazard_saw : Int = 2

///|
pub let hazard_laser : Int = 3

///|
pub let hazard_fire_jet : Int = 4

///|
pub let hazard_pendulum : Int = 5

///|
pub let hazard_crusher : Int = 6

// ========== Enemy types ==========

///|
pub let enemy_patrol : Int = 0

///|
pub let enemy_bounce : Int = 1

///|
pub let enemy_fly_circle : Int = 2

///|
pub let enemy_chase : Int = 3

///|
pub let enemy_turret : Int = 4

///|
pub let enemy_ghost : Int = 5

// ========== Power-up types ==========

///|
pub let powerup_double_jump : Int = 0

///|
pub let powerup_speed : Int = 1

///|
pub let powerup_shield : Int = 2

///|
pub let powerup_magnet : Int = 3

///|
pub let powerup_slow_fall : Int = 4

// ========== Worlds ==========

///|
pub let num_worlds : Int = 4

///|
pub let levels_per_world : Int = 5

///|
pub let total_levels : Int = 20

// ========== World theme indices ==========

///|
pub let world_forest : Int = 0

///|
pub let world_crystal : Int = 1

///|
pub let world_lava : Int = 2

///|
pub let world_sky : Int = 3

// ========== Bouncy ==========

///|
pub let bounce_force : Float = 15.0

///|
pub let super_bounce_force : Float = 20.0

// ========== Falling platform ==========

///|
pub let fall_delay : Float = 0.5

///|
pub let fall_speed : Float = 8.0

///|
pub let fall_shake_amp : Float = 0.05

// ========== Crumbling ==========

///|
pub let crumble_time : Float = 0.8

// ========== Phasing platform ==========

///|
pub let phase_on_time : Float = 2.0

///|
pub let phase_off_time : Float = 1.5

// ========== Rotating platform ==========

///|
pub let rotate_speed : Float = 1.5

// ========== Conveyor ==========

///|
pub let conveyor_force : Float = 3.0

// ========== Score ==========

///|
pub let gem_score : Int = 10

///|
pub let star_score : Int = 50

///|
pub let coin_bronze_score : Int = 5

///|
pub let coin_silver_score : Int = 20

///|
pub let coin_gold_score : Int = 100

///|
pub let key_score : Int = 200

///|
pub let enemy_kill_score : Int = 30

///|
pub let combo_base_mult : Float = 1.0

///|
pub let combo_increment : Float = 0.5

///|
pub let combo_decay_time : Float = 2.0

///|
pub let combo_max : Float = 5.0

// ========== Enemy parameters ==========

///|
pub let enemy_patrol_speed : Float = 2.0

///|
pub let enemy_bounce_speed : Float = 4.0

///|
pub let enemy_bounce_height : Float = 3.0

///|
pub let enemy_fly_radius : Float = 3.0

///|
pub let enemy_fly_speed : Float = 1.5

///|
pub let enemy_chase_speed : Float = 3.5

///|
pub let enemy_chase_range : Float = 10.0

///|
pub let enemy_turret_range : Float = 12.0

///|
pub let enemy_turret_fire_rate : Float = 2.0

///|
pub let enemy_ghost_speed : Float = 2.0

///|
pub let enemy_ghost_fade_dist : Float = 6.0

///|
pub let enemy_stomp_bounce : Float = 8.0

///|
pub let enemy_size : Float = 0.6

///|
pub let enemy_kill_radius : Float = 0.7

// ========== Power-up parameters ==========

///|
pub let powerup_duration : Float = 8.0

///|
pub let powerup_speed_mult : Float = 1.6

///|
pub let powerup_magnet_range : Float = 5.0

///|
pub let powerup_slow_fall_mult : Float = 0.3

///|
pub let powerup_bob_speed : Float = 3.0

///|
pub let powerup_spin_speed : Float = 4.0

// ========== Particle parameters ==========

///|
pub let particle_jump_count : Int = 6

///|
pub let particle_collect_count : Int = 8

///|
pub let particle_death_count : Int = 16

///|
pub let particle_stomp_count : Int = 10

///|
pub let particle_trail_count : Int = 2

///|
pub let particle_powerup_count : Int = 12

///|
pub let particle_checkpoint_count : Int = 8

///|
pub let particle_landing_count : Int = 4

///|
pub let particle_wall_slide_count : Int = 1

///|
pub let particle_dash_count : Int = 6

// ========== Decoration parameters ==========

///|
pub let deco_tree : Int = 0

///|
pub let deco_rock : Int = 1

///|
pub let deco_crystal : Int = 2

///|
pub let deco_mushroom : Int = 3

///|
pub let deco_pillar : Int = 4

///|
pub let deco_stalagmite : Int = 5

///|
pub let deco_lava_rock : Int = 6

///|
pub let deco_cloud : Int = 7

///|
pub let deco_bush : Int = 8

///|
pub let deco_lamp : Int = 9

// ========== Projectile types ==========

///|
pub let proj_enemy_shot : Int = 0

///|
pub let proj_fire_ball : Int = 1

///|
pub let proj_speed : Float = 8.0

///|
pub let proj_lifetime : Float = 3.0

///|
pub let proj_radius : Float = 0.2

// ========== Level complete stars ==========

///|
pub let star_time_threshold_1 : Float = 60.0

///|
pub let star_time_threshold_2 : Float = 45.0

///|
pub let star_time_threshold_3 : Float = 30.0

///|
pub let star_no_death_bonus : Int = 100

///|
pub let star_all_gems_bonus : Int = 200

// ========== UI animation ==========

///|
pub let ui_fade_speed : Float = 3.0

///|
pub let ui_slide_speed : Float = 5.0

///|
pub let ui_blink_speed : Float = 3.5

///|
pub let ui_score_fly_speed : Float = 2.0

///|
pub let hud_height : Int = 36

///|
pub let hud_combo_bar_width : Int = 120

///|
pub let hud_combo_bar_height : Int = 12

///|
pub let minimap_size : Int = 140

///|
pub let minimap_margin : Int = 10

// ========== World intro ==========

///|
pub let world_intro_duration : Float = 2.5

///|
pub let world_intro_fade : Float = 0.8

// ========== Death animation ==========

///|
pub let death_anim_time : Float = 1.0

///|
pub let death_bounce_height : Float = 5.0

// ========== Checkpoint ==========

///|
pub let checkpoint_activate_range : Float = 1.5

///|
pub let checkpoint_flag_height : Float = 1.5

// ========== Level select grid ==========

///|
pub let level_grid_cols : Int = 5

///|
pub let level_card_w : Int = 140

///|
pub let level_card_h : Int = 100

///|
pub let level_card_gap : Int = 20

// ========== Shadow ==========

///|
pub let shadow_size_base : Float = 0.5

///|
pub let shadow_max_height : Float = 20.0

///|
pub let shadow_min_alpha : Int = 20

///|
pub let shadow_max_alpha : Int = 80

// ========== Math constants ==========

///|
pub let pi : Float = 3.14159265

///|
pub let two_pi : Float = 6.28318530

///|
pub let deg2rad : Float = 0.01745329

///|
pub let rad2deg : Float = 57.2957795

// ========== Forest world colors ==========

///|
pub let forest_plat_r : Int = 80

///|
pub let forest_plat_g : Int = 160

///|
pub let forest_plat_b : Int = 60

///|
pub let forest_bg_r : Int = 100

///|
pub let forest_bg_g : Int = 180

///|
pub let forest_bg_b : Int = 255

///|
pub let forest_fog_r : Int = 140

///|
pub let forest_fog_g : Int = 200

///|
pub let forest_fog_b : Int = 255

///|
pub let forest_tree_r : Int = 60

///|
pub let forest_tree_g : Int = 130

///|
pub let forest_tree_b : Int = 40

///|
pub let forest_trunk_r : Int = 100

///|
pub let forest_trunk_g : Int = 70

///|
pub let forest_trunk_b : Int = 40

// ========== Crystal world colors ==========

///|
pub let crystal_plat_r : Int = 80

///|
pub let crystal_plat_g : Int = 120

///|
pub let crystal_plat_b : Int = 180

///|
pub let crystal_bg_r : Int = 20

///|
pub let crystal_bg_g : Int = 30

///|
pub let crystal_bg_b : Int = 60

///|
pub let crystal_glow_r : Int = 100

///|
pub let crystal_glow_g : Int = 150

///|
pub let crystal_glow_b : Int = 255

///|
pub let crystal_ice_r : Int = 150

///|
pub let crystal_ice_g : Int = 210

///|
pub let crystal_ice_b : Int = 240

// ========== Lava world colors ==========

///|
pub let lava_plat_r : Int = 160

///|
pub let lava_plat_g : Int = 80

///|
pub let lava_plat_b : Int = 40

///|
pub let lava_bg_r : Int = 60

///|
pub let lava_bg_g : Int = 20

///|
pub let lava_bg_b : Int = 10

///|
pub let lava_glow_r : Int = 255

///|
pub let lava_glow_g : Int = 100

///|
pub let lava_glow_b : Int = 20

///|
pub let lava_rock_r : Int = 80

///|
pub let lava_rock_g : Int = 50

///|
pub let lava_rock_b : Int = 30

// ========== Sky world colors ==========

///|
pub let sky_plat_r : Int = 140

///|
pub let sky_plat_g : Int = 140

///|
pub let sky_plat_b : Int = 160

///|
pub let sky_bg_r : Int = 180

///|
pub let sky_bg_g : Int = 200

///|
pub let sky_bg_b : Int = 240

///|
pub let sky_cloud_r : Int = 240

///|
pub let sky_cloud_g : Int = 245

///|
pub let sky_cloud_b : Int = 255

///|
pub let sky_pillar_r : Int = 200

///|
pub let sky_pillar_g : Int = 195

///|
pub let sky_pillar_b : Int = 210

// ========== Player colors ==========

///|
pub let player_body_r : Int = 60

///|
pub let player_body_g : Int = 140

///|
pub let player_body_b : Int = 220

///|
pub let player_head_r : Int = 80

///|
pub let player_head_g : Int = 170

///|
pub let player_head_b : Int = 250

///|
pub let player_eye_r : Int = 255

///|
pub let player_eye_g : Int = 255

///|
pub let player_eye_b : Int = 255

///|
pub let player_arm_r : Int = 50

///|
pub let player_arm_g : Int = 120

///|
pub let player_arm_b : Int = 200

///|
pub let player_leg_r : Int = 40

///|
pub let player_leg_g : Int = 100

///|
pub let player_leg_b : Int = 180

///|
pub let player_shield_r : Int = 100

///|
pub let player_shield_g : Int = 200

///|
pub let player_shield_b : Int = 255

///|
pub let player_shield_a : Int = 80

// ========== Gem colors ==========

///|
pub let gem_r : Int = 0

///|
pub let gem_g : Int = 255

///|
pub let gem_b : Int = 100

///|
pub let star_r : Int = 255

///|
pub let star_g : Int = 255

///|
pub let star_b : Int = 0

///|
pub let coin_bronze_r : Int = 180

///|
pub let coin_bronze_g : Int = 130

///|
pub let coin_bronze_b : Int = 70

///|
pub let coin_silver_r : Int = 200

///|
pub let coin_silver_g : Int = 200

///|
pub let coin_silver_b : Int = 210

///|
pub let coin_gold_r : Int = 255

///|
pub let coin_gold_g : Int = 215

///|
pub let coin_gold_b : Int = 0

///|
pub let key_r : Int = 255

///|
pub let key_g : Int = 200

///|
pub let key_b : Int = 50

// ========== Goal colors ==========

///|
pub let goal_inner_r : Int = 255

///|
pub let goal_inner_g : Int = 215

///|
pub let goal_inner_b : Int = 0

///|
pub let goal_outer_r : Int = 255

///|
pub let goal_outer_g : Int = 255

///|
pub let goal_outer_b : Int = 100

// ========== Enemy colors ==========

///|
pub let enemy_patrol_r : Int = 200

///|
pub let enemy_patrol_g : Int = 60

///|
pub let enemy_patrol_b : Int = 60

///|
pub let enemy_bounce_r : Int = 180

///|
pub let enemy_bounce_g : Int = 100

///|
pub let enemy_bounce_b : Int = 200

///|
pub let enemy_fly_r : Int = 200

///|
pub let enemy_fly_g : Int = 150

///|
pub let enemy_fly_b : Int = 50

///|
pub let enemy_chase_r : Int = 220

///|
pub let enemy_chase_g : Int = 50

///|
pub let enemy_chase_b : Int = 50

///|
pub let enemy_turret_r : Int = 120

///|
pub let enemy_turret_g : Int = 120

///|
pub let enemy_turret_b : Int = 130

///|
pub let enemy_ghost_r : Int = 160

///|
pub let enemy_ghost_g : Int = 180

///|
pub let enemy_ghost_b : Int = 220

// ========== Hazard colors ==========

///|
pub let spike_r : Int = 200

///|
pub let spike_g : Int = 200

///|
pub let spike_b : Int = 200

///|
pub let saw_r : Int = 180

///|
pub let saw_g : Int = 180

///|
pub let saw_b : Int = 180

///|
pub let laser_r : Int = 255

///|
pub let laser_g : Int = 50

///|
pub let laser_b : Int = 50

///|
pub let fire_jet_r : Int = 255

///|
pub let fire_jet_g : Int = 150

///|
pub let fire_jet_b : Int = 30

// ========== Power-up colors ==========

///|
pub let pu_double_jump_r : Int = 100

///|
pub let pu_double_jump_g : Int = 200

///|
pub let pu_double_jump_b : Int = 255

///|
pub let pu_speed_r : Int = 255

///|
pub let pu_speed_g : Int = 200

///|
pub let pu_speed_b : Int = 50

///|
pub let pu_shield_r : Int = 100

///|
pub let pu_shield_g : Int = 255

///|
pub let pu_shield_b : Int = 200

///|
pub let pu_magnet_r : Int = 200

///|
pub let pu_magnet_g : Int = 100

///|
pub let pu_magnet_b : Int = 255

///|
pub let pu_slow_fall_r : Int = 200

///|
pub let pu_slow_fall_g : Int = 255

///|
pub let pu_slow_fall_b : Int = 200
