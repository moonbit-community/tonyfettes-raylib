// Mission definitions
// Returns (num_fighters, num_cruisers, num_asteroids, hp_mult, speed_mult)
pub fn get_mission_def(
  mission : Int
) -> (Int, Int, Int, Float, Float) {
  if mission == 0 {
    (4, 0, 6, 1.0, 1.0)
  } else if mission == 1 {
    (6, 0, 10, 1.0, 1.0)
  } else if mission == 2 {
    (8, 1, 8, 1.0, 1.0)
  } else if mission == 3 {
    (10, 1, 12, 1.2, 1.0)
  } else if mission == 4 {
    (8, 2, 15, 1.2, 1.1)
  } else if mission == 5 {
    (12, 2, 10, 1.4, 1.1)
  } else if mission == 6 {
    (14, 3, 18, 1.5, 1.2)
  } else if mission == 7 {
    (10, 4, 20, 1.6, 1.2)
  } else if mission == 8 {
    (16, 3, 15, 1.8, 1.3)
  } else if mission == 9 {
    (12, 5, 24, 2.0, 1.3)
  } else if mission == 10 {
    (18, 5, 20, 2.2, 1.4)
  } else {
    (20, 6, 28, 2.5, 1.5)
  }
}

// Extended mission definition
// Returns (interceptors, bombers, capitals, num_stations_friendly, num_stations_enemy, num_powerups, num_waves)
pub fn get_mission_extended(
  mission : Int
) -> (Int, Int, Int, Int, Int, Int, Int) {
  if mission == 0 {
    // Patrol Sweep: basic fighters only, one wave
    (0, 0, 0, 0, 0, 1, 1)
  } else if mission == 1 {
    // Asteroid Clearing: some interceptors in asteroids
    (2, 0, 0, 0, 0, 2, 1)
  } else if mission == 2 {
    // First Contact: first cruiser encounter
    (0, 0, 0, 1, 0, 1, 1)
  } else if mission == 3 {
    // Convoy Defense: defend a friendly station
    (3, 0, 0, 1, 0, 2, 2)
  } else if mission == 4 {
    // Nebula Strike: bombers appear, enemy station
    (2, 2, 0, 0, 1, 2, 2)
  } else if mission == 5 {
    // Supply Raid: attack enemy station
    (4, 1, 0, 0, 1, 3, 2)
  } else if mission == 6 {
    // Deep Space Push: multi-wave, many enemies
    (4, 2, 0, 0, 0, 3, 3)
  } else if mission == 7 {
    // Capital Assault: first capital ship
    (3, 2, 1, 0, 0, 3, 2)
  } else if mission == 8 {
    // Asteroid Siege: heavy asteroids with enemies
    (5, 3, 0, 1, 1, 4, 3)
  } else if mission == 9 {
    // Armada Clash: massive battle
    (6, 3, 0, 1, 1, 4, 3)
  } else if mission == 10 {
    // Final Frontier: everything
    (8, 4, 1, 1, 1, 5, 3)
  } else {
    // Omega Strike: boss rush
    (6, 4, 2, 0, 1, 5, 4)
  }
}

// Mission names
pub fn mission_name(mission : Int) -> String {
  if mission == 0 {
    "Patrol Sweep"
  } else if mission == 1 {
    "Asteroid Clearing"
  } else if mission == 2 {
    "First Contact"
  } else if mission == 3 {
    "Convoy Defense"
  } else if mission == 4 {
    "Nebula Strike"
  } else if mission == 5 {
    "Supply Raid"
  } else if mission == 6 {
    "Deep Space Push"
  } else if mission == 7 {
    "Capital Assault"
  } else if mission == 8 {
    "Asteroid Siege"
  } else if mission == 9 {
    "Armada Clash"
  } else if mission == 10 {
    "Final Frontier"
  } else {
    "Omega Strike"
  }
}

// Mission briefing text
pub fn mission_briefing(mission : Int) -> String {
  if mission == 0 {
    "A routine patrol sweep of Sector 7. Clear out any hostiles you encounter. This should be straightforward - perfect for getting your bearings."
  } else if mission == 1 {
    "An asteroid field in the shipping lanes needs clearing. Watch for hostiles hiding among the rocks. Destroy asteroids blocking navigation routes."
  } else if mission == 2 {
    "We have detected a cruiser-class vessel in the Vega system. Engage and eliminate. This is your first encounter with heavy armor - use missiles wisely."
  } else if mission == 3 {
    "A friendly supply station is under attack. Defend it from incoming waves of fighters and interceptors. The station must survive."
  } else if mission == 4 {
    "Intel reports an enemy staging area inside a nebula. Strike fast and destroy their bomber squadron before they can launch an attack on our fleet."
  } else if mission == 5 {
    "We need supplies captured from an enemy outpost. Destroy the station defenses and any escort ships. Watch for incoming reinforcement waves."
  } else if mission == 6 {
    "Push deep into enemy territory. Expect heavy resistance across multiple waves. Manage your ammo and energy carefully - this will be a long fight."
  } else if mission == 7 {
    "A capital ship has been spotted. It has multiple turrets and a reinforced hull. Target the weak points on its underside. Escort fighters will defend it."
  } else if mission == 8 {
    "An enemy fleet has taken position in a dense asteroid field. Navigate the debris while engaging hostiles. Stations on both sides are in the combat zone."
  } else if mission == 9 {
    "Our fleet engages the main enemy armada. This is a massive battle. Focus on eliminating high-value targets and supporting our station."
  } else if mission == 10 {
    "The final push to the enemy homeworld. A capital ship guards the approach. Destroy all opposition. This is everything we have trained for."
  } else {
    "Omega Strike: a gauntlet of capital ships and elite squadrons. Only the best pilots survive. Eliminate all enemy capital ships to end the war."
  }
}

// Mission objective type for each mission
pub fn mission_objective_type(mission : Int) -> Int {
  if mission == 0 {
    0 // destroy_all
  } else if mission == 1 {
    0 // destroy_all
  } else if mission == 2 {
    0 // destroy_all
  } else if mission == 3 {
    2 // defend_station
  } else if mission == 4 {
    0 // destroy_all
  } else if mission == 5 {
    7 // destroy_count
  } else if mission == 6 {
    0 // destroy_all
  } else if mission == 7 {
    3 // boss_fight
  } else if mission == 8 {
    0 // destroy_all
  } else if mission == 9 {
    7 // destroy_count
  } else if mission == 10 {
    3 // boss_fight
  } else {
    3 // boss_fight
  }
}

// Objective target count (for destroy_count type)
pub fn mission_objective_target(mission : Int) -> Int {
  if mission == 5 {
    15
  } else if mission == 9 {
    20
  } else {
    0
  }
}

// Mission reward score bonus
pub fn mission_reward(mission : Int) -> Int {
  (mission + 1) * 500
}

// Enemy formation pattern for each mission
pub fn mission_formation(mission : Int) -> Int {
  if mission == 0 {
    0 // formation_v
  } else if mission == 1 {
    1 // formation_line
  } else if mission == 2 {
    0 // formation_v
  } else if mission == 3 {
    2 // formation_circle
  } else if mission == 4 {
    3 // formation_wedge
  } else if mission == 5 {
    0 // formation_v
  } else if mission == 6 {
    3 // formation_wedge
  } else if mission == 7 {
    2 // formation_circle
  } else if mission == 8 {
    1 // formation_line
  } else if mission == 9 {
    0 // formation_v
  } else if mission == 10 {
    3 // formation_wedge
  } else {
    2 // formation_circle
  }
}

// Asteroid field density multiplier per mission
pub fn mission_asteroid_density(mission : Int) -> Float {
  if mission == 1 {
    1.5
  } else if mission == 8 {
    2.0
  } else {
    1.0
  }
}

// Station positions for missions that have them
// Returns (station_x, station_y, station_z)
pub fn mission_station_pos(mission : Int, index : Int) -> (Float, Float, Float) {
  if mission == 2 && index == 0 {
    (50.0, 0.0, 80.0)
  } else if mission == 3 && index == 0 {
    (0.0, 0.0, 30.0)
  } else if mission == 4 && index == 0 {
    (-80.0, 10.0, 120.0)
  } else if mission == 5 && index == 0 {
    (100.0, -5.0, 150.0)
  } else if mission == 8 && index == 0 {
    (-30.0, 0.0, 50.0)
  } else if mission == 8 && index == 1 {
    (60.0, 0.0, 100.0)
  } else if mission == 9 && index == 0 {
    (-20.0, 0.0, 40.0)
  } else if mission == 9 && index == 1 {
    (80.0, 0.0, 120.0)
  } else if mission == 10 && index == 0 {
    (0.0, 0.0, 60.0)
  } else if mission == 10 && index == 1 {
    (100.0, -10.0, 180.0)
  } else if mission == 11 && index == 0 {
    (120.0, 0.0, 200.0)
  } else {
    (0.0, 0.0, 100.0)
  }
}

// Boss configuration for boss missions
// Returns (boss_x, boss_y, boss_z, boss_hp_mult)
pub fn mission_boss_config(mission : Int) -> (Float, Float, Float, Float) {
  if mission == 7 {
    (0.0, 0.0, 200.0, 1.0)
  } else if mission == 10 {
    (0.0, 10.0, 250.0, 1.5)
  } else if mission == 11 {
    (50.0, 0.0, 300.0, 2.0)
  } else {
    (0.0, 0.0, 200.0, 1.0)
  }
}

// Wave spawn delay in seconds
pub fn wave_spawn_delay(mission : Int, wave : Int) -> Float {
  ignore(mission)
  if wave == 0 {
    0.0
  } else if wave == 1 {
    15.0
  } else if wave == 2 {
    25.0
  } else {
    35.0
  }
}

// How many enemies to spawn in each wave
// Returns (fighters, interceptors, bombers, cruisers)
pub fn wave_composition(mission : Int, wave : Int) -> (Int, Int, Int, Int) {
  if wave == 0 {
    // First wave is the main mission def
    let def = get_mission_def(mission)
    let ext = get_mission_extended(mission)
    (def.0, ext.0, ext.1, def.1)
  } else if wave == 1 {
    // Reinforcement wave 1
    if mission < 4 {
      (3, 1, 0, 0)
    } else if mission < 8 {
      (4, 2, 1, 1)
    } else {
      (6, 3, 2, 1)
    }
  } else if wave == 2 {
    // Reinforcement wave 2
    if mission < 6 {
      (4, 2, 0, 1)
    } else {
      (6, 3, 2, 2)
    }
  } else {
    // Late waves
    (8, 4, 2, 2)
  }
}

// Power-up spawn positions for a mission
pub fn powerup_spawn_pos(
  mission : Int,
  index : Int
) -> (Float, Float, Float, Int) {
  // Returns (x, y, z, type)
  ignore(mission)
  if index == 0 {
    (30.0, 5.0, 50.0, 0)
  } else if index == 1 {
    (-40.0, -3.0, 80.0, 1)
  } else if index == 2 {
    (60.0, 10.0, 120.0, 2)
  } else if index == 3 {
    (-20.0, 0.0, 60.0, 3)
  } else if index == 4 {
    (80.0, -5.0, 160.0, 0)
  } else {
    (0.0, 8.0, 100.0, 1)
  }
}

// Difficulty description for mission select
pub fn mission_difficulty_text(mission : Int) -> String {
  if mission < 3 {
    "Easy"
  } else if mission < 6 {
    "Medium"
  } else if mission < 9 {
    "Hard"
  } else if mission < 11 {
    "Very Hard"
  } else {
    "Extreme"
  }
}

// Recommended ship class for each mission
pub fn mission_recommended_ship(mission : Int) -> String {
  if mission < 3 {
    "Fighter"
  } else if mission < 5 {
    "Fighter / Interceptor"
  } else if mission < 8 {
    "Bomber / Cruiser"
  } else {
    "Any"
  }
}
