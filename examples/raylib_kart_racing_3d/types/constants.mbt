// Screen
pub let screen_width : Int = 1024
pub let screen_height : Int = 768

// Game states
pub let state_menu : Int = 0
pub let state_countdown : Int = 1
pub let state_racing : Int = 2
pub let state_paused : Int = 3
pub let state_race_complete : Int = 4
pub let state_cup_complete : Int = 5
pub let state_kart_select : Int = 6
pub let state_track_preview : Int = 7

// Kart constants
pub let max_karts : Int = 8
pub let player_kart : Int = 0
pub let kart_width : Float = 0.8
pub let kart_height : Float = 0.5
pub let kart_length : Float = 1.2

// Kart type indices
pub let kart_type_balanced : Int = 0
pub let kart_type_speed : Int = 1
pub let kart_type_accel : Int = 2
pub let kart_type_handling : Int = 3
pub let kart_type_heavy : Int = 4
pub let kart_type_drift : Int = 5
pub let kart_type_turbo : Int = 6
pub let kart_type_feather : Int = 7
pub let kart_type_count : Int = 8

// Kart type stats: (max_speed, acceleration, handling, weight, drift_boost)
pub let kart_stats : Array[(Float, Float, Float, Float, Float)] = [
  (28.0, 18.0, 2.8, 1.0, 1.0),  // Balanced
  (33.0, 15.0, 2.4, 0.9, 0.8),  // Speed - fast top speed, slower accel
  (25.0, 24.0, 2.6, 0.8, 0.9),  // Accel - quick acceleration
  (26.0, 17.0, 3.5, 0.7, 1.1),  // Handling - tight turns
  (30.0, 12.0, 2.0, 1.5, 0.7),  // Heavy - high top speed, poor handling
  (27.0, 16.0, 3.0, 0.9, 1.5),  // Drift - massive drift boosts
  (32.0, 20.0, 2.2, 0.8, 1.2),  // Turbo - good speed and accel, poor handling
  (24.0, 22.0, 3.2, 0.5, 1.0),  // Feather - light, nimble, slow
]

// Kart type names
pub let kart_type_names : Array[String] = [
  "Balanced", "Speed", "Accel", "Handling",
  "Heavy", "Drift", "Turbo", "Feather",
]

// Character names for racers
pub let character_names : Array[String] = [
  "Dash", "Blaze", "Leaf", "Sunny",
  "Violet", "Frost", "Ember", "Ghost",
]

// Physics
pub let kart_accel : Float = 18.0
pub let kart_brake : Float = 25.0
pub let kart_max_speed : Float = 28.0
pub let kart_friction : Float = 8.0
pub let kart_steer_speed : Float = 2.8
pub let drift_steer_mult : Float = 1.6
pub let drift_friction_mult : Float = 0.6
pub let drift_boost_time : Float = 0.8
pub let drift_boost_speed : Float = 8.0
pub let gravity : Float = 20.0
pub let kart_bounce : Float = 0.3
pub let jump_ramp_force : Float = 12.0
pub let air_steer_mult : Float = 0.4

// Powerup types
pub let powerup_none : Int = 0
pub let powerup_boost : Int = 1
pub let powerup_shield : Int = 2
pub let powerup_missile : Int = 3
pub let powerup_oil_slick : Int = 4
pub let powerup_lightning : Int = 5
pub let powerup_star : Int = 6
pub let powerup_banana : Int = 7
pub let powerup_triple_mushroom : Int = 8
pub let powerup_type_count : Int = 9

// Powerup effects
pub let boost_duration : Float = 2.0
pub let boost_speed_add : Float = 12.0
pub let shield_duration : Float = 5.0
pub let missile_speed : Float = 40.0
pub let oil_slick_lifetime : Float = 15.0
pub let lightning_duration : Float = 4.0
pub let lightning_slow_mult : Float = 0.5
pub let star_duration : Float = 6.0
pub let star_speed_add : Float = 6.0
pub let banana_lifetime : Float = 20.0
pub let triple_mushroom_boost : Float = 1.2

// Object pools
pub let max_powerups : Int = 32
pub let max_projectiles : Int = 16
pub let max_particles : Int = 256
pub let max_dropped_items : Int = 24

// Track segment types
pub let seg_straight : Int = 0
pub let seg_curve_gentle : Int = 1
pub let seg_curve_sharp : Int = 2
pub let seg_s_curve : Int = 3
pub let seg_chicane : Int = 4
pub let seg_jump_ramp : Int = 5
pub let seg_tunnel : Int = 6
pub let seg_bridge : Int = 7

// Track surface types
pub let surface_road : Int = 0
pub let surface_dirt : Int = 1
pub let surface_grass : Int = 2
pub let surface_boost_pad : Int = 3
pub let surface_oil : Int = 4
pub let surface_ice : Int = 5

// Surface grip multipliers
pub let grip_road : Float = 1.0
pub let grip_dirt : Float = 0.7
pub let grip_grass : Float = 0.5
pub let grip_boost_pad : Float = 1.0
pub let grip_oil : Float = 0.3
pub let grip_ice : Float = 0.35

// Surface speed multipliers
pub let speed_mult_road : Float = 1.0
pub let speed_mult_dirt : Float = 0.75
pub let speed_mult_grass : Float = 0.55
pub let speed_mult_boost_pad : Float = 1.3
pub let speed_mult_oil : Float = 0.9
pub let speed_mult_ice : Float = 0.95

// Drift boost levels
pub let drift_level_none : Int = 0
pub let drift_level_mini : Int = 1
pub let drift_level_super : Int = 2
pub let drift_level_ultra : Int = 3

// Drift level timing thresholds (seconds of sustained drift)
pub let drift_mini_threshold : Float = 0.6
pub let drift_super_threshold : Float = 1.5
pub let drift_ultra_threshold : Float = 2.8

// Drift boost power per level
pub let drift_mini_boost : Float = 4.0
pub let drift_super_boost : Float = 8.0
pub let drift_ultra_boost : Float = 14.0

// Drift boost duration per level
pub let drift_mini_duration : Float = 0.4
pub let drift_super_duration : Float = 0.8
pub let drift_ultra_duration : Float = 1.3

// Track
pub let max_waypoints : Int = 64
pub let road_width : Float = 8.0
pub let road_half : Float = 4.0
pub let total_laps : Int = 3

// Cup / race
pub let cups_count : Int = 4
pub let races_per_cup : Int = 4

// Cup point system (position 1-8)
pub let cup_points_table : Array[Int] = [15, 12, 10, 8, 6, 5, 4, 3]

// Camera
pub let camera_fovy : Float = 55.0
pub let camera_dist : Float = 8.0
pub let camera_height : Float = 4.0
pub let camera_smooth : Float = 5.0
pub let camera_drift_offset : Float = 1.5
pub let camera_boost_fov_add : Float = 8.0

// AI rubber-banding
pub let ai_base_speed_mult : Float = 0.92
pub let ai_rubberband_behind : Float = 0.12
pub let ai_rubberband_ahead : Float = 0.08
pub let ai_difficulty_easy : Int = 0
pub let ai_difficulty_medium : Int = 1
pub let ai_difficulty_hard : Int = 2
pub let ai_difficulty_expert : Int = 3

// AI difficulty modifiers: (speed_mult, item_luck, line_accuracy, reaction_time)
pub let ai_difficulty_stats : Array[(Float, Float, Float, Float)] = [
  (0.85, 0.7, 0.6, 1.5),   // Easy
  (0.92, 0.85, 0.8, 1.0),  // Medium
  (0.97, 1.0, 0.92, 0.6),  // Hard
  (1.02, 1.1, 0.98, 0.3),  // Expert
]

// Countdown
pub let countdown_total : Float = 3.0

// Colors for karts (r,g,b)
pub let kart_colors : Array[(Int, Int, Int)] = [
  (220, 40, 40),    // Player - Red
  (40, 100, 220),   // Blue
  (40, 200, 40),    // Green
  (220, 200, 40),   // Yellow
  (200, 60, 200),   // Purple
  (40, 200, 200),   // Cyan
  (220, 130, 40),   // Orange
  (200, 200, 200),  // White
]

// Track theme indices
pub let theme_circuit : Int = 0
pub let theme_beach : Int = 1
pub let theme_mountain : Int = 2
pub let theme_castle : Int = 3
pub let theme_desert : Int = 4
pub let theme_ice : Int = 5
pub let theme_night : Int = 6
pub let theme_volcano : Int = 7

// Theme sky colors (r, g, b)
pub let theme_sky_colors : Array[(Int, Int, Int)] = [
  (100, 180, 255),   // Circuit - blue sky
  (130, 200, 255),   // Beach - bright sky
  (140, 160, 200),   // Mountain - hazy
  (80, 90, 140),     // Castle - overcast
  (220, 180, 100),   // Desert - warm
  (180, 210, 240),   // Ice - pale
  (20, 25, 50),      // Night - dark
  (120, 60, 40),     // Volcano - smoky
]

// Theme ground colors (r, g, b)
pub let theme_ground_colors : Array[(Int, Int, Int)] = [
  (80, 160, 60),     // Circuit - green grass
  (220, 200, 140),   // Beach - sand
  (100, 120, 80),    // Mountain - alpine
  (60, 80, 50),      // Castle - dark grass
  (200, 170, 100),   // Desert - sand
  (220, 230, 240),   // Ice - snow
  (40, 50, 40),      // Night - dark
  (80, 50, 35),      // Volcano - dark rock
]

// Wrong way detection
pub let wrong_way_angle_threshold : Float = 2.0
pub let wrong_way_flash_speed : Float = 4.0

// Stun/spin durations
pub let spin_duration : Float = 1.5
pub let lightning_spin_duration : Float = 1.0
pub let bump_spin_threshold : Float = 0.8

// Weight-based collision
pub let weight_bump_force : Float = 3.0
pub let weight_spin_diff : Float = 0.5

// Decoration density
pub let tree_spacing : Float = 8.0
pub let barrier_height : Float = 0.6
pub let barrier_width : Float = 0.3

// PI
pub let pi : Float = 3.14159265
pub let two_pi : Float = 6.28318530
pub let half_pi : Float = 1.57079632

// Item detailed stats: (duration, speed_multiplier, damage_power, cooldown)
pub let item_stats_boost : (Float, Float, Float, Float) = (2.0, 1.4, 0.0, 0.5)
pub let item_stats_shield : (Float, Float, Float, Float) = (5.0, 1.0, 0.0, 1.0)
pub let item_stats_missile : (Float, Float, Float, Float) = (6.0, 1.0, 1.5, 2.0)
pub let item_stats_oil : (Float, Float, Float, Float) = (15.0, 0.5, 0.8, 1.5)
pub let item_stats_lightning : (Float, Float, Float, Float) = (4.0, 0.5, 1.0, 3.0)
pub let item_stats_star : (Float, Float, Float, Float) = (6.0, 1.3, 2.0, 5.0)
pub let item_stats_banana : (Float, Float, Float, Float) = (20.0, 0.0, 1.0, 0.5)
pub let item_stats_triple : (Float, Float, Float, Float) = (1.2, 1.4, 0.0, 0.3)

// Track decoration types
pub let deco_none : Int = 0
pub let deco_tree_green : Int = 1
pub let deco_tree_pine : Int = 2
pub let deco_tree_palm : Int = 3
pub let deco_rock_small : Int = 4
pub let deco_rock_large : Int = 5
pub let deco_barrier_metal : Int = 6
pub let deco_barrier_tire : Int = 7
pub let deco_grandstand : Int = 8
pub let deco_building_small : Int = 9
pub let deco_building_tall : Int = 10
pub let deco_cactus : Int = 11
pub let deco_snow_mound : Int = 12
pub let deco_lava_rock : Int = 13
pub let deco_lamp_post : Int = 14
pub let deco_sign_board : Int = 15
pub let deco_type_count : Int = 16

// Decoration colors by type (r, g, b)
pub let deco_colors : Array[(Int, Int, Int)] = [
  (100, 100, 100),   // none
  (40, 120, 30),     // tree_green
  (30, 80, 40),      // tree_pine
  (50, 140, 40),     // tree_palm
  (110, 105, 95),    // rock_small
  (90, 85, 75),      // rock_large
  (160, 160, 170),   // barrier_metal
  (30, 30, 30),      // barrier_tire
  (180, 170, 150),   // grandstand
  (160, 150, 140),   // building_small
  (140, 140, 150),   // building_tall
  (60, 120, 40),     // cactus
  (230, 235, 240),   // snow_mound
  (100, 40, 20),     // lava_rock
  (120, 120, 130),   // lamp_post
  (180, 180, 40),    // sign_board
]

// Particle configuration constants
pub let particle_gravity : Float = 8.0
pub let particle_drag : Float = 0.97
pub let drift_spark_emit_rate : Int = 3
pub let boost_flame_emit_rate : Int = 3
pub let dust_emit_rate : Int = 6
pub let explosion_particle_count : Int = 15
pub let star_sparkle_rate : Int = 4
pub let confetti_count : Int = 20

// Particle size ranges
pub let particle_size_tiny : Float = 0.03
pub let particle_size_small : Float = 0.05
pub let particle_size_medium : Float = 0.08
pub let particle_size_large : Float = 0.12

// Particle life ranges
pub let particle_life_short : Float = 0.2
pub let particle_life_medium : Float = 0.5
pub let particle_life_long : Float = 0.8

// Extended kart color palette with secondary colors
pub let kart_secondary_colors : Array[(Int, Int, Int)] = [
  (255, 100, 100),   // Player - Light Red
  (100, 150, 255),   // Light Blue
  (100, 230, 100),   // Light Green
  (255, 240, 100),   // Light Yellow
  (240, 120, 240),   // Light Purple
  (100, 240, 240),   // Light Cyan
  (255, 180, 100),   // Light Orange
  (240, 240, 240),   // Bright White
]

// Kart accent colors (for trim/details)
pub let kart_accent_colors : Array[(Int, Int, Int)] = [
  (150, 20, 20),     // Dark Red
  (20, 60, 150),     // Dark Blue
  (20, 130, 20),     // Dark Green
  (180, 160, 20),    // Dark Yellow
  (130, 30, 130),    // Dark Purple
  (20, 140, 140),    // Dark Cyan
  (180, 90, 20),     // Dark Orange
  (140, 140, 140),   // Gray
]

// Character stats modifiers (speed_bonus, accel_bonus, weight_bonus, drift_bonus)
pub let character_stats : Array[(Float, Float, Float, Float)] = [
  (1.0, 1.0, 1.0, 1.0),   // Dash - balanced
  (1.1, 0.9, 0.9, 1.0),   // Blaze - fast
  (0.9, 1.1, 0.8, 1.1),   // Leaf - nimble
  (1.0, 1.0, 0.9, 1.0),   // Sunny - balanced-light
  (0.95, 1.05, 1.0, 1.1), // Violet - drift focus
  (1.05, 0.95, 1.1, 0.9), // Frost - heavy-fast
  (1.1, 1.1, 0.8, 0.9),   // Ember - glass cannon
  (0.9, 0.9, 0.7, 1.2),   // Ghost - light drifter
]

// Track record times (in seconds) for each track
pub let track_record_times : Array[Float] = [
  65.0,   // Green Meadow Oval
  72.0,   // Crosswind Circuit
  68.0,   // Sunny Circuit
  75.0,   // Beach Loop
  80.0,   // Mountain Pass
  78.0,   // Castle Circuit
  85.0,   // S-Curve Challenge
  76.0,   // Bridge Run
  88.0,   // Technical Circuit
  82.0,   // Desert Storm
  90.0,   // Ice Track
  84.0,   // Night City
  95.0,   // Rainbow Road
  92.0,   // Volcano Run
  87.0,   // Deep Trench
  100.0,  // Grand Prix
]

// Track difficulty ratings (1-5 stars)
pub let track_difficulty_ratings : Array[Int] = [
  1,  // Green Meadow Oval
  1,  // Crosswind Circuit
  2,  // Sunny Circuit
  2,  // Beach Loop
  3,  // Mountain Pass
  3,  // Castle Circuit
  3,  // S-Curve Challenge
  3,  // Bridge Run
  4,  // Technical Circuit
  4,  // Desert Storm
  4,  // Ice Track
  4,  // Night City
  5,  // Rainbow Road
  5,  // Volcano Run
  4,  // Deep Trench
  5,  // Grand Prix
]

// Theme-specific decoration mapping: which deco types to use per theme
pub let theme_decorations : Array[Array[Int]] = [
  [1, 4, 6, 8, 15],      // Circuit: green trees, rocks, metal barriers, grandstands, signs
  [3, 4, 7, 15, 0],      // Beach: palm trees, rocks, tire barriers, signs
  [2, 5, 6, 4, 0],       // Mountain: pine trees, large rocks, metal barriers, small rocks
  [6, 9, 10, 15, 4],     // Castle: metal barriers, buildings, tall buildings, signs, rocks
  [11, 5, 15, 4, 0],     // Desert: cactus, large rocks, signs, small rocks
  [12, 2, 6, 4, 0],      // Ice: snow mounds, pine trees, metal barriers, rocks
  [14, 9, 10, 7, 15],    // Night: lamp posts, buildings, tall buildings, tire barriers, signs
  [13, 5, 6, 4, 0],      // Volcano: lava rocks, large rocks, metal barriers, small rocks
]
