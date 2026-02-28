// Battle definitions - 12 scenarios
// Returns (enemy_count, enemy_hp, enemy_speed, enemy_fire_rate, enemy_damage, detect_range, score_per_kill)
pub fn get_battle_def(battle : Int) -> (Int, Float, Float, Float, Float, Float, Int) {
  if battle == 0 {
    // Patrol Duty: Easy intro, 2 sloops
    (2, 40.0, 3.0, 3.0, 6.0, 35.0, 100)
  } else if battle == 1 {
    // Coastal Skirmish: 3 sloops
    (3, 45.0, 3.5, 2.8, 7.0, 38.0, 120)
  } else if battle == 2 {
    // Open Water: 4 mixed
    (4, 50.0, 3.5, 2.5, 8.0, 40.0, 150)
  } else if battle == 3 {
    // Island Ambush: enemies behind islands
    (4, 60.0, 4.0, 2.3, 9.0, 42.0, 180)
  } else if battle == 4 {
    // Channel Run: narrow passage, 5 enemies
    (5, 65.0, 4.0, 2.0, 10.0, 45.0, 200)
  } else if battle == 5 {
    // Fortress Assault: fortress island + escort
    (4, 70.0, 4.5, 1.8, 11.0, 45.0, 250)
  } else if battle == 6 {
    // Fleet Engagement: 6 brigantines
    (6, 80.0, 4.0, 2.0, 12.0, 45.0, 280)
  } else if battle == 7 {
    // Escort Mission: protect convoy
    (5, 70.0, 4.5, 1.8, 11.0, 48.0, 300)
  } else if battle == 8 {
    // Night Raid: heavy hitters
    (5, 90.0, 3.5, 1.8, 14.0, 40.0, 350)
  } else if battle == 9 {
    // Blockade Run: survive and break through
    (7, 80.0, 4.5, 1.5, 12.0, 48.0, 300)
  } else if battle == 10 {
    // Grand Battle: 8 ships mixed
    (8, 100.0, 4.5, 1.5, 13.0, 50.0, 380)
  } else {
    // Final Stand: 8 heavy warships
    (8, 130.0, 5.0, 1.2, 16.0, 55.0, 500)
  }
}

// Get battle name
pub fn get_battle_name(battle : Int) -> String {
  if battle == 0 {
    "Patrol Duty"
  } else if battle == 1 {
    "Coastal Skirmish"
  } else if battle == 2 {
    "Open Water"
  } else if battle == 3 {
    "Island Ambush"
  } else if battle == 4 {
    "Channel Run"
  } else if battle == 5 {
    "Fortress Assault"
  } else if battle == 6 {
    "Fleet Engagement"
  } else if battle == 7 {
    "Escort Mission"
  } else if battle == 8 {
    "Night Raid"
  } else if battle == 9 {
    "Blockade Run"
  } else if battle == 10 {
    "Grand Battle"
  } else {
    "Final Stand"
  }
}

// Get battle description
pub fn get_battle_description(battle : Int) -> String {
  if battle == 0 {
    "Scout the area. Destroy 2 enemy sloops."
  } else if battle == 1 {
    "Clear the coast of 3 pirate raiders."
  } else if battle == 2 {
    "Engage a mixed squadron in open waters."
  } else if battle == 3 {
    "Flush out enemies hiding behind islands."
  } else if battle == 4 {
    "Navigate a narrow channel under fire."
  } else if battle == 5 {
    "Destroy the fortress and its escort."
  } else if battle == 6 {
    "Engage a full enemy fleet of brigantines."
  } else if battle == 7 {
    "Protect the convoy from raiders."
  } else if battle == 8 {
    "Strike hard against heavy warships."
  } else if battle == 9 {
    "Break through the enemy blockade."
  } else if battle == 10 {
    "Command the grand fleet battle."
  } else {
    "Defeat the enemy armada. Last stand!"
  }
}

// Get battle difficulty (1-5 stars)
pub fn get_battle_difficulty(battle : Int) -> Int {
  if battle <= 1 { 1 } else if battle <= 3 { 2 } else if battle <= 5 {
    3
  } else if battle <= 8 { 4 } else { 5 }
}

// Get battle objective type
pub fn get_battle_objective_type(battle : Int) -> Int {
  if battle == 5 {
    // Fortress assault: destroy fortress + ships
    @types.objective_destroy_all
  } else if battle == 7 {
    @types.objective_escort_convoy
  } else if battle == 9 {
    @types.objective_blockade_run
  } else {
    @types.objective_destroy_all
  }
}

// Get battle objective description
pub fn get_battle_objective_desc(battle : Int) -> String {
  let obj_type = get_battle_objective_type(battle)
  if obj_type == @types.objective_destroy_all {
    "Destroy all enemy ships"
  } else if obj_type == @types.objective_escort_convoy {
    "Protect the convoy ships"
  } else if obj_type == @types.objective_blockade_run {
    "Reach the far side of the map"
  } else {
    "Complete the objective"
  }
}

// Get enemy ship classes per battle
// Returns array of ship class IDs
pub fn get_enemy_classes(battle : Int) -> Array[Int] {
  if battle == 0 {
    [@types.class_sloop, @types.class_sloop]
  } else if battle == 1 {
    [@types.class_sloop, @types.class_sloop, @types.class_sloop]
  } else if battle == 2 {
    [
      @types.class_sloop,
      @types.class_sloop,
      @types.class_brigantine,
      @types.class_brigantine,
    ]
  } else if battle == 3 {
    [
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_sloop,
      @types.class_sloop,
    ]
  } else if battle == 4 {
    [
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_sloop,
      @types.class_sloop,
    ]
  } else if battle == 5 {
    [
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_frigate,
      @types.class_sloop,
    ]
  } else if battle == 6 {
    [
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_brigantine,
    ]
  } else if battle == 7 {
    [
      @types.class_sloop,
      @types.class_sloop,
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_frigate,
    ]
  } else if battle == 8 {
    [
      @types.class_frigate,
      @types.class_frigate,
      @types.class_galleon,
      @types.class_brigantine,
      @types.class_brigantine,
    ]
  } else if battle == 9 {
    [
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_frigate,
      @types.class_frigate,
      @types.class_frigate,
      @types.class_galleon,
      @types.class_galleon,
    ]
  } else if battle == 10 {
    [
      @types.class_frigate,
      @types.class_frigate,
      @types.class_frigate,
      @types.class_galleon,
      @types.class_galleon,
      @types.class_brigantine,
      @types.class_brigantine,
      @types.class_man_of_war,
    ]
  } else {
    [
      @types.class_galleon,
      @types.class_galleon,
      @types.class_galleon,
      @types.class_frigate,
      @types.class_frigate,
      @types.class_man_of_war,
      @types.class_man_of_war,
      @types.class_man_of_war,
    ]
  }
}

// Get AI personalities per battle
pub fn get_enemy_personalities(battle : Int) -> Array[Int] {
  if battle == 0 {
    [@types.ai_personality_defensive, @types.ai_personality_defensive]
  } else if battle == 1 {
    [
      @types.ai_personality_aggressive,
      @types.ai_personality_defensive,
      @types.ai_personality_flanker,
    ]
  } else if battle == 2 {
    [
      @types.ai_personality_aggressive,
      @types.ai_personality_flanker,
      @types.ai_personality_defensive,
      @types.ai_personality_aggressive,
    ]
  } else if battle == 3 {
    [
      @types.ai_personality_flanker,
      @types.ai_personality_flanker,
      @types.ai_personality_aggressive,
      @types.ai_personality_retreater,
    ]
  } else if battle == 4 {
    [
      @types.ai_personality_aggressive,
      @types.ai_personality_aggressive,
      @types.ai_personality_defensive,
      @types.ai_personality_flanker,
      @types.ai_personality_flanker,
    ]
  } else if battle == 5 {
    [
      @types.ai_personality_defensive,
      @types.ai_personality_defensive,
      @types.ai_personality_aggressive,
      @types.ai_personality_flanker,
    ]
  } else if battle == 6 {
    [
      @types.ai_personality_aggressive,
      @types.ai_personality_aggressive,
      @types.ai_personality_flanker,
      @types.ai_personality_flanker,
      @types.ai_personality_defensive,
      @types.ai_personality_berserker,
    ]
  } else if battle == 7 {
    [
      @types.ai_personality_berserker,
      @types.ai_personality_berserker,
      @types.ai_personality_aggressive,
      @types.ai_personality_aggressive,
      @types.ai_personality_flanker,
    ]
  } else if battle == 8 {
    [
      @types.ai_personality_aggressive,
      @types.ai_personality_aggressive,
      @types.ai_personality_berserker,
      @types.ai_personality_flanker,
      @types.ai_personality_defensive,
    ]
  } else if battle == 9 {
    [
      @types.ai_personality_defensive,
      @types.ai_personality_defensive,
      @types.ai_personality_aggressive,
      @types.ai_personality_aggressive,
      @types.ai_personality_flanker,
      @types.ai_personality_flanker,
      @types.ai_personality_defensive,
    ]
  } else if battle == 10 {
    [
      @types.ai_personality_aggressive,
      @types.ai_personality_berserker,
      @types.ai_personality_flanker,
      @types.ai_personality_defensive,
      @types.ai_personality_aggressive,
      @types.ai_personality_flanker,
      @types.ai_personality_aggressive,
      @types.ai_personality_berserker,
    ]
  } else {
    [
      @types.ai_personality_berserker,
      @types.ai_personality_berserker,
      @types.ai_personality_aggressive,
      @types.ai_personality_aggressive,
      @types.ai_personality_flanker,
      @types.ai_personality_berserker,
      @types.ai_personality_berserker,
      @types.ai_personality_aggressive,
    ]
  }
}

// Which battle index has a fortress island
pub fn battle_has_fortress(battle : Int) -> Bool {
  battle == 5 || battle == 9 || battle == 11
}

// Get fortress island index for a battle (-1 if none)
pub fn get_fortress_island(battle : Int) -> Int {
  if battle == 5 { 0 } else if battle == 9 { 2 } else if battle == 11 {
    0
  } else { -1 }
}

// Get fleet ship count for battle (allied ships)
pub fn get_fleet_count(battle : Int) -> Int {
  if battle <= 4 {
    0
  } else if battle <= 7 {
    1
  } else if battle <= 9 {
    2
  } else {
    3
  }
}

// Get fleet ship classes
pub fn get_fleet_classes(battle : Int) -> Array[Int] {
  if battle <= 4 {
    []
  } else if battle == 5 {
    [@types.class_sloop]
  } else if battle == 6 {
    [@types.class_brigantine]
  } else if battle == 7 {
    [@types.class_brigantine]
  } else if battle == 8 {
    [@types.class_sloop, @types.class_sloop]
  } else if battle == 9 {
    [@types.class_brigantine, @types.class_sloop]
  } else if battle == 10 {
    [@types.class_frigate, @types.class_brigantine, @types.class_sloop]
  } else {
    [@types.class_frigate, @types.class_brigantine, @types.class_brigantine]
  }
}

// Get convoy ship count
pub fn get_convoy_count(battle : Int) -> Int {
  if battle == 7 { 3 } else { 0 }
}

// Get starting wind conditions per battle
pub fn get_wind_conditions(battle : Int) -> (Float, Float, Float) {
  // Returns (direction, speed, shift_interval)
  if battle == 0 {
    (0.5, @types.wind_speed_moderate, 20.0)
  } else if battle == 1 {
    (1.2, @types.wind_speed_moderate, 18.0)
  } else if battle == 2 {
    (2.0, @types.wind_speed_strong, 15.0)
  } else if battle == 3 {
    (0.8, @types.wind_speed_light, 25.0)
  } else if battle == 4 {
    (@types.pi * 0.5, @types.wind_speed_strong, 12.0)
  } else if battle == 5 {
    (1.5, @types.wind_speed_moderate, 18.0)
  } else if battle == 6 {
    (2.5, @types.wind_speed_strong, 10.0)
  } else if battle == 7 {
    (0.0, @types.wind_speed_moderate, 20.0)
  } else if battle == 8 {
    (@types.pi, @types.wind_speed_light, 30.0)
  } else if battle == 9 {
    (@types.pi * 0.75, @types.wind_speed_gale, 8.0)
  } else if battle == 10 {
    (1.0, @types.wind_speed_strong, 12.0)
  } else {
    (@types.pi * 0.5, @types.wind_speed_gale, 6.0)
  }
}

// Island layout per battle
// Returns array of (x, z, radius, height, block_count)
pub fn get_island_layout(battle : Int) -> Array[(Float, Float, Float, Float, Int)] {
  if battle == 0 {
    [
      (30.0, 30.0, 6.0, 4.0, 4),
      (-25.0, -20.0, 5.0, 3.0, 3),
    ]
  } else if battle == 1 {
    [
      (0.0, 35.0, 7.0, 5.0, 5),
      (-30.0, -10.0, 5.0, 3.0, 3),
      (25.0, -25.0, 4.0, 2.5, 2),
    ]
  } else if battle == 2 {
    [
      (20.0, 20.0, 6.0, 4.0, 4),
      (-20.0, 25.0, 5.0, 3.5, 3),
      (0.0, -30.0, 8.0, 5.0, 5),
      (-35.0, -15.0, 4.0, 2.0, 2),
    ]
  } else if battle == 3 {
    [
      (15.0, 30.0, 7.0, 5.0, 5),
      (-25.0, 20.0, 6.0, 4.0, 4),
      (30.0, -20.0, 5.0, 3.0, 3),
      (-15.0, -30.0, 6.0, 4.0, 4),
      (0.0, 0.0, 4.0, 2.0, 2),
    ]
  } else if battle == 4 {
    // Channel: two long island barriers
    [
      (25.0, 25.0, 8.0, 5.0, 6),
      (-30.0, 15.0, 6.0, 4.0, 4),
      (10.0, -35.0, 7.0, 4.5, 5),
      (-20.0, -25.0, 5.0, 3.0, 3),
      (30.0, -10.0, 6.0, 4.0, 4),
      (-25.0, 30.0, 5.0, 3.5, 3),
    ]
  } else if battle == 5 {
    // Fortress in center
    [
      (0.0, 0.0, 10.0, 7.0, 6),
      (30.0, 30.0, 6.0, 4.0, 4),
      (-30.0, 30.0, 5.0, 3.0, 3),
      (25.0, -20.0, 4.0, 2.5, 2),
      (-25.0, -25.0, 5.0, 3.5, 3),
    ]
  } else if battle == 6 {
    [
      (0.0, 30.0, 9.0, 6.0, 6),
      (30.0, 0.0, 7.0, 4.5, 5),
      (-30.0, 0.0, 7.0, 4.5, 5),
      (0.0, -30.0, 9.0, 6.0, 6),
      (20.0, 20.0, 4.0, 2.5, 2),
      (-20.0, -20.0, 4.0, 2.5, 2),
    ]
  } else if battle == 7 {
    // Escort: islands along convoy route
    [
      (20.0, -30.0, 6.0, 4.0, 4),
      (-20.0, -10.0, 5.0, 3.0, 3),
      (25.0, 10.0, 7.0, 5.0, 5),
      (-30.0, 30.0, 6.0, 4.0, 4),
      (15.0, 40.0, 5.0, 3.0, 3),
    ]
  } else if battle == 8 {
    [
      (20.0, 30.0, 6.0, 4.0, 4),
      (-20.0, 30.0, 6.0, 4.0, 4),
      (35.0, 0.0, 5.0, 3.0, 3),
      (-35.0, 0.0, 5.0, 3.0, 3),
      (20.0, -30.0, 6.0, 4.0, 4),
      (-20.0, -30.0, 6.0, 4.0, 4),
      (0.0, 0.0, 5.0, 3.0, 3),
    ]
  } else if battle == 9 {
    // Blockade: barrier of islands
    [
      (-40.0, 20.0, 8.0, 5.0, 5),
      (-15.0, 25.0, 6.0, 4.0, 4),
      (15.0, 20.0, 7.0, 5.0, 5),
      (40.0, 25.0, 6.0, 4.0, 4),
      (0.0, -30.0, 5.0, 3.0, 3),
      (-30.0, -15.0, 4.0, 2.5, 2),
      (30.0, -10.0, 5.0, 3.0, 3),
    ]
  } else if battle == 10 {
    [
      (25.0, 25.0, 7.0, 5.0, 5),
      (-25.0, 25.0, 7.0, 5.0, 5),
      (25.0, -25.0, 7.0, 5.0, 5),
      (-25.0, -25.0, 7.0, 5.0, 5),
      (0.0, 35.0, 5.0, 3.0, 3),
      (0.0, -35.0, 5.0, 3.0, 3),
      (35.0, 0.0, 5.0, 3.0, 3),
      (-35.0, 0.0, 5.0, 3.0, 3),
    ]
  } else {
    // Final: fortress islands
    [
      (0.0, 40.0, 10.0, 8.0, 7),
      (30.0, 30.0, 6.0, 4.0, 4),
      (-30.0, 30.0, 6.0, 4.0, 4),
      (40.0, 0.0, 7.0, 5.0, 5),
      (-40.0, 0.0, 7.0, 5.0, 5),
      (25.0, -25.0, 5.0, 3.0, 3),
      (-25.0, -25.0, 5.0, 3.0, 3),
      (0.0, -40.0, 8.0, 6.0, 5),
    ]
  }
}

// Island types per battle (parallel to layout)
pub fn get_island_types(battle : Int) -> Array[Int] {
  if battle == 0 {
    [@types.island_medium, @types.island_small]
  } else if battle == 1 {
    [@types.island_medium, @types.island_small, @types.island_small]
  } else if battle == 2 {
    [
      @types.island_medium,
      @types.island_small,
      @types.island_large,
      @types.island_small,
    ]
  } else if battle == 3 {
    [
      @types.island_medium,
      @types.island_medium,
      @types.island_small,
      @types.island_medium,
      @types.island_small,
    ]
  } else if battle == 4 {
    [
      @types.island_large,
      @types.island_medium,
      @types.island_medium,
      @types.island_small,
      @types.island_medium,
      @types.island_small,
    ]
  } else if battle == 5 {
    [
      @types.island_fortress,
      @types.island_medium,
      @types.island_small,
      @types.island_small,
      @types.island_small,
    ]
  } else if battle == 6 {
    [
      @types.island_large,
      @types.island_medium,
      @types.island_medium,
      @types.island_large,
      @types.island_small,
      @types.island_small,
    ]
  } else if battle == 7 {
    [
      @types.island_medium,
      @types.island_small,
      @types.island_medium,
      @types.island_medium,
      @types.island_small,
    ]
  } else if battle == 8 {
    [
      @types.island_medium,
      @types.island_medium,
      @types.island_small,
      @types.island_small,
      @types.island_medium,
      @types.island_medium,
      @types.island_small,
    ]
  } else if battle == 9 {
    [
      @types.island_large,
      @types.island_medium,
      @types.island_fortress,
      @types.island_medium,
      @types.island_small,
      @types.island_small,
      @types.island_small,
    ]
  } else if battle == 10 {
    [
      @types.island_medium,
      @types.island_medium,
      @types.island_medium,
      @types.island_medium,
      @types.island_small,
      @types.island_small,
      @types.island_small,
      @types.island_small,
    ]
  } else {
    [
      @types.island_fortress,
      @types.island_medium,
      @types.island_medium,
      @types.island_medium,
      @types.island_medium,
      @types.island_small,
      @types.island_small,
      @types.island_large,
    ]
  }
}

// Enemy starting positions relative to center, returns (angle, distance)
pub fn get_enemy_spawn_angle(idx : Int, total : Int) -> (Float, Float) {
  let base_angle : Float = 6.28318 * Float::from_int(idx) / Float::from_int(total)
  let dist : Float = 45.0
  (base_angle, dist)
}

// Get flagship index for a battle (-1 if no flagship)
pub fn get_flagship_index(battle : Int) -> Int {
  if battle >= 6 { 0 } else { -1 }
}

// Get reward score multiplier for battle
pub fn get_battle_reward_mult(battle : Int) -> Int {
  if battle <= 2 {
    1
  } else if battle <= 5 {
    2
  } else if battle <= 8 {
    3
  } else {
    4
  }
}

// Cannon type per enemy class for a given battle
pub fn get_enemy_cannon_type(ship_class : Int, battle : Int) -> Int {
  if ship_class == @types.class_sloop {
    @types.cannon_light
  } else if ship_class == @types.class_brigantine {
    if battle >= 6 { @types.cannon_medium } else { @types.cannon_light }
  } else if ship_class == @types.class_frigate {
    @types.cannon_medium
  } else if ship_class == @types.class_galleon {
    if battle >= 10 { @types.cannon_heavy } else { @types.cannon_medium }
  } else if ship_class == @types.class_man_of_war {
    @types.cannon_heavy
  } else {
    @types.cannon_medium
  }
}
