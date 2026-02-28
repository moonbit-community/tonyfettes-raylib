// Map and wave data

// Map layouts - returns array of strings (20 chars wide, 15 tall)
// Legend: '.' = grass, '#' = path, 'S' = start, 'E' = end, '~' = water, 'R' = rock

///|
pub fn get_map_data(map_idx : Int) -> Array[String] {
  if map_idx == 0 {
    // Map 1: Serpentine - Classic zigzag path
    [
      "....................", "S###................", "...#................", "...#####............",
      ".......#............", ".......####.........", "..........#.........", "..........####......",
      ".............#......", ".............####...", "................#...", "................####",
      "...................E", "....................", "....................",
    ]
  } else if map_idx == 1 {
    // Map 2: Spiral - Enemies spiral inward
    [
      "....................", "S################..", ".................#..", "..#############..#..",
      "..#...........#..#..", "..#..#######..#..#..", "..#..#.....#..#..#..", "..#..#..E..#..#..#..",
      "..#..#.....#..#..#..", "..#..#######..#..#..", "..#...........#..#..", "..#############..#..",
      ".................#..", "..################..", "....................",
    ]
  } else if map_idx == 2 {
    // Map 3: Crossroads - Path crosses itself
    [
      "........S...........", "........#...........", "........#...........", "........####........",
      "...........#........", "...........#........", "S####......####....", "....#.........#....",
      "....#.........#....", "....######....#....", ".........#....#....", ".........######....",
      ".................E..", "....................", "....................",
    ]
  } else if map_idx == 3 {
    // Map 4: Figure-8 - Enemies loop around twice
    [
      "....................", "..S###########......", "..#..........#......", "..#..........#......",
      "..#..........#......", "..#####..#####......", "......#..#..........", "......#..#..........",
      "..#####..#####......", "..#..........#......", "..#..........#......", "..#..........#......",
      "..############E.....", "....................", "....................",
    ]
  } else {
    // Map 5: Fortress - Open field with water hazards
    [
      "....................", ".S##...............", "...#..~~...........", "...####~~..........",
      "......#............", "......####.........", "..~~.....#..~~.....", "..~~.....#..~~.....",
      ".........####......", "............#......", "..........###......", "..........#........",
      "....~~....####E....", "....~~.............", "....................",
    ]
  }
}

// Map info for display

///|
pub fn get_map_info(map_idx : Int) -> @types.MapInfo {
  if map_idx == 0 {
    {
      name: "Serpentine",
      difficulty: 1,
      layout: get_map_data(0),
      description: "Classic zigzag path",
      starting_gold_bonus: 0,
    }
  } else if map_idx == 1 {
    {
      name: "Spiral",
      difficulty: 2,
      layout: get_map_data(1),
      description: "Enemies spiral inward",
      starting_gold_bonus: 50,
    }
  } else if map_idx == 2 {
    {
      name: "Crossroads",
      difficulty: 2,
      layout: get_map_data(2),
      description: "Paths cross each other",
      starting_gold_bonus: 25,
    }
  } else if map_idx == 3 {
    {
      name: "Figure-8",
      difficulty: 3,
      layout: get_map_data(3),
      description: "Looping double path",
      starting_gold_bonus: 75,
    }
  } else {
    {
      name: "Fortress",
      difficulty: 3,
      layout: get_map_data(4),
      description: "Open field with hazards",
      starting_gold_bonus: 100,
    }
  }
}

// Wave definitions - 30 waves

///|
pub fn get_wave_def(wave : Int) -> (Int, Int, Float, Float) {
  // Returns (enemy_kind, count, hp_mult, speed_mult)
  if wave == 0 {
    (0, 8, 1.0, 1.0)
  } else if wave == 1 {
    (0, 12, 1.0, 1.0)
  } else if wave == 2 {
    (1, 8, 1.0, 1.0)
  } else if wave == 3 {
    (0, 15, 1.3, 1.0)
  } else if wave == 4 {
    (2, 5, 1.0, 1.0)
  } else if wave == 5 {
    (6, 20, 0.8, 1.2)
  } else if wave == 6 {
    (1, 15, 1.0, 1.2)
  } else if wave == 7 {
    (3, 6, 1.0, 1.0)
  } else if wave == 8 {
    (5, 4, 1.0, 0.9)
  } else if wave == 9 {
    (4, 1, 1.0, 0.7)
  } else if wave == 10 {
    (0, 25, 2.0, 1.1)
  } else if wave == 11 {
    (7, 6, 1.5, 0.9)
  } else if wave == 12 {
    (8, 8, 1.2, 1.3)
  } else if wave == 13 {
    (9, 5, 1.5, 1.0)
  } else if wave == 14 {
    (4, 2, 1.5, 0.8)
  } else if wave == 15 {
    (6, 35, 1.0, 1.3)
  } else if wave == 16 {
    (2, 12, 2.5, 1.0)
  } else if wave == 17 {
    (3, 15, 2.0, 1.2)
  } else if wave == 18 {
    (5, 8, 2.0, 1.0)
  } else if wave == 19 {
    (4, 3, 2.0, 0.8)
  } else if wave == 20 {
    (1, 30, 2.5, 1.5)
  } else if wave == 21 {
    (7, 10, 2.5, 1.0)
  } else if wave == 22 {
    (9, 8, 2.5, 1.1)
  } else if wave == 23 {
    (8, 12, 2.0, 1.5)
  } else if wave == 24 {
    (4, 4, 2.5, 0.9)
  } else if wave == 25 {
    (6, 50, 1.5, 1.5)
  } else if wave == 26 {
    (2, 20, 3.5, 1.0)
  } else if wave == 27 {
    (3, 20, 3.0, 1.3)
  } else if wave == 28 {
    (5, 12, 3.0, 1.1)
  } else {
    (4, 5, 3.5, 0.9)
  }
}

// Extended wave info for multi-group waves

///|
pub fn get_wave_info(wave : Int) -> @types.WaveInfo {
  if wave == 0 {
    {
      entries: [
        {
          enemy_kind: 0,
          count: 8,
          hp_mult: 1.0,
          speed_mult: 1.0,
          spawn_delay: 0.8,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 0,
      wave_message: "First wave incoming!",
    }
  } else if wave == 4 {
    {
      entries: [
        {
          enemy_kind: 2,
          count: 5,
          hp_mult: 1.0,
          speed_mult: 1.0,
          spawn_delay: 1.2,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 10,
      wave_message: "Heavy enemies approach!",
    }
  } else if wave == 5 {
    {
      entries: [
        {
          enemy_kind: 6,
          count: 20,
          hp_mult: 0.8,
          speed_mult: 1.2,
          spawn_delay: 0.3,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 15,
      wave_message: "Swarm alert!",
    }
  } else if wave == 7 {
    {
      entries: [
        {
          enemy_kind: 3,
          count: 6,
          hp_mult: 1.0,
          speed_mult: 1.0,
          spawn_delay: 1.0,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 15,
      wave_message: "Flyers incoming!",
    }
  } else if wave == 8 {
    {
      entries: [
        {
          enemy_kind: 5,
          count: 4,
          hp_mult: 1.0,
          speed_mult: 0.9,
          spawn_delay: 1.5,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 20,
      wave_message: "Medics on the field!",
    }
  } else if wave == 9 {
    {
      entries: [
        {
          enemy_kind: 4,
          count: 1,
          hp_mult: 1.0,
          speed_mult: 0.7,
          spawn_delay: 2.0,
        },
      ],
      is_boss_wave: true,
      bonus_gold: 50,
      wave_message: "BOSS WAVE!",
    }
  } else if wave == 11 {
    {
      entries: [
        {
          enemy_kind: 7,
          count: 6,
          hp_mult: 1.5,
          speed_mult: 0.9,
          spawn_delay: 1.2,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 20,
      wave_message: "Shielded enemies!",
    }
  } else if wave == 12 {
    {
      entries: [
        {
          enemy_kind: 8,
          count: 8,
          hp_mult: 1.2,
          speed_mult: 1.3,
          spawn_delay: 0.8,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 20,
      wave_message: "Stealth units detected!",
    }
  } else if wave == 13 {
    {
      entries: [
        {
          enemy_kind: 9,
          count: 5,
          hp_mult: 1.5,
          speed_mult: 1.0,
          spawn_delay: 1.5,
        },
      ],
      is_boss_wave: false,
      bonus_gold: 25,
      wave_message: "Splitter enemies!",
    }
  } else if wave == 14 {
    {
      entries: [
        {
          enemy_kind: 4,
          count: 2,
          hp_mult: 1.5,
          speed_mult: 0.8,
          spawn_delay: 3.0,
        },
      ],
      is_boss_wave: true,
      bonus_gold: 75,
      wave_message: "Double BOSS!",
    }
  } else if wave == 19 {
    {
      entries: [
        {
          enemy_kind: 4,
          count: 3,
          hp_mult: 2.0,
          speed_mult: 0.8,
          spawn_delay: 3.0,
        },
      ],
      is_boss_wave: true,
      bonus_gold: 100,
      wave_message: "Triple BOSS!",
    }
  } else if wave == 24 {
    {
      entries: [
        {
          enemy_kind: 4,
          count: 4,
          hp_mult: 2.5,
          speed_mult: 0.9,
          spawn_delay: 2.5,
        },
      ],
      is_boss_wave: true,
      bonus_gold: 125,
      wave_message: "Quad BOSS!",
    }
  } else if wave == 29 {
    {
      entries: [
        {
          enemy_kind: 4,
          count: 5,
          hp_mult: 3.5,
          speed_mult: 0.9,
          spawn_delay: 2.0,
        },
      ],
      is_boss_wave: true,
      bonus_gold: 200,
      wave_message: "FINAL BOSS WAVE!",
    }
  } else {
    let def = get_wave_def(wave)
    {
      entries: [
        {
          enemy_kind: def.0,
          count: def.1,
          hp_mult: def.2,
          speed_mult: def.3,
          spawn_delay: @types.spawn_interval,
        },
      ],
      is_boss_wave: false,
      bonus_gold: @types.wave_completion_bonus,
      wave_message: "Wave \{wave + 1}",
    }
  }
}

///|
pub fn enemy_base_hp(kind : Int) -> Float {
  if kind == 0 {
    30.0
  } else if kind == 1 {
    20.0
  } else if kind == 2 {
    80.0
  } else if kind == 3 {
    25.0
  } else if kind == 4 {
    300.0
  } else if kind == 5 {
    40.0
  } else if kind == 6 {
    12.0
  } else if kind == 7 {
    60.0
  } else if kind == 8 {
    22.0
  } else if kind == 9 {
    50.0
  } else {
    30.0
  }
}

///|
pub fn enemy_base_speed(kind : Int) -> Float {
  if kind == 0 {
    2.5
  } else if kind == 1 {
    4.0
  } else if kind == 2 {
    1.5
  } else if kind == 3 {
    3.0
  } else if kind == 4 {
    1.2
  } else if kind == 5 {
    2.0
  } else if kind == 6 {
    3.5
  } else if kind == 7 {
    1.8
  } else if kind == 8 {
    3.2
  } else if kind == 9 {
    2.2
  } else {
    2.5
  }
}

///|
pub fn enemy_gold_value(kind : Int) -> Int {
  if kind == 0 {
    10
  } else if kind == 1 {
    12
  } else if kind == 2 {
    25
  } else if kind == 3 {
    15
  } else if kind == 4 {
    100
  } else if kind == 5 {
    20
  } else if kind == 6 {
    5
  } else if kind == 7 {
    30
  } else if kind == 8 {
    18
  } else if kind == 9 {
    22
  } else {
    10
  }
}

// Enemy score value (may differ from gold)

///|
pub fn enemy_score_value(kind : Int) -> Int {
  if kind == 0 {
    10
  } else if kind == 1 {
    15
  } else if kind == 2 {
    30
  } else if kind == 3 {
    20
  } else if kind == 4 {
    200
  } else if kind == 5 {
    25
  } else if kind == 6 {
    5
  } else if kind == 7 {
    35
  } else if kind == 8 {
    25
  } else if kind == 9 {
    30
  } else {
    10
  }
}

// Check if enemy type is flying

///|
pub fn enemy_is_flying(kind : Int) -> Bool {
  kind == 3
}

// Check if enemy type is a boss

///|
pub fn enemy_is_boss(kind : Int) -> Bool {
  kind == 4
}

// Check if enemy type is camo

///|
pub fn enemy_is_camo(kind : Int) -> Bool {
  kind == 8
}

// Check if enemy type spawns children on death

///|
pub fn enemy_spawns_children(kind : Int) -> Bool {
  kind == 9
}

// Check if enemy type heals others

///|
pub fn enemy_is_healer(kind : Int) -> Bool {
  kind == 5
}

// Check if enemy type has shield

///|
pub fn enemy_has_shield(kind : Int) -> Bool {
  kind == 7
}

// Get shield HP for shield enemies

///|
pub fn enemy_shield_hp(kind : Int, hp_mult : Float) -> Float {
  if kind == 7 {
    let base_hp = enemy_base_hp(kind) * hp_mult
    base_hp * @types.shield_max_pct
  } else {
    0.0
  }
}
