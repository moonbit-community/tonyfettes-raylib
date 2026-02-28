// Wave definitions - 30 waves
// Each wave defines enemy types and counts
// Returns (enemy_kinds array, enemy_counts array, hp_mult, speed_mult)

// Helper: get wave enemy kind for current spawn index

///|
pub fn get_wave_enemy_kind(wave : Int, spawn_idx : Int) -> Int {
  let kinds = get_wave_kinds(wave)
  let counts = get_wave_counts(wave)
  let mut total = 0
  for i in 0..<kinds.length() {
    total += counts[i]
    if spawn_idx < total {
      return kinds[i]
    }
  }
  // Default fallback
  kinds[kinds.length() - 1]
}

///|
pub fn get_wave_total_enemies(wave : Int) -> Int {
  let counts = get_wave_counts(wave)
  let mut total = 0
  for count in counts {
    total += count
  }
  total
}

///|
pub fn get_wave_kinds(wave : Int) -> Array[Int] {
  if wave == 0 {
    [0] // Zombies
  } else if wave == 1 {
    [0] // More zombies
  } else if wave == 2 {
    [1] // Runners
  } else if wave == 3 {
    [0, 1] // Zombies + runners
  } else if wave == 4 {
    [2] // Brutes intro
  } else if wave == 5 {
    [0, 1, 3] // Mixed + spitters
  } else if wave == 6 {
    [1, 1] // Fast runners
  } else if wave == 7 {
    [0, 2] // Zombies + brutes
  } else if wave == 8 {
    [3, 4] // Spitters + exploders intro
  } else if wave == 9 {
    [7] // BOSS wave
  } else if wave == 10 {
    [0, 1, 4] // Mixed swarm
  } else if wave == 11 {
    [3, 5] // Spitters + necromancer intro
  } else if wave == 12 {
    [1, 6] // Runners + shielded intro
  } else if wave == 13 {
    [2, 4, 3] // Heavy mixed
  } else if wave == 14 {
    [7, 2] // BOSS + brutes
  } else if wave == 15 {
    [0, 0, 4] // Zombie horde + exploders
  } else if wave == 16 {
    [5, 3, 6] // Necro + spitters + shielded
  } else if wave == 17 {
    [1, 4] // Runner blitz + exploders
  } else if wave == 18 {
    [2, 6] // Brute wall + shielded
  } else if wave == 19 {
    [7, 5] // BOSS + necromancer
  } else if wave == 20 {
    [0, 1, 2, 3] // All basic types
  } else if wave == 21 {
    [4, 5, 6] // All special types
  } else if wave == 22 {
    [3, 3, 5] // Spitter swarm + necro
  } else if wave == 23 {
    [2, 6, 4] // Heavy assault
  } else if wave == 24 {
    [7, 6, 2] // BOSS + elite guard
  } else if wave == 25 {
    [0, 1, 2, 3, 4] // Mega horde
  } else if wave == 26 {
    [5, 6, 3, 4] // Elite swarm
  } else if wave == 27 {
    [2, 2, 6] // Brute invasion
  } else if wave == 28 {
    [7, 5, 6, 4] // Penultimate: boss + elites
  } else {
    [7, 7, 2, 6]
  } // Final: multiple bosses + elites
}

///|
pub fn get_wave_counts(wave : Int) -> Array[Int] {
  if wave == 0 {
    [6]
  } else if wave == 1 {
    [10]
  } else if wave == 2 {
    [6]
  } else if wave == 3 {
    [8, 4]
  } else if wave == 4 {
    [4]
  } else if wave == 5 {
    [6, 4, 3]
  } else if wave == 6 {
    [8, 6]
  } else if wave == 7 {
    [10, 4]
  } else if wave == 8 {
    [5, 3]
  } else if wave == 9 {
    [1] // Single boss
  } else if wave == 10 {
    [10, 6, 4]
  } else if wave == 11 {
    [6, 2]
  } else if wave == 12 {
    [8, 4]
  } else if wave == 13 {
    [6, 4, 4]
  } else if wave == 14 {
    [2, 6] // 2 bosses + brutes
  } else if wave == 15 {
    [15, 10, 5]
  } else if wave == 16 {
    [3, 6, 4]
  } else if wave == 17 {
    [14, 6]
  } else if wave == 18 {
    [8, 6]
  } else if wave == 19 {
    [2, 3] // 2 bosses + necros
  } else if wave == 20 {
    [8, 6, 4, 5]
  } else if wave == 21 {
    [6, 4, 5]
  } else if wave == 22 {
    [8, 6, 3]
  } else if wave == 23 {
    [8, 5, 5]
  } else if wave == 24 {
    [2, 5, 6]
  } else if wave == 25 {
    [12, 10, 6, 6, 4]
  } else if wave == 26 {
    [4, 6, 6, 5]
  } else if wave == 27 {
    [10, 8, 6]
  } else if wave == 28 {
    [3, 3, 5, 5]
  } else {
    [3, 2, 6, 5]
  }
}

///|
pub fn get_wave_hp_mult(wave : Int) -> Float {
  let base : Float = 1.0
  let scale = Float::from_int(wave) * 0.08
  base + scale
}

///|
pub fn get_wave_speed_mult(wave : Int) -> Float {
  let base : Float = 1.0
  let scale = Float::from_int(wave) * 0.025
  let result = base + scale
  if result > 2.0 {
    2.0
  } else {
    result
  }
}

// Enemy base HP

///|
pub fn enemy_base_hp(kind : Int) -> Float {
  if kind == 0 {
    30.0 // Zombie
  } else if kind == 1 {
    20.0 // Runner
  } else if kind == 2 {
    120.0 // Brute
  } else if kind == 3 {
    25.0 // Spitter
  } else if kind == 4 {
    35.0 // Exploder
  } else if kind == 5 {
    60.0 // Necromancer
  } else if kind == 6 {
    80.0 // Shielded
  } else {
    500.0
  } // Boss
}

// Enemy base speed

///|
pub fn enemy_base_speed(kind : Int) -> Float {
  if kind == 0 {
    3.0 // Zombie
  } else if kind == 1 {
    6.5 // Runner
  } else if kind == 2 {
    2.0 // Brute
  } else if kind == 3 {
    3.5 // Spitter
  } else if kind == 4 {
    5.0 // Exploder
  } else if kind == 5 {
    2.5 // Necromancer
  } else if kind == 6 {
    2.8 // Shielded
  } else {
    2.5
  } // Boss
}

// Enemy base damage per attack

///|
pub fn enemy_base_damage(kind : Int) -> Float {
  if kind == 0 {
    8.0 // Zombie
  } else if kind == 1 {
    5.0 // Runner
  } else if kind == 2 {
    20.0 // Brute
  } else if kind == 3 {
    12.0 // Spitter (ranged)
  } else if kind == 4 {
    0.0 // Exploder (does explosion damage)
  } else if kind == 5 {
    6.0 // Necromancer
  } else if kind == 6 {
    12.0 // Shielded
  } else {
    30.0
  } // Boss
}

// Enemy attack range

///|
pub fn enemy_attack_range(kind : Int) -> Float {
  if kind == 0 {
    2.0 // Zombie (melee)
  } else if kind == 1 {
    1.8 // Runner (melee)
  } else if kind == 2 {
    2.5 // Brute (melee)
  } else if kind == 3 {
    15.0 // Spitter (ranged)
  } else if kind == 4 {
    1.5 // Exploder (melee - triggers explosion)
  } else if kind == 5 {
    20.0 // Necromancer (ranged ability)
  } else if kind == 6 {
    2.2 // Shielded (melee)
  } else {
    3.5
  } // Boss (melee)
}

// Enemy size

///|
pub fn enemy_size(kind : Int) -> Float {
  if kind == 0 {
    0.6 // Zombie
  } else if kind == 1 {
    0.5 // Runner
  } else if kind == 2 {
    1.0 // Brute
  } else if kind == 3 {
    0.5 // Spitter
  } else if kind == 4 {
    0.55 // Exploder
  } else if kind == 5 {
    0.6 // Necromancer
  } else if kind == 6 {
    0.7 // Shielded
  } else {
    1.5
  } // Boss
}

// Enemy gold value

///|
pub fn enemy_gold_value(kind : Int) -> Int {
  if kind == 0 {
    10 // Zombie
  } else if kind == 1 {
    12 // Runner
  } else if kind == 2 {
    25 // Brute
  } else if kind == 3 {
    15 // Spitter
  } else if kind == 4 {
    18 // Exploder
  } else if kind == 5 {
    35 // Necromancer
  } else if kind == 6 {
    30 // Shielded
  } else {
    150
  } // Boss
}

// Enemy score value

///|
pub fn enemy_score_value(kind : Int) -> Int {
  if kind == 0 {
    10 // Zombie
  } else if kind == 1 {
    15 // Runner
  } else if kind == 2 {
    30 // Brute
  } else if kind == 3 {
    20 // Spitter
  } else if kind == 4 {
    25 // Exploder
  } else if kind == 5 {
    50 // Necromancer
  } else if kind == 6 {
    40 // Shielded
  } else {
    300
  } // Boss
}

// Spit cooldown for spitter type

///|
pub fn enemy_spit_cooldown(kind : Int) -> Float {
  if kind == 3 {
    2.5 // Spitter
  } else if kind == 5 {
    8.0 // Necromancer (revive cooldown)
  } else {
    999.0
  } // Others don't spit
}

// Wave gold bonus

///|
pub fn wave_bonus(wave : Int) -> Int {
  50 + wave * 20
}

// Pickup drop chance by enemy kind

///|
pub fn enemy_drop_chance(kind : Int) -> Float {
  if kind == 0 {
    0.08 // Zombie - low chance
  } else if kind == 1 {
    0.06 // Runner - low
  } else if kind == 2 {
    0.15 // Brute - medium
  } else if kind == 3 {
    0.10 // Spitter
  } else if kind == 4 {
    0.12 // Exploder
  } else if kind == 5 {
    0.20 // Necromancer - higher
  } else if kind == 6 {
    0.18 // Shielded
  } else {
    0.80
  } // Boss - very high
}

// Random pickup kind (weighted)

///|
pub fn random_pickup_kind(roll : Int) -> Int {
  let r = roll % 100
  if r < 35 {
    0 // Health pack - 35%
  } else if r < 60 {
    1 // Ammo crate - 25%
  } else if r < 75 {
    2 // Speed boost - 15%
  } else if r < 88 {
    3 // Damage boost - 13%
  } else if r < 97 {
    4 // Shield - 9%
  } else {
    5
  } // Nuke - 3%
}

// Shop item count

///|
pub fn shop_item_count() -> Int {
  14
}

// Shop item definition: (name, cost)

///|
pub fn shop_item_name(idx : Int) -> String {
  if idx == 0 {
    "Heal +40 HP"
  } else if idx == 1 {
    "Armor +30"
  } else if idx == 2 {
    "Shotgun Ammo +12"
  } else if idx == 3 {
    "Rifle Ammo +30"
  } else if idx == 4 {
    "Sniper Ammo +5"
  } else if idx == 5 {
    "Rocket Ammo +3"
  } else if idx == 6 {
    "Minigun Ammo +100"
  } else if idx == 7 {
    "Damage +15%"
  } else if idx == 8 {
    "Speed +10%"
  } else if idx == 9 {
    "Buy Sniper Rifle"
  } else if idx == 10 {
    "Buy Rocket Launcher"
  } else if idx == 11 {
    "Buy Minigun"
  } else if idx == 12 {
    "Place Barricade"
  } else {
    "Place Spike Trap"
  }
}

///|
pub fn shop_item_cost(idx : Int) -> Int {
  if idx == 0 {
    50
  } else if idx == 1 {
    40
  } else if idx == 2 {
    30
  } else if idx == 3 {
    25
  } else if idx == 4 {
    50
  } else if idx == 5 {
    60
  } else if idx == 6 {
    45
  } else if idx == 7 {
    100
  } else if idx == 8 {
    80
  } else if idx == 9 {
    200
  } else if idx == 10 {
    300
  } else if idx == 11 {
    400
  } else if idx == 12 {
    60
  } else {
    80
  }
}

// Boss configurations

///|
pub fn boss_phase_hp_threshold(phase : Int) -> Float {
  if phase == 0 {
    0.75
  } else if phase == 1 {
    0.50
  } else if phase == 2 {
    0.25
  } else {
    0.0
  }
}

///|
pub fn boss_ability_cooldown(phase : Int) -> Float {
  if phase == 0 {
    5.0
  } else if phase == 1 {
    3.5
  } else if phase == 2 {
    2.5
  } else {
    2.0
  }
}

///|
pub fn boss_charge_speed_mult(phase : Int) -> Float {
  if phase == 0 {
    2.0
  } else if phase == 1 {
    2.5
  } else if phase == 2 {
    3.0
  } else {
    3.5
  }
}
