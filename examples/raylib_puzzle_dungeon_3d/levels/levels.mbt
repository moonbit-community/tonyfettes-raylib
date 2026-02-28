// Level data for 30 floors across 5 worlds
// Legend:
// '#' = wall, '.' = floor, 'P' = player start, 'B' = block, 'O' = plate (pressure)
// 'E' = exit, 'D' = diamond, 'K' = key, 'I' = ice, 'T' = teleport A, 'U' = teleport B
// 'C' = cracked floor, 'X' = pit, 'S' = switch
// '^' = conveyor up, '>' = conveyor right, 'v' = conveyor down, '<' = conveyor left
// 'b' = bridge off, 'w' = bridge on, 'G' = gate closed
// '/' = mirror NE, '\' = mirror NW
// 'L' = laser source right, 'J' = laser source down, 'H' = laser source left, 'F' = laser source up
// 'Q' = laser target, 'R' = rotate platform

///|
pub fn get_floor_data(floor : Int) -> Array[String] {
  if floor == 0 {
    // World 1 Floor 1: Tutorial - push block onto plate
    [
      "############", "#..........#", "#..........#", "#..P.......#", "#..........#",
      "#.....B....#", "#..........#", "#......O...#", "#..........#", "#.........E#",
      "#..........#", "############",
    ]
  } else if floor == 1 {
    // World 1 Floor 2: Two blocks two plates
    [
      "############", "#..........#", "#.P........#", "#..........#", "#...B..B...#",
      "#..........#", "#..O....O..#", "#..........#", "#..........#", "#.........E#",
      "#..........#", "############",
    ]
  } else if floor == 2 {
    // World 1 Floor 3: Corridor puzzle with walls
    [
      "############", "#P.........#", "#.####.....#", "#....#.B...#", "#.O..#.....#",
      "#....#.....#", "#.####.....#", "#..........#", "#......O.B.#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 3 {
    // World 1 Floor 4: Diamond collection
    [
      "############", "#P.........#", "#..D.......#", "#..........#", "#.....D....#",
      "#..........#", "#..........#", "#.......D..#", "#..........#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 4 {
    // World 1 Floor 5: Pit hazards with block bridge
    [
      "############", "#P.........#", "#..........#", "#..XX......#", "#..X.......#",
      "#.....B.B..#", "#..........#", "#.....O....#", "#..........#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 5 {
    // World 1 Floor 6: Complex block puzzle with cracked floor
    [
      "############", "#P...#.....#", "#....#.....#", "#.B..#..B..#", "#....#.....#",
      "#..###.....#", "#...CCC....#", "#..O...O...#", "#..........#", "#.....O....#",
      "#.........E#", "############",
    ]
  } else if floor == 6 {
    // World 2 Floor 1: Ice introduction
    [
      "############", "#P.........#", "#..........#", "#...IIII...#", "#...I..I...#",
      "#...I.BI...#", "#...IIII...#", "#..........#", "#.....O....#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 7 {
    // World 2 Floor 2: Ice corridor sliding
    [
      "############", "#P.........#", "#.IIIIII...#", "#.I........#", "#.I..B.....#",
      "#.I........#", "#.IIIIII...#", "#..........#", "#......O...#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 8 {
    // World 2 Floor 3: Multi-block ice with diamonds
    [
      "############", "#P.........#", "#..IIIIII..#", "#..I.D..I..#", "#..I.BB.I..#",
      "#..I..D.I..#", "#..IIIIII..#", "#..........#", "#...O..O...#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 9 {
    // World 2 Floor 4: Ice puzzle advanced
    [
      "############", "#P.........#", "#.III......#", "#.I.I......#", "#.IBI......#",
      "#.III......#", "#..........#", "#...III....#", "#...IOI....#", "#...III....#",
      "#.........E#", "############",
    ]
  } else if floor == 10 {
    // World 2 Floor 5: Ice diamond run
    [
      "############", "#P.........#", "#..IIIIII..#", "#..I.D..I..#", "#..I....I..#",
      "#..I..D.I..#", "#..IIIIII..#", "#..........#", "#..D....D..#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 11 {
    // World 2 Floor 6: Teleporter and ice combo
    [
      "############", "#P.........#", "#..T.......#", "#..III.....#", "#..I.I.....#",
      "#..IBI.....#", "#..III.....#", "#.......U..#", "#.....O....#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 12 {
    // World 3 Floor 1: Conveyor introduction
    [
      "############", "#P.........#", "#..........#", "#..B.......#", "#..>>>O....#",
      "#..........#", "#..........#", "#..........#", "#..........#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 13 {
    // World 3 Floor 2: Switch and bridge puzzle
    [
      "############", "#P.........#", "#..........#", "#..S.......#", "#..........#",
      "#....bbb...#", "#..........#", "#.....B....#", "#......O...#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 14 {
    // World 3 Floor 3: Conveyor maze with blocks
    [
      "############", "#P.........#", "#..........#", "#..B..>>.O.#", "#..........#",
      "#..vv......#", "#..........#", "#..B..>>.O.#", "#..........#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 15 {
    // World 3 Floor 4: Mixed hazards with spikes and conveyors
    [
      "############", "#P...#.....#", "#....#.D...#", "#.B..#.....#", "#....##.##.#",
      "#..........#", "#..XX......#", "#..>>>.....#", "#..O...O...#", "#.....D....#",
      "#.........E#", "############",
    ]
  } else if floor == 16 {
    // World 3 Floor 5: Conveyor circuit
    [
      "############", "#P.........#", "#..........#", "#..>>v.....#", "#..^.v.B...#",
      "#..^<<.....#", "#..........#", "#.....O....#", "#..........#", "#..D.......#",
      "#.........E#", "############",
    ]
  } else if floor == 17 {
    // World 3 Floor 6: Switch with spikes and gate
    [
      "############", "#P.........#", "#..........#", "#..S.......#", "#..........#",
      "#.....B....#", "#..........#", "#......O...#", "#..........#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 18 {
    // World 4 Floor 1: Mirror and laser introduction
    [
      "############", "#P.........#", "#..........#", "#L.........#", "#..........#",
      "#..../.....#", "#..........#", "#..........#", "#..........#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 19 {
    // World 4 Floor 2: Laser target puzzle
    [
      "############", "#P.........#", "#..........#", "#L.../..Q..#", "#..........#",
      "#..........#", "#..........#", "#..B.......#", "#..O.......#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 20 {
    // World 4 Floor 3: Multi-mirror laser path
    [
      "############", "#P.........#", "#..........#", "#L.........#", "#.....\\....#",
      "#..........#", "#......\\...#", "#..........#", "#.......Q..#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 21 {
    // World 4 Floor 4: Garden with flowers and mirrors
    [
      "############", "#P.........#", "#..........#", "#..D.......#", "#L.../..Q..#",
      "#..........#", "#.....D....#", "#..B.......#", "#..O.......#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 22 {
    // World 4 Floor 5: Rotating platform with mirrors
    [
      "############", "#P.........#", "#..........#", "#L.../.....#", "#..........#",
      "#....R.....#", "#..........#", "#..........#", "#......Q...#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 23 {
    // World 4 Floor 6: Complex garden laser puzzle
    [
      "############", "#P.........#", "#..........#", "#L.../.....#", "#..........#",
      "#.....\\..Q.#", "#..........#", "#...B..O...#", "#...D......#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 24 {
    // World 5 Floor 1: Teleporter introduction in void
    [
      "############", "#P.........#", "#..........#", "#..T.......#", "#..........#",
      "#..........#", "#.......U..#", "#..........#", "#..B...O...#", "#..........#",
      "#.........E#", "############",
    ]
  } else if floor == 25 {
    // World 5 Floor 2: Mixed everything - blocks and teleporters
    [
      "############", "#P.........#", "#.D.I..T...#", "#..........#", "#.B..XX....#",
      "#..........#", "#.....U..C.#", "#..........#", "#.O........#", "#.....D....#",
      "#.........E#", "############",
    ]
  } else if floor == 26 {
    // World 5 Floor 3: Spiral
    [
      "############", "#P.........#", "#.########.#", "#.#......#.#", "#.#.####.#.#",
      "#.#.#B.#.#.#", "#.#.#..#.#.#", "#.#.####.#.#", "#.#......#.#", "#.###O####.#",
      "#.........E#", "############",
    ]
  } else if floor == 27 {
    // World 5 Floor 4: Triple threat
    [
      "############", "#P.........#", "#..........#", "#.B..B..B..#", "#..........#",
      "#..........#", "#..........#", "#.O..O..O..#", "#..........#", "#..D..D..D.#",
      "#.........E#", "############",
    ]
  } else if floor == 28 {
    // World 5 Floor 5: Gauntlet with all mechanics
    [
      "############", "#P...#.....#", "#.D..#..D..#", "#..B.#.B...#", "#....#.....#",
      "#.####.##..#", "#..........#", "#.O..O.....#", "#......XX..#", "#..D.......#",
      "#.........E#", "############",
    ]
  } else {
    // World 5 Floor 6: Final floor - grand challenge
    [
      "############", "#P.........#", "#.B.B.B.B..#", "#..........#", "#..D..D....#",
      "#..........#", "#.O.O.O.O..#", "#..........#", "#..D..D....#", "#..........#",
      "#.........E#", "############",
    ]
  }
}

// Floor names organized by world

///|
pub fn get_floor_name(floor : Int) -> String {
  if floor == 0 {
    "First Steps"
  } else if floor == 1 {
    "Double Duty"
  } else if floor == 2 {
    "Corridor"
  } else if floor == 3 {
    "Gem Hunt"
  } else if floor == 4 {
    "Pit Stop"
  } else if floor == 5 {
    "Crumble Maze"
  } else if floor == 6 {
    "Ice Flow"
  } else if floor == 7 {
    "Ice Trail"
  } else if floor == 8 {
    "Frozen Lock"
  } else if floor == 9 {
    "Ice Maze"
  } else if floor == 10 {
    "Icy Gems"
  } else if floor == 11 {
    "Warp Chill"
  } else if floor == 12 {
    "Conveyor Belt"
  } else if floor == 13 {
    "Bridge Works"
  } else if floor == 14 {
    "Lava Lanes"
  } else if floor == 15 {
    "Hazard Mix"
  } else if floor == 16 {
    "Hot Circuit"
  } else if floor == 17 {
    "Switch Play"
  } else if floor == 18 {
    "First Light"
  } else if floor == 19 {
    "Laser Target"
  } else if floor == 20 {
    "Reflection"
  } else if floor == 21 {
    "Bloom Path"
  } else if floor == 22 {
    "Spin Mirror"
  } else if floor == 23 {
    "Garden Beam"
  } else if floor == 24 {
    "Warp Zone"
  } else if floor == 25 {
    "Everything"
  } else if floor == 26 {
    "Spiral"
  } else if floor == 27 {
    "Triple Threat"
  } else if floor == 28 {
    "Gauntlet"
  } else {
    "Final Floor"
  }
}

// Par moves for star ratings

///|
pub fn get_par_moves(floor : Int) -> Int {
  if floor == 0 {
    8
  } else if floor == 1 {
    12
  } else if floor == 2 {
    15
  } else if floor == 3 {
    10
  } else if floor == 4 {
    14
  } else if floor == 5 {
    20
  } else if floor == 6 {
    14
  } else if floor == 7 {
    16
  } else if floor == 8 {
    20
  } else if floor == 9 {
    18
  } else if floor == 10 {
    18
  } else if floor == 11 {
    16
  } else if floor == 12 {
    10
  } else if floor == 13 {
    14
  } else if floor == 14 {
    16
  } else if floor == 15 {
    22
  } else if floor == 16 {
    18
  } else if floor == 17 {
    14
  } else if floor == 18 {
    8
  } else if floor == 19 {
    14
  } else if floor == 20 {
    12
  } else if floor == 21 {
    16
  } else if floor == 22 {
    14
  } else if floor == 23 {
    18
  } else if floor == 24 {
    14
  } else if floor == 25 {
    25
  } else if floor == 26 {
    22
  } else if floor == 27 {
    20
  } else if floor == 28 {
    28
  } else {
    30
  }
}

// Get world description text

///|
pub fn get_world_description(world : Int) -> String {
  if world == 0 {
    "Ancient stone halls with push blocks and plates"
  } else if world == 1 {
    "Frozen caverns where everything slides on ice"
  } else if world == 2 {
    "Volcanic fortress with conveyors and bridges"
  } else if world == 3 {
    "Lush gardens with mirrors and laser beams"
  } else if world == 4 {
    "The void between worlds - all mechanics combined"
  } else {
    "Unknown realm"
  }
}

// Get the number of completed levels in a world

///|
pub fn get_world_completion(game : @types.Game, world : Int) -> (Int, Int) {
  let start = world * @types.floors_per_world
  let mut completed = 0
  let total = @types.floors_per_world
  for i = start; i < start + total; i = i + 1 {
    if i < @types.max_floors && game.floor_info[i].completed {
      completed += 1
    }
  }
  (completed, total)
}

// Get total stars for a world

///|
pub fn get_world_stars(game : @types.Game, world : Int) -> (Int, Int) {
  let start = world * @types.floors_per_world
  let mut earned = 0
  let total = @types.floors_per_world * @types.max_stars
  for i = start; i < start + @types.floors_per_world; i = i + 1 {
    if i < @types.max_floors {
      earned += game.floor_info[i].stars
    }
  }
  (earned, total)
}
