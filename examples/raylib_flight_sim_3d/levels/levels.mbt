// Mission checkpoint positions
// Returns (x, y, z) for checkpoint index in a given mission

///|
pub fn get_checkpoint_pos(mission : Int, index : Int) -> (Float, Float, Float) {
  if mission == 0 {
    // Training: simple ring around start
    if index == 0 {
      (40.0, 25.0, 40.0)
    } else if index == 1 {
      (80.0, 30.0, 0.0)
    } else if index == 2 {
      (40.0, 35.0, -50.0)
    } else if index == 3 {
      (-30.0, 25.0, -30.0)
    } else {
      (-20.0, 30.0, 30.0)
    }
  } else if mission == 3 {
    // Fog navigation: tighter course
    if index == 0 {
      (30.0, 20.0, 30.0)
    } else if index == 1 {
      (60.0, 25.0, 60.0)
    } else if index == 2 {
      (90.0, 15.0, 30.0)
    } else if index == 3 {
      (60.0, 20.0, -10.0)
    } else if index == 4 {
      (30.0, 25.0, -40.0)
    } else {
      (0.0, 20.0, -10.0)
    }
  } else if mission == 6 {
    // Storm run: varied altitudes
    if index == 0 {
      (30.0, 35.0, 20.0)
    } else if index == 1 {
      (60.0, 15.0, 50.0)
    } else if index == 2 {
      (100.0, 40.0, 30.0)
    } else if index == 3 {
      (80.0, 20.0, -20.0)
    } else if index == 4 {
      (40.0, 45.0, -50.0)
    } else if index == 5 {
      (0.0, 25.0, -30.0)
    } else {
      (-30.0, 30.0, 10.0)
    }
  } else if mission == 11 {
    // Canyon run
    if index == 0 {
      (20.0, 15.0, 20.0)
    } else if index == 1 {
      (50.0, 12.0, 40.0)
    } else if index == 2 {
      (80.0, 18.0, 20.0)
    } else if index == 3 {
      (100.0, 10.0, -10.0)
    } else if index == 4 {
      (70.0, 15.0, -40.0)
    } else if index == 5 {
      (40.0, 20.0, -60.0)
    } else if index == 6 {
      (10.0, 12.0, -30.0)
    } else {
      (-20.0, 18.0, 0.0)
    }
  } else {
    // Default fallback
    let angle : Float = 3.14159265 * 2.0 * Float::from_int(index) / 5.0
    let dist : Float = 50.0 + Float::from_int(index) * 10.0
    let cx : Float = dist * @math.cosf(angle)
    let cz : Float = dist * @math.sinf(angle)
    let cy : Float = 20.0 + Float::from_int(index % 3) * 10.0
    (cx, cy, cz)
  }
}

// Enemy spawn positions for ground targets

///|
pub fn get_ground_enemy_pos(
  mission : Int,
  index : Int,
) -> (Float, Float, Float) {
  let base_x = Float::from_int(mission * 17 + index * 31) * 0.7
  let base_z = Float::from_int(mission * 23 + index * 41) * 0.5
  let offset_x = @math.sinf(base_x) * 60.0 + Float::from_int(index) * 15.0
  let offset_z = @math.cosf(base_z) * 60.0 + Float::from_int(index) * 12.0
  let ground_y : Float = 0.0
  (offset_x, ground_y, offset_z)
}

// Enemy spawn positions for air targets

///|
pub fn get_air_enemy_pos(mission : Int, index : Int) -> (Float, Float, Float) {
  let denom = if index + 1 > 1 { index + 1 } else { 1 }
  let angle : Float = 3.14159265 *
    2.0 *
    Float::from_int(index) /
    Float::from_int(denom)
  let dist : Float = 40.0 + Float::from_int(mission) * 5.0
  let ex : Float = dist * @math.cosf(angle + Float::from_int(mission))
  let ez : Float = dist * @math.sinf(angle + Float::from_int(mission))
  let ey : Float = 25.0 + Float::from_int(index) * 5.0
  (ex, ey, ez)
}

///|
pub fn get_turret_pos(mission : Int, index : Int) -> (Float, Float, Float) {
  let angle : Float = 3.14159265 * 2.0 * Float::from_int(index) / 6.0
  let dist : Float = 20.0 + Float::from_int(mission) * 3.0
  let tx : Float = dist * @math.cosf(angle + Float::from_int(mission) * 0.5)
  let tz : Float = dist * @math.sinf(angle + Float::from_int(mission) * 0.5)
  let ty : Float = 0.0
  (tx, ty, tz)
}

///|
pub fn get_building_info(
  mission : Int,
  index : Int,
) -> (Float, Float, Float, Int) {
  // Mission-specific building layouts
  if mission == 1 {
    // Ground Strike: clustered base
    if index == 0 {
      (30.0, 0.0, 20.0, 0) // hangar
    } else if index == 1 {
      (35.0, 0.0, 28.0, 3) // house
    } else {
      (25.0, 0.0, 25.0, 4)
    } // factory
  } else if mission == 4 {
    // Emergency Landing: runway area with support buildings
    if index == 0 {
      (50.0, 0.0, 50.0, 2) // runway
    } else if index == 1 {
      (58.0, 0.0, 50.0, 1) // tower
    } else if index == 2 {
      (42.0, 0.0, 55.0, 0) // hangar
    } else {
      (55.0, 0.0, 42.0, 3)
    } // house
  } else if mission == 5 {
    // Valley Assault: spread along valley
    if index == 0 {
      (40.0, 0.0, 10.0, 4) // factory
    } else if index == 1 {
      (55.0, 0.0, 20.0, 5) // bunker
    } else if index == 2 {
      (35.0, 0.0, 30.0, 0) // hangar
    } else {
      (50.0, 0.0, 35.0, 3)
    } // house
  } else if mission == 8 {
    // Base Raid: compact military base
    if index == 0 {
      (60.0, 0.0, 0.0, 4) // factory
    } else if index == 1 {
      (55.0, 0.0, 8.0, 0) // hangar
    } else if index == 2 {
      (65.0, 0.0, 8.0, 0) // hangar
    } else if index == 3 {
      (60.0, 0.0, 15.0, 5) // bunker
    } else if index == 4 {
      (52.0, 0.0, -5.0, 1) // tower
    } else {
      (68.0, 0.0, -5.0, 3)
    } // house
  } else if mission == 10 {
    // Night Recon: scattered targets
    if index == 0 {
      (40.0, 0.0, 40.0, 4) // factory
    } else if index == 1 {
      (70.0, 0.0, -20.0, 0) // hangar
    } else if index == 2 {
      (-30.0, 0.0, 50.0, 1) // tower
    } else {
      (20.0, 0.0, -40.0, 5)
    } // bunker
  } else if mission == 12 {
    // Base Defense: friendly base layout
    if index == 0 {
      (0.0, 0.0, 0.0, 0) // hangar (friendly)
    } else if index == 1 {
      (8.0, 0.0, 5.0, 3) // house
    } else if index == 2 {
      (-8.0, 0.0, 5.0, 3) // house
    } else if index == 3 {
      (0.0, 0.0, 12.0, 4) // factory
    } else if index == 4 {
      (12.0, 0.0, 0.0, 1) // tower
    } else {
      (-12.0, 0.0, 0.0, 2)
    } // runway
  } else if mission == 14 {
    // Final Sortie: fortress compound
    if index == 0 {
      (80.0, 0.0, 80.0, 4) // factory
    } else if index == 1 {
      (85.0, 0.0, 88.0, 0) // hangar
    } else if index == 2 {
      (75.0, 0.0, 88.0, 0) // hangar
    } else if index == 3 {
      (80.0, 0.0, 95.0, 5) // bunker
    } else if index == 4 {
      (90.0, 0.0, 75.0, 1) // tower
    } else if index == 5 {
      (70.0, 0.0, 75.0, 1) // tower
    } else if index == 6 {
      (80.0, 0.0, 70.0, 5) // bunker
    } else {
      (88.0, 0.0, 82.0, 3)
    } // house
  } else {
    // Default procedural placement
    let angle : Float = 3.14159265 * 2.0 * Float::from_int(index) / 8.0
    let dist : Float = 15.0 + Float::from_int(mission) * 2.0
    let bx : Float = dist * @math.cosf(angle + Float::from_int(mission) * 0.3)
    let bz : Float = dist * @math.sinf(angle + Float::from_int(mission) * 0.3)
    let by : Float = 0.0
    let kind = index % 4
    (bx, by, bz, kind)
  }
}

// Turret placement data per mission

///|
pub fn get_turret_placement(
  mission : Int,
  index : Int,
) -> (Float, Float, Float, Float) {
  // Returns (x, y, z, range)
  if mission == 1 {
    if index == 0 {
      (20.0, 0.0, 15.0, 70.0)
    } else {
      (40.0, 0.0, 30.0, 70.0)
    }
  } else if mission == 5 {
    if index == 0 {
      (30.0, 0.0, 5.0, 80.0)
    } else {
      (60.0, 0.0, 25.0, 60.0)
    }
  } else if mission == 8 {
    if index == 0 {
      (50.0, 0.0, -10.0, 80.0)
    } else if index == 1 {
      (70.0, 0.0, -10.0, 80.0)
    } else if index == 2 {
      (50.0, 0.0, 20.0, 70.0)
    } else {
      (70.0, 0.0, 20.0, 70.0)
    }
  } else if mission == 10 {
    if index == 0 {
      (45.0, 0.0, 45.0, 60.0)
    } else {
      (65.0, 0.0, -15.0, 60.0)
    }
  } else if mission == 11 {
    if index == 0 {
      (30.0, 0.0, 10.0, 50.0)
    } else if index == 1 {
      (80.0, 0.0, -20.0, 50.0)
    } else {
      (50.0, 0.0, -50.0, 50.0)
    }
  } else if mission == 13 {
    if index == 0 {
      (20.0, 0.0, 20.0, 80.0)
    } else if index == 1 {
      (-20.0, 0.0, 30.0, 80.0)
    } else if index == 2 {
      (30.0, 0.0, -20.0, 80.0)
    } else {
      (-30.0, 0.0, -10.0, 80.0)
    }
  } else if mission == 14 {
    if index == 0 {
      (70.0, 0.0, 70.0, 90.0)
    } else if index == 1 {
      (90.0, 0.0, 70.0, 90.0)
    } else if index == 2 {
      (70.0, 0.0, 95.0, 90.0)
    } else if index == 3 {
      (90.0, 0.0, 95.0, 90.0)
    } else if index == 4 {
      (80.0, 0.0, 65.0, 80.0)
    } else {
      (80.0, 0.0, 100.0, 80.0)
    }
  } else {
    let angle : Float = 3.14159265 * 2.0 * Float::from_int(index) / 6.0
    let dist : Float = 20.0 + Float::from_int(mission) * 3.0
    let tx : Float = dist * @math.cosf(angle + Float::from_int(mission) * 0.5)
    let tz : Float = dist * @math.sinf(angle + Float::from_int(mission) * 0.5)
    (tx, 0.0, tz, 70.0)
  }
}

// Mission briefing text (extended descriptions)

///|
pub fn get_mission_briefing_lines(mission : Int) -> Array[String] {
  if mission == 0 {
    [
      "MISSION: Training Flight", "OBJECTIVE: Fly through all checkpoint rings",
      "WEATHER: Clear skies", "THREATS: None", "NOTE: Use W/S for pitch, A/D for yaw",
      "TIP: Follow the green rings to complete",
    ]
  } else if mission == 1 {
    [
      "MISSION: Ground Strike", "OBJECTIVE: Destroy all ground targets", "WEATHER: Clear skies",
      "THREATS: Ground enemies and AA turrets", "NOTE: Use rockets or bombs for ground targets",
      "TIP: Approach from high altitude to avoid AA",
    ]
  } else if mission == 2 {
    [
      "MISSION: Dogfight", "OBJECTIVE: Shoot down enemy fighters", "WEATHER: Clear skies",
      "THREATS: 3 enemy fighter aircraft", "NOTE: Machine guns are most effective",
      "TIP: Use energy tactics - climb and dive",
    ]
  } else if mission == 3 {
    [
      "MISSION: Fog Navigation", "OBJECTIVE: Navigate checkpoints in heavy fog",
      "WEATHER: Heavy fog - reduced visibility", "THREATS: None", "NOTE: Use instruments to navigate",
      "TIP: Maintain steady altitude and speed",
    ]
  } else if mission == 4 {
    [
      "MISSION: Emergency Landing", "OBJECTIVE: Land at the marked runway", "WEATHER: Clear skies",
      "THREATS: None", "NOTE: Reduce speed below 25 before landing", "TIP: Level wings and lower pitch on approach",
    ]
  } else if mission == 5 {
    [
      "MISSION: Valley Assault", "OBJECTIVE: Clear the valley of all enemies", "WEATHER: Clear skies",
      "THREATS: Ground and air targets, AA turrets", "NOTE: Mixed threat environment",
      "TIP: Prioritize AA turrets first",
    ]
  } else if mission == 6 {
    [
      "MISSION: Storm Runner", "OBJECTIVE: Fly through rings in a storm", "WEATHER: Severe storm with turbulence",
      "THREATS: Extreme weather conditions", "NOTE: Expect strong turbulence", "TIP: Reduce speed for better control",
    ]
  } else if mission == 7 {
    [
      "MISSION: Air Superiority", "OBJECTIVE: Defeat the enemy squadron", "WEATHER: Cloudy with limited visibility",
      "THREATS: 5 enemy fighter aircraft", "TIME LIMIT: 120 seconds", "TIP: Engage targets quickly and efficiently",
    ]
  } else if mission == 8 {
    [
      "MISSION: Base Raid", "OBJECTIVE: Destroy enemy base installations", "WEATHER: Fog conditions",
      "THREATS: Ground AA and patrol fighters", "NOTE: Bomb key buildings to complete",
      "TIP: Use the bomber aircraft for this mission",
    ]
  } else if mission == 9 {
    [
      "MISSION: Survival", "OBJECTIVE: Survive for 60 seconds", "WEATHER: Clear but hostile",
      "THREATS: Multiple air and ground enemies", "TIME LIMIT: 60 seconds", "TIP: Keep moving - do not fly straight",
    ]
  } else if mission == 10 {
    [
      "MISSION: Night Recon", "OBJECTIVE: Photograph targets at night", "WEATHER: Night conditions",
      "THREATS: Ground AA and patrols", "NOTE: Fly near targets to photograph them",
      "TIP: Low and fast approach works best",
    ]
  } else if mission == 11 {
    [
      "MISSION: Canyon Run", "OBJECTIVE: High speed checkpoint run", "WEATHER: Clear skies",
      "THREATS: AA emplacements and fighters", "TIME LIMIT: 90 seconds", "TIP: Use the interceptor for max speed",
    ]
  } else if mission == 12 {
    [
      "MISSION: Base Defense", "OBJECTIVE: Defend the base from attack", "WEATHER: Rain",
      "THREATS: 8 enemy attackers", "TIME LIMIT: 90 seconds", "WARNING: If all buildings fall, mission fails",
    ]
  } else if mission == 13 {
    [
      "MISSION: Storm Survival", "OBJECTIVE: Survive 90 seconds in storm", "WEATHER: Extreme storm",
      "THREATS: Heavy enemy presence", "TIME LIMIT: 90 seconds", "TIP: Weather is as dangerous as the enemy",
    ]
  } else {
    [
      "MISSION: Final Sortie", "OBJECTIVE: Eliminate the ace commander", "WEATHER: Storm conditions",
      "THREATS: Full enemy fortress defense", "NOTE: This is the final mission",
      "TIP: Destroy turrets before engaging the ace",
    ]
  }
}

// Get mission par time for scoring

///|
pub fn get_mission_par_time(mission : Int) -> Float {
  if mission == 0 {
    60.0
  } else if mission == 1 {
    90.0
  } else if mission == 2 {
    120.0
  } else if mission == 3 {
    90.0
  } else if mission == 4 {
    60.0
  } else if mission == 5 {
    150.0
  } else if mission == 6 {
    120.0
  } else if mission == 7 {
    120.0
  } else if mission == 8 {
    180.0
  } else if mission == 9 {
    60.0
  } else if mission == 10 {
    120.0
  } else if mission == 11 {
    90.0
  } else if mission == 12 {
    90.0
  } else if mission == 13 {
    90.0
  } else {
    240.0
  }
}

// Scoring criteria per mission

///|
pub fn get_mission_scoring_info(mission : Int) -> (Int, Int, Int) {
  // Returns (s_threshold, a_threshold, base_bonus)
  if mission == 0 {
    (800, 500, 200)
  } else if mission == 1 {
    (1200, 800, 300)
  } else if mission == 2 {
    (1500, 1000, 400)
  } else if mission == 3 {
    (1000, 700, 250)
  } else if mission == 4 {
    (600, 400, 200)
  } else if mission == 5 {
    (2000, 1400, 500)
  } else if mission == 6 {
    (1200, 800, 350)
  } else if mission == 7 {
    (2000, 1500, 500)
  } else if mission == 8 {
    (2500, 1800, 600)
  } else if mission == 9 {
    (1500, 1000, 400)
  } else if mission == 10 {
    (1800, 1200, 450)
  } else if mission == 11 {
    (1800, 1300, 400)
  } else if mission == 12 {
    (2200, 1600, 550)
  } else if mission == 13 {
    (2500, 1800, 600)
  } else {
    (3000, 2200, 800)
  }
}
