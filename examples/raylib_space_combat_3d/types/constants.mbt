// Screen
pub let screen_width : Int = 1280
pub let screen_height : Int = 720

// Game states
pub let state_menu : Int = 0
pub let state_playing : Int = 1
pub let state_paused : Int = 2
pub let state_mission_complete : Int = 3
pub let state_game_over : Int = 4
pub let state_mission_briefing : Int = 5
pub let state_mission_select : Int = 6
pub let state_loadout : Int = 7

// Ship classes
pub let ship_fighter : Int = 0
pub let ship_interceptor : Int = 1
pub let ship_bomber : Int = 2
pub let ship_cruiser : Int = 3
pub let ship_capital_ship : Int = 4

// Weapon types
pub let weapon_laser : Int = 0
pub let weapon_missile : Int = 1
pub let weapon_plasma : Int = 2
pub let weapon_railgun : Int = 3

// Enemy types
pub let enemy_fighter : Int = 0
pub let enemy_cruiser : Int = 1
pub let enemy_asteroid : Int = 2
pub let enemy_interceptor : Int = 3
pub let enemy_bomber : Int = 4
pub let enemy_capital : Int = 5

// Enemy AI states
pub let ai_idle : Int = 0
pub let ai_patrol : Int = 1
pub let ai_chase : Int = 2
pub let ai_attack : Int = 3
pub let ai_evade : Int = 4
pub let ai_flee : Int = 5
pub let ai_formation : Int = 6

// Power-up types
pub let powerup_health : Int = 0
pub let powerup_shield : Int = 1
pub let powerup_weapon_boost : Int = 2
pub let powerup_speed_boost : Int = 3

// Asteroid size tiers
pub let asteroid_large : Int = 0
pub let asteroid_medium : Int = 1
pub let asteroid_small : Int = 2

// Formation patterns
pub let formation_v : Int = 0
pub let formation_line : Int = 1
pub let formation_circle : Int = 2
pub let formation_wedge : Int = 3

// Pool sizes
pub let max_enemies : Int = 64
pub let max_projectiles : Int = 128
pub let max_particles : Int = 512
pub let max_asteroids : Int = 96
pub let max_stars : Int = 200
pub let max_powerups : Int = 16
pub let max_stations : Int = 4
pub let max_debris : Int = 64

// Ship class stats: hull, shield, speed, turn_rate, boost_speed
// Fighter - balanced
pub let fighter_class_hull : Float = 100.0
pub let fighter_class_shield : Float = 80.0
pub let fighter_class_speed : Float = 40.0
pub let fighter_class_turn : Float = 2.5
pub let fighter_class_boost : Float = 70.0

// Interceptor - fast, fragile
pub let interceptor_class_hull : Float = 70.0
pub let interceptor_class_shield : Float = 50.0
pub let interceptor_class_speed : Float = 55.0
pub let interceptor_class_turn : Float = 3.5
pub let interceptor_class_boost : Float = 90.0

// Bomber - slow, tough, high damage
pub let bomber_class_hull : Float = 150.0
pub let bomber_class_shield : Float = 100.0
pub let bomber_class_speed : Float = 28.0
pub let bomber_class_turn : Float = 1.5
pub let bomber_class_boost : Float = 45.0

// Cruiser class - for player
pub let cruiser_class_hull : Float = 200.0
pub let cruiser_class_shield : Float = 160.0
pub let cruiser_class_speed : Float = 22.0
pub let cruiser_class_turn : Float = 1.2
pub let cruiser_class_boost : Float = 35.0

// Capital class - for player
pub let capital_class_hull : Float = 350.0
pub let capital_class_shield : Float = 250.0
pub let capital_class_speed : Float = 15.0
pub let capital_class_turn : Float = 0.8
pub let capital_class_boost : Float = 22.0

// Player constants (default fighter)
pub let player_max_hull : Float = 100.0
pub let player_max_shield : Float = 80.0
pub let shield_regen_rate : Float = 3.0
pub let shield_regen_delay : Float = 2.5
pub let player_speed : Float = 40.0
pub let player_boost_speed : Float = 70.0
pub let player_turn_speed : Float = 2.5
pub let player_roll_speed : Float = 3.0

// Weapon stats
// Laser: rapid fire, low damage, no ammo cost
pub let laser_damage : Float = 8.0
pub let laser_speed : Float = 120.0
pub let laser_cooldown : Float = 0.12
pub let laser_range : Float = 200.0
pub let laser_energy_cost : Float = 2.0

// Plasma: medium fire, medium damage, energy cost
pub let plasma_damage : Float = 50.0
pub let plasma_speed : Float = 60.0
pub let plasma_cooldown : Float = 1.2
pub let plasma_range : Float = 150.0
pub let plasma_energy_cost : Float = 15.0
pub let plasma_aoe_radius : Float = 5.0

// Missile: slow fire, high damage, limited ammo, homing
pub let missile_damage : Float = 35.0
pub let missile_speed : Float = 50.0
pub let missile_cooldown : Float = 0.8
pub let missile_range : Float = 300.0
pub let missile_turn_rate : Float = 4.0
pub let missile_fuel : Float = 5.0
pub let missile_prox_radius : Float = 3.0
pub let missile_max_ammo : Int = 24

// Railgun: very slow, very high damage, piercing, energy cost
pub let railgun_damage : Float = 80.0
pub let railgun_speed : Float = 250.0
pub let railgun_cooldown : Float = 2.5
pub let railgun_range : Float = 400.0
pub let railgun_energy_cost : Float = 30.0

// Weapon energy
pub let max_weapon_energy : Float = 100.0
pub let weapon_energy_regen : Float = 8.0

// Boost fuel
pub let max_boost_fuel : Float = 100.0
pub let boost_fuel_drain : Float = 25.0
pub let boost_fuel_regen : Float = 10.0

// Enemy stats
pub let fighter_hp : Float = 30.0
pub let fighter_speed : Float = 25.0
pub let fighter_fire_rate : Float = 1.5
pub let fighter_damage : Float = 5.0
pub let fighter_score : Int = 100
pub let fighter_detect_range : Float = 120.0
pub let fighter_attack_range : Float = 80.0
pub let fighter_evade_hp_pct : Float = 0.3
pub let fighter_flee_hp_pct : Float = 0.15

pub let interceptor_hp : Float = 20.0
pub let interceptor_speed : Float = 40.0
pub let interceptor_fire_rate : Float = 0.8
pub let interceptor_damage : Float = 4.0
pub let interceptor_score : Int = 150
pub let interceptor_detect_range : Float = 150.0

pub let bomber_hp : Float = 60.0
pub let bomber_speed : Float = 15.0
pub let bomber_fire_rate : Float = 3.0
pub let bomber_damage : Float = 20.0
pub let bomber_score : Int = 250

pub let cruiser_hp : Float = 120.0
pub let cruiser_speed : Float = 10.0
pub let cruiser_fire_rate : Float = 2.0
pub let cruiser_damage : Float = 12.0
pub let cruiser_score : Int = 500

pub let capital_hp : Float = 500.0
pub let capital_speed : Float = 5.0
pub let capital_fire_rate : Float = 1.0
pub let capital_damage : Float = 25.0
pub let capital_score : Int = 2000
pub let capital_turret_count : Int = 4
pub let capital_weak_point_hp : Float = 80.0

pub let asteroid_hp : Float = 50.0
pub let asteroid_score : Int = 25
pub let asteroid_large_hp : Float = 80.0
pub let asteroid_medium_hp : Float = 40.0
pub let asteroid_small_hp : Float = 15.0
pub let asteroid_large_size : Float = 4.5
pub let asteroid_medium_size : Float = 2.5
pub let asteroid_small_size : Float = 1.2
pub let asteroid_break_count : Int = 3

// Station parameters
pub let station_hp : Float = 300.0
pub let station_friendly : Int = 0
pub let station_enemy : Int = 1
pub let station_dock_range : Float = 15.0

// Power-up parameters
pub let powerup_health_amount : Float = 40.0
pub let powerup_shield_amount : Float = 30.0
pub let powerup_weapon_duration : Float = 10.0
pub let powerup_speed_duration : Float = 8.0
pub let powerup_float_speed : Float = 1.5
pub let powerup_bob_amplitude : Float = 0.5
pub let powerup_spin_speed : Float = 2.0
pub let powerup_collect_radius : Float = 3.0

// Particle effect parameters
pub let particle_thruster_life : Float = 0.5
pub let particle_explosion_life : Float = 1.2
pub let particle_shield_hit_life : Float = 0.4
pub let particle_weapon_trail_life : Float = 0.3
pub let particle_debris_life : Float = 2.0
pub let particle_spark_life : Float = 0.25

// Camera
pub let camera_fovy : Float = 60.0
pub let camera_distance : Float = 12.0
pub let camera_height : Float = 4.0

// World bounds
pub let world_size : Float = 500.0

// Pi
pub let pi : Float = 3.14159265
pub let two_pi : Float = 6.2831853

// Mission count
pub let total_missions : Int = 12

// Combo system
pub let combo_timeout : Float = 3.0
pub let combo_mult_2 : Float = 1.5
pub let combo_mult_3 : Float = 2.0
pub let combo_mult_5 : Float = 3.0
pub let combo_mult_8 : Float = 5.0

// Kill feed
pub let max_kill_feed : Int = 5
pub let kill_feed_duration : Float = 3.0

// Damage flash
pub let damage_flash_duration : Float = 0.3

// Radar/minimap
pub let radar_radius : Int = 60
pub let radar_range : Float = 200.0

// Difficulty scaling per mission
pub fn mission_difficulty_hp_mult(mission : Int) -> Float {
  1.0 + Float::from_int(mission) * 0.15
}

pub fn mission_difficulty_speed_mult(mission : Int) -> Float {
  1.0 + Float::from_int(mission) * 0.05
}

pub fn mission_difficulty_fire_rate_mult(mission : Int) -> Float {
  let base : Float = 1.0 - Float::from_int(mission) * 0.03
  if base < 0.5 { 0.5 } else { base }
}

pub fn mission_difficulty_damage_mult(mission : Int) -> Float {
  1.0 + Float::from_int(mission) * 0.1
}

// Ship class hull by type
pub fn ship_class_hull(ship_class : Int) -> Float {
  if ship_class == ship_fighter {
    fighter_class_hull
  } else if ship_class == ship_interceptor {
    interceptor_class_hull
  } else if ship_class == ship_bomber {
    bomber_class_hull
  } else if ship_class == ship_cruiser {
    cruiser_class_hull
  } else {
    capital_class_hull
  }
}

pub fn ship_class_shield(ship_class : Int) -> Float {
  if ship_class == ship_fighter {
    fighter_class_shield
  } else if ship_class == ship_interceptor {
    interceptor_class_shield
  } else if ship_class == ship_bomber {
    bomber_class_shield
  } else if ship_class == ship_cruiser {
    cruiser_class_shield
  } else {
    capital_class_shield
  }
}

pub fn ship_class_speed(ship_class : Int) -> Float {
  if ship_class == ship_fighter {
    fighter_class_speed
  } else if ship_class == ship_interceptor {
    interceptor_class_speed
  } else if ship_class == ship_bomber {
    bomber_class_speed
  } else if ship_class == ship_cruiser {
    cruiser_class_speed
  } else {
    capital_class_speed
  }
}

pub fn ship_class_turn(ship_class : Int) -> Float {
  if ship_class == ship_fighter {
    fighter_class_turn
  } else if ship_class == ship_interceptor {
    interceptor_class_turn
  } else if ship_class == ship_bomber {
    bomber_class_turn
  } else if ship_class == ship_cruiser {
    cruiser_class_turn
  } else {
    capital_class_turn
  }
}

pub fn ship_class_boost(ship_class : Int) -> Float {
  if ship_class == ship_fighter {
    fighter_class_boost
  } else if ship_class == ship_interceptor {
    interceptor_class_boost
  } else if ship_class == ship_bomber {
    bomber_class_boost
  } else if ship_class == ship_cruiser {
    cruiser_class_boost
  } else {
    capital_class_boost
  }
}

pub fn ship_class_name(ship_class : Int) -> String {
  if ship_class == ship_fighter {
    "Fighter"
  } else if ship_class == ship_interceptor {
    "Interceptor"
  } else if ship_class == ship_bomber {
    "Bomber"
  } else if ship_class == ship_cruiser {
    "Cruiser"
  } else {
    "Capital Ship"
  }
}

// Enemy type score
pub fn enemy_score_value(kind : Int) -> Int {
  if kind == enemy_fighter {
    fighter_score
  } else if kind == enemy_cruiser {
    cruiser_score
  } else if kind == enemy_interceptor {
    interceptor_score
  } else if kind == enemy_bomber {
    bomber_score
  } else if kind == enemy_capital {
    capital_score
  } else {
    asteroid_score
  }
}

// Mission objective types
pub let objective_destroy_all : Int = 0
pub let objective_escort : Int = 1
pub let objective_defend_station : Int = 2
pub let objective_boss_fight : Int = 3
pub let objective_ambush : Int = 4
pub let objective_patrol : Int = 5
pub let objective_survive : Int = 6
pub let objective_destroy_count : Int = 7

pub fn objective_type_name(obj_type : Int) -> String {
  if obj_type == objective_destroy_all {
    "Destroy all enemies"
  } else if obj_type == objective_escort {
    "Escort ally ship"
  } else if obj_type == objective_defend_station {
    "Defend the station"
  } else if obj_type == objective_boss_fight {
    "Destroy the capital ship"
  } else if obj_type == objective_ambush {
    "Survive the ambush"
  } else if obj_type == objective_patrol {
    "Clear patrol waypoints"
  } else if obj_type == objective_survive {
    "Survive for the duration"
  } else if obj_type == objective_destroy_count {
    "Destroy target count"
  } else {
    "Unknown objective"
  }
}
