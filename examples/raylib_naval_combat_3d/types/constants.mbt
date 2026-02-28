// Screen
///|
pub let screen_width : Int = 1024

///|
pub let screen_height : Int = 768

// Game states

///|
pub let state_menu : Int = 0

///|
pub let state_playing : Int = 1

///|
pub let state_paused : Int = 2

///|
pub let state_battle_complete : Int = 3

///|
pub let state_game_over : Int = 4

///|
pub let state_battle_select : Int = 5

///|
pub let state_victory : Int = 6

// Ship classes

///|
pub let class_sloop : Int = 0

///|
pub let class_brigantine : Int = 1

///|
pub let class_frigate : Int = 2

///|
pub let class_galleon : Int = 3

///|
pub let class_man_of_war : Int = 4

// Ship class stats: (max_hull, max_mast_hp, max_rudder_hp, max_crew, cannon_count, base_speed, turn_rate, ship_length, ship_width)
// Sloop: fast, light, small crew

///|
pub let sloop_max_hull : Float = 60.0

///|
pub let sloop_max_mast : Float = 50.0

///|
pub let sloop_max_rudder : Float = 45.0

///|
pub let sloop_max_crew : Int = 20

///|
pub let sloop_cannon_count : Int = 4

///|
pub let sloop_base_speed : Float = 10.0

///|
pub let sloop_turn_rate : Float = 1.8

///|
pub let sloop_length : Float = 3.0

///|
pub let sloop_width : Float = 1.2

// Brigantine: balanced

///|
pub let brigantine_max_hull : Float = 85.0

///|
pub let brigantine_max_mast : Float = 70.0

///|
pub let brigantine_max_rudder : Float = 60.0

///|
pub let brigantine_max_crew : Int = 40

///|
pub let brigantine_cannon_count : Int = 8

///|
pub let brigantine_base_speed : Float = 8.0

///|
pub let brigantine_turn_rate : Float = 1.4

///|
pub let brigantine_length : Float = 4.0

///|
pub let brigantine_width : Float = 1.6

// Frigate: strong, moderate

///|
pub let frigate_max_hull : Float = 120.0

///|
pub let frigate_max_mast : Float = 90.0

///|
pub let frigate_max_rudder : Float = 75.0

///|
pub let frigate_max_crew : Int = 80

///|
pub let frigate_cannon_count : Int = 16

///|
pub let frigate_base_speed : Float = 7.0

///|
pub let frigate_turn_rate : Float = 1.2

///|
pub let frigate_length : Float = 5.0

///|
pub let frigate_width : Float = 2.0

// Galleon: heavy, slow, powerful

///|
pub let galleon_max_hull : Float = 160.0

///|
pub let galleon_max_mast : Float = 110.0

///|
pub let galleon_max_rudder : Float = 90.0

///|
pub let galleon_max_crew : Int = 120

///|
pub let galleon_cannon_count : Int = 20

///|
pub let galleon_base_speed : Float = 5.5

///|
pub let galleon_turn_rate : Float = 0.9

///|
pub let galleon_length : Float = 6.5

///|
pub let galleon_width : Float = 2.4

// Man-of-War: massive fortress

///|
pub let mow_max_hull : Float = 220.0

///|
pub let mow_max_mast : Float = 140.0

///|
pub let mow_max_rudder : Float = 110.0

///|
pub let mow_max_crew : Int = 200

///|
pub let mow_cannon_count : Int = 30

///|
pub let mow_base_speed : Float = 4.5

///|
pub let mow_turn_rate : Float = 0.7

///|
pub let mow_length : Float = 8.0

///|
pub let mow_width : Float = 3.0

// Cannon types

///|
pub let cannon_light : Int = 0

///|
pub let cannon_medium : Int = 1

///|
pub let cannon_heavy : Int = 2

///|
pub let cannon_mortar : Int = 3

///|
pub let cannon_chain_shot : Int = 4

// Cannon stats: damage, range, reload_time, speed, arc

///|
pub let light_cannon_damage : Float = 8.0

///|
pub let light_cannon_range : Float = 35.0

///|
pub let light_cannon_reload : Float = 1.5

///|
pub let light_cannon_speed : Float = 32.0

///|
pub let light_cannon_arc : Float = 4.0

///|
pub let medium_cannon_damage : Float = 14.0

///|
pub let medium_cannon_range : Float = 40.0

///|
pub let medium_cannon_reload : Float = 2.2

///|
pub let medium_cannon_speed : Float = 30.0

///|
pub let medium_cannon_arc : Float = 5.0

///|
pub let heavy_cannon_damage : Float = 22.0

///|
pub let heavy_cannon_range : Float = 45.0

///|
pub let heavy_cannon_reload : Float = 3.5

///|
pub let heavy_cannon_speed : Float = 28.0

///|
pub let heavy_cannon_arc : Float = 6.0

///|
pub let mortar_damage : Float = 30.0

///|
pub let mortar_range : Float = 55.0

///|
pub let mortar_reload : Float = 5.0

///|
pub let mortar_speed : Float = 20.0

///|
pub let mortar_arc : Float = 12.0

///|
pub let chain_shot_damage : Float = 5.0

///|
pub let chain_shot_range : Float = 25.0

///|
pub let chain_shot_reload : Float = 2.0

///|
pub let chain_shot_speed : Float = 25.0

///|
pub let chain_shot_arc : Float = 3.0

// Ammo types

///|
pub let ammo_round_shot : Int = 0

///|
pub let ammo_chain_shot : Int = 1

///|
pub let ammo_grapeshot : Int = 2

// Ammo multipliers

///|
pub let round_shot_hull_mult : Float = 1.0

///|
pub let round_shot_mast_mult : Float = 0.3

///|
pub let round_shot_crew_mult : Float = 0.1

///|
pub let chain_shot_hull_mult : Float = 0.2

///|
pub let chain_shot_mast_mult : Float = 1.5

///|
pub let chain_shot_crew_mult : Float = 0.1

///|
pub let grapeshot_hull_mult : Float = 0.1

///|
pub let grapeshot_mast_mult : Float = 0.1

///|
pub let grapeshot_crew_mult : Float = 2.0

// Wind system

///|
pub let wind_dir_n : Int = 0

///|
pub let wind_dir_ne : Int = 1

///|
pub let wind_dir_e : Int = 2

///|
pub let wind_dir_se : Int = 3

///|
pub let wind_dir_s : Int = 4

///|
pub let wind_dir_sw : Int = 5

///|
pub let wind_dir_w : Int = 6

///|
pub let wind_dir_nw : Int = 7

///|
pub let wind_speed_calm : Float = 0.2

///|
pub let wind_speed_light : Float = 0.5

///|
pub let wind_speed_moderate : Float = 1.0

///|
pub let wind_speed_strong : Float = 1.5

///|
pub let wind_speed_gale : Float = 2.0

///|
pub let wind_gust_frequency : Float = 8.0

///|
pub let wind_gust_duration : Float = 2.0

///|
pub let wind_gust_strength : Float = 0.5

///|
pub let wind_shift_speed : Float = 0.03

// Sailing physics - point of sail coefficients
// Relative wind angle -> speed multiplier

///|
pub let sail_in_irons : Float = 0.05

///|
pub let sail_close_haul : Float = 0.45

///|
pub let sail_beam_reach : Float = 0.85

///|
pub let sail_broad_reach : Float = 1.0

///|
pub let sail_running : Float = 0.75

// In-irons zone: within this angle of dead upwind

///|
pub let in_irons_angle : Float = 0.35
// Close haul zone

///|
pub let close_haul_angle : Float = 1.0
// Beam reach zone

///|
pub let beam_reach_angle : Float = 1.8
// Broad reach zone

///|
pub let broad_reach_angle : Float = 2.5

// Sail states

///|
pub let sail_furled : Int = 0

///|
pub let sail_half : Int = 1

///|
pub let sail_full : Int = 2

// Sail state speed multipliers

///|
pub let sail_furled_mult : Float = 0.05

///|
pub let sail_half_mult : Float = 0.5

///|
pub let sail_full_mult : Float = 1.0

// Ship damage zones

///|
pub let zone_hull : Int = 0

///|
pub let zone_mast : Int = 1

///|
pub let zone_rudder : Int = 2

///|
pub let zone_cannon_deck : Int = 3

// Repair speeds per damage type (HP per second per crew member assigned)

///|
pub let repair_hull_speed : Float = 0.8

///|
pub let repair_mast_speed : Float = 0.5

///|
pub let repair_rudder_speed : Float = 0.6

///|
pub let repair_cannon_speed : Float = 0.4

// Crew action modes

///|
pub let crew_action_sailing : Int = 0

///|
pub let crew_action_cannons : Int = 1

///|
pub let crew_action_repair_hull : Int = 2

///|
pub let crew_action_repair_mast : Int = 3

///|
pub let crew_action_repair_rudder : Int = 4

///|
pub let crew_action_boarding : Int = 5

// AI captain personality types

///|
pub let ai_personality_aggressive : Int = 0

///|
pub let ai_personality_defensive : Int = 1

///|
pub let ai_personality_flanker : Int = 2

///|
pub let ai_personality_retreater : Int = 3

///|
pub let ai_personality_berserker : Int = 4

// Enemy AI states

///|
pub let ai_patrol : Int = 0

///|
pub let ai_chase : Int = 1

///|
pub let ai_attack : Int = 2

///|
pub let ai_retreat : Int = 3

///|
pub let ai_flank : Int = 4

///|
pub let ai_broadside_run : Int = 5

// Battle objective types

///|
pub let objective_destroy_all : Int = 0

///|
pub let objective_capture_flagship : Int = 1

///|
pub let objective_defend_port : Int = 2

///|
pub let objective_escort_convoy : Int = 3

///|
pub let objective_blockade_run : Int = 4

///|
pub let objective_survive_time : Int = 5

// Island types

///|
pub let island_small : Int = 0

///|
pub let island_medium : Int = 1

///|
pub let island_large : Int = 2

///|
pub let island_fortress : Int = 3

// Pool sizes

///|
pub let max_enemies : Int = 16

///|
pub let max_cannonballs : Int = 192

///|
pub let max_particles : Int = 640

///|
pub let max_islands : Int = 32

///|
pub let max_wakes : Int = 256

///|
pub let max_debris : Int = 128

///|
pub let max_messages : Int = 8

// Camera

///|
pub let camera_fovy : Float = 50.0

///|
pub let camera_dist : Float = 18.0

///|
pub let camera_height : Float = 10.0

///|
pub let camera_dist_min : Float = 10.0

///|
pub let camera_dist_max : Float = 30.0

// Physics

///|
pub let gravity : Float = 9.8

///|
pub let cannonball_speed : Float = 30.0

///|
pub let cannonball_life : Float = 4.0

///|
pub let water_drag : Float = 0.98

///|
pub let drift_factor : Float = 0.3

// Player ship defaults (frigate class)

///|
pub let player_max_hp : Float = 120.0

///|
pub let player_turn_speed : Float = 1.2

///|
pub let player_max_sail : Float = 8.0

///|
pub let player_cannon_reload : Float = 1.0

///|
pub let player_cannon_damage : Float = 15.0

///|
pub let player_start_crew : Int = 80

///|
pub let player_start_ammo : Int = 60

// Boarding combat

///|
pub let boarding_range : Float = 3.5

///|
pub let boarding_crew_power : Float = 1.0

///|
pub let boarding_duration : Float = 5.0

// Fortress constants

///|
pub let fortress_base_hp : Float = 200.0

///|
pub let fortress_cannon_count : Int = 6

///|
pub let fortress_fire_rate : Float = 3.0

///|
pub let fortress_cannon_damage : Float = 18.0

///|
pub let fortress_range : Float = 50.0

// Wind

///|
pub let wind_strength : Float = 1.0

// Ocean

///|
pub let ocean_size : Float = 200.0

// Wave parameters

///|
pub let wave_amplitude : Float = 0.3

///|
pub let wave_frequency : Float = 0.15

///|
pub let wave_speed : Float = 1.5

// Pi

///|
pub let pi : Float = 3.14159

///|
pub let two_pi : Float = 6.28318

// Minimap

///|
pub let minimap_x : Int = 860

///|
pub let minimap_y : Int = 80

///|
pub let minimap_size : Int = 150

///|
pub let minimap_scale : Float = 0.7

// Score multipliers

///|
pub let score_sloop_kill : Int = 80

///|
pub let score_brigantine_kill : Int = 150

///|
pub let score_frigate_kill : Int = 250

///|
pub let score_galleon_kill : Int = 400

///|
pub let score_mow_kill : Int = 600

///|
pub let score_fortress_kill : Int = 500

// Reputation thresholds

///|
pub let rep_privateer : Int = 0

///|
pub let rep_captain : Int = 500

///|
pub let rep_commodore : Int = 1500

///|
pub let rep_admiral : Int = 3000

///|
pub let rep_legend : Int = 5000

// Water wake parameters

///|
pub let wake_lifetime : Float = 2.5

///|
pub let wake_max_width : Float = 2.0

///|
pub let wake_min_speed : Float = 1.0

// Debris parameters

///|
pub let debris_lifetime : Float = 8.0

///|
pub let debris_sink_speed : Float = 0.3

// Message display

///|
pub let message_display_time : Float = 3.0

///|
pub let message_fade_time : Float = 1.0

// Battle timer (for survive objectives)

///|
pub let survive_time_default : Float = 120.0

// Convoy speed

///|
pub let convoy_speed : Float = 2.0

///|
pub let convoy_spacing : Float = 8.0

// Fleet command distance

///|
pub let fleet_follow_dist : Float = 15.0

///|
pub let fleet_attack_dist : Float = 30.0
